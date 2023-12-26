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
    ID_CU            = 0                    ,
    ID_BUNDLE        = 0                    ,
    ID_LANE          = 0                    ,
    ID_ENGINE        = 0                    ,
    ID_MODULE        = 1                    ,
    ENGINES_CONFIG   = 0                    ,
    FIFO_WRITE_DEPTH = 16                   ,
    PROG_THRESH      = 8                    ,
    PIPELINE_STAGES  = 2                    ,
    COUNTER_WIDTH    = CACHE_FRONTEND_DATA_W
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  ReadWriteConfiguration configure_memory_in                ,
    input  FIFOStateSignalsInput  fifo_configure_memory_in_signals_in,
    input  MemoryPacket           response_engine_in                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output MemoryPacket           request_engine_out                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out,
    output MemoryPacket           request_memory_out                 ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out,
    output logic                  fifo_setup_signal                  ,
    output logic                  configure_memory_setup             ,
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

    ReadWriteConfiguration configure_memory_reg;
    ReadWriteConfiguration configure_engine_reg;
    MemoryPacket           request_out_int     ;

    logic fifo_empty_int;
    logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
    engine_read_write_generator_state current_state;
    engine_read_write_generator_state next_state   ;

    logic done_int_reg;
    logic done_out_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    MemoryPacketPayload           fifo_request_din             ;
    MemoryPacketPayload           fifo_request_dout            ;
    MemoryPacket                  fifo_response_comb           ;
    FIFOStateSignalsInput         fifo_request_signals_in_reg  ;
    FIFOStateSignalsInputInternal fifo_request_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_request_signals_out_int ;
    logic                         fifo_request_setup_signal_int;

    MemoryPacket response_engine_in_reg    ;
    MemoryPacket response_memory_in_reg    ;
    logic        configure_memory_setup_reg;

    logic                            configure_engine_param_valid;
    ReadWriteConfigurationParameters configure_engine_param_int  ;

    MemoryPacket generator_engine_request_engine_reg;
    MemoryPacket request_engine_out_reg             ;
    MemoryPacket request_memory_out_reg             ;

    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_reg;

    FIFOStateSignalsInput  fifo_configure_memory_in_signals_in_reg;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_reg ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg ;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_reg ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_reg ;
    FIFOStateSignalsOutput fifo_request_memory_out_signals_out_reg;
    FIFOStateSignalsOutput fifo_request_engine_out_signals_out_reg;

// --------------------------------------------------------------------------------------
// Generation Logic - read/write data [0-4] -> Gen
// --------------------------------------------------------------------------------------
    logic               read_write_response_engine_in_valid_reg    ;
    logic               read_write_response_engine_in_valid_flag   ;
    logic               read_write_response_engine_in_valid_flag_S2;
    MemoryPacketData    result_int                                 ;
    MemoryPacketAddress address_int                                ;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacket                  response_engine_in_int                  ;
    MemoryPacketPayload           fifo_response_engine_in_din             ;
    MemoryPacketPayload           fifo_response_engine_in_dout            ;
    FIFOStateSignalsInputInternal fifo_response_engine_in_signals_in_int  ;
    FIFOStateSignalsOutInternal   fifo_response_engine_in_signals_out_int ;
    logic                         fifo_response_engine_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO pending cache requests out fifo_oending_MemoryPacket
