// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

`include "global_package.vh"

module engine_m_axi #(
  parameter integer C_M_AXI_ADDR_WIDTH = M_AXI_MEMORY_ADDR_WIDTH     ,
  parameter integer C_M_AXI_DATA_WIDTH = M_AXI_MEMORY_DATA_WIDTH_BITS,
  parameter integer C_XFER_SIZE_WIDTH  = GLOBAL_DATA_WIDTH_BITS      ,
  parameter integer C_ADDER_BIT_WIDTH  = GLOBAL_DATA_WIDTH_BITS
) (
  // System Signals
  input  logic                            aclk                   ,
  input  logic                            areset                 ,
  // Extra clocks
  input  logic                            kernel_clk             ,
  input  logic                            kernel_rst             ,
  // AXI4 master interface
  output logic                            m_axi_awvalid          ,
  input  logic                            m_axi_awready          ,
  output logic [  C_M_AXI_ADDR_WIDTH-1:0] m_axi_awaddr           ,
  output logic [                   8-1:0] m_axi_awlen            ,
  output logic                            m_axi_wvalid           ,
  input  logic                            m_axi_wready           ,
  output logic [  C_M_AXI_DATA_WIDTH-1:0] m_axi_wdata            ,
  output logic [C_M_AXI_DATA_WIDTH/8-1:0] m_axi_wstrb            ,
  output logic                            m_axi_wlast            ,
  output logic                            m_axi_arvalid          ,
  input  logic                            m_axi_arready          ,
  output logic [  C_M_AXI_ADDR_WIDTH-1:0] m_axi_araddr           ,
  output logic [                   8-1:0] m_axi_arlen            ,
  input  logic                            m_axi_rvalid           ,
  output logic                            m_axi_rready           ,
  input  logic [  C_M_AXI_DATA_WIDTH-1:0] m_axi_rdata            ,
  input  logic                            m_axi_rlast            ,
  input  logic                            m_axi_bvalid           ,
  output logic                            m_axi_bready           ,
  input  logic                            ap_start               ,
  output logic                            ap_done                ,
  input  logic [  C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset       ,
  input  logic [   C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes,
  input  logic [   C_ADDER_BIT_WIDTH-1:0] ctrl_constant
);

  timeunit 1ps;
  timeprecision 1ps;


///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
  localparam integer LP_DW_BYTES           = C_M_AXI_DATA_WIDTH/8                           ;
  localparam integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
  localparam integer LP_LOG_BURST_LEN      = $clog2(LP_AXI_BURST_LEN)                       ;
  localparam integer LP_BRAM_DEPTH         = 512                                            ;
  localparam integer LP_RD_MAX_OUTSTANDING = LP_BRAM_DEPTH / LP_AXI_BURST_LEN               ;
  localparam integer LP_WR_MAX_OUTSTANDING = 32                                             ;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////

// Control logic
  logic done = 1'b0;
// AXI read master stage
  logic                          read_done;
  logic                          rd_tvalid;
  logic                          rd_tready;
  logic                          rd_tlast ;
  logic [C_M_AXI_DATA_WIDTH-1:0] rd_tdata ;
// Adder stage
  logic                          adder_tvalid;
  logic                          adder_tready;
  logic [C_M_AXI_DATA_WIDTH-1:0] adder_tdata ;

// AXI write master stage
  logic write_done;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// AXI4 Read Master, output format is an AXI4-Stream master, one stream per thread.
  engine_m_axi_read #(
    .C_M_AXI_ADDR_WIDTH (C_M_AXI_ADDR_WIDTH   ),
    .C_M_AXI_DATA_WIDTH (C_M_AXI_DATA_WIDTH   ),
    .C_XFER_SIZE_WIDTH  (C_XFER_SIZE_WIDTH    ),
    .C_MAX_OUTSTANDING  (LP_RD_MAX_OUTSTANDING),
    .C_INCLUDE_DATA_FIFO(1                    )
  ) inst_axi_read_master (
    .aclk                   (aclk                   ),
    .areset                 (areset                 ),
    .ctrl_start             (ap_start               ),
    .ctrl_done              (read_done              ),
    .ctrl_addr_offset       (ctrl_addr_offset       ),
    .ctrl_xfer_size_in_bytes(ctrl_xfer_size_in_bytes),
    .m_axi_arvalid          (m_axi_arvalid          ),
    .m_axi_arready          (m_axi_arready          ),
    .m_axi_araddr           (m_axi_araddr           ),
    .m_axi_arlen            (m_axi_arlen            ),
    .m_axi_rvalid           (m_axi_rvalid           ),
    .m_axi_rready           (m_axi_rready           ),
    .m_axi_rdata            (m_axi_rdata            ),
    .m_axi_rlast            (m_axi_rlast            ),
    .m_axis_aclk            (kernel_clk             ),
    .m_axis_areset          (kernel_rst             ),
    .m_axis_tvalid          (rd_tvalid              ),
    .m_axis_tready          (rd_tready              ),
    .m_axis_tlast           (rd_tlast               ),
    .m_axis_tdata           (rd_tdata               )
  );

  engine_m_axi_kernel #(
    .C_AXIS_TDATA_WIDTH(C_M_AXI_DATA_WIDTH),
    .C_ADDER_BIT_WIDTH (C_ADDER_BIT_WIDTH ),
    .C_NUM_CLOCKS      (1                 )
  ) inst_adder (
    .s_axis_aclk  (kernel_clk                  ),
    .s_axis_areset(kernel_rst                  ),
    .ctrl_constant(ctrl_constant               ),
    .s_axis_tvalid(rd_tvalid                   ),
    .s_axis_tready(rd_tready                   ),
    .s_axis_tdata (rd_tdata                    ),
    .s_axis_tkeep ({C_M_AXI_DATA_WIDTH/8{1'b1}}),
    .s_axis_tlast (rd_tlast                    ),
    .m_axis_aclk  (kernel_clk                  ),
    .m_axis_tvalid(adder_tvalid                ),
    .m_axis_tready(adder_tready                ),
    .m_axis_tdata (adder_tdata                 ),
    .m_axis_tkeep (                            ), // Not used
    .m_axis_tlast (                            )  // Not used
  );

// AXI4 Write Master
  engine_m_axi_write #(
    .C_M_AXI_ADDR_WIDTH (C_M_AXI_ADDR_WIDTH   ),
    .C_M_AXI_DATA_WIDTH (C_M_AXI_DATA_WIDTH   ),
    .C_XFER_SIZE_WIDTH  (C_XFER_SIZE_WIDTH    ),
    .C_MAX_OUTSTANDING  (LP_WR_MAX_OUTSTANDING),
    .C_INCLUDE_DATA_FIFO(1                    )
  ) inst_axi_write_master (
    .aclk                   (aclk                   ),
    .areset                 (areset                 ),
    .ctrl_start             (ap_start               ),
    .ctrl_done              (write_done             ),
    .ctrl_addr_offset       (ctrl_addr_offset       ),
    .ctrl_xfer_size_in_bytes(ctrl_xfer_size_in_bytes),
    .m_axi_awvalid          (m_axi_awvalid          ),
    .m_axi_awready          (m_axi_awready          ),
    .m_axi_awaddr           (m_axi_awaddr           ),
    .m_axi_awlen            (m_axi_awlen            ),
    .m_axi_wvalid           (m_axi_wvalid           ),
    .m_axi_wready           (m_axi_wready           ),
    .m_axi_wdata            (m_axi_wdata            ),
    .m_axi_wstrb            (m_axi_wstrb            ),
    .m_axi_wlast            (m_axi_wlast            ),
    .m_axi_bvalid           (m_axi_bvalid           ),
    .m_axi_bready           (m_axi_bready           ),
    .s_axis_aclk            (kernel_clk             ),
    .s_axis_areset          (kernel_rst             ),
    .s_axis_tvalid          (adder_tvalid           ),
    .s_axis_tready          (adder_tready           ),
    .s_axis_tdata           (adder_tdata            )
  );

  assign ap_done = write_done;

endmodule : engine_m_axi

