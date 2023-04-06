  `include "iob_lib.vh"

  //START_IO_TABLE m_axi_m_port
 `IOB_OUTPUT(m_axi_awid, CACHE_AXI_ID_W), //Address write channel ID
 `IOB_OUTPUT(m_axi_awaddr, CACHE_AXI_ADDR_W), //Address write channel address
 `IOB_OUTPUT(m_axi_awlen, CACHE_AXI_LEN_W), //Address write channel burst length
 `IOB_OUTPUT(m_axi_awsize, CACHE_AXI_SIZE_W), //Address write channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_awburst, CACHE_AXI_BURST_W), //Address write channel burst type
 `IOB_OUTPUT(m_axi_awlock, CACHE_AXI_LOCK_W), //Address write channel lock type
 `IOB_OUTPUT(m_axi_awcache, CACHE_AXI_CACHE_W), //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_awprot, CACHE_AXI_PROT_W), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_awqos, CACHE_AXI_QOS_W), //Address write channel quality of service
 `IOB_OUTPUT(m_axi_awvalid, 1), //Address write channel valid
 `IOB_INPUT(m_axi_awready, 1), //Address write channel ready
 `IOB_OUTPUT(m_axi_wdata, CACHE_AXI_DATA_W), //Write channel data
 `IOB_OUTPUT(m_axi_wstrb, (CACHE_AXI_DATA_W/8)), //Write channel write strobe
 `IOB_OUTPUT(m_axi_wlast, 1), //Write channel last word flag
 `IOB_OUTPUT(m_axi_wvalid, 1), //Write channel valid
 `IOB_INPUT(m_axi_wready, 1), //Write channel ready
 `IOB_INPUT(m_axi_bid, CACHE_AXI_ID_W), //Write response channel ID
 `IOB_INPUT(m_axi_bresp, CACHE_AXI_RESP_W), //Write response channel response
 `IOB_INPUT(m_axi_bvalid, 1), //Write response channel valid
 `IOB_OUTPUT(m_axi_bready, 1), //Write response channel ready
 `IOB_OUTPUT(m_axi_arid, CACHE_AXI_ID_W), //Address read channel ID
 `IOB_OUTPUT(m_axi_araddr, CACHE_AXI_ADDR_W), //Address read channel address
 `IOB_OUTPUT(m_axi_arlen, CACHE_AXI_LEN_W), //Address read channel burst length
 `IOB_OUTPUT(m_axi_arsize, CACHE_AXI_SIZE_W), //Address read channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_arburst, CACHE_AXI_BURST_W), //Address read channel burst type
 `IOB_OUTPUT(m_axi_arlock, CACHE_AXI_LOCK_W), //Address read channel lock type
 `IOB_OUTPUT(m_axi_arcache, CACHE_AXI_CACHE_W), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_arprot, CACHE_AXI_PROT_W), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_arqos, CACHE_AXI_QOS_W), //Address read channel quality of service
 `IOB_OUTPUT(m_axi_arvalid, 1), //Address read channel valid
 `IOB_INPUT(m_axi_arready, 1), //Address read channel ready
 `IOB_INPUT(m_axi_rid, CACHE_AXI_ID_W), //Read channel ID
 `IOB_INPUT(m_axi_rdata, CACHE_AXI_DATA_W), //Read channel data
 `IOB_INPUT(m_axi_rresp, CACHE_AXI_RESP_W), //Read channel response
 `IOB_INPUT(m_axi_rlast, 1), //Read channel last word
 `IOB_INPUT(m_axi_rvalid, 1), //Read channel valid
 `IOB_OUTPUT(m_axi_rready, 1), //Read channel ready
