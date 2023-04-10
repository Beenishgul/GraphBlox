// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_request_generator.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_MEMORY_PKG::*;

module cache_request_generator #(
  parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
  parameter NUM_MODULES        = 3              ,
  parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                   ap_clk                      ,
  input  logic                   areset                      ,
  input  GLAYDescriptorInterface glay_descriptor_in          ,
  input  MemoryRequestPacket     mem_req_in [NUM_MODULES-1:0],
  output GlayCacheRequest        glay_cache_req_out          ,
  output FIFOStateSignalsOutput  mem_req_fifo_out_signals    ,
  input  FIFOStateSignalsInput   mem_req_fifo_in_signals     ,
  output logic                   fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic                          m_axi_areset             ;
  logic                          control_areset           ;
  logic                          cache_areset             ;
  logic                          fifo_areset              ;
  logic                          arbiter_areset           ;
  logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_done_reg         ;
  logic [       NUM_MODULES-1:0] glay_cu_setup_state      ;
  logic                          fifo_setup_signal_638x128;
  logic                          fifo_setup_signal_516x128;


  GLAYDescriptorInterface      glay_descriptor_in_reg;
  logic [VERTEX_DATA_BITS-1:0] counter               ;

// --------------------------------------------------------------------------------------
//   AXI Cache FIFO signals
// --------------------------------------------------------------------------------------

  GlayCacheRequest glay_cache_req_fifo_dout;
  GlayCacheRequest glay_cache_req_fifo_din ;


  FIFOStateSignalsOutput cache_req_fifo_out_signals ;
  FIFOStateSignalsOutput cache_resp_fifo_out_signals;

  FIFOStateSignalsInput cache_req_fifo_in_signals;

  logic force_inv_in;
  logic wtb_empty_in;

  assign force_inv_in = 1'b0;
  assign wtb_empty_in = 1'b1;

// --------------------------------------------------------------------------------------
// Bus arbiter Signals fifo_638x128_GlayCacheRequest
// --------------------------------------------------------------------------------------
  localparam BUS_ARBITER_N_IN_1_OUT_WIDTH     = 2                           ;
  localparam BUS_ARBITER_N_IN_1_OUT_BUS_NUM   = BUS_ARBITER_N_IN_1_OUT_WIDTH;
  localparam BUS_ARBITER_N_IN_1_OUT_BUS_WIDTH = $bits(MemoryRequestPacket)  ;

  MemoryRequestPacket bus_out                                    ;
  MemoryRequestPacket bus_in [0:BUS_ARBITER_N_IN_1_OUT_BUS_NUM-1];

  logic [1:0] grant;
  logic [1:0] req  ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    control_areset <= areset;
    fifo_areset    <= areset;
    arbiter_areset <= areset;
  end

// --------------------------------------------------------------------------------------
// Done Logic
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      fifo_setup_signal <= 0;
    end
    else begin
      fifo_setup_signal <= fifo_setup_signal_638x128;
    end
  end


// --------------------------------------------------------------------------------------
// READ GLAY Descriptor Control
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_descriptor_in_reg.valid <= 0;
    end
    else begin
      glay_descriptor_in_reg.valid <= glay_descriptor_in.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    glay_descriptor_in_reg.payload <= glay_descriptor_in.payload;
  end

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
  assign fifo_setup_signal_638x128 = cache_resp_fifo_out_signals.wr_rst_busy | cache_resp_fifo_out_signals.rd_rst_busy ;

// --------------------------------------------------------------------------------------
// FIFO cache requests in fifo_638x128_GlayCacheRequest
// --------------------------------------------------------------------------------------
  fifo_638x128 inst_fifo_638x128_GlayCacheRequest (
    .clk         (ap_clk                                 ),
    .srst        (fifo_areset                            ),
    .din         (glay_cache_req_fifo_din                ),
    .wr_en       (cache_req_fifo_in_signals.wr_en        ),
    .rd_en       (cache_req_fifo_in_signals.rd_en        ),
    .dout        (glay_cache_req_fifo_dout               ),
    .full        (cache_req_fifo_out_signals.full        ),
    .almost_full (cache_req_fifo_out_signals.almost_full ),
    .empty       (cache_req_fifo_out_signals.empty       ),
    .almost_empty(cache_req_fifo_out_signals.almost_empty),
    .valid       (cache_req_fifo_out_signals.valid       ),
    .prog_full   (cache_req_fifo_out_signals.prog_full   ),
    .prog_empty  (cache_req_fifo_out_signals.prog_empty  ),
    .wr_rst_busy (cache_req_fifo_out_signals.wr_rst_busy ),
    .rd_rst_busy (cache_req_fifo_out_signals.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// Bus arbiter for requests fifo_638x128_GlayCacheRequest
// --------------------------------------------------------------------------------------
  assign bus_in[0] = mem_req_in[0];
  assign req[0]    = mem_req_in[0].valid;

  assign bus_in[1] = mem_req_in[1];
  assign req[1]    = mem_req_in[1].valid;

  assign glay_cache_req_fifo_din = bus_out;

  bus_arbiter_N_in_1_out #(
    .WIDTH    (BUS_ARBITER_N_IN_1_OUT_WIDTH    ),
    .BUS_WIDTH(BUS_ARBITER_N_IN_1_OUT_BUS_WIDTH),
    .BUS_NUM  (BUS_ARBITER_N_IN_1_OUT_BUS_NUM  )
  ) inst_bus_arbiter_N_in_1_out (
    .enable (1'b1          ),
    .req    (req           ),
    .bus_in (bus_in        ),
    .grant  (grant         ),
    .bus_out(bus_out       ),
    .ap_clk (ap_clk        ),
    .areset (arbiter_areset)
  );

endmodule : cache_request_generator
