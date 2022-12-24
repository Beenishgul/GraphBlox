// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_top.v
// Create : 2022-11-29 19:06:29
// Revise : 2022-11-29 19:06:29
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

// This is a generated file. Use and modify at your own risk.
// --------------------------------------------------------------------------------------/
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps
// Top level of the kernel. Do not modify module name, parameters or ports.
module glay_top #(
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12 ,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32 ,
  parameter integer C_M00_AXI_ADDR_WIDTH       = 64 ,
  parameter integer C_M00_AXI_DATA_WIDTH       = 512,
  parameter integer C_M00_AXI_ID_WIDTH         = 1
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
  input  wire                                    m00_axi_awready      , // Address write channel ready
  input  wire                                    m00_axi_wready       , // Write channel ready
  output wire                                    m00_axi_awvalid      , // Address write channel valid
  output wire                                    m00_axi_wlast        , // Write channel last word flag
  output wire                                    m00_axi_wvalid       , // Write channel valid
  output wire [                           8-1:0] m00_axi_awlen        , // Address write channel burst length
  output wire [        C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr       , // Address write channel address
  output wire [        C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata        , // Write channel data
  output wire [      C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb        , // Write channel write strobe
  input  wire                                    m00_axi_bvalid       , // Write response channel valid
  output wire                                    m00_axi_bready       , // Write response channel ready
  input  wire                                    m00_axi_arready      , // Address read channel ready
  input  wire                                    m00_axi_rlast        , // Read channel last word
  input  wire                                    m00_axi_rvalid       , // Read channel valid
  input  wire [        C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata        , // Read channel data
  output wire                                    m00_axi_arvalid      , // Address read channel valid
  output wire                                    m00_axi_rready       , // Read channel ready
  output wire [                           8-1:0] m00_axi_arlen        , // Address write channel burst length
  output wire [        C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr       , // Address read channel address
  // AXI4 master interface m00_axi missing ports
  input  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_bid          , // Write response channel ID
  input  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_rid          , // Read channel ID
  input  wire [                           2-1:0] m00_axi_rresp        , // Read channel response
  input  wire [                           2-1:0] m00_axi_bresp        , // Write channel response
  output wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_awid         , // Address write channel ID
  output wire [                           3-1:0] m00_axi_awsize       , // Address write channel burst size. This signal indicates the size of each transfer in the burst
  output wire [                           2-1:0] m00_axi_awburst      , // Address write channel burst type
  output wire [                           1-1:0] m00_axi_awlock       , // Address write channel lock type
  output wire [                           4-1:0] m00_axi_awcache      , // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  output wire [                           3-1:0] m00_axi_awprot       , // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  output wire [                           4-1:0] m00_axi_awqos        , // Address write channel quality of service
  output wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_arid         , // Address read channel ID
  output wire [                           3-1:0] m00_axi_arsize       , // Address read channel burst size. This signal indicates the size of each transfer in the burst
  output wire [                           2-1:0] m00_axi_arburst      , // Address read channel burst type
  output wire [                           1-1:0] m00_axi_arlock       , // Address read channel lock type
  output wire [                           4-1:0] m00_axi_arcache      , // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  output wire [                           3-1:0] m00_axi_arprot       , // Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  output wire [                           4-1:0] m00_axi_arqos        , // Address read channel quality of service
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
  reg           areset             = 1'b0;
  wire          ap_start                 ;
  wire          ap_idle                  ;
  wire          ap_done                  ;
  wire          ap_ready                 ;
  wire          ap_continue              ;
  wire [64-1:0] graph_csr_struct         ;
  wire [64-1:0] vertex_out_degree        ;
  wire [64-1:0] vertex_in_degree         ;
  wire [64-1:0] vertex_edges_idx         ;
  wire [64-1:0] edges_array_weight       ;
  wire [64-1:0] edges_array_src          ;
  wire [64-1:0] edges_array_dest         ;
  wire [64-1:0] auxiliary_1              ;
  wire [64-1:0] auxiliary_2              ;

// Register and invert reset signal.
  always @(posedge ap_clk) begin
    areset <= ~ap_rst_n;
  end

// --------------------------------------------------------------------------------------
// Begin control interface RTL.  Modifying not recommended.
// --------------------------------------------------------------------------------------


// AXI4-Lite slave interface
  glay_top_control_s_axi #(
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH)
  ) inst_glay_top_control_s_axi (
    .ACLK              (ap_clk               ),
    .ARESET            (areset               ),
    .ACLK_EN           (1'b1                 ),
    .AWVALID           (s_axi_control_awvalid),
    .AWREADY           (s_axi_control_awready),
    .AWADDR            (s_axi_control_awaddr ),
    .WVALID            (s_axi_control_wvalid ),
    .WREADY            (s_axi_control_wready ),
    .WDATA             (s_axi_control_wdata  ),
    .WSTRB             (s_axi_control_wstrb  ),
    .ARVALID           (s_axi_control_arvalid),
    .ARREADY           (s_axi_control_arready),
    .ARADDR            (s_axi_control_araddr ),
    .RVALID            (s_axi_control_rvalid ),
    .RREADY            (s_axi_control_rready ),
    .RDATA             (s_axi_control_rdata  ),
    .RRESP             (s_axi_control_rresp  ),
    .BVALID            (s_axi_control_bvalid ),
    .BREADY            (s_axi_control_bready ),
    .BRESP             (s_axi_control_bresp  ),
    .interrupt         (interrupt            ),
    .ap_start          (ap_start             ),
    .ap_done           (ap_done              ),
    .ap_ready          (ap_ready             ),
    .ap_idle           (ap_idle              ),
    .ap_continue       (ap_continue          ),
    .graph_csr_struct  (graph_csr_struct     ),
    .vertex_out_degree (vertex_out_degree    ),
    .vertex_in_degree  (vertex_in_degree     ),
    .vertex_edges_idx  (vertex_edges_idx     ),
    .edges_array_weight(edges_array_weight   ),
    .edges_array_src   (edges_array_src      ),
    .edges_array_dest  (edges_array_dest     ),
    .auxiliary_1       (auxiliary_1          ),
    .auxiliary_2       (auxiliary_2          )
  );

// --------------------------------------------------------------------------------------
// GLay kernel logic here.
// --------------------------------------------------------------------------------------

  glay_kernel_afu #(
    .C_M00_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
    .C_M00_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH)
  ) inst_glay_kernel_afu (
    .ap_clk            (ap_clk            ),
    .ap_rst_n          (ap_rst_n          ),
    .m00_axi_awvalid   (m00_axi_awvalid   ),
    .m00_axi_awready   (m00_axi_awready   ),
    .m00_axi_awaddr    (m00_axi_awaddr    ),
    .m00_axi_awlen     (m00_axi_awlen     ),
    .m00_axi_wvalid    (m00_axi_wvalid    ),
    .m00_axi_wready    (m00_axi_wready    ),
    .m00_axi_wdata     (m00_axi_wdata     ),
    .m00_axi_wstrb     (m00_axi_wstrb     ),
    .m00_axi_wlast     (m00_axi_wlast     ),
    .m00_axi_bvalid    (m00_axi_bvalid    ),
    .m00_axi_bready    (m00_axi_bready    ),
    .m00_axi_arvalid   (m00_axi_arvalid   ),
    .m00_axi_arready   (m00_axi_arready   ),
    .m00_axi_araddr    (m00_axi_araddr    ),
    .m00_axi_arlen     (m00_axi_arlen     ),
    .m00_axi_rvalid    (m00_axi_rvalid    ),
    .m00_axi_rready    (m00_axi_rready    ),
    .m00_axi_rdata     (m00_axi_rdata     ),
    .m00_axi_rlast     (m00_axi_rlast     ),
    .m00_axi_bid       (m00_axi_bid       ),
    .m00_axi_rid       (m00_axi_rid       ),
    .m00_axi_rresp     (m00_axi_rresp     ),
    .m00_axi_bresp     (m00_axi_bresp     ),
    .m00_axi_awid      (m00_axi_awid      ),
    .m00_axi_awsize    (m00_axi_awsize    ),
    .m00_axi_awburst   (m00_axi_awburst   ),
    .m00_axi_awlock    (m00_axi_awlock    ),
    .m00_axi_awcache   (m00_axi_awcache   ),
    .m00_axi_awprot    (m00_axi_awprot    ),
    .m00_axi_awqos     (m00_axi_awqos     ),
    .m00_axi_arid      (m00_axi_arid      ),
    .m00_axi_arsize    (m00_axi_arsize    ),
    .m00_axi_arburst   (m00_axi_arburst   ),
    .m00_axi_arlock    (m00_axi_arlock    ),
    .m00_axi_arcache   (m00_axi_arcache   ),
    .m00_axi_arprot    (m00_axi_arprot    ),
    .m00_axi_arqos     (m00_axi_arqos     ),
    .ap_start          (ap_start          ),
    .ap_idle           (ap_idle           ),
    .ap_done           (ap_done           ),
    .ap_ready          (ap_ready          ),
    .ap_continue       (ap_continue       ),
    .graph_csr_struct  (graph_csr_struct  ),
    .vertex_out_degree (vertex_out_degree ),
    .vertex_in_degree  (vertex_in_degree  ),
    .vertex_edges_idx  (vertex_edges_idx  ),
    .edges_array_weight(edges_array_weight),
    .edges_array_src   (edges_array_src   ),
    .edges_array_dest  (edges_array_dest  ),
    .auxiliary_1       (auxiliary_1       ),
    .auxiliary_2       (auxiliary_2       )
  );

endmodule
`default_nettype wire
