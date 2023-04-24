// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_cache.sv
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

module kernel_cache #(
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
  logic areset_m_axi   ;
  logic areset_control ;
  logic areset_fifo    ;
  logic areset_arbiter ;
  logic areset_setup   ;
  logic areset_L2_cache;
  logic areset_L1_cache;

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
  CacheRequest         L1_cache_request_in ;
  CacheRequestIOB      L1_cache_request_mem;
  CacheRequestIOB      L1_cache_request_end;
  CacheControlIOBInput L1_cache_ctrl_in    ;
  CacheControlIOBInput L1_cache_ctrl_out   ;

  CacheResponseIOB      L2_cache_response_mem;
  CacheControlIOBOutput L2_cache_ctrl_in     ;
  CacheControlIOBOutput L2_cache_ctrl_out    ;
// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
  CacheResponse          L1_cache_response_out                                              ;
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
    areset_m_axi    <= areset;
    areset_control  <= areset;
    areset_L2_cache <= areset;
    areset_L1_cache <= areset;
    areset_fifo     <= areset;
    areset_arbiter  <= areset;
    areset_setup    <= areset;
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
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_m_axi) begin
      m_axi_write.in <= 0;
    end
    else begin
      m_axi_write.in <= m_axi_write_in;
    end
  end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_m_axi) begin
      m_axi_read.in <= 0;
    end
    else begin
      m_axi_read.in <= m_axi_read_in;
    end
  end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_m_axi) begin
      m_axi_write_out <= 0;
    end
    else begin
      m_axi_write_out <= m_axi_write.out;
    end
  end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_m_axi) begin
      m_axi_read_out <= 0;
    end
    else begin
      m_axi_read_out <= m_axi_read.out;
    end
  end

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
// Cache L1 <-> L2 Pipeline logic
// --------------------------------------------------------------------------------------
  localparam DEPTH = 8;

  CacheRequestIOB   L1_cache_request_S      [0:DEPTH-1];
  CacheResponseIOB  L2_cache_response_S     [0:DEPTH-1];
  logic [DEPTH-1:0] L1_cache_request_pending           ;

  assign L1_cache_request_S[0].addr  = L1_cache_request_mem.addr ;
  assign L1_cache_request_S[0].wdata = L1_cache_request_mem.wdata;
  assign L1_cache_request_S[0].wstrb = L1_cache_request_mem.wstrb;
  assign L1_cache_request_S[0].valid = L1_cache_request_mem.valid & ~(|L1_cache_request_pending);

  assign L2_cache_response_S[0]      = L2_cache_response_mem;
  assign L1_cache_request_pending[0] = L2_cache_response_S[0].ready;

  always_ff @(posedge ap_clk ) begin
    if (areset_setup) begin
      for (int i = 0; i < DEPTH; i++) begin
        L1_cache_request_S[i].valid <= 0;
        L1_cache_request_pending[i] <= 0;
      end
    end
    else begin
      for (int i = 1; i < DEPTH; i++) begin
        if(|L1_cache_request_pending) begin
          L1_cache_request_S[i].valid <= 0;
          L1_cache_request_pending[i] <= L1_cache_request_pending[i-1];
        end else begin
          L1_cache_request_S[i].valid <= L1_cache_request_S[i-1].valid & ~(|L1_cache_request_pending);
          L1_cache_request_pending[i] <= 0;
        end
      end
    end
  end

  always_ff @(posedge ap_clk ) begin
    for (int i = 1; i < DEPTH; i++) begin
      L1_cache_request_S[i].addr <= L1_cache_request_S[i-1].addr;
      L1_cache_request_S[i].wdata<= L1_cache_request_S[i-1].wdata;
      L1_cache_request_S[i].wstrb<= L1_cache_request_S[i-1].wstrb;
      L2_cache_response_S[i] <= L2_cache_response_S[i-1];
    end
  end

  assign L1_cache_request_end.addr  = L1_cache_request_S[DEPTH-1].addr;
  assign L1_cache_request_end.wdata = L1_cache_request_S[DEPTH-1].wdata;
  assign L1_cache_request_end.wstrb = L1_cache_request_S[DEPTH-1].wstrb;
  assign L1_cache_request_end.valid = L1_cache_request_S[DEPTH-1].valid & ~(|L1_cache_request_pending);

