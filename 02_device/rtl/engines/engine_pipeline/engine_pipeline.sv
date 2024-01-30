// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_pipeline.sv
// Create : 2023-06-14 20:53:28
// Revise : 2023-08-28 15:36:57
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_pipeline #(parameter
    ID_CU               = 0                             ,
    ID_BUNDLE           = 0                             ,
    ID_LANE             = 0                             ,
    ID_ENGINE           = 0                             ,
    ID_RELATIVE         = 0                             ,
    NUM_BACKTRACK_LANES = 4                             ,
    NUM_CHANNELS        = 2                             ,
    ENGINE_CAST_WIDTH   = 0                             ,
    NUM_BUNDLES         = 4                             ,
    ENGINES_CONFIG      = 0                             ,
    FIFO_WRITE_DEPTH    = 16                            ,
    PROG_THRESH         = 8                             ,
    ENGINE_SEQ_WIDTH    = 16                            ,
    ENGINE_SEQ_MIN      = ID_RELATIVE * ENGINE_SEQ_WIDTH,
    PIPELINE_STAGES     = 2
) (
    // System Signals
    input  logic                  ap_clk                                                                             ,
    input  logic                  areset                                                                             ,
    input  KernelDescriptor       descriptor_in                                                                      ,
    input  EnginePacket           response_engine_in                                                                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in                                                 ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out                                                ,
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
    output ControlPacket          request_control_out                                                                ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in                                                ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out                                               ,
    output logic                  fifo_setup_signal                                                                  ,
    output logic                  done_out
);

assign fifo_request_control_out_signals_out = 2'b10;
assign fifo_response_control_in_signals_out = 2'b10;
assign request_control_out                  = 0;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_template_engine;
logic areset_fifo           ;

KernelDescriptor descriptor_in_reg;

EnginePacket         response_engine_in_reg;
MemoryPacketResponse response_memory_in_reg;

EnginePacket         request_engine_out_int;
MemoryPacketRequest  request_memory_out_int;
EnginePacket         response_engine_in_int;
MemoryPacketResponse response_memory_in_int;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
EnginePacketPayload           fifo_response_engine_in_din             ;
EnginePacketPayload           fifo_response_engine_in_dout            ;
FIFOStateSignalsInput         fifo_response_engine_in_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_engine_in_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_response_engine_in_signals_out_int ;
logic                         fifo_response_engine_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
MemoryPacketResponsetPayload  fifo_response_memory_in_din             ;
MemoryPacketResponsePayload   fifo_response_memory_in_dout            ;
FIFOStateSignalsInput         fifo_response_memory_in_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_memory_in_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_response_memory_in_signals_out_int ;
logic                         fifo_response_memory_in_setup_signal_int;

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
// FIFO OUTPUT Memory Request Memory EnginePacket
// --------------------------------------------------------------------------------------
MemoryPacketRequestPayload    fifo_request_memory_out_din             ;
MemoryPacketRequestPayload    fifo_request_memory_out_dout            ;
FIFOStateSignalsInput         fifo_request_memory_out_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_request_memory_out_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_request_memory_out_signals_out_int ;
logic                         fifo_request_memory_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// Generate Bundles
// --------------------------------------------------------------------------------------
logic                  areset_template                             ;
KernelDescriptor       template_descriptor_in                      ;
EnginePacket           template_response_engine_in                 ;
FIFOStateSignalsOutput template_fifo_response_engine_in_signals_out;
MemoryPacketResponse   template_response_memory_in                 ;
FIFOStateSignalsOutput template_fifo_response_memory_in_signals_out;
EnginePacket           template_request_engine_out                 ;
MemoryPacketRequest    template_request_memory_out                 ;
logic                  template_fifo_setup_signal                  ;
logic                  template_done_out                           ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_template_engine <= areset;
    areset_fifo            <= areset;
end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_template_engine) begin
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
    if (areset_template_engine) begin
        fifo_response_engine_in_signals_in_reg <= 0;
        fifo_request_engine_out_signals_in_reg <= 0;
        fifo_response_memory_in_signals_in_reg <= 0;
        fifo_request_memory_out_signals_in_reg <= 0;
        response_engine_in_reg.valid           <= 1'b0;
        response_memory_in_reg.valid           <= 1'b0;
    end
    else begin
        fifo_response_engine_in_signals_in_reg <= fifo_response_engine_in_signals_in;
        fifo_request_engine_out_signals_in_reg <= fifo_request_engine_out_signals_in;
        fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
        fifo_request_memory_out_signals_in_reg <= fifo_request_memory_out_signals_in;
        response_engine_in_reg.valid           <= response_engine_in.valid;
        response_memory_in_reg.valid           <= 1'b0;
    end
end

always_ff @(posedge ap_clk) begin
    response_engine_in_reg.payload <= response_engine_in.payload;
    response_memory_in_reg.payload <= response_memory_in.payload;
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_template_engine) begin
        fifo_setup_signal        <= 1'b1;
        request_engine_out.valid <= 1'b0;
        request_memory_out.valid <= 1'b0;
        done_out                 <= 1'b0;
        fifo_empty_reg           <= 1'b1;
    end
    else begin
        fifo_setup_signal        <= fifo_response_engine_in_setup_signal_int | fifo_response_memory_in_setup_signal_int | fifo_request_engine_out_setup_signal_int | fifo_request_memory_out_setup_signal_int | template_fifo_setup_signal;
        request_engine_out.valid <= request_engine_out_int.valid;
        request_memory_out.valid <= request_memory_out_int.valid;
        done_out                 <= template_done_out & fifo_empty_reg;
        fifo_empty_reg           <= fifo_empty_int;
    end
end

