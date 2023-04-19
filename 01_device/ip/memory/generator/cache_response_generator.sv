// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_response_generator.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;

module cache_response_generator #(
  parameter NUM_GRAPH_CLUSTERS   = CU_COUNT_GLOBAL,
  parameter NUM_MEMORY_REQUESTOR = 2              ,
  parameter NUM_GRAPH_PE         = CU_COUNT_LOCAL
) (
  input  logic                  ap_clk                                 ,
  input  logic                  areset                                 ,
  output MemoryPacket           mem_resp_out [NUM_MEMORY_REQUESTOR-1:0],
  input  CacheResponse          cache_resp_in                          ,
  output FIFOStateSignalsInput  cache_resp_fifo_in_signals             ,
  output FIFOStateSignalsOutput cache_resp_fifo_out_signals            ,
  output logic                  fifo_setup_signal
);


// --------------------------------------------------------------------------------------
// Cache response variables
// --------------------------------------------------------------------------------------
  logic control_areset                 ;
  logic fifo_areset                    ;
  logic arbiter_areset                 ;
  logic fifo_CacheResponse_setup_signal;

  MemoryPacket  mem_resp_reg        [NUM_MEMORY_REQUESTOR-1:0];
  CacheResponse cache_resp_fifo_dout                          ;
  CacheResponse cache_resp_fifo_din                           ;
  CacheResponse cache_resp_reg                                ;

  FIFOStateSignalsInput  cache_resp_fifo_in_signals_reg ;
  FIFOStateSignalsOutput cache_resp_fifo_out_signals_reg;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    control_areset <= areset;
    fifo_areset    <= areset;
    arbiter_areset <= areset;
  end

// --------------------------------------------------------------------------------------
//   Drive Inputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(control_areset) begin
      cache_resp_reg <= 0;
    end else begin
      cache_resp_reg <= cache_resp_in;
    end
  end

// --------------------------------------------------------------------------------------
//   Drive Outputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(control_areset) begin
      fifo_setup_signal           <= 1'b1;
      cache_resp_fifo_out_signals <= 0;
    end else begin
      fifo_setup_signal           <= fifo_CacheResponse_setup_signal;
      cache_resp_fifo_out_signals <= cache_resp_fifo_out_signals_reg;
    end
  end

  genvar i;
  generate
    for (i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      always_ff @(posedge ap_clk ) begin
        if(control_areset) begin
          mem_resp_out[i].valid <= 0;
        end else begin
          mem_resp_out[i].valid <= mem_resp_reg[i].valid;
        end
      end

      always_ff @(posedge ap_clk) begin
        mem_resp_out[i].payload <= mem_resp_reg[i].payload;
      end
    end
  endgenerate

  assign mem_resp_reg[0].valid   = cache_resp_fifo_out_signals_reg.valid;
  assign mem_resp_reg[0].payload.meta = cache_resp_fifo_dout.payload.meta;
  assign mem_resp_reg[0].payload.data.field = cache_resp_fifo_dout.payload.iob.rdata;

  assign mem_resp_reg[1].valid   = 0;
  assign mem_resp_reg[1].payload = 0;

// --------------------------------------------------------------------------------------
// FIFO cache response out fifo_814x16_CacheResponse
// --------------------------------------------------------------------------------------
  assign cache_resp_fifo_din.valid                     = cache_resp_reg.valid;
  assign cache_resp_fifo_din.payload.iob.rdata         = swap_endianness_cacheline(cache_resp_reg.payload.iob.rdata);
  assign cache_resp_fifo_din.payload.iob.wtb_empty_out = cache_resp_reg.payload.iob.wtb_empty_out;
  assign cache_resp_fifo_din.payload.meta              = cache_resp_reg.payload.meta;

  assign fifo_CacheResponse_setup_signal      = cache_resp_fifo_out_signals_reg.wr_rst_busy  | cache_resp_fifo_out_signals_reg.rd_rst_busy;
  assign cache_resp_fifo_in_signals_reg.wr_en = cache_resp_fifo_din.valid;
  assign cache_resp_fifo_in_signals_reg.rd_en = ~cache_resp_fifo_out_signals_reg.empty;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(32                         ),
    .WRITE_DATA_WIDTH($bits(CacheResponsePayload)),
    .READ_DATA_WIDTH ($bits(CacheResponsePayload)),
    .PROG_THRESH     (8                          )
  ) inst_fifo_CacheResponse (
    .clk         (ap_clk                                      ),
    .srst        (fifo_areset                                 ),
    .din         (cache_resp_fifo_din.payload                 ),
    .wr_en       (cache_resp_fifo_in_signals_reg.wr_en        ),
    .rd_en       (cache_resp_fifo_in_signals_reg.rd_en        ),
    .dout        (cache_resp_fifo_dout.payload                ),
    .full        (cache_resp_fifo_out_signals_reg.full        ),
    .almost_full (cache_resp_fifo_out_signals_reg.almost_full ),
    .empty       (cache_resp_fifo_out_signals_reg.empty       ),
    .almost_empty(cache_resp_fifo_out_signals_reg.almost_empty),
    .valid       (cache_resp_fifo_out_signals_reg.valid       ),
    .prog_full   (cache_resp_fifo_out_signals_reg.prog_full   ),
    .prog_empty  (cache_resp_fifo_out_signals_reg.prog_empty  ),
    .wr_rst_busy (cache_resp_fifo_out_signals_reg.wr_rst_busy ),
    .rd_rst_busy (cache_resp_fifo_out_signals_reg.rd_rst_busy )
  );


endmodule : cache_response_generator
