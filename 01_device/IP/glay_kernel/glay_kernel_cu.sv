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
import GLAY_DESCRIPTOR_PKG::*;

module glay_kernel_cu #(
  parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
  parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                          ap_clk         ,
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
  logic   glay_done;
  logic  m_axi_areset;

  GLAYDescriptorInterface  glay_descriptor_reg0;
  AXI4MasterReadInterface  m_axi_read     ;
  AXI4MasterWriteInterface m_axi_write    ;

  assign m_axi_write.out = 0;
  assign m_axi_read.out = 0;

// Register reset signal.
  always @(posedge ap_clk) begin
    m_axi_areset <= areset;
  end


///////////////////////////////////////////////////////////////////////////////
// Done Logic
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (areset) begin
      glay_done <= 0;
    end
    else begin
      glay_done <= 1;
    end
  end

  assign ap_done = glay_done;

///////////////////////////////////////////////////////////////////////////////
// WRITE AXI4 SIGNALS INPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_write.in <= 0;
    end
    else begin
      m_axi_write.in <= m_axi_write_in;
    end
  end

///////////////////////////////////////////////////////////////////////////////
// READ AXI4 SIGNALS INPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_read.in <= 0;
    end
    else begin
      m_axi_read.in <= m_axi_read_in;
    end
  end


///////////////////////////////////////////////////////////////////////////////
// WRITE AXI4 SIGNALS OUTPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_write_out <= 0;
    end
    else begin
      m_axi_write_out <= m_axi_write.out;
    end
  end

///////////////////////////////////////////////////////////////////////////////
// READ AXI4 SIGNALS OUTPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_read_out <= 0;
    end
    else begin
      m_axi_read_out <= m_axi_write.out;
    end
  end


///////////////////////////////////////////////////////////////////////////////
// READ GLAY Descriptor
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (m_axi_areset) begin
      glay_descriptor_reg0.valid <= 0;
    end
    else begin
      glay_descriptor_reg0.valid <= glay_descriptor.valid;
    end
  end

  always @(posedge ap_clk) begin
      glay_descriptor_reg0.payload <= glay_descriptor.payload;
  end



endmodule : glay_kernel_cu
