// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   cu_buffer.sv
// Create : 2023-06-13 23:21:43
// Revise : 2023-08-28 18:21:31
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module cu_buffer #(
  parameter NUM_CHANNELS_READ = 1 ,
  parameter FIFO_WRITE_DEPTH  = 32,
  parameter PROG_THRESH       = 16
) (
  // System Signals
  input  logic                             ap_clk                   ,
  input  logic                             areset                   ,
  input  CacheRequest                      request_in               ,
  output FIFOStateSignalsOutput            fifo_request_signals_out ,
  input  FIFOStateSignalsInput             fifo_request_signals_in  ,
  output CacheResponse                     response_out             ,
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
logic areset_m_axi       ;
logic areset_fifo        ;
logic areset_arbiter     ;
logic areset_setup       ;
logic areset_engine_m_axi;
logic areset_control     ;

CacheRequest  request_in_reg ;
CacheResponse response_in_int;

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
CacheRequestPayload  engine_m_axi_request_mem    ;
CacheRequestPayload  engine_m_axi_request_mem_reg;
CacheResponsePayload engine_m_axi_response_mem   ;

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
// Cache response FIFO
// --------------------------------------------------------------------------------------
CacheResponsePayload          fifo_response_din             ;
CacheResponsePayload          fifo_response_dout            ;
FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// READ/WRITE ENGINE
// --------------------------------------------------------------------------------------
logic                                                read_transaction_done_out     ;
logic                                                read_transaction_start_in     ;
logic [NUM_CHANNELS_READ-1:0]                        read_transaction_prog_full    ;
logic [NUM_CHANNELS_READ-1:0]                        read_transaction_tready_in    ;
logic [NUM_CHANNELS_READ-1:0]                        read_transaction_tvalid_out   ;
logic [NUM_CHANNELS_READ-1:0][M_AXI4_MID_ADDR_W-1:0] read_transaction_offset_in    ;
logic [NUM_CHANNELS_READ-1:0][M_AXI4_MID_DATA_W-1:0] read_transaction_tdata_out    ;
logic [NUM_CHANNELS_READ-1:0][M_AXI4_MID_DATA_W-1:0] read_transaction_tdata_out_reg;
logic [M_AXI4_MID_DATA_W-1:0]                        read_transaction_length_in    ;

logic                         write_transaction_start_in    ;
logic                         write_transaction_tvalid_in   ;
logic [M_AXI4_MID_DATA_W-1:0] write_transaction_length_in   ;
logic [M_AXI4_MID_ADDR_W-1:0] write_transaction_offset_in   ;
logic [M_AXI4_MID_DATA_W-1:0] write_transaction_tdata_in    ;
logic [M_AXI4_MID_DATA_W-1:0] write_transaction_tdata_in_reg;
logic                         write_transaction_done_out    ;
logic                         write_transaction_tready_out  ;


// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_m_axi        <= areset;
  areset_fifo         <= areset;
  areset_arbiter      <= areset;
  areset_setup        <= areset;
  areset_control      <= areset;
  areset_engine_m_axi <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    request_in_reg.valid         <= 1'b0;
    fifo_response_signals_in_reg <= 0;
    fifo_request_signals_in_reg  <= 0;
  end
  else begin
    request_in_reg.valid         <= request_in.valid;
    fifo_response_signals_in_reg <= fifo_response_signals_in;
    fifo_request_signals_in_reg  <= fifo_request_signals_in;
  end
end

always_ff @(posedge ap_clk) begin
  request_in_reg.payload <= request_in.payload;
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

assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty & write_transaction_tready_out;

always_ff @(posedge ap_clk) begin
  fifo_request_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
  fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
  response_out.payload      <= response_in_int.payload;
end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m_axi_write.in <= 0;
  end
  else begin
    m_axi_write.in <= m_axi_write_in;
  end
end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m_axi_read.in <= 0;
  end
  else begin
    m_axi_read.in <= m_axi_read_in;
  end
end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m_axi_write_out <= 0;
  end
  else begin
    m_axi_write_out <= m_axi_write.out;
  end
end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_m_axi) begin
    m_axi_read_out <= 0;
  end
  else begin
    m_axi_read_out <= m_axi_read.out;
  end
end

// --------------------------------------------------------------------------------------
// AXI port engine_m_axi
// --------------------------------------------------------------------------------------
// Request FIFO FWFT
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_signals_in_int.wr_en = request_in_reg.valid;
assign fifo_request_din.iob              = request_in_reg.payload.iob;
assign fifo_request_din.meta             = request_in_reg.payload.meta;
assign fifo_request_din.data             = request_in_reg.payload.data;

