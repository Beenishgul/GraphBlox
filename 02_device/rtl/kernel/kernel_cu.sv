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
  input  logic                             ap_clk           ,
  input  logic                             areset           ,
  input  KernelDescriptor                  descriptor_in    ,
  input  AXI4MIDMasterReadInterfaceInput   m_axi_read_in    ,
  output AXI4MIDMasterReadInterfaceOutput  m_axi_read_out   ,
  input  AXI4MIDMasterWriteInterfaceInput  m_axi_write_in   ,
  output AXI4MIDMasterWriteInterfaceOutput m_axi_write_out  ,
  output logic                             fifo_setup_signal,
  output logic                             done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
logic areset_control  ;
logic areset_generator;
logic areset_setup    ;
logic areset_bundles  ;
logic areset_cache    ;
logic areset_axi_slice;

logic fifo_empty_int;
logic fifo_empty_reg;

KernelDescriptor descriptor_in_reg;

// --------------------------------------------------------------------------------------
// Assign FIFO signals Requestor <-> Generator <-> Setup <-> CU <-> Cache
// --------------------------------------------------------------------------------------
CacheResponse         response_in_reg             ;
CacheRequest          request_out_reg             ;
FIFOStateSignalsInput fifo_response_signals_in_reg;
FIFOStateSignalsInput fifo_request_signals_in_reg ;

// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
CacheResponse          cache_generator_response_in                                         ;
FIFOStateSignalsInput  cache_generator_fifo_response_signals_in                            ;
FIFOStateSignalsOutput cache_generator_fifo_response_signals_out                           ;
MemoryPacket           cache_generator_response_out              [NUM_MEMORY_REQUESTOR-1:0];
logic                  cache_generator_fifo_response_setup_signal                          ;

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
MemoryPacket                     cache_generator_request_in               [NUM_MEMORY_REQUESTOR-1:0];
FIFOStateSignalsInput            cache_generator_fifo_request_signals_in                            ;
FIFOStateSignalsOutput           cache_generator_fifo_request_signals_out                           ;
logic [NUM_MEMORY_REQUESTOR-1:0] cache_generator_arbiter_request_in                                 ;
logic [NUM_MEMORY_REQUESTOR-1:0] cache_generator_arbiter_grant_out                                  ;
CacheRequest                     cache_generator_request_out                                        ;
logic                            cache_generator_fifo_request_setup_signal                          ;

// --------------------------------------------------------------------------------------
// Signals setup and configuration reading
// --------------------------------------------------------------------------------------
KernelDescriptor       cu_setup_descriptor               ;
MemoryPacket           cu_setup_response_in              ;
FIFOStateSignalsOutput cu_setup_fifo_response_signals_out;
FIFOStateSignalsInput  cu_setup_fifo_response_signals_in ;
MemoryPacket           cu_setup_request_out              ;
FIFOStateSignalsOutput cu_setup_fifo_request_signals_out ;
FIFOStateSignalsInput  cu_setup_fifo_request_signals_in  ;
logic                  cu_setup_fifo_setup_signal        ;
logic                  cu_setup_cu_flush                 ;
logic                  cu_setup_done_out                 ;

// --------------------------------------------------------------------------------------
// Signals for CU
// --------------------------------------------------------------------------------------
KernelDescriptor       cu_bundles_descriptor               ;
MemoryPacket           cu_bundles_response_in              ;
FIFOStateSignalsOutput cu_bundles_fifo_response_signals_out;
FIFOStateSignalsInput  cu_bundles_fifo_response_signals_in ;
MemoryPacket           cu_bundles_request_out              ;
FIFOStateSignalsOutput cu_bundles_fifo_request_signals_out ;
FIFOStateSignalsInput  cu_bundles_fifo_request_signals_in  ;
logic                  cu_bundles_fifo_setup_signal        ;

// --------------------------------------------------------------------------------------
parameter              PULSE_HOLD             = 128;
logic [PULSE_HOLD-1:0] cu_bundles_done_hold        ;
logic                  cu_bundles_done_out         ;
logic                  cu_bundles_done_assert      ;
logic [PULSE_HOLD-1:0] cu_setup_done_hold          ;
logic                  cu_setup_done_assert        ;

