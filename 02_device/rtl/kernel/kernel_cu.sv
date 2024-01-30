// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_cu.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-06-22 15:43:24
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module kernel_cu #(
  `include "kernel_parameters.vh"
) (
  input  logic                                   ap_clk                              ,
  input  logic                                   areset                              ,
  input  KernelDescriptor                        descriptor_in                       ,
  `include "m_axi_ports_kernel_cu.vh"
  output logic                                   fifo_setup_signal                   ,
  output logic                                   done_out
);

genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
logic areset_control  ;
logic areset_generator;
logic areset_setup    ;
logic areset_bundles  ;

logic fifo_empty_int;
logic fifo_empty_reg;

KernelDescriptor descriptor_in_reg;

// --------------------------------------------------------------------------------------
// Assign FIFO signals Requestor <-> Generator <-> Setup <-> CU <-> Cache
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
MemoryPacketResponse   cache_generator_response_in                                         ;
FIFOStateSignalsInput  cache_generator_fifo_response_signals_in                            ;
FIFOStateSignalsOutput cache_generator_fifo_response_signals_out                           ;
MemoryPacketResponse   cache_generator_response_out              [NUM_MEMORY_REQUESTOR-1:0];
logic                  cache_generator_fifo_response_setup_signal                          ;

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
MemoryPacketRequest              cache_generator_request_in               [NUM_MEMORY_REQUESTOR-1:0];
FIFOStateSignalsInput            cache_generator_fifo_request_signals_in                            ;
FIFOStateSignalsOutput           cache_generator_fifo_request_signals_out                           ;
logic [NUM_MEMORY_REQUESTOR-1:0] cache_generator_arbiter_grant_out                                  ;
MemoryPacketRequest              cache_generator_request_out                                        ;
logic                            cache_generator_fifo_request_setup_signal                          ;

// --------------------------------------------------------------------------------------
// Signals setup and configuration reading
// --------------------------------------------------------------------------------------
KernelDescriptor       cu_setup_descriptor               ;
MemoryPacketResponse   cu_setup_response_in              ;
FIFOStateSignalsOutput cu_setup_fifo_response_signals_out;
FIFOStateSignalsInput  cu_setup_fifo_response_signals_in ;
MemoryPacketRequest    cu_setup_request_out              ;
FIFOStateSignalsOutput cu_setup_fifo_request_signals_out ;
FIFOStateSignalsInput  cu_setup_fifo_request_signals_in  ;
logic                  cu_setup_fifo_setup_signal        ;
logic                  cu_setup_cu_flush                 ;
logic                  cu_setup_done_out                 ;

// --------------------------------------------------------------------------------------
// Signals for CU
// --------------------------------------------------------------------------------------
KernelDescriptor       cu_bundles_descriptor               ;
MemoryPacketResponse   cu_bundles_response_in              ;
FIFOStateSignalsOutput cu_bundles_fifo_response_signals_out;
FIFOStateSignalsInput  cu_bundles_fifo_response_signals_in ;
MemoryPacketRequest    cu_bundles_request_out              ;
FIFOStateSignalsOutput cu_bundles_fifo_request_signals_out ;
FIFOStateSignalsInput  cu_bundles_fifo_request_signals_in  ;
logic                  cu_bundles_fifo_setup_signal        ;

// --------------------------------------------------------------------------------------
logic [PULSE_HOLD-1:0] cu_bundles_done_hold  ;
logic                  cu_bundles_done_out   ;
logic                  cu_bundles_done_assert;
logic [PULSE_HOLD-1:0] cu_setup_done_hold    ;
logic                  cu_setup_done_assert  ;

