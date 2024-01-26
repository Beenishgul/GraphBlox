// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

// Description:
// This is an AXI4 read master module example. The module demonstrates how to
// issue AXI read transactions to a memory mapped slave.  Given a starting
// address offset and a transfer size in bytes, it will issue one or more AXI
// transactions and return the data over an AXI4-Stream interface.
//
// Theory of operation:
// It uses a minimum subset of the AXI4 protocol by omitting AXI4 signals that
// are not used.  When packaged as a kernel or IP, this allows for
// optimizations to occur within the AXI Interconnect system to increase Fmax,
// potentially increase performance, and reduce latency/area. When
// C_INCLUDE_DATA_FIFO is set to 1, a data FIFO is included and configured so
// that all transactions that are issued can fit into the FIFO.  This allows
// for m_axi_rready to be tied high, and ensures that an unexpected stall
// internally does not cause the AXI Interconnect system to become
// inadvertantly deadlocked or cause head of line blocking to other AXI masters
// in the system.
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
//    This value will be rounded up to the nearest multiple of the interface width.
//    For example a request of 100 bytes will be rounded up to 128 bytes on a 64 byte
//    (512 bits) wide interface.
// 3) Assert ctrl_start for once cycle.  At the posedge, the ctrl_addr_offset and
//    ctrl_xfer_size_in_bytes will be registered in the module, and will start
//    issue read address transfers.  If the the transfer size is larger than 4096
//    bytes, multiple transactions will be issued.  There may be up to the
//    C_MAX_OUTSTANDING issued in succession.  Once the limit is hit
//    no more read address transfers on the AR channel will be issued until
//    R channel transactions have completed as indicated by the RLAST signal.
// 4) Read Data will appear on the AXI4-Stream interface (m_axis) as signalled by
//    an assertion of the m_axis_tvalid signal.
// 5) When the final R-channel transaction has completed, the module will assert
//    the ctrl_done signal for one cycle.  If a data FIFO is present, data may
//    still be present in the FIFO.
// 6) Jump to step 1.
////////////////////////////////////////////////////////////////////////////////

