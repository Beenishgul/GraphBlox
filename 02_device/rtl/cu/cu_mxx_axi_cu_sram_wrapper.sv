
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m00_axi_cu_sram_wrapper.sv
// Create : 2023-06-13 23:21:43
// Revise : 2024-01-11 02:41:36
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
`include "typedef.svh"


module m00_axi_cu_sram_mid32x64_fe32x64_wrapper #(
  parameter FIFO_WRITE_DEPTH = 64,
  parameter PROG_THRESH      = 32
) (
  // System Signals
  input  logic                                   ap_clk                   ,
  input  logic                                   areset                   ,
  input  KernelDescriptor                        descriptor_in            ,
  input  MemoryPacketRequest                     request_in               ,
  output FIFOStateSignalsOutput                  fifo_request_signals_out ,
  input  FIFOStateSignalsInput                   fifo_request_signals_in  ,
  output MemoryPacketResponse                    response_out             ,
  output FIFOStateSignalsOutput                  fifo_response_signals_out,
  input  FIFOStateSignalsInput                   fifo_response_signals_in ,
  output logic                                   fifo_setup_signal        ,
  input  M00_AXI4_MID_MasterReadInterfaceInput   m_axi_read_in            ,
  output M00_AXI4_MID_MasterReadInterfaceOutput  m_axi_read_out           ,
  input  M00_AXI4_MID_MasterWriteInterfaceInput  m_axi_write_in           ,
  output M00_AXI4_MID_MasterWriteInterfaceOutput m_axi_write_out          ,
  output logic                                   done_out
);


// --------------------------------------------------------------------------------------
// Define SRAM axi data types
// --------------------------------------------------------------------------------------
`AXI_TYPEDEF_ALL(axi, type_m00_axi4_mid_addr, type_m00_axi4_mid_id, type_m00_axi4_mid_data, type_m00_axi4_mid_strb, type_m00_axi4_mid_user)
axi_req_t  axi_req_o;
axi_resp_t axi_rsp_i;
// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign axi_rsp_i.ar_ready = m_axi_read_in.arready ;// Input Read Address read channel ready
assign axi_rsp_i.r.data   = m_axi_read_in.rdata   ;// Input Read channel data
assign axi_rsp_i.r.id     = m_axi_read_in.rid     ;// Input Read channel ID
assign axi_rsp_i.r.last   = m_axi_read_in.rlast   ;// Input Read channel last word
assign axi_rsp_i.r.resp   = m_axi_read_in.rresp   ;// Input Read channel response
assign axi_rsp_i.r_valid  = m_axi_read_in.rvalid  ;// Input Read channel valid
assign axi_rsp_i.r.user   = 0 ;// Input Read channel user
// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign axi_rsp_i.aw_ready = m_axi_write_in.awready ;// Input Write Address write channel ready
assign axi_rsp_i.w_ready  = m_axi_write_in.wready  ;// Input Write channel ready
assign axi_rsp_i.b.id     = m_axi_write_in.bid     ;// Input Write response channel ID
assign axi_rsp_i.b.resp   = m_axi_write_in.bresp   ;// Input Write channel response
assign axi_rsp_i.b_valid  = m_axi_write_in.bvalid  ;// Input Write response channel valid
assign axi_rsp_i.b.user   = 0 ;// Input Write channel user
// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out.arvalid  = axi_req_o.ar_valid;// Output Read Address read channel valid
assign m_axi_read_out.araddr   = axi_req_o.ar.addr ;// Output Read Address read channel address
assign m_axi_read_out.arlen    = axi_req_o.ar.len  ;// Output Read Address channel burst length
assign m_axi_read_out.rready   = axi_req_o.r_ready ;// Output Read Read channel ready
assign m_axi_read_out.arid     = axi_req_o.ar.id   ;// Output Read Address read channel ID
assign m_axi_read_out.arsize   = axi_req_o.ar.size ;// Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
assign m_axi_read_out.arburst  = axi_req_o.ar.burst;// Output Read Address read channel burst type
assign m_axi_read_out.arlock   = axi_req_o.ar.lock ;// Output Read Address read channel lock type
assign m_axi_read_out.arcache  = axi_req_o.ar.cache;// Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
assign m_axi_read_out.arprot   = axi_req_o.ar.prot ;// Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
assign m_axi_read_out.arqos    = axi_req_o.ar.qos  ;// Output Read Address channel quality of service
assign m_axi_read_out.arregion = axi_req_o.ar.region;// Output Read Address channel arregion
//assign m_axi_read_out.user     = axi_req_o.ar.user;
// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_write_out.awvalid  = axi_req_o.aw_valid; // Output Write Address write channel valid
assign m_axi_write_out.awid     = axi_req_o.aw.id   ; // Output Write Address write channel ID
assign m_axi_write_out.awaddr   = axi_req_o.aw.addr ; // Output Write Address write channel address
assign m_axi_write_out.awlen    = axi_req_o.aw.len  ; // Output Write Address write channel burst length
assign m_axi_write_out.awsize   = axi_req_o.aw.size ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
assign m_axi_write_out.awburst  = axi_req_o.aw.burst; // Output Write Address write channel burst type
assign m_axi_write_out.awlock   = axi_req_o.aw.lock ; // Output Write Address write channel lock type
assign m_axi_write_out.awcache  = axi_req_o.aw.cache; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
assign m_axi_write_out.awprot   = axi_req_o.aw.prot ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
assign m_axi_write_out.awqos    = axi_req_o.aw.qos  ; // Output Write Address write channel quality of service
assign m_axi_write_out.wdata    = axi_req_o.w.data  ; // Output Write channel data
assign m_axi_write_out.wstrb    = axi_req_o.w.strb  ; // Output Write channel write strobe
assign m_axi_write_out.wlast    = axi_req_o.w.last  ; // Output Write channel last word flag
assign m_axi_write_out.wvalid   = axi_req_o.w_valid ; // Output Write channel valid
assign m_axi_write_out.bready   = axi_req_o.b_ready ; // Output Write response channel ready
assign m_axi_write_out.awregion = axi_req_o.aw.region;
// assign m_axi_write_out.awatop = axi_req_o.aw.atop;
// assign m_axi_write_out.awuser = axi_req_o.aw.user;
// assign m_axi_write_out.wuser  = axi_req_o.w.user;

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic            areset_fifo      ;
logic            areset_sram      ;
logic            areset_control   ;
KernelDescriptor descriptor_in_reg;

