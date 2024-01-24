`timescale 1ns / 1ps
`define Sieve 
// A BankGroup module model that bundles multiple Bank modules.
// parameter `BAWIDTH` determines the number of Banks
module BankGroup
    #(parameter BAWIDTH = 2,
    parameter COLWIDTH = 7,
    parameter DEVICE_WIDTH = 16,
    parameter CHWIDTH = 10,
    
    localparam BANKSPERGROUP = 2**BAWIDTH,
    localparam log_DEVICE_WIDTH = 4
    )
    (
    input logic clk,
    // the Bank inputs are bundled together for easy indexing
    input logic  [0:0]             rd_o_wr [BANKSPERGROUP-1:0],
    input logic  [DEVICE_WIDTH-1:0]dqin    [BANKSPERGROUP-1:0],
    output logic [DEVICE_WIDTH-1:0]dqout   [BANKSPERGROUP-1:0],
    input logic  [CHWIDTH-1:0]     row     [BANKSPERGROUP-1:0],
    input logic  [COLWIDTH-1:0]    column  [BANKSPERGROUP-1:0],
    `ifdef Sieve
      output logic ETM [BANKSPERGROUP-1:0],
      input logic [COLWIDTH+log_DEVICE_WIDTH-1:0] query_col,
      input logic [CHWIDTH-1:0] row_address,
      input logic host_write,
      input logic host_en,
      input logic sieve_write,
      input logic sieve_en,
      input logic sieve_rsn,
      output logic [COLWIDTH+log_DEVICE_WIDTH-1:0] match_col [BANKSPERGROUP-1:0],
    `endif
    input logic rst
    );
    
    // generating BANKSPERGROUP Bank instances and mapping the bi'th wires
    genvar bi;
    generate
        for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
        begin:B
            Bank #(.DEVICE_WIDTH(DEVICE_WIDTH),
            .COLWIDTH(COLWIDTH),
            .CHWIDTH(CHWIDTH)) Bi (
            .clk(clk),
            .rd_o_wr(rd_o_wr[bi]),
            .dqin(dqin[bi]),
            .dqout(dqout[bi]),
            .row(row[bi]),
            .column(column[bi]),
            `ifdef Sieve
            .ETM(ETM[bi]),
            .query_col(query_col),
            .row_address(row_address),
            .host_write(host_write),
            .host_en(host_en),
            .sieve_write(sieve_write),
            .sieve_en(sieve_en),
            .sieve_rsn(sieve_rsn),
            .match_col(match_col[bi]),
            `endif
            .rst(rst)
            );
        end
    endgenerate
    
endmodule

// References
// https://www.verilogpro.com/systemverilog-arrays-synthesizable/
