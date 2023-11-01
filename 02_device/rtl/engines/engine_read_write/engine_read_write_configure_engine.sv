// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_read_write_configure_engine.sv
// Create : 2023-07-17 15:02:02
// Revise : 2023-08-30 13:18:48
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_CACHE::*;

module engine_read_write_configure_engine #(parameter
    ID_CU     = 0,
    ID_BUNDLE = 0,
    ID_LANE   = 0,
    ID_ENGINE = 0
) (
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  MemoryPacket           response_engine_in                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out,
    output CSRIndexConfiguration  configure_engine_out               ,
    input  FIFOStateSignalsInput  fifo_configure_engine_signals_in   ,
    output FIFOStateSignalsOutput fifo_configure_engine_signals_out  ,
    output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_csr_index_generator;
    logic areset_fifo               ;

    MemoryPacket          response_engine_in_reg    ;
    CSRIndexConfiguration configure_engine_reg      ;
    logic                 configure_engine_valid_reg;
    logic                 configure_engine_valid_int;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_engine_in_din             ;
    MemoryPacket           fifo_response_engine_in_dout_int        ;
    MemoryPacketPayload    fifo_response_engine_in_dout            ;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_engine_in_signals_out_int ;
    logic                  fifo_response_engine_in_setup_signal_int;
    logic                  fifo_response_engine_in_push_filter     ;

// --------------------------------------------------------------------------------------
// Configure FIFO
// --------------------------------------------------------------------------------------
    CSRIndexConfigurationPayload fifo_configure_engine_din             ;
    CSRIndexConfiguration        fifo_configure_engine_dout_int        ;
    CSRIndexConfigurationPayload fifo_configure_engine_dout            ;
    FIFOStateSignalsInput        fifo_configure_engine_signals_in_reg  ;
    FIFOStateSignalsInput        fifo_configure_engine_signals_in_int  ;
    FIFOStateSignalsOutput       fifo_configure_engine_signals_out_int ;
    logic                        fifo_configure_engine_setup_signal_int;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_csr_index_generator <= areset;
        areset_fifo                <= areset;
    end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_csr_index_generator) begin
            response_engine_in_reg.valid           <= 1'b0;
            fifo_response_engine_in_signals_in_reg <= 0;
            fifo_configure_engine_signals_in_reg   <= 0;
        end else begin
            response_engine_in_reg.valid                 <= response_engine_in.valid ;
            fifo_response_engine_in_signals_in_reg.rd_en <= fifo_response_engine_in_signals_in.rd_en;
            fifo_configure_engine_signals_in_reg.rd_en   <= fifo_configure_engine_signals_in.rd_en;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_engine_in_reg.payload <= response_engine_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_csr_index_generator) begin
            fifo_setup_signal          <= 1'b1;
            configure_engine_out.valid <= 0;
        end else begin
            fifo_setup_signal          <= fifo_response_engine_in_setup_signal_int | fifo_configure_engine_setup_signal_int;
            configure_engine_out.valid <= fifo_configure_engine_dout_int.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_engine_in_signals_out <= fifo_response_engine_in_signals_out_int;
        fifo_configure_engine_signals_out   <= fifo_configure_engine_signals_out_int;
        configure_engine_out.payload        <= fifo_configure_engine_dout_int.payload;
    end

// --------------------------------------------------------------------------------------
// Create Configuration Packet
// --------------------------------------------------------------------------------------
    assign configure_engine_valid_int = configure_engine_valid_reg;

    always_ff @(posedge ap_clk) begin
        if(areset_csr_index_generator) begin
            configure_engine_reg       <= 0;
            configure_engine_valid_reg <= 0;
        end else begin
            configure_engine_reg.valid <= configure_engine_valid_int;

            if(fifo_response_engine_in_dout_int.valid) begin
                configure_engine_reg.payload.meta                <= fifo_response_engine_in_dout_int.payload.meta;
                configure_engine_reg.payload.param.increment     <= 0;
                configure_engine_reg.payload.param.decrement     <= 0;
                configure_engine_reg.payload.param.mode_sequence <= 0;
                configure_engine_reg.payload.param.mode_buffer   <= 0;
                configure_engine_reg.payload.param.index_start   <= fifo_response_engine_in_dout_int.payload.data.field[0];
                configure_engine_reg.payload.param.index_end     <= fifo_response_engine_in_dout_int.payload.data.field[1];
                configure_engine_reg.payload.param.stride        <= 0;
                configure_engine_reg.payload.param.granularity   <= 0;
                configure_engine_reg.payload.param.array_pointer <= 0;
                configure_engine_reg.payload.param.array_size    <= fifo_response_engine_in_dout_int.payload.data.field[3];
                configure_engine_valid_reg                       <= 1'b1  ;
            end else begin
                configure_engine_reg.payload.param <= configure_engine_reg.payload.param;
                if(configure_engine_valid_int)
                    configure_engine_valid_reg <= 0;
                else
                    configure_engine_valid_reg <= configure_engine_valid_reg;
            end
        end
    end

