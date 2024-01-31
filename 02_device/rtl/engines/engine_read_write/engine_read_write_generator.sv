// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_read_write_generator.sv
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

module engine_read_write_generator #(parameter
    ID_CU               = 0                    ,
    ID_BUNDLE           = 0                    ,
    ID_LANE             = 0                    ,
    ID_ENGINE           = 0                    ,
    ID_MODULE           = 1                    ,
    ENGINES_CONFIG      = 0                    ,
    FIFO_WRITE_DEPTH    = 16                   ,
    PROG_THRESH         = 8                    ,
    PIPELINE_STAGES     = 2                    ,
    COUNTER_WIDTH       = CACHE_FRONTEND_DATA_W,
    NUM_BACKTRACK_LANES = 4                    ,
    NUM_CHANNELS        = 2                    ,
    ENGINE_CAST_WIDTH   = 1                    ,
    NUM_BUNDLES         = 4
) (
    // System Signals
    input  logic                  ap_clk                                                                             ,
    input  logic                  areset                                                                             ,
    input  KernelDescriptor       descriptor_in                                                                      ,
    input  ReadWriteConfiguration configure_memory_in                                                                ,
    input  FIFOStateSignalsInput  fifo_configure_memory_in_signals_in                                                ,
    input  EnginePacket           response_engine_in                                                                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out                                                ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0],
    input  MemoryPacketResponse   response_memory_in                                                                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                                                ,
    output EnginePacket           request_engine_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out                                                ,
    output MemoryPacketRequest    request_memory_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                                                ,
    input  FIFOStateSignalsOutput fifo_request_memory_out_backtrack_signals_in[NUM_CHANNELS-1:0]                     ,
    output logic                  fifo_setup_signal                                                                  ,
    output logic                  configure_memory_setup                                                             ,
    output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_generator;
    logic areset_counter  ;
    logic areset_fifo     ;
    logic areset_kernel   ;

    KernelDescriptor descriptor_in_reg;

    logic                  configure_memory_setup_reg;
    ReadWriteConfiguration configure_memory_reg      ;
    ReadWriteConfiguration configure_engine_int      ;

    logic fifo_empty_int     ;
    logic fifo_empty_reg     ;
    logic cmd_stream_mode_pop;

// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
    engine_read_write_generator_state current_state;
    engine_read_write_generator_state next_state   ;

    logic done_out_reg;

    logic enter_gen_pause_int;
    logic exit_gen_pause_int ;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    EnginePacket         response_engine_in_reg                ;
    EnginePacket         request_engine_out_reg                ;
    EnginePacket         fifo_response_comb                    ;
    EnginePacketFull     generator_engine_request_engine_reg   ;
    EnginePacketFull     generator_engine_request_engine_reg_S2;
    EnginePacketFull     generator_engine_request_engine_reg_S3;
    EnginePacketFull     request_memory_out_reg                ;
    MemoryPacketResponse response_memory_in_reg                ;
    MemoryPacketResponse response_memory_in_reg_S2             ;

    FIFOStateSignalsInput fifo_configure_memory_in_signals_in_reg;
    FIFOStateSignalsInput fifo_request_engine_out_signals_in_reg ;
    FIFOStateSignalsInput fifo_request_memory_out_signals_in_reg ;
    FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg ;
    FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg ;

// --------------------------------------------------------------------------------------
// Generation Logic - read/write data [0-4] -> Gen
// --------------------------------------------------------------------------------------
    EnginePacketData         result_int ;
    PacketRequestDataAddress address_int;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
    EnginePacket                  response_engine_in_int                  ;
    EnginePacketPayload           fifo_response_engine_in_din             ;
    EnginePacketPayload           fifo_response_engine_in_dout            ;
    FIFOStateSignalsInputInternal fifo_response_engine_in_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_response_engine_in_signals_out_int ;
    logic                         fifo_response_engine_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
    EnginePacketFull              request_send_out_int              ;
    EnginePacketFullPayload       fifo_request_send_din             ;
    EnginePacketFullPayload       fifo_request_send_dout            ;
    FIFOStateSignalsInputInternal fifo_request_send_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_request_send_signals_out_int ;
    logic                         fifo_request_send_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO pending cache requests out fifo_oending_EnginePacket
