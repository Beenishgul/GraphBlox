// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_forward_data.sv
// Create : 2023-07-17 14:42:46
// Revise : 2023-08-28 15:49:58
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_forward_data #(parameter
    ID_CU               = 0                             ,
    ID_BUNDLE           = 0                             ,
    ID_LANE             = 0                             ,
    ID_ENGINE           = 0                             ,
    ID_RELATIVE         = 0                             ,
    ENGINE_CAST_WIDTH   = 0                             ,
    ENGINE_MERGE_WIDTH  = 0                             ,
    NUM_CHANNELS        = 2                             ,
    NUM_CUS             = 1                             ,
    ENGINES_CONFIG      = 0                             ,
    MERGE_WIDTH         = 1                             ,
    FIFO_WRITE_DEPTH    = 32                            ,
    PROG_THRESH         = 16                            ,
    NUM_MODULES         = 2                             ,
    NUM_BACKTRACK_LANES = 4                             ,
    NUM_BUNDLES         = 4                             ,
    ENGINE_SEQ_WIDTH    = 16                            ,
    ENGINE_SEQ_MIN      = ID_RELATIVE * ENGINE_SEQ_WIDTH,
    PIPELINE_STAGES     = 2
) (
    // System Signals
    input  logic                  ap_clk                                                                             ,
    input  logic                  areset                                                                             ,
    input  EnginePacket           response_engine_in                                                                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out                                                ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0],
    input  MemoryPacketResponse   response_memory_in                                                                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                                                ,
    input  ControlPacket          response_control_in                                                                ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in                                                ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out                                               ,
    output EnginePacket           request_engine_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out                                                ,
    output MemoryPacketRequest    request_memory_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                                                ,
    input  FIFOStateSignalsOutput fifo_request_memory_out_backtrack_signals_in[NUM_CHANNELS-1:0]                     ,
    output ControlPacket          request_control_out                                                                ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in                                                ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out                                               ,
    output logic                  fifo_setup_signal                                                                  ,
    output logic                  done_out
);

assign fifo_request_control_out_signals_out = 2'b10;
assign fifo_request_memory_out_signals_out  = 2'b10;
assign fifo_response_control_in_signals_out = 2'b10;
assign fifo_response_memory_in_signals_out  = 2'b10;
assign request_control_out                  = 0;
assign request_memory_out                   = 0;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_forward_data_engine;
logic areset_generator          ;

EnginePacket     response_engine_in_reg;
EnginePacket     request_engine_out_int;
EnginePacket     response_engine_in_int;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_engine_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// Generation module - Memory/Engine Config -> Gen
// --------------------------------------------------------------------------------------
EnginePacket           generator_engine_response_engine_in                 ;
FIFOStateSignalsInput  generator_engine_fifo_response_engine_in_signals_in ;
FIFOStateSignalsOutput generator_engine_fifo_response_engine_in_signals_out;
FIFOStateSignalsOutput generator_engine_fifo_request_engine_out_signals_out;

EnginePacket          generator_engine_request_engine_out                ;
FIFOStateSignalsInput generator_engine_fifo_request_engine_out_signals_in;

logic generator_engine_fifo_setup_signal;
logic generator_engine_done_out         ;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
FIFOStateSignalsOutput generator_fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0];

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_forward_data_engine <= areset;
    areset_generator           <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_forward_data_engine) begin
        fifo_request_engine_out_signals_in_reg <= 0;
    end
    else begin
        fifo_request_engine_out_signals_in_reg <= fifo_request_engine_out_signals_in;
    end
end

always_ff @(posedge ap_clk) begin
    if (areset_forward_data_engine) begin
        fifo_response_engine_in_signals_in_reg <= 0;
        response_engine_in_reg.valid           <= 1'b0;
    end
    else begin
        fifo_response_engine_in_signals_in_reg <= fifo_response_engine_in_signals_in;
        response_engine_in_reg.valid           <= response_engine_in.valid;
    end
end

always_ff @(posedge ap_clk) begin
    response_engine_in_reg.payload <= response_engine_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_forward_data_engine) begin
        fifo_setup_signal        <= 1'b1;
        request_engine_out.valid <= 1'b0;
        done_out                 <= 1'b0;
    end
    else begin
        fifo_setup_signal        <= generator_engine_fifo_setup_signal;
        request_engine_out.valid <= request_engine_out_int.valid;
        done_out                 <= generator_engine_done_out;
    end
end

always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_signals_out <= generator_engine_fifo_response_engine_in_signals_out;
    fifo_request_engine_out_signals_out <= generator_engine_fifo_request_engine_out_signals_out;
    request_engine_out.payload          <= request_engine_out_int.payload;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_engine_in_int = response_engine_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_engine_out_int = generator_engine_request_engine_out;

// --------------------------------------------------------------------------------------
// Generation module - Memory/Engine Config -> Gen
// --------------------------------------------------------------------------------------

assign generator_engine_response_engine_in                       = response_engine_in_int ;
assign generator_engine_fifo_response_engine_in_signals_in.rd_en = fifo_response_engine_in_signals_in_reg.rd_en;

assign generator_engine_fifo_request_engine_out_signals_in.rd_en = fifo_request_engine_out_signals_in_reg.rd_en;;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
assign generator_fifo_response_lanes_backtrack_signals_in = fifo_response_lanes_backtrack_signals_in;

engine_forward_data_generator #(
    .ID_CU              (ID_CU              ),
    .ID_BUNDLE          (ID_BUNDLE          ),
    .ID_LANE            (ID_LANE            ),
    .ID_ENGINE          (ID_ENGINE          ),
    .ID_MODULE          (1                  ),
    .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
    .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
    .ENGINES_CONFIG     (ENGINES_CONFIG     ),
    .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
    .PROG_THRESH        (PROG_THRESH        ),
    .PIPELINE_STAGES    (PIPELINE_STAGES    ),
    .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
    .NUM_BUNDLES        (NUM_BUNDLES        )
) inst_engine_forward_data_generator (
    .ap_clk                                  (ap_clk                                              ),
    .areset                                  (areset_generator                                    ),
    .response_engine_in                      (generator_engine_response_engine_in                 ),
    .fifo_response_engine_in_signals_in      (generator_engine_fifo_response_engine_in_signals_in ),
    .fifo_response_engine_in_signals_out     (generator_engine_fifo_response_engine_in_signals_out),
    .fifo_response_lanes_backtrack_signals_in(generator_fifo_response_lanes_backtrack_signals_in  ),
    .request_engine_out                      (generator_engine_request_engine_out                 ),
    .fifo_request_engine_out_signals_in      (generator_engine_fifo_request_engine_out_signals_in ),
    .fifo_request_engine_out_signals_out     (generator_engine_fifo_request_engine_out_signals_out),
    .fifo_setup_signal                       (generator_engine_fifo_setup_signal                  ),
    .done_out                                (generator_engine_done_out                           )
);

endmodule : engine_forward_data