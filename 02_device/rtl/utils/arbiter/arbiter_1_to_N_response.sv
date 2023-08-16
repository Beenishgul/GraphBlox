// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_1_to_N_response.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-06-17 07:17:55
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_CACHE::*;

module arbiter_1_to_N_response #(
  parameter NUM_MEMORY_REQUESTOR = 2                         ,
  parameter DEMUX_DATA_WIDTH     = $bits(MemoryPacketPayload),
  parameter DEMUX_BUS_WIDTH      = NUM_MEMORY_REQUESTOR      ,
  parameter DEMUX_SEL_WIDTH      = NUM_MEMORY_REQUESTOR      ,
  parameter ID_LEVEL             = 1
) (
  input  logic                  ap_clk                                             ,
  input  logic                  areset                                             ,
  input  MemoryPacket           response_in                                        ,
  input  FIFOStateSignalsInput  fifo_response_signals_in [NUM_MEMORY_REQUESTOR-1:0],
  output FIFOStateSignalsOutput fifo_response_signals_out                          ,
  output MemoryPacket           response_out [NUM_MEMORY_REQUESTOR-1:0]            ,
  output logic                  fifo_setup_signal
);

  genvar i;
// --------------------------------------------------------------------------------------
// Cache response variables
// --------------------------------------------------------------------------------------
  logic areset_control  ;
  logic areset_fifo     ;
  logic areset_demux_bus;

  MemoryPacket response_in_reg;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
  MemoryPacketPayload              fifo_response_din                    ;
  MemoryPacket                     fifo_response_dout_int               ;
  MemoryPacketPayload              fifo_response_dout                   ;
  logic [NUM_MEMORY_REQUESTOR-1:0] fifo_response_signals_in_reg_rd_en   ;
  logic [NUM_MEMORY_REQUESTOR-1:0] fifo_response_signals_in_reg_peek_int;
  FIFOStateSignalsInput            fifo_response_signals_in_int         ;
  FIFOStateSignalsOutput           fifo_response_signals_out_int        ;
  logic                            fifo_response_setup_signal_int       ;

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
    areset_control   <= areset;
    areset_fifo      <= areset;
    areset_demux_bus <= areset;
  end

// --------------------------------------------------------------------------------------
//   Drive Inputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control) begin
      response_in_reg.valid <= 1'b0;
    end else begin
      response_in_reg.valid <= response_in.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    response_in_reg.payload <= response_in.payload;
  end

  generate
    for (i=0; i<NUM_MEMORY_REQUESTOR; i++) begin : generate_fifo_response_signals_in_reg_rd_en
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          fifo_response_signals_in_reg_rd_en[i] <= 1'b0;
        end else begin
          fifo_response_signals_in_reg_rd_en[i] <= fifo_response_signals_in[i].rd_en;
        end
      end
    end

 for (i=0; i<NUM_MEMORY_REQUESTOR; i++) begin : generate_fifo_response_signals_in_reg_peek_int
    case (ID_LEVEL)
      0 : begin
        assign fifo_response_signals_in_reg_peek_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.to.id_cu[i]);
      end
      1 : begin
        assign fifo_response_signals_in_reg_peek_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.to.id_bundle[i]);
      end
      2 : begin
        assign fifo_response_signals_in_reg_peek_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.to.id_lane[i]);
      end
      3 : begin
        assign fifo_response_signals_in_reg_peek_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.to.id_engine[i]);
      end
      4 : begin
        assign fifo_response_signals_in_reg_peek_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.to.id_module[i]);
      end
      default : begin
        assign fifo_response_signals_in_reg_peek_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.to.id_cu[i]);
      end
    endcase
  end
  endgenerate

// --------------------------------------------------------------------------------------
//   Drive Outputs
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control) begin
      fifo_setup_signal <= 1'b1;
    end else begin
      fifo_setup_signal <= fifo_response_setup_signal_int;
    end
  end

  always_ff @(posedge ap_clk) begin
    fifo_response_signals_out <= fifo_response_signals_out_int;
  end