// --------------------------------------------------------------------------------------
// CU Stream -> AXI-Multi CH
// --------------------------------------------------------------------------------------
logic                  areset_cu_channel                           [NUM_CHANNELS-1:0];
KernelDescriptor       cu_channel_descriptor                       [NUM_CHANNELS-1:0];
MemoryPacketRequest    cu_channel_request_in                       [NUM_CHANNELS-1:0];
FIFOStateSignalsOutput cu_channel_fifo_request_signals_out         [NUM_CHANNELS-1:0];
FIFOStateSignalsInput  cu_channel_fifo_request_signals_in          [NUM_CHANNELS-1:0];
FIFOStateSignalsOutput cu_channel_fifo_request_backtrack_signals_in[NUM_CHANNELS-1:0];

MemoryPacketResponse     cu_channel_response_out             [NUM_CHANNELS-1:0];
FIFOStateSignalsOutput   cu_channel_fifo_response_signals_out[NUM_CHANNELS-1:0];
FIFOStateSignalsInput    cu_channel_fifo_response_signals_in [NUM_CHANNELS-1:0];
logic [NUM_CHANNELS-1:0] cu_channel_fifo_setup_signal                          ;
logic [NUM_CHANNELS-1:0] cu_channel_done_out                                   ;

// --------------------------------------------------------------------------------------
logic areset_axi_slice     [NUM_CHANNELS-1:0];
logic areset_axi_lite_slice[NUM_CHANNELS-1:0];

// --------------------------------------------------------------------------------------
// Generate Channel - Arbiter Signals: Channel Respnse Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput    ch_arbiter_N_to_1_cache_fifo_response_signals_in                   ;
FIFOStateSignalsOutput   ch_arbiter_N_to_1_cache_fifo_response_signals_out                  ;
logic                    areset_ch_arbiter_N_to_1_cache                                     ;
logic                    ch_arbiter_N_to_1_cache_fifo_setup_signal                          ;
logic [NUM_CHANNELS-1:0] ch_arbiter_N_to_1_cache_ch_arbiter_grant_out                       ;
MemoryPacketResponse     ch_arbiter_N_to_1_cache_response_in              [NUM_CHANNELS-1:0];
MemoryPacketResponse     ch_arbiter_N_to_1_cache_response_out                               ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Channel Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  ch_arbiter_1_to_N_chs_cache_fifo_request_signals_in [NUM_CHANNELS-1:0];
FIFOStateSignalsOutput ch_arbiter_1_to_N_chs_cache_fifo_request_signals_out                  ;
logic                  areset_ch_arbiter_1_to_N_chs_cache                                    ;
logic                  ch_arbiter_1_to_N_chs_cache_fifo_setup_signal                         ;
MemoryPacketRequest    ch_arbiter_1_to_N_chs_cache_request_in                                ;
MemoryPacketRequest    ch_arbiter_1_to_N_chs_cache_request_out             [NUM_CHANNELS-1:0];


// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_control                     <= areset;
  areset_setup                       <= areset;
  areset_generator                   <= areset;
  areset_ch_arbiter_N_to_1_cache     <= areset;
  areset_ch_arbiter_1_to_N_chs_cache <= areset;
  areset_bundles                     <= areset;
  for (int i = 0; i < NUM_CHANNELS; i++) begin
    areset_axi_slice[i]      <= areset;
    areset_cu_channel[i]     <= areset;
    areset_axi_lite_slice[i] <= areset;
  end
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal <= 1'b1;
    done_out          <= 1'b0;
    fifo_empty_reg    <= 1'b1;
    cu_setup_cu_flush <= 1'b0;
  end
  else begin
    fifo_setup_signal <= ch_arbiter_1_to_N_chs_cache_fifo_setup_signal | ch_arbiter_N_to_1_cache_fifo_setup_signal | (|cu_channel_fifo_setup_signal) | cache_generator_fifo_request_setup_signal | cache_generator_fifo_response_setup_signal | cu_setup_fifo_setup_signal | cu_bundles_fifo_setup_signal;
    done_out          <= cu_setup_done_assert;
    cu_setup_cu_flush <= cu_bundles_done_assert;
    fifo_empty_reg    <= fifo_empty_int;
  end
end

