// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_stride_index_generator.sv
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
import PKG_CACHE::*;

// ------------------------
// Stride\_Index\_Generator
// ------------------------

// ### Input: index\_start, index\_end, stride, granularity

// The stride index generator serves two purposes. First, it generates a
// sequence of indices or Vertex-IDs scheduled to the Vertex Compute Units
// (CUs). For each Vertex-CU, a batch of Vertex-IDs is sent to be processed
// based on the granularity. For example, if granularity is (8), each CU
// (Compute Units) would get eight vertex IDs in chunks.

// uint32_t *strideIndexGenerator(uint32_t indexStart, uint32_t indexEnd, uint32_t granularity)

module engine_stride_index_generator #(parameter COUNTER_WIDTH      = 32) (
    // System Signals
    input  logic                    ap_clk                  ,
    input  logic                    areset                  ,
    input  StrideIndexConfiguration configuration_in        ,
    output MemoryPacket             request_out             ,
    input  FIFOStateSignalsInput    fifo_request_signals_in ,
    output FIFOStateSignalsOutput   fifo_request_signals_out,
    output logic                    fifo_setup_signal       ,
    input  logic                    pause_in                ,
    output logic                    ready_out               ,
    output logic                    done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_engine ;
    logic areset_counter;
    logic areset_fifo   ;

    StrideIndexConfiguration configuration_reg;
    MemoryPacket             request_out_int  ;

// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
    engine_stride_index_generator_state current_state;
    engine_stride_index_generator_state next_state   ;

    logic done_int_reg ;
    logic pause_in_reg ;
    logic ready_out_reg;
    logic done_out_reg ;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_din             ;
    MemoryPacket           fifo_request_din_reg         ;
    MemoryPacketPayload    fifo_request_dout            ;
    MemoryPacket           fifo_request_comb            ;
    FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_signals_out_int ;
    logic                  fifo_request_setup_signal_int;

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
        areset_engine  <= areset;
        areset_counter <= areset;
        areset_fifo    <= areset;
    end
// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_engine) begin
            fifo_request_signals_in_reg <= 0;
            configuration_reg.valid     <= 1'b0;
            pause_in_reg                <= 1'b0;
        end
        else begin
            fifo_request_signals_in_reg <= fifo_request_signals_in ;
            pause_in_reg                <= pause_in;
            if(ready_out_reg & done_out_reg) begin
                configuration_reg.valid <= configuration_in.valid;
            end else begin
                configuration_reg.valid <= configuration_reg.valid;
            end
        end
    end



    always_ff @(posedge ap_clk) begin
        configuration_reg.payload <= configuration_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_engine) begin
            fifo_setup_signal <= 1'b1;
            ready_out         <= 1'b0;
            done_out          <= 1'b0;
            request_out.valid <= 1'b0;
        end
        else begin
            fifo_setup_signal <= fifo_request_setup_signal_int;
            ready_out         <= ready_out_reg;
            done_out          <= done_out_reg;
            request_out.valid <= request_out_int.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_request_signals_out <= fifo_request_signals_out_int;
        request_out.payload      <= request_out_int.payload;
    end

