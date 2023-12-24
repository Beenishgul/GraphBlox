// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_filter_cond_generator.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_filter_cond_generator #(parameter
    ID_CU              = 0               ,
    ID_BUNDLE          = 0               ,
    ID_LANE            = 0               ,
    ID_ENGINE          = 0               ,
    ID_MODULE          = 0               ,
    ENGINE_CAST_WIDTH  = 0               ,
    ENGINE_MERGE_WIDTH = 0               ,
    ENGINES_CONFIG     = 0               ,
    FIFO_WRITE_DEPTH   = 16              ,
    PROG_THRESH        = 8               ,
    PIPELINE_STAGES    = 2               ,
    COUNTER_WIDTH      = M_AXI4_FE_ADDR_W,
    NUM_LANES_MAX      = 4               ,
    NUM_BUNDLES_MAX    = 4
) (
    // System Signals
    input  logic                   ap_clk                                                     ,
    input  logic                   areset                                                     ,
    input  KernelDescriptor        descriptor_in                                              ,
    input  FilterCondConfiguration configure_memory_in                                        ,
    input  FIFOStateSignalsInput   fifo_configure_memory_in_signals_in                        ,
    input  MemoryPacket            response_engine_in                                         ,
    input  FIFOStateSignalsInput   fifo_response_engine_in_signals_in                         ,
    output FIFOStateSignalsOutput  fifo_response_engine_in_signals_out                        ,
    input  FIFOStateSignalsOutput  fifo_response_lanes_backtrack_signals_in[NUM_LANES_MAX-1:0],
    output MemoryPacket            request_engine_out                                         ,
    input  FIFOStateSignalsInput   fifo_request_engine_out_signals_in                         ,
    output FIFOStateSignalsOutput  fifo_request_engine_out_signals_out                        ,
    output MemoryPacket            request_control_out                                        ,
    input  FIFOStateSignalsInput   fifo_request_control_out_signals_in                        ,
    output FIFOStateSignalsOutput  fifo_request_control_out_signals_out                       ,
    output logic                   fifo_setup_signal                                          ,
    output logic                   configure_memory_setup                                     ,
    output logic                   done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_generator;
logic areset_kernel   ;
logic areset_counter  ;
logic areset_fifo     ;

KernelDescriptor descriptor_in_reg;

FilterCondConfiguration configure_memory_reg;

logic configure_memory_setup_reg;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
engine_filter_cond_generator_state current_state;
engine_filter_cond_generator_state next_state   ;

logic done_int_reg;
logic done_out_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
MemoryPacket          response_engine_in_int                ;
MemoryPacket          response_engine_in_reg                ;
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;

FilterCondConfiguration configure_engine_int;

FIFOStateSignalsInput fifo_configure_memory_in_signals_in_reg;
MemoryPacket          generator_engine_request_control_reg_S4;
MemoryPacket          generator_engine_request_engine_reg    ;
MemoryPacket          generator_engine_request_engine_reg_S2 ;
MemoryPacket          generator_engine_request_engine_reg_S3 ;
MemoryPacket          generator_engine_request_engine_reg_S4 ;
MemoryPacket          request_control_out_int                ;
MemoryPacket          request_engine_out_int                 ;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_response_engine_in_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_response_engine_in_signals_out_int ;
logic                         fifo_response_engine_in_setup_signal_int;
MemoryPacketPayload           fifo_response_engine_in_din             ;
MemoryPacketPayload           fifo_response_engine_in_dout            ;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_request_engine_out_signals_in_int  ;
FIFOStateSignalsInput         fifo_request_engine_out_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_request_engine_out_signals_out_int ;
logic                         fifo_request_engine_out_setup_signal_int;
MemoryPacketPayload           fifo_request_engine_out_din             ;
MemoryPacketPayload           fifo_request_engine_out_dout            ;

// --------------------------------------------------------------------------------------
// FIFO control OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInputInternal fifo_request_control_out_signals_in_int  ;
FIFOStateSignalsInput         fifo_request_control_out_signals_in_reg  ;
FIFOStateSignalsOutInternal   fifo_request_control_out_signals_out_int ;
logic                         fifo_request_control_out_setup_signal_int;
MemoryPacketPayload           fifo_request_control_out_din             ;
MemoryPacketPayload           fifo_request_control_out_dout            ;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
logic                  areset_backtrack                                                     ;
logic                  backtrack_configure_route_valid                                      ;
MemoryPacketArbitrate  backtrack_configure_route_in                                         ;
FIFOStateSignalsInput  backtrack_fifo_response_engine_in_signals_in                         ;
FIFOStateSignalsOutput backtrack_fifo_response_lanes_backtrack_signals_in[NUM_LANES_MAX-1:0];
FIFOStateSignalsInput  backtrack_fifo_response_engine_in_signals_out                        ;

// --------------------------------------------------------------------------------------
// Generation Logic - Filter data [0-4] -> Gen
// --------------------------------------------------------------------------------------
logic            break_done_int      ;
logic            break_flow_int      ;
logic            break_running_reg   ;
logic            conditional_flow_int;
logic            filter_flow_int     ;
logic            result_flag_int     ;
logic            done_flow_int       ;
logic            sequence_done_int   ;
logic            sequence_flow_int   ;
logic [1:0]      sequence_flow_reg   ;
MemoryPacketData result_data_int     ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_counter   <= areset;
    areset_fifo      <= areset;
    areset_generator <= areset;
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
// Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_generator) begin
        fifo_configure_memory_in_signals_in_reg <= 0;
        fifo_request_control_out_signals_in_reg <= 0;
        fifo_request_engine_out_signals_in_reg  <= 0;
    end
    else begin
        fifo_configure_memory_in_signals_in_reg <= fifo_configure_memory_in_signals_in;
        fifo_request_control_out_signals_in_reg <= fifo_request_control_out_signals_in;
        fifo_request_engine_out_signals_in_reg  <= fifo_request_engine_out_signals_in;
    end
end

always_ff @(posedge ap_clk) begin
    if (areset_generator) begin
        fifo_response_engine_in_signals_in_reg <= 0;
        response_engine_in_reg.valid           <= 1'b0;
    end
    else begin
        fifo_response_engine_in_signals_in_reg <= fifo_response_engine_in_signals_in;
        response_engine_in_reg.valid           <= response_engine_in.valid;
    end
end

always_ff @(posedge ap_clk) begin
    response_engine_in_reg.payload <= response_engine_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_generator) begin
        fifo_setup_signal         <= 1'b1;
        request_engine_out.valid  <= 1'b0;
        request_control_out.valid <= 1'b0;
        configure_memory_setup    <= 1'b0;
        done_out                  <= 1'b0;
        fifo_empty_reg            <= 1'b1;
    end
    else begin
        configure_memory_setup    <= configure_memory_setup_reg;
        done_out                  <= done_out_reg & fifo_empty_reg;
        fifo_empty_reg            <= fifo_empty_int;
        fifo_setup_signal         <= (|fifo_response_engine_in_setup_signal_int) | fifo_request_engine_out_setup_signal_int | fifo_request_control_out_setup_signal_int;
        request_control_out.valid <= request_control_out_int.valid;
        request_engine_out.valid  <= request_engine_out_int.valid;
    end
