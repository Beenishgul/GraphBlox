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
  input  logic                  ap_clk                                 ,
  input  logic                  areset                                 ,
  input  CacheResponse          response_in                            ,
  input  FIFOStateSignalsInput  fifo_response_signals_in               ,
  output FIFOStateSignalsOutput fifo_response_signals_out              ,
  output MemoryPacket           response_out [NUM_MEMORY_REQUESTOR-1:0],
  output logic                  fifo_setup_signal
);


// --------------------------------------------------------------------------------------
// Cache response variables
// --------------------------------------------------------------------------------------
  logic areset_control;
  logic areset_fifo   ;

  MemoryPacket  response_out_reg[NUM_MEMORY_REQUESTOR-1:0];
  CacheResponse response_in_reg                           ;

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
  MemoryPacket           fifo_response_dout_reg           ;
  CacheResponsePayload   fifo_response_dout               ;
  CacheResponsePayload   fifo_response_din                ;
  FIFOStateSignalsOutput fifo_response_signals_out_reg    ;
  FIFOStateSignalsInput  fifo_response_signals_in_reg     ;
  FIFOStateSignalsInput  fifo_response_signals_in_internal;
  logic                  fifo_response_setup_signal       ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_control <= areset;
    areset_fifo    <= areset;
  end

// --------------------------------------------------------------------------------------
//   Drive Inputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control) begin
      response_in_reg              <= 0;
      fifo_response_signals_in_reg <= 0;
    end else begin
      response_in_reg                    <= response_in;
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

// --------------------------------------------------------------------------------------
// Arbitrate responses
// --------------------------------------------------------------------------------------
  genvar i;
  generate
    for (i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          response_out[i].valid <= 0;
        end else begin
          response_out[i].valid <= response_out_reg[i].valid;
        end
      end

      always_ff @(posedge ap_clk) begin
        response_out[i].payload <= response_out_reg[i].payload;
      end
    end
  endgenerate

  assign response_out_reg[0] = fifo_response_dout_reg;
  assign response_out_reg[1] = 0;

// --------------------------------------------------------------------------------------
// FIFO cache response out fifo CacheResponse
// --------------------------------------------------------------------------------------
  // FIFO is resetting
  assign fifo_response_setup_signal = fifo_response_signals_out_reg.wr_rst_busy  | fifo_response_signals_out_reg.rd_rst_busy;

  // Push
  assign fifo_response_signals_in_internal.wr_en = fifo_response_din.valid;
  assign fifo_response_din.iob                   = response_in_reg.payload.iob;
  assign fifo_response_din.meta                  = response_in_reg.payload.meta;

  // Pop
  assign fifo_response_signals_in_internal.rd_en   = ~fifo_response_signals_out_reg.empty & fifo_response_signals_in_reg.rd_en;
  assign fifo_response_dout_reg.valid              = fifo_response_signals_out_reg.valid;
  assign fifo_response_dout_reg.payload.meta       = fifo_response_dout.meta;
  assign fifo_response_dout_reg.payload.data.field = fifo_response_dout.iob.rdata;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(32                         ),
    .WRITE_DATA_WIDTH($bits(CacheResponsePayload)),
    .READ_DATA_WIDTH ($bits(CacheResponsePayload)),
    .PROG_THRESH     (8                          )
  ) inst_fifo_CacheResponse (
    .clk         (ap_clk                                    ),
    .srst        (areset_fifo                               ),
    .din         (fifo_response_din                         ),
    .wr_en       (fifo_response_signals_in_internal.wr_en   ),
    .rd_en       (fifo_response_signals_in_internal.rd_en   ),
    .dout        (fifo_response_dout                        ),
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
