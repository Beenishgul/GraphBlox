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

module kernel_afu #(
  `include "afu_parameters.vh"
) (
  // System Signals
  input  logic                           ap_clk     ,
  input  logic                           ap_rst_n   ,
  // AXI4 master interface m00_axi
  `include "m_axi_ports_afu.vh"
  // Control Signals
  input  logic                           ap_start   ,
  output logic                           ap_idle    ,
  output logic                           ap_done    ,
  output logic                           ap_ready   ,
  input  logic                           ap_continue,
  input  logic [BUFFER_0_WIDTH_BITS-1:0] buffer_0   ,
  input  logic [BUFFER_1_WIDTH_BITS-1:0] buffer_1   ,
  input  logic [BUFFER_2_WIDTH_BITS-1:0] buffer_2   ,
  input  logic [BUFFER_3_WIDTH_BITS-1:0] buffer_3   ,
  input  logic [BUFFER_4_WIDTH_BITS-1:0] buffer_4   ,
  input  logic [BUFFER_5_WIDTH_BITS-1:0] buffer_5   ,
  input  logic [BUFFER_6_WIDTH_BITS-1:0] buffer_6   ,
  input  logic [BUFFER_7_WIDTH_BITS-1:0] buffer_7   ,
  input  logic [BUFFER_8_WIDTH_BITS-1:0] buffer_8   ,
  input  logic [BUFFER_9_WIDTH_BITS-1:0] buffer_9
);

genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_m_axi               ;
logic areset_cu     [NUM_CUS-1:0];
logic areset_control             ;


logic endian_read_reg ;
logic endian_write_reg;

// --------------------------------------------------------------------------------------
// Kernel -> State Control
// --------------------------------------------------------------------------------------
ControlChainInterfaceInput  kernel_control_in ;
ControlChainInterfaceOutput kernel_control_out;

KernelDescriptorPayload kernel_control_descriptor_in ;
KernelDescriptor        kernel_control_descriptor_out;

logic [NUM_CUS-1:0] kernel_cu_done_out         ;
logic [NUM_CUS-1:0] kernel_cu_fifo_setup_signal;

logic [NUM_CUS-1:0] cus_flush_int;
logic [NUM_CUS-1:0] cu_flush_out;
// --------------------------------------------------------------------------------------
// CU -> [CU_CACHE|BUNDLES|LANES|ENGINES]
// --------------------------------------------------------------------------------------
KernelDescriptor kernel_cu_descriptor_in[NUM_CUS-1:0];

// --------------------------------------------------------------------------------------
// System Cache -> AXI Mutli channels support
// --------------------------------------------------------------------------------------
logic                    areset_axi_slice         [NUM_CHANNELS-1:0];
logic                    areset_cache             [NUM_CHANNELS-1:0];
logic [NUM_CHANNELS-1:0] kernel_cache_setup_signal                  ;

// --------------------------------------------------------------------------------------
//   Register and invert reset signal.
// --------------------------------------------------------------------------------------
localparam PULSE_HOLD    = 100;
logic      areset_system      ;
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_m_axi   <= areset_system;
  areset_control <= areset_system;

  for (int i = 0; i < NUM_CHANNELS; i++) begin
    areset_cache[i]     <= areset_system;
    areset_axi_slice[i] <= areset_system;
  end

  for (int i = 0; i < NUM_CUS; i++) begin
    areset_cu[i] <= areset_system;
  end
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
    kernel_control_in.setup       <= ~(|kernel_cu_fifo_setup_signal | (|kernel_cache_setup_signal));
    kernel_control_in.done        <= &kernel_cu_done_out;
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

// --------------------------------------------------------------------------------------
// System Cache CH 0-> AXI
// --------------------------------------------------------------------------------------
`include "afu_topology.vh"

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

