// -----------------------------------------------------------------------------
//
//    "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_1_to_N_response_memory.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-06-17 07:17:55
// Edifromr : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module arbiter_1_to_N_response_memory #(
  parameter ID_LEVEL              = 1                                                          ,
  parameter ID_BUNDLE             = 0                                                          ,
  parameter NUM_MEMORY_RECEIVER   = 2                                                          ,
  parameter DEMUX_BUS_WIDTH       = NUM_MEMORY_RECEIVER                                        ,
  parameter DEMUX_SEL_WIDTH       = NUM_MEMORY_RECEIVER                                        ,
  parameter NUM_ARBITER_RECEIVER  = 2**$clog2(NUM_MEMORY_RECEIVER)                             ,
  parameter FIFO_ARBITER_DEPTH    = 8                                                          ,
  parameter FIFO_WRITE_DEPTH      = (FIFO_ARBITER_DEPTH>15)? 2**$clog2(FIFO_ARBITER_DEPTH) : 16,
  parameter PROG_THRESH           = (FIFO_WRITE_DEPTH/2)                                       ,
  parameter FIFO_ENABLE           = 0                                                          ,
  parameter PIPELINE_STAGES_DEPTH = 1
) (
  input  logic                  ap_clk                                            ,
  input  logic                  areset                                            ,
  input  MemoryPacketResponse   response_in                                       ,
  input  FIFOStateSignalsInput  fifo_response_signals_in [NUM_MEMORY_RECEIVER-1:0],
  output FIFOStateSignalsOutput fifo_response_signals_out                         ,
  output MemoryPacketResponse   response_out [NUM_MEMORY_RECEIVER-1:0]            ,
  output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Cache response variables
// --------------------------------------------------------------------------------------
logic areset_control;

MemoryPacketResponse            response_in_reg;
MemoryPacketResponse            response_in_int;
logic [NUM_MEMORY_RECEIVER-1:0] id_mask        ;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
MemoryPacketResponsePayload     fifo_response_din                    ;
MemoryPacketResponse            fifo_response_dout_int               ;
MemoryPacketResponse            fifo_response_dout_reg               ;
MemoryPacketResponsePayload     fifo_response_dout                   ;
logic [NUM_MEMORY_RECEIVER-1:0] fifo_response_signals_in_reg_rd_en   ;
logic [NUM_MEMORY_RECEIVER-1:0] fifo_response_signals_in_reg_mask_int;
logic [NUM_MEMORY_RECEIVER-1:0] fifo_response_signals_in_reg_mask_reg;
FIFOStateSignalsInputInternal   fifo_response_signals_in_int         ;
FIFOStateSignalsOutInternal     fifo_response_signals_out_int        ;
logic                           fifo_response_setup_signal_int       ;
logic                           fifo_response_signals_in_int_rd_en   ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------

assign id_mask = ~0;

always_ff @(posedge ap_clk) begin
  areset_control <= areset;
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

always_ff @(posedge ap_clk ) begin
  if(areset_control) begin
    for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
      fifo_response_signals_in_reg_rd_en[i]    <= 1'b0;
      fifo_response_signals_in_reg_mask_reg[i] <= 1'b0;
    end
  end else begin
    for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
      fifo_response_signals_in_reg_rd_en[i]    <= fifo_response_signals_in[i].rd_en;
      fifo_response_signals_in_reg_mask_reg[i] <= fifo_response_signals_in_reg_mask_int[i];
    end
  end
end

generate
  case (ID_LEVEL)
    0 : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
          fifo_response_signals_in_reg_mask_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.packet_source.id_cu[i]);
        end
      end
    end
    1 : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
          fifo_response_signals_in_reg_mask_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.packet_source.id_bundle[i]);
        end
      end
    end
    2 : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
          fifo_response_signals_in_reg_mask_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.packet_source.id_lane[i]);
        end
      end
    end
    3 : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
          fifo_response_signals_in_reg_mask_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.packet_source.id_engine[i]);
        end
      end
    end
    4 : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
          fifo_response_signals_in_reg_mask_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.packet_source.id_module[i]);
        end
      end
    end
    5 : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
          fifo_response_signals_in_reg_mask_int[i] = (fifo_response_signals_in_reg_rd_en[i] & id_mask[i]);
        end
      end
    end
    default : begin
      always_comb begin
        for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
          fifo_response_signals_in_reg_mask_int[i] = (fifo_response_signals_in_reg_rd_en[i] & fifo_response_dout_int.payload.meta.route.packet_source.id_cu[i]);
        end
      end
    end
  endcase
endgenerate

generate
  case (ID_LEVEL)
    0 : begin
      assign fifo_response_signals_in_int_rd_en = (fifo_response_signals_in_reg_mask_reg == fifo_response_dout_int.payload.meta.route.packet_source.id_cu[NUM_MEMORY_RECEIVER-1:0]);
    end
    1 : begin
      assign fifo_response_signals_in_int_rd_en = (fifo_response_signals_in_reg_mask_reg == fifo_response_dout_int.payload.meta.route.packet_source.id_bundle[NUM_MEMORY_RECEIVER-1:0]);
    end
    2 : begin
      assign fifo_response_signals_in_int_rd_en = (fifo_response_signals_in_reg_mask_reg == fifo_response_dout_int.payload.meta.route.packet_source.id_lane[NUM_MEMORY_RECEIVER-1:0]);
    end
    3 : begin
      assign fifo_response_signals_in_int_rd_en = (fifo_response_signals_in_reg_mask_reg == fifo_response_dout_int.payload.meta.route.packet_source.id_engine[NUM_MEMORY_RECEIVER-1:0]);
    end
    4 : begin
      assign fifo_response_signals_in_int_rd_en = (fifo_response_signals_in_reg_mask_reg == fifo_response_dout_int.payload.meta.route.packet_source.id_module[NUM_MEMORY_RECEIVER-1:0]);
    end
    5 : begin
      assign fifo_response_signals_in_int_rd_en = (fifo_response_signals_in_reg_mask_reg == id_mask[NUM_MEMORY_RECEIVER-1:0]);
    end
    default : begin
      assign fifo_response_signals_in_int_rd_en = (fifo_response_signals_in_reg_mask_reg == fifo_response_dout_int.payload.meta.route.packet_source.id_cu[NUM_MEMORY_RECEIVER-1:0]);
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
    fifo_setup_signal <= fifo_response_setup_signal_int;
  end
