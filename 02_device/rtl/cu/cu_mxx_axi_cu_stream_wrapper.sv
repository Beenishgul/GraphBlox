
// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m00_axi_cu_stream_mid_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"



module m00_axi_cu_stream_mid32x33_fe32x33_wrapper #(
  parameter NUM_CHANNELS_READ = 1 ,
  parameter FIFO_WRITE_DEPTH  = 64,
  parameter PROG_THRESH       = 32
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
    assign m_axi_write_out = 0;
// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_m_axi       ;
    logic areset_fifo        ;
    logic areset_engine_m_axi;
    logic areset_control     ;

    KernelDescriptor descriptor_in_reg;

    MemoryPacketRequest  request_in_reg      ;
    CacheRequest         cache_request_in_reg;
    MemoryPacketResponse response_in_int     ;

    logic fifo_empty_int;
    logic fifo_empty_reg;

    logic cmd_read_condition ;
    logic cmd_halt_condition ;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
    M00_AXI4_MID_MasterReadInterface  m_axi_read ;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
    CacheRequestPayload  stream_request_mem     ;
    CacheRequestPayload  stream_request_mem_int ;
    CacheResponsePayload stream_response_mem    ;
    // CacheResponsePayload stream_response_mem_reg;

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
    CacheRequestPayload           fifo_response_din             ;
    CacheRequestPayload           fifo_response_dout            ;
    FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
    FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
    FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
    logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// READ/WRITE ENGINE
// --------------------------------------------------------------------------------------
    logic                                                    read_transaction_done_out     ;
    logic                                                    read_transaction_start_in     ;
    logic [  NUM_CHANNELS_READ-1:0]                          read_transaction_prog_full    ;
    logic [  NUM_CHANNELS_READ-1:0]                          read_transaction_tready_in    ;
    logic [  NUM_CHANNELS_READ-1:0]                          read_transaction_tvalid_out   ;
    logic [  NUM_CHANNELS_READ-1:0][M00_AXI4_MID_ADDR_W-1:0] read_transaction_offset_in    ;
    logic [  NUM_CHANNELS_READ-1:0][M00_AXI4_MID_DATA_W-1:0] read_transaction_tdata_out    ;
    logic [M00_AXI4_MID_DATA_W-1:0]                          read_transaction_length_in    ;

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
    logic                           areset_counter         ;
    logic                           counter_load           ;
    logic                           command_counter_is_zero;
     type_m01_axi4_fe_len   command_counter_       ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      areset_m_axi        <= areset;
      areset_fifo         <= areset;
      areset_control      <= areset;
      areset_engine_m_axi <= areset;
      areset_counter      <= areset;
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

    assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty;

    always_ff @(posedge ap_clk) begin
      fifo_request_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
      fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
      response_out.payload      <= response_in_int.payload;
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
    assign fifo_request_signals_in_int.wr_en = cache_request_in_reg.valid;
    assign fifo_request_din.iob              = cache_request_in_reg.payload.iob;
    assign fifo_request_din.meta             = cache_request_in_reg.payload.meta;
    assign fifo_request_din.data             = cache_request_in_reg.payload.data;

// Pop
// assign fifo_request_signals_in_int.rd_en = stream_request_pop_int;
    assign stream_request_mem.iob.valid = stream_request_mem_int.iob.valid;
    assign stream_request_mem.iob.addr  = stream_request_mem_int.iob.addr;
    assign stream_request_mem.iob.wdata = stream_request_mem_int.iob.wdata;
    assign stream_request_mem.iob.wstrb = stream_request_mem_int.iob.wstrb;
    assign stream_request_mem.meta      = stream_request_mem_int.meta;
    assign stream_request_mem.data      = stream_request_mem_int.data;

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
    assign fifo_response_signals_in_int.wr_en   = stream_response_mem.iob.valid & cmd_halt_condition;
    always_comb fifo_response_din               = map_CacheResponse_to_MemoryResponsePacket(fifo_request_dout, stream_response_mem);

