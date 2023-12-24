// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_filter_cond.sv
// Create : 2023-07-17 14:42:46
// Revise : 2023-08-28 15:49:58
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_filter_cond #(parameter
    ID_CU              = 0                             ,
    ID_BUNDLE          = 0                             ,
    ID_LANE            = 0                             ,
    ID_ENGINE          = 0                             ,
    ID_RELATIVE        = 0                             ,
    ENGINE_CAST_WIDTH  = 0                             ,
    ENGINE_MERGE_WIDTH = 0                             ,
    ENGINES_CONFIG     = 0                             ,
    MERGE_WIDTH        = 1                             ,
    FIFO_WRITE_DEPTH   = 32                            ,
    PROG_THRESH        = 16                            ,
    NUM_MODULES        = 2                             ,
    NUM_LANES_MAX      = 4                             ,
    NUM_BUNDLES_MAX    = 4                             , 
    ENGINE_SEQ_WIDTH   = 16                            ,
    ENGINE_SEQ_MIN     = ID_RELATIVE * ENGINE_SEQ_WIDTH,
    PIPELINE_STAGES    = 2
) (
    // System Signals
    input  logic                  ap_clk                                                     ,
    input  logic                  areset                                                     ,
    input  KernelDescriptor       descriptor_in                                              ,
    input  MemoryPacket           response_engine_in                                         ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in                         ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out                        ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_LANES_MAX-1:0],
    input  MemoryPacket           response_memory_in                                         ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                         ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                        ,
    input  MemoryPacket           response_control_in                                        ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in                        ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out                       ,
    output MemoryPacket           request_engine_out                                         ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in                         ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out                        ,
    output MemoryPacket           request_memory_out                                         ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                         ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                        ,
    output MemoryPacket           request_control_out                                        ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in                        ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out                       ,
    output logic                  fifo_setup_signal                                          ,
    output logic                  done_out
);

assign fifo_request_memory_out_signals_out  = 2'b10;
assign fifo_response_control_in_signals_out = 2'b10;
assign request_memory_out                   = 0;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_filter_cond_engine;
logic areset_configure_memory  ;
logic areset_generator         ;

KernelDescriptor descriptor_in_reg;

MemoryPacket request_control_out_int;
MemoryPacket request_engine_out_int ;
MemoryPacket response_engine_in_int ;
MemoryPacket response_engine_in_reg ;
MemoryPacket response_memory_in_int ;
MemoryPacket response_memory_in_reg ;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_engine_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO CONTROL OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_control_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// ENGINE CONFIGURATION AND GENERATION LOGIC
// --------------------------------------------------------------------------------------
logic configure_fifo_setup_signal;

FIFOStateSignalsInput   configure_memory_fifo_configure_memory_signals_in   ;
FIFOStateSignalsInput   configure_memory_fifo_response_memory_in_signals_in ;
FIFOStateSignalsOutput  configure_memory_fifo_configure_memory_signals_out  ;
FIFOStateSignalsOutput  configure_memory_fifo_response_memory_in_signals_out;
FilterCondConfiguration configure_memory_out                                ;
logic                   configure_memory_fifo_setup_signal                  ;
MemoryPacket            configure_memory_response_memory_in                 ;

// --------------------------------------------------------------------------------------
// Generation module - Memory/Engine Config -> Gen
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput   generator_engine_fifo_configure_memory_in_signals_in ;
FIFOStateSignalsInput   generator_engine_fifo_response_engine_in_signals_in  ;
FIFOStateSignalsInput   generator_engine_fifo_request_control_out_signals_in ;
FIFOStateSignalsInput   generator_engine_fifo_request_engine_out_signals_in  ;
FIFOStateSignalsOutput  generator_engine_fifo_response_engine_in_signals_out ;
FIFOStateSignalsOutput  generator_engine_fifo_request_engine_out_signals_out ;
FIFOStateSignalsOutput  generator_engine_fifo_request_control_out_signals_out;
FilterCondConfiguration generator_engine_configure_memory_in                 ;
MemoryPacket            generator_engine_response_engine_in                  ;
MemoryPacket            generator_engine_request_control_out                 ;
MemoryPacket            generator_engine_request_engine_out                  ;

