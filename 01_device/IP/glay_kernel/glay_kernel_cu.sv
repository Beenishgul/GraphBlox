// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_cu.sv
// Create : 2022-11-29 18:50:35
// Revise : 2022-11-29 18:50:35
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import GLAY_GLOBALS_PKG::*;
import GLAY_AXI4_PKG::*;
import GLOBALS_AFU_PKG::*;

module glay_kernel_cu #(
  parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
  parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                          ap_clk           ,
  input  logic                          areset         ,
  input  logic                          ap_start       ,
  output logic                          ap_done        ,
  input  GLAYDescriptorInterface        glay_descriptor,
  input  AXI4MasterReadInterfaceInput   m_axi_read_in  ,
  output AXI4MasterReadInterfaceOutput  m_axi_read_out ,
  input  AXI4MasterWriteInterfaceInput  m_axi_write_in ,
  output AXI4MasterWriteInterfaceOutput m_axi_write_out
);

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
// AXI write master stage
  logic write_done;



///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////
  always @(posedge ap_clk) begin
    if (areset) begin
      write_done <= 0;
    end
    else begin
      write_done <= 1;
    end
  end

  assign ap_done = write_done;

endmodule : glay_kernel_cu
