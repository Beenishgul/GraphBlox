// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_csr_index_generator.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

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

module engine_csr_index_generator #(parameter
    ID_CU               = 0                    ,
    ID_BUNDLE           = 0                    ,
    ID_LANE             = 0                    ,
    ID_ENGINE           = 0                    ,
    ID_MODULE           = 0                    ,
    ENGINES_CONFIG      = 0                    ,
    FIFO_WRITE_DEPTH    = 16                   ,
    PROG_THRESH         = 8                    ,
    PIPELINE_STAGES     = 2                    ,
    COUNTER_WIDTH       = CACHE_FRONTEND_DATA_W,
    NUM_BACKTRACK_LANES = 4                    ,
    NUM_CHANNELS        = 2                    ,
    NUM_CUS             = 1                    ,
    ENGINE_CAST_WIDTH   = 1                    ,
    NUM_BUNDLES         = 4
) (
    // System Signals
    input  logic                  ap_clk                                                                             ,
    input  logic                  areset                                                                             ,
    input  CSRIndexConfiguration  configure_engine_in                                                                ,
    input  FIFOStateSignalsInput  fifo_configure_engine_in_signals_in                                                ,
    input  CSRIndexConfiguration  configure_memory_in                                                                ,
    input  FIFOStateSignalsInput  fifo_configure_memory_in_signals_in                                                ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0],
    input  MemoryPacketResponse   response_memory_in                                                                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                                                ,
    input  ControlPacket          response_control_in                                                                ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in                                                ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out                                               ,
    output EnginePacket           request_engine_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out                                                ,
    output MemoryPacketRequest    request_memory_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                                                ,
    input  FIFOStateSignalsOutput fifo_request_memory_out_backtrack_signals_in[NUM_CHANNELS-1:0]                     ,
    output logic                  fifo_setup_signal                                                                  ,
    output logic                  configure_memory_setup                                                             ,
    output logic                  configure_engine_setup                                                             ,
    output logic                  done_out
);

    assign fifo_response_control_in_signals_out = 2'b10;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_generator;
    logic areset_counter  ;
    logic areset_fifo     ;

    CSRIndexConfiguration configure_engine_reg;
    CSRIndexConfiguration configure_memory_reg;

    logic            response_engine_in_break_flag_int;
    logic            response_engine_in_break_flag_reg;
    logic            response_engine_in_done_flag_reg ;
    EnginePacketFull request_out_int                  ;

    logic                                        fifo_empty_int     ;
    logic                                        fifo_empty_reg     ;
    logic [CU_PACKET_SEQUENCE_ID_WIDTH_BITS-1:0] sequence_id_counter;

    // ----------------------------------------------------------------------------------
    logic cmd_stream_read_int   ;
    logic cmd_stream_mode_int   ;
    logic cmd_stream_mode_pop   ;
    logic enter_stream_pause_int;
    logic exit_gen_pause_int    ;
    logic enter_gen_pause_int   ;
    logic cmd_done_mode_int     ;
    logic sequence_done_mode_int;

// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
    engine_csr_index_generator_state current_state;
    engine_csr_index_generator_state next_state   ;

    logic done_int_reg ;
    logic done_out_reg ;
    logic counter_clear;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInputInternal fifo_request_send_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_request_send_signals_out_int ;
    logic                         fifo_request_setup_signal_int     ;
    logic                         fifo_request_signals_out_reg_empty;

    EnginePacketFull        fifo_request_comb       ;
    EnginePacketFull        fifo_request_din_reg    ;
    EnginePacketFull        fifo_request_din_reg_S2 ;
    EnginePacketFull        fifo_request_dout_reg   ;
    EnginePacketFull        fifo_request_dout_reg_S2;
    EnginePacket            fifo_response_comb      ;
    EnginePacketFullPayload fifo_request_send_din   ;
    EnginePacketFullPayload fifo_request_send_dout  ;

    ControlPacket        response_control_in_reg   ;
    MemoryPacketResponse response_memory_in_reg    ;
    MemoryPacketResponse response_memory_in_reg_S2 ;
    logic                configure_engine_setup_reg;
    logic                configure_memory_setup_reg;

    CSRIndexConfiguration configure_engine_int ;
    CSRIndexConfiguration configure_engine_comb;

    EnginePacket     request_engine_out_reg;
    EnginePacketFull request_memory_out_reg;

    FIFOStateSignalsInput  fifo_configure_engine_in_signals_in_reg;
    FIFOStateSignalsInput  fifo_configure_memory_in_signals_in_reg;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_reg ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_reg ;
    FIFOStateSignalsInput  fifo_response_control_in_signals_in_reg;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_reg;
    FIFOStateSignalsOutput fifo_request_engine_out_signals_out_reg;
    FIFOStateSignalsOutput fifo_request_memory_out_signals_out_reg;

// --------------------------------------------------------------------------------------
// FIFO pending cache requests out fifo_oending_EnginePacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInputInternal fifo_request_pending_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_request_pending_signals_out_int ;
    logic                         fifo_request_pending_setup_signal_int;
    EnginePacket                  request_pending_out_int              ;
    EnginePacket                  request_pending_out_reg              ;
    EnginePacketPayload           fifo_request_pending_din             ;
    EnginePacketPayload           fifo_request_pending_dout            ;

// --------------------------------------------------------------------------------------
// FIFO commit cache requests out fifo_oending_EnginePacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInputInternal fifo_request_commit_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_request_commit_signals_out_int ;
    logic                         fifo_request_commit_setup_signal_int;
    EnginePacket                  request_commit_out_int              ;
    EnginePacketPayload           fifo_request_commit_din             ;
    EnginePacketPayload           fifo_request_commit_dout            ;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
    logic                     counter_decr        ;
    logic                     counter_enable      ;
    logic                     counter_incr        ;
    logic                     counter_is_zero     ;
    logic                     counter_load        ;
    logic [COUNTER_WIDTH-1:0] counter_count       ;
    logic [COUNTER_WIDTH-1:0] counter_load_value  ;
    logic [COUNTER_WIDTH-1:0] counter_stride_value;

    logic                     response_memory_counter_is_zero   ;
    logic [COUNTER_WIDTH-1:0] response_memory_counter_          ;
    logic [COUNTER_WIDTH-1:0] response_memory_counter_load_value;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
    logic                  areset_backtrack                                                                             ;
    logic                  backtrack_configure_route_valid                                                              ;
    PacketRouteAddress     backtrack_configure_route_in                                                                 ;
    FIFOStateSignalsOutput backtrack_fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0];
    FIFOStateSignalsInput  backtrack_fifo_response_engine_in_signals_out                                                ;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Engine i <- Channel i-1