end

assign fifo_empty_int = fifo_response_engine_in_signals_out_int.empty & fifo_request_engine_out_signals_out_int.empty & fifo_request_control_out_signals_out_int.empty;

always_ff @(posedge ap_clk) begin
    fifo_request_engine_out_signals_out  <= fifo_request_engine_out_signals_out_int;
    fifo_request_control_out_signals_out <= fifo_request_control_out_signals_out_int;
    request_control_out.payload          <= request_control_out_int.payload;
    request_engine_out.payload           <= request_engine_out_int.payload;
end


always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_engine_in_signals_out_int);
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
assign fifo_response_engine_in_signals_in_int.rd_en = (~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en & ~(|sequence_flow_reg) & ~generator_engine_request_engine_reg.valid & ~generator_engine_request_engine_reg_S2.valid & ~response_engine_in_int.valid & configure_engine_int.valid & ~fifo_request_engine_out_signals_out_int.prog_full & ~fifo_request_control_out_signals_out_int.prog_full);
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
        current_state <= ENGINE_FILTER_COND_GEN_RESET;
    else begin
        current_state <= next_state;
    end
end// always_ff @(posedge ap_clk)

always_comb begin
    next_state = current_state;
    case (current_state)
        ENGINE_FILTER_COND_GEN_RESET : begin
            next_state = ENGINE_FILTER_COND_GEN_IDLE;
        end
        ENGINE_FILTER_COND_GEN_IDLE : begin
            if(descriptor_in_reg.valid)
                next_state = ENGINE_FILTER_COND_GEN_SETUP_MEMORY_IDLE;
            else
                next_state = ENGINE_FILTER_COND_GEN_IDLE;
        end
        ENGINE_FILTER_COND_GEN_SETUP_MEMORY_IDLE : begin
            if(fifo_configure_memory_in_signals_in.rd_en)
                next_state = ENGINE_FILTER_COND_GEN_SETUP_MEMORY_TRANS;
            else
                next_state = ENGINE_FILTER_COND_GEN_SETUP_MEMORY_IDLE;
        end
        ENGINE_FILTER_COND_GEN_SETUP_MEMORY_TRANS : begin
            next_state = ENGINE_FILTER_COND_GEN_SETUP_MEMORY;
        end
        ENGINE_FILTER_COND_GEN_SETUP_MEMORY : begin
            if(configure_memory_reg.valid) // (0) direct mode (get count from memory)
                next_state = ENGINE_FILTER_COND_GEN_START_TRANS;
            else
                next_state = ENGINE_FILTER_COND_GEN_SETUP_MEMORY;
        end
        ENGINE_FILTER_COND_GEN_START_TRANS : begin
            next_state = ENGINE_FILTER_COND_GEN_START;
        end
        ENGINE_FILTER_COND_GEN_START : begin
            next_state = ENGINE_FILTER_COND_GEN_BUSY;
        end
        ENGINE_FILTER_COND_GEN_BUSY_TRANS : begin
            if (break_flow_int)
                next_state = ENGINE_FILTER_COND_GEN_BREAK_TRANS;
            else
                next_state = ENGINE_FILTER_COND_GEN_BUSY;
        end
        ENGINE_FILTER_COND_GEN_BUSY : begin
            if (done_int_reg)
                next_state = ENGINE_FILTER_COND_GEN_DONE_TRANS;
            else if (fifo_request_engine_out_signals_out_int.prog_full)
                next_state = ENGINE_FILTER_COND_GEN_PAUSE_TRANS;
            else if (break_flow_int)
                next_state = ENGINE_FILTER_COND_GEN_BREAK_TRANS;
            else
                next_state = ENGINE_FILTER_COND_GEN_BUSY;
        end
        ENGINE_FILTER_COND_GEN_BREAK_TRANS : begin
            if (break_done_int)
                next_state = ENGINE_FILTER_COND_GEN_BUSY_TRANS;
            else
                next_state = ENGINE_FILTER_COND_GEN_BREAK;
        end
        ENGINE_FILTER_COND_GEN_BREAK : begin
            if (break_done_int)
                next_state = ENGINE_FILTER_COND_GEN_BUSY_TRANS;
            else
                next_state = ENGINE_FILTER_COND_GEN_BREAK;
        end
        ENGINE_FILTER_COND_GEN_PAUSE_TRANS : begin
            next_state = ENGINE_FILTER_COND_GEN_PAUSE;
        end
        ENGINE_FILTER_COND_GEN_PAUSE : begin
            if (~fifo_request_engine_out_signals_out_int.prog_full)
                next_state = ENGINE_FILTER_COND_GEN_BUSY_TRANS;
            else
                next_state = ENGINE_FILTER_COND_GEN_PAUSE;
        end
        ENGINE_FILTER_COND_GEN_DONE_TRANS : begin
            if (done_int_reg)
                next_state = ENGINE_FILTER_COND_GEN_DONE;
            else
                next_state = ENGINE_FILTER_COND_GEN_DONE_TRANS;
        end
        ENGINE_FILTER_COND_GEN_DONE : begin
            if (done_int_reg)
                next_state = ENGINE_FILTER_COND_GEN_IDLE;
            else
                next_state = ENGINE_FILTER_COND_GEN_DONE;
        end
    endcase
