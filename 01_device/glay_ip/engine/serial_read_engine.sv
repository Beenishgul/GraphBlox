// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : serial_read_engine.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_REQ_PKG::*;
import GLAY_ENGINE_PKG::*;

// Serial\_Read\_Engine
// --------------------

// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity

// The serial read engine sends read commands to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array.

// uint32_t *serialReadEngine(uint32_t *arrayPointer, uint32_t arraySize, uint32_t startRead, uint32_t endRead, uint32_t stride, uint32_t granularity)

module serial_read_engine #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL ,
    parameter ENGINE_ID          = 0              ,
    parameter COUNTER_WIDTH      = 32
) (
    // System Signals
    input  logic                         ap_clk                    ,
    input  logic                         areset                    ,
    input  SerialReadEngineConfiguration serial_read_config        ,
    output MemoryRequestPacket           serial_read_engine_req_out,
    output FIFOStateSignalsOutput        req_out_fifo_out_signals  ,
    input  FIFOStateSignalsInput         req_out_fifo_in_signals   ,
    output logic                         fifo_setup_signal
);

    logic engine_areset ;
    logic counter_areset;
    logic fifo_areset   ;

// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
    serial_read_engine_state current_state;
    serial_read_engine_state next_state   ;

    logic serial_read_engine_done ;
    logic serial_read_engine_start;
    logic serial_read_engine_setup;
    logic serial_read_engine_pause;

    SerialReadEngineConfiguration serial_read_config_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    MemoryRequestPacket    serial_read_engine_req_out_dout;
    MemoryRequestPacket    serial_read_engine_req_out_din ;
    FIFOStateSignalsOutput req_out_fifo_out_signals_reg   ;
    FIFOStateSignalsInput  req_out_fifo_in_signals_reg    ;
    logic                  fifo_setup_signal_reg          ;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
    logic                     counter_load        ;
    logic                     counter_incr        ;
    logic                     counter_decr        ;
    logic                     is_zero             ;
    logic [COUNTER_WIDTH-1:0] counter_load_value  ;
    logic [COUNTER_WIDTH-1:0] counter_stride_value;
    logic [COUNTER_WIDTH-1:0] counter_count       ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        engine_areset  <= areset;
        counter_areset <= areset;
        fifo_areset    <= areset;
    end
// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (engine_areset) begin
            serial_read_config_reg.valid <= 0;
            req_out_fifo_in_signals_reg  <= 0;
        end
        else begin
            serial_read_config_reg.valid <= serial_read_config.valid;
            req_out_fifo_in_signals_reg  <= req_out_fifo_in_signals;
        end
    end

    always_ff @(posedge ap_clk) begin
        serial_read_config_reg.payload <= serial_read_config.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (engine_areset) begin
            fifo_setup_signal                <= 1;
            serial_read_engine_req_out.valid <= 0;
            req_out_fifo_out_signals         <= 0;
        end
        else begin
            fifo_setup_signal                <= fifo_setup_signal_reg;
            serial_read_engine_req_out.valid <= serial_read_engine_req_out_dout.valid;
            req_out_fifo_out_signals         <= req_out_fifo_out_signals_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        serial_read_engine_req_out.payload <= serial_read_engine_req_out_dout.payload;
    end