always_ff @(posedge ap_clk) begin
    fifo_response_engine_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_engine_in_signals_out_int);
    fifo_request_engine_out_signals_out <= map_internal_fifo_signals_to_output(fifo_request_engine_out_signals_out_int);
    fifo_response_memory_in_signals_out <= map_internal_fifo_signals_to_output(fifo_response_memory_in_signals_out_int);
    fifo_request_memory_out_signals_out <= map_internal_fifo_signals_to_output(fifo_request_memory_out_signals_out_int);
    request_engine_out.payload          <= request_engine_out_int.payload;
    request_memory_out.payload          <= request_memory_out_int.payload ;
end

assign fifo_empty_int = fifo_response_engine_in_signals_out_int.empty & fifo_response_memory_in_signals_out_int.empty & fifo_request_engine_out_signals_out_int.empty & fifo_request_memory_out_signals_out_int.empty;

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_engine_in_setup_signal_int = fifo_response_engine_in_signals_out_int.wr_rst_busy | fifo_response_engine_in_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_engine_in_signals_in_int.wr_en = response_engine_in_reg.valid;
assign fifo_response_engine_in_din                  = response_engine_in_reg.payload;

// Pop
assign fifo_response_engine_in_signals_in_int.rd_en = ~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en & ~template_fifo_response_engine_in_signals_out.prog_full;
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
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_memory_in_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy | fifo_response_memory_in_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid;
assign fifo_response_memory_in_din                  = response_memory_in_reg.payload;

// Pop
assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~template_fifo_response_memory_in_signals_out.prog_full;
assign response_memory_in_int.valid                 = fifo_response_memory_in_signals_out_int.valid;
assign response_memory_in_int.payload               = fifo_response_memory_in_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                  ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketResponsePayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketResponsePayload)),
    .PROG_THRESH     (PROG_THRESH                       )
) inst_fifo_EnginePacketResponseMemoryInput (
    .clk        (ap_clk                                             ),
    .srst       (areset_fifo                                        ),
    .din        (fifo_response_memory_in_din                        ),
    .wr_en      (fifo_response_memory_in_signals_in_int.wr_en       ),
    .rd_en      (fifo_response_memory_in_signals_in_int.rd_en       ),
    .dout       (fifo_response_memory_in_dout                       ),
    .full       (fifo_response_memory_in_signals_out_int.full       ),
    .empty      (fifo_response_memory_in_signals_out_int.empty      ),
    .valid      (fifo_response_memory_in_signals_out_int.valid      ),
    .prog_full  (fifo_response_memory_in_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_response_memory_in_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_response_memory_in_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_engine_out_setup_signal_int = fifo_request_engine_out_signals_out_int.wr_rst_busy | fifo_request_engine_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_engine_out_signals_in_int.wr_en = template_request_engine_out.valid;
assign fifo_request_engine_out_din                  = template_request_engine_out.payload;

// Pop
assign fifo_request_engine_out_signals_in_int.rd_en = ~fifo_request_engine_out_signals_out_int.empty & fifo_request_engine_out_signals_in_reg.rd_en;
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

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_memory_out_signals_in_int.wr_en = template_request_memory_out.valid;
assign fifo_request_memory_out_din                  = template_request_memory_out.payload;

// Pop
assign fifo_request_memory_out_signals_in_int.rd_en = ~fifo_request_memory_out_signals_out_int.empty & fifo_request_memory_out_signals_in_reg.rd_en;
assign request_memory_out_int.valid                 = fifo_request_memory_out_signals_out_int.valid;
assign request_memory_out_int.payload               = fifo_request_memory_out_dout;

xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                 ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketRequestPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketRequestPayload)),
    .PROG_THRESH     (PROG_THRESH                      )
) inst_fifo_EnginePacketRequestMemoryOutput (
    .clk        (ap_clk                                             ),
    .srst       (areset_fifo                                        ),
    .din        (fifo_request_memory_out_din                        ),
    .wr_en      (fifo_request_memory_out_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_memory_out_signals_in_int.rd_en       ),
    .dout       (fifo_request_memory_out_dout                       ),
    .full       (fifo_request_memory_out_signals_out_int.full       ),
    .empty      (fifo_request_memory_out_signals_out_int.empty      ),
    .valid      (fifo_request_memory_out_signals_out_int.valid      ),
    .prog_full  (fifo_request_memory_out_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_memory_out_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_memory_out_signals_out_int.rd_rst_busy)
);


// --------------------------------------------------------------------------------------
// Generate Engine - Engine Logic Pipeline
// --------------------------------------------------------------------------------------
assign template_response_engine_in = response_engine_in_int;
assign template_response_memory_in = response_memory_in_int;

assign areset_template        = areset_template_engine;
assign template_descriptor_in = descriptor_in_reg;

hyper_pipeline #(
    .STAGES(PIPELINE_STAGES    ),
    .WIDTH ($bits(EnginePacket))
) inst_hyper_pipeline_template_response_engine_in (
    .ap_clk(ap_clk                     ),
    .areset(areset_template            ),
    .din   (template_response_engine_in),
    .dout  (template_request_engine_out)
);

// --------------------------------------------------------------------------------------
// PIPELINE FIFO signals EMPTY
// --------------------------------------------------------------------------------------
assign template_fifo_setup_signal = 1'b0;
assign template_done_out          = 1'b1;

assign template_request_memory_out                  = 0;
assign template_fifo_response_engine_in_signals_out = map_internal_fifo_signals_to_output(fifo_request_engine_out_signals_out_int);
assign template_fifo_response_memory_in_signals_out = map_internal_fifo_signals_to_output(fifo_request_memory_out_signals_out_int);

endmodule : engine_pipeline