end// always_comb

always_ff @(posedge ap_clk) begin
    case (current_state)
        ENGINE_FILTER_COND_GEN_RESET : begin
            done_int_reg                 <= 1'b1;
            done_out_reg                 <= 1'b1;
            configure_memory_setup_reg   <= 1'b0;
            configure_engine_int.valid   <= 1'b0;
            configure_engine_int.payload <= 0;
            break_running_reg            <= 1'b0;
        end
        ENGINE_FILTER_COND_GEN_IDLE : begin
            done_int_reg               <= 1'b1;
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_FILTER_COND_GEN_SETUP_MEMORY_IDLE : begin
            done_int_reg               <= 1'b1;
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_FILTER_COND_GEN_SETUP_MEMORY_TRANS : begin
            configure_memory_setup_reg <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_SETUP_MEMORY : begin
            configure_memory_setup_reg <= 1'b0;
            if(configure_memory_reg.valid) begin
                configure_engine_int.valid   <= 1'b1;
                configure_engine_int.payload <= configure_memory_reg.payload;
            end
        end
        ENGINE_FILTER_COND_GEN_START_TRANS : begin
            done_int_reg               <= 1'b0;
            done_out_reg               <= 1'b0;
            configure_engine_int.valid <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_START : begin
            done_int_reg               <= 1'b0;
            done_out_reg               <= 1'b1;
            configure_engine_int.valid <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_PAUSE_TRANS : begin
            done_int_reg <= 1'b0;
            done_out_reg <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_BUSY : begin
            done_int_reg <= 1'b0;
            done_out_reg <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_BREAK_TRANS : begin
            break_running_reg <= 1'b0;
        end
        ENGINE_FILTER_COND_GEN_BREAK : begin
            break_running_reg <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_BUSY_TRANS : begin
            done_int_reg      <= 1'b0;
            done_out_reg      <= 1'b1;
            break_running_reg <= 1'b0;
        end
        ENGINE_FILTER_COND_GEN_PAUSE : begin
            done_int_reg <= 1'b0;
            done_out_reg <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_DONE_TRANS : begin
            done_int_reg <= 1'b1;
            done_out_reg <= 1'b1;
        end
        ENGINE_FILTER_COND_GEN_DONE : begin
            done_int_reg                 <= 1'b1;
            done_out_reg                 <= 1'b1;
            configure_engine_int.valid   <= 1'b0;
            configure_engine_int.payload <= 0;
        end
    endcase
