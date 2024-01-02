// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_csr_index_configure_engine.sv
// Create : 2023-07-17 15:02:02
// Revise : 2023-08-28 15:42:14
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_csr_index_configure_engine #(parameter
    ID_CU            = 0 ,
    ID_BUNDLE        = 0 ,
    ID_LANE          = 0 ,
    ID_ENGINE        = 0 ,
    ID_RELATIVE      = 0 ,
    ID_MODULE        = 0 ,
    FIFO_WRITE_DEPTH = 16,
    PROG_THRESH      = 8 ,
    ENGINE_SEQ_WIDTH = 1
) (
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  EnginePacket           response_engine_in                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out,
    output CSRIndexConfiguration  configure_engine_out               ,
    input  FIFOStateSignalsInput  fifo_configure_engine_signals_in   ,
    output FIFOStateSignalsOutput fifo_configure_engine_signals_out  ,
    output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_csr_index_generator;
logic areset_fifo               ;

EnginePacket          response_engine_in_reg;
CSRIndexConfiguration configure_engine_reg  ;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
EnginePacket          fifo_response_engine_in_dout_int      ;
EnginePacket          fifo_response_engine_in_dout_reg      ;
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;
logic                 fifo_response_engine_in_push_filter   ;

// --------------------------------------------------------------------------------------
// Configure FIFO
// --------------------------------------------------------------------------------------
CSRIndexConfigurationPayload  fifo_configure_engine_din             ;
CSRIndexConfiguration         fifo_configure_engine_dout_int        ;
CSRIndexConfigurationPayload  fifo_configure_engine_dout            ;
FIFOStateSignalsInput         fifo_configure_engine_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_configure_engine_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_configure_engine_signals_out_int ;
logic                         fifo_configure_engine_setup_signal_int;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_csr_index_generator <= areset;
    areset_fifo                <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(areset_csr_index_generator) begin
        response_engine_in_reg.valid           <= 1'b0;
        fifo_response_engine_in_signals_in_reg <= 0;
        fifo_configure_engine_signals_in_reg   <= 0;
    end else begin
        response_engine_in_reg.valid                 <= response_engine_in.valid ;
        fifo_response_engine_in_signals_in_reg.rd_en <= fifo_response_engine_in_signals_in.rd_en;
        fifo_configure_engine_signals_in_reg.rd_en   <= fifo_configure_engine_signals_in.rd_en;
    end
end

always_ff @(posedge ap_clk) begin
    response_engine_in_reg.payload <= response_engine_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(areset_csr_index_generator) begin
        fifo_setup_signal          <= 1'b1;
        configure_engine_out.valid <= 0;
    end else begin
        fifo_setup_signal          <= fifo_configure_engine_setup_signal_int;
        configure_engine_out.valid <= fifo_configure_engine_dout_int.valid;
    end
end

always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_signals_out <= map_internal_fifo_signals_to_output(fifo_configure_engine_signals_out_int);
    fifo_configure_engine_signals_out   <= map_internal_fifo_signals_to_output(fifo_configure_engine_signals_out_int);
    configure_engine_out.payload        <= fifo_configure_engine_dout_int.payload;
end

// --------------------------------------------------------------------------------------
// Create Configuration Packet
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(areset_csr_index_generator) begin
        fifo_response_engine_in_dout_reg.valid <= 1'b0;
        configure_engine_reg.valid             <= 1'b0;
    end else begin
        fifo_response_engine_in_dout_reg.valid <= fifo_response_engine_in_dout_int.valid;
        configure_engine_reg.valid             <= fifo_response_engine_in_dout_reg.valid;
    end
end

always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_dout_reg.payload <= fifo_response_engine_in_dout_int.payload;
end

always_ff @(posedge ap_clk) begin
    configure_engine_reg.payload.meta.route.packet_destination <= fifo_response_engine_in_dout_reg.payload.meta.route.packet_destination ;
    configure_engine_reg.payload.meta.address                  <= 0;
    configure_engine_reg.payload.meta.subclass.cmd             <= CMD_ENGINE_PROGRAM;
    configure_engine_reg.payload.data                          <= fifo_response_engine_in_dout_reg.payload.data;
    configure_engine_reg.payload.param.increment               <= 1'b0;
    configure_engine_reg.payload.param.decrement               <= 1'b0;
    configure_engine_reg.payload.param.mode_sequence           <= 1'b0;
    configure_engine_reg.payload.param.mode_buffer             <= 1'b0;
    configure_engine_reg.payload.param.mode_break              <= 1'b0;
    configure_engine_reg.payload.param.index_start             <= fifo_response_engine_in_dout_reg.payload.data.field[0];
    configure_engine_reg.payload.param.index_end               <= fifo_response_engine_in_dout_reg.payload.data.field[0] + fifo_response_engine_in_dout_reg.payload.data.field[1];
    configure_engine_reg.payload.param.stride                  <= 0;
    configure_engine_reg.payload.param.granularity             <= 0;
    configure_engine_reg.payload.param.direction               <= 0;
    configure_engine_reg.payload.param.id_buffer               <= 0;
    configure_engine_reg.payload.param.array_size              <= fifo_response_engine_in_dout_reg.payload.data.field[1];
end

// --------------------------------------------------------------------------------------
// engine response out fifo EnginePacket
// --------------------------------------------------------------------------------------
// Push
assign fifo_response_engine_in_dout_int.valid   = response_engine_in_reg.valid;
assign fifo_response_engine_in_dout_int.payload = response_engine_in_reg.payload;

// --------------------------------------------------------------------------------------
// FIFO engine configure_engine out fifo EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_configure_engine_setup_signal_int = fifo_configure_engine_signals_out_int.wr_rst_busy  | fifo_configure_engine_signals_out_int.rd_rst_busy;

// Push
assign fifo_configure_engine_signals_in_int.wr_en = configure_engine_reg.valid & (|configure_engine_reg.payload.param.array_size);
assign fifo_configure_engine_din                  = configure_engine_reg.payload;

// Pop
assign fifo_configure_engine_signals_in_int.rd_en = ~fifo_configure_engine_signals_out_int.empty & fifo_configure_engine_signals_in_reg.rd_en;
assign fifo_configure_engine_dout_int.valid       = fifo_configure_engine_signals_out_int.valid;
assign fifo_configure_engine_dout_int.payload     = fifo_configure_engine_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                   ),
    .WRITE_DATA_WIDTH($bits(CSRIndexConfigurationPayload)),
    .READ_DATA_WIDTH ($bits(CSRIndexConfigurationPayload)),
    .PROG_THRESH     (FIFO_WRITE_DEPTH- 4                )
) inst_fifo_EnginePacketResponseConigurationInput (
    .clk        (ap_clk                                           ),
    .srst       (areset_fifo                                      ),
    .din        (fifo_configure_engine_din                        ),
    .wr_en      (fifo_configure_engine_signals_in_int.wr_en       ),
    .rd_en      (fifo_configure_engine_signals_in_int.rd_en       ),
    .dout       (fifo_configure_engine_dout                       ),
    .full       (fifo_configure_engine_signals_out_int.full       ),
    .empty      (fifo_configure_engine_signals_out_int.empty      ),
    .valid      (fifo_configure_engine_signals_out_int.valid      ),
    .prog_full  (fifo_configure_engine_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_configure_engine_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_configure_engine_signals_out_int.rd_rst_busy)
);

endmodule : engine_csr_index_configure_engine