// --------------------------------------------------------------------------------------
// Serial Read Engine State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_engine)
            current_state <= ENGINE_STRIDE_INDEX_GEN_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            ENGINE_STRIDE_INDEX_GEN_RESET : begin
                next_state = ENGINE_STRIDE_INDEX_GEN_IDLE;
            end
            ENGINE_STRIDE_INDEX_GEN_IDLE : begin
                if(configuration_reg.valid)
                    next_state = ENGINE_STRIDE_INDEX_GEN_SETUP;
                else
                    next_state = ENGINE_STRIDE_INDEX_GEN_IDLE;
            end
            ENGINE_STRIDE_INDEX_GEN_SETUP : begin
                next_state = ENGINE_STRIDE_INDEX_GEN_START;
            end
            ENGINE_STRIDE_INDEX_GEN_START : begin
                next_state = ENGINE_STRIDE_INDEX_GEN_BUSY;
            end
            ENGINE_STRIDE_INDEX_GEN_BUSY_TRANS : begin
                next_state = ENGINE_STRIDE_INDEX_GEN_BUSY;
            end
            ENGINE_STRIDE_INDEX_GEN_BUSY : begin
                if (done_int_reg)
                    next_state = ENGINE_STRIDE_INDEX_GEN_DONE;
                else if (fifo_request_signals_out_int.prog_full | pause_in_reg)
                    next_state = ENGINE_STRIDE_INDEX_GEN_PAUSE_TRANS;
                else
                    next_state = ENGINE_STRIDE_INDEX_GEN_BUSY;
            end
            ENGINE_STRIDE_INDEX_GEN_PAUSE_TRANS : begin
                next_state = ENGINE_STRIDE_INDEX_GEN_PAUSE;
            end
            ENGINE_STRIDE_INDEX_GEN_PAUSE : begin
                if (~fifo_request_signals_out_int.prog_full & ~pause_in_reg)
                    next_state = ENGINE_STRIDE_INDEX_GEN_BUSY_TRANS;
                else
                    next_state = ENGINE_STRIDE_INDEX_GEN_PAUSE;
            end
            ENGINE_STRIDE_INDEX_GEN_DONE : begin
                next_state = ENGINE_STRIDE_INDEX_GEN_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_STRIDE_INDEX_GEN_RESET : begin
                done_int_reg               <= 1'b1;
                ready_out_reg              <= 1'b0;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b0;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                counter_load_value         <= 0;
                counter_stride_value       <= 0;
                fifo_request_din_reg.valid <= 1'b0;
            end
            ENGINE_STRIDE_INDEX_GEN_IDLE : begin
                done_int_reg               <= 1'b1;
                ready_out_reg              <= 1'b1;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                counter_load_value         <= 0;
                counter_stride_value       <= 0;
                fifo_request_din_reg.valid <= 1'b0;
            end
            ENGINE_STRIDE_INDEX_GEN_SETUP : begin
                done_int_reg               <= 1'b0;
                ready_out_reg              <= 1'b0;
                done_out_reg               <= 1'b0;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b1;
                counter_incr               <= configuration_reg.payload.param.increment;
                counter_decr               <= configuration_reg.payload.param.decrement;
                counter_load_value         <= configuration_reg.payload.param.index_start;
                counter_stride_value       <= configuration_reg.payload.param.stride;
                fifo_request_din_reg.valid <= 1'b0;
            end
            ENGINE_STRIDE_INDEX_GEN_START : begin
                done_int_reg               <= 1'b0;
                ready_out_reg              <= 1'b0;
                done_out_reg               <= 1'b0;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
                counter_incr               <= configuration_reg.payload.param.increment;
                counter_decr               <= configuration_reg.payload.param.decrement;
                fifo_request_din_reg.valid <= 1'b0;
            end
            ENGINE_STRIDE_INDEX_GEN_PAUSE_TRANS : begin
                done_int_reg               <= 1'b0;
                ready_out_reg              <= 1'b0;
                done_out_reg               <= 1'b0;
                counter_enable             <= 1'b0;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                fifo_request_din_reg.valid <= 1'b1;
            end
            ENGINE_STRIDE_INDEX_GEN_BUSY : begin
                if((counter_count >= configuration_reg.payload.param.index_end)) begin
                    done_int_reg               <= 1'b1;
                    counter_incr               <= 1'b0;
                    counter_decr               <= 1'b0;
                    fifo_request_din_reg.valid <= 1'b0;
                end
                else begin
                    done_int_reg               <= 1'b0;
                    counter_enable             <= 1'b1;
                    counter_incr               <= configuration_reg.payload.param.increment;
                    counter_decr               <= configuration_reg.payload.param.decrement;
                    fifo_request_din_reg.valid <= 1'b1;
                end
                ready_out_reg  <= 1'b0;
                done_out_reg   <= 1'b0;
                counter_enable <= 1'b1;
                counter_load   <= 1'b0;
            end
            ENGINE_STRIDE_INDEX_GEN_BUSY_TRANS : begin
                if((counter_count >= configuration_reg.payload.param.index_end)) begin
                    done_int_reg               <= 1'b1;
                    counter_incr               <= 1'b0;
                    counter_decr               <= 1'b0;
                    fifo_request_din_reg.valid <= 1'b0;
                end
                else begin
                    done_int_reg               <= 1'b0;
                    counter_enable             <= 1'b1;
                    counter_incr               <= configuration_reg.payload.param.increment;
                    counter_decr               <= configuration_reg.payload.param.decrement;
                    fifo_request_din_reg.valid <= 1'b0;
                end
                ready_out_reg  <= 1'b0;
                done_out_reg   <= 1'b0;
                counter_enable <= 1'b1;
                counter_load   <= 1'b0;
            end
            ENGINE_STRIDE_INDEX_GEN_PAUSE : begin
                done_int_reg               <= 1'b0;
                ready_out_reg              <= 1'b0;
                done_out_reg               <= 1'b0;
                counter_enable             <= 1'b0;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                fifo_request_din_reg.valid <= 1'b0;
            end
            ENGINE_STRIDE_INDEX_GEN_DONE : begin
                done_int_reg               <= 1'b1;
                ready_out_reg              <= 1'b0;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                fifo_request_din_reg.valid <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    always_comb begin
        fifo_request_comb.payload.meta.route          = configuration_reg.payload.meta.route;
        fifo_request_comb.payload.meta.address.base   = configuration_reg.payload.param.index_start;
        fifo_request_comb.payload.meta.address.offset = counter_count << configuration_reg.payload.param.granularity;
        fifo_request_comb.payload.meta.type           = configuration_reg.payload.meta.type;
        fifo_request_comb.payload.data.field          = counter_count;
    end

    always_ff @(posedge ap_clk) begin
        fifo_request_din_reg.payload.meta <= fifo_request_comb.payload.meta;
        fifo_request_din_reg.payload.data <= fifo_request_comb.payload.data;
    end

    counter #(.C_WIDTH(COUNTER_WIDTH)) inst_counter (
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
// FIFO cache requests out fifo_814x16_MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy ;

    // Push
    assign fifo_request_signals_in_int.wr_en = fifo_request_din_reg.valid;
    assign fifo_request_din                  = fifo_request_din_reg.payload;

    // Pop
    assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
    assign request_out_int.valid             = fifo_request_signals_out_int.valid;
    assign request_out_int.payload           = fifo_request_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
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

endmodule : engine_stride_index_generator