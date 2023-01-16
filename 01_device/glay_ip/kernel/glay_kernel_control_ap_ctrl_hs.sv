// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_control_ap_ctrl_hs.sv
// Create : 2022-12-20 21:55:38
// Revise : 2022-12-20 21:55:38
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_GLOBALS_PKG::*;
import GLAY_AXI4_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;

module glay_kernel_control_ap_ctrl_hs #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
    // System Signals
    input  logic                           ap_clk             ,
    input  logic                           areset             ,
    input  logic [NUM_GRAPH_CLUSTERS-1:0]  glay_cu_done_in    ,
    input  logic [NUM_GRAPH_CLUSTERS-1:0]  glay_cu_setup_in   ,
    input  GlayControlChainInterfaceInput  glay_control_in    ,
    output GlayControlChainInterfaceOutput glay_control_out   ,
    input  GLAYDescriptorInterface         glay_descriptor_in ,
    output GLAYDescriptorInterface         glay_descriptor_out
);

    logic                          glay_descriptor_valid_reg;
    logic                          control_areset           ;
    logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_done_reg         ;
    logic [NUM_GRAPH_CLUSTERS-1:0] glay_cu_setup_reg        ;

    logic glay_start_reg;
    logic glay_ready_reg;
    logic glay_idle_reg ;
    logic glay_done_reg ;

    logic glay_continue_reg;

    control_sync_state_user_managed current_state;
    control_sync_state_user_managed next_state   ;

    GlayControlChainInterfaceOutput glay_control_out_reg;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        control_areset <= areset;
    end

// --------------------------------------------------------------------------------------
//   Reset internal registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_cu_done_reg  <= 0;
            glay_cu_setup_reg <= 1;
        end
        else begin
            glay_cu_done_reg  <= glay_cu_done_in;
            glay_cu_setup_reg <= glay_cu_setup_in;
        end
    end

// --------------------------------------------------------------------------------------
//   Reset output registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_control_out.glay_ready <= 1'b0;
            glay_control_out.glay_done  <= 1'b0;
            glay_control_out.glay_idle  <= 1'b1;
        end
        else begin
            glay_control_out <= glay_control_out_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_control_out_reg.glay_ready <= 1'b0;
            glay_control_out_reg.glay_done  <= 1'b0;
            glay_control_out_reg.glay_idle  <= 1'b1;
        end
        else begin
            glay_control_out_reg.glay_ready <= glay_ready_reg;
            glay_control_out_reg.glay_done  <= glay_done_reg;
            glay_control_out_reg.glay_idle  <= glay_idle_reg;
        end
    end

// --------------------------------------------------------------------------------------
//   Reset input registers
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (control_areset) begin
            glay_start_reg    <= 0;
            glay_continue_reg <= 0;
        end
        else begin
            glay_start_reg    <= glay_control_in.glay_start;
            glay_continue_reg <= glay_control_in.glay_continue;
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
//   State Machine AP_CTRL_CHAIN sync
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if(control_areset)
            current_state <= USER_MANAGED_SYNC_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            USER_MANAGED_SYNC_RESET : begin
                next_state = USER_MANAGED_SYNC_IDLE;
            end
            USER_MANAGED_SYNC_IDLE : begin
                next_state = USER_MANAGED_SYNC_SETUP;
            end
            USER_MANAGED_SYNC_SETUP : begin
                if(glay_start_reg & ~|glay_cu_setup_reg)
                    next_state = USER_MANAGED_SYNC_READY;
                else
                    next_state = USER_MANAGED_SYNC_SETUP;
            end
            USER_MANAGED_SYNC_READY : begin
                next_state = USER_MANAGED_SYNC_START;
            end
            USER_MANAGED_SYNC_START : begin
                next_state = USER_MANAGED_SYNC_BUSY;
            end
            USER_MANAGED_SYNC_BUSY : begin
                if (&glay_cu_done_reg)
                    next_state = USER_MANAGED_SYNC_DONE;
                else
                    next_state = USER_MANAGED_SYNC_BUSY;
            end
            USER_MANAGED_SYNC_DONE : begin
                if(glay_continue_reg | glay_start_reg)
                    next_state = USER_MANAGED_SYNC_READY;
                else
                    next_state = USER_MANAGED_SYNC_DONE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            USER_MANAGED_SYNC_RESET : begin
                glay_ready_reg            <= 1'b0;
                glay_done_reg             <= 1'b0;
                glay_idle_reg             <= 1'b1;
                glay_descriptor_valid_reg <= 1'b0;
            end
            USER_MANAGED_SYNC_IDLE : begin
                glay_ready_reg            <= 1'b0;
                glay_done_reg             <= 1'b0;
                glay_idle_reg             <= 1'b1;
                glay_descriptor_valid_reg <= 1'b0;
            end
            USER_MANAGED_SYNC_SETUP : begin
                glay_ready_reg            <= 1'b0;
                glay_done_reg             <= 1'b0;
                glay_idle_reg             <= 1'b1;
                glay_descriptor_valid_reg <= 1'b0;
            end
            USER_MANAGED_SYNC_READY : begin
                glay_ready_reg            <= 1'b1;
                glay_done_reg             <= 1'b0;
                glay_idle_reg             <= 1'b0;
                glay_descriptor_valid_reg <= 1'b0;
            end
            USER_MANAGED_SYNC_START : begin
                glay_ready_reg            <= 1'b0;
                glay_done_reg             <= 1'b0;
                glay_idle_reg             <= 1'b0;
                glay_descriptor_valid_reg <= 1'b1;
            end
            USER_MANAGED_SYNC_BUSY : begin
                glay_ready_reg            <= 1'b0;
                glay_done_reg             <= 1'b0;
                glay_idle_reg             <= 1'b0;
                glay_descriptor_valid_reg <= 1'b1;
            end
            USER_MANAGED_SYNC_DONE : begin
                glay_ready_reg            <= 1'b0;
                glay_done_reg             <= 1'b1;
                glay_idle_reg             <= 1'b1;
                glay_descriptor_valid_reg <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

endmodule : glay_kernel_control_ap_ctrl_hs
