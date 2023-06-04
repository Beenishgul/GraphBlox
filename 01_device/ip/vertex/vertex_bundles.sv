// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : vertex_bundles.sv
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

module vertex_bundles #(
    parameter ENGINE_ID_VERTEX   = 0,
    parameter ENGINE_BUNDLES_NUM = 4
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
    logic areset_vertex_bundles;
    logic areset_fifo          ;


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
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_in_din             ;
    MemoryPacketPayload    fifo_response_in_dout            ;
    FIFOStateSignalsInput  fifo_response_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_in_signals_out_int ;
    logic                  fifo_response_in_setup_signal_int;

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
// Generate Bundles
// --------------------------------------------------------------------------------------
    logic                  areset_engines                              [ENGINE_BUNDLES_NUM-1:0];
    KernelDescriptor       bundle_engines_descriptor_in                [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_request_in                   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_request_in_signals_in   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_request_in_signals_out  [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_bundle_engines_response_in   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_response_in_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_response_in_signals_out [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_request_out                  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_request_out_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_request_out_signals_out [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_response_out                 [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_response_out_signals_in [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_response_out_signals_out[ENGINE_BUNDLES_NUM-1:0];
    logic                  bundle_engines_fifo_setup_signal            [ENGINE_BUNDLES_NUM-1:0];
    logic                  bundle_engines_done_out                     [ENGINE_BUNDLES_NUM-1:0];


// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_vertex_bundles <= areset;
        areset_fifo           <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_bundles) begin
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
        if (areset_vertex_bundles) begin
            fifo_request_in_signals_in_reg  <= 0;
            fifo_response_in_signals_in_reg <= 0;
            fifo_request_out_signals_in_reg <= 0;
            request_in_reg.valid            <= 0;
            response_in_reg.valid           <= 0;
        end
        else begin
            fifo_request_in_signals_in_reg  <= fifo_request_in_signals_in;
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
        if (areset_vertex_bundles) begin
            fifo_setup_signal <= 1;
            request_out.valid <= 0;
        end
        else begin
            fifo_setup_signal <= fifo_request_in_setup_signal_int | fifo_request_out_setup_signal_int | fifo_response_in_setup_signal_int;
            request_out.valid <= request_out_int.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_request_in_signals_out  <= fifo_request_in_signals_out_int;
        fifo_response_in_signals_out <= fifo_response_in_signals_out_int;
        fifo_request_out_signals_out <= fifo_request_out_signals_out_int;
        request_out.payload          <= request_out_int.payload;
    end

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
    ) inst_fifo_MemoryPacketResponseInput (
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
// Bundles Arbitration INPUT
// --------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------
// Bundles Arbitration OUTPUT
// --------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------
// Generate Bundles
// --------------------------------------------------------------------------------------

    KernelDescriptor       bundle_engines_descriptor_in                [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_request_in                   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_request_in_signals_in   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_request_in_signals_out  [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_bundle_engines_response_in   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_response_in_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_response_in_signals_out [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_request_out                  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_request_out_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_request_out_signals_out [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_response_out                 [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_response_out_signals_in [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_response_out_signals_out[ENGINE_BUNDLES_NUM-1:0];
    logic                  bundle_engines_fifo_setup_signal            [ENGINE_BUNDLES_NUM-1:0];
    logic                  bundle_engines_done_out                     [ENGINE_BUNDLES_NUM-1:0];

    genvar i;
    generate
        for (i=0; i< ENGINE_BUNDLES_NUM; i++) begin : generate_bundle_engines
            bundle_engines #(
                .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
                .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE)
            ) inst_bundle_engines (
                .ap_clk                       (ap_clk                                         ),
                .areset                       (areset_engines                                 ),
                .descriptor_in                (bundle_engines_descriptor_in[i]                ),
                .request_in                   (bundle_engines_request_in[i]                   ),
                .fifo_request_in_signals_in   (bundle_engines_fifo_request_in_signals_in[i]   ),
                .fifo_request_in_signals_out  (bundle_engines_fifo_request_in_signals_out[i]  ),
                .response_in                  (bundle_engines_response_in[i]                  ),
                .fifo_response_in_signals_in  (bundle_engines_fifo_response_in_signals_in[i]  ),
                .fifo_response_in_signals_out (bundle_engines_fifo_response_in_signals_out[i] ),
                .request_out                  (bundle_engines_request_out[i]                  ),
                .fifo_request_out_signals_in  (bundle_engines_fifo_request_out_signals_in[i]  ),
                .fifo_request_out_signals_out (bundle_engines_fifo_request_out_signals_out[i] ),
                .response_out                 (bundle_engines_response_out[i]                 ),
                .fifo_response_out_signals_in (bundle_engines_fifo_response_out_signals_in[i] ),
                .fifo_response_out_signals_out(bundle_engines_fifo_response_out_signals_out[i]),
                .fifo_setup_signal            (bundle_engines_fifo_setup_signal[i]            ),
                .done_out                     (bundle_engines_done_out[i]                     )
            );
        end
    endgenerate


endmodule : vertex_bundles