// --------------------------------------------------------------------------------------
    FIFOStateSignalsInputInternal fifo_request_pending_signals_in_int;
    FIFOStateSignalsOutInternal fifo_request_pending_signals_out_int;
    logic fifo_request_pending_setup_signal_int;
    MemoryPacket request_pending_out_int;
    MemoryPacketPayload fifo_request_pending_din;
    MemoryPacketPayload fifo_request_pending_dout;

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
    logic                     counter_load                      ;
    logic                     response_memory_counter_is_zero   ;
    logic [COUNTER_WIDTH-1:0] response_memory_counter_          ;
    logic [COUNTER_WIDTH-1:0] response_memory_counter_load_value;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_generator <= areset;
        areset_counter   <= areset;
        areset_fifo      <= areset;
        areset_kernel    <= areset;
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
            configure_engine_reg.valid <= 1'b0;
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
            fifo_request_engine_out_signals_out <= fifo_request_engine_out_signals_out_reg;
            fifo_request_memory_out_signals_out <= fifo_request_memory_out_signals_out_reg;
            fifo_response_engine_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_engine_in_signals_out_int);
            fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_reg;
            fifo_setup_signal                   <= fifo_request_setup_signal_int | fifo_response_engine_in_setup_signal_int;
            request_engine_out.valid            <= request_engine_out_reg.valid;
            request_memory_out.valid            <= request_memory_out_reg.valid;
        end
    end

    assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_engine_in_signals_out_int.empty;

    always_ff @(posedge ap_clk) begin
        request_engine_out.payload <= request_engine_out_reg.payload;
        request_memory_out.payload <= request_memory_out_reg.payload;
    end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_engine_in_setup_signal_int = fifo_response_engine_in_signals_out_int.wr_rst_busy | fifo_response_engine_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_engine_in_signals_in_int.wr_en = response_engine_in_reg.valid;
    assign fifo_response_engine_in_din                  = response_engine_in_reg.payload;

    // Pop
    assign fifo_response_engine_in_signals_in_int.rd_en = (~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en & ~read_write_response_engine_in_valid_reg & ~response_engine_in_int.valid & configure_engine_param_valid & ~fifo_request_signals_out_int.prog_full);
    assign response_engine_in_int.valid                 = fifo_response_engine_in_signals_out_int.valid;
    assign response_engine_in_int.payload               = fifo_response_engine_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketResponseEngineInput (
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
                if(fifo_configure_memory_in_signals_in.rd_en)
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
                if (done_int_reg)
                    next_state = ENGINE_READ_WRITE_GEN_DONE_TRANS;
                else if (fifo_request_signals_out_int.prog_full | fifo_request_pending_signals_out_int.prog_full)
                    next_state = ENGINE_READ_WRITE_GEN_PAUSE_TRANS;
                else
                    next_state = ENGINE_READ_WRITE_GEN_BUSY;
            end
            ENGINE_READ_WRITE_GEN_PAUSE_TRANS : begin
                next_state = ENGINE_READ_WRITE_GEN_PAUSE;
            end
            ENGINE_READ_WRITE_GEN_PAUSE : begin
                if (fifo_request_signals_out_int.empty && fifo_request_pending_signals_out_int.empty)
                    next_state = ENGINE_READ_WRITE_GEN_BUSY_TRANS;
                else
                    next_state = ENGINE_READ_WRITE_GEN_PAUSE;
            end
            ENGINE_READ_WRITE_GEN_DONE_TRANS : begin
                if (done_int_reg & (response_memory_counter_is_zero | ~configure_engine_param_int.mode_counter))
                    next_state = ENGINE_READ_WRITE_GEN_DONE;
                else
                    next_state = ENGINE_READ_WRITE_GEN_DONE_TRANS;
            end
            ENGINE_READ_WRITE_GEN_DONE : begin
                if (done_int_reg)
                    next_state = ENGINE_READ_WRITE_GEN_IDLE;
                else
                    next_state = ENGINE_READ_WRITE_GEN_DONE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_READ_WRITE_GEN_RESET : begin
                done_int_reg                 <= 1'b1;
                done_out_reg                 <= 1'b1;
                configure_memory_setup_reg   <= 1'b0;
                configure_engine_param_valid <= 1'b0;
                configure_engine_param_int   <= 0;

                counter_load                       <= 1'b0;
                response_memory_counter_load_value <= 0;
            end
            ENGINE_READ_WRITE_GEN_IDLE : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b0;
                configure_memory_setup_reg <= 1'b0;

                counter_load                       <= 1'b0;
                response_memory_counter_load_value <= 0;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY_IDLE : begin
                done_int_reg                       <= 1'b1;
                done_out_reg                       <= 1'b0;
                configure_memory_setup_reg         <= 1'b0;
                counter_load                       <= 1'b0;
                response_memory_counter_load_value <= 0;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY_TRANS : begin
                configure_memory_setup_reg <= 1'b1;
            end
            ENGINE_READ_WRITE_GEN_SETUP_MEMORY : begin
                configure_memory_setup_reg   <= 1'b0;
                configure_engine_param_valid <= 1'b0;
                if(configure_memory_reg.valid)
                    configure_engine_param_int <= configure_memory_reg.payload.param;
            end
            ENGINE_READ_WRITE_GEN_START_TRANS : begin
                done_int_reg                 <= 1'b0;
                done_out_reg                 <= 1'b0;
                configure_engine_param_valid <= 1'b1;

                counter_load <= 1'b1;
                // if(|configure_engine_param_int.index_end & ~configure_engine_param_int.mode_sequence) begin
                //     response_memory_counter_load_value <= configure_engine_param_int.index_end-1;
                // end
            end
            ENGINE_READ_WRITE_GEN_START : begin
                done_int_reg                 <= 1'b0;
                done_out_reg                 <= 1'b0;
                configure_engine_param_valid <= 1'b1;
                counter_load                 <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_PAUSE_TRANS : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b0;
                counter_load <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_BUSY : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b1;
                counter_load <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_BUSY_TRANS : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b0;
                counter_load <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_PAUSE : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b0;
                counter_load <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_DONE_TRANS : begin
                done_int_reg <= 1'b1;
                done_out_reg <= 1'b0;
                counter_load <= 1'b0;
            end
            ENGINE_READ_WRITE_GEN_DONE : begin
                done_int_reg                 <= 1'b1;
                done_out_reg                 <= 1'b1;
                configure_engine_param_valid <= 1'b0;
                configure_engine_param_int   <= 0;
                counter_load                 <= 1'b0;
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
    assign read_write_response_engine_in_valid_flag = read_write_response_engine_in_valid_reg;

    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            read_write_response_engine_in_valid_reg     <= 1'b0;
            read_write_response_engine_in_valid_flag_S2 <= 1'b0;
            generator_engine_request_engine_reg.valid   <= 1'b0;
        end
        else begin
            read_write_response_engine_in_valid_flag_S2 <= read_write_response_engine_in_valid_flag;
            generator_engine_request_engine_reg.valid   <= read_write_response_engine_in_valid_flag_S2;
            if(response_engine_in_int.valid & configure_engine_param_valid) begin
                read_write_response_engine_in_valid_reg <= 1'b1;
            end else begin
                if(read_write_response_engine_in_valid_flag)
                    read_write_response_engine_in_valid_reg <= 1'b0;
                else
                    read_write_response_engine_in_valid_reg <= read_write_response_engine_in_valid_reg;
            end
        end
    end

    always_ff @(posedge ap_clk) begin
        generator_engine_request_engine_reg.payload.data                      <= result_int;
        generator_engine_request_engine_reg.payload.meta.address              <= address_int;
        generator_engine_request_engine_reg.payload.meta.route.from.id_module <= 1 << ID_MODULE;
        generator_engine_request_engine_reg.payload.meta.route.from.id_cu     <= configure_memory_reg.payload.meta.route.from.id_cu ;
        generator_engine_request_engine_reg.payload.meta.route.from.id_bundle <= configure_memory_reg.payload.meta.route.from.id_bundle;
        generator_engine_request_engine_reg.payload.meta.route.from.id_lane   <= configure_memory_reg.payload.meta.route.from.id_lane;
        generator_engine_request_engine_reg.payload.meta.route.from.id_engine <= configure_memory_reg.payload.meta.route.from.id_engine;
        generator_engine_request_engine_reg.payload.meta.route.from.id_buffer <= configure_memory_reg.payload.meta.route.from.id_buffer;
        generator_engine_request_engine_reg.payload.meta.route.to             <= configure_memory_reg.payload.meta.route.to;
        generator_engine_request_engine_reg.payload.meta.route.seq_src        <= response_engine_in_int.payload.meta.route.seq_src;
        generator_engine_request_engine_reg.payload.meta.route.seq_state      <= response_engine_in_int.payload.meta.route.seq_state;
        generator_engine_request_engine_reg.payload.meta.route.seq_id         <= response_engine_in_int.payload.meta.route.seq_id;
        generator_engine_request_engine_reg.payload.meta.route.hops           <= response_engine_in_int.payload.meta.route.hops;
        generator_engine_request_engine_reg.payload.meta.subclass             <= configure_memory_reg.payload.meta.subclass;
    end

    engine_read_write_kernel inst_engine_read_write_kernel (
        .ap_clk                (ap_clk                             ),
        .areset                (areset_kernel                      ),
        .clear_in              (~(configure_engine_param_valid)    ),
        .config_params_valid_in(configure_engine_param_valid       ),
        .config_params_in      (configure_engine_param_int         ),
        .data_valid_in         (response_engine_in_int.valid       ),
        .data_in               (response_engine_in_int.payload.data),
        .address_out           (address_int                        ),
        .result_out            (result_int                         )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_814x16_MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy ;

    // Push
    assign fifo_request_signals_in_int.wr_en = generator_engine_request_engine_reg.valid;
    assign fifo_request_din                  = generator_engine_request_engine_reg.payload;

    // Pop
    assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en & fifo_request_engine_out_signals_in_reg.rd_en;
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

// --------------------------------------------------------------------------------------
// FIFO pending cache requests out fifo_oending_MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_pending_setup_signal_int = fifo_request_pending_signals_out_int.wr_rst_busy | fifo_request_pending_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_pending_signals_in_int.wr_en = request_memory_out_reg.valid;
    assign fifo_request_pending_din                  = request_memory_out_reg.payload;

    // Pop
    assign fifo_request_pending_signals_in_int.rd_en = ~fifo_request_pending_signals_out_int.empty & fifo_response_comb.valid;
    assign request_pending_out_int.valid             = fifo_request_pending_signals_out_int.valid;
    assign request_pending_out_int.payload           = fifo_request_pending_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketRequestPending (
        .clk        (ap_clk                                  ),
        .srst       (areset_fifo                             ),
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
// Generator FLow logic
// --------------------------------------------------------------------------------------
    assign fifo_response_comb.valid                     = response_memory_in_reg.valid;
    assign fifo_response_comb.payload.meta.route        = response_memory_in_reg.payload.meta.route;
    assign fifo_response_comb.payload.meta.address      = response_memory_in_reg.payload.meta.address;
    assign fifo_response_comb.payload.meta.subclass.cmd = CMD_ENGINE;
    assign fifo_response_comb.payload.data              = response_memory_in_reg.payload.data;

    always_comb begin
        if(response_memory_in_reg.payload.meta.route.to.id_module == 2'b01) begin
            fifo_response_comb.payload.meta.subclass.buffer = STRUCT_ENGINE_SETUP;
        end else begin
            fifo_response_comb.payload.meta.subclass.buffer = STRUCT_ENGINE_DATA;
        end
    end

    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            fifo_request_engine_out_signals_out_reg <= 2'b10;
            fifo_request_memory_out_signals_out_reg <= 2'b10;
            fifo_request_signals_in_reg             <= 0;
            fifo_response_memory_in_signals_out_reg <= 2'b10;
            request_engine_out_reg.valid            <= 1'b0;
            request_memory_out_reg.valid            <= 1'b0;
        end
        else begin
            fifo_request_engine_out_signals_out_reg           <= 2'b00;
            fifo_request_memory_out_signals_out_reg           <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
            fifo_request_signals_in_reg                       <= fifo_request_memory_out_signals_in_reg;
            fifo_response_memory_in_signals_out_reg.empty     <= 1'b0;
            fifo_response_memory_in_signals_out_reg.prog_full <= ~fifo_request_engine_out_signals_in_reg.rd_en;
            request_engine_out_reg.valid                      <= fifo_response_comb.valid;
            request_memory_out_reg.valid                      <= request_out_int.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_memory_out_reg.payload <= request_out_int.payload;
        request_engine_out_reg.payload <= fifo_response_comb.payload;
    end

endmodule : engine_read_write_generator