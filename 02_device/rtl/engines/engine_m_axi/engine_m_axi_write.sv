// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

// Description: This is an AXI4 write master module example. The module
// demonstrates how to issue AXI write transactions to a memory mapped slave.
// Given a starting address offset and a transfer size in bytes, it will issue
// one or more AXI transactions by generating incrementing AXI write transfers
// when data is transfered over the AXI4-Stream interface.

// Theory of operation:
// It uses a minimum subset of the AXI4 protocol by omitting AXI4 signals that
// are not used.  When packaged as a kernel or IP, this allows for optimizations
// to occur within the AXI Interconnect system to increase Fmax, potentially
// increase performance, and reduce latency/area. When C_INCLUDE_DATA_FIFO is
// set to 1, a depth 32 FIFO is provided for extra buffering.
//
// When ctrl_start is asserted, the ctrl_addr_offset (assumed 4kb aligned) and
// the transfer size in bytes is registered into the module.  the The bulk of the
// logic consists of counters to track how many transfers/transactions have been
// issued.  When the transfer size is reached, and all transactions are
// committed, then done is asserted.
//
// Usage:
// 1) assign ctrl_addr_offset to a 4kB aligned starting address.
// 2) assign ctrl_xfer_size_in_bytes to the size in bytes of the requested transfer.
// 3) Assert ctrl_start for once cycle.  At the posedge, the ctrl_addr_offset and
// ctrl_xfer_size_in_bytes will be registered in the module, and will start
// to issue write address transfers when the first data arrives on the s_axis
// interface.  If the the transfer size is larger than 4096
// bytes, multiple transactions will be issued.
// 4) As write data is presented on the axi4-stream interface, WLAST and
// additional write address transfers will be issued as necessary.
// 5) When the final B-channel transaction has been received, the module will assert
//    the ctrl_done signal for one cycle.  If a data FIFO is present, data may
//    still be present in the FIFO.  It will
// 6) Jump to step 1.
////////////////////////////////////////////////////////////////////////////////

