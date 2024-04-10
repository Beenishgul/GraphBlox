// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_N_to_1_request_control.sv
// Create : 2023-06-17 07:18:54
// Revise : 2023-06-17 07:19:17
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module arbiter_N_to_1_request_control #(
  parameter NUM_CONTROL_REQUESTOR = 2                               ,
  parameter NUM_ARBITER_REQUESTOR = 2**$clog2(NUM_CONTROL_REQUESTOR),
  parameter FIFO_ARBITER_DEPTH    = 8                               ,
  parameter FIFO_WRITE_DEPTH      = (FIFO_ARBITER_DEPTH>15)? 2**$clog2(FIFO_ARBITER_DEPTH) : 16,
  parameter PROG_THRESH           = (FIFO_WRITE_DEPTH/2)            ,
  parameter FIFO_ENABLE           = 1                               ,
  parameter PIPELINE_STAGES_DEPTH = 1
) (
  input  logic                             ap_clk                                ,
  input  logic                             areset                                ,
  input  ControlPacket                     request_in [NUM_CONTROL_REQUESTOR-1:0],
  input  FIFOStateSignalsInput             fifo_request_signals_in               ,
  output FIFOStateSignalsOutput            fifo_request_signals_out              ,
  output logic [NUM_CONTROL_REQUESTOR-1:0] arbiter_grant_out                     ,
  output ControlPacket                     request_out                           ,
  output logic                             fifo_setup_signal
);

genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_control;
logic areset_fifo   ;
logic areset_arbiter;

ControlPacket request_in_reg [NUM_CONTROL_REQUESTOR-1:0];
ControlPacket request_out_int                           ;

// --------------------------------------------------------------------------------------
//  Cache FIFO signals
// --------------------------------------------------------------------------------------
ControlPacketPayload          fifo_request_din             ;
ControlPacket                 fifo_request_din_reg         ;
ControlPacketPayload          fifo_request_dout            ;
FIFOStateSignalsInput         fifo_request_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_request_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_request_signals_out_int ;
logic                         fifo_request_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
logic         arbiter_bus_out_valid                           ;
ControlPacket arbiter_bus_out                                 ;
ControlPacket arbiter_bus_in       [NUM_ARBITER_REQUESTOR-1:0];

logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_grant    ;
logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_request  ;
logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_bus_valid;

// --------------------------------------------------------------------------------------
// FIFO Request INPUT Arbiter ControlPacket
// --------------------------------------------------------------------------------------
ControlPacket request_arbiter_in_int[(NUM_CONTROL_REQUESTOR)-1:0];
ControlPacket request_arbiter_in_reg[(NUM_CONTROL_REQUESTOR)-1:0];

ControlPacketPayload                fifo_request_arbiter_in_din             [(NUM_CONTROL_REQUESTOR)-1:0];
ControlPacketPayload                fifo_request_arbiter_in_dout            [(NUM_CONTROL_REQUESTOR)-1:0];
FIFOStateSignalsInputInternal       fifo_request_arbiter_in_signals_in_int  [(NUM_CONTROL_REQUESTOR)-1:0];
FIFOStateSignalsOutInternal         fifo_request_arbiter_in_signals_out_int [(NUM_CONTROL_REQUESTOR)-1:0];
logic [(NUM_CONTROL_REQUESTOR)-1:0] fifo_request_arbiter_in_setup_signal_int                             ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_control <= areset;
  areset_fifo    <= areset;
  areset_arbiter <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_request_signals_in_reg <= 0;
  end
  else begin
    fifo_request_signals_in_reg <= fifo_request_signals_in;
  end
end

always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    for (int i=0; i<NUM_CONTROL_REQUESTOR; i++) begin
      request_in_reg[i].valid  <= 1'b0;
    end
  end
  else begin
    for (int i=0; i<NUM_CONTROL_REQUESTOR; i++) begin
      request_in_reg[i].valid  <= request_in[i].valid;
    end
  end
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i<NUM_CONTROL_REQUESTOR; i++) begin
    request_in_reg[i].payload  <= request_in[i].payload ;
  end
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal        <= 1'b1;
    fifo_request_signals_out <= 2'b10;
    request_out.valid        <= 1'b0;
  end
  else begin
    fifo_setup_signal        <= fifo_request_setup_signal_int | (|fifo_request_arbiter_in_setup_signal_int);
    fifo_request_signals_out <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
    request_out.valid        <= request_out_int.valid;
  end
end

always_ff @(posedge ap_clk) begin
  request_out.payload <= request_out_int.payload ;
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i<NUM_CONTROL_REQUESTOR; i++) begin : generate_arbiter_bus_in
    arbiter_grant_out[i] <= ~fifo_request_arbiter_in_signals_out_int[i].prog_full & ~fifo_request_signals_out_int.prog_full;
  end
end

// --------------------------------------------------------------------------------------
// Generate requests
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_request_din_reg.valid <= 1'b0;
  end
  else begin
    fifo_request_din_reg.valid <= arbiter_bus_out.valid & arbiter_bus_out_valid;
  end
end

always_ff @(posedge ap_clk) begin
  fifo_request_din_reg.payload <= arbiter_bus_out.payload;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response ControlPacket
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_arbiter) begin
    for (int i=0; i< NUM_CONTROL_REQUESTOR; i++) begin
      request_arbiter_in_reg[i].valid           <= 1'b0;
    end
  end
  else begin
    for (int i=0; i< NUM_CONTROL_REQUESTOR; i++) begin
      request_arbiter_in_reg[i].valid           <= request_in[i].valid;
    end
  end
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i< NUM_CONTROL_REQUESTOR; i++) begin
    request_arbiter_in_reg[i].payload <= request_in[i].payload;
  end
