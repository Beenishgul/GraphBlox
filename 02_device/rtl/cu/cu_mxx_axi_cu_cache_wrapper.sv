
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m01_axi_cu_cache_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"



module m00_axi_cu_cache_mid32x64_fe32x64_wrapper #(
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
  input  M00_AXI4_LITE_MID_RESP_T                m_axi_lite_in            ,
  output M00_AXI4_LITE_MID_REQ_T                 m_axi_lite_out           ,
  output logic                                   done_out
);

assign m_axi_lite_out = 0;
// --------------------------------------------------------------------------------------
// Define SRAM axi data types
// --------------------------------------------------------------------------------------
M00_AXI4_FE_REQ_T  axi_req_o;
M00_AXI4_FE_RESP_T axi_rsp_i;

// --------------------------------------------------------------------------------------
logic                   m_axi_read_out_araddr_63 ;
logic                   m_axi_write_out_awaddr_63;
type_m00_axi4_mid_cache m_axi_read_out_arcache   ;
type_m00_axi4_mid_cache m_axi_read_out_awcache   ;
logic                   cache_setup_signal_int   ;
logic                   cache_setup_signal       ;
logic                   areset_control           ;
logic                   areset_cu_cache          ;

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic            areset_fifo      ;
logic            areset_sram      ;
KernelDescriptor descriptor_in_reg;

MemoryPacketRequest  request_in_reg     ;
CacheRequest         sram_request_in_reg;
MemoryPacketResponse response_in_int    ;

logic fifo_empty_int;
logic fifo_empty_reg;

logic cmd_read_condition ;
logic cmd_write_condition;
logic mem_rsp_error_o    ;
// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
CacheRequestPayload  sram_request_mem        ;
CacheRequestPayload  sram_request_mem_int    ;
CacheResponsePayload sram_response_mem       ;
CacheResponsePayload sram_response_mem_reg   ;
CacheResponsePayload sram_response_mem_reg_S2;

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
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_fifo    <= areset;
  areset_control <= areset;
  areset_sram    <= ~areset;
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
    fifo_setup_signal  <= fifo_request_setup_signal_int | fifo_response_setup_signal_int | cache_setup_signal;
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
axi_from_mem #(
  .MemAddrWidth(M00_AXI4_FE_ADDR_W),
  .AxiAddrWidth(M00_AXI4_FE_ADDR_W),
  .DataWidth   (M00_AXI4_FE_DATA_W),
  .MaxRequests (2**8              ),
  .axi_req_t   (M00_AXI4_FE_REQ_T ),
  .axi_rsp_t   (M00_AXI4_FE_RESP_T)
) inst_axi_from_mem (
  .clk_i          (ap_clk                                             ),
  .rst_ni         (areset_sram                                        ),
  .mem_req_i      (sram_request_mem.iob.valid                         ),
  .mem_addr_i     (sram_request_mem.iob.addr                          ),
  .mem_we_i       (cmd_write_condition                                ),
  .mem_wdata_i    (sram_request_mem.iob.wdata                         ),
  .mem_be_i       (sram_request_mem.iob.wstrb                         ),
  .mem_gnt_o      (sram_response_mem.iob.ready                        ),
  .mem_rsp_valid_o(sram_response_mem.iob.valid                        ),
  .mem_rsp_rdata_o(sram_response_mem.iob.rdata                        ),
  .mem_rsp_error_o(mem_rsp_error_o                                    ),
  .slv_aw_cache_i (M00_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES),
  .slv_ar_cache_i (M00_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES),
  .axi_req_o      (axi_req_o                                          ),
  .axi_rsp_i      (axi_rsp_i                                          )
);
// --------------------------------------------------------------------------------------
assign sram_response_mem.meta = 0;
assign sram_response_mem.data = 0;


// --------------------------------------------------------------------------------------
// Drive cache_setup_signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    cache_setup_signal <= 1'b1;
  end
  else begin
    cache_setup_signal <= cache_setup_signal_int;
  end
