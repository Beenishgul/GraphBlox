// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_forward_data_generator.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-08-30 13:56:22
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
// CSR\_Index\_Generator
// ---------------------

// ### Input: array\_pointer, array\_size, offset, degree

// When reading the edge list of the Graph CSR structure, a sequence of
// Vertex-IDs is generated based on the edges\_index and the degree size of
// the processed vertex. The read engines can connect to the
// CSR\_Index\_Generator to acquire the neighbor IDs for further
// processing, in this scenario reading the data of the vertex neighbors.

// uint32_t *csrIndexGenerator(uint32_t indexStart, uint32_t indexEnd, uint32_t granularity)

module engine_forward_data_generator #(parameter
    ID_CU            = 0 ,
    ID_BUNDLE        = 0 ,
    ID_LANE          = 0 ,
    ID_ENGINE        = 0 ,
    ENGINES_CONFIG   = 0 ,
    FIFO_WRITE_DEPTH = 16,
    PROG_THRESH      = 8 ,
    PIPELINE_STAGES  = 2 ,
    COUNTER_WIDTH    = 32
) (
    // System Signals
    input  logic                 ap_clk                             ,
    input  logic                 areset                             ,
    input  KernelDescriptor      descriptor_in                      ,
    input  CSRIndexConfiguration configure_engine_in                ,
    input  FIFOStateSignalsInput fifo_configure_engine_in_signals_in,
    input  CSRIndexConfiguration configure_memory_in                ,
    input  FIFOStateSignalsInput fifo_configure_memory_in_signals_in,
    input  MemoryPacket          response_engine_in                 ,
    input  FIFOStateSignalsInput fifo_response_engine_in_signals_in ,
    output FIFOStateSignalsInput fifo_response_engine_in_signals_out,
    input  MemoryPacket          response_memory_in                 ,
    input  FIFOStateSignalsInput fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsInput fifo_response_memory_in_signals_out,
    output MemoryPacket          request_engine_out                 ,
    input  FIFOStateSignalsInput fifo_request_engine_out_signals_in ,
    output MemoryPacket          request_memory_out                 ,
    input  FIFOStateSignalsInput fifo_request_memory_out_signals_in ,
    output logic                 fifo_setup_signal                  ,
    output logic                 configure_memory_setup             ,
    output logic                 configure_engine_setup             ,
    output logic                 done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_generator;
    logic areset_counter  ;
    logic areset_fifo     ;

    KernelDescriptor descriptor_in_reg;

    CSRIndexConfiguration configure_memory_reg;
    CSRIndexConfiguration configure_engine_reg;
    MemoryPacket          request_out_int     ;

// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
    engine_csr_index_generator_state current_state;
    engine_csr_index_generator_state next_state   ;

    logic done_int_reg;
    logic done_out_reg;
// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_din             ;
    MemoryPacket           fifo_request_din_reg         ;
    MemoryPacketPayload    fifo_request_dout            ;
    MemoryPacket           fifo_request_comb            ;
    MemoryPacket           fifo_response_comb           ;
    FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_signals_out_int ;
    logic                  fifo_request_setup_signal_int;

    MemoryPacket response_engine_in_reg    ;
    MemoryPacket response_memory_in_reg    ;
    logic        configure_engine_setup_reg;
    logic        configure_memory_setup_reg;

    CSRIndexConfigurationParameters configure_engine_param_int;

    MemoryPacket request_engine_out_reg;
    MemoryPacket request_memory_out_reg;

    FIFOStateSignalsInput fifo_response_engine_in_signals_out_reg;
    FIFOStateSignalsInput fifo_response_memory_in_signals_out_reg;

    FIFOStateSignalsInput fifo_configure_engine_in_signals_in_reg;
    FIFOStateSignalsInput fifo_configure_memory_in_signals_in_reg;
    FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg ;
    FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg ;
    FIFOStateSignalsInput fifo_request_engine_out_signals_in_reg ;
    FIFOStateSignalsInput fifo_request_memory_out_signals_in_reg ;

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
        areset_generator <= areset;
        areset_counter   <= areset;
        areset_fifo      <= areset;
    end
// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
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
        if (areset_generator) begin
            fifo_configure_engine_in_signals_in_reg <= 0;
            fifo_configure_memory_in_signals_in_reg <= 0;
            fifo_response_engine_in_signals_in_reg  <= 0;
            fifo_response_memory_in_signals_in_reg  <= 0;
            fifo_request_engine_out_signals_in_reg  <= 0;
            fifo_request_memory_out_signals_in_reg  <= 0;
            response_engine_in_reg.valid            <= 1'b0;
            response_memory_in_reg.valid            <= 1'b0;
        end
        else begin
            fifo_configure_engine_in_signals_in_reg <= fifo_configure_engine_in_signals_in;
            fifo_configure_memory_in_signals_in_reg <= fifo_configure_memory_in_signals_in;
            fifo_response_engine_in_signals_in_reg  <= fifo_response_engine_in_signals_in;
            fifo_response_memory_in_signals_in_reg  <= fifo_response_memory_in_signals_in;
            fifo_request_engine_out_signals_in_reg  <= fifo_request_engine_out_signals_in;
            fifo_request_memory_out_signals_in_reg  <= fifo_request_memory_out_signals_in;
            response_engine_in_reg.valid            <= response_engine_in.valid;
            response_memory_in_reg.valid            <= response_memory_in.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_engine_in_reg.payload <= response_engine_in.payload;
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Configure Engine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            configure_engine_reg.valid <= 1'b0;
            configure_memory_reg.valid <= 1'b0;
        end
        else begin
            configure_engine_reg.valid <= configure_engine_in.valid;
            configure_memory_reg.valid <= configure_memory_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        configure_engine_reg.payload <= configure_engine_in.payload;
        configure_memory_reg.payload <= configure_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            fifo_setup_signal                   <= 1'b1;
            request_engine_out.valid            <= 1'b0;
            request_memory_out.valid            <= 1'b0;
            configure_memory_setup              <= 1'b0;
            configure_engine_setup              <= 1'b0;
            done_out                            <= 1'b0;
            fifo_response_engine_in_signals_out <= 0;
            fifo_response_memory_in_signals_out <= 0;
        end
        else begin
            fifo_setup_signal                   <= fifo_request_setup_signal_int;
            request_engine_out.valid            <= request_engine_out_reg.valid;
            request_memory_out.valid            <= request_memory_out_reg.valid;
            configure_memory_setup              <= configure_memory_setup_reg;
            configure_engine_setup              <= configure_engine_setup_reg;
            done_out                            <= done_out_reg;
            fifo_response_engine_in_signals_out <= fifo_response_engine_in_signals_out_reg;
            fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_engine_out.payload <= request_engine_out_reg.payload;
        request_memory_out.payload <= request_memory_out_reg.payload ;
    end

// --------------------------------------------------------------------------------------
// Serial Read Engine State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_generator)
            current_state <= ENGINE_CSR_INDEX_GEN_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            ENGINE_CSR_INDEX_GEN_RESET : begin
                next_state = ENGINE_CSR_INDEX_GEN_IDLE;
            end
            ENGINE_CSR_INDEX_GEN_IDLE : begin
                if(descriptor_in_reg.valid)
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_IDLE;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE : begin
                if(fifo_configure_memory_in_signals_in.rd_en)
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_TRANS : begin
                next_state = ENGINE_CSR_INDEX_GEN_SETUP_MEMORY;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY : begin
                if(configure_memory_reg.valid & configure_memory_reg.payload.param.mode_sequence) // (1) indirect mode (get count from other engines)
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE;
                else if(configure_memory_reg.valid & ~configure_memory_reg.payload.param.mode_sequence) // (0) direct mode (get count from memory)
                    next_state = ENGINE_CSR_INDEX_GEN_START_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_MEMORY;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE : begin
                if(fifo_configure_engine_in_signals_in.rd_en)
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_TRANS : begin
                next_state = ENGINE_CSR_INDEX_GEN_SETUP_ENGINE;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE : begin
                if(configure_engine_reg.valid) // (1) indirect mode (get count from other engines)
                    next_state = ENGINE_CSR_INDEX_GEN_START_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_ENGINE;
            end
            ENGINE_CSR_INDEX_GEN_START_TRANS : begin
                next_state = ENGINE_CSR_INDEX_GEN_START;
            end
            ENGINE_CSR_INDEX_GEN_START : begin
                next_state = ENGINE_CSR_INDEX_GEN_BUSY;
            end
            ENGINE_CSR_INDEX_GEN_BUSY_TRANS : begin
                next_state = ENGINE_CSR_INDEX_GEN_BUSY;
            end
            ENGINE_CSR_INDEX_GEN_BUSY : begin
                if (done_int_reg)
                    next_state = ENGINE_CSR_INDEX_GEN_DONE;
                else if (fifo_request_signals_out_int.prog_full)
                    next_state = ENGINE_CSR_INDEX_GEN_PAUSE_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_BUSY;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE_TRANS : begin
                next_state = ENGINE_CSR_INDEX_GEN_PAUSE;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE : begin
                if (~fifo_request_signals_out_int.prog_full)
                    next_state = ENGINE_CSR_INDEX_GEN_BUSY_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_PAUSE;
            end
            ENGINE_CSR_INDEX_GEN_DONE : begin
                if (configure_engine_param_int.mode_sequence)
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_CSR_INDEX_GEN_RESET : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b0;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                counter_load_value         <= 0;
                counter_stride_value       <= 0;
                fifo_request_din_reg.valid <= 1'b0;

                configure_memory_setup_reg <= 1'b0;
                configure_engine_setup_reg <= 1'b0;
                configure_engine_param_int <= 0;
            end
            ENGINE_CSR_INDEX_GEN_IDLE : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                counter_load_value         <= 0;
                counter_stride_value       <= 0;
                fifo_request_din_reg.valid <= 1'b0;

                configure_memory_setup_reg <= 1'b0;
                configure_engine_setup_reg <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                counter_load_value         <= 0;
                counter_stride_value       <= 0;
                fifo_request_din_reg.valid <= 1'b0;
                configure_memory_setup_reg <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_TRANS : begin
                configure_memory_setup_reg <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY : begin
                configure_memory_setup_reg <= 1'b0;
                configure_engine_param_int <= configure_memory_reg.payload.param;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
                counter_incr               <= 1'b0;
                counter_decr               <= 1'b0;
                counter_load_value         <= 0;
                counter_stride_value       <= 0;
                fifo_request_din_reg.valid <= 1'b0;
                configure_engine_setup_reg <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_TRANS : begin
                configure_engine_setup_reg <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE : begin
                configure_engine_setup_reg             <= 1'b0;
                configure_engine_param_int.index_start <= configure_engine_reg.payload.param.index_start;
                configure_engine_param_int.index_end   <= configure_engine_reg.payload.param.index_end;
            end
            ENGINE_CSR_INDEX_GEN_START_TRANS : begin
                done_int_reg         <= 1'b0;
                done_out_reg         <= 1'b0;
                counter_enable       <= 1'b1;
                counter_load         <= 1'b1;
                counter_incr         <= configure_engine_param_int.increment;
                counter_decr         <= configure_engine_param_int.decrement;
                counter_load_value   <= configure_engine_param_int.index_start;
                counter_stride_value <= configure_engine_param_int.stride;
            end
            ENGINE_CSR_INDEX_GEN_START : begin
                counter_enable <= 1'b1;
                counter_load   <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE_TRANS : begin
                done_int_reg               <= 1'b0;
                done_out_reg               <= 1'b0;
                counter_enable             <= 1'b0;
                counter_load               <= 1'b0;
                fifo_request_din_reg.valid <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_BUSY : begin
                if((counter_count >= configure_engine_param_int.index_end)) begin
                    done_int_reg               <= 1'b1;
                    counter_enable             <= 1'b0;
                    fifo_request_din_reg.valid <= 1'b0;
                end
                else begin
                    done_int_reg               <= 1'b0;
                    counter_enable             <= 1'b1;
                    fifo_request_din_reg.valid <= 1'b1;
                end
                done_out_reg <= 1'b0;
                counter_load <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_BUSY_TRANS : begin
                if((counter_count >= configure_engine_param_int.index_end)) begin
                    done_int_reg               <= 1'b1;
                    counter_enable             <= 1'b0;
                    fifo_request_din_reg.valid <= 1'b0;
                end
                else begin
                    done_int_reg               <= 1'b0;
                    counter_enable             <= 1'b1;
                    fifo_request_din_reg.valid <= 1'b0;
                end
                done_out_reg <= 1'b0;
                counter_load <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE : begin
                done_int_reg               <= 1'b0;
                done_out_reg               <= 1'b0;
                counter_enable             <= 1'b0;
                counter_load               <= 1'b0;
                fifo_request_din_reg.valid <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_DONE : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b1;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
                fifo_request_din_reg.valid <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    always_comb begin
        fifo_request_comb.payload.meta.route        = configure_memory_reg.payload.meta.route;
        fifo_request_comb.payload.meta.address.base = configure_engine_param_int.array_pointer;
        if(configure_memory_reg.payload.meta.address.shift.direction) begin
            fifo_request_comb.payload.meta.address.offset = counter_count << configure_memory_reg.payload.meta.address.shift.amount;
        end else begin
            fifo_request_comb.payload.meta.address.offset = counter_count >> configure_memory_reg.payload.meta.address.shift.amount;
        end

        fifo_request_comb.payload.meta.address.shift = configure_memory_reg.payload.meta.address.shift;
        fifo_request_comb.payload.meta.subclass      = configure_memory_reg.payload.meta.subclass;
        fifo_request_comb.payload.data.field[0]       = counter_count;
        fifo_request_comb.payload.data.field[1]       = counter_count;
        fifo_request_comb.payload.data.field[2]       = counter_count;
        fifo_request_comb.payload.data.field[3]       = counter_count;
    end

    always_ff @(posedge ap_clk) begin
        fifo_request_din_reg.payload <= fifo_request_comb.payload;
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
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequest (
        .clk        (ap_clk                                  ),
        .srst       (areset_fifo                             ),
        .din        (fifo_request_din                        ),
        .wr_en      (fifo_request_signals_in_int.wr_en       ),
        .rd_en      (fifo_request_signals_in_int.rd_en       ),
        .dout       (fifo_request_dout                       ),
        .full       (fifo_request_signals_out_int.full       ),
        .empty      (fifo_request_signals_out_int.empty      ),
        .valid      (fifo_request_signals_out_int.valid      ),
        .prog_full  (fifo_request_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_request_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_request_signals_out_int.rd_rst_busy)
    );

// --------------------------------------------------------------------------------------
// Generator FLow logic
// --------------------------------------------------------------------------------------
    always_comb begin
        fifo_response_comb.valid                     = response_memory_in_reg.valid;
        fifo_response_comb.payload.meta.route        = configure_memory_reg.payload.meta.route;
        fifo_response_comb.payload.meta.address.base = configure_engine_param_int.array_pointer;
        if(configure_memory_reg.payload.meta.address.shift.direction) begin
            fifo_response_comb.payload.meta.address.offset = response_memory_in_reg.payload.data.field[0] << configure_memory_reg.payload.meta.address.shift.amount;
        end else begin
            fifo_response_comb.payload.meta.address.offset = response_memory_in_reg.payload.data.field[0] >> configure_memory_reg.payload.meta.address.shift.amount;
        end
        fifo_response_comb.payload.meta.address.shift = configure_memory_reg.payload.meta.address.shift;
        fifo_response_comb.payload.meta.subclass      = configure_memory_reg.payload.meta.subclass;
        fifo_response_comb.payload.data               = response_memory_in_reg.payload.data;
    end



    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            fifo_request_signals_in_reg             <= 0;
            request_engine_out_reg                  <= 0;
            request_memory_out_reg                  <= 0;
            fifo_response_engine_in_signals_out_reg <= 0;
            fifo_response_memory_in_signals_out_reg <= 0;
        end
        else begin
            if(~configure_engine_param_int.mode_buffer) begin // (0) engine buffer (1) memory buffer
                fifo_request_signals_in_reg                   <= fifo_request_engine_out_signals_in_reg;
                fifo_response_engine_in_signals_out_reg.rd_en <= 1'b0;
                fifo_response_memory_in_signals_out_reg.rd_en <= 1'b0;
                request_engine_out_reg                        <= request_out_int;
                request_memory_out_reg                        <= 0;
            end
            else if(configure_engine_param_int.mode_buffer) begin // response from memory -> request engine
                fifo_request_signals_in_reg <= fifo_request_memory_out_signals_in_reg;
                request_memory_out_reg      <= request_out_int;

                fifo_response_engine_in_signals_out_reg.rd_en <= 1'b0;
                fifo_response_memory_in_signals_out_reg.rd_en <= ~fifo_request_engine_out_signals_in_reg.rd_en;
                request_engine_out_reg                        <= fifo_response_comb;
            end
        end
    end

endmodule : engine_forward_data_generator