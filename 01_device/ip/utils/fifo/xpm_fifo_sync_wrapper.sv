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
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

module xpm_fifo_sync_wrapper #(
  parameter FIFO_WRITE_DEPTH = 16,
  parameter WRITE_DATA_WIDTH = 32,
  parameter READ_DATA_WIDTH  = 32,
  parameter PROG_THRESH      = 4
) (
  input  logic clk         ,
  input  logic srst        ,
  input  logic din         ,
  input  logic wr_en       ,
  input  logic rd_en       ,
  output logic dout        ,
  output logic full        ,
  output logic almost_full ,
  output logic empty       ,
  output logic almost_empty,
  output logic valid       ,
  output logic prog_full   ,
  output logic prog_empty  ,
  output logic wr_rst_busy ,
  output logic rd_rst_busy
);

  // localparam                      XPM_FIFO_SYNC_PROG_FULL  = ALMFUL_HI_THRESHOLD - 1;
  // localparam                      XPM_FIFO_SYNC_PROG_EMPTY = ALMFUL_LO_THRESHOLD - 2;
  // localparam                      RD_DATA_COUNT_WIDTH      = $clog2(DEPTH)          ;
  // localparam                      WR_DATA_COUNT_WIDTH      = $clog2(DEPTH)          ;
  // logic [RD_DATA_COUNT_WIDTH-1:0] rd_data_count                                     ;
  // logic [WR_DATA_COUNT_WIDTH-1:0] wr_data_count                                     ;
  // logic                           prog_full, prog_empty;
  // logic                           rd_rst_busy, wr_rst_busy;
  // if (2**$clog2(FIFO_WRITE_DEPTH) != FIFO_WRITE_DEPTH)
  //   $error("DEPTH: %d has to be power of 2", DEPTH);
  // if (FIFO_WRITE_DEPTH < 16 || FIFO_WRITE_DEPTH > 4194304)
  //   $error("FIFO_WRITE_DEPTH %d, has to be 16 - 4194304");
  // if (XPM_FIFO_SYNC_PROG_FULL > FIFO_WRITE_DEPTH - 3 - 2 || XPM_FIFO_SYNC_PROG_FULL < 3 + 2)
  //   $error("ALMFUL_HI out of range : threshold %d, FIFO_WRITE_DEPTH: %d",
  //     ALMFUL_HI_THRESHOLD, FIFO_WRITE_DEPTH);
  // if (XPM_FIFO_SYNC_PROG_EMPTY > FIFO_WRITE_DEPTH - 3 - 2 || XPM_FIFO_SYNC_PROG_EMPTY < 3 + 2)
  //   $error("ALMFUL_LO_THRESHOLD out of range : threshold %d, DEPTH: %d",
  //     ALMFUL_LO_THRESHOLD, FIFO_WRITE_DEPTH);

// xpm_fifo_sync: Synchronous FIFO
// Xilinx Parameterized Macro
  xpm_fifo_sync #(
    .FIFO_MEMORY_TYPE   ("auto"                        ), //string; "auto", "block", "distributed", or "ultra";
    .ECC_MODE           ("no_ecc"                      ), //string; "no_ecc" or "en_ecc";
    .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH              ), //positive integer
    .WRITE_DATA_WIDTH   (WRITE_DATA_WIDTH              ), //positive integer
    .WR_DATA_COUNT_WIDTH($clog2(WRITE_DATA_WIDTH)      ), //positive integer
    .PROG_FULL_THRESH   (FIFO_WRITE_DEPTH - PROG_THRESH), //positive integer
    .FULL_RESET_VALUE   (0                             ), //positive integer; 0 or 1
    .USE_ADV_FEATURES   ("1A0A"                        ), //string; "0000" to "1F1F";
    .READ_MODE          ("std"                         ), //string; "std" or "fwft";
    .FIFO_READ_LATENCY  (1                             ), //positive integer;
    .READ_DATA_WIDTH    (READ_DATA_WIDTH               ), //positive integer
    .RD_DATA_COUNT_WIDTH($clog2(READ_DATA_WIDTH)       ), //positive integer
    .PROG_EMPTY_THRESH  (PROG_THRESH                   ), //positive integer
    .DOUT_RESET_VALUE   ("0"                           ), //string
    .WAKEUP_TIME        (0                             )  //positive integer; 0 or 2;
  ) xpm_fifo_sync_inst (
    .sleep        (1'b0        ),
    .rst          (srst        ),
    .wr_clk       (clk         ),
    .wr_en        (wr_en       ),
    .din          (din         ),
    .full         (full        ),
    .overflow     (            ),
    .prog_full    (prog_full   ),
    .wr_data_count(            ),
    .almost_full  (            ),
    .wr_ack       (            ),
    .wr_rst_busy  (wr_rst_busy ),
    .rd_en        (rd_en       ),
    .dout         (dout        ),
    .empty        (empty       ),
    .prog_empty   (prog_empty  ),
    .rd_data_count(            ),
    .almost_empty (almost_empty),
    .data_valid   (valid       ),
    .underflow    (            ),
    .rd_rst_busy  (rd_rst_busy ),
    .injectsbiterr(1'b0        ),
    .injectdbiterr(1'b0        ),
    .sbiterr      (            ),
    .dbiterr      (            )
  );
// End of xpm_fifo_sync instance declaration


endmodule : xpm_fifo_sync_wrapper
