`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2023 01:25:10 AM
// Design Name: 
// Module Name: RLU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define Sieve
`define DDR4
module RLU_fsm #(
    parameter RANKS = 1,
    parameter CHIPS = 1,
    parameter ADDRWIDTH = 17,
    parameter BGWIDTH = 2,
    parameter BAWIDTH = 2,
    parameter COLWIDTH = 7,
    parameter DEVICE_WIDTH = 16,
    parameter CHWIDTH = 10,
    parameter log_DEVICE_WIDTH = 4,
    localparam BANKGROUPS = 2**BGWIDTH,
    localparam BANKSPERGROUP = 2**BAWIDTH) (
    input logic [CHWIDTH-1:0] cRowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input logic [COLWIDTH-1:0] ColId [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input logic rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    `ifdef DDR4
    input logic [BGWIDTH-1:0] bg,
    `endif
    input logic [BAWIDTH-1:0] ba,// can be removed for broadcasting control to all banks
    input logic clk,
    input logic rst,
    input logic match_en,
    input logic [4:0] BankFSM [BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    input [DEVICE_WIDTH-1:0] chipdqi [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output [DEVICE_WIDTH-1:0] chipdqo [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0],
    output logic [ADDRWIDTH-1:0] A, //  A can be inout to DIMM (if A = `h1A5A5 or soem pattern triggger RLU)
    output logic sieve_match, // new commands for new sieve_matching state -> goes to TimingFSM
    `ifdef Sieve
    output logic [COLWIDTH+log_DEVICE_WIDTH-1:0] match_col [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0], //newly added to read the match_col in testbench
    `endif
    output logic act_n
    
    );

 `ifdef Sieve
  logic sieve_en;
  logic sieve_write;
  logic sieve_rsn;
  logic host_en;
  logic host_write;
  logic [COLWIDTH+log_DEVICE_WIDTH-1:0] query_col;
  logic ETM [CHIPS-1:0][BANKGROUPS-1:0][BANKSPERGROUP-1:0];
 `endif  
 
 genvar ri, ci;
 // Rank and Chip instances that model the shared bus and data placement todo: multi rank logic
  generate
    for (ri = 0; ri < RANKS ; ri=ri+1)
    begin:R
      for (ci = 0; ci < CHIPS ; ci=ci+1)
      begin:C
        Chip #(.BGWIDTH(BGWIDTH),
        .BAWIDTH(BAWIDTH),
        .COLWIDTH(COLWIDTH),
        .DEVICE_WIDTH(DEVICE_WIDTH),
        .CHWIDTH(CHWIDTH)) Ci (
        .clk(clk),
        // all the information on the data bus is in these wire bundles below
        .rd_o_wr(rd_o_wr),
        .dqin(chipdqi[ci]),
        .dqout(chipdqo[ci]),
        .row(cRowId),
        .column(ColId),
        `ifdef Sieve
        .ETM(ETM[ci]),
        .query_col(query_col),
        .row_address({4'b0000,6'b111111-counter[5:0]}),
        .host_write(host_write),
        .host_en(host_en),
        .sieve_write(sieve_write),
        .sieve_en(sieve_en),
        .sieve_rsn(sieve_rsn),
        .match_col(match_col[ci]),
        `endif
        .rst(rst)
        );
      end
    end
  endgenerate

 
 assign sieve_write = 1'b0; // always zero, sieve will not write anything to memory
 //assign host_write = 1'b1;
 assign host_write = rd_o_wr[bg][ba]; 
 assign host_en = 1'b1;
 //assign sieve_en = 1'b0;    
 
 // first
 // Load the data ( can assume for now that it has been loaded)
 // no of columns / device_width * no_of_rows writes ( without burst)
 // 8192/16 * 64 writes ( interleaved reference and query)
 
 // for row 1:64
 //     for col 1:512
 //         write ( where is the data coming from? - link with the U280 DRAM)
 
 // second 
 // Sieve_enable 
 // for query 1:64 
 //     if (!ETM)
 //     for row 1:64 
 //         ACT
 //         MAT
 //         PRE
 reg [ADDRWIDTH-1:0] A_reg;
 reg [11:0] counter;
 reg A_incr;
 reg i;

 //assign A = (match_en) ? (A_reg) : 1'bZ;  // might not need this?
 assign A = (match_en) ? (A_reg) : 17'b0;  // might not need this
 assign sieve_en = 1'b1;
// assign cs_n = 0;
 
 
 assign A_reg = {1'b0,i,9'b0,counter[5:0]}; // act,pre
 
// instead of for loops - use posedge clk
 always@(posedge clk)
 begin
    if (rst) 
    begin
        counter <= 0;
        A_incr <= 1;
        A_reg <= 0;
        i <= 1;
        sieve_match <= 0;
        sieve_rsn <= 1;
    end
    else  /// can be optimized but later, can we do a rsn for ETM 
    begin        
  
        if(BankFSM[bg][ba] == 5'b00000) //idle
        begin 
          if(A_incr == 1)
          begin
            i <= 0;  //activate
            act_n <= 0;
            sieve_rsn <= 1;
          end
        end


       if(BankFSM[bg][ba] == 5'b00001) //activating
       begin
          act_n <= 1;    
       end
       
       if(BankFSM[bg][ba] == 5'b00011) //active
       begin 
          sieve_match <= 1; //matching
       end

       if(BankFSM[bg][ba] == 5'b10010) //Sieve_matching
       begin 
        sieve_match <= 0;
        i <= 1; //precharge
        act_n <= 1;
       
       //counter updates
       counter <= counter + 1;
            if (counter == 6'b111111 || ETM[0][bg][ba]) // for 64 rows 
            begin    
               //rsn  <= 1; // we should reset here - make rsn inout or introduce new reset, then synchronize Sieve_reset and main reset
               // counter should not be zero on reset, some way to store the query column we were matching
               //ETM <= 0; // to move to next query, commented bcz added sieve reset
               sieve_rsn <= 0;
               counter[5:0] <= 0;
               if(counter[11:6] == 6'b111111)
               begin
                  A_incr <= 0;
               end
               else
               begin
                  counter[11:6] <= counter[11:6] + 1;
               end
            end
       end
 
    end
 end

assign query_col = {7'b0000000,counter[11:6]};
 
 
  
 // third
 // Write the matching column number
 
 
 
 // fourth 
 // Load another batch of query
 // read (read 319-256, write to 1791-1728, 1215-1152, 639-576)

 // fifth
 // Load another batch of ref and query

    
endmodule
