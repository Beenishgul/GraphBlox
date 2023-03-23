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
    parameter ENGINE_ID          = 0
) (
    // System Signals
    input  logic                         ap_clk                    ,
    input  logic                         areset                    ,
    input  logic                         enable                    ,
    input  SerialReadEngineConfiguration serial_read_config        ,
    output MemoryRequestPacket           serial_read_engine_req_out,
    output FIFOStateSignalsOutput        req_out_fifo_out_signals  ,
    input  FIFOStateSignalsInput         req_out_fifo_in_signals   ,
    output logic                         fifo_setup_signal
);


    logic engine_areset;
// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
    serial_read_engine_state current_state;
    serial_read_engine_state next_state   ;

    logic serial_read_engine_done ;
    logic serial_read_engine_start;

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
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        engine_areset <= areset;
    end

// --------------------------------------------------------------------------------------
// READ GLAY Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (engine_areset) begin
            glay_descriptor_reg.valid <= 0;
        end
        else begin
            glay_descriptor_reg.valid <= glay_descriptor.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        glay_descriptor_reg.payload <= glay_descriptor.payload;
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
            serial_read_config_reg.valid <= serial_read_config_reg.valid;
            req_out_fifo_in_signals_reg  <= req_out_fifo_in_signals;
        end
    end

    always_ff @(posedge ap_clk) begin
        serial_read_config_reg.payload <= serial_read_config_reg.payload;
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
                if(glay_descriptor_reg.valid)
                    next_state = SERIAL_READ_ENGINE_START;
                else
                    next_state = SERIAL_READ_ENGINE_IDLE;
            end
            SERIAL_READ_ENGINE_START : begin
                next_state = SERIAL_READ_ENGINE_BUSY;
            end
            SERIAL_READ_ENGINE_BUSY : begin
                if (serial_read_engine_done)
                    next_state = SERIAL_READ_ENGINE_DONE;
                else
                    next_state = SERIAL_READ_ENGINE_BUSY;
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
            end
            SERIAL_READ_ENGINE_IDLE : begin
                serial_read_engine_done  <= 1'b1;
                serial_read_engine_start <= 1'b0;
            end
            SERIAL_READ_ENGINE_START : begin
                serial_read_engine_done  <= 1'b0;
                serial_read_engine_start <= 1'b1;
            end
            SERIAL_READ_ENGINE_BUSY : begin
                serial_read_engine_done  <= 1'b0;
                serial_read_engine_start <= 1'b1;
            end
            SERIAL_READ_ENGINE_DONE : begin
                serial_read_engine_done  <= 1'b1;
                serial_read_engine_start <= 1'b0;
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
            if(serial_read_engine_start && !req_out_fifo_out_signals_reg.almost_full) begin
                serial_read_engine_req_out_din.valid <= 1'b1;
            end else begin
                serial_read_engine_req_out_din.valid <= 1'b0;
            end
        end
    end

    always_ff @(posedge ap_clk) begin
        if(serial_read_engine_start && !req_out_fifo_out_signals_reg.almost_full) begin
            serial_read_engine_req_out_din.payload <= 0;
        end
    end


    glay_transactions_counter #(
        .C_WIDTH(C_WIDTH),
        .C_INIT (C_INIT )
    ) inst_glay_transactions_counter (
        .ap_clk    (ap_clk    ),
        .ap_clken  (ap_clken  ),
        .areset    (areset    ),
        .load      (load      ),
        .incr      (incr      ),
        .decr      (decr      ),
        .load_value(load_value),
        .count     (count     ),
        .is_zero   (is_zero   )
    );

// --------------------------------------------------------------------------------------
// FIFO Ready
// --------------------------------------------------------------------------------------
    assign fifo_setup_signal_reg = req_out_fifo_out_signals_reg.wr_rst_busy | req_out_fifo_out_signals_reg.rd_rst_busy ;

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_516x32_MemoryRequestPacket
// --------------------------------------------------------------------------------------
    assign req_out_fifo_in_signals_reg.wr_en    = serial_read_engine_req_out_din.valid;
    assign serial_read_engine_req_in_dout.valid = req_out_fifo_out_signals_reg.valid;

    fifo_138x32 inst_fifo_138x32_MemoryRequestPacket (
        .clk         (ap_clk                                   ),
        .srst        (engine_areset                            ),
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