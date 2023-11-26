// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
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
    ID_CU              = 0                    ,
    ID_BUNDLE          = 0                    ,
    ID_LANE            = 0                    ,
    ID_ENGINE          = 0                    ,
    ID_MODULE          = 0                    ,
    ENGINE_CAST_WIDTH  = 0                    ,
    ENGINE_MERGE_WIDTH = 0                    ,
    ENGINES_CONFIG     = 0                    ,
    FIFO_WRITE_DEPTH   = 16                   ,
    PROG_THRESH        = 8                    ,
    PIPELINE_STAGES    = 2                    ,
    COUNTER_WIDTH      = M_AXI4_FE_ADDR_W
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  ALUOpsConfiguration    configure_memory_in                ,
    input  FIFOStateSignalsInput  fifo_configure_memory_in_signals_in,
    input  MemoryPacket           response_engine_in                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out,
    output MemoryPacket           request_engine_out                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in ,
    output logic                  fifo_setup_signal                  ,
    output logic                  configure_memory_setup             ,
    output logic                  done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_generator;
    logic areset_kernel   ;
    logic areset_counter  ;
    logic areset_fifo     ;

    KernelDescriptor descriptor_in_reg;

    ALUOpsConfiguration configure_memory_reg;

    logic configure_memory_setup_reg;

    logic fifo_empty_int;
    logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
    engine_alu_ops_generator_state current_state;
    engine_alu_ops_generator_state next_state   ;

    logic done_int_reg;
    logic done_out_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
    MemoryPacket          response_engine_in_int                ;
    MemoryPacket          response_engine_in_reg                ;
    FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;

    logic                         configure_engine_param_valid;
    ALUOpsConfigurationParameters configure_engine_param_int  ;

    MemoryPacket          generator_engine_request_engine_reg    ;
    MemoryPacket          generator_engine_request_engine_reg_S2 ;
    MemoryPacket          request_engine_out_int                 ;
    FIFOStateSignalsInput fifo_configure_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// Generation Logic - Merge data [0-4] -> Gen
// --------------------------------------------------------------------------------------
    logic alu_ops_response_engine_in_valid_reg    ;
    logic alu_ops_response_engine_in_valid_flag_S2;
    logic alu_ops_response_engine_in_valid_flag   ;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_engine_in_din             ;
    MemoryPacketPayload    fifo_response_engine_in_dout            ;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_engine_in_signals_out_int ;
    logic                  fifo_response_engine_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_engine_out_din             ;
    MemoryPacketPayload    fifo_request_engine_out_dout            ;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_engine_out_signals_out_int ;
    logic                  fifo_request_engine_out_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_kernel    <= areset;
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
            fifo_setup_signal        <= (|fifo_response_engine_in_setup_signal_int) | fifo_request_engine_out_setup_signal_int;
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
        fifo_response_engine_in_signals_out <= fifo_response_engine_in_signals_out_int;
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
    assign fifo_response_engine_in_signals_in_int.rd_en = (~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en & ~alu_ops_response_engine_in_valid_reg & ~generator_engine_request_engine_reg.valid & ~alu_ops_response_engine_in_valid_flag_S2 & ~response_engine_in_int.valid & configure_engine_param_valid & ~fifo_request_engine_out_signals_out_int.prog_full);
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
            current_state <= ENGINE_ALU_OPS_GEN_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            ENGINE_ALU_OPS_GEN_RESET : begin
                next_state = ENGINE_ALU_OPS_GEN_IDLE;
            end
            ENGINE_ALU_OPS_GEN_IDLE : begin
                if(descriptor_in_reg.valid)
                    next_state = ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE;
                else
                    next_state = ENGINE_ALU_OPS_GEN_IDLE;
            end
            ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE : begin
                if(fifo_configure_memory_in_signals_in.rd_en)
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
                if (done_int_reg)
                    next_state = ENGINE_ALU_OPS_GEN_DONE_TRANS;
                else if (fifo_request_engine_out_signals_out_int.prog_full)
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
            ENGINE_ALU_OPS_GEN_DONE_TRANS : begin
                if (done_int_reg)
                    next_state = ENGINE_ALU_OPS_GEN_DONE;
                else
                    next_state = ENGINE_ALU_OPS_GEN_DONE_TRANS;
            end
            ENGINE_ALU_OPS_GEN_DONE : begin
                if (done_int_reg)
                    next_state = ENGINE_ALU_OPS_GEN_IDLE;
                else
                    next_state = ENGINE_ALU_OPS_GEN_DONE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            ENGINE_ALU_OPS_GEN_RESET : begin
                done_int_reg                 <= 1'b1;
                done_out_reg                 <= 1'b1;
                configure_memory_setup_reg   <= 1'b0;
                configure_engine_param_valid <= 1'b0;
                configure_engine_param_int   <= 0;
            end
            ENGINE_ALU_OPS_GEN_IDLE : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b0;
                configure_memory_setup_reg <= 1'b0;
            end
            ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE : begin
                done_int_reg               <= 1'b1;
                done_out_reg               <= 1'b0;
                configure_memory_setup_reg <= 1'b0;
            end
            ENGINE_ALU_OPS_GEN_SETUP_MEMORY_TRANS : begin
                configure_memory_setup_reg <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_SETUP_MEMORY : begin
                configure_memory_setup_reg   <= 1'b0;
                configure_engine_param_valid <= 1'b0;
                if(configure_memory_reg.valid)
                    configure_engine_param_int <= configure_memory_reg.payload.param;
            end
            ENGINE_ALU_OPS_GEN_START_TRANS : begin
                done_int_reg                 <= 1'b0;
                done_out_reg                 <= 1'b0;
                configure_engine_param_valid <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_START : begin
                done_int_reg                 <= 1'b0;
                done_out_reg                 <= 1'b1;
                configure_engine_param_valid <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_PAUSE_TRANS : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_BUSY : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_BUSY_TRANS : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_PAUSE : begin
                done_int_reg <= 1'b0;
                done_out_reg <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_DONE_TRANS : begin
                done_int_reg <= 1'b1;
                done_out_reg <= 1'b1;
            end
            ENGINE_ALU_OPS_GEN_DONE : begin
                done_int_reg                 <= 1'b1;
                done_out_reg                 <= 1'b1;
                configure_engine_param_valid <= 1'b0;
                configure_engine_param_int   <= 0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Generation Logic - ALU OPS data [0-4] -> Gen
