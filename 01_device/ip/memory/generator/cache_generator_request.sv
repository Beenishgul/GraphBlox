// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_generator_request.sv
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

module cache_generator_request #(
  parameter NUM_GRAPH_CLUSTERS        = CU_COUNT_GLOBAL                  ,
  parameter NUM_MEMORY_REQUESTOR      = 2                                ,
  parameter NUM_GRAPH_PE              = CU_COUNT_LOCAL                   ,
  parameter OUTSTANDING_COUNTER_MAX   = 16                               ,
  parameter OUTSTANDING_COUNTER_WIDTH = $clog2(OUTSTANDING_COUNTER_MAX+1)
) (
  input  logic                            ap_clk                                      ,
  input  logic                            areset                                      ,
  input  MemoryPacket                     memory_request_in [NUM_MEMORY_REQUESTOR-1:0],
  input  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_request_in                          ,
  output logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_grant_out                           ,
  output CacheRequest                     cache_request_out                           ,
  input  logic                            cache_response_ready                        ,
  input  FIFOStateSignalsInput            fifo_request_signals_in                     ,
  output FIFOStateSignalsOutput           fifo_request_signals_out                    ,
  output logic                            fifo_setup_signal
);


// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic areset_control;
  logic areset_fifo   ;
  logic areset_arbiter;
  logic areset_counter;

  logic        fifo_request_setup_signal                          ;
  logic        memory_response_valid_reg                          ;
  MemoryPacket memory_request_reg       [NUM_MEMORY_REQUESTOR-1:0];

  CacheRequest cache_request_reg_S0;
  CacheRequest cache_request_reg_S1;
  CacheRequest cache_request_reg_S2;

// --------------------------------------------------------------------------------------
//  Cache FIFO signals
// --------------------------------------------------------------------------------------
  CacheRequest fifo_request_dout;
  CacheRequest fifo_request_din ;
  CacheRequest fifo_request_comb;

  FIFOStateSignalsOutput fifo_request_signals_out_reg;
  FIFOStateSignalsInput  fifo_request_signals_in_reg ;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
  logic                                 counter_incr  ;
  logic                                 counter_decr  ;
  logic                                 counter_stall ;
  logic [OUTSTANDING_COUNTER_WIDTH-1:0] counter_count ;
  logic [OUTSTANDING_COUNTER_WIDTH-1:0] counter_stride;

  MemoryPacket arbiter_bus_out                          ;
  MemoryPacket arbiter_bus_in [0:NUM_MEMORY_REQUESTOR-1];

  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_grant      ;
  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_request    ;
  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_request_reg;
  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_bus_valid  ;

// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
  cache_generator_request_state current_state;
  cache_generator_request_state next_state   ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_control <= areset;
    areset_fifo    <= areset;
    areset_arbiter <= areset;
    areset_counter <= areset;
  end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      memory_response_valid_reg <= 0;
      arbiter_request_reg       <= 0;
    end
    else begin
      memory_response_valid_reg <= cache_response_ready;
      arbiter_request_reg       <= arbiter_request_in;
    end
  end

  genvar i;
  generate
    for (i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      always_ff @(posedge ap_clk) begin
        if (areset_control) begin
          memory_request_reg[i].valid  <= 0;
        end
        else begin
          memory_request_reg[i].valid  <= memory_request_in[i].valid;
        end
      end

      always_ff @(posedge ap_clk) begin
        memory_request_reg[i].payload  <= memory_request_in[i].payload ;
      end
    end
  endgenerate

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_setup_signal        <= 1'b1;
      fifo_request_signals_out <= 1'b0;
      arbiter_grant_out        <= 0;
    end
    else begin
      fifo_setup_signal        <= fifo_request_setup_signal;
      fifo_request_signals_out <= fifo_request_signals_out_reg;
      arbiter_grant_out        <= arbiter_grant;
    end
  end

// --------------------------------------------------------------------------------------
// Cache Request state machine
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset_control)
      current_state <= CACHE_REQUEST_GEN_RESET;
    else begin
      current_state <= next_state;
    end
  end // always_ff @(posedge ap_clk)

  always_comb begin
    next_state = current_state;
    case (current_state)
      CACHE_REQUEST_GEN_RESET : begin
        next_state = CACHE_REQUEST_GEN_IDLE;
      end
      CACHE_REQUEST_GEN_IDLE : begin
        next_state = CACHE_REQUEST_GEN_SEND_S1;
      end
      CACHE_REQUEST_GEN_SEND_S1 : begin
        if(~counter_stall & ~fifo_request_signals_out_reg.empty & fifo_request_signals_in.rd_en)
          next_state = CACHE_REQUEST_GEN_SEND_S2;
        else
          next_state = CACHE_REQUEST_GEN_SEND_S1;
      end
      CACHE_REQUEST_GEN_SEND_S2 : begin
        if(fifo_request_dout.valid)
          next_state = CACHE_REQUEST_GEN_BUSY;
        else
          next_state = CACHE_REQUEST_GEN_SEND_S2;
      end
      CACHE_REQUEST_GEN_BUSY : begin
        if(~cache_request_reg_S1.valid)
          next_state = CACHE_REQUEST_GEN_SEND_S1;
        else
          next_state = CACHE_REQUEST_GEN_BUSY;
      end
    endcase
  end // always_comb

  always_ff @(posedge ap_clk) begin
    case (current_state)
      CACHE_REQUEST_GEN_RESET : begin
        fifo_request_signals_in_reg.rd_en <= 1'b0;
        cache_request_reg_S0.valid        <= 1'b0;
      end
      CACHE_REQUEST_GEN_IDLE : begin
        fifo_request_signals_in_reg.rd_en <= 1'b0;
        cache_request_reg_S0.valid        <= 1'b0;
      end
      CACHE_REQUEST_GEN_SEND_S1 : begin
        fifo_request_signals_in_reg.rd_en <= ~counter_stall & ~fifo_request_signals_out_reg.empty & fifo_request_signals_in.rd_en;
        cache_request_reg_S0.valid        <= 1'b0;
      end
      CACHE_REQUEST_GEN_SEND_S2 : begin
        fifo_request_signals_in_reg.rd_en <= 1'b0;
        cache_request_reg_S0.valid        <= fifo_request_dout.valid;
      end
      CACHE_REQUEST_GEN_BUSY : begin
        fifo_request_signals_in_reg.rd_en <= 1'b0;

        if(fifo_request_dout.valid) begin
          cache_request_reg_S0.valid <= 1'b1;
        end else if(cache_request_reg_S1.valid) begin
          cache_request_reg_S0.valid <= cache_request_reg_S0.valid;
        end else begin
          cache_request_reg_S0.valid <= 1'b0;
        end
      end
    endcase
  end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Drive instructions and latch if no change
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      cache_request_reg_S0.payload <= 0;
    end
    else begin
      if(fifo_request_dout.valid) begin
        cache_request_reg_S0.payload <= fifo_request_dout.payload;
      end else if(cache_request_reg_S1.valid) begin
        cache_request_reg_S0.payload <= cache_request_reg_S0.payload;
      end else begin
        cache_request_reg_S0.payload <= 0;
      end
    end
  end

// --------------------------------------------------------------------------------------
// Back to back cache requests when ready logic
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      cache_request_reg_S1 <= 0;
    end
    else begin
      if(~cache_request_reg_S1.valid)begin
        cache_request_reg_S1 <= cache_request_reg_S0;
      end else if(cache_request_reg_S2.valid) begin
        cache_request_reg_S1 <= cache_request_reg_S1;
      end else begin
        cache_request_reg_S1 <= 0;
      end
    end
  end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      cache_request_reg_S2 <= 0;
    end
    else begin
      if(~cache_request_reg_S2.valid)begin
        cache_request_reg_S2 <= cache_request_reg_S1;
      end else if(cache_request_out.valid) begin
        cache_request_reg_S2 <= cache_request_reg_S2;
      end else begin
        cache_request_reg_S2 <= 0;
      end
    end
  end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      cache_request_out <= 0;
    end
    else begin
      if(~cache_request_out.valid)begin
        cache_request_out <= cache_request_reg_S2;
      end else if(~cache_response_ready) begin
        cache_request_out <= cache_request_out;
      end else begin
        cache_request_out <= 0;
      end
    end
  end

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
  assign fifo_request_setup_signal         = fifo_request_signals_out_reg.wr_rst_busy | fifo_request_signals_out_reg.rd_rst_busy;
  assign fifo_request_signals_in_reg.wr_en = fifo_request_din.valid;
  assign fifo_request_dout.valid           = fifo_request_signals_out_reg.valid;
