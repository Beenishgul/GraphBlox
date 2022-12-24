// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_control_input.sv
// Create : 2022-12-23 19:39:33
// Revise : 2022-12-23 19:39:33
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_GLOBALS_PKG::*;
import GLAY_AXI4_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;

module glay_kernel_control_input #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
    // System Signals
    input  logic                                    ap_clk                       ,
    input  logic                                    areset                       ,
    input  logic [NUM_GRAPH_CLUSTERS-1:0]           glay_cu_done_in              ,
    input  GlayControlChainInterfaceInput           glay_control_in              ,
    output GlayControlChainInputSyncInterfaceOutput glay_kernel_control_input_out,
    output logic                                    glay_descriptor_valid_out
);

    logic control_input_areset     ;
    logic glay_start_reg           ;
    logic glay_ready_reg           ;
    logic glay_descriptor_valid_reg;

    control_input_state current_state;
    control_input_state next_state   ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        control_input_areset <= areset;
    end

// --------------------------------------------------------------------------------------
//   Reset input registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_input_areset) begin
            glay_start_reg <= 0;
        end
        else begin
            glay_start_reg <= glay_control_in.glay_start;
        end
    end

// --------------------------------------------------------------------------------------
//   Reset output registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_input_areset) begin
            glay_kernel_control_input_out.glay_ready <= 0;
            glay_descriptor_valid_out                <= 0;
        end
        else begin
            glay_kernel_control_input_out.glay_ready <= glay_ready_reg;
            glay_descriptor_valid_out                <= glay_descriptor_valid_reg;
        end
    end

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN input sync
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if(control_input_areset)
            current_state <= CTRL_IN_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            CTRL_IN_RESET : begin
                next_state = CTRL_IN_IDLE;
            end
            CTRL_IN_IDLE : begin
                if(glay_start_reg)
                    next_state = CTRL_IN_START_S1;
                else
                    next_state = CTRL_IN_IDLE;
            end
            CTRL_IN_START_S1 : begin
                next_state = CTRL_IN_READY;
            end
            CTRL_IN_READY : begin
                if(glay_start_reg)
                    next_state = CTRL_IN_START_S2;
                else
                    next_state = CTRL_IN_READY;
            end
            CTRL_IN_START_S2 : begin
                next_state = CTRL_IN_BUSY;
            end
            CTRL_IN_BUSY : begin
                next_state = CTRL_IN_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            CTRL_IN_RESET : begin
                glay_ready_reg            <= 0;
                glay_descriptor_valid_reg <= 0;
            end
            CTRL_IN_IDLE : begin
                glay_ready_reg            <= 0;
                glay_descriptor_valid_reg <= 0;
            end
            CTRL_IN_START_S1 : begin
                glay_ready_reg            <= 1;
                glay_descriptor_valid_reg <= 0;
            end
            CTRL_IN_READY : begin
                glay_ready_reg            <= 0;
                glay_descriptor_valid_reg <= 0;
            end
            CTRL_IN_START_S2 : begin
                glay_ready_reg            <= 0;
                glay_descriptor_valid_reg <= 1;
            end
            CTRL_IN_BUSY : begin
                glay_ready_reg            <= 0;
                glay_descriptor_valid_reg <= 0;
            end
        endcase
    end // always_ff @(posedge ap_clk)


endmodule : glay_kernel_control_input