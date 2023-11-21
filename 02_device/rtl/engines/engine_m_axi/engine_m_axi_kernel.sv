// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// Description: Pipelined adder.  This is an adder with pipelines before and
//   after the adder datapath.  The output is fed into a FIFO and prog_full is
//   used to signal ready.  This design allows for high Fmax.

`include "global_package.vh"

module engine_m_axi_kernel #(
  parameter integer C_AXIS_TDATA_WIDTH = GLOBAL_DATA_WIDTH_BITS, // Data width of both input and output data
  parameter integer C_ADDER_BIT_WIDTH  = GLOBAL_ADDR_WIDTH_BITS,
  parameter integer C_NUM_CLOCKS       = 1                     ,
  parameter integer C_AXIS_TID_WIDTH   = M_AXI4_ID_W           ,
  parameter integer C_AXIS_TDEST_WIDTH = 1                     ,
  parameter integer C_AXIS_TUSER_WIDTH = M_AXI4_USER_W
) (
  input  logic [   C_ADDER_BIT_WIDTH-1:0] ctrl_constant,
  input  logic                            s_axis_aclk  ,
  input  logic                            s_axis_areset,
  input  logic                            s_axis_tvalid,
  output logic                            s_axis_tready,
  input  logic [  C_AXIS_TDATA_WIDTH-1:0] s_axis_tdata ,
  input  logic [C_AXIS_TDATA_WIDTH/8-1:0] s_axis_tkeep ,
  input  logic [C_AXIS_TDATA_WIDTH/8-1:0] s_axis_tstrb ,
  input  logic                            s_axis_tlast ,
  input  logic [    C_AXIS_TID_WIDTH-1:0] s_axis_tid   ,
  input  logic [  C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest ,
  input  logic [  C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser ,
  input  logic                            m_axis_aclk  ,
  output logic                            m_axis_tvalid,
  input  logic                            m_axis_tready,
  output logic [  C_AXIS_TDATA_WIDTH-1:0] m_axis_tdata ,
  output logic [C_AXIS_TDATA_WIDTH/8-1:0] m_axis_tkeep ,
  output logic [C_AXIS_TDATA_WIDTH/8-1:0] m_axis_tstrb ,
  output logic                            m_axis_tlast ,
  output logic [    C_AXIS_TID_WIDTH-1:0] m_axis_tid   ,
  output logic [  C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest ,
  output logic [  C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser
);

  localparam integer LP_NUM_LOOPS = C_AXIS_TDATA_WIDTH/C_ADDER_BIT_WIDTH;
  localparam         LP_CLOCKING_MODE = C_NUM_CLOCKS == 1 ? "common_clock" : "independent_clock";
/////////////////////////////////////////////////////////////////////////////
// Variables
/////////////////////////////////////////////////////////////////////////////
  logic                              d1_tvalid   = 1'b0                        ;
  logic                              d1_tready   = 1'b0                        ;
  logic   [  C_AXIS_TDATA_WIDTH-1:0] d1_tdata                                  ;
  logic   [C_AXIS_TDATA_WIDTH/8-1:0] d1_tkeep                                  ;
  logic                              d1_tlast                                  ;
  logic   [   C_ADDER_BIT_WIDTH-1:0] d1_constant                               ;
  logic   [C_AXIS_TDATA_WIDTH/8-1:0] d1_tstrb    = {C_AXIS_TDATA_WIDTH/8{1'b1}};
  logic   [    C_AXIS_TID_WIDTH-1:0] d1_tid      = {C_AXIS_TID_WIDTH{1'b0}}    ;
  logic   [  C_AXIS_TDEST_WIDTH-1:0] d1_tdest    = {C_AXIS_TDEST_WIDTH{1'b0}}  ;
  logic   [  C_AXIS_TUSER_WIDTH-1:0] d1_tuser    = {C_AXIS_TUSER_WIDTH{1'b0}}  ;
  integer                            i                                         ;

  logic                            d2_tvalid = 1'b0;
  logic [  C_AXIS_TDATA_WIDTH-1:0] d2_tdata        ;
  logic [C_AXIS_TDATA_WIDTH/8-1:0] d2_tkeep        ;
  logic                            d2_tlast        ;


  logic [C_AXIS_TDATA_WIDTH/8-1:0] d2_tstrb;
  logic [    C_AXIS_TID_WIDTH-1:0] d2_tid  ;
  logic [  C_AXIS_TDEST_WIDTH-1:0] d2_tdest;
  logic [  C_AXIS_TUSER_WIDTH-1:0] d2_tuser;

  logic prog_full_axis       ;
  logic fifo_ready_r   = 1'b0;
/////////////////////////////////////////////////////////////////////////////
// RTL Logic
/////////////////////////////////////////////////////////////////////////////

// Register s_axis_interface/inputs
  always @(posedge s_axis_aclk) begin
    d1_tvalid   <= s_axis_tvalid;
    d1_tready   <= s_axis_tready;
    d1_tdata    <= s_axis_tdata;
    d1_tkeep    <= s_axis_tkeep;
    d1_tlast    <= s_axis_tlast;
    d1_tid      <= s_axis_tid;
    d1_tdest    <= s_axis_tdest;
    d1_tstrb    <= s_axis_tstrb;
    d1_tuser    <= s_axis_tuser;
    d1_constant <= ctrl_constant;
  end

// Adder function
  always @(posedge s_axis_aclk) begin
    for (i = 0; i < LP_NUM_LOOPS; i = i + 1) begin
      d2_tdata[i*C_ADDER_BIT_WIDTH+:C_ADDER_BIT_WIDTH] <= d1_tdata[C_ADDER_BIT_WIDTH*i+:C_ADDER_BIT_WIDTH] + d1_constant;
    end
  end

// Register inputs to fifo
  always @(posedge s_axis_aclk) begin
    d2_tvalid <= d1_tvalid & d1_tready;
    d2_tkeep  <= d1_tkeep;
    d2_tlast  <= d1_tlast;
    d2_tid    <= d1_tid;
    d2_tstrb  <= d1_tstrb;
    d2_tuser  <= d1_tuser;
    d2_tdest  <= d1_tdest;
  end

// Tie-off unused inputs to FIFO.

  always @(posedge s_axis_aclk) begin
    fifo_ready_r <= ~prog_full_axis;
  end

  assign s_axis_tready = fifo_ready_r;

  xpm_fifo_axis #(
    .CDC_SYNC_STAGES    (2                 ), // DECIMAL
    .CLOCKING_MODE      (LP_CLOCKING_MODE  ), // String
    .ECC_MODE           ("no_ecc"          ), // String
    .FIFO_DEPTH         (32                ), // DECIMAL
    .FIFO_MEMORY_TYPE   ("distributed"     ), // String
    .PACKET_FIFO        ("false"           ), // String
    .PROG_EMPTY_THRESH  (5                 ), // DECIMAL
    .PROG_FULL_THRESH   (32-5              ), // DECIMAL
    .RD_DATA_COUNT_WIDTH(6                 ), // DECIMAL
    .RELATED_CLOCKS     (0                 ), // DECIMAL
    .TDATA_WIDTH        (C_AXIS_TDATA_WIDTH), // DECIMAL
    .TDEST_WIDTH        (C_AXIS_TDEST_WIDTH), // DECIMAL
    .TID_WIDTH          (C_AXIS_TID_WIDTH  ), // DECIMAL
    .TUSER_WIDTH        (C_AXIS_TUSER_WIDTH), // DECIMAL
    .USE_ADV_FEATURES   ("1002"            ), // String: Only use prog_full
    .WR_DATA_COUNT_WIDTH(6                 )  // DECIMAL
  ) inst_xpm_fifo_axis (
    .s_aclk            (s_axis_aclk   ),
    .s_aresetn         (~s_axis_areset),
    .s_axis_tvalid     (d2_tvalid     ),
    .s_axis_tready     (              ),
    .s_axis_tdata      (d2_tdata      ),
    .s_axis_tstrb      (d2_tstrb      ),
    .s_axis_tkeep      (d2_tkeep      ),
    .s_axis_tlast      (d2_tlast      ),
    .s_axis_tid        (d2_tid        ),
    .s_axis_tdest      (d2_tdest      ),
    .s_axis_tuser      (d2_tuser      ),
    .almost_full_axis  (              ),
    .prog_full_axis    (prog_full_axis),
    .wr_data_count_axis(              ),
    .injectdbiterr_axis(1'b0          ),
    .injectsbiterr_axis(1'b0          ),
    
    .m_aclk            (m_axis_aclk   ),
    .m_axis_tvalid     (m_axis_tvalid ),
    .m_axis_tready     (m_axis_tready ),
    .m_axis_tdata      (m_axis_tdata  ),
    .m_axis_tstrb      (m_axis_tstrb  ),
    .m_axis_tkeep      (m_axis_tkeep  ),
    .m_axis_tlast      (m_axis_tlast  ),
    .m_axis_tid        (m_axis_tid    ),
    .m_axis_tdest      (m_axis_tdest  ),
    .m_axis_tuser      (m_axis_tuser  ),
    .almost_empty_axis (              ),
    .prog_empty_axis   (              ),
    .rd_data_count_axis(              ),
    .sbiterr_axis      (              ),
    .dbiterr_axis      (              )
  );

endmodule


