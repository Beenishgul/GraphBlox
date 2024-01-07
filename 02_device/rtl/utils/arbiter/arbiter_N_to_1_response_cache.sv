// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_N_to_1_response_cache.sv
// Create : 2023-06-17 07:18:54
// Revise : 2023-06-17 07:19:17
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module arbiter_N_to_1_response_cache #(
  parameter NUM_MEMORY_RECEIVER   = 2                              ,
  parameter NUM_ARBITER_REQUESTOR = 2**$clog2(NUM_MEMORY_RECEIVER) ,
  parameter FIFO_ARBITER_DEPTH    = 8                              ,
  parameter FIFO_WRITE_DEPTH      = 2**$clog2(FIFO_ARBITER_DEPTH+9),
  parameter PROG_THRESH           = (FIFO_WRITE_DEPTH/2) + 3
) (
  input  logic                           ap_clk                              ,
  input  logic                           areset                              ,
  input  MemoryPacketResponse            response_in [NUM_MEMORY_RECEIVER-1:0],
  input  FIFOStateSignalsInput           fifo_response_signals_in             ,
  output FIFOStateSignalsOutput          fifo_response_signals_out            ,
  output logic [NUM_MEMORY_RECEIVER-1:0] arbiter_grant_out                   ,
  output MemoryPacketResponse            response_out                         ,
  output logic                           fifo_setup_signal
);

genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_control;
logic areset_fifo   ;
logic areset_arbiter;

MemoryPacketResponse response_in_reg [NUM_MEMORY_RECEIVER-1:0];
MemoryPacketResponse response_out_int                         ;
MemoryPacketResponse response_out_reg                         ;

// --------------------------------------------------------------------------------------
//  Cache FIFO signals
// --------------------------------------------------------------------------------------
MemoryPacketResponsePayload   fifo_response_din             ;
MemoryPacketResponse          fifo_response_din_reg         ;
MemoryPacketResponsePayload   fifo_response_dout            ;
FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
MemoryPacketResponse arbiter_bus_out                           ;
MemoryPacketResponse arbiter_bus_in [NUM_ARBITER_REQUESTOR-1:0];

logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_grant    ;
logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_request  ;
logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_bus_valid;

// --------------------------------------------------------------------------------------
// FIFO Request INPUT Arbiter MemoryPacketResponse
// --------------------------------------------------------------------------------------
MemoryPacketResponse response_arbiter_in_int[(NUM_MEMORY_RECEIVER)-1:0];
MemoryPacketResponse response_arbiter_in_reg[(NUM_MEMORY_RECEIVER)-1:0];

MemoryPacketResponsePayload       fifo_response_arbiter_in_din             [(NUM_MEMORY_RECEIVER)-1:0];
MemoryPacketResponsePayload       fifo_response_arbiter_in_dout            [(NUM_MEMORY_RECEIVER)-1:0];
FIFOStateSignalsInputInternal     fifo_response_arbiter_in_signals_in_int  [(NUM_MEMORY_RECEIVER)-1:0];
FIFOStateSignalsOutInternal       fifo_response_arbiter_in_signals_out_int [(NUM_MEMORY_RECEIVER)-1:0];
logic [(NUM_MEMORY_RECEIVER)-1:0] fifo_response_arbiter_in_setup_signal_int                           ;

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
    fifo_response_signals_in_reg <= 0;
  end
  else begin
    fifo_response_signals_in_reg <= fifo_response_signals_in;
  end
end

always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
      response_in_reg[i].valid  <= 1'b0;
    end
  end
  else begin
    for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
      response_in_reg[i].valid  <= response_in[i].valid;
    end
  end
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
    response_in_reg[i].payload  <= response_in[i].payload ;
  end
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal         <= 1'b1;
    fifo_response_signals_out <= 2'b10;
    response_out.valid        <= 1'b0;
  end
  else begin
    fifo_setup_signal         <= fifo_response_setup_signal_int | (|fifo_response_arbiter_in_setup_signal_int);
    fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
    response_out.valid        <= response_out_reg.valid;
  end
end

always_ff @(posedge ap_clk) begin
  response_out.payload <= response_out_reg.payload ;
  response_out_reg     <= response_out_int;
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin : generate_arbiter_bus_in
    arbiter_grant_out[i] <= ~fifo_response_arbiter_in_signals_out_int[i].prog_full & ~fifo_response_signals_out_int.prog_full;
  end
end

// --------------------------------------------------------------------------------------
// Generate requests
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_response_din_reg.valid <= 1'b0;
  end
  else begin
    fifo_response_din_reg.valid <= arbiter_bus_out.valid;
  end
end

always_ff @(posedge ap_clk) begin
  fifo_response_din_reg.payload <= arbiter_bus_out.payload;
end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response MemoryPacketResponse
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_arbiter) begin
    for (int i=0; i< NUM_MEMORY_RECEIVER; i++) begin
      response_arbiter_in_reg[i].valid           <= 1'b0;
    end
  end
  else begin
    for (int i=0; i< NUM_MEMORY_RECEIVER; i++) begin
      response_arbiter_in_reg[i].valid           <= response_in[i].valid;
    end
  end
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i< NUM_MEMORY_RECEIVER; i++) begin
    response_arbiter_in_reg[i].payload <= response_in[i].payload;
  end
end