// --------------------------------------------------------------------------------------
// FIFO engine response out fifo MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_engine_in_setup_signal_int = fifo_response_engine_in_signals_out_int.wr_rst_busy  | fifo_response_engine_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_engine_in_push_filter          = ((response_engine_in_reg.payload.meta.subclass.buffer == STRUCT_CU_SETUP)|(response_engine_in_reg.payload.meta.subclass.buffer == STRUCT_ENGINE_SETUP));
    assign fifo_response_engine_in_signals_in_int.wr_en = response_engine_in_reg.valid & fifo_response_engine_in_push_filter;
    assign fifo_response_engine_in_din                  = response_engine_in_reg.payload;

    // Pop
    assign fifo_response_engine_in_signals_in_int.rd_en = ~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en & ~(configure_engine_valid_int) & ~fifo_configure_engine_signals_out_int.prog_full ;
    assign fifo_response_engine_in_dout_int.valid       = fifo_response_engine_in_signals_out_int.valid;
    assign fifo_response_engine_in_dout_int.payload     = fifo_response_engine_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponseMemoryInput (
        .clk        (ap_clk                                             ),
        .srst       (areset_fifo                                        ),
        .din        (fifo_response_engine_in_din                        ),
        .wr_en      (fifo_response_engine_in_signals_in_int.wr_en       ),
        .rd_en      (fifo_response_engine_in_signals_in_int.rd_en       ),
        .dout       (fifo_response_engine_in_dout                       ),
        .full       (fifo_response_engine_in_signals_out_int.full       ),
        .empty      (fifo_response_engine_in_signals_out_int.empty      ),
        .valid      (fifo_response_engine_in_signals_out_int.valid      ),
        .prog_full  (fifo_response_engine_in_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_response_engine_in_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_response_engine_in_signals_out_int.rd_rst_busy)
    );

// --------------------------------------------------------------------------------------
// FIFO engine configure_engine out fifo MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_configure_engine_setup_signal_int = fifo_configure_engine_signals_out_int.wr_rst_busy  | fifo_configure_engine_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_configure_engine_signals_in_int.wr_en = configure_engine_reg.valid;
    assign fifo_configure_engine_din                  = configure_engine_reg.payload;

    // Pop
    assign fifo_configure_engine_signals_in_int.rd_en = ~fifo_configure_engine_signals_out_int.empty & fifo_configure_engine_signals_in_reg.rd_en;
    assign fifo_configure_engine_dout_int.valid       = fifo_configure_engine_signals_out_int.valid;
    assign fifo_configure_engine_dout_int.payload     = fifo_configure_engine_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                                 ),
        .WRITE_DATA_WIDTH($bits(CSRIndexConfigurationPayload)),
        .READ_DATA_WIDTH ($bits(CSRIndexConfigurationPayload)),
        .PROG_THRESH     (8                                  )
    ) inst_fifo_MemoryPacketResponseConigurationInput (
        .clk        (ap_clk                                           ),
        .srst       (areset_fifo                                      ),
        .din        (fifo_configure_engine_din                        ),
        .wr_en      (fifo_configure_engine_signals_in_int.wr_en       ),
        .rd_en      (fifo_configure_engine_signals_in_int.rd_en       ),
        .dout       (fifo_configure_engine_dout                       ),
        .full       (fifo_configure_engine_signals_out_int.full       ),
        .empty      (fifo_configure_engine_signals_out_int.empty      ),
        .valid      (fifo_configure_engine_signals_out_int.valid      ),
        .prog_full  (fifo_configure_engine_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_configure_engine_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_configure_engine_signals_out_int.rd_rst_busy)
    );

endmodule : engine_read_write_configure_engine