// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_csr_index.sv
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

module engine_csr_index #(
    parameter ENGINE_ID_VERTEX = 0 ,
    parameter ENGINE_ID_BUNDLE = 0 ,
    parameter ENGINE_ID_ENGINE = 0 ,
    parameter ENGINE_SEQ_WIDTH = 11,
    parameter ENGINE_SEQ_MIN   = 0 ,
    parameter COUNTER_WIDTH    = 32
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output MemoryPacket           request_out                        ,
    input  FIFOStateSignalsInput  fifo_request_signals_in            ,
    output FIFOStateSignalsOutput fifo_request_signals_out           ,
    output logic                  fifo_setup_signal                  ,
    output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic            areset_engine_csr_index   ;
    logic            areset_csr_index_generator;
    logic            areset_csr_index_configure;
    logic            areset_fifo               ;
    KernelDescriptor descriptor_in_reg         ;
    MemoryPacket     response_memory_in_reg    ;
    MemoryPacket     response_out_int          ;
    MemoryPacket     request_out_int           ;

// --------------------------------------------------------------------------------------
// Setup state machine signals
// --------------------------------------------------------------------------------------
    logic                  done_int_reg ;
    engine_csr_index_state current_state;
    engine_csr_index_state next_state   ;

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
    MemoryPacketPayload    fifo_response_din                      ;
    MemoryPacketPayload    fifo_response_dout                     ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_int ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_int;
    logic                  fifo_response_setup_signal_int         ;

// --------------------------------------------------------------------------------------
// Serial Read Engine Signals
// --------------------------------------------------------------------------------------
// Serial Read Engine Configure
// --------------------------------------------------------------------------------------
    MemoryPacket           engine_csr_index_configure_response_memory_in                 ;
    CSRIndexConfiguration  engine_csr_index_configure_configuration_out                  ;
    FIFOStateSignalsOutput engine_csr_index_configure_fifo_response_memory_in_signals_out;
    FIFOStateSignalsInput  engine_csr_index_configure_fifo_response_memory_in_signals_in ;
    FIFOStateSignalsOutput engine_csr_index_configure_fifo_configuration_signals_out     ;
    FIFOStateSignalsInput  engine_csr_index_configure_fifo_configuration_signals_in      ;
    logic                  engine_csr_index_configure_fifo_setup_signal                  ;
// --------------------------------------------------------------------------------------
// Serial Read Engine Generator
// --------------------------------------------------------------------------------------
    MemoryPacket           engine_csr_index_generator_request_out             ;
    FIFOStateSignalsOutput engine_csr_index_generator_fifo_request_signals_out;
    FIFOStateSignalsInput  engine_csr_index_generator_fifo_request_signals_in ;
    FIFOStateSignalsInput  engine_csr_index_generator_fifo_request_signals_reg;
    logic                  engine_csr_index_generator_pause_in                ;
    logic                  engine_csr_index_generator_ready_out               ;
    logic                  engine_csr_index_generator_done_out                ;
    CSRIndexConfiguration  engine_csr_index_generator_configuration_in        ;
    logic                  engine_csr_index_generator_fifo_setup_signal       ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_engine_csr_index    <= areset;
        areset_csr_index_generator <= areset;
        areset_csr_index_configure <= areset;
        areset_fifo                <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_engine_csr_index) begin
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
        if (areset_engine_csr_index) begin
            fifo_response_memory_in_signals_in_reg <= 0;
            fifo_request_signals_in_reg            <= 0;
            response_memory_in_reg.valid           <= 1'b0  ;
        end
        else begin
            fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
            fifo_request_signals_in_reg            <= fifo_request_signals_in;
            response_memory_in_reg.valid           <= response_memory_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_engine_csr_index) begin
            fifo_setup_signal <= 1'b1  ;

            request_out.valid <= 1'b0;
            done_out          <= 1'b0;
        end
        else begin
            fifo_setup_signal <= fifo_request_setup_signal_int | fifo_response_setup_signal_int | engine_csr_index_generator_fifo_setup_signal | engine_csr_index_configure_fifo_setup_signal;
            request_out.valid <= request_out_int.valid ;
            done_out          <= done_int_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_int;
        fifo_request_signals_out            <= fifo_request_signals_out_int;
        request_out.payload                 <= request_out_int.payload;
    end

