// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_parallel_read_write.sv
// Create : 2023-07-17 14:42:46
// Revise : 2023-08-28 15:49:58
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_parallel_read_write #(parameter
    ID_CU               = 0                             ,
    ID_BUNDLE           = 0                             ,
    ID_LANE             = 0                             ,
    ID_ENGINE           = 0                             ,
    ID_RELATIVE         = 0                             ,
    ENGINE_CAST_WIDTH   = 1                             ,
    ENGINE_MERGE_WIDTH  = 1                             ,
    NUM_CHANNELS        = 2                             ,
    NUM_CUS             = 1                             ,
    ENGINES_CONFIG      = 0                             ,
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
assign fifo_response_control_in_signals_out = 2'b10;
assign request_control_out                  = 0;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_read_write_engine;
logic areset_configure_memory ;
logic areset_generator        ;

EnginePacket         response_engine_in_reg;
MemoryPacketResponse response_memory_in_reg;

EnginePacket         request_engine_out_int;
MemoryPacketRequest  request_memory_out_int;
EnginePacket         response_engine_in_int;
MemoryPacketResponse response_memory_in_int;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_engine_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_memory_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// ENGINE CONFIGURATION AND GENERATION LOGIC
// --------------------------------------------------------------------------------------
logic configure_fifo_setup_signal;

FIFOStateSignalsInput          configure_memory_fifo_configure_memory_signals_in   ;
FIFOStateSignalsInput          configure_memory_fifo_response_memory_in_signals_in ;
FIFOStateSignalsOutput         configure_memory_fifo_configure_memory_signals_out  ;
FIFOStateSignalsOutput         configure_memory_fifo_response_memory_in_signals_out;
logic                          configure_memory_fifo_setup_signal                  ;
MemoryPacketResponse           configure_memory_response_memory_in                 ;
ParallelReadWriteConfiguration configure_memory_out                                ;

// --------------------------------------------------------------------------------------
// Generation module - Memory/Engine Config -> Gen
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput          generator_engine_fifo_configure_memory_in_signals_in;
FIFOStateSignalsInput          generator_engine_fifo_request_engine_out_signals_in ;
FIFOStateSignalsInput          generator_engine_fifo_request_memory_out_signals_in ;
FIFOStateSignalsInput          generator_engine_fifo_response_engine_in_signals_in ;
FIFOStateSignalsInput          generator_engine_fifo_response_memory_in_signals_in ;
FIFOStateSignalsOutput         generator_engine_fifo_response_memory_in_signals_out;
FIFOStateSignalsOutput         generator_engine_fifo_request_engine_out_signals_out;
FIFOStateSignalsOutput         generator_engine_fifo_request_memory_out_signals_out;
FIFOStateSignalsOutput         generator_engine_fifo_response_engine_in_signals_out;
logic                          generator_engine_configure_memory_setup             ;
logic                          generator_engine_done_out                           ;
logic                          generator_engine_fifo_setup_signal                  ;
EnginePacket                   generator_engine_request_engine_out                 ;
MemoryPacketRequest            generator_engine_request_memory_out                 ;
EnginePacket                   generator_engine_response_engine_in                 ;
MemoryPacketResponse           generator_engine_response_memory_in                 ;
ParallelReadWriteConfiguration generator_engine_configure_memory_in                ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Response/Engine Generator
// --------------------------------------------------------------------------------------
logic                  areset_arbiter_1_to_N_memory                                    ;
MemoryPacketResponse   arbiter_1_to_N_memory_response_in                               ;
FIFOStateSignalsInput  arbiter_1_to_N_memory_fifo_response_signals_in [NUM_MODULES-1:0];
FIFOStateSignalsOutput arbiter_1_to_N_memory_fifo_response_signals_out                 ;
MemoryPacketResponse   arbiter_1_to_N_memory_response_out             [NUM_MODULES-1:0];
logic                  arbiter_1_to_N_memory_fifo_setup_signal                         ;

MemoryPacketResponse   modules_response_memory_in                 [NUM_MODULES-1:0];
FIFOStateSignalsInput  modules_fifo_response_memory_in_signals_in [NUM_MODULES-1:0];
FIFOStateSignalsOutput modules_fifo_response_memory_in_signals_out[NUM_MODULES-1:0];

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
FIFOStateSignalsOutput generator_fifo_response_lanes_backtrack_signals_in    [NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0];
FIFOStateSignalsOutput generator_fifo_request_memory_out_backtrack_signals_in[                         NUM_CHANNELS-1:0];

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_read_write_engine     <= areset;
    areset_configure_memory      <= areset;
    areset_generator             <= areset;
    areset_arbiter_1_to_N_memory <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_read_write_engine) begin
        fifo_response_engine_in_signals_in_reg <= 0;
        fifo_request_engine_out_signals_in_reg <= 0;
        fifo_response_memory_in_signals_in_reg <= 0;
        fifo_request_memory_out_signals_in_reg <= 0;
        response_engine_in_reg.valid           <= 1'b0;
        response_memory_in_reg.valid           <= 1'b0;
    end
    else begin
        fifo_response_engine_in_signals_in_reg <= fifo_response_engine_in_signals_in;
        fifo_request_engine_out_signals_in_reg <= fifo_request_engine_out_signals_in;
        fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
        fifo_request_memory_out_signals_in_reg <= fifo_request_memory_out_signals_in;
        response_engine_in_reg.valid           <= response_engine_in.valid;
        response_memory_in_reg.valid           <= response_memory_in.valid ;
    end