// Pop
    assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en ;
    assign response_in_int.valid              = fifo_response_signals_out_int.valid;
    always_comb response_in_int.payload       = fifo_response_dout;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH           ),
    .WRITE_DATA_WIDTH($bits(CacheRequestPayload )),
    .READ_DATA_WIDTH ($bits(CacheRequestPayload )),
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

    // always_ff @(posedge ap_clk) begin
    //   stream_response_mem_reg <= stream_response_mem;
    // end

// --------------------------------------------------------------------------------------
// Cache Commands Read State Machine
// --------------------------------------------------------------------------------------
    cu_stream_command_generator_state current_state;
    cu_stream_command_generator_state next_state   ;

    logic cmd_read_pending ;
// --------------------------------------------------------------------------------------
//   State Machine AP_USER_MANAGED sync
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      if(areset_control)
        current_state <= CU_STREAM_CMD_RESET;
      else begin
        current_state <= next_state;
      end
    end// always_ff @(posedge ap_clk)
// --------------------------------------------------------------------------------------
    assign fifo_request_signals_out_valid_int = ~command_counter_is_zero & fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & fifo_response_signals_in_reg.rd_en & descriptor_in_reg.valid;
    assign cmd_read_condition                 = ((fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH))  & fifo_request_signals_out_valid_int;
    assign cmd_halt_condition                 = ~command_counter_is_zero & ~fifo_response_signals_out_int.prog_full & descriptor_in_reg.valid;
// --------------------------------------------------------------------------------------

    always_comb begin
      next_state = current_state;
      case (current_state)
        CU_STREAM_CMD_RESET : begin
          next_state = CU_STREAM_CMD_READY;
        end
        CU_STREAM_CMD_READY : begin
          if(cmd_read_condition)
            next_state = CU_STREAM_CMD_READ_TRANS;
          else
            next_state = CU_STREAM_CMD_READY;
        end
        CU_STREAM_CMD_READ_TRANS : begin
          next_state = CU_STREAM_CMD_PENDING;
        end
        CU_STREAM_CMD_PENDING : begin
          if(command_counter_is_zero)
            next_state = CU_STREAM_CMD_DONE;
          else
            next_state = CU_STREAM_CMD_PENDING;
        end
        CU_STREAM_CMD_DONE : begin
          next_state = CU_STREAM_CMD_READY;
        end
        default : begin
          next_state = CU_STREAM_CMD_RESET;
        end
      endcase
    end// always_comb
// State Transition Logic

    always_ff @(posedge ap_clk) begin
      case (current_state)
        CU_STREAM_CMD_RESET : begin
          cmd_read_pending                   <= 1'b0;
          counter_load                       <= 1'b0;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
        end
        CU_STREAM_CMD_READY : begin
          cmd_read_pending                   <= 1'b0;
          counter_load                       <= 1'b1;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
        end
        CU_STREAM_CMD_READ_TRANS : begin
          cmd_read_pending                   <= 1'b1;
          counter_load                       <= 1'b0;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b1;
        end
        CU_STREAM_CMD_PENDING : begin
          counter_load                       <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
          if(command_counter_is_zero)
            fifo_request_signals_in_int.rd_en  <= 1'b1;
          else
            fifo_request_signals_in_int.rd_en  <= 1'b0;
        end
        CU_STREAM_CMD_DONE : begin
          cmd_read_pending                   <= 1'b0;
          counter_load                       <= 1'b0;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
        end
      endcase
    end// always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
    always_comb begin
      stream_request_mem_int.iob.wstrb = 0;
      stream_request_mem_int.iob.addr  = fifo_request_dout.iob.addr;
      stream_request_mem_int.iob.wdata = fifo_request_dout.iob.wdata;
      stream_request_mem_int.meta      = fifo_request_dout.meta;
      stream_request_mem_int.data      = fifo_request_dout.data;
    end

