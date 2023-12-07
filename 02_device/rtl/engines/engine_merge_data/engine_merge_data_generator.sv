// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_merge_data_generator.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_merge_data_generator #(parameter
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
    input  logic                  ap_clk                                                         ,
    input  logic                  areset                                                         ,
    input  KernelDescriptor       descriptor_in                                                  ,
    input  MergeDataConfiguration configure_memory_in                                            ,
    input  FIFOStateSignalsInput  fifo_configure_memory_in_signals_in                            ,
    input  MemoryPacket           response_engine_in[(1+ENGINE_MERGE_WIDTH)-1:0]                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in[(1+ENGINE_MERGE_WIDTH)-1:0] ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out[(1+ENGINE_MERGE_WIDTH)-1:0],
    output MemoryPacket           request_engine_out                                             ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in                             ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out                            ,
    output logic                  fifo_setup_signal                                              ,
    output logic                  configure_memory_setup                                         ,
    output logic                  done_out
);

genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_generator;
logic areset_counter  ;
logic areset_fifo     ;

KernelDescriptor descriptor_in_reg;

MergeDataConfiguration configure_memory_reg;

logic configure_memory_setup_reg;
// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
engine_merge_data_generator_state current_state;
engine_merge_data_generator_state next_state   ;

logic done_int_reg;
logic done_out_reg;

