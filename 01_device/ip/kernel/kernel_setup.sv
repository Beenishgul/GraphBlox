// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_setup.sv
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

module kernel_setup #(
    parameter ENGINE_ID_X   = 0 ,
    parameter ENGINE_ID_Y   = 0 ,
    parameter COUNTER_WIDTH = 32
) (
    // System Signals
    input  logic                       ap_clk                   ,
    input  logic                       areset                   ,
    input  ControlChainInterfaceOutput control_state            ,
    input  DescriptorInterface         descriptor_in            ,
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
    logic areset_kernel_setup;
    logic areset_serial_read ;
    logic areset_fifo        ;

    DescriptorInterface descriptor_reg  ;
    MemoryPacket        response_in_reg ;
    MemoryPacket        response_out_reg;
    MemoryPacket        request_out_reg ;

// --------------------------------------------------------------------------------------
// Setup state machine signals
// --------------------------------------------------------------------------------------
    logic              done_internal_reg;
    kernel_setup_state current_state    ;
    kernel_setup_state next_state       ;

// --------------------------------------------------------------------------------------
// Request FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_din                ;
    MemoryPacketPayload    fifo_request_dout               ;
    FIFOStateSignalsInput  fifo_request_signals_in_reg     ;
    FIFOStateSignalsInput  fifo_request_signals_in_internal;
    FIFOStateSignalsOutput fifo_request_signals_out_reg    ;
    logic                  fifo_request_setup_signal       ;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_din                ;
    MemoryPacketPayload    fifo_response_dout               ;
    FIFOStateSignalsInput  fifo_response_signals_in_reg     ;
    FIFOStateSignalsInput  fifo_response_signals_in_internal;
    FIFOStateSignalsOutput fifo_response_signals_out_reg    ;
    logic                  fifo_response_setup_signal       ;

// --------------------------------------------------------------------------------------
// Serial Read Engine Signals
// --------------------------------------------------------------------------------------
    SerialReadEngineConfiguration engine_serial_read_configuration_in        ;
    SerialReadEngineConfiguration configuration_comb                         ;
    MemoryPacket                  engine_serial_read_request_out             ;
    FIFOStateSignalsOutput        engine_serial_read_fifo_request_signals_out;
    FIFOStateSignalsInput         engine_serial_read_fifo_request_signals_in ;
    FIFOStateSignalsInput         engine_serial_read_fifo_request_signals_reg;
    logic                         engine_serial_read_start_in                ;
    logic                         engine_serial_read_pause_in                ;
    logic                         engine_serial_read_ready_out               ;
    logic                         engine_serial_read_done_out                ;

    logic engine_serial_read_fifo_setup_signal;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_kernel_setup <= areset;
        areset_serial_read  <= areset;
        areset_fifo         <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_kernel_setup) begin
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
        if (areset_kernel_setup) begin
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
        if (areset_kernel_setup) begin
            fifo_setup_signal         <= 1;
            fifo_response_signals_out <= 0;
            fifo_request_signals_out  <= 0;
            request_out.valid         <= 0;
        end
        else begin
            fifo_setup_signal         <= engine_serial_read_fifo_setup_signal | fifo_request_setup_signal | fifo_response_setup_signal;
            fifo_response_signals_out <= fifo_response_signals_out_reg;
            fifo_request_signals_out  <= fifo_request_signals_out_reg;
            request_out.valid         <= request_out_reg.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_out.payload <= request_out_reg.payload;
    end

