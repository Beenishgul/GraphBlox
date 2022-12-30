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
import GLAY_REQ_PKG::*;

module glay_kernel_cu #(
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

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic                          m_axi_areset    ;
  logic                          control_areset  ;
  logic                          cache_areset    ;
  logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_done_reg;

  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;

  GlayControlChainInterfaceInput  glay_control_in_reg    ;
  GlayControlChainInterfaceOutput glay_control_out_reg   ;
  GLAYDescriptorInterface         glay_descriptor_in_reg ;
  GLAYDescriptorInterface         glay_descriptor_out_reg;

  // assign m_axi_write.out = 0;
  // assign m_axi_read.out  = 0;

  // assign m_axi_write.out.awburst = M_AXI4_BURST_INCR;
  // assign m_axi_read.out.arburst  = M_AXI4_BURST_INCR;
  // assign m_axi_write.out.awsize  = M_AXI4_SIZE_64B;
  // assign m_axi_read.out.arsize   = M_AXI4_SIZE_64B;
  // assign m_axi_write.out.awcache = M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;
  // assign m_axi_read.out.arcache  = M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;

  logic [VERTEX_DATA_BITS-1:0] counter;

// --------------------------------------------------------------------------------------
//   AXI Cache signals
// --------------------------------------------------------------------------------------


  GlayCacheRequestInterfaceInput  iob_cache_req_in ;
  GlayCacheRequestInterfaceOutput iob_cache_req_out;

  logic force_inv_in ;
  logic force_inv_out;
  logic wtb_empty_in ;
  logic wtb_empty_out;

  assign force_inv_in = 1'b0;
  assign wtb_empty_in = 1'b1;

  assign iob_cache_req_in.valid = 1'b0;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    m_axi_areset   <= areset;
    control_areset <= areset;
    cache_areset   <= areset;
  end

// --------------------------------------------------------------------------------------
// Done Logic
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (areset) begin
      counter          <= 0;
      glay_cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
    end
    else begin
      if (glay_descriptor_out_reg.valid) begin
        if(counter > 2000) begin
          glay_cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b1}};
          counter          <= 0;
        end
        else begin
          counter <= counter + 1;
        end
      end else begin
        glay_cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
        counter          <= 0;
      end
    end
  end

// --------------------------------------------------------------------------------------
// GLay control chain signals
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_in_reg.glay_start    <= 1'b0;
      glay_control_in_reg.glay_continue <= 1'b0;
    end
    else begin
      glay_control_in_reg.glay_start    <= glay_control_in.glay_start ;
      glay_control_in_reg.glay_continue <= glay_control_in.glay_continue;
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_out.glay_ready <= 1'b0;
      glay_control_out.glay_done  <= 1'b0;
      glay_control_out.glay_idle  <= 1'b1;
    end
    else begin
      glay_control_out.glay_ready <= glay_control_out_reg.glay_ready;
      glay_control_out.glay_idle  <= glay_control_out_reg.glay_idle;
      glay_control_out.glay_done  <= glay_control_out_reg.glay_done;
    end
  end

  glay_kernel_control #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_glay_kernel_control (
    .ap_clk             (ap_clk                 ),
    .areset             (control_areset         ),
    .glay_cu_done_in    (glay_cu_done_reg       ),
    .glay_control_in    (glay_control_in_reg    ),
    .glay_control_out   (glay_control_out_reg   ),
    .glay_descriptor_in (glay_descriptor_in_reg ),
    .glay_descriptor_out(glay_descriptor_out_reg)
  );

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_write.in <= 0;
    end
    else begin
      m_axi_write.in <= m_axi_write_in;
    end
  end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_read.in <= 0;
    end
    else begin
      m_axi_read.in <= m_axi_read_in;
    end
  end


// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_write_out <= 0;
    end
    else begin
      m_axi_write_out <= m_axi_write.out;
    end
  end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_read_out <= 0;
    end
    else begin
      m_axi_read_out <=  m_axi_read.out;
    end
  end


// --------------------------------------------------------------------------------------
// READ GLAY Descriptor
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      glay_descriptor_in_reg.valid <= 0;
    end
    else begin
      glay_descriptor_in_reg.valid <= glay_descriptor.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    glay_descriptor_in_reg.payload <= glay_descriptor.payload;
  end

  iob_cache_axi #(
    .FE_ADDR_W    (CACHE_FRONTEND_ADDR_W),
    .FE_DATA_W    (CACHE_FRONTEND_DATA_W),
    .N_WAYS       (CACHE_N_WAYS         ),
    .LINE_OFF_W   (CACHE_LINE_OFF_W     ),
    .WORD_OFF_W   (CACHE_WORD_OFF_W     ),
    .WTBUF_DEPTH_W(CACHE_WTBUF_DEPTH_W  ),
    .REP_POLICY   (CACHE_REP_POLICY     ),
    .NWAY_W       (CACHE_NWAY_W         ),
    .FE_NBYTES    (CACHE_FRONTEND_NBYTES),
    .FE_BYTE_W    (CACHE_FRONTEND_BYTE_W),
    .BE_ADDR_W    (CACHE_BACKEND_ADDR_W ),
    .BE_DATA_W    (CACHE_BACKEND_DATA_W ),
    .BE_NBYTES    (CACHE_BACKEND_NBYTES ),
    .BE_BYTE_W    (CACHE_BACKEND_BYTE_W ),
    .LINE2MEM_W   (CACHE_LINE2MEM_W     ),
    .WRITE_POL    (CACHE_WRITE_POL      ),
    .AXI_ADDR_W   (CACHE_AXI_ADDR_W     ),
    .AXI_DATA_W   (CACHE_AXI_DATA_W     ),
    .AXI_ID_W     (CACHE_AXI_ID_W       ),
    .AXI_LEN_W    (CACHE_AXI_LEN_W      ),
    .AXI_ID       (CACHE_AXI_ID         ),
    .CTRL_CACHE   (CACHE_CTRL_CACHE     ),
    .CTRL_CNT     (CACHE_CTRL_CNT       )
  ) inst_iob_cache_axi (
    .valid        (iob_cache_req_in.payload.valid ),
    .addr         (iob_cache_req_in.payload.addr  ),
    .wdata        (iob_cache_req_in.payload.wdata ),
    .wstrb        (iob_cache_req_in.payload.wstrb ),
    .rdata        (iob_cache_req_out.payload.rdata),
    .ready        (iob_cache_req_out.payload.ready),
    .force_inv_in (force_inv_in                   ),
    .force_inv_out(force_inv_out                  ),
    .wtb_empty_in (wtb_empty_in                   ),
    .wtb_empty_out(wtb_empty_out                  ),
    `include "m_axi_portmap_glay.vh"
    .clk          (ap_clk                         ),
    .reset        (cache_areset                   )
  );



endmodule : glay_kernel_cu