`include "global_package.vh"

module engine_m_axi_write #(
  parameter integer C_ADDR_WIDTH        = 64 ,
  parameter integer C_DATA_WIDTH        = 32 ,
  parameter integer C_MAX_LENGTH_WIDTH  = 32 ,
  parameter integer C_BURST_LEN         = 256,
  parameter integer C_LOG_BURST_LEN     = 8  ,
  parameter integer C_INCLUDE_DATA_FIFO = 1
) (
  // AXI Interface
  input  logic                          ap_clk       ,
  input  logic                          areset     ,
  // Control interface
  input  logic                          ctrl_start ,
  input  logic [      C_ADDR_WIDTH-1:0] ctrl_offset,
  input  logic [C_MAX_LENGTH_WIDTH-1:0] ctrl_length,
  output logic                          ctrl_done  ,
  // AXI4-Stream interface
  input  logic                          s_tvalid   ,
  input  logic [      C_DATA_WIDTH-1:0] s_tdata    ,
  output logic                          s_tready   ,

  output logic [      C_ADDR_WIDTH-1:0] awaddr     ,
  output logic [                   7:0] awlen      ,
  output logic [                   2:0] awsize     ,
  output logic                          awvalid    ,
  input  logic                          awready    ,
  output logic [      C_DATA_WIDTH-1:0] wdata      ,
  output logic [    C_DATA_WIDTH/8-1:0] wstrb      ,
  output logic                          wlast      ,
  output logic                          wvalid     ,
  input  logic                          wready     ,
  input  logic [                   1:0] bresp      ,
  input  logic                          bvalid     ,
  output logic                          bready
);

timeunit 1ps;
timeprecision 1ps;

/////////////////////////////////////////////////////////////////////////////
// Local Parameters
/////////////////////////////////////////////////////////////////////////////
localparam integer LP_LOG_MAX_W_TO_AW        = 8                                 ; // Allow up to 256 outstanding w to aw transactions
localparam integer LP_TRANSACTION_CNTR_WIDTH = C_MAX_LENGTH_WIDTH-C_LOG_BURST_LEN;
localparam integer LP_FIFO_DEPTH             = C_BURST_LEN                       ;
localparam integer LP_FIFO_READ_LATENCY      = 1                                 ; // 2: Registered output on BRAM, 1: Registered output on LUTRAM
localparam integer LP_FIFO_COUNT_WIDTH       = $clog2(LP_FIFO_DEPTH)             ;

/////////////////////////////////////////////////////////////////////////////
// Variables
/////////////////////////////////////////////////////////////////////////////
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_full_bursts          ;
logic                                 num_partial_bursts       ;
logic                                 start              = 1'b0;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_transactions         ;
logic                                 has_partial_burst        ;
logic [          C_LOG_BURST_LEN-1:0] final_burst_len          ;
logic                                 single_transaction       ;

logic                                 wxfer                            ; // Unregistered write data transfer
logic                                 wfirst                     = 1'b1;
logic                                 load_burst_cntr                  ;
logic [          C_LOG_BURST_LEN-1:0] wxfers_to_go                     ; // Used for simulation debug
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] w_transactions_to_go             ;
logic                                 w_final_transaction              ;
logic                                 w_almost_final_transaction = 1'b0;

logic                                 awxfer                        ;
logic                                 awvalid_r               = 1'b0;
logic [             C_ADDR_WIDTH-1:0] addr                          ;
logic                                 wfirst_d1               = 1'b0;
logic                                 wfirst_pulse            = 1'b0;
logic [       LP_LOG_MAX_W_TO_AW-1:0] dbg_w_to_aw_outstanding       ;
logic                                 idle_aw                       ;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] aw_transactions_to_go         ;
logic                                 aw_final_transaction          ;

logic                                 bxfer               ;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] b_transactions_to_go;
logic                                 b_final_transaction ;

logic s_tready_n;
logic wr_rst_busy;
logic rd_rst_busy;
/////////////////////////////////////////////////////////////////////////////
// Control logic
/////////////////////////////////////////////////////////////////////////////
// Count the number of transfers and assert done when the last bvalid is received.
assign num_full_bursts    = ctrl_length[C_LOG_BURST_LEN+:C_MAX_LENGTH_WIDTH-C_LOG_BURST_LEN];
assign num_partial_bursts = ctrl_length[0+:C_LOG_BURST_LEN] ? 1'b1 : 1'b0;

always @(posedge ap_clk) begin
  start             <= ctrl_start;
  num_transactions  <= (num_partial_bursts == 1'b0) ? num_full_bursts - 1'b1 : num_full_bursts;
  has_partial_burst <= num_partial_bursts;
  final_burst_len   <= ctrl_length[0+:C_LOG_BURST_LEN] - 1'b1;
end

assign ctrl_done          = bxfer & b_final_transaction;
assign single_transaction = (num_transactions == {LP_TRANSACTION_CNTR_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

/////////////////////////////////////////////////////////////////////////////
// AXI Write Data Channel
/////////////////////////////////////////////////////////////////////////////
generate
  if (C_INCLUDE_DATA_FIFO == 1) begin : gen_fifo

    // xpm_fifo_sync: Synchronous FIFO
    // Xilinx Parameterized Macro, Version 2017.4
    xpm_fifo_sync #(
      .FIFO_MEMORY_TYPE   ("auto"              ), // string; "auto", "block", "distributed", or "ultra";
      .ECC_MODE           ("no_ecc"            ), // string; "no_ecc" or "en_ecc";
      .FIFO_WRITE_DEPTH   (LP_FIFO_DEPTH       ), // positive integer
      .WRITE_DATA_WIDTH   (C_DATA_WIDTH        ), // positive integer
      .WR_DATA_COUNT_WIDTH(LP_FIFO_COUNT_WIDTH ), // positive integer, not used
      .PROG_FULL_THRESH   (10                  ), // positive integer, not used
      .FULL_RESET_VALUE   (1                   ), // positive integer; 0 or 1
      .USE_ADV_FEATURES   ("1F1F"              ), // string; "0000" to "1F1F";
      .READ_MODE          ("fwft"              ), // string; "std" or "fwft";
      .FIFO_READ_LATENCY  (LP_FIFO_READ_LATENCY), // positive integer;
      .READ_DATA_WIDTH    (C_DATA_WIDTH        ), // positive integer
      .RD_DATA_COUNT_WIDTH(LP_FIFO_COUNT_WIDTH ), // positive integer, not used
      .PROG_EMPTY_THRESH  (10                  ), // positive integer, not used
      .DOUT_RESET_VALUE   ("0"                 ), // string, don't care
      .WAKEUP_TIME        (0                   )  // positive integer; 0 or 2;
    ) inst_xpm_fifo_sync (
      .sleep        (1'b0       ),
      .rst          (areset     ),
      .wr_clk       (ap_clk     ),
      .wr_en        (s_tvalid   ),
      .din          (s_tdata    ),
      .full         (           ),
      .overflow     (           ),
      .prog_full    (s_tready_n ),
      .wr_data_count(           ),
      .almost_full  (           ),
      .wr_ack       (           ),
      .wr_rst_busy  (wr_rst_busy),
      .rd_en        (wready     ),
      .dout         (wdata      ),
      .empty        (           ),
      .prog_empty   (           ),
      .rd_data_count(           ),
      .almost_empty (           ),
      .data_valid   (wvalid     ),
      .underflow    (           ),
      .rd_rst_busy  (rd_rst_busy),
      .injectsbiterr(1'b0       ),
      .injectdbiterr(1'b0       ),
      .sbiterr      (           ),
      .dbiterr      (           )
    );
    assign s_tready = ~s_tready_n & ~wr_rst_busy & ~rd_rst_busy;

  end
  else begin : gen_no_fifo
    // Gate valid/ready signals with running so transfers don't occur before the
    // xfer size is known.
    assign wvalid = s_tvalid;
    assign wdata    = s_tdata;
    assign s_tready = wready;
    assign wr_rst_busy = 0;
    assign rd_rst_busy = 0;
  end
endgenerate

assign wstrb = {(C_DATA_WIDTH/8){1'b1}};
assign wxfer = wvalid & wready;

always @(posedge ap_clk) begin
  if (areset) begin
    wfirst <= 1'b1;
  end
  else begin
    wfirst <= wxfer ? wlast : wfirst;
  end
end

// Load burst counter with partial burst if on final transaction or if there is only 1 transaction
assign load_burst_cntr = (wxfer & wlast & w_almost_final_transaction) || (start & single_transaction);

axi_counter #(
  .C_WIDTH(C_LOG_BURST_LEN        ),
  .C_INIT ({C_LOG_BURST_LEN{1'b1}})
) inst_burst_cntr (
  .clk       (ap_clk         ),
  .clken     (1'b1           ),
  .rst       (areset         ),
  .load      (load_burst_cntr),
  .incr      (1'b0           ),
  .decr      (wxfer          ),
  .load_value(final_burst_len),
  .count     (wxfers_to_go   ),
  .is_zero   (wlast          )
);

axi_counter #(
  .C_WIDTH(LP_TRANSACTION_CNTR_WIDTH        ),
  .C_INIT ({LP_TRANSACTION_CNTR_WIDTH{1'b0}})
) inst_w_transaction_cntr (
  .clk       (ap_clk              ),
  .clken     (1'b1                ),
  .rst       (areset              ),
  .load      (start               ),
  .incr      (1'b0                ),
  .decr      (wxfer & wlast       ),
  .load_value(num_transactions    ),
  .count     (w_transactions_to_go),
  .is_zero   (w_final_transaction )
);

always @(posedge ap_clk) begin
  w_almost_final_transaction <= (w_transactions_to_go == 1) ? 1'b1 : 1'b0;
end

/////////////////////////////////////////////////////////////////////////////
// AXI Write Address Channel
/////////////////////////////////////////////////////////////////////////////
// The address channel samples the data channel and send out transactions when
// first beat of wdata is asserted. This ensures that address requests are not
// sent without data on the way.

assign awvalid = awvalid_r;
assign awxfer  = awvalid & awready;

always @(posedge ap_clk) begin
  if (areset) begin
    awvalid_r <= 1'b0;
  end
  else begin
    awvalid_r <= ~idle_aw & ~awvalid_r ? 1'b1 :
      awready               ? 1'b0 :
      awvalid_r;
  end
end

assign awaddr = addr;

always @(posedge ap_clk) begin
  addr <= ctrl_start ? ctrl_offset :
    awxfer     ? addr + C_BURST_LEN*C_DATA_WIDTH/8 :
    addr;
end

assign awlen  = aw_final_transaction || (start & single_transaction) ? final_burst_len : C_BURST_LEN - 1;
assign awsize = $clog2((C_DATA_WIDTH/8));

axi_counter #(
  .C_WIDTH(LP_LOG_MAX_W_TO_AW        ),
  .C_INIT ({LP_LOG_MAX_W_TO_AW{1'b0}})
) inst_w_to_aw_cntr (
  .clk       (ap_clk                 ),
  .clken     (1'b1                   ),
  .rst       (areset                 ),
  .load      (1'b0                   ),
  .incr      (wfirst_pulse           ),
  .decr      (awxfer                 ),
  .load_value(                       ),
  .count     (dbg_w_to_aw_outstanding),
  .is_zero   (idle_aw                )
);

always @(posedge ap_clk) begin
  wfirst_d1 <= wvalid & wfirst;
end

always @(posedge ap_clk) begin
  wfirst_pulse <= wvalid & wfirst & ~wfirst_d1;
end

axi_counter #(
  .C_WIDTH(LP_TRANSACTION_CNTR_WIDTH        ),
  .C_INIT ({LP_TRANSACTION_CNTR_WIDTH{1'b0}})
) inst_aw_transaction_cntr (
  .clk       (ap_clk               ),
  .clken     (1'b1                 ),
  .rst       (areset               ),
  .load      (start                ),
  .incr      (1'b0                 ),
  .decr      (awxfer               ),
  .load_value(num_transactions     ),
  .count     (aw_transactions_to_go),
  .is_zero   (aw_final_transaction )
);

/////////////////////////////////////////////////////////////////////////////
// AXI Write Response Channel
/////////////////////////////////////////////////////////////////////////////

assign bready = 1'b1;
assign bxfer  = bready & bvalid;

axi_counter #(
  .C_WIDTH(LP_TRANSACTION_CNTR_WIDTH        ),
  .C_INIT ({LP_TRANSACTION_CNTR_WIDTH{1'b0}})
) inst_b_transaction_cntr (
  .clk       (ap_clk              ),
  .clken     (1'b1                ),
  .rst       (areset              ),
  .load      (start               ),
  .incr      (1'b0                ),
  .decr      (bxfer               ),
  .load_value(num_transactions    ),
  .count     (b_transactions_to_go),
  .is_zero   (b_final_transaction )
);

endmodule : engine_m_axi_write