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
  input  logic                          ap_clk                   ,
  input  logic                          areset                   ,
  input  CacheRequest                   kernel_cache_request_in  ,
  output CacheResponse                  kernel_cache_response_out,
  input  AXI4MasterReadInterfaceInput   m_axi_read_in            ,
  output AXI4MasterReadInterfaceOutput  m_axi_read_out           ,
  input  AXI4MasterWriteInterfaceInput  m_axi_write_in           ,
  output AXI4MasterWriteInterfaceOutput m_axi_write_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic areset_m_axi   ;
  logic areset_fifo    ;
  logic areset_arbiter ;
  logic areset_setup   ;
  logic areset_L2_cache;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
  CacheRequestIOB       L2_cache_request_mem ;
  CacheResponseIOB      L2_cache_response_mem;
  CacheControlIOBOutput L2_cache_ctrl_in     ;
  CacheControlIOBOutput L2_cache_ctrl_out    ;
// --------------------------------------------------------------------------------------
// Cache response generator
// --------------------------------------------------------------------------------------
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
    areset_fifo    <= areset;
    areset_arbiter <= areset;
    areset_setup   <= areset;
  end

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
// AXI port cache
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
    .CACHE_FRONTEND_ADDR_W(L2_CACHE_FRONTEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(L2_CACHE_FRONTEND_DATA_W),
    .CACHE_N_WAYS         (L2_CACHE_N_WAYS         ),
    .CACHE_LINE_OFF_W     (L2_CACHE_LINE_OFF_W     ),
    .CACHE_WORD_OFF_W     (L2_CACHE_WORD_OFF_W     ),
    .CACHE_WTBUF_DEPTH_W  (L2_CACHE_WTBUF_DEPTH_W  ),
    .CACHE_REP_POLICY     (L2_CACHE_REP_POLICY     ),
    .CACHE_NWAY_W         (L2_CACHE_NWAY_W         ),
    .CACHE_FRONTEND_NBYTES(L2_CACHE_FRONTEND_NBYTES),
    .CACHE_FRONTEND_BYTE_W(L2_CACHE_FRONTEND_BYTE_W),
    .CACHE_BACKEND_ADDR_W (L2_CACHE_BACKEND_ADDR_W ),
    .CACHE_BACKEND_DATA_W (L2_CACHE_BACKEND_DATA_W ),
    .CACHE_BACKEND_NBYTES (L2_CACHE_BACKEND_NBYTES ),
    .CACHE_BACKEND_BYTE_W (L2_CACHE_BACKEND_BYTE_W ),
    .CACHE_LINE2MEM_W     (L2_CACHE_LINE2MEM_W     ),
    .CACHE_WRITE_POL      (L2_CACHE_WRITE_POL      ),
    .CACHE_CTRL_CACHE     (L2_CACHE_CTRL_CACHE     ),
    .CACHE_CTRL_CNT       (L2_CACHE_CTRL_CNT       ),
    .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W        ),
    .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W        ),
    .CACHE_AXI_ID_W       (CACHE_AXI_ID_W          ),
    .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W         ),
    .CACHE_AXI_ID         (CACHE_AXI_ID            ),
    .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W        ),
    .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W       ),
    .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W        ),
    .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W         ),
    .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W       ),
    .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W        )
  ) inst_L2_cache_axi (
    .valid        (L2_cache_request_mem.valid ),
    .addr         (L2_cache_request_mem.addr  ),
    .wdata        (L2_cache_request_mem.wdata ),
    .wstrb        (L2_cache_request_mem.wstrb ),
    .rdata        (L2_cache_response_mem.rdata),
    .ready        (L2_cache_response_mem.ready),
    `ifdef CTRL_IO
    .force_inv_in (L2_cache_ctrl_in.force_inv ),
    .force_inv_out(L2_cache_ctrl_out.force_inv), // floating
    .wtb_empty_in (L2_cache_ctrl_in.wtb_empty ),
    .wtb_empty_out(L2_cache_ctrl_out.wtb_empty),
    `endif
    `include "m_axi_portmap_glay.vh"
    .ap_clk       (ap_clk                     ),
    .reset        (areset_L2_cache            )
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

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(32                        ),
    .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
    .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
    .PROG_THRESH     (8                         ),
    .READ_MODE       ("fwft"                    )
  ) inst_fifo_CacheRequest (
    .clk         (ap_clk                                   ),
    .srst        (areset_fifo                              ),
    .din         (fifo_request_din                         ),
    .wr_en       (fifo_request_signals_in_reg.wr_en        ),
    .rd_en       (fifo_request_signals_in_reg.rd_en        ),
    .dout        (fifo_request_dout                        ),
    .full        (fifo_request_signals_out_reg.full        ),
    .almost_full (fifo_request_signals_out_reg.almost_full ),
    .empty       (fifo_request_signals_out_reg.empty       ),
    .almost_empty(fifo_request_signals_out_reg.almost_empty),
    .valid       (fifo_request_signals_out_reg.valid       ),
    .prog_full   (fifo_request_signals_out_reg.prog_full   ),
    .prog_empty  (fifo_request_signals_out_reg.prog_empty  ),
    .wr_rst_busy (fifo_request_signals_out_reg.wr_rst_busy ),
    .rd_rst_busy (fifo_request_signals_out_reg.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
  assign L1_cache_response_out.valid            = L1_cache_response_out.payload.iob.ready;
  assign L1_cache_response_out.payload.meta     = L1_cache_request_in.payload.meta;
  assign L1_cache_response_out.payload.ctrl.out = L1_cache_ctrl_out;
  assign L1_cache_response_out.payload.ctrl.in  = L1_cache_ctrl_in;
  assign cache_fifo_response_signals_in.rd_en   = ~cache_fifo_response_signals_out.empty;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(32                         ),
    .WRITE_DATA_WIDTH($bits(CacheResponsePayload)),
    .READ_DATA_WIDTH ($bits(CacheResponsePayload)),
    .PROG_THRESH     (8                          )
  ) inst_fifo_CacheResponse (
    .clk         (ap_clk                                    ),
    .srst        (areset_fifo                               ),
    .din         (fifo_response_din.payload                 ),
    .wr_en       (fifo_response_signals_in_reg.wr_en        ),
    .rd_en       (fifo_response_signals_in_reg.rd_en        ),
    .dout        (fifo_response_dout.payload                ),
    .full        (fifo_response_signals_out_reg.full        ),
    .almost_full (fifo_response_signals_out_reg.almost_full ),
    .empty       (fifo_response_signals_out_reg.empty       ),
    .almost_empty(fifo_response_signals_out_reg.almost_empty),
    .valid       (fifo_response_signals_out_reg.valid       ),
    .prog_full   (fifo_response_signals_out_reg.prog_full   ),
    .prog_empty  (fifo_response_signals_out_reg.prog_empty  ),
    .wr_rst_busy (fifo_response_signals_out_reg.wr_rst_busy ),
    .rd_rst_busy (fifo_response_signals_out_reg.rd_rst_busy )
  );



endmodule : kernel_cache