// --------------------------------------------------------------------------------------
    logic                    backtrack_configure_address_valid                                       ;
    PacketRequestDataAddress backtrack_configure_address_in                                          ;
    FIFOStateSignalsOutput   backtrack_fifo_request_memory_out_backtrack_signals_in[NUM_CHANNELS-1:0];
    FIFOStateSignalsInput    backtrack_fifo_request_memory_out_signals_out                           ;

// --------------------------------------------------------------------------------------
// Handle bursty transaction (READ ONLY)
// --------------------------------------------------------------------------------------
    localparam                PULSE_HOLD           = 4;
    logic [   PULSE_HOLD-1:0] cmd_in_flight_hold      ;
    logic                     cmd_in_flight_assert    ;
    logic [COUNTER_WIDTH-1:0] page_start              ;
    logic [COUNTER_WIDTH-1:0] page_end                ;
    logic [COUNTER_WIDTH-1:0] burst_length_trunk      ;
    logic                     page_crossing_flag      ;
// --------------------------------------------------------------------------------------
// Burst crosses page boundary, split into two commands.
    logic [COUNTER_WIDTH-1:0] first_burst_length    ;
    logic [COUNTER_WIDTH-1:0] remaining_burst_length;
// --------------------------------------------------------------------------------------
// Delay the second burst by one cycle.
    type_memory_burst_length next_burst_length    ;
    type_memory_burst_length next_burst_length_reg;
    logic                    next_burst_flag      ;
    logic                    next_burst_flag_reg  ;
// --------------------------------------------------------------------------------------
    type_memory_burst_length  burst_length      ;
    logic                     burst_flag        ;
    logic                     mod_flag          ;
    logic                     burst_flag_reg    ;
    logic [COUNTER_WIDTH-1:0] counter_temp_value;
// --------------------------------------------------------------------------------------
    logic cmd_burst_active        ;
    logic cmd_done_packet_int     ;
    logic cmd_done_packet_send_reg;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
    EnginePacketRouteAttributes engine_csr_index_route;
// --------------------------------------------------------------------------------------
    assign engine_csr_index_route.packet_destination        = 0;
    assign engine_csr_index_route.sequence_source.id_cu     = 1 << ID_CU;
    assign engine_csr_index_route.sequence_source.id_bundle = 1 << ID_BUNDLE;
    assign engine_csr_index_route.sequence_source.id_lane   = 1 << ID_LANE;
    assign engine_csr_index_route.sequence_source.id_engine = 1 << ID_ENGINE;
    assign engine_csr_index_route.sequence_source.id_module = 1 << ID_MODULE;
    assign engine_csr_index_route.sequence_state            = SEQUENCE_INVALID;
    assign engine_csr_index_route.sequence_id               = 0;
    assign engine_csr_index_route.hops                      = NUM_BUNDLES_WIDTH_BITS;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_counter   <= areset;
        areset_fifo      <= areset;
        areset_generator <= areset;
        areset_backtrack <= areset;
    end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            fifo_configure_engine_in_signals_in_reg <= 0;
            fifo_configure_memory_in_signals_in_reg <= 0;
            fifo_request_engine_out_signals_in_reg  <= 0;
            fifo_request_memory_out_signals_in_reg  <= 0;
            fifo_response_control_in_signals_in_reg <= 0;
            fifo_response_memory_in_signals_in_reg  <= 0;
            response_control_in_reg.valid           <= 1'b0;
            response_memory_in_reg.valid            <= 1'b0;
        end
        else begin
            fifo_configure_engine_in_signals_in_reg <= fifo_configure_engine_in_signals_in;
            fifo_configure_memory_in_signals_in_reg <= fifo_configure_memory_in_signals_in;
            fifo_request_engine_out_signals_in_reg  <= fifo_request_engine_out_signals_in;
            fifo_request_memory_out_signals_in_reg  <= fifo_request_memory_out_signals_in;
            fifo_response_control_in_signals_in_reg <= fifo_response_control_in_signals_in;
            fifo_response_memory_in_signals_in_reg  <= fifo_response_memory_in_signals_in;
            response_control_in_reg.valid           <= response_control_in.valid;
            response_memory_in_reg.valid            <= response_memory_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_control_in_reg.payload <= response_control_in.payload;
        response_memory_in_reg.payload  <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Configure Engine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            configure_engine_reg.valid <= 1'b0;
            configure_memory_reg.valid <= 1'b0;
            sequence_id_counter        <= 0;
        end
        else begin
            configure_engine_reg.valid <= configure_engine_in.valid;
            configure_memory_reg.valid <= configure_memory_in.valid;

            if(configure_memory_reg.valid | configure_engine_reg.valid)
                sequence_id_counter <= sequence_id_counter + 1;
            else
                sequence_id_counter <= sequence_id_counter;
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
            configure_engine_setup              <= 1'b0;
            configure_memory_setup              <= 1'b0;
            done_out                            <= 1'b0;
            fifo_empty_reg                      <= 1'b1;
            fifo_response_memory_in_signals_out <= 2'b10;
            fifo_setup_signal                   <= 1'b1;
            request_engine_out.valid            <= 1'b0;
            request_memory_out.valid            <= 1'b0;
        end
        else begin
            configure_engine_setup              <= configure_engine_setup_reg;
            configure_memory_setup              <= configure_memory_setup_reg;
            done_out                            <= done_out_reg & fifo_empty_reg & response_memory_counter_is_zero;
            fifo_empty_reg                      <= fifo_empty_int;
            fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_reg;
            fifo_request_engine_out_signals_out <= fifo_request_engine_out_signals_out_reg;
            fifo_request_memory_out_signals_out <= fifo_request_memory_out_signals_out_reg;
            fifo_setup_signal                   <= fifo_request_setup_signal_int | fifo_request_pending_setup_signal_int | fifo_request_commit_setup_signal_int;
            request_engine_out.valid            <= request_engine_out_reg.valid;
            request_memory_out.valid            <= request_memory_out_reg.valid;
        end
    end

    assign fifo_empty_int = fifo_request_send_signals_out_int.empty & fifo_request_pending_signals_out_int.empty & fifo_request_commit_signals_out_int.empty;

    always_ff @(posedge ap_clk) begin
        request_engine_out.payload <= request_engine_out_reg.payload;
        request_memory_out.payload <= map_EnginePacket_to_MemoryRequestPacket(request_memory_out_reg.payload, engine_csr_index_route.sequence_source);
    end

