// --------------------------------------------------------------------------------------
// Channel 0
// --------------------------------------------------------------------------------------

M00_AXI4_BE_MasterReadInterface  m00_axi4_read ;
M00_AXI4_BE_MasterWriteInterface m00_axi4_write;

M00_AXI4_MID_SlaveReadInterfaceOutput  kernel_s00_axi_read_out ;
M00_AXI4_MID_SlaveReadInterfaceInput   kernel_s00_axi_read_in  ;
M00_AXI4_MID_SlaveWriteInterfaceOutput kernel_s00_axi_write_out;
M00_AXI4_MID_SlaveWriteInterfaceInput  kernel_s00_axi_write_in ;

M00_AXI4_BE_MasterReadInterfaceInput   kernel_m00_axi4_read_in  ;
M00_AXI4_BE_MasterReadInterfaceOutput  kernel_m00_axi4_read_out ;
M00_AXI4_BE_MasterWriteInterfaceInput  kernel_m00_axi4_write_in ;
M00_AXI4_BE_MasterWriteInterfaceOutput kernel_m00_axi4_write_out;


// --------------------------------------------------------------------------------------
// Channel 0 READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m00_axi4_read.in.rvalid  = m00_axi_rvalid ; // Read channel valid
assign m00_axi4_read.in.arready = m00_axi_arready; // Address read channel ready
assign m00_axi4_read.in.rlast   = m00_axi_rlast  ; // Read channel last word
assign m00_axi4_read.in.rdata   = swap_endianness_cacheline_m00_axi_be(m00_axi_rdata, endian_read_reg)  ; // Read channel data
assign m00_axi4_read.in.rid     = m00_axi_rid    ; // Read channel ID
assign m00_axi4_read.in.rresp   = m00_axi_rresp  ; // Read channel response

// --------------------------------------------------------------------------------------
// Channel 0 READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m00_axi_arvalid = m00_axi4_read.out.arvalid; // Address read channel valid
assign m00_axi_araddr  = m00_axi4_read.out.araddr ; // Address read channel address
assign m00_axi_arlen   = m00_axi4_read.out.arlen  ; // Address write channel burst length
assign m00_axi_rready  = m00_axi4_read.out.rready ; // Read channel ready
assign m00_axi_arid    = m00_axi4_read.out.arid   ; // Address read channel ID
assign m00_axi_arsize  = m00_axi4_read.out.arsize ; // Address read channel burst size
assign m00_axi_arburst = m00_axi4_read.out.arburst; // Address read channel burst type
assign m00_axi_arlock  = m00_axi4_read.out.arlock ; // Address read channel lock type
assign m00_axi_arcache = m00_axi4_read.out.arcache; // Address read channel memory type
assign m00_axi_arprot  = m00_axi4_read.out.arprot ; // Address write channel protection type
assign m00_axi_arqos   = m00_axi4_read.out.arqos  ; // Address write channel quality of service

// --------------------------------------------------------------------------------------
// Channel 0 WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m00_axi4_write.in.awready = m00_axi_awready; // Address write channel ready
assign m00_axi4_write.in.wready  = m00_axi_wready ; // Write channel ready
assign m00_axi4_write.in.bid     = m00_axi_bid    ; // Write response channel ID
assign m00_axi4_write.in.bresp   = m00_axi_bresp  ; // Write channel response
assign m00_axi4_write.in.bvalid  = m00_axi_bvalid ; // Write response channel valid

// --------------------------------------------------------------------------------------
// Channel 0 WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m00_axi_awvalid = m00_axi4_write.out.awvalid; // Address write channel valid
assign m00_axi_awid    = m00_axi4_write.out.awid   ; // Address write channel ID
assign m00_axi_awaddr  = m00_axi4_write.out.awaddr ; // Address write channel address
assign m00_axi_awlen   = m00_axi4_write.out.awlen  ; // Address write channel burst length
assign m00_axi_awsize  = m00_axi4_write.out.awsize ; // Address write channel burst size
assign m00_axi_awburst = m00_axi4_write.out.awburst; // Address write channel burst type
assign m00_axi_awlock  = m00_axi4_write.out.awlock ; // Address write channel lock type
assign m00_axi_awcache = m00_axi4_write.out.awcache; // Address write channel memory type
assign m00_axi_awprot  = m00_axi4_write.out.awprot ; // Address write channel protection type
assign m00_axi_awqos   = m00_axi4_write.out.awqos  ; // Address write channel quality of service
assign m00_axi_wdata   = swap_endianness_cacheline_m00_axi_be(m00_axi4_write.out.wdata, endian_write_reg); // Write channel data
assign m00_axi_wstrb   = m00_axi4_write.out.wstrb  ; // Write channel write strobe
assign m00_axi_wlast   = m00_axi4_write.out.wlast  ; // Write channel last word flag
assign m00_axi_wvalid  = m00_axi4_write.out.wvalid ; // Write channel valid
assign m00_axi_bready  = m00_axi4_write.out.bready ; // Write response channel ready
    

