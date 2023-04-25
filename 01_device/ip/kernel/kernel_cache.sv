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
  output FIFOStateSignalsOutput         fifo_request_signals_out ,
  input  FIFOStateSignalsInput          fifo_request_signals_in  ,
  output CacheResponse                  kernel_cache_response_out,
  output FIFOStateSignalsOutput         fifo_response_signals_out,
  input  FIFOStateSignalsInput          fifo_response_signals_in ,
  input  AXI4MasterReadInterfaceInput   m_axi_read_in            ,
  output AXI4MasterReadInterfaceOutput  m_axi_read_out           ,
  input  AXI4MasterWriteInterfaceInput  m_axi_write_in           ,
  output AXI4MasterWriteInterfaceOutput m_axi_write_out          ,
  output logic                          fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
//
  logic areset_m_axi   ;
  logic areset_fifo    ;
  logic areset_arbiter ;
  logic areset_setup   ;
  logic areset_L2_cache;

  CacheRequest  kernel_cache_request_reg ;
  CacheResponse kernel_cache_response_reg;

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
// Cache response FIFO
// --------------------------------------------------------------------------------------
  CacheResponsePayload   fifo_response_din            ;
  CacheResponsePayload   fifo_response_dout           ;
  FIFOStateSignalsOutput fifo_response_signals_out_reg;
  FIFOStateSignalsInput  fifo_response_signals_in_reg ;

// --------------------------------------------------------------------------------------
// Cache request FIFO
// --------------------------------------------------------------------------------------
  CacheResponsePayload   fifo_request_din            ;
  CacheResponsePayload   fifo_request_dout           ;
  FIFOStateSignalsOutput fifo_request_signals_out_reg;
  FIFOStateSignalsInput  fifo_request_signals_in_reg ;

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
// Drive input
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      kernel_cache_request_reg.valid <= 1'b0;
    end
    else begin
      kernel_cache_request_reg.valid <= kernel_cache_request_in.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    kernel_cache_request_reg.payload <= kernel_cache_request_in.payload;
  end
// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_setup_signal               <= 1'b1;
      fifo_request_signals_out        <= 0;
      fifo_response_signals_out       <= 0;
      kernel_cache_response_out.valid <= 1'b0;
    end
    else begin
      fifo_setup_signal               <= fifo_request_setup_signal | fifo_response_setup_signal;
      fifo_request_signals_out        <= fifo_request_signals_reg;
      fifo_response_signals_out       <= fifo_response_signals_reg;
      kernel_cache_response_out.valid <= kernel_cache_response_reg.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    kernel_cache_response_out.payload <= kernel_cache_response_reg.payload;
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
  assign L2_cache_ctrl_in.force_inv = 1'b0;
  assign L2_cache_ctrl_in.wtb_empty = 1'b1;

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
  CacheResponsePayload   fifo_request_din            ;
  CacheResponsePayload   fifo_request_dout           ;
  FIFOStateSignalsOutput fifo_request_signals_out_reg;
  FIFOStateSignalsInput  fifo_request_signals_in_reg ;

  assign fifo_request_setup_signal = fifo_request_signals_out_reg.wr_rst_busy | fifo_request_signals_out_reg.rd_rst_busy;
  fifo_request_signals_in_reg.wr_en = fifo_request_din.valid;

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
  CacheResponsePayload   fifo_response_din            ;
  CacheResponsePayload   fifo_response_dout           ;
  FIFOStateSignalsOutput fifo_response_signals_out_reg;
  FIFOStateSignalsInput  fifo_response_signals_in_reg ;


  assign fifo_response_setup_signal = fifo_response_signals_out_reg.wr_rst_busy | fifo_response_signals_out_reg.rd_rst_busy;
  fifo_response_signals_in_reg.wr_en = fifo_response_din.valid;

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