// --------------------------------------------------------------------------------------
// READ Stream
// --------------------------------------------------------------------------------------
    assign read_transaction_length_in = { {M00_AXI4_MID_DATA_W - $bits(fifo_request_dout.meta.address.burst_length){1'b0}}, fifo_request_dout.meta.address.burst_length };
    assign read_transaction_start_in  = stream_request_mem_int.iob.valid & ((fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH));
    assign read_transaction_offset_in = stream_request_mem_int.iob.addr;
    assign read_transaction_tready_in = cmd_read_pending & cmd_halt_condition;
// --------------------------------------------------------------------------------------
// output Stream
// --------------------------------------------------------------------------------------
    assign stream_response_mem.iob.ready = ~read_transaction_prog_full;
    assign stream_response_mem.iob.valid = read_transaction_tvalid_out;
    assign stream_response_mem.iob.rdata = read_transaction_tdata_out;

    assign stream_response_mem.data = 0;
    assign stream_response_mem.meta = 0;


  engine_m_axi #(
    .C_NUM_CHANNELS     (NUM_CHANNELS_READ                        ),
    .M_AXI4_MID_ADDR_W  (M00_AXI4_MID_ADDR_W                      ),
    .M_AXI4_MID_BURST_W (M00_AXI4_MID_BURST_W                     ),
    .M_AXI4_MID_CACHE_W (M00_AXI4_MID_CACHE_W                     ),
    .M_AXI4_MID_DATA_W  (M00_AXI4_MID_DATA_W                      ),
    .M_AXI4_MID_ID_W    (M00_AXI4_MID_ID_W                        ),
    .M_AXI4_MID_LEN_W   (M00_AXI4_MID_LEN_W                       ),
    .M_AXI4_MID_LOCK_W  (M00_AXI4_MID_LOCK_W                      ),
    .M_AXI4_MID_PROT_W  (M00_AXI4_MID_PROT_W                      ),
    .M_AXI4_MID_QOS_W   (M00_AXI4_MID_QOS_W                       ),
    .M_AXI4_MID_REGION_W(M00_AXI4_MID_REGION_W                    ),
    .M_AXI4_MID_RESP_W  (M00_AXI4_MID_RESP_W                      ),
    .M_AXI4_MID_SIZE_W  (M00_AXI4_MID_SIZE_W                      ),
    .C_AXI_RW_CACHE     (M00_AXI4_MID_CACHE_BUFFERABLE_NO_ALLOCATE)
  ) inst_engine_m_axi (
    .read_transaction_done_out   (read_transaction_done_out   ),
    .read_transaction_length_in  (read_transaction_length_in  ),
    .read_transaction_offset_in  (read_transaction_offset_in  ),
    .read_transaction_start_in   (read_transaction_start_in   ),
    .read_transaction_tdata_out  (read_transaction_tdata_out  ),
    .read_transaction_tready_in  (read_transaction_tready_in  ),
    .read_transaction_tvalid_out (read_transaction_tvalid_out ),
    .read_transaction_prog_full  (read_transaction_prog_full  ),
    `include "m_axi_portmap_buffer.vh"
    .ap_clk                      (ap_clk                      ),
    .areset                      (areset_engine_m_axi         )
  );

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
  counter #(.C_WIDTH($bits(type_m01_axi4_fe_len))) inst_write_command_counter (
    .ap_clk      (ap_clk                                          ),
    .ap_clken    (1'b1                                            ),
    .areset      (areset_counter                                  ),
    .load        (counter_load                                    ),
    .incr        (1'b0                                            ),
    .decr        (stream_response_mem.iob.valid                   ),
    .load_value  (fifo_request_dout.meta.address.burst_length     ),
    .stride_value({{($bits(type_m01_axi4_fe_len)-1){1'b0}},{1'b1}}),
    .count       (command_counter_                                ),
    .is_zero     (command_counter_is_zero                         )
  );


  endmodule : m00_axi_cu_stream_mid32x33_fe32x33_wrapper
  