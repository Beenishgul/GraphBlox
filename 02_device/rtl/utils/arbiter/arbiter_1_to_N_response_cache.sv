// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_generator_response.sv
// Create : 2023-06-17 01:03:07
// Revise : 2023-06-19 01:19:58
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module arbiter_1_to_N_response_cache #(
  parameter NUM_MEMORY_REQUESTOR = 2                                ,
  parameter FIFO_ARBITER_DEPTH   = 16                               ,
  parameter FIFO_WRITE_DEPTH     = 2**$clog2(FIFO_ARBITER_DEPTH+9)  ,
  parameter PROG_THRESH          = (FIFO_WRITE_DEPTH/2) + 3
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
logic areset_control        ;
logic areset_fifo           ;
logic areset_demux          ;
logic cu_setup_push_filter  ;
logic cu_bundles_push_filter;

MemoryPacket  response_out_reg[NUM_MEMORY_REQUESTOR-1:0];
CacheResponse response_in_reg                           ;

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
CacheResponsePayload          fifo_response_din             ;
MemoryPacket                  fifo_response_dout_int        ;
CacheResponsePayload          fifo_response_dout            ;
FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_control <= areset;
  areset_fifo    <= areset;
  areset_demux   <= areset;
end

// --------------------------------------------------------------------------------------
//   Drive Inputs
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if(areset_control) begin
    response_in_reg.valid              <= 1'b0;
    fifo_response_signals_in_reg.rd_en <= 1'b0;
  end else begin
    response_in_reg.valid              <= response_in.valid;
    fifo_response_signals_in_reg.rd_en <= fifo_response_signals_in.rd_en;
  end
end

always_ff @(posedge ap_clk) begin
  response_in_reg.payload <= response_in.payload;
end

// --------------------------------------------------------------------------------------
//   Drive Outputs
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if(areset_control) begin
    fifo_setup_signal <= 1'b1;
  end else begin
    fifo_setup_signal <= fifo_response_setup_signal_int;
  end
end

always_ff @(posedge ap_clk) begin
  fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
end

// --------------------------------------------------------------------------------------
// drive Responses
// --------------------------------------------------------------------------------------

assign cu_setup_push_filter   = ((&{fifo_response_dout_int.payload.meta.route.packet_source.id_cu,fifo_response_dout_int.payload.meta.route.packet_source.id_bundle,fifo_response_dout_int.payload.meta.route.packet_source.id_lane,fifo_response_dout_int.payload.meta.route.packet_source.id_engine}) | ~(|fifo_response_dout_int.payload.meta.route.packet_source));
assign cu_bundles_push_filter = (|fifo_response_dout_int.payload.meta.route.packet_source);

always_ff @(posedge ap_clk ) begin
  if(areset_control) begin
    response_out[0].valid <= 1'b0;
    response_out[1].valid <= 1'b0;
  end else begin
    response_out[0].valid <= fifo_response_dout_int.valid & cu_setup_push_filter;
    response_out[1].valid <= fifo_response_dout_int.valid & cu_bundles_push_filter;
  end
end

always_ff @(posedge ap_clk) begin
  response_out[0].payload <= fifo_response_dout_int.payload;
  response_out[1].payload <= fifo_response_dout_int.payload;
end

// --------------------------------------------------------------------------------------
// FIFO cache response out fifo CacheResponse
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy  | fifo_response_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_signals_in_int.wr_en = response_in_reg.valid;
assign fifo_response_din                  = map_CacheResponse_to_MemoryResponsePacket(response_in_reg.payload);

// Pop
assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;
assign fifo_response_dout_int.valid       = fifo_response_signals_out_int.valid;
assign fifo_response_dout_int.payload     = fifo_response_dout;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
  .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
  .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
  .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketResponse (
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

endmodule : arbiter_1_to_N_response_cache