// Pop
// assign fifo_request_signals_in_int.rd_en = engine_m_axi_request_pop_int;
assign engine_m_axi_request_mem.iob.valid = engine_m_axi_request_mem_reg.iob.valid;
assign engine_m_axi_request_mem.iob.addr  = engine_m_axi_request_mem_reg.iob.addr;
assign engine_m_axi_request_mem.iob.wdata = engine_m_axi_request_mem_reg.iob.wdata;
assign engine_m_axi_request_mem.iob.wstrb = engine_m_axi_request_mem_reg.iob.wstrb;
assign engine_m_axi_request_mem.meta      = engine_m_axi_request_mem_reg.meta;
assign engine_m_axi_request_mem.data      = engine_m_axi_request_mem_reg.data;

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
// assign fifo_response_signals_in_int.wr_en = engine_m_axi_response_push_int;
assign fifo_response_din.iob  = engine_m_axi_request_mem.iob;
assign fifo_response_din.meta = engine_m_axi_request_mem.meta;
assign fifo_response_din.data = engine_m_axi_request_mem.data;

// Pop
assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en & engine_m_axi_response_mem.iob.valid;
assign response_in_int.valid              = fifo_response_signals_out_int.valid;
// assign response_in_int.payload.iob        = fifo_response_dout.iob;
assign response_in_int.payload.meta = fifo_response_dout.meta;
assign response_in_int.payload.data = fifo_response_dout.data;

assign response_in_int.payload.iob.valid = fifo_response_signals_out_int.valid;
assign response_in_int.payload.iob.ready = fifo_response_signals_out_int.valid;

always_comb begin
  if((fifo_response_dout.meta.subclass.cmd == CMD_MEM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_MEM_PROGRAM) | (fifo_request_dout.meta.subclass.cmd == CMD_MEM_FLUSH))
    response_in_int.payload.iob.rdata = read_transaction_tdata_out_reg;
  else
    response_in_int.payload.iob.rdata = write_transaction_tdata_in_reg;
end

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH           ),
  .WRITE_DATA_WIDTH($bits(CacheResponsePayload)),
  .READ_DATA_WIDTH ($bits(CacheResponsePayload)),
  .PROG_THRESH     (PROG_THRESH                )
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
// Cache Commands Read State Machine
// --------------------------------------------------------------------------------------
cu_engine_m_axi_state current_state;
cu_engine_m_axi_state next_state   ;
// --------------------------------------------------------------------------------------
//   State Machine AP_USER_MANAGED sync
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if(areset_control)
    current_state <= CU_ENGINE_M_AXI_RESET;
  else begin
    current_state <= next_state;
  end
end// always_ff @(posedge ap_clk)

always_comb begin
  next_state = current_state;
  case (current_state)
    CU_ENGINE_M_AXI_RESET : begin
      next_state = CU_ENGINE_M_AXI_READY;
    end
    CU_ENGINE_M_AXI_READY : begin
      if(~fifo_response_signals_out_int.prog_full & ~read_transaction_prog_full & fifo_request_signals_out_valid_int & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_MEM_PROGRAM) | (fifo_request_dout.meta.subclass.cmd == CMD_MEM_FLUSH))
        next_state = CU_ENGINE_M_AXI_CMD_TRANS;
      else if(~fifo_response_signals_out_int.prog_full & engine_m_axi_response_mem.iob.ready & fifo_request_signals_out_valid_int & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE))
        next_state = CU_ENGINE_M_AXI_CMD_TRANS;
      else
        next_state = CU_ENGINE_M_AXI_READY;
    end
    CU_ENGINE_M_AXI_CMD_TRANS : begin
      next_state = CU_ENGINE_M_AXI_PEND;
    end
    CU_ENGINE_M_AXI_PEND : begin
      if(engine_m_axi_response_mem.iob.valid)
        next_state = CU_ENGINE_M_AXI_READY;
      else
        next_state = CU_ENGINE_M_AXI_READY;
    end
    CU_ENGINE_M_AXI_DONE : begin
      next_state = CU_ENGINE_M_AXI_DONE;
    end
  endcase
end// always_comb
// State Transition Logic