// --------------------------------------------------------------------------------------
// Serial Read Engine State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(engine_areset)
            current_state <= SERIAL_READ_ENGINE_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            SERIAL_READ_ENGINE_RESET : begin
                next_state = SERIAL_READ_ENGINE_IDLE;
            end
            SERIAL_READ_ENGINE_IDLE : begin
                if(serial_read_config_reg.valid)
                    next_state = SERIAL_READ_ENGINE_SETUP;
                else
                    next_state = SERIAL_READ_ENGINE_IDLE;
            end
            SERIAL_READ_ENGINE_SETUP : begin
                next_state = SERIAL_READ_ENGINE_START;
            end
            SERIAL_READ_ENGINE_START : begin
                next_state = SERIAL_READ_ENGINE_BUSY;
            end
            SERIAL_READ_ENGINE_BUSY : begin
                if (serial_read_engine_done)
                    next_state = SERIAL_READ_ENGINE_DONE;
                else if (req_out_fifo_out_signals_reg.almost_full)
                    next_state = SERIAL_READ_ENGINE_PAUSE;
                else
                    next_state = SERIAL_READ_ENGINE_BUSY;
            end
            SERIAL_READ_ENGINE_PAUSE : begin
                if (!req_out_fifo_out_signals_reg.almost_full)
                    next_state = SERIAL_READ_ENGINE_BUSY;
                else
                    next_state = SERIAL_READ_ENGINE_PAUSE;
            end
            SERIAL_READ_ENGINE_DONE : begin
                next_state = SERIAL_READ_ENGINE_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            SERIAL_READ_ENGINE_RESET : begin
                serial_read_engine_done  <= 1'b1;
                serial_read_engine_start <= 1'b0;
                serial_read_engine_setup <= 1'b1;
                serial_read_engine_pause <= 1'b0;
                counter_load             <= 1'b0;
                counter_incr             <= 1'b0;
                counter_decr             <= 1'b0;
                counter_load_value       <= 0;
                counter_stride_value     <= 0;
            end
            end
            SERIAL_READ_ENGINE_IDLE : begin
                serial_read_engine_done  <= 1'b1;
                serial_read_engine_start <= 1'b0;
                serial_read_engine_setup <= 1'b1;
                serial_read_engine_pause <= 1'b0;
                counter_load             <= 1'b0;
                counter_incr             <= 1'b0;
                counter_decr             <= 1'b0;
                counter_load_value       <= 0;
                counter_stride_value     <= 0;
            end
            end
            SERIAL_READ_ENGINE_SETUP : begin
                serial_read_engine_done  <= 1'b0;
                serial_read_engine_start <= 1'b0;
                serial_read_engine_setup <= 1'b1;
                serial_read_engine_pause <= 1'b0;
                counter_load             <= 1'b1;
                counter_incr             <= serial_read_config_reg.payload.increment;
                counter_decr             <= serial_read_config_reg.payload.decrement;
                counter_load_value       <= serial_read_config_reg.payload.start_read;
                counter_stride_value     <= serial_read_config_reg.payload.stride;
            end
            end
            SERIAL_READ_ENGINE_START : begin
                serial_read_engine_done  <= 1'b0;
                serial_read_engine_start <= 1'b1;
                serial_read_engine_setup <= 1'b0;
                serial_read_engine_pause <= 1'b0;
                counter_load             <= 1'b0;
                counter_incr             <= serial_read_config_reg.payload.increment;
                counter_decr             <= serial_read_config_reg.payload.decrement;
            end
            SERIAL_READ_ENGINE_BUSY : begin
                if(counter_count == serial_read_config_reg.payload.end_read)
                    serial_read_engine_done <= 1'b1;
                else
                    serial_read_engine_done <= 1'b0;

                serial_read_engine_start <= 1'b1;
                serial_read_engine_setup <= 1'b0;
                serial_read_engine_pause <= 1'b0;
                counter_load             <= 1'b0;
                counter_incr             <= serial_read_config_reg.payload.increment;
                counter_decr             <= serial_read_config_reg.payload.decrement;
            end
            SERIAL_READ_ENGINE_PAUSE : begin
                serial_read_engine_done  <= 1'b0;
                serial_read_engine_start <= 1'b1;
                serial_read_engine_setup <= 1'b0;
                serial_read_engine_pause <= 1'b1;
                counter_load             <= 1'b0;
                counter_incr             <= 1'b0;
                counter_decr             <= 1'b0;
            end
            SERIAL_READ_ENGINE_DONE : begin
                serial_read_engine_done  <= 1'b1;
                serial_read_engine_start <= 1'b0;
                serial_read_engine_setup <= 1'b0;
                counter_load             <= 1'b0;
                counter_incr             <= 1'b0;
                counter_decr             <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (engine_areset) begin
            serial_read_engine_req_out_din.valid <= 1'b0;
        end
        else begin
            if(serial_read_engine_start && ~serial_read_engine_done && ~serial_read_engine_pause && ~serial_read_engine_setup) begin
                serial_read_engine_req_out_din.valid <= 1'b1;
            end else begin
                serial_read_engine_req_out_din.valid <= 1'b0;
            end
        end
    end

    always_ff @(posedge ap_clk) begin
        if(serial_read_engine_start) begin
            serial_read_engine_req_out_din.payload.cu_id          <= ENGINE_ID;
            serial_read_engine_req_out_din.payload.base_address   <= serial_read_config_reg.payload.array_pointer;
            serial_read_engine_req_out_din.payload.address_offset <= counter_count;
            serial_read_engine_req_out_din.payload.cmd_type       <= CMD_READ;
        end
    end

    glay_transactions_counter #(.C_WIDTH(COUNTER_WIDTH)) inst_glay_transactions_counter (
        .ap_clk      (ap_clk              ),
        .ap_clken    (ap_clken            ),
        .areset      (counter_areset      ),
        .load        (counter_load        ),
        .incr        (counter_incr        ),
        .decr        (counter_decr        ),
        .load_value  (counter_load_value  ),
        .stride_value(counter_stride_value),
        .count       (counter_count       ),
        .is_zero     (is_zero             )
    );

// --------------------------------------------------------------------------------------
// FIFO Ready
// --------------------------------------------------------------------------------------
    assign fifo_setup_signal_reg = req_out_fifo_out_signals_reg.wr_rst_busy | req_out_fifo_out_signals_reg.rd_rst_busy ;

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_516x32_MemoryRequestPacket
// --------------------------------------------------------------------------------------
    assign req_out_fifo_in_signals_reg.wr_en = serial_read_engine_req_out_din.valid;

    fifo_138x32 inst_fifo_138x32_MemoryRequestPacket (
        .clk         (ap_clk                                   ),
        .srst        (fifo_areset                              ),
        .din         (serial_read_engine_req_out_din           ),
        .wr_en       (req_out_fifo_in_signals_reg.wr_en        ),
        .rd_en       (req_out_fifo_in_signals_reg.rd_en        ),
        .dout        (serial_read_engine_req_out_dout          ),
        .full        (req_out_fifo_out_signals_reg.full        ),
        .almost_full (req_out_fifo_out_signals_reg.almost_full ),
        .empty       (req_out_fifo_out_signals_reg.empty       ),
        .almost_empty(req_out_fifo_out_signals_reg.almost_empty),
        .valid       (req_out_fifo_out_signals_reg.valid       ),
        .prog_full   (req_out_fifo_out_signals_reg.prog_full   ),
        .prog_empty  (req_out_fifo_out_signals_reg.prog_empty  ),
        .wr_rst_busy (req_out_fifo_out_signals_reg.wr_rst_busy ),
        .rd_rst_busy (req_out_fifo_out_signals_reg.rd_rst_busy )
    );


endmodule : serial_read_engine