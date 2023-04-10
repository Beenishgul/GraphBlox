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

import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_MEMORY_PKG::*;

module cache_response_generator #(
  parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
  parameter NUM_MODULES        = 3              ,
  parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
  input  logic                   ap_clk                       ,
  input  logic                   areset                       ,
  input  GLAYDescriptorInterface glay_descriptor_in           ,
  output MemoryRequestPacket     mem_req_out [NUM_MODULES-1:0],
  input  GlayCacheRequest        glay_cache_req_in            ,
  output FIFOStateSignalsOutput  mem_req_fifo_out_signals     ,
  input  FIFOStateSignalsInput   mem_req_fifo_in_signals      ,
  output logic                   fifo_setup_signal
);



endmodule : cache_response_generator