end

generate
  for (i=0; i<(NUM_CONTROL_REQUESTOR); i++) begin : generate_fifo_request_arbiter_in_din
    // FIFO is resetting
    assign fifo_request_arbiter_in_setup_signal_int[i] = fifo_request_arbiter_in_signals_out_int[i].wr_rst_busy | fifo_request_arbiter_in_signals_out_int[i].rd_rst_busy;

    // Push
    assign fifo_request_arbiter_in_signals_in_int[i].wr_en = request_arbiter_in_reg[i].valid;
    assign fifo_request_arbiter_in_din[i] = request_arbiter_in_reg[i].payload;

    // Pop
    assign fifo_request_arbiter_in_signals_in_int[i].rd_en = ~fifo_request_arbiter_in_signals_out_int[i].empty & arbiter_grant[i];
    assign request_arbiter_in_int[i].valid                 = fifo_request_arbiter_in_signals_out_int[i].valid;
    assign request_arbiter_in_int[i].payload               = fifo_request_arbiter_in_dout[i];

    xpm_fifo_sync_wrapper #(
      .FIFO_WRITE_DEPTH(16                         ),
      .WRITE_DATA_WIDTH($bits(ControlPacketPayload)),
      .READ_DATA_WIDTH ($bits(ControlPacketPayload)),
      .PROG_THRESH     (12                         )
    ) inst_fifo_ControlPacketRequestArbiter (
      .clk        (ap_clk                                                ),
      .srst       (areset_fifo                                           ),
      .din        (fifo_request_arbiter_in_din[i]                        ),
      .wr_en      (fifo_request_arbiter_in_signals_in_int[i].wr_en       ),
      .rd_en      (fifo_request_arbiter_in_signals_in_int[i].rd_en       ),
      .dout       (fifo_request_arbiter_in_dout[i]                       ),
      .full       (fifo_request_arbiter_in_signals_out_int[i].full       ),
      .empty      (fifo_request_arbiter_in_signals_out_int[i].empty      ),
      .valid      (fifo_request_arbiter_in_signals_out_int[i].valid      ),
      .prog_full  (fifo_request_arbiter_in_signals_out_int[i].prog_full  ),
      .wr_rst_busy(fifo_request_arbiter_in_signals_out_int[i].wr_rst_busy),
      .rd_rst_busy(fifo_request_arbiter_in_signals_out_int[i].rd_rst_busy)
    );

    // assign fifo_empty_int[i] = fifo_request_arbiter_in_signals_out_int[i].empty;
  end
endgenerate

// --------------------------------------------------------------------------------------
generate
  if (FIFO_ENABLE == 1) begin : gen_fifo
// --------------------------------------------------------------------------------------
// FIFO memory Ready
// --------------------------------------------------------------------------------------
// FIFO is reseting
    assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
    assign fifo_request_signals_in_int.wr_en = fifo_request_din_reg.valid;
    assign fifo_request_din                  = fifo_request_din_reg.payload;

// Pop
    assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
    assign request_out_int.valid             = fifo_request_signals_out_int.valid;
    assign request_out_int.payload           = fifo_request_dout;

    xpm_fifo_sync_wrapper #(
      .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH           ),
      .WRITE_DATA_WIDTH($bits(ControlPacketPayload)),
      .READ_DATA_WIDTH ($bits(ControlPacketPayload)),
      .PROG_THRESH     (PROG_THRESH                )
    ) inst_fifo_ControlPacket (
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
  end else begin
// --------------------------------------------------------------------------------------
    assign fifo_request_signals_out_int  = 6'b010000;
    assign fifo_request_dout             = 0;
    assign fifo_request_din              = 0;
    assign fifo_request_signals_in_int   = 0;
    assign fifo_request_setup_signal_int = 1'b0;

    hyper_pipeline_noreset #(
      .STAGES(PIPELINE_STAGES_DEPTH),
      .WIDTH ($bits(ControlPacket) )
    ) inst_hyper_pipeline (
      .ap_clk(ap_clk              ),
      .din   (fifo_request_din_reg),
      .dout  (request_out_int     )
    );
  end
endgenerate

// --------------------------------------------------------------------------------------
// Bus arbiter for requests fifo_942x16_ControlPacket
// --------------------------------------------------------------------------------------
always_comb begin
  for (int i=0; i<NUM_CONTROL_REQUESTOR; i++) begin : generate_arbiter_bus_in
    arbiter_bus_in[i]    = request_arbiter_in_int[i];
    arbiter_bus_valid[i] = request_arbiter_in_int[i].valid;
    arbiter_request[i]   = ~fifo_request_arbiter_in_signals_out_int[i].empty;
  end
  for (int i=NUM_CONTROL_REQUESTOR; i<NUM_ARBITER_REQUESTOR; i++) begin : generate_arbiter_bus_invalid
    arbiter_bus_in[i]    = 0;
    arbiter_bus_valid[i] = 0;
    arbiter_request[i]   = 0;
  end
end

arbiter_bus_N_in_1_out #(
  .WIDTH    (NUM_CONTROL_REQUESTOR),
  .BUS_WIDTH($bits(ControlPacket) )
) inst_arbiter_bus_N_in_1_out (
  .ap_clk               (ap_clk               ),
  .areset               (areset_arbiter       ),
  .arbiter_req          (arbiter_request      ),
  .arbiter_bus_valid    (arbiter_bus_valid    ),
  .arbiter_bus_in       (arbiter_bus_in       ),
  .arbiter_grant        (arbiter_grant        ),
  .arbiter_bus_out_valid(arbiter_bus_out_valid),
  .arbiter_bus_out      (arbiter_bus_out      )
);

endmodule : arbiter_N_to_1_request_control