// --------------------------------------------------------------------------------------
// AXI port cache L1
// --------------------------------------------------------------------------------------
  assign L1_cache_ctrl_in.force_inv = 1'b0;
  assign L1_cache_ctrl_in.wtb_empty = L2_cache_ctrl_out.wtb_empty;

  iob_cache #(
    .CACHE_FRONTEND_ADDR_W(L1_CACHE_FRONTEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(L1_CACHE_FRONTEND_DATA_W),
    .CACHE_N_WAYS         (L1_CACHE_N_WAYS         ),
    .CACHE_LINE_OFF_W     (L1_CACHE_LINE_OFF_W     ),
    .CACHE_WORD_OFF_W     (L1_CACHE_WORD_OFF_W     ),
    .CACHE_WTBUF_DEPTH_W  (L1_CACHE_WTBUF_DEPTH_W  ),
    .CACHE_REP_POLICY     (L1_CACHE_REP_POLICY     ),
    .CACHE_NWAY_W         (L1_CACHE_NWAY_W         ),
    .CACHE_FRONTEND_NBYTES(L1_CACHE_FRONTEND_NBYTES),
    .CACHE_FRONTEND_BYTE_W(L1_CACHE_FRONTEND_BYTE_W),
    .CACHE_BACKEND_ADDR_W (L1_CACHE_BACKEND_ADDR_W ),
    .CACHE_BACKEND_DATA_W (L1_CACHE_BACKEND_DATA_W ),
    .CACHE_BACKEND_NBYTES (L1_CACHE_BACKEND_NBYTES ),
    .CACHE_BACKEND_BYTE_W (L1_CACHE_BACKEND_BYTE_W ),
    .CACHE_LINE2MEM_W     (L1_CACHE_LINE2MEM_W     ),
    .CACHE_WRITE_POL      (L1_CACHE_WRITE_POL      ),
    .CACHE_CTRL_CACHE     (L1_CACHE_CTRL_CACHE     ),
    .CACHE_CTRL_CNT       (L1_CACHE_CTRL_CNT       )
  ) inst_L1_cache_native (
    .ap_clk       (ap_clk                                 ),
    .reset        (areset_L1_cache                        ),
    .valid        (L1_cache_request_in.payload.iob.valid  ),
    .addr         (L1_cache_request_in.payload.iob.addr   ),
    .wdata        (L1_cache_request_in.payload.iob.wdata  ),
    .wstrb        (L1_cache_request_in.payload.iob.wstrb  ),
    .rdata        (L1_cache_response_out.payload.iob.rdata),
    .ready        (L1_cache_response_out.payload.iob.ready),
    `ifdef CTRL_IO
    .force_inv_in (L1_cache_ctrl_in.force_inv             ), // force 0
    .force_inv_out(L1_cache_ctrl_out.force_inv            ),
    .wtb_empty_in (L1_cache_ctrl_in.wtb_empty             ),
    .wtb_empty_out(L1_cache_ctrl_out.wtb_empty            ), // floating Z
    `endif
    .mem_valid    (L1_cache_request_mem.valid             ),
    .mem_addr     (L1_cache_request_mem.addr              ),
    .mem_wdata    (L1_cache_request_mem.wdata             ),
    .mem_wstrb    (L1_cache_request_mem.wstrb             ),
    .mem_rdata    (L2_cache_response_S[DEPTH-1].rdata     ),
    .mem_ready    (L2_cache_response_S[DEPTH-1].ready     )
  );

