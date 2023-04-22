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
    output MemoryPacket                  engine_serial_read_req_out  ,
    output FIFOStateSignalsOutput        fifo_request_signals_out    ,
    input  FIFOStateSignalsInput         fifo_request_signals_in     ,
    output logic                         fifo_setup_signal           ,
    input  logic                         engine_serial_read_in_start ,
    output logic                         engine_serial_read_out_ready,
    output logic                         engine_serial_read_out_done ,
    output logic                         engine_serial_read_out_pause
);

    logic engine_areset ;
    logic areset_counter;
    logic areset_fifo   ;

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
    MemoryPacket           engine_serial_read_req_dout          ;
    MemoryPacket           engine_serial_read_req_din           ;
    MemoryPacket           engine_serial_read_req_comb          ;
    FIFOStateSignalsOutput fifo_request_signals_out_reg         ;
    FIFOStateSignalsInput  fifo_request_signals_in_reg          ;
    logic                  fifo_MemoryPacketRequest_setup_signal;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
    logic                     counter_enable      ;
    logic                     counter_load        ;
    logic                     counter_incr        ;
    logic                     counter_decr        ;
    logic                     counter_is_zero     ;
    logic [COUNTER_WIDTH-1:0] counter_load_value  ;
    logic [COUNTER_WIDTH-1:0] counter_stride_value;
    logic [COUNTER_WIDTH-1:0] counter_count       ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        engine_areset  <= areset;
        areset_counter <= areset;
        areset_fifo    <= areset;
    end
// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (engine_areset) begin
            serial_read_config_reg.valid      <= 0;
            fifo_request_signals_in_reg.rd_en <= 0;
            engine_serial_read_in_start_reg   <= 0;
        end
        else begin
            serial_read_config_reg.valid      <= serial_read_config.valid;
            fifo_request_signals_in_reg.rd_en <= fifo_request_signals_in.rd_en & ~fifo_request_signals_out_reg.empty ;
            engine_serial_read_in_start_reg   <= engine_serial_read_in_start;
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
            fifo_request_signals_out         <= 0;
            engine_serial_read_out_ready     <= 0;
            engine_serial_read_out_done      <= 0;
        end
        else begin
            fifo_setup_signal                <= fifo_MemoryPacketRequest_setup_signal;
            engine_serial_read_req_out.valid <= fifo_request_signals_out_reg.valid;
            fifo_request_signals_out         <= fifo_request_signals_out_reg;
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
                else if (fifo_request_signals_out_reg.prog_full && ~engine_serial_read_done_reg)
                    next_state = ENGINE_SERIAL_READ_PAUSE;
                else
                    next_state = ENGINE_SERIAL_READ_BUSY;
            end
            ENGINE_SERIAL_READ_PAUSE : begin
                if (~fifo_request_signals_out_reg.prog_full)
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
                counter_incr                     <= serial_read_config_reg.payload.param.increment;
                counter_decr                     <= serial_read_config_reg.payload.param.decrement;
                counter_load_value               <= serial_read_config_reg.payload.param.start_read;
                counter_stride_value             <= serial_read_config_reg.payload.param.stride;
                engine_serial_read_req_din.valid <= 1'b0;
            end
            ENGINE_SERIAL_READ_START : begin
                engine_serial_read_done_reg      <= 1'b0;
                engine_serial_read_start_reg     <= 1'b1;
                engine_serial_read_out_ready_reg <= 1'b0;
                engine_serial_read_out_done_reg  <= 1'b0;
                counter_enable                   <= 1'b1;
                counter_load                     <= 1'b0;
                counter_incr                     <= serial_read_config_reg.payload.param.increment;
                counter_decr                     <= serial_read_config_reg.payload.param.decrement;
                engine_serial_read_req_din.valid <= 1'b0;
            end
            ENGINE_SERIAL_READ_BUSY : begin
                if((counter_count >= serial_read_config_reg.payload.param.end_read)) begin
                    engine_serial_read_done_reg      <= 1'b1;
                    counter_incr                     <= 1'b0;
                    counter_decr                     <= 1'b0;
                    engine_serial_read_req_din.valid <= 1'b0;
                end
                else begin
                    engine_serial_read_done_reg      <= 1'b0;
                    counter_enable                   <= 1'b1;
                    counter_incr                     <= serial_read_config_reg.payload.param.increment;
                    counter_decr                     <= serial_read_config_reg.payload.param.decrement;
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
    always_comb begin
        engine_serial_read_req_comb.payload.meta.cu_engine_id_x = serial_read_config_reg.payload.meta.cu_engine_id_x;
        engine_serial_read_req_comb.payload.meta.cu_engine_id_y = serial_read_config_reg.payload.meta.cu_engine_id_x;
        engine_serial_read_req_comb.payload.meta.base_address   = serial_read_config_reg.payload.param.array_pointer;
        engine_serial_read_req_comb.payload.meta.address_offset = counter_count;
        engine_serial_read_req_comb.payload.meta.cmd_type       = serial_read_config_reg.payload.meta.cmd_type;
        engine_serial_read_req_comb.payload.meta.struct_type    = serial_read_config_reg.payload.meta.struct_type;
        engine_serial_read_req_comb.payload.meta.operand_loc    = serial_read_config_reg.payload.meta.operand_loc ;
        engine_serial_read_req_comb.payload.meta.filter_op      = serial_read_config_reg.payload.meta.filter_op;
        engine_serial_read_req_comb.payload.meta.ALU_op         = serial_read_config_reg.payload.meta.ALU_op;
    end

    always_ff @(posedge ap_clk) begin
        if(engine_serial_read_start_reg) begin
            engine_serial_read_req_din.payload.meta <= engine_serial_read_req_comb.payload.meta;
        end else begin
            engine_serial_read_req_din.payload.meta <= 0;
        end
    end

    transactions_counter #(.C_WIDTH(COUNTER_WIDTH)) inst_transactions_counter (
        .ap_clk      (ap_clk              ),
        .ap_clken    (counter_enable      ),
        .areset      (areset_counter      ),
        .load        (counter_load        ),
        .incr        (counter_incr        ),
        .decr        (counter_decr        ),
        .load_value  (counter_load_value  ),
        .stride_value(counter_stride_value),
        .count       (counter_count       ),
        .is_zero     (counter_is_zero     )
    );

// --------------------------------------------------------------------------------------
// FIFO Ready
// --------------------------------------------------------------------------------------
    assign fifo_MemoryPacketRequest_setup_signal = fifo_request_signals_out_reg.wr_rst_busy | fifo_request_signals_out_reg.rd_rst_busy ;

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_814x16_MemoryPacket
// --------------------------------------------------------------------------------------
    assign fifo_request_signals_in_reg.wr_en = engine_serial_read_req_din.valid;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequest (
        .clk         (ap_clk                                   ),
        .srst        (areset_fifo                              ),
        .din         (engine_serial_read_req_din.payload       ),
        .wr_en       (fifo_request_signals_in_reg.wr_en        ),
        .rd_en       (fifo_request_signals_in_reg.rd_en        ),
        .dout        (engine_serial_read_req_dout.payload      ),
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


endmodule : engine_serial_read