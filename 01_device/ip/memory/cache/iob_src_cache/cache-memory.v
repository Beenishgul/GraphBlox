`timescale 1ns / 1ps
`include "iob-cache.vh"

module cache_memory #(
  //memory cache's parameters
  parameter CACHE_FRONTEND_ADDR_W = 32                                                                 , //Address width - width that will used for the cache
  parameter CACHE_FRONTEND_DATA_W = 32                                                                 , //Data width - word size used for the cache
  parameter CACHE_N_WAYS          = 2                                                                  , //Number of Cache Ways
  parameter CACHE_LINE_OFF_W      = 10                                                                 , //Line-Offset Width - 2**NLINE_W total cache lines
  parameter CACHE_WORD_OFF_W      = 3                                                                  , //Word-Offset Width - 2**OFFSET_W total CACHE_FRONTEND_DATA_W words per line
  //Do NOT change - memory cache's parameters - dependency
  parameter CACHE_NWAY_W          = $clog2(CACHE_N_WAYS)                                               , //Cache Ways Width
  parameter CACHE_FRONTEND_NBYTES = CACHE_FRONTEND_DATA_W/8                                            , //Number of Bytes per Word
  parameter CACHE_FRONTEND_BYTE_W = $clog2(CACHE_FRONTEND_NBYTES)                                      , //Offset of the Number of Bytes per Word
  /*---------------------------------------------------*/
  //Higher hierarchy memory (slave) interface parameters
  parameter CACHE_BACKEND_DATA_W  = CACHE_FRONTEND_DATA_W                                              , //Data width of the memory
  parameter CACHE_BACKEND_NBYTES  = CACHE_BACKEND_DATA_W/8                                             , //Number of bytes
  parameter CACHE_BACKEND_BYTE_W  = $clog2(CACHE_BACKEND_NBYTES)                                       , //Offset of the Number of Bytes per Word
  //Do NOT change - slave parameters - dependency
  parameter CACHE_LINE2MEM_W      = CACHE_WORD_OFF_W-$clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W), //burst offset based on the cache and memory word size
  parameter CACHE_WTBUF_DEPTH_W   = 3                                                                  ,
  //Replacement policy (CACHE_N_WAYS > 1)
  parameter CACHE_REP_POLICY      = `PLRU_tree                                                         , //LRU - Least Recently Used; PLRU_mru (1) - mru-based pseudoLRU; PLRU_tree (3) - tree-based pseudoLRU
  // //Controller's options
  parameter CACHE_CTRL_CACHE      = 0                                                                  , //Adds a Controller to the cache, to use functions sent by the master or count the hits and misses
  parameter CACHE_CTRL_CNT        = 0                                                                  , //Counters for Cache Hits and Misses - Disabling this and previous, the Controller only store the buffer states and allows cache invalidation
  // Write-Policy
  parameter CACHE_WRITE_POL       = `WRITE_THROUGH                                                       //write policy: write-through (0), write-back (1)
) (
  input                                                                                                                  ap_clk       ,
  input                                                                                                                  reset        ,
  //front-end
  input                                                                                                                  valid        ,
  input  [                                                CACHE_FRONTEND_ADDR_W-1:CACHE_BACKEND_BYTE_W+CACHE_LINE2MEM_W] addr         ,
  output [                                                                                    CACHE_FRONTEND_DATA_W-1:0] rdata        ,
  output                                                                                                                 ready        ,
  //stored input value
  input                                                                                                                  valid_reg    ,
  input  [                                                                CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W] addr_reg     ,
  input  [                                                                                    CACHE_FRONTEND_DATA_W-1:0] wdata_reg    ,
  input  [                                                                                    CACHE_FRONTEND_NBYTES-1:0] wstrb_reg    ,
  //back-end write-channel
  output                                                                                                                 write_valid  ,
  output [                               CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W+CACHE_WRITE_POL*CACHE_WORD_OFF_W] write_addr   ,
  output [CACHE_FRONTEND_DATA_W+CACHE_WRITE_POL*(CACHE_FRONTEND_DATA_W*(2**CACHE_WORD_OFF_W)-CACHE_FRONTEND_DATA_W)-1:0] write_wdata  , //write-through[CACHE_FRONTEND_DATA_W]; write-back[CACHE_FRONTEND_DATA_W*2**CACHE_WORD_OFF_W]
  output [                                                                                    CACHE_FRONTEND_NBYTES-1:0] write_wstrb  ,
  input                                                                                                                  write_ready  ,
  //back-end read-channel
  output                                                                                                                 replace_valid,
  output [                                                CACHE_FRONTEND_ADDR_W-1:CACHE_BACKEND_BYTE_W+CACHE_LINE2MEM_W] replace_addr ,
  input                                                                                                                  replace      ,
  input                                                                                                                  read_valid   ,
  input  [                                                                                         CACHE_LINE2MEM_W-1:0] read_addr    ,
  input  [                                                                                     CACHE_BACKEND_DATA_W-1:0] read_rdata   ,
  //cache-control
  input                                                                                                                  invalidate   ,
  output                                                                                                                 wtbuf_full   ,
  output                                                                                                                 wtbuf_empty  ,
  output                                                                                                                 write_hit    ,
  output                                                                                                                 write_miss   ,
  output                                                                                                                 read_hit     ,
  output                                                                                                                 read_miss
);