// --------------------------------------------------------------------------------------
    EnginePacket                  request_pending_out_int              ;
    EnginePacketPayload           fifo_request_pending_din             ;
    EnginePacketPayload           fifo_request_pending_dout            ;
    FIFOStateSignalsInputInternal fifo_request_pending_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_request_pending_signals_out_int ;
    logic                         fifo_request_pending_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO commit cache requests out fifo_oending_EnginePacket
// --------------------------------------------------------------------------------------
    EnginePacket                  request_commit_out_int              ;
    EnginePacketPayload           fifo_request_commit_din             ;
    EnginePacketPayload           fifo_request_commit_dout            ;
    FIFOStateSignalsInputInternal fifo_request_commit_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_request_commit_signals_out_int ;
    logic                         fifo_request_commit_setup_signal_int;

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
    logic                     counter_load                      ;
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
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
    EnginePacketRouteAttributes engine_read_write_route;
// --------------------------------------------------------------------------------------
    assign engine_read_write_route.packet_destination        = 0;
    assign engine_read_write_route.sequence_source.id_cu     = 1 << ID_CU;
    assign engine_read_write_route.sequence_source.id_bundle = 1 << ID_BUNDLE;
    assign engine_read_write_route.sequence_source.id_lane   = 1 << ID_LANE;
    assign engine_read_write_route.sequence_source.id_engine = 1 << ID_ENGINE;
    assign engine_read_write_route.sequence_source.id_module = 1 << ID_MODULE;
    assign engine_read_write_route.sequence_state            = SEQUENCE_INVALID;
    assign engine_read_write_route.sequence_id               = 0;
    assign engine_read_write_route.hops                      = NUM_BUNDLES_WIDTH_BITS;