end// always_ff @(posedge ap_clk)


// --------------------------------------------------------------------------------------
// Generation Logic - Filter data [0-4] -> Gen
// --------------------------------------------------------------------------------------
assign conditional_flow_int = (filter_flow_int & configure_engine_int.payload.param.conditional_flag);
assign filter_flow_int      = (result_flag_int ^ configure_engine_int.payload.param.filter_pass) & generator_engine_request_engine_reg_S2.valid;
assign break_flow_int       = (result_flag_int ^ configure_engine_int.payload.param.break_pass)  & configure_engine_int.payload.param.break_flag & generator_engine_request_engine_reg_S2.valid & ~break_running_reg;
assign done_flow_int        = configure_engine_int.payload.param.break_flag | sequence_done_int;

assign sequence_done_int = ((generator_engine_request_engine_reg_S2.payload.meta.route.seq_state == SEQUENCE_DONE) & generator_engine_request_engine_reg_S2.valid);
assign sequence_flow_int = break_flow_int | sequence_done_int | break_done_int;
assign break_done_int    = break_running_reg & sequence_done_int;

always_ff @(posedge ap_clk) begin
    if (areset_generator) begin
        generator_engine_request_engine_reg.valid     <= 1'b0; // s1
        generator_engine_request_engine_reg_S2.valid  <= 1'b0;
        generator_engine_request_engine_reg_S3.valid  <= 1'b0;
        generator_engine_request_engine_reg_S4.valid  <= 1'b0;
        generator_engine_request_control_reg_S4.valid <= 1'b0;
    end
    else begin
        generator_engine_request_engine_reg_S2.valid  <= generator_engine_request_engine_reg.valid;
        generator_engine_request_engine_reg_S3.valid  <= (generator_engine_request_engine_reg_S2.valid & filter_flow_int & ~break_running_reg) | sequence_flow_int | sequence_flow_reg[0];
        generator_engine_request_engine_reg_S4.valid  <= generator_engine_request_engine_reg_S3.valid  & (generator_engine_request_engine_reg_S3.payload.meta.subclass.cmd != CMD_CONTROL);
        generator_engine_request_control_reg_S4.valid <= generator_engine_request_engine_reg_S3.valid  & (generator_engine_request_engine_reg_S3.payload.meta.subclass.cmd == CMD_CONTROL);


        if(response_engine_in_int.valid & configure_engine_int.valid) begin
            generator_engine_request_engine_reg.valid <= 1'b1;
        end else begin
            if(generator_engine_request_engine_reg.valid)
                generator_engine_request_engine_reg.valid <= 1'b0;
            else
                generator_engine_request_engine_reg.valid <= generator_engine_request_engine_reg.valid;
        end
    end
