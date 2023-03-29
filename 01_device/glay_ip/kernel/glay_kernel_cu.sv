// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_cu.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_REQ_PKG::*;

module glay_kernel_cu #(
  parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
  parameter NUM_MODULES        = 3              ,
  parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                           ap_clk          ,
  input  logic                           areset          ,
  input  GlayControlChainInterfaceInput  glay_control_in ,
  output GlayControlChainInterfaceOutput glay_control_out,
  input  GLAYDescriptorInterface         glay_descriptor ,
  input  AXI4MasterReadInterfaceInput    m_axi_read_in   ,
  output AXI4MasterReadInterfaceOutput   m_axi_read_out  ,
  input  AXI4MasterWriteInterfaceInput   m_axi_write_in  ,
  output AXI4MasterWriteInterfaceOutput  m_axi_write_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
// AXI write master stage
  logic                          m_axi_areset             ;
  logic                          control_areset           ;
  logic                          cache_areset             ;
  logic                          fifo_areset              ;
  logic                          arbiter_areset           ;
  logic                          setup_areset             ;
  logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_done_reg         ;
  logic [       NUM_MODULES-1:0] glay_cu_setup_state      ;
  logic                          fifo_setup_signal_638x128;
  logic                          fifo_setup_signal_516x128;

  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;

  GlayControlChainInterfaceInput  glay_control_in_reg    ;
  GlayControlChainInterfaceOutput glay_control_out_reg   ;
  GLAYDescriptorInterface         glay_descriptor_in_reg ;
  GLAYDescriptorInterface         glay_descriptor_out_reg;


  // assign m_axi_write.out = 0;
  // assign m_axi_read.out  = 0;

  // assign m_axi_write.out.awburst = M_AXI4_BURST_INCR;
  // assign m_axi_read.out.arburst  = M_AXI4_BURST_INCR;
  // assign m_axi_write.out.awsize  = M_AXI4_SIZE_64B;
  // assign m_axi_read.out.arsize   = M_AXI4_SIZE_64B;
  // assign m_axi_write.out.awcache = M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;
  // assign m_axi_read.out.arcache  = M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;

  logic [VERTEX_DATA_BITS-1:0] counter;

// --------------------------------------------------------------------------------------
//   AXI Cache FIFO signals
// --------------------------------------------------------------------------------------

  GlayCacheRequestInterfaceInput glay_cache_req_in;

  GlayCacheRequestInterfaceInput glay_cache_req_in_fifo_dout;
  GlayCacheRequestInterfaceInput glay_cache_req_in_fifo_din ;

  GlayCacheRequestInterfaceOutput glay_cache_req_out_fifo_dout;
  GlayCacheRequestInterfaceOutput glay_cache_req_out_fifo_din ;

  FIFOStateSignalsOutput cache_req_in_fifo_out_signals ;
  FIFOStateSignalsOutput cache_req_out_fifo_out_signals;

  FIFOStateSignalsInput cache_req_in_fifo_in_signals ;
  FIFOStateSignalsInput cache_req_out_fifo_in_signals;

  logic force_inv_in ;
  logic force_inv_out;
  logic wtb_empty_in ;
  logic wtb_empty_out;

  assign force_inv_in = 1'b0;
  assign wtb_empty_in = 1'b1;

  assign glay_cache_req_in.valid = 1'b0;

// --------------------------------------------------------------------------------------
// Bus arbiter Signals fifo_638x128_GlayCacheRequestInterfaceInput
// --------------------------------------------------------------------------------------
  localparam BUS_ARBITER_N_IN_1_OUT_WIDTH     = 2                                    ;
  localparam BUS_ARBITER_N_IN_1_OUT_BUS_NUM   = BUS_ARBITER_N_IN_1_OUT_WIDTH         ;
  localparam BUS_ARBITER_N_IN_1_OUT_BUS_WIDTH = $bits(GlayCacheRequestInterfaceInput);

  GlayCacheRequestInterfaceInput bus_out                                    ;
  GlayCacheRequestInterfaceInput bus_in [0:BUS_ARBITER_N_IN_1_OUT_BUS_NUM-1];

  logic [1:0] grant;
  logic [1:0] req  ;

