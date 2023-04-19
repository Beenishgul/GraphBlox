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
  logic                          m_axi_areset                              ;
  logic                          control_areset                            ;
  logic                          cache_areset                              ;
  logic                          fifo_areset                               ;
  logic                          arbiter_areset                            ;
  logic                          setup_areset                              ;
  logic [NUM_GRAPH_CLUSTERS-1:0] cu_done_reg                               ;
  logic [ NUM_SETUP_MODULES-1:0] cu_setup_state                            ;
  logic                          cache_request_generator_fifo_setup_signal ;
  logic                          cache_response_generator_fifo_setup_signal;

  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;

  ControlChainInterfaceInput  control_in_reg    ;
  ControlChainInterfaceOutput control_out_reg   ;
  DescriptorInterface         descriptor_in_reg ;
  DescriptorInterface         descriptor_out_reg;


  logic [VERTEX_DATA_BITS-1:0] counter;

// --------------------------------------------------------------------------------------
//   AXI Cache FIFO signals
// --------------------------------------------------------------------------------------



  logic force_inv_in ;
  logic force_inv_out;
  logic wtb_empty_in ;
  logic wtb_empty_out;

  assign force_inv_in = 1'b0;
  assign wtb_empty_in = 1'b1;

// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
  FIFOStateSignalsOutput cache_resp_fifo_out_signals                          ;
  FIFOStateSignalsInput  cache_resp_fifo_in_signals                           ;
  MemoryPacket           mem_resp_out               [NUM_MEMORY_REQUESTOR-1:0];
  CacheResponse          cache_resp_fifo_dout                                 ;
  CacheResponse          cache_resp_fifo_din                                  ;
  CacheResponse          cache_resp_out                                       ;


// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
  FIFOStateSignalsOutput cache_req_fifo_out_signals                          ;
  FIFOStateSignalsInput  cache_req_fifo_in_signals                           ;
  MemoryPacket           mem_req_in                [NUM_MEMORY_REQUESTOR-1:0];
  CacheRequest           cache_req_out                                       ;
  logic                  cache_resp_ready                                    ;
  logic                  cache_req_out_valid                                 ;

// --------------------------------------------------------------------------------------
// Signals setup and configuration reading
// --------------------------------------------------------------------------------------
  ControlChainInterfaceOutput kernel_setup_control_state        ;
  DescriptorInterface         kernel_setup_descriptor           ;
  MemoryPacket                kernel_setup_mem_resp_in          ;
  FIFOStateSignalsOutput      kernel_setup_resp_fifo_out_signals;
  FIFOStateSignalsInput       kernel_setup_resp_fifo_in_signals ;
  MemoryPacket                kernel_setup_mem_req_out          ;
  FIFOStateSignalsOutput      kernel_setup_req_fifo_out_signals ;
  FIFOStateSignalsInput       kernel_setup_req_fifo_in_signals  ;
  logic                       kernel_setup_fifo_setup_signal    ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    m_axi_areset   <= areset;
    control_areset <= areset;
    cache_areset   <= areset;
    fifo_areset    <= areset;
    arbiter_areset <= areset;
    setup_areset   <= areset;
  end