end

always_ff @(posedge ap_clk) begin
  fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
end

// --------------------------------------------------------------------------------------
//  Demux Logic and arbitration
// --------------------------------------------------------------------------------------
generate
  case (ID_LEVEL)
    0       : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid <= fifo_response_dout_reg.payload.meta.route.packet_source.id_cu[i]     & fifo_response_dout_reg.valid;
          end
        end
      end
    end
    1       : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid <= fifo_response_dout_reg.payload.meta.route.packet_source.id_bundle[i] & fifo_response_dout_reg.valid;
          end
        end
      end
    end
    2       : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid <= fifo_response_dout_reg.payload.meta.route.packet_source.id_lane[i] & fifo_response_dout_reg.valid;
          end
        end
      end
    end
    3       : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid <= fifo_response_dout_reg.payload.meta.route.packet_source.id_engine[i] & fifo_response_dout_reg.valid;
          end
        end
      end
    end
    4       : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid <= fifo_response_dout_reg.payload.meta.route.packet_source.id_module[i] & fifo_response_dout_reg.valid;
          end
        end
      end
    end
    5       : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid <= id_mask[i] & fifo_response_dout_reg.valid;
          end
        end
      end
    end
    default : begin
      always_ff @(posedge ap_clk ) begin
        if(areset_control) begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid       <= 1'b0;
          end
        end else begin
          for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
            response_out[i].valid <= fifo_response_dout_reg.payload.meta.route.packet_source.id_cu[i] & fifo_response_dout_reg.valid;
          end
        end
      end
    end
  endcase
endgenerate

always_ff @(posedge ap_clk) begin
  for (int i=0; i<NUM_MEMORY_RECEIVER; i++) begin
    response_out[i].payload <= fifo_response_dout_reg.payload;
  end
end

always_ff @(posedge ap_clk) begin
  if(areset_control) begin
    fifo_response_dout_reg.valid <= 1'b0;
  end else begin
    fifo_response_dout_reg.valid <= fifo_response_dout_int.valid ;
  end
end

always_ff @(posedge ap_clk) begin
  fifo_response_dout_reg.payload <= fifo_response_dout_int.payload;
end

// --------------------------------------------------------------------------------------
generate
  if (FIFO_ENABLE == 1) begin : gen_fifo
// --------------------------------------------------------------------------------------
// FIFO memory response out fifo MemoryPacketResponse
// --------------------------------------------------------------------------------------
// FIFO is resetting
// --------------------------------------------------------------------------------------
    logic areset_fifo;
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      areset_fifo    <= areset;
    end
    
    assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy  | fifo_response_signals_out_int.rd_rst_busy;
    assign response_in_int = 0;

    case (ID_LEVEL)
      5       : begin
        assign fifo_response_signals_in_int.wr_en = response_in_reg.valid;
      end
      default : begin
        assign fifo_response_signals_in_int.wr_en = response_in_reg.valid & (|response_in_reg.payload.meta.route.packet_source);
      end
    endcase

    assign fifo_response_din = response_in_reg.payload;

// Pop
    assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_int_rd_en;
    assign fifo_response_dout_int.valid       = fifo_response_signals_out_int.valid & fifo_response_signals_in_int_rd_en;
    assign fifo_response_dout_int.payload     = fifo_response_dout;

    xpm_fifo_sync_wrapper #(
      .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                  ),
      .WRITE_DATA_WIDTH($bits(MemoryPacketResponsePayload)),
      .READ_DATA_WIDTH ($bits(MemoryPacketResponsePayload)),
      .PROG_THRESH     (PROG_THRESH                       ),
      .READ_MODE       ("fwft"                            )
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
  end else begin
// --------------------------------------------------------------------------------------
    assign fifo_response_signals_out_int  = 6'b010000;
    assign fifo_response_dout             = 0;
    assign fifo_response_din              = 0;
    assign fifo_response_signals_in_int   = 0;
    assign fifo_response_setup_signal_int = 1'b0;

    case (ID_LEVEL)
      5       : begin
        assign response_in_int.valid = response_in_reg.valid;
      end
      default : begin
        assign response_in_int.valid = response_in_reg.valid & (|response_in_reg.payload.meta.route.packet_source);
      end
    endcase

    assign response_in_int.payload = response_in_reg.payload;

    hyper_pipeline_noreset #(
      .STAGES(PIPELINE_STAGES_DEPTH      ),
      .WIDTH ($bits(MemoryPacketResponse))
    ) inst_hyper_pipeline (
      .ap_clk(ap_clk                ),
      .din   (response_in_int       ),
      .dout  (fifo_response_dout_int)
    );
  end
endgenerate

endmodule : arbiter_1_to_N_response_memory