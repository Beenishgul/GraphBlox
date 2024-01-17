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
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_forward_data_generator #(parameter
    ID_CU               = 0               ,
    ID_BUNDLE           = 0               ,
    ID_LANE             = 0               ,
    ID_ENGINE           = 0               ,
    ID_MODULE           = 0               ,
    ENGINE_CAST_WIDTH   = 0               ,
    ENGINE_MERGE_WIDTH  = 0               ,
    ENGINES_CONFIG      = 0               ,
    FIFO_WRITE_DEPTH    = 16              ,
    PROG_THRESH         = 8               ,
    PIPELINE_STAGES     = 2               ,
    COUNTER_WIDTH       = M00_AXI4_FE_ADDR_W,
    NUM_BACKTRACK_LANES = 4               ,
    NUM_BUNDLES         = 4
) (
    // System Signals
    input  logic                    ap_clk                                                           ,
    input  logic                    areset                                                           ,
    input  KernelDescriptor         descriptor_in                                                    ,
    input  EnginePacket             response_engine_in                                               ,
    input  FIFOStateSignalsInput    fifo_response_engine_in_signals_in                               ,
    output FIFOStateSignalsOutput   fifo_response_engine_in_signals_out                              ,
    input  FIFOStateSignalsOutput   fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES-1:0],
    output EnginePacket             request_engine_out                                               ,
    input  FIFOStateSignalsInput    fifo_request_engine_out_signals_in                               ,
    output FIFOStateSignalsOutput   fifo_request_engine_out_signals_out                              ,
    output logic                    fifo_setup_signal                                                ,
    output logic                    done_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_generator;
logic areset_fifo     ;

KernelDescriptor descriptor_in_reg;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//  Setup state machine signals
// --------------------------------------------------------------------------------------
logic done_out_reg;

// --------------------------------------------------------------------------------------
//   Engine FIFO signals
// --------------------------------------------------------------------------------------
EnginePacket          response_engine_in_int                ;
EnginePacket          response_engine_in_reg                ;
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;
EnginePacket          generator_engine_request_engine_reg   ;
EnginePacket          request_engine_out_int                ;

// --------------------------------------------------------------------------------------
// Generation Logic - Merge data [0-4] -> Gen
// --------------------------------------------------------------------------------------
logic forward_data_response_engine_in_valid_reg ;
logic forward_data_response_engine_in_valid_flag;

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
logic                  areset_backtrack                                                           ;
logic                  backtrack_configure_route_valid                                            ;
PacketRouteAddress     backtrack_configure_route_in                                               ;
FIFOStateSignalsOutput backtrack_fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES-1:0];
FIFOStateSignalsInput  backtrack_fifo_response_engine_in_signals_out                              ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_generator <= areset;
    areset_fifo      <= areset;
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
        fifo_request_engine_out_signals_in_reg <= 0;
    end
    else begin
        fifo_request_engine_out_signals_in_reg <= fifo_request_engine_out_signals_in;
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
        done_out                 <= 1'b0;
        fifo_empty_reg           <= 1'b1;
    end
    else begin
        fifo_setup_signal        <= (|fifo_response_engine_in_setup_signal_int) | fifo_request_engine_out_setup_signal_int;
        request_engine_out.valid <= request_engine_out_int.valid;
        done_out                 <= done_out_reg;
        fifo_empty_reg           <= fifo_empty_int;
    end
end

assign fifo_empty_int = fifo_response_engine_in_signals_out_int.empty & fifo_request_engine_out_signals_out_int.empty;

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
assign fifo_response_engine_in_signals_in_int.rd_en = ~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en & ~fifo_request_engine_out_signals_out_int.prog_full;
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

always_ff @(posedge ap_clk) begin
    generator_engine_request_engine_reg.valid                                 <= response_engine_in_int.valid & (|response_engine_in_int.payload.meta.route.hops);
    generator_engine_request_engine_reg.payload.meta.route.packet_destination <= response_engine_in_int.payload.meta.route.packet_destination;
    generator_engine_request_engine_reg.payload.meta.route.sequence_source    <= response_engine_in_int.payload.meta.route.sequence_source;
    generator_engine_request_engine_reg.payload.meta.route.sequence_state     <= response_engine_in_int.payload.meta.route.sequence_state;
    generator_engine_request_engine_reg.payload.meta.route.sequence_id        <= response_engine_in_int.payload.meta.route.sequence_id;
    generator_engine_request_engine_reg.payload.data                          <= response_engine_in_int.payload.data;

    if (response_engine_in_int.payload.meta.route.hops >= 1'b1) begin
        generator_engine_request_engine_reg.payload.meta.route.hops <= response_engine_in_int.payload.meta.route.hops - 1'b1;
    end else begin
        generator_engine_request_engine_reg.payload.meta.route.hops <= 0;
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
assign request_engine_out_int.valid                 = fifo_request_engine_out_signals_out_int.valid & fifo_request_engine_out_signals_in_int.rd_en;
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
    .NUM_BUNDLES        (NUM_BUNDLES        )
) inst_backtrack_fifo_lanes_response_signal (
    .ap_clk                                  (ap_clk                                            ),
    .areset                                  (areset_backtrack                                  ),
    .configure_route_valid                   (backtrack_configure_route_valid                   ),
    .configure_route_in                      (backtrack_configure_route_in                      ),
    .fifo_response_lanes_backtrack_signals_in(backtrack_fifo_response_lanes_backtrack_signals_in),
    .fifo_response_engine_in_signals_out     (backtrack_fifo_response_engine_in_signals_out     )
);

endmodule : engine_forward_data_generator