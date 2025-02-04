// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_alu_ops_generator.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_alu_ops_generator #(parameter
    ID_CU               = 0                 ,
    ID_BUNDLE           = 0                 ,
    ID_LANE             = 0                 ,
    ID_ENGINE           = 0                 ,
    ID_MODULE           = 0                 ,
    ENGINE_CAST_WIDTH   = 0                 ,
    ENGINE_MERGE_WIDTH  = 0                 ,
    ENGINES_CONFIG      = 0                 ,
    FIFO_WRITE_DEPTH    = 16                ,
    PROG_THRESH         = 8                 ,
    PIPELINE_STAGES     = 2                 ,
    COUNTER_WIDTH       = M00_AXI4_FE_ADDR_W,
    NUM_BACKTRACK_LANES = 4                 ,
    NUM_BUNDLES         = 4
) (
    // System Signals
    input  logic                  ap_clk                                                                             ,
    input  logic                  areset                                                                             ,
    input  ALUOpsConfiguration    configure_memory_in                                                                ,
    input  FIFOStateSignalsInput  fifo_configure_memory_in_signals_in                                                ,
    input  EnginePacket           response_engine_in                                                                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out                                                ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0],
    output EnginePacket           request_engine_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out                                                ,
    output logic                  fifo_setup_signal                                                                  ,
    output logic                  configure_memory_setup                                                             ,
    output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_generator;
logic areset_kernel   ;
logic areset_fifo     ;

ALUOpsConfiguration configure_memory_reg;
ALUOpsConfiguration configure_engine_int;

logic configure_memory_setup_reg;

logic fifo_empty_int    ;
logic fifo_empty_reg    ;
logic sequence_done_flag;

// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
engine_alu_ops_generator_state current_state;
engine_alu_ops_generator_state next_state   ;

logic done_out_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
EnginePacket          response_engine_in_int                ;
EnginePacketMeta      response_engine_reg_int               ;
logic                 response_engine_reg_int_valid         ;
EnginePacket          response_engine_in_reg                ;
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;

EnginePacket generator_engine_request_engine_start_Stage;
EnginePacket generator_engine_request_engine_final_Stage;

EnginePacket          request_engine_out_int                 ;
FIFOStateSignalsInput fifo_configure_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
EnginePacketPayload           fifo_response_engine_in_din             ;
EnginePacketPayload           fifo_response_engine_in_dout            ;
FIFOStateSignalsInputInternal fifo_response_engine_in_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_response_engine_in_signals_out_int ;
logic                         fifo_response_engine_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request EnginePacket
// --------------------------------------------------------------------------------------
EnginePacketPayload           fifo_request_engine_out_din             ;
EnginePacketPayload           fifo_request_engine_out_dout            ;
FIFOStateSignalsInput         fifo_request_engine_out_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_request_engine_out_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_request_engine_out_signals_out_int ;
logic                         fifo_request_engine_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
logic                  areset_backtrack                                                                             ;
logic                  backtrack_configure_route_valid                                                              ;
PacketRouteAddress     backtrack_configure_route_in                                                                 ;
FIFOStateSignalsOutput backtrack_fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0];
FIFOStateSignalsInput  backtrack_fifo_response_engine_in_signals_out                                                ;
// --------------------------------------------------------------------------------------
localparam             PULSE_HOLD          = 2;
logic [PULSE_HOLD-1:0] alu_ops_done_hold      ;
logic                  alu_ops_done_assert    ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_kernel    <= areset;
    areset_generator <= areset;
    areset_fifo      <= areset;
    areset_backtrack <= areset;
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
        fifo_request_engine_out_signals_in_reg  <= 0;
    end
    else begin
        fifo_configure_memory_in_signals_in_reg <= fifo_configure_memory_in_signals_in;
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
        fifo_setup_signal        <= 1'b1;
        request_engine_out.valid <= 1'b0;
        configure_memory_setup   <= 1'b0;
        done_out                 <= 1'b0;
        fifo_empty_reg           <= 1'b1;
    end
    else begin
        fifo_setup_signal        <= fifo_response_engine_in_setup_signal_int | fifo_request_engine_out_setup_signal_int;
        request_engine_out.valid <= request_engine_out_int.valid;
        configure_memory_setup   <= configure_memory_setup_reg;
        done_out                 <= done_out_reg & fifo_empty_reg;
        fifo_empty_reg           <= fifo_empty_int;
    end
end

assign fifo_empty_int = fifo_response_engine_in_signals_out_int.empty & fifo_request_engine_out_signals_out_int.empty ;

always_ff @(posedge ap_clk) begin
    request_engine_out.payload <= request_engine_out_int.payload;
end


