// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cu_bundles.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-01 14:14:12
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module cu_bundles #(
    `include "cu_parameters.vh"
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output MemoryPacket           request_memory_out                 ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out,
    output logic                  fifo_setup_signal                  ,
    output logic                  done_out
);

genvar i;
genvar j;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_cu_bundles;
logic areset_fifo      ;

KernelDescriptor descriptor_in_reg;

ControlPacket request_control_out_int;
MemoryPacket  request_memory_out_int ;
ControlPacket response_control_in_int;
ControlPacket response_control_in_reg;
MemoryPacket  response_memory_in_int ;
MemoryPacket  response_memory_in_reg ;

logic fifo_empty_int;
logic fifo_empty_reg;
// --------------------------------------------------------------------------------------
// FIFO INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_response_memory_in_signals_in_int  ;
FIFOStateSignalsInput         fifo_response_memory_in_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_response_memory_in_signals_out_int ;
logic                         fifo_response_memory_in_setup_signal_int;
MemoryPacketPayload           fifo_response_memory_in_din             ;
MemoryPacketPayload           fifo_response_memory_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_response_control_in_signals_in_int  ;
FIFOStateSignalsInput         fifo_response_control_in_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_response_control_in_signals_out_int ;
logic                         fifo_response_control_in_setup_signal_int;
ControlPacketPayload          fifo_response_control_in_din             ;
ControlPacketPayload          fifo_response_control_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Request EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_request_memory_out_signals_in_int  ;
FIFOStateSignalsInput         fifo_request_memory_out_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_request_memory_out_signals_out_int ;
logic                         fifo_request_memory_out_setup_signal_int;
MemoryPacketPayload           fifo_request_memory_out_din             ;
MemoryPacketPayload           fifo_request_memory_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL Request EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_request_control_out_signals_in_int  ;
FIFOStateSignalsInput         fifo_request_control_out_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_request_control_out_signals_out_int ;
logic                         fifo_request_control_out_setup_signal_int;
ControlPacketPayload          fifo_request_control_out_din             ;
ControlPacketPayload          fifo_request_control_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT BackTrack Avoid mem -> engine deadlocks
// --------------------------------------------------------------------------------------
FIFOStateSignalsOutput bundle_fifo_response_lanes_backtrack_signals_out[NUM_BUNDLES-1:0][NUM_LANES_MAX-1:0];
FIFOStateSignalsOutput bundle_fifo_response_lanes_backtrack_signals_in [NUM_BUNDLES-1:0][NUM_LANES_MAX-1:0];

// --------------------------------------------------------------------------------------
// Generate Bundles
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  bundle_fifo_request_control_out_signals_in [NUM_BUNDLES-1:0];
FIFOStateSignalsInput  bundle_fifo_request_lanes_out_signals_in   [NUM_BUNDLES-1:0];
FIFOStateSignalsInput  bundle_fifo_request_memory_out_signals_in  [NUM_BUNDLES-1:0];
FIFOStateSignalsInput  bundle_fifo_response_control_in_signals_in [NUM_BUNDLES-1:0];
FIFOStateSignalsInput  bundle_fifo_response_lanes_in_signals_in   [NUM_BUNDLES-1:0];
FIFOStateSignalsInput  bundle_fifo_response_memory_in_signals_in  [NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_fifo_request_control_out_signals_out[NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_fifo_request_lanes_out_signals_out  [NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_fifo_request_memory_out_signals_out [NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_fifo_response_control_in_signals_out[NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_fifo_response_lanes_in_signals_out  [NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_fifo_response_memory_in_signals_out [NUM_BUNDLES-1:0];
KernelDescriptor       bundle_descriptor_in                       [NUM_BUNDLES-1:0];
logic                  areset_bundle                              [NUM_BUNDLES-1:0];
logic                  bundle_done_out                            [NUM_BUNDLES-1:0];
logic                  bundle_fifo_setup_signal                   [NUM_BUNDLES-1:0];
ControlPacket          bundle_request_control_out                 [NUM_BUNDLES-1:0];
EnginePacket           bundle_request_lanes_out                   [NUM_BUNDLES-1:0];
MemoryPacket           bundle_request_memory_out                  [NUM_BUNDLES-1:0];
ControlPacket          bundle_response_control_in                 [NUM_BUNDLES-1:0];
EnginePacket           bundle_response_lanes_in                   [NUM_BUNDLES-1:0];
MemoryPacket           bundle_response_memory_in                  [NUM_BUNDLES-1:0];

logic [NUM_BUNDLES-1:0] bundle_fifo_setup_signal_reg;
logic [NUM_BUNDLES-1:0] bundle_done_out_reg         ;

// --------------------------------------------------------------------------------------
// Generate Bundles -  Memory Arbitration OUTPUT
// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput   bundle_arbiter_memory_N_to_1_fifo_request_signals_in                  ;
FIFOStateSignalsOutput  bundle_arbiter_memory_N_to_1_fifo_request_signals_out                 ;
logic                   areset_arbiter_memory_N_to_1                                          ;
logic                   bundle_arbiter_memory_N_to_1_fifo_setup_signal                        ;
logic [NUM_BUNDLES-1:0] bundle_arbiter_memory_N_to_1_arbiter_grant_out                        ;
logic [NUM_BUNDLES-1:0] bundle_arbiter_memory_N_to_1_arbiter_request_in                       ;
MemoryPacket            bundle_arbiter_memory_N_to_1_request_in              [NUM_BUNDLES-1:0];
MemoryPacket            bundle_arbiter_memory_N_to_1_request_out                              ;

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request CONTROL Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput   bundle_arbiter_control_N_to_1_fifo_request_signals_in                  ;
FIFOStateSignalsOutput  bundle_arbiter_control_N_to_1_fifo_request_signals_out                 ;
logic                   areset_arbiter_control_N_to_1                                          ;
logic                   bundle_arbiter_control_N_to_1_fifo_setup_signal                        ;
logic [NUM_BUNDLES-1:0] bundle_arbiter_control_N_to_1_arbiter_grant_out                        ;
logic [NUM_BUNDLES-1:0] bundle_arbiter_control_N_to_1_arbiter_request_in                       ;
ControlPacket           bundle_arbiter_control_N_to_1_request_in              [NUM_BUNDLES-1:0];
ControlPacket           bundle_arbiter_control_N_to_1_request_out                              ;

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  bundle_arbiter_memory_1_to_N_fifo_response_signals_in [NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_arbiter_memory_1_to_N_fifo_response_signals_out                 ;
logic                  areset_arbiter_memory_1_to_N                                           ;
logic                  bundle_arbiter_memory_1_to_N_fifo_setup_signal                         ;
MemoryPacket           bundle_arbiter_memory_1_to_N_response_in                               ;
MemoryPacket           bundle_arbiter_memory_1_to_N_response_out             [NUM_BUNDLES-1:0];

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: CONTROL Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  bundle_arbiter_control_1_to_N_fifo_response_signals_in [NUM_BUNDLES-1:0];
FIFOStateSignalsOutput bundle_arbiter_control_1_to_N_fifo_response_signals_out                 ;
logic                  areset_arbiter_control_1_to_N                                           ;
logic                  bundle_arbiter_control_1_to_N_fifo_setup_signal                         ;
ControlPacket          bundle_arbiter_control_1_to_N_response_in                               ;
ControlPacket          bundle_arbiter_control_1_to_N_response_out             [NUM_BUNDLES-1:0];

// --------------------------------------------------------------------------------------
// CONTROL Variables
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  fifo_request_control_out_signals_in ;
FIFOStateSignalsInput  fifo_response_control_in_signals_in ;
FIFOStateSignalsOutput fifo_request_control_out_signals_out;
FIFOStateSignalsOutput fifo_response_control_in_signals_out;
ControlPacket          request_control_out                 ;
ControlPacket          response_control_in                 ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_arbiter_memory_1_to_N  <= areset;
    areset_arbiter_control_1_to_N <= areset;
    areset_arbiter_control_N_to_1 <= areset;
    areset_arbiter_memory_N_to_1  <= areset;
    areset_cu_bundles             <= areset;
    areset_fifo                   <= areset;
end

// --------------------------------------------------------------------------------------
// assign CONTROL Variables
// --------------------------------------------------------------------------------------
assign fifo_request_control_out_signals_in.rd_en = ~fifo_response_control_in_signals_out.prog_full & ~fifo_request_control_out_signals_out.empty;
assign fifo_response_control_in_signals_in.rd_en = 1'b1;
assign response_control_in                       = request_control_out;

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_cu_bundles) begin
        descriptor_in_reg.valid <= 0;
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
    if (areset_cu_bundles) begin
        fifo_request_control_out_signals_in_reg <= 0;
        fifo_request_memory_out_signals_in_reg  <= 0;
        fifo_response_control_in_signals_in_reg <= 0;
        fifo_response_memory_in_signals_in_reg  <= 0;
        response_control_in_reg.valid           <= 1'b0;
        response_memory_in_reg.valid            <= 1'b0;
    end
    else begin
        fifo_request_control_out_signals_in_reg <= fifo_request_control_out_signals_in;
        fifo_request_memory_out_signals_in_reg  <= fifo_request_memory_out_signals_in;
        fifo_response_control_in_signals_in_reg <= fifo_response_control_in_signals_in;
        fifo_response_memory_in_signals_in_reg  <= fifo_response_memory_in_signals_in;
        response_control_in_reg.valid           <= response_control_in.valid;
        response_memory_in_reg.valid            <= response_memory_in.valid;
    end
end

always_ff @(posedge ap_clk) begin
    response_control_in_reg.payload <= response_control_in.payload;
    response_memory_in_reg.payload  <= response_memory_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_cu_bundles) begin
        done_out                  <= 1'b0;
        fifo_empty_reg            <= 1'b1;
        fifo_setup_signal         <= 1'b1;
        request_control_out.valid <= 1'b0;
        request_memory_out.valid  <= 1'b0;
    end
    else begin
        done_out                  <= (&bundle_done_out_reg) & fifo_empty_reg;
        fifo_empty_reg            <= fifo_empty_int;
        fifo_setup_signal         <= fifo_request_memory_out_setup_signal_int | fifo_request_control_out_setup_signal_int | fifo_response_control_in_setup_signal_int |fifo_response_memory_in_setup_signal_int | (|bundle_fifo_setup_signal_reg) | bundle_arbiter_memory_N_to_1_fifo_setup_signal | bundle_arbiter_control_N_to_1_fifo_setup_signal| bundle_arbiter_control_1_to_N_fifo_setup_signal | bundle_arbiter_memory_1_to_N_fifo_setup_signal;
        request_control_out.valid <= request_control_out_int.valid ;
        request_memory_out.valid  <= request_memory_out_int.valid ;
    end
end

assign fifo_empty_int = fifo_response_memory_in_signals_out_int.empty & fifo_response_control_in_signals_out_int.empty & fifo_request_memory_out_signals_out_int.empty & fifo_request_control_out_signals_out_int.empty & bundle_arbiter_memory_N_to_1_fifo_request_signals_out.empty  & bundle_arbiter_control_N_to_1_fifo_request_signals_out.empty  &  bundle_arbiter_control_1_to_N_fifo_response_signals_out.empty & bundle_arbiter_memory_1_to_N_fifo_response_signals_out.empty;

always_ff @(posedge ap_clk) begin
    fifo_request_control_out_signals_out <= map_internal_fifo_signals_to_output(fifo_request_control_out_signals_out_int);
    fifo_request_memory_out_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_memory_out_signals_out_int);
    fifo_response_control_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_control_in_signals_out_int);
    fifo_response_memory_in_signals_out  <= map_internal_fifo_signals_to_output(fifo_response_memory_in_signals_out_int);
    request_control_out.payload          <= request_control_out_int.payload;
    request_memory_out.payload           <= request_memory_out_int.payload;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_memory_in_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy | fifo_response_memory_in_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid;
assign fifo_response_memory_in_din                  = response_memory_in_reg.payload;

// Pop
assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~bundle_arbiter_memory_1_to_N_fifo_response_signals_out.prog_full;
assign response_memory_in_int.valid                 = fifo_response_memory_in_signals_out_int.valid;
assign response_memory_in_int.payload               = fifo_response_memory_in_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_EnginePacketResponseMemoryInput (
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
// FIFO CONTROL INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_control_in_setup_signal_int = fifo_response_control_in_signals_out_int.wr_rst_busy | fifo_response_control_in_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_control_in_signals_in_int.wr_en = response_control_in_reg.valid;
assign fifo_response_control_in_din                  = response_control_in_reg.payload;

// Pop
assign fifo_response_control_in_signals_in_int.rd_en = ~fifo_response_control_in_signals_out_int.empty & fifo_response_control_in_signals_in_reg.rd_en & ~bundle_arbiter_memory_1_to_N_fifo_response_signals_out.prog_full;
assign response_control_in_int.valid                 = fifo_response_control_in_signals_out_int.valid;
assign response_control_in_int.payload               = fifo_response_control_in_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH           ),
    .WRITE_DATA_WIDTH($bits(ControlPacketPayload)),
    .READ_DATA_WIDTH ($bits(ControlPacketPayload)),
    .PROG_THRESH     (PROG_THRESH                )
) inst_fifo_EnginePacketResponseControlInput (
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
// FIFO OUTPUT requests EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_memory_out_signals_in_int.wr_en = bundle_arbiter_memory_N_to_1_request_out.valid;
assign fifo_request_memory_out_din                  = bundle_arbiter_memory_N_to_1_request_out.payload;

// Pop
assign fifo_request_memory_out_signals_in_int.rd_en = ~fifo_request_memory_out_signals_out_int.empty & fifo_request_memory_out_signals_in_reg.rd_en;
assign request_memory_out_int.valid                 = fifo_request_memory_out_signals_out_int.valid;
assign request_memory_out_int.payload               = fifo_request_memory_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_EnginePacketRequestMemoryOutput (
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
// FIFO OUTPUT requests CONTROL EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_control_out_setup_signal_int = fifo_request_control_out_signals_out_int.wr_rst_busy | fifo_request_control_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_control_out_signals_in_int.wr_en = bundle_arbiter_control_N_to_1_request_out.valid;
assign fifo_request_control_out_din                  = bundle_arbiter_control_N_to_1_request_out.payload;

// Pop
assign fifo_request_control_out_signals_in_int.rd_en = ~fifo_request_control_out_signals_out_int.empty & fifo_request_control_out_signals_in_reg.rd_en;
assign request_control_out_int.valid                 = fifo_request_control_out_signals_out_int.valid;
assign request_control_out_int.payload               = fifo_request_control_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH           ),
    .WRITE_DATA_WIDTH($bits(ControlPacketPayload)),
    .READ_DATA_WIDTH ($bits(ControlPacketPayload)),
    .PROG_THRESH     (PROG_THRESH                )
) inst_fifo_EnginePacketRequestControlOutput (
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
// Generate Bundles Arbitration|Instants|Signals
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Generate Bundles - Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    for (int i=0; i<NUM_BUNDLES; i++) begin
        areset_bundle[i] <= areset;
    end
end

always_ff @(posedge ap_clk) begin
    if (areset_cu_bundles) begin
        for (int i=0; i<NUM_BUNDLES; i++) begin
            bundle_descriptor_in[i].valid <= 0;
        end
    end
    else begin
        for (int i=0; i<NUM_BUNDLES; i++) begin
            bundle_descriptor_in[i].valid <= descriptor_in_reg.valid;
        end
    end
end

always_ff @(posedge ap_clk) begin
    for (int i=0; i<NUM_BUNDLES; i++) begin
        bundle_descriptor_in[i].payload <= descriptor_in_reg.payload;
    end
end

// --------------------------------------------------------------------------------------
// Generate Bundles - Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_cu_bundles) begin
        for (int i=0; i<NUM_BUNDLES; i++) begin
            bundle_fifo_setup_signal_reg[i] <= 1'b1;
            bundle_done_out_reg[i]          <= 1'b1;
        end
    end
    else begin
        for (int i=0; i<NUM_BUNDLES; i++) begin
            bundle_fifo_setup_signal_reg[i] <= bundle_fifo_setup_signal[i];
            bundle_done_out_reg[i]          <= bundle_done_out[i];
        end
    end
end

// --------------------------------------------------------------------------------------
// Generate Bundles - Drive Intra-signals
// --------------------------------------------------------------------------------------
// Generate Bundles - [0]->[1]->[2]->[3]->[4]->[0]
// --------------------------------------------------------------------------------------
assign bundle_response_lanes_in[0] = bundle_request_lanes_out[NUM_BUNDLES-1];
assign bundle_fifo_request_lanes_out_signals_in[NUM_BUNDLES-1].rd_en = ~bundle_fifo_response_lanes_in_signals_out[0].prog_full;
assign bundle_fifo_response_lanes_in_signals_in[0].rd_en = 1'b1;
generate
    for (i=1; i<NUM_BUNDLES; i++) begin : generate_bundle_intra_signals
        assign bundle_response_lanes_in[i] = bundle_request_lanes_out[i-1];
        assign bundle_fifo_request_lanes_out_signals_in[i-1].rd_en = ~bundle_fifo_response_lanes_in_signals_out[i].prog_full;
        assign bundle_fifo_response_lanes_in_signals_in[i].rd_en = 1'b1;
    end
endgenerate

assign bundle_fifo_response_lanes_backtrack_signals_in[NUM_BUNDLES-1][LANES_COUNT_ARRAY[0]-1:0] = bundle_fifo_response_lanes_backtrack_signals_out[0][LANES_COUNT_ARRAY[0]-1:0];
generate
    for (i=0; i<NUM_BUNDLES-1; i++) begin : generate_bundle_backtrack_signals
        assign bundle_fifo_response_lanes_backtrack_signals_in[i][LANES_COUNT_ARRAY[i+1]-1:0] = bundle_fifo_response_lanes_backtrack_signals_out[i+1][LANES_COUNT_ARRAY[i+1]-1:0];
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - Memory Arbitration OUTPUT
// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
generate
    if(BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY>0) begin
// --------------------------------------------------------------------------------------
        arbiter_N_to_1_request_memory #(
            .NUM_MEMORY_REQUESTOR(BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY      ),
            .FIFO_ARBITER_DEPTH  (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
        ) inst_bundle_arbiter_memory_N_to_1_request_memory_out (
            .ap_clk                  (ap_clk                                                                                  ),
            .areset                  (areset_arbiter_memory_N_to_1                                                            ),
            .request_in              (bundle_arbiter_memory_N_to_1_request_in[BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY-1:0]       ),
            .fifo_request_signals_in (bundle_arbiter_memory_N_to_1_fifo_request_signals_in                                    ),
            .fifo_request_signals_out(bundle_arbiter_memory_N_to_1_fifo_request_signals_out                                   ),
            .arbiter_grant_out       (bundle_arbiter_memory_N_to_1_arbiter_grant_out[BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY-1:0]),
            .request_out             (bundle_arbiter_memory_N_to_1_request_out                                                ),
            .fifo_setup_signal       (bundle_arbiter_memory_N_to_1_fifo_setup_signal                                          )
        );
// --------------------------------------------------------------------------------------
    end else begin
        for (i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_memory_N_to_1_request_in
            assign bundle_fifo_request_memory_out_signals_in[i].rd_en  = 1'b0;
        end
        assign bundle_arbiter_memory_N_to_1_fifo_request_signals_out = 2'b10;
        assign bundle_arbiter_memory_N_to_1_arbiter_grant_out        = 0;
        assign bundle_arbiter_memory_N_to_1_request_out              = 0;
        assign bundle_arbiter_memory_N_to_1_fifo_setup_signal        = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - Memory Arbitration OUTPUT
// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request CONTROL Generator
// --------------------------------------------------------------------------------------
generate
    if(BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST>0) begin
// --------------------------------------------------------------------------------------
        arbiter_N_to_1_request_control #(
            .NUM_CONTROL_REQUESTOR(BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST      ),
            .FIFO_ARBITER_DEPTH   (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST)
        ) inst_bundle_arbiter_control_N_to_1_request_control_out (
            .ap_clk                  (ap_clk                                                                                            ),
            .areset                  (areset_arbiter_control_N_to_1                                                                     ),
            .request_in              (bundle_arbiter_control_N_to_1_request_in[BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST-1:0]       ),
            .fifo_request_signals_in (bundle_arbiter_control_N_to_1_fifo_request_signals_in                                             ),
            .fifo_request_signals_out(bundle_arbiter_control_N_to_1_fifo_request_signals_out                                            ),
            .arbiter_grant_out       (bundle_arbiter_control_N_to_1_arbiter_grant_out[BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST-1:0]),
            .request_out             (bundle_arbiter_control_N_to_1_request_out                                                         ),
            .fifo_setup_signal       (bundle_arbiter_control_N_to_1_fifo_setup_signal                                                   )
        );
// --------------------------------------------------------------------------------------
    end else begin
        for (i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_control_N_to_1_request_in
            assign bundle_fifo_request_control_out_signals_in[i].rd_en  = 1'b0;
        end
        assign bundle_arbiter_control_N_to_1_fifo_request_signals_out = 2'b10;
        assign bundle_arbiter_control_N_to_1_arbiter_grant_out        = 0;
        assign bundle_arbiter_control_N_to_1_request_out              = 0;
        assign bundle_arbiter_control_N_to_1_fifo_setup_signal        = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
assign bundle_arbiter_memory_1_to_N_response_in = response_memory_in_int;
generate
    for (i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_memory_1_to_N_response
        assign bundle_arbiter_memory_1_to_N_fifo_response_signals_in[i].rd_en = ~bundle_fifo_response_memory_in_signals_out[i].prog_full;
        assign bundle_response_memory_in[i] = bundle_arbiter_memory_1_to_N_response_out[i];
        assign bundle_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
    end
endgenerate

// --------------------------------------------------------------------------------------
arbiter_1_to_N_response_memory #(
    .NUM_MEMORY_RECEIVER(NUM_BUNDLES                               ),
    .ID_LEVEL           (1                                         ),
    .FIFO_ARBITER_DEPTH (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY)
) inst_bundle_arbiter_memory_1_to_N_response_memory_in (
    .ap_clk                   (ap_clk                                                ),
    .areset                   (areset_arbiter_memory_1_to_N                          ),
    .response_in              (bundle_arbiter_memory_1_to_N_response_in              ),
    .fifo_response_signals_in (bundle_arbiter_memory_1_to_N_fifo_response_signals_in ),
    .fifo_response_signals_out(bundle_arbiter_memory_1_to_N_fifo_response_signals_out),
    .response_out             (bundle_arbiter_memory_1_to_N_response_out             ),
    .fifo_setup_signal        (bundle_arbiter_memory_1_to_N_fifo_setup_signal        )
);

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: CONTROL Response Generator
// --------------------------------------------------------------------------------------
generate
    if(BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE>0) begin
// --------------------------------------------------------------------------------------
        arbiter_1_to_N_response_control #(
            .NUM_CONTROL_RECEIVER(BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE      ),
            .ID_LEVEL            (1                                                   ),
            .FIFO_ARBITER_DEPTH  (BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)
        ) inst_bundle_arbiter_control_1_to_N_response_control_in (
            .ap_clk                   (ap_clk                                                                                                    ),
            .areset                   (areset_arbiter_control_1_to_N                                                                             ),
            .response_in              (bundle_arbiter_control_1_to_N_response_in                                                                 ),
            .fifo_response_signals_in (bundle_arbiter_control_1_to_N_fifo_response_signals_in[BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE-1:0]),
            .fifo_response_signals_out(bundle_arbiter_control_1_to_N_fifo_response_signals_out                                                   ),
            .response_out             (bundle_arbiter_control_1_to_N_response_out[BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE-1:0]            ),
            .fifo_setup_signal        (bundle_arbiter_control_1_to_N_fifo_setup_signal                                                           )
        );
// --------------------------------------------------------------------------------------
    end else begin
        for (i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_control_1_to_N_response
            assign bundle_response_control_in[i] = 0;
            assign bundle_fifo_response_control_in_signals_in[i].rd_en  = 1'b0;
            assign bundle_arbiter_control_1_to_N_response_out[i] = 0;
        end
        assign bundle_arbiter_control_1_to_N_fifo_response_signals_out = 2'b10;
        assign bundle_arbiter_control_1_to_N_fifo_setup_signal         = 1'b0;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
generate
    for (j=0; j<NUM_BUNDLES; j++) begin : generate_bundle_lanes
        bundle_lanes #(
            `include"set_bundle_parameters.vh"
        ) inst_bundle_lanes (
            .ap_clk                                   (ap_clk                                                                                      ),
            .areset                                   (areset_bundle[j]                                                                            ),
            .descriptor_in                            (bundle_descriptor_in[j]                                                                     ),
            .response_lanes_in                        (bundle_response_lanes_in[j]                                                                 ),
            .fifo_response_lanes_in_signals_in        (bundle_fifo_response_lanes_in_signals_in[j]                                                 ),
            .fifo_response_lanes_in_signals_out       (bundle_fifo_response_lanes_in_signals_out[j]                                                ),
            .fifo_response_lanes_backtrack_signals_out(bundle_fifo_response_lanes_backtrack_signals_out[j][LANES_COUNT_ARRAY[j]-1:0]               ),
            .fifo_response_lanes_backtrack_signals_in (bundle_fifo_response_lanes_backtrack_signals_in[j][LANES_COUNT_ARRAY[(j+1)%NUM_BUNDLES]-1:0]),
            .response_memory_in                       (bundle_response_memory_in[j]                                                                ),
            .fifo_response_memory_in_signals_in       (bundle_fifo_response_memory_in_signals_in[j]                                                ),
            .fifo_response_memory_in_signals_out      (bundle_fifo_response_memory_in_signals_out[j]                                               ),
            .response_control_in                      (bundle_response_control_in[j]                                                               ),
            .fifo_response_control_in_signals_in      (bundle_fifo_response_control_in_signals_in[j]                                               ),
            .fifo_response_control_in_signals_out     (bundle_fifo_response_control_in_signals_out[j]                                              ),
            .request_lanes_out                        (bundle_request_lanes_out[j]                                                                 ),
            .fifo_request_lanes_out_signals_in        (bundle_fifo_request_lanes_out_signals_in[j]                                                 ),
            .fifo_request_lanes_out_signals_out       (bundle_fifo_request_lanes_out_signals_out[j]                                                ),
            .request_memory_out                       (bundle_request_memory_out[j]                                                                ),
            .fifo_request_memory_out_signals_in       (bundle_fifo_request_memory_out_signals_in[j]                                                ),
            .fifo_request_memory_out_signals_out      (bundle_fifo_request_memory_out_signals_out[j]                                               ),
            .request_control_out                      (bundle_request_control_out[j]                                                               ),
            .fifo_request_control_out_signals_in      (bundle_fifo_request_control_out_signals_in[j]                                               ),
            .fifo_request_control_out_signals_out     (bundle_fifo_request_control_out_signals_out[j]                                              ),
            .fifo_setup_signal                        (bundle_fifo_setup_signal[j]                                                                 ),
            .done_out                                 (bundle_done_out[j]                                                                          )
        );
    end
endgenerate

// --------------------------------------------------------------------------------------
// Generate bundle MERGE/CAST wires
// --------------------------------------------------------------------------------------
`include "cu_arbitration.vh"

endmodule : cu_bundles