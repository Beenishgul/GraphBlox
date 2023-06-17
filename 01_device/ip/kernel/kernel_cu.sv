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
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_CACHE::*;

module kernel_cu #(
  `include "kernel_parameters.vh"
  ) (
  input  logic                  ap_clk                   ,
  input  logic                  areset                   ,
  input  KernelDescriptor       descriptor_in            ,
  output CacheRequest           request_out              ,
  output FIFOStateSignalsOutput fifo_request_signals_out ,
  input  FIFOStateSignalsInput  fifo_request_signals_in  ,
  input  CacheResponse          response_in              ,
  output FIFOStateSignalsOutput fifo_response_signals_out,
  input  FIFOStateSignalsInput  fifo_response_signals_in ,
  output logic                  fifo_setup_signal        ,
  output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic areset_control  ;
  logic areset_generator;
  logic areset_setup    ;
  logic areset_bundles  ;

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
  KernelDescriptor       kernel_setup_descriptor               ;
  MemoryPacket           kernel_setup_response_in              ;
  FIFOStateSignalsOutput kernel_setup_fifo_response_signals_out;
  FIFOStateSignalsInput  kernel_setup_fifo_response_signals_in ;
  MemoryPacket           kernel_setup_request_out              ;
  FIFOStateSignalsOutput kernel_setup_fifo_request_signals_out ;
  FIFOStateSignalsInput  kernel_setup_fifo_request_signals_in  ;
  logic                  kernel_setup_fifo_setup_signal        ;

// --------------------------------------------------------------------------------------
// Signals for Vertex CU
// --------------------------------------------------------------------------------------
  KernelDescriptor       cu_bundles_descriptor               ;
  MemoryPacket           cu_bundles_response_in              ;
  FIFOStateSignalsOutput cu_bundles_fifo_response_signals_out;
  FIFOStateSignalsInput  cu_bundles_fifo_response_signals_in ;
  MemoryPacket           cu_bundles_request_out              ;
  FIFOStateSignalsOutput cu_bundles_fifo_request_signals_out ;
  FIFOStateSignalsInput  cu_bundles_fifo_request_signals_in  ;
  logic                  cu_bundles_fifo_setup_signal        ;
  logic                  cu_bundles_done_out                 ;


// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_control   <= areset;
    areset_setup     <= areset;
    areset_generator <= areset;
    areset_bundles   <= areset;
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
      fifo_response_signals_in_reg <= fifo_response_signals_in;
      fifo_request_signals_in_reg  <= fifo_request_signals_in;
      response_in_reg.valid        <= response_in.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    response_in_reg.payload <= response_in.payload;
  end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_setup_signal <= 1'b1;
      request_out.valid <= 1'b0;
      done_out          <= 1'b0;
    end
    else begin
      fifo_setup_signal <= cache_generator_fifo_request_setup_signal | cache_generator_fifo_response_setup_signal | kernel_setup_fifo_setup_signal | cu_bundles_fifo_setup_signal;
      request_out.valid <= request_out_reg.valid ;
      done_out          <= cu_bundles_done_out;
    end
  end

// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      descriptor_in_reg.valid       <= 0;
      kernel_setup_descriptor.valid <= 0;
      cu_bundles_descriptor.valid   <= 0;
    end
    else begin
      descriptor_in_reg.valid       <= descriptor_in.valid;
      kernel_setup_descriptor.valid <= descriptor_in_reg.valid;
      cu_bundles_descriptor.valid   <= descriptor_in_reg.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    descriptor_in_reg.payload       <= descriptor_in.payload;
    kernel_setup_descriptor.payload <= descriptor_in_reg.payload;
    cu_bundles_descriptor.payload   <= descriptor_in_reg.payload;
  end

// --------------------------------------------------------------------------------------
// Assign FIFO signals Requestor <-> Generator <-> Setup <-> CU
// --------------------------------------------------------------------------------------
  assign cache_generator_fifo_request_signals_in.rd_en  = ~cache_generator_fifo_response_signals_out.prog_full & fifo_request_signals_in_reg.rd_en;
  assign cache_generator_fifo_response_signals_in.rd_en = ~(kernel_setup_fifo_response_signals_out.prog_full|cu_bundles_fifo_response_signals_out.prog_full);

  assign kernel_setup_fifo_request_signals_in.rd_en  = ~cache_generator_fifo_request_signals_out.prog_full & fifo_request_signals_in_reg.rd_en & cache_generator_arbiter_grant_out[0];
  assign kernel_setup_fifo_response_signals_in.rd_en = 1;

  assign cu_bundles_fifo_request_signals_in.rd_en  = ~cache_generator_fifo_request_signals_out.prog_full & fifo_request_signals_in_reg.rd_en & cache_generator_arbiter_grant_out[1];
  assign cu_bundles_fifo_response_signals_in.rd_en = 1;

// --------------------------------------------------------------------------------------
// Arbiter Signals: Cache Request Generator
// --------------------------------------------------------------------------------------
  // kernel_setup
  assign kernel_setup_response_in              = cache_generator_response_out[0];
  assign cache_generator_request_in[0]         = kernel_setup_request_out;
  assign cache_generator_arbiter_request_in[0] = ~kernel_setup_fifo_request_signals_out.empty & ~cache_generator_fifo_request_signals_out.prog_full;

  // vertex_cu
  assign cu_bundles_response_in                = cache_generator_response_out[1];
  assign cache_generator_request_in[1]         = cu_bundles_request_out;
  assign cache_generator_arbiter_request_in[1] = ~cu_bundles_fifo_request_signals_out.empty & ~cache_generator_fifo_request_signals_out.prog_full ;

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
  assign request_out_reg = cache_generator_request_out;

  cache_generator_request #(.NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR)) inst_cache_generator_request (
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

  cache_generator_response #(.NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR)) inst_cache_generator_response (
    .ap_clk                   (ap_clk                                    ),
    .areset                   (areset_generator                          ),
    .response_in              (cache_generator_response_in               ),
    .fifo_response_signals_in (cache_generator_fifo_response_signals_in  ),
    .fifo_response_signals_out(cache_generator_fifo_response_signals_out ),
    .response_out             (cache_generator_response_out              ),
    .fifo_setup_signal        (cache_generator_fifo_response_setup_signal)
  );

// --------------------------------------------------------------------------------------
// Initial setup and configuration reading
// --------------------------------------------------------------------------------------
  kernel_setup #(
    .ID_CU    ({KERNEL_CU_COUNT_WIDTH_BITS{1'b1}}),
    .ID_BUNDLE({CU_BUNDLE_COUNT_WIDTH_BITS{1'b1}}),
    .ID_LANE  ({CU_LANE_COUNT_WIDTH_BITS{1'b1}}  )
  ) inst_kernel_setup (
    .ap_clk                   (ap_clk                                ),
    .areset                   (areset_setup                          ),
    .descriptor_in            (kernel_setup_descriptor               ),
    .response_in              (kernel_setup_response_in              ),
    .fifo_response_signals_in (kernel_setup_fifo_response_signals_in ),
    .fifo_response_signals_out(kernel_setup_fifo_response_signals_out),
    .request_out              (kernel_setup_request_out              ),
    .fifo_request_signals_in  (kernel_setup_fifo_request_signals_in  ),
    .fifo_request_signals_out (kernel_setup_fifo_request_signals_out ),
    .fifo_setup_signal        (kernel_setup_fifo_setup_signal        )
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

endmodule : kernel_cu
