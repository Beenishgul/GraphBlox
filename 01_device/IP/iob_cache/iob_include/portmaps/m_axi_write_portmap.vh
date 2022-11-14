.m_axi_awid(m_axi_awid), //Address write channel ID
.m_axi_awaddr(m_axi_awaddr), //Address write channel address
.m_axi_awlen(m_axi_awlen), //Address write channel burst length
.m_axi_awsize(m_axi_awsize), //Address write channel burst size. This signal indicates the size of each transfer in the burst
.m_axi_awburst(m_axi_awburst), //Address write channel burst type
.m_axi_awlock(m_axi_awlock), //Address write channel lock type
.m_axi_awcache(m_axi_awcache), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
.m_axi_awprot(m_axi_awprot), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
.m_axi_awqos(m_axi_awqos), //Address write channel quality of service
.m_axi_awvalid(m_axi_awvalid), //Address write channel valid
.m_axi_awready(m_axi_awready), //Address write channel ready
.m_axi_wdata(m_axi_wdata), //Write channel data
.m_axi_wstrb(m_axi_wstrb), //Write channel write strobe
.m_axi_wlast(m_axi_wlast), //Write channel last word flag
.m_axi_wvalid(m_axi_wvalid), //Write channel valid
.m_axi_wready(m_axi_wready), //Write channel ready
.m_axi_bid(m_axi_bid), //Write response channel ID
.m_axi_bresp(m_axi_bresp), //Write response channel response
.m_axi_bvalid(m_axi_bvalid), //Write response channel valid
.m_axi_bready(m_axi_bready), //Write response channel ready