assign fifo_empty_int = ch_arbiter_N_to_1_cache_fifo_response_signals_out.empty & cache_generator_fifo_request_signals_out.empty & cache_generator_fifo_response_signals_out.empty;


// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    descriptor_in_reg.valid     <= 1'b0;
    cu_setup_descriptor.valid   <= 1'b0;
    cu_bundles_descriptor.valid <= 1'b0;
    for (int i = 0; i < NUM_CHANNELS; i++) begin
      cu_channel_descriptor[i].valid  <= 1'b0;
    end
  end
  else begin
    descriptor_in_reg.valid     <= descriptor_in.valid;
    cu_setup_descriptor.valid   <= descriptor_in_reg.valid;
    cu_bundles_descriptor.valid <= descriptor_in_reg.valid;
    for (int i = 0; i < NUM_CHANNELS; i++) begin
      cu_channel_descriptor[i].valid  <= descriptor_in_reg.valid;
    end
  end
end

always_ff @(posedge ap_clk) begin
  descriptor_in_reg.payload     <= descriptor_in.payload;
  cu_setup_descriptor.payload   <= descriptor_in_reg.payload;
  cu_bundles_descriptor.payload <= descriptor_in_reg.payload;
  for (int i = 0; i < NUM_CHANNELS; i++) begin
    cu_channel_descriptor[i].payload  <= descriptor_in_reg.payload;
  end
end

// --------------------------------------------------------------------------------------
// Assign FIFO signals Requestor <-> Generator <-> Setup <-> CU
// --------------------------------------------------------------------------------------
assign cache_generator_fifo_request_signals_in.rd_en  = ~(ch_arbiter_1_to_N_chs_cache_fifo_request_signals_out.prog_full);
assign cache_generator_fifo_response_signals_in.rd_en = ~(cu_setup_fifo_response_signals_out.prog_full|cu_bundles_fifo_response_signals_out.prog_full);

assign cu_setup_fifo_request_signals_in.rd_en  = ~cache_generator_fifo_request_signals_out.prog_full & cache_generator_arbiter_grant_out[0];
assign cu_setup_fifo_response_signals_in.rd_en = 1'b1;

assign cu_bundles_fifo_request_signals_in.rd_en  = ~cache_generator_fifo_request_signals_out.prog_full & cache_generator_arbiter_grant_out[1];
assign cu_bundles_fifo_response_signals_in.rd_en = 1'b1;

// --------------------------------------------------------------------------------------
// Arbiter Signals: Cache Request Generator
// --------------------------------------------------------------------------------------
// cu_setup
assign cu_setup_response_in          = cache_generator_response_out[0];
assign cache_generator_request_in[0] = cu_setup_request_out;

// vertex_cu
assign cu_bundles_response_in        = cache_generator_response_out[1];
assign cache_generator_request_in[1] = cu_bundles_request_out;

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
arbiter_N_to_1_request_cache #(
  .NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR                      ),
  .FIFO_ARBITER_DEPTH  (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
) inst_cache_generator_request (
  .ap_clk                  (ap_clk                                   ),
  .areset                  (areset_generator                         ),
  .request_in              (cache_generator_request_in               ),
  .fifo_request_signals_in (cache_generator_fifo_request_signals_in  ),
  .fifo_request_signals_out(cache_generator_fifo_request_signals_out ),
  .arbiter_grant_out       (cache_generator_arbiter_grant_out        ),
  .request_out             (cache_generator_request_out              ),
  .fifo_setup_signal       (cache_generator_fifo_request_setup_signal)
);

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Channel Request Generator
// --------------------------------------------------------------------------------------
arbiter_1_to_N_request_cache #(
  .ID_LEVEL            (0                                         ),
  .NUM_MEMORY_REQUESTOR(NUM_CHANNELS                              ),
  .FIFO_ARBITER_DEPTH  (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
) inst_ch_arbiter_1_to_N_request_cache_out (
  .ap_clk                  (ap_clk                                              ),
  .areset                  (areset_ch_arbiter_1_to_N_chs_cache                  ),
  .request_in              (ch_arbiter_1_to_N_chs_cache_request_in              ),
  .fifo_request_signals_in (ch_arbiter_1_to_N_chs_cache_fifo_request_signals_in ),
  .fifo_request_signals_out(ch_arbiter_1_to_N_chs_cache_fifo_request_signals_out),
  .request_out             (ch_arbiter_1_to_N_chs_cache_request_out             ),
  .fifo_setup_signal       (ch_arbiter_1_to_N_chs_cache_fifo_setup_signal       )
);

