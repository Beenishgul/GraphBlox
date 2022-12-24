// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_control_output.sv
// Create : 2022-12-23 19:39:28
// Revise : 2022-12-23 19:39:28
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_GLOBALS_PKG::*;
import GLAY_AXI4_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;

module glay_kernel_control_output #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
    // System Signals
    input  logic                                     ap_clk                        ,
    input  logic                                     areset                        ,
    input  logic [NUM_GRAPH_CLUSTERS-1:0]            glay_cu_done_in               ,
    input  GlayControlChainInterfaceInput            glay_control_in               ,
    output GlayControlChainOutputSyncInterfaceOutput glay_kernel_control_output_out
);

    logic control_ouput_areset;
    logic glay_continue_reg   ;
    logic glay_done_reg       ;
    logic glay_idle_reg       ;

    control_output_state current_state;
    control_output_state next_state   ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        control_ouput_areset <= areset;
    end

// --------------------------------------------------------------------------------------
//   Reset input registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_ouput_areset) begin
            glay_continue_reg <= 0;
        end
        else begin
            glay_continue_reg <= glay_control_in.glay_continue;
        end
    end

// --------------------------------------------------------------------------------------
//   Reset output registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_ouput_areset) begin
            glay_kernel_control_output_out.glay_done <= 1;
            glay_kernel_control_output_out.glay_idle <= 1;
        end
        else begin
            glay_kernel_control_output_out.glay_done <= glay_done_reg;
            glay_kernel_control_output_out.glay_idle <= glay_idle_reg;
        end
    end

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN output sync
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if(control_ouput_areset)
            current_state <= CTRL_OUT_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            CTRL_OUT_RESET : begin
                next_state = CTRL_OUT_IDLE;
            end
            CTRL_OUT_IDLE : begin
                next_state = CTRL_OUT_DONE;
            end
            CTRL_OUT_DONE : begin
                next_state = CTRL_OUT_CONTINUE;
            end
            CTRL_OUT_CONTINUE : begin
                next_state = CTRL_OUT_BUSY;
            end
            CTRL_OUT_BUSY : begin
                next_state = CTRL_OUT_BUSY;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            CTRL_OUT_RESET : begin

            end
            CTRL_OUT_IDLE : begin

            end
            CTRL_OUT_DONE : begin

            end
            CTRL_OUT_CONTINUE : begin

            end
            CTRL_OUT_BUSY : begin

            end
        endcase
    end // always_ff @(posedge ap_clk)



endmodule : glay_kernel_control_output