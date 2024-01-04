// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : bundle_lanes.sv
// Create : 2023-06-17 07:15:49
// Revise : 2023-06-21 03:14:18
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module bundle_lanes #(
    `include "bundle_parameters.vh"
) (
    // System Signals
    input  logic                  ap_clk                                                            ,
    input  logic                  areset                                                            ,
    input  KernelDescriptor       descriptor_in                                                     ,
    input  EnginePacket           response_lanes_in                                                 ,
    input  FIFOStateSignalsInput  fifo_response_lanes_in_signals_in                                 ,
    output FIFOStateSignalsOutput fifo_response_lanes_in_signals_out                                ,
    output FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_out[NUM_LANES-1:0]          ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in [NUM_BACKTRACK_LANES-1:0],
    input  MemoryPacket           response_memory_in                                                ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                                ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                               ,
    input  ControlPacket          response_control_in                                               ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in                               ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out                              ,
    output EnginePacket           request_lanes_out                                                 ,
    input  FIFOStateSignalsInput  fifo_request_lanes_out_signals_in                                 ,
    output FIFOStateSignalsOutput fifo_request_lanes_out_signals_out                                ,
    output MemoryPacket           request_memory_out                                                ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                                ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                               ,
    output ControlPacket          request_control_out                                               ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in                               ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out                              ,
    output logic                  fifo_setup_signal                                                 ,
    output logic                  done_out
);

genvar i;
genvar j;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_lanes;

KernelDescriptor descriptor_in_reg;

ControlPacket request_control_out_int;
EnginePacket  request_engine_out_int ;
MemoryPacket  request_memory_out_int ;
ControlPacket response_control_in_int;
ControlPacket response_control_in_reg;
EnginePacket  response_engine_in_int ;
EnginePacket  response_engine_in_reg ;
MemoryPacket  response_memory_in_int ;
MemoryPacket  response_memory_in_reg ;

logic fifo_empty_int;
logic fifo_empty_reg;
// --------------------------------------------------------------------------------------
// FIFO Lanes INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_lanes_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_control_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Lanes OUTPUT Request EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_lanes_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_memory_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL Request CONTROL EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_control_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT BackTrack Avoid mem -> engine deadlocks
// --------------------------------------------------------------------------------------
FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_out_int[NUM_LANES-1:0]                         ;
FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in_reg [NUM_LANES-1:0][NUM_BACKTRACK_LANES-1:0];

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_N_to_1_lane_fifo_request_signals_in                ;
FIFOStateSignalsOutput lane_arbiter_N_to_1_lane_fifo_request_signals_out               ;
logic                  areset_lane_arbiter_N_to_1_lanes                                ;
logic                  lane_arbiter_N_to_1_lane_fifo_setup_signal                      ;
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_lane_lane_arbiter_grant_out                 ;
EnginePacket           lane_arbiter_N_to_1_lane_request_in              [NUM_LANES-1:0];
EnginePacket           lane_arbiter_N_to_1_lane_request_out                            ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_1_to_N_lanes_fifo_response_signals_in [NUM_LANES-1:0];
FIFOStateSignalsOutput lane_arbiter_1_to_N_lanes_fifo_response_signals_out               ;
logic                  areset_lane_arbiter_1_to_N_lanes                                  ;
logic                  lane_arbiter_1_to_N_lanes_fifo_setup_signal                       ;
EnginePacket           lane_arbiter_1_to_N_lanes_response_in                             ;
EnginePacket           lane_arbiter_1_to_N_lanes_response_out             [NUM_LANES-1:0];

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_N_to_1_memory_fifo_request_signals_in                ;
FIFOStateSignalsOutput lane_arbiter_N_to_1_memory_fifo_request_signals_out               ;
logic                  areset_lane_arbiter_N_to_1_memory                                 ;
logic                  lane_arbiter_N_to_1_memory_fifo_setup_signal                      ;
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_memory_lane_arbiter_grant_out                 ;
MemoryPacket           lane_arbiter_N_to_1_memory_request_in              [NUM_LANES-1:0];
MemoryPacket           lane_arbiter_N_to_1_memory_request_out                            ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_N_to_1_control_fifo_request_signals_in                ;
FIFOStateSignalsOutput lane_arbiter_N_to_1_control_fifo_request_signals_out               ;
logic                  areset_lane_arbiter_N_to_1_control                                 ;
logic                  lane_arbiter_N_to_1_control_fifo_setup_signal                      ;
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_control_lane_arbiter_grant_out                 ;
ControlPacket          lane_arbiter_N_to_1_control_request_in              [NUM_LANES-1:0];
ControlPacket          lane_arbiter_N_to_1_control_request_out                            ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_1_to_N_memory_fifo_response_signals_in [NUM_LANES-1:0];
FIFOStateSignalsOutput lane_arbiter_1_to_N_memory_fifo_response_signals_out               ;
logic                  areset_lane_arbiter_1_to_N_memory                                  ;
logic                  lane_arbiter_1_to_N_memory_fifo_setup_signal                       ;
MemoryPacket           lane_arbiter_1_to_N_memory_response_in                             ;
MemoryPacket           lane_arbiter_1_to_N_memory_response_out             [NUM_LANES-1:0];

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: CONTROL Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_1_to_N_control_fifo_response_signals_in [NUM_LANES-1:0];
FIFOStateSignalsOutput lane_arbiter_1_to_N_control_fifo_response_signals_out               ;
logic                  areset_lane_arbiter_1_to_N_control                                  ;
logic                  lane_arbiter_1_to_N_control_fifo_setup_signal                       ;
ControlPacket          lane_arbiter_1_to_N_control_response_in                             ;
ControlPacket          lane_arbiter_1_to_N_control_response_out             [NUM_LANES-1:0];

// --------------------------------------------------------------------------------------
// Generate Lanes
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lanes_fifo_request_control_out_signals_in [NUM_LANES-1:0];
FIFOStateSignalsInput  lanes_fifo_request_lane_out_signals_in    [NUM_LANES-1:0];
FIFOStateSignalsInput  lanes_fifo_request_memory_out_signals_in  [NUM_LANES-1:0];
FIFOStateSignalsInput  lanes_fifo_response_control_in_signals_in [NUM_LANES-1:0];
FIFOStateSignalsInput  lanes_fifo_response_lane_in_signals_in    [NUM_LANES-1:0];
FIFOStateSignalsInput  lanes_fifo_response_memory_in_signals_in  [NUM_LANES-1:0];
FIFOStateSignalsOutput lanes_fifo_request_control_out_signals_out[NUM_LANES-1:0];
FIFOStateSignalsOutput lanes_fifo_request_lane_out_signals_out   [NUM_LANES-1:0];
FIFOStateSignalsOutput lanes_fifo_request_memory_out_signals_out [NUM_LANES-1:0];
FIFOStateSignalsOutput lanes_fifo_response_control_in_signals_out[NUM_LANES-1:0];
FIFOStateSignalsOutput lanes_fifo_response_lane_in_signals_out   [NUM_LANES-1:0];
FIFOStateSignalsOutput lanes_fifo_response_memory_in_signals_out [NUM_LANES-1:0];
KernelDescriptor       lanes_descriptor_in                       [NUM_LANES-1:0];
logic                  areset_lane                               [NUM_LANES-1:0];
logic                  lanes_done_out                            [NUM_LANES-1:0];
logic                  lanes_fifo_setup_signal                   [NUM_LANES-1:0];
ControlPacket          lanes_request_control_out                 [NUM_LANES-1:0];
EnginePacket           lanes_request_lane_out                    [NUM_LANES-1:0];
MemoryPacket           lanes_request_memory_out                  [NUM_LANES-1:0];
ControlPacket          lanes_response_control_in                 [NUM_LANES-1:0];
EnginePacket           lanes_response_engine_in                  [NUM_LANES-1:0];
MemoryPacket           lanes_response_memory_in                  [NUM_LANES-1:0];

logic [NUM_LANES-1:0] lanes_done_out_reg         ;
logic [NUM_LANES-1:0] lanes_fifo_setup_signal_reg;

// --------------------------------------------------------------------------------------
// Generate Lanes MERGE/CAST wires
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lanes_fifo_request_cast_lane_out_signals_in  [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:0];
FIFOStateSignalsInput  lanes_fifo_response_merge_lane_in_signals_in [NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0];
FIFOStateSignalsOutput lanes_fifo_request_cast_lane_out_signals_out [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:0];
FIFOStateSignalsOutput lanes_fifo_response_merge_lane_in_signals_out[NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0];
EnginePacket           lanes_request_cast_lane_out                  [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:0];
EnginePacket           lanes_response_merge_engine_in               [NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0];

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_lane_arbiter_1_to_N_control <= areset;
    areset_lane_arbiter_1_to_N_lanes   <= areset;
    areset_lane_arbiter_1_to_N_memory  <= areset;
    areset_lane_arbiter_N_to_1_control <= areset;
    areset_lane_arbiter_N_to_1_lanes   <= areset;
    areset_lane_arbiter_N_to_1_memory  <= areset;
    areset_lanes                       <= areset;
end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_lanes) begin
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
    if (areset_lanes) begin
        fifo_request_control_out_signals_in_reg <= 0;
        fifo_request_lanes_out_signals_in_reg   <= 0;
        fifo_request_memory_out_signals_in_reg  <= 0;
        fifo_response_control_in_signals_in_reg <= 0;
        fifo_response_lanes_in_signals_in_reg   <= 0;
        fifo_response_memory_in_signals_in_reg  <= 0;
        response_control_in_reg.valid           <= 1'b0;
        response_engine_in_reg.valid            <= 1'b0;
        response_memory_in_reg.valid            <= 1'b0;
    end
    else begin
        fifo_request_control_out_signals_in_reg <= fifo_request_control_out_signals_in;
        fifo_request_lanes_out_signals_in_reg   <= fifo_request_lanes_out_signals_in;
        fifo_request_memory_out_signals_in_reg  <= fifo_request_memory_out_signals_in;
        fifo_response_control_in_signals_in_reg <= fifo_response_control_in_signals_in;
        fifo_response_lanes_in_signals_in_reg   <= fifo_response_lanes_in_signals_in;
        fifo_response_memory_in_signals_in_reg  <= fifo_response_memory_in_signals_in;
        response_control_in_reg.valid           <= response_control_in.valid ;
        response_engine_in_reg.valid            <= response_lanes_in.valid;
        response_memory_in_reg.valid            <= response_memory_in.valid ;
    end
end

always_ff @(posedge ap_clk) begin
    response_control_in_reg.payload <= response_control_in.payload;
    response_engine_in_reg.payload  <= response_lanes_in.payload;
    response_memory_in_reg.payload  <= response_memory_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_lanes) begin
        done_out                  <= 1'b0;
        fifo_empty_reg            <= 1'b1;
        fifo_setup_signal         <= 1'b1;
        request_control_out.valid <= 1'b0;
        request_lanes_out.valid   <= 1'b0;
        request_memory_out.valid  <= 1'b0;
    end
    else begin
        done_out                  <= (&lanes_done_out_reg) & fifo_empty_reg;
        fifo_empty_reg            <= fifo_empty_int;
        fifo_setup_signal         <= lane_arbiter_1_to_N_memory_fifo_setup_signal | lane_arbiter_1_to_N_control_fifo_setup_signal | lane_arbiter_N_to_1_control_fifo_setup_signal | lane_arbiter_N_to_1_memory_fifo_setup_signal | lane_arbiter_N_to_1_lane_fifo_setup_signal | lane_arbiter_1_to_N_lanes_fifo_setup_signal | (|lanes_fifo_setup_signal_reg);
        request_control_out.valid <= request_control_out_int.valid ;
        request_lanes_out.valid   <= request_engine_out_int.valid ;
        request_memory_out.valid  <= request_memory_out_int.valid ;
    end
end

assign fifo_empty_int = lane_arbiter_N_to_1_lane_fifo_request_signals_out.empty & lane_arbiter_1_to_N_lanes_fifo_response_signals_out.empty & lane_arbiter_1_to_N_control_fifo_response_signals_out.empty & lane_arbiter_N_to_1_memory_fifo_request_signals_out.empty & lane_arbiter_N_to_1_control_fifo_request_signals_out.empty & lane_arbiter_1_to_N_memory_fifo_response_signals_out.empty;

always_ff @(posedge ap_clk) begin
    fifo_request_control_out_signals_out <= lane_arbiter_N_to_1_control_fifo_request_signals_out;
    fifo_request_lanes_out_signals_out   <= lane_arbiter_N_to_1_lane_fifo_request_signals_out;
    fifo_request_memory_out_signals_out  <= lane_arbiter_N_to_1_memory_fifo_request_signals_out;
    fifo_response_control_in_signals_out <= lane_arbiter_1_to_N_control_fifo_response_signals_out;
    fifo_response_lanes_in_signals_out   <= lane_arbiter_1_to_N_lanes_fifo_response_signals_out;
    fifo_response_memory_in_signals_out  <= lane_arbiter_1_to_N_memory_fifo_response_signals_out;
    request_control_out.payload          <= request_control_out_int.payload ;
    request_lanes_out.payload            <= request_engine_out_int.payload;
    request_memory_out.payload           <= request_memory_out_int.payload ;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Lanes Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_engine_in_int = response_engine_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_memory_in_int = response_memory_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_control_in_int = response_control_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Lanes requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_engine_out_int = lane_arbiter_N_to_1_lane_request_out;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_memory_out_int = lane_arbiter_N_to_1_memory_request_out;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_control_out_int = lane_arbiter_N_to_1_control_request_out;

// --------------------------------------------------------------------------------------
// Generate Lanes Arbitration|Instants|Signals
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Generate Lanes - Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    for (int i=0; i<NUM_LANES; i++) begin
        areset_lane[i] <= areset;
    end
end

always_ff @(posedge ap_clk) begin
    if (areset_lanes) begin
        for (int i=0; i<NUM_LANES; i++) begin
            lanes_descriptor_in[i].valid <= 0;
        end
    end
    else begin
        for (int i=0; i<NUM_LANES; i++) begin
            lanes_descriptor_in[i].valid <= descriptor_in_reg.valid;
        end
    end
end

always_ff @(posedge ap_clk) begin
    for (int i=0; i<NUM_LANES; i++) begin
        lanes_descriptor_in[i].payload <= descriptor_in_reg.payload;
    end
end

// --------------------------------------------------------------------------------------
// Generate Lanes - Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_lanes) begin
        for (int i=0; i<NUM_LANES; i++) begin
            lanes_fifo_setup_signal_reg[i] <= 1'b1;
            lanes_done_out_reg[i]          <= 1'b1;
        end
    end
    else begin
        for (int i=0; i<NUM_LANES; i++) begin
            lanes_fifo_setup_signal_reg[i] <= lanes_fifo_setup_signal[i];
            lanes_done_out_reg[i]          <= lanes_done_out[i];
        end
    end
end


// --------------------------------------------------------------------------------------
// Generate FIFO backtrack signals - Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
generate
    for (i=0; i<NUM_LANES; i++) begin  : generate_response_lanes_backtrack_signals
        assign fifo_response_lanes_backtrack_signals_out_int[i] = lanes_fifo_response_merge_lane_in_signals_out[i][0];

        always_ff @(posedge ap_clk) begin
            fifo_response_lanes_backtrack_signals_out[i] <= fifo_response_lanes_backtrack_signals_out_int[i];
        end

        always_ff @(posedge ap_clk) begin
            fifo_response_lanes_backtrack_signals_in_reg[i]    <= fifo_response_lanes_backtrack_signals_in;
        end
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes - Lanes Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Request Generator
// --------------------------------------------------------------------------------------
generate
    for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_N_to_1_engine_request_in
        assign lane_arbiter_N_to_1_lane_request_in[i] = lanes_request_lane_out[i];
        assign lanes_fifo_request_lane_out_signals_in[i].rd_en  = ~lane_arbiter_N_to_1_lane_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_lane_lane_arbiter_grant_out[i];
    end
endgenerate

assign lane_arbiter_N_to_1_lane_fifo_request_signals_in.rd_en = fifo_request_lanes_out_signals_in_reg.rd_en;
// --------------------------------------------------------------------------------------
arbiter_N_to_1_request_engine #(
    .NUM_ENGINE_REQUESTOR(NUM_LANES                                   ),
    .FIFO_ARBITER_DEPTH  (LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE)
) inst_lane_arbiter_N_to_1_engine_request_out (
    .ap_clk                  (ap_clk                                           ),
    .areset                  (areset_lane_arbiter_N_to_1_lanes                 ),
    .request_in              (lane_arbiter_N_to_1_lane_request_in              ),
    .fifo_request_signals_in (lane_arbiter_N_to_1_lane_fifo_request_signals_in ),
    .fifo_request_signals_out(lane_arbiter_N_to_1_lane_fifo_request_signals_out),
    .arbiter_grant_out       (lane_arbiter_N_to_1_lane_lane_arbiter_grant_out  ),
    .request_out             (lane_arbiter_N_to_1_lane_request_out             ),
    .fifo_setup_signal       (lane_arbiter_N_to_1_lane_fifo_setup_signal       )
);

// --------------------------------------------------------------------------------------
// Generate Lanes - Memory Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
generate
    if(LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY>0) begin
        arbiter_N_to_1_request_memory #(
            .NUM_MEMORY_REQUESTOR(LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY      ),
            .FIFO_ARBITER_DEPTH  (LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY)
        ) inst_lane_arbiter_N_to_1_memory_request_out (
            .ap_clk                  (ap_clk                                                                                       ),
            .areset                  (areset_lane_arbiter_N_to_1_memory                                                            ),
            .request_in              (lane_arbiter_N_to_1_memory_request_in[LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY-1:0]            ),
            .fifo_request_signals_in (lane_arbiter_N_to_1_memory_fifo_request_signals_in                                           ),
            .fifo_request_signals_out(lane_arbiter_N_to_1_memory_fifo_request_signals_out                                          ),
            .arbiter_grant_out       (lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY-1:0]),
            .request_out             (lane_arbiter_N_to_1_memory_request_out                                                       ),
            .fifo_setup_signal       (lane_arbiter_N_to_1_memory_fifo_setup_signal                                                 )
        );
// --------------------------------------------------------------------------------------
    end else begin
        for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_N_to_1_memory_request_in
            assign lanes_fifo_request_memory_out_signals_in[i].rd_en  = 1'b0;
        end
        assign lane_arbiter_N_to_1_memory_fifo_request_signals_out = 2'b10;
        assign lane_arbiter_N_to_1_memory_lane_arbiter_grant_out   = 0;
        assign lane_arbiter_N_to_1_memory_request_out              = 0;
        assign lane_arbiter_N_to_1_memory_fifo_setup_signal        = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes - CONTROL Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: CONTROL Request Generator
// --------------------------------------------------------------------------------------
generate
    if(LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST>0) begin
        arbiter_N_to_1_request_control #(
            .NUM_CONTROL_REQUESTOR(LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST      ),
            .FIFO_ARBITER_DEPTH   (LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST)
        ) inst_lane_arbiter_N_to_1_control_request_out (
            .ap_clk                  (ap_clk                                                                                                 ),
            .areset                  (areset_lane_arbiter_N_to_1_control                                                                     ),
            .request_in              (lane_arbiter_N_to_1_control_request_in[LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST-1:0]            ),
            .fifo_request_signals_in (lane_arbiter_N_to_1_control_fifo_request_signals_in                                                    ),
            .fifo_request_signals_out(lane_arbiter_N_to_1_control_fifo_request_signals_out                                                   ),
            .arbiter_grant_out       (lane_arbiter_N_to_1_control_lane_arbiter_grant_out[LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST-1:0]),
            .request_out             (lane_arbiter_N_to_1_control_request_out                                                                ),
            .fifo_setup_signal       (lane_arbiter_N_to_1_control_fifo_setup_signal                                                          )
        );
// --------------------------------------------------------------------------------------
    end else begin
        for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_N_to_1_control_request_in
            assign lanes_fifo_request_control_out_signals_in[i].rd_en  = 1'b0;
        end
        assign lane_arbiter_N_to_1_control_fifo_request_signals_out = 2'b10;
        assign lane_arbiter_N_to_1_control_lane_arbiter_grant_out   = 0;
        assign lane_arbiter_N_to_1_control_request_out              = 0;
        assign lane_arbiter_N_to_1_control_fifo_setup_signal        = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
assign lane_arbiter_1_to_N_lanes_response_in = response_engine_in_int;

generate
    for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_1_to_N_engine_response
        assign lane_arbiter_1_to_N_lanes_fifo_response_signals_in[i].rd_en = ~lanes_fifo_response_lane_in_signals_out[i].prog_full & fifo_response_lanes_in_signals_in_reg.rd_en;
        assign lanes_response_engine_in[i] = lane_arbiter_1_to_N_lanes_response_out[i];
        assign lanes_fifo_response_lane_in_signals_in[i].rd_en = 1'b1;
    end
endgenerate

// --------------------------------------------------------------------------------------
arbiter_1_to_N_response_engine #(
    .NUM_ENGINE_RECEIVER (NUM_LANES                                   ),
    .ID_LEVEL            (2                                           ),
    .ID_BUNDLE           (ID_BUNDLE                                   ),
    .FIFO_ARBITER_DEPTH  (LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE)
) inst_lane_arbiter_1_to_N_engine_response_in (
    .ap_clk                   (ap_clk                                             ),
    .areset                   (areset_lane_arbiter_1_to_N_lanes                   ),
    .response_in              (lane_arbiter_1_to_N_lanes_response_in              ),
    .fifo_response_signals_in (lane_arbiter_1_to_N_lanes_fifo_response_signals_in ),
    .fifo_response_signals_out(lane_arbiter_1_to_N_lanes_fifo_response_signals_out),
    .response_out             (lane_arbiter_1_to_N_lanes_response_out             ),
    .fifo_setup_signal        (lane_arbiter_1_to_N_lanes_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
assign lane_arbiter_1_to_N_memory_response_in = response_memory_in_int;

generate
    for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_1_to_N_memory_response
        assign lane_arbiter_1_to_N_memory_fifo_response_signals_in[i].rd_en = ~lanes_fifo_response_memory_in_signals_out[i].prog_full & fifo_response_memory_in_signals_in_reg.rd_en;
        assign lanes_response_memory_in[i] = lane_arbiter_1_to_N_memory_response_out[i];
        assign lanes_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
    end
endgenerate

// --------------------------------------------------------------------------------------
arbiter_1_to_N_response_memory #(
    .NUM_MEMORY_RECEIVER(NUM_LANES                                   ),
    .ID_LEVEL           (2                                           ),
    .FIFO_ARBITER_DEPTH (LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY)
) inst_lane_arbiter_1_to_N_memory_response_in (
    .ap_clk                   (ap_clk                                              ),
    .areset                   (areset_lane_arbiter_1_to_N_memory                   ),
    .response_in              (lane_arbiter_1_to_N_memory_response_in              ),
    .fifo_response_signals_in (lane_arbiter_1_to_N_memory_fifo_response_signals_in ),
    .fifo_response_signals_out(lane_arbiter_1_to_N_memory_fifo_response_signals_out),
    .response_out             (lane_arbiter_1_to_N_memory_response_out             ),
    .fifo_setup_signal        (lane_arbiter_1_to_N_memory_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: CONTROL Response Generator
// --------------------------------------------------------------------------------------
generate
    if(LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE>0) begin
        arbiter_1_to_N_response_control #(
            .NUM_CONTROL_RECEIVER(LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE      ),
            .ID_LEVEL            (2                                                     ),
            .FIFO_ARBITER_DEPTH  (LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)
        ) inst_lane_arbiter_1_to_N_control_response_in (
            .ap_clk                   (ap_clk                                                                                                    ),
            .areset                   (areset_lane_arbiter_1_to_N_control                                                                        ),
            .response_in              (lane_arbiter_1_to_N_control_response_in                                                                   ),
            .fifo_response_signals_in (lane_arbiter_1_to_N_control_fifo_response_signals_in[LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE-1:0]),
            .fifo_response_signals_out(lane_arbiter_1_to_N_control_fifo_response_signals_out                                                     ),
            .response_out             (lane_arbiter_1_to_N_control_response_out[LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE-1:0]            ),
            .fifo_setup_signal        (lane_arbiter_1_to_N_control_fifo_setup_signal                                                             )
        );
// --------------------------------------------------------------------------------------
    end else begin
        for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_1_to_N_control_response
            assign lanes_response_control_in[i] = 0;
            assign lanes_fifo_response_control_in_signals_in[i].rd_en  = 1'b0;
            assign lane_arbiter_1_to_N_control_response_out[i] = 0;
        end
        assign lane_arbiter_1_to_N_control_fifo_response_signals_out = 2'b10;
        assign lane_arbiter_1_to_N_control_fifo_setup_signal         = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes
// --------------------------------------------------------------------------------------
generate
    for (j=0; j<NUM_LANES; j++) begin : generate_lane_template
        lane_template #(
            `include"set_lane_parameters.vh"
        ) inst_lane_template (
            .ap_clk                                  (ap_clk                                                                                    ),
            .areset                                  (areset_lane[j]                                                                            ),
            .descriptor_in                           (lanes_descriptor_in[j]                                                                    ),
            .response_lane_in                        (lanes_response_merge_engine_in[j][LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]:0]               ),
            .fifo_response_lane_in_signals_in        (lanes_fifo_response_merge_lane_in_signals_in[j][LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]:0] ),
            .fifo_response_lane_in_signals_out       (lanes_fifo_response_merge_lane_in_signals_out[j][LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]:0]),
            .fifo_response_lanes_backtrack_signals_in(fifo_response_lanes_backtrack_signals_in_reg[j]                                           ),
            .response_memory_in                      (lanes_response_memory_in[j]                                                               ),
            .fifo_response_memory_in_signals_in      (lanes_fifo_response_memory_in_signals_in[j]                                               ),
            .fifo_response_memory_in_signals_out     (lanes_fifo_response_memory_in_signals_out[j]                                              ),
            .response_control_in                     (lanes_response_control_in[j]                                                              ),
            .fifo_response_control_in_signals_in     (lanes_fifo_response_control_in_signals_in[j]                                              ),
            .fifo_response_control_in_signals_out    (lanes_fifo_response_control_in_signals_out[j]                                             ),
            .request_lane_out                        (lanes_request_cast_lane_out[j][LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]:0]                   ),
            .fifo_request_lane_out_signals_in        (lanes_fifo_request_cast_lane_out_signals_in[j][LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]:0]   ),
            .fifo_request_lane_out_signals_out       (lanes_fifo_request_cast_lane_out_signals_out[j][LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]:0]  ),
            .request_memory_out                      (lanes_request_memory_out[j]                                                               ),
            .fifo_request_memory_out_signals_in      (lanes_fifo_request_memory_out_signals_in[j]                                               ),
            .fifo_request_memory_out_signals_out     (lanes_fifo_request_memory_out_signals_out[j]                                              ),
            .request_control_out                     (lanes_request_control_out[j]                                                              ),
            .fifo_request_control_out_signals_in     (lanes_fifo_request_control_out_signals_in[j]                                              ),
            .fifo_request_control_out_signals_out    (lanes_fifo_request_control_out_signals_out[j]                                             ),
            .fifo_setup_signal                       (lanes_fifo_setup_signal[j]                                                                ),
            .done_out                                (lanes_done_out[j]                                                                         )
        );
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes MERGE/CAST wires
// --------------------------------------------------------------------------------------
`include "bundle_topology.vh"
`include "bundle_arbitration.vh"

endmodule : bundle_lanes