// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_setup.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_REQ_PKG::*;

module glay_kernel_setup #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
    // System Signals
    input  logic                           ap_clk                  ,
    input  logic                           areset                  ,
    input  GlayControlChainInterfaceOutput glay_control_state      ,
    input  GLAYDescriptorInterface         glay_descriptor         ,
    input  GlayCacheRequestInterfaceInput  glay_setup_cache_req_in ,
    output GlayCacheRequestInterfaceOutput glay_setup_cache_req_out
);

    GlayControlChainInterfaceOutput glay_control_state_reg      ;
    GLAYDescriptorInterface         glay_descriptor_reg         ;
    GlayCacheRequestInterfaceInput  glay_setup_cache_req_in_reg ;
    GlayCacheRequestInterfaceOutput glay_setup_cache_req_out_reg;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        setup_areset <= areset;
    end

// --------------------------------------------------------------------------------------
// READ GLAY Descriptor
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (setup_areset) begin
      glay_descriptor_reg.valid <= 0;
    end
    else begin
      glay_descriptor_reg.valid <= glay_descriptor.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    glay_descriptor_reg.payload <= glay_descriptor.payload;
  end


endmodule : glay_kernel_setup