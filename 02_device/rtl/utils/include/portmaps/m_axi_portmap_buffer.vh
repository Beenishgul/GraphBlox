  .axi_araddr         (m_axi_read.out.araddr    ), //Address read channel address
  .axi_arburst        (m_axi_read.out.arburst   ), //Address read channel burst type
  .axi_arcache        (m_axi_read.out.arcache   ), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .axi_arid           (m_axi_read.out.arid      ), //Address read channel ID
  .axi_arlen          (m_axi_read.out.arlen     ), //Address read channel burst length
  .axi_arlock         (m_axi_read.out.arlock    ), //Address read channel lock type
  .axi_arprot         (m_axi_read.out.arprot    ), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .axi_arqos          (m_axi_read.out.arqos     ), //Address read channel quality of service
  .axi_arready        (m_axi_read.in.arready    ), //Address read channel ready
  .axi_arsize         (m_axi_read.out.arsize    ), //Address read channel burst size. This signal indicates the size of each transfer in the burst
  .axi_arvalid        (m_axi_read.out.arvalid   ), //Address read channel valid
  .axi_arregion       (m_axi_read.out.arregion  ), //Address read channel valid
  .axi_awaddr         (m_axi_write.out.awaddr   ), //Address write channel address
  .axi_awburst        (m_axi_write.out.awburst  ), //Address write channel burst type
  .axi_awcache        (m_axi_write.out.awcache  ), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .axi_awid           (m_axi_write.out.awid     ), //Address write channel ID
  .axi_awlen          (m_axi_write.out.awlen    ), //Address write channel burst length
  .axi_awlock         (m_axi_write.out.awlock   ), //Address write channel lock type
  .axi_awprot         (m_axi_write.out.awprot   ), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .axi_awqos          (m_axi_write.out.awqos    ), //Address write channel quality of service
  .axi_awready        (m_axi_write.in.awready   ), //Address write channel ready
  .axi_awsize         (m_axi_write.out.awsize   ), //Address write channel burst size. This signal indicates the size of each transfer in the burst
  .axi_awvalid        (m_axi_write.out.awvalid  ), //Address write channel valid
  .axi_bid            (m_axi_write.in.bid       ), //Write response channel ID
  .axi_bready         (m_axi_write.out.bready   ), //Write response channel ready
  .axi_bresp          (m_axi_write.in.bresp     ), //Write response channel response
  .axi_bvalid         (m_axi_write.in.bvalid    ), //Write response channel valid
  .axi_rdata          (m_axi_read.in.rdata      ), //Read channel data
  .axi_rid            (m_axi_read.in.rid        ), //Read channel ID
  .axi_rlast          (m_axi_read.in.rlast      ), //Read channel last word
  .axi_rready         (m_axi_read.out.rready    ), //Read channel ready
  .axi_rresp          (m_axi_read.in.rresp      ), //Read channel response
  .axi_rvalid         (m_axi_read.in.rvalid     ), //Read channel valid
  .axi_wdata          (m_axi_write.out.wdata    ), //Write channel data
  .axi_wlast          (m_axi_write.out.wlast    ), //Write channel last word flag
  .axi_wready         (m_axi_write.in.wready    ), //Write channel ready
  .axi_wstrb          (m_axi_write.out.wstrb    ), //Write channel write strobe
  .axi_wvalid         (m_axi_write.out.wvalid   ), //Write channel valid
  .axi_awregion       (m_axi_write.out.awregion ), //Write channel valid