// --------------------------------------------------------------------------------------
// Serial Read Engine State Machine
// --------------------------------------------------------------------------------------
    // localparam BURST_LENGTH = M01_AXI4_BE_DATA_W/M00_AXI4_FE_DATA_W;
    localparam BURST_LENGTH    = 16                         ;
    localparam BURST_SCALE     = 2                          ;
    localparam PAGE_SIZE_WORDS = 4096/(M00_AXI4_FE_DATA_W/8); // 4K page size in words
    localparam PAGE_SIZE_LOG2  = $clog2(PAGE_SIZE_WORDS)    ;
// --------------------------------------------------------------------------------------
    assign cmd_stream_read_int = configure_engine_int.payload.param.mode_buffer ? (fifo_request_memory_out_signals_in_reg.rd_en & backtrack_fifo_request_memory_out_signals_out.rd_en) : (fifo_request_engine_out_signals_in_reg.rd_en & backtrack_fifo_response_engine_in_signals_out.rd_en);
    assign enter_gen_pause_int = configure_engine_int.payload.param.mode_buffer ? fifo_request_send_signals_out_int.prog_full : fifo_request_send_signals_out_int.prog_full;
    assign exit_gen_pause_int  = configure_engine_int.payload.param.mode_buffer ? (fifo_request_commit_signals_out_int.empty & fifo_request_pending_signals_out_int.empty & fifo_request_send_signals_out_int.empty & ~cmd_in_flight_assert) : fifo_request_send_signals_out_int.empty & ~cmd_in_flight_assert;
// --------------------------------------------------------------------------------------
    assign cmd_stream_mode_int    = (configure_memory_reg.payload.meta.subclass.cmd == CMD_STREAM_READ) | (configure_engine_int.payload.meta.subclass.cmd == CMD_STREAM_WRITE);
    assign enter_stream_pause_int = ~(|((counter_count-counter_load_value)%BURST_LENGTH)) & cmd_stream_mode_int;
    assign cmd_burst_active       = cmd_stream_mode_int & fifo_request_din_reg.valid;
    assign cmd_done_packet_int    = (counter_count >= configure_engine_int.payload.param.index_end | (fifo_request_pending_signals_out_int.full | fifo_request_send_signals_out_int.full | fifo_request_commit_signals_out_int.full));
