    .m_axi_araddr (m_axi_read.out.araddr          ), //Address read channel address
    .m_axi_arburst(m_axi_read.out.arburst         ), //Address read channel burst type
    .m_axi_arcache(m_axi_read.out.arcache         ), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    .m_axi_arid   (m_axi_read.out.arid            ), //Address read channel ID
    .m_axi_arlen  (m_axi_read.out.arlen           ), //Address read channel burst length
    .m_axi_arlock (m_axi_read.out.arlock          ), //Address read channel lock type
    .m_axi_arprot (m_axi_read.out.arprot          ), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    .m_axi_arqos  (m_axi_read.out.arqos           ), //Address read channel quality of service
    .m_axi_arready(m_axi_read.in.arready          ), //Address read channel ready
    .m_axi_arsize (m_axi_read.out.arsize          ), //Address read channel burst size. This signal indicates the size of each transfer in the burst
    .m_axi_arvalid(m_axi_read.out.arvalid         ), //Address read channel valid
    .m_axi_awaddr (m_axi_write.out.awaddr         ), //Address write channel address
    .m_axi_awburst(m_axi_write.out.awburst        ), //Address write channel burst type
    .m_axi_awcache(m_axi_write.out.awcache        ), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    .m_axi_awid   (m_axi_write.out.awid           ), //Address write channel ID
    .m_axi_awlen  (m_axi_write.out.awlen          ), //Address write channel burst length
    .m_axi_awlock (m_axi_write.out.awlock         ), //Address write channel lock type
    .m_axi_awprot (m_axi_write.out.awprot         ), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    .m_axi_awqos  (m_axi_write.out.awqos          ), //Address write channel quality of service
    .m_axi_awready(m_axi_write.in.awready         ), //Address write channel ready
    .m_axi_awsize (m_axi_write.out.awsize         ), //Address write channel burst size. This signal indicates the size of each transfer in the burst
    .m_axi_awvalid(m_axi_write.out.awvalid        ), //Address write channel valid
    .m_axi_bid    (m_axi_write.in.bid             ), //Write response channel ID
    .m_axi_bready (m_axi_write.out.bready         ), //Write response channel ready
    .m_axi_bresp  (m_axi_write.in.bresp           ), //Write response channel response
    .m_axi_bvalid (m_axi_write.in.bvalid          ), //Write response channel valid
    .m_axi_rdata  (m_axi_read.in.rdata            ), //Read channel data
    .m_axi_rid    (m_axi_read.in.rid              ), //Read channel ID
    .m_axi_rlast  (m_axi_read.in.rlast            ), //Read channel last word
    .m_axi_rready (m_axi_read.out.rready          ), //Read channel ready
    .m_axi_rresp  (m_axi_read.in.rresp            ), //Read channel response
    .m_axi_rvalid (m_axi_read.in.rvalid           ), //Read channel valid
    .m_axi_wdata  (m_axi_write.out.wdata          ), //Write channel data
    .m_axi_wlast  (m_axi_write.out.wlast          ), //Write channel last word flag
    .m_axi_wready (m_axi_write.in.wready          ), //Write channel ready
    .m_axi_wstrb  (m_axi_write.out.wstrb          ), //Write channel write strobe
    .m_axi_wvalid (m_axi_write.out.wvalid         ), //Write channel valid