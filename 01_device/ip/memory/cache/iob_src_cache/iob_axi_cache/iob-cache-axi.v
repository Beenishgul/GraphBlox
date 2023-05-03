`timescale 1ns / 1ps
`include "iob_lib.vh"
`include "iob-cache.vh"

module iob_cache_axi #(
  //memory cache's parameters
  parameter                      CACHE_FRONTEND_ADDR_W = 64                           , //Address width - width of the Master's entire access address (including the LSBs that are discarded, but discarding the Controller's)
  parameter                      CACHE_FRONTEND_DATA_W = 512                          , //Data width - word size used for the cache
  parameter                      CACHE_N_WAYS          = 2                            , //Number of Cache Ways (Needs to be Potency of 2: 1, 2, 4, 8, ..)
  parameter                      CACHE_LINE_OFF_W      = 7                            , //Line-Offset Width - 2**NLINE_W total cache lines
  parameter                      CACHE_WORD_OFF_W      = 3                            , //Word-Offset Width - 2**OFFSET_W total CACHE_FRONTEND_DATA_W words per line - WARNING about LINE2MEM_DATA_RATIO_W (can cause word_counter [-1:0]
  parameter                      CACHE_WTBUF_DEPTH_W   = 5                            , //Depth Width of Write-Through Buffer
  //Replacement policy (CACHE_N_WAYS > 1)
  parameter                      CACHE_REP_POLICY      = `PLRU_tree                   , //LRU - Least Recently Used; PLRU_mru (1) - MRU-based pseudoLRU; PLRU_tree (3) - tree-based pseudoLRU
  //Do NOT change - memory cache's parameters - dependency
  parameter                      CACHE_NWAY_W          = $clog2(CACHE_N_WAYS)         , //Cache Ways Width
  parameter                      CACHE_FRONTEND_NBYTES = CACHE_FRONTEND_DATA_W/8      , //Number of Bytes per Word
  parameter                      CACHE_FRONTEND_BYTE_W = $clog2(CACHE_FRONTEND_NBYTES), //Byte Offset
  /*---------------------------------------------------*/
  //Higher hierarchy memory (slave) interface parameters
  parameter                      CACHE_BACKEND_ADDR_W  = CACHE_FRONTEND_ADDR_W        , //Address width of the higher hierarchy memory
  parameter                      CACHE_BACKEND_DATA_W  = CACHE_FRONTEND_DATA_W        , //Data width of the memory
  parameter                      CACHE_BACKEND_NBYTES  = CACHE_BACKEND_DATA_W/8       , //Number of bytes
  parameter                      CACHE_BACKEND_BYTE_W  = $clog2(CACHE_BACKEND_NBYTES) , //Offset of Number of Bytes
  /*---------------------------------------------------*/
  //Write Policy
  parameter                      CACHE_WRITE_POL       = `WRITE_THROUGH               , //write policy: write-through (0), write-back (1)
  /*---------------------------------------------------*/
  //AXI specific parameters
  parameter                      CACHE_AXI_ADDR_W      = CACHE_BACKEND_ADDR_W         ,
  parameter                      CACHE_AXI_DATA_W      = CACHE_BACKEND_DATA_W         ,
  parameter                      CACHE_AXI_ID_W        = 1                            , //AXI ID (identification) width
  parameter                      CACHE_AXI_LEN_W       = 8                            , //AXI ID burst length (log2)
  parameter [CACHE_AXI_ID_W-1:0] CACHE_AXI_ID          = 0                            , //AXI ID value
  //Controller's options
  parameter                      CACHE_CTRL_CACHE      = 0                            , //Adds a Controller to the cache, to use functions sent by the master or count the hits and misses
  parameter                      CACHE_CTRL_CNT        = 1                            , //Counters for Cache Hits and Misses - Disabling this and previous, the Controller only store the buffer states and allows cache invalidation
  parameter                      CACHE_AXI_LOCK_W      = 1                            ,
  parameter                      CACHE_AXI_CACHE_W     = 4                            ,
  parameter                      CACHE_AXI_PROT_W      = 3                            ,
  parameter                      CACHE_AXI_QOS_W       = 4                            ,
  parameter                      CACHE_AXI_BURST_W     = 2                            ,
  parameter                      CACHE_AXI_RESP_W      = 1                            ,
  parameter                      CACHE_AXI_SIZE_W      = 3
) (
  //IOb slave frontend interface
  input                                                                   valid        ,
  `ifdef WORD_ADDR
  input  [CACHE_CTRL_CACHE+CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W] addr         , //MSB is used for Controller selection
  `else
  input  [                    CACHE_CTRL_CACHE+CACHE_FRONTEND_ADDR_W-1:0] addr         , //MSB is used for Controller selection
  `endif
  input  [                                     CACHE_FRONTEND_DATA_W-1:0] wdata        ,
  input  [                                     CACHE_FRONTEND_NBYTES-1:0] wstrb        ,
  output [                                     CACHE_FRONTEND_DATA_W-1:0] rdata        ,
  output                                                                  ready        ,
  `ifdef CTRL_IO
  //control-status io
  input                                                                   force_inv_in , //force 1'b0 if unused
  output                                                                  force_inv_out,
  input                                                                   wtb_empty_in , //force 1'b1 if unused
  output                                                                  wtb_empty_out,
  `endif
  //AXI master backend interface
  `include "m_axi_m_port.vh"
  input                                                                   ap_clk       ,
  input                                                                   reset
);

  //internal signals (front-end inputs)
  wire                                                 data_valid, data_ready;
  wire [CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W] data_addr ;
  wire [                    CACHE_FRONTEND_DATA_W-1:0] data_wdata, data_rdata;
  wire [                    CACHE_FRONTEND_NBYTES-1:0] data_wstrb;
  //stored signals
  wire [CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W] data_addr_reg ;
  wire [                    CACHE_FRONTEND_DATA_W-1:0] data_wdata_reg;
  wire [                    CACHE_FRONTEND_NBYTES-1:0] data_wstrb_reg;
  wire                                                 data_valid_reg;
  //back-end write-channel
  wire                                                                                                                 write_valid;
  wire                                                                                                                 write_ready;
  wire [                               CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W+CACHE_WRITE_POL*CACHE_WORD_OFF_W] write_addr ;
  wire [CACHE_FRONTEND_DATA_W+CACHE_WRITE_POL*(CACHE_FRONTEND_DATA_W*(2**CACHE_WORD_OFF_W)-CACHE_FRONTEND_DATA_W)-1:0] write_wdata;
  wire [                                                                                    CACHE_FRONTEND_NBYTES-1:0] write_wstrb;
  //back-end read-channel
  wire                                                replace_valid, replace;
  wire [CACHE_FRONTEND_ADDR_W-1:CACHE_BACKEND_BYTE_W] replace_addr ;
  wire                                                read_valid   ;
  wire [                    CACHE_BACKEND_DATA_W-1:0] read_rdata   ;
  //cache-control
  wire                                                ctrl_valid, ctrl_ready;
  wire [                            `CTRL_ADDR_W-1:0] ctrl_addr ;
  wire                                                wtbuf_full, wtbuf_empty;
  wire                                                write_hit, write_miss, read_hit, read_miss;
  wire [CACHE_CTRL_CACHE*(CACHE_FRONTEND_DATA_W-1):0] ctrl_rdata;
  wire                                                invalidate;