end

always_ff @(posedge ap_clk) begin
  areset_cu_cache <= ~areset;
end

assign m_axi_read_out.araddr[63]  = 1'b0;
assign m_axi_write_out.awaddr[63] = 1'b0;
assign m_axi_write_out.awregion   = axi_req_o.aw.region;
assign m_axi_read_out.arregion    = axi_req_o.ar.region;
assign axi_rsp_i.b.user           = 0 ;// Input Write channel user
assign axi_rsp_i.r.user           = 0 ;// Input Read channel user

assign m_axi_read_out.arcache  = M00_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES;
assign m_axi_write_out.awcache = M00_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES;

m00_axi_cu_cache_mid32x64_fe32x64 inst_m01_axi_system_cache_mid32x64_fe32x64 (
  .S0_AXI_GEN_ARUSER (0                                                        ),
  .S0_AXI_GEN_AWUSER (0                                                        ),
  .S0_AXI_GEN_RVALID (axi_rsp_i.r_valid                                        ), // Output Read channel valid
  .S0_AXI_GEN_ARREADY(axi_rsp_i.ar_ready                                       ), // Output Read Address read channel ready
  .S0_AXI_GEN_RLAST  (axi_rsp_i.r.last                                         ), // Output Read channel last word
  .S0_AXI_GEN_RDATA  (axi_rsp_i.r.data                                         ), // Output Read channel data
  .S0_AXI_GEN_RID    (axi_rsp_i.r.id                                           ), // Output Read channel ID
  .S0_AXI_GEN_RRESP  (axi_rsp_i.r.resp                                         ), // Output Read channel response
  .S0_AXI_GEN_ARVALID(axi_req_o.ar_valid                                       ), // Input Read Address read channel valid
  .S0_AXI_GEN_ARADDR (axi_req_o.ar.addr                                        ), // Input Read Address read channel address
  .S0_AXI_GEN_ARLEN  (axi_req_o.ar.len                                         ), // Input Read Address channel burst length
  .S0_AXI_GEN_RREADY (axi_req_o.r_ready                                        ), // Input Read Read channel ready
  .S0_AXI_GEN_ARID   (axi_req_o.ar.id                                          ), // Input Read Address read channel ID
  .S0_AXI_GEN_ARSIZE (axi_req_o.ar.size                                        ), // Input Read Address read channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_ARBURST(axi_req_o.ar.burst                                       ), // Input Read Address read channel burst type
  .S0_AXI_GEN_ARLOCK (axi_req_o.ar.lock                                        ), // Input Read Address read channel lock type
  .S0_AXI_GEN_ARCACHE(axi_req_o.ar.cache                                       ), // Input Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_ARPROT (axi_req_o.ar.prot                                        ), // Input Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_ARQOS  (axi_req_o.ar.qos                                         ), // Input Read Address channel quality of service
  .S0_AXI_GEN_AWREADY(axi_rsp_i.aw_ready                                       ), // Output Write Address write channel ready
  .S0_AXI_GEN_WREADY (axi_rsp_i.w_ready                                        ), // Output Write channel ready
  .S0_AXI_GEN_BID    (axi_rsp_i.b.id                                           ), // Output Write response channel ID
  .S0_AXI_GEN_BRESP  (axi_rsp_i.b.resp                                         ), // Output Write channel response
  .S0_AXI_GEN_BVALID (axi_rsp_i.b_valid                                        ), // Output Write response channel valid
  .S0_AXI_GEN_AWVALID(axi_req_o.aw_valid                                       ), // Input Write Address write channel valid
  .S0_AXI_GEN_AWID   (axi_req_o.aw.id                                          ), // Input Write Address write channel ID
  .S0_AXI_GEN_AWADDR (axi_req_o.aw.addr                                        ), // Input Write Address write channel address
  .S0_AXI_GEN_AWLEN  (axi_req_o.aw.len                                         ), // Input Write Address write channel burst length
  .S0_AXI_GEN_AWSIZE (axi_req_o.aw.size                                        ), // Input Write Address write channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_AWBURST(axi_req_o.aw.burst                                       ), // Input Write Address write channel burst type
  .S0_AXI_GEN_AWLOCK (axi_req_o.aw.lock                                        ), // Input Write Address write channel lock type
  .S0_AXI_GEN_AWCACHE(axi_req_o.aw.cache                                       ), // Input Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_AWPROT (axi_req_o.aw.prot                                        ), // Input Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_AWQOS  (axi_req_o.aw.qos                                         ), // Input Write Address write channel quality of service
  .S0_AXI_GEN_WDATA  (axi_req_o.w.data                                         ), // Input Write channel data
  .S0_AXI_GEN_WSTRB  (axi_req_o.w.strb                                         ), // Input Write channel write strobe
  .S0_AXI_GEN_WLAST  (axi_req_o.w.last                                         ), // Input Write channel last word flag
  .S0_AXI_GEN_WVALID (axi_req_o.w_valid                                        ), // Input Write channel valid
  .S0_AXI_GEN_BREADY (axi_req_o.b_ready                                        ), // Input Write response channel ready
  
  .M0_AXI_RVALID     (m_axi_read_in.rvalid                                     ), // Input Read channel valid
  .M0_AXI_ARREADY    (m_axi_read_in.arready                                    ), // Input Read Address read channel ready
  .M0_AXI_RLAST      (m_axi_read_in.rlast                                      ), // Input Read channel last word
  .M0_AXI_RDATA      (m_axi_read_in.rdata                                      ), // Input Read channel data
  .M0_AXI_RID        (m_axi_read_in.rid                                        ), // Input Read channel ID
  .M0_AXI_RRESP      (m_axi_read_in.rresp                                      ), // Input Read channel response
  .M0_AXI_ARVALID    (m_axi_read_out.arvalid                                   ), // Output Read Address read channel valid
  .M0_AXI_ARADDR     ({m_axi_read_out_araddr_63, m_axi_read_out.araddr[62:0]}  ), // Output Read Address read channel address
  .M0_AXI_ARLEN      (m_axi_read_out.arlen                                     ), // Output Read Address channel burst length
  .M0_AXI_RREADY     (m_axi_read_out.rready                                    ), // Output Read Read channel ready
  .M0_AXI_ARID       (m_axi_read_out.arid                                      ), // Output Read Address read channel ID
  .M0_AXI_ARSIZE     (m_axi_read_out.arsize                                    ), // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_ARBURST    (m_axi_read_out.arburst                                   ), // Output Read Address read channel burst type
  .M0_AXI_ARLOCK     (m_axi_read_out.arlock                                    ), // Output Read Address read channel lock type
  .M0_AXI_ARCACHE    (m_axi_read_out_arcache                                   ), // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_ARPROT     (m_axi_read_out.arprot                                    ), // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_ARQOS      (m_axi_read_out.arqos                                     ), // Output Read Address channel quality of service
  .M0_AXI_AWREADY    (m_axi_write_in.awready                                   ), // Input Write Address write channel ready
  .M0_AXI_WREADY     (m_axi_write_in.wready                                    ), // Input Write channel ready
  .M0_AXI_BID        (m_axi_write_in.bid                                       ), // Input Write response channel ID
  .M0_AXI_BRESP      (m_axi_write_in.bresp                                     ), // Input Write channel response
  .M0_AXI_BVALID     (m_axi_write_in.bvalid                                    ), // Input Write response channel valid
  .M0_AXI_AWVALID    (m_axi_write_out.awvalid                                  ), // Output Write Address write channel valid
  .M0_AXI_AWID       (m_axi_write_out.awid                                     ), // Output Write Address write channel ID
  .M0_AXI_AWADDR     ({m_axi_write_out_awaddr_63, m_axi_write_out.awaddr[62:0]}), // Output Write Address write channel address
  .M0_AXI_AWLEN      (m_axi_write_out.awlen                                    ), // Output Write Address write channel burst length
  .M0_AXI_AWSIZE     (m_axi_write_out.awsize                                   ), // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_AWBURST    (m_axi_write_out.awburst                                  ), // Output Write Address write channel burst type
  .M0_AXI_AWLOCK     (m_axi_write_out.awlock                                   ), // Output Write Address write channel lock type
  .M0_AXI_AWCACHE    (m_axi_read_out_awcache                                   ), // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_AWPROT     (m_axi_write_out.awprot                                   ), // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_AWQOS      (m_axi_write_out.awqos                                    ), // Output Write Address write channel quality of service
  .M0_AXI_WDATA      (m_axi_write_out.wdata                                    ), // Output Write channel data
  .M0_AXI_WSTRB      (m_axi_write_out.wstrb                                    ), // Output Write channel write strobe
  .M0_AXI_WLAST      (m_axi_write_out.wlast                                    ), // Output Write channel last word flag
  .M0_AXI_WVALID     (m_axi_write_out.wvalid                                   ), // Output Write channel valid
  .M0_AXI_BREADY     (m_axi_write_out.bready                                   ), // Output Write response channel ready
  
  
  .ACLK              (ap_clk                                                   ),
  .ARESETN           (areset_cu_cache                                          ),
  .Initializing      (cache_setup_signal_int                                   )
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
assign sram_request_mem.iob.valid = sram_request_mem_int.iob.valid;
assign sram_request_mem.iob.addr  = sram_request_mem_int.iob.addr;
assign sram_request_mem.iob.wdata = sram_request_mem_int.iob.wdata;
assign sram_request_mem.iob.wstrb = sram_request_mem_int.iob.wstrb;
assign sram_request_mem.meta      = sram_request_mem_int.meta;
assign sram_request_mem.data      = sram_request_mem_int.data;

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
assign fifo_response_din = sram_request_mem;

// Pop
assign fifo_response_signals_in_int.rd_en = sram_response_mem_reg.iob.valid ;
assign response_in_int.valid              = fifo_response_signals_out_int.valid;
always_comb response_in_int.payload       = map_CacheResponse_to_MemoryResponsePacket(fifo_response_dout, sram_response_mem_reg_S2);

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
  sram_response_mem_reg    <= sram_response_mem;
  sram_response_mem_reg_S2 <= sram_response_mem_reg;
end

// --------------------------------------------------------------------------------------
// SRAM Commands State Machine
// --------------------------------------------------------------------------------------
assign fifo_request_signals_out_valid_int = fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & fifo_response_signals_in_reg.rd_en & descriptor_in_reg.valid;
assign sram_request_mem_int.iob.valid     = fifo_request_signals_out_valid_int;
assign fifo_request_signals_in_int.rd_en  = sram_response_mem.iob.ready;
assign fifo_response_signals_in_int.wr_en = sram_response_mem.iob.ready;
assign cmd_read_condition                 = (fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH);
assign cmd_write_condition                = (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE)| (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_WRITE);

always_comb begin
  sram_request_mem_int.iob.wstrb = fifo_request_dout.iob.wstrb & {32{(cmd_write_condition)}};
  sram_request_mem_int.iob.addr  = fifo_request_dout.iob.addr;
  sram_request_mem_int.iob.wdata = fifo_request_dout.iob.wdata;
  sram_request_mem_int.meta      = fifo_request_dout.meta;
  sram_request_mem_int.data      = fifo_request_dout.data;
end


  endmodule : m00_axi_cu_cache_mid32x64_fe32x64_wrapper
  


module m01_axi_cu_cache_mid32x64_fe32x64_wrapper #(
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
  input  M01_AXI4_MID_MasterReadInterfaceInput   m_axi_read_in            ,
  output M01_AXI4_MID_MasterReadInterfaceOutput  m_axi_read_out           ,
  input  M01_AXI4_MID_MasterWriteInterfaceInput  m_axi_write_in           ,
  output M01_AXI4_MID_MasterWriteInterfaceOutput m_axi_write_out          ,
  input  M01_AXI4_LITE_MID_RESP_T                m_axi_lite_in            ,
  output M01_AXI4_LITE_MID_REQ_T                 m_axi_lite_out           ,
  output logic                                   done_out
);