// --------------------------------------------------------------------------------------
// CU Cache -> AXI
// --------------------------------------------------------------------------------------
CacheRequest           cu_cache_request_in              ;
FIFOStateSignalsOutput cu_cache_fifo_request_signals_out;
FIFOStateSignalsInput  cu_cache_fifo_request_signals_in ;

CacheResponse          cu_cache_response_out             ;
FIFOStateSignalsOutput cu_cache_fifo_response_signals_out;
FIFOStateSignalsInput  cu_cache_fifo_response_signals_in ;
logic                  cu_cache_fifo_setup_signal        ;
logic                  cu_cache_done_out                 ;

AXI4MIDMasterReadInterfaceInput   cu_cache_m_axi_read_in  ;
AXI4MIDMasterReadInterfaceOutput  cu_cache_m_axi_read_out ;
AXI4MIDMasterWriteInterfaceInput  cu_cache_m_axi_write_in ;
AXI4MIDMasterWriteInterfaceOutput cu_cache_m_axi_write_out;


// --------------------------------------------------------------------------------------
// CU -> PEs
// --------------------------------------------------------------------------------------
CacheRequest           kernel_cu_request_out             ;
FIFOStateSignalsOutput kernel_cu_fifo_request_signals_out;
FIFOStateSignalsInput  kernel_cu_fifo_request_signals_in ;

CacheResponse          kernel_cu_response_in              ;
FIFOStateSignalsOutput kernel_cu_fifo_response_signals_out;
FIFOStateSignalsInput  kernel_cu_fifo_response_signals_in ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_control   <= areset;
  areset_setup     <= areset;
  areset_generator <= areset;
  areset_bundles   <= areset;
  areset_cache     <= areset;
  areset_axi_slice <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_response_signals_in_reg <= 0;
    fifo_request_signals_in_reg  <= 0;
    response_in_reg.valid        <= 0;
  end
  else begin
    fifo_response_signals_in_reg <= kernel_cu_fifo_response_signals_in;
    fifo_request_signals_in_reg  <= kernel_cu_fifo_request_signals_in;
    response_in_reg.valid        <= kernel_cu_response_in.valid;
  end
end

always_ff @(posedge ap_clk) begin
  response_in_reg.payload <= kernel_cu_response_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal           <= 1'b1;
    kernel_cu_request_out.valid <= 1'b0;
    done_out                    <= 1'b0;
    fifo_empty_reg              <= 1'b1;
    cu_setup_cu_flush           <= 1'b0;
  end
  else begin
    fifo_setup_signal           <= cu_cache_fifo_setup_signal | cache_generator_fifo_request_setup_signal | cache_generator_fifo_response_setup_signal | cu_setup_fifo_setup_signal | cu_bundles_fifo_setup_signal;
    kernel_cu_request_out.valid <= request_out_reg.valid ;
    done_out                    <= cu_setup_done_assert;
    cu_setup_cu_flush           <= cu_bundles_done_assert;
    fifo_empty_reg              <= fifo_empty_int;
  end
end

assign fifo_empty_int = cache_generator_fifo_request_signals_out.empty & cache_generator_fifo_response_signals_out.empty;

always_ff @(posedge ap_clk) begin
  kernel_cu_fifo_request_signals_out  <= cache_generator_fifo_request_signals_out;
  kernel_cu_fifo_response_signals_out <= cache_generator_fifo_response_signals_out;
  kernel_cu_request_out.payload       <= request_out_reg.payload;
end

// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    descriptor_in_reg.valid     <= 0;
    cu_setup_descriptor.valid   <= 0;
    cu_bundles_descriptor.valid <= 0;
  end
  else begin
    descriptor_in_reg.valid     <= descriptor_in.valid;
    cu_setup_descriptor.valid   <= descriptor_in_reg.valid;
    cu_bundles_descriptor.valid <= descriptor_in_reg.valid;
  end
end

always_ff @(posedge ap_clk) begin
  descriptor_in_reg.payload     <= descriptor_in.payload;
  cu_setup_descriptor.payload   <= descriptor_in_reg.payload;
  cu_bundles_descriptor.payload <= descriptor_in_reg.payload;
end

// --------------------------------------------------------------------------------------
// Assign FIFO signals Requestor <-> Generator <-> Setup <-> CU
// --------------------------------------------------------------------------------------
assign cache_generator_fifo_request_signals_in.rd_en  = ~(cu_cache_fifo_request_signals_out.prog_full) & fifo_request_signals_in_reg.rd_en;
assign cache_generator_fifo_response_signals_in.rd_en = ~(cu_setup_fifo_response_signals_out.prog_full|cu_bundles_fifo_response_signals_out.prog_full);