// --------------------------------------------------------------------------------------
    assign cmd_done_mode_int                 = done_int_reg & response_memory_counter_is_zero & response_engine_in_done_flag_reg & exit_gen_pause_int;
    assign sequence_done_mode_int            = (counter_count >= configure_engine_int.payload.param.index_end) | (~cmd_burst_active & response_engine_in_break_flag_reg & ~fifo_request_signals_out_reg_empty);
    assign response_engine_in_break_flag_int = (response_control_in_reg.payload.meta.route.sequence_state == SEQUENCE_BREAK) & response_control_in_reg.valid & (response_control_in_reg.payload.meta.route.sequence_id == sequence_id_counter);
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
                next_state = ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE;
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
                if(configure_engine_reg.valid) // (0) indirect mode (get count from other engines)
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
                    next_state = ENGINE_CSR_INDEX_GEN_DONE_TRANS;
                else if (enter_gen_pause_int)
                    next_state = ENGINE_CSR_INDEX_GEN_PAUSE_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_BUSY;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE_TRANS : begin
                if (done_int_reg)
                    next_state = ENGINE_CSR_INDEX_GEN_DONE_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_PAUSE;
            end
            ENGINE_CSR_INDEX_GEN_DONE_PACKET : begin
                if(fifo_request_pending_signals_out_int.full | fifo_request_send_signals_out_int.full | fifo_request_commit_signals_out_int.full)
                    next_state = ENGINE_CSR_INDEX_GEN_DONE_PACKET;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_DONE_TRANS;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE : begin
                if(response_engine_in_break_flag_reg & exit_gen_pause_int)
                    next_state = ENGINE_CSR_INDEX_GEN_DONE_PACKET;
                else if (~response_engine_in_break_flag_reg & exit_gen_pause_int)
                    next_state = ENGINE_CSR_INDEX_GEN_BUSY_TRANS;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_PAUSE;
            end
            ENGINE_CSR_INDEX_GEN_DONE_TRANS : begin
                if (configure_engine_int.payload.param.mode_sequence & cmd_done_mode_int)
                    next_state = ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE;
                else if (~configure_engine_int.payload.param.mode_sequence & cmd_done_mode_int)
                    next_state = ENGINE_CSR_INDEX_GEN_DONE;
                else
                    next_state = ENGINE_CSR_INDEX_GEN_DONE_TRANS;
            end
            ENGINE_CSR_INDEX_GEN_DONE : begin
                // if (done_int_reg)
                //     next_state = ENGINE_CSR_INDEX_GEN_IDLE;
                // else
                next_state = ENGINE_CSR_INDEX_GEN_DONE;
            end
            default : begin
                next_state = ENGINE_CSR_INDEX_GEN_RESET;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_CSR_INDEX_GEN_RESET : begin
                configure_engine_int.payload       <= 0;
                cmd_stream_mode_pop                <= 1'b0;
                configure_engine_int.valid         <= 1'b0;
                configure_engine_setup_reg         <= 1'b0;
                configure_memory_setup_reg         <= 1'b0;
                configure_memory_setup_reg         <= 1'b0;
                counter_clear                      <= 1'b1;
                counter_decr                       <= 1'b0;
                counter_enable                     <= 1'b0;
                counter_incr                       <= 1'b0;
                counter_load                       <= 1'b0;
                counter_load_value                 <= 0;
                counter_stride_value               <= 0;
                done_int_reg                       <= 1'b1;
                done_out_reg                       <= 1'b1;
                fifo_request_din_reg.valid         <= 1'b0;
                response_engine_in_break_flag_reg  <= 1'b0;
                response_engine_in_done_flag_reg   <= 1'b0;
                response_memory_counter_load_value <= 0;
                cmd_done_packet_send_reg           <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_IDLE : begin
                configure_engine_int.payload       <= 0;
                cmd_stream_mode_pop                <= 1'b0;
                configure_engine_int.valid         <= 1'b0;
                configure_engine_setup_reg         <= 1'b0;
                configure_memory_setup_reg         <= 1'b0;
                configure_memory_setup_reg         <= 1'b0;
                counter_clear                      <= 1'b0;
                counter_decr                       <= 1'b0;
                counter_enable                     <= 1'b1;
                counter_incr                       <= 1'b0;
                counter_load                       <= 1'b0;
                counter_load_value                 <= 0;
                counter_stride_value               <= 0;
                done_int_reg                       <= 1'b1;
                done_out_reg                       <= 1'b0;
                fifo_request_din_reg.valid         <= 1'b0;
                response_engine_in_break_flag_reg  <= 1'b0;
                response_engine_in_done_flag_reg   <= 1'b0;
                response_memory_counter_load_value <= 0;
                cmd_done_packet_send_reg           <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE : begin
                configure_memory_setup_reg         <= 1'b0;
                cmd_stream_mode_pop                <= 1'b0;
                counter_clear                      <= 1'b0;
                counter_decr                       <= 1'b0;
                counter_enable                     <= 1'b1;
                counter_incr                       <= 1'b0;
                counter_load                       <= 1'b0;
                counter_load_value                 <= 0;
                counter_stride_value               <= 0;
                done_int_reg                       <= 1'b1;
                done_out_reg                       <= 1'b0;
                fifo_request_din_reg.valid         <= 1'b0;
                response_engine_in_break_flag_reg  <= 1'b0;
                response_engine_in_done_flag_reg   <= 1'b0;
                response_memory_counter_load_value <= 0;
                cmd_done_packet_send_reg           <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_TRANS : begin
                configure_memory_setup_reg <= 1'b1;
                configure_engine_int       <= 0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_MEMORY : begin
                configure_memory_setup_reg <= 1'b0;
                if(configure_memory_reg.valid)
                    configure_engine_int <= configure_engine_comb;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE : begin
                configure_engine_int.valid         <= 1'b0;
                configure_engine_setup_reg         <= 1'b0;
                cmd_stream_mode_pop                <= 1'b0;
                counter_clear                      <= 1'b1;
                counter_decr                       <= 1'b0;
                counter_enable                     <= 1'b0;
                counter_incr                       <= 1'b0;
                counter_load                       <= 1'b0;
                counter_load_value                 <= 0;
                counter_stride_value               <= 0;
                done_int_reg                       <= 1'b1;
                done_out_reg                       <= 1'b0 | configure_engine_int.payload.param.mode_sequence;
                fifo_request_din_reg.valid         <= 1'b0;
                response_engine_in_break_flag_reg  <= 1'b0;
                response_engine_in_done_flag_reg   <= 1'b0;
                response_memory_counter_load_value <= 0;
                cmd_done_packet_send_reg           <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_TRANS : begin
                configure_engine_setup_reg <= 1'b1;
                counter_clear              <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_SETUP_ENGINE : begin
                configure_engine_setup_reg <= 1'b0;
                if(configure_engine_reg.valid) begin
                    configure_engine_int.payload.param.index_start <= configure_engine_reg.payload.param.index_start;
                    configure_engine_int.payload.param.index_end   <= configure_engine_reg.payload.param.index_end;
                    configure_engine_int.payload.param.array_size  <= configure_engine_reg.payload.param.array_size;
                    configure_engine_int.valid                     <= 1'b1;
                    configure_engine_int.payload.data              <= configure_engine_reg.payload.data;
                end
            end
            ENGINE_CSR_INDEX_GEN_START_TRANS : begin
                counter_clear        <= 1'b0;
                counter_decr         <= configure_engine_int.payload.param.decrement;
                counter_enable       <= 1'b1;
                counter_incr         <= configure_engine_int.payload.param.increment;
                counter_load         <= 1'b1;
                counter_load_value   <= configure_engine_int.payload.param.index_start;
                counter_stride_value <= configure_engine_int.payload.param.stride;
                done_int_reg         <= 1'b0;
                done_out_reg         <= 1'b0;

                response_memory_counter_load_value <= configure_engine_int.payload.param.array_size;

                if(~configure_engine_int.payload.param.mode_sequence) begin
                    configure_engine_int.valid <= 1'b1;
                end
            end
            ENGINE_CSR_INDEX_GEN_START : begin
                configure_engine_int.valid <= 1'b1;
                counter_clear              <= 1'b0;
                counter_enable             <= 1'b1;
                counter_load               <= 1'b0;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE_TRANS : begin
                if(sequence_done_mode_int) begin
                    done_int_reg               <= 1'b1;
                    counter_clear              <= 1'b1;
                    fifo_request_din_reg.valid <= 1'b0;
                end

                cmd_stream_mode_pop <= 1'b1;
                counter_enable      <= 1'b0;
                counter_load        <= 1'b0;
                done_out_reg        <= 1'b0;
                if(response_engine_in_break_flag_int)
                    response_engine_in_break_flag_reg <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_BUSY : begin
                if(sequence_done_mode_int) begin
                    done_int_reg               <= 1'b1;
                    counter_enable             <= 1'b0;
                    counter_clear              <= 1'b1;
                    fifo_request_din_reg.valid <= 1'b0;
                end
                else begin
                    done_int_reg               <= 1'b0;
                    counter_enable             <= 1'b1;
                    counter_clear              <= 1'b0;
                    fifo_request_din_reg.valid <= 1'b1;
                end
                done_out_reg               <= 1'b0;
                cmd_stream_mode_pop        <= 1'b0;
                counter_load               <= 1'b0;
                configure_engine_int.valid <= 1'b1;
                if(response_engine_in_break_flag_int)
                    response_engine_in_break_flag_reg <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_BUSY_TRANS : begin
                done_int_reg               <= 1'b0;
                cmd_stream_mode_pop        <= 1'b0;
                counter_enable             <= 1'b1;
                fifo_request_din_reg.valid <= 1'b0;
                if(sequence_done_mode_int)
                    counter_clear <= 1'b1;

                done_out_reg               <= 1'b0;
                counter_load               <= 1'b0;
                configure_engine_int.valid <= 1'b1;
                if(response_engine_in_break_flag_int)
                    response_engine_in_break_flag_reg <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_PAUSE : begin
                done_int_reg               <= 1'b0;
                configure_engine_int.valid <= 1'b1;
                if(sequence_done_mode_int)
                    counter_clear <= 1'b1;

                counter_enable             <= 1'b0;
                counter_load               <= 1'b0;
                done_out_reg               <= 1'b0;
                cmd_stream_mode_pop        <= 1'b1;
                fifo_request_din_reg.valid <= 1'b0;
                if(response_engine_in_break_flag_int)
                    response_engine_in_break_flag_reg <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_DONE_PACKET : begin
                if(cmd_done_packet_int) begin
                    fifo_request_din_reg.valid <= 1'b0;
                    counter_enable             <= 1'b0;
                    cmd_done_packet_send_reg   <= 1'b0;
                end
                else begin
                    counter_enable             <= 1'b1;
                    fifo_request_din_reg.valid <= 1'b1;
                    cmd_done_packet_send_reg   <= 1'b1;
                end
                counter_clear                     <= 1'b0;
                done_int_reg                      <= 1'b0;
                done_out_reg                      <= 1'b0;
                cmd_stream_mode_pop               <= 1'b1;
                counter_load                      <= 1'b0;
                configure_engine_int.valid        <= 1'b1;
                response_engine_in_break_flag_reg <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_DONE_TRANS : begin
                configure_engine_int.valid        <= 1'b1;
                counter_clear                     <= 1'b1;
                counter_enable                    <= 1'b0;
                counter_load                      <= 1'b0;
                done_int_reg                      <= 1'b1;
                done_out_reg                      <= 1'b0;
                cmd_stream_mode_pop               <= 1'b1;
                fifo_request_din_reg.valid        <= 1'b0;
                response_engine_in_break_flag_reg <= 1'b0;
                response_engine_in_done_flag_reg  <= 1'b1;
            end
            ENGINE_CSR_INDEX_GEN_DONE : begin
                configure_engine_int.valid        <= 1'b0;
                counter_clear                     <= 1'b1;
                counter_enable                    <= 1'b0;
                counter_load                      <= 1'b0;
                done_int_reg                      <= 1'b1;
                done_out_reg                      <= 1'b1;
                fifo_request_din_reg.valid        <= 1'b0;
                response_engine_in_break_flag_reg <= 1'b0;
                response_engine_in_done_flag_reg  <= 1'b0;
                cmd_done_packet_send_reg          <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    assign fifo_request_comb.valid                                 = 1'b0;
    assign fifo_request_comb.payload.meta.route.packet_destination = configure_engine_int.payload.meta.route.packet_destination;
    assign fifo_request_comb.payload.meta.route.hops               = engine_csr_index_route.hops;
    assign fifo_request_comb.payload.meta.route.sequence_source    = engine_csr_index_route.sequence_source;
    assign fifo_request_comb.payload.meta.route.sequence_state     = engine_csr_index_route.sequence_state;
    assign fifo_request_comb.payload.meta.route.sequence_id        = sequence_id_counter;
    assign fifo_request_comb.payload.meta.address.id_channel       = configure_engine_int.payload.meta.address.id_channel;
    assign fifo_request_comb.payload.meta.address.id_buffer        = configure_engine_int.payload.meta.address.id_buffer;
    assign fifo_request_comb.payload.meta.address.shift            = configure_engine_int.payload.meta.address.shift;
    assign fifo_request_comb.payload.meta.address.mode_cache       = configure_memory_reg.payload.meta.address.mode_cache;
    assign fifo_request_comb.payload.meta.address.burst_length     = 1;
    assign fifo_request_comb.payload.meta.subclass                 = configure_engine_int.payload.meta.subclass;