// --------------------------------------------------------------------------------------
// Done Logic
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      counter     <= 0;
      cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
    end
    else begin
      if (descriptor_out_reg.valid) begin
        if(counter > 2000) begin
          cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b1}};
          counter     <= 0;
        end
        else begin
          counter <= counter + 1;
        end
      end else begin
        cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
        counter     <= 0;
      end
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      cu_setup_state <= {NUM_GRAPH_CLUSTERS{1'b1}};
    end
    else begin
      cu_setup_state[0] <= cache_request_generator_fifo_setup_signal;
      cu_setup_state[1] <= cache_response_generator_fifo_setup_signal;
      cu_setup_state[2] <= kernel_setup_fifo_setup_signal;
    end
  end

// --------------------------------------------------------------------------------------
// Control signals
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
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
    if (control_areset) begin
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
    .areset        (control_areset    ),
    .control_in    (control_in_reg    ),
    .control_out   (control_out_reg   ),
    .descriptor_in (descriptor_in_reg ),
    .descriptor_out(descriptor_out_reg)
  );

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
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
    if (m_axi_areset) begin
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
    if (m_axi_areset) begin
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
    if (m_axi_areset) begin
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
    if (control_areset) begin
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
// Drive Setup signals to other modules
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (setup_areset) begin
      kernel_setup_descriptor.valid <= 0;
    end
    else begin
      kernel_setup_descriptor.valid <= descriptor_out_reg.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    kernel_setup_descriptor.payload <= descriptor_out_reg.payload;
  end

// --------------------------------------------------------------------------------------
// AXI port cache
// --------------------------------------------------------------------------------------
  iob_cache_axi #(
    .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),
    .CACHE_N_WAYS         (CACHE_N_WAYS         ),
    .CACHE_LINE_OFF_W     (CACHE_LINE_OFF_W     ),
    .CACHE_WORD_OFF_W     (CACHE_WORD_OFF_W     ),
    .CACHE_WTBUF_DEPTH_W  (CACHE_WTBUF_DEPTH_W  ),
    .CACHE_REP_POLICY     (CACHE_REP_POLICY     ),
    .CACHE_NWAY_W         (CACHE_NWAY_W         ),
    .CACHE_FRONTEND_NBYTES(CACHE_FRONTEND_NBYTES),
    .CACHE_FRONTEND_BYTE_W(CACHE_FRONTEND_BYTE_W),
    .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W ),
    .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W ),
    .CACHE_BACKEND_NBYTES (CACHE_BACKEND_NBYTES ),
    .CACHE_BACKEND_BYTE_W (CACHE_BACKEND_BYTE_W ),
    .CACHE_LINE2MEM_W     (CACHE_LINE2MEM_W     ),
    .CACHE_WRITE_POL      (CACHE_WRITE_POL      ),
    .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W     ),
    .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W     ),
    .CACHE_AXI_ID_W       (CACHE_AXI_ID_W       ),
    .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W      ),
    .CACHE_AXI_ID         (CACHE_AXI_ID         ),
    .CACHE_CTRL_CACHE     (CACHE_CTRL_CACHE     ),
    .CACHE_CTRL_CNT       (CACHE_CTRL_CNT       ),
    .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W     ),
    .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W    ),
    .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W     ),
    .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W      ),
    .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W    ),
    .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W     )
  ) inst_cache_axi (
    .valid        (cache_req_out_valid             ),
    .addr         (cache_req_out.payload.iob.addr  ),
    .wdata        (cache_req_out.payload.iob.wdata ),
    .wstrb        (cache_req_out.payload.iob.wstrb ),
    .rdata        (cache_resp_out.payload.iob.rdata),
    .ready        (cache_resp_out.valid            ),
    .force_inv_in (force_inv_in                    ),
    .force_inv_out(force_inv_out                   ),
    .wtb_empty_in (wtb_empty_in                    ),
    .wtb_empty_out(wtb_empty_out                   ),
    `include "m_axi_portmap_glay.vh"
    .ap_clk       (ap_clk                          ),
    .reset        (cache_areset                    )
  );


// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
  cache_response_generator #(
    .NUM_GRAPH_CLUSTERS  (NUM_GRAPH_CLUSTERS  ),
    .NUM_MEMORY_REQUESTOR(NUM_MEMORY_REQUESTOR),
    .NUM_GRAPH_PE        (NUM_GRAPH_PE        )
  ) inst_cache_response_generator (
    .ap_clk                     (ap_clk                                    ),
    .areset                     (areset                                    ),
    .mem_resp_out               (mem_resp_out                              ),
    .cache_resp_in              (cache_resp_out                            ),
    .cache_resp_fifo_in_signals (cache_resp_fifo_in_signals                ),
    .cache_resp_fifo_out_signals(cache_resp_fifo_out_signals               ),
    .fifo_setup_signal          (cache_response_generator_fifo_setup_signal)
  );

// --------------------------------------------------------------------------------------
// Cache request generator
// --------------------------------------------------------------------------------------
  assign mem_req_in[0]       = kernel_setup_mem_req_out;
  assign mem_req_in[1]       = 0;
  assign cache_resp_ready    = cache_resp_out.valid;
  assign cache_req_out_valid = cache_req_out.valid & ~cache_resp_out.valid;

  cache_request_generator #(
    .NUM_GRAPH_CLUSTERS     (NUM_GRAPH_CLUSTERS  ),
    .NUM_MEMORY_REQUESTOR   (NUM_MEMORY_REQUESTOR),
    .NUM_GRAPH_PE           (NUM_GRAPH_PE        ),
    .OUTSTANDING_COUNTER_MAX(32                  )
  ) inst_cache_request_generator (
    .ap_clk                    (ap_clk                                   ),
    .areset                    (areset                                   ),
    .mem_req_in                (mem_req_in                               ),
    .cache_req_gen_out         (cache_req_out                            ),
    .cache_resp_ready          (cache_resp_ready                         ),
    .cache_req_fifo_in_signals (cache_req_fifo_in_signals                ),
    .cache_req_fifo_out_signals(cache_req_fifo_out_signals               ),
    .fifo_setup_signal         (cache_request_generator_fifo_setup_signal)
  );

// --------------------------------------------------------------------------------------
// Initial setup and configuration reading
// --------------------------------------------------------------------------------------
  assign kernel_setup_mem_resp_in               = cache_resp_fifo_dout;
  assign kernel_setup_req_fifo_in_signals.rd_en = ~kernel_setup_req_fifo_out_signals.empty & ~cache_req_fifo_out_signals.prog_full;

  kernel_setup #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_kernel_setup (
    .ap_clk                  (ap_clk                            ),
    .areset                  (setup_areset                      ),
    .control_state           (kernel_setup_control_state        ),
    .descriptor              (kernel_setup_descriptor           ),
    .setup_mem_resp_in       (kernel_setup_mem_resp_in          ),
    .resp_fifo_out_signals   (kernel_setup_resp_fifo_out_signals),
    .resp_fifo_in_signals    (kernel_setup_resp_fifo_in_signals ),
    .kernel_setup_mem_req_out(kernel_setup_mem_req_out          ),
    .req_fifo_out_signals    (kernel_setup_req_fifo_out_signals ),
    .req_fifo_in_signals     (kernel_setup_req_fifo_in_signals  ),
    .fifo_setup_signal       (kernel_setup_fifo_setup_signal    )
  );

endmodule : kernel_cu
