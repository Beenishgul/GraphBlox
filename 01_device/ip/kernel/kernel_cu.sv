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
  parameter NUM_GRAPH_CLUSTERS   = CU_COUNT_GLOBAL,
  parameter NUM_SETUP_MODULES    = 4              ,
  parameter NUM_MEMORY_REQUESTOR = 2              ,
  parameter NUM_GRAPH_PE         = CU_COUNT_LOCAL
) (
  input  logic                  ap_clk                   ,
  input  logic                  areset                   ,
  input  DescriptorInterface    descriptor_in            ,
  output CacheRequest           request_out              ,
  output FIFOStateSignalsOutput fifo_request_signals_out ,
  input  FIFOStateSignalsInput  fifo_request_signals_in  ,
  input  CacheResponse          response_in              ,
  output FIFOStateSignalsOutput fifo_response_signals_out,
  input  FIFOStateSignalsInput  fifo_response_signals_in ,
  output logic                  done_signal              ,
  output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic areset_control  ;
  logic areset_generator;
  logic areset_setup    ;
  logic areset_cu       ;

  logic [NUM_GRAPH_CLUSTERS-1:0] done_signal_reg  ;
  logic [  VERTEX_DATA_BITS-1:0] counter          ;
  logic [ NUM_SETUP_MODULES-1:0] cu_setup_state   ;
  DescriptorInterface            descriptor_in_reg;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
  CacheRequest cache_request_in;

// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
  CacheResponse          cache_response_out                                                 ;
  FIFOStateSignalsOutput cache_fifo_response_signals_out                                    ;
  FIFOStateSignalsInput  cache_fifo_response_signals_in                                     ;
  MemoryPacket           memory_response_out                      [NUM_MEMORY_REQUESTOR-1:0];
  logic                  cache_generator_request_fifo_setup_signal                          ;

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
  ControlChainInterfaceOutput kernel_setup_control_state            ;
  DescriptorInterface         kernel_setup_descriptor               ;
  MemoryPacket                kernel_setup_memory_response_in       ;
  FIFOStateSignalsOutput      kernel_setup_fifo_response_signals_out;
  FIFOStateSignalsInput       kernel_setup_fifo_response_signals_in ;
  MemoryPacket                kernel_setup_memory_request_out       ;
  FIFOStateSignalsOutput      kernel_setup_fifo_request_signals_out ;
  FIFOStateSignalsInput       kernel_setup_fifo_request_signals_in  ;
  logic                       kernel_setup_fifo_setup_signal        ;

// --------------------------------------------------------------------------------------
// Signals for Vertex CU
// --------------------------------------------------------------------------------------
  ControlChainInterfaceOutput vertex_cu_control_state            ;
  DescriptorInterface         vertex_cu_descriptor               ;
  MemoryPacket                vertex_cu_memory_response_in       ;
  FIFOStateSignalsOutput      vertex_cu_fifo_response_signals_out;
  FIFOStateSignalsInput       vertex_cu_fifo_response_signals_in ;
  MemoryPacket                vertex_cu_memory_request_out       ;
  FIFOStateSignalsOutput      vertex_cu_fifo_request_signals_out ;
  FIFOStateSignalsInput       vertex_cu_fifo_request_signals_in  ;
  logic                       vertex_cu_fifo_setup_signal        ;


// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_control   <= areset;
    areset_setup     <= areset;
    areset_generator <= areset;
    areset_cu        <= areset;
  end

// --------------------------------------------------------------------------------------
// Done Logic (DUMMY)
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      counter         <= 0;
      done_signal_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
    end
    else begin
      if (descriptor_in_reg.valid) begin
        if(counter >= (descriptor_in_reg.payload.auxiliary_2 -1)) begin
          done_signal_reg <= {NUM_GRAPH_CLUSTERS{1'b1}};
          counter         <= 0;
        end
        else begin
          if(kernel_setup_memory_response_in.valid) begin
            counter <= counter + 4;
          end
          else begin
            counter <= counter;
          end
        end
      end else begin
        done_signal_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
        counter         <= 0;
      end
    end
  end

// --------------------------------------------------------------------------------------
// Control signals
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      cu_setup_state <= {NUM_GRAPH_CLUSTERS{1'b1}};
    end
    else begin
      cu_setup_state[0] <= cache_generator_fifo_request_setup_signal;
      cu_setup_state[1] <= cache_generator_fifo_response_setup_signal;
      cu_setup_state[2] <= kernel_setup_fifo_setup_signal;
      cu_setup_state[3] <= vertex_cu_fifo_setup_signal;
    end
  end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_setup_signal <= 1'b1;
      done_signal       <= 1'b0;
    end
    else begin
      fifo_setup_signal <= ~|cu_setup_state;
      done_signal       <= &done_signal_reg;
    end
  end

// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_setup) begin
      descriptor_in_reg.valid       <= 0;
      kernel_setup_descriptor.valid <= 0;
      vertex_cu_descriptor.valid    <= 0;
    end
    else begin
      descriptor_in_reg.valid       <= descriptor_in.valid;
      kernel_setup_descriptor.valid <= descriptor_in_reg.valid;
      vertex_cu_descriptor.valid    <= descriptor_in_reg.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    descriptor_in_reg.payload       <= descriptor_in.payload;
    kernel_setup_descriptor.payload <= descriptor_in_reg.payload;
    vertex_cu_descriptor.payload    <= descriptor_in_reg.payload;
  end

// --------------------------------------------------------------------------------------
// Assign FIFO signals Requestor <-> Generator <-> Setup <-> CU
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Arbiter Signals: Cache Request Generator
// --------------------------------------------------------------------------------------
  // kernel_setup
  assign kernel_setup_memory_response_in            = memory_response_out[0];
  assign kernel_setup_fifo_request_signals_in.rd_en = cache_generator_arbiter_grant_out[0];
  assign cache_generator_request_in[0]              = kernel_setup_memory_request_out;
  assign cache_arbiter_request_in[0]                = ~kernel_setup_fifo_request_signals_out.empty & ~cache_generator_fifo_request_signals_out.prog_full;

  // vertex_cu
  assign vertex_cu_memory_response_in            = memory_response_out[1];
  assign vertex_cu_fifo_request_signals_in.rd_en = cache_generator_arbiter_grant_out[1];
  assign cache_generator_request_in[1]           = vertex_cu_memory_request_out;
  assign cache_arbiter_request_in[1]             = ~vertex_cu_fifo_request_signals_out.empty & ~cache_generator_fifo_request_signals_out.prog_full ;

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
  always_comb begin
    cache_request_in                   = cache_generator_request_out;
    cache_request_in.payload.iob.valid = cache_generator_request_out.valid & ~cache_response_out.valid;
  end

  // assign cache_generator_request_out.payload.iob.valid = cache_generator_request_out.payload.iob.valid | (cache_generator_request_out.valid & ~cache_response_out.valid);
  assign cache_generator_fifo_request_signals_in.rd_en = ~cache_fifo_response_signals_out.prog_full;

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
  assign cache_response_out.valid             = cache_response_out.payload.iob.ready;
  assign cache_response_out.payload.meta      = cache_request_in.payload.meta;
  assign cache_fifo_response_signals_in.rd_en = ~cache_fifo_response_signals_out.empty;

  cache_generator_response #(
    .NUM_GRAPH_CLUSTERS  (NUM_GRAPH_CLUSTERS  ),
    .NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR),
    .NUM_GRAPH_PE        (NUM_GRAPH_PE        )
  ) inst_cache_generator_response (
    .ap_clk                   (ap_clk                                    ),
    .areset                   (areset                                    ),
    .memory_response_out      (memory_response_out                       ),
    .cache_resp_in            (cache_response_out                        ),
    .fifo_response_signals_in (cache_fifo_response_signals_in            ),
    .fifo_response_signals_out(cache_fifo_response_signals_out           ),
    .fifo_setup_signal        (cache_generator_fifo_response_setup_signal)
  );


  CacheResponse          cache_generator_response_in                                         ;
  FIFOStateSignalsInput  cache_generator_fifo_response_signals_in                            ;
  FIFOStateSignalsOutput cache_generator_fifo_response_signals_out                           ;
  MemoryPacket           cache_generator_response_out              [NUM_MEMORY_REQUESTOR-1:0];
  logic                  cache_generator_fifo_response_setup_signal                          ;


  cache_generator_response #(.NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR)) inst_cache_generator_response (
    .ap_clk                   (ap_clk                                   ),
    .areset                   (areset                                   ),
    .response_in              (cache_generator_response_in              ),
    .fifo_response_signals_in (cache_generator_fifo_response_signals_in ),
    .fifo_response_signals_out(cache_generator_fifo_response_signals_out),
    .response_out             (response_out                             ),
    .fifo_setup_signal        (fifo_setup_signal                        )
  );


// --------------------------------------------------------------------------------------
// Initial setup and configuration reading
// --------------------------------------------------------------------------------------
  kernel_setup #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_kernel_setup (
    .ap_clk                   (ap_clk                                ),
    .areset                   (areset_setup                          ),
    .control_state            (kernel_setup_control_state            ),
    .descriptor_in               (kernel_setup_descriptor               ),
    .memory_response_in       (kernel_setup_memory_response_in       ),
    .fifo_response_signals_in (kernel_setup_fifo_response_signals_in ),
    .fifo_response_signals_out(kernel_setup_fifo_response_signals_out),
    .memory_request_out       (kernel_setup_memory_request_out       ),
    .fifo_request_signals_in  (kernel_setup_fifo_request_signals_in  ),
    .fifo_request_signals_out (kernel_setup_fifo_request_signals_out ),
    .fifo_setup_signal        (kernel_setup_fifo_setup_signal        )
  );

// --------------------------------------------------------------------------------------
// Vertex CU
// --------------------------------------------------------------------------------------
  vertex_cu #() inst_vertex_cu (
    .ap_clk                   (ap_clk                             ),
    .areset                   (areset_cu                          ),
    .control_state            (vertex_cu_control_state            ),
    .descriptor_in               (vertex_cu_descriptor               ),
    .memory_response_in       (vertex_cu_memory_response_in       ),
    .fifo_response_signals_in (vertex_cu_fifo_response_signals_in ),
    .fifo_response_signals_out(vertex_cu_fifo_response_signals_out),
    .memory_request_out       (vertex_cu_memory_request_out       ),
    .fifo_request_signals_in  (vertex_cu_fifo_request_signals_in  ),
    .fifo_request_signals_out (vertex_cu_fifo_request_signals_out ),
    .fifo_setup_signal        (vertex_cu_fifo_setup_signal        )
  );

endmodule : kernel_cu