// --------------------------------------------------------------------------------------
// System Cache CH 0-> AXI
// --------------------------------------------------------------------------------------
generate
// --------------------------------------------------------------------------------------
    if(CHANNEL_CONFIG_L2_CACHE[0] == 0) begin
// --------------------------------------------------------------------------------------
      kernel_m00_axi_system_cache_be512x64_mid512x64_wrapper inst_kernel_m00_axi_system_cache_be512x64_mid512x64_wrapper_cache_l2 (
        .ap_clk            (ap_clk                          ),
        .areset            (areset_cache[0]               ),
        .s_axi_read_out    (kernel_s00_axi_read_out    ),
        .s_axi_read_in     (kernel_s00_axi_read_in     ),
        .s_axi_write_out   (kernel_s00_axi_write_out   ),
        .s_axi_write_in    (kernel_s00_axi_write_in    ),
        .m_axi_read_in     (kernel_m00_axi4_read_in    ),
        .m_axi_read_out    (kernel_m00_axi4_read_out   ),
        .m_axi_write_in    (kernel_m00_axi4_write_in   ),
        .m_axi_write_out   (kernel_m00_axi4_write_out  ),
        .cache_setup_signal(kernel_cache_setup_signal[0])
      );
// Kernel CACHE (M->S) Register Slice
// --------------------------------------------------------------------------------------
      m00_axi_register_slice_be_512x64_wrapper inst_m00_axi_register_slice_be_512x64_wrapper (
        .ap_clk         (ap_clk                        ),
        .areset         (areset_axi_slice[0]         ),
        .s_axi_read_out (kernel_m00_axi4_read_in  ),
        .s_axi_read_in  (kernel_m00_axi4_read_out ),
        .s_axi_write_out(kernel_m00_axi4_write_in ),
        .s_axi_write_in (kernel_m00_axi4_write_out),
        .m_axi_read_in  (m00_axi4_read.in         ),
        .m_axi_read_out (m00_axi4_read.out        ),
        .m_axi_write_in (m00_axi4_write.in        ),
        .m_axi_write_out(m00_axi4_write.out       )
      );

    end else begin
      assign kernel_cache_setup_signal[0]   = 0;
      assign kernel_s00_axi_read_out     = m00_axi4_read.in       ;
      assign m00_axi4_read.out           = kernel_s00_axi_read_in ;
      assign kernel_s00_axi_write_out    = m00_axi4_write.in      ;
      assign m00_axi4_write.out          = kernel_s00_axi_write_in;
    end
// --------------------------------------------------------------------------------------
endgenerate
    
// --------------------------------------------------------------------------------------
// Channel 1
// --------------------------------------------------------------------------------------

M01_AXI4_BE_MasterReadInterface  m01_axi4_read ;
M01_AXI4_BE_MasterWriteInterface m01_axi4_write;

M01_AXI4_MID_SlaveReadInterfaceOutput  kernel_s01_axi_read_out ;
M01_AXI4_MID_SlaveReadInterfaceInput   kernel_s01_axi_read_in  ;
M01_AXI4_MID_SlaveWriteInterfaceOutput kernel_s01_axi_write_out;
M01_AXI4_MID_SlaveWriteInterfaceInput  kernel_s01_axi_write_in ;

M01_AXI4_BE_MasterReadInterfaceInput   kernel_m01_axi4_read_in  ;
M01_AXI4_BE_MasterReadInterfaceOutput  kernel_m01_axi4_read_out ;
M01_AXI4_BE_MasterWriteInterfaceInput  kernel_m01_axi4_write_in ;
M01_AXI4_BE_MasterWriteInterfaceOutput kernel_m01_axi4_write_out;


// --------------------------------------------------------------------------------------
// Channel 1 READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m01_axi4_read.in.rvalid  = m01_axi_rvalid ; // Read channel valid
assign m01_axi4_read.in.arready = m01_axi_arready; // Address read channel ready
assign m01_axi4_read.in.rlast   = m01_axi_rlast  ; // Read channel last word
assign m01_axi4_read.in.rdata   = swap_endianness_cacheline_m01_axi_be(m01_axi_rdata, endian_read_reg)  ; // Read channel data
assign m01_axi4_read.in.rid     = m01_axi_rid    ; // Read channel ID
assign m01_axi4_read.in.rresp   = m01_axi_rresp  ; // Read channel response

// --------------------------------------------------------------------------------------
// Channel 1 READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m01_axi_arvalid = m01_axi4_read.out.arvalid; // Address read channel valid
assign m01_axi_araddr  = m01_axi4_read.out.araddr ; // Address read channel address
assign m01_axi_arlen   = m01_axi4_read.out.arlen  ; // Address write channel burst length
assign m01_axi_rready  = m01_axi4_read.out.rready ; // Read channel ready
assign m01_axi_arid    = m01_axi4_read.out.arid   ; // Address read channel ID
assign m01_axi_arsize  = m01_axi4_read.out.arsize ; // Address read channel burst size
assign m01_axi_arburst = m01_axi4_read.out.arburst; // Address read channel burst type
assign m01_axi_arlock  = m01_axi4_read.out.arlock ; // Address read channel lock type
assign m01_axi_arcache = m01_axi4_read.out.arcache; // Address read channel memory type
assign m01_axi_arprot  = m01_axi4_read.out.arprot ; // Address write channel protection type
assign m01_axi_arqos   = m01_axi4_read.out.arqos  ; // Address write channel quality of service