// --------------------------------------------------------------------------------------
// AXI port cache L2
// --------------------------------------------------------------------------------------

  logic invalidate     = L1_cache_ctrl_out.force_inv;
  logic invalidate_reg                              ;
  logic l2_valid       = L1_cache_request_end.valid ;

  assign L2_cache_ctrl_in.force_inv = invalidate_reg & ~l2_valid;
  assign L2_cache_ctrl_in.wtb_empty = 1'b1;

  always @(posedge ap_clk) begin
    if (areset_L2_cache)
      invalidate_reg <= 1'b0;
    else
      if (invalidate)
        invalidate_reg <= 1'b1;
    else
      if(~l2_valid)
        invalidate_reg <= 1'b0;
    else
      invalidate_reg <= invalidate_reg;
  end


  iob_cache_axi #(
    .CACHE_FRONTEND_ADDR_W(L1_CACHE_BACKEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(L1_CACHE_BACKEND_DATA_W),
    .CACHE_N_WAYS         (L2_CACHE_N_WAYS        ),
    .CACHE_LINE_OFF_W     (L2_CACHE_LINE_OFF_W    ),
    .CACHE_WORD_OFF_W     (L2_CACHE_WORD_OFF_W    ),
    .CACHE_WTBUF_DEPTH_W  (L2_CACHE_WTBUF_DEPTH_W ),
    .CACHE_REP_POLICY     (L2_CACHE_REP_POLICY    ),
    .CACHE_NWAY_W         (L2_CACHE_NWAY_W        ),
    .CACHE_FRONTEND_NBYTES(L1_CACHE_BACKEND_NBYTES),
    .CACHE_FRONTEND_BYTE_W(L1_CACHE_BACKEND_BYTE_W),
    .CACHE_BACKEND_ADDR_W (L2_CACHE_BACKEND_ADDR_W),
    .CACHE_BACKEND_DATA_W (L2_CACHE_BACKEND_DATA_W),
    .CACHE_BACKEND_NBYTES (L2_CACHE_BACKEND_NBYTES),
    .CACHE_BACKEND_BYTE_W (L2_CACHE_BACKEND_BYTE_W),
    .CACHE_LINE2MEM_W     (L2_CACHE_LINE2MEM_W    ),
    .CACHE_WRITE_POL      (L2_CACHE_WRITE_POL     ),
    .CACHE_CTRL_CACHE     (L2_CACHE_CTRL_CACHE    ),
    .CACHE_CTRL_CNT       (L2_CACHE_CTRL_CNT      ),
    .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W       ),
    .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W       ),
    .CACHE_AXI_ID_W       (CACHE_AXI_ID_W         ),
    .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W        ),
    .CACHE_AXI_ID         (CACHE_AXI_ID           ),
    .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W       ),
    .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W      ),
    .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W       ),
    .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W        ),
    .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W      ),
    .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W       )
  ) inst_L2_cache_axi (
    .valid        (L1_cache_request_S[DEPTH-1].valid),
    .addr         (L1_cache_request_S[DEPTH-1].addr ),
    .wdata        (L1_cache_request_S[DEPTH-1].wdata),
    .wstrb        (L1_cache_request_S[DEPTH-1].wstrb),
    .rdata        (L2_cache_response_mem.rdata      ),
    .ready        (L2_cache_response_mem.ready      ),
    `ifdef CTRL_IO
    .force_inv_in (L2_cache_ctrl_in.force_inv       ),
    .force_inv_out(L2_cache_ctrl_out.force_inv      ), // floating
    .wtb_empty_in (L2_cache_ctrl_in.wtb_empty       ),
    .wtb_empty_out(L2_cache_ctrl_out.wtb_empty      ),
    `endif
    `include "m_axi_portmap_glay.vh"
    .ap_clk       (ap_clk                           ),
    .reset        (areset_L2_cache                  )
  );

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
  assign L1_cache_response_out.valid            = L1_cache_response_out.payload.iob.ready;
  assign L1_cache_response_out.payload.meta     = L1_cache_request_in.payload.meta;
  assign L1_cache_response_out.payload.ctrl.out = L1_cache_ctrl_out;
  assign L1_cache_response_out.payload.ctrl.in  = L1_cache_ctrl_in;
  assign cache_fifo_response_signals_in.rd_en   = ~cache_fifo_response_signals_out.empty;

  cache_generator_response #(
    .NUM_GRAPH_CLUSTERS  (NUM_GRAPH_CLUSTERS  ),
    .NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR),
    .NUM_GRAPH_PE        (NUM_GRAPH_PE        )
  ) inst_cache_generator_response (
    .ap_clk                   (ap_clk                                    ),
    .areset                   (areset                                    ),
    .memory_response_out      (memory_response_out                       ),
    .cache_resp_in            (L1_cache_response_out                     ),
    .fifo_response_signals_in (cache_fifo_response_signals_in            ),
    .fifo_response_signals_out(cache_fifo_response_signals_out           ),
    .fifo_setup_signal        (cache_generator_response_fifo_setup_signal)
  );

// --------------------------------------------------------------------------------------
// Cache request FIFO
// --------------------------------------------------------------------------------------
  always_comb begin
    L1_cache_request_in                   = cache_request_out;
    L1_cache_request_in.payload.iob.valid = cache_request_out.valid & ~L1_cache_response_out.valid;
  end


  assign cache_memory_request_in[0] = kernel_setup_memory_request_out;
  assign cache_memory_request_in[1] = vertex_cu_memory_request_out;

  assign cache_response_ready = L1_cache_response_out.payload.iob.ready;
  // assign cache_request_out.payload.iob.valid = cache_request_out.payload.iob.valid | (cache_request_out.valid & ~L1_cache_response_out.valid);
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
    .cache_response_ready    (cache_response_ready                     ),
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

endmodule : kernel_cache
