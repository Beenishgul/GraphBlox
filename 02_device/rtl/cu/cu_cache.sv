// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cu_cache.sv
// Create : 2023-06-13 23:21:43
// Revise : 2023-08-28 18:21:31
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module cu_cache #(
  parameter FIFO_WRITE_DEPTH = 64,
  parameter PROG_THRESH      = 32
) (
  // System Signals
  input  logic                             ap_clk                   ,
  input  logic                             areset                   ,
  input  KernelDescriptor                  descriptor_in            ,
  input  MemoryPacketRequest               request_in               ,
  output FIFOStateSignalsOutput            fifo_request_signals_out ,
  input  FIFOStateSignalsInput             fifo_request_signals_in  ,
  output MemoryPacketResponse              response_out             ,
  output FIFOStateSignalsOutput            fifo_response_signals_out,
  input  FIFOStateSignalsInput             fifo_response_signals_in ,
  output logic                             fifo_setup_signal        ,
  input  AXI4MIDMasterReadInterfaceInput   m_axi_read_in            ,
  output AXI4MIDMasterReadInterfaceOutput  m_axi_read_out           ,
  input  AXI4MIDMasterWriteInterfaceInput  m_axi_write_in           ,
  output AXI4MIDMasterWriteInterfaceOutput m_axi_write_out          ,
  output logic                             done_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic            areset_fifo      ;
logic            areset_cache     ;
logic            areset_control   ;
KernelDescriptor descriptor_in_reg;

MemoryPacketRequest request_in_reg      ;
CacheRequest        cache_request_in_reg;
CacheResponse       response_in_int     ;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
AXI4MIDMasterReadInterface  m_axi_read ;
AXI4MIDMasterWriteInterface m_axi_write;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
CacheRequestPayload   cache_request_mem    ;
CacheRequestPayload   cache_request_mem_reg;
CacheResponsePayload  cache_response_mem   ;
CacheControlIOBOutput cache_ctrl_in        ;
CacheControlIOBOutput cache_ctrl_out       ;

// --------------------------------------------------------------------------------------
// Cache request FIFO
// --------------------------------------------------------------------------------------
CacheRequestPayload           fifo_request_din                  ;
CacheRequestPayload           fifo_request_dout                 ;
FIFOStateSignalsOutInternal   fifo_request_signals_out_int      ;
FIFOStateSignalsInput         fifo_request_signals_in_reg       ;
FIFOStateSignalsInputInternal fifo_request_signals_in_int       ;
logic                         fifo_request_setup_signal_int     ;
logic                         fifo_request_signals_out_valid_int;

// --------------------------------------------------------------------------------------
// Memory response FIFO
// --------------------------------------------------------------------------------------
MemoryPacketResponsePayload   fifo_response_din             ;
MemoryPacketResponsePayload   fifo_response_dout            ;
FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
logic                           areset_counter                  ;
logic                           counter_load                    ;
logic                           write_command_counter_is_zero   ;
logic [CACHE_WTBUF_DEPTH_W-1:0] write_command_counter_          ;
logic [CACHE_WTBUF_DEPTH_W-1:0] write_command_counter_load_value;

assign write_command_counter_load_value = ((CACHE_WTBUF_DEPTH_W**2)-1);

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_fifo    <= areset;
  areset_control <= areset;
  areset_cache   <= areset;
  areset_counter <= areset;
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
    request_in_reg.valid         <= 1'b0;
    cache_request_in_reg.valid   <= 1'b0;
    fifo_response_signals_in_reg <= 0;
    fifo_request_signals_in_reg  <= 0;
  end
  else begin
    request_in_reg.valid         <= request_in.valid;
    cache_request_in_reg.valid   <= request_in_reg.valid;
    fifo_response_signals_in_reg <= fifo_response_signals_in;
    fifo_request_signals_in_reg  <= fifo_request_signals_in;
  end
end

always_ff @(posedge ap_clk) begin
  request_in_reg.payload       <= request_in.payload;
  cache_request_in_reg.payload <= map_MemoryRequestPacket_to_CacheRequest(request_in_reg.payload, descriptor_in_reg.payload, request_in_reg.valid);
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal  <= 1'b1;
    response_out.valid <= 1'b0;
    done_out           <= 1'b0;
    fifo_empty_reg     <= 1'b1;
  end
  else begin
    fifo_setup_signal  <= fifo_request_setup_signal_int | fifo_response_setup_signal_int;
    response_out.valid <= response_in_int.valid;
    done_out           <= fifo_empty_reg;
    fifo_empty_reg     <= fifo_empty_int;
  end
end

assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty & cache_ctrl_out.wtb_empty & cache_response_mem.iob.ready;

always_ff @(posedge ap_clk) begin
  fifo_request_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
  fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
  response_out.payload      <= response_in_int.payload;
end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_write.in = m_axi_write_in;

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_read.in = m_axi_read_in;

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_write_out = m_axi_write.out;

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out = m_axi_read.out;

// --------------------------------------------------------------------------------------
// AXI port cache
// --------------------------------------------------------------------------------------
assign cache_ctrl_in.force_inv = 1'b0;
assign cache_ctrl_in.wtb_empty = 1'b1;

iob_cache_axi #(
  .FE_ADDR_W           (M_AXI4_FE_ADDR_W                                 ),
  .FE_DATA_W           (CACHE_FRONTEND_DATA_W                            ),
  .BE_ADDR_W           (CACHE_BACKEND_ADDR_W                             ),
  .BE_DATA_W           (CACHE_BACKEND_DATA_W                             ),
  .NWAYS_W             (CACHE_N_WAYS                                     ),
  .NLINES_W            (CACHE_LINE_OFF_W                                 ),
  .WORD_OFFSET_W       (CACHE_WORD_OFF_W                                 ),
  .WTBUF_DEPTH_W       (CACHE_WTBUF_DEPTH_W                              ),
  .REP_POLICY          (CACHE_REP_POLICY                                 ),
  .WRITE_POL           (CACHE_WRITE_POL                                  ),
  .USE_CTRL            (CACHE_CTRL_CACHE                                 ),
  .USE_CTRL_CNT        (CACHE_CTRL_CACHE                                 ),
  .AXI_ID_W            (CACHE_AXI_ID_W                                   ),
  .AXI_ID              (CACHE_AXI_ID                                     ),
  .AXI_LEN_W           (CACHE_AXI_LEN_W                                  ),
  .AXI_ADDR_W          (CACHE_AXI_ADDR_W                                 ),
  .AXI_DATA_W          (CACHE_AXI_DATA_W                                 ),
  .CACHE_AXI_CACHE_MODE(M_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES)
) inst_iob_cache_axi (
  .iob_avalid_i(cache_request_mem.iob.valid                                                         ),
  .iob_addr_i  (cache_request_mem.iob.addr [CACHE_CTRL_CNT+M_AXI4_FE_ADDR_W-1:CACHE_FRONTEND_BYTE_W]),
  .iob_wdata_i (cache_request_mem.iob.wdata                                                         ),
  .iob_wstrb_i (cache_request_mem.iob.wstrb                                                         ),
  .iob_rdata_o (cache_response_mem.iob.rdata                                                        ),
  .iob_rvalid_o(cache_response_mem.iob.valid                                                        ),
  .iob_ready_o (cache_response_mem.iob.ready                                                        ),
  .invalidate_i(cache_ctrl_in.force_inv                                                             ),
  .invalidate_o(cache_ctrl_out.force_inv                                                            ),
  .wtb_empty_i (cache_ctrl_in.wtb_empty                                                             ),
  .wtb_empty_o (cache_ctrl_out.wtb_empty                                                            ),
  `include "m_axi_portmap_cache.vh"
  .clk_i       (ap_clk                                                                              ),
  .cke_i       (1'b1                                                                                ),
  .arst_i      (areset_cache                                                                        )
);

// --------------------------------------------------------------------------------------
// Cache request FIFO FWFT
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_signals_in_int.wr_en = cache_request_in_reg.valid;
assign fifo_request_din.iob              = cache_request_in_reg.payload.iob;
assign fifo_request_din.meta             = cache_request_in_reg.payload.meta;
assign fifo_request_din.data             = cache_request_in_reg.payload.data;

// Pop
// assign fifo_request_signals_in_int.rd_en = cache_request_pop_int;
assign cache_request_mem.iob.valid = cache_request_mem_reg.iob.valid;
assign cache_request_mem.iob.addr  = cache_request_mem_reg.iob.addr;
assign cache_request_mem.iob.wdata = cache_request_mem_reg.iob.wdata;
assign cache_request_mem.iob.wstrb = cache_request_mem_reg.iob.wstrb;
assign cache_request_mem.meta      = cache_request_mem_reg.meta;
assign cache_request_mem.data      = cache_request_mem_reg.data;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
  .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
  .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
  .PROG_THRESH     (PROG_THRESH               ),
  .READ_MODE       ("fwft"                    )  //string; "std" or "fwft";
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
// Cache response FIFO
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy | fifo_response_signals_out_int.rd_rst_busy;

// Push
always_comb fifo_response_din = map_CacheResponse_to_MemoryResponsePacket(cache_request_mem, cache_response_mem);

// Pop
assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;
assign response_in_int.valid              = fifo_response_signals_out_int.valid;
assign response_in_int.payload            = fifo_response_dout;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                  ),
  .WRITE_DATA_WIDTH($bits(MemoryPacketResponsePayload)),
  .READ_DATA_WIDTH ($bits(MemoryPacketResponsePayload)),
  .PROG_THRESH     (PROG_THRESH                       )
) inst_fifo_CacheResponse (
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
// Cache Commands State Machine
// --------------------------------------------------------------------------------------
logic cmd_read_condition ;
logic cmd_write_condition;

cu_cache_command_generator_state current_state;
cu_cache_command_generator_state next_state   ;
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if(areset_control)
    current_state <= CU_CACHE_CMD_RESET;
  else begin
    current_state <= next_state;
  end
end// always_ff @(posedge ap_clk)
// --------------------------------------------------------------------------------------
assign fifo_request_signals_out_valid_int = fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & descriptor_in_reg.valid;
assign cmd_read_condition                 = cache_response_mem.iob.ready & fifo_request_signals_out_valid_int & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ);
assign cmd_write_condition                = cache_response_mem.iob.ready & fifo_request_signals_out_valid_int & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE) & ~(write_command_counter_is_zero & ~cache_ctrl_out.wtb_empty);
// --------------------------------------------------------------------------------------
always_comb begin
  next_state = current_state;
  case (current_state)
    CU_CACHE_CMD_RESET : begin
      next_state = CU_CACHE_CMD_READY;
    end
    CU_CACHE_CMD_READY : begin
      if(cmd_read_condition)
        next_state = CU_CACHE_CMD_READ;
      else if(cmd_write_condition)
        next_state = CU_CACHE_CMD_WRITE;
      else
        next_state = CU_CACHE_CMD_READY;
    end
    CU_CACHE_CMD_READ : begin
      if(cache_response_mem.iob.valid)
        next_state = CU_CACHE_CMD_READY;
      else
        next_state = CU_CACHE_CMD_READ;
    end
    CU_CACHE_CMD_WRITE : begin
        next_state = CU_CACHE_CMD_READY;
    end
    CU_CACHE_CMD_DONE : begin
      next_state = CU_CACHE_CMD_DONE;
    end
  endcase
end// always_comb
// State Transition Logic

always_comb begin
  counter_load                       = 1'b0;
  fifo_request_signals_in_int.rd_en  = 1'b0;
  fifo_response_signals_in_int.wr_en = 1'b0;
  cache_request_mem_reg.iob.valid    = 1'b0;
  case (current_state)
    CU_CACHE_CMD_RESET : begin
      counter_load                       = 1'b1;
      fifo_request_signals_in_int.rd_en  = 1'b0;
      fifo_response_signals_in_int.wr_en = 1'b0;
      cache_request_mem_reg.iob.valid    = 1'b0;
    end
    CU_CACHE_CMD_READY : begin
      counter_load                       = 1'b0;
      fifo_request_signals_in_int.rd_en  = 1'b0;
      fifo_response_signals_in_int.wr_en = 1'b0;
      cache_request_mem_reg.iob.valid    = 1'b0;
    end
    CU_CACHE_CMD_READ : begin
      if(~cache_response_mem.iob.valid) begin
        cache_request_mem_reg.iob.valid    = 1'b1;
        fifo_request_signals_in_int.rd_en  = 1'b0;
        fifo_response_signals_in_int.wr_en = 1'b0;
      end else begin
        fifo_request_signals_in_int.rd_en  = 1'b1;
        fifo_response_signals_in_int.wr_en = 1'b1;
        cache_request_mem_reg.iob.valid    = 1'b0;
      end 
    end
    CU_CACHE_CMD_WRITE : begin
        cache_request_mem_reg.iob.valid    = 1'b1;
        fifo_request_signals_in_int.rd_en  = 1'b1;
        fifo_response_signals_in_int.wr_en = 1'b1;
    end
    CU_CACHE_CMD_DONE : begin
      fifo_request_signals_in_int.rd_en  = 1'b0;
      fifo_response_signals_in_int.wr_en = 1'b0;
      cache_request_mem_reg.iob.valid    = 1'b0;
    end
  endcase
end// always_comb

always_comb begin
  cache_request_mem_reg.iob.wstrb = fifo_request_dout.iob.wstrb & {32{((fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE))}};
  cache_request_mem_reg.iob.addr  = fifo_request_dout.iob.addr;
  cache_request_mem_reg.iob.wdata = fifo_request_dout.iob.wdata;
  cache_request_mem_reg.meta      = fifo_request_dout.meta;
  cache_request_mem_reg.data      = fifo_request_dout.data;
end

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
counter #(.C_WIDTH(CACHE_WTBUF_DEPTH_W)) inst_write_command_counter (
  .ap_clk      (ap_clk                                                                                       ),
  .ap_clken    (1'b1                                                                                         ),
  .areset      (areset_counter                                                                               ),
  .load        (counter_load                                                                                 ),
  .incr        (fifo_response_signals_in_int.wr_en  & (cache_request_mem.meta.subclass.cmd == CMD_MEM_WRITE) ),
  .decr        (cache_request_mem_reg.iob.valid  & (cache_request_mem_reg.meta.subclass.cmd == CMD_MEM_WRITE)),
  .load_value  (write_command_counter_load_value                                                             ),
  .stride_value({{(CACHE_WTBUF_DEPTH_W-1){1'b0}},{1'b1}}                                                     ),
  .count       (write_command_counter_                                                                       ),
  .is_zero     (write_command_counter_is_zero                                                                )
);

endmodule : cu_cache

