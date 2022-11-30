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
  parameter integer C_M00_AXI_ADDR_WIDTH = 64 ,
  parameter integer C_M00_AXI_DATA_WIDTH = 512
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
  input  wire [          IOB_AXI_ID_W-1:0] m00_axi_bid       , // Write response channel ID
  input  wire [          IOB_AXI_ID_W-1:0] m00_axi_rid       , // Read channel ID
  input  wire [                     2-1:0] m00_axi_rresp     , // Read channel response
  input  wire [                     2-1:0] m00_axi_bresp     , // Write channel response
  output wire [          IOB_AXI_ID_W-1:0] m00_axi_awid      , // Address write channel ID
  output wire [                     3-1:0] m00_axi_awsize    , // Address write channel burst size. This signal indicates the size of each transfer in the burst
  output wire [                     2-1:0] m00_axi_awburst   , // Address write channel burst type
  output wire [                     2-1:0] m00_axi_awlock    , // Address write channel lock type
  output wire [                     4-1:0] m00_axi_awcache   , // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  output wire [                     3-1:0] m00_axi_awprot    , // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  output wire [                     4-1:0] m00_axi_awqos     , // Address write channel quality of service
  output wire [          IOB_AXI_ID_W-1:0] m00_axi_arid      , // Address read channel ID
  output wire [                     3-1:0] m00_axi_arsize    , // Address read channel burst size. This signal indicates the size of each transfer in the burst
  output wire [                     2-1:0] m00_axi_arburst   , // Address read channel burst type
  output wire [                     2-1:0] m00_axi_arlock    , // Address read channel lock type
  output wire [                     4-1:0] m00_axi_arcache   , // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  output wire [                     3-1:0] m00_axi_arprot    , // Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  output wire [                     4-1:0] m00_axi_arqos     , // Address read channel quality of service
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
  logic                areset         = 1'b0            ;
  logic                ap_start_r     = 1'b0            ;
  logic                ap_idle_r      = 1'b1            ;
  logic                ap_start_pulse                   ;
  logic [CU_COUNT-1:0] ap_done_i                        ;
  logic [CU_COUNT-1:0] ap_done_r      = {CU_COUNT{1'b0}};


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


///////////////////////////////////////////////////////////////////////////////
// READ AXI4 SIGNALS OUTPUT
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// WRITE AXI4 SIGNALS INPUT
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
// WRITE AXI4 SIGNALS OUTPUT
///////////////////////////////////////////////////////////////////////////////


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

