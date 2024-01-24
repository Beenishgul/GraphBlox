`timescale 1ns / 1ps
`define Sieve
// This Bank module models the basics in terms of structure and data storage of a memory Bank.
// * parameter `DEVICE_WIDTH` corresponds with the width of the memory Chip, Bank Group, Bank
// and sets the number of bits addressed by one row-column address location
// * parameter `COLWIDTH` determines the number of columns in one row
// * parameter `CHWIDTH` determines the number of full rows to be modeled. 
// The number of full rows modeled will be much smaller than the real number of rows
// because of the limited BRAM available on the FPGA chip.
// The small number of full rows modeled are then mapped to any rows in use.

module Bank
  #(parameter DEVICE_WIDTH = 16,
  parameter COLWIDTH = 7,
  parameter RAM_WIDTH = DEVICE_WIDTH*2**COLWIDTH, //8192 //2048
  parameter CHWIDTH = 10,
  localparam COLS = 2**COLWIDTH, // number of columns
  localparam CHROWS = 2**CHWIDTH, // number of full rows allocated to a Bank model
  localparam DEPTH = COLS*CHROWS, // amount of BRAM per Bank as full rows
  localparam log_DEVICE_WIDTH = 4)
  (
  input  logic clk,
  input  logic [0:0]              rd_o_wr,
  input  logic [DEVICE_WIDTH-1:0] dqin,
  output logic [DEVICE_WIDTH-1:0] dqout,
  input  logic [CHWIDTH-1:0]      row,
  input  logic [COLWIDTH-1:0]     column,
  // new ports for Sieve and mem_dual_port
  `ifdef Sieve
  output logic ETM,
  input logic [COLWIDTH+log_DEVICE_WIDTH-1:0] query_col,
  input logic [CHWIDTH-1:0] row_address,
  input logic host_write,
  input logic host_en,
  input logic sieve_write,
  input logic sieve_en,
  input logic sieve_rsn,
  output logic [COLWIDTH+log_DEVICE_WIDTH-1:0] match_col,
  `endif
  input logic rst   // I should keep this port and not use it in nonsieve case
  );
  
  
  logic [DEVICE_WIDTH-1:0] douta;
  logic [2**COLWIDTH*DEVICE_WIDTH-1:0] doutb;
  logic [DEVICE_WIDTH-1:0] dina;           // Port A RAM input data
  logic [RAM_WIDTH-1:0] dinb;             // Port B RAM input data

  `ifdef Sieve
   temp_wrap #(
   ) sieve_wrapper(
               .query_col(query_col), 
               .row_address(row_address), 
               .clk(clk), 
               .rsn(!rst & sieve_rsn), 
               .ETM(ETM), 
               .douta(douta), 
               .doutb(doutb), 
               .dina(dina),
               .match_col(match_col)
               );
  
  `endif
 
 `ifdef Sieve
    mem_wrapper mem(
    .addra({row,column}),
    .addrb(row_address),   // Port B address bus, width determined from RAM_DEPTH
    .dina(dqin),     // Port A RAM input data, width determined from RAM_WIDTH
    .dinb(dinb),     // Port B RAM input data, width determined from RAM_WIDTH // Sieve will not write column back, either Z or 0 doesnt matter
    .clka(clk),     // Port A clock
    .clkb(clk),     // Port B clock
    .host_write(host_write),       // Port A write enable
    .sieve_write(sieve_write),       // Port B write enable  // sieve_write should always be 0
    .host_en(host_en),       // Port A RAM Enable, for additional power savings, disable port when not in use
    .sieve_en(sieve_en),       // Port B RAM Enable, for additional power savings, disable port when not in use
    //.rsta(rst),     // Port A output reset (does not affect memory contents)
    //.rstb(rst),     // Port B output reset (does not affect memory contents)
    //.regcea(rst), // Port A output register enable
    //.regceb(rst), // Port B output register enable
    .douta(dqout),   // Port A RAM output data, width determined from RAM_WIDTH
    .doutb(doutb)    // Port B RAM output data, width determined from RAM_WIDTH
    );
 `else
  bank_array #(.WIDTH(DEVICE_WIDTH), 
               .DEPTH(DEPTH)
               ) arrayi (
              .clk(clk),
              .addr({row, column}),
              .rd_o_wr(rd_o_wr), // 0->rd, 1->wr
              .i_data(dqin),
              .o_data(dqout)
              );
  `endif
  
endmodule
