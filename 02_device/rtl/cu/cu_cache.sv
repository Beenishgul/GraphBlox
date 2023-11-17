// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cu_cache.sv
// Create : 2023-06-13 23:21:43
// Revise : 2023-08-28 18:21:31
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_CACHE::*;
import PKG_MEMORY::*;


module cu_cache #(
  parameter FIFO_WRITE_DEPTH = 32,
  parameter PROG_THRESH      = 16
) (
  // System Signals
  input  logic                          ap_clk                   ,
  input  logic                          areset                   ,
  input  CacheRequest                   request_in               ,
  output FIFOStateSignalsOutput         fifo_request_signals_out ,
  input  FIFOStateSignalsInput          fifo_request_signals_in  ,
  output CacheResponse                  response_out             ,
  output FIFOStateSignalsOutput         fifo_response_signals_out,
  input  FIFOStateSignalsInput          fifo_response_signals_in ,
  output logic                          fifo_setup_signal        ,
  input  AXI4MasterReadInterfaceInput   m_axi_read_in            ,
  output AXI4MasterReadInterfaceOutput  m_axi_read_out           ,
  input  AXI4MasterWriteInterfaceInput  m_axi_write_in           ,
  output AXI4MasterWriteInterfaceOutput m_axi_write_out          ,
  output logic                          done_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
  logic areset_m_axi  ;
  logic areset_fifo   ;
  logic areset_arbiter;
  logic areset_setup  ;
  logic areset_cache  ;
  logic areset_control;

  CacheRequest  request_in_reg ;
  CacheResponse response_in_int;

  logic fifo_empty_int;
  logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
  CacheRequestPayload   cache_request_mem ;
  CacheResponsePayload  cache_response_mem;
  CacheControlIOBOutput cache_ctrl_in     ;
  CacheControlIOBOutput cache_ctrl_out    ;
  // logic                 invalidate        ;
  // logic                 invalidate_reg    ;
  // logic                 l1_avalid         ;

// --------------------------------------------------------------------------------------
// Cache request FIFO
// --------------------------------------------------------------------------------------
  CacheRequestPayload    fifo_request_din             ;
  CacheRequestPayload    fifo_request_dout            ;
  FIFOStateSignalsOutput fifo_request_signals_out_int ;
  FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
  FIFOStateSignalsInput  fifo_request_signals_in_int  ;
  logic                  fifo_request_setup_signal_int;


// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
  CacheResponsePayload   fifo_response_din             ;
  CacheResponsePayload   fifo_response_dout            ;
  FIFOStateSignalsOutput fifo_response_signals_out_int ;
  FIFOStateSignalsInput  fifo_response_signals_in_reg  ;
  FIFOStateSignalsInput  fifo_response_signals_in_int  ;
  logic                  fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_m_axi   <= areset;
    areset_fifo    <= areset;
    areset_arbiter <= areset;
    areset_setup   <= areset;
    areset_control <= areset;
    areset_cache   <= areset;
  end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      request_in_reg.valid         <= 1'b0;
      fifo_response_signals_in_reg <= 0;
      fifo_request_signals_in_reg  <= 0;
    end
    else begin
      request_in_reg.valid         <= request_in.valid;
      fifo_response_signals_in_reg <= fifo_response_signals_in;
      fifo_request_signals_in_reg  <= fifo_request_signals_in;
    end
  end

  always_ff @(posedge ap_clk) begin
    request_in_reg.payload <= request_in.payload;
  end
// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_setup_signal  <= 1'b1;
      response_out.valid <= 1'b0;
      done_out           <= 1'b0;
      fifo_empty_reg     <= 1'b1;
    end
    else begin
      fifo_setup_signal  <= fifo_request_setup_signal_int | fifo_response_setup_signal_int;
      response_out.valid <= response_in_int.valid;
      done_out           <= fifo_empty_reg;
      fifo_empty_reg     <= fifo_empty_int;
    end
  end

  assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty & cache_ctrl_out.wtb_empty & ~cache_response_mem.iob.ready;

  always_ff @(posedge ap_clk) begin
    fifo_request_signals_out  <= fifo_request_signals_out_int;
    fifo_response_signals_out <= fifo_response_signals_out_int;
    response_out.payload      <= response_in_int.payload;
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
  assign cache_ctrl_in.force_inv = 1'b0;
  assign cache_ctrl_in.wtb_empty = 1'b1;

  iob_cache_axi #(
    .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W                        ),
    .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W                        ),
    .CACHE_N_WAYS         (CACHE_N_WAYS                                 ),
    .CACHE_LINE_OFF_W     (CACHE_LINE_OFF_W                             ),
    .CACHE_WORD_OFF_W     (CACHE_WORD_OFF_W                             ),
    .CACHE_WTBUF_DEPTH_W  (CACHE_WTBUF_DEPTH_W                          ),
    .CACHE_REP_POLICY     (CACHE_REP_POLICY                             ),
    .CACHE_NWAY_W         (CACHE_NWAY_W                                 ),
    .CACHE_FRONTEND_NBYTES(CACHE_FRONTEND_NBYTES                        ),
    .CACHE_FRONTEND_BYTE_W(CACHE_FRONTEND_BYTE_W                        ),
    .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W                         ),
    .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W                         ),
    .CACHE_BACKEND_NBYTES (CACHE_BACKEND_NBYTES                         ),
    .CACHE_BACKEND_BYTE_W (CACHE_BACKEND_BYTE_W                         ),
    .CACHE_WRITE_POL      (CACHE_WRITE_POL                              ),
    .CACHE_CTRL_CACHE     (CACHE_CTRL_CACHE                             ),
    .CACHE_CTRL_CNT       (CACHE_CTRL_CNT                               ),
    .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W                             ),
    .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W                             ),
    .CACHE_AXI_ID_W       (CACHE_AXI_ID_W                               ),
    .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W                              ),
    .CACHE_AXI_ID         (CACHE_AXI_ID                                 ),
    .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W                             ),
    .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W                            ),
    .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W                             ),
    .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W                              ),
    .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W                            ),
    .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W                             ),
    .CACHE_AXI_CACHE_MODE (M_AXI4_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES)
  ) inst_cache_axi (
    .valid        (cache_request_mem.iob.valid ),
    .addr         (cache_request_mem.iob.addr  ),
    .wdata        (cache_request_mem.iob.wdata ),
    .wstrb        (cache_request_mem.iob.wstrb ),
    .rdata        (cache_response_mem.iob.rdata),
    .ready        (cache_response_mem.iob.ready),
    `ifdef CTRL_IO
    .force_inv_in (cache_ctrl_in.force_inv     ),
    .force_inv_out(cache_ctrl_out.force_inv    ), // floating
    .wtb_empty_in (cache_ctrl_in.wtb_empty     ),
    .wtb_empty_out(cache_ctrl_out.wtb_empty    ),
    `endif
    `include "m_axi_portmap_glay.vh"
    .ap_clk       (ap_clk                      ),
    .reset        (areset_cache                )
  );

  // assign l1_avalid               = cache_request_mem.iob.valid ;
  // assign cache_ctrl_in.force_inv = invalidate_reg & ~l1_avalid;
  // assign cache_ctrl_in.wtb_empty = 1'b1;
  // assign invalidate   = 1'b0;

  // //Necessary logic to avoid invalidating L2 while it's being accessed by a request
  // always @(posedge ap_clk)
  //   if (areset_cache) invalidate_reg    <= 1'b0;
  //   else if (invalidate) invalidate_reg <= 1'b1;
  //   else if (~l1_avalid) invalidate_reg <= 1'b0;
  //   else invalidate_reg <= invalidate_reg;

// --------------------------------------------------------------------------------------
// Cache request FIFO FWFT
// --------------------------------------------------------------------------------------
  // FIFO is resetting
  assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

  // Push
  assign fifo_request_signals_in_int.wr_en = request_in_reg.valid;
  assign fifo_request_din.iob              = request_in_reg.payload.iob;
  assign fifo_request_din.meta             = request_in_reg.payload.meta;
  assign fifo_request_din.data             = request_in_reg.payload.data;

  // Pop
  assign fifo_request_signals_in_int.rd_en = cache_response_mem.iob.ready & ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
  assign cache_request_mem.iob.valid       = fifo_request_dout.iob.valid & ~cache_response_mem.iob.ready & ~fifo_request_signals_out_int.empty;
  assign cache_request_mem.iob.addr        = fifo_request_dout.iob.addr;
  assign cache_request_mem.iob.wdata       = fifo_request_dout.iob.wdata;
  assign cache_request_mem.iob.wstrb       = fifo_request_dout.iob.wstrb;
  assign cache_request_mem.meta            = fifo_request_dout.meta;
  assign cache_request_mem.data            = fifo_request_dout.data;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
    .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
    .PROG_THRESH     (PROG_THRESH               ),
    .READ_MODE       ("fwft"                    )  //string; "std" or "fwft";
  ) inst_fifo_CacheRequest (
    .clk        (ap_clk                                  ),
    .srst       (areset_fifo                             ),
    .din        (fifo_request_din                        ),
    .wr_en      (fifo_request_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_signals_in_int.rd_en       ),
    .dout       (fifo_request_dout                       ),
    .full       (fifo_request_signals_out_int.full       ),
    .empty      (fifo_request_signals_out_int.empty      ),
    .valid      (fifo_request_signals_out_int.valid      ),
    .prog_full  (fifo_request_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_signals_out_int.rd_rst_busy)
  );

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
  // FIFO is resetting
  assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy | fifo_response_signals_out_int.rd_rst_busy;

  // Push
  assign fifo_response_signals_in_int.wr_en = cache_response_mem.iob.ready;
  assign fifo_response_din.iob              = cache_response_mem.iob;
  assign fifo_response_din.meta             = cache_request_mem.meta;
  assign fifo_response_din.data             = cache_request_mem.data;

  // Pop
  assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;
  assign response_in_int.valid              = fifo_response_signals_out_int.valid;
  assign response_in_int.payload            = fifo_response_dout;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH           ),
    .WRITE_DATA_WIDTH($bits(CacheResponsePayload)),
    .READ_DATA_WIDTH ($bits(CacheResponsePayload)),
    .PROG_THRESH     (PROG_THRESH                )
  ) inst_fifo_CacheResponse (
    .clk        (ap_clk                                   ),
    .srst       (areset_fifo                              ),
    .din        (fifo_response_din                        ),
    .wr_en      (fifo_response_signals_in_int.wr_en       ),
    .rd_en      (fifo_response_signals_in_int.rd_en       ),
    .dout       (fifo_response_dout                       ),
    .full       (fifo_response_signals_out_int.full       ),
    .empty      (fifo_response_signals_out_int.empty      ),
    .valid      (fifo_response_signals_out_int.valid      ),
    .prog_full  (fifo_response_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_response_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_response_signals_out_int.rd_rst_busy)
  );


endmodule : cu_cache
