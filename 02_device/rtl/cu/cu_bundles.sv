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

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_SETUP::*;
import PKG_CACHE::*;

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

    genvar j;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_cu_bundles;
    logic areset_fifo      ;

    KernelDescriptor descriptor_in_reg;

    MemoryPacket request_control_out_int;
    MemoryPacket request_memory_out_int ;
    MemoryPacket response_control_in_int;
    MemoryPacket response_control_in_reg;
    MemoryPacket response_memory_in_int ;
    MemoryPacket response_memory_in_reg ;

    logic fifo_empty_int;
    logic fifo_empty_reg;
// --------------------------------------------------------------------------------------
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_int  ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_int ;
    logic                  fifo_response_memory_in_setup_signal_int;
    MemoryPacketPayload    fifo_response_memory_in_din             ;
    MemoryPacketPayload    fifo_response_memory_in_dout            ;

    // --------------------------------------------------------------------------------------
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_response_control_in_signals_in_int  ;
    FIFOStateSignalsInput  fifo_response_control_in_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_response_control_in_signals_out_int ;
    logic                  fifo_response_control_in_setup_signal_int;
    MemoryPacketPayload    fifo_response_control_in_din             ;
    MemoryPacketPayload    fifo_response_control_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_int  ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_request_memory_out_signals_out_int ;
    logic                  fifo_request_memory_out_setup_signal_int;
    MemoryPacketPayload    fifo_request_memory_out_din             ;
    MemoryPacketPayload    fifo_request_memory_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL Request MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_request_control_out_signals_in_int  ;
    FIFOStateSignalsInput  fifo_request_control_out_signals_in_reg  ;
    FIFOStateSignalsOutput fifo_request_control_out_signals_out_int ;
    logic                  fifo_request_control_out_setup_signal_int;
    MemoryPacketPayload    fifo_request_control_out_din             ;
    MemoryPacketPayload    fifo_request_control_out_dout            ;

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
    MemoryPacket           bundle_request_control_out                 [NUM_BUNDLES-1:0];
    MemoryPacket           bundle_request_lanes_out                   [NUM_BUNDLES-1:0];
    MemoryPacket           bundle_request_memory_out                  [NUM_BUNDLES-1:0];
    MemoryPacket           bundle_response_control_in                 [NUM_BUNDLES-1:0];
    MemoryPacket           bundle_response_lanes_in                   [NUM_BUNDLES-1:0];
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
    FIFOStateSignalsInput   bundle_arbiter_N_to_1_fifo_request_signals_in                  ;
    FIFOStateSignalsOutput  bundle_arbiter_N_to_1_fifo_request_signals_out                 ;
    logic                   areset_arbiter_N_to_1                                          ;
    logic                   bundle_arbiter_N_to_1_fifo_setup_signal                        ;
    logic [NUM_BUNDLES-1:0] bundle_arbiter_N_to_1_arbiter_grant_out                        ;
    logic [NUM_BUNDLES-1:0] bundle_arbiter_N_to_1_arbiter_request_in                       ;
    MemoryPacket            bundle_arbiter_N_to_1_request_in              [NUM_BUNDLES-1:0];
    MemoryPacket            bundle_arbiter_N_to_1_request_out                              ;

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
    MemoryPacket            bundle_arbiter_control_N_to_1_request_in              [NUM_BUNDLES-1:0];
    MemoryPacket            bundle_arbiter_control_N_to_1_request_out                              ;

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  bundle_arbiter_1_to_N_fifo_response_signals_in [NUM_BUNDLES-1:0];
    FIFOStateSignalsOutput bundle_arbiter_1_to_N_fifo_response_signals_out                 ;
    logic                  areset_arbiter_1_to_N                                           ;
    logic                  bundle_arbiter_1_to_N_fifo_setup_signal                         ;
    MemoryPacket           bundle_arbiter_1_to_N_response_in                               ;
    MemoryPacket           bundle_arbiter_1_to_N_response_out             [NUM_BUNDLES-1:0];

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: CONTROL Response Generator
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  bundle_arbiter_control_1_to_N_fifo_response_signals_in [NUM_BUNDLES-1:0];
    FIFOStateSignalsOutput bundle_arbiter_control_1_to_N_fifo_response_signals_out                 ;
    logic                  areset_arbiter_control_1_to_N                                           ;
    logic                  bundle_arbiter_control_1_to_N_fifo_setup_signal                         ;
    MemoryPacket           bundle_arbiter_control_1_to_N_response_in                               ;
    MemoryPacket           bundle_arbiter_control_1_to_N_response_out             [NUM_BUNDLES-1:0];