end

always_ff @(posedge ap_clk) begin
    response_engine_in_reg.payload <= response_engine_in.payload;
    response_memory_in_reg.payload <= response_memory_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_read_write_engine) begin
        fifo_setup_signal        <= 1'b1;
        request_engine_out.valid <= 1'b0;
        request_memory_out.valid <= 1'b0;
        done_out                 <= 1'b0;
        fifo_empty_reg           <= 1'b1;
    end
    else begin
        fifo_setup_signal        <= configure_fifo_setup_signal | generator_engine_fifo_setup_signal;
        request_engine_out.valid <= request_engine_out_int.valid;
        request_memory_out.valid <= request_memory_out_int.valid;
        done_out                 <= generator_engine_done_out & fifo_empty_reg;
        fifo_empty_reg           <= fifo_empty_int;
    end
end

assign fifo_empty_int = arbiter_1_to_N_memory_fifo_response_signals_out.empty & configure_memory_fifo_response_memory_in_signals_out.empty & configure_memory_fifo_configure_memory_signals_out.empty;

always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_signals_out <= generator_engine_fifo_response_engine_in_signals_out;
    fifo_request_engine_out_signals_out <= generator_engine_fifo_request_engine_out_signals_out;
    fifo_response_memory_in_signals_out <= arbiter_1_to_N_memory_fifo_response_signals_out;
    fifo_request_memory_out_signals_out <= generator_engine_fifo_request_memory_out_signals_out;
    request_engine_out.payload          <= request_engine_out_int.payload;
    request_memory_out.payload          <= request_memory_out_int.payload ;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_engine_in_int = response_engine_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_memory_in_int = response_memory_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_engine_out_int = generator_engine_request_engine_out;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_memory_out_int = generator_engine_request_memory_out;

// --------------------------------------------------------------------------------------
// Generate Engine - Engine Logic Pipeline
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Configuration modules
// --------------------------------------------------------------------------------------
assign configure_fifo_setup_signal = configure_memory_fifo_setup_signal | arbiter_1_to_N_memory_fifo_setup_signal;

// --------------------------------------------------------------------------------------
// Generate Response - Signals
// --------------------------------------------------------------------------------------
// Generate Response - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
assign arbiter_1_to_N_memory_response_in = response_memory_in_int;
always_comb begin
    for (int i=0; i<NUM_MODULES; i++) begin : generate_arbiter_1_to_N_memory_response
        arbiter_1_to_N_memory_fifo_response_signals_in[i].rd_en = ~modules_fifo_response_memory_in_signals_out[i].prog_full & fifo_response_memory_in_signals_in_reg.rd_en;
        modules_response_memory_in[i] = arbiter_1_to_N_memory_response_out[i];
        modules_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
    end
end

// --------------------------------------------------------------------------------------
arbiter_1_to_N_response_memory #(
    .NUM_MEMORY_RECEIVER(2),
    .ID_LEVEL           (4)
) inst_arbiter_1_to_N_memory_response_in (
    .ap_clk                   (ap_clk                                         ),
    .areset                   (areset_arbiter_1_to_N_memory                   ),
    .response_in              (arbiter_1_to_N_memory_response_in              ),
    .fifo_response_signals_in (arbiter_1_to_N_memory_fifo_response_signals_in ),
    .fifo_response_signals_out(arbiter_1_to_N_memory_fifo_response_signals_out),
    .response_out             (arbiter_1_to_N_memory_response_out             ),
    .fifo_setup_signal        (arbiter_1_to_N_memory_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
// Configuration module - Memory permanent
// --------------------------------------------------------------------------------------
assign configure_memory_fifo_configure_memory_signals_in.rd_en = generator_engine_configure_memory_setup;

assign configure_memory_response_memory_in                       = modules_response_memory_in[0];
assign configure_memory_fifo_response_memory_in_signals_in.rd_en = modules_fifo_response_memory_in_signals_in[0].rd_en;

assign modules_fifo_response_memory_in_signals_out[0] = configure_memory_fifo_response_memory_in_signals_out;

engine_parallel_read_write_configure_memory #(
    .ID_CU           (ID_CU           ),
    .ID_BUNDLE       (ID_BUNDLE       ),
    .ID_LANE         (ID_LANE         ),
    .ID_ENGINE       (ID_ENGINE       ),
    .ID_RELATIVE     (ID_RELATIVE     ),
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH),
    .PROG_THRESH     (PROG_THRESH     ),
    .ENGINE_SEQ_WIDTH(ENGINE_SEQ_WIDTH),
    .ENGINE_SEQ_MIN  (ENGINE_SEQ_MIN  ),
    .ID_MODULE       (0               )
) inst_engine_parallel_read_write_configure_memory (
    .ap_clk                             (ap_clk                                              ),
    .areset                             (areset_configure_memory                             ),
    .response_memory_in                 (configure_memory_response_memory_in                 ),
    .fifo_response_memory_in_signals_in (configure_memory_fifo_response_memory_in_signals_in ),
    .fifo_response_memory_in_signals_out(configure_memory_fifo_response_memory_in_signals_out),
    .configure_memory_out               (configure_memory_out                                ),
    .fifo_configure_memory_signals_in   (configure_memory_fifo_configure_memory_signals_in   ),
    .fifo_configure_memory_signals_out  (configure_memory_fifo_configure_memory_signals_out  ),
    .fifo_setup_signal                  (configure_memory_fifo_setup_signal                  )
);