MemoryPacketRequest request_in_reg     ;
CacheRequest        sram_request_in_reg;
CacheResponse       response_in_int    ;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
CacheRequestPayload  sram_request_mem     ;
CacheRequestPayload  sram_request_mem_reg ;
CacheResponsePayload sram_response_mem    ;
CacheResponsePayload sram_response_mem_reg;


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
CacheRequestPayload           fifo_response_din             ;
CacheRequestPayload           fifo_response_dout            ;
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
  areset_sram    <= ~areset;
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
    sram_request_in_reg.valid    <= 1'b0;
    fifo_response_signals_in_reg <= 0;
    fifo_request_signals_in_reg  <= 0;
  end
  else begin
    request_in_reg.valid         <= request_in.valid;
    sram_request_in_reg.valid    <= request_in_reg.valid;
    fifo_response_signals_in_reg <= fifo_response_signals_in;
    fifo_request_signals_in_reg  <= fifo_request_signals_in;
  end
end

always_ff @(posedge ap_clk) begin
  request_in_reg.payload      <= request_in.payload;
  sram_request_in_reg.payload <= map_MemoryRequestPacket_to_CacheRequest(request_in_reg.payload, descriptor_in_reg.payload, request_in_reg.valid);
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

assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty;

always_ff @(posedge ap_clk) begin
  fifo_request_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
  fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
  response_out.payload      <= response_in_int.payload;
end

// --------------------------------------------------------------------------------------
// AXI port sram
// --------------------------------------------------------------------------------------

logic mem_gnt_o      ;
logic mem_rsp_error_o;

axi_from_mem #(
  .MemAddrWidth(M00_AXI4_FE_ADDR_W    ),
  .AxiAddrWidth(M00_AXI4_FE_ADDR_W    ),
  .DataWidth   (M00_AXI4_FE_DATA_W    ),
  .MaxRequests (2**CACHE_WTBUF_DEPTH_W),
  .axi_req_t   (axi_req_t             ),
  .axi_rsp_t   (axi_resp_t            )
) inst_axi_from_mem (
  .clk_i          (ap_clk                                   ),
  .rst_ni         (areset_sram                              ),
  .mem_req_i      (sram_request_mem.iob.valid               ),
  .mem_addr_i     (sram_request_mem.iob.addr                ),
  .mem_we_i       (cmd_write_condition                      ),
  .mem_wdata_i    (sram_request_mem.iob.wdata               ),
  .mem_be_i       (sram_request_mem.iob.wstrb               ),
  .mem_gnt_o      (mem_gnt_o                                ),
  .mem_rsp_valid_o(sram_response_mem.iob.valid              ),
  .mem_rsp_rdata_o(sram_response_mem.iob.rdata              ),
  .mem_rsp_error_o(mem_rsp_error_o                          ),
  .slv_aw_cache_i (M00_AXI4_MID_CACHE_BUFFERABLE_NO_ALLOCATE),
  .slv_ar_cache_i (M00_AXI4_MID_CACHE_BUFFERABLE_NO_ALLOCATE),
  .axi_req_o      (axi_req_o                                ),
  .axi_rsp_i      (axi_rsp_i                                )
);

// --------------------------------------------------------------------------------------
// Cache request FIFO FWFT
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_signals_in_int.wr_en = sram_request_in_reg.valid;
assign fifo_request_din.iob              = sram_request_in_reg.payload.iob;
assign fifo_request_din.meta             = sram_request_in_reg.payload.meta;
assign fifo_request_din.data             = sram_request_in_reg.payload.data;

