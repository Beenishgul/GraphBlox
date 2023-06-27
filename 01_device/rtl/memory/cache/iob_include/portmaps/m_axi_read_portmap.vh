.m_axi_arid(m_axi_arid), //Address read channel ID
.m_axi_araddr(m_axi_araddr), //Address read channel address
.m_axi_arlen(m_axi_arlen), //Address read channel burst length
.m_axi_arsize(m_axi_arsize), //Address read channel burst size. This signal indicates the size of each transfer in the burst
.m_axi_arburst(m_axi_arburst), //Address read channel burst type
.m_axi_arlock(m_axi_arlock), //Address read channel lock type
.m_axi_arcache(m_axi_arcache), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
.m_axi_arprot(m_axi_arprot), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
.m_axi_arqos(m_axi_arqos), //Address read channel quality of service
.m_axi_arvalid(m_axi_arvalid), //Address read channel valid
.m_axi_arready(m_axi_arready), //Address read channel ready
.m_axi_rid(m_axi_rid), //Read channel ID
.m_axi_rdata(m_axi_rdata), //Read channel data
.m_axi_rresp(m_axi_rresp), //Read channel response
.m_axi_rlast(m_axi_rlast), //Read channel last word
.m_axi_rvalid(m_axi_rvalid), //Read channel valid
.m_axi_rready(m_axi_rready), //Read channel ready
