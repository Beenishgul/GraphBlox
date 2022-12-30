  //START_IO_TABLE m_axi_m_port
 `IOB_OUTPUT(m_axi_awid, AXI_ID_W), //Address write channel ID
 `IOB_OUTPUT(m_axi_awaddr, AXI_ADDR_W), //Address write channel address
 `IOB_OUTPUT(m_axi_awlen, AXI_LEN_W), //Address write channel burst length
 `IOB_OUTPUT(m_axi_awsize, 3), //Address write channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_awburst, 2), //Address write channel burst type
 `IOB_OUTPUT(m_axi_awlock, 2), //Address write channel lock type
 `IOB_OUTPUT(m_axi_awcache, 4), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_awprot, 3), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_awqos, 4), //Address write channel quality of service
 `IOB_OUTPUT(m_axi_awvalid, 1), //Address write channel valid
 `IOB_INPUT(m_axi_awready, 1), //Address write channel ready
 `IOB_OUTPUT(m_axi_wdata, AXI_DATA_W), //Write channel data
 `IOB_OUTPUT(m_axi_wstrb, (AXI_DATA_W/8)), //Write channel write strobe
 `IOB_OUTPUT(m_axi_wlast, 1), //Write channel last word flag
 `IOB_OUTPUT(m_axi_wvalid, 1), //Write channel valid
 `IOB_INPUT(m_axi_wready, 1), //Write channel ready
 `IOB_INPUT(m_axi_bid, AXI_ID_W), //Write response channel ID
 `IOB_INPUT(m_axi_bresp, 2), //Write response channel response
 `IOB_INPUT(m_axi_bvalid, 1), //Write response channel valid
 `IOB_OUTPUT(m_axi_bready, 1), //Write response channel ready
 `IOB_OUTPUT(m_axi_arid, AXI_ID_W), //Address read channel ID
 `IOB_OUTPUT(m_axi_araddr, AXI_ADDR_W), //Address read channel address
 `IOB_OUTPUT(m_axi_arlen, AXI_LEN_W), //Address read channel burst length
 `IOB_OUTPUT(m_axi_arsize, 3), //Address read channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_arburst, 2), //Address read channel burst type
 `IOB_OUTPUT(m_axi_arlock, 2), //Address read channel lock type
 `IOB_OUTPUT(m_axi_arcache, 4), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_arprot, 3), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_arqos, 4), //Address read channel quality of service
 `IOB_OUTPUT(m_axi_arvalid, 1), //Address read channel valid
 `IOB_INPUT(m_axi_arready, 1), //Address read channel ready
 `IOB_INPUT(m_axi_rid, AXI_ID_W), //Read channel ID
 `IOB_INPUT(m_axi_rdata, AXI_DATA_W), //Read channel data
 `IOB_INPUT(m_axi_rresp, 2), //Read channel response
 `IOB_INPUT(m_axi_rlast, 1), //Read channel last word
 `IOB_INPUT(m_axi_rvalid, 1), //Read channel valid
 `IOB_OUTPUT(m_axi_rready, 1), //Read channel ready
