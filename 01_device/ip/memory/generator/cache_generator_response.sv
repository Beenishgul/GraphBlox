// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_generator_response.sv
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

module cache_generator_response #(
  parameter NUM_GRAPH_CLUSTERS   = CU_COUNT_GLOBAL,
  parameter NUM_MEMORY_REQUESTOR = 2              ,
  parameter NUM_GRAPH_PE         = CU_COUNT_LOCAL
) (
  input  logic                  ap_clk                                        ,
  input  logic                  areset                                        ,
  output MemoryPacket           memory_response_out [NUM_MEMORY_REQUESTOR-1:0],
  input  CacheResponse          cache_resp_in                                 ,
  input  FIFOStateSignalsInput  fifo_response_signals_in                      ,
  output FIFOStateSignalsOutput fifo_response_signals_out                     ,
  output logic                  fifo_setup_signal
);


// --------------------------------------------------------------------------------------
// Cache response variables
// --------------------------------------------------------------------------------------
  logic areset_control            ;
  logic areset_fifo               ;
  logic areset_arbiter            ;
  logic fifo_response_setup_signal;

  MemoryPacket  mem_resp_reg      [NUM_MEMORY_REQUESTOR-1:0];
  CacheResponse fifo_response_dout                          ;
  CacheResponse fifo_response_din                           ;
  CacheResponse cache_resp_reg                              ;

  FIFOStateSignalsInput  fifo_response_signals_in_reg ;
  FIFOStateSignalsOutput fifo_response_signals_out_reg;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_control <= areset;
    areset_fifo    <= areset;
    areset_arbiter <= areset;
  end

// --------------------------------------------------------------------------------------
//   Drive Inputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control) begin
      cache_resp_reg                     <= 0;
      fifo_response_signals_in_reg.rd_en <= 0;
    end else begin
      cache_resp_reg                     <= cache_resp_in;
      fifo_response_signals_in_reg.rd_en <= fifo_response_signals_in.rd_en;
    end
  end

// --------------------------------------------------------------------------------------
//   Drive Outputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control) begin
      fifo_setup_signal         <= 1'b1;
      fifo_response_signals_out <= 0;
    end else begin
      fifo_setup_signal         <= fifo_response_setup_signal;
      fifo_response_signals_out <= fifo_response_signals_out_reg;
    end
  end

  genvar i;
  generate
    for (i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          memory_response_out[i].valid <= 0;
        end else begin
          memory_response_out[i].valid <= mem_resp_reg[i].valid;
        end
      end

      always_ff @(posedge ap_clk) begin
        memory_response_out[i].payload <= mem_resp_reg[i].payload;
      end
    end
  endgenerate

  assign mem_resp_reg[0].valid   = fifo_response_signals_out_reg.valid;
  assign mem_resp_reg[0].payload.meta = fifo_response_dout.payload.meta;
  assign mem_resp_reg[0].payload.data.field = fifo_response_dout.payload.iob.rdata;

  assign mem_resp_reg[1].valid   = 0;
  assign mem_resp_reg[1].payload = 0;

// --------------------------------------------------------------------------------------
// FIFO cache response out fifo_814x16_CacheResponse
// --------------------------------------------------------------------------------------
  assign fifo_response_din.valid                     = cache_resp_reg.valid;
  assign fifo_response_din.payload.iob.rdata         = cache_resp_reg.payload.iob.rdata;
  assign fifo_response_din.payload.iob.wtb_empty_out = cache_resp_reg.payload.iob.wtb_empty_out;
  assign fifo_response_din.payload.meta              = cache_resp_reg.payload.meta;

  assign fifo_response_setup_signal         = fifo_response_signals_out_reg.wr_rst_busy  | fifo_response_signals_out_reg.rd_rst_busy;
  assign fifo_response_signals_in_reg.wr_en = fifo_response_din.valid;

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


endmodule : cache_generator_response
