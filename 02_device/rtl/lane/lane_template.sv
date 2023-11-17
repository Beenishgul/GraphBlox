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

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_SETUP::*;
import PKG_CACHE::*;

module lane_template #(
    `include "lane_parameters.vh"
    ) (
    // System Signals
    input  logic                  ap_clk                                                     ,
    input  logic                  areset                                                     ,
    input  KernelDescriptor       descriptor_in                                              ,
    input  MemoryPacket           response_lane_in[(1+LANE_MERGE_WIDTH)-1:0]                 ,
    input  FIFOStateSignalsInput  fifo_response_lane_in_signals_in[(1+LANE_MERGE_WIDTH)-1:0] ,
    output FIFOStateSignalsOutput fifo_response_lane_in_signals_out[(1+LANE_MERGE_WIDTH)-1:0],
    input  MemoryPacket           response_memory_in                                         ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                         ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                        ,
    input  MemoryPacket           response_control_in                                        ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in                        ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out                       ,
    output MemoryPacket           request_lane_out[ (1+LANE_CAST_WIDTH)-1:0]                 ,
    input  FIFOStateSignalsInput  fifo_request_lane_out_signals_in[ (1+LANE_CAST_WIDTH)-1:0] ,
    output FIFOStateSignalsOutput fifo_request_lane_out_signals_out[ (1+LANE_CAST_WIDTH)-1:0],
    output MemoryPacket           request_memory_out                                         ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                         ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                        ,
    output MemoryPacket           request_control_out                                        ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in                        ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out                       ,
    output logic                  fifo_setup_signal                                          ,
    output logic                  done_out
);

    genvar j;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_lane_template;
    logic areset_fifo         ;

    KernelDescriptor descriptor_in_reg;

    MemoryPacket request_control_out_int;
    MemoryPacket request_lane_out_int   ;
    MemoryPacket request_memory_out_int ;
    MemoryPacket response_control_in_int;
    MemoryPacket response_control_in_reg;
    MemoryPacket response_lane_in_int   ;
    MemoryPacket response_lane_in_reg   ;
    MemoryPacket response_memory_in_int ;
    MemoryPacket response_memory_in_reg ;

    logic fifo_empty_int;
    logic fifo_empty_reg;
// --------------------------------------------------------------------------------------
// FIFO Engines INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_response_lane_in_signals_in_int  ;
    FIFOStateSignalsInput  fifo_response_lane_in_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_response_lane_in_signals_out_int ;
    logic                  fifo_response_lane_in_setup_signal_int;
    MemoryPacketPayload    fifo_response_lane_in_din             ;
    MemoryPacketPayload    fifo_response_lane_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_int  ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_int ;
    logic                  fifo_response_memory_in_setup_signal_int;
    MemoryPacketPayload    fifo_response_memory_in_din             ;
    MemoryPacketPayload    fifo_response_memory_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_response_control_in_signals_in_int  ;
    FIFOStateSignalsInput  fifo_response_control_in_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_response_control_in_signals_out_int ;
    logic                  fifo_response_control_in_setup_signal_int;
    MemoryPacketPayload    fifo_response_control_in_din             ;
    MemoryPacketPayload    fifo_response_control_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO Engines OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_request_lane_out_signals_in_int  ;
    FIFOStateSignalsInput  fifo_request_lane_out_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_request_lane_out_signals_out_int ;
    logic                  fifo_request_lane_out_setup_signal_int;
    MemoryPacketPayload    fifo_request_lane_out_din             ;
    MemoryPacketPayload    fifo_request_lane_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_int  ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_request_memory_out_signals_out_int ;
    logic                  fifo_request_memory_out_setup_signal_int;
    MemoryPacketPayload    fifo_request_memory_out_din             ;
    MemoryPacketPayload    fifo_request_memory_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL Request CONTROL MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_request_control_out_signals_in_int  ;
    FIFOStateSignalsInput  fifo_request_control_out_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_request_control_out_signals_out_int ;
    logic                  fifo_request_control_out_setup_signal_int;
    MemoryPacketPayload    fifo_request_control_out_din             ;
    MemoryPacketPayload    fifo_request_control_out_dout            ;

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput   engine_arbiter_N_to_1_memory_fifo_request_signals_in                   ;
    FIFOStateSignalsOutput  engine_arbiter_N_to_1_memory_fifo_request_signals_out                  ;
    logic                   areset_engine_arbiter_N_to_1_memory                                    ;
    logic                   engine_arbiter_N_to_1_memory_fifo_setup_signal                         ;
    logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_memory_engine_arbiter_grant_out                  ;
    logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_memory_engine_arbiter_request_in                 ;
    MemoryPacket            engine_arbiter_N_to_1_memory_request_in               [NUM_ENGINES-1:0];
    MemoryPacket            engine_arbiter_N_to_1_memory_request_out                               ;

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: CONTROL Request Generator
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput   engine_arbiter_N_to_1_control_fifo_request_signals_in                   ;
    FIFOStateSignalsOutput  engine_arbiter_N_to_1_control_fifo_request_signals_out                  ;
    logic                   areset_engine_arbiter_N_to_1_control                                    ;
    logic                   engine_arbiter_N_to_1_control_fifo_setup_signal                         ;
    logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_control_engine_arbiter_grant_out                  ;
    logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_control_engine_arbiter_request_in                 ;
    MemoryPacket            engine_arbiter_N_to_1_control_request_in               [NUM_ENGINES-1:0];
    MemoryPacket            engine_arbiter_N_to_1_control_request_out                               ;

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  engine_arbiter_1_to_N_memory_fifo_response_signals_in [NUM_ENGINES-1:0];
    FIFOStateSignalsOutput engine_arbiter_1_to_N_memory_fifo_response_signals_out                 ;
    logic                  areset_engine_arbiter_1_to_N_memory                                    ;
    logic                  engine_arbiter_1_to_N_memory_fifo_setup_signal                         ;
    MemoryPacket           engine_arbiter_1_to_N_memory_response_in                               ;
    MemoryPacket           engine_arbiter_1_to_N_memory_response_out             [NUM_ENGINES-1:0];

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  engine_arbiter_1_to_N_control_fifo_response_signals_in [NUM_ENGINES-1:0];
    FIFOStateSignalsOutput engine_arbiter_1_to_N_control_fifo_response_signals_out                 ;
    logic                  areset_engine_arbiter_1_to_N_control                                    ;
    logic                  engine_arbiter_1_to_N_control_fifo_setup_signal                         ;
    MemoryPacket           engine_arbiter_1_to_N_control_response_in                               ;
    MemoryPacket           engine_arbiter_1_to_N_control_response_out             [NUM_ENGINES-1:0];

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
    KernelDescriptor        engines_descriptor_in                       [NUM_ENGINES-1:0];
    logic                   areset_engine                               [NUM_ENGINES-1:0];
    logic                   engines_done_out                            [NUM_ENGINES-1:0];
    logic                   engines_fifo_setup_signal                   [NUM_ENGINES-1:0];
    logic [NUM_ENGINES-1:0] engines_done_out_reg                                         ;
    logic [NUM_ENGINES-1:0] engines_fifo_setup_signal_reg                                ;
    MemoryPacket            engines_request_control_out                 [NUM_ENGINES-1:0];
    MemoryPacket            engines_request_control_out_int                              ;
    MemoryPacket            engines_request_lane_out                    [NUM_ENGINES-1:0];
    MemoryPacket            engines_request_lane_out_int                                 ;
    MemoryPacket            engines_request_memory_out                  [NUM_ENGINES-1:0];
    MemoryPacket            engines_request_memory_out_int                               ;
    MemoryPacket            engines_response_control_in                 [NUM_ENGINES-1:0];
    MemoryPacket            engines_response_lane_in                    [NUM_ENGINES-1:0];
    MemoryPacket            engines_response_memory_in                  [NUM_ENGINES-1:0];

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  engines_fifo_request_cast_lane_out_signals_in  [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
    FIFOStateSignalsInput  engines_fifo_response_merge_lane_in_signals_in [NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];
    FIFOStateSignalsOutput engines_fifo_request_cast_lane_out_signals_out [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
    FIFOStateSignalsOutput engines_fifo_response_merge_lane_in_signals_out[NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];
    MemoryPacket           engines_request_cast_lane_out                  [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
    MemoryPacket           engines_response_merge_lane_in                 [NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_engine_arbiter_1_to_N_control <= areset;
        areset_engine_arbiter_1_to_N_memory  <= areset;
        areset_engine_arbiter_N_to_1_control <= areset;
        areset_engine_arbiter_N_to_1_memory  <= areset;
        areset_fifo                          <= areset;
        areset_lane_template                 <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_lane_template) begin
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
            fifo_setup_signal         <= fifo_response_lane_in_setup_signal_int | fifo_response_control_in_setup_signal_int  | engine_arbiter_N_to_1_memory_fifo_setup_signal |  engine_arbiter_N_to_1_control_fifo_setup_signal |  engine_arbiter_1_to_N_memory_fifo_setup_signal | engine_arbiter_1_to_N_control_fifo_setup_signal | fifo_response_memory_in_setup_signal_int | fifo_request_lane_out_setup_signal_int | fifo_request_control_out_setup_signal_int | fifo_request_memory_out_setup_signal_int | (|engines_fifo_setup_signal_reg);
            request_control_out.valid <= request_control_out_int.valid;
            request_lane_out[0].valid <= request_lane_out_int.valid ;
            request_memory_out.valid  <= request_memory_out_int.valid;
        end
    end

    assign fifo_empty_int = fifo_response_lane_in_signals_out_int.empty & fifo_response_control_in_signals_out_int.empty & fifo_response_memory_in_signals_out_int.empty & fifo_request_lane_out_signals_out_int.empty & fifo_request_memory_out_signals_out_int.empty & fifo_request_control_out_signals_out_int.empty & engine_arbiter_1_to_N_control_fifo_response_signals_out.empty & engine_arbiter_N_to_1_memory_fifo_request_signals_out.empty & engine_arbiter_N_to_1_control_fifo_request_signals_out.empty & engine_arbiter_1_to_N_memory_fifo_response_signals_out.empty;

    always_ff @(posedge ap_clk) begin
        fifo_request_control_out_signals_out <= fifo_request_control_out_signals_out_int;
        fifo_request_lane_out_signals_out[0] <= fifo_request_lane_out_signals_out_int;
        fifo_request_memory_out_signals_out  <= fifo_request_memory_out_signals_out_int;
        fifo_response_control_in_signals_out <= fifo_response_control_in_signals_out_int;
        fifo_response_lane_in_signals_out[0] <= fifo_response_lane_in_signals_out_int;
        fifo_response_memory_in_signals_out  <= fifo_response_memory_in_signals_out_int;
        request_control_out.payload          <= request_control_out_int.payload ;
        request_lane_out[0].payload          <= request_lane_out_int.payload;
        request_memory_out.payload           <= request_memory_out_int.payload ;
    end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engines Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_lane_in_setup_signal_int = fifo_response_lane_in_signals_out_int.wr_rst_busy | fifo_response_lane_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_lane_in_signals_in_int.wr_en = response_lane_in_reg.valid;
    assign fifo_response_lane_in_din                  = response_lane_in_reg.payload;

    // Pop
    assign fifo_response_lane_in_signals_in_int.rd_en = ~fifo_response_lane_in_signals_out_int.empty & fifo_response_lane_in_signals_in_reg.rd_en & ~engines_fifo_response_lane_in_signals_out[0].prog_full;
    assign response_lane_in_int.valid                 = fifo_response_lane_in_signals_out_int.valid;
    assign response_lane_in_int.payload               = fifo_response_lane_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketResponseEnginesInput (
        .clk        (ap_clk                                           ),
        .srst       (areset_fifo                                      ),
        .din        (fifo_response_lane_in_din                        ),
        .wr_en      (fifo_response_lane_in_signals_in_int.wr_en       ),
        .rd_en      (fifo_response_lane_in_signals_in_int.rd_en       ),
        .dout       (fifo_response_lane_in_dout                       ),
        .full       (fifo_response_lane_in_signals_out_int.full       ),
        .empty      (fifo_response_lane_in_signals_out_int.empty      ),
        .valid      (fifo_response_lane_in_signals_out_int.valid      ),
        .prog_full  (fifo_response_lane_in_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_response_lane_in_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_response_lane_in_signals_out_int.rd_rst_busy)
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
    assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~engine_arbiter_1_to_N_memory_fifo_response_signals_out.prog_full;
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
    assign fifo_response_control_in_signals_in_int.rd_en = ~fifo_response_control_in_signals_out_int.empty & fifo_response_control_in_signals_in_reg.rd_en & ~engine_arbiter_1_to_N_control_fifo_response_signals_out.prog_full;
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
// FIFO OUTPUT Engines requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_lane_out_setup_signal_int = fifo_request_lane_out_signals_out_int.wr_rst_busy | fifo_request_lane_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_lane_out_signals_in_int.wr_en = engines_request_lane_out_int.valid;
    assign fifo_request_lane_out_din                  = engines_request_lane_out_int.payload;

    // Pop
    assign fifo_request_lane_out_signals_in_int.rd_en = ~fifo_request_lane_out_signals_out_int.empty & fifo_request_lane_out_signals_in_reg.rd_en;
    assign request_lane_out_int.valid                 = fifo_request_lane_out_signals_out_int.valid;
    assign request_lane_out_int.payload               = fifo_request_lane_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketRequestEnginesOutput (
        .clk        (ap_clk                                           ),
        .srst       (areset_fifo                                      ),
        .din        (fifo_request_lane_out_din                        ),
        .wr_en      (fifo_request_lane_out_signals_in_int.wr_en       ),
        .rd_en      (fifo_request_lane_out_signals_in_int.rd_en       ),
        .dout       (fifo_request_lane_out_dout                       ),
        .full       (fifo_request_lane_out_signals_out_int.full       ),
        .empty      (fifo_request_lane_out_signals_out_int.empty      ),
        .valid      (fifo_request_lane_out_signals_out_int.valid      ),
        .prog_full  (fifo_request_lane_out_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_request_lane_out_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_request_lane_out_signals_out_int.rd_rst_busy)
    );

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_memory_out_signals_in_int.wr_en = engine_arbiter_N_to_1_memory_request_out.valid;
    assign fifo_request_memory_out_din                  = engine_arbiter_N_to_1_memory_request_out.payload;

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
    assign fifo_request_control_out_signals_in_int.wr_en = engine_arbiter_N_to_1_control_request_out.valid;
    assign fifo_request_control_out_din                  = engine_arbiter_N_to_1_control_request_out.payload;

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
// Generate Engines
// --------------------------------------------------------------------------------------
// Generate Engines - Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        for (int i=0; i< NUM_ENGINES; i++) begin
            areset_engine[i] <= areset;
        end
    end

    always_ff @(posedge ap_clk) begin
        if (areset_lane_template) begin
            for (int i=0; i< NUM_ENGINES; i++) begin
                engines_descriptor_in[i].valid <= 0;
            end
        end
        else begin
            for (int i=0; i< NUM_ENGINES; i++) begin
                engines_descriptor_in[i].valid <= descriptor_in_reg.valid;
            end
        end
    end

    always_ff @(posedge ap_clk) begin
        for (int i=0; i< NUM_ENGINES; i++) begin
            engines_descriptor_in[i].payload <= descriptor_in_reg.payload;
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
    assign engines_fifo_response_lane_in_signals_in[0].rd_en = 1'b1;

    always_comb begin
        for (int i=1; i<NUM_ENGINES; i++) begin : generate_lane_template_intra_signals
            engines_response_lane_in[i] = engines_request_lane_out[i-1];
            engines_fifo_request_lane_out_signals_in[i-1].rd_en = ~engines_fifo_response_lane_in_signals_out[i].prog_full;
            engines_fifo_response_lane_in_signals_in[i].rd_en = 1'b1;
        end
    end

    assign engines_request_lane_out_int = engines_request_lane_out[NUM_ENGINES-1];
    assign engines_fifo_request_lane_out_signals_in[NUM_ENGINES-1].rd_en = ~fifo_request_lane_out_signals_out_int.prog_full;

// --------------------------------------------------------------------------------------
// Generate Engines - Memory Arbitration
// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    always_comb begin
        for (int i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_N_to_1_memory_request_in
            engine_arbiter_N_to_1_memory_request_in[i]                = engines_request_memory_out[i];
            engine_arbiter_N_to_1_memory_engine_arbiter_request_in[i] = ~engines_fifo_request_memory_out_signals_out[i].empty & ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full;
            engines_fifo_request_memory_out_signals_in[i].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[i];
        end
    end

    assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = ~fifo_request_memory_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_ENGINES)) inst_engine_arbiter_N_to_1_memory_request_out (
        .ap_clk                  (ap_clk                                                ),
        .areset                  (areset_engine_arbiter_N_to_1_memory                   ),
        .request_in              (engine_arbiter_N_to_1_memory_request_in               ),
        .fifo_request_signals_in (engine_arbiter_N_to_1_memory_fifo_request_signals_in  ),
        .fifo_request_signals_out(engine_arbiter_N_to_1_memory_fifo_request_signals_out ),
        .arbiter_request_in      (engine_arbiter_N_to_1_memory_engine_arbiter_request_in),
        .arbiter_grant_out       (engine_arbiter_N_to_1_memory_engine_arbiter_grant_out ),
        .request_out             (engine_arbiter_N_to_1_memory_request_out              ),
        .fifo_setup_signal       (engine_arbiter_N_to_1_memory_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Engines - CONTROL Arbitration
// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: CONTROL Request Generator
// --------------------------------------------------------------------------------------
    always_comb begin
        for (int i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_N_to_1_control_request_in
            engine_arbiter_N_to_1_control_request_in[i]                = engines_request_control_out[i];
            engine_arbiter_N_to_1_control_engine_arbiter_request_in[i] = ~engines_fifo_request_control_out_signals_out[i].empty & ~engine_arbiter_N_to_1_control_fifo_request_signals_out.prog_full;
            engines_fifo_request_control_out_signals_in[i].rd_en  = ~engine_arbiter_N_to_1_control_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_control_engine_arbiter_grant_out[i];
        end
    end

    assign engine_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = ~fifo_request_control_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_ENGINES)) inst_engine_arbiter_N_to_1_control_request_out (
        .ap_clk                  (ap_clk                                                 ),
        .areset                  (areset_engine_arbiter_N_to_1_control                   ),
        .request_in              (engine_arbiter_N_to_1_control_request_in               ),
        .fifo_request_signals_in (engine_arbiter_N_to_1_control_fifo_request_signals_in  ),
        .fifo_request_signals_out(engine_arbiter_N_to_1_control_fifo_request_signals_out ),
        .arbiter_request_in      (engine_arbiter_N_to_1_control_engine_arbiter_request_in),
        .arbiter_grant_out       (engine_arbiter_N_to_1_control_engine_arbiter_grant_out ),
        .request_out             (engine_arbiter_N_to_1_control_request_out              ),
        .fifo_setup_signal       (engine_arbiter_N_to_1_control_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    assign engine_arbiter_1_to_N_memory_response_in = response_memory_in_int;
    always_comb begin
        for (int i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_1_to_N_memory_response
            engine_arbiter_1_to_N_memory_fifo_response_signals_in[i].rd_en = ~engines_fifo_response_memory_in_signals_out[i].prog_full;
            engines_response_memory_in[i] = engine_arbiter_1_to_N_memory_response_out[i];
            engines_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
        end
    end

// --------------------------------------------------------------------------------------
    arbiter_1_to_N_response #(
        .NUM_MEMORY_REQUESTOR(NUM_ENGINES),
        .ID_LEVEL            (3          )
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
    assign engine_arbiter_1_to_N_control_response_in = response_control_in_int;
    always_comb begin
        for (int i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_1_to_N_control_response
            engine_arbiter_1_to_N_control_fifo_response_signals_in[i].rd_en = ~engines_fifo_response_control_in_signals_out[i].prog_full;
            engines_response_control_in[i] = engine_arbiter_1_to_N_control_response_out[i];
            engines_fifo_response_control_in_signals_in[i].rd_en = 1'b1;
        end
    end

// --------------------------------------------------------------------------------------
    arbiter_1_to_N_response #(
        .NUM_MEMORY_REQUESTOR(NUM_ENGINES),
        .ID_LEVEL            (3          )
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
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
    generate
        for (j=0; j<NUM_ENGINES; j++) begin : generate_engine_template
            engine_template #(
                `include"set_engine_parameters.vh"
                ) inst_engine_template (
                .ap_clk                              (ap_clk                                                                                   ),
                .areset                              (areset_engine[j]                                                                         ),
                .descriptor_in                       (engines_descriptor_in[j]                                                                 ),
                .response_engine_in                  (engines_response_merge_lane_in[j][ENGINES_CONFIG_MERGE_WIDTH_ARRAY[j]:0]                 ),
                .fifo_response_engine_in_signals_in  (engines_fifo_response_merge_lane_in_signals_in[j][ENGINES_CONFIG_MERGE_WIDTH_ARRAY[j]:0] ),
                .fifo_response_engine_in_signals_out (engines_fifo_response_merge_lane_in_signals_out[j][ENGINES_CONFIG_MERGE_WIDTH_ARRAY[j]:0]),
                .response_memory_in                  (engines_response_memory_in[j]                                                            ),
                .fifo_response_memory_in_signals_in  (engines_fifo_response_memory_in_signals_in[j]                                            ),
                .fifo_response_memory_in_signals_out (engines_fifo_response_memory_in_signals_out[j]                                           ),
                .response_control_in                 (engines_response_control_in[j]                                                           ),
                .fifo_response_control_in_signals_in (engines_fifo_response_control_in_signals_in[j]                                           ),
                .fifo_response_control_in_signals_out(engines_fifo_response_control_in_signals_out[j]                                          ),
                .request_engine_out                  (engines_request_cast_lane_out[j][ENGINES_CONFIG_CAST_WIDTH_ARRAY[j]:0]                   ),
                .fifo_request_engine_out_signals_in  (engines_fifo_request_cast_lane_out_signals_in[j][ENGINES_CONFIG_CAST_WIDTH_ARRAY[j]:0]   ),
                .fifo_request_engine_out_signals_out (engines_fifo_request_cast_lane_out_signals_out[j][ENGINES_CONFIG_CAST_WIDTH_ARRAY[j]:0]  ),
                .request_memory_out                  (engines_request_memory_out[j]                                                            ),
                .fifo_request_memory_out_signals_in  (engines_fifo_request_memory_out_signals_in[j]                                            ),
                .fifo_request_memory_out_signals_out (engines_fifo_request_memory_out_signals_out[j]                                           ),
                .request_control_out                 (engines_request_control_out[j]                                                           ),
                .fifo_request_control_out_signals_in (engines_fifo_request_control_out_signals_in[j]                                           ),
                .fifo_request_control_out_signals_out(engines_fifo_request_control_out_signals_out[j]                                          ),
                .fifo_setup_signal                   (engines_fifo_setup_signal[j]                                                             ),
                .done_out                            (engines_done_out[j]                                                                      )
            );
        end
    endgenerate

    // --------------------------------------------------------------------------------------
    // Generate Lanes MERGE/CAST wires
    // --------------------------------------------------------------------------------------
    always_comb begin : generate_engine_topology
        automatic int cast_count = 0;
        automatic int merge_count = 0;

        for (int engine_idx=0; engine_idx < NUM_ENGINES; engine_idx++) begin

            automatic int engine_idx_l                       = engine_idx;
            automatic int ENGINES_CONFIG_MERGE_WIDTH_ARRAY_L = ENGINES_CONFIG_MERGE_WIDTH_ARRAY[engine_idx_l];
            automatic int ENGINES_CONFIG_CAST_WIDTH_ARRAY_L  = ENGINES_CONFIG_CAST_WIDTH_ARRAY[engine_idx_l];

            engines_response_merge_lane_in[engine_idx_l][0]         = engines_response_lane_in[engine_idx_l];
            engines_fifo_response_merge_lane_in_signals_in[engine_idx_l][0].rd_en = 1'b1;
            engines_fifo_response_lane_in_signals_out[engine_idx_l] = engines_fifo_response_merge_lane_in_signals_out[engine_idx_l][0];

            engines_request_lane_out[engine_idx_l]                  = engines_request_cast_lane_out[engine_idx_l][0];
            engines_fifo_request_cast_lane_out_signals_in[engine_idx_l][0].rd_en = engines_fifo_request_lane_out_signals_in[engine_idx_l].rd_en ;
            engines_fifo_request_lane_out_signals_out[engine_idx_l] = engines_fifo_request_cast_lane_out_signals_out [engine_idx_l][0];

            for (int engine_merge=0; engine_merge < ENGINES_CONFIG_MERGE_WIDTH_ARRAY_L; engine_merge++) begin
                automatic int engine_merge_l                                                                 = engine_merge;
                merge_count++;
                engines_response_merge_lane_in[engine_idx_l][engine_merge_l+1] = response_lane_in[merge_count];
                engines_fifo_response_merge_lane_in_signals_in[engine_idx_l][engine_merge_l+1].rd_en = 1'b1;
                fifo_response_lane_in_signals_out[merge_count]                 = engines_fifo_response_merge_lane_in_signals_out[engine_idx_l][engine_merge_l+1];
            end
            for (int engine_cast=0; engine_cast < ENGINES_CONFIG_CAST_WIDTH_ARRAY_L; engine_cast++) begin
                automatic int engine_cast_l                                                                = engine_cast;
                cast_count++;
                request_lane_out[cast_count]                  = engines_request_cast_lane_out[engine_idx_l][engine_cast_l+1];
                engines_fifo_request_cast_lane_out_signals_in[engine_idx_l][engine_cast_l+1].rd_en = fifo_request_lane_out_signals_in[cast_count].rd_en;
                fifo_request_lane_out_signals_out[cast_count] = engines_fifo_request_cast_lane_out_signals_out[engine_idx_l][engine_cast_l+1];
            end
        end
    end

endmodule : lane_template
