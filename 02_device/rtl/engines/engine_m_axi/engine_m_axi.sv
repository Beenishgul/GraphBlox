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

module engine_m_axi #(
  parameter C_NUM_CHANNELS      = 1                                                 ,
  parameter M_AXI4_MID_ADDR_W   = M00_AXI4_MID_ADDR_W                               ,
  parameter M_AXI4_MID_BURST_W  = M00_AXI4_MID_BURST_W                              ,
  parameter M_AXI4_MID_CACHE_W  = M00_AXI4_MID_CACHE_W                              ,
  parameter M_AXI4_MID_DATA_W   = M00_AXI4_MID_DATA_W                               ,
  parameter M_AXI4_MID_ID_W     = M00_AXI4_MID_ID_W                                 ,
  parameter M_AXI4_MID_LEN_W    = M00_AXI4_MID_LEN_W                                ,
  parameter M_AXI4_MID_LOCK_W   = M00_AXI4_MID_LOCK_W                               ,
  parameter M_AXI4_MID_PROT_W   = M00_AXI4_MID_PROT_W                               ,
  parameter M_AXI4_MID_QOS_W    = M00_AXI4_MID_QOS_W                                ,
  parameter M_AXI4_MID_REGION_W = M00_AXI4_MID_REGION_W                             ,
  parameter M_AXI4_MID_RESP_W   = M00_AXI4_MID_RESP_W                               ,
  parameter M_AXI4_MID_SIZE_W   = M00_AXI4_MID_SIZE_W                               ,
  parameter C_AXI_RW_CACHE      = M00_AXI4_BE_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES
) (
  // System signals
  input  logic                                                  ap_clk                      ,
  input  logic                                                  areset                      ,
  // Transactions READ
  input  logic                                                  read_transaction_start_in   ,
  input  logic [  M_AXI4_MID_DATA_W-1:0]                        read_transaction_length_in  ,
  input  logic [     C_NUM_CHANNELS-1:0][M_AXI4_MID_ADDR_W-1:0] read_transaction_offset_in  ,
  output logic                                                  read_transaction_done_out   ,
  input  logic [     C_NUM_CHANNELS-1:0]                        read_transaction_tready_in  ,
  output logic [     C_NUM_CHANNELS-1:0]                        read_transaction_tvalid_out ,
  output logic [     C_NUM_CHANNELS-1:0][M_AXI4_MID_DATA_W-1:0] read_transaction_tdata_out  ,
  output logic [     C_NUM_CHANNELS-1:0]                        read_transaction_prog_full  ,
  // AXI4 master interface READ
  input  logic                                                  axi_arready                 ,
  input  logic                                                  axi_rlast                   ,
  input  logic                                                  axi_rvalid                  ,
  input  logic [    M_AXI4_MID_ID_W-1:0]                        axi_rid                     ,
  input  logic [  M_AXI4_MID_DATA_W-1:0]                        axi_rdata                   ,
  input  logic [  M_AXI4_MID_RESP_W-1:0]                        axi_rresp                   ,
  output logic                                                  axi_arvalid                 ,
  output logic                                                  axi_rready                  ,
  output logic [    M_AXI4_MID_ID_W-1:0]                        axi_arid                    ,
  output logic [   M_AXI4_MID_LEN_W-1:0]                        axi_arlen                   ,
  output logic [   M_AXI4_MID_QOS_W-1:0]                        axi_arqos                   ,
  output logic [  M_AXI4_MID_ADDR_W-1:0]                        axi_araddr                  ,
  output logic [  M_AXI4_MID_LOCK_W-1:0]                        axi_arlock                  ,
  output logic [  M_AXI4_MID_PROT_W-1:0]                        axi_arprot                  ,
  output logic [  M_AXI4_MID_SIZE_W-1:0]                        axi_arsize                  ,
  output logic [ M_AXI4_MID_BURST_W-1:0]                        axi_arburst                 ,
  output logic [ M_AXI4_MID_CACHE_W-1:0]                        axi_arcache                 ,
  output logic [M_AXI4_MID_REGION_W-1:0]                        axi_arregion                
);
// --------------------------------------------------------------------------------------//
// Local Parameters (constants)
// --------------------------------------------------------------------------------------//
localparam integer LP_NUM_READ_CHANNELS = 1                  ;
localparam integer LP_DW_BYTES          = M_AXI4_MID_DATA_W/8;
localparam integer LP_AXI_BURST_LEN      = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
// localparam integer LP_AXI_BURST_LEN      = 16                      ;
localparam integer LP_LOG_BURST_LEN      = $clog2(LP_AXI_BURST_LEN);
localparam integer LP_RD_MAX_OUTSTANDING = 16                      ;

