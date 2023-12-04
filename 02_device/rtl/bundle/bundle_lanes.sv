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
    input  logic                  ap_clk                              ,
    input  logic                  areset                              ,
    input  KernelDescriptor       descriptor_in                       ,
    input  MemoryPacket           response_lanes_in                   ,
    input  FIFOStateSignalsInput  fifo_response_lanes_in_signals_in   ,
    output FIFOStateSignalsOutput fifo_response_lanes_in_signals_out  ,
    input  MemoryPacket           response_memory_in                  ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in  ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out ,
    input  MemoryPacket           response_control_in                 ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out,
    output MemoryPacket           request_lanes_out                   ,
    input  FIFOStateSignalsInput  fifo_request_lanes_out_signals_in   ,
    output FIFOStateSignalsOutput fifo_request_lanes_out_signals_out  ,
    output MemoryPacket           request_memory_out                  ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in  ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out ,
    output MemoryPacket           request_control_out                 ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out,
    output logic                  fifo_setup_signal                   ,
    output logic                  done_out
);

genvar i;
genvar j;

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_lanes;
logic areset_fifo ;

KernelDescriptor descriptor_in_reg;

MemoryPacket request_control_out_int;
MemoryPacket request_engine_out_int ;
MemoryPacket request_memory_out_int ;
MemoryPacket response_control_in_int;
MemoryPacket response_control_in_reg;
MemoryPacket response_engine_in_int ;
MemoryPacket response_engine_in_reg ;
MemoryPacket response_memory_in_int ;
MemoryPacket response_memory_in_reg ;