`ifdef CTRL_IO
  assign force_inv_out = invalidate;

  generate
    if (CACHE_CTRL_CACHE)
      assign wtb_empty_out = wtbuf_empty;
    else
      assign wtb_empty_out = wtbuf_empty & wtb_empty_in; //to remove unconnected port warning. If unused wtb_empty_in = 1'b1
  endgenerate
`endif
   
  front_end #(
    .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),
    .CACHE_CTRL_CACHE     (CACHE_CTRL_CACHE     )
  ) front_end (
    .ap_clk        (ap_clk        ),
    .reset         (reset         ),
    //front-end port
    .valid         (valid         ),
    .addr          (addr          ),
    .wdata         (wdata         ),
    .wstrb         (wstrb         ),
    .rdata         (rdata         ),
    .ready         (ready         ),
    //cache-memory input signals
    .data_valid    (data_valid    ),
    .data_addr     (data_addr     ),
    //cache-memory output
    .data_rdata    (data_rdata    ),
    .data_ready    (data_ready    ),
    //stored input signals
    .data_valid_reg(data_valid_reg),
    .data_addr_reg (data_addr_reg ),
    .data_wdata_reg(data_wdata_reg),
    .data_wstrb_reg(data_wstrb_reg),
    //cache-control
    .ctrl_valid    (ctrl_valid    ),
    .ctrl_addr     (ctrl_addr     ),
    .ctrl_rdata    (ctrl_rdata    ),
    .ctrl_ready    (ctrl_ready    )
  );

  cache_memory #(
    .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),
    .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W ),
    .CACHE_N_WAYS         (CACHE_N_WAYS         ),
    .CACHE_LINE_OFF_W     (CACHE_LINE_OFF_W     ),
    .CACHE_WORD_OFF_W     (CACHE_WORD_OFF_W     ),
    .CACHE_REP_POLICY     (CACHE_REP_POLICY     ),
    .CACHE_WTBUF_DEPTH_W  (CACHE_WTBUF_DEPTH_W  ),
    .CACHE_CTRL_CACHE     (CACHE_CTRL_CACHE     ),
    .CACHE_CTRL_CNT       (CACHE_CTRL_CNT       ),
    .CACHE_WRITE_POL      (CACHE_WRITE_POL      )
  ) cache_memory (
    .ap_clk       (ap_clk                                                 ),
    .reset        (reset                                                  ),
    //front-end
    //internal data signals
    .valid        (data_valid                                             ),
    .addr         (data_addr[CACHE_FRONTEND_ADDR_W-1:CACHE_BACKEND_BYTE_W]),
    //.wdata (data_wdata),
    // .wstrb (data_wstrb),
    .rdata        (data_rdata                                             ),
    .ready        (data_ready                                             ),
    //stored data signals
    .valid_reg    (data_valid_reg                                         ),
    .addr_reg     (data_addr_reg                                          ),
    .wdata_reg    (data_wdata_reg                                         ),
    .wstrb_reg    (data_wstrb_reg                                         ),
    //back-end
    //write-through-buffer (write-channel)
    .write_valid  (write_valid                                            ),
    .write_addr   (write_addr                                             ),
    .write_wdata  (write_wdata                                            ),
    .write_wstrb  (write_wstrb                                            ),
    .write_ready  (write_ready                                            ),
    //cache-line replacement (read-channel)
    .replace_valid(replace_valid                                          ),
    .replace_addr (replace_addr                                           ),
    .replace      (replace                                                ),
    .read_valid   (read_valid                                             ),
    .read_rdata   (read_rdata                                             ),
    //control's signals
    .wtbuf_empty  (wtbuf_empty                                            ),
    .wtbuf_full   (wtbuf_full                                             ),
    .write_hit    (write_hit                                              ),
    .write_miss   (write_miss                                             ),
    .read_hit     (read_hit                                               ),
    .read_miss    (read_miss                                              ),
    `ifdef CTRL_IO
    .invalidate   (invalidate | force_inv_in                              )
    `else
    .invalidate   (invalidate                                             )
    `endif
  );

  back_end_axi #(
    .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),
    .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W ),
    .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W ),
    .CACHE_WORD_OFF_W     (CACHE_WORD_OFF_W     ),
    .CACHE_WRITE_POL      (CACHE_WRITE_POL      ),
    .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W     ),
    .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W     ),
    .CACHE_AXI_ID_W       (CACHE_AXI_ID_W       ),
    .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W      ),
    .CACHE_AXI_ID         (CACHE_AXI_ID         ),
    .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W     ),
    .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W    ),
    .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W     ),
    .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W      ),
    .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W    ),
    .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W     ),
    .CACHE_AXI_SIZE_W     (CACHE_AXI_SIZE_W     )
  ) back_end (
    //write-through-buffer (write-channel)
    .write_valid  (write_valid  ),
    .write_addr   (write_addr   ),
    .write_wdata  (write_wdata  ),
    .write_wstrb  (write_wstrb  ),
    .write_ready  (write_ready  ),
    //cache-line replacement (read-channel)
    .replace_valid(replace_valid),
    .replace_addr (replace_addr ),
    .replace      (replace      ),
    .read_valid   (read_valid   ),
    .read_rdata   (read_rdata   ),
    `include "m_axi_portmap.vh"
    .ap_clk       (ap_clk       ),
    .reset        (reset        )
  );

  generate
    if (CACHE_CTRL_CACHE)

      cache_control
        #(
          .CACHE_FRONTEND_DATA_W  (CACHE_FRONTEND_DATA_W),
          .CACHE_CTRL_CNT   (CACHE_CTRL_CNT)
        )
        cache_control
          (
            .ap_clk      (ap_clk),
            .reset       (reset),
            //control's signals
            .valid       (ctrl_valid),
            .addr        (ctrl_addr),
            //write data
            .wtbuf_full  (wtbuf_full),
            `ifdef CTRL_IO
              .wtbuf_empty (wtbuf_empty & wtb_empty_in),
              `else
              .wtbuf_empty (wtbuf_empty),
              `endif
              .write_hit   (write_hit),
              .write_miss  (write_miss),
              .read_hit    (read_hit),
              .read_miss   (read_miss),
              ////////////
              .rdata       (ctrl_rdata),
              .ready       (ctrl_ready),
              .invalidate  (invalidate)
            );
      else
        begin
          assign ctrl_rdata = 1'bx;
          assign ctrl_ready = 1'bx;
          assign invalidate = 1'b0;
        end // else: !if(CACHE_CTRL_CACHE)

    endgenerate

endmodule // iob_cache_axi