logic generator_engine_fifo_setup_signal     ;
logic generator_engine_configure_memory_setup;
logic generator_engine_done_out              ;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
logic                  areset_backtrack                                                     ;
logic                  backtrack_configure_route_valid                                      ;
MemoryPacketArbitrate  backtrack_configure_route_in                                         ;
FIFOStateSignalsInput  backtrack_fifo_response_engine_in_signals_in                         ;
FIFOStateSignalsOutput backtrack_fifo_response_lanes_backtrack_signals_in[NUM_LANES_MAX-1:0];
FIFOStateSignalsInput  backtrack_fifo_response_engine_in_signals_out                        ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_configure_memory   <= areset;
    areset_filter_cond_engine <= areset;
    areset_generator          <= areset;
    areset_backtrack          <= areset;
end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_filter_cond_engine) begin
        descriptor_in_reg.valid <= 1'b0;
    end
    else begin
        descriptor_in_reg.valid <= descriptor_in.valid;
    end
end

always_ff @(posedge ap_clk) begin
    descriptor_in_reg.payload <= descriptor_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_filter_cond_engine) begin
        fifo_request_engine_out_signals_in_reg  <= 0;
        fifo_request_control_out_signals_in_reg <= 0;
        fifo_response_memory_in_signals_in_reg  <= 0;
        response_memory_in_reg.valid            <= 1'b0;
    end
    else begin
        fifo_request_engine_out_signals_in_reg  <= fifo_request_engine_out_signals_in;
        fifo_request_control_out_signals_in_reg <= fifo_request_control_out_signals_in;
        fifo_response_memory_in_signals_in_reg  <= fifo_response_memory_in_signals_in;
        response_memory_in_reg.valid            <= response_memory_in.valid ;
    end
end

always_ff @(posedge ap_clk) begin
    response_memory_in_reg.payload <= response_memory_in.payload;
end

always_ff @(posedge ap_clk) begin
    if (areset_filter_cond_engine) begin
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
    if (areset_filter_cond_engine) begin
        done_out                  <= 1'b0;
        fifo_empty_reg            <= 1'b1;
        fifo_setup_signal         <= 1'b1;
        request_engine_out.valid  <= 1'b0;
        request_control_out.valid <= 1'b0;
    end
    else begin
        done_out                  <= generator_engine_done_out & fifo_empty_reg;
        fifo_empty_reg            <= fifo_empty_int;
        fifo_setup_signal         <= configure_fifo_setup_signal | generator_engine_fifo_setup_signal;
        request_engine_out.valid  <= request_engine_out_int.valid;
        request_control_out.valid <= request_control_out_int.valid;
    end
end

assign fifo_empty_int = configure_memory_fifo_response_memory_in_signals_out.empty & configure_memory_fifo_configure_memory_signals_out.empty;

always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_signals_out  <= generator_engine_fifo_response_engine_in_signals_out;
    fifo_request_engine_out_signals_out  <= generator_engine_fifo_request_engine_out_signals_out;
    fifo_request_control_out_signals_out <= generator_engine_fifo_request_control_out_signals_out;
    fifo_response_memory_in_signals_out  <= configure_memory_fifo_response_memory_in_signals_out;
    request_engine_out.payload           <= request_engine_out_int.payload;
    request_control_out.payload          <= request_control_out_int.payload;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response MemoryPacket
// --------------------------------------------------------------------------------------
assign response_engine_in_int = response_engine_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
assign response_memory_in_int = response_memory_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests MemoryPacket
// --------------------------------------------------------------------------------------
assign request_engine_out_int = generator_engine_request_engine_out;

// --------------------------------------------------------------------------------------
// FIFO CONTROL OUTPUT Engine requests MemoryPacket
// --------------------------------------------------------------------------------------
assign request_control_out_int = generator_engine_request_control_out;

// --------------------------------------------------------------------------------------
// Configuration modules
// --------------------------------------------------------------------------------------
assign configure_fifo_setup_signal = configure_memory_fifo_setup_signal;

// --------------------------------------------------------------------------------------
// Configuration module - Memory permanent
// --------------------------------------------------------------------------------------
assign configure_memory_fifo_configure_memory_signals_in.rd_en = generator_engine_configure_memory_setup;

assign configure_memory_response_memory_in                       = response_memory_in_int;
assign configure_memory_fifo_response_memory_in_signals_in.rd_en = fifo_response_memory_in_signals_in_reg.rd_en;

