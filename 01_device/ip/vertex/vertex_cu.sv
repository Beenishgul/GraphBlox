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
    input  logic                  ap_clk                   ,
    input  logic                  areset                   ,
    input  KernelDescriptor       descriptor_in            ,
    output MemoryPacket           request_out              ,
    input  FIFOStateSignalsInput  fifo_request_signals_in  ,
    output FIFOStateSignalsOutput fifo_request_signals_out ,
    input  MemoryPacket           response_in              ,
    input  FIFOStateSignalsInput  fifo_response_signals_in ,
    output FIFOStateSignalsOutput fifo_response_signals_out,
    output logic                  fifo_setup_signal        ,
    output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic            areset_vertex_cu ;
    logic            areset_fifo      ;
    KernelDescriptor descriptor_in_reg;
    MemoryPacket     response_in_reg  ;
    MemoryPacket     request_out_reg  ;

// --------------------------------------------------------------------------------------
// Request FIFO
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_request_signals_in_reg ;
    FIFOStateSignalsOutput fifo_request_signals_out_int;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_response_signals_in_reg ;
    FIFOStateSignalsOutput fifo_response_signals_out_int;

// --------------------------------------------------------------------------------------
// Instantiate vertex scheduling using stride index generator
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
    logic                  engine_stride_index_done_out                 ;


// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_vertex_cu    <= areset;
        areset_stride_index <= areset;
        areset_fifo         <= areset;
    end


// --------------------------------------------------------------------------------------
// Done Logic (DUMMY) Variables
// --------------------------------------------------------------------------------------
    logic                              done_signal_reg;
    logic [GLOBAL_DATA_WIDTH_BITS-1:0] counter        ;

// --------------------------------------------------------------------------------------
// Done Logic (DUMMY)
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            done_signal_reg <= 1'b0;
            counter         <= 0;
        end
        else begin
            if (descriptor_in_reg.valid) begin
                if(counter >= 100000) begin
                    done_signal_reg <= 1'b1;
                    counter         <= 0;
                end
                else begin
                    if(engine_stride_index_request_out.valid & (engine_stride_index_request_out.payload.meta.type.struct == STRUCT_ENGINE_SETUP)) begin
                        counter <= counter + 1;
                        if (counter == 0)
                            $display("MSG:  VERTEX ID -> %0d", engine_stride_index_request_out.payload.data.field);
                    end else
                    counter <= counter;
                end
            end else begin
                done_signal_reg <= 1'b0;
                counter         <= 0;
            end
        end
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
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
        if (areset_vertex_cu) begin
            fifo_response_signals_in_reg <= 0;
            fifo_request_signals_in_reg  <= 0;
            response_in_reg.valid        <= 1'b0;
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
            fifo_setup_signal <= 1'b1;
            request_out.valid <= 1'b0;
            done_out          <= 1'b0;
        end
        else begin
            fifo_setup_signal <= engine_stride_index_fifo_setup_signal;
            request_out.valid <= request_out_reg.valid ;
            // done_out          <= engine_stride_index_done_out | done_signal_reg;
            done_out          <= engine_stride_index_done_out;

        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_signals_out <= fifo_response_signals_out_int;
        fifo_request_signals_out  <= fifo_request_signals_out_int;
        request_out.payload       <= request_out_reg.payload;
    end

// --------------------------------------------------------------------------------------
// FIFO 
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Instantiate vertex scheduling using stride index generator
// --------------------------------------------------------------------------------------
    assign engine_stride_index_descriptor_in                 = descriptor_in_reg  ;
    assign engine_stride_index_fifo_request_signals_in.rd_en = 1'b1  ;

    // FIFOStateSignalsOutput engine_stride_index_fifo_request_signals_out ;
    // FIFOStateSignalsOutput engine_stride_index_fifo_response_signals_out;

    assign engine_stride_index_response_in                    = response_in_reg;
    assign engine_stride_index_fifo_response_signals_in.rd_en = 1'b1  ;

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
        .fifo_setup_signal        (engine_stride_index_fifo_setup_signal        ),
        .done_out                 (engine_stride_index_done_out                 )
    );

// --------------------------------------------------------------------------------------
// Instantiate vertex bundles
// --------------------------------------------------------------------------------------

    assign request_out_reg               = 0;
    assign fifo_response_signals_out_int = engine_stride_index_fifo_response_signals_out;
    assign fifo_request_signals_out_int  = engine_stride_index_fifo_request_signals_out;

    assign engine_stride_index_descriptor_in                 = descriptor_in_reg  ;

    assign engine_stride_index_response_in                    = response_in_reg;

    logic                  areset_bundles                             ;
    KernelDescriptor       vertex_bundles_descriptor_in               ;
    MemoryPacket           vertex_bundles_request_in                  ;
    FIFOStateSignalsInput  vertex_bundles_fifo_request_in_signals_in  ;
    FIFOStateSignalsOutput vertex_bundles_fifo_request_in_signals_out ;
    MemoryPacket           vertex_bundles_request_out                 ;
    FIFOStateSignalsInput  vertex_bundles_fifo_request_out_signals_in ;
    FIFOStateSignalsOutput vertex_bundles_fifo_request_out_signals_out;
    MemoryPacket           vertex_bundles_response_in                 ;
    FIFOStateSignalsInput  vertex_bundles_fifo_response_in_signals_in ;
    FIFOStateSignalsOutput vertex_bundles_fifo_response_in_signals_out;
    logic                  vertex_bundles_fifo_setup_signal           ;
    logic                  vertex_bundles_done_out                    ;

    vertex_bundles #(
        .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
        .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE),
        .ENGINE_ID_ENGINE(ENGINE_ID_ENGINE)
    ) inst_vertex_bundles (
        .ap_clk                      (ap_clk                                     ),
        .areset                      (vertex_bundles_areset                      ),
        .descriptor_in               (vertex_bundles_descriptor_in               ),
        .request_in                  (vertex_bundles_request_in                  ),
        .fifo_request_in_signals_in  (vertex_bundles_fifo_request_in_signals_in  ),
        .fifo_request_in_signals_out (vertex_bundles_fifo_request_in_signals_out ),
        .request_out                 (vertex_bundles_request_out                 ),
        .fifo_request_out_signals_in (vertex_bundles_fifo_request_out_signals_in ),
        .fifo_request_out_signals_out(vertex_bundles_fifo_request_out_signals_out),
        .response_in                 (vertex_bundles_response_in                 ),
        .fifo_response_in_signals_in (vertex_bundles_fifo_response_in_signals_in ),
        .fifo_response_in_signals_out(vertex_bundles_fifo_response_in_signals_out),
        .fifo_setup_signal           (vertex_bundles_fifo_setup_signal           ),
        .done_out                    (vertex_bundles_done_out                    )
    );



endmodule : vertex_cu