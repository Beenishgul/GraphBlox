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
import GLAY_ENGINE_PKG::*;

// Serial\_Read\_Engine
// --------------------

// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity

// The serial read engine sends read commands to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array.

// uint32_t *serialReadEngine(uint32_t *arrayPointer, uint32_t arraySize, uint32_t startRead, uint32_t endRead, uint32_t stride, uint32_t granularity)

module serial_read_engine #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL ,
    parameter ENGINE_ID          = 0
) (
    // System Signals
    input  logic                           ap_clk                  ,
    input  logic                           areset                  ,
    input  SerialReadEngineConfiguration   serial_read_engine_in   ,
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