// --------------------------------------------------------------------------------------
    localparam             PULSE_HOLD           = 4;
    logic [PULSE_HOLD-1:0] cmd_in_flight_hold      ;
    logic                  cmd_in_flight_assert    ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_generator <= areset;
        areset_counter   <= areset;
        areset_fifo      <= areset;
        areset_kernel    <= areset;
        areset_backtrack <= areset;
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
            fifo_configure_memory_in_signals_in_reg <= 0;
            fifo_response_engine_in_signals_in_reg  <= 0;
            fifo_response_memory_in_signals_in_reg  <= 0;
            fifo_request_engine_out_signals_in_reg  <= 0;
            fifo_request_memory_out_signals_in_reg  <= 0;
            response_engine_in_reg.valid            <= 1'b0;
            response_memory_in_reg.valid            <= 1'b0;
        end
        else begin
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
            configure_memory_reg.valid <= 1'b0;
        end
        else begin
            configure_memory_reg.valid <= configure_memory_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        configure_memory_reg.payload <= configure_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            configure_memory_setup              <= 1'b0;
            done_out                            <= 1'b0;
            fifo_empty_reg                      <= 1'b1;
            fifo_request_engine_out_signals_out <= 2'b10;
            fifo_request_memory_out_signals_out <= 2'b10;
            fifo_response_engine_in_signals_out <= 2'b10;
            fifo_response_memory_in_signals_out <= 2'b10;
            fifo_setup_signal                   <= 1'b1;
            request_engine_out.valid            <= 1'b0;
            request_memory_out.valid            <= 1'b0;
        end
        else begin
            configure_memory_setup              <= configure_memory_setup_reg;
            done_out                            <= done_out_reg & response_memory_counter_is_zero & fifo_empty_reg;
            fifo_empty_reg                      <= fifo_empty_int;
            fifo_request_engine_out_signals_out <= map_internal_dual_fifo_signals_to_output_internal(fifo_request_pending_signals_out_int, fifo_request_commit_signals_out_int);
            fifo_request_memory_out_signals_out <= map_internal_fifo_signals_to_output(fifo_request_send_signals_out_int);
            fifo_response_engine_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_engine_in_signals_out_int);
            fifo_response_memory_in_signals_out <= map_internal_fifo_signals_to_output(fifo_request_commit_signals_out_int);
            fifo_setup_signal                   <= fifo_request_send_setup_signal_int | fifo_request_pending_setup_signal_int | fifo_request_commit_setup_signal_int | fifo_response_engine_in_setup_signal_int;
            request_engine_out.valid            <= request_engine_out_reg.valid;
            request_memory_out.valid            <= request_memory_out_reg.valid;
        end
    end

    assign fifo_empty_int = fifo_request_pending_signals_out_int.empty &  fifo_request_commit_signals_out_int.empty & fifo_request_send_signals_out_int.empty & fifo_response_engine_in_signals_out_int.empty;

    always_ff @(posedge ap_clk) begin
        request_engine_out.payload <= request_engine_out_reg.payload;
        request_memory_out.payload <= map_EnginePacket_to_MemoryRequestPacket(request_memory_out_reg.payload, engine_read_write_route.sequence_source);
    end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response EnginePacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_engine_in_setup_signal_int = fifo_response_engine_in_signals_out_int.wr_rst_busy | fifo_response_engine_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_engine_in_signals_in_int.wr_en = response_engine_in_reg.valid;
    assign fifo_response_engine_in_din                  = response_engine_in_reg.payload;

    // Pop
    assign fifo_response_engine_in_signals_in_int.rd_en = ~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en & ~fifo_request_send_signals_out_int.prog_full & ~cmd_stream_mode_pop & configure_engine_int.valid ;
    assign response_engine_in_int.valid                 = fifo_response_engine_in_signals_out_int.valid;
    assign response_engine_in_int.payload               = fifo_response_engine_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(EnginePacketPayload)),
        .READ_DATA_WIDTH ($bits(EnginePacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_EnginePacketResponseEngineInput (
        .clk        (ap_clk                                             ),
        .srst       (areset_fifo                                        ),
        .din        (fifo_response_engine_in_din                        ),
        .wr_en      (fifo_response_engine_in_signals_in_int.wr_en       ),
        .rd_en      (fifo_response_engine_in_signals_in_int.rd_en       ),
        .dout       (fifo_response_engine_in_dout                       ),
        .full       (fifo_response_engine_in_signals_out_int.full       ),
        .empty      (fifo_response_engine_in_signals_out_int.empty      ),
        .valid      (fifo_response_engine_in_signals_out_int.valid      ),
        .prog_full  (fifo_response_engine_in_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_response_engine_in_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_response_engine_in_signals_out_int.rd_rst_busy)
    );

// --------------------------------------------------------------------------------------
// Serial Read Engine State Machine
// --------------------------------------------------------------------------------------
    localparam BURST_LENGTH = 16;
// --------------------------------------------------------------------------------------
    assign enter_gen_pause_int = fifo_request_pending_signals_out_int.prog_full | fifo_request_send_signals_out_int.prog_full;
    assign exit_gen_pause_int  = fifo_request_pending_signals_out_int.empty & fifo_request_send_signals_out_int.empty & ~cmd_in_flight_assert;
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_generator)
            current_state <= ENGINE_READ_WRITE_GEN_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            ENGINE_READ_WRITE_GEN_RESET : begin
                next_state = ENGINE_READ_WRITE_GEN_IDLE;
            end
            ENGINE_READ_WRITE_GEN_IDLE : begin
                if(descriptor_in_reg.valid)
                    next_state = ENGINE_READ_WRITE_GEN_SETUP_MEMORY_IDLE;
                else
                    next_state = ENGINE_READ_WRITE_GEN_IDLE;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY_IDLE : begin
                if(fifo_configure_memory_in_signals_in_reg.rd_en)
                    next_state = ENGINE_READ_WRITE_GEN_SETUP_MEMORY_TRANS;
                else
                    next_state = ENGINE_READ_WRITE_GEN_SETUP_MEMORY_IDLE;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY_TRANS : begin
                next_state = ENGINE_READ_WRITE_GEN_SETUP_MEMORY;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY : begin
                if(configure_memory_reg.valid) // (0) direct mode (get count from memory)
                    next_state = ENGINE_READ_WRITE_GEN_START_TRANS;
                else
                    next_state = ENGINE_READ_WRITE_GEN_SETUP_MEMORY;
            end
            ENGINE_READ_WRITE_GEN_START_TRANS : begin
                next_state = ENGINE_READ_WRITE_GEN_START;
            end
            ENGINE_READ_WRITE_GEN_START : begin
                next_state = ENGINE_READ_WRITE_GEN_BUSY;
            end
            ENGINE_READ_WRITE_GEN_BUSY_TRANS : begin
                next_state = ENGINE_READ_WRITE_GEN_BUSY;
            end
            ENGINE_READ_WRITE_GEN_BUSY : begin
                if (enter_gen_pause_int)
                    next_state = ENGINE_READ_WRITE_GEN_PAUSE_TRANS;
                else
                    next_state = ENGINE_READ_WRITE_GEN_BUSY;
            end
            ENGINE_READ_WRITE_GEN_PAUSE_TRANS : begin
                next_state = ENGINE_READ_WRITE_GEN_PAUSE;
            end
            ENGINE_READ_WRITE_GEN_PAUSE : begin
                if (exit_gen_pause_int)
                    next_state = ENGINE_READ_WRITE_GEN_BUSY_TRANS;
                else
                    next_state = ENGINE_READ_WRITE_GEN_PAUSE;
            end
            default : begin
                next_state = ENGINE_READ_WRITE_GEN_RESET;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_READ_WRITE_GEN_RESET : begin
                done_out_reg                       <= 1'b1;
                configure_memory_setup_reg         <= 1'b0;
                configure_engine_int.valid         <= 1'b0;
                counter_load                       <= 1'b0;
                response_memory_counter_load_value <= 0;
                cmd_stream_mode_pop                <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_IDLE : begin
                done_out_reg                       <= 1'b0;
                configure_memory_setup_reg         <= 1'b0;
                counter_load                       <= 1'b0;
                response_memory_counter_load_value <= 0;
                cmd_stream_mode_pop                <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY_IDLE : begin
                done_out_reg                       <= 1'b0;
                configure_memory_setup_reg         <= 1'b0;
                counter_load                       <= 1'b0;
                response_memory_counter_load_value <= 0;
                cmd_stream_mode_pop                <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY_TRANS : begin
                configure_memory_setup_reg <= 1'b1;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY : begin
                configure_memory_setup_reg <= 1'b0;
                configure_engine_int.valid <= 1'b0;
                if(configure_memory_reg.valid)
                    configure_engine_int <= configure_memory_reg;
            end
            ENGINE_READ_WRITE_GEN_START_TRANS : begin
                done_out_reg               <= 1'b0;
                configure_engine_int.valid <= 1'b1;
                counter_load               <= 1'b1;
                cmd_stream_mode_pop        <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_START : begin
                done_out_reg               <= 1'b0;
                configure_engine_int.valid <= 1'b1;
                counter_load               <= 1'b0;
                cmd_stream_mode_pop        <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_PAUSE_TRANS : begin
                done_out_reg        <= 1'b0;
                counter_load        <= 1'b0;
                cmd_stream_mode_pop <= 1'b1;
            end
            ENGINE_READ_WRITE_GEN_BUSY : begin
                done_out_reg        <= 1'b1;
                counter_load        <= 1'b0;
                cmd_stream_mode_pop <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_BUSY_TRANS : begin
                done_out_reg        <= 1'b0;
                counter_load        <= 1'b0;
                cmd_stream_mode_pop <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_PAUSE : begin
                done_out_reg        <= 1'b0;
                counter_load        <= 1'b0;
                cmd_stream_mode_pop <= 1'b1;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
    counter #(.C_WIDTH(COUNTER_WIDTH)) inst_response_memory_counter (
        .ap_clk      (ap_clk                            ),
        .ap_clken    (1'b1                              ),
        .areset      (areset_counter                    ),
        .load        (counter_load                      ),
        .incr        (request_memory_out_reg.valid      ),
        .decr        (request_engine_out_reg.valid      ),
        .load_value  (response_memory_counter_load_value),
        .stride_value({{(COUNTER_WIDTH-1){1'b0}},{1'b1}}),
        .count       (response_memory_counter_          ),
        .is_zero     (response_memory_counter_is_zero   )
    );

// --------------------------------------------------------------------------------------
// Generation Logic - Read/Write data [0-4] -> Gen
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        generator_engine_request_engine_reg.valid                                 <= response_engine_in_int.valid;
        generator_engine_request_engine_reg.payload.data                          <= 0;
        generator_engine_request_engine_reg.payload.meta.address                  <= 0;
        generator_engine_request_engine_reg.payload.meta.route.packet_destination <= configure_memory_reg.payload.meta.route.packet_destination;
        generator_engine_request_engine_reg.payload.meta.route.sequence_source    <= response_engine_in_int.payload.meta.route.sequence_source;
        generator_engine_request_engine_reg.payload.meta.route.sequence_state     <= response_engine_in_int.payload.meta.route.sequence_state;
        generator_engine_request_engine_reg.payload.meta.route.sequence_id        <= response_engine_in_int.payload.meta.route.sequence_id;
        generator_engine_request_engine_reg.payload.meta.route.hops               <= response_engine_in_int.payload.meta.route.hops;
        generator_engine_request_engine_reg.payload.meta.subclass                 <= configure_memory_reg.payload.meta.subclass;
    end

    always_ff @(posedge ap_clk) begin
        generator_engine_request_engine_reg_S2.valid                                 <= generator_engine_request_engine_reg.valid;
        generator_engine_request_engine_reg_S2.payload.data                          <= 0;
        generator_engine_request_engine_reg_S2.payload.meta.address                  <= 0;
        generator_engine_request_engine_reg_S2.payload.meta.route.packet_destination <= generator_engine_request_engine_reg.payload.meta.route.packet_destination;
        generator_engine_request_engine_reg_S2.payload.meta.route.sequence_source    <= generator_engine_request_engine_reg.payload.meta.route.sequence_source;
        generator_engine_request_engine_reg_S2.payload.meta.route.sequence_state     <= generator_engine_request_engine_reg.payload.meta.route.sequence_state;
        generator_engine_request_engine_reg_S2.payload.meta.route.sequence_id        <= generator_engine_request_engine_reg.payload.meta.route.sequence_id;
        generator_engine_request_engine_reg_S2.payload.meta.route.hops               <= generator_engine_request_engine_reg.payload.meta.route.hops;
        generator_engine_request_engine_reg_S2.payload.meta.subclass                 <= generator_engine_request_engine_reg.payload.meta.subclass;
    end

    always_ff @(posedge ap_clk) begin
        generator_engine_request_engine_reg_S3.valid                                 <= generator_engine_request_engine_reg_S2.valid;
        generator_engine_request_engine_reg_S3.payload.data                          <= result_int;
        generator_engine_request_engine_reg_S3.payload.meta.address                  <= address_int;
        generator_engine_request_engine_reg_S3.payload.meta.route.packet_destination <= generator_engine_request_engine_reg_S2.payload.meta.route.packet_destination;
        generator_engine_request_engine_reg_S3.payload.meta.route.sequence_source    <= generator_engine_request_engine_reg_S2.payload.meta.route.sequence_source;
        generator_engine_request_engine_reg_S3.payload.meta.route.sequence_state     <= generator_engine_request_engine_reg_S2.payload.meta.route.sequence_state;
        generator_engine_request_engine_reg_S3.payload.meta.route.sequence_id        <= generator_engine_request_engine_reg_S2.payload.meta.route.sequence_id;
        generator_engine_request_engine_reg_S3.payload.meta.route.hops               <= generator_engine_request_engine_reg_S2.payload.meta.route.hops;
        generator_engine_request_engine_reg_S3.payload.meta.subclass                 <= generator_engine_request_engine_reg_S2.payload.meta.subclass;
    end

// --------------------------------------------------------------------------------------
    engine_read_write_kernel inst_engine_read_write_kernel (
        .ap_clk                (ap_clk                             ),
        .areset                (areset_kernel                      ),
        .clear_in              (~(configure_engine_int.valid)      ),
        .config_params_valid_in(configure_engine_int.valid         ),
        .config_params_in      (configure_engine_int.payload.param ),
        .data_valid_in         (response_engine_in_int.valid       ),
        .data_in               (response_engine_in_int.payload.data),
        .address_out           (address_int                        ),
        .result_out            (result_int                         )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_814x16_EnginePacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_send_setup_signal_int = fifo_request_send_signals_out_int.wr_rst_busy | fifo_request_send_signals_out_int.rd_rst_busy ;

    // Push
    assign fifo_request_send_signals_in_int.wr_en = generator_engine_request_engine_reg_S3.valid;
    assign fifo_request_send_din                  = generator_engine_request_engine_reg_S3.payload;

    // Pop
    assign fifo_request_send_signals_in_int.rd_en = ~fifo_request_send_signals_out_int.empty & ~fifo_request_pending_signals_out_int.prog_full & ~fifo_request_commit_signals_out_int.prog_full & fifo_request_memory_out_signals_in_reg.rd_en & backtrack_fifo_request_memory_out_signals_out.rd_en;
    assign request_send_out_int.valid             = fifo_request_send_signals_out_int.valid;
    assign request_send_out_int.payload           = fifo_request_send_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(BURST_LENGTH * 2              ),
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
    assign cmd_in_flight_assert = |cmd_in_flight_hold;
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            cmd_in_flight_hold <= 0;
        end else begin
            cmd_in_flight_hold <= {cmd_in_flight_hold[PULSE_HOLD-2:0],(request_send_out_int.valid|response_engine_in_int.valid)};
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
    assign fifo_request_pending_signals_in_int.wr_en = request_memory_out_reg.valid;
    assign fifo_request_pending_din                  = map_EnginePacketFull_to_EnginePacket(request_memory_out_reg.payload);

    // Pop
    assign fifo_request_pending_signals_in_int.rd_en  = ~fifo_request_pending_signals_out_int.empty & response_memory_in_reg.valid;
    assign request_pending_out_int.valid              = fifo_request_pending_signals_out_int.valid;
    assign request_pending_out_int.payload.meta.route = fifo_request_pending_dout.meta.route;
    assign request_pending_out_int.payload.data       = map_MemoryResponsePacketData_to_EnginePacketData(response_memory_in_reg_S2.payload.data, fifo_request_pending_dout.data);

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(BURST_LENGTH * 2          ),
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

// --------------------------------------------------------------------------------------
// FIFO commit cache requests out fifo_oending_EnginePacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_commit_setup_signal_int = fifo_request_commit_signals_out_int.wr_rst_busy | fifo_request_commit_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_commit_signals_in_int.wr_en = request_pending_out_int.valid;
    assign fifo_request_commit_din                  = request_pending_out_int.payload;

    // Pop
    assign fifo_request_commit_signals_in_int.rd_en = ~fifo_request_commit_signals_out_int.empty & backtrack_fifo_response_engine_in_signals_out.rd_en & fifo_request_engine_out_signals_in_reg.rd_en;
    assign request_commit_out_int.valid             = fifo_request_commit_signals_out_int.valid;
    assign request_commit_out_int.payload           = fifo_request_commit_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(BURST_LENGTH * 4          ),
        .WRITE_DATA_WIDTH($bits(EnginePacketPayload)),
        .READ_DATA_WIDTH ($bits(EnginePacketPayload)),
        .PROG_THRESH     (BURST_LENGTH * 2          )
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
            request_engine_out_reg.valid <= 1'b0;
            request_memory_out_reg.valid <= 1'b0;
        end
        else begin
            request_engine_out_reg.valid <= fifo_response_comb.valid;
            request_memory_out_reg.valid <= request_send_out_int.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_memory_out_reg.payload <= request_send_out_int.payload;
        request_engine_out_reg.payload <= fifo_response_comb.payload;
    end

endmodule : engine_read_write_generator