// --------------------------------------------------------------------------------------
    always_comb begin
        if(configure_engine_int.payload.meta.address.shift.direction) begin
            fifo_request_comb.payload.meta.address.offset = counter_count << configure_engine_int.payload.meta.address.shift.amount;
        end else begin
            fifo_request_comb.payload.meta.address.offset = counter_count >> configure_engine_int.payload.meta.address.shift.amount;
        end
    end
// --------------------------------------------------------------------------------------
    always_comb begin
        configure_engine_comb.valid   = 1'b0;
        configure_engine_comb.payload = configure_memory_reg.payload;
        if(configure_memory_reg.payload.param.mode_parallel) begin
            configure_engine_comb.payload.param.index_start = configure_memory_reg.payload.param.index_start + (ID_CU*configure_memory_reg.payload.param.array_size);
            configure_engine_comb.payload.param.index_end   = (ID_CU == (NUM_CUS-1)) ? configure_memory_reg.payload.param.index_end : configure_memory_reg.payload.param.index_start + ((ID_CU+1)*configure_memory_reg.payload.param.array_size);
            configure_engine_comb.payload.param.array_size  = (ID_CU == (NUM_CUS-1)) ? (configure_memory_reg.payload.param.index_end - (configure_memory_reg.payload.param.index_start + (ID_CU*configure_memory_reg.payload.param.array_size))): configure_memory_reg.payload.param.array_size;
        end
        if(configure_memory_reg.valid & configure_memory_reg.payload.param.mode_sequence) begin
            configure_engine_comb.valid = 1'b0;
        end else if(configure_memory_reg.valid & ~configure_memory_reg.payload.param.mode_sequence) begin
            configure_engine_comb.valid = 1'b1;
        end
    end
