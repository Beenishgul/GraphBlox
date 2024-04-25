// -----------------------------------------------------------------------------
//
//    "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_1_to_N_request_cache.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-06-17 07:17:55
// Edifromr : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module arbiter_1_to_N_request_cache #(
  parameter ID_LEVEL             = 1                        ,
  parameter ID_BUNDLE            = 0                        ,
  parameter NUM_MEMORY_REQUESTOR = 2                        ,
  parameter DEMUX_BUS_WIDTH      = NUM_MEMORY_REQUESTOR     ,
  parameter DEMUX_SEL_WIDTH      = NUM_MEMORY_REQUESTOR     ,
  parameter FIFO_ARBITER_DEPTH   = 8                        ,
  // parameter FIFO_WRITE_DEPTH     = 2**$clog2(FIFO_ARBITER_DEPTH)  ,
  parameter FIFO_WRITE_DEPTH     = NUM_MEMORY_REQUESTOR * 32,
  parameter PROG_THRESH          = (FIFO_WRITE_DEPTH/2)
) (
  input  logic                  ap_clk                                            ,
  input  logic                  areset                                            ,
  input  MemoryPacketRequest    request_in                                        ,
  input  FIFOStateSignalsInput  fifo_request_signals_in [NUM_MEMORY_REQUESTOR-1:0],
  output FIFOStateSignalsOutput fifo_request_signals_out                          ,
  output MemoryPacketRequest    request_out [NUM_MEMORY_REQUESTOR-1:0]            ,
  output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Cache request variables
// --------------------------------------------------------------------------------------
logic areset_control;
logic areset_fifo   ;

MemoryPacketRequest              request_in_reg;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
MemoryPacketRequestPayload       fifo_request_din                    ;
MemoryPacketRequest              fifo_request_dout_int               ;
MemoryPacketRequest              fifo_request_dout_reg               ;
MemoryPacketRequestPayload       fifo_request_dout                   ;
logic [NUM_MEMORY_REQUESTOR-1:0] fifo_request_signals_in_reg_rd_en   ;
logic [NUM_MEMORY_REQUESTOR-1:0] fifo_request_signals_in_reg_mask_int;
logic [NUM_MEMORY_REQUESTOR-1:0] fifo_request_signals_in_reg_mask_reg;
FIFOStateSignalsInputInternal    fifo_request_signals_in_int         ;
FIFOStateSignalsOutInternal      fifo_request_signals_out_int        ;
logic                            fifo_request_setup_signal_int       ;
logic                            fifo_request_signals_in_int_rd_en   ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_control <= areset;
  areset_fifo    <= areset;
end

// --------------------------------------------------------------------------------------
//   Drive Inputs
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if(areset_control) begin
    request_in_reg.valid <= 1'b0;
  end else begin
    request_in_reg.valid <= request_in.valid;
  end
end

always_ff @(posedge ap_clk) begin
  request_in_reg.payload <= request_in.payload;
end

always_ff @(posedge ap_clk ) begin
  if(areset_control) begin
    for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
      fifo_request_signals_in_reg_rd_en[i]    <= 1'b0;
      fifo_request_signals_in_reg_mask_reg[i] <= 1'b0;
    end
  end else begin
    for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
      fifo_request_signals_in_reg_rd_en[i]    <= fifo_request_signals_in[i].rd_en;
      fifo_request_signals_in_reg_mask_reg[i] <= fifo_request_signals_in_reg_mask_int[i];
    end
  end
end

generate
  case (ID_LEVEL)
    0 : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
          fifo_request_signals_in_reg_mask_int[i] = (fifo_request_signals_in_reg_rd_en[i] & fifo_request_dout_int.payload.meta.address.id_channel[i]);
        end
      end
    end
    default : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
          fifo_request_signals_in_reg_mask_int[i] = (fifo_request_signals_in_reg_rd_en[i] & fifo_request_dout_int.payload.meta.address.id_channel[i]);
        end
      end
    end
  endcase
endgenerate

generate
  case (ID_LEVEL)
    0 : begin
      assign fifo_request_signals_in_int_rd_en = (fifo_request_signals_in_reg_mask_reg == fifo_request_dout_int.payload.meta.address.id_channel[NUM_MEMORY_REQUESTOR-1:0]);
    end
    default : begin
      assign fifo_request_signals_in_int_rd_en = (fifo_request_signals_in_reg_mask_reg == fifo_request_dout_int.payload.meta.address.id_channel[NUM_MEMORY_REQUESTOR-1:0]);
    end
  endcase
endgenerate

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
  fifo_request_signals_out <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
end

// --------------------------------------------------------------------------------------
//  Demux Logic and arbitration
// --------------------------------------------------------------------------------------
generate
  case (ID_LEVEL)
    0       : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
            request_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
            request_out[i].valid <= fifo_request_dout_reg.payload.meta.address.id_channel[i] & fifo_request_dout_reg.valid;
          end
        end
      end
    end
    default : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
            request_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
            request_out[i].valid <= fifo_request_dout_reg.payload.meta.address.id_channel[i] & fifo_request_dout_reg.valid;
          end
        end
      end
    end
  endcase
endgenerate

always_ff @(posedge ap_clk) begin
  for (int i=0; i<NUM_MEMORY_REQUESTOR; i++) begin
    request_out[i].payload <= fifo_request_dout_reg.payload;
  end
end

always_ff @(posedge ap_clk) begin
  if(areset_control) begin
    fifo_request_dout_reg.valid <= 1'b0;
  end else begin
    fifo_request_dout_reg.valid <= fifo_request_dout_int.valid ;
  end
end

always_ff @(posedge ap_clk) begin
  fifo_request_dout_reg.payload <= fifo_request_dout_int.payload;
end


// --------------------------------------------------------------------------------------
// FIFO memory request out fifo MemoryPacketRequest
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy  | fifo_request_signals_out_int.rd_rst_busy;

// Push
generate
  case (ID_LEVEL)
    5       : begin
      assign fifo_request_signals_in_int.wr_en = request_in_reg.valid;
    end
    default : begin
      assign fifo_request_signals_in_int.wr_en = request_in_reg.valid & (|request_in_reg.payload.meta.address.id_channel);
    end
  endcase
endgenerate

assign fifo_request_din = request_in_reg.payload;

// Pop
assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_int_rd_en;
assign fifo_request_dout_int.valid       = fifo_request_signals_out_int.valid & fifo_request_signals_in_int_rd_en;
assign fifo_request_dout_int.payload     = fifo_request_dout;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                 ),
  .WRITE_DATA_WIDTH($bits(MemoryPacketRequestPayload)),
  .READ_DATA_WIDTH ($bits(MemoryPacketRequestPayload)),
  .PROG_THRESH     (PROG_THRESH                      ),
  .READ_MODE       ("fwft"                           )
) inst_fifo_MemoryPacketRequest (
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

endmodule : arbiter_1_to_N_request_cache