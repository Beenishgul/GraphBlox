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
  parameter NUM_SETUP_MODULES    = 3              ,
  parameter NUM_MEMORY_REQUESTOR = 2              ,
  parameter NUM_GRAPH_PE         = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                          ap_clk         ,
  input  logic                          areset         ,
  input  ControlChainInterfaceInput     control_in     ,
  output ControlChainInterfaceOutput    control_out    ,
  input  DescriptorInterface            descriptor     ,
  input  AXI4MasterReadInterfaceInput   m_axi_read_in  ,
  output AXI4MasterReadInterfaceOutput  m_axi_read_out ,
  input  AXI4MasterWriteInterfaceInput  m_axi_write_in ,
  output AXI4MasterWriteInterfaceOutput m_axi_write_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic areset_m_axi  ;
  logic areset_control;
  logic areset_fifo   ;
  logic areset_arbiter;
  logic areset_setup  ;
  logic areset_cache  ;
  logic areset_cache  ;

  logic [NUM_GRAPH_CLUSTERS-1:0] cu_done_reg   ;
  logic [  VERTEX_DATA_BITS-1:0] counter       ;
  logic [ NUM_SETUP_MODULES-1:0] cu_setup_state;

  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;

  ControlChainInterfaceInput  control_in_reg    ;
  ControlChainInterfaceOutput control_out_reg   ;
  DescriptorInterface         descriptor_in_reg ;
  DescriptorInterface         descriptor_out_reg;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
  CacheRequest         cache_request_in ;
  CacheRequestIOB      cache_request_mem;
  CacheRequestIOB      cache_request_end;
  CacheControlIOBInput cache_ctrl_in    ;
  CacheControlIOBInput cache_ctrl_out   ;

  CacheResponseIOB      cache_response_mem;
  CacheControlIOBOutput cache_ctrl_in     ;
  CacheControlIOBOutput cache_ctrl_out    ;
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
  CacheRequest                     cache_request_out                                                   ;
  FIFOStateSignalsOutput           cache_fifo_request_signals_out                                      ;
  FIFOStateSignalsInput            cache_fifo_request_signals_in                                       ;
  MemoryPacket                     cache_memory_request_in                   [NUM_MEMORY_REQUESTOR-1:0];
  logic [NUM_MEMORY_REQUESTOR-1:0] cache_arbiter_grant_out                                             ;
  logic [NUM_MEMORY_REQUESTOR-1:0] cache_arbiter_request_in                                            ;
  logic                            cache_response_ready                                                ;
  logic                            cache_request_out_valid                                             ;
  logic                            cache_generator_response_fifo_setup_signal                          ;

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
    areset_m_axi   <= areset;
    areset_control <= areset;
    areset_fifo    <= areset;
    areset_arbiter <= areset;
    areset_setup   <= areset;
  end

// --------------------------------------------------------------------------------------
// Done Logic
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      counter     <= 0;
      cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
    end
    else begin
      if (descriptor_out_reg.valid) begin
        if(counter >= (descriptor_out_reg.payload.auxiliary_2 -1)) begin
          cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b1}};
          counter     <= 0;
        end
        else begin
          if(kernel_setup_memory_response_in.valid) begin
            // $display("counter: %d >= %d", counter, descriptor_out_reg.payload.auxiliary_2);
            counter <= counter + 4;
          end
          else begin
            counter <= counter;
          end
        end
      end else begin
        cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
        counter     <= 0;
      end
    end
  end

  // always_ff @(posedge ap_clk) begin
  //   if (areset_control) begin
  //     counter     <= 0;
  //     cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
  //   end
  //   else begin
  //     if (descriptor_out_reg.valid) begin
  //       if(counter > 2000) begin
  //         cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b1}};
  //         counter     <= 0;
  //       end
  //       else begin
  //         counter <= counter + 1;
  //       end
  //     end else begin
  //       cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
  //       counter     <= 0;
  //     end
  //   end
  // end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      cu_setup_state <= {NUM_GRAPH_CLUSTERS{1'b1}};
    end
    else begin
      cu_setup_state[0] <= cache_generator_request_fifo_setup_signal;
      cu_setup_state[1] <= cache_generator_response_fifo_setup_signal;
      cu_setup_state[2] <= kernel_setup_fifo_setup_signal;
    end
  end

// --------------------------------------------------------------------------------------
// Control signals
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      control_in_reg.ap_start    <= 1'b0;
      control_in_reg.ap_continue <= 1'b0;
      control_in_reg.setup       <= 1'b1;
      control_in_reg.done        <= 1'b0;
    end
    else begin
      control_in_reg.ap_start    <= control_in.ap_start ;
      control_in_reg.ap_continue <= control_in.ap_continue;
      control_in_reg.setup       <= ~|cu_setup_state;
      control_in_reg.done        <= &cu_done_reg;
    end
  end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      control_out.ap_ready <= 1'b0;
      control_out.ap_done  <= 1'b0;
      control_out.ap_idle  <= 1'b1;
      control_out.start    <= 1'b0;
    end
    else begin
      control_out.ap_ready <= control_out_reg.ap_ready;
      control_out.ap_idle  <= control_out_reg.ap_idle;
      control_out.ap_done  <= control_out_reg.ap_done;
      control_out.start    <= control_out_reg.start;
    end
  end

  kernel_control #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_kernel_control (
    .ap_clk        (ap_clk            ),
    .areset        (areset_control    ),
    .control_in    (control_in_reg    ),
    .control_out   (control_out_reg   ),
    .descriptor_in (descriptor_in_reg ),
    .descriptor_out(descriptor_out_reg)
  );

