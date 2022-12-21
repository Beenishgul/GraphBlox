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
import GLAY_CONTROL_PKG::*;

module glay_kernel_cu #(
  parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
  parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                          ap_clk          ,
  input  logic                          areset          ,
  input  GlayControlChainIterfaceInput  glay_control_in ,
  output GlayControlChainIterfaceInput  glay_control_out,
  input  GLAYDescriptorInterface        glay_descriptor ,
  input  AXI4MasterReadInterfaceInput   m_axi_read_in   ,
  output AXI4MasterReadInterfaceOutput  m_axi_read_out  ,
  input  AXI4MasterWriteInterfaceInput  m_axi_write_in  ,
  output AXI4MasterWriteInterfaceOutput m_axi_write_out
);

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
// AXI write master stage
  logic glay_done   ;
  logic m_axi_areset;


  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;

  GlayControlChainIterfaceInput glay_control_in_reg    ;
  GlayControlChainIterfaceInput glay_control_out_reg   ;
  GLAYDescriptorInterface       glay_descriptor_in_reg ;
  GLAYDescriptorInterface       glay_descriptor_out_reg;

  assign m_axi_write.out = 0;
  assign m_axi_read.out  = 0;

  assign m_axi_write.out.awburst = M_AXI4_BURST_INCR;
  assign m_axi_read.out.arburst  = M_AXI4_BURST_INCR;
  assign m_axi_write.out.awsize  = M_AXI4_SIZE_64B;
  assign m_axi_read.out.arsize   = M_AXI4_SIZE_64B;
  assign m_axi_write.out.awcache = M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;
  assign m_axi_read.out.arcache  = M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;

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
// GLay control chain signals
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_in_reg.start    <= 1'b0;
      glay_control_in_reg.continue <= 1'b0;
    end
    else begin
      glay_control_in_reg.start    <= glay_control_in.start ;
      glay_control_in_reg.continue <= glay_control_in.continue;
    end
  end

  always @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_out.idle  <= 1'b1;
      glay_control_out.done  <= 1'b0;
      glay_control_out.ready <= 1'b0;
    end
    else begin
      glay_control_out.idle  <= glay_control_out_reg.idle;
      glay_control_out.done  <= glay_control_out_reg.done;
      glay_control_out.ready <= glay_control_out_reg.ready;
    end
  end

  glay_kernel_control #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_glay_kernel_control (
    .ap_clk             (ap_clk                 ),
    .areset             (control_areset         ),
    .glay_control_in    (glay_control_in_reg    ),
    .glay_control_out   (glay_control_out       ),
    .glay_descriptor_in (glay_descriptor_in_reg ),
    .glay_descriptor_out(glay_descriptor_out_reg)
  );

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
      glay_descriptor_in_reg.valid <= 0;
    end
    else begin
      glay_descriptor_in_reg.valid <= glay_descriptor.valid;
    end
  end

  always @(posedge ap_clk) begin
    glay_descriptor_in_reg.payload <= glay_descriptor.payload;
  end



endmodule : glay_kernel_cu
