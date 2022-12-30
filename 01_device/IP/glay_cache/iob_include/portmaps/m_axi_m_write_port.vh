  //START_IO_TABLE m_axi_m_write_port
 `IOB_OUTPUT(m_axi_awid, M_AXI4_ID_W), //Address write channel ID
 `IOB_OUTPUT(m_axi_awaddr, M_AXI4_ADDR_W), //Address write channel address
 `IOB_OUTPUT(m_axi_awlen, M_AXI4_LEN_W), //Address write channel burst length
 `IOB_OUTPUT(m_axi_awsize, 3), //Address write channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_awburst, 2), //Address write channel burst type
 `IOB_OUTPUT(m_axi_awlock, M_AXI4_LOCK_W), //Address write channel lock type
 `IOB_OUTPUT(m_axi_awcache, 4), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_awprot, 3), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_awqos, 4), //Address write channel quality of service
 `IOB_OUTPUT(m_axi_awvalid, 1), //Address write channel valid
 `IOB_INPUT(m_axi_awready, 1), //Address write channel ready
 `IOB_OUTPUT(m_axi_wdata, M_AXI4_DATA_W), //Write channel data
 `IOB_OUTPUT(m_axi_wstrb, (M_AXI4_DATA_W/8)), //Write channel write strobe
 `IOB_OUTPUT(m_axi_wlast, 1), //Write channel last word flag
 `IOB_OUTPUT(m_axi_wvalid, 1), //Write channel valid
 `IOB_INPUT(m_axi_wready, 1), //Write channel ready
 `IOB_INPUT(m_axi_bid, M_AXI4_ID_W), //Write response channel ID
 `IOB_INPUT(m_axi_bresp, 2), //Write response channel response
 `IOB_INPUT(m_axi_bvalid, 1), //Write response channel valid
 `IOB_OUTPUT(m_axi_bready, 1), //Write response channel ready