generate
  for (i=0; i<(NUM_MEMORY_RECEIVER); i++) begin : generate_fifo_response_arbiter_in_din
    // FIFO is resetting
    assign fifo_response_arbiter_in_setup_signal_int[i] = fifo_response_arbiter_in_signals_out_int[i].wr_rst_busy | fifo_response_arbiter_in_signals_out_int[i].rd_rst_busy;

    // Push
    assign fifo_response_arbiter_in_signals_in_int[i].wr_en = response_arbiter_in_reg[i].valid;
    assign fifo_response_arbiter_in_din[i] = response_arbiter_in_reg[i].payload;

    // Pop
    assign fifo_response_arbiter_in_signals_in_int[i].rd_en = ~fifo_response_arbiter_in_signals_out_int[i].empty & arbiter_grant[i];
    assign response_arbiter_in_int[i].valid                 = fifo_response_arbiter_in_signals_out_int[i].valid;
    assign response_arbiter_in_int[i].payload               = fifo_response_arbiter_in_dout[i];

    xpm_fifo_sync_wrapper #(
      .FIFO_WRITE_DEPTH(16                                ),
      .WRITE_DATA_WIDTH($bits(MemoryPacketResponsePayload)),
      .READ_DATA_WIDTH ($bits(MemoryPacketResponsePayload)),
      .PROG_THRESH     (12                                )
    ) inst_fifo_MemoryPacketResponseRequestArbiter (
      .clk        (ap_clk                                                 ),
      .srst       (areset_fifo                                            ),
      .din        (fifo_response_arbiter_in_din[i]                        ),
      .wr_en      (fifo_response_arbiter_in_signals_in_int[i].wr_en       ),
      .rd_en      (fifo_response_arbiter_in_signals_in_int[i].rd_en       ),
      .dout       (fifo_response_arbiter_in_dout[i]                       ),
      .full       (fifo_response_arbiter_in_signals_out_int[i].full       ),
      .empty      (fifo_response_arbiter_in_signals_out_int[i].empty      ),
      .valid      (fifo_response_arbiter_in_signals_out_int[i].valid      ),
      .prog_full  (fifo_response_arbiter_in_signals_out_int[i].prog_full  ),
      .wr_rst_busy(fifo_response_arbiter_in_signals_out_int[i].wr_rst_busy),
      .rd_rst_busy(fifo_response_arbiter_in_signals_out_int[i].rd_rst_busy)
    );

    // assign fifo_empty_int[i] = fifo_response_arbiter_in_signals_out_int[i].empty;
  end
endgenerate

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
// FIFO is reseting
assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy | fifo_response_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_signals_in_int.wr_en = fifo_response_din_reg.valid;
assign fifo_response_din                  = fifo_response_din_reg.payload;

// Pop
assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;
assign response_out_int.valid             = fifo_response_signals_out_int.valid;
assign response_out_int.payload           = fifo_response_dout;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                  ),
  .WRITE_DATA_WIDTH($bits(MemoryPacketResponsePayload)),
  .READ_DATA_WIDTH ($bits(MemoryPacketResponsePayload)),
  .PROG_THRESH     (PROG_THRESH                       )
) inst_fifo_MemoryPacketResponse (
  .clk        (ap_clk                                   ),
  .srst       (areset_fifo                              ),
  .din        (fifo_response_din                        ),
  .wr_en      (fifo_response_signals_in_int.wr_en       ),
  .rd_en      (fifo_response_signals_in_int.rd_en       ),
  .dout       (fifo_response_dout                       ),
  .full       (fifo_response_signals_out_int.full       ),
  .empty      (fifo_response_signals_out_int.empty      ),
  .valid      (fifo_response_signals_out_int.valid      ),
  .prog_full  (fifo_response_signals_out_int.prog_full  ),
  .wr_rst_busy(fifo_response_signals_out_int.wr_rst_busy),
  .rd_rst_busy(fifo_response_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// Bus arbiter for requests fifo_942x16_MemoryPacketResponse
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin : generate_arbiter_bus_in
    arbiter_bus_in[i]    <= response_arbiter_in_int[i];
    arbiter_bus_valid[i] <= response_arbiter_in_int[i].valid;
    arbiter_request[i]   <= ~fifo_response_arbiter_in_signals_out_int[i].empty;
  end
  for (int i=NUM_MEMORY_RECEIVER; i<NUM_ARBITER_REQUESTOR; i++) begin : generate_arbiter_bus_invalid
    arbiter_bus_in[i]    <= 0;
    arbiter_bus_valid[i] <= 1'b0;
    arbiter_request[i]   <= 1'b0;
  end
end

arbiter_bus_N_in_1_out #(
  .WIDTH    (NUM_MEMORY_RECEIVER        ),
  .BUS_WIDTH($bits(MemoryPacketResponse))
) inst_arbiter_bus_N_in_1_out (
  .ap_clk           (ap_clk           ),
  .areset           (areset_arbiter   ),
  .arbiter_req      (arbiter_request  ),
  .arbiter_bus_valid(arbiter_bus_valid),
  .arbiter_bus_in   (arbiter_bus_in   ),
  .arbiter_grant    (arbiter_grant    ),
  .arbiter_bus_out  (arbiter_bus_out  )
);

endmodule : arbiter_N_to_1_response_cache
