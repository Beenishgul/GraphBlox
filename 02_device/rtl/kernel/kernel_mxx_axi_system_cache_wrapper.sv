
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_mxx_axi_system_cache_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"



module kernel_m00_axi_system_cache_be512x33_mid32x33_wrapper  #(
  parameter NUM_CUS             = 1
) (
  // System Signals
  input  logic                                  ap_clk            ,
  input  logic                                  areset            ,
  

  output M00_AXI4_MID_SlaveReadInterfaceOutput  s0_axi_read_out [NUM_CUS-1:0]    ,
  input  M00_AXI4_MID_SlaveReadInterfaceInput   s0_axi_read_in  [NUM_CUS-1:0]    ,
  output M00_AXI4_MID_SlaveWriteInterfaceOutput s0_axi_write_out[NUM_CUS-1:0]    ,
  input  M00_AXI4_MID_SlaveWriteInterfaceInput  s0_axi_write_in [NUM_CUS-1:0]    ,
  

  output M01_AXI4_MID_SlaveReadInterfaceOutput  s1_axi_read_out [NUM_CUS-1:0]    ,
  input  M01_AXI4_MID_SlaveReadInterfaceInput   s1_axi_read_in  [NUM_CUS-1:0]    ,
  output M01_AXI4_MID_SlaveWriteInterfaceOutput s1_axi_write_out[NUM_CUS-1:0]    ,
  input  M01_AXI4_MID_SlaveWriteInterfaceInput  s1_axi_write_in [NUM_CUS-1:0]    ,
  

  input  M00_AXI4_BE_MasterReadInterfaceInput   m_axi_read_in     ,
  output M00_AXI4_BE_MasterReadInterfaceOutput  m_axi_read_out    ,
  input  M00_AXI4_BE_MasterWriteInterfaceInput  m_axi_write_in    ,
  output M00_AXI4_BE_MasterWriteInterfaceOutput m_axi_write_out   ,
  input  S00_AXI4_LITE_MID_REQ_T                s_axi_lite_in  [NUM_CUS-1:0]    ,
  output S00_AXI4_LITE_MID_RESP_T               s_axi_lite_out [NUM_CUS-1:0]    ,
  output logic                                  cache_setup_signal
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_system_cache;
logic areset_control     ;

logic cache_setup_signal_int;

// logic m_axi_read_out_araddr_33 ;
// logic m_axi_write_out_awaddr_33;

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
// System cache
// --------------------------------------------------------------------------------------
// assign m_axi_read_out.araddr[33-1]  = 1'b0;
// assign m_axi_write_out.awaddr[33-1] = 1'b0;
assign m_axi_write_out.awregion   = 0;
assign m_axi_read_out.arregion    = 0;

m00_axi_system_cache_be512x33_mid32x33 inst_m00_axi_system_cache_be512x33_mid32x33 (
  

  .S0_AXI_GEN_ARUSER (0                           ),
  .S0_AXI_GEN_AWUSER (0                           ),
  .S0_AXI_GEN_RVALID (s0_axi_read_out[0].rvalid       ), // Output Read channel valid
  .S0_AXI_GEN_ARREADY(s0_axi_read_out[0].arready      ), // Output Read Address read channel ready
  .S0_AXI_GEN_RLAST  (s0_axi_read_out[0].rlast        ), // Output Read channel last word
  .S0_AXI_GEN_RDATA  (s0_axi_read_out[0].rdata        ), // Output Read channel data
  .S0_AXI_GEN_RID    (s0_axi_read_out[0].rid          ), // Output Read channel ID
  .S0_AXI_GEN_RRESP  (s0_axi_read_out[0].rresp        ), // Output Read channel response
  .S0_AXI_GEN_ARVALID(s0_axi_read_in[0].arvalid       ), // Input Read Address read channel valid
  .S0_AXI_GEN_ARADDR (s0_axi_read_in[0].araddr        ), // Input Read Address read channel address
  .S0_AXI_GEN_ARLEN  (s0_axi_read_in[0].arlen         ), // Input Read Address channel burst length
  .S0_AXI_GEN_RREADY (s0_axi_read_in[0].rready        ), // Input Read Read channel ready
  .S0_AXI_GEN_ARID   (s0_axi_read_in[0].arid          ), // Input Read Address read channel ID
  .S0_AXI_GEN_ARSIZE (s0_axi_read_in[0].arsize        ), // Input Read Address read channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_ARBURST(s0_axi_read_in[0].arburst       ), // Input Read Address read channel burst type
  .S0_AXI_GEN_ARLOCK (s0_axi_read_in[0].arlock        ), // Input Read Address read channel lock type
  .S0_AXI_GEN_ARCACHE(s0_axi_read_in[0].arcache       ), // Input Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_ARPROT (s0_axi_read_in[0].arprot        ), // Input Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_ARQOS  (s0_axi_read_in[0].arqos         ), // Input Read Address channel quality of service
  .S0_AXI_GEN_AWREADY(s0_axi_write_out[0].awready     ), // Output Write Address write channel ready
  .S0_AXI_GEN_WREADY (s0_axi_write_out[0].wready      ), // Output Write channel ready
  .S0_AXI_GEN_BID    (s0_axi_write_out[0].bid         ), // Output Write response channel ID
  .S0_AXI_GEN_BRESP  (s0_axi_write_out[0].bresp       ), // Output Write channel response
  .S0_AXI_GEN_BVALID (s0_axi_write_out[0].bvalid      ), // Output Write response channel valid
  .S0_AXI_GEN_AWVALID(s0_axi_write_in[0].awvalid      ), // Input Write Address write channel valid
  .S0_AXI_GEN_AWID   (s0_axi_write_in[0].awid         ), // Input Write Address write channel ID
  .S0_AXI_GEN_AWADDR (s0_axi_write_in[0].awaddr       ), // Input Write Address write channel address
  .S0_AXI_GEN_AWLEN  (s0_axi_write_in[0].awlen        ), // Input Write Address write channel burst length
  .S0_AXI_GEN_AWSIZE (s0_axi_write_in[0].awsize       ), // Input Write Address write channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_AWBURST(s0_axi_write_in[0].awburst      ), // Input Write Address write channel burst type
  .S0_AXI_GEN_AWLOCK (s0_axi_write_in[0].awlock       ), // Input Write Address write channel lock type
  .S0_AXI_GEN_AWCACHE(s0_axi_write_in[0].awcache      ), // Input Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_AWPROT (s0_axi_write_in[0].awprot       ), // Input Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_AWQOS  (s0_axi_write_in[0].awqos        ), // Input Write Address write channel quality of service
  .S0_AXI_GEN_WDATA  (s0_axi_write_in[0].wdata        ), // Input Write channel data
  .S0_AXI_GEN_WSTRB  (s0_axi_write_in[0].wstrb        ), // Input Write channel write strobe
  .S0_AXI_GEN_WLAST  (s0_axi_write_in[0].wlast        ), // Input Write channel last word flag
  .S0_AXI_GEN_WVALID (s0_axi_write_in[0].wvalid       ), // Input Write channel valid
  .S0_AXI_GEN_BREADY (s0_axi_write_in[0].bready       ), // Input Write response channel ready
  

  .S1_AXI_GEN_ARUSER (0                           ),
  .S1_AXI_GEN_AWUSER (0                           ),
  .S1_AXI_GEN_RVALID (s1_axi_read_out[0].rvalid       ), // Output Read channel valid
  .S1_AXI_GEN_ARREADY(s1_axi_read_out[0].arready      ), // Output Read Address read channel ready
  .S1_AXI_GEN_RLAST  (s1_axi_read_out[0].rlast        ), // Output Read channel last word
  .S1_AXI_GEN_RDATA  (s1_axi_read_out[0].rdata        ), // Output Read channel data
  .S1_AXI_GEN_RID    (s1_axi_read_out[0].rid          ), // Output Read channel ID
  .S1_AXI_GEN_RRESP  (s1_axi_read_out[0].rresp        ), // Output Read channel response
  .S1_AXI_GEN_ARVALID(s1_axi_read_in[0].arvalid       ), // Input Read Address read channel valid
  .S1_AXI_GEN_ARADDR (s1_axi_read_in[0].araddr        ), // Input Read Address read channel address
  .S1_AXI_GEN_ARLEN  (s1_axi_read_in[0].arlen         ), // Input Read Address channel burst length
  .S1_AXI_GEN_RREADY (s1_axi_read_in[0].rready        ), // Input Read Read channel ready
  .S1_AXI_GEN_ARID   (s1_axi_read_in[0].arid          ), // Input Read Address read channel ID
  .S1_AXI_GEN_ARSIZE (s1_axi_read_in[0].arsize        ), // Input Read Address read channel burst size. This signal indicates the size of each transfer out the burst
  .S1_AXI_GEN_ARBURST(s1_axi_read_in[0].arburst       ), // Input Read Address read channel burst type
  .S1_AXI_GEN_ARLOCK (s1_axi_read_in[0].arlock        ), // Input Read Address read channel lock type
  .S1_AXI_GEN_ARCACHE(s1_axi_read_in[0].arcache       ), // Input Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S1_AXI_GEN_ARPROT (s1_axi_read_in[0].arprot        ), // Input Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S1_AXI_GEN_ARQOS  (s1_axi_read_in[0].arqos         ), // Input Read Address channel quality of service
  .S1_AXI_GEN_AWREADY(s1_axi_write_out[0].awready     ), // Output Write Address write channel ready
  .S1_AXI_GEN_WREADY (s1_axi_write_out[0].wready      ), // Output Write channel ready
  .S1_AXI_GEN_BID    (s1_axi_write_out[0].bid         ), // Output Write response channel ID
  .S1_AXI_GEN_BRESP  (s1_axi_write_out[0].bresp       ), // Output Write channel response
  .S1_AXI_GEN_BVALID (s1_axi_write_out[0].bvalid      ), // Output Write response channel valid
  .S1_AXI_GEN_AWVALID(s1_axi_write_in[0].awvalid      ), // Input Write Address write channel valid
  .S1_AXI_GEN_AWID   (s1_axi_write_in[0].awid         ), // Input Write Address write channel ID
  .S1_AXI_GEN_AWADDR (s1_axi_write_in[0].awaddr       ), // Input Write Address write channel address
  .S1_AXI_GEN_AWLEN  (s1_axi_write_in[0].awlen        ), // Input Write Address write channel burst length
  .S1_AXI_GEN_AWSIZE (s1_axi_write_in[0].awsize       ), // Input Write Address write channel burst size. This signal indicates the size of each transfer out the burst
  .S1_AXI_GEN_AWBURST(s1_axi_write_in[0].awburst      ), // Input Write Address write channel burst type
  .S1_AXI_GEN_AWLOCK (s1_axi_write_in[0].awlock       ), // Input Write Address write channel lock type
  .S1_AXI_GEN_AWCACHE(s1_axi_write_in[0].awcache      ), // Input Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S1_AXI_GEN_AWPROT (s1_axi_write_in[0].awprot       ), // Input Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S1_AXI_GEN_AWQOS  (s1_axi_write_in[0].awqos        ), // Input Write Address write channel quality of service
  .S1_AXI_GEN_WDATA  (s1_axi_write_in[0].wdata        ), // Input Write channel data
  .S1_AXI_GEN_WSTRB  (s1_axi_write_in[0].wstrb        ), // Input Write channel write strobe
  .S1_AXI_GEN_WLAST  (s1_axi_write_in[0].wlast        ), // Input Write channel last word flag
  .S1_AXI_GEN_WVALID (s1_axi_write_in[0].wvalid       ), // Input Write channel valid
  .S1_AXI_GEN_BREADY (s1_axi_write_in[0].bready       ), // Input Write response channel ready
  

  .M0_AXI_RVALID     (m_axi_read_in.rvalid        ), // Input Read channel valid
  .M0_AXI_ARREADY    (m_axi_read_in.arready       ), // Input Read Address read channel ready
  .M0_AXI_RLAST      (m_axi_read_in.rlast         ), // Input Read channel last word
  .M0_AXI_RDATA      (m_axi_read_in.rdata         ), // Input Read channel data
  .M0_AXI_RID        (m_axi_read_in.rid           ), // Input Read channel ID
  .M0_AXI_RRESP      (m_axi_read_in.rresp         ), // Input Read channel response
  .M0_AXI_ARVALID    (m_axi_read_out.arvalid      ), // Output Read Address read channel valid
   //.M0_AXI_ARADDR     ({m_axi_read_out_araddr_33, m_axi_read_out.araddr[33-2:0]} ), // Output Read Address read channel address
  .M0_AXI_ARADDR     (m_axi_read_out.araddr       ), // Output Read Address read channel address
  .M0_AXI_ARLEN      (m_axi_read_out.arlen        ), // Output Read Address channel burst length
  .M0_AXI_RREADY     (m_axi_read_out.rready       ), // Output Read Read channel ready
  .M0_AXI_ARID       (m_axi_read_out.arid         ), // Output Read Address read channel ID
  .M0_AXI_ARSIZE     (m_axi_read_out.arsize       ), // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_ARBURST    (m_axi_read_out.arburst      ), // Output Read Address read channel burst type
  .M0_AXI_ARLOCK     (m_axi_read_out.arlock       ), // Output Read Address read channel lock type
  .M0_AXI_ARCACHE    (m_axi_read_out.arcache      ), // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_ARPROT     (m_axi_read_out.arprot       ), // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_ARQOS      (m_axi_read_out.arqos        ), // Output Read Address channel quality of service
  .M0_AXI_AWREADY    (m_axi_write_in.awready      ), // Input Write Address write channel ready
  .M0_AXI_WREADY     (m_axi_write_in.wready       ), // Input Write channel ready
  .M0_AXI_BID        (m_axi_write_in.bid          ), // Input Write response channel ID
  .M0_AXI_BRESP      (m_axi_write_in.bresp        ), // Input Write channel response
  .M0_AXI_BVALID     (m_axi_write_in.bvalid       ), // Input Write response channel valid
  .M0_AXI_AWVALID    (m_axi_write_out.awvalid     ), // Output Write Address write channel valid
  .M0_AXI_AWID       (m_axi_write_out.awid        ), // Output Write Address write channel ID
   //.M0_AXI_AWADDR     ({m_axi_write_out_awaddr_33, m_axi_write_out.awaddr[33-2:0]}), // Output Write Address write channel address
  .M0_AXI_AWADDR     (m_axi_write_out.awaddr      ), // Output Write Address write channel address
  .M0_AXI_AWLEN      (m_axi_write_out.awlen       ), // Output Write Address write channel burst length
  .M0_AXI_AWSIZE     (m_axi_write_out.awsize      ), // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_AWBURST    (m_axi_write_out.awburst     ), // Output Write Address write channel burst type
  .M0_AXI_AWLOCK     (m_axi_write_out.awlock      ), // Output Write Address write channel lock type
  .M0_AXI_AWCACHE    (m_axi_write_out.awcache     ), // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_AWPROT     (m_axi_write_out.awprot      ), // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_AWQOS      (m_axi_write_out.awqos       ), // Output Write Address write channel quality of service
  .M0_AXI_WDATA      (m_axi_write_out.wdata       ), // Output Write channel data
  .M0_AXI_WSTRB      (m_axi_write_out.wstrb       ), // Output Write channel write strobe
  .M0_AXI_WLAST      (m_axi_write_out.wlast       ), // Output Write channel last word flag
  .M0_AXI_WVALID     (m_axi_write_out.wvalid      ), // Output Write channel valid
  .M0_AXI_BREADY     (m_axi_write_out.bready      ),  // Output Write response channel ready
    

  .ACLK              (ap_clk                      ),
  .ARESETN           (areset_system_cache         ),
  .Initializing      (cache_setup_signal_int      )    
);

generate
    for (genvar i=0; i<NUM_CUS; i++) begin : generate_s_axi_lite_out
        assign s_axi_lite_out[i] = 0;
    end
endgenerate

endmodule : kernel_m00_axi_system_cache_be512x33_mid32x33_wrapper




module kernel_m01_axi_system_cache_be512x33_mid32x33_wrapper  #(
  parameter NUM_CUS             = 1
) (
  // System Signals
  input  logic                                  ap_clk            ,
  input  logic                                  areset            ,
  

  output M01_AXI4_MID_SlaveReadInterfaceOutput  s0_axi_read_out [NUM_CUS-1:0]    ,
  input  M01_AXI4_MID_SlaveReadInterfaceInput   s0_axi_read_in  [NUM_CUS-1:0]    ,
  output M01_AXI4_MID_SlaveWriteInterfaceOutput s0_axi_write_out[NUM_CUS-1:0]    ,
  input  M01_AXI4_MID_SlaveWriteInterfaceInput  s0_axi_write_in [NUM_CUS-1:0]    ,
  

  input  M01_AXI4_BE_MasterReadInterfaceInput   m_axi_read_in     ,
  output M01_AXI4_BE_MasterReadInterfaceOutput  m_axi_read_out    ,
  input  M01_AXI4_BE_MasterWriteInterfaceInput  m_axi_write_in    ,
  output M01_AXI4_BE_MasterWriteInterfaceOutput m_axi_write_out   ,
  input  S01_AXI4_LITE_MID_REQ_T                s_axi_lite_in  [NUM_CUS-1:0]    ,
  output S01_AXI4_LITE_MID_RESP_T               s_axi_lite_out [NUM_CUS-1:0]    ,
  output logic                                  cache_setup_signal
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_system_cache;
logic areset_control     ;

logic cache_setup_signal_int;

// logic m_axi_read_out_araddr_33 ;
// logic m_axi_write_out_awaddr_33;

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
// System cache
// --------------------------------------------------------------------------------------
// assign m_axi_read_out.araddr[33-1]  = 1'b0;
// assign m_axi_write_out.awaddr[33-1] = 1'b0;
assign m_axi_write_out.awregion   = 0;
assign m_axi_read_out.arregion    = 0;

m01_axi_system_cache_be512x33_mid32x33 inst_m01_axi_system_cache_be512x33_mid32x33 (
  

  .S0_AXI_GEN_ARUSER (0                           ),
  .S0_AXI_GEN_AWUSER (0                           ),
  .S0_AXI_GEN_RVALID (s0_axi_read_out[0].rvalid       ), // Output Read channel valid
  .S0_AXI_GEN_ARREADY(s0_axi_read_out[0].arready      ), // Output Read Address read channel ready
  .S0_AXI_GEN_RLAST  (s0_axi_read_out[0].rlast        ), // Output Read channel last word
  .S0_AXI_GEN_RDATA  (s0_axi_read_out[0].rdata        ), // Output Read channel data
  .S0_AXI_GEN_RID    (s0_axi_read_out[0].rid          ), // Output Read channel ID
  .S0_AXI_GEN_RRESP  (s0_axi_read_out[0].rresp        ), // Output Read channel response
  .S0_AXI_GEN_ARVALID(s0_axi_read_in[0].arvalid       ), // Input Read Address read channel valid
  .S0_AXI_GEN_ARADDR (s0_axi_read_in[0].araddr        ), // Input Read Address read channel address
  .S0_AXI_GEN_ARLEN  (s0_axi_read_in[0].arlen         ), // Input Read Address channel burst length
  .S0_AXI_GEN_RREADY (s0_axi_read_in[0].rready        ), // Input Read Read channel ready
  .S0_AXI_GEN_ARID   (s0_axi_read_in[0].arid          ), // Input Read Address read channel ID
  .S0_AXI_GEN_ARSIZE (s0_axi_read_in[0].arsize        ), // Input Read Address read channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_ARBURST(s0_axi_read_in[0].arburst       ), // Input Read Address read channel burst type
  .S0_AXI_GEN_ARLOCK (s0_axi_read_in[0].arlock        ), // Input Read Address read channel lock type
  .S0_AXI_GEN_ARCACHE(s0_axi_read_in[0].arcache       ), // Input Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_ARPROT (s0_axi_read_in[0].arprot        ), // Input Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_ARQOS  (s0_axi_read_in[0].arqos         ), // Input Read Address channel quality of service
  .S0_AXI_GEN_AWREADY(s0_axi_write_out[0].awready     ), // Output Write Address write channel ready
  .S0_AXI_GEN_WREADY (s0_axi_write_out[0].wready      ), // Output Write channel ready
  .S0_AXI_GEN_BID    (s0_axi_write_out[0].bid         ), // Output Write response channel ID
  .S0_AXI_GEN_BRESP  (s0_axi_write_out[0].bresp       ), // Output Write channel response
  .S0_AXI_GEN_BVALID (s0_axi_write_out[0].bvalid      ), // Output Write response channel valid
  .S0_AXI_GEN_AWVALID(s0_axi_write_in[0].awvalid      ), // Input Write Address write channel valid
  .S0_AXI_GEN_AWID   (s0_axi_write_in[0].awid         ), // Input Write Address write channel ID
  .S0_AXI_GEN_AWADDR (s0_axi_write_in[0].awaddr       ), // Input Write Address write channel address
  .S0_AXI_GEN_AWLEN  (s0_axi_write_in[0].awlen        ), // Input Write Address write channel burst length
  .S0_AXI_GEN_AWSIZE (s0_axi_write_in[0].awsize       ), // Input Write Address write channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_AWBURST(s0_axi_write_in[0].awburst      ), // Input Write Address write channel burst type
  .S0_AXI_GEN_AWLOCK (s0_axi_write_in[0].awlock       ), // Input Write Address write channel lock type
  .S0_AXI_GEN_AWCACHE(s0_axi_write_in[0].awcache      ), // Input Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_AWPROT (s0_axi_write_in[0].awprot       ), // Input Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_AWQOS  (s0_axi_write_in[0].awqos        ), // Input Write Address write channel quality of service
  .S0_AXI_GEN_WDATA  (s0_axi_write_in[0].wdata        ), // Input Write channel data
  .S0_AXI_GEN_WSTRB  (s0_axi_write_in[0].wstrb        ), // Input Write channel write strobe
  .S0_AXI_GEN_WLAST  (s0_axi_write_in[0].wlast        ), // Input Write channel last word flag
  .S0_AXI_GEN_WVALID (s0_axi_write_in[0].wvalid       ), // Input Write channel valid
  .S0_AXI_GEN_BREADY (s0_axi_write_in[0].bready       ), // Input Write response channel ready
  

  .M0_AXI_RVALID     (m_axi_read_in.rvalid        ), // Input Read channel valid
  .M0_AXI_ARREADY    (m_axi_read_in.arready       ), // Input Read Address read channel ready
  .M0_AXI_RLAST      (m_axi_read_in.rlast         ), // Input Read channel last word
  .M0_AXI_RDATA      (m_axi_read_in.rdata         ), // Input Read channel data
  .M0_AXI_RID        (m_axi_read_in.rid           ), // Input Read channel ID
  .M0_AXI_RRESP      (m_axi_read_in.rresp         ), // Input Read channel response
  .M0_AXI_ARVALID    (m_axi_read_out.arvalid      ), // Output Read Address read channel valid
   //.M0_AXI_ARADDR     ({m_axi_read_out_araddr_33, m_axi_read_out.araddr[33-2:0]} ), // Output Read Address read channel address
  .M0_AXI_ARADDR     (m_axi_read_out.araddr       ), // Output Read Address read channel address
  .M0_AXI_ARLEN      (m_axi_read_out.arlen        ), // Output Read Address channel burst length
  .M0_AXI_RREADY     (m_axi_read_out.rready       ), // Output Read Read channel ready
  .M0_AXI_ARID       (m_axi_read_out.arid         ), // Output Read Address read channel ID
  .M0_AXI_ARSIZE     (m_axi_read_out.arsize       ), // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_ARBURST    (m_axi_read_out.arburst      ), // Output Read Address read channel burst type
  .M0_AXI_ARLOCK     (m_axi_read_out.arlock       ), // Output Read Address read channel lock type
  .M0_AXI_ARCACHE    (m_axi_read_out.arcache      ), // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_ARPROT     (m_axi_read_out.arprot       ), // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_ARQOS      (m_axi_read_out.arqos        ), // Output Read Address channel quality of service
  .M0_AXI_AWREADY    (m_axi_write_in.awready      ), // Input Write Address write channel ready
  .M0_AXI_WREADY     (m_axi_write_in.wready       ), // Input Write channel ready
  .M0_AXI_BID        (m_axi_write_in.bid          ), // Input Write response channel ID
  .M0_AXI_BRESP      (m_axi_write_in.bresp        ), // Input Write channel response
  .M0_AXI_BVALID     (m_axi_write_in.bvalid       ), // Input Write response channel valid
  .M0_AXI_AWVALID    (m_axi_write_out.awvalid     ), // Output Write Address write channel valid
  .M0_AXI_AWID       (m_axi_write_out.awid        ), // Output Write Address write channel ID
   //.M0_AXI_AWADDR     ({m_axi_write_out_awaddr_33, m_axi_write_out.awaddr[33-2:0]}), // Output Write Address write channel address
  .M0_AXI_AWADDR     (m_axi_write_out.awaddr      ), // Output Write Address write channel address
  .M0_AXI_AWLEN      (m_axi_write_out.awlen       ), // Output Write Address write channel burst length
  .M0_AXI_AWSIZE     (m_axi_write_out.awsize      ), // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_AWBURST    (m_axi_write_out.awburst     ), // Output Write Address write channel burst type
  .M0_AXI_AWLOCK     (m_axi_write_out.awlock      ), // Output Write Address write channel lock type
  .M0_AXI_AWCACHE    (m_axi_write_out.awcache     ), // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_AWPROT     (m_axi_write_out.awprot      ), // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_AWQOS      (m_axi_write_out.awqos       ), // Output Write Address write channel quality of service
  .M0_AXI_WDATA      (m_axi_write_out.wdata       ), // Output Write channel data
  .M0_AXI_WSTRB      (m_axi_write_out.wstrb       ), // Output Write channel write strobe
  .M0_AXI_WLAST      (m_axi_write_out.wlast       ), // Output Write channel last word flag
  .M0_AXI_WVALID     (m_axi_write_out.wvalid      ), // Output Write channel valid
  .M0_AXI_BREADY     (m_axi_write_out.bready      ),  // Output Write response channel ready
    

  .ACLK              (ap_clk                      ),
  .ARESETN           (areset_system_cache         ),
  .Initializing      (cache_setup_signal_int      )    
);

generate
    for (genvar i=0; i<NUM_CUS; i++) begin : generate_s_axi_lite_out
        assign s_axi_lite_out[i] = 0;
    end
endgenerate

endmodule : kernel_m01_axi_system_cache_be512x33_mid32x33_wrapper