end

always_ff @(posedge ap_clk) begin
    generator_engine_request_engine_reg.payload <= response_engine_in_int.payload;
end

always_ff @(posedge ap_clk) begin
    generator_engine_request_engine_reg_S2.payload <= generator_engine_request_engine_reg.payload;

    if (sequence_flow_int & ~sequence_flow_reg[0]) begin
        sequence_flow_reg[0] <= 1'b1 & filter_flow_int;
    end else begin
        sequence_flow_reg <= sequence_flow_reg << 1'b1;
    end
end

always_ff @(posedge ap_clk) begin
    generator_engine_request_engine_reg_S3.payload.data                 <= result_data_int;
    generator_engine_request_engine_reg_S3.payload.meta.address         <= generator_engine_request_engine_reg_S2.payload.meta.address;
    generator_engine_request_engine_reg_S3.payload.meta.route.from      <= generator_engine_request_engine_reg_S2.payload.meta.route.from;
    generator_engine_request_engine_reg_S3.payload.meta.route.hops      <= generator_engine_request_engine_reg_S2.payload.meta.route.hops;
    generator_engine_request_engine_reg_S3.payload.meta.route.seq_id    <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_id;
    generator_engine_request_engine_reg_S3.payload.meta.route.seq_src   <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_src;
    generator_engine_request_engine_reg_S3.payload.meta.subclass.buffer <= generator_engine_request_engine_reg_S2.payload.meta.subclass.buffer;

    if(sequence_flow_reg[0])begin
        if(configure_engine_int.payload.param.conditional_flag) begin
            if(conditional_flow_int) begin
                generator_engine_request_engine_reg_S3.payload.meta.route.to <= configure_engine_int.payload.param.filter_route._if;
            end else begin
                generator_engine_request_engine_reg_S3.payload.meta.route.to <= configure_engine_int.payload.param.filter_route._else;
            end
        end else begin
            generator_engine_request_engine_reg_S3.payload.meta.route.to <= generator_engine_request_engine_reg_S2.payload.meta.route.to;
        end

        if (done_flow_int)
            generator_engine_request_engine_reg_S3.payload.meta.route.seq_state <= SEQUENCE_DONE;
        else
            generator_engine_request_engine_reg_S3.payload.meta.route.seq_state <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_state;

        generator_engine_request_engine_reg_S3.payload.meta.route.from   <= generator_engine_request_engine_reg_S2.payload.meta.route.from;
        generator_engine_request_engine_reg_S3.payload.meta.subclass.cmd <= generator_engine_request_engine_reg_S2.payload.meta.subclass.cmd;
    end else begin
        if (generator_engine_request_engine_reg_S2.payload.meta.route.seq_state == SEQUENCE_DONE) begin
            generator_engine_request_engine_reg_S3.payload.meta.route.seq_state <= SEQUENCE_DONE;
            generator_engine_request_engine_reg_S3.payload.meta.route.to        <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_src;
            generator_engine_request_engine_reg_S3.payload.meta.route.from      <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_src;
            generator_engine_request_engine_reg_S3.payload.meta.subclass.cmd    <= CMD_CONTROL;
        end else if (break_flow_int) begin
            generator_engine_request_engine_reg_S3.payload.meta.route.seq_state <= SEQUENCE_BREAK;
            generator_engine_request_engine_reg_S3.payload.meta.route.to        <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_src;
            generator_engine_request_engine_reg_S3.payload.meta.route.from      <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_src;
            generator_engine_request_engine_reg_S3.payload.meta.subclass.cmd    <= CMD_CONTROL;
        end else begin

            if (done_flow_int)
                generator_engine_request_engine_reg_S3.payload.meta.route.seq_state <= SEQUENCE_DONE;
            else
                generator_engine_request_engine_reg_S3.payload.meta.route.seq_state <= generator_engine_request_engine_reg_S2.payload.meta.route.seq_state;

            generator_engine_request_engine_reg_S3.payload.meta.route.from   <= generator_engine_request_engine_reg_S2.payload.meta.route.from;
            generator_engine_request_engine_reg_S3.payload.meta.route.to     <= generator_engine_request_engine_reg_S2.payload.meta.route.to;
            generator_engine_request_engine_reg_S3.payload.meta.subclass.cmd <= generator_engine_request_engine_reg_S2.payload.meta.subclass.cmd;
        end
    end
