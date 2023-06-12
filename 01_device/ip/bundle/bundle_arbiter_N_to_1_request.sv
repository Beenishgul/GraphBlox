// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : bundle_arbiter_N_to_1_request.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_CACHE::*;

module bundle_arbiter_N_to_1_request #(parameter NUM_MEMORY_REQUESTOR      = 2) (
  input  logic                            ap_clk                               ,
  input  logic                            areset                               ,
  input  MemoryPacket                     request_in [NUM_MEMORY_REQUESTOR-1:0],
  input  FIFOStateSignalsInput            fifo_request_signals_in              ,
  output FIFOStateSignalsOutput           fifo_request_signals_out             ,
  input  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_request_in                   ,
  output logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_grant_out                    ,
  output MemoryPacket                     request_out                          ,
  output logic                            fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
  logic areset_control;
  logic areset_fifo   ;
  logic areset_arbiter;

  MemoryPacket request_in_reg [NUM_MEMORY_REQUESTOR-1:0];
  MemoryPacket request_out_int                          ;

// --------------------------------------------------------------------------------------
//  Cache FIFO signals
// --------------------------------------------------------------------------------------
  MemoryPacketPayload    fifo_request_din             ;
  MemoryPacket           fifo_request_din_reg         ;
  MemoryPacket           fifo_request_comb            ;
  MemoryPacketPayload    fifo_request_dout            ;
  FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
  FIFOStateSignalsInput  fifo_request_signals_in_int  ;
  FIFOStateSignalsOutput fifo_request_signals_out_int ;
  logic                  fifo_request_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
  MemoryPacket arbiter_bus_out                          ;
  MemoryPacket arbiter_bus_in [NUM_MEMORY_REQUESTOR-1:0];

  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_grant      ;
  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_request    ;
  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_request_reg;
  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_bus_valid  ;

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
      arbiter_request_reg         <= 0;
    end
    else begin
      fifo_request_signals_in_reg <= fifo_request_signals_in;
      arbiter_request_reg         <= arbiter_request_in;
    end
  end

  genvar i;
  generate
    for (i=0; i < NUM_MEMORY_REQUESTOR; i++) begin : generate_request_in_reg
      always_ff @(posedge ap_clk) begin
        if (areset_control) begin
          request_in_reg[i].valid  <= 1'b0;
        end
        else begin
          request_in_reg[i].valid  <= request_in[i].valid;
        end
      end

      always_ff @(posedge ap_clk) begin
        request_in_reg[i].payload  <= request_in[i].payload ;
      end
    end
  endgenerate

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_setup_signal        <= 1'b1;
      fifo_request_signals_out <= 0;
      arbiter_grant_out        <= 0;
      request_out.valid        <= 1'b0;
    end
    else begin
      fifo_setup_signal        <= fifo_request_setup_signal_int;
      fifo_request_signals_out <= fifo_request_signals_out_int;
      arbiter_grant_out        <= arbiter_grant;
      request_out.valid        <= request_out_int.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    request_out.payload <= request_out_int.payload ;
  end

// --------------------------------------------------------------------------------------
// Generate memory requests from generic memory requests
// --------------------------------------------------------------------------------------
  always_comb begin
    fifo_request_comb.valid   = arbiter_bus_out.valid;
    fifo_request_comb.payload = arbiter_bus_out.payload;
  end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_request_din_reg.valid <= 0;
    end
    else begin
      fifo_request_din_reg.valid <= fifo_request_comb.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    fifo_request_din_reg.payload <= fifo_request_comb.payload;
  end
// --------------------------------------------------------------------------------------
// FIFO memory Ready
// --------------------------------------------------------------------------------------
  // FIFO is reseting
  assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

  // Push
  assign fifo_request_signals_in_int.wr_en = fifo_request_din_reg.valid;
  assign fifo_request_din                  = fifo_request_din_reg.payload ;

  // Pop
  assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
  assign request_out_int.valid             = fifo_request_signals_out_int.valid;
  assign request_out_int.payload           = fifo_request_dout;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(16                        ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (8                         )
  ) inst_fifo_MemoryPacket (
    .clk         (ap_clk                                   ),
    .srst        (areset_fifo                              ),
    .din         (fifo_request_din                         ),
    .wr_en       (fifo_request_signals_in_int.wr_en        ),
    .rd_en       (fifo_request_signals_in_int.rd_en        ),
    .dout        (fifo_request_dout                        ),
    .full        (fifo_request_signals_out_int.full        ),
    .almost_full (fifo_request_signals_out_int.almost_full ),
    .empty       (fifo_request_signals_out_int.empty       ),
    .almost_empty(fifo_request_signals_out_int.almost_empty),
    .valid       (fifo_request_signals_out_int.valid       ),
    .prog_full   (fifo_request_signals_out_int.prog_full   ),
    .prog_empty  (fifo_request_signals_out_int.prog_empty  ),
    .wr_rst_busy (fifo_request_signals_out_int.wr_rst_busy ),
    .rd_rst_busy (fifo_request_signals_out_int.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// Bus arbiter for requests fifo_942x16_MemoryPacket
// --------------------------------------------------------------------------------------
  generate
    for (i=0; i < NUM_MEMORY_REQUESTOR; i++) begin : generate_arbiter_bus_in
      always_comb begin
        arbiter_bus_in[i]    = request_in_reg[i];
        arbiter_bus_valid[i] = request_in_reg[i].valid;
        arbiter_request[i]   = arbiter_request_reg[i];
      end
    end
  endgenerate

  arbiter_bus_N_in_1_out #(
    .WIDTH    (NUM_MEMORY_REQUESTOR),
    .BUS_WIDTH($bits(MemoryPacket) )
  ) inst_arbiter_bus_N_in_1_out (
    .ap_clk           (ap_clk           ),
    .areset           (areset_arbiter   ),
    .arbiter_enable   (1'b1             ),
    .arbiter_req      (arbiter_request  ),
    .arbiter_bus_valid(arbiter_bus_valid),
    .arbiter_bus_in   (arbiter_bus_in   ),
    .arbiter_grant    (arbiter_grant    ),
    .arbiter_bus_out  (arbiter_bus_out  )
  );

endmodule : bundle_arbiter_N_to_1_request