// --------------------------------------------------------------------------------------
// READ Descriptor Control
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      descriptor_in_reg.valid <= 0;
    end
    else begin
      descriptor_in_reg.valid <= descriptor.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    descriptor_in_reg.payload <= descriptor.payload;
  end

// --------------------------------------------------------------------------------------
// Drive descriptor signals to other modules
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_setup) begin
      kernel_setup_descriptor.valid <= 0;
      vertex_cu_descriptor.valid    <= 0;
    end
    else begin
      kernel_setup_descriptor.valid <= descriptor_out_reg.valid;
      vertex_cu_descriptor.valid    <= descriptor_out_reg.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    kernel_setup_descriptor.payload <= descriptor_out_reg.payload;
    vertex_cu_descriptor.payload    <= descriptor_out_reg.payload;
  end

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
    .fifo_setup_signal        (cache_generator_response_fifo_setup_signal)
  );

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
  always_comb begin
    cache_request_in                   = cache_request_out;
    cache_request_in.payload.iob.valid = cache_request_out.valid & ~cache_response_out.valid;
  end

  assign cache_memory_request_in[0] = kernel_setup_memory_request_out;
  assign cache_memory_request_in[1] = vertex_cu_memory_request_out;

  assign cache_response_ready = cache_response_out.payload.iob.ready;
  // assign cache_request_out.payload.iob.valid = cache_request_out.payload.iob.valid | (cache_request_out.valid & ~cache_response_out.valid);
  assign cache_fifo_request_signals_in.rd_en = ~cache_fifo_response_signals_out.prog_full;

  cache_generator_request #(
    .NUM_GRAPH_CLUSTERS     (NUM_GRAPH_CLUSTERS  ),
    .NUM_MEMORY_REQUESTOR   (NUM_MEMORY_REQUESTOR),
    .NUM_GRAPH_PE           (NUM_GRAPH_PE        ),
    .OUTSTANDING_COUNTER_MAX(32                  )
  ) inst_cache_generator_request (
    .ap_clk                  (ap_clk                                   ),
    .areset                  (areset                                   ),
    .memory_request_in       (cache_memory_request_in                  ),
    .arbiter_request_in      (cache_arbiter_request_in                 ),
    .arbiter_grant_out       (cache_arbiter_grant_out                  ),
    .cache_request_out       (cache_request_out                        ),
    .fifo_request_signals_in (cache_fifo_request_signals_in            ),
    .fifo_request_signals_out(cache_fifo_request_signals_out           ),
    .fifo_setup_signal       (cache_generator_request_fifo_setup_signal)
  );

// --------------------------------------------------------------------------------------
// Initial setup and configuration reading
// --------------------------------------------------------------------------------------
  assign kernel_setup_memory_response_in            = memory_response_out[0];
  assign kernel_setup_fifo_request_signals_in.rd_en = cache_arbiter_grant_out[0];

  assign cache_arbiter_request_in[0] = ~kernel_setup_fifo_request_signals_out.empty & ~cache_fifo_request_signals_out.prog_full;

  kernel_setup #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_kernel_setup (
    .ap_clk                   (ap_clk                                ),
    .areset                   (areset_setup                          ),
    .control_state            (kernel_setup_control_state            ),
    .descriptor               (kernel_setup_descriptor               ),
    .memory_response_in       (kernel_setup_memory_response_in       ),
    .fifo_response_signals_out(kernel_setup_fifo_response_signals_out),
    .fifo_response_signals_in (kernel_setup_fifo_response_signals_in ),
    .memory_request_out       (kernel_setup_memory_request_out       ),
    .fifo_request_signals_out (kernel_setup_fifo_request_signals_out ),
    .fifo_request_signals_in  (kernel_setup_fifo_request_signals_in  ),
    .fifo_setup_signal        (kernel_setup_fifo_setup_signal        )
  );

// --------------------------------------------------------------------------------------
// Vertex CU
// --------------------------------------------------------------------------------------
  assign vertex_cu_memory_response_in            = memory_response_out[1];
  assign vertex_cu_fifo_request_signals_in.rd_en = cache_arbiter_grant_out[1];

  // assign cache_arbiter_request_in[1] = ~vertex_cu_fifo_request_signals_out.empty & ~cache_fifo_request_signals_out.prog_full ;
  assign cache_arbiter_request_in[1] = 0 ;

  vertex_cu #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_vertex_cu (
    .ap_clk                   (ap_clk                             ),
    .areset                   (areset_setup                       ),
    .control_state            (vertex_cu_control_state            ),
    .descriptor               (vertex_cu_descriptor               ),
    .memory_response_in       (vertex_cu_memory_response_in       ),
    .fifo_response_signals_out(vertex_cu_fifo_response_signals_out),
    .fifo_response_signals_in (vertex_cu_fifo_response_signals_in ),
    .memory_request_out       (vertex_cu_memory_request_out       ),
    .fifo_request_signals_out (vertex_cu_fifo_request_signals_out ),
    .fifo_request_signals_in  (vertex_cu_fifo_request_signals_in  ),
    .fifo_setup_signal        (vertex_cu_fifo_setup_signal        )
  );

endmodule : kernel_cu
