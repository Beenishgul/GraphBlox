// --------------------------------------------------------------------------------------
// Channel 0
// --------------------------------------------------------------------------------------
// Channel 0 READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi4_read[0].in.rvalid  = m00_axi_rvalid ; // Read channel valid
assign m_axi4_read[0].in.arready = m00_axi_arready; // Address read channel ready
assign m_axi4_read[0].in.rlast   = m00_axi_rlast  ; // Read channel last word
assign m_axi4_read[0].in.rdata   = swap_endianness_cacheline_axi_be(m00_axi_rdata, endian_read_reg)  ; // Read channel data
assign m_axi4_read[0].in.rid     = m00_axi_rid    ; // Read channel ID
assign m_axi4_read[0].in.rresp   = m00_axi_rresp  ; // Read channel response

// --------------------------------------------------------------------------------------
// Channel 0 READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m00_axi_arvalid = m_axi4_read[0].out.arvalid; // Address read channel valid
assign m00_axi_araddr  = m_axi4_read[0].out.araddr ; // Address read channel address
assign m00_axi_arlen   = m_axi4_read[0].out.arlen  ; // Address write channel burst length
assign m00_axi_rready  = m_axi4_read[0].out.rready ; // Read channel ready
assign m00_axi_arid    = m_axi4_read[0].out.arid   ; // Address read channel ID
assign m00_axi_arsize  = m_axi4_read[0].out.arsize ; // Address read channel burst size
assign m00_axi_arburst = m_axi4_read[0].out.arburst; // Address read channel burst type
assign m00_axi_arlock  = m_axi4_read[0].out.arlock ; // Address read channel lock type
assign m00_axi_arcache = m_axi4_read[0].out.arcache; // Address read channel memory type
assign m00_axi_arprot  = m_axi4_read[0].out.arprot ; // Address write channel protection type
assign m00_axi_arqos   = m_axi4_read[0].out.arqos  ; // Address write channel quality of service

// --------------------------------------------------------------------------------------
// Channel 0 WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi4_write[0].in.awready = m00_axi_awready; // Address write channel ready
assign m_axi4_write[0].in.wready  = m00_axi_wready ; // Write channel ready
assign m_axi4_write[0].in.bid     = m00_axi_bid    ; // Write response channel ID
assign m_axi4_write[0].in.bresp   = m00_axi_bresp  ; // Write channel response
assign m_axi4_write[0].in.bvalid  = m00_axi_bvalid ; // Write response channel valid

// --------------------------------------------------------------------------------------
// Channel 0 WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m00_axi_awvalid = m_axi4_write[0].out.awvalid; // Address write channel valid
assign m00_axi_awid    = m_axi4_write[0].out.awid   ; // Address write channel ID
assign m00_axi_awaddr  = m_axi4_write[0].out.awaddr ; // Address write channel address
assign m00_axi_awlen   = m_axi4_write[0].out.awlen  ; // Address write channel burst length
assign m00_axi_awsize  = m_axi4_write[0].out.awsize ; // Address write channel burst size
assign m00_axi_awburst = m_axi4_write[0].out.awburst; // Address write channel burst type
assign m00_axi_awlock  = m_axi4_write[0].out.awlock ; // Address write channel lock type
assign m00_axi_awcache = m_axi4_write[0].out.awcache; // Address write channel memory type
assign m00_axi_awprot  = m_axi4_write[0].out.awprot ; // Address write channel protection type
assign m00_axi_awqos   = m_axi4_write[0].out.awqos  ; // Address write channel quality of service
assign m00_axi_wdata   = swap_endianness_cacheline_axi_be(m_axi4_write[0].out.wdata, endian_write_reg); // Write channel data
assign m00_axi_wstrb   = m_axi4_write[0].out.wstrb  ; // Write channel write strobe
assign m00_axi_wlast   = m_axi4_write[0].out.wlast  ; // Write channel last word flag
assign m00_axi_wvalid  = m_axi4_write[0].out.wvalid ; // Write channel valid
assign m00_axi_bready  = m_axi4_write[0].out.bready ; // Write response channel ready
