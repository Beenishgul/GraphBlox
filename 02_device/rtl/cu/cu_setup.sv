// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cu_setup.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-08-28 16:06:34
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

module cu_setup #(
    parameter ID_CU            = 0                    ,
    parameter ID_BUNDLE        = 0                    ,
    parameter ID_LANE          = 0                    ,
    parameter ID_ENGINE        = 0                    ,
    parameter ID_MODULE        = 0                    ,
    parameter FIFO_WRITE_DEPTH = 32                   ,
    parameter PROG_THRESH      = 16                   ,
    parameter COUNTER_WIDTH    = CACHE_FRONTEND_DATA_W
) (
    // System Signals
    input  logic                  ap_clk                   ,
    input  logic                  areset                   ,
    input  logic                  cu_flush                 ,
    input  KernelDescriptor       descriptor_in            ,
    input  MemoryPacket           response_in              ,
    input  FIFOStateSignalsInput  fifo_response_signals_in ,
    output FIFOStateSignalsOutput fifo_response_signals_out,
    output MemoryPacket           request_out              ,
    input  FIFOStateSignalsInput  fifo_request_signals_in  ,
    output FIFOStateSignalsOutput fifo_request_signals_out ,
    output logic                  fifo_setup_signal        ,
    output logic                  done_out
);


// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_cu_setup   ;
    logic areset_serial_read;
    logic areset_fifo       ;
    logic areset_counter    ;

    logic counter_clear;
    logic counter_load ;

    logic            cu_flush_reg     ;
    logic            cu_flush_mode    ;
    KernelDescriptor descriptor_in_reg;
    MemoryPacket     response_in_reg  ;
    MemoryPacket     request_out_int  ;

// --------------------------------------------------------------------------------------
// Setup state machine signals
// --------------------------------------------------------------------------------------
    logic done_int_reg;
    logic done_out_int;
    logic done_out_reg;

    cu_setup_state current_state;
    cu_setup_state next_state   ;

// --------------------------------------------------------------------------------------
// Request FIFO OUTPUT
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_din             ;
    MemoryPacketPayload    fifo_request_dout            ;
    FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_signals_out_int ;
    logic                  fifo_request_setup_signal_int;

// --------------------------------------------------------------------------------------
// Response FIFO INPUT
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInput  fifo_response_signals_in_reg ;
    FIFOStateSignalsOutput fifo_response_signals_out_int;

// --------------------------------------------------------------------------------------
// Serial Read Engine Signals
// --------------------------------------------------------------------------------------
    CUSetupEngineConfiguration engine_cu_setup_configuration_in        ;
    CUSetupEngineConfiguration configuration_comb_program              ;
    CUSetupEngineConfiguration configuration_comb_flush                ;
    MemoryPacket               engine_cu_setup_request_out             ;
    FIFOStateSignalsOutput     engine_cu_setup_fifo_request_signals_out;
    FIFOStateSignalsInput      engine_cu_setup_fifo_request_signals_in ;
    FIFOStateSignalsInput      engine_cu_setup_fifo_request_signals_reg;
    logic                      engine_cu_setup_start_in                ;
    logic                      engine_cu_setup_pause_in                ;
    logic                      engine_cu_setup_ready_out               ;
    logic                      engine_cu_setup_done_out                ;

    logic engine_cu_setup_fifo_setup_signal;

    logic                     response_memory_counter_is_zero   ;
    logic [COUNTER_WIDTH-1:0] response_memory_counter_          ;
    logic [COUNTER_WIDTH-1:0] response_memory_counter_load_value;

    assign fifo_response_signals_out_int = 6'b010000;
    assign done_out_int                  = done_int_reg & fifo_request_signals_out_int.empty & response_memory_counter_is_zero;
// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_cu_setup    <= areset;
        areset_serial_read <= areset;
        areset_counter     <= areset;
        areset_fifo        <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_cu_setup) begin
            descriptor_in_reg.valid <= 0;
            cu_flush_reg            <= 1'b0;
        end
        else begin
            descriptor_in_reg.valid <= descriptor_in.valid;
            cu_flush_reg            <= cu_flush;
        end
    end

    always_ff @(posedge ap_clk) begin
        descriptor_in_reg.payload <= descriptor_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_cu_setup) begin
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
        if (areset_cu_setup) begin
            fifo_setup_signal <= 1'b1;
            request_out.valid <= 1'b0;
            done_out          <= 1'b0;
        end
        else begin
            fifo_setup_signal <= engine_cu_setup_fifo_setup_signal | fifo_request_setup_signal_int;
            request_out.valid <= request_out_int.valid;
            done_out          <= done_out_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_signals_out <= fifo_response_signals_out_int;
        fifo_request_signals_out  <= fifo_request_signals_out_int;
        request_out.payload       <= request_out_int.payload;
    end