// --------------------------------------------------------------------------------------
// Channel 1 WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m01_axi4_write.in.awready = m01_axi_awready; // Address write channel ready
assign m01_axi4_write.in.wready  = m01_axi_wready ; // Write channel ready
assign m01_axi4_write.in.bid     = m01_axi_bid    ; // Write response channel ID
assign m01_axi4_write.in.bresp   = m01_axi_bresp  ; // Write channel response
assign m01_axi4_write.in.bvalid  = m01_axi_bvalid ; // Write response channel valid

// --------------------------------------------------------------------------------------
// Channel 1 WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m01_axi_awvalid = m01_axi4_write.out.awvalid; // Address write channel valid
assign m01_axi_awid    = m01_axi4_write.out.awid   ; // Address write channel ID
assign m01_axi_awaddr  = m01_axi4_write.out.awaddr ; // Address write channel address
assign m01_axi_awlen   = m01_axi4_write.out.awlen  ; // Address write channel burst length
assign m01_axi_awsize  = m01_axi4_write.out.awsize ; // Address write channel burst size
assign m01_axi_awburst = m01_axi4_write.out.awburst; // Address write channel burst type
assign m01_axi_awlock  = m01_axi4_write.out.awlock ; // Address write channel lock type
assign m01_axi_awcache = m01_axi4_write.out.awcache; // Address write channel memory type
assign m01_axi_awprot  = m01_axi4_write.out.awprot ; // Address write channel protection type
assign m01_axi_awqos   = m01_axi4_write.out.awqos  ; // Address write channel quality of service
assign m01_axi_wdata   = swap_endianness_cacheline_m01_axi_be(m01_axi4_write.out.wdata, endian_write_reg); // Write channel data
assign m01_axi_wstrb   = m01_axi4_write.out.wstrb  ; // Write channel write strobe
assign m01_axi_wlast   = m01_axi4_write.out.wlast  ; // Write channel last word flag
assign m01_axi_wvalid  = m01_axi4_write.out.wvalid ; // Write channel valid
assign m01_axi_bready  = m01_axi4_write.out.bready ; // Write response channel ready
    

// --------------------------------------------------------------------------------------
// System Cache CH 1-> AXI
// --------------------------------------------------------------------------------------
generate
// --------------------------------------------------------------------------------------
    if(CHANNEL_CONFIG_L2_CACHE[1] == 0) begin
// --------------------------------------------------------------------------------------
      kernel_m01_axi_system_cache_be512x64_mid512x64_wrapper inst_kernel_m01_axi_system_cache_be512x64_mid512x64_wrapper_cache_l2 (
        .ap_clk            (ap_clk                          ),
        .areset            (areset_cache[1]               ),
        .s_axi_read_out    (kernel_s01_axi_read_out    ),
        .s_axi_read_in     (kernel_s01_axi_read_in     ),
        .s_axi_write_out   (kernel_s01_axi_write_out   ),
        .s_axi_write_in    (kernel_s01_axi_write_in    ),
        .m_axi_read_in     (kernel_m01_axi4_read_in    ),
        .m_axi_read_out    (kernel_m01_axi4_read_out   ),
        .m_axi_write_in    (kernel_m01_axi4_write_in   ),
        .m_axi_write_out   (kernel_m01_axi4_write_out  ),
        .cache_setup_signal(kernel_cache_setup_signal[1])
      );
// Kernel CACHE (M->S) Register Slice
// --------------------------------------------------------------------------------------
      m01_axi_register_slice_be_512x64_wrapper inst_m01_axi_register_slice_be_512x64_wrapper (
        .ap_clk         (ap_clk                        ),
        .areset         (areset_axi_slice[1]         ),
        .s_axi_read_out (kernel_m01_axi4_read_in  ),
        .s_axi_read_in  (kernel_m01_axi4_read_out ),
        .s_axi_write_out(kernel_m01_axi4_write_in ),
        .s_axi_write_in (kernel_m01_axi4_write_out),
        .m_axi_read_in  (m01_axi4_read.in         ),
        .m_axi_read_out (m01_axi4_read.out        ),
        .m_axi_write_in (m01_axi4_write.in        ),
        .m_axi_write_out(m01_axi4_write.out       )
      );

    end else begin
      assign kernel_cache_setup_signal[1]   = 0;
      assign kernel_s01_axi_read_out     = m01_axi4_read.in       ;
      assign m01_axi4_read.out           = kernel_s01_axi_read_in ;
      assign kernel_s01_axi_write_out    = m01_axi4_write.in      ;
      assign m01_axi4_write.out          = kernel_s01_axi_write_in;
    end
// --------------------------------------------------------------------------------------
endgenerate
    