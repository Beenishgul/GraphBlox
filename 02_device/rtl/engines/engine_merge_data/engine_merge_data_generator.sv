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
    input  MergeDataConfiguration configure_memory_in                                                                ,
    input  FIFOStateSignalsInput  fifo_configure_memory_in_signals_in                                                ,
    input  EnginePacket           response_engine_in[(1+ENGINE_MERGE_WIDTH)-1:0]                                     ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in[(1+ENGINE_MERGE_WIDTH)-1:0]                     ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out[(1+ENGINE_MERGE_WIDTH)-1:0]                    ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES+ENGINE_CAST_WIDTH-1:0],
    output EnginePacket           request_engine_out                                                                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out                                                ,
    output logic                  fifo_setup_signal                                                                  ,
    output logic                  configure_memory_setup                                                             ,
    output logic                  done_out
);

genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_generator;
logic areset_fifo     ;

MergeDataConfiguration configure_memory_reg;

logic configure_memory_setup_reg;
// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
engine_merge_data_generator_state current_state;
engine_merge_data_generator_state next_state   ;

logic done_out_reg;

logic [(1+ENGINE_MERGE_WIDTH)-1:0] fifo_empty_int;
logic                              fifo_empty_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
EnginePacket          response_engine_in_int                [(1+ENGINE_MERGE_WIDTH)-1:0];
EnginePacket          response_engine_in_reg                [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg[(1+ENGINE_MERGE_WIDTH)-1:0];

logic                            configure_engine_param_valid;
MergeDataConfigurationParameters configure_engine_param_int  ;

EnginePacket          generator_engine_request_engine_reg    ;
EnginePacket          request_engine_out_int                 ;
FIFOStateSignalsInput fifo_configure_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
EnginePacketPayload                fifo_response_engine_in_din             [(1+ENGINE_MERGE_WIDTH)-1:0];
EnginePacketPayload                fifo_response_engine_in_dout            [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsInputInternal      fifo_response_engine_in_signals_in_int  [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsOutInternal        fifo_response_engine_in_signals_out_int [(1+ENGINE_MERGE_WIDTH)-1:0];
logic [(1+ENGINE_MERGE_WIDTH)-1:0] fifo_response_engine_in_setup_signal_int                            ;

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
logic [(1+ENGINE_MERGE_WIDTH)-1:0] merge_mask_assert_int             ;
logic [(1+ENGINE_MERGE_WIDTH)-1:0] fifo_response_signals_in_int_rd_en;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
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
// FIFO INPUT Engine Response EnginePacket
// --------------------------------------------------------------------------------------
generate
// --------------------------------------------------------------------------------------
    for (i=0; i<(1+ENGINE_MERGE_WIDTH); i++) begin : generate_fifo_response_engine_in_din
        // FIFO is resetting
        assign fifo_response_engine_in_setup_signal_int[i] = fifo_response_engine_in_signals_out_int[i].wr_rst_busy | fifo_response_engine_in_signals_out_int[i].rd_rst_busy;

        // Push
        assign fifo_response_engine_in_signals_in_int[i].wr_en = response_engine_in_reg[i].valid;
        assign fifo_response_engine_in_din[i] = response_engine_in_reg[i].payload;

        // Pop
        // assign fifo_response_engine_in_signals_in_int[i].rd_en = (~fifo_response_engine_in_signals_out_int[i].empty & fifo_response_engine_in_signals_in_reg[i].rd_en & ~merge_data_response_engine_in_valid_reg[i] & ~response_engine_in_int[i].valid & configure_engine_param_valid & ~fifo_request_engine_out_signals_out_int.prog_full) | (~configure_engine_param_int.merge_mask[i] & configure_engine_param_valid) ;
        assign fifo_response_engine_in_signals_in_int[i].rd_en = fifo_response_signals_in_int_rd_en[i];
        assign response_engine_in_int[i].valid                 = fifo_response_engine_in_signals_out_int[i].valid;
        assign response_engine_in_int[i].payload               = fifo_response_engine_in_dout[i];

        xpm_fifo_sync_wrapper #(
            .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
            .WRITE_DATA_WIDTH($bits(EnginePacketPayload)),
            .READ_DATA_WIDTH ($bits(EnginePacketPayload)),
            .PROG_THRESH     (PROG_THRESH               )
        ) inst_fifo_EnginePacketResponseEngineInput (
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
// --------------------------------------------------------------------------------------
        assign fifo_empty_int[i] = fifo_response_engine_in_signals_out_int[i].empty;
// --------------------------------------------------------------------------------------
    end
endgenerate

// --------------------------------------------------------------------------------------
always_comb begin
    for (int i=0; i<(1+ENGINE_MERGE_WIDTH); i++) begin
        merge_mask_assert_int[i] = ~fifo_response_engine_in_signals_out_int[i].empty & configure_engine_param_int.merge_mask[i] & configure_engine_param_valid & fifo_response_engine_in_signals_in_reg[i].rd_en & ~fifo_request_engine_out_signals_out_int.prog_full;
    end

    if((merge_mask_assert_int ==  configure_engine_param_int.merge_mask[(1+ENGINE_MERGE_WIDTH)-1:0]) & configure_engine_param_valid)
        fifo_response_signals_in_int_rd_en = configure_engine_param_int.merge_mask[(1+ENGINE_MERGE_WIDTH)-1:0];
    else
        fifo_response_signals_in_int_rd_en = 0;
end

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
            next_state = ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE : begin
            if(fifo_configure_memory_in_signals_in_reg.rd_en)
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
            if (fifo_request_engine_out_signals_out_int.prog_full)
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
        default : begin
            next_state = ENGINE_MERGE_DATA_GEN_RESET;
        end
    endcase
end// always_comb

always_ff @(posedge ap_clk) begin
    case (current_state)
        ENGINE_MERGE_DATA_GEN_RESET : begin
            done_out_reg                 <= 1'b1;
            configure_memory_setup_reg   <= 1'b0;
            configure_engine_param_valid <= 1'b0;
        end
        ENGINE_MERGE_DATA_GEN_IDLE : begin
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE : begin
            done_out_reg               <= 1'b0;
            configure_memory_setup_reg <= 1'b0;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_TRANS : begin
            configure_memory_setup_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_SETUP_MEMORY : begin
            configure_memory_setup_reg <= 1'b0;
            if(configure_memory_reg.valid)
                configure_engine_param_valid <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_START_TRANS : begin
            done_out_reg                 <= 1'b0;
            configure_engine_param_valid <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_START : begin
            done_out_reg                 <= 1'b1;
            configure_engine_param_valid <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_PAUSE_TRANS : begin
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_BUSY : begin
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_BUSY_TRANS : begin
            done_out_reg <= 1'b1;
        end
        ENGINE_MERGE_DATA_GEN_PAUSE : begin
            done_out_reg <= 1'b1;
        end
    endcase
end// always_ff @(posedge ap_clk)

always_ff @(posedge ap_clk) begin
    if(configure_memory_reg.valid)
        configure_engine_param_int <= configure_memory_reg.payload.param;
end

// --------------------------------------------------------------------------------------
// Generation Logic - Merge data [0-4] -> Gen
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    generator_engine_request_engine_reg.valid        <= response_engine_in_int[0].valid;
    generator_engine_request_engine_reg.payload.meta <= response_engine_in_int[0].payload.meta;
end

always_ff @(posedge ap_clk) begin
    for (int i=0; i<(1+ENGINE_MERGE_WIDTH); i++) begin
        if(configure_engine_param_int.merge_mask[i]) begin
            for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
                if(configure_engine_param_int.ops_mask[i][j]) begin
                    generator_engine_request_engine_reg.payload.data.field[j] <= response_engine_in_int[i].payload.data.field[0];
                end
            end
        end else begin
            generator_engine_request_engine_reg.payload.data.field[i] <= response_engine_in_int[0].payload.data.field[i];
        end
    end

    for (int i=(1+ENGINE_MERGE_WIDTH); i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
        generator_engine_request_engine_reg.payload.data.field[i] <= response_engine_in_int[0].payload.data.field[i];
    end
end

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_engine_out_setup_signal_int = fifo_request_engine_out_signals_out_int.wr_rst_busy | fifo_request_engine_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_engine_out_signals_in_int.wr_en = generator_engine_request_engine_reg.valid;
assign fifo_request_engine_out_din                  = generator_engine_request_engine_reg.payload;

// Pop
assign fifo_request_engine_out_signals_in_int.rd_en = ~fifo_request_engine_out_signals_out_int.empty & fifo_request_engine_out_signals_in_reg.rd_en & backtrack_fifo_response_engine_in_signals_out.rd_en;
assign request_engine_out_int.valid                 = fifo_request_engine_out_signals_out_int.valid & fifo_request_engine_out_signals_in_int.rd_en ;
assign request_engine_out_int.payload               = fifo_request_engine_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(EnginePacketPayload)),
    .READ_DATA_WIDTH ($bits(EnginePacketPayload)),
    .PROG_THRESH     (PROG_THRESH               ),
    .READ_MODE       ("fwft"                    )
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

// --------------------------------------------------------------------------------------
// Backtrack FIFO module - Bundle i <- Bundle i-1
// --------------------------------------------------------------------------------------
assign backtrack_configure_route_valid                    = fifo_request_engine_out_signals_out_int.valid;
assign backtrack_configure_route_in                       = fifo_request_engine_out_dout.meta.route.packet_destination;
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

endmodule : engine_merge_data_generator