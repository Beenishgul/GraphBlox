// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_response_generator.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;

module cache_response_generator #(
  parameter         NUM_GRAPH_CLUSTERS        = CU_COUNT_GLOBAL                  ,
  parameter         NUM_MEMORY_REQUESTOR      = 2                                ,
  parameter         NUM_GRAPH_PE              = CU_COUNT_LOCAL                   ,
  parameter integer OUTSTANDING_COUNTER_MAX   = 16                               ,
  parameter         OUTSTANDING_COUNTER_WIDTH = $clog2(OUTSTANDING_COUNTER_MAX+1)
) (
  input  logic                  ap_clk                                 ,
  input  logic                  areset                                 ,
  output MemoryPacket   mem_resp_out [NUM_MEMORY_REQUESTOR-1:0],
  input  CacheResponse          cache_resp_in                          ,
  input  CacheRequest           cache_req_in                           ,
  output FIFOStateSignalsOutput cache_resp_fifo_out_signals            ,
  output logic                  fifo_setup_signal
);



endmodule : cache_response_generator
