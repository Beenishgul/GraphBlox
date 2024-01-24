`timescale 1ns / 1ps

`define Sieve
`define DDR4

module tb_memory_BRAM_sieve();

  parameter RANKS = 1;
  parameter CHIPS = 1;
  parameter BGWIDTH = 2;
  parameter BAWIDTH = 2;
  parameter ADDRWIDTH = 17;
  parameter BL = 8; // not sure how to use this
  
  parameter CHWIDTH = 10;
  parameter COLWIDTH = 7;
  parameter DEVICE_WIDTH = 16;
  parameter log_DEVICE_WIDTH = 4;
  
  localparam DQWIDTH = DEVICE_WIDTH*CHIPS; 
  localparam BANKGROUPS = 2**BGWIDTH;
  localparam BANKSPERGROUP = 2**BAWIDTH;
  localparam ROWS = 2**ADDRWIDTH;
  localparam COLS = 2**COLWIDTH;
  localparam CHIPSIZE = (DEVICE_WIDTH*COLS*(ROWS/1024)*BANKSPERGROUP*BANKGROUPS)/(1024); // Mbit
  localparam DIMMSIZE = (CHIPSIZE*CHIPS)/(1024*8); // GB
  localparam tCK = 0.75;


    logic reset_n;
    logic ck2x;
    `ifdef DDR4
    logic ck_c;
    logic ck_t;
    `elsif DDR3
    logic ck_n;
    logic ck_p;
    `endif
    logic cke;
    logic [RANKS-1:0]cs_n;
    `ifdef DDR4 
    //logic act_n;
    `endif
    `ifdef DDR3
    logic ras_n;
    logic cas_n;
    logic we_n;
    `endif
    //logic [ADDRWIDTH-1:0]A;
    logic [BAWIDTH-1:0]ba;
    `ifdef DDR4
    logic [BGWIDTH-1:0]bg; // todo: explore adding one bit that is always ignored
    `endif
    wire [DQWIDTH-1:0]dq;
    logic [DQWIDTH-1:0]dq_reg;
    `ifdef DDR4
    wire [CHIPS-1:0]dqs_c;
    logic [CHIPS-1:0]dqs_c_reg;
    wire [CHIPS-1:0]dqs_t;
    logic [CHIPS-1:0]dqs_t_reg;
    `elsif DDR3
    wire [CHIPS-1:0]dqs_n;
    logic [CHIPS-1:0]dqs_n_reg;
    wire [CHIPS-1:0]dqs_p;
    logic [CHIPS-1:0]dqs_p_reg;
    `endif
    logic odt;
    `ifdef DDR4
    logic parity;
    `endif

    logic sync [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    
    logic writing;
    
    assign dq = (writing) ? dq_reg:{DQWIDTH{1'bZ}};
    assign dqs_c = (writing) ? dqs_c_reg:{CHIPS{1'bZ}};
    assign dqs_t = (writing) ? dqs_t_reg:{CHIPS{1'bZ}};

    //assign dq = (writing) ? dq_reg:{DQWIDTH{1'bZ}};
    //assign dqs_n = (writing) ? dqs_n_reg:{CHIPS{1'bZ}};
    //assign dqs_p = (writing) ? dqs_p_reg:{CHIPS{1'bZ}};
    
// for Sieve and temp wrap

    //logic  [(COLWIDTH+log_DEVICE_WIDTH)-1:0] query_column;
    //logic  [CHWIDTH-1:0] row_address;
    //logic  [CHWIDTH:0] row_address; // so that initial row address is 64
    //logic  [DEVICE_WIDTH*2**COLWIDTH-1:0] match_row;
    //logic  [(COLWIDTH+log_DEVICE_WIDTH)-1:0] match_col;
    logic  match_en;   //unused wire
    logic [COLWIDTH+log_DEVICE_WIDTH-1:0] match_col [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    //logic  ETM;

//DIMM #(.RANKS(RANKS),
DIMM_fsm #(.RANKS(RANKS),
    .CHIPS(CHIPS),
    .BGWIDTH(BGWIDTH),
    .BAWIDTH(BAWIDTH),
    .ADDRWIDTH(ADDRWIDTH),
    .COLWIDTH(COLWIDTH),
    .DEVICE_WIDTH(DEVICE_WIDTH),
    .BL(BL),
    .CHWIDTH(CHWIDTH)
    ) dut (
    .reset_n(reset_n),
    .ck2x(ck2x),
    `ifdef DDR4
    .ck_c(ck_c),
    .ck_t(ck_t),
    `elsif DDR3
    .ck_n(ck_n),
    .ck_p(ck_p),
    `endif
    .cke(cke),
    .cs_n(cs_n),
    `ifndef Sieve
    `ifdef DDR4
    .act_n(act_n), // not needed for ifndef Sieve
    `endif
    `endif
    `ifdef DDR3
    .ras_n(ras_n),
    .cas_n(cas_n),
    .we_n(we_n),
    `endif
    //.A(A), // A fix pattern that gives control to RLU
    .ba(ba),
    `ifdef DDR4
    .bg(bg),
    `endif
    .dq(dq),
    `ifdef DDR4
    .dqs_c(dqs_c),
    .dqs_t(dqs_t),
    `elsif DDR3
    .dqs_n(dqs_n),
    .dqs_p(dqs_p),
    `endif
    .odt(odt),
    `ifdef DDR4
    .parity(parity),
    `endif
    `ifdef Sieve
    .match_en(match_en),
    .match_col(match_col), // added new
    `endif
    .sync(sync)    
    );


    always #(tCK) ck_t = ~ck_t;
    always #(tCK) ck_c = ~ck_c;
    always #(tCK*0.5) ck2x = ~ck2x;
int i,j;

initial
    begin
        
        assign match_en = 1;
    // initialize all inputs
        reset_n = 0; // DRAM is active only when this signal is HIGH
        ck_t = 1;
        ck_c = 0;
        ck2x = 1;
        cke = 1;
        cs_n = {RANKS{1'b1}}; // LOW makes rank active
        //act_n = 1; // no ACT
        //A = {ADDRWIDTH{1'b0}};
        bg = 1;
        ba = 1;
        dq_reg = {DQWIDTH{1'b0}};
        dqs_t_reg = {CHIPS{1'b0}};
        dqs_c_reg = {CHIPS{1'b1}};
        odt = 0;
        parity = 0;
        writing = 0;
        for (i = 0; i < BANKGROUPS; i = i + 1)
        begin
            for (j = 0; j < BANKSPERGROUP; j = j + 1)
            begin
                sync[i][j] = 0;
            end
        end
        #(tCK*0.99) // use a propagation delay because of (suspected) bug in Vivado Simulator
        
        // reset high
        reset_n = 1;
        cs_n = 1'b0; // LOW makes rank active
        #tCK;
        for (i = 0; i < BANKGROUPS; i = i + 1)
        begin
            for (j = 0; j < BANKSPERGROUP; j = j + 1)
            begin
                assert (dut.TimingFSMi.BankFSM[i][j] == 5'h00) $display("[T=%0t] OK: StateTimingIdle", $time); else $display(dut.TimingFSMi.BankFSM[i][j]);
                
            end
        end
        #tCK;

        $monitor("T=%0t, match_col=%0d, query_col=%0d", $time, dut.match_col[0][bg][ba], dut.RLUi.query_col); //added new

        //assign match_en = 1;
        //assign A = 'h1A5A5;
        // A is 1A5A% when match_en is 1
    end

//always@(posedge clk) begin
//    if (rsn == 1 && row_address != 0 && ETM == 0) begin
//       assign row_address = row_address - 1;
//    end
//    if(row_address == 0 || ETM == 1) begin
//        if(ETM==0) begin
//        #30 $display("Query Column = %d ", query_column, " Matched Column = %d", match_col);
//        end
//        #40 assign rsn = 1'b0;
//        if(query_column<64)
//        begin
//            #20 assign rsn = 1'b1;
//            assign query_column = query_column + 1;
//            assign row_address = (2**CHWIDTH);
//            //assign row_address = 6'b111111;
//        end
//        else
//            $finish;    
//    end
//end     
endmodule



//initial 
//    begin 
//        assign clk = 1'b1;
//        assign rsn = 1'b1;
//        #10 assign rsn = 1'b0;
//        #10 assign rsn = 1'b1;
//        //assign row_address = 5'h0;
//        assign query_column = 11'd511;
//        assign match_en = 1;     
//        //row address
//        assign row_address = 2**CHWIDTH-1;// 5'h0;
//        //for (n = 0; n < 2**CHWIDTH; n++)
//        for (i = 2**CHWIDTH-1; i >= 0 ; i--)
//            begin
//            #20 assign row_address = i;
//        end
//        $display("Query Column = %d ", query_column, " Matched Column = %d", match_col);
        
//        // new query
//        assign rsn = 1'b0;
//        assign query_column = 11'd1019;
//        #30 assign rsn = 1'b1;
//        assign row_address = 2**CHWIDTH-1 ;// 5'h0;
//        //for (n = 0; n < 2**CHWIDTH; n++)
//        for (i = 2**CHWIDTH-1; i >=0 ; i--)
//            begin
//            #20 assign row_address = i;
//        end
//        $display("Query Column = %d ", query_column, " Matched Column = %d", match_col);
        
//        // new query
//        assign rsn = 1'b0;
//        assign query_column = 11'd1502;
//        #30 assign rsn = 1'b1;
//        assign row_address = 2**CHWIDTH-1;// 5'h0;
//        //for (n = 0; n < 2**CHWIDTH; n++)
//        for (i = 2**CHWIDTH-1; i >=0 ; i--)
//            begin
//            #20 assign row_address = i;
//        end
//        $display("Query Column = %d ", query_column, " Matched Column = %d", match_col);
        
//        // new query
//        assign rsn = 1'b0;
//        assign query_column = 11'd2020;
//        #30 assign rsn = 1'b1;
//        assign row_address = 2**CHWIDTH-1;// 5'h0;
//        //for (n = 0; n < 2**CHWIDTH; n++)
//        for (i = 2**CHWIDTH-1; i >=0 ; i--)
//            begin
//            #20 assign row_address = i;
//        end
//        $display("Query Column = %d ", query_column, " Matched Column = %d", match_col);
        
//        $stop;
//    end


  
  
//endmodule