logic fifo_empty_int;
logic fifo_empty_reg;
// --------------------------------------------------------------------------------------
// FIFO Lanes INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_response_lanes_in_signals_in_int  ;
FIFOStateSignalsInput         fifo_response_lanes_in_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_response_lanes_in_signals_out_int ;
logic                         fifo_response_lanes_in_setup_signal_int;
MemoryPacketPayload           fifo_response_lanes_in_din             ;
MemoryPacketPayload           fifo_response_lanes_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_response_memory_in_signals_in_int  ;
FIFOStateSignalsInput         fifo_response_memory_in_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_response_memory_in_signals_out_int ;
logic                         fifo_response_memory_in_setup_signal_int;
MemoryPacketPayload           fifo_response_memory_in_din             ;
MemoryPacketPayload           fifo_response_memory_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_response_control_in_signals_in_int  ;
FIFOStateSignalsInput         fifo_response_control_in_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_response_control_in_signals_out_int ;
logic                         fifo_response_control_in_setup_signal_int;
MemoryPacketPayload           fifo_response_control_in_din             ;
MemoryPacketPayload           fifo_response_control_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO Lanes OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_request_lanes_out_signals_in_int  ;
FIFOStateSignalsInput         fifo_request_lanes_out_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_request_lanes_out_signals_out_int ;
logic                         fifo_request_lanes_out_setup_signal_int;
MemoryPacketPayload           fifo_request_lanes_out_din             ;
MemoryPacketPayload           fifo_request_lanes_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_request_memory_out_signals_in_int  ;
FIFOStateSignalsInput         fifo_request_memory_out_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_request_memory_out_signals_out_int ;
logic                         fifo_request_memory_out_setup_signal_int;
MemoryPacketPayload           fifo_request_memory_out_din             ;
MemoryPacketPayload           fifo_request_memory_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL Request CONTROL MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_request_control_out_signals_in_int  ;
FIFOStateSignalsInput         fifo_request_control_out_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_request_control_out_signals_out_int ;
logic                         fifo_request_control_out_setup_signal_int;
MemoryPacketPayload           fifo_request_control_out_din             ;
MemoryPacketPayload           fifo_request_control_out_dout            ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_N_to_1_lane_fifo_request_signals_in                ;
FIFOStateSignalsOutput lane_arbiter_N_to_1_lane_fifo_request_signals_out               ;
logic                  areset_lane_arbiter_N_to_1_lanes                                ;
logic                  lane_arbiter_N_to_1_lane_fifo_setup_signal                      ;
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_lane_lane_arbiter_grant_out                 ;
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_lane_lane_arbiter_request_in                ;
MemoryPacket           lane_arbiter_N_to_1_lane_request_in              [NUM_LANES-1:0];
MemoryPacket           lane_arbiter_N_to_1_lane_request_out                            ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_1_to_N_lanes_fifo_response_signals_in [NUM_LANES-1:0];
FIFOStateSignalsOutput lane_arbiter_1_to_N_lanes_fifo_response_signals_out               ;
logic                  areset_lane_arbiter_1_to_N_lanes                                  ;
logic                  lane_arbiter_1_to_N_lanes_fifo_setup_signal                       ;
MemoryPacket           lane_arbiter_1_to_N_lanes_response_in                             ;
MemoryPacket           lane_arbiter_1_to_N_lanes_response_out             [NUM_LANES-1:0];

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  lane_arbiter_N_to_1_memory_fifo_request_signals_in                ;
FIFOStateSignalsOutput lane_arbiter_N_to_1_memory_fifo_request_signals_out               ;
logic                  areset_lane_arbiter_N_to_1_memory                                 ;
logic                  lane_arbiter_N_to_1_memory_fifo_setup_signal                      ;
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_memory_lane_arbiter_grant_out                 ;
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_memory_lane_arbiter_request_in                ;
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
logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_control_lane_arbiter_request_in                ;
MemoryPacket           lane_arbiter_N_to_1_control_request_in              [NUM_LANES-1:0];
MemoryPacket           lane_arbiter_N_to_1_control_request_out                            ;

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
MemoryPacket           lane_arbiter_1_to_N_control_response_in                             ;
MemoryPacket           lane_arbiter_1_to_N_control_response_out             [NUM_LANES-1:0];

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
MemoryPacket           lanes_request_control_out                 [NUM_LANES-1:0];
MemoryPacket           lanes_request_lane_out                    [NUM_LANES-1:0];
MemoryPacket           lanes_request_memory_out                  [NUM_LANES-1:0];
MemoryPacket           lanes_response_control_in                 [NUM_LANES-1:0];
MemoryPacket           lanes_response_engine_in                  [NUM_LANES-1:0];
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
MemoryPacket           lanes_request_cast_lane_out                  [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:0];
MemoryPacket           lanes_response_merge_engine_in               [NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0];

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_fifo                        <= areset;
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
        fifo_setup_signal         <= lane_arbiter_1_to_N_memory_fifo_setup_signal | lane_arbiter_1_to_N_control_fifo_setup_signal | lane_arbiter_N_to_1_control_fifo_setup_signal | lane_arbiter_N_to_1_memory_fifo_setup_signal | lane_arbiter_N_to_1_lane_fifo_setup_signal | lane_arbiter_1_to_N_lanes_fifo_setup_signal | fifo_response_lanes_in_setup_signal_int | fifo_response_control_in_setup_signal_int | fifo_response_memory_in_setup_signal_int | fifo_request_lanes_out_setup_signal_int | fifo_request_control_out_setup_signal_int | fifo_request_memory_out_setup_signal_int | (|lanes_fifo_setup_signal_reg);
        request_control_out.valid <= request_control_out_int.valid ;
        request_lanes_out.valid   <= request_engine_out_int.valid ;
        request_memory_out.valid  <= request_memory_out_int.valid ;
    end
end

assign fifo_empty_int = fifo_response_lanes_in_signals_out_int.empty & fifo_response_control_in_signals_out_int.empty & fifo_response_memory_in_signals_out_int.empty & fifo_request_lanes_out_signals_out_int.empty & fifo_request_memory_out_signals_out_int.empty & fifo_request_control_out_signals_out_int.empty & lane_arbiter_N_to_1_lane_fifo_request_signals_out.empty & lane_arbiter_1_to_N_lanes_fifo_response_signals_out.empty & lane_arbiter_1_to_N_control_fifo_response_signals_out.empty & lane_arbiter_N_to_1_memory_fifo_request_signals_out.empty & lane_arbiter_N_to_1_control_fifo_request_signals_out.empty & lane_arbiter_1_to_N_memory_fifo_response_signals_out.empty;