// --------------------------------------------------------------------------------------
// SETUP State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_cu_setup)
            current_state <= CU_SETUP_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            CU_SETUP_RESET : begin
                next_state = CU_SETUP_IDLE;
            end
            CU_SETUP_IDLE : begin
                if(descriptor_in_reg.valid & (engine_cu_setup_done_out & engine_cu_setup_ready_out))
                    next_state = CU_SETUP_REQ_START;
                else
                    next_state = CU_SETUP_IDLE;
            end
            CU_SETUP_REQ_START : begin
                if(engine_cu_setup_done_out | engine_cu_setup_ready_out) begin
                    next_state = CU_SETUP_REQ_START;
                end else begin
                    next_state = CU_SETUP_REQ_BUSY;
                end
            end
            CU_SETUP_REQ_BUSY : begin
                if (done_int_reg)
                    next_state = CU_SETUP_REQ_DONE;
                else if (fifo_request_signals_out_int.prog_full)
                    next_state = CU_SETUP_REQ_PAUSE;
                else
                    next_state = CU_SETUP_REQ_BUSY;
            end
            CU_SETUP_REQ_PAUSE : begin
                if (~(fifo_request_signals_out_int.prog_full))
                    next_state = CU_SETUP_REQ_BUSY;
                else
                    next_state = CU_SETUP_REQ_PAUSE;
            end
            CU_SETUP_REQ_DONE : begin
                if (cu_flush_reg)
                    next_state = CU_SETUP_FLUSH_START;
                else
                    next_state = CU_SETUP_REQ_DONE;
            end
            CU_SETUP_FLUSH_START : begin
                if(engine_cu_setup_done_out | engine_cu_setup_ready_out) begin
                    next_state = CU_SETUP_FLUSH_START;
                end else begin
                    next_state = CU_SETUP_FLUSH_BUSY;
                end
            end
            CU_SETUP_FLUSH_BUSY : begin
                if (done_int_reg)
                    next_state = CU_SETUP_FLUSH_DONE;
                else if (fifo_request_signals_out_int.prog_full)
                    next_state = CU_SETUP_FLUSH_PAUSE;
                else
                    next_state = CU_SETUP_FLUSH_BUSY;
            end
            CU_SETUP_FLUSH_PAUSE : begin
                if (~(fifo_request_signals_out_int.prog_full))
                    next_state = CU_SETUP_FLUSH_BUSY;
                else
                    next_state = CU_SETUP_FLUSH_PAUSE;
            end
            CU_SETUP_FLUSH_DONE : begin
                    next_state = CU_SETUP_FLUSH_DONE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            CU_SETUP_RESET : begin
                done_int_reg                                   <= 1'b1;
                done_out_reg                                   <= 1'b1;
                cu_flush_mode                                  <= 1'b0;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b0;
                counter_clear                                  <= 1'b1;
                counter_load                                   <= 1'b0;
                response_memory_counter_load_value             <= 0;
            end
            CU_SETUP_IDLE : begin
                done_int_reg                                   <= 1'b0;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b0;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b0;
                counter_clear                                  <= 1'b1;
                counter_load                                   <= 1'b0;
                response_memory_counter_load_value             <= 0;
            end
            CU_SETUP_REQ_START : begin
                done_int_reg                                   <= 1'b0;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b0;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b1;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b1;
                counter_clear                                  <= 1'b0;
                counter_load                                   <= 1'b1;
                response_memory_counter_load_value             <= configuration_comb_program.payload.param.array_size;
            end
            CU_SETUP_REQ_BUSY : begin
                done_int_reg                                   <= engine_cu_setup_done_out & response_memory_counter_is_zero;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b0;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= ~fifo_request_signals_out_int.prog_full;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b1;
                counter_load                                   <= 1'b0;
            end
            CU_SETUP_REQ_PAUSE : begin
                done_int_reg                                   <= 1'b0;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b0;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b1;
                engine_cu_setup_configuration_in.valid         <= 1'b0;
            end
            CU_SETUP_REQ_DONE : begin
                done_int_reg                                   <= 1'b1;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b0;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b0;
                counter_clear                                  <= 1'b0;
                counter_load                                   <= 1'b0;
                response_memory_counter_load_value             <= 0;
            end
            CU_SETUP_FLUSH_START : begin
                done_int_reg                                   <= 1'b0;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b1;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b1;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b1;
                counter_clear                                  <= 1'b0;
                counter_load                                   <= 1'b1;
                response_memory_counter_load_value             <= configuration_comb_flush.payload.param.array_size;
            end
            CU_SETUP_FLUSH_BUSY : begin
                done_int_reg                                   <= engine_cu_setup_done_out & response_memory_counter_is_zero;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b1;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= ~fifo_request_signals_out_int.prog_full;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b1;
                counter_load                                   <= 1'b0;
            end
            CU_SETUP_FLUSH_PAUSE : begin
                done_int_reg                                   <= 1'b0;
                done_out_reg                                   <= 1'b0;
                cu_flush_mode                                  <= 1'b1;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b1;
                engine_cu_setup_configuration_in.valid         <= 1'b0;
            end
            CU_SETUP_FLUSH_DONE : begin
                done_int_reg                                   <= 1'b1;
                done_out_reg                                   <= 1'b1;
                cu_flush_mode                                  <= 1'b0;
                engine_cu_setup_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_cu_setup_start_in                       <= 1'b0;
                engine_cu_setup_pause_in                       <= 1'b0;
                engine_cu_setup_configuration_in.valid         <= 1'b0;
                counter_clear                                  <= 1'b0;
                counter_load                                   <= 1'b0;
                response_memory_counter_load_value             <= 0;
            end
        endcase
    end // always_ff @(posedge ap_clk)