engine_filter_cond_configure_memory #(
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
) inst_engine_filter_cond_configure_memory (
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

assign generator_engine_response_engine_in                       = response_engine_in_int ;
assign generator_engine_fifo_response_engine_in_signals_in.rd_en = fifo_response_engine_in_signals_in_reg.rd_en;

assign generator_engine_fifo_request_engine_out_signals_in.rd_en  = backtrack_fifo_response_engine_in_signals_out.rd_en & ~generator_engine_fifo_request_control_out_signals_out.prog_full;
assign generator_engine_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;

engine_filter_cond_generator #(
    .ID_CU             (ID_CU             ),
    .ID_BUNDLE         (ID_BUNDLE         ),
    .ID_LANE           (ID_LANE           ),
    .ID_ENGINE         (ID_ENGINE         ),
    .ID_MODULE         (1                 ),
    .ENGINE_CAST_WIDTH (ENGINE_CAST_WIDTH ),
    .ENGINE_MERGE_WIDTH(ENGINE_MERGE_WIDTH),
    .ENGINES_CONFIG    (ENGINES_CONFIG    ),
    .FIFO_WRITE_DEPTH  (FIFO_WRITE_DEPTH  ),
    .PROG_THRESH       (PROG_THRESH       ),
    .PIPELINE_STAGES   (PIPELINE_STAGES   )
) inst_engine_filter_cond_generator (
    .ap_clk                              (ap_clk                                               ),
    .areset                              (areset_generator                                     ),
    .descriptor_in                       (descriptor_in_reg                                    ),
    .configure_memory_in                 (generator_engine_configure_memory_in                 ),
    .fifo_configure_memory_in_signals_in (generator_engine_fifo_configure_memory_in_signals_in ),
    .response_engine_in                  (generator_engine_response_engine_in                  ),
    .fifo_response_engine_in_signals_in  (generator_engine_fifo_response_engine_in_signals_in  ),
    .fifo_response_engine_in_signals_out (generator_engine_fifo_response_engine_in_signals_out ),
    .request_engine_out                  (generator_engine_request_engine_out                  ),
    .fifo_request_engine_out_signals_in  (generator_engine_fifo_request_engine_out_signals_in  ),
    .fifo_request_engine_out_signals_out (generator_engine_fifo_request_engine_out_signals_out ),
    .request_control_out                 (generator_engine_request_control_out                 ),
    .fifo_request_control_out_signals_in (generator_engine_fifo_request_control_out_signals_in ),
    .fifo_request_control_out_signals_out(generator_engine_fifo_request_control_out_signals_out),
    .fifo_setup_signal                   (generator_engine_fifo_setup_signal                   ),
    .configure_memory_setup              (generator_engine_configure_memory_setup              ),
    .done_out                            (generator_engine_done_out                            )
);

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
assign backtrack_configure_route_valid                    = configure_memory_out.valid;
assign backtrack_configure_route_in                       = configure_memory_out.payload.meta.route.to;
assign backtrack_fifo_response_engine_in_signals_in       = fifo_request_engine_out_signals_in_reg;
assign backtrack_fifo_response_lanes_backtrack_signals_in = fifo_response_lanes_backtrack_signals_in;

backtrack_fifo_lanes_response_signal #(
    .ID_CU          (ID_CU          ),
    .ID_BUNDLE      (ID_BUNDLE      ),
    .ID_LANE        (ID_LANE        ),
    .ID_ENGINE      (ID_ENGINE      ),
    .ID_MODULE      (2              ),
    .NUM_LANES_MAX  (NUM_LANES_MAX  ),
    .NUM_BUNDLES_MAX(NUM_BUNDLES_MAX)
) inst_backtrack_fifo_lanes_response_signal (
    .ap_clk                                  (ap_clk                                            ),
    .areset                                  (areset_backtrack                                  ),
    .configure_route_valid                   (backtrack_configure_route_valid                   ),
    .configure_route_in                      (backtrack_configure_route_in                      ),
    .fifo_response_engine_in_signals_in      (backtrack_fifo_response_engine_in_signals_in      ),
    .fifo_response_lanes_backtrack_signals_in(backtrack_fifo_response_lanes_backtrack_signals_in),
    .fifo_response_engine_in_signals_out     (backtrack_fifo_response_engine_in_signals_out     )
);

endmodule : engine_filter_cond