localparam TAG_W = CACHE_FRONTEND_ADDR_W - (CACHE_FRONTEND_BYTE_W + CACHE_WORD_OFF_W + CACHE_LINE_OFF_W);

wire hit;

//cache-memory internal signals
wire [CACHE_N_WAYS-1:0] way_hit, way_select;

wire [           TAG_W-1:0] tag       = addr_reg[CACHE_FRONTEND_ADDR_W-1       -:TAG_W     ]      ; //so the tag doesnt update during ready on a read-access, losing the current hit status (can take the 1 clock-cycle delay)
wire [CACHE_LINE_OFF_W-1:0] index     = addr    [CACHE_FRONTEND_ADDR_W-TAG_W-1 -:CACHE_LINE_OFF_W]; //cant wait, doesnt update during a write-access
wire [CACHE_LINE_OFF_W-1:0] index_reg = addr_reg[CACHE_FRONTEND_ADDR_W-TAG_W-1 -:CACHE_LINE_OFF_W]; //cant wait, doesnt update during a write-access
wire [CACHE_WORD_OFF_W-1:0] offset    = addr_reg[CACHE_FRONTEND_BYTE_W         +:CACHE_WORD_OFF_W]; //so the offset doesnt update during ready on a read-access (can take the 1 clock-cycle delay)


wire [CACHE_N_WAYS*(2**CACHE_WORD_OFF_W)*CACHE_FRONTEND_DATA_W-1:0] line_rdata;
wire [                                      CACHE_N_WAYS*TAG_W-1:0] line_tag  ;
reg  [                      CACHE_N_WAYS*(2**CACHE_LINE_OFF_W)-1:0] v_reg     ;
reg  [                                            CACHE_N_WAYS-1:0] v         ;



reg [(2**CACHE_WORD_OFF_W)*CACHE_FRONTEND_NBYTES-1:0] line_wstrb;

wire write_access = |wstrb_reg & valid_reg ;
wire read_access  = ~|wstrb_reg & valid_reg; //signal mantains the access 1 addition clock-cycle after ready is asserted


//back-end write channel
wire                                                                                                   buffer_empty, buffer_full;
wire [CACHE_FRONTEND_NBYTES+(CACHE_FRONTEND_ADDR_W-CACHE_FRONTEND_BYTE_W)+(CACHE_FRONTEND_DATA_W)-1:0] buffer_dout ;

//for write-back write-allocate only
reg [                      CACHE_N_WAYS-1:0] dirty    ;
reg [CACHE_N_WAYS*(2**CACHE_LINE_OFF_W)-1:0] dirty_reg;