always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    ch_arbiter_1_to_N_chs_cache_request_in.valid <= 1'b0;
  end
  else begin
    ch_arbiter_1_to_N_chs_cache_request_in.valid <= cache_generator_request_out.valid ;
  end
end

always_ff @(posedge ap_clk) begin
  ch_arbiter_1_to_N_chs_cache_request_in.payload <= cache_generator_request_out.payload;

  for (int i = 0; i < NUM_CHANNELS; i++) begin
    cu_channel_request_in[i] <= ch_arbiter_1_to_N_chs_cache_request_out[i];
    ch_arbiter_1_to_N_chs_cache_fifo_request_signals_in[i].rd_en = ~cu_channel_fifo_request_signals_out[i].prog_full ;
    cu_channel_fifo_request_signals_in[i].rd_en <= 1'b1;

    cu_channel_fifo_request_backtrack_signals_in[i]  = cu_channel_fifo_request_signals_out[i];
  end
end

// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
arbiter_1_to_N_response_cache #(
  .NUM_MEMORY_RECEIVER(NUM_MEMORY_REQUESTOR                      ),
  .FIFO_ARBITER_DEPTH (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
) inst_cache_generator_response (
  .ap_clk                   (ap_clk                                    ),
  .areset                   (areset_generator                          ),
  .response_in              (cache_generator_response_in               ),
  .fifo_response_signals_in (cache_generator_fifo_response_signals_in  ),
  .fifo_response_signals_out(cache_generator_fifo_response_signals_out ),
  .response_out             (cache_generator_response_out              ),
  .fifo_setup_signal        (cache_generator_fifo_response_setup_signal)
);

