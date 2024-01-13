
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m01_axi_lite_register_slice_mid_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"



module m00_axi_lite_register_slice_mid_64x17_wrapper (
  // System Signals
  input  logic                   ap_clk,
  input  logic                   areset,
  input  M00_AXI4_LITE_MID_RESP_T m_axi_lite_in,
  output M00_AXI4_LITE_MID_REQ_T  m_axi_lite_out,
  input  S00_AXI4_LITE_MID_REQ_T  s_axi_lite_in,
  output S00_AXI4_LITE_MID_RESP_T s_axi_lite_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_register_slice;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_register_slice <= ~areset;
end

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
m00_axi_lite_register_slice_mid_64x17 inst_m00_axi_lite_register_slice_mid_64x17 (
  .aclk         (ap_clk                 ),
  .aresetn      (aresetn                ),
  .s_axi_araddr (s_axi_lite_in.ar.addr  ), // : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  .s_axi_arprot (s_axi_lite_in.ar.prot  ), // : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  .s_axi_arready(s_axi_lite_out.ar_ready), // : OUT STD_LOGIC;
  .s_axi_arvalid(s_axi_lite_in.ar_valid ), // : IN STD_LOGIC;
  .s_axi_awaddr (s_axi_lite_in.aw.addr  ), // : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  .s_axi_awprot (s_axi_lite_in.aw.prot  ), // : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  .s_axi_awready(s_axi_lite_out.aw_ready),
  .s_axi_awvalid(s_axi_lite_in.aw_valid ), // : IN STD_LOGIC;
  .s_axi_bready (s_axi_lite_in.b_ready  ), // : IN STD_LOGIC;
  .s_axi_bresp  (s_axi_lite_out.b.resp  ), // : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  .s_axi_bvalid (s_axi_lite_out.b_valid ), // : OUT STD_LOGIC;
  .s_axi_rdata  (s_axi_lite_out.r.data  ), // : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  .s_axi_rready (s_axi_lite_in.r_ready  ), // : IN STD_LOGIC;
  .s_axi_rresp  (s_axi_lite_out.r.resp  ), // : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  .s_axi_rvalid (s_axi_lite_out.r_valid ), // : OUT STD_LOGIC;
  .s_axi_wdata  (s_axi_lite_in.w.data   ), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  .s_axi_wready (s_axi_lite_out.w_ready ),
  .s_axi_wstrb  (s_axi_lite_in.w.strb   ),
  .s_axi_wvalid (s_axi_lite_in.w_valid  ), // : IN STD_LOGIC;
  
  .m_axi_araddr (m_axi_lite_out.ar.addr ), // : out STD_LOGIC_VECTOR(16 DOWNTO 0);
  .m_axi_arprot (m_axi_lite_out.ar.prot ), // : out STD_LOGIC_VECTOR(2 DOWNTO 0);
  .m_axi_arready(m_axi_lite_in.ar_ready ), // : in STD_LOGIC;
  .m_axi_arvalid(m_axi_lite_out.ar_valid), // : out STD_LOGIC;
  .m_axi_awaddr (m_axi_lite_out.aw.addr ), // : out STD_LOGIC_VECTOR(16 DOWNTO 0);
  .m_axi_awprot (m_axi_lite_out.aw.prot ), // : out STD_LOGIC_VECTOR(2 DOWNTO 0);
  .m_axi_awready(m_axi_lite_in.aw_ready ),
  .m_axi_awvalid(m_axi_lite_out.aw_valid), // : out STD_LOGIC;
  .m_axi_bready (m_axi_lite_out.b_ready ), // : out STD_LOGIC;
  .m_axi_bresp  (m_axi_lite_in.b.resp   ), // : in STD_LOGIC_VECTOR(1 DOWNTO 0);
  .m_axi_bvalid (m_axi_lite_in.b_valid  ), // : in STD_LOGIC;
  .m_axi_rdata  (m_axi_lite_in.r.data   ), // : in STD_LOGIC_VECTOR(63 DOWNTO 0);
  .m_axi_rready (m_axi_lite_out.r_ready ), // : out STD_LOGIC;
  .m_axi_rresp  (m_axi_lite_in.r.resp   ), // : in STD_LOGIC_VECTOR(1 DOWNTO 0);
  .m_axi_rvalid (m_axi_lite_in.r_valid  ), // : in STD_LOGIC;
  .m_axi_wdata  (m_axi_lite_out.w.data  ), // : out STD_LOGIC_VECTOR(63 DOWNTO 0);
  .m_axi_wready (m_axi_lite_in.w_ready  ),
  .m_axi_wstrb  (m_axi_lite_out.w.strb  ),
  .m_axi_wvalid (m_axi_lite_out.w_valid )  // : out STD_LOGIC;
);

endmodule : m00_axi_lite_register_slice_mid_64x17_wrapper

  