always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_engine_in_signals_out_int);
    fifo_request_engine_out_signals_out <= map_internal_fifo_signals_to_output(fifo_request_engine_out_signals_out_int);
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
assign fifo_response_engine_in_signals_in_int.rd_en = ~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en  & ~fifo_request_engine_out_signals_out_int.prog_full & ~alu_ops_done_assert;
assign response_engine_in_int.valid                 = fifo_response_engine_in_signals_out_int.valid;
assign response_engine_in_int.payload               = fifo_response_engine_in_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(64                        ),
    .WRITE_DATA_WIDTH($bits(EnginePacketPayload)),
    .READ_DATA_WIDTH ($bits(EnginePacketPayload)),
    .PROG_THRESH     (48                        )
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
assign sequence_done_flag = (configure_engine_int.payload.param.alu_operation == ALU_ACC) & response_engine_in_int.valid & (response_engine_in_int.payload.meta.route.sequence_state == SEQUENCE_DONE);
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(areset_generator)
        current_state <= ENGINE_ALU_OPS_GEN_RESET;
    else begin
        current_state <= next_state;
    end
end// always_ff @(posedge ap_clk)

always_comb begin
    next_state = current_state;
    case (current_state)
        ENGINE_ALU_OPS_GEN_RESET : begin
            next_state = ENGINE_ALU_OPS_GEN_IDLE;
        end
        ENGINE_ALU_OPS_GEN_IDLE : begin
            next_state = ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE;
        end
        ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE : begin
            if(fifo_configure_memory_in_signals_in_reg.rd_en)
                next_state = ENGINE_ALU_OPS_GEN_SETUP_MEMORY_TRANS;
            else
                next_state = ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE;
        end
        ENGINE_ALU_OPS_GEN_SETUP_MEMORY_TRANS : begin
            next_state = ENGINE_ALU_OPS_GEN_SETUP_MEMORY;
        end
        ENGINE_ALU_OPS_GEN_SETUP_MEMORY : begin
            if(configure_memory_reg.valid) // (0) direct mode (get count from memory)
                next_state = ENGINE_ALU_OPS_GEN_START_TRANS;
            else
                next_state = ENGINE_ALU_OPS_GEN_SETUP_MEMORY;
        end
        ENGINE_ALU_OPS_GEN_START_TRANS : begin
            next_state = ENGINE_ALU_OPS_GEN_START;
        end
        ENGINE_ALU_OPS_GEN_START : begin
            next_state = ENGINE_ALU_OPS_GEN_BUSY;
        end
        ENGINE_ALU_OPS_GEN_BUSY_TRANS : begin
            next_state = ENGINE_ALU_OPS_GEN_BUSY;
        end
        ENGINE_ALU_OPS_GEN_BUSY : begin
            if (fifo_request_engine_out_signals_out_int.prog_full)
                next_state = ENGINE_ALU_OPS_GEN_PAUSE_TRANS;
            else
                next_state = ENGINE_ALU_OPS_GEN_BUSY;
        end
        ENGINE_ALU_OPS_GEN_PAUSE_TRANS : begin
            next_state = ENGINE_ALU_OPS_GEN_PAUSE;
        end
        ENGINE_ALU_OPS_GEN_PAUSE : begin
            if (~fifo_request_engine_out_signals_out_int.prog_full)
                next_state = ENGINE_ALU_OPS_GEN_BUSY_TRANS;
            else
                next_state = ENGINE_ALU_OPS_GEN_PAUSE;
        end
        default : begin
            next_state = ENGINE_ALU_OPS_GEN_RESET;
        end
    endcase
end// always_comb

always_ff @(posedge ap_clk) begin
    case (current_state)
        ENGINE_ALU_OPS_GEN_RESET : begin
            done_out_reg               <= 1'b1;
            configure_memory_setup_reg <= 1'b0;
            configure_engine_int.valid <= 1'b0;
        end
        ENGINE_ALU_OPS_GEN_IDLE : begin
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE : begin
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_ALU_OPS_GEN_SETUP_MEMORY_TRANS : begin
            configure_memory_setup_reg <= 1'b1;
        end
        ENGINE_ALU_OPS_GEN_SETUP_MEMORY : begin
            configure_memory_setup_reg <= 1'b0;
            if(configure_memory_reg.valid)
                configure_engine_int.valid <= 1'b1;
        end
        ENGINE_ALU_OPS_GEN_START_TRANS : begin
            done_out_reg               <= 1'b0;
            configure_engine_int.valid <= 1'b1;
        end
        ENGINE_ALU_OPS_GEN_START : begin
            done_out_reg               <= 1'b1;
            configure_engine_int.valid <= 1'b1;
        end
        ENGINE_ALU_OPS_GEN_PAUSE_TRANS : begin
            done_out_reg <= 1'b1;
        end
        ENGINE_ALU_OPS_GEN_BUSY : begin
            done_out_reg <= 1'b1;
        end
        ENGINE_ALU_OPS_GEN_BUSY_TRANS : begin
            done_out_reg <= 1'b1;
        end
        ENGINE_ALU_OPS_GEN_PAUSE : begin
            done_out_reg <= 1'b1;
        end
    endcase
end// always_ff @(posedge ap_clk)

always_ff @(posedge ap_clk) begin
    if(configure_memory_reg.valid)
        configure_engine_int.payload <= configure_memory_reg.payload;
end