// --------------------------------------------------------------------------------------
// Create Configuration Packet Program
// --------------------------------------------------------------------------------------
    assign configuration_comb_program.payload.param.increment              = 1'b1;
    assign configuration_comb_program.payload.param.decrement              = 1'b0;
    assign configuration_comb_program.payload.param.flush_mode             = 1'b0;
    assign configuration_comb_program.payload.param.array_pointer          = descriptor_in_reg.payload.buffer_0;
    assign configuration_comb_program.payload.param.array_size             = {1'b0,descriptor_in_reg.payload.buffer_9[CACHE_FRONTEND_DATA_W-1:1]};
    assign configuration_comb_program.payload.param.start_read             = 0;
    assign configuration_comb_program.payload.param.end_read               = {1'b0,descriptor_in_reg.payload.buffer_9[CACHE_FRONTEND_DATA_W-1:1]};
    assign configuration_comb_program.payload.param.stride                 = 1;
    assign configuration_comb_program.payload.param.granularity            = $clog2(CACHE_FRONTEND_DATA_W/8);
    assign configuration_comb_program.payload.meta.route.from.id_cu        = ID_CU;
    assign configuration_comb_program.payload.meta.route.from.id_bundle    = {CU_BUNDLE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.from.id_lane      = {CU_LANE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.from.id_engine    = {CU_ENGINE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.from.id_module    = 1;
    assign configuration_comb_program.payload.meta.route.from.id_buffer    = 0;
    assign configuration_comb_program.payload.meta.route.to.id_cu          = ID_CU;
    assign configuration_comb_program.payload.meta.route.to.id_bundle      = {CU_BUNDLE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.to.id_lane        = {CU_LANE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.to.id_engine      = {CU_ENGINE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.to.id_module      = 1; // routes to memory configuration modules in engines
    assign configuration_comb_program.payload.meta.route.to.id_buffer      = 0;
    assign configuration_comb_program.payload.meta.route.seq_src.id_cu     = ID_CU;
    assign configuration_comb_program.payload.meta.route.seq_src.id_bundle = {CU_BUNDLE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.seq_src.id_lane   = {CU_LANE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.seq_src.id_engine = {CU_ENGINE_COUNT_WIDTH_BITS{1'b1}};
    assign configuration_comb_program.payload.meta.route.seq_src.id_module = 1;
    assign configuration_comb_program.payload.meta.route.seq_src.id_buffer = 0;
    assign configuration_comb_program.payload.meta.route.seq_state         = SEQUENCE_INVALID;
    assign configuration_comb_program.payload.meta.route.hops              = CU_BUNDLE_COUNT_WIDTH_BITS;
    assign configuration_comb_program.payload.meta.address.base            = descriptor_in_reg.payload.buffer_0;
    assign configuration_comb_program.payload.meta.address.offset          = 0;
    assign configuration_comb_program.payload.meta.address.shift.amount    = $clog2(CACHE_FRONTEND_DATA_W/8);
    assign configuration_comb_program.payload.meta.address.shift.direction = 1'b1;
    assign configuration_comb_program.payload.meta.subclass.cmd            = CMD_MEM_READ;
    assign configuration_comb_program.payload.meta.subclass.buffer         = STRUCT_CU_SETUP;

// --------------------------------------------------------------------------------------
// Create Configuration Packet FLUSH
// --------------------------------------------------------------------------------------
    assign configuration_comb_flush.payload.param.increment              = 1'b1;
    assign configuration_comb_flush.payload.param.decrement              = 1'b0;
    assign configuration_comb_flush.payload.param.flush_mode             = 1'b1;
    assign configuration_comb_flush.payload.param.array_pointer          = descriptor_in_reg.payload.buffer_0;
    assign configuration_comb_flush.payload.param.array_size             = descriptor_in_reg.payload.buffer_9[M_AXI_MEMORY_ADDR_WIDTH-1:CACHE_FRONTEND_DATA_W] - {1'b0,descriptor_in_reg.payload.buffer_9[CACHE_FRONTEND_DATA_W-1:1]};
    assign configuration_comb_flush.payload.param.start_read             = {1'b0,descriptor_in_reg.payload.buffer_9[CACHE_FRONTEND_DATA_W-1:1]};
    assign configuration_comb_flush.payload.param.end_read               = descriptor_in_reg.payload.buffer_9[M_AXI_MEMORY_ADDR_WIDTH-1:CACHE_FRONTEND_DATA_W];
    assign configuration_comb_flush.payload.param.stride                 = 1;
    assign configuration_comb_flush.payload.param.granularity            = $clog2(CACHE_FRONTEND_DATA_W/8);
    assign configuration_comb_flush.payload.meta.route                   = 0;
    assign configuration_comb_flush.payload.meta.address.base            = descriptor_in_reg.payload.buffer_0;
    assign configuration_comb_flush.payload.meta.address.offset          = 0;
    assign configuration_comb_flush.payload.meta.address.shift.amount    = $clog2(CACHE_FRONTEND_DATA_W/8);
    assign configuration_comb_flush.payload.meta.address.shift.direction = 1'b1;
    assign configuration_comb_flush.payload.meta.subclass.cmd            = CMD_MEM_READ;
    assign configuration_comb_flush.payload.meta.subclass.buffer         = STRUCT_CU_FLUSH;

// --------------------------------------------------------------------------------------
// Create Configuration Packet
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(cu_flush_mode)
            engine_cu_setup_configuration_in.payload <= configuration_comb_flush.payload;
        else
            engine_cu_setup_configuration_in.payload <= configuration_comb_program.payload;
    end

// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    assign engine_cu_setup_fifo_request_signals_in = engine_cu_setup_fifo_request_signals_reg;

    engine_cu_setup #(.COUNTER_WIDTH(COUNTER_WIDTH)) inst_engine_cu_setup (
        .ap_clk                  (ap_clk                                  ),
        .areset                  (areset_serial_read                      ),
        .configuration_in        (engine_cu_setup_configuration_in        ),
        .request_out             (engine_cu_setup_request_out             ),
        .fifo_request_signals_in (engine_cu_setup_fifo_request_signals_in ),
        .fifo_request_signals_out(engine_cu_setup_fifo_request_signals_out),
        .fifo_setup_signal       (engine_cu_setup_fifo_setup_signal       ),
        .start_in                (engine_cu_setup_start_in                ),
        .pause_in                (engine_cu_setup_pause_in                ),
        .ready_out               (engine_cu_setup_ready_out               ),
        .done_out                (engine_cu_setup_done_out                )
    );

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
    counter #(.C_WIDTH(COUNTER_WIDTH)) inst_response_memory_counter (
        .ap_clk      (ap_clk                            ),
        .ap_clken    (1'b1                              ),
        .areset      (areset_counter  | counter_clear   ),
        .load        (counter_load                      ),
        .incr        (1'b0                              ),
        .decr        (response_in_reg.valid             ),
        .load_value  (response_memory_counter_load_value),
        .stride_value({{(COUNTER_WIDTH-1){1'b0}},{1'b1}}),
        .count       (response_memory_counter_          ),
        .is_zero     (response_memory_counter_is_zero   )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_signals_in_int.wr_en = engine_cu_setup_request_out.valid;
    assign fifo_request_din                  = engine_cu_setup_request_out.payload;

    // Pop
    assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
    assign request_out_int.valid             = fifo_request_signals_out_int.valid;
    assign request_out_int.payload           = fifo_request_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
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

endmodule : cu_setup