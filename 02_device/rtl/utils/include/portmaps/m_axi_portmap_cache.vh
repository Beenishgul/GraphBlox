  .axi_araddr_o       (m_axi_read.out.araddr   ), //Address read channel address
  .axi_arburst_o      (m_axi_read.out.arburst  ), //Address read channel burst type
  .axi_arcache_o      (m_axi_read.out.arcache  ), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .axi_arid_o         (m_axi_read.out.arid     ), //Address read channel ID
  .axi_arlen_o        (m_axi_read.out.arlen    ), //Address read channel burst length
  .axi_arlock_o       (m_axi_read.out.arlock   ), //Address read channel lock type
  .axi_arprot_o       (m_axi_read.out.arprot   ), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .axi_arqos_o        (m_axi_read.out.arqos    ), //Address read channel quality of service
  .axi_arready_i      (m_axi_read.in.arready   ), //Address read channel ready
  .axi_arsize_o       (m_axi_read.out.arsize   ), //Address read channel burst size. This signal indicates the size of each transfer in the burst
  .axi_arvalid_o      (m_axi_read.out.arvalid  ), //Address read channel valid
  .axi_awaddr_o       (m_axi_write.out.awaddr  ), //Address write channel address
  .axi_awburst_o      (m_axi_write.out.awburst ), //Address write channel burst type
  .axi_awcache_o      (m_axi_write.out.awcache ), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .axi_awid_o         (m_axi_write.out.awid    ), //Address write channel ID
  .axi_awlen_o        (m_axi_write.out.awlen   ), //Address write channel burst length
  .axi_awlock_o       (m_axi_write.out.awlock  ), //Address write channel lock type
  .axi_awprot_o       (m_axi_write.out.awprot  ), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .axi_awqos_o        (m_axi_write.out.awqos   ), //Address write channel quality of service
  .axi_awready_i      (m_axi_write.in.awready  ), //Address write channel ready
  .axi_awsize_o       (m_axi_write.out.awsize  ), //Address write channel burst size. This signal indicates the size of each transfer in the burst
  .axi_awvalid_o      (m_axi_write.out.awvalid ), //Address write channel valid
  .axi_bid_i          (m_axi_write.in.bid      ), //Write response channel ID
  .axi_bready_o       (m_axi_write.out.bready  ), //Write response channel ready
  .axi_bresp_i        (m_axi_write.in.bresp    ), //Write response channel response
  .axi_bvalid_i       (m_axi_write.in.bvalid   ), //Write response channel valid
  .axi_rdata_i        (m_axi_read.in.rdata     ), //Read channel data
  .axi_rid_i          (m_axi_read.in.rid       ), //Read channel ID
  .axi_rlast_i        (m_axi_read.in.rlast     ), //Read channel last word
  .axi_rready_o       (m_axi_read.out.rready   ), //Read channel ready
  .axi_rresp_i        (m_axi_read.in.rresp     ), //Read channel response
  .axi_rvalid_i       (m_axi_read.in.rvalid    ), //Read channel valid
  .axi_wdata_o        (m_axi_write.out.wdata   ), //Write channel data
  .axi_wlast_o        (m_axi_write.out.wlast   ), //Write channel last word flag
  .axi_wready_i       (m_axi_write.in.wready   ), //Write channel ready
  .axi_wstrb_o        (m_axi_write.out.wstrb   ), //Write channel write strobe
  .axi_wvalid_o       (m_axi_write.out.wvalid  ), //Write channel valid