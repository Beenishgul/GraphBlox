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
  logic                          m_axi_areset       ;
  logic                          control_areset     ;
  logic                          cache_areset       ;
  logic                          fifo_areset        ;
  logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_done_reg   ;
  logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_setup_reg  ;
  logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_setup_reg_2;

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

  GlayCacheRequestInterfaceInput  glay_cache_req_in ;
  GlayCacheRequestInterfaceOutput glay_cache_req_out;

  GlayCacheRequestInterfaceInput glay_cache_req_in_fifo_dout;
  GlayCacheRequestInterfaceInput glay_cache_req_in_fifo_din ;

  GlayCacheRequestInterfaceOutput glay_cache_req_out_fifo_dout;
  GlayCacheRequestInterfaceOutput glay_cache_req_out_fifo_din ;

  FIFOStateSignals cache_req_in_fifo_signals ;
  FIFOStateSignals cache_req_out_fifo_signals;

  logic force_inv_in           ;
  logic force_inv_out          ;
  logic wtb_empty_in           ;
  logic wtb_empty_out          ;
  logic cache_fifo_setup_signal;

  assign force_inv_in = 1'b0;
  assign wtb_empty_in = 1'b1;

  assign glay_cache_req_in.valid = 1'b0;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    m_axi_areset   <= areset;
    control_areset <= areset;
    cache_areset   <= areset;
    fifo_areset    <= areset;
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
      glay_cu_setup_reg <= {NUM_GRAPH_CLUSTERS{1'b1}};
    end
    else begin
      glay_cu_setup_reg <= glay_cu_setup_reg_2;
    end
  end

// --------------------------------------------------------------------------------------
// GLay control chain signals
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_in_reg.glay_start    <= 1'b0;
      glay_control_in_reg.glay_continue <= 1'b0;
    end
    else begin
      glay_control_in_reg.glay_start    <= glay_control_in.glay_start ;
      glay_control_in_reg.glay_continue <= glay_control_in.glay_continue;
    end
  end

  always_ff @(posedge ap_clk) begin
    if (control_areset) begin
      glay_control_out.glay_ready <= 1'b0;
      glay_control_out.glay_done  <= 1'b0;
      glay_control_out.glay_idle  <= 1'b1;
    end
    else begin
      glay_control_out.glay_ready <= glay_control_out_reg.glay_ready;
      glay_control_out.glay_idle  <= glay_control_out_reg.glay_idle;
      glay_control_out.glay_done  <= glay_control_out_reg.glay_done;
    end
  end

  glay_kernel_control #(
    .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
    .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
  ) inst_glay_kernel_control (
    .ap_clk             (ap_clk                 ),
    .areset             (control_areset         ),
    .glay_cu_done_in    (glay_cu_done_reg       ),
    .glay_cu_setup_in   (glay_cu_setup_reg      ),
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
// READ GLAY Descriptor
// --------------------------------------------------------------------------------------

  always_ff @(posedge ap_clk) begin
    if (m_axi_areset) begin
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
    .valid        (glay_cache_req_in.payload.valid ),
    .addr         (glay_cache_req_in.payload.addr  ),
    .wdata        (glay_cache_req_in.payload.wdata ),
    .wstrb        (glay_cache_req_in.payload.wstrb ),
    .rdata        (glay_cache_req_out.payload.rdata),
    .ready        (glay_cache_req_out.payload.ready),
    .force_inv_in (force_inv_in                    ),
    .force_inv_out(force_inv_out                   ),
    .wtb_empty_in (wtb_empty_in                    ),
    .wtb_empty_out(wtb_empty_out                   ),
    `include "m_axi_portmap_glay.vh"
    .ap_clk       (ap_clk                          ),
    .reset        (cache_areset                    )
  );


// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
  assign glay_cu_setup_reg_2 = control_areset | cache_req_out_fifo_signals.wr_rst_busy | cache_req_out_fifo_signals.rd_rst_busy | cache_req_in_fifo_signals.wr_rst_busy | cache_req_in_fifo_signals.rd_rst_busy;

// --------------------------------------------------------------------------------------
// FIFO cache requests in fifo_638x128_GlayCacheRequestInterfaceInput
// --------------------------------------------------------------------------------------
  assign cache_req_in_fifo_signals.wr_en   = glay_cache_req_in_fifo_din.valid;
  assign glay_cache_req_in_fifo_dout.valid = cache_req_in_fifo_signals.valid;
  assign glay_cache_req_in_fifo_din        = 0;
  assign glay_cache_req_in                 = glay_cache_req_in_fifo_dout;

  fifo_638x128 inst_fifo_638x128_GlayCacheRequestInterfaceInput (
    .clk         (ap_clk                                ),
    .srst        (fifo_areset                           ),
    .din         (glay_cache_req_in_fifo_din            ),
    .wr_en       (cache_req_in_fifo_signals.wr_en       ),
    .rd_en       (cache_req_in_fifo_signals.rd_en       ),
    .dout        (glay_cache_req_in_fifo_dout           ),
    .full        (cache_req_in_fifo_signals.full        ),
    .almost_full (cache_req_in_fifo_signals.almost_full ),
    .empty       (cache_req_in_fifo_signals.empty       ),
    .almost_empty(cache_req_in_fifo_signals.almost_empty),
    .valid       (cache_req_in_fifo_signals.valid       ),
    .prog_full   (cache_req_in_fifo_signals.prog_full   ),
    .prog_empty  (cache_req_in_fifo_signals.prog_empty  ),
    .wr_rst_busy (cache_req_in_fifo_signals.wr_rst_busy ),
    .rd_rst_busy (cache_req_in_fifo_signals.rd_rst_busy )
  );

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_516x128_GlayCacheRequestInterfaceOutput
// --------------------------------------------------------------------------------------
  assign cache_req_out_fifo_signals.wr_en  = glay_cache_req_in_fifo_din.valid;
  assign glay_cache_req_in_fifo_dout.valid = cache_req_out_fifo_signals.valid;
  assign glay_cache_req_out.valid          = glay_cache_req_out.payload.ready;
  assign glay_cache_req_out_fifo_din       = glay_cache_req_out;

  fifo_516x128 inst_fifo_516x128_GlayCacheRequestInterfaceOutput (
    .clk         (ap_clk                                 ),
    .srst        (fifo_areset                            ),
    .din         (glay_cache_req_out_fifo_din            ),
    .wr_en       (cache_req_out_fifo_signals.wr_en       ),
    .rd_en       (cache_req_out_fifo_signals.rd_en       ),
    .dout        (glay_cache_req_out_fifo_dout           ),
    .full        (cache_req_out_fifo_signals.full        ),
    .almost_full (cache_req_out_fifo_signals.almost_full ),
    .empty       (cache_req_out_fifo_signals.empty       ),
    .almost_empty(cache_req_out_fifo_signals.almost_empty),
    .valid       (cache_req_out_fifo_signals.valid       ),
    .prog_full   (cache_req_out_fifo_signals.prog_full   ),
    .prog_empty  (cache_req_out_fifo_signals.prog_empty  ),
    .wr_rst_busy (cache_req_out_fifo_signals.wr_rst_busy ),
    .rd_rst_busy (cache_req_out_fifo_signals.rd_rst_busy )
  );


endmodule : glay_kernel_cu
