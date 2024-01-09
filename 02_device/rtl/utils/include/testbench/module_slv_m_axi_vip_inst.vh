
    // Slave MM VIP instantiation
    slv_m00_axi_vip inst_slv_m00_axi_vip (
        .aclk         (ap_clk         ),
        .aresetn      (ap_rst_n       ),
        .s_axi_awvalid(m00_axi_awvalid),
        .s_axi_awready(m00_axi_awready),
        .s_axi_awaddr (m00_axi_awaddr ),
        .s_axi_awlen  (m00_axi_awlen  ),
        .s_axi_wvalid (m00_axi_wvalid ),
        .s_axi_wready (m00_axi_wready ),
        .s_axi_wdata  (m00_axi_wdata  ),
        .s_axi_wstrb  (m00_axi_wstrb  ),
        .s_axi_wlast  (m00_axi_wlast  ),
        .s_axi_bvalid (m00_axi_bvalid ),
        .s_axi_bready (m00_axi_bready ),
        .s_axi_arvalid(m00_axi_arvalid),
        .s_axi_arready(m00_axi_arready),
        .s_axi_araddr (m00_axi_araddr ),
        .s_axi_arlen  (m00_axi_arlen  ),
        .s_axi_rvalid (m00_axi_rvalid ),
        .s_axi_rready (m00_axi_rready ),
        .s_axi_rdata  (m00_axi_rdata  ),
        .s_axi_rlast  (m00_axi_rlast  ),
        
        .s_axi_bid    (m00_axi_bid    ),
        .s_axi_rid    (m00_axi_rid    ),
        .s_axi_rresp  (m00_axi_rresp  ),
        .s_axi_bresp  (m00_axi_bresp  ),
        .s_axi_awid   (m00_axi_awid   ),
        .s_axi_awsize (m00_axi_awsize ),
        .s_axi_awburst(m00_axi_awburst),
        .s_axi_awlock (m00_axi_awlock ),
        .s_axi_awcache(m00_axi_awcache),
        .s_axi_awprot (m00_axi_awprot ),
        .s_axi_awqos  (m00_axi_awqos  ),
        .s_axi_arid   (m00_axi_arid   ),
        .s_axi_arsize (m00_axi_arsize ),
        .s_axi_arburst(m00_axi_arburst),
        .s_axi_arlock (m00_axi_arlock ),
        .s_axi_arcache(m00_axi_arcache),
        .s_axi_arprot (m00_axi_arprot ),
        .s_axi_arqos  (m00_axi_arqos  )
    );

        slv_m00_axi_vip_slv_mem_t m00_axi    ;
        slv_m00_axi_vip_slv_t     m00_axi_slv;
        

    // Slave MM VIP instantiation
    slv_m01_axi_vip inst_slv_m01_axi_vip (
        .aclk         (ap_clk         ),
        .aresetn      (ap_rst_n       ),
        .s_axi_awvalid(m01_axi_awvalid),
        .s_axi_awready(m01_axi_awready),
        .s_axi_awaddr (m01_axi_awaddr ),
        .s_axi_awlen  (m01_axi_awlen  ),
        .s_axi_wvalid (m01_axi_wvalid ),
        .s_axi_wready (m01_axi_wready ),
        .s_axi_wdata  (m01_axi_wdata  ),
        .s_axi_wstrb  (m01_axi_wstrb  ),
        .s_axi_wlast  (m01_axi_wlast  ),
        .s_axi_bvalid (m01_axi_bvalid ),
        .s_axi_bready (m01_axi_bready ),
        .s_axi_arvalid(m01_axi_arvalid),
        .s_axi_arready(m01_axi_arready),
        .s_axi_araddr (m01_axi_araddr ),
        .s_axi_arlen  (m01_axi_arlen  ),
        .s_axi_rvalid (m01_axi_rvalid ),
        .s_axi_rready (m01_axi_rready ),
        .s_axi_rdata  (m01_axi_rdata  ),
        .s_axi_rlast  (m01_axi_rlast  ),
        
        .s_axi_bid    (m01_axi_bid    ),
        .s_axi_rid    (m01_axi_rid    ),
        .s_axi_rresp  (m01_axi_rresp  ),
        .s_axi_bresp  (m01_axi_bresp  ),
        .s_axi_awid   (m01_axi_awid   ),
        .s_axi_awsize (m01_axi_awsize ),
        .s_axi_awburst(m01_axi_awburst),
        .s_axi_awlock (m01_axi_awlock ),
        .s_axi_awcache(m01_axi_awcache),
        .s_axi_awprot (m01_axi_awprot ),
        .s_axi_awqos  (m01_axi_awqos  ),
        .s_axi_arid   (m01_axi_arid   ),
        .s_axi_arsize (m01_axi_arsize ),
        .s_axi_arburst(m01_axi_arburst),
        .s_axi_arlock (m01_axi_arlock ),
        .s_axi_arcache(m01_axi_arcache),
        .s_axi_arprot (m01_axi_arprot ),
        .s_axi_arqos  (m01_axi_arqos  )
    );

        slv_m01_axi_vip_slv_mem_t m01_axi    ;
        slv_m01_axi_vip_slv_t     m01_axi_slv;
        