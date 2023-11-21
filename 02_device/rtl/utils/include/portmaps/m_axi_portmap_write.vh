.awaddr             (m_axi_write.out.awaddr  ), //Address write channel address
.awburst            (m_axi_write.out.awburst ), //Address write channel burst type
.awcache            (m_axi_write.out.awcache ), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
.awid               (m_axi_write.out.awid    ), //Address write channel ID
.awlen              (m_axi_write.out.awlen   ), //Address write channel burst length
.awlock             (m_axi_write.out.awlock  ), //Address write channel lock type
.awprot             (m_axi_write.out.awprot  ), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
.awqos              (m_axi_write.out.awqos   ), //Address write channel quality of service
.awready            (m_axi_write.in.awready  ), //Address write channel ready
.awsize             (m_axi_write.out.awsize  ), //Address write channel burst size. This signal indicates the size of each transfer in the burst
.awvalid            (m_axi_write.out.awvalid ), //Address write channel valid
.bid                (m_axi_write.in.bid      ), //Write response channel ID
.bready             (m_axi_write.out.bready  ), //Write response channel ready
.bresp              (m_axi_write.in.bresp    ), //Write response channel response
.bvalid             (m_axi_write.in.bvalid   ), //Write response channel valid
.wdata              (m_axi_write.out.wdata   ), //Write channel data
.wlast              (m_axi_write.out.wlast   ), //Write channel last word flag
.wready             (m_axi_write.in.wready   ), //Write channel ready
.wstrb              (m_axi_write.out.wstrb   ), //Write channel write strobe
.wvalid             (m_axi_write.out.wvalid  ), //Write channel valid
  