end

always_ff @(posedge ap_clk) begin
    generator_engine_request_engine_reg_S4.payload  <= generator_engine_request_engine_reg_S3.payload;
    generator_engine_request_control_reg_S4.payload <= generator_engine_request_engine_reg_S3.payload;

    // if(generator_engine_request_engine_reg_S4.valid)
    //     $display("%t - D %0s B:%0d L:%0d-%0d-%0d", $time,generator_engine_request_engine_reg_S4.payload.meta.route.seq_state.name(),ID_BUNDLE, ID_LANE, generator_engine_request_engine_reg_S4.payload.data.field[0], generator_engine_request_engine_reg_S4.payload.data.field[3]);

    // if(generator_engine_request_control_reg_S4.valid)
    //     $display("%t - C %0s B:%0d L:%0d-%0d-%0d", $time,generator_engine_request_control_reg_S4.payload.meta.route.seq_state.name(),ID_BUNDLE, ID_LANE, generator_engine_request_control_reg_S4.payload.data.field[0], generator_engine_request_control_reg_S4.payload.data.field[3]);
end

engine_filter_cond_kernel inst_engine_filter_cond_kernel (
    .ap_clk             (ap_clk                             ),
    .areset             (areset_kernel                      ),
    .clear              (~(configure_engine_int.valid)      ),
    .config_params_valid(configure_engine_int.valid         ),
    .config_params      (configure_engine_int.payload.param ),
    .data_valid         (response_engine_in_int.valid       ),
    .data               (response_engine_in_int.payload.data),
    .result_flag        (result_flag_int                    ),
    .result_data        (result_data_int                    )
);

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_engine_out_setup_signal_int = fifo_request_engine_out_signals_out_int.wr_rst_busy | fifo_request_engine_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_engine_out_signals_in_int.wr_en = generator_engine_request_engine_reg_S4.valid;
assign fifo_request_engine_out_din                  = generator_engine_request_engine_reg_S4.payload;