// --------------------------------------------------------------------------------------
//  Demux Logic and arbitration
// --------------------------------------------------------------------------------------
  generate
    for (i=0; i < DEMUX_BUS_WIDTH; i++) begin : generate_response_out
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          response_out[i].valid       <= 1'b0;
          demux_bus_data_in_valid[i] <= 1'b0;
        end else begin
          response_out[i].valid       <= demux_bus_data_out_valid[i];

          case (ID_LEVEL)
            0       : begin
              demux_bus_data_in_valid[i] <= fifo_response_dout_int.payload.meta.route.to.id_cu[i] & fifo_response_dout_int.valid;
            end
            1       : begin
              demux_bus_data_in_valid[i] <= fifo_response_dout_int.payload.meta.route.to.id_bundle[i] & fifo_response_dout_int.valid;
            end
            2       : begin
              demux_bus_data_in_valid[i] <= fifo_response_dout_int.payload.meta.route.to.id_lane[i] & fifo_response_dout_int.valid;
            end
            3       : begin
              demux_bus_data_in_valid[i] <= fifo_response_dout_int.payload.meta.route.to.id_engine[i] & fifo_response_dout_int.valid;
            end
            4       : begin
              demux_bus_data_in_valid[i] <= fifo_response_dout_int.payload.meta.route.to.id_module[i] & fifo_response_dout_int.valid;
            end
            default : begin
              demux_bus_data_in_valid[i] <= fifo_response_dout_int.payload.meta.route.to.id_cu[i] & fifo_response_dout_int.valid;
            end
          endcase
        end
      end

      always_ff @(posedge ap_clk) begin
        response_out[i].payload <= demux_bus_data_out[i];
      end
    end

    always_ff @(posedge ap_clk) begin
      demux_bus_data_in <= fifo_response_dout_int.payload;

      case (ID_LEVEL)
        0       : begin
          demux_bus_sel_in <= fifo_response_dout_int.payload.meta.route.to.id_cu[NUM_MEMORY_REQUESTOR-1:0];
        end
        1       : begin
          demux_bus_sel_in <= fifo_response_dout_int.payload.meta.route.to.id_bundle[NUM_MEMORY_REQUESTOR-1:0];
        end
        2       : begin
          demux_bus_sel_in <= fifo_response_dout_int.payload.meta.route.to.id_lane[NUM_MEMORY_REQUESTOR-1:0];
        end
        3       : begin
          demux_bus_sel_in <= fifo_response_dout_int.payload.meta.route.to.id_engine[NUM_MEMORY_REQUESTOR-1:0];
        end
        4       : begin
          demux_bus_sel_in <= fifo_response_dout_int.payload.meta.route.to.id_module[NUM_MEMORY_REQUESTOR-1:0];
        end
        default : begin
          demux_bus_sel_in <= fifo_response_dout_int.payload.meta.route.to.id_cu[NUM_MEMORY_REQUESTOR-1:0];
        end
      endcase
    end
  endgenerate
// --------------------------------------------------------------------------------------
// Demux instantiation
// --------------------------------------------------------------------------------------
  demux_bus_one_hot #(
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
// FIFO memory response out fifo MemoryPacket
// --------------------------------------------------------------------------------------
  // FIFO is resetting
  assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy  | fifo_response_signals_out_int.rd_rst_busy;

  // Push
  assign fifo_response_signals_in_int.wr_en = response_in_reg.valid;
  assign fifo_response_din                  = response_in_reg.payload;

  // Pop
  assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & (fifo_response_signals_in_reg_peek_int == demux_bus_data_in_valid);
  assign fifo_response_dout_int.valid       = fifo_response_signals_out_int.valid & ~fifo_response_signals_out_int.empty & (|fifo_response_signals_in_reg_peek_int);
  assign fifo_response_dout_int.payload     = fifo_response_dout;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(16                        ),
    .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
    .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
    .PROG_THRESH     (8                         ),
    .READ_MODE       ("fwft"                    )
  ) inst_fifo_MemoryPacket (
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

endmodule : arbiter_1_to_N_response