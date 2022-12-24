// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_control.sv
// Create : 2022-12-20 21:55:38
// Revise : 2022-12-20 21:55:38
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_GLOBALS_PKG::*;
import GLAY_AXI4_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;

module glay_kernel_control #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
    // System Signals
    input  logic                          ap_clk             ,
    input  logic                          areset             ,
    input  logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_done_in    ,
    input  GlayControlChainIterfaceInput  glay_control_in    ,
    output GlayControlChainIterfaceOutput glay_control_out   ,
    input  GLAYDescriptorInterface        glay_descriptor_in ,
    output GLAYDescriptorInterface        glay_descriptor_out
);

    logic                          ap_start_r     = 1'b0                      ;
    logic                          ap_idle_r      = 1'b1                      ;
    logic                          ap_start_pulse                             ;
    logic [NUM_GRAPH_CLUSTERS-1:0] ap_done_i      = {NUM_GRAPH_CLUSTERS{1'b0}};
    logic [NUM_GRAPH_CLUSTERS-1:0] ap_done_r      = {NUM_GRAPH_CLUSTERS{1'b0}};


    always @(posedge ap_clk) begin
        if (areset) begin
            ap_done_i <= {NUM_GRAPH_CLUSTERS{1'b0}};
        end
        else begin
            ap_done_i <= glay_cu_done_in;
        end
    end

// create pulse when ap_start transitions to 1
    always @(posedge ap_clk) begin
        begin
            ap_start_r <= glay_control_in.glay_start;
        end
    end

    assign ap_start_pulse = glay_control_in.glay_start & ~ap_start_r;

// glay_control_out.glay_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
    always @(posedge ap_clk) begin
        if (areset) begin
            ap_idle_r <= 1'b1;
        end
        else begin
            ap_idle_r <= glay_control_out.glay_done ? 1'b1 : ap_start_pulse ? 1'b0 : glay_control_out.glay_idle;
        end
    end

    assign glay_control_out.glay_idle = ap_idle_r;

// Done logic
    always @(posedge ap_clk) begin
        if (areset) begin
            ap_done_r <= '0;
        end
        else begin
            ap_done_r <= (glay_control_in.glay_continue & glay_control_out.glay_done) ? '0 : ap_done_r | ap_done_i;
        end
    end

    assign glay_control_out.glay_done = &ap_done_r;

// Ready Logic (non-pipelined case)
    assign glay_control_out.glay_ready = glay_control_out.glay_done;


    always @(posedge ap_clk) begin
        if (areset) begin
            glay_descriptor_out.valid <= 0;
        end
        else begin
            glay_descriptor_out.valid <= glay_descriptor_in.valid;
        end
    end

    always @(posedge ap_clk) begin
        glay_descriptor_out.payload <= glay_descriptor_in.payload;
    end

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN input sync
// --------------------------------------------------------------------------------------

    glay_kernel_control_input #(
        .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
        .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
    ) inst_glay_kernel_control_input (
        .ap_clk          (ap_clk              ),
        .areset          (areset              ),
        .glay_cu_done_in (glay_cu_done_in_reg ),
        .glay_control_in (glay_control_in_reg ),
        .glay_control_out(glay_control_out_reg)
    );

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN output sync
// --------------------------------------------------------------------------------------

    glay_kernel_control_output #(
        .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
        .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
    ) inst_glay_kernel_control_output (
        .ap_clk          (ap_clk             ),
        .areset          (areset             ),
        .glay_cu_done_in (glay_cu_done_in_reg),
        .glay_control_in (glay_control_in_reg),
        .glay_control_out(glay_control_out   )
    );


endmodule : glay_kernel_control