assign m_axi_lite_out = 0;
// --------------------------------------------------------------------------------------
// Define SRAM axi data types
// --------------------------------------------------------------------------------------
M01_AXI4_FE_REQ_T  axi_req_o;
M01_AXI4_FE_RESP_T axi_rsp_i;

// --------------------------------------------------------------------------------------
logic                   m_axi_read_out_araddr_63 ;
logic                   m_axi_write_out_awaddr_63;
type_m01_axi4_mid_cache m_axi_read_out_arcache   ;
type_m01_axi4_mid_cache m_axi_read_out_awcache   ;
logic                   cache_setup_signal_int   ;
logic                   cache_setup_signal       ;
logic                   areset_control           ;
logic                   areset_cu_cache          ;

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic            areset_fifo      ;
logic            areset_sram      ;
KernelDescriptor descriptor_in_reg;

MemoryPacketRequest  request_in_reg     ;
CacheRequest         sram_request_in_reg;
MemoryPacketResponse response_in_int    ;

logic fifo_empty_int;
logic fifo_empty_reg;

logic cmd_read_condition ;
logic cmd_write_condition;
logic mem_rsp_error_o    ;
// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
CacheRequestPayload  sram_request_mem        ;
CacheRequestPayload  sram_request_mem_int    ;
CacheResponsePayload sram_response_mem       ;
CacheResponsePayload sram_response_mem_reg   ;
CacheResponsePayload sram_response_mem_reg_S2;

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
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_fifo    <= areset;
  areset_control <= areset;
  areset_sram    <= ~areset;
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
    fifo_setup_signal  <= fifo_request_setup_signal_int | fifo_response_setup_signal_int | cache_setup_signal;
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
axi_from_mem #(
  .MemAddrWidth(M01_AXI4_FE_ADDR_W),
  .AxiAddrWidth(M01_AXI4_FE_ADDR_W),
  .DataWidth   (M01_AXI4_FE_DATA_W),
  .MaxRequests (2**1              ),
  .axi_req_t   (M01_AXI4_FE_REQ_T ),
  .axi_rsp_t   (M01_AXI4_FE_RESP_T)
) inst_axi_from_mem (
  .clk_i          (ap_clk                                             ),
  .rst_ni         (areset_sram                                        ),
  .mem_req_i      (sram_request_mem.iob.valid                         ),
  .mem_addr_i     (sram_request_mem.iob.addr                          ),
  .mem_we_i       (cmd_write_condition                                ),
  .mem_wdata_i    (sram_request_mem.iob.wdata                         ),
  .mem_be_i       (sram_request_mem.iob.wstrb                         ),
  .mem_gnt_o      (sram_response_mem.iob.ready                        ),
  .mem_rsp_valid_o(sram_response_mem.iob.valid                        ),
  .mem_rsp_rdata_o(sram_response_mem.iob.rdata                        ),
  .mem_rsp_error_o(mem_rsp_error_o                                    ),
  .slv_aw_cache_i (M01_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES),
  .slv_ar_cache_i (M01_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES),
  .axi_req_o      (axi_req_o                                          ),
  .axi_rsp_i      (axi_rsp_i                                          )
);
// --------------------------------------------------------------------------------------
assign sram_response_mem.meta = 0;
assign sram_response_mem.data = 0;


