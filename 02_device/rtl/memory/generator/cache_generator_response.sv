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

module cache_generator_response #(
  parameter NUM_MEMORY_REQUESTOR = 2 ,
  parameter FIFO_WRITE_DEPTH     = 32,
  parameter PROG_THRESH          = 16
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
logic areset_demux  ;

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
    response_in_reg.valid        <= 0;
    fifo_response_signals_in_reg <= 0;
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
always_ff @(posedge ap_clk ) begin
  if(areset_control) begin
    for (int i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      response_out[i].valid <= 0;
    end
  end else begin
    for (int i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      response_out[i].valid <= response_out_reg[i].valid;
    end
  end
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
    response_out[i].payload <= response_out_reg[i].payload;
  end
end

always_comb begin
  if(fifo_response_dout_int.valid) begin
    case (fifo_response_dout_int.payload.meta.subclass.buffer)
      STRUCT_CU_SETUP : begin
        response_out_reg[0] = fifo_response_dout_int;
        response_out_reg[1] = fifo_response_dout_int;
      end
      STRUCT_CU_FLUSH : begin
        response_out_reg[0] = fifo_response_dout_int;
        response_out_reg[1] = 0;
      end
      default : begin
        response_out_reg[0] = 0;
        response_out_reg[1] = fifo_response_dout_int;
      end
    endcase
  end else begin
    response_out_reg[0] = 0;
    response_out_reg[1] = 0;
  end
end

// --------------------------------------------------------------------------------------
// FIFO cache response out fifo CacheResponse
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy  | fifo_response_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_signals_in_int.wr_en     = response_in_reg.valid;
assign fifo_response_din.iob                  = response_in_reg.payload.iob;
assign fifo_response_din.meta.address         = response_in_reg.payload.meta.address ;
assign fifo_response_din.meta.route           = response_in_reg.payload.meta.route;
assign fifo_response_din.meta.subclass.buffer = response_in_reg.payload.meta.subclass.buffer;
assign fifo_response_din.meta.subclass.cmd    = CMD_MEM_RESPONSE;
assign fifo_response_din.data                 = response_in_reg.payload.data;

// Pop
assign fifo_response_signals_in_int.rd_en           = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;
assign fifo_response_dout_int.valid                 = fifo_response_signals_out_int.valid;
assign fifo_response_dout_int.payload.meta          = fifo_response_dout.meta;
assign fifo_response_dout_int.payload.data.field[0] = fifo_response_dout.iob.rdata;
assign fifo_response_dout_int.payload.data.field[1] = fifo_response_dout.data.field[0];
assign fifo_response_dout_int.payload.data.field[2] = fifo_response_dout.data.field[1];
assign fifo_response_dout_int.payload.data.field[3] = fifo_response_dout.data.field[2];

xpm_fifo_sync_bram_wrapper #(
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

endmodule : cache_generator_response