// --------------------------------------------------------------------------------------
    always_comb begin
        fifo_request_comb.payload.data = 0;
        if(configure_memory_reg.payload.param.mode_sequence) begin
            for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
                if(configure_memory_reg.payload.param.const_mask[i]) begin
                    fifo_request_comb.payload.data.field[i] = configure_engine_int.payload.param.const_value;
                end else  begin
                    if(|configure_memory_reg.payload.param.ops_mask[i])begin
                        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
                            if(configure_memory_reg.payload.param.ops_mask[i][j]) begin
                                fifo_request_comb.payload.data.field[i]       = configure_engine_int.payload.data.field[j];
                                fifo_request_comb.payload.data.field_state[i] = configure_engine_int.payload.data.field_state[j];
                            end
                        end
                    end else begin
                        fifo_request_comb.payload.data.field[i]       = counter_count;
                        fifo_request_comb.payload.data.field_state[i] = SEQUENCE_RUNNING;
                    end
                end
            end
        end else begin
            for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
                if(configure_memory_reg.payload.param.const_mask[i]) begin
                    fifo_request_comb.payload.data.field[i] = configure_memory_reg.payload.param.const_value;
                end else  begin
                    fifo_request_comb.payload.data.field[i] = counter_count;
                end
                fifo_request_comb.payload.data.field_state[i] = SEQUENCE_RUNNING;
            end
        end
    end
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        fifo_request_din_reg.payload <= fifo_request_comb.payload;
    end

    always_ff @(posedge ap_clk) begin
        fifo_request_din_reg_S2.valid   <= fifo_request_din_reg.valid;
        fifo_request_din_reg_S2.payload <= fifo_request_din_reg.payload;
    end

    counter #(.C_WIDTH(COUNTER_WIDTH)) inst_request_counter (
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
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
    counter #(.C_WIDTH(COUNTER_WIDTH)) inst_response_memory_counter (
        .ap_clk      (ap_clk                            ),
        .ap_clken    (1'b1                              ),
        .areset      (areset_counter  |  counter_clear  ),
        .load        (counter_load                      ),
        .incr        (1'b0                              ),
        .decr        (request_out_int.valid             ),
        .load_value  (response_memory_counter_load_value),
        .stride_value({{(COUNTER_WIDTH-1){1'b0}},{1'b1}}),
        .count       (response_memory_counter_          ),
        .is_zero     (response_memory_counter_is_zero   )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out EnginePacketRequest
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_setup_signal_int = fifo_request_send_signals_out_int.wr_rst_busy | fifo_request_send_signals_out_int.rd_rst_busy ;

    // Push
    assign fifo_request_send_signals_in_int.wr_en = fifo_request_din_reg_S2.valid;
    assign fifo_request_send_din                  = fifo_request_din_reg_S2.payload;

    // Pop
    assign fifo_request_send_signals_in_int.rd_en = ~fifo_request_send_signals_out_int.empty & cmd_stream_mode_pop & cmd_stream_read_int;
    assign request_out_int.valid                  = fifo_request_send_signals_out_int.valid;
    assign request_out_int.payload                = fifo_request_send_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(BURST_LENGTH * BURST_SCALE    ),
        .WRITE_DATA_WIDTH($bits(EnginePacketFullPayload)),
        .READ_DATA_WIDTH ($bits(EnginePacketFullPayload)),
        .PROG_THRESH     (5                             )
    ) inst_fifo_EnginePacketRequestSend (
        .clk        (ap_clk                                       ),
        .srst       (areset_fifo                                  ),
        .din        (fifo_request_send_din                        ),
        .wr_en      (fifo_request_send_signals_in_int.wr_en       ),
        .rd_en      (fifo_request_send_signals_in_int.rd_en       ),
        .dout       (fifo_request_send_dout                       ),
        .full       (fifo_request_send_signals_out_int.full       ),
        .empty      (fifo_request_send_signals_out_int.empty      ),
        .valid      (fifo_request_send_signals_out_int.valid      ),
        .prog_full  (fifo_request_send_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_request_send_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_request_send_signals_out_int.rd_rst_busy)
    );
// --------------------------------------------------------------------------------------
    always_ff  @(posedge ap_clk) begin
        fifo_request_dout_reg              <= request_out_int;
        fifo_request_signals_out_reg_empty <= fifo_request_send_signals_out_int.empty;

        fifo_request_dout_reg_S2.valid                                 <= fifo_request_dout_reg.valid;
        fifo_request_dout_reg_S2.payload.data                          <= fifo_request_dout_reg.payload.data;
        fifo_request_dout_reg_S2.payload.meta.subclass                 <= fifo_request_dout_reg.payload.meta.subclass;
        fifo_request_dout_reg_S2.payload.meta.route.packet_destination <= fifo_request_dout_reg.payload.meta.route.packet_destination;
        fifo_request_dout_reg_S2.payload.meta.route.hops               <= fifo_request_dout_reg.payload.meta.route.hops;
        fifo_request_dout_reg_S2.payload.meta.route.sequence_source    <= fifo_request_dout_reg.payload.meta.route.sequence_source;
        fifo_request_dout_reg_S2.payload.meta.route.sequence_id        <= fifo_request_dout_reg.payload.meta.route.sequence_id;
        fifo_request_dout_reg_S2.payload.meta.address.id_channel       <= fifo_request_dout_reg.payload.meta.address.id_channel;
        fifo_request_dout_reg_S2.payload.meta.address.mode_cache       <= fifo_request_dout_reg.payload.meta.address.mode_cache;
        fifo_request_dout_reg_S2.payload.meta.address.id_buffer        <= fifo_request_dout_reg.payload.meta.address.id_buffer;

        fifo_request_dout_reg_S2.payload.meta.address.offset <= fifo_request_dout_reg.payload.meta.address.offset;
        fifo_request_dout_reg_S2.payload.meta.address.shift  <= fifo_request_dout_reg.payload.meta.address.shift;

        burst_flag_reg        <= burst_flag|next_burst_flag_reg;
        next_burst_flag_reg   <= next_burst_flag;
        next_burst_length_reg <= next_burst_length;

        if (next_burst_flag_reg) begin
            fifo_request_dout_reg_S2.payload.meta.address.burst_length <= next_burst_length_reg;
            if(configure_engine_int.payload.meta.address.shift.direction) begin
                fifo_request_dout_reg_S2.payload.meta.address.offset <= fifo_request_dout_reg_S2.payload.meta.address.offset + (fifo_request_dout_reg_S2.payload.meta.address.burst_length  << configure_engine_int.payload.meta.address.shift.amount);
            end else begin
                fifo_request_dout_reg_S2.payload.meta.address.offset <= fifo_request_dout_reg_S2.payload.meta.address.offset + (fifo_request_dout_reg_S2.payload.meta.address.burst_length  >> configure_engine_int.payload.meta.address.shift.amount);
            end
        end else begin
            fifo_request_dout_reg_S2.payload.meta.address.burst_length <= burst_length;
            fifo_request_dout_reg_S2.payload.meta.address.offset       <= fifo_request_dout_reg.payload.meta.address.offset;
        end

        if(response_memory_counter_is_zero & fifo_request_signals_out_reg_empty) begin
            fifo_request_dout_reg_S2.payload.meta.route.sequence_state <= SEQUENCE_DONE;
            fifo_request_dout_reg_S2.payload.data.field_state[0]       <= SEQUENCE_DONE;
        end else begin
            fifo_request_dout_reg_S2.payload.meta.route.sequence_state <= SEQUENCE_RUNNING;
            fifo_request_dout_reg_S2.payload.data.field_state[0]       <= SEQUENCE_RUNNING;
        end
    end
// --------------------------------------------------------------------------------------
    always_comb begin
        burst_length       = 0;
        burst_flag         = 0;
        next_burst_flag    = 0;
        next_burst_length  = 0;
        counter_temp_value = fifo_request_dout_reg.valid ? fifo_request_dout_reg.payload.data.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] : 0;
        mod_flag           = (|counter_temp_value) ? |((counter_temp_value - counter_load_value) % BURST_LENGTH) : 1'b0;

        // Calculate the page start and end addresses for the counter value and burst length.
        page_start         = 0;
        page_end           = 0;
        burst_length_trunk = 0;
        page_crossing_flag = 0;

        first_burst_length     = 0;
        remaining_burst_length = 0;

        case (fifo_request_dout_reg.payload.meta.subclass.cmd)
            CMD_STREAM_READ : begin
                if(~mod_flag) begin

                    page_start         = counter_temp_value >> PAGE_SIZE_LOG2;
                    page_end           = (counter_temp_value + BURST_LENGTH - 1) >> PAGE_SIZE_LOG2;
                    burst_length_trunk = ((counter_temp_value+BURST_LENGTH) > configure_engine_int.payload.param.index_end) ? (configure_engine_int.payload.param.index_end - counter_temp_value) : BURST_LENGTH;
                    page_crossing_flag = (page_start != page_end);

                    burst_flag             = 1'b1;
                    first_burst_length     = min(burst_length_trunk, PAGE_SIZE_WORDS - (counter_temp_value % PAGE_SIZE_WORDS));
                    remaining_burst_length = burst_length_trunk - first_burst_length;

                    if(page_crossing_flag & ~cmd_done_packet_send_reg) begin
                        next_burst_flag   = 1'b1 & (|remaining_burst_length);
                        next_burst_length = remaining_burst_length[$bits(next_burst_length)-1:0];
                        burst_length      = first_burst_length[$bits(burst_length)-1:0];
                    end else begin
                        next_burst_flag   = 1'b0;
                        next_burst_length = 0;
                        burst_length      = ~cmd_done_packet_send_reg ? first_burst_length[$bits(burst_length)-1:0] : 1;
                    end
                end
                else begin
                    burst_flag             = 1'b0;
                    burst_length           = 1;
                    page_start             = 0;
                    page_end               = 0;
                    burst_length_trunk     = 0;
                    page_crossing_flag     = 0;
                    first_burst_length     = 0;
                    remaining_burst_length = 0;
                end
            end
            default : begin
                burst_flag             = 1'b1;
                burst_length           = 1;
                page_start             = 0;
                page_end               = 0;
                burst_length_trunk     = 0;
                page_crossing_flag     = 0;
                first_burst_length     = 0;
                remaining_burst_length = 0;
            end
        endcase
    end

// --------------------------------------------------------------------------------------
    assign cmd_in_flight_assert = (request_out_int.valid|fifo_request_din_reg.valid|response_memory_in_reg.valid) | (|cmd_in_flight_hold);
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            cmd_in_flight_hold <= 0;
        end else begin
            cmd_in_flight_hold <= {cmd_in_flight_hold[PULSE_HOLD-2:0],(request_out_int.valid|fifo_request_din_reg.valid|response_memory_in_reg.valid)};
        end
    end
// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
    assign backtrack_configure_route_valid                    = configure_engine_int.valid;
    assign backtrack_configure_route_in                       = configure_engine_int.payload.meta.route.packet_destination;
    assign backtrack_fifo_response_lanes_backtrack_signals_in = fifo_response_lanes_backtrack_signals_in;

    backtrack_fifo_lanes_response_signal #(
        .ID_CU              (ID_CU              ),
        .ID_BUNDLE          (ID_BUNDLE          ),
        .ID_LANE            (ID_LANE            ),
        .ID_ENGINE          (ID_ENGINE          ),
        .ID_MODULE          (2                  ),
        .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
        .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
        .NUM_BUNDLES        (NUM_BUNDLES        )
    ) inst_backtrack_fifo_lanes_response_signal (
        .ap_clk                                  (ap_clk                                            ),
        .areset                                  (areset_backtrack                                  ),
        .configure_route_valid                   (backtrack_configure_route_valid                   ),
        .configure_route_in                      (backtrack_configure_route_in                      ),
        .fifo_response_lanes_backtrack_signals_in(backtrack_fifo_response_lanes_backtrack_signals_in),
        .fifo_response_engine_in_signals_out     (backtrack_fifo_response_engine_in_signals_out     )
    );

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Engine i <- Channel i-1
// --------------------------------------------------------------------------------------
    assign backtrack_configure_address_valid                      = configure_engine_int.valid;
    assign backtrack_configure_address_in                         = configure_engine_int.payload.meta.address;
    assign backtrack_fifo_request_memory_out_backtrack_signals_in = fifo_request_memory_out_backtrack_signals_in;

    backtrack_fifo_request_memory_out_signals #(
        .ID_CU       (ID_CU       ),
        .ID_BUNDLE   (ID_BUNDLE   ),
        .ID_LANE     (ID_LANE     ),
        .ID_ENGINE   (ID_ENGINE   ),
        .ID_MODULE   (ID_MODULE   ),
        .NUM_CHANNELS(NUM_CHANNELS)
    ) inst_backtrack_fifo_request_memory_out_signals (
        .ap_clk                                      (ap_clk                                                ),
        .areset                                      (areset_backtrack                                      ),
        .configure_address_valid                     (backtrack_configure_address_valid                     ),
        .configure_address_in                        (backtrack_configure_address_in                        ),
        .fifo_request_memory_out_backtrack_signals_in(backtrack_fifo_request_memory_out_backtrack_signals_in),
        .fifo_request_memory_out_signals_out         (backtrack_fifo_request_memory_out_signals_out         )
    );

