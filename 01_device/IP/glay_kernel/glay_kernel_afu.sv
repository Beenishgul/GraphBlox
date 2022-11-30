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
import GLOBALS_AFU_PKG::*;

module glay_kernel_afu #(
  parameter C_M00_AXI_ADDR_WIDTH = 64             ,
  parameter C_M00_AXI_DATA_WIDTH = 512            ,
  parameter NUM_GRAPH_CLUSTERS   = CU_COUNT_GLOBAL,
  parameter NUM_GRAPH_PE         = CU_COUNT_LOCAL
) (
  // System Signals
  input  wire                              ap_clk            ,
  input  wire                              ap_rst_n          ,
  // AXI4 master interface m00_axi
  output wire                              m00_axi_awvalid   ,
  input  wire                              m00_axi_awready   ,
  output wire [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr    ,
  output wire [                     8-1:0] m00_axi_awlen     ,
  output wire                              m00_axi_wvalid    ,
  input  wire                              m00_axi_wready    ,
  output wire [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata     ,
  output wire [C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb     ,
  output wire                              m00_axi_wlast     ,
  input  wire                              m00_axi_bvalid    ,
  output wire                              m00_axi_bready    ,
  output wire                              m00_axi_arvalid   ,
  input  wire                              m00_axi_arready   ,
  output wire [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr    ,
  output wire [                     8-1:0] m00_axi_arlen     ,
  input  wire                              m00_axi_rvalid    ,
  output wire                              m00_axi_rready    ,
  input  wire [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata     ,
  input  wire                              m00_axi_rlast     ,
  // Control Signals
  // AXI4 master interface m00_axi missing ports
  input  wire [          IOB_AXI_ID_W-1:0] m00_axi_bid       ,
  input  wire [          IOB_AXI_ID_W-1:0] m00_axi_rid       ,
  input  wire [                     2-1:0] m00_axi_rresp     ,
  input  wire [                     2-1:0] m00_axi_bresp     ,
  output wire [          IOB_AXI_ID_W-1:0] m00_axi_awid      ,
  output wire [                     3-1:0] m00_axi_awsize    ,
  output wire [                     2-1:0] m00_axi_awburst   ,
  output wire [                     2-1:0] m00_axi_awlock    ,
  output wire [                     4-1:0] m00_axi_awcache   ,
  output wire [                     3-1:0] m00_axi_awprot    ,
  output wire [                     4-1:0] m00_axi_awqos     ,
  output wire [          IOB_AXI_ID_W-1:0] m00_axi_arid      ,
  output wire [                     3-1:0] m00_axi_arsize    ,
  output wire [                     2-1:0] m00_axi_arburst   ,
  output wire [                     2-1:0] m00_axi_arlock    ,
  output wire [                     4-1:0] m00_axi_arcache   ,
  output wire [                     3-1:0] m00_axi_arprot    ,
  output wire [                     4-1:0] m00_axi_arqos     ,
  input  wire                              ap_start          ,
  output wire                              ap_idle           ,
  output wire                              ap_done           ,
  output wire                              ap_ready          ,
  input  wire                              ap_continue       ,
  input  wire [                    64-1:0] graph_csr_struct  ,
  input  wire [                    64-1:0] vertex_out_degree ,
  input  wire [                    64-1:0] vertex_in_degree  ,
  input  wire [                    64-1:0] vertex_edges_idx  ,
  input  wire [                    64-1:0] edges_array_weight,
  input  wire [                    64-1:0] edges_array_src   ,
  input  wire [                    64-1:0] edges_array_dest  ,
  input  wire [                    64-1:0] auxiliary_1       ,
  input  wire [                    64-1:0] auxiliary_2
);

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
  (* KEEP = "yes" *)
  logic                          areset         = 1'b0                      ;
  logic                          ap_start_r     = 1'b0                      ;
  logic                          ap_idle_r      = 1'b1                      ;
  logic                          ap_start_pulse                             ;
  logic [NUM_GRAPH_CLUSTERS-1:0] ap_done_i                                  ;
  logic [NUM_GRAPH_CLUSTERS-1:0] ap_done_r      = {NUM_GRAPH_CLUSTERS{1'b0}};

  GLAYDescriptorInterface        glay_descriptor;
  AXI4MasterReadInterfaceInput   m_axi_read_in  ;
  AXI4MasterReadInterfaceOutput  m_axi_read_out ;
  AXI4MasterWriteInterfaceInput  m_axi_write_in ;
  AXI4MasterWriteInterfaceOutput m_axi_write_out;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// Register and invert reset signal.
  always @(posedge ap_clk) begin
    areset <= ~ap_rst_n;
  end

// create pulse when ap_start transitions to 1
  always @(posedge ap_clk) begin
    begin
      ap_start_r <= ap_start;
    end
  end

  assign ap_start_pulse = ap_start & ~ap_start_r;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
  always @(posedge ap_clk) begin
    if (areset) begin
      ap_idle_r <= 1'b1;
    end
    else begin
      ap_idle_r <= ap_done ? 1'b1 :
        ap_start_pulse ? 1'b0 : ap_idle;
    end
  end

  assign ap_idle = ap_idle_r;

// Done logic
  always @(posedge ap_clk) begin
    if (areset) begin
      ap_done_r <= '0;
    end
    else begin
      ap_done_r <= (ap_continue & ap_done) ? '0 : ap_done_r | ap_done_i;
    end
  end

  assign ap_done = &ap_done_r;

// Ready Logic (non-pipelined case)
  assign ap_ready = ap_done;


///////////////////////////////////////////////////////////////////////////////
// DRIVE GLAY AXI4 SIGNALS
///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// READ AXI4 SIGNALS INPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (areset) begin
      m_axi_read_in <= 0;
    end
    else begin
      m_axi_read_in.rvalid  <= m00_axi_rvalid ; // Read channel valid
      m_axi_read_in.arready <= m00_axi_arready; // Address read channel ready
      m_axi_read_in.rlast   <= m00_axi_rlast  ; // Read channel last word
      m_axi_read_in.rdata   <= m00_axi_rdata  ; // Read channel data
      m_axi_read_in.rid     <= m00_axi_rid    ; // Read channel ID
      m_axi_read_in.rresp   <= m00_axi_rresp  ; // Read channel response
    end
  end

///////////////////////////////////////////////////////////////////////////////
// READ AXI4 SIGNALS OUTPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (areset) begin
      m00_axi_arvalid <= 0; // Address read channel valid
      m00_axi_araddr  <= 0; // Address read channel address
      m00_axi_arlen   <= 0; // Address write channel burst length
      m00_axi_rready  <= 0; // Read channel ready
      m00_axi_arid    <= 0; // Address read channel ID
      m00_axi_arsize  <= 0; // Address read channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_arburst <= 0; // Address read channel burst type
      m00_axi_arlock  <= 0; // Address read channel lock type
      m00_axi_arcache <= 0; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_arprot  <= 0; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_arqos   <= 0; // Address write channel quality of service
    end
    else begin
      m00_axi_arvalid <= m_axi_read_out.arvalid; // Address read channel valid
      m00_axi_araddr  <= m_axi_read_out.araddr;  // Address read channel address
      m00_axi_arlen   <= m_axi_read_out.arlen;   // Address write channel burst length
      m00_axi_rready  <= m_axi_read_out.rready;  // Read channel ready
      m00_axi_arid    <= m_axi_read_out.arid;    // Address read channel ID
      m00_axi_arsize  <= m_axi_read_out.arsize;  // Address read channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_arburst <= m_axi_read_out.arburst; // Address read channel burst type
      m00_axi_arlock  <= m_axi_read_out.arlock;  // Address read channel lock type
      m00_axi_arcache <= m_axi_read_out.arcache; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_arprot  <= m_axi_read_out.arprot;  // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_arqos   <= m_axi_read_out.arqos;   // Address write channel quality of service
    end
  end

///////////////////////////////////////////////////////////////////////////////
// WRITE AXI4 SIGNALS INPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (areset) begin
      m_axi_write_in <= 0;
    end
    else begin
      m_axi_write_in.awready <= m00_axi_awready; // Address write channel ready
      m_axi_write_in.wready  <= m00_axi_wready;  // Write channel ready
      m_axi_write_in.bid     <= m00_axi_bid;     // Write response channel ID
      m_axi_write_in.bresp   <= m00_axi_bresp;   // Write channel response
      m_axi_write_in.bvalid  <= m00_axi_bvalid;  // Write response channel valid
    end
  end

///////////////////////////////////////////////////////////////////////////////
// WRITE AXI4 SIGNALS OUTPUT
///////////////////////////////////////////////////////////////////////////////

  always @(posedge ap_clk) begin
    if (areset) begin
      m00_axi_awvalid <= 0;// Address write channel valid
      m00_axi_awid    <= 0;// Address write channel ID
      m00_axi_awaddr  <= 0;// Address write channel address
      m00_axi_awlen   <= 0;// Address write channel burst length
      m00_axi_awsize  <= 0;// Address write channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_awburst <= 0;// Address write channel burst type
      m00_axi_awlock  <= 0;// Address write channel lock type
      m00_axi_awcache <= 0;// Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_awprot  <= 0;// Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_awqos   <= 0;// Address write channel quality of service
      m00_axi_wdata   <= 0;// Write channel data
      m00_axi_wstrb   <= 0;// Write channel write strobe
      m00_axi_wlast   <= 0;// Write channel last word flag
      m00_axi_wvalid  <= 0;// Write channel valid
      m00_axi_bready  <= 0;// Write response channel ready
    end
    else begin
      m00_axi_awvalid <= m_axi_write_out.awvalid; // Address write channel valid
      m00_axi_awid    <= m_axi_write_out.awid   ; // Address write channel ID
      m00_axi_awaddr  <= m_axi_write_out.awaddr ; // Address write channel address
      m00_axi_awlen   <= m_axi_write_out.awlen  ; // Address write channel burst length
      m00_axi_awsize  <= m_axi_write_out.awsize ; // Address write channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_awburst <= m_axi_write_out.awburst; // Address write channel burst type
      m00_axi_awlock  <= m_axi_write_out.awlock ; // Address write channel lock type
      m00_axi_awcache <= m_axi_write_out.awcache; // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_awprot  <= m_axi_write_out.awprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_awqos   <= m_axi_write_out.awqos  ; // Address write channel quality of service
      m00_axi_wdata   <= m_axi_write_out.wdata  ; // Write channel data
      m00_axi_wstrb   <= m_axi_write_out.wstrb  ; // Write channel write strobe
      m00_axi_wlast   <= m_axi_write_out.wlast  ; // Write channel last word flag
      m00_axi_wvalid  <= m_axi_write_out.wvalid ; // Write channel valid
      m00_axi_bready  <= m_axi_write_out.bready ; // Write response channel ready
    end
  end

///////////////////////////////////////////////////////////////////////////////
// DRIVE GLAY DESCRIPTOR
///////////////////////////////////////////////////////////////////////////////


  glay_kernel_cu #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_glay_kernel_cu (
    .aclk           (aclk           ),
    .areset         (areset         ),
    .ap_start       (ap_start       ),
    .ap_done        (ap_done        ),
    .glay_descriptor(glay_descriptor),
    .m_axi_read_in  (m_axi_read_in  ),
    .m_axi_read_out (m_axi_read_out ),
    .m_axi_write_in (m_axi_write_in ),
    .m_axi_write_out(m_axi_write_out)
  );

endmodule : glay_kernel_afu

