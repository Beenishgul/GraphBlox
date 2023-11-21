// /*******************************************************************************
// Copyright (c) 2019, Xilinx, Inc.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
//
// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// *******************************************************************************/

// --------------------------------------------------------------------------------------//
// Description: This is a example of how to create an RTL Kernel.  The function
// of this module is to add two 32-bit values and produce a result.  The values
// are read from one AXI4 memory mapped master, processed and then written out.
//
// Data flow: axi_read_master->fifo[2]->adder->fifo->axi_write_master
// --------------------------------------------------------------------------------------//

// default_nettype of none prevents implicit logic declaration.
`include "global_package.vh"

module engine_m_axi (
  // System signals
  input  logic                          ap_clk      ,
  input  logic                          areset      ,
  // AXI4 master interface
  output logic                          axi_awvalid ,
  input  logic                          axi_awready ,
  output logic [  M_AXI4_FE_ADDR_W-1:0] axi_awaddr  ,
  output logic [    M_AXI4_FE_ID_W-1:0] axi_awid    ,
  output logic [   M_AXI4_FE_LEN_W-1:0] axi_awlen   ,
  output logic [  M_AXI4_FE_SIZE_W-1:0] axi_awsize  ,
  output logic [ M_AXI4_FE_BURST_W-1:0] axi_awburst ,
  output logic [  M_AXI4_FE_LOCK_W-1:0] axi_awlock  ,
  output logic [ M_AXI4_FE_CACHE_W-1:0] axi_awcache ,
  output logic [  M_AXI4_FE_PROT_W-1:0] axi_awprot  ,
  output logic [   M_AXI4_FE_QOS_W-1:0] axi_awqos   ,
  output logic [M_AXI4_FE_REGION_W-1:0] axi_awregion,
  output logic                          axi_wvalid  ,
  input  logic                          axi_wready  ,
  output logic [  M_AXI4_FE_DATA_W-1:0] axi_wdata   ,
  output logic [M_AXI4_FE_DATA_W/8-1:0] axi_wstrb   ,
  output logic                          axi_wlast   ,
  output logic                          axi_arvalid ,
  input  logic                          axi_arready ,
  output logic [  M_AXI4_FE_ADDR_W-1:0] axi_araddr  ,
  output logic [    M_AXI4_FE_ID_W-1:0] axi_arid    ,
  output logic [   M_AXI4_FE_LEN_W-1:0] axi_arlen   ,
  output logic [  M_AXI4_FE_SIZE_W-1:0] axi_arsize  ,
  output logic [ M_AXI4_FE_BURST_W-1:0] axi_arburst ,
  output logic [  M_AXI4_FE_LOCK_W-1:0] axi_arlock  ,
  output logic [ M_AXI4_FE_CACHE_W-1:0] axi_arcache ,
  output logic [  M_AXI4_FE_PROT_W-1:0] axi_arprot  ,
  output logic [   M_AXI4_FE_QOS_W-1:0] axi_arqos   ,
  output logic [M_AXI4_FE_REGION_W-1:0] axi_arregion,
  input  logic                          axi_rvalid  ,
  output logic                          axi_rready  ,
  input  logic [  M_AXI4_FE_DATA_W-1:0] axi_rdata   ,
  input  logic                          axi_rlast   ,
  input  logic [    M_AXI4_FE_ID_W-1:0] axi_rid     ,
  input  logic [  M_AXI4_FE_RESP_W-1:0] axi_rresp   ,
  input  logic                          axi_bvalid  ,
  output logic                          axi_bready  ,
  input  logic [  M_AXI4_FE_RESP_W-1:0] axi_bresp   ,
  input  logic [    M_AXI4_FE_ID_W-1:0] axi_bid
);
// --------------------------------------------------------------------------------------//
// Local Parameters (constants)
// --------------------------------------------------------------------------------------//
localparam integer LP_NUM_READ_CHANNELS  = 1                                              ;
localparam integer LP_LENGTH_WIDTH       = M_AXI4_FE_DATA_W                               ;
localparam integer LP_DW_BYTES           = M_AXI4_FE_DATA_W/8                             ;
localparam integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
localparam integer LP_LOG_BURST_LEN      = $clog2(LP_AXI_BURST_LEN)                       ;
localparam integer LP_RD_MAX_OUTSTANDING = 3                                              ;

// --------------------------------------------------------------------------------------//
// Variables
// --------------------------------------------------------------------------------------//
logic                                                  areset_m_axi_kernel    ;
logic                                                  read_transaction_done  ;
logic                                                  read_transaction_start ;
logic [     LP_LENGTH_WIDTH-1:0]                       read_transaction_length;
logic [LP_NUM_READ_CHANNELS-1:0]                       read_transaction_tready;
logic [LP_NUM_READ_CHANNELS-1:0]                       read_transaction_tvalid;
logic [LP_NUM_READ_CHANNELS-1:0][M_AXI4_FE_DATA_W-1:0] read_transaction_tdata ;
logic [    M_AXI4_FE_ADDR_W-1:0]                       read_transaction_offset;

logic                        write_transaction_tready;
logic                        write_transaction_tvalid;
logic                        write_transaction_done  ;
logic                        write_transaction_start ;
logic [ LP_LENGTH_WIDTH-1:0] write_transaction_length;
logic [M_AXI4_FE_ADDR_W-1:0] write_transaction_offset;
logic [M_AXI4_FE_DATA_W-1:0] write_transaction_tdata ;

// --------------------------------------------------------------------------------------//
// RTL Logic
// --------------------------------------------------------------------------------------//
// Tie-off unused AXI protocol features
assign axi_arburst  = 2'b01;
assign axi_arcache  = 4'b0011;
assign axi_arlock   = 2'b00;
assign axi_arprot   = 3'b000;
assign axi_arqos    = 4'b0000;
assign axi_arregion = 4'b0000;
assign axi_awburst  = 2'b01;
assign axi_awcache  = 4'b0011;
assign axi_awid     = {M_AXI4_FE_ID_W{1'b0}};
assign axi_awlock   = 2'b00;
assign axi_awprot   = 3'b000;
assign axi_awqos    = 4'b0000;
assign axi_awregion = 4'b0000;

// Register and invert reset signal for better timing.
always @(posedge ap_clk) begin
  areset_m_axi_kernel <= areset;
end

// --------------------------------------------------------------------------------------
// Variables
// --------------------------------------------------------------------------------------
logic [M_AXI4_FE_DATA_W-1:0] acc;

// --------------------------------------------------------------------------------------
// Logic
// --------------------------------------------------------------------------------------

always_comb begin
  acc = read_transaction_tdata[0];
  for (int i = 1; i < LP_NUM_READ_CHANNELS; i++) begin
    acc = acc + read_transaction_tdata[i];
  end
end

assign write_transaction_tvalid = &read_transaction_tvalid;
assign write_transaction_tdata  = acc;

// Only assert read_transaction_tready when transfer has been accepted.  tready asserted on all channels simultaneously
assign read_transaction_tready = write_transaction_tready & write_transaction_tvalid ? {LP_NUM_READ_CHANNELS{1'b1}} : {LP_NUM_READ_CHANNELS{1'b0}};

// AXI4 Read Master
engine_m_axi_read #(
  .C_ADDR_WIDTH       (M_AXI4_FE_ADDR_W     ),
  .C_DATA_WIDTH       (M_AXI4_FE_DATA_W     ),
  .C_ID_WIDTH         (M_AXI4_FE_ID_W       ),
  .C_NUM_CHANNELS     (LP_NUM_READ_CHANNELS ),
  .C_LENGTH_WIDTH     (LP_LENGTH_WIDTH      ),
  .C_BURST_LEN        (LP_AXI_BURST_LEN     ),
  .C_LOG_BURST_LEN    (LP_LOG_BURST_LEN     ),
  .C_MAX_OUTSTANDING  (LP_RD_MAX_OUTSTANDING),
  .C_INCLUDE_DATA_FIFO(1                    )
) inst_engine_m_axi_read (
  .aclk               (ap_clk                 ),
  .areset_m_axi_kernel(areset_m_axi_kernel    ),
  
  .ctrl_start         (read_transaction_start ),
  .ctrl_done          (read_transaction_done  ),
  .ctrl_offset        (read_transaction_offset),
  .ctrl_length        (read_transaction_length),
  
  .arvalid            (axi_arvalid            ),
  .arready            (axi_arready            ),
  .araddr             (axi_araddr             ),
  .arid               (axi_arid               ),
  .arlen              (axi_arlen              ),
  .arsize             (axi_arsize             ),
  .rvalid             (axi_rvalid             ),
  .rready             (axi_rready             ),
  .rdata              (axi_rdata              ),
  .rlast              (axi_rlast              ),
  .rid                (axi_rid                ),
  .rresp              (axi_rresp              ),
  
  .m_tvalid           (read_transaction_tvalid),
  .m_tready           (read_transaction_tready),
  .m_tdata            (read_transaction_tdata )
);

// AXI4 Write Master
engine_m_axi_write #(
  .C_ADDR_WIDTH       (M_AXI4_FE_ADDR_W),
  .C_DATA_WIDTH       (M_AXI4_FE_DATA_W),
  .C_MAX_LENGTH_WIDTH (LP_LENGTH_WIDTH ),
  .C_BURST_LEN        (LP_AXI_BURST_LEN),
  .C_LOG_BURST_LEN    (LP_LOG_BURST_LEN),
  .C_INCLUDE_DATA_FIFO(1               )
) inst_engine_m_axi_write (
  .aclk               (ap_clk                  ),
  .areset_m_axi_kernel(areset_m_axi_kernel     ),
  
  .ctrl_start         (write_transaction_start ),
  .ctrl_offset        (write_transaction_offset),
  .ctrl_length        (write_transaction_length),
  .ctrl_done          (write_transaction_done  ),
  
  .awvalid            (axi_awvalid             ),
  .awready            (axi_awready             ),
  .awaddr             (axi_awaddr              ),
  .awlen              (axi_awlen               ),
  .awsize             (axi_awsize              ),
  .wvalid             (axi_wvalid              ),
  .wready             (axi_wready              ),
  .wdata              (axi_wdata               ),
  .wstrb              (axi_wstrb               ),
  .wlast              (axi_wlast               ),
  .bvalid             (axi_bvalid              ),
  .bready             (axi_bready              ),
  .bresp              (axi_bresp               ),
  
  .s_tvalid           (write_transaction_tvalid),
  .s_tready           (write_transaction_tready),
  .s_tdata            (write_transaction_tdata )
);

endmodule : engine_m_axi