always_ff @(posedge ap_clk) begin
  case (current_state)
    CU_ENGINE_M_AXI_RESET : begin
      fifo_request_signals_in_int.rd_en      <= 1'b0;
      fifo_response_signals_in_int.wr_en     <= 1'b0;
      engine_m_axi_request_mem_reg.iob.valid <= 1'b0;
    end
    CU_ENGINE_M_AXI_READY : begin
      fifo_request_signals_in_int.rd_en      <= 1'b0;
      fifo_response_signals_in_int.wr_en     <= 1'b0;
      engine_m_axi_request_mem_reg.iob.valid <= 1'b0;
    end
    CU_ENGINE_M_AXI_CMD_TRANS : begin
      fifo_request_signals_in_int.rd_en      <= 1'b1;
      fifo_response_signals_in_int.wr_en     <= 1'b1;
      engine_m_axi_request_mem_reg.iob.valid <= 1'b1;
    end
    CU_ENGINE_M_AXI_PEND : begin
      fifo_request_signals_in_int.rd_en      <= 1'b0;
      fifo_response_signals_in_int.wr_en     <= 1'b0;
      engine_m_axi_request_mem_reg.iob.valid <= 1'b0;
    end
    CU_ENGINE_M_AXI_DONE : begin
      fifo_request_signals_in_int.rd_en      <= 1'b0;
      fifo_response_signals_in_int.wr_en     <= 1'b0;
      engine_m_axi_request_mem_reg.iob.valid <= 1'b0;
    end
  endcase
end// always_ff @(posedge ap_clk)

assign fifo_request_signals_out_valid_int = fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full;

always_ff @(posedge ap_clk) begin
  engine_m_axi_request_mem_reg.iob.wstrb <= fifo_request_dout.iob.wstrb & {32{((fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE))}};
  engine_m_axi_request_mem_reg.iob.addr  <= fifo_request_dout.iob.addr;
  engine_m_axi_request_mem_reg.iob.wdata <= fifo_request_dout.iob.wdata;
  engine_m_axi_request_mem_reg.meta      <= fifo_request_dout.meta;
  engine_m_axi_request_mem_reg.data      <= fifo_request_dout.data;
  read_transaction_tdata_out_reg         <= engine_m_axi_response_mem.iob.rdata ;
  write_transaction_tdata_in_reg         <= engine_m_axi_request_mem.iob.wdata;
end


assign engine_m_axi_response_mem.iob.ready = write_transaction_tready_out & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE);
assign engine_m_axi_response_mem.iob.valid = (read_transaction_tvalid_out | write_transaction_done_out);
assign engine_m_axi_response_mem.iob.rdata = read_transaction_tdata_out;
assign read_transaction_length_in          = 1;
assign read_transaction_start_in           = engine_m_axi_request_mem_reg.iob.valid & ((fifo_response_dout.meta.subclass.cmd == CMD_MEM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_MEM_PROGRAM) | (fifo_request_dout.meta.subclass.cmd == CMD_MEM_FLUSH));
assign read_transaction_offset_in          = engine_m_axi_request_mem_reg.iob.addr;
assign read_transaction_tready_in          = fifo_request_signals_out_valid_int;
// --------------------------------------------------------------------------------------
// READ/WRITE ENGINE
// --------------------------------------------------------------------------------------
assign write_transaction_start_in  = engine_m_axi_request_mem_reg.iob.valid & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE);
assign write_transaction_tvalid_in = engine_m_axi_request_mem_reg.iob.valid & (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE);
assign write_transaction_length_in = 1;
assign write_transaction_offset_in = engine_m_axi_request_mem_reg.iob.addr;
assign write_transaction_tdata_in  = engine_m_axi_request_mem_reg.iob.wdata;

engine_m_axi #(
  .C_NUM_CHANNELS(NUM_CHANNELS_READ                                ),
  .C_AXI_RW_CACHE(M_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES)
) inst_engine_m_axi (
  .read_transaction_done_out   (read_transaction_done_out   ),
  .read_transaction_length_in  (read_transaction_length_in  ),
  .read_transaction_offset_in  (read_transaction_offset_in  ),
  .read_transaction_start_in   (read_transaction_start_in   ),
  .read_transaction_tdata_out  (read_transaction_tdata_out  ),
  .read_transaction_tready_in  (read_transaction_tready_in  ),
  .read_transaction_tvalid_out (read_transaction_tvalid_out ),
  .read_transaction_prog_full  (read_transaction_prog_full  ),
  .write_transaction_start_in  (write_transaction_start_in  ),
  .write_transaction_tvalid_in (write_transaction_tvalid_in ),
  .write_transaction_length_in (write_transaction_length_in ),
  .write_transaction_offset_in (write_transaction_offset_in ),
  .write_transaction_tdata_in  (write_transaction_tdata_in  ),
  .write_transaction_done_out  (write_transaction_done_out  ),
  .write_transaction_tready_out(write_transaction_tready_out),
  `include "m_axi_portmap_buffer.vh"
  .ap_clk                      (ap_clk                      ),
  .areset                      (areset_engine_m_axi         )
);

endmodule : cu_buffer
