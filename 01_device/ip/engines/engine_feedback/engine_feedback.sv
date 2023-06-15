// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_feedback.sv
// Create : 2023-06-14 20:53:28
// Revise : 2023-06-14 22:40:40
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

module engine_feedback #(
    parameter ID_CU       = 0,
    parameter ID_BUNDLE   = 0,
    parameter ID_LANE     = 0,
    parameter ID_ENGINE   = 0,
    parameter MODE_ENGINE = 0
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  MemoryPacket           response_engine_in                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output MemoryPacket           request_engine_out                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out,
    output MemoryPacket           request_memory_out                 ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out,
    output logic                  fifo_setup_signal                  ,
    output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_template_engine;
    logic areset_fifo           ;

    KernelDescriptor descriptor_in_reg;

    MemoryPacket request_memory_out_reg;
    MemoryPacket response_engine_in_reg;
    MemoryPacket response_memory_in_reg;

    MemoryPacket request_engine_out_int;
    MemoryPacket request_memory_out_int;
    MemoryPacket response_engine_in_int;
    MemoryPacket response_memory_in_int;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_engine_in_din             ;
    MemoryPacketPayload    fifo_response_engine_in_dout            ;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_engine_in_signals_out_int ;
    logic                  fifo_response_engine_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_memory_in_din             ;
    MemoryPacketPayload    fifo_response_memory_in_dout            ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_int ;
    logic                  fifo_response_memory_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_engine_out_din             ;
    MemoryPacketPayload    fifo_request_engine_out_dout            ;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_engine_out_signals_out_int ;
    logic                  fifo_request_engine_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_memory_out_din             ;
    MemoryPacketPayload    fifo_request_memory_out_dout            ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_memory_out_signals_out_int ;
    logic                  fifo_request_memory_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// Generate Bundles
// --------------------------------------------------------------------------------------
    logic                  areset_template                             ;
    KernelDescriptor       template_descriptor_in                      ;
    MemoryPacket           template_response_engine_in                 ;
    FIFOStateSignalsInput  template_fifo_response_engine_in_signals_in ;
    FIFOStateSignalsOutput template_fifo_response_engine_in_signals_out;
    MemoryPacket           template_response_memory_in                 ;
    FIFOStateSignalsInput  template_fifo_response_memory_in_signals_in ;
    FIFOStateSignalsOutput template_fifo_response_memory_in_signals_out;
    MemoryPacket           template_request_engine_out                 ;
    FIFOStateSignalsInput  template_fifo_request_engine_out_signals_in ;
    FIFOStateSignalsOutput template_fifo_request_engine_out_signals_out;
    MemoryPacket           template_request_memory_out                 ;
    FIFOStateSignalsInput  template_fifo_request_memory_out_signals_in ;
    FIFOStateSignalsOutput template_fifo_request_memory_out_signals_out;
    logic                  template_fifo_setup_signal                  ;
    logic                  template_done_out                           ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_template_engine <= areset;
        areset_fifo            <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_template_engine) begin
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
        if (areset_template_engine) begin
            fifo_response_engine_in_signals_in_reg <= 0;
            fifo_request_engine_out_signals_in_reg <= 0;
            fifo_response_memory_in_signals_in_reg <= 0;
            fifo_request_memory_out_signals_in_reg <= 0;
            response_engine_in_reg.valid           <= 1'b0;
            response_memory_in_reg.valid           <= 1'b0;
        end
        else begin
            fifo_response_engine_in_signals_in_reg <= fifo_response_engine_in_signals_in;
            fifo_request_engine_out_signals_in_reg <= fifo_request_engine_out_signals_in;
            fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
            fifo_request_memory_out_signals_in_reg <= fifo_request_memory_out_signals_in;
            response_engine_in_reg.valid           <= response_engine_in.valid;
            response_memory_in_reg.valid           <= response_memory_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_engine_in_reg.payload <= response_engine_in.payload;
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_template_engine) begin
            fifo_setup_signal        <= 1'b0;
            request_engine_out.valid <= 1'b0;
            request_memory_out.valid <= 1'b0;
            done_out                 <= 1'b1;
        end
        else begin
            fifo_setup_signal        <= 1'b0;
            request_engine_out.valid <= request_engine_out_int.valid;
            request_memory_out.valid <= request_memory_out_int.valid;
            done_out                 <= template_done_out;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_engine_in_signals_out <= fifo_response_engine_in_signals_out_int;
        fifo_request_engine_out_signals_out <= fifo_request_engine_out_signals_out_int;
        fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_int;
        fifo_request_memory_out_signals_out <= fifo_request_memory_out_signals_out_int;
        request_engine_out.payload          <= request_engine_out_int.payload;
        request_memory_out.payload          <= request_memory_out_int.payload ;
    end
    
// --------------------------------------------------------------------------------------
// FEEDBACK signals
// --------------------------------------------------------------------------------------


endmodule : engine_feedback