// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel.sv
// Create : 2022-11-29 12:42:56
// Revise : 2022-11-29 12:42:56
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

import PKG_GLOBALS::*;
import PKG_AXI4::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_CACHE::*;

module kernel_afu #(
  parameter C_M00_AXI_ADDR_WIDTH = M_AXI_MEMORY_ADDR_WIDTH     ,
  parameter C_M00_AXI_DATA_WIDTH = M_AXI_MEMORY_DATA_WIDTH_BITS,
  parameter NUM_GRAPH_CLUSTERS   = CU_COUNT_GLOBAL             ,
  parameter NUM_GRAPH_PE         = CU_COUNT_LOCAL
) (
  // System Signals
  input  logic                              ap_clk         ,
  input  logic                              ap_rst_n       ,
  // AXI4 master interface m00_axi
  output logic                              m00_axi_awvalid,
  input  logic                              m00_axi_awready,
  output logic [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr ,
  output logic [                     8-1:0] m00_axi_awlen  ,
  output logic                              m00_axi_wvalid ,
  input  logic                              m00_axi_wready ,
  output logic [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata  ,
  output logic [C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb  ,
  output logic                              m00_axi_wlast  ,
  input  logic                              m00_axi_bvalid ,
  output logic                              m00_axi_bready ,
  output logic                              m00_axi_arvalid,
  input  logic                              m00_axi_arready,
  output logic [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr ,
  output logic [                     8-1:0] m00_axi_arlen  ,
  input  logic                              m00_axi_rvalid ,
  output logic                              m00_axi_rready ,
  input  logic [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata  ,
  input  logic                              m00_axi_rlast  ,
  // Control Signals
  // AXI4 master interface m00_axi missing ports
  input  logic [        CACHE_AXI_ID_W-1:0] m00_axi_bid    ,
  input  logic [        CACHE_AXI_ID_W-1:0] m00_axi_rid    ,
  input  logic [                     2-1:0] m00_axi_rresp  ,
  input  logic [                     2-1:0] m00_axi_bresp  ,
  output logic [        CACHE_AXI_ID_W-1:0] m00_axi_awid   ,
  output logic [                     3-1:0] m00_axi_awsize ,
  output logic [                     2-1:0] m00_axi_awburst,
  output logic [                     1-1:0] m00_axi_awlock ,
  output logic [                     4-1:0] m00_axi_awcache,
  output logic [                     3-1:0] m00_axi_awprot ,
  output logic [                     4-1:0] m00_axi_awqos  ,
  output logic [        CACHE_AXI_ID_W-1:0] m00_axi_arid   ,
  output logic [                     3-1:0] m00_axi_arsize ,
  output logic [                     2-1:0] m00_axi_arburst,
  output logic [                     1-1:0] m00_axi_arlock ,
  output logic [                     4-1:0] m00_axi_arcache,
  output logic [                     3-1:0] m00_axi_arprot ,
  output logic [                     4-1:0] m00_axi_arqos  ,
  input  logic                              ap_start       ,
  output logic                              ap_idle        ,
  output logic                              ap_done        ,
  output logic                              ap_ready       ,
  input  logic                              ap_continue    ,
  input  logic [                    64-1:0] buffer_0       ,
  input  logic [                    64-1:0] buffer_1       ,
  input  logic [                    64-1:0] buffer_2       ,
  input  logic [                    64-1:0] buffer_3       ,
  input  logic [                    64-1:0] buffer_4       ,
  input  logic [                    64-1:0] buffer_5       ,
  input  logic [                    64-1:0] buffer_6       ,
  input  logic [                    64-1:0] buffer_7       ,
  input  logic [                    64-1:0] buffer_8       ,
  input  logic [                    64-1:0] buffer_9       
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
  (* KEEP = "yes" *)
  logic areset_m_axi   = 1'b0;
  logic areset_cu      = 1'b0;
  logic areset_control = 1'b0;
  logic areset_cache   = 1'b0;

// --------------------------------------------------------------------------------------
// AXI
// --------------------------------------------------------------------------------------
  AXI4MasterReadInterface  m_axi_read ;
  AXI4MasterWriteInterface m_axi_write;
  logic                    endian_reg ;

// --------------------------------------------------------------------------------------
// Kernel -> State Control
// --------------------------------------------------------------------------------------
  ControlChainInterfaceInput  kernel_control_in ;
  ControlChainInterfaceOutput kernel_control_out;

  KernelDescriptorPayload kernel_control_descriptor_in ;
  KernelDescriptor        kernel_control_descriptor_out;

// --------------------------------------------------------------------------------------
// Cache -> AXI
// --------------------------------------------------------------------------------------
  CacheRequest           kernel_cache_request_in              ;
  FIFOStateSignalsOutput kernel_cache_fifo_request_signals_out;
  FIFOStateSignalsInput  kernel_cache_fifo_request_signals_in ;

  CacheResponse          kernel_cache_response_out             ;
  FIFOStateSignalsOutput kernel_cache_fifo_response_signals_out;
  FIFOStateSignalsInput  kernel_cache_fifo_response_signals_in ;
  logic                  kernel_cache_fifo_setup_signal        ;

  // --------------------------------------------------------------------------------------
// CU -> PEs
// --------------------------------------------------------------------------------------
  KernelDescriptor kernel_cu_descriptor_in;

  CacheRequest           kernel_cu_request_out             ;
  FIFOStateSignalsOutput kernel_cu_fifo_request_signals_out;
  FIFOStateSignalsInput  kernel_cu_fifo_request_signals_in ;

  CacheResponse          kernel_cu_response_in              ;
  FIFOStateSignalsOutput kernel_cu_fifo_response_signals_out;
  FIFOStateSignalsInput  kernel_cu_fifo_response_signals_in ;

  logic kernel_cu_done_out         ;
  logic kernel_cu_fifo_setup_signal;

// --------------------------------------------------------------------------------------
//   Register and invert reset signal.
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    areset_m_axi   <= ~ap_rst_n;
    areset_cu      <= ~ap_rst_n | ap_done;
    areset_control <= ~ap_rst_n;
    areset_cache   <= ~ap_rst_n;
  end

// --------------------------------------------------------------------------------------
// Control chain signals
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      kernel_control_in.ap_start    <= 1'b0;
      kernel_control_in.ap_continue <= 1'b0;
      kernel_control_in.setup       <= 1'b0;
      kernel_control_in.done        <= 1'b0;
    end
    else begin
      kernel_control_in.ap_start    <= ap_start;
      kernel_control_in.ap_continue <= ap_continue;
      kernel_control_in.setup       <= ~(kernel_cache_fifo_setup_signal | kernel_cu_fifo_setup_signal);
      kernel_control_in.done        <= kernel_cu_done_out;
    end
  end

  always_ff @(posedge ap_clk) begin
    if (areset_control) begin
      ap_ready   <= 1'b0;
      ap_done    <= 1'b0;
      ap_idle    <= 1'b1;
      endian_reg <= 1'b0;
    end
    else begin
      ap_done    <= kernel_control_out.ap_done;
      ap_ready   <= kernel_control_out.ap_ready;
      ap_idle    <= kernel_control_out.ap_idle;
      endian_reg <= kernel_control_out.endian;
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
      m_axi_read.in.rvalid  <= m00_axi_rvalid ; // Read channel valid
      m_axi_read.in.arready <= m00_axi_arready; // Address read channel ready
      m_axi_read.in.rlast   <= m00_axi_rlast  ; // Read channel last word
      m_axi_read.in.rdata   <= swap_endianness_cacheline_axi(m00_axi_rdata, endian_reg)  ; // Read channel data
      m_axi_read.in.rid     <= m00_axi_rid    ; // Read channel ID
      m_axi_read.in.rresp   <= m00_axi_rresp  ; // Read channel response
    end
  end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_m_axi) begin
      m00_axi_arvalid <= 0; // Address read channel valid
      m00_axi_araddr  <= 0; // Address read channel address
      m00_axi_arlen   <= 0; // Address write channel burst length
      m00_axi_rready  <= 0; // Read channel ready
      m00_axi_arid    <= 0; // Address read channel ID
      m00_axi_arsize  <= 0; // Address read channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_arburst <= M_AXI4_BURST_INCR; // Address read channel burst type
      m00_axi_arlock  <= 0; // Address read channel lock type
      m00_axi_arcache <= M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_arprot  <= 0; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_arqos   <= 0; // Address write channel quality of service
    end
    else begin
      m00_axi_arvalid <= m_axi_read.out.arvalid; // Address read channel valid
      m00_axi_araddr  <= m_axi_read.out.araddr ; // Address read channel address
      m00_axi_arlen   <= m_axi_read.out.arlen  ; // Address write channel burst length
      m00_axi_rready  <= m_axi_read.out.rready ; // Read channel ready
      m00_axi_arid    <= m_axi_read.out.arid   ; // Address read channel ID
      m00_axi_arsize  <= m_axi_read.out.arsize ; // Address read channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_arburst <= m_axi_read.out.arburst; // Address read channel burst type
      m00_axi_arlock  <= m_axi_read.out.arlock ; // Address read channel lock type
      m00_axi_arcache <= m_axi_read.out.arcache; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_arprot  <= m_axi_read.out.arprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_arqos   <= m_axi_read.out.arqos  ; // Address write channel quality of service
    end
  end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_m_axi) begin
      m_axi_write.in <= 0;
    end
    else begin
      m_axi_write.in.awready <= m00_axi_awready; // Address write channel ready
      m_axi_write.in.wready  <= m00_axi_wready ; // Write channel ready
      m_axi_write.in.bid     <= m00_axi_bid    ; // Write response channel ID
      m_axi_write.in.bresp   <= m00_axi_bresp  ; // Write channel response
      m_axi_write.in.bvalid  <= m00_axi_bvalid ; // Write response channel valid
    end
  end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if (areset_m_axi) begin
      m00_axi_awvalid <= 0;// Address write channel valid
      m00_axi_awid    <= 0;// Address write channel ID
      m00_axi_awaddr  <= 0;// Address write channel address
      m00_axi_awlen   <= 0;// Address write channel burst length
      m00_axi_awsize  <= 0;// Address write channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_awburst <= M_AXI4_BURST_INCR;// Address write channel burst type
      m00_axi_awlock  <= 0;// Address write channel lock type
      m00_axi_awcache <= M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE;// Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_awprot  <= 0;// Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_awqos   <= 0;// Address write channel quality of service
      m00_axi_wdata   <= 0;// Write channel data
      m00_axi_wstrb   <= 0;// Write channel write strobe
      m00_axi_wlast   <= 0;// Write channel last word flag
      m00_axi_wvalid  <= 0;// Write channel valid
      m00_axi_bready  <= 0;// Write response channel ready
    end
    else begin
      m00_axi_awvalid <= m_axi_write.out.awvalid; // Address write channel valid
      m00_axi_awid    <= m_axi_write.out.awid   ; // Address write channel ID
      m00_axi_awaddr  <= m_axi_write.out.awaddr ; // Address write channel address
      m00_axi_awlen   <= m_axi_write.out.awlen  ; // Address write channel burst length
      m00_axi_awsize  <= m_axi_write.out.awsize ; // Address write channel burst size. This signal indicates the size of each transfer in the burst
      m00_axi_awburst <= m_axi_write.out.awburst; // Address write channel burst type
      m00_axi_awlock  <= m_axi_write.out.awlock ; // Address write channel lock type
      m00_axi_awcache <= m_axi_write.out.awcache; // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
      m00_axi_awprot  <= m_axi_write.out.awprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
      m00_axi_awqos   <= m_axi_write.out.awqos  ; // Address write channel quality of service
      m00_axi_wdata   <= swap_endianness_cacheline_axi(m_axi_write.out.wdata, endian_reg)  ; // Write channel data
      m00_axi_wstrb   <= m_axi_write.out.wstrb  ; // Write channel write strobe
      m00_axi_wlast   <= m_axi_write.out.wlast  ; // Write channel last word flag
      m00_axi_wvalid  <= m_axi_write.out.wvalid ; // Write channel valid
      m00_axi_bready  <= m_axi_write.out.bready ; // Write response channel ready
    end
  end

// --------------------------------------------------------------------------------------
// DRIVE DESCRIPTOR
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    kernel_control_descriptor_in.buffer_0 <= buffer_0  ;
    kernel_control_descriptor_in.buffer_1 <= buffer_1  ;
    kernel_control_descriptor_in.buffer_2 <= buffer_2  ;
    kernel_control_descriptor_in.buffer_3 <= buffer_3  ;
    kernel_control_descriptor_in.buffer_4 <= buffer_4  ;
    kernel_control_descriptor_in.buffer_5 <= buffer_5  ;
    kernel_control_descriptor_in.buffer_6 <= buffer_6  ;
    kernel_control_descriptor_in.buffer_7 <= buffer_7  ;
    kernel_control_descriptor_in.buffer_8 <= buffer_8  ;
    kernel_control_descriptor_in.buffer_9 <= buffer_9  ;
  end

// --------------------------------------------------------------------------------------
// Assign Kernel Cache <-> CU Signals
// --------------------------------------------------------------------------------------
  // kernel_cache
  assign kernel_cache_request_in                     = kernel_cu_request_out;
  assign kernel_cache_fifo_request_signals_in.wr_en  = 0;
  assign kernel_cache_fifo_request_signals_in.rd_en  = ~(kernel_cu_fifo_response_signals_out.prog_full);
  assign kernel_cache_fifo_response_signals_in.wr_en = 0;
  assign kernel_cache_fifo_response_signals_in.rd_en = ~(kernel_cu_fifo_response_signals_out.prog_full);

  // kernel_cu
  assign kernel_cu_response_in                    = kernel_cache_response_out;
  assign kernel_cu_fifo_request_signals_in.wr_en  = 0;
  assign kernel_cu_fifo_request_signals_in.rd_en  = ~(kernel_cache_fifo_request_signals_out.prog_full | kernel_cache_fifo_response_signals_out.prog_full);
  assign kernel_cu_fifo_response_signals_in.wr_en = 0;
  assign kernel_cu_fifo_response_signals_in.rd_en = 0;

  // Kernel_setup
  assign kernel_cu_descriptor_in = kernel_control_descriptor_out;

// --------------------------------------------------------------------------------------
// Cache -> AXI
// --------------------------------------------------------------------------------------
  kernel_cache inst_kernel_cache (
    .ap_clk                   (ap_clk                                ),
    .areset                   (areset_cache                          ),
    .request_in               (kernel_cache_request_in               ),
    .fifo_request_signals_out (kernel_cache_fifo_request_signals_out ),
    .fifo_request_signals_in  (kernel_cache_fifo_request_signals_in  ),
    .response_out             (kernel_cache_response_out             ),
    .fifo_response_signals_out(kernel_cache_fifo_response_signals_out),
    .fifo_response_signals_in (kernel_cache_fifo_response_signals_in ),
    .fifo_setup_signal        (kernel_cache_fifo_setup_signal        ),
    .m_axi_read_in            (m_axi_read.in                         ),
    .m_axi_read_out           (m_axi_read.out                        ),
    .m_axi_write_in           (m_axi_write.in                        ),
    .m_axi_write_out          (m_axi_write.out                       )
  );

// --------------------------------------------------------------------------------------
// CU -> Caches/PEs
// --------------------------------------------------------------------------------------
  kernel_cu #(.NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS)) inst_kernel_cu (
    .ap_clk                   (ap_clk                             ),
    .areset                   (areset_cu                          ),
    .descriptor_in            (kernel_cu_descriptor_in            ),
    .request_out              (kernel_cu_request_out              ),
    .fifo_request_signals_out (kernel_cu_fifo_request_signals_out ),
    .fifo_request_signals_in  (kernel_cu_fifo_request_signals_in  ),
    .response_in              (kernel_cu_response_in              ),
    .fifo_response_signals_out(kernel_cu_fifo_response_signals_out),
    .fifo_response_signals_in (kernel_cu_fifo_response_signals_in ),
    .fifo_setup_signal        (kernel_cu_fifo_setup_signal        ),
    .done_out                 (kernel_cu_done_out                 )
  );

// --------------------------------------------------------------------------------------
// Kernel -> State Control
// --------------------------------------------------------------------------------------
  kernel_control inst_kernel_control (
    .ap_clk        (ap_clk                       ),
    .areset        (areset_control               ),
    .control_in    (kernel_control_in            ),
    .control_out   (kernel_control_out           ),
    .descriptor_in (kernel_control_descriptor_in ),
    .descriptor_out(kernel_control_descriptor_out)
  );

endmodule : kernel_afu

