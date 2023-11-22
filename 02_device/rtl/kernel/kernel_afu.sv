// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_afu.sv
// Create : 2022-11-29 12:42:56
// Revise : 2023-06-13 00:31:13
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module kernel_afu (
  // System Signals
  input  logic                         ap_clk         ,
  input  logic                         ap_rst_n       ,
  // AXI4 master interface m00_axi
  output logic                         m00_axi_awvalid,
  input  logic                         m00_axi_awready,
  output logic [ M_AXI4_BE_ADDR_W-1:0] m00_axi_awaddr ,
  output logic [  M_AXI4_BE_LEN_W-1:0] m00_axi_awlen  ,
  output logic                         m00_axi_wvalid ,
  input  logic                         m00_axi_wready ,
  output logic [ M_AXI4_BE_DATA_W-1:0] m00_axi_wdata  ,
  output logic [ M_AXI4_BE_STRB_W-1:0] m00_axi_wstrb  ,
  output logic                         m00_axi_wlast  ,
  input  logic                         m00_axi_bvalid ,
  output logic                         m00_axi_bready ,
  output logic                         m00_axi_arvalid,
  input  logic                         m00_axi_arready,
  output logic [ M_AXI4_BE_ADDR_W-1:0] m00_axi_araddr ,
  output logic [  M_AXI4_BE_LEN_W-1:0] m00_axi_arlen  ,
  input  logic                         m00_axi_rvalid ,
  output logic                         m00_axi_rready ,
  input  logic [ M_AXI4_BE_DATA_W-1:0] m00_axi_rdata  ,
  input  logic                         m00_axi_rlast  ,
  // Control Signals
  // AXI4 master interface m00_axi missing ports
  input  logic [   M_AXI4_BE_ID_W-1:0] m00_axi_bid    ,
  input  logic [   M_AXI4_BE_ID_W-1:0] m00_axi_rid    ,
  input  logic [ M_AXI4_BE_RESP_W-1:0] m00_axi_rresp  ,
  input  logic [ M_AXI4_BE_RESP_W-1:0] m00_axi_bresp  ,
  output logic [   M_AXI4_BE_ID_W-1:0] m00_axi_awid   ,
  output logic [ M_AXI4_BE_SIZE_W-1:0] m00_axi_awsize ,
  output logic [M_AXI4_BE_BURST_W-1:0] m00_axi_awburst,
  output logic [ M_AXI4_BE_LOCK_W-1:0] m00_axi_awlock ,
  output logic [M_AXI4_BE_CACHE_W-1:0] m00_axi_awcache,
  output logic [ M_AXI4_BE_PROT_W-1:0] m00_axi_awprot ,
  output logic [  M_AXI4_BE_QOS_W-1:0] m00_axi_awqos  ,
  output logic [   M_AXI4_BE_ID_W-1:0] m00_axi_arid   ,
  output logic [ M_AXI4_BE_SIZE_W-1:0] m00_axi_arsize ,
  output logic [M_AXI4_BE_BURST_W-1:0] m00_axi_arburst,
  output logic [ M_AXI4_BE_LOCK_W-1:0] m00_axi_arlock ,
  output logic [M_AXI4_BE_CACHE_W-1:0] m00_axi_arcache,
  output logic [ M_AXI4_BE_PROT_W-1:0] m00_axi_arprot ,
  output logic [  M_AXI4_BE_QOS_W-1:0] m00_axi_arqos  ,
  input  logic                         ap_start       ,
  output logic                         ap_idle        ,
  output logic                         ap_done        ,
  output logic                         ap_ready       ,
  input  logic                         ap_continue    ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_0       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_1       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_2       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_3       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_4       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_5       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_6       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_7       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_8       ,
  input  logic [ M_AXI4_BE_ADDR_W-1:0] buffer_9
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_m_axi  ;
logic areset_cu     ;
logic areset_control;
logic areset_cache  ;

// --------------------------------------------------------------------------------------
// AXI
// --------------------------------------------------------------------------------------
AXI4BEMasterReadInterface  m_axi4_read     ;
AXI4BEMasterWriteInterface m_axi4_write    ;
logic                      endian_read_reg ;
logic                      endian_write_reg;

// --------------------------------------------------------------------------------------
// Kernel -> State Control
// --------------------------------------------------------------------------------------
ControlChainInterfaceInput  kernel_control_in ;
ControlChainInterfaceOutput kernel_control_out;

KernelDescriptorPayload kernel_control_descriptor_in ;
KernelDescriptor        kernel_control_descriptor_out;

logic kernel_cu_done_out         ;
logic kernel_cu_fifo_setup_signal;

// --------------------------------------------------------------------------------------
// CU -> [CU_CACHE|BUNDLES|LANES|ENGINES]
// --------------------------------------------------------------------------------------
KernelDescriptor kernel_cu_descriptor_in;

// --------------------------------------------------------------------------------------
// System Cache -> AXI
// --------------------------------------------------------------------------------------
AXI4MIDSlaveReadInterfaceOutput  kernel_cache_s_axi_read_out ;
AXI4MIDSlaveReadInterfaceInput   kernel_cache_s_axi_read_in  ;
AXI4MIDSlaveWriteInterfaceOutput kernel_cache_s_axi_write_out;
AXI4MIDSlaveWriteInterfaceInput  kernel_cache_s_axi_write_in ;

AXI4BEMasterReadInterfaceInput   kernel_cache_m_axi4_read_in  ;
AXI4BEMasterReadInterfaceOutput  kernel_cache_m_axi4_read_out ;
AXI4BEMasterWriteInterfaceInput  kernel_cache_m_axi4_write_in ;
AXI4BEMasterWriteInterfaceOutput kernel_cache_m_axi4_write_out;

logic kernel_cache_setup_signal;

// --------------------------------------------------------------------------------------
//   Register and invert reset signal.
// --------------------------------------------------------------------------------------
parameter PULSE_HOLD    = 100;
logic     areset_system      ;
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_m_axi   <= areset_system;
  areset_cu      <= areset_system;
  areset_control <= areset_system;
  areset_cache   <= areset_system;
end

logic [PULSE_HOLD-1:0] sync_ff;

always_ff @(posedge ap_clk or negedge ap_rst_n) begin
  if (~ap_rst_n | ap_done) begin
    // Asynchronously assert reset (active low reset)
    sync_ff <= {PULSE_HOLD{1'b1}};;
  end else begin
    // Synchronously de-assert reset
    sync_ff <= sync_ff << 1'b1;
  end
end

// Output of the second flip-flop is the synchronized reset
assign areset_system = sync_ff[PULSE_HOLD-1];

// --------------------------------------------------------------------------------------
// Control chain signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    kernel_control_in.ap_start    <= 1'b0;
    kernel_control_in.ap_continue <= 1'b0;
    kernel_control_in.setup       <= 1'b0;
    kernel_control_in.done        <= 1'b0;
  end
  else begin
    kernel_control_in.ap_start    <= ap_start;
    kernel_control_in.ap_continue <= ap_continue;
    kernel_control_in.setup       <= ~(kernel_cu_fifo_setup_signal | kernel_cache_setup_signal);
    kernel_control_in.done        <= kernel_cu_done_out;
  end
end

always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    ap_ready         <= 1'b0;
    ap_done          <= 1'b0;
    ap_idle          <= 1'b1;
    endian_read_reg  <= 1'b0;
    endian_write_reg <= 1'b0;
  end
  else begin
    ap_done          <= kernel_control_out.ap_done;
    ap_ready         <= kernel_control_out.ap_ready;
    ap_idle          <= kernel_control_out.ap_idle;
    endian_read_reg  <= kernel_control_out.endian_read;
    endian_write_reg <= kernel_control_out.endian_write;
  end
end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m_axi4_read.in <= 0;
  end
  else begin
    m_axi4_read.in.rvalid  <= m00_axi_rvalid ; // Read channel valid
    m_axi4_read.in.arready <= m00_axi_arready; // Address read channel ready
    m_axi4_read.in.rlast   <= m00_axi_rlast  ; // Read channel last word
    m_axi4_read.in.rdata   <= swap_endianness_cacheline_axi_be(m00_axi_rdata, endian_read_reg)  ; // Read channel data
    m_axi4_read.in.rid     <= m00_axi_rid    ; // Read channel ID
    m_axi4_read.in.rresp   <= m00_axi_rresp  ; // Read channel response
  end
end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m00_axi_arvalid <= 0; // Address read channel valid
    m00_axi_araddr  <= 0; // Address read channel address
    m00_axi_arlen   <= 0; // Address write channel burst length
    m00_axi_rready  <= 0; // Read channel ready
    m00_axi_arid    <= 0; // Address read channel ID
    m00_axi_arsize  <= 0; // Address read channel burst size. This signal indicates the size of each transfer in the burst
    m00_axi_arburst <= M_AXI4_BE_BURST_INCR; // Address read channel burst type
    m00_axi_arlock  <= 0; // Address read channel lock type
    m00_axi_arcache <= M_AXI4_BE_CACHE_BUFFERABLE_NO_ALLOCATE; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    m00_axi_arprot  <= 0; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    m00_axi_arqos   <= 0; // Address write channel quality of service
  end
  else begin
    m00_axi_arvalid <= m_axi4_read.out.arvalid; // Address read channel valid
    m00_axi_araddr  <= m_axi4_read.out.araddr ; // Address read channel address
    m00_axi_arlen   <= m_axi4_read.out.arlen  ; // Address write channel burst length
    m00_axi_rready  <= m_axi4_read.out.rready ; // Read channel ready
    m00_axi_arid    <= m_axi4_read.out.arid   ; // Address read channel ID
    m00_axi_arsize  <= m_axi4_read.out.arsize ; // Address read channel burst size. This signal indicates the size of each transfer in the burst
    m00_axi_arburst <= m_axi4_read.out.arburst; // Address read channel burst type
    m00_axi_arlock  <= m_axi4_read.out.arlock ; // Address read channel lock type
    m00_axi_arcache <= m_axi4_read.out.arcache; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    m00_axi_arprot  <= m_axi4_read.out.arprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    m00_axi_arqos   <= m_axi4_read.out.arqos  ; // Address write channel quality of service
  end
end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m_axi4_write.in <= 0;
  end
  else begin
    m_axi4_write.in.awready <= m00_axi_awready; // Address write channel ready
    m_axi4_write.in.wready  <= m00_axi_wready ; // Write channel ready
    m_axi4_write.in.bid     <= m00_axi_bid    ; // Write response channel ID
    m_axi4_write.in.bresp   <= m00_axi_bresp  ; // Write channel response
    m_axi4_write.in.bvalid  <= m00_axi_bvalid ; // Write response channel valid
  end
end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m00_axi_awvalid <= 0;// Address write channel valid
    m00_axi_awid    <= 0;// Address write channel ID
    m00_axi_awaddr  <= 0;// Address write channel address
    m00_axi_awlen   <= 0;// Address write channel burst length
    m00_axi_awsize  <= 0;// Address write channel burst size. This signal indicates the size of each transfer in the burst
    m00_axi_awburst <= M_AXI4_BE_BURST_INCR;// Address write channel burst type
    m00_axi_awlock  <= 0;// Address write channel lock type
    m00_axi_awcache <= M_AXI4_BE_CACHE_BUFFERABLE_NO_ALLOCATE;// Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    m00_axi_awprot  <= 0;// Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    m00_axi_awqos   <= 0;// Address write channel quality of service
    m00_axi_wdata   <= 0;// Write channel data
    m00_axi_wstrb   <= 0;// Write channel write strobe
    m00_axi_wlast   <= 0;// Write channel last word flag
    m00_axi_wvalid  <= 0;// Write channel valid
    m00_axi_bready  <= 0;// Write response channel ready
  end
  else begin
    m00_axi_awvalid <= m_axi4_write.out.awvalid; // Address write channel valid
    m00_axi_awid    <= m_axi4_write.out.awid   ; // Address write channel ID
    m00_axi_awaddr  <= m_axi4_write.out.awaddr ; // Address write channel address
    m00_axi_awlen   <= m_axi4_write.out.awlen  ; // Address write channel burst length
    m00_axi_awsize  <= m_axi4_write.out.awsize ; // Address write channel burst size. This signal indicates the size of each transfer in the burst
    m00_axi_awburst <= m_axi4_write.out.awburst; // Address write channel burst type
    m00_axi_awlock  <= m_axi4_write.out.awlock ; // Address write channel lock type
    m00_axi_awcache <= m_axi4_write.out.awcache; // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    m00_axi_awprot  <= m_axi4_write.out.awprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    m00_axi_awqos   <= m_axi4_write.out.awqos  ; // Address write channel quality of service
    m00_axi_wdata   <= swap_endianness_cacheline_axi_be(m_axi4_write.out.wdata , endian_write_reg); // Write channel data
    m00_axi_wstrb   <= m_axi4_write.out.wstrb  ; // Write channel write strobe
    m00_axi_wlast   <= m_axi4_write.out.wlast  ; // Write channel last word flag
    m00_axi_wvalid  <= m_axi4_write.out.wvalid ; // Write channel valid
    m00_axi_bready  <= m_axi4_write.out.bready ; // Write response channel ready
  end
end

// --------------------------------------------------------------------------------------
// DRIVE DESCRIPTOR
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  kernel_control_descriptor_in.buffer_0 <= buffer_0  ;
  kernel_control_descriptor_in.buffer_1 <= buffer_1  ;
  kernel_control_descriptor_in.buffer_2 <= buffer_2  ;
  kernel_control_descriptor_in.buffer_3 <= buffer_3  ;
  kernel_control_descriptor_in.buffer_4 <= buffer_4  ;
  kernel_control_descriptor_in.buffer_5 <= buffer_5  ;
  kernel_control_descriptor_in.buffer_6 <= buffer_6  ;
  kernel_control_descriptor_in.buffer_7 <= buffer_7  ;
  kernel_control_descriptor_in.buffer_8 <= buffer_8  ;
  kernel_control_descriptor_in.buffer_9 <= buffer_9  ;
end


generate
  if(GLOBAL_SYSTEM_CACHE_IP == 1) begin
// --------------------------------------------------------------------------------------
// System Cache -> AXI
// --------------------------------------------------------------------------------------
    assign kernel_cache_m_axi4_read_in  = m_axi4_read.in  ;
    assign m_axi4_read.out              = kernel_cache_m_axi4_read_out  ;
    assign kernel_cache_m_axi4_write_in = m_axi4_write.in ;
    assign m_axi4_write.out             = kernel_cache_m_axi4_write_out;

    kernel_cache inst_kernel_cache (
      .ap_clk            (ap_clk                       ),
      .areset            (areset_cache                 ),
      .s_axi_read_out    (kernel_cache_s_axi_read_out  ),
      .s_axi_read_in     (kernel_cache_s_axi_read_in   ),
      .s_axi_write_out   (kernel_cache_s_axi_write_out ),
      .s_axi_write_in    (kernel_cache_s_axi_write_in  ),
      .m_axi_read_in     (kernel_cache_m_axi4_read_in  ),
      .m_axi_read_out    (kernel_cache_m_axi4_read_out ),
      .m_axi_write_in    (kernel_cache_m_axi4_write_in ),
      .m_axi_write_out   (kernel_cache_m_axi4_write_out),
      .cache_setup_signal(kernel_cache_setup_signal    )
    );
  end else begin
    assign kernel_cache_setup_signal     = 0;
    assign kernel_cache_m_axi4_read_in   = m_axi4_read.in  ;
    assign m_axi4_read.out               = kernel_cache_m_axi4_read_out;
    assign kernel_cache_m_axi4_write_in  = m_axi4_write.in ;
    assign m_axi4_write.out              = kernel_cache_m_axi4_write_out;
    assign kernel_cache_s_axi_read_out   = kernel_cache_m_axi4_read_in;
    assign kernel_cache_m_axi4_read_out  = kernel_cache_s_axi_read_in;
    assign kernel_cache_s_axi_write_out  = kernel_cache_m_axi4_write_in;
    assign kernel_cache_m_axi4_write_out = kernel_cache_s_axi_write_in;
  end
endgenerate

// --------------------------------------------------------------------------------------
// CU -> [CU_CACHE|BUNDLES|LANES|ENGINES]
// --------------------------------------------------------------------------------------
// Kernel_setup
assign kernel_cu_descriptor_in = kernel_control_descriptor_out;

kernel_cu #(.ID_CU(0)) inst_kernel_cu (
  .ap_clk           (ap_clk                      ),
  .areset           (areset_cu                   ),
  .descriptor_in    (kernel_cu_descriptor_in     ),
  .m_axi_read_in    (kernel_cache_s_axi_read_out ),
  .m_axi_read_out   (kernel_cache_s_axi_read_in  ),
  .m_axi_write_in   (kernel_cache_s_axi_write_out),
  .m_axi_write_out  (kernel_cache_s_axi_write_in ),
  .fifo_setup_signal(kernel_cu_fifo_setup_signal ),
  .done_out         (kernel_cu_done_out          )
);

// --------------------------------------------------------------------------------------
// Kernel -> State Control
// --------------------------------------------------------------------------------------
kernel_control inst_kernel_control (
  .ap_clk        (ap_clk                       ),
  .areset        (areset_control               ),
  .control_in    (kernel_control_in            ),
  .control_out   (kernel_control_out           ),
  .descriptor_in (kernel_control_descriptor_in ),
  .descriptor_out(kernel_control_descriptor_out)
);

endmodule : kernel_afu

