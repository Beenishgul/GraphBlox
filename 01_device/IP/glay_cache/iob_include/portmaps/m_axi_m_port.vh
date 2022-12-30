  //START_IO_TABLE m_axi_m_port
 `IOB_OUTPUT(m_axi_awid, M_AXI4_ID_W), //Address write channel ID
 `IOB_OUTPUT(m_axi_awaddr, M_AXI4_ADDR_W), //Address write channel address
 `IOB_OUTPUT(m_axi_awlen, M_AXI4_LEN_W), //Address write channel burst length
 `IOB_OUTPUT(m_axi_awsize, M_AXI4_SIZE_W), //Address write channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_awburst, M_AXI4_BURST_W), //Address write channel burst type
 `IOB_OUTPUT(m_axi_awlock, M_AXI4_LOCK_W), //Address write channel lock type
 `IOB_OUTPUT(m_axi_awcache, M_AXI4_CACHE_W), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_awprot, M_AXI4_PROT_W), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_awqos, M_AXI4_QOS_W), //Address write channel quality of service
 `IOB_OUTPUT(m_axi_awvalid, 1), //Address write channel valid
 `IOB_INPUT(m_axi_awready, 1), //Address write channel ready
 `IOB_OUTPUT(m_axi_wdata, M_AXI4_DATA_W), //Write channel data
 `IOB_OUTPUT(m_axi_wstrb, (M_AXI4_DATA_W/8)), //Write channel write strobe
 `IOB_OUTPUT(m_axi_wlast, 1), //Write channel last word flag
 `IOB_OUTPUT(m_axi_wvalid, 1), //Write channel valid
 `IOB_INPUT(m_axi_wready, 1), //Write channel ready
 `IOB_INPUT(m_axi_bid, M_AXI4_ID_W), //Write response channel ID
 `IOB_INPUT(m_axi_bresp, M_AXI4_RESP_W), //Write response channel response
 `IOB_INPUT(m_axi_bvalid, 1), //Write response channel valid
 `IOB_OUTPUT(m_axi_bready, 1), //Write response channel ready
 `IOB_OUTPUT(m_axi_arid, M_AXI4_ID_W), //Address read channel ID
 `IOB_OUTPUT(m_axi_araddr, M_AXI4_ADDR_W), //Address read channel address
 `IOB_OUTPUT(m_axi_arlen, M_AXI4_LEN_W), //Address read channel burst length
 `IOB_OUTPUT(m_axi_arsize, M_AXI4_SIZE_W), //Address read channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_arburst, M_AXI4_BURST_W), //Address read channel burst type
 `IOB_OUTPUT(m_axi_arlock, M_AXI4_LOCK_W), //Address read channel lock type
 `IOB_OUTPUT(m_axi_arcache, M_AXI4_CACHE_W), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_arprot, M_AXI4_PROT_W), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_arqos, M_AXI4_QOS_W), //Address read channel quality of service
 `IOB_OUTPUT(m_axi_arvalid, 1), //Address read channel valid
 `IOB_INPUT(m_axi_arready, 1), //Address read channel ready
 `IOB_INPUT(m_axi_rid, M_AXI4_ID_W), //Read channel ID
 `IOB_INPUT(m_axi_rdata, M_AXI4_DATA_W), //Read channel data
 `IOB_INPUT(m_axi_rresp, M_AXI4_RESP_W), //Read channel response
 `IOB_INPUT(m_axi_rlast, 1), //Read channel last word
 `IOB_INPUT(m_axi_rvalid, 1), //Read channel valid
 `IOB_OUTPUT(m_axi_rready, 1), //Read channel ready