logic [(1+ENGINE_MERGE_WIDTH)-1:0] fifo_empty_int;
logic                              fifo_empty_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
MemoryPacket          response_engine_in_int                [(1+ENGINE_MERGE_WIDTH)-1:0];
MemoryPacket          response_engine_in_reg                [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg[(1+ENGINE_MERGE_WIDTH)-1:0];

logic                            configure_engine_param_valid;
MergeDataConfigurationParameters configure_engine_param_int  ;

MemoryPacket          generator_engine_request_engine_reg    ;
MemoryPacket          request_engine_out_int                 ;
FIFOStateSignalsInput fifo_configure_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// Generation Logic - Merge data [0-4] -> Gen
// --------------------------------------------------------------------------------------
logic [(1+ENGINE_MERGE_WIDTH)-1:0] merge_data_response_engine_in_valid_reg ;
logic                              merge_data_response_engine_in_valid_flag;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
MemoryPacketPayload                fifo_response_engine_in_din             [(1+ENGINE_MERGE_WIDTH)-1:0];
MemoryPacketPayload                fifo_response_engine_in_dout            [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsInputInternal      fifo_response_engine_in_signals_in_int  [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsOutInternal        fifo_response_engine_in_signals_out_int [(1+ENGINE_MERGE_WIDTH)-1:0];
logic [(1+ENGINE_MERGE_WIDTH)-1:0] fifo_response_engine_in_setup_signal_int                            ;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
MemoryPacketPayload           fifo_request_engine_out_din             ;
MemoryPacketPayload           fifo_request_engine_out_dout            ;
FIFOStateSignalsInput         fifo_request_engine_out_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_request_engine_out_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_request_engine_out_signals_out_int ;
logic                         fifo_request_engine_out_setup_signal_int;

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
        for (int i=0; i<= ENGINE_MERGE_WIDTH; i++) begin
            fifo_response_engine_in_signals_in_reg[i] <= 0;
            response_engine_in_reg[i].valid           <= 1'b0;
        end

    end
    else begin
        for (int i=0; i<= ENGINE_MERGE_WIDTH; i++) begin
            fifo_response_engine_in_signals_in_reg[i] <= fifo_response_engine_in_signals_in[i];
            response_engine_in_reg[i].valid           <= response_engine_in[i].valid;
        end
    end
end

always_ff @(posedge ap_clk) begin
    for (int i=0; i<= ENGINE_MERGE_WIDTH; i++) begin
        response_engine_in_reg[i].payload <= response_engine_in[i].payload;
    end
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
        fifo_empty_reg           <= (&fifo_empty_int) & fifo_request_engine_out_signals_out_int.empty;
    end
end

always_ff @(posedge ap_clk) begin
    request_engine_out.payload          <= request_engine_out_int.payload;
    fifo_request_engine_out_signals_out <= map_internal_fifo_signals_to_output(fifo_request_engine_out_signals_out_int);
end

always_ff @(posedge ap_clk) begin
    for (int i=0; i<= ENGINE_MERGE_WIDTH; i++) begin
        fifo_response_engine_in_signals_out[i] <= map_internal_fifo_signals_to_output(fifo_response_engine_in_signals_out_int[i]);
    end
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response MemoryPacket
// --------------------------------------------------------------------------------------
generate
    for (i=0; i<(1+ENGINE_MERGE_WIDTH); i++) begin : generate_fifo_response_engine_in_din
        // FIFO is resetting
        assign fifo_response_engine_in_setup_signal_int[i] = fifo_response_engine_in_signals_out_int[i].wr_rst_busy | fifo_response_engine_in_signals_out_int[i].rd_rst_busy;

        // Push
        assign fifo_response_engine_in_signals_in_int[i].wr_en = response_engine_in_reg[i].valid;
        assign fifo_response_engine_in_din[i] = response_engine_in_reg[i].payload;

        // Pop
        assign fifo_response_engine_in_signals_in_int[i].rd_en = (~fifo_response_engine_in_signals_out_int[i].empty & fifo_response_engine_in_signals_in_reg[i].rd_en & ~merge_data_response_engine_in_valid_reg[i] & ~response_engine_in_int[i].valid & configure_engine_param_valid & ~fifo_request_engine_out_signals_out_int.prog_full) | (~configure_engine_param_int.merge_mask[i] & configure_engine_param_valid) ;
        assign response_engine_in_int[i].valid                 = fifo_response_engine_in_signals_out_int[i].valid;
        assign response_engine_in_int[i].payload               = fifo_response_engine_in_dout[i];

        xpm_fifo_sync_wrapper #(
            .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
            .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
            .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
            .PROG_THRESH     (PROG_THRESH               )
        ) inst_fifo_MemoryPacketResponseEngineInput (
            .clk        (ap_clk                                                ),
            .srst       (areset_fifo                                           ),
            .din        (fifo_response_engine_in_din[i]                        ),
            .wr_en      (fifo_response_engine_in_signals_in_int[i].wr_en       ),
            .rd_en      (fifo_response_engine_in_signals_in_int[i].rd_en       ),
            .dout       (fifo_response_engine_in_dout[i]                       ),
            .full       (fifo_response_engine_in_signals_out_int[i].full       ),
            .empty      (fifo_response_engine_in_signals_out_int[i].empty      ),
            .valid      (fifo_response_engine_in_signals_out_int[i].valid      ),
            .prog_full  (fifo_response_engine_in_signals_out_int[i].prog_full  ),
            .wr_rst_busy(fifo_response_engine_in_signals_out_int[i].wr_rst_busy),
            .rd_rst_busy(fifo_response_engine_in_signals_out_int[i].rd_rst_busy)
        );

        assign fifo_empty_int[i] = fifo_response_engine_in_signals_out_int[i].empty;
    end
endgenerate

// --------------------------------------------------------------------------------------
// Serial Read Engine State Machine
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(areset_generator)
        current_state <= ENGINE_MERGE_DATA_GEN_RESET;
    else begin
        current_state <= next_state;
    end
end// always_ff @(posedge ap_clk)

always_comb begin
    next_state = current_state;
    case (current_state)
        ENGINE_MERGE_DATA_GEN_RESET : begin
            next_state = ENGINE_MERGE_DATA_GEN_IDLE;
        end
        ENGINE_MERGE_DATA_GEN_IDLE : begin
            if(descriptor_in_reg.valid)
                next_state = ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE;
            else
                next_state = ENGINE_MERGE_DATA_GEN_IDLE;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE : begin
            if(fifo_configure_memory_in_signals_in.rd_en)
                next_state = ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_TRANS;
            else
                next_state = ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_TRANS : begin
            next_state = ENGINE_MERGE_DATA_GEN_SETUP_MEMORY;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY : begin
            if(configure_memory_reg.valid) // (0) direct mode (get count from memory)
                next_state = ENGINE_MERGE_DATA_GEN_START_TRANS;
            else
                next_state = ENGINE_MERGE_DATA_GEN_SETUP_MEMORY;
        end
        ENGINE_MERGE_DATA_GEN_START_TRANS : begin
            next_state = ENGINE_MERGE_DATA_GEN_START;
        end
        ENGINE_MERGE_DATA_GEN_START : begin
            next_state = ENGINE_MERGE_DATA_GEN_BUSY;
        end
        ENGINE_MERGE_DATA_GEN_BUSY_TRANS : begin
            next_state = ENGINE_MERGE_DATA_GEN_BUSY;
        end
        ENGINE_MERGE_DATA_GEN_BUSY : begin
            if (done_int_reg)
                next_state = ENGINE_MERGE_DATA_GEN_DONE_TRANS;
            else if (fifo_request_engine_out_signals_out_int.prog_full)
                next_state = ENGINE_MERGE_DATA_GEN_PAUSE_TRANS;
            else
                next_state = ENGINE_MERGE_DATA_GEN_BUSY;
        end
        ENGINE_MERGE_DATA_GEN_PAUSE_TRANS : begin
            next_state = ENGINE_MERGE_DATA_GEN_PAUSE;
        end
        ENGINE_MERGE_DATA_GEN_PAUSE : begin
            if (~fifo_request_engine_out_signals_out_int.prog_full)
                next_state = ENGINE_MERGE_DATA_GEN_BUSY_TRANS;
            else
                next_state = ENGINE_MERGE_DATA_GEN_PAUSE;
        end
        ENGINE_MERGE_DATA_GEN_DONE_TRANS : begin
            if (done_int_reg)
                next_state = ENGINE_MERGE_DATA_GEN_DONE;
            else
                next_state = ENGINE_MERGE_DATA_GEN_DONE_TRANS;
        end
        ENGINE_MERGE_DATA_GEN_DONE : begin
            if (done_int_reg)
                next_state = ENGINE_MERGE_DATA_GEN_IDLE;
            else
                next_state = ENGINE_MERGE_DATA_GEN_DONE;
        end
    endcase
end// always_comb

always_ff @(posedge ap_clk) begin
    case (current_state)
        ENGINE_MERGE_DATA_GEN_RESET : begin
            done_int_reg                          <= 1'b1;
            done_out_reg                          <= 1'b1;
            configure_memory_setup_reg            <= 1'b0;
            configure_engine_param_valid          <= 1'b0;
            configure_engine_param_int.merge_mask <= ~0;
            configure_engine_param_int.merge_type <= 0;
        end
        ENGINE_MERGE_DATA_GEN_IDLE : begin
            done_int_reg               <= 1'b1;
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE : begin
            done_int_reg               <= 1'b1;
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_TRANS : begin
            configure_memory_setup_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY : begin
            configure_memory_setup_reg   <= 1'b0;
            configure_engine_param_valid <= 1'b0;
            if(configure_memory_reg.valid)
                configure_engine_param_int <= configure_memory_reg.payload.param;
        end
        ENGINE_MERGE_DATA_GEN_START_TRANS : begin
            done_int_reg                 <= 1'b0;
            done_out_reg                 <= 1'b0;
            configure_engine_param_valid <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_START : begin
            done_int_reg                 <= 1'b0;
            done_out_reg                 <= 1'b1;
            configure_engine_param_valid <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_PAUSE_TRANS : begin
            done_int_reg <= 1'b0;
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_BUSY : begin
            done_int_reg <= 1'b0;
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_BUSY_TRANS : begin
            done_int_reg <= 1'b0;
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_PAUSE : begin
            done_int_reg <= 1'b0;
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_DONE_TRANS : begin
            done_int_reg <= 1'b1;
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_DONE : begin
            done_int_reg                          <= 1'b1;
            done_out_reg                          <= 1'b1;
            configure_engine_param_valid          <= 1'b0;
            configure_engine_param_int.merge_mask <= ~0;
            configure_engine_param_int.merge_type <= 0;
        end
    endcase
end// always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Generation Logic - Merge data [0-4] -> Gen
// --------------------------------------------------------------------------------------
assign merge_data_response_engine_in_valid_flag = &merge_data_response_engine_in_valid_reg;

always_ff @(posedge ap_clk) begin
    if (areset_generator) begin
        merge_data_response_engine_in_valid_reg   <= 0;
        generator_engine_request_engine_reg.valid <= 1'b0;
    end
    else begin
        generator_engine_request_engine_reg.valid <= merge_data_response_engine_in_valid_flag;

        if(response_engine_in_int[0].valid & configure_engine_param_valid & configure_engine_param_int.merge_mask[0]) begin
            merge_data_response_engine_in_valid_reg[0] <= 1'b1;
        end else begin
            if(merge_data_response_engine_in_valid_flag)
                merge_data_response_engine_in_valid_reg[0] <= 1'b0 | ~configure_engine_param_int.merge_mask[0];
            else
                merge_data_response_engine_in_valid_reg[0] <= merge_data_response_engine_in_valid_reg[0] | ~configure_engine_param_int.merge_mask[0];
        end

        for (int j=1; j<(1+ENGINE_MERGE_WIDTH); j++) begin
            if(response_engine_in_int[j].valid & configure_engine_param_valid & configure_engine_param_int.merge_mask[j]) begin
                merge_data_response_engine_in_valid_reg[j] <= 1'b1;
            end else begin
                if(merge_data_response_engine_in_valid_flag)
                    merge_data_response_engine_in_valid_reg[j] <= 1'b0 | ~configure_engine_param_int.merge_mask[j];
                else
                    merge_data_response_engine_in_valid_reg[j] <= merge_data_response_engine_in_valid_reg[j] | ~configure_engine_param_int.merge_mask[j];
            end
        end
    end
end

always_ff @(posedge ap_clk) begin
    if(response_engine_in_int[0].valid & configure_engine_param_valid & configure_engine_param_int.merge_mask[0]) begin
        generator_engine_request_engine_reg.payload.meta          <= response_engine_in_int[0].payload.meta;
        generator_engine_request_engine_reg.payload.data.field[0] <= response_engine_in_int[0].payload.data.field[0];
        // $display("%t - %0d->%0d-%0d", $time,0,response_engine_in_int[0].payload.data.field[1], response_engine_in_int[0].payload.data.field[0]);
    end else begin
        generator_engine_request_engine_reg.payload.meta          <= generator_engine_request_engine_reg.payload.meta ;
        generator_engine_request_engine_reg.payload.data.field[0] <= generator_engine_request_engine_reg.payload.data.field[0];
    end

    for (int j=1; j<(1+ENGINE_MERGE_WIDTH); j++) begin
        if(response_engine_in_int[j].valid & configure_engine_param_valid & configure_engine_param_int.merge_mask[j]) begin
            generator_engine_request_engine_reg.payload.data.field[j] <= response_engine_in_int[j].payload.data.field[0];
            // $display("%t - %0d->%0d-%0d", $time,j,response_engine_in_int[j].payload.data.field[1], response_engine_in_int[j].payload.data.field[0]);
        end else if (configure_engine_param_valid & ~configure_engine_param_int.merge_mask[j]) begin
            generator_engine_request_engine_reg.payload.data.field[j] <= response_engine_in_int[0].payload.data.field[j];
        end else begin
            generator_engine_request_engine_reg.payload.data.field[j] <= generator_engine_request_engine_reg.payload.data.field[j];
        end
    end

    for (int j=(1+ENGINE_MERGE_WIDTH); j<NUM_FIELDS_MEMORYPACKETDATA; j++) begin
        if(response_engine_in_int[0].valid & configure_engine_param_valid) begin
            generator_engine_request_engine_reg.payload.data.field[j] <= response_engine_in_int[0].payload.data.field[j];
        end else begin
            generator_engine_request_engine_reg.payload.data.field[j] <= generator_engine_request_engine_reg.payload.data.field[j] ;
        end
    end
end

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests MemoryPacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_engine_out_setup_signal_int = fifo_request_engine_out_signals_out_int.wr_rst_busy | fifo_request_engine_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_engine_out_signals_in_int.wr_en = generator_engine_request_engine_reg.valid;
assign fifo_request_engine_out_din                  = generator_engine_request_engine_reg.payload;

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

endmodule : engine_merge_data_generator