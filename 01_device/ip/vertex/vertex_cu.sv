// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : vertex_cu.sv
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
import PKG_VERTEX::*;
import PKG_CACHE::*;

module vertex_cu #(
    parameter ENGINE_ID_VERTEX = 0 ,
    parameter ENGINE_ID_BUNDLE = 0 ,
    parameter ENGINE_ID_ENGINE = 0 ,
    parameter COUNTER_WIDTH    = 32
) (
    // System Signals
    input  logic                       ap_clk                   ,
    input  logic                       areset                   ,
    input  ControlChainInterfaceOutput control_state            ,
    input  KernelDescriptor            descriptor_in            ,
    output MemoryPacket                request_out              ,
    input  FIFOStateSignalsInput       fifo_request_signals_in  ,
    output FIFOStateSignalsOutput      fifo_request_signals_out ,
    input  MemoryPacket                response_in              ,
    input  FIFOStateSignalsInput       fifo_response_signals_in ,
    output FIFOStateSignalsOutput      fifo_response_signals_out,
    output logic                       fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic            areset_vertex_cu             ;
    logic            areset_stride_index_generator;
    logic            areset_fifo                  ;
    KernelDescriptor descriptor_reg               ;
    MemoryPacket     response_in_reg              ;
    MemoryPacket     response_out_int             ;
    MemoryPacket     request_out_reg              ;

// --------------------------------------------------------------------------------------
// Setup state machine signals
// --------------------------------------------------------------------------------------
    logic           done_int_reg ;
    vertex_cu_state current_state;
    vertex_cu_state next_state   ;

// --------------------------------------------------------------------------------------
// Request FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_din             ;
    MemoryPacketPayload    fifo_request_dout            ;
    FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_signals_out_int ;
    logic                  fifo_request_setup_signal_int;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_din             ;
    MemoryPacketPayload    fifo_response_dout            ;
    FIFOStateSignalsInput  fifo_response_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_signals_out_int ;
    logic                  fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// Serial Read Engine Signals
// --------------------------------------------------------------------------------------
    MemoryPacket                      engine_stride_index_generator_request_out             ;
    FIFOStateSignalsOutput            engine_stride_index_generator_fifo_request_signals_out;
    FIFOStateSignalsInput             engine_stride_index_generator_fifo_request_signals_in ;
    FIFOStateSignalsInput             engine_stride_index_generator_fifo_request_signals_reg;
    logic                             engine_stride_index_generator_start_in                ;
    logic                             engine_stride_index_generator_pause_in                ;
    logic                             engine_stride_index_generator_ready_out               ;
    logic                             engine_stride_index_generator_done_out                ;
    StrideIndexGeneratorConfiguration engine_stride_index_generator_configuration_in        ;
    logic                             engine_stride_index_generator_fifo_setup_signal       ;

// Serial Read Engine Configure
// --------------------------------------------------------------------------------------
    MemoryPacket                      engine_stride_index_generator_configure_response_in                   ;
    StrideIndexGeneratorConfiguration engine_stride_index_generator_configure_configuration_out             ;
    FIFOStateSignalsOutput            engine_stride_index_generator_configure_fifo_response_signals_out     ;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_fifo_response_signals_in      ;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_response_signals_reg          ;
    FIFOStateSignalsOutput            engine_stride_index_generator_configure_fifo_configuration_signals_out;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_fifo_configuration_signals_in ;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_configuration_signals_reg     ;
    logic                             engine_stride_index_generator_configure_fifo_setup_signal             ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_vertex_cu              <= areset;
        areset_stride_index_generator <= areset;
        areset_fifo                   <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            descriptor_reg.valid <= 0;
        end
        else begin
            descriptor_reg.valid <= descriptor_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        descriptor_reg.payload <= descriptor_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            fifo_response_signals_in_reg <= 0;
            fifo_request_signals_in_reg  <= 0;
            response_in_reg.valid        <= 0;
        end
        else begin
            fifo_response_signals_in_reg <= fifo_response_signals_in;
            fifo_request_signals_in_reg  <= fifo_request_signals_in;
            response_in_reg.valid        <= response_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_in_reg.payload <= response_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            fifo_setup_signal         <= 1;
            fifo_response_signals_out <= 0;
            fifo_request_signals_out  <= 0;
            request_out.valid         <= 0;
        end
        else begin
            fifo_setup_signal         <= engine_stride_index_generator_fifo_setup_signal | fifo_request_setup_signal_int | fifo_response_setup_signal_int | engine_stride_index_generator_configure_fifo_setup_signal;
            fifo_response_signals_out <= fifo_response_signals_out_int;
            fifo_request_signals_out  <= fifo_request_signals_out_int;
            request_out.valid         <= request_out_reg.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_out.payload <= request_out_reg.payload;
    end

// --------------------------------------------------------------------------------------
// Instantiate vertex scheduling
// --------------------------------------------------------------------------------------

    logic                  areset_stride_index                          ;
    KernelDescriptor       engine_stride_index_descriptor_in            ;
    MemoryPacket           engine_stride_index_request_out              ;
    FIFOStateSignalsInput  engine_stride_index_fifo_request_signals_in  ;
    FIFOStateSignalsOutput engine_stride_index_fifo_request_signals_out ;
    MemoryPacket           engine_stride_index_response_in              ;
    FIFOStateSignalsInput  engine_stride_index_fifo_response_signals_in ;
    FIFOStateSignalsOutput engine_stride_index_fifo_response_signals_out;
    logic                  engine_stride_index_fifo_setup_signal        ;

    engine_stride_index #(
        .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
        .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE),
        .ENGINE_ID_ENGINE(1               )
    ) inst_engine_stride_index (
        .ap_clk                   (ap_clk                                       ),
        .areset                   (areset_stride_index                          ),
        .descriptor_in            (engine_stride_index_descriptor_in            ),
        .request_out              (engine_stride_index_request_out              ),
        .fifo_request_signals_in  (engine_stride_index_fifo_request_signals_in  ),
        .fifo_request_signals_out (engine_stride_index_fifo_request_signals_out ),
        .response_in              (engine_stride_index_response_in              ),
        .fifo_response_signals_in (engine_stride_index_fifo_response_signals_in ),
        .fifo_response_signals_out(engine_stride_index_fifo_response_signals_out),
        .fifo_setup_signal        (engine_stride_index_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Instantiate vertex bundles
// --------------------------------------------------------------------------------------

    // vertex_cu_bundles #(
    //     .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
    //     .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE),
    //     .ENGINE_ID_ENGINE(ENGINE_ID_ENGINE)
    // ) inst_vertex_cu_bundles (
    //     .ap_clk                   (ap_clk                   ),
    //     .areset                   (areset                   ),
    //     .descriptor_in            (descriptor_in            ),
    //     .request_out              (request_out              ),
    //     .fifo_request_signals_in  (fifo_request_signals_in  ),
    //     .fifo_request_signals_out (fifo_request_signals_out ),
    //     .response_in              (response_in              ),
    //     .fifo_response_signals_in (fifo_response_signals_in ),
    //     .fifo_response_signals_out(fifo_response_signals_out),
    //     .fifo_setup_signal        (fifo_setup_signal        )
    // );


endmodule : vertex_cu