`include "global_package.vh"

module engine_m_axi_read #(
  parameter integer C_ID_WIDTH          = 1,   // Must be >= $clog2(C_NUM_CHANNELS)
  parameter integer C_ADDR_WIDTH        = 64,
  parameter integer C_DATA_WIDTH        = 32,
  parameter integer C_NUM_CHANNELS      = 1,   // Only 2 tested.
  parameter integer C_LENGTH_WIDTH      = 32,
  parameter integer C_BURST_LEN         = 256, // Max AXI burst length for read commands
  parameter integer C_LOG_BURST_LEN     = 8,
  parameter integer C_MAX_OUTSTANDING   = 3,
  parameter integer C_INCLUDE_DATA_FIFO = 1
)
(
  // System signals
  input  logic                                          ap_clk,
  input  logic                                          areset,
  // Control signals
  input  logic                                          ctrl_start,
  output logic                                          ctrl_done,
  input  logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0]   ctrl_offset,
  input  logic                     [C_LENGTH_WIDTH-1:0] ctrl_length,
  output logic [C_NUM_CHANNELS-1:0]                     ctrl_prog_full,
  // AXI4 master interface
  output logic                                          arvalid,
  input  logic                                          arready,
  output logic [C_ADDR_WIDTH-1:0]                       araddr,
  output logic [C_ID_WIDTH-1:0]                         arid,
  output logic [7:0]                                    arlen,
  output logic [2:0]                                    arsize,
  input  logic                                          rvalid,
  output logic                                          rready,
  input  logic [C_DATA_WIDTH - 1:0]                     rdata,
  input  logic                                          rlast,
  input  logic [C_ID_WIDTH - 1:0]                       rid,
  input  logic [1:0]                                    rresp,
  // AXI4-Stream master interface, 1 interface per channel.
  output logic [C_NUM_CHANNELS-1:0]                     m_tvalid,
  input  logic [C_NUM_CHANNELS-1:0]                     m_tready,
  output logic [C_NUM_CHANNELS-1:0][C_DATA_WIDTH-1:0]   m_tdata
);

timeunit 1ps;
timeprecision 1ps;

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_MAX_OUTSTANDING_CNTR_WIDTH = $clog2(C_MAX_OUTSTANDING+1)                   ;
localparam integer LP_TRANSACTION_CNTR_WIDTH     = C_LENGTH_WIDTH-C_LOG_BURST_LEN                ;
localparam integer LP_FIFO_DEPTH                 = 2**($clog2(C_BURST_LEN*(C_MAX_OUTSTANDING+1))); // Ensure power of 2

///////////////////////////////////////////////////////////////////////////////
// Variables
///////////////////////////////////////////////////////////////////////////////
// Control logic
logic [           C_NUM_CHANNELS-1:0] done               = '0  ;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_full_bursts          ;
logic                                 num_partial_bursts       ;
logic                                 start              = 1'b0;
logic [LP_TRANSACTION_CNTR_WIDTH-1:0] num_transactions         ;
logic                                 has_partial_burst        ;
logic [          C_LOG_BURST_LEN-1:0] final_burst_len          ;
logic                                 single_transaction       ;
logic                                 ar_idle            = 1'b1;
logic                                 ar_done                  ;
// AXI Read Address Channel
logic [C_NUM_CHANNELS-1:0]                   prog_full        ;
logic [C_NUM_CHANNELS-1:0]                   fifo_full        ;
logic [C_NUM_CHANNELS-1:0]                   fifo_valid       ;
logic                                        fifo_stall       ;
logic                                        arxfer           ;
logic                                        arvalid_r  = 1'b0;
logic [C_NUM_CHANNELS-1:0][C_ADDR_WIDTH-1:0] addr             ;
// TODO this needs to be reset as the maximum value
logic [               C_ID_WIDTH-1:0]                                    id                        = {C_ID_WIDTH{C_NUM_CHANNELS-1}};
logic [LP_TRANSACTION_CNTR_WIDTH-1:0]                                    ar_transactions_to_go                                     ;
logic                                                                    ar_final_transaction                                      ;
logic [           C_NUM_CHANNELS-1:0]                                    incr_ar_to_r_cnt                                          ;
logic [           C_NUM_CHANNELS-1:0]                                    decr_ar_to_r_cnt                                          ;
logic [           C_NUM_CHANNELS-1:0]                                    stall_ar                                                  ;
logic [           C_NUM_CHANNELS-1:0][LP_MAX_OUTSTANDING_CNTR_WIDTH-1:0] outstanding_vacancy_count                                 ;
// AXI Data Channel
logic [C_NUM_CHANNELS-1:0]                                tvalid                 ;
logic [C_NUM_CHANNELS-1:0][             C_DATA_WIDTH-1:0] tdata                  ;
logic                                                     rxfer                  ;
logic [C_NUM_CHANNELS-1:0]                                decr_r_transaction_cntr;
logic [C_NUM_CHANNELS-1:0][LP_TRANSACTION_CNTR_WIDTH-1:0] r_transactions_to_go   ;
logic [C_NUM_CHANNELS-1:0]                                r_final_transaction    ;

logic [C_NUM_CHANNELS-1:0] m_tvalid_n ;
logic [C_NUM_CHANNELS-1:0] wr_rst_busy;
logic [C_NUM_CHANNELS-1:0] rd_rst_busy;
///////////////////////////////////////////////////////////////////////////////
// Control Logic
///////////////////////////////////////////////////////////////////////////////

always @(posedge ap_clk) begin
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    done[i] <= rxfer & rlast & (rid == i) & r_final_transaction[i] ? 1'b1 :
      ctrl_done ? 1'b0 : done[i];
  end
end
assign ctrl_done = &done;

// Determine how many full burst to issue and if there are any partial bursts.
assign num_full_bursts    = ctrl_length[C_LOG_BURST_LEN+:C_LENGTH_WIDTH-C_LOG_BURST_LEN];
assign num_partial_bursts = ctrl_length[0+:C_LOG_BURST_LEN] ? 1'b1 : 1'b0;

always @(posedge ap_clk) begin
  start             <= ctrl_start;
  num_transactions  <= (num_partial_bursts == 1'b0) ? num_full_bursts - 1'b1 : num_full_bursts;
  has_partial_burst <= num_partial_bursts;
  final_burst_len   <= ctrl_length[0+:C_LOG_BURST_LEN] - 1'b1;
end

// Special case if there is only 1 AXI transaction.
assign single_transaction = (num_transactions == {LP_TRANSACTION_CNTR_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

///////////////////////////////////////////////////////////////////////////////
// AXI Read Address Channel
///////////////////////////////////////////////////////////////////////////////
assign arvalid = arvalid_r;
assign araddr  = addr[id];
assign arlen   = ar_final_transaction || (start & single_transaction) ? final_burst_len : C_BURST_LEN - 1;
assign arsize  = $clog2((C_DATA_WIDTH/8));
assign arid    = id;

assign arxfer     = arvalid & arready;
assign fifo_stall = prog_full[id];

always @(posedge ap_clk) begin
  if (areset) begin
    arvalid_r <= 1'b0;
  end
  else begin
    arvalid_r <= ~ar_idle & ~stall_ar[id] & ~arvalid_r & ~fifo_stall ? 1'b1 :
      arready ? 1'b0 : arvalid_r;
  end
end

// When ar_idle, there are no transactions to issue.
always @(posedge ap_clk) begin
  if (areset) begin
    ar_idle <= 1'b1;
  end
  else begin
    ar_idle <= start   ? 1'b0 :
      ar_done ? 1'b1 :
      ar_idle;
  end
end

// each channel is assigned a different id. The transactions are interleaved.
always @(posedge ap_clk) begin
  if (start) begin
    // TODO this needs to be reset to maximum id
    id <= {C_ID_WIDTH{C_NUM_CHANNELS-1}};
  end
  else begin
    id <= arxfer ? (id - 1'b1) % {C_ID_WIDTH{C_NUM_CHANNELS}} : id;
  end
end


// Increment to next address after each transaction is issued.
always @(posedge ap_clk) begin
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    addr[i] <= ctrl_start?ctrl_offset[i] :
      arxfer && (id == i) ? addr[i] + C_BURST_LEN*C_DATA_WIDTH/8 :
        addr[i];
  end
end

// Counts down the number of transactions to send.
axi_counter #(
  .C_WIDTH(LP_TRANSACTION_CNTR_WIDTH        ),
  .C_INIT ({LP_TRANSACTION_CNTR_WIDTH{1'b0}})
) inst_ar_transaction_cntr (
  .clk       (ap_clk               ),
  .clken     (1'b1                 ),
  .rst       (areset               ),
  .load      (start                ),
  .incr      (1'b0                 ),
  .decr      (arxfer && id == '0   ),
  .load_value(num_transactions     ),
  .count     (ar_transactions_to_go),
  .is_zero   (ar_final_transaction )
);

assign ar_done = ar_final_transaction && arxfer && id == 1'b0;

always_comb begin
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    incr_ar_to_r_cnt[i] = rxfer & rlast & (rid == i);
    decr_ar_to_r_cnt[i] = arxfer & (arid == i);
  end
end

// Keeps track of the number of outstanding transactions. Stalls
// when the value is reached so that the FIFO won't overflow.
axi_counter #(
  .C_WIDTH ( LP_MAX_OUTSTANDING_CNTR_WIDTH                       ) ,
  .C_INIT  ( C_MAX_OUTSTANDING[0+:LP_MAX_OUTSTANDING_CNTR_WIDTH] )
)
inst_ar_to_r_transaction_cntr[C_NUM_CHANNELS-1:0] (
  .clk        ( ap_clk                           ) ,
  .clken      ( 1'b1                           ) ,
  .rst        ( areset                         ) ,
  .load       ( 1'b0                           ) ,
  .incr       ( incr_ar_to_r_cnt               ) ,
  .decr       ( decr_ar_to_r_cnt               ) ,
  .load_value ( {LP_MAX_OUTSTANDING_CNTR_WIDTH{1'b0}} ) ,
  .count      ( outstanding_vacancy_count      ) ,
  .is_zero    ( stall_ar                       )
);

///////////////////////////////////////////////////////////////////////////////
// AXI Read Channel
///////////////////////////////////////////////////////////////////////////////

generate
  if (C_INCLUDE_DATA_FIFO == 1) begin : gen_fifo
    genvar i;
    for (i = 0; i < C_NUM_CHANNELS; i = i+1) begin

      xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(LP_FIFO_DEPTH),
        .WRITE_DATA_WIDTH(C_DATA_WIDTH ),
        .READ_DATA_WIDTH (C_DATA_WIDTH ),
        .PROG_THRESH     (C_BURST_LEN-2),
        .READ_MODE       ("fwft"       )
      ) inst_rd_xpm_fifo_sync (
        .clk        (ap_clk        ),
        .srst       (areset        ),
        .din        (tdata[i]      ),
        .wr_en      (tvalid[i]     ),
        .rd_en      (m_tready[i]   ),
        .dout       (m_tdata[i]    ),
        .full       (fifo_full[i]  ),
        .empty      (m_tvalid_n[i] ),
        .valid      (fifo_valid[i] ),
        .prog_full  (prog_full[i]  ),
        .wr_rst_busy(wr_rst_busy[i]),
        .rd_rst_busy(rd_rst_busy[i])
      );

      // rready can remain high for optimal timing because ar transactions are
      // not issued unless there is enough space in the FIFO.
      assign ctrl_prog_full[i] = prog_full[i] | wr_rst_busy[i]  | rd_rst_busy[i] | fifo_full[i] ;
    end
    assign rready   = 1'b1;
    assign m_tvalid = ~m_tvalid_n;
  end else begin
    assign m_tvalid       = tvalid;
    assign m_tdata        = tdata;
    assign rready         = &m_tready;
    assign wr_rst_busy    = 0;
    assign rd_rst_busy    = 0;
    assign ctrl_prog_full = 0;
    assign prog_full      = 0;
    assign fifo_full      = 0;
    assign fifo_valid     = 0;
  end
endgenerate

always_comb begin
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    tvalid[i] = rvalid && (rid == i);
    tdata[i]  = rdata;
  end
end

assign rxfer = rready & rvalid;

always_comb begin
  for (int i = 0; i < C_NUM_CHANNELS; i++) begin
    decr_r_transaction_cntr[i] = rxfer & rlast & (rid == i);
  end
end
axi_counter #(
  .C_WIDTH ( LP_TRANSACTION_CNTR_WIDTH         ) ,
  .C_INIT  ( {LP_TRANSACTION_CNTR_WIDTH{1'b0}} )
)
inst_r_transaction_cntr[C_NUM_CHANNELS-1:0] (
  .clk        ( ap_clk                          ) ,
  .clken      ( 1'b1                          ) ,
  .rst        ( areset                        ) ,
  .load       ( start                         ) ,
  .incr       ( 1'b0                          ) ,
  .decr       ( decr_r_transaction_cntr       ) ,
  .load_value ( num_transactions              ) ,
  .count      ( r_transactions_to_go          ) ,
  .is_zero    ( r_final_transaction           )
);


endmodule : engine_m_axi_read