// --------------------------------------------------------------------------------------
// CONTROL Variables
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_request_control_out_signals_in ;
    FIFOStateSignalsInput  fifo_response_control_in_signals_in ;
    FIFOStateSignalsOutput fifo_request_control_out_signals_out;
    FIFOStateSignalsOutput fifo_response_control_in_signals_out;
    MemoryPacket           request_control_out                 ;
    MemoryPacket           response_control_in                 ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_arbiter_1_to_N         <= areset;
        areset_arbiter_control_1_to_N <= areset;
        areset_arbiter_control_N_to_1 <= areset;
        areset_arbiter_N_to_1         <= areset;
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
            fifo_setup_signal         <= fifo_request_memory_out_setup_signal_int | fifo_request_control_out_setup_signal_int | fifo_response_control_in_setup_signal_int |fifo_response_memory_in_setup_signal_int | (|bundle_fifo_setup_signal_reg) | bundle_arbiter_N_to_1_fifo_setup_signal | bundle_arbiter_control_N_to_1_fifo_setup_signal| bundle_arbiter_control_1_to_N_fifo_setup_signal | bundle_arbiter_1_to_N_fifo_setup_signal;
            request_control_out.valid <= request_control_out_int.valid ;
            request_memory_out.valid  <= request_memory_out_int.valid ;
        end
    end

    assign fifo_empty_int = fifo_response_memory_in_signals_out_int.empty & fifo_response_control_in_signals_out_int.empty & fifo_request_memory_out_signals_out_int.empty & fifo_request_control_out_signals_out_int.empty & bundle_arbiter_N_to_1_fifo_request_signals_out.empty  & bundle_arbiter_control_N_to_1_fifo_request_signals_out.empty  &  bundle_arbiter_control_1_to_N_fifo_response_signals_out.empty & bundle_arbiter_1_to_N_fifo_response_signals_out.empty;

    always_ff @(posedge ap_clk) begin
        fifo_request_control_out_signals_out <= fifo_request_control_out_signals_out_int;
        fifo_request_memory_out_signals_out  <= fifo_request_memory_out_signals_out_int;
        fifo_response_control_in_signals_out <= fifo_response_control_in_signals_out_int;
        fifo_response_memory_in_signals_out  <= fifo_response_memory_in_signals_out_int;
        request_control_out.payload          <= request_control_out_int.payload;
        request_memory_out.payload           <= request_memory_out_int.payload;
    end

