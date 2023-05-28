// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : bundle_engines.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
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

module bundle_engines #(
    parameter ENGINE_ID_VERTEX = 0 ,
    parameter ENGINE_ID_BUNDLE = 0 ,
    parameter COUNTER_WIDTH    = 32
) (
    // System Signals
    input  logic                  ap_clk                      ,
    input  logic                  areset                      ,
    input  KernelDescriptor       descriptor_in               ,
    input  MemoryPacket           request_in                  ,
    input  FIFOStateSignalsInput  fifo_request_in_signals_in  ,
    output FIFOStateSignalsOutput fifo_request_in_signals_out ,
    input  MemoryPacket           response_in                 ,
    input  FIFOStateSignalsInput  fifo_response_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_in_signals_out,
    output MemoryPacket           request_out                 ,
    input  FIFOStateSignalsInput  fifo_request_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_out_signals_out,
    output logic                  fifo_setup_signal           ,
    output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_bundle_engines;

    KernelDescriptor descriptor_in_reg;
    MemoryPacket     request_in_reg   ;
    MemoryPacket     response_in_reg  ;
    MemoryPacket     response_in_int  ;
    MemoryPacket     request_in_int   ;
    MemoryPacket     request_out_int  ;

// --------------------------------------------------------------------------------------
// FIFO INPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_in_din             ;
    MemoryPacketPayload    fifo_request_in_dout            ;
    FIFOStateSignalsInput  fifo_request_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_in_signals_out_int ;
    logic                  fifo_request_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_out_din             ;
    MemoryPacketPayload    fifo_request_out_dout            ;
    FIFOStateSignalsInput  fifo_request_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_out_signals_out_int ;
    logic                  fifo_request_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_in_din             ;
    MemoryPacketPayload    fifo_response_in_dout            ;
    FIFOStateSignalsInput  fifo_response_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_in_signals_out_int ;
    logic                  fifo_response_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_bundle_engines <= areset;
        areset_fifo           <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_bundle_engines) begin
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
        if (areset_bundle_engines) begin
            fifo_response_in_signals_in_reg <= 0;
            fifo_request_out_signals_in_reg <= 0;
            request_in_reg.valid            <= 0;
            response_in_reg.valid           <= 0;
        end
        else begin
            fifo_response_in_signals_in_reg <= fifo_response_in_signals_in;
            fifo_request_out_signals_in_reg <= fifo_request_out_signals_in;
            request_in_reg.valid            <= request_in.valid;
            response_in_reg.valid           <= response_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_in_reg.payload  <= request_in.payload;
        response_in_reg.payload <= response_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_bundle_engines) begin
            fifo_setup_signal            <= 1;
            fifo_response_in_signals_out <= 0;
            fifo_request_out_signals_out <= 0;
            request_out.valid            <= 0;
        end
        else begin
            fifo_setup_signal            <= fifo_request_in_setup_signal_int | fifo_request_out_setup_signal_int | fifo_response_in_setup_signal_int;
            fifo_response_in_signals_out <= fifo_response_in_signals_out_int;
            fifo_request_out_signals_out <= fifo_request_out_signals_out_int;
            request_out.valid            <= request_out_int.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_out.payload <= request_out_int.payload;
    end

// --------------------------------------------------------------------------------------
// FIFO OUTPUT requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_out_setup_signal_int = fifo_request_out_signals_out_int.wr_rst_busy | fifo_request_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_out_signals_in_int.wr_en = 1'b0;
    assign fifo_request_out_din                  = 0;

    // Pop
    assign fifo_request_out_signals_in_int.rd_en = ~fifo_request_out_signals_out_int.empty & fifo_request_out_signals_in_reg.rd_en;
    assign request_out_int.valid                 = fifo_request_out_signals_out_int.valid;
    assign request_out_int.payload               = fifo_request_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequestOutput (
        .clk         (ap_clk                                       ),
        .srst        (areset_fifo                                  ),
        .din         (fifo_request_out_din                         ),
        .wr_en       (fifo_request_out_signals_in_int.wr_en        ),
        .rd_en       (fifo_request_out_signals_in_int.rd_en        ),
        .dout        (fifo_request_out_dout                        ),
        .full        (fifo_request_out_signals_out_int.full        ),
        .almost_full (fifo_request_out_signals_out_int.almost_full ),
        .empty       (fifo_request_out_signals_out_int.empty       ),
        .almost_empty(fifo_request_out_signals_out_int.almost_empty),
        .valid       (fifo_request_out_signals_out_int.valid       ),
        .prog_full   (fifo_request_out_signals_out_int.prog_full   ),
        .prog_empty  (fifo_request_out_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_request_out_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_request_out_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_in_setup_signal_int = fifo_response_in_signals_out_int.wr_rst_busy | fifo_response_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_in_signals_in_int.wr_en = response_in_reg.valid;
    assign fifo_response_in_din                  = response_in_reg.payload;

    // Pop
    assign fifo_response_in_signals_in_int.rd_en = ~fifo_response_in_signals_out_int.empty & fifo_response_in_signals_in_reg.rd_en;;
    assign response_in_int.valid                 = fifo_response_in_signals_out_int.valid;
    assign response_in_int.payload               = fifo_response_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponse (
        .clk         (ap_clk                                       ),
        .srst        (areset_fifo                                  ),
        .din         (fifo_response_in_din                         ),
        .wr_en       (fifo_response_in_signals_in_int.wr_en        ),
        .rd_en       (fifo_response_in_signals_in_int.rd_en        ),
        .dout        (fifo_response_in_dout                        ),
        .full        (fifo_response_in_signals_out_int.full        ),
        .almost_full (fifo_response_in_signals_out_int.almost_full ),
        .empty       (fifo_response_in_signals_out_int.empty       ),
        .almost_empty(fifo_response_in_signals_out_int.almost_empty),
        .valid       (fifo_response_in_signals_out_int.valid       ),
        .prog_full   (fifo_response_in_signals_out_int.prog_full   ),
        .prog_empty  (fifo_response_in_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_response_in_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_response_in_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO INPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_in_setup_signal_int = fifo_request_in_signals_out_int.wr_rst_busy | fifo_request_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_in_signals_in_int.wr_en = request_in_reg.valid;
    assign fifo_request_in_din                  = request_in_reg.payload;

    // Pop
    assign fifo_request_in_signals_in_int.rd_en = ~fifo_request_in_signals_out_int.empty & fifo_request_in_signals_in_reg.rd_en;;
    assign request_in_int.valid                 = fifo_request_in_signals_out_int.valid;
    assign request_in_int.payload               = fifo_request_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequestInput (
        .clk         (ap_clk                                      ),
        .srst        (areset_fifo                                 ),
        .din         (fifo_request_in_din                         ),
        .wr_en       (fifo_request_in_signals_in_int.wr_en        ),
        .rd_en       (fifo_request_in_signals_in_int.rd_en        ),
        .dout        (fifo_request_in_dout                        ),
        .full        (fifo_request_in_signals_out_int.full        ),
        .almost_full (fifo_request_in_signals_out_int.almost_full ),
        .empty       (fifo_request_in_signals_out_int.empty       ),
        .almost_empty(fifo_request_in_signals_out_int.almost_empty),
        .valid       (fifo_request_in_signals_out_int.valid       ),
        .prog_full   (fifo_request_in_signals_out_int.prog_full   ),
        .prog_empty  (fifo_request_in_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_request_in_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_request_in_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// Engines Arbitration INPUT
// --------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------
// Engines Arbitration OUTPUT
// --------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------
// Generate Engines
// --------------------------------------------------------------------------------------


endmodule : bundle_engines