// --------------------------------------------------------------------------------------
// FIFO pending cache requests out fifo_oending_EnginePacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_pending_setup_signal_int = fifo_request_pending_signals_out_int.wr_rst_busy | fifo_request_pending_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_pending_signals_in_int.wr_en = fifo_request_dout_reg_S2.valid & configure_engine_int.payload.param.mode_buffer;
    assign fifo_request_pending_din                  = map_EnginePacketFull_to_EnginePacket(fifo_request_dout_reg_S2.payload);

    // Pop
    assign fifo_request_pending_signals_in_int.rd_en  = ~fifo_request_pending_signals_out_int.empty & response_memory_in_reg.valid;
    assign request_pending_out_int.valid              = fifo_request_pending_signals_out_int.valid;
    assign request_pending_out_int.payload.meta.route = fifo_request_pending_dout.meta.route;
    assign request_pending_out_int.payload.data       = map_MemoryResponsePacketData_to_EnginePacketData(response_memory_in_reg_S2.payload.data, fifo_request_pending_dout.data);

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(BURST_LENGTH * BURST_SCALE),
        .WRITE_DATA_WIDTH($bits(EnginePacketPayload)),
        .READ_DATA_WIDTH ($bits(EnginePacketPayload)),
        .PROG_THRESH     (5                         )
    ) inst_fifo_EnginePacketRequestPending (
        .clk        (ap_clk                                          ),
        .srst       (areset_fifo                                     ),
        .din        (fifo_request_pending_din                        ),
        .wr_en      (fifo_request_pending_signals_in_int.wr_en       ),
        .rd_en      (fifo_request_pending_signals_in_int.rd_en       ),
        .dout       (fifo_request_pending_dout                       ),
        .full       (fifo_request_pending_signals_out_int.full       ),
        .empty      (fifo_request_pending_signals_out_int.empty      ),
        .valid      (fifo_request_pending_signals_out_int.valid      ),
        .prog_full  (fifo_request_pending_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_request_pending_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_request_pending_signals_out_int.rd_rst_busy)
    );

    always_ff @(posedge ap_clk) begin
        request_pending_out_reg <= request_pending_out_int;
    end

