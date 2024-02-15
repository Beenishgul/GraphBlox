// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : lane_template.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-08-28 14:16:13
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module lane_template #(
    `include "lane_parameters.vh"
) (
    // System Signals
    input  logic                  ap_clk                                                           ,
    input  logic                  areset                                                           ,
    input  EnginePacket           response_lane_in[(1+LANE_MERGE_WIDTH)-1:0]                       ,
    input  FIFOStateSignalsInput  fifo_response_lane_in_signals_in[(1+LANE_MERGE_WIDTH)-1:0]       ,
    output FIFOStateSignalsOutput fifo_response_lane_in_signals_out[(1+LANE_MERGE_WIDTH)-1:0]      ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES-1:0],
    input  MemoryPacketResponse   response_memory_in                                               ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                               ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                              ,
    input  ControlPacket          response_control_in                                              ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in                              ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out                             ,
    output EnginePacket           request_lane_out[ (1+LANE_CAST_WIDTH)-1:0]                       ,
    input  FIFOStateSignalsInput  fifo_request_lane_out_signals_in[ (1+LANE_CAST_WIDTH)-1:0]       ,
    output FIFOStateSignalsOutput fifo_request_lane_out_signals_out[ (1+LANE_CAST_WIDTH)-1:0]      ,
    output MemoryPacketRequest    request_memory_out                                               ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                               ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                              ,
    input  FIFOStateSignalsOutput fifo_request_memory_out_backtrack_signals_in[NUM_CHANNELS-1:0]   ,
    output ControlPacket          request_control_out                                              ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in                              ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out                             ,
    output logic                  fifo_setup_signal                                                ,
    output logic                  done_out
);

genvar i;
genvar j;
genvar k;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_lane_template;

ControlPacket        request_control_out_int;
EnginePacket         request_lane_out_int   ;
MemoryPacketRequest  request_memory_out_int ;
ControlPacket        response_control_in_int;
ControlPacket        response_control_in_reg;
EnginePacket         response_lane_in_int   ;
EnginePacket         response_lane_in_reg   ;
MemoryPacketResponse response_memory_in_int ;
MemoryPacketResponse response_memory_in_reg ;

logic fifo_empty_int;
logic fifo_empty_reg;
// --------------------------------------------------------------------------------------
// FIFO Engines INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_lane_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_control_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Engines OUTPUT Request EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_lane_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_memory_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL Request CONTROL EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_control_out_signals_in_reg;


// --------------------------------------------------------------------------------------
// Generate FIFO backtrack signals - Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsOutput engines_fifo_response_lanes_backtrack_signals_in_reg    [NUM_ENGINES-1:0][NUM_BACKTRACK_LANES-1:0];
FIFOStateSignalsOutput engines_fifo_request_memory_out_backtrack_signals_in_reg[NUM_ENGINES-1:0][       NUM_CHANNELS-1:0];

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput   engine_arbiter_N_to_1_memory_fifo_request_signals_in                  ;
FIFOStateSignalsOutput  engine_arbiter_N_to_1_memory_fifo_request_signals_out                 ;
logic                   areset_engine_arbiter_N_to_1_memory                                   ;
logic                   engine_arbiter_N_to_1_memory_fifo_setup_signal                        ;
logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_memory_engine_arbiter_grant_out                 ;
MemoryPacketRequest     engine_arbiter_N_to_1_memory_request_in              [NUM_ENGINES-1:0];
MemoryPacketRequest     engine_arbiter_N_to_1_memory_request_out                              ;

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: CONTROL Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput   engine_arbiter_N_to_1_control_fifo_request_signals_in                  ;
FIFOStateSignalsOutput  engine_arbiter_N_to_1_control_fifo_request_signals_out                 ;
logic                   areset_engine_arbiter_N_to_1_control                                   ;
logic                   engine_arbiter_N_to_1_control_fifo_setup_signal                        ;
logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_control_engine_arbiter_grant_out                 ;
ControlPacket           engine_arbiter_N_to_1_control_request_in              [NUM_ENGINES-1:0];
ControlPacket           engine_arbiter_N_to_1_control_request_out                              ;

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  engine_arbiter_1_to_N_memory_fifo_response_signals_in [NUM_ENGINES-1:0];
FIFOStateSignalsOutput engine_arbiter_1_to_N_memory_fifo_response_signals_out                 ;
logic                  areset_engine_arbiter_1_to_N_memory                                    ;
logic                  engine_arbiter_1_to_N_memory_fifo_setup_signal                         ;
MemoryPacketResponse   engine_arbiter_1_to_N_memory_response_in                               ;
MemoryPacketResponse   engine_arbiter_1_to_N_memory_response_out             [NUM_ENGINES-1:0];

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  engine_arbiter_1_to_N_control_fifo_response_signals_in [NUM_ENGINES-1:0];
FIFOStateSignalsOutput engine_arbiter_1_to_N_control_fifo_response_signals_out                 ;
logic                  areset_engine_arbiter_1_to_N_control                                    ;
logic                  engine_arbiter_1_to_N_control_fifo_setup_signal                         ;
ControlPacket          engine_arbiter_1_to_N_control_response_in                               ;
ControlPacket          engine_arbiter_1_to_N_control_response_out             [NUM_ENGINES-1:0];

// --------------------------------------------------------------------------------------
// Generate Engines
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput   engines_fifo_request_control_out_signals_in [NUM_ENGINES-1:0];
FIFOStateSignalsInput   engines_fifo_request_lane_out_signals_in    [NUM_ENGINES-1:0];
FIFOStateSignalsInput   engines_fifo_request_memory_out_signals_in  [NUM_ENGINES-1:0];
FIFOStateSignalsInput   engines_fifo_response_control_in_signals_in [NUM_ENGINES-1:0];
FIFOStateSignalsInput   engines_fifo_response_lane_in_signals_in    [NUM_ENGINES-1:0];
FIFOStateSignalsInput   engines_fifo_response_memory_in_signals_in  [NUM_ENGINES-1:0];
FIFOStateSignalsOutput  engines_fifo_request_control_out_signals_out[NUM_ENGINES-1:0];
FIFOStateSignalsOutput  engines_fifo_request_lane_out_signals_out   [NUM_ENGINES-1:0];
FIFOStateSignalsOutput  engines_fifo_request_memory_out_signals_out [NUM_ENGINES-1:0];
FIFOStateSignalsOutput  engines_fifo_response_control_in_signals_out[NUM_ENGINES-1:0];
FIFOStateSignalsOutput  engines_fifo_response_lane_in_signals_out   [NUM_ENGINES-1:0];
FIFOStateSignalsOutput  engines_fifo_response_memory_in_signals_out [NUM_ENGINES-1:0];
logic                   areset_engine                               [NUM_ENGINES-1:0];
logic                   engines_done_out                            [NUM_ENGINES-1:0];
logic                   engines_fifo_setup_signal                   [NUM_ENGINES-1:0];
logic [NUM_ENGINES-1:0] engines_done_out_reg                                         ;
logic [NUM_ENGINES-1:0] engines_fifo_setup_signal_reg                                ;
ControlPacket           engines_request_control_out                 [NUM_ENGINES-1:0];
EnginePacket            engines_request_lane_out                    [NUM_ENGINES-1:0];
EnginePacket            engines_request_lane_out_int                                 ;
MemoryPacketRequest     engines_request_memory_out                  [NUM_ENGINES-1:0];
ControlPacket           engines_response_control_in                 [NUM_ENGINES-1:0];
EnginePacket            engines_response_lane_in                    [NUM_ENGINES-1:0];
MemoryPacketResponse    engines_response_memory_in                  [NUM_ENGINES-1:0];

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  engines_fifo_request_cast_lane_out_signals_in  [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
FIFOStateSignalsInput  engines_fifo_response_merge_lane_in_signals_in [NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];
FIFOStateSignalsOutput engines_fifo_request_cast_lane_out_signals_out [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
FIFOStateSignalsOutput engines_fifo_response_merge_lane_in_signals_out[NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];
EnginePacket           engines_request_cast_lane_out                  [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
EnginePacket           engines_response_merge_lane_in                 [NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_engine_arbiter_1_to_N_control <= areset;
    areset_engine_arbiter_1_to_N_memory  <= areset;
    areset_engine_arbiter_N_to_1_control <= areset;
    areset_engine_arbiter_N_to_1_memory  <= areset;
    areset_lane_template                 <= areset;
end

// --------------------------------------------------------------------------------------
// Generate FIFO backtrack signals - Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
generate
    for (j=0; j<NUM_ENGINES; j++) begin  : generate_response_lanes_backtrack_signals_engines
        for (i=0; i<NUM_BACKTRACK_LANES; i++) begin  : generate_response_lanes_backtrack_signals
            always_ff @(posedge ap_clk) begin
                engines_fifo_response_lanes_backtrack_signals_in_reg[j][i] <= fifo_response_lanes_backtrack_signals_in[i];
            end
        end
        for (i=0; i<NUM_CHANNELS; i++) begin  : generate_request_memory_out_backtrack_signals
            always_ff @(posedge ap_clk) begin
                engines_fifo_request_memory_out_backtrack_signals_in_reg[j][i] <= fifo_request_memory_out_backtrack_signals_in[i];
            end
        end
    end
endgenerate

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_lane_template) begin
        fifo_request_control_out_signals_in_reg <= 0;
        fifo_request_lane_out_signals_in_reg    <= 0;
        fifo_request_memory_out_signals_in_reg  <= 0;
        fifo_response_control_in_signals_in_reg <= 0;
        fifo_response_lane_in_signals_in_reg    <= 0;
        fifo_response_memory_in_signals_in_reg  <= 0;
        response_control_in_reg.valid           <= 1'b0;
        response_lane_in_reg.valid              <= 1'b0;
        response_memory_in_reg.valid            <= 1'b0;
    end
    else begin
        fifo_request_control_out_signals_in_reg <= fifo_request_control_out_signals_in;
        fifo_request_lane_out_signals_in_reg    <= fifo_request_lane_out_signals_in[0];
        fifo_request_memory_out_signals_in_reg  <= fifo_request_memory_out_signals_in;
        fifo_response_control_in_signals_in_reg <= fifo_response_control_in_signals_in;
        fifo_response_lane_in_signals_in_reg    <= fifo_response_lane_in_signals_in[0];
        fifo_response_memory_in_signals_in_reg  <= fifo_response_memory_in_signals_in;
        response_control_in_reg.valid           <= response_control_in.valid ;
        response_lane_in_reg.valid              <= response_lane_in[0].valid;
        response_memory_in_reg.valid            <= response_memory_in.valid ;
    end
end

always_ff @(posedge ap_clk) begin
    response_control_in_reg.payload <= response_control_in.payload;
    response_lane_in_reg.payload    <= response_lane_in[0].payload;
    response_memory_in_reg.payload  <= response_memory_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_lane_template) begin
        done_out                  <= 1'b0;
        fifo_empty_reg            <= 1'b1;
        fifo_setup_signal         <= 1'b1;
        request_control_out.valid <= 1'b0;
        request_lane_out[0].valid <= 1'b0;
        request_memory_out.valid  <= 1'b0;
    end
    else begin
        done_out                  <= (&engines_done_out_reg) & fifo_empty_reg;
        fifo_empty_reg            <= fifo_empty_int;
        fifo_setup_signal         <= engine_arbiter_N_to_1_memory_fifo_setup_signal |  engine_arbiter_N_to_1_control_fifo_setup_signal |  engine_arbiter_1_to_N_memory_fifo_setup_signal | engine_arbiter_1_to_N_control_fifo_setup_signal | (|engines_fifo_setup_signal_reg);
        request_control_out.valid <= request_control_out_int.valid;
        request_lane_out[0].valid <= request_lane_out_int.valid ;
        request_memory_out.valid  <= request_memory_out_int.valid;
    end
end

assign fifo_empty_int = engine_arbiter_1_to_N_control_fifo_response_signals_out.empty & engine_arbiter_N_to_1_memory_fifo_request_signals_out.empty & engine_arbiter_N_to_1_control_fifo_request_signals_out.empty & engine_arbiter_1_to_N_memory_fifo_response_signals_out.empty;

always_ff @(posedge ap_clk) begin
    fifo_request_control_out_signals_out <= engine_arbiter_N_to_1_control_fifo_request_signals_out;
    fifo_request_lane_out_signals_out[0] <= engines_fifo_request_lane_out_signals_out[NUM_ENGINES-1];
    fifo_request_memory_out_signals_out  <= engine_arbiter_N_to_1_memory_fifo_request_signals_out;
    fifo_response_control_in_signals_out <= engine_arbiter_1_to_N_control_fifo_response_signals_out;
    fifo_response_lane_in_signals_out[0] <= engines_fifo_response_lane_in_signals_out[0];
    fifo_response_memory_in_signals_out  <= engine_arbiter_1_to_N_memory_fifo_response_signals_out;
    request_control_out.payload          <= request_control_out_int.payload ;
    request_lane_out[0].payload          <= request_lane_out_int.payload;
    request_memory_out.payload           <= request_memory_out_int.payload ;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engines Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_lane_in_int = response_lane_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_memory_in_int = response_memory_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_control_in_int = response_control_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engines requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_lane_out_int = engines_request_lane_out_int;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_memory_out_int = engine_arbiter_N_to_1_memory_request_out;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_control_out_int = engine_arbiter_N_to_1_control_request_out;

// --------------------------------------------------------------------------------------
// Generate Engines
// --------------------------------------------------------------------------------------
// Generate Engines - Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    for (int i=0; i< NUM_ENGINES; i++) begin
        areset_engine[i] <= areset;
    end
end

// --------------------------------------------------------------------------------------
// Generate Engines - Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_lane_template) begin
        for (int i=0; i< NUM_ENGINES; i++) begin
            engines_fifo_setup_signal_reg[i] <= 1'b1;
            engines_done_out_reg[i]          <= 1'b1;
        end
    end
    else begin
        for (int i=0; i< NUM_ENGINES; i++) begin
            engines_fifo_setup_signal_reg[i] <= engines_fifo_setup_signal[i];
            engines_done_out_reg[i]          <= engines_done_out[i];
        end
    end
end

// --------------------------------------------------------------------------------------
// Generate Engines - Drive Intra-signals
// --------------------------------------------------------------------------------------
// Generate Engines - in->[0]->[1]->[2]->[3]->[4]->out
// --------------------------------------------------------------------------------------
assign engines_response_lane_in[0] = response_lane_in_int;
assign engines_fifo_response_lane_in_signals_in[0].rd_en = 1'b1; // fifo_response_lane_in_signals_in_reg.rd_en

generate
    for (i=1; i<NUM_ENGINES; i++) begin : generate_lane_template_intra_signals
        assign engines_response_lane_in[i] = engines_request_lane_out[i-1];
        assign engines_fifo_request_lane_out_signals_in[i-1].rd_en = ~engines_fifo_response_lane_in_signals_out[i].prog_full ;
        assign engines_fifo_response_lane_in_signals_in[i].rd_en = 1'b1;
    end
endgenerate

assign engines_request_lane_out_int = engines_request_lane_out[NUM_ENGINES-1];
assign engines_fifo_request_lane_out_signals_in[NUM_ENGINES-1].rd_en = fifo_request_lane_out_signals_in_reg.rd_en;

// --------------------------------------------------------------------------------------
// Generate Engines - Memory Arbitration
// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
generate
    if(ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY>0) begin
        arbiter_N_to_1_request_memory #(
            .NUM_MEMORY_REQUESTOR(ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY      ),
            .FIFO_ARBITER_DEPTH  (ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY)
        ) inst_engine_arbiter_N_to_1_memory_request_out (
            .ap_clk                  (ap_clk                                                                                           ),
            .areset                  (areset_engine_arbiter_N_to_1_memory                                                              ),
            .request_in              (engine_arbiter_N_to_1_memory_request_in[ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY-1:0]              ),
            .fifo_request_signals_in (engine_arbiter_N_to_1_memory_fifo_request_signals_in                                             ),
            .fifo_request_signals_out(engine_arbiter_N_to_1_memory_fifo_request_signals_out                                            ),
            .arbiter_grant_out       (engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY-1:0]),
            .request_out             (engine_arbiter_N_to_1_memory_request_out                                                         ),
            .fifo_setup_signal       (engine_arbiter_N_to_1_memory_fifo_setup_signal                                                   )
        );
    end else begin
        for (i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_N_to_1_memory_request_in
            assign engines_fifo_request_memory_out_signals_in[i].rd_en      = 1'b1;
            assign engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[i] = 1'b0;
            assign engine_arbiter_N_to_1_memory_request_in[i]               = 0;
        end
        assign engine_arbiter_N_to_1_memory_fifo_request_signals_in  = 1'b0;
        assign engine_arbiter_N_to_1_memory_fifo_request_signals_out = 2'b10;
        assign engine_arbiter_N_to_1_memory_request_out              = 0;
        assign engine_arbiter_N_to_1_memory_fifo_setup_signal        = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Engines - CONTROL Arbitration
// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: CONTROL Request Generator
// --------------------------------------------------------------------------------------
generate
    if(ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST>0) begin
        arbiter_N_to_1_request_control #(
            .NUM_CONTROL_REQUESTOR(ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST      ),
            .FIFO_ARBITER_DEPTH   (ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST)
        ) inst_engine_arbiter_N_to_1_control_request_out (
            .ap_clk                  (ap_clk                                                                                                     ),
            .areset                  (areset_engine_arbiter_N_to_1_control                                                                       ),
            .request_in              (engine_arbiter_N_to_1_control_request_in[ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST-1:0]              ),
            .fifo_request_signals_in (engine_arbiter_N_to_1_control_fifo_request_signals_in                                                      ),
            .fifo_request_signals_out(engine_arbiter_N_to_1_control_fifo_request_signals_out                                                     ),
            .arbiter_grant_out       (engine_arbiter_N_to_1_control_engine_arbiter_grant_out[ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST-1:0]),
            .request_out             (engine_arbiter_N_to_1_control_request_out                                                                  ),
            .fifo_setup_signal       (engine_arbiter_N_to_1_control_fifo_setup_signal                                                            )
        );
    end else begin
        for (i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_N_to_1_control_request_in
            assign engines_fifo_request_control_out_signals_in[i].rd_en      = 1'b1;
            assign engine_arbiter_N_to_1_control_engine_arbiter_grant_out[i] = 1'b0;
            assign engine_arbiter_N_to_1_control_request_in[i]               = 0;
        end
        assign engine_arbiter_N_to_1_control_fifo_request_signals_in  = 1'b0;
        assign engine_arbiter_N_to_1_control_fifo_request_signals_out = 2'b10;
        assign engine_arbiter_N_to_1_control_request_out              = 0;
        assign engine_arbiter_N_to_1_control_fifo_setup_signal        = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
assign engine_arbiter_1_to_N_memory_response_in = response_memory_in_int;
generate
    for (i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_1_to_N_memory_response
        assign engine_arbiter_1_to_N_memory_fifo_response_signals_in[i].rd_en = ~engines_fifo_response_memory_in_signals_out[i].prog_full & fifo_response_memory_in_signals_in_reg.rd_en;
        assign engines_response_memory_in[i] = engine_arbiter_1_to_N_memory_response_out[i];
        assign engines_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
    end
endgenerate

// --------------------------------------------------------------------------------------
arbiter_1_to_N_response_memory #(
    .NUM_MEMORY_RECEIVER(NUM_ENGINES                                 ),
    .ID_LEVEL           (3                                           ),
    .FIFO_ARBITER_DEPTH (ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY)
) inst_engine_arbiter_1_to_N_memory_response_in (
    .ap_clk                   (ap_clk                                                ),
    .areset                   (areset_engine_arbiter_1_to_N_memory                   ),
    .response_in              (engine_arbiter_1_to_N_memory_response_in              ),
    .fifo_response_signals_in (engine_arbiter_1_to_N_memory_fifo_response_signals_in ),
    .fifo_response_signals_out(engine_arbiter_1_to_N_memory_fifo_response_signals_out),
    .response_out             (engine_arbiter_1_to_N_memory_response_out             ),
    .fifo_setup_signal        (engine_arbiter_1_to_N_memory_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: CONTROL Response Generator
// --------------------------------------------------------------------------------------
generate
    if(ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE>0) begin
// --------------------------------------------------------------------------------------
        assign engine_arbiter_1_to_N_control_response_in = response_control_in_int;

        for (i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_1_to_N_control_response
            assign engine_arbiter_1_to_N_control_fifo_response_signals_in[i].rd_en = ~engines_fifo_response_control_in_signals_out[i].prog_full & fifo_response_control_in_signals_in_reg.rd_en;
            assign engines_response_control_in[i] = engine_arbiter_1_to_N_control_response_out[i];
            assign engines_fifo_response_control_in_signals_in[i].rd_en = 1'b1;
        end
// --------------------------------------------------------------------------------------
        arbiter_1_to_N_response_control #(
            .NUM_CONTROL_RECEIVER(NUM_ENGINES                                           ),
            .ID_LEVEL            (3                                                     ),
            .FIFO_ARBITER_DEPTH  (ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)
        ) inst_engine_arbiter_1_to_N_control_response_in (
            .ap_clk                   (ap_clk                                                 ),
            .areset                   (areset_engine_arbiter_1_to_N_control                   ),
            .response_in              (engine_arbiter_1_to_N_control_response_in              ),
            .fifo_response_signals_in (engine_arbiter_1_to_N_control_fifo_response_signals_in ),
            .fifo_response_signals_out(engine_arbiter_1_to_N_control_fifo_response_signals_out),
            .response_out             (engine_arbiter_1_to_N_control_response_out             ),
            .fifo_setup_signal        (engine_arbiter_1_to_N_control_fifo_setup_signal        )
        );
// --------------------------------------------------------------------------------------
    end else begin
        for (i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_1_to_N_control_response
            assign engines_response_control_in[i] = 0;
            assign engines_fifo_response_control_in_signals_in[i].rd_en  = 1'b1;
            assign engine_arbiter_1_to_N_control_fifo_response_signals_in[i].rd_en = 1'b0;
            assign engine_arbiter_1_to_N_control_response_out[i] = 0;
        end
        assign engine_arbiter_1_to_N_control_fifo_response_signals_out = 2'b10;
        assign engine_arbiter_1_to_N_control_fifo_setup_signal         = 1'b0;
        assign engine_arbiter_1_to_N_control_response_in               = 0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
generate
    for (j=0; j<NUM_ENGINES; j++) begin : generate_engine_template
        engine_template #(
            `include"set_engine_parameters.vh"
        ) inst_engine_template (
            .ap_clk                                      (ap_clk                                                                                   ),
            .areset                                      (areset_engine[j]                                                                         ),
            .response_engine_in                          (engines_response_merge_lane_in[j][ENGINES_CONFIG_MERGE_WIDTH_ARRAY[j]:0]                 ),
            .fifo_response_engine_in_signals_in          (engines_fifo_response_merge_lane_in_signals_in[j][ENGINES_CONFIG_MERGE_WIDTH_ARRAY[j]:0] ),
            .fifo_response_engine_in_signals_out         (engines_fifo_response_merge_lane_in_signals_out[j][ENGINES_CONFIG_MERGE_WIDTH_ARRAY[j]:0]),
            .fifo_response_lanes_backtrack_signals_in    (engines_fifo_response_lanes_backtrack_signals_in_reg[j][NUM_BACKTRACK_LANES-1:0]         ),
            .response_memory_in                          (engines_response_memory_in[j]                                                            ),
            .fifo_response_memory_in_signals_in          (engines_fifo_response_memory_in_signals_in[j]                                            ),
            .fifo_response_memory_in_signals_out         (engines_fifo_response_memory_in_signals_out[j]                                           ),
            .response_control_in                         (engines_response_control_in[j]                                                           ),
            .fifo_response_control_in_signals_in         (engines_fifo_response_control_in_signals_in[j]                                           ),
            .fifo_response_control_in_signals_out        (engines_fifo_response_control_in_signals_out[j]                                          ),
            .request_engine_out                          (engines_request_cast_lane_out[j][ENGINES_CONFIG_CAST_WIDTH_ARRAY[j]:0]                   ),
            .fifo_request_engine_out_signals_in          (engines_fifo_request_cast_lane_out_signals_in[j][ENGINES_CONFIG_CAST_WIDTH_ARRAY[j]:0]   ),
            .fifo_request_engine_out_signals_out         (engines_fifo_request_cast_lane_out_signals_out[j][ENGINES_CONFIG_CAST_WIDTH_ARRAY[j]:0]  ),
            .request_memory_out                          (engines_request_memory_out[j]                                                            ),
            .fifo_request_memory_out_signals_in          (engines_fifo_request_memory_out_signals_in[j]                                            ),
            .fifo_request_memory_out_signals_out         (engines_fifo_request_memory_out_signals_out[j]                                           ),
            .fifo_request_memory_out_backtrack_signals_in(engines_fifo_request_memory_out_backtrack_signals_in_reg[j]                              ),
            .request_control_out                         (engines_request_control_out[j]                                                           ),
            .fifo_request_control_out_signals_in         (engines_fifo_request_control_out_signals_in[j]                                           ),
            .fifo_request_control_out_signals_out        (engines_fifo_request_control_out_signals_out[j]                                          ),
            .fifo_setup_signal                           (engines_fifo_setup_signal[j]                                                             ),
            .done_out                                    (engines_done_out[j]                                                                      )
        );

        for(k=ENGINES_CONFIG_MERGE_WIDTH_ARRAY[j]+1; k < (1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY); k = k+1 ) begin
            assign engines_response_merge_lane_in[j][k] = 0;
            assign engines_fifo_response_merge_lane_in_signals_in[j][k]  = 1'b0;
            assign engines_fifo_response_merge_lane_in_signals_out[j][k] = 2'b10;
        end

        for(k=ENGINES_CONFIG_CAST_WIDTH_ARRAY[j]+1; k < (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY); k = k+1 ) begin
            assign engines_request_cast_lane_out[j][k] = 0;
            assign engines_fifo_request_cast_lane_out_signals_in[j][k]  = 1'b0;
            assign engines_fifo_request_cast_lane_out_signals_out[j][k] = 2'b10;
        end
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes MERGE/CAST wires
// --------------------------------------------------------------------------------------
`include "lane_topology.vh"
`include "lane_arbitration.vh"

endmodule : lane_template
