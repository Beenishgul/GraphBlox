// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : serial_read_engine.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_REQ_PKG::*;

module serial_read_engine #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL ,
    parameter ENGINE_ID          = 0
) (
    // System Signals
    input  logic                           ap_clk                  ,
    input  logic                           areset                  ,
    input  GlayControlChainInterfaceOutput glay_control_state      ,
    input  GLAYDescriptorInterface         glay_descriptor         ,
    input  GlayCacheRequestInterfaceOutput glay_setup_cache_req_in ,
    output FIFOStateSignalsOutput          req_in_fifo_out_signals ,
    input  FIFOStateSignalsInput           req_in_fifo_in_signals  ,
    output GlayCacheRequestInterfaceInput  glay_setup_cache_req_out,
    output FIFOStateSignalsOutput          req_out_fifo_out_signals,
    input  FIFOStateSignalsInput           req_out_fifo_in_signals ,
    output logic                           fifo_setup_signal
);





endmodule : serial_read_engine