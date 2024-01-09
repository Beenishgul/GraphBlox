
// --------------------------------------------------------------------------------------
// CU Cache -> AXI-CH 0
// --------------------------------------------------------------------------------------


M00_AXI4_MID_MasterReadInterfaceInput   cu_m00_axi_read_in  ;
M00_AXI4_MID_MasterReadInterfaceOutput  cu_m00_axi_read_out ;
M00_AXI4_MID_MasterWriteInterfaceInput  cu_m00_axi_write_in ;
M00_AXI4_MID_MasterWriteInterfaceOutput cu_m00_axi_write_out;

generate
// --------------------------------------------------------------------------------------
    if(CHANNEL_CONFIG_L1_CACHE[0] == 0) begin
// --------------------------------------------------------------------------------------
// CU Cache -> AXI Kernel Cache
      m00_axi_cu_cache_mid512x64_fe32x64_wrapper inst_cu_cache_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[0]                   ),
        .descriptor_in            (cu_channel_descriptor[0]               ),
        .request_in               (cu_channel_request_in[0]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[0] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[0]  ),
        .response_out             (cu_channel_response_out[0]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[0]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[0] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[0]        ),
        .m_axi_read_in            (cu_m00_axi_read_in                  ),
        .m_axi_read_out           (cu_m00_axi_read_out                 ),
        .m_axi_write_in           (cu_m00_axi_write_in                 ),
        .m_axi_write_out          (cu_m00_axi_write_out                ),
        .done_out                 (cu_channel_done_out[0]                 )
      );
    end else if(CHANNEL_CONFIG_L1_CACHE[0] == 1) begin
// CU BUFFER -> AXI Kernel Cache
      m00_axi_cu_cache_mid512x64_fe32x64_wrapper inst_cu_stream_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[0]                   ),
        .descriptor_in            (cu_channel_descriptor[0]               ),
        .request_in               (cu_channel_request_in[0]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[0] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[0]  ),
        .response_out             (cu_channel_response_out[0]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[0]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[0] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[0]        ),
        .m_axi_read_in            (cu_m00_axi_read_in                  ),
        .m_axi_read_out           (cu_m00_axi_read_out                 ),
        .m_axi_write_in           (cu_m00_axi_write_in                 ),
        .m_axi_write_out          (cu_m00_axi_write_out                ),
        .done_out                 (cu_channel_done_out[0]                 )
      );
    end else begin
// CU BUFFER -> AXI Kernel Cache
      m00_axi_cu_cache_mid512x64_fe32x64_wrapper inst_cu_buffer_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[0]                   ),
        .descriptor_in            (cu_channel_descriptor[0]               ),
        .request_in               (cu_channel_request_in[0]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[0] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[0]  ),
        .response_out             (cu_channel_response_out[0]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[0]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[0] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[0]        ),
        .m_axi_read_in            (cu_m00_axi_read_in                  ),
        .m_axi_read_out           (cu_m00_axi_read_out                 ),
        .m_axi_write_in           (cu_m00_axi_write_in                 ),
        .m_axi_write_out          (cu_m00_axi_write_out                ),
        .done_out                 (cu_channel_done_out[0]                 )
      );
    end
endgenerate
// --------------------------------------------------------------------------------------
// Generate CU CACHE CH 1:0 (M->S) Register Slice
// --------------------------------------------------------------------------------------
    m00_axi_register_slice_mid_512x64_wrapper inst_m00_axi_register_slice_mid_512x64_wrapper_ch (
      .ap_clk         (ap_clk                 ),
      .areset         (areset_axi_slice[0]    ),
      .s_axi_read_out (cu_m00_axi_read_in  ),
      .s_axi_read_in  (cu_m00_axi_read_out ),
      .s_axi_write_out(cu_m00_axi_write_in ),
      .s_axi_write_in (cu_m00_axi_write_out),
      .m_axi_read_in  (m00_axi_read_in     ),
      .m_axi_read_out (m00_axi_read_out    ),
      .m_axi_write_in (m00_axi_write_in    ),
      .m_axi_write_out(m00_axi_write_out   )
    );

    