always_ff @(posedge ap_clk) begin
    fifo_request_control_out_signals_out <= map_internal_fifo_signals_to_output(fifo_request_control_out_signals_out_int);
    fifo_request_lanes_out_signals_out   <= map_internal_fifo_signals_to_output(fifo_request_lanes_out_signals_out_int);
    fifo_request_memory_out_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_memory_out_signals_out_int);
    fifo_response_control_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_control_in_signals_out_int);
    fifo_response_lanes_in_signals_out   <= map_internal_fifo_signals_to_output(fifo_response_lanes_in_signals_out_int);
    fifo_response_memory_in_signals_out  <= map_internal_fifo_signals_to_output(fifo_response_memory_in_signals_out_int);
    request_control_out.payload          <= request_control_out_int.payload ;
    request_lanes_out.payload            <= request_engine_out_int.payload;
    request_memory_out.payload           <= request_memory_out_int.payload ;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Lanes Response MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_lanes_in_setup_signal_int = fifo_response_lanes_in_signals_out_int.wr_rst_busy | fifo_response_lanes_in_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_lanes_in_signals_in_int.wr_en = response_engine_in_reg.valid;
assign fifo_response_lanes_in_din                  = response_engine_in_reg.payload;

// Pop
assign fifo_response_lanes_in_signals_in_int.rd_en = ~fifo_response_lanes_in_signals_out_int.empty & fifo_response_lanes_in_signals_in_reg.rd_en & ~lane_arbiter_1_to_N_lanes_fifo_response_signals_out.prog_full;
assign response_engine_in_int.valid                = fifo_response_lanes_in_signals_out_int.valid;
assign response_engine_in_int.payload              = fifo_response_lanes_in_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketResponseLanesInput (
    .clk        (ap_clk                                            ),
    .srst       (areset_fifo                                       ),
    .din        (fifo_response_lanes_in_din                        ),
    .wr_en      (fifo_response_lanes_in_signals_in_int.wr_en       ),
    .rd_en      (fifo_response_lanes_in_signals_in_int.rd_en       ),
    .dout       (fifo_response_lanes_in_dout                       ),
    .full       (fifo_response_lanes_in_signals_out_int.full       ),
    .empty      (fifo_response_lanes_in_signals_out_int.empty      ),
    .valid      (fifo_response_lanes_in_signals_out_int.valid      ),
    .prog_full  (fifo_response_lanes_in_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_response_lanes_in_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_response_lanes_in_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_memory_in_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy | fifo_response_memory_in_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid;
assign fifo_response_memory_in_din                  = response_memory_in_reg.payload;

// Pop
assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~lane_arbiter_1_to_N_memory_fifo_response_signals_out.prog_full;
assign response_memory_in_int.valid                 = fifo_response_memory_in_signals_out_int.valid;
assign response_memory_in_int.payload               = fifo_response_memory_in_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketResponseMemoryInput (
    .clk        (ap_clk                                             ),
    .srst       (areset_fifo                                        ),
    .din        (fifo_response_memory_in_din                        ),
    .wr_en      (fifo_response_memory_in_signals_in_int.wr_en       ),
    .rd_en      (fifo_response_memory_in_signals_in_int.rd_en       ),
    .dout       (fifo_response_memory_in_dout                       ),
    .full       (fifo_response_memory_in_signals_out_int.full       ),
    .empty      (fifo_response_memory_in_signals_out_int.empty      ),
    .valid      (fifo_response_memory_in_signals_out_int.valid      ),
    .prog_full  (fifo_response_memory_in_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_response_memory_in_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_response_memory_in_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_control_in_setup_signal_int = fifo_response_control_in_signals_out_int.wr_rst_busy | fifo_response_control_in_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_control_in_signals_in_int.wr_en = response_control_in_reg.valid;
assign fifo_response_control_in_din                  = response_control_in_reg.payload;

// Pop
assign fifo_response_control_in_signals_in_int.rd_en = ~fifo_response_control_in_signals_out_int.empty & fifo_response_control_in_signals_in_reg.rd_en & ~lane_arbiter_1_to_N_control_fifo_response_signals_out.prog_full;
assign response_control_in_int.valid                 = fifo_response_control_in_signals_out_int.valid;
assign response_control_in_int.payload               = fifo_response_control_in_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketResponseControlInput (
    .clk        (ap_clk                                              ),
    .srst       (areset_fifo                                         ),
    .din        (fifo_response_control_in_din                        ),
    .wr_en      (fifo_response_control_in_signals_in_int.wr_en       ),
    .rd_en      (fifo_response_control_in_signals_in_int.rd_en       ),
    .dout       (fifo_response_control_in_dout                       ),
    .full       (fifo_response_control_in_signals_out_int.full       ),
    .empty      (fifo_response_control_in_signals_out_int.empty      ),
    .valid      (fifo_response_control_in_signals_out_int.valid      ),
    .prog_full  (fifo_response_control_in_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_response_control_in_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_response_control_in_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Lanes requests MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_lanes_out_setup_signal_int = fifo_request_lanes_out_signals_out_int.wr_rst_busy | fifo_request_lanes_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_lanes_out_signals_in_int.wr_en = lane_arbiter_N_to_1_lane_request_out.valid;
assign fifo_request_lanes_out_din                  = lane_arbiter_N_to_1_lane_request_out.payload;

// Pop
assign fifo_request_lanes_out_signals_in_int.rd_en = ~fifo_request_lanes_out_signals_out_int.empty & fifo_request_lanes_out_signals_in_reg.rd_en;
assign request_engine_out_int.valid                = fifo_request_lanes_out_signals_out_int.valid;
assign request_engine_out_int.payload              = fifo_request_lanes_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketRequestLanesOutput (
    .clk        (ap_clk                                            ),
    .srst       (areset_fifo                                       ),
    .din        (fifo_request_lanes_out_din                        ),
    .wr_en      (fifo_request_lanes_out_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_lanes_out_signals_in_int.rd_en       ),
    .dout       (fifo_request_lanes_out_dout                       ),
    .full       (fifo_request_lanes_out_signals_out_int.full       ),
    .empty      (fifo_request_lanes_out_signals_out_int.empty      ),
    .valid      (fifo_request_lanes_out_signals_out_int.valid      ),
    .prog_full  (fifo_request_lanes_out_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_lanes_out_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_lanes_out_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_memory_out_signals_in_int.wr_en = lane_arbiter_N_to_1_memory_request_out.valid;
assign fifo_request_memory_out_din                  = lane_arbiter_N_to_1_memory_request_out.payload;

// Pop
assign fifo_request_memory_out_signals_in_int.rd_en = ~fifo_request_memory_out_signals_out_int.empty & fifo_request_memory_out_signals_in_reg.rd_en;
assign request_memory_out_int.valid                 = fifo_request_memory_out_signals_out_int.valid;
assign request_memory_out_int.payload               = fifo_request_memory_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketRequestMemoryOutput (
    .clk        (ap_clk                                             ),
    .srst       (areset_fifo                                        ),
    .din        (fifo_request_memory_out_din                        ),
    .wr_en      (fifo_request_memory_out_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_memory_out_signals_in_int.rd_en       ),
    .dout       (fifo_request_memory_out_dout                       ),
    .full       (fifo_request_memory_out_signals_out_int.full       ),
    .empty      (fifo_request_memory_out_signals_out_int.empty      ),
    .valid      (fifo_request_memory_out_signals_out_int.valid      ),
    .prog_full  (fifo_request_memory_out_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_memory_out_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_memory_out_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL requests MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_control_out_setup_signal_int = fifo_request_control_out_signals_out_int.wr_rst_busy | fifo_request_control_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_control_out_signals_in_int.wr_en = lane_arbiter_N_to_1_control_request_out.valid;
assign fifo_request_control_out_din                  = lane_arbiter_N_to_1_control_request_out.payload;

// Pop
assign fifo_request_control_out_signals_in_int.rd_en = ~fifo_request_control_out_signals_out_int.empty & fifo_request_control_out_signals_in_reg.rd_en;
assign request_control_out_int.valid                 = fifo_request_control_out_signals_out_int.valid;
assign request_control_out_int.payload               = fifo_request_control_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketRequestControlOutput (
    .clk        (ap_clk                                              ),
    .srst       (areset_fifo                                         ),
    .din        (fifo_request_control_out_din                        ),
    .wr_en      (fifo_request_control_out_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_control_out_signals_in_int.rd_en       ),
    .dout       (fifo_request_control_out_dout                       ),
    .full       (fifo_request_control_out_signals_out_int.full       ),
    .empty      (fifo_request_control_out_signals_out_int.empty      ),
    .valid      (fifo_request_control_out_signals_out_int.valid      ),
    .prog_full  (fifo_request_control_out_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_control_out_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_control_out_signals_out_int.rd_rst_busy)
);

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
// Generate Lanes - Lanes Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Request Generator
// --------------------------------------------------------------------------------------
always_comb begin : generate_lane_arbiter_N_to_1_engine_request_in
    for (int i=0; i<NUM_LANES; i++) begin
        lane_arbiter_N_to_1_lane_request_in[i]              = lanes_request_lane_out[i];
        lane_arbiter_N_to_1_lane_lane_arbiter_request_in[i] = ~lanes_fifo_request_lane_out_signals_out[i].empty & ~lane_arbiter_N_to_1_lane_fifo_request_signals_out.prog_full;
        lanes_fifo_request_lane_out_signals_in[i].rd_en  = ~lane_arbiter_N_to_1_lane_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_lane_lane_arbiter_grant_out[i];
    end
end

assign lane_arbiter_N_to_1_lane_fifo_request_signals_in.rd_en = ~fifo_request_lanes_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_LANES)) inst_lane_arbiter_N_to_1_engine_request_out (
    .ap_clk                  (ap_clk                                           ),
    .areset                  (areset_lane_arbiter_N_to_1_lanes                 ),
    .request_in              (lane_arbiter_N_to_1_lane_request_in              ),
    .fifo_request_signals_in (lane_arbiter_N_to_1_lane_fifo_request_signals_in ),
    .fifo_request_signals_out(lane_arbiter_N_to_1_lane_fifo_request_signals_out),
    .arbiter_request_in      (lane_arbiter_N_to_1_lane_lane_arbiter_request_in ),
    .arbiter_grant_out       (lane_arbiter_N_to_1_lane_lane_arbiter_grant_out  ),
    .request_out             (lane_arbiter_N_to_1_lane_request_out             ),
    .fifo_setup_signal       (lane_arbiter_N_to_1_lane_fifo_setup_signal       )
);

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
assign lane_arbiter_1_to_N_lanes_response_in = response_engine_in_int;

always_comb begin : generate_lane_arbiter_1_to_N_engine_response
    for (int i=0; i<NUM_LANES; i++) begin
        lane_arbiter_1_to_N_lanes_fifo_response_signals_in[i].rd_en = ~lanes_fifo_response_lane_in_signals_out[i].prog_full;
        lanes_response_engine_in[i] = lane_arbiter_1_to_N_lanes_response_out[i];
        lanes_fifo_response_lane_in_signals_in[i].rd_en = 1'b1;
    end
end

// --------------------------------------------------------------------------------------
arbiter_1_to_N_request #(
    .NUM_MEMORY_REQUESTOR(NUM_LANES),
    .ID_LEVEL            (2        ),
    .ID_BUNDLE           (ID_BUNDLE)
) inst_lane_arbiter_1_to_N_engine_response_in (
    .ap_clk                  (ap_clk                                             ),
    .areset                  (areset_lane_arbiter_1_to_N_lanes                   ),
    .request_in              (lane_arbiter_1_to_N_lanes_response_in              ),
    .fifo_request_signals_in (lane_arbiter_1_to_N_lanes_fifo_response_signals_in ),
    .fifo_request_signals_out(lane_arbiter_1_to_N_lanes_fifo_response_signals_out),
    .request_out             (lane_arbiter_1_to_N_lanes_response_out             ),
    .fifo_setup_signal       (lane_arbiter_1_to_N_lanes_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
// Generate Lanes - Memory Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
always_comb begin : generate_lane_arbiter_N_to_1_memory_request_in
    for (int i=0; i<NUM_LANES; i++) begin
        lane_arbiter_N_to_1_memory_request_in[i]              = lanes_request_memory_out[i];
        lane_arbiter_N_to_1_memory_lane_arbiter_request_in[i] = ~lanes_fifo_request_memory_out_signals_out[i].empty & ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full;
        lanes_fifo_request_memory_out_signals_in[i].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[i];
    end
end

assign lane_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = ~fifo_request_memory_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_LANES)) inst_lane_arbiter_N_to_1_memory_request_out (
    .ap_clk                  (ap_clk                                             ),
    .areset                  (areset_lane_arbiter_N_to_1_memory                  ),
    .request_in              (lane_arbiter_N_to_1_memory_request_in              ),
    .fifo_request_signals_in (lane_arbiter_N_to_1_memory_fifo_request_signals_in ),
    .fifo_request_signals_out(lane_arbiter_N_to_1_memory_fifo_request_signals_out),
    .arbiter_request_in      (lane_arbiter_N_to_1_memory_lane_arbiter_request_in ),
    .arbiter_grant_out       (lane_arbiter_N_to_1_memory_lane_arbiter_grant_out  ),
    .request_out             (lane_arbiter_N_to_1_memory_request_out             ),
    .fifo_setup_signal       (lane_arbiter_N_to_1_memory_fifo_setup_signal       )
);

// --------------------------------------------------------------------------------------
// Generate Lanes - CONTROL Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: CONTROL Request Generator
// --------------------------------------------------------------------------------------
always_comb begin : generate_lane_arbiter_N_to_1_control_request_in
    for (int i=0; i<NUM_LANES; i++) begin
        lane_arbiter_N_to_1_control_request_in[i]              = lanes_request_control_out[i];
        lane_arbiter_N_to_1_control_lane_arbiter_request_in[i] = ~lanes_fifo_request_control_out_signals_out[i].empty & ~lane_arbiter_N_to_1_control_fifo_request_signals_out.prog_full;
        lanes_fifo_request_control_out_signals_in[i].rd_en  = ~lane_arbiter_N_to_1_control_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_control_lane_arbiter_grant_out[i];
    end
end

assign lane_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = ~fifo_request_control_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_LANES)) inst_lane_arbiter_N_to_1_control_request_out (
    .ap_clk                  (ap_clk                                              ),
    .areset                  (areset_lane_arbiter_N_to_1_control                  ),
    .request_in              (lane_arbiter_N_to_1_control_request_in              ),
    .fifo_request_signals_in (lane_arbiter_N_to_1_control_fifo_request_signals_in ),
    .fifo_request_signals_out(lane_arbiter_N_to_1_control_fifo_request_signals_out),
    .arbiter_request_in      (lane_arbiter_N_to_1_control_lane_arbiter_request_in ),
    .arbiter_grant_out       (lane_arbiter_N_to_1_control_lane_arbiter_grant_out  ),
    .request_out             (lane_arbiter_N_to_1_control_request_out             ),
    .fifo_setup_signal       (lane_arbiter_N_to_1_control_fifo_setup_signal       )
);

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
assign lane_arbiter_1_to_N_memory_response_in = response_memory_in_int;

always_comb begin : generate_lane_arbiter_1_to_N_memory_response
    for (int i=0; i<NUM_LANES; i++) begin
        lane_arbiter_1_to_N_memory_fifo_response_signals_in[i].rd_en = ~lanes_fifo_response_memory_in_signals_out[i].prog_full;
        lanes_response_memory_in[i] = lane_arbiter_1_to_N_memory_response_out[i];
        lanes_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
    end
end

// --------------------------------------------------------------------------------------
arbiter_1_to_N_response #(
    .NUM_MEMORY_REQUESTOR(NUM_LANES),
    .ID_LEVEL            (2        )
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
assign lane_arbiter_1_to_N_control_response_in = response_control_in_int;

always_comb begin : generate_lane_arbiter_1_to_N_control_response
    for (int i=0; i<NUM_LANES; i++) begin
        lane_arbiter_1_to_N_control_fifo_response_signals_in[i].rd_en = ~lanes_fifo_response_control_in_signals_out[i].prog_full;
        lanes_response_control_in[i] = lane_arbiter_1_to_N_control_response_out[i];
        lanes_fifo_response_control_in_signals_in[i].rd_en = 1'b1;
    end
end

// --------------------------------------------------------------------------------------
arbiter_1_to_N_response #(
    .NUM_MEMORY_REQUESTOR(NUM_LANES),
    .ID_LEVEL            (2        )
) inst_lane_arbiter_1_to_N_control_response_in (
    .ap_clk                   (ap_clk                                               ),
    .areset                   (areset_lane_arbiter_1_to_N_control                   ),
    .response_in              (lane_arbiter_1_to_N_control_response_in              ),
    .fifo_response_signals_in (lane_arbiter_1_to_N_control_fifo_response_signals_in ),
    .fifo_response_signals_out(lane_arbiter_1_to_N_control_fifo_response_signals_out),
    .response_out             (lane_arbiter_1_to_N_control_response_out             ),
    .fifo_setup_signal        (lane_arbiter_1_to_N_control_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
// Generate Lanes
// --------------------------------------------------------------------------------------
generate
    for (j=0; j<NUM_LANES; j++) begin : generate_lane_template
        lane_template #(
            `include"set_lane_parameters.vh"
        ) inst_lane_template (
            .ap_clk                              (ap_clk                                                                                    ),
            .areset                              (areset_lane[j]                                                                            ),
            .descriptor_in                       (lanes_descriptor_in[j]                                                                    ),
            .response_lane_in                    (lanes_response_merge_engine_in[j][LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]:0]               ),
            .fifo_response_lane_in_signals_in    (lanes_fifo_response_merge_lane_in_signals_in[j][LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]:0] ),
            .fifo_response_lane_in_signals_out   (lanes_fifo_response_merge_lane_in_signals_out[j][LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]:0]),
            .response_memory_in                  (lanes_response_memory_in[j]                                                               ),
            .fifo_response_memory_in_signals_in  (lanes_fifo_response_memory_in_signals_in[j]                                               ),
            .fifo_response_memory_in_signals_out (lanes_fifo_response_memory_in_signals_out[j]                                              ),
            .response_control_in                 (lanes_response_control_in[j]                                                              ),
            .fifo_response_control_in_signals_in (lanes_fifo_response_control_in_signals_in[j]                                              ),
            .fifo_response_control_in_signals_out(lanes_fifo_response_control_in_signals_out[j]                                             ),
            .request_lane_out                    (lanes_request_cast_lane_out[j][LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]:0]                   ),
            .fifo_request_lane_out_signals_in    (lanes_fifo_request_cast_lane_out_signals_in[j][LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]:0]   ),
            .fifo_request_lane_out_signals_out   (lanes_fifo_request_cast_lane_out_signals_out[j][LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]:0]  ),
            .request_memory_out                  (lanes_request_memory_out[j]                                                               ),
            .fifo_request_memory_out_signals_in  (lanes_fifo_request_memory_out_signals_in[j]                                               ),
            .fifo_request_memory_out_signals_out (lanes_fifo_request_memory_out_signals_out[j]                                              ),
            .request_control_out                 (lanes_request_control_out[j]                                                              ),
            .fifo_request_control_out_signals_in (lanes_fifo_request_control_out_signals_in[j]                                              ),
            .fifo_request_control_out_signals_out(lanes_fifo_request_control_out_signals_out[j]                                             ),
            .fifo_setup_signal                   (lanes_fifo_setup_signal[j]                                                                ),
            .done_out                            (lanes_done_out[j]                                                                         )
        );
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes MERGE/CAST wires
// --------------------------------------------------------------------------------------
`include "bundle_topology.vh"

endmodule : bundle_lanes