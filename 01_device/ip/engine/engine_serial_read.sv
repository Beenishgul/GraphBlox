// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_serial_read.sv
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

module engine_serial_read #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL ,
    parameter ENGINE_ID          = 0              ,
    parameter COUNTER_WIDTH      = 32
) (
    // System Signals
    input  logic                         ap_clk                      ,
    input  logic                         areset                      ,
    input  SerialReadEngineConfiguration serial_read_config          ,
    output MemoryRequestPacket           engine_serial_read_req_out  ,
    output FIFOStateSignalsOutput        req_fifo_out_signals        ,
    input  FIFOStateSignalsInput         req_fifo_in_signals         ,
    output logic                         fifo_setup_signal           ,
    input  logic                         engine_serial_read_in_start ,
    output logic                         engine_serial_read_out_ready,
    output logic                         engine_serial_read_out_done ,
    output logic                         engine_serial_read_out_pause
);

    logic engine_areset ;
    logic counter_areset;
    logic fifo_areset   ;

// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
    engine_serial_read_state current_state;
    engine_serial_read_state next_state   ;

    logic engine_serial_read_done_reg ;
    logic engine_serial_read_start_reg;

    SerialReadEngineConfiguration serial_read_config_reg;

    logic engine_serial_read_in_start_reg ;
    logic engine_serial_read_out_ready_reg;
    logic engine_serial_read_out_done_reg ;
    logic engine_serial_read_out_pause_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    MemoryRequestPacket    engine_serial_read_req_dout;
    MemoryRequestPacket    engine_serial_read_req_din ;
    FIFOStateSignalsOutput req_fifo_out_signals_reg   ;
    FIFOStateSignalsInput  req_fifo_in_signals_reg    ;
    logic                  fifo_setup_signal_reg      ;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
    logic                     counter_enable      ;
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
            serial_read_config_reg.valid    <= 0;
            req_fifo_in_signals_reg.rd_en   <= 0;
            engine_serial_read_in_start_reg <= 0;
        end
        else begin
            serial_read_config_reg.valid    <= serial_read_config.valid;
            req_fifo_in_signals_reg.rd_en   <= req_fifo_in_signals.rd_en & ~req_fifo_out_signals_reg.empty ;
            engine_serial_read_in_start_reg <= engine_serial_read_in_start;
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
            engine_serial_read_req_out.valid <= 0;
            req_fifo_out_signals             <= 0;
            engine_serial_read_out_ready     <= 0;
            engine_serial_read_out_done      <= 0;
        end
        else begin
            fifo_setup_signal                <= fifo_setup_signal_reg;
            engine_serial_read_req_out.valid <= req_fifo_out_signals_reg.valid;
            req_fifo_out_signals             <= req_fifo_out_signals_reg;
            engine_serial_read_out_ready     <= engine_serial_read_out_ready_reg;
            engine_serial_read_out_done      <= engine_serial_read_out_done_reg;
            engine_serial_read_out_pause     <= engine_serial_read_out_pause_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        engine_serial_read_req_out.payload <= engine_serial_read_req_dout.payload;
    end