// --------------------------------------------------------------------------------------
// Generation module - Memory/Engine Config -> Gen
// --------------------------------------------------------------------------------------
assign generator_engine_configure_memory_in                       = configure_memory_out;
assign generator_engine_fifo_configure_memory_in_signals_in.rd_en = ~configure_memory_fifo_configure_memory_signals_out.empty;

assign generator_engine_response_engine_in                       = response_engine_in_int;
assign generator_engine_fifo_response_engine_in_signals_in.rd_en = fifo_response_engine_in_signals_in_reg.rd_en;

assign generator_engine_response_memory_in                       = modules_response_memory_in[1];
assign generator_engine_fifo_response_memory_in_signals_in.rd_en = modules_fifo_response_memory_in_signals_in[1].rd_en;
assign modules_fifo_response_memory_in_signals_out[1]            = generator_engine_fifo_response_memory_in_signals_out;

assign generator_engine_fifo_request_engine_out_signals_in.rd_en = fifo_request_engine_out_signals_in_reg.rd_en;

assign generator_engine_fifo_request_memory_out_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
assign generator_fifo_response_lanes_backtrack_signals_in     = fifo_response_lanes_backtrack_signals_in;
assign generator_fifo_request_memory_out_backtrack_signals_in = fifo_request_memory_out_backtrack_signals_in;

engine_parallel_read_write_generator #(
    .ID_CU              (ID_CU              ),
    .ID_BUNDLE          (ID_BUNDLE          ),
    .ID_LANE            (ID_LANE            ),
    .ID_ENGINE          (ID_ENGINE          ),
    .ID_MODULE          (1                  ),
    .ENGINES_CONFIG     (ENGINES_CONFIG     ),
    .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
    .PROG_THRESH        (PROG_THRESH        ),
    .PIPELINE_STAGES    (PIPELINE_STAGES    ),
    .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
    .NUM_CHANNELS       (NUM_CHANNELS       ),
    .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
    .NUM_BUNDLES        (NUM_BUNDLES        )
) inst_engine_parallel_read_write_generator (
    .ap_clk                                      (ap_clk                                                ),
    .areset                                      (areset_generator                                      ),
    .configure_memory_in                         (generator_engine_configure_memory_in                  ),
    .fifo_configure_memory_in_signals_in         (generator_engine_fifo_configure_memory_in_signals_in  ),
    .response_engine_in                          (generator_engine_response_engine_in                   ),
    .fifo_response_engine_in_signals_in          (generator_engine_fifo_response_engine_in_signals_in   ),
    .fifo_response_engine_in_signals_out         (generator_engine_fifo_response_engine_in_signals_out  ),
    .fifo_response_lanes_backtrack_signals_in    (generator_fifo_response_lanes_backtrack_signals_in    ),
    .response_memory_in                          (generator_engine_response_memory_in                   ),
    .fifo_response_memory_in_signals_in          (generator_engine_fifo_response_memory_in_signals_in   ),
    .fifo_response_memory_in_signals_out         (generator_engine_fifo_response_memory_in_signals_out  ),
    .request_engine_out                          (generator_engine_request_engine_out                   ),
    .fifo_request_engine_out_signals_in          (generator_engine_fifo_request_engine_out_signals_in   ),
    .fifo_request_engine_out_signals_out         (generator_engine_fifo_request_engine_out_signals_out  ),
    .request_memory_out                          (generator_engine_request_memory_out                   ),
    .fifo_request_memory_out_signals_in          (generator_engine_fifo_request_memory_out_signals_in   ),
    .fifo_request_memory_out_signals_out         (generator_engine_fifo_request_memory_out_signals_out  ),
    .fifo_request_memory_out_backtrack_signals_in(generator_fifo_request_memory_out_backtrack_signals_in),
    .fifo_setup_signal                           (generator_engine_fifo_setup_signal                    ),
    .configure_memory_setup                      (generator_engine_configure_memory_setup               ),
    .done_out                                    (generator_engine_done_out                             )
);

endmodule : engine_parallel_read_write
