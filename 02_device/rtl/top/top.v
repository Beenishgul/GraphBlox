// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : top.v
// Create : 2023-06-17 01:02:46
// Revise : 2023-06-17 01:02:57
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

// --------------------------------------------------------------------------------------/
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`include "global_timescale.vh"
// Top level of the kernel. Do not modify module name, parameters or ports.
module top #(
  `include "top_parameters.vh"
  ) (
  // System Signals
  input  wire                                    ap_clk               ,
  input  wire                                    ap_rst_n             ,
  //  Note: A minimum subset of AXI4 memory mapped signals are declared.  AXI
  // signals omitted from these interfaces are automatically inferred with the
  // optimal values for Xilinx accleration platforms.  This allows Xilinx AXI4 Interconnects
  // within the system to be optimized by removing logic for AXI4 protocol
  // features that are not necessary. When adapting AXI4 masters within the RTL
  // kernel that have signals not declared below, it is suitable to add the
  // signals to the declarations below to connect them to the AXI4 Master.
  //
  // List of ommited signals - effect
  // -------------------------------
  // ID - Transaction ID are used for multithreading and out of order
  // transactions.  This increases complexity. This saves logic and increases Fmax
  // in the system when ommited.
  // SIZE - Default value is log2(data width in bytes). Needed for subsize bursts.
  // This saves logic and increases Fmax in the system when ommited.
  // BURST - Default value (0b01) is incremental.  Wrap and fixed bursts are not
  // recommended. This saves logic and increases Fmax in the system when ommited.
  // LOCK - Not supported in AXI4
  // CACHE - Default value (0b0011) allows modifiable transactions. No benefit to
  // changing this.
  // PROT - Has no effect in current acceleration platforms.
  // QOS - Has no effect in current acceleration platforms.
  // REGION - Has no effect in current acceleration platforms.
  // USER - Has no effect in current acceleration platforms.
  // RESP - Not useful in most acceleration platforms.
  //
  // AXI4 master interface m00_axi
  `include "m_axi_ports_top.vh"
  // AXI4-Lite slave interface
  input  wire                                    s_axi_control_awvalid,
  output wire                                    s_axi_control_awready,
  input  wire [  C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_awaddr ,
  input  wire                                    s_axi_control_wvalid ,
  output wire                                    s_axi_control_wready ,
  input  wire [  C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_wdata  ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb  ,
  input  wire                                    s_axi_control_arvalid,
  output wire                                    s_axi_control_arready,
  input  wire [  C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_araddr ,
  output wire                                    s_axi_control_rvalid ,
  input  wire                                    s_axi_control_rready ,
  output wire [  C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_rdata  ,
  output wire [                           2-1:0] s_axi_control_rresp  ,
  output wire                                    s_axi_control_bvalid ,
  input  wire                                    s_axi_control_bready ,
  output wire [                           2-1:0] s_axi_control_bresp  ,
  output wire                                    interrupt
);

// --------------------------------------------------------------------------------------
// Local Parameters
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
  (* DONT_TOUCH                              = "yes" *)
  reg           areset      = 1'b0;
  wire          ap_start          ;
  wire          ap_idle           ;
  wire          ap_done           ;
  wire          ap_ready          ;
  wire          ap_continue       ;
  wire [64-1:0] buffer_0          ;
  wire [64-1:0] buffer_1          ;
  wire [64-1:0] buffer_2          ;
  wire [64-1:0] buffer_3          ;
  wire [64-1:0] buffer_4          ;
  wire [64-1:0] buffer_5          ;
  wire [64-1:0] buffer_6          ;
  wire [64-1:0] buffer_7          ;
  wire [64-1:0] buffer_8          ;
  wire [64-1:0] buffer_9          ;

// Register and invert reset signal.
  always @(posedge ap_clk) begin
    areset <= ~ap_rst_n;
  end

// --------------------------------------------------------------------------------------
// Begin control interface RTL.  Modifying not recommended.
// --------------------------------------------------------------------------------------
// AXI4-Lite slave interface
  top_control_s_axi #(
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH)
  ) inst_top_control_s_axi (
    .ACLK       (ap_clk               ),
    .ARESET     (areset               ),
    .ACLK_EN    (1'b1                 ),
    .AWVALID    (s_axi_control_awvalid),
    .AWREADY    (s_axi_control_awready),
    .AWADDR     (s_axi_control_awaddr ),
    .WVALID     (s_axi_control_wvalid ),
    .WREADY     (s_axi_control_wready ),
    .WDATA      (s_axi_control_wdata  ),
    .WSTRB      (s_axi_control_wstrb  ),
    .ARVALID    (s_axi_control_arvalid),
    .ARREADY    (s_axi_control_arready),
    .ARADDR     (s_axi_control_araddr ),
    .RVALID     (s_axi_control_rvalid ),
    .RREADY     (s_axi_control_rready ),
    .RDATA      (s_axi_control_rdata  ),
    .RRESP      (s_axi_control_rresp  ),
    .BVALID     (s_axi_control_bvalid ),
    .BREADY     (s_axi_control_bready ),
    .BRESP      (s_axi_control_bresp  ),
    .interrupt  (interrupt            ),
    .ap_start   (ap_start             ),
    .ap_done    (ap_done              ),
    .ap_ready   (ap_ready             ),
    .ap_idle    (ap_idle              ),
    .ap_continue(ap_continue          ),
    .buffer_0   (buffer_0             ),
    .buffer_1   (buffer_1             ),
    .buffer_2   (buffer_2             ),
    .buffer_3   (buffer_3             ),
    .buffer_4   (buffer_4             ),
    .buffer_5   (buffer_5             ),
    .buffer_6   (buffer_6             ),
    .buffer_7   (buffer_7             ),
    .buffer_8   (buffer_8             ),
    .buffer_9   (buffer_9             )
  );

// --------------------------------------------------------------------------------------
// GLay kernel logic here.
// --------------------------------------------------------------------------------------

  kernel_afu inst_kernel_afu (
    .ap_clk     (ap_clk     ),
    .ap_rst_n   (ap_rst_n   ),
    // AXI4 master interface m00_axi
    `include "m_axi_portmap_afu.vh"
    // Control Signals
    .ap_start   (ap_start   ),
    .ap_idle    (ap_idle    ),
    .ap_done    (ap_done    ),
    .ap_ready   (ap_ready   ),
    .ap_continue(ap_continue),
    .buffer_0   (buffer_0   ),
    .buffer_1   (buffer_1   ),
    .buffer_2   (buffer_2   ),
    .buffer_3   (buffer_3   ),
    .buffer_4   (buffer_4   ),
    .buffer_5   (buffer_5   ),
    .buffer_6   (buffer_6   ),
    .buffer_7   (buffer_7   ),
    .buffer_8   (buffer_8   ),
    .buffer_9   (buffer_9   )
  );

endmodule
`default_nettype wire