// --------------------------------------------------------------------------------------
// FIFO cache requests in fifo_942x16_CacheRequest
// --------------------------------------------------------------------------------------
  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(64                        ),
    .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
    .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
    .PROG_THRESH     (32                        )
  ) inst_fifo_CacheRequest (
    .clk         (ap_clk                                   ),
    .srst        (areset_fifo                              ),
    .din         (fifo_request_din.payload                 ),
    .wr_en       (fifo_request_signals_in_reg.wr_en        ),
    .rd_en       (fifo_request_signals_in_reg.rd_en        ),
    .dout        (fifo_request_dout.payload                ),
    .full        (fifo_request_signals_out_reg.full        ),
    .almost_full (fifo_request_signals_out_reg.almost_full ),
    .empty       (fifo_request_signals_out_reg.empty       ),
    .almost_empty(fifo_request_signals_out_reg.almost_empty),
    .valid       (fifo_request_signals_out_reg.valid       ),
    .prog_full   (fifo_request_signals_out_reg.prog_full   ),
    .prog_empty  (fifo_request_signals_out_reg.prog_empty  ),
    .wr_rst_busy (fifo_request_signals_out_reg.wr_rst_busy ),
    .rd_rst_busy (fifo_request_signals_out_reg.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// Bus arbiter for requests fifo_942x16_CacheRequest
// --------------------------------------------------------------------------------------
  generate
    for (i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      always_comb begin
        arbiter_bus_in[i]    = memory_request_reg[i];
        arbiter_bus_valid[i] = memory_request_reg[i].valid;
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

// --------------------------------------------------------------------------------------
// Generate Cache requests from generic memory requests
// --------------------------------------------------------------------------------------
  always_comb begin
    fifo_request_comb.valid                    = 0;
    fifo_request_comb.payload.iob.addr         = arbiter_bus_out.payload.meta.base_address + arbiter_bus_out.payload.meta.address_offset;
    fifo_request_comb.payload.iob.force_inv_in = 1'b0;
    fifo_request_comb.payload.iob.wtb_empty_in = 1'b1;

    if(arbiter_bus_out.payload.meta.cmd_type == CMD_WRITE)
      fifo_request_comb.payload.iob.wstrb = {L1_CACHE_FRONTEND_NBYTES{1'b1}};
    else
      fifo_request_comb.payload.iob.wstrb = 0;

    fifo_request_comb.payload.iob.wdata = arbiter_bus_out.payload.data.field;
    fifo_request_comb.payload.meta      = arbiter_bus_out.payload.meta;
  end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      fifo_request_din.valid <= 0;
    end
    else begin
      fifo_request_din.valid <= arbiter_bus_out.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    fifo_request_din.payload <= fifo_request_comb.payload;
  end

// --------------------------------------------------------------------------------------
// Keep Track of outstanding transactions
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      counter_incr <= 0;
      counter_decr <= 0;
    end
    else begin
      counter_incr <= memory_response_valid_reg;
      counter_decr <= fifo_request_dout.valid;
    end
  end

  assign counter_stride = 1;

  transactions_counter #(
    .C_WIDTH(OUTSTANDING_COUNTER_WIDTH                            ),
    .C_INIT (OUTSTANDING_COUNTER_MAX[0+:OUTSTANDING_COUNTER_WIDTH])
  ) inst_transactions_counter (
    .ap_clk      (ap_clk                           ),
    .ap_clken    (1'b1                             ),
    .areset      (areset_counter                   ),
    .load        (1'b0                             ),
    .incr        (counter_incr                     ),
    .decr        (counter_decr                     ),
    .load_value  ({OUTSTANDING_COUNTER_WIDTH{1'b0}}),
    .stride_value(counter_stride                   ),
    .count       (counter_count                    ),
    .is_zero     (counter_stall                    )
  );

endmodule : cache_generator_request