// Pop
assign fifo_request_engine_out_signals_in_int.rd_en = ~fifo_request_engine_out_signals_out_int.empty & backtrack_fifo_response_engine_in_signals_out.rd_en;
assign request_engine_out_int.valid                 = fifo_request_engine_out_signals_out_int.valid & fifo_request_engine_out_signals_in_int.rd_en ;
assign request_engine_out_int.payload               = fifo_request_engine_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               ),
    .READ_MODE       ("fwft"                    )
) inst_fifo_MemoryPacketRequestEngineOutput (
    .clk        (ap_clk                                             ),
    .srst       (areset_fifo                                        ),
    .din        (fifo_request_engine_out_din                        ),
    .wr_en      (fifo_request_engine_out_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_engine_out_signals_in_int.rd_en       ),
    .dout       (fifo_request_engine_out_dout                       ),
    .full       (fifo_request_engine_out_signals_out_int.full       ),
    .empty      (fifo_request_engine_out_signals_out_int.empty      ),
    .valid      (fifo_request_engine_out_signals_out_int.valid      ),
    .prog_full  (fifo_request_engine_out_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_engine_out_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_engine_out_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
assign backtrack_configure_route_valid                    = fifo_request_engine_out_signals_out_int.valid;
assign backtrack_configure_route_in                       = fifo_request_engine_out_dout.meta.route.to;
assign backtrack_fifo_response_engine_in_signals_in       = fifo_request_engine_out_signals_in_reg;
assign backtrack_fifo_response_lanes_backtrack_signals_in = fifo_response_lanes_backtrack_signals_in;

backtrack_fifo_lanes_response_signal #(
    .ID_CU          (ID_CU          ),
    .ID_BUNDLE      (ID_BUNDLE      ),
    .ID_LANE        (ID_LANE        ),
    .ID_ENGINE      (ID_ENGINE      ),
    .ID_MODULE      (2              ),
    .NUM_LANES_MAX  (NUM_LANES_MAX  ),
    .NUM_BUNDLES_MAX(NUM_BUNDLES_MAX)
) inst_backtrack_fifo_lanes_response_signal (
    .ap_clk                                  (ap_clk                                            ),
    .areset                                  (areset_backtrack                                  ),
    .configure_route_valid                   (backtrack_configure_route_valid                   ),
    .configure_route_in                      (backtrack_configure_route_in                      ),
    .fifo_response_engine_in_signals_in      (backtrack_fifo_response_engine_in_signals_in      ),
    .fifo_response_lanes_backtrack_signals_in(backtrack_fifo_response_lanes_backtrack_signals_in),
    .fifo_response_engine_in_signals_out     (backtrack_fifo_response_engine_in_signals_out     )
);

// --------------------------------------------------------------------------------------
// FIFO OUTPUT control requests MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_control_out_setup_signal_int = fifo_request_control_out_signals_out_int.wr_rst_busy | fifo_request_control_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_control_out_signals_in_int.wr_en = generator_engine_request_control_reg_S4.valid;
assign fifo_request_control_out_din                  = generator_engine_request_control_reg_S4.payload;

// Pop
assign fifo_request_control_out_signals_in_int.rd_en = ~fifo_request_control_out_signals_out_int.empty & fifo_request_control_out_signals_in_reg.rd_en;
assign request_control_out_int.valid                 = fifo_request_control_out_signals_out_int.valid;
assign request_control_out_int.payload               = fifo_request_control_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_MemoryPacketRequestcontrolOutput (
    .clk        (ap_clk                                              ),
    .srst       (areset_fifo                                         ),
    .din        (fifo_request_control_out_din                        ),
    .wr_en      (fifo_request_control_out_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_control_out_signals_in_int.rd_en       ),
    .dout       (fifo_request_control_out_dout                       ),
    .full       (fifo_request_control_out_signals_out_int.full       ),
    .empty      (fifo_request_control_out_signals_out_int.empty      ),
    .valid      (fifo_request_control_out_signals_out_int.valid      ),
    .prog_full  (fifo_request_control_out_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_control_out_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_control_out_signals_out_int.rd_rst_busy)
);

endmodule : engine_filter_cond_generator