// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : bundle_arbiter_1_to_N_request.sv
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

module bundle_arbiter_1_to_N_request #(
  parameter NUM_MEMORY_REQUESTOR = 2                      ,
  parameter DEMUX_DATA_WIDTH     = 32                     ,
  parameter DEMUX_BUS_WIDTH      = NUM_MEMORY_REQUESTOR   ,
  parameter DEMUX_SEL_WIDTH      = $clog2(DEMUX_BUS_WIDTH)
) (
  input  logic                  ap_clk                                ,
  input  logic                  areset                                ,
  input  MemoryPacket           request_in                            ,
  input  FIFOStateSignalsInput  fifo_request_signals_in               ,
  output FIFOStateSignalsOutput fifo_request_signals_out              ,
  output MemoryPacket           request_out [NUM_MEMORY_REQUESTOR-1:0],
  output logic                  fifo_setup_signal
);

  genvar i;
// --------------------------------------------------------------------------------------
// Cache request variables
// --------------------------------------------------------------------------------------
  logic areset_control;
  logic areset_fifo   ;
  logic areset_demux  ;

  MemoryPacket request_out_reg[NUM_MEMORY_REQUESTOR-1:0];
  MemoryPacket request_in_reg                           ;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
  MemoryPacketPayload    fifo_request_din             ;
  MemoryPacket           fifo_request_dout_int        ;
  MemoryPacketPayload    fifo_request_dout            ;
  FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
  FIFOStateSignalsInput  fifo_request_signals_in_int  ;
  FIFOStateSignalsOutput fifo_request_signals_out_int ;
  logic                  fifo_request_setup_signal_int;

// --------------------------------------------------------------------------------------
// Demux Logic and arbitration
// --------------------------------------------------------------------------------------
  logic [ DEMUX_SEL_WIDTH-1:0] demux_bus_sel_in                             ;
  logic [ DEMUX_BUS_WIDTH-1:0] demux_bus_data_in_valid                      ;
  logic [DEMUX_DATA_WIDTH-1:0] demux_bus_data_in                            ;
  logic [DEMUX_DATA_WIDTH-1:0] demux_bus_data_out      [DEMUX_BUS_WIDTH-1:0];
  logic [ DEMUX_BUS_WIDTH-1:0] demux_bus_data_out_valid                     ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_control <= areset;
    areset_fifo    <= areset;
    areset_demux   <= areset;
  end

// --------------------------------------------------------------------------------------
//   Drive Inputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control) begin
      request_in_reg.valid        <= 1'b0;
      fifo_request_signals_in_reg <= 0;
    end else begin
      request_in_reg.valid              <= request_in.valid;
      fifo_request_signals_in_reg.rd_en <= fifo_request_signals_in.rd_en;
    end
  end

  always_ff @(posedge ap_clk) begin
    request_in_reg.payload <= request_in.payload;
  end

// --------------------------------------------------------------------------------------
//   Drive Outputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control) begin
      fifo_setup_signal <= 1'b1;
    end else begin
      fifo_setup_signal <= fifo_request_setup_signal_int;
    end
  end

  always_ff @(posedge ap_clk) begin
    fifo_request_signals_out <= fifo_request_signals_out_int;
  end
// --------------------------------------------------------------------------------------
//  Demux Logic and arbitration
// --------------------------------------------------------------------------------------
  generate
    for (i=0; i < DEMUX_BUS_WIDTH; i++) begin : generate_request_out
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          request_out[i].valid       <= 1'b0;
          demux_bus_data_in_valid[i] <= 1'b0;
        end else begin
          request_out[i].valid       <= demux_bus_data_out_valid[i];
          demux_bus_data_in_valid[i] <= (fifo_request_dout_int.payload.meta.id_bundle == i) & fifo_request_dout_int.valid;
        end
      end

      always_ff @(posedge ap_clk) begin
        request_out[i].payload <= demux_bus_data_out[i];
      end
    end
  endgenerate

  always_ff @(posedge ap_clk) begin
    demux_bus_data_in <= fifo_request_dout_int.payload;
    demux_bus_sel_in  <= fifo_request_dout_int.payload.meta.id_bundle;
  end

// --------------------------------------------------------------------------------------
// Demux instantiation
// --------------------------------------------------------------------------------------
  demux_bus #(
    .DATA_WIDTH(DEMUX_DATA_WIDTH),
    .BUS_WIDTH (DEMUX_BUS_WIDTH )
  ) inst_demux_bus (
    .ap_clk        (ap_clk                  ),
    .areset        (areset_demux_bus        ),
    .sel_in        (demux_bus_sel_in        ),
    .data_in_valid (demux_bus_data_in_valid ),
    .data_in       (demux_bus_data_in       ),
    .data_out      (demux_bus_data_out      ),
    .data_out_valid(demux_bus_data_out_valid)
  );

// --------------------------------------------------------------------------------------
// FIFO memory request out fifo MemoryPacket
// --------------------------------------------------------------------------------------
  // FIFO is resetting
  assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy  | fifo_request_signals_out_int.rd_rst_busy;

  // Push
  assign fifo_request_signals_in_int.wr_en = request_in_reg.valid;
  assign fifo_request_din.iob              = request_in_reg.payload.iob;
  assign fifo_request_din.meta             = request_in_reg.payload.meta;

  // Pop
  assign fifo_request_signals_in_int.rd_en          = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
  assign fifo_request_dout_int.valid                = fifo_request_signals_out_int.valid;
  assign fifo_request_dout_int.payload.meta         = fifo_request_dout.meta;
  assign fifo_request_dout_int.payload.data.field_0 = fifo_request_dout.iob.rdata;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(32                        ),
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

endmodule : bundle_arbiter_1_to_N_request
