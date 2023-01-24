// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel.sv
// Create : 2022-11-29 12:42:56
// Revise : 2022-11-29 12:42:56
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import GLAY_GLOBALS_PKG::*;
import GLAY_AXI4_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;


module glay_kernel_afu #(
  parameter C_M00_AXI_ADDR_WIDTH = M_AXI_MEMORY_ADDR_WIDTH     ,
  parameter C_M00_AXI_DATA_WIDTH = M_AXI_MEMORY_DATA_WIDTH_BITS,
  parameter NUM_GRAPH_CLUSTERS   = CU_COUNT_GLOBAL             ,
  parameter NUM_GRAPH_PE         = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                              ap_clk            ,
  input  logic                              ap_rst_n          ,
  // AXI4 master interface m00_axi
  output logic                              m00_axi_awvalid   ,
  input  logic                              m00_axi_awready   ,
  output logic [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr    ,
  output logic [                     8-1:0] m00_axi_awlen     ,
  output logic                              m00_axi_wvalid    ,
  input  logic                              m00_axi_wready    ,
  output logic [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata     ,
  output logic [C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb     ,
  output logic                              m00_axi_wlast     ,
  input  logic                              m00_axi_bvalid    ,
  output logic                              m00_axi_bready    ,
  output logic                              m00_axi_arvalid   ,
  input  logic                              m00_axi_arready   ,
  output logic [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr    ,
  output logic [                     8-1:0] m00_axi_arlen     ,
  input  logic                              m00_axi_rvalid    ,
  output logic                              m00_axi_rready    ,
  input  logic [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata     ,
  input  logic                              m00_axi_rlast     ,
  // Control Signals
  // AXI4 master interface m00_axi missing ports
  input  logic [        CACHE_AXI_ID_W-1:0] m00_axi_bid       ,
  input  logic [        CACHE_AXI_ID_W-1:0] m00_axi_rid       ,
  input  logic [                     2-1:0] m00_axi_rresp     ,
  input  logic [                     2-1:0] m00_axi_bresp     ,
  output logic [        CACHE_AXI_ID_W-1:0] m00_axi_awid      ,
  output logic [                     3-1:0] m00_axi_awsize    ,
  output logic [                     2-1:0] m00_axi_awburst   ,
  output logic [                     1-1:0] m00_axi_awlock    ,
  output logic [                     4-1:0] m00_axi_awcache   ,
  output logic [                     3-1:0] m00_axi_awprot    ,
  output logic [                     4-1:0] m00_axi_awqos     ,
  output logic [        CACHE_AXI_ID_W-1:0] m00_axi_arid      ,
  output logic [                     3-1:0] m00_axi_arsize    ,
  output logic [                     2-1:0] m00_axi_arburst   ,
  output logic [                     1-1:0] m00_axi_arlock    ,
  output logic [                     4-1:0] m00_axi_arcache   ,
  output logic [                     3-1:0] m00_axi_arprot    ,
  output logic [                     4-1:0] m00_axi_arqos     ,
  input  logic                              ap_start          ,
  output logic                              ap_idle           ,
  output logic                              ap_done           ,
  output logic                              ap_ready          ,
  input  logic                              ap_continue       ,
  input  logic [                    64-1:0] graph_csr_struct  ,
  input  logic [                    64-1:0] vertex_out_degree ,
  input  logic [                    64-1:0] vertex_in_degree  ,
  input  logic [                    64-1:0] vertex_edges_idx  ,
  input  logic [                    64-1:0] edges_array_weight,
  input  logic [                    64-1:0] edges_array_src   ,
  input  logic [                    64-1:0] edges_array_dest  ,
  input  logic [                    64-1:0] auxiliary_1       ,
  input  logic [                    64-1:0] auxiliary_2
);

// --------------------------------------------------------------------------------------
// Local Parameters
// --------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
  (* KEEP = "yes" *)
  logic areset         = 1'b0;
  logic m_axi_areset   = 1'b0;
  logic glay_areset    = 1'b0;
  logic control_areset = 1'b0;

  GlayControlChainInterfaceInput  glay_control_in ;
  GlayControlChainInterfaceOutput glay_control_out;

  GLAYDescriptorInterface  glay_descriptor;
  AXI4MasterReadInterface  m_axi_read     ;
  AXI4MasterWriteInterface m_axi_write    ;


// --------------------------------------------------------------------------------------
//   Register and invert reset signal.
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    areset         <= ~ap_rst_n;
    m_axi_areset   <= ~ap_rst_n;
    glay_areset    <= ~ap_rst_n;
    control_areset <= ~ap_rst_n;
  end

// --------------------------------------------------------------------------------------
// GLay control chain signals
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_in.ap_start    <= 1'b0;
      glay_control_in.ap_continue <= 1'b0;
    end
    else begin
      glay_control_in.ap_start    <= ap_start;
      glay_control_in.ap_continue <= ap_continue;
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      ap_ready <= 1'b0;
      ap_done  <= 1'b0;
      ap_idle  <= 1'b1;
    end
    else begin
      ap_done  <= glay_control_out.ap_done;
      ap_ready <= glay_control_out.ap_ready;
      ap_idle  <= glay_control_out.ap_idle;
    end
  end

// --------------------------------------------------------------------------------------
// DRIVE GLAY AXI4 SIGNALS
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_read.in <= 0;
    end
    else begin
      m_axi_read.in.rvalid  <= m00_axi_rvalid ; // Read channel valid
      m_axi_read.in.arready <= m00_axi_arready; // Address read channel ready
      m_axi_read.in.rlast   <= m00_axi_rlast  ; // Read channel last word
      m_axi_read.in.rdata   <= m00_axi_rdata  ; // Read channel data
      m_axi_read.in.rid     <= m00_axi_rid    ; // Read channel ID
      m_axi_read.in.rresp   <= m00_axi_rresp  ; // Read channel response
    end
  end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m00_axi_arvalid <= 0; // Address read channel valid
      m00_axi_araddr  <= 0; // Address read channel address
      m00_axi_arlen   <= 0; // Address write channel burst length
      m00_axi_rready  <= 0; // Read channel ready
      m00_axi_arid    <= 0; // Address read channel ID
      m00_axi_arsize  <= 0; // Address read channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_arburst <= M_AXI4_BURST_INCR; // Address read channel burst type
      m00_axi_arlock  <= 0; // Address read channel lock type
      m00_axi_arcache <= M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_arprot  <= 0; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_arqos   <= 0; // Address write channel quality of service
    end
    else begin
      m00_axi_arvalid <= m_axi_read.out.arvalid; // Address read channel valid
      m00_axi_araddr  <= m_axi_read.out.araddr ; // Address read channel address
      m00_axi_arlen   <= m_axi_read.out.arlen  ; // Address write channel burst length
      m00_axi_rready  <= m_axi_read.out.rready ; // Read channel ready
      m00_axi_arid    <= m_axi_read.out.arid   ; // Address read channel ID
      m00_axi_arsize  <= m_axi_read.out.arsize ; // Address read channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_arburst <= m_axi_read.out.arburst; // Address read channel burst type
      m00_axi_arlock  <= m_axi_read.out.arlock ; // Address read channel lock type
      m00_axi_arcache <= m_axi_read.out.arcache; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_arprot  <= m_axi_read.out.arprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_arqos   <= m_axi_read.out.arqos  ; // Address write channel quality of service
    end
  end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m_axi_write.in <= 0;
    end
    else begin
      m_axi_write.in.awready <= m00_axi_awready; // Address write channel ready
      m_axi_write.in.wready  <= m00_axi_wready ; // Write channel ready
      m_axi_write.in.bid     <= m00_axi_bid    ; // Write response channel ID
      m_axi_write.in.bresp   <= m00_axi_bresp  ; // Write channel response
      m_axi_write.in.bvalid  <= m00_axi_bvalid ; // Write response channel valid
    end
  end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
      m00_axi_awvalid <= 0;// Address write channel valid
      m00_axi_awid    <= 0;// Address write channel ID
      m00_axi_awaddr  <= 0;// Address write channel address
      m00_axi_awlen   <= 0;// Address write channel burst length
      m00_axi_awsize  <= 0;// Address write channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_awburst <= M_AXI4_BURST_INCR;// Address write channel burst type
      m00_axi_awlock  <= 0;// Address write channel lock type
      m00_axi_awcache <= M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;// Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_awprot  <= 0;// Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_awqos   <= 0;// Address write channel quality of service
      m00_axi_wdata   <= 0;// Write channel data
      m00_axi_wstrb   <= 0;// Write channel write strobe
      m00_axi_wlast   <= 0;// Write channel last word flag
      m00_axi_wvalid  <= 0;// Write channel valid
      m00_axi_bready  <= 0;// Write response channel ready
    end
    else begin
      m00_axi_awvalid <= m_axi_write.out.awvalid; // Address write channel valid
      m00_axi_awid    <= m_axi_write.out.awid   ; // Address write channel ID
      m00_axi_awaddr  <= m_axi_write.out.awaddr ; // Address write channel address
      m00_axi_awlen   <= m_axi_write.out.awlen  ; // Address write channel burst length
      m00_axi_awsize  <= m_axi_write.out.awsize ; // Address write channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_awburst <= m_axi_write.out.awburst; // Address write channel burst type
      m00_axi_awlock  <= m_axi_write.out.awlock ; // Address write channel lock type
      m00_axi_awcache <= m_axi_write.out.awcache; // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_awprot  <= m_axi_write.out.awprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_awqos   <= m_axi_write.out.awqos  ; // Address write channel quality of service
      m00_axi_wdata   <= m_axi_write.out.wdata  ; // Write channel data
      m00_axi_wstrb   <= m_axi_write.out.wstrb  ; // Write channel write strobe
      m00_axi_wlast   <= m_axi_write.out.wlast  ; // Write channel last word flag
      m00_axi_wvalid  <= m_axi_write.out.wvalid ; // Write channel valid
      m00_axi_bready  <= m_axi_write.out.bready ; // Write response channel ready
    end
  end

// --------------------------------------------------------------------------------------
// DRIVE GLAY DESCRIPTOR
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    glay_descriptor.valid                      <= 0;
    glay_descriptor.payload.graph_csr_struct   <= graph_csr_struct  ;
    glay_descriptor.payload.vertex_out_degree  <= vertex_out_degree ;
    glay_descriptor.payload.vertex_in_degree   <= vertex_in_degree  ;
    glay_descriptor.payload.vertex_edges_idx   <= vertex_edges_idx  ;
    glay_descriptor.payload.edges_array_weight <= edges_array_weight;
    glay_descriptor.payload.edges_array_src    <= edges_array_src   ;
    glay_descriptor.payload.edges_array_dest   <= edges_array_dest  ;
    glay_descriptor.payload.auxiliary_1        <= auxiliary_1       ;
    glay_descriptor.payload.auxiliary_2        <= auxiliary_2       ;
  end


// --------------------------------------------------------------------------------------
// GLay CU -> Caches/PEs and Logic here.
// --------------------------------------------------------------------------------------

  glay_kernel_cu #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_glay_kernel_cu (
    .ap_clk          (ap_clk          ),
    .areset          (areset          ),
    .glay_control_in (glay_control_in ),
    .glay_control_out(glay_control_out),
    .glay_descriptor (glay_descriptor ),
    .m_axi_read_in   (m_axi_read.in   ),
    .m_axi_read_out  (m_axi_read.out  ),
    .m_axi_write_in  (m_axi_write.in  ),
    .m_axi_write_out (m_axi_write.out )
  );


endmodule : glay_kernel_afu

