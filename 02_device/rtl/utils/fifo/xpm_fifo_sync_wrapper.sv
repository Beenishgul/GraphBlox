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

`include "fifo_wrapper_topology.vh"

endmodule : xpm_fifo_sync_wrapper
