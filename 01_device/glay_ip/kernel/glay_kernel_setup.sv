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
  input  logic                           ap_clk          ,
  input  logic                           areset          ,
  input  GlayControlChainInterfaceInput  glay_control_in ,
  output GlayControlChainInterfaceOutput glay_control_out,
  input  GLAYDescriptorInterface         glay_descriptor ,
  input  AXI4MasterReadInterfaceInput    m_axi_read_in   ,
  output AXI4MasterReadInterfaceOutput   m_axi_read_out  ,
  input  AXI4MasterWriteInterfaceInput   m_axi_write_in  ,
  output AXI4MasterWriteInterfaceOutput  m_axi_write_out
);







endmodule : glay_kernel_setup