// --------------------------------------------------------------------------------------
// Generate Channel - Arbiter Signals: Channel Response Generator
// --------------------------------------------------------------------------------------
arbiter_N_to_1_response_cache #(
  .NUM_MEMORY_RECEIVER(NUM_CHANNELS                              ),
  .FIFO_ARBITER_DEPTH (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
) inst_ch_arbiter_N_to_1_response_cache_in (
  .ap_clk                   (ap_clk                                           ),
  .areset                   (areset_ch_arbiter_N_to_1_cache                   ),
  .response_in              (ch_arbiter_N_to_1_cache_response_in              ),
  .fifo_response_signals_in (ch_arbiter_N_to_1_cache_fifo_response_signals_in ),
  .fifo_response_signals_out(ch_arbiter_N_to_1_cache_fifo_response_signals_out),
  .arbiter_grant_out        (ch_arbiter_N_to_1_cache_ch_arbiter_grant_out     ),
  .response_out             (ch_arbiter_N_to_1_cache_response_out             ),
  .fifo_setup_signal        (ch_arbiter_N_to_1_cache_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
//   Register arbiter_N_to_1_response_cache signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    cache_generator_response_in.valid <= 1'b0;
  end
  else begin
    cache_generator_response_in.valid <= ch_arbiter_N_to_1_cache_response_out.valid;
  end
end

always_ff @(posedge ap_clk) begin
  cache_generator_response_in.payload                    <= ch_arbiter_N_to_1_cache_response_out.payload;
  ch_arbiter_N_to_1_cache_fifo_response_signals_in.rd_en <= ~cache_generator_fifo_response_signals_out.prog_full;

  for (int i = 0; i < NUM_CHANNELS; i++) begin
    ch_arbiter_N_to_1_cache_response_in[i] <= cu_channel_response_out[i];
    cu_channel_fifo_response_signals_in[i].rd_en <= ~ch_arbiter_N_to_1_cache_fifo_response_signals_out.prog_full & ch_arbiter_N_to_1_cache_ch_arbiter_grant_out[i];
  end
end

// --------------------------------------------------------------------------------------
// CU Cache -> AXI-CH 0
// --------------------------------------------------------------------------------------
`include "kernel_cu_topology.vh"
// --------------------------------------------------------------------------------------
// Generate CU CACHE CH 1:0 (M->S) Register Slice
// --------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------
// Initial setup and configuration reading
// --------------------------------------------------------------------------------------
cu_setup #(
  .ID_CU    ({NUM_CUS_WIDTH_BITS{1'b1}}    ),
  .ID_BUNDLE({NUM_BUNDLES_WIDTH_BITS{1'b1}}),
  .ID_LANE  ({NUM_LANES_WIDTH_BITS{1'b1}}  )
) inst_cu_setup (
  .ap_clk                   (ap_clk                            ),
  .areset                   (areset_setup                      ),
  .cu_flush                 (cu_setup_cu_flush                 ),
  .descriptor_in            (cu_setup_descriptor               ),
  .response_in              (cu_setup_response_in              ),
  .fifo_response_signals_in (cu_setup_fifo_response_signals_in ),
  .fifo_response_signals_out(cu_setup_fifo_response_signals_out),
  .request_out              (cu_setup_request_out              ),
  .fifo_request_signals_in  (cu_setup_fifo_request_signals_in  ),
  .fifo_request_signals_out (cu_setup_fifo_request_signals_out ),
  .fifo_setup_signal        (cu_setup_fifo_setup_signal        ),
  .done_out                 (cu_setup_done_out                 )
);

// --------------------------------------------------------------------------------------
// Bundles CU
// --------------------------------------------------------------------------------------
cu_bundles #(
  `include"set_cu_parameters.vh"
  ) inst_cu_bundles (
  .ap_clk                                      (ap_clk                                      ),
  .areset                                      (areset_bundles                              ),
  .descriptor_in                               (cu_bundles_descriptor                       ),
  .response_memory_in                          (cu_bundles_response_in                      ),
  .fifo_response_memory_in_signals_in          (cu_bundles_fifo_response_signals_in         ),
  .fifo_response_memory_in_signals_out         (cu_bundles_fifo_response_signals_out        ),
  .request_memory_out                          (cu_bundles_request_out                      ),
  .fifo_request_memory_out_signals_in          (cu_bundles_fifo_request_signals_in          ),
  .fifo_request_memory_out_signals_out         (cu_bundles_fifo_request_signals_out         ),
  .fifo_request_memory_out_backtrack_signals_in(cu_channel_fifo_request_backtrack_signals_in),
  .fifo_setup_signal                           (cu_bundles_fifo_setup_signal                ),
  .done_out                                    (cu_bundles_done_out                         )
);

// --------------------------------------------------------------------------------------
// Make sure done signal is asserted for N cycles
// --------------------------------------------------------------------------------------
assign cu_bundles_done_assert = &cu_bundles_done_hold;

always_ff @(posedge ap_clk) begin
  if (areset_bundles) begin
    cu_bundles_done_hold <= 0;
  end else begin
    cu_bundles_done_hold <= {cu_bundles_done_hold[PULSE_HOLD-2:0],(cu_bundles_done_out & (&cu_channel_done_out) & fifo_empty_reg)};
  end
end

assign cu_setup_done_assert = &cu_setup_done_hold;

always_ff @(posedge ap_clk) begin
  if (areset_bundles) begin
    cu_setup_done_hold <= 0;
  end else begin
    cu_setup_done_hold <= {cu_setup_done_hold[PULSE_HOLD-2:0],(cu_setup_done_out & (&cu_channel_done_out) & fifo_empty_reg)};
  end
end

endmodule : kernel_cu
