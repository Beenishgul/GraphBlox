
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : mxx_axi_register_slice_be_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"



module m00_axi_register_slice_be_512x32_wrapper (
  // System Signals
  input  logic                                  ap_clk         ,
  input  logic                                  areset         ,
  output M00_AXI4_BE_SlaveReadInterfaceOutput   s_axi_read_out ,
  input  M00_AXI4_BE_SlaveReadInterfaceInput    s_axi_read_in  ,
  output M00_AXI4_BE_SlaveWriteInterfaceOutput  s_axi_write_out,
  input  M00_AXI4_BE_SlaveWriteInterfaceInput   s_axi_write_in ,
  input  M00_AXI4_BE_MasterReadInterfaceInput   m_axi_read_in  ,
  output M00_AXI4_BE_MasterReadInterfaceOutput  m_axi_read_out ,
  input  M00_AXI4_BE_MasterWriteInterfaceInput  m_axi_write_in ,
  output M00_AXI4_BE_MasterWriteInterfaceOutput m_axi_write_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_register_slice;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
M00_AXI4_BE_MasterReadInterface  m_axi_read ;
M00_AXI4_BE_MasterWriteInterface m_axi_write;
M00_AXI4_BE_SlaveReadInterface   s_axi_read ;
M00_AXI4_BE_SlaveWriteInterface  s_axi_write;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_register_slice <= ~areset;
end

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_write.in = m_axi_write_in;
assign m_axi_read.in  = m_axi_read_in;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out  = m_axi_read.out;
assign m_axi_write_out = m_axi_write.out;

// --------------------------------------------------------------------------------------
// AXI4 SLAVE
// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign s_axi_write_out = s_axi_write.out;
assign s_axi_read_out  = s_axi_read.out;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign s_axi_read.in  = s_axi_read_in;
assign s_axi_write.in = s_axi_write_in;

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
m00_axi_register_slice_be_512x32 inst_m00_axi_register_slice_be_512x32 (
  .aclk          (ap_clk                  ),
  .aresetn       (areset_register_slice   ),
  .s_axi_araddr  (s_axi_read.in.araddr    ), // input read address read channel address
  .s_axi_arburst (s_axi_read.in.arburst   ), // input read address read channel burst type
  .s_axi_arcache (s_axi_read.in.arcache   ), // input read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0011).
  .s_axi_arid    (s_axi_read.in.arid      ), // input read address read channel id
  .s_axi_arlen   (s_axi_read.in.arlen     ), // input read address channel burst length
  .s_axi_arlock  (s_axi_read.in.arlock    ), // input read address read channel lock type
  .s_axi_arprot  (s_axi_read.in.arprot    ), // input read address channel protection type. transactions set with normal, secure, and data attributes (000).
  .s_axi_arqos   (s_axi_read.in.arqos     ), // input read address channel quality of service
  .s_axi_arready (s_axi_read.out.arready  ), // output read address read channel ready
  .s_axi_arregion(s_axi_read.in.arregion  ),
  .s_axi_arsize  (s_axi_read.in.arsize    ), // input read address read channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_arvalid (s_axi_read.in.arvalid   ), // input read address read channel valid
  .s_axi_awaddr  (s_axi_write.in.awaddr   ), // input write address write channel address
  .s_axi_awburst (s_axi_write.in.awburst  ), // input write address write channel burst type
  .s_axi_awcache (s_axi_write.in.awcache  ), // input write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0011).
  .s_axi_awid    (s_axi_write.in.awid     ), // input write address write channel id
  .s_axi_awlen   (s_axi_write.in.awlen    ), // input write address write channel burst length
  .s_axi_awlock  (s_axi_write.in.awlock   ), // input write address write channel lock type
  .s_axi_awprot  (s_axi_write.in.awprot   ), // input write address write channel protection type. transactions set with normal, secure, and data attributes (000).
  .s_axi_awqos   (s_axi_write.in.awqos    ), // input write address write channel quality of service
  .s_axi_awready (s_axi_write.out.awready ), // output write address write channel ready
  .s_axi_awregion(s_axi_write.in.awregion ),
  .s_axi_awsize  (s_axi_write.in.awsize   ), // input write address write channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_awvalid (s_axi_write.in.awvalid  ), // input write address write channel valid
  .s_axi_bid     (s_axi_write.out.bid     ), // output write response channel id
  .s_axi_bready  (s_axi_write.in.bready   ), // input write response channel ready
  .s_axi_bresp   (s_axi_write.out.bresp   ), // output write channel response
  .s_axi_bvalid  (s_axi_write.out.bvalid  ), // output write response channel valid
  .s_axi_rdata   (s_axi_read.out.rdata    ), // output read channel data
  .s_axi_rid     (s_axi_read.out.rid      ), // output read channel id
  .s_axi_rlast   (s_axi_read.out.rlast    ), // output read channel last word
  .s_axi_rready  (s_axi_read.in.rready    ), // input read read channel ready
  .s_axi_rresp   (s_axi_read.out.rresp    ), // output read channel response
  .s_axi_rvalid  (s_axi_read.out.rvalid   ), // output read channel valid
  .s_axi_wdata   (s_axi_write.in.wdata    ), // input write channel data
  .s_axi_wlast   (s_axi_write.in.wlast    ), // input write channel last word flag
  .s_axi_wready  (s_axi_write.out.wready  ), // output write channel ready
  .s_axi_wstrb   (s_axi_write.in.wstrb    ), // input write channel write strobe
  .s_axi_wvalid  (s_axi_write.in.wvalid   ), // input write channel valid
  
  .m_axi_araddr  (m_axi_read.out.araddr   ), // output read address read channel address
  .m_axi_arburst (m_axi_read.out.arburst  ), // output read address read channel burst type
  .m_axi_arcache (m_axi_read.out.arcache  ), // output read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0011).
  .m_axi_arid    (m_axi_read.out.arid     ), // output read address read channel id
  .m_axi_arlen   (m_axi_read.out.arlen    ), // output read address channel burst length
  .m_axi_arlock  (m_axi_read.out.arlock   ), // output read address read channel lock type
  .m_axi_arprot  (m_axi_read.out.arprot   ), // output read address channel protection type. transactions set with normal, secure, and data attributes (000).
  .m_axi_arqos   (m_axi_read.out.arqos    ), // output read address channel quality of service
  .m_axi_arready (m_axi_read.in.arready   ), // input read address read channel ready
  .m_axi_arregion(m_axi_read.out.arregion ),
  .m_axi_arsize  (m_axi_read.out.arsize   ), // output read address read channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_arvalid (m_axi_read.out.arvalid  ), // output read address read channel valid
  .m_axi_awaddr  (m_axi_write.out.awaddr  ), // output write address write channel address
  .m_axi_awburst (m_axi_write.out.awburst ), // output write address write channel burst type
  .m_axi_awcache (m_axi_write.out.awcache ), // output write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0011).
  .m_axi_awid    (m_axi_write.out.awid    ), // output write address write channel id
  .m_axi_awlen   (m_axi_write.out.awlen   ), // output write address write channel burst length
  .m_axi_awlock  (m_axi_write.out.awlock  ), // output write address write channel lock type
  .m_axi_awprot  (m_axi_write.out.awprot  ), // output write address write channel protection type. transactions set with normal, secure, and data attributes (000).
  .m_axi_awqos   (m_axi_write.out.awqos   ), // output write address write channel quality of service
  .m_axi_awready (m_axi_write.in.awready  ), // input write address write channel ready
  .m_axi_awregion(m_axi_write.out.awregion),
  .m_axi_awsize  (m_axi_write.out.awsize  ), // output write address write channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_awvalid (m_axi_write.out.awvalid ), // output write address write channel valid
  .m_axi_bid     (m_axi_write.in.bid      ), // input write response channel id
  .m_axi_bready  (m_axi_write.out.bready  ), // output write response channel ready
  .m_axi_bresp   (m_axi_write.in.bresp    ), // input write channel response
  .m_axi_bvalid  (m_axi_write.in.bvalid   ), // input write response channel valid
  .m_axi_rdata   (m_axi_read.in.rdata     ), // input read channel data
  .m_axi_rid     (m_axi_read.in.rid       ), // input read channel id
  .m_axi_rlast   (m_axi_read.in.rlast     ), // input read channel last word
  .m_axi_rready  (m_axi_read.out.rready   ), // output read read channel ready
  .m_axi_rresp   (m_axi_read.in.rresp     ), // input read channel response
  .m_axi_rvalid  (m_axi_read.in.rvalid    ), // input read channel valid
  .m_axi_wdata   (m_axi_write.out.wdata   ), // output write channel data
  .m_axi_wlast   (m_axi_write.out.wlast   ), // output write channel last word flag
  .m_axi_wready  (m_axi_write.in.wready   ), // input write channel ready
  .m_axi_wstrb   (m_axi_write.out.wstrb   ), // output write channel write strobe
  .m_axi_wvalid  (m_axi_write.out.wvalid  )  // output write channel valid
);

endmodule : m00_axi_register_slice_be_512x32_wrapper

  


module m01_axi_register_slice_be_32x32_wrapper (
  // System Signals
  input  logic                                  ap_clk         ,
  input  logic                                  areset         ,
  output M01_AXI4_BE_SlaveReadInterfaceOutput   s_axi_read_out ,
  input  M01_AXI4_BE_SlaveReadInterfaceInput    s_axi_read_in  ,
  output M01_AXI4_BE_SlaveWriteInterfaceOutput  s_axi_write_out,
  input  M01_AXI4_BE_SlaveWriteInterfaceInput   s_axi_write_in ,
  input  M01_AXI4_BE_MasterReadInterfaceInput   m_axi_read_in  ,
  output M01_AXI4_BE_MasterReadInterfaceOutput  m_axi_read_out ,
  input  M01_AXI4_BE_MasterWriteInterfaceInput  m_axi_write_in ,
  output M01_AXI4_BE_MasterWriteInterfaceOutput m_axi_write_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_register_slice;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
M01_AXI4_BE_MasterReadInterface  m_axi_read ;
M01_AXI4_BE_MasterWriteInterface m_axi_write;
M01_AXI4_BE_SlaveReadInterface   s_axi_read ;
M01_AXI4_BE_SlaveWriteInterface  s_axi_write;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_register_slice <= ~areset;
end

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_write.in = m_axi_write_in;
assign m_axi_read.in  = m_axi_read_in;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out  = m_axi_read.out;
assign m_axi_write_out = m_axi_write.out;

// --------------------------------------------------------------------------------------
// AXI4 SLAVE
// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign s_axi_write_out = s_axi_write.out;
assign s_axi_read_out  = s_axi_read.out;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign s_axi_read.in  = s_axi_read_in;
assign s_axi_write.in = s_axi_write_in;

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
m01_axi_register_slice_be_32x32 inst_m01_axi_register_slice_be_32x32 (
  .aclk          (ap_clk                  ),
  .aresetn       (areset_register_slice   ),
  .s_axi_araddr  (s_axi_read.in.araddr    ), // input read address read channel address
  .s_axi_arburst (s_axi_read.in.arburst   ), // input read address read channel burst type
  .s_axi_arcache (s_axi_read.in.arcache   ), // input read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0111).
  .s_axi_arid    (s_axi_read.in.arid      ), // input read address read channel id
  .s_axi_arlen   (s_axi_read.in.arlen     ), // input read address channel burst length
  .s_axi_arlock  (s_axi_read.in.arlock    ), // input read address read channel lock type
  .s_axi_arprot  (s_axi_read.in.arprot    ), // input read address channel protection type. transactions set with normal, secure, and data attributes (010).
  .s_axi_arqos   (s_axi_read.in.arqos     ), // input read address channel quality of service
  .s_axi_arready (s_axi_read.out.arready  ), // output read address read channel ready
  .s_axi_arregion(s_axi_read.in.arregion  ),
  .s_axi_arsize  (s_axi_read.in.arsize    ), // input read address read channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_arvalid (s_axi_read.in.arvalid   ), // input read address read channel valid
  .s_axi_awaddr  (s_axi_write.in.awaddr   ), // input write address write channel address
  .s_axi_awburst (s_axi_write.in.awburst  ), // input write address write channel burst type
  .s_axi_awcache (s_axi_write.in.awcache  ), // input write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0111).
  .s_axi_awid    (s_axi_write.in.awid     ), // input write address write channel id
  .s_axi_awlen   (s_axi_write.in.awlen    ), // input write address write channel burst length
  .s_axi_awlock  (s_axi_write.in.awlock   ), // input write address write channel lock type
  .s_axi_awprot  (s_axi_write.in.awprot   ), // input write address write channel protection type. transactions set with normal, secure, and data attributes (010).
  .s_axi_awqos   (s_axi_write.in.awqos    ), // input write address write channel quality of service
  .s_axi_awready (s_axi_write.out.awready ), // output write address write channel ready
  .s_axi_awregion(s_axi_write.in.awregion ),
  .s_axi_awsize  (s_axi_write.in.awsize   ), // input write address write channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_awvalid (s_axi_write.in.awvalid  ), // input write address write channel valid
  .s_axi_bid     (s_axi_write.out.bid     ), // output write response channel id
  .s_axi_bready  (s_axi_write.in.bready   ), // input write response channel ready
  .s_axi_bresp   (s_axi_write.out.bresp   ), // output write channel response
  .s_axi_bvalid  (s_axi_write.out.bvalid  ), // output write response channel valid
  .s_axi_rdata   (s_axi_read.out.rdata    ), // output read channel data
  .s_axi_rid     (s_axi_read.out.rid      ), // output read channel id
  .s_axi_rlast   (s_axi_read.out.rlast    ), // output read channel last word
  .s_axi_rready  (s_axi_read.in.rready    ), // input read read channel ready
  .s_axi_rresp   (s_axi_read.out.rresp    ), // output read channel response
  .s_axi_rvalid  (s_axi_read.out.rvalid   ), // output read channel valid
  .s_axi_wdata   (s_axi_write.in.wdata    ), // input write channel data
  .s_axi_wlast   (s_axi_write.in.wlast    ), // input write channel last word flag
  .s_axi_wready  (s_axi_write.out.wready  ), // output write channel ready
  .s_axi_wstrb   (s_axi_write.in.wstrb    ), // input write channel write strobe
  .s_axi_wvalid  (s_axi_write.in.wvalid   ), // input write channel valid
  
  .m_axi_araddr  (m_axi_read.out.araddr   ), // output read address read channel address
  .m_axi_arburst (m_axi_read.out.arburst  ), // output read address read channel burst type
  .m_axi_arcache (m_axi_read.out.arcache  ), // output read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0111).
  .m_axi_arid    (m_axi_read.out.arid     ), // output read address read channel id
  .m_axi_arlen   (m_axi_read.out.arlen    ), // output read address channel burst length
  .m_axi_arlock  (m_axi_read.out.arlock   ), // output read address read channel lock type
  .m_axi_arprot  (m_axi_read.out.arprot   ), // output read address channel protection type. transactions set with normal, secure, and data attributes (010).
  .m_axi_arqos   (m_axi_read.out.arqos    ), // output read address channel quality of service
  .m_axi_arready (m_axi_read.in.arready   ), // input read address read channel ready
  .m_axi_arregion(m_axi_read.out.arregion ),
  .m_axi_arsize  (m_axi_read.out.arsize   ), // output read address read channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_arvalid (m_axi_read.out.arvalid  ), // output read address read channel valid
  .m_axi_awaddr  (m_axi_write.out.awaddr  ), // output write address write channel address
  .m_axi_awburst (m_axi_write.out.awburst ), // output write address write channel burst type
  .m_axi_awcache (m_axi_write.out.awcache ), // output write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable (0111).
  .m_axi_awid    (m_axi_write.out.awid    ), // output write address write channel id
  .m_axi_awlen   (m_axi_write.out.awlen   ), // output write address write channel burst length
  .m_axi_awlock  (m_axi_write.out.awlock  ), // output write address write channel lock type
  .m_axi_awprot  (m_axi_write.out.awprot  ), // output write address write channel protection type. transactions set with normal, secure, and data attributes (010).
  .m_axi_awqos   (m_axi_write.out.awqos   ), // output write address write channel quality of service
  .m_axi_awready (m_axi_write.in.awready  ), // input write address write channel ready
  .m_axi_awregion(m_axi_write.out.awregion),
  .m_axi_awsize  (m_axi_write.out.awsize  ), // output write address write channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_awvalid (m_axi_write.out.awvalid ), // output write address write channel valid
  .m_axi_bid     (m_axi_write.in.bid      ), // input write response channel id
  .m_axi_bready  (m_axi_write.out.bready  ), // output write response channel ready
  .m_axi_bresp   (m_axi_write.in.bresp    ), // input write channel response
  .m_axi_bvalid  (m_axi_write.in.bvalid   ), // input write response channel valid
  .m_axi_rdata   (m_axi_read.in.rdata     ), // input read channel data
  .m_axi_rid     (m_axi_read.in.rid       ), // input read channel id
  .m_axi_rlast   (m_axi_read.in.rlast     ), // input read channel last word
  .m_axi_rready  (m_axi_read.out.rready   ), // output read read channel ready
  .m_axi_rresp   (m_axi_read.in.rresp     ), // input read channel response
  .m_axi_rvalid  (m_axi_read.in.rvalid    ), // input read channel valid
  .m_axi_wdata   (m_axi_write.out.wdata   ), // output write channel data
  .m_axi_wlast   (m_axi_write.out.wlast   ), // output write channel last word flag
  .m_axi_wready  (m_axi_write.in.wready   ), // input write channel ready
  .m_axi_wstrb   (m_axi_write.out.wstrb   ), // output write channel write strobe
  .m_axi_wvalid  (m_axi_write.out.wvalid  )  // output write channel valid
);

endmodule : m01_axi_register_slice_be_32x32_wrapper

  