// --------------------------------------------------------------------------------------
// SETUP State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_engine_csr_index)
            current_state <= ENGINE_CSR_INDEX_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            ENGINE_CSR_INDEX_RESET : begin
                next_state = ENGINE_CSR_INDEX_IDLE;
            end
            ENGINE_CSR_INDEX_IDLE : begin
                if(~engine_csr_index_configure_fifo_configuration_signals_out.empty & descriptor_in_reg.valid & (engine_csr_index_generator_done_out & engine_csr_index_generator_ready_out))
                    next_state = ENGINE_CSR_INDEX_START;
                else
                    next_state = ENGINE_CSR_INDEX_IDLE;
            end
            ENGINE_CSR_INDEX_START : begin
                next_state = ENGINE_CSR_INDEX_START_TRANS;
            end
            ENGINE_CSR_INDEX_START_TRANS : begin
                if(engine_csr_index_generator_done_out | engine_csr_index_generator_ready_out)
                    next_state = ENGINE_CSR_INDEX_START_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_BUSY;
            end
            ENGINE_CSR_INDEX_BUSY : begin
                if (done_int_reg)
                    next_state = ENGINE_CSR_INDEX_DONE;
                else if (fifo_request_signals_out_int.prog_full | fifo_response_memory_in_signals_out_int.prog_full)
                    next_state = ENGINE_CSR_INDEX_PAUSE;
                else
                    next_state = ENGINE_CSR_INDEX_BUSY;
            end
            ENGINE_CSR_INDEX_PAUSE : begin
                if (~(fifo_request_signals_out_int.prog_full | fifo_response_memory_in_signals_out_int.prog_full))
                    next_state = ENGINE_CSR_INDEX_BUSY;
                else
                    next_state = ENGINE_CSR_INDEX_PAUSE;
            end
            ENGINE_CSR_INDEX_DONE : begin
                if (descriptor_in_reg.valid & engine_csr_index_configure_fifo_configuration_signals_out.empty)
                    next_state = ENGINE_CSR_INDEX_DONE;
                else
                    next_state = ENGINE_CSR_INDEX_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_CSR_INDEX_RESET : begin
                done_int_reg                                                   <= 1'b1;
                engine_csr_index_generator_fifo_request_signals_reg.rd_en      <= 1'b0;
                engine_csr_index_configure_fifo_configuration_signals_in.rd_en <= 1'b0;
                engine_csr_index_generator_pause_in                            <= 1'b0;
            end
            ENGINE_CSR_INDEX_IDLE : begin
                done_int_reg                                                   <= 1'b0;
                engine_csr_index_generator_fifo_request_signals_reg.rd_en      <= 1'b0;
                engine_csr_index_configure_fifo_configuration_signals_in.rd_en <= 1'b0;
                engine_csr_index_generator_pause_in                            <= 1'b0;
            end
            ENGINE_CSR_INDEX_START : begin
                done_int_reg                                                   <= 1'b0;
                engine_csr_index_generator_fifo_request_signals_reg.rd_en      <= 1'b0;
                engine_csr_index_configure_fifo_configuration_signals_in.rd_en <= 1'b1;
                engine_csr_index_generator_pause_in                            <= 1'b0;
            end
            ENGINE_CSR_INDEX_START_TRANS : begin
                done_int_reg                                                   <= 1'b0;
                engine_csr_index_generator_fifo_request_signals_reg.rd_en      <= 1'b0;
                engine_csr_index_configure_fifo_configuration_signals_in.rd_en <= 1'b0;
                engine_csr_index_generator_pause_in                            <= 1'b0;
            end
            ENGINE_CSR_INDEX_BUSY : begin
                done_int_reg                                                   <= engine_csr_index_generator_done_out & engine_csr_index_generator_fifo_request_signals_out.empty & fifo_request_signals_out_int.empty;
                engine_csr_index_generator_fifo_request_signals_reg.rd_en      <= ~fifo_request_signals_out_int.prog_full;
                engine_csr_index_configure_fifo_configuration_signals_in.rd_en <= 1'b0;
                engine_csr_index_generator_pause_in                            <= 1'b0;
            end
            ENGINE_CSR_INDEX_PAUSE : begin
                done_int_reg                                                   <= 1'b0;
                engine_csr_index_generator_fifo_request_signals_reg.rd_en      <= 1'b0;
                engine_csr_index_configure_fifo_configuration_signals_in.rd_en <= 1'b0;
                engine_csr_index_generator_pause_in                            <= 1'b1;
            end
            ENGINE_CSR_INDEX_DONE : begin
                done_int_reg                                                   <= 1'b1;
                engine_csr_index_generator_fifo_request_signals_reg.rd_en      <= 1'b0;
                engine_csr_index_configure_fifo_configuration_signals_in.rd_en <= 1'b0;
                engine_csr_index_generator_pause_in                            <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)