assign cu_setup_fifo_request_signals_in.rd_en  = ~cache_generator_fifo_request_signals_out.prog_full & fifo_request_signals_in_reg.rd_en & cache_generator_arbiter_grant_out[0];
assign cu_setup_fifo_response_signals_in.rd_en = 1'b1;

assign cu_bundles_fifo_request_signals_in.rd_en  = ~cache_generator_fifo_request_signals_out.prog_full & fifo_request_signals_in_reg.rd_en & cache_generator_arbiter_grant_out[1];
assign cu_bundles_fifo_response_signals_in.rd_en = 1'b1;

// --------------------------------------------------------------------------------------
// Arbiter Signals: Cache Request Generator
// --------------------------------------------------------------------------------------
// cu_setup
assign cu_setup_response_in                  = cache_generator_response_out[0];
assign cache_generator_request_in[0]         = cu_setup_request_out;
assign cache_generator_arbiter_request_in[0] = ~cu_setup_fifo_request_signals_out.empty & ~cache_generator_fifo_request_signals_out.prog_full;

// vertex_cu
assign cu_bundles_response_in                = cache_generator_response_out[1];
assign cache_generator_request_in[1]         = cu_bundles_request_out;
assign cache_generator_arbiter_request_in[1] = ~cu_bundles_fifo_request_signals_out.empty & ~cache_generator_fifo_request_signals_out.prog_full ;

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
assign request_out_reg = cache_generator_request_out;

cache_generator_request #(
  .NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR                      ),
  .FIFO_WRITE_DEPTH    (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
) inst_cache_generator_request (
  .ap_clk                  (ap_clk                                   ),
  .areset                  (areset_generator                         ),
  .request_in              (cache_generator_request_in               ),
  .fifo_request_signals_in (cache_generator_fifo_request_signals_in  ),
  .fifo_request_signals_out(cache_generator_fifo_request_signals_out ),
  .arbiter_request_in      (cache_generator_arbiter_request_in       ),
  .arbiter_grant_out       (cache_generator_arbiter_grant_out        ),
  .request_out             (cache_generator_request_out              ),
  .fifo_setup_signal       (cache_generator_fifo_request_setup_signal)
);

// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
assign cache_generator_response_in = response_in_reg;