// --------------------------------------------------------------------------------------
// Generation Logic - ALU OPS data [0-4] -> Gen
// --------------------------------------------------------------------------------------
EnginePacketData result_int          ;
logic            engine_alu_ops_clear;
logic            alu_op_done_int     ;
logic            alu_op_clear_int    ;
// --------------------------------------------------------------------------------------
always_comb alu_op_done_int  = (configure_engine_int.payload.param.alu_operation == ALU_ACC) ? ((response_engine_reg_int_valid & (response_engine_reg_int.route.sequence_state == SEQUENCE_DONE)) ? 1'b1 : 1'b0) : response_engine_reg_int_valid;
always_comb alu_op_clear_int = (configure_engine_int.payload.param.alu_operation == ALU_ACC) ? ((response_engine_reg_int_valid & (response_engine_reg_int.route.sequence_state == SEQUENCE_DONE)) ? 1'b1 : 1'b0) : 1'b0;
// --------------------------------------------------------------------------------------
localparam RESPONSE_ENGINE_IN_INT_STAGES  = 3;
localparam RESPONSE_ENGINE_GEN_INT_STAGES = 1;
// --------------------------------------------------------------------------------------
hyper_pipeline_noreset #(
    .STAGES(RESPONSE_ENGINE_IN_INT_STAGES),
    .WIDTH ($bits(EnginePacketMeta)      )
) inst_hyper_pipeline_response_engine_in_int (
    .ap_clk(ap_clk                             ),
    .din   (response_engine_in_int.payload.meta),
    .dout  (response_engine_reg_int            )
);
// --------------------------------------------------------------------------------------
hyper_pipeline_noreset #(
    .STAGES(RESPONSE_ENGINE_IN_INT_STAGES),
    .WIDTH (1                            )
) inst_hyper_pipeline_response_engine_in_int_valid (
    .ap_clk(ap_clk                       ),
    .din   (response_engine_in_int.valid ),
    .dout  (response_engine_reg_int_valid)
);
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    engine_alu_ops_clear <= alu_op_clear_int;
end
// --------------------------------------------------------------------------------------
engine_alu_ops_kernel inst_engine_alu_ops_kernel (
    .ap_clk             (ap_clk                             ),
    .areset             (areset_kernel                      ),
    .clear              (engine_alu_ops_clear               ),
    .config_params_in   (configure_engine_int.payload.param ),
    .data_valid         (response_engine_in_int.valid       ),
    .data_in            (response_engine_in_int.payload.data),
    .result_out         (result_int                         )
);
// --------------------------------------------------------------------------------------
always_comb begin
    generator_engine_request_engine_start_Stage.valid                                 = alu_op_done_int;
    generator_engine_request_engine_start_Stage.payload.data                          = result_int ;
    generator_engine_request_engine_start_Stage.payload.meta.route.packet_destination = configure_engine_int.payload.meta.route.packet_destination;
    generator_engine_request_engine_start_Stage.payload.meta.route.sequence_source    = response_engine_reg_int.route.sequence_source;
    generator_engine_request_engine_start_Stage.payload.meta.route.sequence_state     = response_engine_reg_int.route.sequence_state;
    generator_engine_request_engine_start_Stage.payload.meta.route.sequence_id        = response_engine_reg_int.route.sequence_id;
    generator_engine_request_engine_start_Stage.payload.meta.route.hops               = response_engine_reg_int.route.hops;
end
// --------------------------------------------------------------------------------------
hyper_pipeline_noreset #(
    .STAGES(RESPONSE_ENGINE_GEN_INT_STAGES),
    .WIDTH ($bits(EnginePacket)           )
) inst_hyper_pipeline_generator_engine_request (
    .ap_clk(ap_clk                                     ),
    .din   (generator_engine_request_engine_start_Stage),
    .dout  (generator_engine_request_engine_final_Stage)
);

// --------------------------------------------------------------------------------------
assign alu_ops_done_assert = (|alu_ops_done_hold) | sequence_done_flag;
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_generator) begin
        alu_ops_done_hold <= 0;
    end else begin
        alu_ops_done_hold <= {alu_ops_done_hold[PULSE_HOLD-2:0],sequence_done_flag};
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
// FIFO OUTPUT Engine requests EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_engine_out_setup_signal_int = fifo_request_engine_out_signals_out_int.wr_rst_busy | fifo_request_engine_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_engine_out_signals_in_int.wr_en = generator_engine_request_engine_final_Stage.valid;
assign fifo_request_engine_out_din                  = generator_engine_request_engine_final_Stage.payload;

// Pop
assign fifo_request_engine_out_signals_in_int.rd_en = ~fifo_request_engine_out_signals_out_int.empty & fifo_request_engine_out_signals_in_reg.rd_en & backtrack_fifo_response_engine_in_signals_out.rd_en;
assign request_engine_out_int.valid                 = fifo_request_engine_out_signals_out_int.valid;
assign request_engine_out_int.payload               = fifo_request_engine_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(EnginePacketPayload)),
    .READ_DATA_WIDTH ($bits(EnginePacketPayload)),
    .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_EnginePacketRequestEngineOutput (
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

endmodule : engine_alu_ops_generator