// --------------------------------------------------------------------------------------
// FIFO commit cache requests out fifo_oending_EnginePacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_commit_setup_signal_int = fifo_request_commit_signals_out_int.wr_rst_busy | fifo_request_commit_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_commit_signals_in_int.wr_en = request_pending_out_int.valid;
    assign fifo_request_commit_din                  = request_pending_out_int.payload;

    // Pop
    assign fifo_request_commit_signals_in_int.rd_en = ~fifo_request_commit_signals_out_int.empty & fifo_request_engine_out_signals_in_reg.rd_en & backtrack_fifo_response_engine_in_signals_out.rd_en;
    assign request_commit_out_int.valid             = fifo_request_commit_signals_out_int.valid;
    assign request_commit_out_int.payload           = fifo_request_commit_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(BURST_LENGTH * BURST_SCALE * 2),
        .WRITE_DATA_WIDTH($bits(EnginePacketPayload)    ),
        .READ_DATA_WIDTH ($bits(EnginePacketPayload)    ),
        .PROG_THRESH     (BURST_LENGTH                  )
    ) inst_fifo_EnginePacketRequestCommit (
        .clk        (ap_clk                                         ),
        .srst       (areset_fifo                                    ),
        .din        (fifo_request_commit_din                        ),
        .wr_en      (fifo_request_commit_signals_in_int.wr_en       ),
        .rd_en      (fifo_request_commit_signals_in_int.rd_en       ),
        .dout       (fifo_request_commit_dout                       ),
        .full       (fifo_request_commit_signals_out_int.full       ),
        .empty      (fifo_request_commit_signals_out_int.empty      ),
        .valid      (fifo_request_commit_signals_out_int.valid      ),
        .prog_full  (fifo_request_commit_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_request_commit_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_request_commit_signals_out_int.rd_rst_busy)
    );

// --------------------------------------------------------------------------------------
// Generator FLow logic
// --------------------------------------------------------------------------------------
    assign fifo_response_comb.valid   = request_commit_out_int.valid;
    assign fifo_response_comb.payload = request_commit_out_int.payload;
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        response_memory_in_reg_S2 <= response_memory_in_reg;
    end
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            fifo_request_engine_out_signals_out_reg <= 2'b10;
            fifo_request_memory_out_signals_out_reg <= 2'b10;
            fifo_response_memory_in_signals_out_reg <= 2'b10;
            request_engine_out_reg.valid            <= 1'b0;
            request_memory_out_reg.valid            <= 1'b0;
        end
        else begin
            if(~configure_engine_int.payload.param.mode_buffer) begin // (0) engine buffer (1) memory buffer
                fifo_request_engine_out_signals_out_reg <= map_internal_fifo_signals_to_output(fifo_request_send_signals_out_int);
                fifo_request_memory_out_signals_out_reg <= 2'b10;
                fifo_response_memory_in_signals_out_reg <= 2'b10;
                request_engine_out_reg.valid            <= fifo_request_dout_reg_S2.valid;
                request_memory_out_reg.valid            <= 1'b0;
            end else if(configure_engine_int.payload.param.mode_buffer) begin // response from memory -> request engine
                fifo_request_engine_out_signals_out_reg <= map_internal_dual_fifo_signals_to_output_internal(fifo_request_pending_signals_out_int, fifo_request_commit_signals_out_int);
                fifo_request_memory_out_signals_out_reg <= map_internal_fifo_signals_to_output(fifo_request_send_signals_out_int);
                fifo_response_memory_in_signals_out_reg <= map_internal_fifo_signals_to_output(fifo_request_commit_signals_out_int);
                request_engine_out_reg.valid            <= fifo_response_comb.valid;
                request_memory_out_reg.valid            <= fifo_request_dout_reg_S2.valid & burst_flag_reg;
            end
        end
    end
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(~configure_engine_int.payload.param.mode_buffer) begin // (0) engine buffer (1) memory buffer
            request_engine_out_reg.payload <= map_EnginePacketFull_to_EnginePacket(fifo_request_dout_reg_S2.payload);
            request_memory_out_reg.payload <= 0;
        end else if(configure_engine_int.payload.param.mode_buffer) begin // response from memory -> request engine
            request_memory_out_reg.payload <= fifo_request_dout_reg_S2.payload;
            request_engine_out_reg.payload <= fifo_response_comb.payload;
        end
    end

endmodule : engine_csr_index_generator