set SynModuleInfo {
  {SRCNAME glay_kernel_Pipeline_1 MODELNAME glay_kernel_Pipeline_1 RTLNAME glay_kernel_glay_kernel_Pipeline_1
    SUBMODULES {
      {MODELNAME glay_kernel_flow_control_loop_pipe_sequential_init RTLNAME glay_kernel_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME glay_kernel_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME glay_kernel_Pipeline_VITIS_LOOP_74_1 MODELNAME glay_kernel_Pipeline_VITIS_LOOP_74_1 RTLNAME glay_kernel_glay_kernel_Pipeline_VITIS_LOOP_74_1}
  {SRCNAME glay_kernel_Pipeline_3 MODELNAME glay_kernel_Pipeline_3 RTLNAME glay_kernel_glay_kernel_Pipeline_3}
  {SRCNAME glay_kernel MODELNAME glay_kernel RTLNAME glay_kernel IS_TOP 1
    SUBMODULES {
      {MODELNAME glay_kernel_m00_axi_input_buffer_RAM_AUTO_1R1W RTLNAME glay_kernel_m00_axi_input_buffer_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME glay_kernel_m00_axi_m_axi RTLNAME glay_kernel_m00_axi_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME glay_kernel_control_s_axi RTLNAME glay_kernel_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
    }
  }
}
