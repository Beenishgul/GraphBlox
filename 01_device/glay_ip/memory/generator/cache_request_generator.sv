// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_request_generator.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_MEMORY_PKG::*;

module cache_request_generator #(
  parameter         NUM_GRAPH_CLUSTERS        = CU_COUNT_GLOBAL                  ,
  parameter         NUM_MEMORY_REQUESTOR      = 2                                ,
  parameter         NUM_GRAPH_PE              = CU_COUNT_LOCAL                   ,
  parameter integer OUTSTANDING_COUNTER_MAX   = 16                               ,
  parameter         OUTSTANDING_COUNTER_WIDTH = $clog2(OUTSTANDING_COUNTER_MAX+1)
) (
  input  logic                  ap_clk                               ,
  input  logic                  areset                               ,
  input  MemoryRequestPacket    mem_req_in [NUM_MEMORY_REQUESTOR-1:0],
  output GlayCacheRequest       glay_cache_req_out                   ,
  input  logic                  cache_resp_ready                     ,
  output FIFOStateSignalsOutput cache_req_fifo_out_signals           ,
  output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic control_areset;
  logic fifo_areset   ;
  logic arbiter_areset;
  logic counter_areset;

  logic               fifo_642x128_setup_signal                          ;
  logic               mem_resp_valid_reg                                 ;
  MemoryRequestPacket mem_req_reg              [NUM_MEMORY_REQUESTOR-1:0];

  GlayCacheRequest cache_req_reg_S0;
  GlayCacheRequest cache_req_reg_S1;
  GlayCacheRequest cache_req_reg_S2;
// --------------------------------------------------------------------------------------
//  Cache FIFO signals
// --------------------------------------------------------------------------------------
  GlayCacheRequest cache_req_fifo_dout;
  GlayCacheRequest cache_req_fifo_din ;
  GlayCacheRequest cache_req_fifo_comb;


  FIFOStateSignalsOutput cache_req_fifo_out_signals_reg;
  FIFOStateSignalsInput  cache_req_fifo_in_signals     ;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
  logic                                 counter_incr             ;
  logic                                 counter_decr             ;
  logic                                 stall                    ;
  logic [OUTSTANDING_COUNTER_WIDTH-1:0] outstanding_counter_count;

// --------------------------------------------------------------------------------------
// Bus arbiter Signals fifo_642x128_GlayCacheRequest
// --------------------------------------------------------------------------------------
  localparam BUS_ARBITER_N_IN_1_OUT_WIDTH     = NUM_MEMORY_REQUESTOR        ;
  localparam BUS_ARBITER_N_IN_1_OUT_BUS_NUM   = BUS_ARBITER_N_IN_1_OUT_WIDTH;
  localparam BUS_ARBITER_N_IN_1_OUT_BUS_WIDTH = $bits(MemoryRequestPacket)  ;

  MemoryRequestPacket bus_out                                    ;
  MemoryRequestPacket bus_in [0:BUS_ARBITER_N_IN_1_OUT_BUS_NUM-1];

  logic [1:0] grant;
  logic [1:0] req  ;

// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
  cache_request_generator_state current_state;
  cache_request_generator_state next_state   ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    control_areset <= areset;
    fifo_areset    <= areset;
    arbiter_areset <= areset;
    counter_areset <= areset;
  end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      mem_req_reg[0].valid  <= 0;
      mem_req_reg[1].valid  <= 0;
      mem_resp_valid_reg <= 0;
    end
    else begin
      mem_req_reg[0].valid  <= mem_req_in[0].valid;
      mem_req_reg[1].valid  <= mem_req_in[1].valid;
      mem_resp_valid_reg <= cache_resp_ready;
    end
  end

  always_ff @(posedge ap_clk) begin
    mem_req_reg[0].payload  <= mem_req_in[0].payload ;
    mem_req_reg[1].payload  <= mem_req_in[1].payload ;
  end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      fifo_setup_signal          <= 1'b0;
      cache_req_fifo_out_signals <= 1'b0;
    end
    else begin
      fifo_setup_signal          <= fifo_642x128_setup_signal;
      cache_req_fifo_out_signals <= cache_req_fifo_out_signals_reg;
    end
  end

// --------------------------------------------------------------------------------------
// Cache Request state machine
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(control_areset)
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
        if(~stall & ~cache_req_fifo_out_signals_reg.empty)
          next_state = CACHE_REQUEST_GEN_SEND_S2;
        else
          next_state = CACHE_REQUEST_GEN_SEND_S1;
      end
      CACHE_REQUEST_GEN_SEND_S2 : begin
        if(cache_req_fifo_dout.valid)
          next_state = CACHE_REQUEST_GEN_BUSY;
        else
          next_state = CACHE_REQUEST_GEN_SEND_S2;
      end
      CACHE_REQUEST_GEN_BUSY : begin
        if(~cache_req_reg_S1.valid)
          next_state = CACHE_REQUEST_GEN_SEND_S1;
        else
          next_state = CACHE_REQUEST_GEN_BUSY;
      end
    endcase
  end // always_comb

  always_ff @(posedge ap_clk) begin
    case (current_state)
      CACHE_REQUEST_GEN_RESET : begin
        cache_req_fifo_in_signals.rd_en <= 1'b0;
        cache_req_reg_S0.valid          <= 1'b0;
      end
      CACHE_REQUEST_GEN_IDLE : begin
        cache_req_fifo_in_signals.rd_en <= 1'b0;
        cache_req_reg_S0.valid          <= 1'b0;
      end
      CACHE_REQUEST_GEN_SEND_S1 : begin
        cache_req_fifo_in_signals.rd_en <= ~stall & ~cache_req_fifo_out_signals_reg.empty;
        cache_req_reg_S0.valid          <= 1'b0;
      end
      CACHE_REQUEST_GEN_SEND_S2 : begin
        cache_req_fifo_in_signals.rd_en <= 1'b0;
        cache_req_reg_S0.valid          <= cache_req_fifo_dout.valid;
      end
      CACHE_REQUEST_GEN_BUSY : begin
        cache_req_fifo_in_signals.rd_en <= 1'b0;

        if(cache_req_fifo_dout.valid) begin
          cache_req_reg_S0.valid <= 1'b1;
        end else if(cache_req_reg_S1.valid) begin
          cache_req_reg_S0.valid <= cache_req_reg_S0.valid;
        end else begin
          cache_req_reg_S0.valid <= 1'b0;
        end
      end
    endcase
  end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Drive instructions and latch if no change
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      cache_req_reg_S0.payload <= 0;
    end
    else begin
      if(cache_req_fifo_dout.valid) begin
        cache_req_reg_S0.payload <= cache_req_fifo_dout.payload;
      end else if(cache_req_reg_S1.valid) begin
        cache_req_reg_S0.payload <= cache_req_reg_S0.payload;
      end else begin
        cache_req_reg_S0.payload <= 0;
      end
    end
  end

// --------------------------------------------------------------------------------------
// Back to back cache requests when ready logic
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      cache_req_reg_S1 <= 0;
    end
    else begin
      if(~cache_req_reg_S1.valid)begin
        cache_req_reg_S1 <= cache_req_reg_S0;
      end else if(cache_req_reg_S2.valid) begin
        cache_req_reg_S1 <= cache_req_reg_S1;
      end else begin
        cache_req_reg_S1 <= 0;
      end
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      cache_req_reg_S2 <= 0;
    end
    else begin
      if(~cache_req_reg_S2.valid)begin
        cache_req_reg_S2 <= cache_req_reg_S1;
      end else if(glay_cache_req_out.valid) begin
        cache_req_reg_S2 <= cache_req_reg_S2;
      end else begin
        cache_req_reg_S2 <= 0;
      end
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_cache_req_out <= 0;
    end
    else begin
      if(~glay_cache_req_out.valid)begin
        glay_cache_req_out <= cache_req_reg_S2;
      end else if(~cache_resp_ready) begin
        glay_cache_req_out <= glay_cache_req_out;
      end else begin
        glay_cache_req_out <= 0;
      end
    end
  end

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
  assign fifo_642x128_setup_signal       = cache_req_fifo_out_signals_reg.wr_rst_busy | cache_req_fifo_out_signals_reg.rd_rst_busy;
  assign cache_req_fifo_in_signals.wr_en = cache_req_fifo_din.valid;
  assign cache_req_fifo_dout.valid       = cache_req_fifo_out_signals_reg.valid;
// --------------------------------------------------------------------------------------
// FIFO cache requests in fifo_642x128_GlayCacheRequest
// --------------------------------------------------------------------------------------
  fifo_642x128 inst_fifo_642x128_GlayCacheRequest (
    .clk         (ap_clk                                     ),
    .srst        (fifo_areset                                ),
    .din         (cache_req_fifo_din.payload                 ),
    .wr_en       (cache_req_fifo_in_signals.wr_en            ),
    .rd_en       (cache_req_fifo_in_signals.rd_en            ),
    .dout        (cache_req_fifo_dout.payload                ),
    .full        (cache_req_fifo_out_signals_reg.full        ),
    .almost_full (cache_req_fifo_out_signals_reg.almost_full ),
    .empty       (cache_req_fifo_out_signals_reg.empty       ),
    .almost_empty(cache_req_fifo_out_signals_reg.almost_empty),
    .valid       (cache_req_fifo_out_signals_reg.valid       ),
    .prog_full   (cache_req_fifo_out_signals_reg.prog_full   ),
    .prog_empty  (cache_req_fifo_out_signals_reg.prog_empty  ),
    .wr_rst_busy (cache_req_fifo_out_signals_reg.wr_rst_busy ),
    .rd_rst_busy (cache_req_fifo_out_signals_reg.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// Bus arbiter for requests fifo_642x128_GlayCacheRequest
// --------------------------------------------------------------------------------------
  assign bus_in[0] = mem_req_reg[0];
  assign req[0]    = mem_req_reg[0].valid;

  assign bus_in[1] = mem_req_reg[1];
  assign req[1]    = mem_req_reg[1].valid;

  bus_arbiter_N_in_1_out #(
    .WIDTH    (BUS_ARBITER_N_IN_1_OUT_WIDTH    ),
    .BUS_WIDTH(BUS_ARBITER_N_IN_1_OUT_BUS_WIDTH),
    .BUS_NUM  (BUS_ARBITER_N_IN_1_OUT_BUS_NUM  )
  ) inst_bus_arbiter_N_in_1_out (
    .enable (1'b1          ),
    .req    (req           ),
    .bus_in (bus_in        ),
    .grant  (grant         ),
    .bus_out(bus_out       ),
    .ap_clk (ap_clk        ),
    .areset (arbiter_areset)
  );

// --------------------------------------------------------------------------------------
// Generate Cache requests from generic memory requests
// --------------------------------------------------------------------------------------


  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      cache_req_fifo_din.valid <= 0;
    end
    else begin
      cache_req_fifo_din.valid <= bus_out.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    cache_req_fifo_din.payload <= cache_req_fifo_comb.payload;
  end

  always_comb begin
    cache_req_fifo_comb.valid                = 0;
    cache_req_fifo_comb.payload.addr         = bus_out.payload.base_address + bus_out.payload.address_offset;
    cache_req_fifo_comb.payload.wdata        = 0;
    cache_req_fifo_comb.payload.wstrb        = 0;
    cache_req_fifo_comb.payload.force_inv_in = 1'b0;
    cache_req_fifo_comb.payload.wtb_empty_in = 1'b1;
  end

// --------------------------------------------------------------------------------------
// Keep Track of outstanding transactions
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      counter_incr <= 0;
      counter_decr <= 0;
    end
    else begin
      counter_incr <= mem_resp_valid_reg;
      counter_decr <= cache_req_fifo_dout.valid;
    end
  end


  glay_transactions_counter #(
    .C_WIDTH(OUTSTANDING_COUNTER_WIDTH                            ),
    .C_INIT (OUTSTANDING_COUNTER_MAX[0+:OUTSTANDING_COUNTER_WIDTH])
  ) inst_glay_transactions_counter (
    .ap_clk      (ap_clk                           ),
    .ap_clken    (1'b1                             ),
    .areset      (counter_areset                   ),
    .load        (1'b0                             ),
    .incr        (counter_incr                     ),
    .decr        (counter_decr                     ),
    .load_value  ({OUTSTANDING_COUNTER_WIDTH{1'b0}}),
    .stride_value(1                                ),
    .count       (outstanding_counter_count        ),
    .is_zero     (stall                            )
  );

endmodule : cache_request_generator
