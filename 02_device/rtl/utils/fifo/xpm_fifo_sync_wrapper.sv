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
  parameter READ_MODE        = "std",
  parameter FIFO_MEMORY_TYPE = "auto"
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

generate
  if((READ_MODE == "std") && (READ_DATA_WIDTH == 107) && (FIFO_WRITE_DEPTH == 32) && (READ_DATA_WIDTH == 32) && (PROG_THRESH == 16) && (FIFO_MEMORY_TYPE == "distributed")) begin
    fifo_generator_ip_107x32x16_distributed fifo_generator_ip_107x32x16_distributed_inst (
      .clk        (clk        ),
      .srst       (srst       ),
      .din        (din        ),
      .wr_en      (wr_en      ),
      .rd_en      (rd_en      ),
      .dout       (dout       ),
      .full       (full       ),
      .empty      (empty      ),
      .valid      (valid      ),
      .prog_full  (prog_full  ),
      .wr_rst_busy(wr_rst_busy),
      .rd_rst_busy(rd_rst_busy)
    );
  end else begin
    // xpm_fifo_sync: Synchronous FIFO
    // Xilinx Parameterized Macro
    xpm_fifo_sync #(
      .FIFO_MEMORY_TYPE   ("distributed"                        ), //string; "auto", "block", "distributed", or "ultra";
      .ECC_MODE           ("no_ecc"                      ), //string; "no_ecc" or "en_ecc";
      .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH              ), //positive integer
      .WRITE_DATA_WIDTH   (WRITE_DATA_WIDTH              ), //positive integer
      .WR_DATA_COUNT_WIDTH($clog2(WRITE_DATA_WIDTH)      ), //positive integer
      .PROG_FULL_THRESH   (FIFO_WRITE_DEPTH - PROG_THRESH), //positive integer
      .FULL_RESET_VALUE   (0                             ), //positive integer; 0 or 1
      .USE_ADV_FEATURES   ("1002"                        ), //string; "0000" to "1F1F", "1A0A", "1002";
      .READ_MODE          (READ_MODE                     ), //string; "std" or "fwft";
      .FIFO_READ_LATENCY  (1                             ), //positive integer;
      .READ_DATA_WIDTH    (READ_DATA_WIDTH               ), //positive integer
      .RD_DATA_COUNT_WIDTH($clog2(READ_DATA_WIDTH)       ), //positive integer
      .PROG_EMPTY_THRESH  (PROG_THRESH                   ), //positive integer
      .DOUT_RESET_VALUE   ("0"                           ), //string
      .WAKEUP_TIME        (0                             )  //positive integer; 0 or 2;
    ) xpm_fifo_sync_inst (
      .sleep        (1'b0       ),
      .rst          (srst       ),
      .wr_clk       (clk        ),
      .wr_en        (wr_en      ),
      .din          (din        ),
      .full         (full       ),
      .overflow     (           ),
      .prog_full    (prog_full  ),
      .wr_data_count(           ),
      .almost_full  (           ),
      .wr_ack       (           ),
      .wr_rst_busy  (wr_rst_busy),
      .rd_en        (rd_en      ),
      .dout         (dout       ),
      .empty        (empty      ),
      .prog_empty   (           ),
      .rd_data_count(           ),
      .almost_empty (           ),
      .data_valid   (valid      ),
      .underflow    (           ),
      .rd_rst_busy  (rd_rst_busy),
      .injectsbiterr(1'b0       ),
      .injectdbiterr(1'b0       ),
      .sbiterr      (           ),
      .dbiterr      (           )
    );
    // End of xpm_fifo_sync instance declaration
  end
endgenerate

endmodule : xpm_fifo_sync_wrapper