cache_generator_response #(
  .NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR                      ),
  .FIFO_WRITE_DEPTH    (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
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
// Assign Kernel Cache <-> CU Signals
// --------------------------------------------------------------------------------------
// cu_cache
assign cu_cache_request_in                     = kernel_cu_request_out;
assign cu_cache_fifo_request_signals_in.rd_en  = ~(kernel_cu_fifo_response_signals_out.prog_full);
assign cu_cache_fifo_response_signals_in.rd_en = ~(kernel_cu_fifo_response_signals_out.prog_full);

// kernel_cu
assign kernel_cu_response_in                    = cu_cache_response_out;
assign kernel_cu_fifo_request_signals_in.rd_en  = ~(cu_cache_fifo_request_signals_out.prog_full | cu_cache_fifo_response_signals_out.prog_full);
assign kernel_cu_fifo_response_signals_in.rd_en = 0;

// --------------------------------------------------------------------------------------
generate
  if(GLOBAL_CU_CACHE_IP == 1) begin
// --------------------------------------------------------------------------------------
// CU Cache -> AXI Kernel Cache
    cu_cache inst_cu_cache (
      .ap_clk                   (ap_clk                            ),
      .areset                   (areset_cache                      ),
      .request_in               (cu_cache_request_in               ),
      .fifo_request_signals_out (cu_cache_fifo_request_signals_out ),
      .fifo_request_signals_in  (cu_cache_fifo_request_signals_in  ),
      .response_out             (cu_cache_response_out             ),
      .fifo_response_signals_out(cu_cache_fifo_response_signals_out),
      .fifo_response_signals_in (cu_cache_fifo_response_signals_in ),
      .fifo_setup_signal        (cu_cache_fifo_setup_signal        ),
      .m_axi_read_in            (cu_cache_m_axi_read_in            ),
      .m_axi_read_out           (cu_cache_m_axi_read_out           ),
      .m_axi_write_in           (cu_cache_m_axi_write_in           ),
      .m_axi_write_out          (cu_cache_m_axi_write_out          ),
      .done_out                 (cu_cache_done_out                 )
    );
  end else begin
// CU BUFFER -> AXI Kernel Cache
    cu_buffer inst_cu_buffer (
      .ap_clk                   (ap_clk                            ),
      .areset                   (areset_cache                      ),
      .request_in               (cu_cache_request_in               ),
      .fifo_request_signals_out (cu_cache_fifo_request_signals_out ),
      .fifo_request_signals_in  (cu_cache_fifo_request_signals_in  ),
      .response_out             (cu_cache_response_out             ),
      .fifo_response_signals_out(cu_cache_fifo_response_signals_out),
      .fifo_response_signals_in (cu_cache_fifo_response_signals_in ),
      .fifo_setup_signal        (cu_cache_fifo_setup_signal        ),
      .m_axi_read_in            (cu_cache_m_axi_read_in            ),
      .m_axi_read_out           (cu_cache_m_axi_read_out           ),
      .m_axi_write_in           (cu_cache_m_axi_write_in           ),
      .m_axi_write_out          (cu_cache_m_axi_write_out          ),
      .done_out                 (cu_cache_done_out                 )
    );
  end
// --------------------------------------------------------------------------------------
endgenerate
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// CU CACHE (M->S) Register Slice
// --------------------------------------------------------------------------------------
axi_register_slice_mid_end inst_axi_register_slice_mid (
  .ap_clk         (ap_clk                  ),
  .areset         (areset_axi_slice        ),
  .s_axi_read_out (cu_cache_m_axi_read_in  ),
  .s_axi_read_in  (cu_cache_m_axi_read_out ),
  .s_axi_write_out(cu_cache_m_axi_write_in ),
  .s_axi_write_in (cu_cache_m_axi_write_out),
  .m_axi_read_in  (m_axi_read_in           ),
  .m_axi_read_out (m_axi_read_out          ),
  .m_axi_write_in (m_axi_write_in          ),
  .m_axi_write_out(m_axi_write_out         )
);

// --------------------------------------------------------------------------------------
// Initial setup and configuration reading
// --------------------------------------------------------------------------------------
cu_setup #(
  .ID_CU    ({CU_KERNEL_COUNT_WIDTH_BITS{1'b1}}),
  .ID_BUNDLE({CU_BUNDLE_COUNT_WIDTH_BITS{1'b1}}),
  .ID_LANE  ({CU_LANE_COUNT_WIDTH_BITS{1'b1}}  )
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
  .ap_clk                             (ap_clk                              ),
  .areset                             (areset_bundles                      ),
  .descriptor_in                      (cu_bundles_descriptor               ),
  .response_memory_in                 (cu_bundles_response_in              ),
  .fifo_response_memory_in_signals_in (cu_bundles_fifo_response_signals_in ),
  .fifo_response_memory_in_signals_out(cu_bundles_fifo_response_signals_out),
  .request_memory_out                 (cu_bundles_request_out              ),
  .fifo_request_memory_out_signals_in (cu_bundles_fifo_request_signals_in  ),
  .fifo_request_memory_out_signals_out(cu_bundles_fifo_request_signals_out ),
  .fifo_setup_signal                  (cu_bundles_fifo_setup_signal        ),
  .done_out                           (cu_bundles_done_out                 )
);

// --------------------------------------------------------------------------------------
// Make sure done signal is asserted for N cycles
// --------------------------------------------------------------------------------------
assign cu_bundles_done_assert = &cu_bundles_done_hold;

always_ff @(posedge ap_clk) begin
  if (areset_bundles) begin
    cu_bundles_done_hold <= 0;
  end else begin
    cu_bundles_done_hold <= {cu_bundles_done_hold[PULSE_HOLD-2:0],(cu_bundles_done_out & cu_cache_done_out & fifo_empty_reg)};
  end
end

assign cu_setup_done_assert = &cu_setup_done_hold;

always_ff @(posedge ap_clk) begin
  if (areset_bundles) begin
    cu_setup_done_hold <= 0;
  end else begin
    cu_setup_done_hold <= {cu_setup_done_hold[PULSE_HOLD-2:0],(cu_setup_done_out & cu_cache_done_out & fifo_empty_reg)};
  end
end

endmodule : kernel_cu