// --------------------------------------------------------------------------------------
// Drive cache_setup_signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    cache_setup_signal <= 1'b1;
  end
  else begin
    cache_setup_signal <= cache_setup_signal_int;
  end
end

always_ff @(posedge ap_clk) begin
  areset_cu_cache <= ~areset;
end

assign m_axi_read_out.araddr[63]  = 1'b0;
assign m_axi_write_out.awaddr[63] = 1'b0;
assign m_axi_write_out.awregion   = axi_req_o.aw.region;
assign m_axi_read_out.arregion    = axi_req_o.ar.region;
assign axi_rsp_i.b.user           = 0 ;// Input Write channel user
assign axi_rsp_i.r.user           = 0 ;// Input Read channel user

assign m_axi_read_out.arcache  = M01_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES;
assign m_axi_write_out.awcache = M01_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES;

m01_axi_cu_cache_mid32x64_fe32x64 inst_m01_axi_system_cache_mid32x64_fe32x64 (
  .S0_AXI_GEN_ARUSER (0                                                        ),
  .S0_AXI_GEN_AWUSER (0                                                        ),
  .S0_AXI_GEN_RVALID (axi_rsp_i.r_valid                                        ), // Output Read channel valid
  .S0_AXI_GEN_ARREADY(axi_rsp_i.ar_ready                                       ), // Output Read Address read channel ready
  .S0_AXI_GEN_RLAST  (axi_rsp_i.r.last                                         ), // Output Read channel last word
  .S0_AXI_GEN_RDATA  (axi_rsp_i.r.data                                         ), // Output Read channel data
  .S0_AXI_GEN_RID    (axi_rsp_i.r.id                                           ), // Output Read channel ID
  .S0_AXI_GEN_RRESP  (axi_rsp_i.r.resp                                         ), // Output Read channel response
  .S0_AXI_GEN_ARVALID(axi_req_o.ar_valid                                       ), // Input Read Address read channel valid
  .S0_AXI_GEN_ARADDR (axi_req_o.ar.addr                                        ), // Input Read Address read channel address
  .S0_AXI_GEN_ARLEN  (axi_req_o.ar.len                                         ), // Input Read Address channel burst length
  .S0_AXI_GEN_RREADY (axi_req_o.r_ready                                        ), // Input Read Read channel ready
  .S0_AXI_GEN_ARID   (axi_req_o.ar.id                                          ), // Input Read Address read channel ID
  .S0_AXI_GEN_ARSIZE (axi_req_o.ar.size                                        ), // Input Read Address read channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_ARBURST(axi_req_o.ar.burst                                       ), // Input Read Address read channel burst type
  .S0_AXI_GEN_ARLOCK (axi_req_o.ar.lock                                        ), // Input Read Address read channel lock type
  .S0_AXI_GEN_ARCACHE(axi_req_o.ar.cache                                       ), // Input Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0111).
  .S0_AXI_GEN_ARPROT (axi_req_o.ar.prot                                        ), // Input Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (010).
  .S0_AXI_GEN_ARQOS  (axi_req_o.ar.qos                                         ), // Input Read Address channel quality of service
  .S0_AXI_GEN_AWREADY(axi_rsp_i.aw_ready                                       ), // Output Write Address write channel ready
  .S0_AXI_GEN_WREADY (axi_rsp_i.w_ready                                        ), // Output Write channel ready
  .S0_AXI_GEN_BID    (axi_rsp_i.b.id                                           ), // Output Write response channel ID
  .S0_AXI_GEN_BRESP  (axi_rsp_i.b.resp                                         ), // Output Write channel response
  .S0_AXI_GEN_BVALID (axi_rsp_i.b_valid                                        ), // Output Write response channel valid
  .S0_AXI_GEN_AWVALID(axi_req_o.aw_valid                                       ), // Input Write Address write channel valid
  .S0_AXI_GEN_AWID   (axi_req_o.aw.id                                          ), // Input Write Address write channel ID
  .S0_AXI_GEN_AWADDR (axi_req_o.aw.addr                                        ), // Input Write Address write channel address
  .S0_AXI_GEN_AWLEN  (axi_req_o.aw.len                                         ), // Input Write Address write channel burst length
  .S0_AXI_GEN_AWSIZE (axi_req_o.aw.size                                        ), // Input Write Address write channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_AWBURST(axi_req_o.aw.burst                                       ), // Input Write Address write channel burst type
  .S0_AXI_GEN_AWLOCK (axi_req_o.aw.lock                                        ), // Input Write Address write channel lock type
  .S0_AXI_GEN_AWCACHE(axi_req_o.aw.cache                                       ), // Input Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0111).
  .S0_AXI_GEN_AWPROT (axi_req_o.aw.prot                                        ), // Input Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (010).
  .S0_AXI_GEN_AWQOS  (axi_req_o.aw.qos                                         ), // Input Write Address write channel quality of service
  .S0_AXI_GEN_WDATA  (axi_req_o.w.data                                         ), // Input Write channel data
  .S0_AXI_GEN_WSTRB  (axi_req_o.w.strb                                         ), // Input Write channel write strobe
  .S0_AXI_GEN_WLAST  (axi_req_o.w.last                                         ), // Input Write channel last word flag
  .S0_AXI_GEN_WVALID (axi_req_o.w_valid                                        ), // Input Write channel valid
  .S0_AXI_GEN_BREADY (axi_req_o.b_ready                                        ), // Input Write response channel ready
  
  .M0_AXI_RVALID     (m_axi_read_in.rvalid                                     ), // Input Read channel valid
  .M0_AXI_ARREADY    (m_axi_read_in.arready                                    ), // Input Read Address read channel ready
  .M0_AXI_RLAST      (m_axi_read_in.rlast                                      ), // Input Read channel last word
  .M0_AXI_RDATA      (m_axi_read_in.rdata                                      ), // Input Read channel data
  .M0_AXI_RID        (m_axi_read_in.rid                                        ), // Input Read channel ID
  .M0_AXI_RRESP      (m_axi_read_in.rresp                                      ), // Input Read channel response
  .M0_AXI_ARVALID    (m_axi_read_out.arvalid                                   ), // Output Read Address read channel valid
  .M0_AXI_ARADDR     ({m_axi_read_out_araddr_63, m_axi_read_out.araddr[62:0]}  ), // Output Read Address read channel address
  .M0_AXI_ARLEN      (m_axi_read_out.arlen                                     ), // Output Read Address channel burst length
  .M0_AXI_RREADY     (m_axi_read_out.rready                                    ), // Output Read Read channel ready
  .M0_AXI_ARID       (m_axi_read_out.arid                                      ), // Output Read Address read channel ID
  .M0_AXI_ARSIZE     (m_axi_read_out.arsize                                    ), // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_ARBURST    (m_axi_read_out.arburst                                   ), // Output Read Address read channel burst type
  .M0_AXI_ARLOCK     (m_axi_read_out.arlock                                    ), // Output Read Address read channel lock type
  .M0_AXI_ARCACHE    (m_axi_read_out_arcache                                   ), // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0111).
  .M0_AXI_ARPROT     (m_axi_read_out.arprot                                    ), // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (010).
  .M0_AXI_ARQOS      (m_axi_read_out.arqos                                     ), // Output Read Address channel quality of service
  .M0_AXI_AWREADY    (m_axi_write_in.awready                                   ), // Input Write Address write channel ready
  .M0_AXI_WREADY     (m_axi_write_in.wready                                    ), // Input Write channel ready
  .M0_AXI_BID        (m_axi_write_in.bid                                       ), // Input Write response channel ID
  .M0_AXI_BRESP      (m_axi_write_in.bresp                                     ), // Input Write channel response
  .M0_AXI_BVALID     (m_axi_write_in.bvalid                                    ), // Input Write response channel valid
  .M0_AXI_AWVALID    (m_axi_write_out.awvalid                                  ), // Output Write Address write channel valid
  .M0_AXI_AWID       (m_axi_write_out.awid                                     ), // Output Write Address write channel ID
  .M0_AXI_AWADDR     ({m_axi_write_out_awaddr_63, m_axi_write_out.awaddr[62:0]}), // Output Write Address write channel address
  .M0_AXI_AWLEN      (m_axi_write_out.awlen                                    ), // Output Write Address write channel burst length
  .M0_AXI_AWSIZE     (m_axi_write_out.awsize                                   ), // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_AWBURST    (m_axi_write_out.awburst                                  ), // Output Write Address write channel burst type
  .M0_AXI_AWLOCK     (m_axi_write_out.awlock                                   ), // Output Write Address write channel lock type
  .M0_AXI_AWCACHE    (m_axi_read_out_awcache                                   ), // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0111).
  .M0_AXI_AWPROT     (m_axi_write_out.awprot                                   ), // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (010).
  .M0_AXI_AWQOS      (m_axi_write_out.awqos                                    ), // Output Write Address write channel quality of service
  .M0_AXI_WDATA      (m_axi_write_out.wdata                                    ), // Output Write channel data
  .M0_AXI_WSTRB      (m_axi_write_out.wstrb                                    ), // Output Write channel write strobe
  .M0_AXI_WLAST      (m_axi_write_out.wlast                                    ), // Output Write channel last word flag
  .M0_AXI_WVALID     (m_axi_write_out.wvalid                                   ), // Output Write channel valid
  .M0_AXI_BREADY     (m_axi_write_out.bready                                   ), // Output Write response channel ready
  
  
  .ACLK              (ap_clk                                                   ),
  .ARESETN           (areset_cu_cache                                          ),
  .Initializing      (cache_setup_signal_int                                   )
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
assign sram_request_mem.iob.valid = sram_request_mem_int.iob.valid;
assign sram_request_mem.iob.addr  = sram_request_mem_int.iob.addr;
assign sram_request_mem.iob.wdata = sram_request_mem_int.iob.wdata;
assign sram_request_mem.iob.wstrb = sram_request_mem_int.iob.wstrb;
assign sram_request_mem.meta      = sram_request_mem_int.meta;
assign sram_request_mem.data      = sram_request_mem_int.data;

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
assign fifo_response_din = sram_request_mem;

// Pop
assign fifo_response_signals_in_int.rd_en = sram_response_mem_reg.iob.valid ;
assign response_in_int.valid              = fifo_response_signals_out_int.valid;
always_comb response_in_int.payload       = map_CacheResponse_to_MemoryResponsePacket(fifo_response_dout, sram_response_mem_reg_S2);

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
  sram_response_mem_reg    <= sram_response_mem;
  sram_response_mem_reg_S2 <= sram_response_mem_reg;
end

// --------------------------------------------------------------------------------------
// SRAM Commands State Machine
// --------------------------------------------------------------------------------------
assign fifo_request_signals_out_valid_int = fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & fifo_response_signals_in_reg.rd_en & descriptor_in_reg.valid;
assign sram_request_mem_int.iob.valid     = fifo_request_signals_out_valid_int;
assign fifo_request_signals_in_int.rd_en  = sram_response_mem.iob.ready;
assign fifo_response_signals_in_int.wr_en = sram_response_mem.iob.ready;
assign cmd_read_condition                 = (fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH);
assign cmd_write_condition                = (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE)| (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_WRITE);

always_comb begin
  sram_request_mem_int.iob.wstrb = fifo_request_dout.iob.wstrb & {32{(cmd_write_condition)}};
  sram_request_mem_int.iob.addr  = fifo_request_dout.iob.addr;
  sram_request_mem_int.iob.wdata = fifo_request_dout.iob.wdata;
  sram_request_mem_int.meta      = fifo_request_dout.meta;
  sram_request_mem_int.data      = fifo_request_dout.data;
end


  endmodule : m01_axi_cu_cache_mid32x64_fe32x64_wrapper
  