// --------------------------------------------------------------------------------------
// Serial Read Engine State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(engine_areset)
            current_state <= ENGINE_SERIAL_READ_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            ENGINE_SERIAL_READ_RESET : begin
                next_state = ENGINE_SERIAL_READ_IDLE;
            end
            ENGINE_SERIAL_READ_IDLE : begin
                if(serial_read_config_reg.valid && engine_serial_read_in_start_reg)
                    next_state = ENGINE_SERIAL_READ_SETUP;
                else
                    next_state = ENGINE_SERIAL_READ_IDLE;
            end
            ENGINE_SERIAL_READ_SETUP : begin
                next_state = ENGINE_SERIAL_READ_START;
            end
            ENGINE_SERIAL_READ_START : begin
                next_state = ENGINE_SERIAL_READ_BUSY;
            end
            ENGINE_SERIAL_READ_BUSY : begin
                if (engine_serial_read_done_reg)
                    next_state = ENGINE_SERIAL_READ_DONE;
                else if (req_fifo_out_signals_reg.prog_full && ~engine_serial_read_done_reg)
                    next_state = ENGINE_SERIAL_READ_PAUSE;
                else
                    next_state = ENGINE_SERIAL_READ_BUSY;
            end
            ENGINE_SERIAL_READ_PAUSE : begin
                if (~req_fifo_out_signals_reg.prog_full)
                    next_state = ENGINE_SERIAL_READ_BUSY;
                else
                    next_state = ENGINE_SERIAL_READ_PAUSE;
            end
            ENGINE_SERIAL_READ_DONE : begin
                if(serial_read_config_reg.valid && engine_serial_read_in_start_reg)
                    next_state = ENGINE_SERIAL_READ_DONE;
                else
                    next_state = ENGINE_SERIAL_READ_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_SERIAL_READ_RESET : begin
                engine_serial_read_done_reg      <= 1'b1;
                engine_serial_read_start_reg     <= 1'b0;
                engine_serial_read_out_ready_reg <= 1'b0;
                engine_serial_read_out_done_reg  <= 1'b1;
                counter_enable                   <= 1'b0;
                counter_load                     <= 1'b0;
                counter_incr                     <= 1'b0;
                counter_decr                     <= 1'b0;
                counter_load_value               <= 0;
                counter_stride_value             <= 0;
                engine_serial_read_req_din.valid <= 1'b0;
            end
            ENGINE_SERIAL_READ_IDLE : begin
                engine_serial_read_done_reg      <= 1'b1;
                engine_serial_read_start_reg     <= 1'b0;
                engine_serial_read_out_ready_reg <= 1'b1;
                engine_serial_read_out_done_reg  <= 1'b1;
                counter_enable                   <= 1'b1;
                counter_load                     <= 1'b0;
                counter_incr                     <= 1'b0;
                counter_decr                     <= 1'b0;
                counter_load_value               <= 0;
                counter_stride_value             <= 0;
                engine_serial_read_req_din.valid <= 1'b0;
            end
            ENGINE_SERIAL_READ_SETUP : begin
                engine_serial_read_done_reg      <= 1'b0;
                engine_serial_read_start_reg     <= 1'b0;
                engine_serial_read_out_ready_reg <= 1'b0;
                engine_serial_read_out_done_reg  <= 1'b0;
                counter_enable                   <= 1'b1;
                counter_load                     <= 1'b1;
                counter_incr                     <= serial_read_config_reg.payload.increment;
                counter_decr                     <= serial_read_config_reg.payload.decrement;
                counter_load_value               <= serial_read_config_reg.payload.start_read;
                counter_stride_value             <= serial_read_config_reg.payload.stride;
                engine_serial_read_req_din.valid <= 1'b0;
            end
            ENGINE_SERIAL_READ_START : begin
                engine_serial_read_done_reg      <= 1'b0;
                engine_serial_read_start_reg     <= 1'b1;
                engine_serial_read_out_ready_reg <= 1'b0;
                engine_serial_read_out_done_reg  <= 1'b0;
                counter_enable                   <= 1'b1;
                counter_load                     <= 1'b0;
                counter_incr                     <= serial_read_config_reg.payload.increment;
                counter_decr                     <= serial_read_config_reg.payload.decrement;
                engine_serial_read_req_din.valid <= 1'b0;
            end
            ENGINE_SERIAL_READ_BUSY : begin
                if((counter_count >= serial_read_config_reg.payload.end_read)) begin
                    engine_serial_read_done_reg      <= 1'b1;
                    counter_incr                     <= 1'b0;
                    counter_decr                     <= 1'b0;
                    engine_serial_read_req_din.valid <= 1'b0;
                end
                else begin
                    engine_serial_read_done_reg      <= 1'b0;
                    counter_enable                   <= 1'b1;
                    counter_incr                     <= serial_read_config_reg.payload.increment;
                    counter_decr                     <= serial_read_config_reg.payload.decrement;
                    engine_serial_read_req_din.valid <= 1'b1;
                end
                engine_serial_read_out_ready_reg <= 1'b0;
                engine_serial_read_out_done_reg  <= 1'b0;
                counter_enable                   <= 1'b1;
                engine_serial_read_start_reg     <= 1'b1;
                counter_load                     <= 1'b0;
            end
            ENGINE_SERIAL_READ_PAUSE : begin
                engine_serial_read_done_reg      <= 1'b1;
                engine_serial_read_start_reg     <= 1'b0;
                engine_serial_read_out_ready_reg <= 1'b0;
                engine_serial_read_out_done_reg  <= 1'b0;
                counter_enable                   <= 1'b0;
                counter_load                     <= 1'b0;
                counter_incr                     <= 1'b0;
                counter_decr                     <= 1'b0;
                engine_serial_read_req_din.valid <= 1'b0;
            end
            ENGINE_SERIAL_READ_DONE : begin
                engine_serial_read_done_reg      <= 1'b1;
                engine_serial_read_start_reg     <= 1'b0;
                engine_serial_read_out_ready_reg <= 1'b0;
                engine_serial_read_out_done_reg  <= 1'b1;
                counter_enable                   <= 1'b1;
                counter_load                     <= 1'b0;
                counter_incr                     <= 1'b0;
                counter_decr                     <= 1'b0;
                engine_serial_read_req_din.valid <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(engine_serial_read_start_reg) begin
            engine_serial_read_req_din.payload.cu_engine_id          <= ENGINE_ID;
            engine_serial_read_req_din.payload.base_address   <= serial_read_config_reg.payload.array_pointer;
            engine_serial_read_req_din.payload.address_offset <= counter_count;
            engine_serial_read_req_din.payload.cmd_type       <= CMD_READ;
        end else begin
            engine_serial_read_req_din.payload <= 0;
        end
    end

    transactions_counter #(.C_WIDTH(COUNTER_WIDTH)) inst_transactions_counter (
        .ap_clk      (ap_clk              ),
        .ap_clken    (counter_enable      ),
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
    assign fifo_setup_signal_reg = req_fifo_out_signals_reg.wr_rst_busy | req_fifo_out_signals_reg.rd_rst_busy ;

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_515x16_MemoryRequestPacket
// --------------------------------------------------------------------------------------
    assign req_fifo_in_signals_reg.wr_en = engine_serial_read_req_din.valid;

    fifo_166x16 inst_fifo_166x16_MemoryRequestPacket (
        .clk         (ap_clk                               ),
        .srst        (fifo_areset                          ),
        .din         (engine_serial_read_req_din.payload   ),
        .wr_en       (req_fifo_in_signals_reg.wr_en        ),
        .rd_en       (req_fifo_in_signals_reg.rd_en        ),
        .dout        (engine_serial_read_req_dout.payload  ),
        .full        (req_fifo_out_signals_reg.full        ),
        .almost_full (req_fifo_out_signals_reg.almost_full ),
        .empty       (req_fifo_out_signals_reg.empty       ),
        .almost_empty(req_fifo_out_signals_reg.almost_empty),
        .valid       (req_fifo_out_signals_reg.valid       ),
        .prog_full   (req_fifo_out_signals_reg.prog_full   ),
        .prog_empty  (req_fifo_out_signals_reg.prog_empty  ),
        .wr_rst_busy (req_fifo_out_signals_reg.wr_rst_busy ),
        .rd_rst_busy (req_fifo_out_signals_reg.rd_rst_busy )
    );


endmodule : engine_serial_read