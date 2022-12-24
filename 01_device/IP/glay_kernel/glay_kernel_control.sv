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
    input  logic                           ap_clk             ,
    input  logic                           areset             ,
    input  logic [NUM_GRAPH_CLUSTERS-1:0]  glay_cu_done_in    ,
    input  GlayControlChainInterfaceInput  glay_control_in    ,
    output GlayControlChainInterfaceOutput glay_control_out   ,
    input  GLAYDescriptorInterface         glay_descriptor_in ,
    output GLAYDescriptorInterface         glay_descriptor_out
);

    logic                          glay_descriptor_valid_reg;
    logic                          control_areset           ;
    logic                          control_input_areset     ;
    logic                          control_output_areset    ;
    logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_done_reg         ;

    GlayControlChainOutputSyncInterfaceOutput glay_kernel_control_output_reg;
    GlayControlChainInputSyncInterfaceOutput  glay_kernel_control_input_reg ;
    GlayControlChainInterfaceInput            glay_control_in_reg           ;
    GlayControlChainInterfaceOutput           glay_control_out_reg          ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        control_areset        <= areset;
        control_input_areset  <= areset;
        control_output_areset <= areset;
    end

// --------------------------------------------------------------------------------------
//   Reset internal registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_cu_done_reg <= {NUM_GRAPH_CLUSTERS{1'b0}};
        end
        else begin
            glay_cu_done_reg <= glay_cu_done_in;
        end
    end

// --------------------------------------------------------------------------------------
//   Reset output registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_control_out.glay_ready <= 1'b0;
            glay_control_out.glay_done  <= 1'b0;
            glay_control_out.glay_idle  <= 1'b0;
        end
        else begin
            glay_control_out <= glay_control_out_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_control_out_reg.glay_ready <= 1'b0;
            glay_control_out_reg.glay_done  <= 1'b0;
            glay_control_out_reg.glay_idle  <= 1'b0;
        end
        else begin
            glay_control_out_reg.glay_ready <= glay_kernel_control_input_reg.glay_ready;
            glay_control_out_reg.glay_done  <= glay_kernel_control_output_reg.glay_done;
            glay_control_out_reg.glay_idle  <= glay_kernel_control_output_reg.glay_idle;
        end
    end

// --------------------------------------------------------------------------------------
//   Reset input registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_control_in_reg <= 0;
        end
        else begin
            glay_control_in_reg <= glay_control_in;
        end
    end

// --------------------------------------------------------------------------------------
//   Glay_descriptor LOGIC
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_descriptor_out.valid <= 1'b0;
        end
        else begin
            glay_descriptor_out.valid <= glay_descriptor_valid_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        glay_descriptor_out.payload <= glay_descriptor_in.payload;
    end

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN input sync
// --------------------------------------------------------------------------------------

    glay_kernel_control_input #(
        .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
        .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
    ) inst_glay_kernel_control_input (
        .ap_clk                       (ap_clk                       ),
        .areset                       (control_input_areset         ),
        .glay_cu_done_in              (glay_cu_done_reg             ),
        .glay_control_in              (glay_control_in_reg          ),
        .glay_kernel_control_input_out(glay_kernel_control_input_reg),
        .glay_descriptor_valid_out    (glay_descriptor_valid_reg    )
    );

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN output sync
// --------------------------------------------------------------------------------------

    glay_kernel_control_output #(
        .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
        .NUM_GRAPH_PE      (NUM_GRAPH_PE      )
    ) inst_glay_kernel_control_output (
        .ap_clk                        (ap_clk                        ),
        .areset                        (control_output_areset         ),
        .glay_cu_done_in               (glay_cu_done_reg              ),
        .glay_control_in               (glay_control_in_reg           ),
        .glay_kernel_control_output_out(glay_kernel_control_output_reg)
    );


endmodule : glay_kernel_control