// --------------------------------------------------------------------------------------
// Drive Response Packet Setup Engine Configuration
// 0 - increment/decrement
// 1 - index_start
// 2 - index_end
// 3 - csr
// 4 - granularity - $clog2(BIT_WIDTH) used to shift
// --------------------------------------------------------------------------------------
    assign engine_csr_index_configure_response_memory_in                       = response_out_int;
    assign engine_csr_index_configure_fifo_response_memory_in_signals_in.rd_en = 1'b1;

    engine_csr_index_configure #(
        .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
        .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE),
        .ENGINE_ID_ENGINE(ENGINE_ID_ENGINE),
        .ENGINE_SEQ_WIDTH(ENGINE_SEQ_WIDTH),
        .ENGINE_SEQ_MIN  (ENGINE_SEQ_MIN  )
    ) inst_engine_csr_index_configure (
        .ap_clk                             (ap_clk                                                        ),
        .areset                             (areset_csr_index_configure                                    ),
        .response_memory_in                 (engine_csr_index_configure_response_memory_in                 ),
        .fifo_response_memory_in_signals_in (engine_csr_index_configure_fifo_response_memory_in_signals_in ),
        .fifo_response_memory_in_signals_out(engine_csr_index_configure_fifo_response_memory_in_signals_out),
        .configuration_out                  (engine_csr_index_configure_configuration_out                  ),
        .fifo_configuration_signals_in      (engine_csr_index_configure_fifo_configuration_signals_in      ),
        .fifo_configuration_signals_out     (engine_csr_index_configure_fifo_configuration_signals_out     ),
        .fifo_setup_signal                  (engine_csr_index_configure_fifo_setup_signal                  )
    );

// --------------------------------------------------------------------------------------
// CSR engine generator instantiation
// --------------------------------------------------------------------------------------
    assign engine_csr_index_generator_configuration_in        = engine_csr_index_configure_configuration_out;
    assign engine_csr_index_generator_fifo_request_signals_in = engine_csr_index_generator_fifo_request_signals_reg;

    engine_csr_index_generator #(.COUNTER_WIDTH(COUNTER_WIDTH)) inst_engine_csr_index_generator (
        .ap_clk                  (ap_clk                                             ),
        .areset                  (areset_csr_index_generator                         ),
        .configuration_in        (engine_csr_index_generator_configuration_in        ),
        .request_out             (engine_csr_index_generator_request_out             ),
        .fifo_request_signals_in (engine_csr_index_generator_fifo_request_signals_in ),
        .fifo_request_signals_out(engine_csr_index_generator_fifo_request_signals_out),
        .fifo_setup_signal       (engine_csr_index_generator_fifo_setup_signal       ),
        .pause_in                (engine_csr_index_generator_pause_in                ),
        .ready_out               (engine_csr_index_generator_ready_out               ),
        .done_out                (engine_csr_index_generator_done_out                )
    );

// --------------------------------------------------------------------------------------
// FIFO sequence requests out MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_signals_in_int.wr_en = engine_csr_index_generator_request_out.valid;
    assign fifo_request_din                  = engine_csr_index_generator_request_out.payload;

    // Pop
    assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
    assign request_out_int.valid             = fifo_request_signals_out_int.valid;
    assign request_out_int.payload           = fifo_request_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequest (
        .clk         (ap_clk                                   ),
        .srst        (areset_fifo                              ),
        .din         (fifo_request_din                         ),
        .wr_en       (fifo_request_signals_in_int.wr_en        ),
        .rd_en       (fifo_request_signals_in_int.rd_en        ),
        .dout        (fifo_request_dout                        ),
        .full        (fifo_request_signals_out_int.full        ),
        .almost_full (fifo_request_signals_out_int.almost_full ),
        .empty       (fifo_request_signals_out_int.empty       ),
        .almost_empty(fifo_request_signals_out_int.almost_empty),
        .valid       (fifo_request_signals_out_int.valid       ),
        .prog_full   (fifo_request_signals_out_int.prog_full   ),
        .prog_empty  (fifo_request_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_request_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_request_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy | fifo_response_memory_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid;
    assign fifo_response_din                            = response_memory_in_reg.payload;

    // Pop
    assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~engine_csr_index_configure_fifo_response_memory_in_signals_out.prog_full;
    assign response_out_int.valid                       = fifo_response_memory_in_signals_out_int.valid;
    assign response_out_int.payload                     = fifo_response_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponse (
        .clk         (ap_clk                                              ),
        .srst        (areset_fifo                                         ),
        .din         (fifo_response_din                                   ),
        .wr_en       (fifo_response_memory_in_signals_in_int.wr_en        ),
        .rd_en       (fifo_response_memory_in_signals_in_int.rd_en        ),
        .dout        (fifo_response_dout                                  ),
        .full        (fifo_response_memory_in_signals_out_int.full        ),
        .almost_full (fifo_response_memory_in_signals_out_int.almost_full ),
        .empty       (fifo_response_memory_in_signals_out_int.empty       ),
        .almost_empty(fifo_response_memory_in_signals_out_int.almost_empty),
        .valid       (fifo_response_memory_in_signals_out_int.valid       ),
        .prog_full   (fifo_response_memory_in_signals_out_int.prog_full   ),
        .prog_empty  (fifo_response_memory_in_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_response_memory_in_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_response_memory_in_signals_out_int.rd_rst_busy )
    );

endmodule : engine_csr_index