// --------------------------------------------------------------------------------------
// CU Cache -> AXI-CH 0
// --------------------------------------------------------------------------------------


M01_AXI4_MID_MasterReadInterfaceInput   cu_m01_axi_read_in  ;
M01_AXI4_MID_MasterReadInterfaceOutput  cu_m01_axi_read_out ;
M01_AXI4_MID_MasterWriteInterfaceInput  cu_m01_axi_write_in ;
M01_AXI4_MID_MasterWriteInterfaceOutput cu_m01_axi_write_out;

generate
// --------------------------------------------------------------------------------------
    if(CHANNEL_CONFIG_L1_CACHE[1] == 0) begin
// --------------------------------------------------------------------------------------
// CU Cache -> AXI Kernel Cache
      m01_axi_cu_cache_mid512x64_fe32x64_wrapper inst_cu_cache_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[1]                   ),
        .descriptor_in            (cu_channel_descriptor[1]               ),
        .request_in               (cu_channel_request_in[1]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[1] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[1]  ),
        .response_out             (cu_channel_response_out[1]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[1]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[1] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[1]        ),
        .m_axi_read_in            (cu_m01_axi_read_in                  ),
        .m_axi_read_out           (cu_m01_axi_read_out                 ),
        .m_axi_write_in           (cu_m01_axi_write_in                 ),
        .m_axi_write_out          (cu_m01_axi_write_out                ),
        .done_out                 (cu_channel_done_out[1]                 )
      );
    end else if(CHANNEL_CONFIG_L1_CACHE[1] == 1) begin
// CU BUFFER -> AXI Kernel Cache
      m01_axi_cu_cache_mid512x64_fe32x64_wrapper inst_cu_stream_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[1]                   ),
        .descriptor_in            (cu_channel_descriptor[1]               ),
        .request_in               (cu_channel_request_in[1]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[1] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[1]  ),
        .response_out             (cu_channel_response_out[1]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[1]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[1] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[1]        ),
        .m_axi_read_in            (cu_m01_axi_read_in                  ),
        .m_axi_read_out           (cu_m01_axi_read_out                 ),
        .m_axi_write_in           (cu_m01_axi_write_in                 ),
        .m_axi_write_out          (cu_m01_axi_write_out                ),
        .done_out                 (cu_channel_done_out[1]                 )
      );
    end else begin
// CU BUFFER -> AXI Kernel Cache
      m01_axi_cu_cache_mid512x64_fe32x64_wrapper inst_cu_buffer_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[1]                   ),
        .descriptor_in            (cu_channel_descriptor[1]               ),
        .request_in               (cu_channel_request_in[1]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[1] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[1]  ),
        .response_out             (cu_channel_response_out[1]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[1]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[1] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[1]        ),
        .m_axi_read_in            (cu_m01_axi_read_in                  ),
        .m_axi_read_out           (cu_m01_axi_read_out                 ),
        .m_axi_write_in           (cu_m01_axi_write_in                 ),
        .m_axi_write_out          (cu_m01_axi_write_out                ),
        .done_out                 (cu_channel_done_out[1]                 )
      );
    end
endgenerate
// --------------------------------------------------------------------------------------
// Generate CU CACHE CH 1:0 (M->S) Register Slice
// --------------------------------------------------------------------------------------
    m01_axi_register_slice_mid_512x64_wrapper inst_m01_axi_register_slice_mid_512x64_wrapper_ch (
      .ap_clk         (ap_clk                 ),
      .areset         (areset_axi_slice[1]    ),
      .s_axi_read_out (cu_m01_axi_read_in  ),
      .s_axi_read_in  (cu_m01_axi_read_out ),
      .s_axi_write_out(cu_m01_axi_write_in ),
      .s_axi_write_in (cu_m01_axi_write_out),
      .m_axi_read_in  (m01_axi_read_in     ),
      .m_axi_read_out (m01_axi_read_out    ),
      .m_axi_write_in (m01_axi_write_in    ),
      .m_axi_write_out(m01_axi_write_out   )
    );

    