// Pop
// assign fifo_request_signals_in_int.rd_en = sram_request_pop_int;
assign sram_request_mem.iob.valid = sram_request_mem_reg.iob.valid;
assign sram_request_mem.iob.addr  = sram_request_mem_reg.iob.addr;
assign sram_request_mem.iob.wdata = sram_request_mem_reg.iob.wdata;
assign sram_request_mem.iob.wstrb = sram_request_mem_reg.iob.wstrb;
assign sram_request_mem.meta      = sram_request_mem_reg.meta;
assign sram_request_mem.data      = sram_request_mem_reg.data;

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
always_comb fifo_response_din = sram_request_mem;

// Pop
// assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;

assign fifo_response_signals_in_int.rd_en = sram_response_mem.iob.valid ;
assign response_in_int.valid              = fifo_response_signals_out_int.valid;
assign response_in_int.payload            = map_CacheResponse_to_MemoryResponsePacket(fifo_response_dout, sram_response_mem_reg);

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
  .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
  .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
  .PROG_THRESH     (PROG_THRESH               )
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


always_ff @(posedge ap_clk) begin
  sram_response_mem_reg <= sram_response_mem;
end
// --------------------------------------------------------------------------------------
// Cache Commands State Machine
// --------------------------------------------------------------------------------------
logic cmd_read_condition ;
logic cmd_write_condition;

cu_sram_command_generator_state current_state;
cu_sram_command_generator_state next_state   ;
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if(areset_control)
    current_state <= CU_SRAM_CMD_RESET;
  else begin
    current_state <= next_state;
  end
end// always_ff @(posedge ap_clk)
// --------------------------------------------------------------------------------------
assign fifo_request_signals_out_valid_int = fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & descriptor_in_reg.valid;
assign cmd_read_condition                 = fifo_request_signals_out_valid_int & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ) & ~(write_command_counter_is_zero);
assign cmd_write_condition                = fifo_request_signals_out_valid_int & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE) & ~(write_command_counter_is_zero);
// --------------------------------------------------------------------------------------
always_comb begin
  next_state = current_state;
  case (current_state)
    CU_SRAM_CMD_RESET : begin
      next_state = CU_SRAM_CMD_READY;
    end
    CU_SRAM_CMD_READY : begin
      next_state = CU_SRAM_CMD_READY;
    end
  endcase
end// always_comb
// State Transition Logic

always_comb begin
  counter_load                       = 1'b0;
  fifo_request_signals_in_int.rd_en  = 1'b0;
  fifo_response_signals_in_int.wr_en = 1'b0;
  sram_request_mem_reg.iob.valid     = 1'b0;
  case (current_state)
    CU_SRAM_CMD_RESET : begin
      counter_load                       = 1'b1;
      fifo_request_signals_in_int.rd_en  = 1'b0;
      fifo_response_signals_in_int.wr_en = 1'b0;
      sram_request_mem_reg.iob.valid     = 1'b0;
    end
    CU_SRAM_CMD_READY : begin
      counter_load                       = 1'b0;
      fifo_request_signals_in_int.rd_en  = 1'b0;
      fifo_response_signals_in_int.wr_en = 1'b0;
      sram_request_mem_reg.iob.valid     = 1'b0;
      if(cmd_read_condition) begin
        sram_request_mem_reg.iob.valid     = 1'b1;
        fifo_request_signals_in_int.rd_en  = 1'b1;
        fifo_response_signals_in_int.wr_en = 1'b1;
      end else if(cmd_write_condition) begin
        sram_request_mem_reg.iob.valid     = 1'b1;
        fifo_request_signals_in_int.rd_en  = 1'b1;
        fifo_response_signals_in_int.wr_en = 1'b1;
      end
    end
  endcase
end// always_comb

always_comb begin
  sram_request_mem_reg.iob.wstrb = fifo_request_dout.iob.wstrb & {32{((fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE))}};
  sram_request_mem_reg.iob.addr  = fifo_request_dout.iob.addr;
  sram_request_mem_reg.iob.wdata = fifo_request_dout.iob.wdata;
  sram_request_mem_reg.meta      = fifo_request_dout.meta;
  sram_request_mem_reg.data      = fifo_request_dout.data;
end

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
counter #(.C_WIDTH(CACHE_WTBUF_DEPTH_W)) inst_write_command_counter (
  .ap_clk      (ap_clk                                  ),
  .ap_clken    (1'b1                                    ),
  .areset      (areset_counter                          ),
  .load        (counter_load                            ),
  .incr        (sram_response_mem.iob.valid             ),
  .decr        (sram_request_mem_reg.iob.valid          ),
  .load_value  (write_command_counter_load_value        ),
  .stride_value({{(CACHE_WTBUF_DEPTH_W-1){1'b0}},{1'b1}}),
  .count       (write_command_counter_                  ),
  .is_zero     (write_command_counter_is_zero           )
);

endmodule : m00_axi_cu_sram_mid32x64_fe32x64_wrapper
