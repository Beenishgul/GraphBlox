// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_cache.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-06-19 00:51:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_CACHE::*;
import PKG_MEMORY::*;

module kernel_cache (
  // System Signals
  input  logic                          ap_clk            ,
  input  logic                          areset            ,
  output AXI4SlaveReadInterfaceOutput   s_axi_read_out    ,
  input  AXI4SlaveReadInterfaceInput    s_axi_read_in     ,
  output AXI4SlaveWriteInterfaceOutput  s_axi_write_out   ,
  input  AXI4SlaveWriteInterfaceInput   s_axi_write_in    ,
  input  AXI4MasterReadInterfaceInput   m_axi_read_in     ,
  output AXI4MasterReadInterfaceOutput  m_axi_read_out    ,
  input  AXI4MasterWriteInterfaceInput  m_axi_write_in    ,
  output AXI4MasterWriteInterfaceOutput m_axi_write_out   ,
  output logic                          cache_setup_signal
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
  logic areset_system_cache;
  logic areset_control     ;

  logic cache_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;
  AXI4SlaveReadInterface   s_axi_read ;
  AXI4SlaveWriteInterface  s_axi_write;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_control      <= areset;
    areset_system_cache <= ~areset;
  end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      cache_setup_signal <= 1'b1;
    end
    else begin
      cache_setup_signal <= cache_setup_signal_int;
    end
  end

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS INPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    m_axi_write.in <= m_axi_write_in;
    m_axi_read.in  <= m_axi_read_in;
  end

// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    m_axi_read_out  <= m_axi_read.out;
    m_axi_write_out <= m_axi_write.out;
  end

// --------------------------------------------------------------------------------------
// AXI4 SLAVE
// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS INPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    s_axi_write_out <= s_axi_write.out;
    s_axi_read_out  <= s_axi_read.out;
  end

// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    s_axi_read.in  <= s_axi_read_in;
    s_axi_write.in <= s_axi_write_in;
  end

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
  assign m_axi_read.out.araddr[63]  = 1'b0;
  assign m_axi_write.out.awaddr[63] = 1'b0;

  system_cache_512x64 inst_system_cache_512x64 (
    .ACLK              (ap_clk                      ),
    .ARESETN           (areset_system_cache         ),
    .Initializing      (cache_setup_signal_int      ),
    
    .S0_AXI_GEN_ARUSER (0                           ),
    .S0_AXI_GEN_AWUSER (0                           ),
    .S0_AXI_GEN_RVALID (s_axi_read.out.rvalid       ), // Output Read channel valid
    .S0_AXI_GEN_ARREADY(s_axi_read.out.arready      ), // Output Read Address read channel ready
    .S0_AXI_GEN_RLAST  (s_axi_read.out.rlast        ), // Output Read channel last word
    .S0_AXI_GEN_RDATA  (s_axi_read.out.rdata        ), // Output Read channel data
    .S0_AXI_GEN_RID    (s_axi_read.out.rid          ), // Output Read channel ID
    .S0_AXI_GEN_RRESP  (s_axi_read.out.rresp        ), // Output Read channel response
    .S0_AXI_GEN_ARVALID(s_axi_read.in.arvalid       ), // Input Read Address read channel valid
    .S0_AXI_GEN_ARADDR (s_axi_read.in.araddr        ), // Input Read Address read channel address
    .S0_AXI_GEN_ARLEN  (s_axi_read.in.arlen         ), // Input Read Address channel burst length
    .S0_AXI_GEN_RREADY (s_axi_read.in.rready        ), // Input Read Read channel ready
    .S0_AXI_GEN_ARID   (s_axi_read.in.arid          ), // Input Read Address read channel ID
    .S0_AXI_GEN_ARSIZE (s_axi_read.in.arsize        ), // Input Read Address read channel burst size. This signal indicates the size of each transfer out the burst
    .S0_AXI_GEN_ARBURST(s_axi_read.in.arburst       ), // Input Read Address read channel burst type
    .S0_AXI_GEN_ARLOCK (s_axi_read.in.arlock        ), // Input Read Address read channel lock type
    .S0_AXI_GEN_ARCACHE(s_axi_read.in.arcache       ), // Input Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    .S0_AXI_GEN_ARPROT (s_axi_read.in.arprot        ), // Input Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    .S0_AXI_GEN_ARQOS  (s_axi_read.in.arqos         ), // Input Read Address channel quality of service
    .S0_AXI_GEN_AWREADY(s_axi_write.out.awready     ), // Output Write Address write channel ready
    .S0_AXI_GEN_WREADY (s_axi_write.out.wready      ), // Output Write channel ready
    .S0_AXI_GEN_BID    (s_axi_write.out.bid         ), // Output Write response channel ID
    .S0_AXI_GEN_BRESP  (s_axi_write.out.bresp       ), // Output Write channel response
    .S0_AXI_GEN_BVALID (s_axi_write.out.bvalid      ), // Output Write response channel valid
    .S0_AXI_GEN_AWVALID(s_axi_write.in.awvalid      ), // Input Write Address write channel valid
    .S0_AXI_GEN_AWID   (s_axi_write.in.awid         ), // Input Write Address write channel ID
    .S0_AXI_GEN_AWADDR (s_axi_write.in.awaddr       ), // Input Write Address write channel address
    .S0_AXI_GEN_AWLEN  (s_axi_write.in.awlen        ), // Input Write Address write channel burst length
    .S0_AXI_GEN_AWSIZE (s_axi_write.in.awsize       ), // Input Write Address write channel burst size. This signal indicates the size of each transfer out the burst
    .S0_AXI_GEN_AWBURST(s_axi_write.in.awburst      ), // Input Write Address write channel burst type
    .S0_AXI_GEN_AWLOCK (s_axi_write.in.awlock       ), // Input Write Address write channel lock type
    .S0_AXI_GEN_AWCACHE(s_axi_write.in.awcache      ), // Input Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    .S0_AXI_GEN_AWPROT (s_axi_write.in.awprot       ), // Input Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    .S0_AXI_GEN_AWQOS  (s_axi_write.in.awqos        ), // Input Write Address write channel quality of service
    .S0_AXI_GEN_WDATA  (s_axi_write.in.wdata        ), // Input Write channel data
    .S0_AXI_GEN_WSTRB  (s_axi_write.in.wstrb        ), // Input Write channel write strobe
    .S0_AXI_GEN_WLAST  (s_axi_write.in.wlast        ), // Input Write channel last word flag
    .S0_AXI_GEN_WVALID (s_axi_write.in.wvalid       ), // Input Write channel valid
    .S0_AXI_GEN_BREADY (s_axi_write.in.bready       ), // Input Write response channel ready
    
    .M0_AXI_RVALID     (m_axi_read.in.rvalid        ), // Input Read channel valid
    .M0_AXI_ARREADY    (m_axi_read.in.arready       ), // Input Read Address read channel ready
    .M0_AXI_RLAST      (m_axi_read.in.rlast         ), // Input Read channel last word
    .M0_AXI_RDATA      (m_axi_read.in.rdata         ), // Input Read channel data
    .M0_AXI_RID        (m_axi_read.in.rid           ), // Input Read channel ID
    .M0_AXI_RRESP      (m_axi_read.in.rresp         ), // Input Read channel response
    .M0_AXI_ARVALID    (m_axi_read.out.arvalid      ), // Output Read Address read channel valid
    .M0_AXI_ARADDR     (m_axi_read.out.araddr[62:0] ), // Output Read Address read channel address
    .M0_AXI_ARLEN      (m_axi_read.out.arlen        ), // Output Read Address channel burst length
    .M0_AXI_RREADY     (m_axi_read.out.rready       ), // Output Read Read channel ready
    .M0_AXI_ARID       (m_axi_read.out.arid         ), // Output Read Address read channel ID
    .M0_AXI_ARSIZE     (m_axi_read.out.arsize       ), // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
    .M0_AXI_ARBURST    (m_axi_read.out.arburst      ), // Output Read Address read channel burst type
    .M0_AXI_ARLOCK     (m_axi_read.out.arlock       ), // Output Read Address read channel lock type
    .M0_AXI_ARCACHE    (m_axi_read.out.arcache      ), // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    .M0_AXI_ARPROT     (m_axi_read.out.arprot       ), // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    .M0_AXI_ARQOS      (m_axi_read.out.arqos        ), // Output Read Address channel quality of service
    .M0_AXI_AWREADY    (m_axi_write.in.awready      ), // Input Write Address write channel ready
    .M0_AXI_WREADY     (m_axi_write.in.wready       ), // Input Write channel ready
    .M0_AXI_BID        (m_axi_write.in.bid          ), // Input Write response channel ID
    .M0_AXI_BRESP      (m_axi_write.in.bresp        ), // Input Write channel response
    .M0_AXI_BVALID     (m_axi_write.in.bvalid       ), // Input Write response channel valid
    .M0_AXI_AWVALID    (m_axi_write.out.awvalid     ), // Output Write Address write channel valid
    .M0_AXI_AWID       (m_axi_write.out.awid        ), // Output Write Address write channel ID
    .M0_AXI_AWADDR     (m_axi_write.out.awaddr[62:0]), // Output Write Address write channel address
    .M0_AXI_AWLEN      (m_axi_write.out.awlen       ), // Output Write Address write channel burst length
    .M0_AXI_AWSIZE     (m_axi_write.out.awsize      ), // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
    .M0_AXI_AWBURST    (m_axi_write.out.awburst     ), // Output Write Address write channel burst type
    .M0_AXI_AWLOCK     (m_axi_write.out.awlock      ), // Output Write Address write channel lock type
    .M0_AXI_AWCACHE    (m_axi_write.out.awcache     ), // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    .M0_AXI_AWPROT     (m_axi_write.out.awprot      ), // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    .M0_AXI_AWQOS      (m_axi_write.out.awqos       ), // Output Write Address write channel quality of service
    .M0_AXI_WDATA      (m_axi_write.out.wdata       ), // Output Write channel data
    .M0_AXI_WSTRB      (m_axi_write.out.wstrb       ), // Output Write channel write strobe
    .M0_AXI_WLAST      (m_axi_write.out.wlast       ), // Output Write channel last word flag
    .M0_AXI_WVALID     (m_axi_write.out.wvalid      ), // Output Write channel valid
    .M0_AXI_BREADY     (m_axi_write.out.bready      )  // Output Write response channel ready
  );

endmodule : kernel_cache