// --------------------------------------------------------------------------------------//
// Variables
// --------------------------------------------------------------------------------------//
logic areset_m_axi_kernel;

// --------------------------------------------------------------------------------------//
// RTL Logic
// --------------------------------------------------------------------------------------//
// Tie-off unused AXI protocol features
assign axi_arburst  = 2'b01;
assign axi_arcache  = C_AXI_RW_CACHE;
assign axi_arlock   = 2'b00;
assign axi_arprot   = 3'b000;
assign axi_arqos    = 4'b0000;
assign axi_arregion = 4'b0000;
assign axi_awburst  = 2'b00;
assign axi_awcache  = C_AXI_RW_CACHE;
assign axi_awid     = {M_AXI4_MID_ID_W{1'b0}};
assign axi_awlock   = 2'b00;
assign axi_awprot   = 3'b000;
assign axi_awqos    = 4'b0000;
assign axi_awregion = 4'b0000;

// Register and invert reset signal for better timing.
always @(posedge ap_clk) begin
  areset_m_axi_kernel <= areset;
end

// AXI4 Read Master
engine_m_axi_read #(
  .C_ADDR_WIDTH       (M_AXI4_MID_ADDR_W    ),
  .C_DATA_WIDTH       (M_AXI4_MID_DATA_W    ),
  .C_ID_WIDTH         (M_AXI4_MID_ID_W      ),
  .C_NUM_CHANNELS     (C_NUM_CHANNELS       ),
  .C_LENGTH_WIDTH     (M_AXI4_MID_DATA_W    ),
  .C_BURST_LEN        (LP_AXI_BURST_LEN     ),
  .C_LOG_BURST_LEN    (LP_LOG_BURST_LEN     ),
  .C_MAX_OUTSTANDING  (LP_RD_MAX_OUTSTANDING),
  .C_INCLUDE_DATA_FIFO(0                    )
) inst_engine_m_axi_read (
  .ap_clk        (ap_clk                     ),
  .areset        (areset_m_axi_kernel        ),
  
  .ctrl_done     (read_transaction_done_out  ),
  .ctrl_length   (read_transaction_length_in ),
  .ctrl_offset   (read_transaction_offset_in ),
  .ctrl_start    (read_transaction_start_in  ),
  .ctrl_prog_full(read_transaction_prog_full ),
  .araddr        (axi_araddr                 ),
  .arid          (axi_arid                   ),
  .arlen         (axi_arlen                  ),
  .arready       (axi_arready                ),
  .arsize        (axi_arsize                 ),
  .arvalid       (axi_arvalid                ),
  .rdata         (axi_rdata                  ),
  .rid           (axi_rid                    ),
  .rlast         (axi_rlast                  ),
  .rready        (axi_rready                 ),
  .rresp         (axi_rresp                  ),
  .rvalid        (axi_rvalid                 ),
  
  .m_tvalid      (read_transaction_tvalid_out),
  .m_tready      (read_transaction_tready_in ),
  .m_tdata       (read_transaction_tdata_out )
);

endmodule : engine_m_axi