// --------------------------------------------------------------------------------------
// SETUP State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_kernel_setup)
            current_state <= KERNEL_SETUP_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            KERNEL_SETUP_RESET : begin
                next_state = KERNEL_SETUP_IDLE;
            end
            KERNEL_SETUP_IDLE : begin
                if(descriptor_reg.valid & engine_serial_read_done_out & engine_serial_read_ready_out)
                    next_state = KERNEL_SETUP_REQ_START;
                else
                    next_state = KERNEL_SETUP_IDLE;
            end
            KERNEL_SETUP_REQ_START : begin
                if(engine_serial_read_done_out & engine_serial_read_ready_out) begin
                    next_state = KERNEL_SETUP_REQ_START;
                end else begin
                    next_state = KERNEL_SETUP_REQ_BUSY;
                end
            end
            KERNEL_SETUP_REQ_BUSY : begin
                if (done_internal_reg)
                    next_state = KERNEL_SETUP_REQ_DONE;
                else if (fifo_request_signals_out_reg.prog_full | fifo_response_signals_out_reg.prog_full)
                    next_state = KERNEL_SETUP_REQ_PAUSE;
                else
                    next_state = KERNEL_SETUP_REQ_BUSY;
            end
            KERNEL_SETUP_REQ_PAUSE : begin
                if (~(fifo_request_signals_out_reg.prog_full | fifo_response_signals_out_reg.prog_full))
                    next_state = KERNEL_SETUP_REQ_BUSY;
                else
                    next_state = KERNEL_SETUP_REQ_PAUSE;
            end
            KERNEL_SETUP_REQ_DONE : begin
                if (descriptor_reg.valid)
                    next_state = KERNEL_SETUP_REQ_DONE;
                else
                    next_state = KERNEL_SETUP_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            KERNEL_SETUP_RESET : begin
                done_internal_reg                                 <= 1'b1;
                engine_serial_read_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_serial_read_start_in                       <= 1'b0;
                engine_serial_read_pause_in                       <= 1'b0;
                engine_serial_read_configuration_in.valid         <= 1'b0;
            end
            KERNEL_SETUP_IDLE : begin
                done_internal_reg                                 <= 1'b0;
                engine_serial_read_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_serial_read_start_in                       <= 1'b0;
                engine_serial_read_pause_in                       <= 1'b0;
                engine_serial_read_configuration_in.valid         <= 1'b0;
            end
            KERNEL_SETUP_REQ_START : begin
                done_internal_reg                                 <= 1'b0;
                engine_serial_read_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_serial_read_start_in                       <= 1'b1;
                engine_serial_read_pause_in                       <= 1'b0;
                engine_serial_read_configuration_in.valid         <= 1'b1;
            end
            KERNEL_SETUP_REQ_BUSY : begin
                done_internal_reg                                 <= engine_serial_read_done_out & engine_serial_read_fifo_request_signals_out.empty & fifo_request_signals_out_reg.empty;
                engine_serial_read_fifo_request_signals_reg.rd_en <= ~fifo_request_signals_out_reg.prog_full;
                engine_serial_read_start_in                       <= 1'b0;
                engine_serial_read_pause_in                       <= 1'b0;
                engine_serial_read_configuration_in.valid         <= 1'b1;
            end
            KERNEL_SETUP_REQ_PAUSE : begin
                done_internal_reg                                 <= 1'b0;
                engine_serial_read_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_serial_read_start_in                       <= 1'b0;
                engine_serial_read_pause_in                       <= 1'b1;
                engine_serial_read_configuration_in.valid         <= 1'b0;
            end
            KERNEL_SETUP_REQ_DONE : begin
                done_internal_reg                                 <= 1'b1;
                engine_serial_read_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_serial_read_start_in                       <= 1'b0;
                engine_serial_read_pause_in                       <= 1'b0;
                engine_serial_read_configuration_in.valid         <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)


// --------------------------------------------------------------------------------------
// Create Configuration Packet
// --------------------------------------------------------------------------------------
    always_comb begin
        configuration_comb.payload.param.increment     = 1'b1;
        configuration_comb.payload.param.decrement     = 1'b0;
        configuration_comb.payload.param.array_pointer = descriptor_reg.payload.graph_csr_struct;
        configuration_comb.payload.param.array_size    = descriptor_reg.payload.auxiliary_2*(CACHE_BACKEND_DATA_W/8);
        configuration_comb.payload.param.start_read    = 0;
        configuration_comb.payload.param.end_read      = descriptor_reg.payload.auxiliary_2*(CACHE_BACKEND_DATA_W/8);
        configuration_comb.payload.param.stride        = CACHE_FRONTEND_DATA_W/8;
        configuration_comb.payload.param.granularity   = CACHE_FRONTEND_DATA_W/8;

        configuration_comb.payload.meta.id_vertex      = ENGINE_ID_X;
        configuration_comb.payload.meta.id_bundle      = ENGINE_ID_X;
        configuration_comb.payload.meta.id_engine      = ENGINE_ID_Y;
        configuration_comb.payload.meta.address_base   = descriptor_reg.payload.graph_csr_struct;
        configuration_comb.payload.meta.address_offset = 0;
        configuration_comb.payload.meta.type_cmd       = CMD_READ;
        configuration_comb.payload.meta.type_struct    = STRUCT_KERNEL_SETUP;
        configuration_comb.payload.meta.type_operand   = OP_LOCATION_0;
        configuration_comb.payload.meta.type_filter    = FILTER_NOP;
        configuration_comb.payload.meta.type_ALU       = ALU_NOP;
    end

    always_ff @(posedge ap_clk) begin
        engine_serial_read_configuration_in.payload <= configuration_comb.payload;
    end

// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    assign engine_serial_read_fifo_request_signals_in = engine_serial_read_fifo_request_signals_reg;

    engine_serial_read #(.COUNTER_WIDTH(COUNTER_WIDTH)) inst_engine_serial_read (
        .ap_clk                  (ap_clk                                     ),
        .areset                  (areset_serial_read                         ),
        .configuration_in        (engine_serial_read_configuration_in        ),
        .request_out             (engine_serial_read_request_out             ),
        .fifo_request_signals_in (engine_serial_read_fifo_request_signals_in ),
        .fifo_request_signals_out(engine_serial_read_fifo_request_signals_out),
        .fifo_setup_signal       (engine_serial_read_fifo_setup_signal       ),
        .start_in                (engine_serial_read_start_in                ),
        .pause_in                (engine_serial_read_pause_in                ),
        .ready_out               (engine_serial_read_ready_out               ),
        .done_out                (engine_serial_read_done_out                )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_setup_signal = fifo_request_signals_out_reg.wr_rst_busy | fifo_request_signals_out_reg.rd_rst_busy;

    // Push
    assign fifo_request_signals_in_internal.wr_en = engine_serial_read_request_out.valid;
    assign fifo_request_din                       = engine_serial_read_request_out.payload;

    // Pop
    assign fifo_request_signals_in_internal.rd_en = ~fifo_request_signals_out_reg.empty & fifo_request_signals_in_reg.rd_en;
    assign request_out_reg.valid                  = fifo_request_signals_out_reg.valid;
    assign request_out_reg.payload                = fifo_request_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequest (
        .clk         (ap_clk                                   ),
        .srst        (areset_fifo                              ),
        .din         (fifo_request_din                         ),
        .wr_en       (fifo_request_signals_in_internal.wr_en   ),
        .rd_en       (fifo_request_signals_in_internal.rd_en   ),
        .dout        (fifo_request_dout                        ),
        .full        (fifo_request_signals_out_reg.full        ),
        .almost_full (fifo_request_signals_out_reg.almost_full ),
        .empty       (fifo_request_signals_out_reg.empty       ),
        .almost_empty(fifo_request_signals_out_reg.almost_empty),
        .valid       (fifo_request_signals_out_reg.valid       ),
        .prog_full   (fifo_request_signals_out_reg.prog_full   ),
        .prog_empty  (fifo_request_signals_out_reg.prog_empty  ),
        .wr_rst_busy (fifo_request_signals_out_reg.wr_rst_busy ),
        .rd_rst_busy (fifo_request_signals_out_reg.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO cache response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_setup_signal = fifo_response_signals_out_reg.wr_rst_busy | fifo_response_signals_out_reg.rd_rst_busy;

    // Push
    assign fifo_response_signals_in_internal.wr_en = response_in_reg.valid;
    assign fifo_response_din                       = response_in_reg.payload;

    // Pop
    assign fifo_response_signals_in_internal.rd_en = ~fifo_response_signals_out_reg.empty & fifo_response_signals_in_reg.rd_en;;
    assign response_out_reg.valid                  = fifo_response_signals_out_reg.valid;
    assign response_out_reg.payload                = fifo_response_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponse (
        .clk         (ap_clk                                    ),
        .srst        (areset_fifo                               ),
        .din         (fifo_response_din                         ),
        .wr_en       (fifo_response_signals_in_internal.wr_en   ),
        .rd_en       (fifo_response_signals_in_internal.rd_en   ),
        .dout        (fifo_response_dout                        ),
        .full        (fifo_response_signals_out_reg.full        ),
        .almost_full (fifo_response_signals_out_reg.almost_full ),
        .empty       (fifo_response_signals_out_reg.empty       ),
        .almost_empty(fifo_response_signals_out_reg.almost_empty),
        .valid       (fifo_response_signals_out_reg.valid       ),
        .prog_full   (fifo_response_signals_out_reg.prog_full   ),
        .prog_empty  (fifo_response_signals_out_reg.prog_empty  ),
        .wr_rst_busy (fifo_response_signals_out_reg.wr_rst_busy ),
        .rd_rst_busy (fifo_response_signals_out_reg.rd_rst_busy )
    );


endmodule : kernel_setup