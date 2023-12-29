// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cache_generator_request.sv
// Create : 2023-06-17 07:16:51
// Revise : 2023-06-17 07:16:57
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module cache_generator_request #(
  parameter NUM_MEMORY_REQUESTOR  = 2                              ,
  parameter NUM_ARBITER_REQUESTOR = 2**$clog2(NUM_MEMORY_REQUESTOR),
  parameter FIFO_WRITE_DEPTH      = 32                             ,
  parameter PROG_THRESH           = 16
) (
  input  logic                            ap_clk                               ,
  input  logic                            areset                               ,
  input  KernelDescriptor                 descriptor_in                        ,
  input  MemoryPacket                     request_in [NUM_MEMORY_REQUESTOR-1:0],
  input  FIFOStateSignalsInput            fifo_request_signals_in              ,
  output FIFOStateSignalsOutput           fifo_request_signals_out             ,
  input  logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_request_in                   ,
  output logic [NUM_MEMORY_REQUESTOR-1:0] arbiter_grant_out                    ,
  output CacheRequest                     request_out                          ,
  output logic                            fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_control;
logic areset_fifo   ;
logic areset_arbiter;

MemoryPacket                 request_in_reg   [NUM_MEMORY_REQUESTOR-1:0];
CacheRequest                 request_out_int                            ;
KernelDescriptor             descriptor_in_reg                          ;
logic [M_AXI4_FE_ADDR_W-1:0] address_base                               ;

// --------------------------------------------------------------------------------------
//  Cache FIFO signals
// --------------------------------------------------------------------------------------
CacheRequestPayload           fifo_request_din             ;
CacheRequest                  fifo_request_din_reg         ;
CacheRequest                  fifo_request_comb            ;
CacheRequestPayload           fifo_request_dout            ;
FIFOStateSignalsInput         fifo_request_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_request_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_request_signals_out_int ;
logic                         fifo_request_setup_signal_int;
logic                         fifo_request_push_filter     ;

// --------------------------------------------------------------------------------------
//   Transaction Counter Signals
// --------------------------------------------------------------------------------------
MemoryPacket arbiter_bus_out                           ;
MemoryPacket arbiter_bus_in [NUM_ARBITER_REQUESTOR-1:0];

logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_grant      ;
logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_request    ;
logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_request_reg;
logic [NUM_ARBITER_REQUESTOR-1:0] arbiter_bus_valid  ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_control <= areset;
  areset_fifo    <= areset;
  areset_arbiter <= areset;
end

// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    descriptor_in_reg.valid <= 0;
  end
  else begin
    if(descriptor_in.valid)begin
      descriptor_in_reg.valid   <= descriptor_in.valid;
      descriptor_in_reg.payload <= descriptor_in.payload;
    end
  end
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

always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    for (int i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      request_in_reg[i].valid  <= 1'b0;
    end
  end
  else begin
    for (int i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
      request_in_reg[i].valid  <= request_in[i].valid;
    end
  end
end

always_ff @(posedge ap_clk) begin
  for (int i=0; i < NUM_MEMORY_REQUESTOR; i++) begin
    request_in_reg[i].payload  <= request_in[i].payload ;
  end
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal <= 1'b1;
    arbiter_grant_out <= 0;
    request_out.valid <= 1'b0;
  end
  else begin
    fifo_setup_signal <= fifo_request_setup_signal_int;
    arbiter_grant_out <= arbiter_grant;
    request_out.valid <= request_out_int.valid;
  end
end

always_ff @(posedge ap_clk) begin
  fifo_request_signals_out <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
  request_out.payload      <= request_out_int.payload ;
end

// --------------------------------------------------------------------------------------
// Generate Cache requests from generic memory requests
// --------------------------------------------------------------------------------------

always_comb begin
  address_base = 0;
  if(arbiter_bus_out.valid & descriptor_in_reg.valid) begin
    case (arbiter_bus_out.payload.meta.route.from.id_buffer)
      (1 << 0) : begin
        address_base = descriptor_in_reg.payload.buffer_1;
      end
      (1 << 1) : begin
        address_base = descriptor_in_reg.payload.buffer_2;
      end
      (1 << 2) : begin
        address_base = descriptor_in_reg.payload.buffer_3;
      end
      (1 << 3) : begin
        address_base = descriptor_in_reg.payload.buffer_4;
      end
      (1 << 4) : begin
        address_base = descriptor_in_reg.payload.buffer_5;
      end
      (1 << 5) : begin
        address_base = descriptor_in_reg.payload.buffer_6;
      end
      (1 << 6) : begin
        address_base = descriptor_in_reg.payload.buffer_7;
      end
      (1 << 7) : begin
        address_base = descriptor_in_reg.payload.buffer_8;
      end
      default : begin
        address_base = 0;
      end
    endcase
  end
end

assign fifo_request_comb.valid             = arbiter_bus_out.valid;
assign fifo_request_comb.payload.meta      = arbiter_bus_out.payload.meta;
assign fifo_request_comb.payload.data      = arbiter_bus_out.payload.data;
assign fifo_request_comb.payload.iob.valid = arbiter_bus_out.valid;
// assign fifo_request_comb.payload.iob.addr  = address_base + arbiter_bus_out.payload.meta.address.offset;
assign fifo_request_comb.payload.iob.addr  = arbiter_bus_out.payload.meta.address.base + arbiter_bus_out.payload.meta.address.offset;
assign fifo_request_comb.payload.iob.wdata = arbiter_bus_out.payload.data.field[0];

always_comb begin
  case (arbiter_bus_out.payload.meta.subclass.cmd)
    CMD_MEM_WRITE : begin
      fifo_request_comb.payload.iob.wstrb = {CACHE_FRONTEND_NBYTES{1'b1}};
    end
    default : begin
      fifo_request_comb.payload.iob.wstrb = 0;
    end
  endcase
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
// FIFO cache Ready
// --------------------------------------------------------------------------------------
// FIFO is reseting
assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_push_filter          = (fifo_request_din_reg.payload.meta.subclass.cmd != CMD_MEM_RESPONSE) & (fifo_request_din_reg.payload.meta.subclass.cmd != CMD_INVALID) & (fifo_request_din_reg.payload.meta.subclass.cmd != CMD_ENGINE);
assign fifo_request_signals_in_int.wr_en = fifo_request_din_reg.valid & fifo_request_push_filter;
assign fifo_request_din.iob              = fifo_request_din_reg.payload.iob;
assign fifo_request_din.meta             = fifo_request_din_reg.payload.meta ;
assign fifo_request_din.data             = fifo_request_din_reg.payload.data ;

// Pop
assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
assign request_out_int.valid             = fifo_request_signals_out_int.valid;
assign request_out_int.payload.iob       = fifo_request_dout.iob;
assign request_out_int.payload.meta      = fifo_request_dout.meta;
assign request_out_int.payload.data      = fifo_request_dout.data;

xpm_fifo_sync_bram_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
  .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
  .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
  .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_CacheRequest (
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

// --------------------------------------------------------------------------------------
// Bus arbiter for requests fifo_942x16_CacheRequest
// --------------------------------------------------------------------------------------
always_comb begin
  for (int i=0; i < NUM_MEMORY_REQUESTOR; i++) begin : generate_arbiter_bus_in
    arbiter_bus_in[i]    = request_in_reg[i];
    arbiter_bus_valid[i] = request_in_reg[i].valid;
    arbiter_request[i]   = arbiter_request_reg[i];
  end
  for (int i=NUM_MEMORY_REQUESTOR; i <  NUM_ARBITER_REQUESTOR; i++) begin : generate_arbiter_bus_invalid
    arbiter_bus_in[i]    = 0;
    arbiter_bus_valid[i] = 0;
    arbiter_request[i]   = 0;
  end
end

arbiter_bus_N_in_1_out #(
  .WIDTH    (NUM_MEMORY_REQUESTOR),
  .BUS_WIDTH($bits(MemoryPacket) )
) inst_arbiter_bus_N_in_1_out (
  .ap_clk           (ap_clk           ),
  .areset           (areset_arbiter   ),
  .arbiter_req      (arbiter_request  ),
  .arbiter_bus_valid(arbiter_bus_valid),
  .arbiter_bus_in   (arbiter_bus_in   ),
  .arbiter_grant    (arbiter_grant    ),
  .arbiter_bus_out  (arbiter_bus_out  )
);

endmodule : cache_generator_request