// --------------------------------------------------------------------------------------
// GLay Signals setup and configuration reading
// --------------------------------------------------------------------------------------
  GlayControlChainInterfaceOutput glay_kernel_setup_control_state           ;
  GLAYDescriptorInterface         glay_kernel_setup_descriptor              ;
  MemoryResponsePacket            glay_kernel_setup_cache_resp_in           ;
  FIFOStateSignalsOutput          glay_kernel_setup_req_in_fifo_out_signals ;
  FIFOStateSignalsInput           glay_kernel_setup_req_in_fifo_in_signals  ;
  MemoryRequestPacket             glay_kernel_setup_cache_req_out           ;
  FIFOStateSignalsOutput          glay_kernel_setup_req_out_fifo_out_signals;
  FIFOStateSignalsInput           glay_kernel_setup_req_out_fifo_in_signals ;
  logic                           glay_kernel_setup_fifo_setup_signal       ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    m_axi_areset   <= areset;
    control_areset <= areset;
    cache_areset   <= areset;
    fifo_areset    <= areset;
    arbiter_areset <= areset;
    setup_areset   <= areset;
  end

// --------------------------------------------------------------------------------------
// Done Logic
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      counter          <= 0;
      glay_cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
    end
    else begin
      if (glay_descriptor_out_reg.valid) begin
        if(counter > 2000) begin
          glay_cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b1}};
          counter          <= 0;
        end
        else begin
          counter <= counter + 1;
        end
      end else begin
        glay_cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
        counter          <= 0;
      end
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_cu_setup_state <= {NUM_GRAPH_CLUSTERS{1'b1}};
    end
    else begin
      glay_cu_setup_state[0] <= fifo_setup_signal_638x128;
      glay_cu_setup_state[1] <= fifo_setup_signal_516x128;
      glay_cu_setup_state[2] <= glay_kernel_setup_fifo_setup_signal;
    end
  end

// --------------------------------------------------------------------------------------
// GLay control signals
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_in_reg.ap_start    <= 1'b0;
      glay_control_in_reg.ap_continue <= 1'b0;
      glay_control_in_reg.glay_setup  <= 1'b1;
      glay_control_in_reg.glay_done   <= 1'b0;
    end
    else begin
      glay_control_in_reg.ap_start    <= glay_control_in.ap_start ;
      glay_control_in_reg.ap_continue <= glay_control_in.ap_continue;
      glay_control_in_reg.glay_setup  <= ~|glay_cu_setup_state;
      glay_control_in_reg.glay_done   <= &glay_cu_done_reg;
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_out.ap_ready   <= 1'b0;
      glay_control_out.ap_done    <= 1'b0;
      glay_control_out.ap_idle    <= 1'b1;
      glay_control_out.glay_start <= 1'b0;
    end
    else begin
      glay_control_out.ap_ready   <= glay_control_out_reg.ap_ready;
      glay_control_out.ap_idle    <= glay_control_out_reg.ap_idle;
      glay_control_out.ap_done    <= glay_control_out_reg.ap_done;
      glay_control_out.glay_start <= glay_control_out_reg.glay_start;
    end
  end

  glay_kernel_control #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_glay_kernel_control (
    .ap_clk             (ap_clk                 ),
    .areset             (control_areset         ),
    .glay_control_in    (glay_control_in_reg    ),
    .glay_control_out   (glay_control_out_reg   ),
    .glay_descriptor_in (glay_descriptor_in_reg ),
    .glay_descriptor_out(glay_descriptor_out_reg)
  );

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
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
    if (m_axi_areset) begin
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
    if (m_axi_areset) begin
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
    if (m_axi_areset) begin
      m_axi_read_out <= 0;
    end
    else begin
      m_axi_read_out <= m_axi_read.out;
    end
  end

// --------------------------------------------------------------------------------------
// READ GLAY Descriptor Control
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_descriptor_in_reg.valid <= 0;
    end
    else begin
      glay_descriptor_in_reg.valid <= glay_descriptor.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    glay_descriptor_in_reg.payload <= glay_descriptor.payload;
  end

// --------------------------------------------------------------------------------------
// Drive GLAY Setup signals to other modules
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (setup_areset) begin
      glay_kernel_setup_descriptor.valid <= 0;
    end
    else begin
      glay_kernel_setup_descriptor.valid <= glay_descriptor_out_reg.valid;
    end
  end

  always_ff @(posedge ap_clk) begin
    glay_kernel_setup_descriptor.payload <= glay_descriptor_out_reg.payload;
  end

// --------------------------------------------------------------------------------------
// GLAY AXI port cache
// --------------------------------------------------------------------------------------
  iob_cache_axi #(
    .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
    .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),
    .CACHE_N_WAYS         (CACHE_N_WAYS         ),
    .CACHE_LINE_OFF_W     (CACHE_LINE_OFF_W     ),
    .CACHE_WORD_OFF_W     (CACHE_WORD_OFF_W     ),
    .CACHE_WTBUF_DEPTH_W  (CACHE_WTBUF_DEPTH_W  ),
    .CACHE_REP_POLICY     (CACHE_REP_POLICY     ),
    .CACHE_NWAY_W         (CACHE_NWAY_W         ),
    .CACHE_FRONTEND_NBYTES(CACHE_FRONTEND_NBYTES),
    .CACHE_FRONTEND_BYTE_W(CACHE_FRONTEND_BYTE_W),
    .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W ),
    .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W ),
    .CACHE_BACKEND_NBYTES (CACHE_BACKEND_NBYTES ),
    .CACHE_BACKEND_BYTE_W (CACHE_BACKEND_BYTE_W ),
    .CACHE_LINE2MEM_W     (CACHE_LINE2MEM_W     ),
    .CACHE_WRITE_POL      (CACHE_WRITE_POL      ),
    .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W     ),
    .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W     ),
    .CACHE_AXI_ID_W       (CACHE_AXI_ID_W       ),
    .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W      ),
    .CACHE_AXI_ID         (CACHE_AXI_ID         ),
    .CACHE_CTRL_CACHE     (CACHE_CTRL_CACHE     ),
    .CACHE_CTRL_CNT       (CACHE_CTRL_CNT       ),
    .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W     ),
    .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W    ),
    .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W     ),
    .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W      ),
    .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W    ),
    .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W     )
  ) inst_glay_cache_axi (
    .valid        (glay_cache_req_in_fifo_dout.payload.valid),
    .addr         (glay_cache_req_in_fifo_dout.payload.addr ),
    .wdata        (glay_cache_req_in_fifo_dout.payload.wdata),
    .wstrb        (glay_cache_req_in_fifo_dout.payload.wstrb),
    .rdata        (glay_cache_req_out_fifo_din.payload.rdata),
    .ready        (glay_cache_req_out_fifo_din.payload.ready),
    .force_inv_in (force_inv_in                             ),
    .force_inv_out(force_inv_out                            ),
    .wtb_empty_in (wtb_empty_in                             ),
    .wtb_empty_out(wtb_empty_out                            ),
    `include "m_axi_portmap_glay.vh"
    .ap_clk       (ap_clk                                   ),
    .reset        (cache_areset                             )
  );

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
  assign fifo_setup_signal_638x128 = cache_req_out_fifo_out_signals.wr_rst_busy | cache_req_out_fifo_out_signals.rd_rst_busy ;
  assign fifo_setup_signal_516x128 = cache_req_in_fifo_out_signals.wr_rst_busy  | cache_req_in_fifo_out_signals.rd_rst_busy;

// --------------------------------------------------------------------------------------
// FIFO cache requests in fifo_638x128_GlayCacheRequestInterfaceInput
// --------------------------------------------------------------------------------------
  fifo_638x128 inst_fifo_638x128_GlayCacheRequestInterfaceInput (
    .clk         (ap_clk                                    ),
    .srst        (fifo_areset                               ),
    .din         (glay_cache_req_in_fifo_din                ),
    .wr_en       (cache_req_in_fifo_in_signals.wr_en        ),
    .rd_en       (cache_req_in_fifo_in_signals.rd_en        ),
    .dout        (glay_cache_req_in_fifo_dout               ),
    .full        (cache_req_in_fifo_out_signals.full        ),
    .almost_full (cache_req_in_fifo_out_signals.almost_full ),
    .empty       (cache_req_in_fifo_out_signals.empty       ),
    .almost_empty(cache_req_in_fifo_out_signals.almost_empty),
    .valid       (cache_req_in_fifo_out_signals.valid       ),
    .prog_full   (cache_req_in_fifo_out_signals.prog_full   ),
    .prog_empty  (cache_req_in_fifo_out_signals.prog_empty  ),
    .wr_rst_busy (cache_req_in_fifo_out_signals.wr_rst_busy ),
    .rd_rst_busy (cache_req_in_fifo_out_signals.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_516x128_GlayCacheRequestInterfaceOutput
// --------------------------------------------------------------------------------------
  fifo_516x128 inst_fifo_516x128_GlayCacheRequestInterfaceOutput (
    .clk         (ap_clk                                     ),
    .srst        (fifo_areset                                ),
    .din         (glay_cache_req_out_fifo_din                ),
    .wr_en       (cache_req_out_fifo_in_signals.wr_en        ),
    .rd_en       (cache_req_out_fifo_in_signals.rd_en        ),
    .dout        (glay_cache_req_out_fifo_dout               ),
    .full        (cache_req_out_fifo_out_signals.full        ),
    .almost_full (cache_req_out_fifo_out_signals.almost_full ),
    .empty       (cache_req_out_fifo_out_signals.empty       ),
    .almost_empty(cache_req_out_fifo_out_signals.almost_empty),
    .valid       (cache_req_out_fifo_out_signals.valid       ),
    .prog_full   (cache_req_out_fifo_out_signals.prog_full   ),
    .prog_empty  (cache_req_out_fifo_out_signals.prog_empty  ),
    .wr_rst_busy (cache_req_out_fifo_out_signals.wr_rst_busy ),
    .rd_rst_busy (cache_req_out_fifo_out_signals.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// Bus arbiter for fifo_638x128_GlayCacheRequestInterfaceInput
// --------------------------------------------------------------------------------------
  assign bus_in[0] = glay_kernel_setup_cache_req_out;
  assign req[0]    = glay_kernel_setup_cache_req_out.valid;

  assign bus_in[1] = 0;
  assign req[1]    = 0;

  assign glay_cache_req_in_fifo_din = bus_out;

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
// GLay initial setup and configuration reading
// --------------------------------------------------------------------------------------
  assign glay_setup_cache_resp_in = glay_cache_req_out_fifo_dout;

  glay_kernel_setup #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_glay_kernel_setup (
    .ap_clk                  (ap_clk                                    ),
    .areset                  (setup_areset                              ),
    .glay_control_state      (glay_kernel_setup_control_state           ),
    .glay_descriptor         (glay_kernel_setup_descriptor              ),
    .glay_setup_cache_resp_in(glay_kernel_setup_cache_resp_in           ),
    .req_in_fifo_out_signals (glay_kernel_setup_req_in_fifo_out_signals ),
    .req_in_fifo_in_signals  (glay_kernel_setup_req_in_fifo_in_signals  ),
    .glay_setup_cache_req_out(glay_kernel_setup_cache_req_out           ),
    .req_out_fifo_out_signals(glay_kernel_setup_req_out_fifo_out_signals),
    .req_out_fifo_in_signals (glay_kernel_setup_req_out_fifo_in_signals ),
    .fifo_setup_signal       (glay_kernel_setup_fifo_setup_signal       )
  );

endmodule : glay_kernel_cu
