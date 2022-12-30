  //START_IO_TABLE m_axi_m_read_port
 `IOB_OUTPUT(m_axi_arid, M_AXI4_ID_W), //Address read channel ID
 `IOB_OUTPUT(m_axi_araddr, M_AXI4_ADDR_W), //Address read channel address
 `IOB_OUTPUT(m_axi_arlen, M_AXI4_LEN_W), //Address read channel burst length
 `IOB_OUTPUT(m_axi_arsize, 3), //Address read channel burst size. This signal indicates the size of each transfer in the burst
 `IOB_OUTPUT(m_axi_arburst, 2), //Address read channel burst type
 `IOB_OUTPUT(m_axi_arlock, M_AXI4_LOCK_W), //Address read channel lock type
 `IOB_OUTPUT(m_axi_arcache, 4), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
 `IOB_OUTPUT(m_axi_arprot, 3), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
 `IOB_OUTPUT(m_axi_arqos, 4), //Address read channel quality of service
 `IOB_OUTPUT(m_axi_arvalid, 1), //Address read channel valid
 `IOB_INPUT(m_axi_arready, 1), //Address read channel ready
 `IOB_INPUT(m_axi_rid, M_AXI4_ID_W), //Read channel ID
 `IOB_INPUT(m_axi_rdata, M_AXI4_DATA_W), //Read channel data
 `IOB_INPUT(m_axi_rresp, 2), //Read channel response
 `IOB_INPUT(m_axi_rlast, 1), //Read channel last word
 `IOB_INPUT(m_axi_rvalid, 1), //Read channel valid
 `IOB_OUTPUT(m_axi_rready, 1), //Read channel ready
