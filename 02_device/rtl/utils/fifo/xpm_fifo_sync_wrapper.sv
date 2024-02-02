// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : xpm_fifo_sync_wrapper.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-06-17 16:37:19
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------
`include "global_package.vh"

module xpm_fifo_sync_wrapper #(
  parameter FIFO_WRITE_DEPTH = 16   ,
  parameter WRITE_DATA_WIDTH = 32   ,
  parameter READ_DATA_WIDTH  = 32   ,
  parameter PROG_THRESH      = 6    ,
  parameter READ_MODE        = "std"
) (
  input  logic                        clk        ,
  input  logic                        srst       ,
  input  logic [WRITE_DATA_WIDTH-1:0] din        ,
  input  logic                        wr_en      ,
  input  logic                        rd_en      ,
  output logic [ READ_DATA_WIDTH-1:0] dout       ,
  output logic                        full       ,
  output logic                        empty      ,
  output logic                        valid      ,
  output logic                        prog_full  ,
  output logic                        wr_rst_busy,
  output logic                        rd_rst_busy
);

// // // xpm_fifo_sync: Synchronous FIFO
// // // Xilinx Parameterized Macro
// xpm_fifo_sync #(
//   .FIFO_MEMORY_TYPE   ("auto"                        ), //string; "auto", "block", "distributed", or "ultra";
//   .ECC_MODE           ("no_ecc"                      ), //string; "no_ecc" or "en_ecc";
//   .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH              ), //positive integer
//   .WRITE_DATA_WIDTH   (WRITE_DATA_WIDTH              ), //positive integer
//   .WR_DATA_COUNT_WIDTH($clog2(WRITE_DATA_WIDTH)      ), //positive integer
//   .PROG_FULL_THRESH   (FIFO_WRITE_DEPTH - PROG_THRESH), //positive integer
//   .FULL_RESET_VALUE   (0                             ), //positive integer; 0 or 1
//   .USE_ADV_FEATURES   ("1002"                        ), //string; "0000" to "1F1F", "1A0A", "1002";
//   .READ_MODE          (READ_MODE                     ), //string; "std" or "fwft";
//   .FIFO_READ_LATENCY  (1                             ), //positive integer;
//   .READ_DATA_WIDTH    (READ_DATA_WIDTH               ), //positive integer
//   .RD_DATA_COUNT_WIDTH($clog2(READ_DATA_WIDTH)       ), //positive integer
//   .PROG_EMPTY_THRESH  (PROG_THRESH                   ), //positive integer
//   .DOUT_RESET_VALUE   ("0"                           ), //string
//   .WAKEUP_TIME        (0                             )  //positive integer; 0 or 2;
// ) xpm_fifo_sync_inst (
//   .sleep        (1'b0       ),
//   .rst          (srst       ),
//   .wr_clk       (clk        ),
//   .wr_en        (wr_en      ),
//   .din          (din        ),
//   .full         (full       ),
//   .overflow     (           ),
//   .prog_full    (prog_full  ),
//   .wr_data_count(           ),
//   .almost_full  (           ),
//   .wr_ack       (           ),
//   .wr_rst_busy  (wr_rst_busy),
//   .rd_en        (rd_en      ),
//   .dout         (dout       ),
//   .empty        (empty      ),
//   .prog_empty   (           ),
//   .rd_data_count(           ),
//   .almost_empty (           ),
//   .data_valid   (valid      ),
//   .underflow    (           ),
//   .rd_rst_busy  (rd_rst_busy),
//   .injectsbiterr(1'b0       ),
//   .injectdbiterr(1'b0       ),
//   .sbiterr      (           ),
//   .dbiterr      (           )
// );
// // // End of xpm_fifo_sync instance declaration


localparam FALL_THROUGH = (READ_MODE == "fwft") ? 1'b1 : 1'b0;
localparam ADDR_DEPTH = (FIFO_WRITE_DEPTH > 1) ? $clog2(FIFO_WRITE_DEPTH) : 1;

logic [     ADDR_DEPTH-1:0] usage   ;
logic [READ_DATA_WIDTH-1:0] dout_int;

logic full_int     ;
logic empty_int    ;
logic valid_int    ;
logic prog_full_int;

logic                       valid_reg   ;
logic                       valid_reg_S2;
logic                       valid_reg_S3;
logic                       empty_int_o ;
logic                       empty_reg   ;
logic                       empty_reg_S2;
logic                       empty_reg_S3;
logic [READ_DATA_WIDTH-1:0] dout_int_o  ;
logic [READ_DATA_WIDTH-1:0] dout_int_reg;

assign wr_rst_busy = 1'b0;
assign rd_rst_busy = 1'b0;
assign dout        = dout_int;
assign prog_full   = prog_full_int;
assign valid       = valid_int;
assign empty       = empty_int;

always_ff @(posedge clk) begin
  if(FALL_THROUGH)begin
    valid_reg_S2 <= ~empty_int_o;
    valid_reg_S3 <= valid_reg_S2;
    valid_reg    <= valid_reg_S3;

    empty_reg_S2 <= empty_int_o;
    empty_reg_S3 <= empty_reg_S2;
    empty_reg    <= empty_reg_S3;

  end else begin
    valid_reg <= ~empty_int_o & rd_en;
  end

  dout_int_reg <= dout_int_o;
  // generate threshold parameters
  if (FIFO_WRITE_DEPTH == 0) begin
    prog_full_int <= 1'b0;
  end else begin
    prog_full_int <= (usage >= PROG_THRESH[ADDR_DEPTH-1:0]);
  end
end

always_comb begin
  if(FALL_THROUGH)begin
    empty_int = empty_reg | empty_int_o;
    dout_int  = dout_int_o;
    valid_int = ~empty_int;
  end else begin
    empty_int = empty_int_o;
    dout_int  = dout_int_reg;
    valid_int = valid_reg;
  end
end

fifo_v3 #(
  .FALL_THROUGH(FALL_THROUGH    ),
  .DATA_WIDTH  (WRITE_DATA_WIDTH),
  .DEPTH       (FIFO_WRITE_DEPTH)
) inst_fifo_v3 (
  .clk_i     (clk        ),
  .rst_ni    (~srst      ),
  .flush_i   (1'b0       ),
  .testmode_i(1'b0       ),
  .full_o    (full_int   ),
  .empty_o   (empty_int_o),
  .usage_o   (usage      ),
  .data_i    (din        ),
  .push_i    (wr_en      ),
  .data_o    (dout_int_o ),
  .pop_i     (rd_en      )
);

endmodule : xpm_fifo_sync_wrapper