// --------------------------------------------------------------------------------------
    MemoryPacketData result_int          ;
    logic            result_flag         ;
    logic            engine_alu_ops_clear;

    assign alu_ops_response_engine_in_valid_flag = alu_ops_response_engine_in_valid_reg;

    always_ff @(posedge ap_clk) begin
        if (areset_generator) begin
            alu_ops_response_engine_in_valid_reg      <= 1'b0;
            alu_ops_response_engine_in_valid_flag_S2  <= 1'b0;
            generator_engine_request_engine_reg.valid <= 1'b0;
        end
        else begin
            alu_ops_response_engine_in_valid_flag_S2  <= alu_ops_response_engine_in_valid_flag;
            generator_engine_request_engine_reg.valid <= alu_ops_response_engine_in_valid_flag_S2;

            if(response_engine_in_int.valid & configure_engine_param_valid) begin
                alu_ops_response_engine_in_valid_reg <= 1'b1;
            end else begin
                if(alu_ops_response_engine_in_valid_flag)
                    alu_ops_response_engine_in_valid_reg <= 1'b0;
                else
                    alu_ops_response_engine_in_valid_reg <= alu_ops_response_engine_in_valid_reg;
            end
        end
    end

    always_ff @(posedge ap_clk) begin
        generator_engine_request_engine_reg.payload.data                 <= response_engine_in_int.payload.data  ;
        generator_engine_request_engine_reg.payload.meta.route.from      <= configure_memory_reg.payload.meta.route.from;
        generator_engine_request_engine_reg.payload.meta.route.to        <= configure_memory_reg.payload.meta.route.to;
        generator_engine_request_engine_reg.payload.meta.route.seq_src   <= response_engine_in_int.payload.meta.route.seq_src;
        generator_engine_request_engine_reg.payload.meta.route.seq_state <= response_engine_in_int.payload.meta.route.seq_state;
        generator_engine_request_engine_reg.payload.meta.route.seq_id    <= response_engine_in_int.payload.meta.route.seq_id;
        generator_engine_request_engine_reg.payload.meta.route.hops      <= response_engine_in_int.payload.meta.route.hops;
        generator_engine_request_engine_reg.payload.meta.address         <= response_engine_in_int.payload.meta.address;
        generator_engine_request_engine_reg.payload.meta.subclass        <= response_engine_in_int.payload.meta.subclass;
    end

    always_ff @(posedge ap_clk) begin
        if((configure_engine_param_int.alu_operation == ALU_ACC) && generator_engine_request_engine_reg.payload.meta.route.seq_state == SEQUENCE_DONE & result_flag) begin
            generator_engine_request_engine_reg_S2.valid <= 1'b1;
            engine_alu_ops_clear                         <= 1'b1;
        end else if ((configure_engine_param_int.alu_operation == ALU_ACC) && generator_engine_request_engine_reg.payload.meta.route.seq_state != SEQUENCE_DONE & ~result_flag) begin
            generator_engine_request_engine_reg_S2.valid <= 1'b0;
            engine_alu_ops_clear                         <= 1'b0;
        end else if ((configure_engine_param_int.alu_operation == ALU_ACC) && generator_engine_request_engine_reg.payload.meta.route.seq_state == SEQUENCE_DONE & ~result_flag) begin
            generator_engine_request_engine_reg_S2.valid <= 1'b0;
            engine_alu_ops_clear                         <= 1'b0;
        end else begin
            generator_engine_request_engine_reg_S2.valid <= generator_engine_request_engine_reg.valid;
            engine_alu_ops_clear                         <= 1'b0;
        end

        generator_engine_request_engine_reg_S2.payload.data                 <= result_int;
        generator_engine_request_engine_reg_S2.payload.meta.route.from      <= generator_engine_request_engine_reg.payload.meta.route.from;
        generator_engine_request_engine_reg_S2.payload.meta.route.to        <= generator_engine_request_engine_reg.payload.meta.route.to;
        generator_engine_request_engine_reg_S2.payload.meta.route.seq_src   <= generator_engine_request_engine_reg.payload.meta.route.seq_src;
        generator_engine_request_engine_reg_S2.payload.meta.route.seq_state <= generator_engine_request_engine_reg.payload.meta.route.seq_state;
        generator_engine_request_engine_reg_S2.payload.meta.route.seq_id    <= generator_engine_request_engine_reg.payload.meta.route.seq_id;
        generator_engine_request_engine_reg_S2.payload.meta.route.hops      <= generator_engine_request_engine_reg.payload.meta.route.hops;
        generator_engine_request_engine_reg_S2.payload.meta.address         <= generator_engine_request_engine_reg.payload.meta.address;
        generator_engine_request_engine_reg_S2.payload.meta.subclass        <= generator_engine_request_engine_reg.payload.meta.subclass;

        // if(generator_engine_request_engine_reg_S2.valid)
        //     $display("%t - D %0s B:%0d L:%0d-%0d-%0d", $time,generator_engine_request_engine_reg_S2.payload.meta.route.seq_state.name(),ID_BUNDLE, ID_LANE, generator_engine_request_engine_reg_S2.payload.data.field[0], generator_engine_request_engine_reg_S2.payload.data.field[2], generator_engine_request_engine_reg_S2.payload.data.field[3]);

    end

    engine_alu_ops_kernel inst_engine_alu_ops_kernel (
        .ap_clk             (ap_clk                                                ),
        .areset             (areset_kernel                                         ),
        .clear              (~(configure_engine_param_valid) | engine_alu_ops_clear),
        .config_params_valid(configure_engine_param_valid                          ),
        .config_params      (configure_engine_param_int                            ),
        .data_valid         (response_engine_in_int.valid                          ),
        .data               (response_engine_in_int.payload.data                   ),
        .result_flag        (result_flag                                           ),
        .result             (result_int                                            )
    );

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_engine_out_setup_signal_int = fifo_request_engine_out_signals_out_int.wr_rst_busy | fifo_request_engine_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_engine_out_signals_in_int.wr_en = generator_engine_request_engine_reg_S2.valid;
    assign fifo_request_engine_out_din                  = generator_engine_request_engine_reg_S2.payload;

    // Pop
    assign fifo_request_engine_out_signals_in_int.rd_en = ~fifo_request_engine_out_signals_out_int.empty & fifo_request_engine_out_signals_in_reg.rd_en;
    assign request_engine_out_int.valid                 = fifo_request_engine_out_signals_out_int.valid;
    assign request_engine_out_int.payload               = fifo_request_engine_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
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

endmodule : engine_alu_ops_generator