generate
  if(CACHE_WRITE_POL == `WRITE_THROUGH) begin

    localparam FIFO_DATA_W = CACHE_FRONTEND_ADDR_W-CACHE_FRONTEND_BYTE_W + CACHE_FRONTEND_DATA_W + CACHE_FRONTEND_NBYTES;
    localparam FIFO_ADDR_W = CACHE_WTBUF_DEPTH_W                                                                        ;

    wire                   mem_w_en  ;
    wire [FIFO_ADDR_W-1:0] mem_w_addr;
    wire [FIFO_DATA_W-1:0] mem_w_data;

    wire                   mem_r_en  ;
    wire [FIFO_ADDR_W-1:0] mem_r_addr;
    wire [FIFO_DATA_W-1:0] mem_r_data;

    // FIFO memory
    iob_ram_2p #(
      .DATA_W(FIFO_DATA_W),
      .ADDR_W(FIFO_ADDR_W)
    ) iob_ram_2p0 (
      .ap_clk(ap_clk    ),
      .rstb  (reset     ),
      
      .w_en  (mem_w_en  ),
      .w_addr(mem_w_addr),
      .w_data(mem_w_data),
      
      .r_en  (mem_r_en  ),
      .r_addr(mem_r_addr),
      .r_data(mem_r_data)
    );

    iob_fifo_sync #(
      .R_DATA_W(FIFO_DATA_W),
      .W_DATA_W(FIFO_DATA_W),
      .ADDR_W  (FIFO_ADDR_W)
    ) write_throught_buffer (
      .ap_clk        (ap_clk                        ),
      .rst           (reset                         ),
      .arst          (reset                         ),
      
      .ext_mem_w_en  (mem_w_en                      ),
      .ext_mem_w_addr(mem_w_addr                    ),
      .ext_mem_w_data(mem_w_data                    ),
      
      .ext_mem_r_en  (mem_r_en                      ),
      .ext_mem_r_addr(mem_r_addr                    ),
      .ext_mem_r_data(mem_r_data                    ),
      
      .level         (                              ),
      
      .r_data        (buffer_dout                   ),
      .r_empty       (buffer_empty                  ),
      .r_en          (write_ready                   ),
      
      .w_data        ({addr_reg,wdata_reg,wstrb_reg}),
      .w_full        (buffer_full                   ),
      .w_en          (write_access & ready          )
    );

    //buffer status
    assign wtbuf_full  = buffer_full;
    assign wtbuf_empty = buffer_empty & write_ready & ~write_valid;

    //back-end write channel
    assign write_valid = ~buffer_empty;
    assign write_addr  = buffer_dout[CACHE_FRONTEND_NBYTES + CACHE_FRONTEND_DATA_W +: CACHE_FRONTEND_ADDR_W - CACHE_FRONTEND_BYTE_W];
    assign write_wdata = buffer_dout[CACHE_FRONTEND_NBYTES             +: CACHE_FRONTEND_DATA_W            ];
    assign write_wstrb = buffer_dout[0                     +: CACHE_FRONTEND_NBYTES            ];


    //back-end read channel
    assign replace_valid = (~hit & read_access & ~replace) & (buffer_empty & write_ready);
    assign replace_addr  = addr[CACHE_FRONTEND_ADDR_W -1:CACHE_BACKEND_BYTE_W+CACHE_LINE2MEM_W];

  end
  else begin // if (CACHE_WRITE_POL == WRITE_BACK)

    //back-end write channel
    assign write_wstrb = {CACHE_FRONTEND_NBYTES{1'bx}};
    //write_valid, write_addr and write_wdata assigns are generated bellow (dependencies)

    //back-end read channel
    assign replace_valid = (~|way_hit) & (write_ready) & valid_reg & ~replace;
    assign replace_addr  = addr[CACHE_FRONTEND_ADDR_W -1:CACHE_BACKEND_BYTE_W+CACHE_LINE2MEM_W];

    //buffer status (non-existant)
    `ifdef CTRL_IO
      assign wtbuf_full  = 1'b0;
      assign wtbuf_empty = 1'b1;
    `else
      assign wtbuf_full  = 1'bx;
      assign wtbuf_empty = 1'bx;
    `endif

  end
endgenerate


//////////////////////////////////////////////////////
// Read-After-Write (RAW) Hazard (pipeline) control
//////////////////////////////////////////////////////
wire                        raw           ;
reg                         write_hit_prev;
reg  [CACHE_WORD_OFF_W-1:0] offset_prev   ;
reg  [    CACHE_N_WAYS-1:0] way_hit_prev  ;

generate
  if (CACHE_WRITE_POL == `WRITE_THROUGH) begin
    always @(posedge ap_clk) begin
      write_hit_prev <= write_access & (|way_hit);
      //previous write position
      offset_prev    <= offset;
      way_hit_prev   <= way_hit;
    end
    assign raw = write_hit_prev & (way_hit_prev == way_hit) & (offset_prev == offset);
  end
  else begin //// if (CACHE_WRITE_POL == WRITE_BACK)
    always @(posedge ap_clk) begin
      write_hit_prev <= write_access; //all writes will have the data in cache in the end
      //previous write position
      offset_prev    <= offset;
      way_hit_prev   <= way_hit;
    end
    assign raw = write_hit_prev & (way_hit_prev == way_hit) & (offset_prev == offset) & read_access; //without read_access it is an infinite replacement loop
  end
endgenerate


///////////////////////////////////////////////////////////////
// Hit signal: data available and in the memory's output
///////////////////////////////////////////////////////////////
assign hit = |way_hit & ~replace & (~raw);


/////////////////////////////////
//front-end READY signal
/////////////////////////////////
generate
  if (CACHE_WRITE_POL == `WRITE_THROUGH)
    assign ready = (hit & read_access) | (~buffer_full & write_access);
  else // if (CACHE_WRITE_POL == WRITE_BACK)
    assign ready = hit & valid_reg;
endgenerate

//cache-control hit-miss counters enables
generate
  if(CACHE_CTRL_CACHE & CACHE_CTRL_CNT)
    begin
      //cache-control hit-miss counters enables
      assign write_hit  = ready & ( hit & write_access);
      assign write_miss = ready & (~hit & write_access);
      assign read_hit   = ready & ( hit &  read_access);
      assign read_miss  = replace_valid;//will also subtract read_hit
    end
  else
    begin
      assign write_hit = 1'bx;
      assign write_miss = 1'bx;
      assign read_hit   = 1'bx;
      assign read_miss  = 1'bx;
    end // else: !if(CACHE_CTRL & CACHE_CTRL_CNT)
endgenerate


////////////////////////////////////////
//Memories implementation configurations
////////////////////////////////////////
genvar                                                   i,j,k;
generate

  //Data-Memory
  for (k = 0; k < CACHE_N_WAYS; k=k+1) begin : n_ways_block
    for(j = 0; j < 2**CACHE_LINE2MEM_W; j=j+1) begin : line2mem_block
      for(i = 0; i < CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W; i=i+1) begin : BE_FE_block
        iob_gen_sp_ram
          #(
            .DATA_W(CACHE_FRONTEND_DATA_W),
            .ADDR_W(CACHE_LINE_OFF_W)
          ) cache_memory (
            .ap_clk (ap_clk),
            .reset(reset),
            .en  (valid),
            .we ({CACHE_FRONTEND_NBYTES{way_hit[k]}} & line_wstrb[(j*(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W)+i)*CACHE_FRONTEND_NBYTES +: CACHE_FRONTEND_NBYTES]),
            .addr((write_access & way_hit[k] & ((j*(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W)+i) == offset))? index_reg : index),
            .data_in ((replace)? read_rdata[i*CACHE_FRONTEND_DATA_W +: CACHE_FRONTEND_DATA_W] : wdata_reg),
            .data_out(line_rdata[(k*(2**CACHE_WORD_OFF_W)+j*(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W)+i)*CACHE_FRONTEND_DATA_W +: CACHE_FRONTEND_DATA_W])
          );
      end
    end
  end

  //Cache Line Write Strobe
  if(CACHE_LINE2MEM_W > 0)
    begin
      always @*
        if(replace)
          line_wstrb = {CACHE_BACKEND_NBYTES{read_valid}} << (read_addr*CACHE_BACKEND_NBYTES); //line-replacement: read_addr indexes the words in cache-line
        else
          line_wstrb = (wstrb_reg & {CACHE_FRONTEND_NBYTES{write_access}}) << (offset*CACHE_FRONTEND_NBYTES);
      end
    else
      begin
        always @*
        if(replace)
          line_wstrb = {CACHE_BACKEND_NBYTES{read_valid}}; //line-replacement: mem's word replaces entire line
        else
          line_wstrb = (wstrb_reg & {CACHE_FRONTEND_NBYTES{write_access}}) << (offset*CACHE_FRONTEND_NBYTES);
      end // else: !if(CACHE_LINE2MEM_W > 0)


    // Valid-Tag memories & replacement-policy
    if(CACHE_N_WAYS > 1)
      begin

        wire [CACHE_NWAY_W-1:0] way_hit_bin, way_select_bin; //reason for the 2 generates for single vs multiple ways
        //valid-memory
        always @ (posedge ap_clk) begin
          if (reset)
            v_reg <= 0;
          else if (invalidate)
            v_reg <= 0;
          else if(replace_valid)
            v_reg <= v_reg | (1<<(way_select_bin*(2**CACHE_LINE_OFF_W) + index_reg));
          else
            v_reg <= v_reg;
        end

        for(k = 0; k < CACHE_N_WAYS; k = k+1) begin : tag_mem_block
          //valid-memory output stage register - 1 c.c. read-latency (cleaner simulation during rep.)
          always @(posedge ap_clk)
          if(invalidate)
            v[k] <= 0;
          else
            v[k] <= v_reg [(2**CACHE_LINE_OFF_W)*k + index];

          //tag-memory
          iob_ram_sp
            #(
              .DATA_W(TAG_W),
              .ADDR_W(CACHE_LINE_OFF_W)
            )
            tag_memory
              (
                .ap_clk (ap_clk                           ),
                .rsta  (reset),
                .en  (valid                         ),
                .we  (way_select[k] & replace_valid),
                .addr(index                        ),
                .din (tag                       ),
                .dout(line_tag[TAG_W*k +: TAG_W])
              );


          //Way hit signal - hit or replacement
          assign way_hit[k] = (tag == line_tag[TAG_W*k +: TAG_W]) & v[k];
        end
        //Read Data Multiplexer
        assign rdata [CACHE_FRONTEND_DATA_W-1:0] = line_rdata >> CACHE_FRONTEND_DATA_W*(offset + (2**CACHE_WORD_OFF_W)*way_hit_bin);


        //replacement-policy module
        replacement_policy #(
          .CACHE_N_WAYS    (CACHE_N_WAYS    ),
          .CACHE_LINE_OFF_W(CACHE_LINE_OFF_W),
          .CACHE_REP_POLICY(CACHE_REP_POLICY)
        )
        replacement_policy_algorithm
          (
            .ap_clk       (ap_clk             ),
            .reset     (reset|invalidate),
            .write_en  (ready           ),
            .way_hit   (way_hit         ),
            .line_addr (index_reg       ),
            .way_select(way_select      ),
            .way_select_bin(way_select_bin)
          );

        //onehot-to-binary for way-hit
        onehot_to_bin #(
          .BIN_W (CACHE_NWAY_W)
        )
        way_hit_encoder
          (
            .onehot(way_hit[CACHE_N_WAYS-1:1]),
            .bin   (way_hit_bin)
          );

        //dirty-memory
        if(CACHE_WRITE_POL == `WRITE_BACK)
          begin
            always @ (posedge ap_clk) begin
              if (reset)
                dirty_reg <= 0;
              else if(write_valid)
                dirty_reg <= dirty_reg & ~(1<<(way_select_bin*(2**CACHE_LINE_OFF_W) + index_reg));// updates position with 0
              else if(write_access & hit)
                dirty_reg <= dirty_reg |  (1<<(way_hit_bin*(2**CACHE_LINE_OFF_W) + index_reg));//updates position with 1
              else
                dirty_reg <= dirty_reg;
            end

            for(k = 0; k < CACHE_N_WAYS; k = k+1) begin : dirty_block
              //valid-memory output stage register - 1 c.c. read-latency (cleaner simulation during rep.)
              always @(posedge ap_clk)
              dirty[k] <= dirty_reg [(2**CACHE_LINE_OFF_W)*k + index];
            end


            //flush line
            assign write_valid = valid_reg & ~(|way_hit) & (way_select == dirty); //flush if there is not a hit, and the way selected is dirty
            wire [TAG_W-1:0] tag_flush = line_tag >> (way_select_bin*TAG_W);      //auxiliary wire
            assign write_addr  = {tag_flush, index_reg};                          //the position of the current block in cache (not of the access)
            assign write_wdata = line_rdata >> (way_select_bin*CACHE_FRONTEND_DATA_W*(2**CACHE_WORD_OFF_W));



          end // if (CACHE_WRITE_POL == WRITE_BACK)

      end
    else // (CACHE_N_WAYS = 1)
      begin
        //valid-memory
        always @ (posedge ap_clk)
        begin
          if (reset)
            v_reg <= 0;
          else if (invalidate)
            v_reg <= 0;
          else if(replace_valid)
            v_reg <= v_reg | (1 << index);
          else
            v_reg <= v_reg;
        end

        //valid-memory output stage register - 1 c.c. read-latency (cleaner simulation during rep.)
        always @(posedge ap_clk)
        if(invalidate)
          v <= 0;
        else
          v <= v_reg [index];

        //tag-memory
        iob_ram_sp
          #(
            .DATA_W(TAG_W),
            .ADDR_W(CACHE_LINE_OFF_W)
          )
          tag_memory
            (
              .ap_clk (ap_clk),
              .rsta  (reset),
              .en  (valid),
              .we  (replace_valid),
              .addr(index),
              .din (tag),
              .dout(line_tag)
            );


        //Cache hit signal that indicates which way has had the hit (also during replacement)
        assign way_hit = (tag == line_tag) & v;

        //Read Data Multiplexer
        assign rdata [CACHE_FRONTEND_DATA_W-1:0] = line_rdata >> CACHE_FRONTEND_DATA_W*offset;

        //dirty-memory
        if(CACHE_WRITE_POL == `WRITE_BACK)
          begin
            //dirty-memory
            always @ (posedge ap_clk) begin
              if (reset)
                dirty_reg <= 0;
              else if(write_valid)
                dirty_reg <= dirty_reg & ~(1<<(index_reg)); //updates postion with 0
              else if(write_access & hit)
                dirty_reg <= dirty_reg | (1<<(index_reg)); //updates position with 1 (needs to be index_reg otherwise updates the new index if the previous access was a write)
              else
                dirty_reg <= dirty_reg;
            end

            always @(posedge ap_clk)
            dirty <= dirty_reg [index];

            //flush line
            assign write_valid = valid_reg & ~(way_hit) & dirty;
            //assign write_valid = write_access & ~(way_hit) & dirty; //flush if there is not a hit, and is dirty
            assign write_addr  = {line_tag, index};                 //the position of the current block in cache (not of the access)
            assign write_wdata = line_rdata;

          end // if (CACHE_WRITE_POL == WRITE_BACK)
      end // else: !if(CACHE_N_WAYS > 1)
  endgenerate

  endmodule // cache_memory


/*---------------------------------*/
/* Byte-width generable iob-sp-ram */
/*---------------------------------*/

//For cycle that generated byte-width (single enable) single-port SRAM
//older synthesis tool may require this approch

module iob_gen_sp_ram #(
  parameter DATA_W = 32,
  parameter ADDR_W = 10
) (
  input                 ap_clk  ,
  input                 reset   ,
  input                 en      ,
  input  [DATA_W/8-1:0] we      ,
  input  [  ADDR_W-1:0] addr    ,
  output [  DATA_W-1:0] data_out,
  input  [  DATA_W-1:0] data_in
);

      genvar                                i;
      generate
        for (i = 0; i < (DATA_W/8); i = i + 1)
          begin : ram
            iob_ram_sp
              #(
                .DATA_W(8),
                .ADDR_W(ADDR_W)
              )
              iob_cache_mem
                (
                  .ap_clk (ap_clk),
                  .rsta  (reset),
                  .en  (en),
                  .we  (we[i]),
                  .addr(addr),
                  .dout(data_out[8*i +: 8]),
                  .din (data_in [8*i +: 8])
                );
          end
      endgenerate

    endmodule // iob_gen_sp_ram