// --------------------------------------------------------------------------------------
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_memory_in_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy | fifo_response_memory_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid;
    assign fifo_response_memory_in_din                  = response_memory_in_reg.payload;

    // Pop
    assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~bundle_arbiter_1_to_N_fifo_response_signals_out.prog_full;
    assign response_memory_in_int.valid                 = fifo_response_memory_in_signals_out_int.valid;
    assign response_memory_in_int.payload               = fifo_response_memory_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketResponseInput (
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
// FIFO CONTROL INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_control_in_setup_signal_int = fifo_response_control_in_signals_out_int.wr_rst_busy | fifo_response_control_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_control_in_signals_in_int.wr_en = response_control_in_reg.valid;
    assign fifo_response_control_in_din                  = response_control_in_reg.payload;

    // Pop
    assign fifo_response_control_in_signals_in_int.rd_en = ~fifo_response_control_in_signals_out_int.empty & fifo_response_control_in_signals_in_reg.rd_en & ~bundle_arbiter_1_to_N_fifo_response_signals_out.prog_full;
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
// FIFO OUTPUT requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_memory_out_signals_in_int.wr_en = bundle_arbiter_N_to_1_request_out.valid;
    assign fifo_request_memory_out_din                  = bundle_arbiter_N_to_1_request_out.payload;

    // Pop
    assign fifo_request_memory_out_signals_in_int.rd_en = ~fifo_request_memory_out_signals_out_int.empty & fifo_request_memory_out_signals_in_reg.rd_en;
    assign request_memory_out_int.valid                 = fifo_request_memory_out_signals_out_int.valid;
    assign request_memory_out_int.payload               = fifo_request_memory_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketRequestOutput (
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
// FIFO OUTPUT requests CONTROL MemoryPacket
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

    always_comb begin
        for (int i=1; i<NUM_BUNDLES; i++) begin : generate_bundle_intra_signals
            bundle_response_lanes_in[i] = bundle_request_lanes_out[i-1];
            bundle_fifo_request_lanes_out_signals_in[i-1].rd_en = ~bundle_fifo_response_lanes_in_signals_out[i].prog_full;
            bundle_fifo_response_lanes_in_signals_in[i].rd_en = 1'b1;
        end
    end

// --------------------------------------------------------------------------------------
// Generate Bundles - Memory Arbitration OUTPUT
// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    always_comb begin
        for (int i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_N_to_1_request_in
            bundle_arbiter_N_to_1_request_in[i]         = bundle_request_memory_out[i];
            bundle_arbiter_N_to_1_arbiter_request_in[i] = ~bundle_fifo_request_memory_out_signals_out[i].empty & ~bundle_arbiter_N_to_1_fifo_request_signals_out.prog_full;
            bundle_fifo_request_memory_out_signals_in[i].rd_en  = ~bundle_arbiter_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_N_to_1_arbiter_grant_out[i];
        end
    end

    assign bundle_arbiter_N_to_1_fifo_request_signals_in.rd_en = ~fifo_request_memory_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_BUNDLES)) inst_bundle_arbiter_N_to_1_request_memory_out (
        .ap_clk                  (ap_clk                                        ),
        .areset                  (areset_arbiter_N_to_1                         ),
        .request_in              (bundle_arbiter_N_to_1_request_in              ),
        .fifo_request_signals_in (bundle_arbiter_N_to_1_fifo_request_signals_in ),
        .fifo_request_signals_out(bundle_arbiter_N_to_1_fifo_request_signals_out),
        .arbiter_request_in      (bundle_arbiter_N_to_1_arbiter_request_in      ),
        .arbiter_grant_out       (bundle_arbiter_N_to_1_arbiter_grant_out       ),
        .request_out             (bundle_arbiter_N_to_1_request_out             ),
        .fifo_setup_signal       (bundle_arbiter_N_to_1_fifo_setup_signal       )
    );

// --------------------------------------------------------------------------------------
// Generate Bundles - Memory Arbitration OUTPUT
// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request CONTROL Generator
// --------------------------------------------------------------------------------------
    always_comb begin
        for (int i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_control_N_to_1_request_in
            bundle_arbiter_control_N_to_1_request_in[i]         = bundle_request_control_out[i];
            bundle_arbiter_control_N_to_1_arbiter_request_in[i] = ~bundle_fifo_request_control_out_signals_out[i].empty & ~bundle_arbiter_control_N_to_1_fifo_request_signals_out.prog_full;
            bundle_fifo_request_control_out_signals_in[i].rd_en  = ~bundle_arbiter_control_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_control_N_to_1_arbiter_grant_out[i];
        end
    end

    assign bundle_arbiter_control_N_to_1_fifo_request_signals_in.rd_en = ~fifo_request_control_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_BUNDLES)) inst_bundle_arbiter_control_N_to_1_request_control_out (
        .ap_clk                  (ap_clk                                                ),
        .areset                  (areset_arbiter_control_N_to_1                         ),
        .request_in              (bundle_arbiter_control_N_to_1_request_in              ),
        .fifo_request_signals_in (bundle_arbiter_control_N_to_1_fifo_request_signals_in ),
        .fifo_request_signals_out(bundle_arbiter_control_N_to_1_fifo_request_signals_out),
        .arbiter_request_in      (bundle_arbiter_control_N_to_1_arbiter_request_in      ),
        .arbiter_grant_out       (bundle_arbiter_control_N_to_1_arbiter_grant_out       ),
        .request_out             (bundle_arbiter_control_N_to_1_request_out             ),
        .fifo_setup_signal       (bundle_arbiter_control_N_to_1_fifo_setup_signal       )
    );

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    assign bundle_arbiter_1_to_N_response_in = response_memory_in_int;
    always_comb begin
        for (int i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_1_to_N_response
            bundle_arbiter_1_to_N_fifo_response_signals_in[i].rd_en = ~bundle_fifo_response_memory_in_signals_out[i].prog_full;
            bundle_response_memory_in[i] = bundle_arbiter_1_to_N_response_out[i];
            bundle_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
        end
    end

// --------------------------------------------------------------------------------------
    arbiter_1_to_N_response #(
        .NUM_MEMORY_REQUESTOR(NUM_BUNDLES),
        .ID_LEVEL            (1          )
    ) inst_bundle_arbiter_1_to_N_response_memory_in (
        .ap_clk                   (ap_clk                                         ),
        .areset                   (areset_arbiter_1_to_N                          ),
        .response_in              (bundle_arbiter_1_to_N_response_in              ),
        .fifo_response_signals_in (bundle_arbiter_1_to_N_fifo_response_signals_in ),
        .fifo_response_signals_out(bundle_arbiter_1_to_N_fifo_response_signals_out),
        .response_out             (bundle_arbiter_1_to_N_response_out             ),
        .fifo_setup_signal        (bundle_arbiter_1_to_N_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: CONTROL Response Generator
// --------------------------------------------------------------------------------------
    assign bundle_arbiter_control_1_to_N_response_in = response_control_in_int;
    always_comb begin
        for (int i=0; i<NUM_BUNDLES; i++) begin : generate_bundle_arbiter_control_1_to_N_response
            bundle_arbiter_control_1_to_N_fifo_response_signals_in[i].rd_en = ~bundle_fifo_response_control_in_signals_out[i].prog_full;
            bundle_response_control_in[i] = bundle_arbiter_control_1_to_N_response_out[i];
            bundle_fifo_response_control_in_signals_in[i].rd_en = 1'b1;
        end
    end

// --------------------------------------------------------------------------------------
    arbiter_1_to_N_response #(
        .NUM_MEMORY_REQUESTOR(NUM_BUNDLES),
        .ID_LEVEL            (1          )
    ) inst_bundle_arbiter_control_1_to_N_response_control_in (
        .ap_clk                   (ap_clk                                                 ),
        .areset                   (areset_arbiter_control_1_to_N                          ),
        .response_in              (bundle_arbiter_control_1_to_N_response_in              ),
        .fifo_response_signals_in (bundle_arbiter_control_1_to_N_fifo_response_signals_in ),
        .fifo_response_signals_out(bundle_arbiter_control_1_to_N_fifo_response_signals_out),
        .response_out             (bundle_arbiter_control_1_to_N_response_out             ),
        .fifo_setup_signal        (bundle_arbiter_control_1_to_N_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
    generate
        for (j=0; j<NUM_BUNDLES; j++) begin : generate_bundle_lanes
            bundle_lanes #(
                `include"set_bundle_parameters.vh"
                ) inst_bundle_lanes (
                .ap_clk                              (ap_clk                                        ),
                .areset                              (areset_bundle[j]                              ),
                .descriptor_in                       (bundle_descriptor_in[j]                       ),
                .response_lanes_in                   (bundle_response_lanes_in[j]                   ),
                .fifo_response_lanes_in_signals_in   (bundle_fifo_response_lanes_in_signals_in[j]   ),
                .fifo_response_lanes_in_signals_out  (bundle_fifo_response_lanes_in_signals_out[j]  ),
                .response_memory_in                  (bundle_response_memory_in[j]                  ),
                .fifo_response_memory_in_signals_in  (bundle_fifo_response_memory_in_signals_in[j]  ),
                .fifo_response_memory_in_signals_out (bundle_fifo_response_memory_in_signals_out[j] ),
                .response_control_in                 (bundle_response_control_in[j]                 ),
                .fifo_response_control_in_signals_in (bundle_fifo_response_control_in_signals_in[j] ),
                .fifo_response_control_in_signals_out(bundle_fifo_response_control_in_signals_out[j]),
                .request_lanes_out                   (bundle_request_lanes_out[j]                   ),
                .fifo_request_lanes_out_signals_in   (bundle_fifo_request_lanes_out_signals_in[j]   ),
                .fifo_request_lanes_out_signals_out  (bundle_fifo_request_lanes_out_signals_out[j]  ),
                .request_memory_out                  (bundle_request_memory_out[j]                  ),
                .fifo_request_memory_out_signals_in  (bundle_fifo_request_memory_out_signals_in[j]  ),
                .fifo_request_memory_out_signals_out (bundle_fifo_request_memory_out_signals_out[j] ),
                .request_control_out                 (bundle_request_control_out[j]                 ),
                .fifo_request_control_out_signals_in (bundle_fifo_request_control_out_signals_in[j] ),
                .fifo_request_control_out_signals_out(bundle_fifo_request_control_out_signals_out[j]),
                .fifo_setup_signal                   (bundle_fifo_setup_signal[j]                   ),
                .done_out                            (bundle_done_out[j]                            )
            );
        end
    endgenerate

endmodule : cu_bundles