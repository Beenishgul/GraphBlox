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
    input  logic                                    ap_clk          ,
    input  logic                                    areset          ,
    input  logic [NUM_GRAPH_CLUSTERS-1:0]           glay_cu_done_in ,
    input  GlayControlChainIterfaceInput            glay_control_in ,
    output GlayControlChainInputSyncInterfaceOutput glay_control_out
);

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN output sync
// --------------------------------------------------------------------------------------

    always_ff @(posedge clock or negedge rstn) begin
        if(~rstn)
            current_state <= SEND_MATRIX_C_RESET;
        else begin
            if(enabled) begin
                current_state <= next_state;
            end
        end
    end // always_ff @(posedge clock)

    always_comb begin
        next_state = current_state;
        case (current_state)
            SEND_MATRIX_C_RESET : begin
                if(wed_request_in_latched.valid && enabled_cmd)
                    next_state = SEND_MATRIX_C_INIT;
                else
                    next_state = SEND_MATRIX_C_RESET;
            end
            SEND_MATRIX_C_INIT : begin
                next_state = SEND_MATRIX_C_IDLE;
            end
            SEND_MATRIX_C_IDLE : begin
                if(send_request_ready)
                    next_state = START_MATRIX_C_REQ;
                else
                    next_state = SEND_MATRIX_C_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge clock) begin
        case (current_state)
            SEND_MATRIX_C_RESET : begin
                read_command_matrix_C_job_latched.valid <= 0;
                generate_read_command                   <= 0;
                setup_read_command                      <= 0;
                clear_data_ready                        <= 1;
                shift_limit_clear                       <= 1;
                start_shift_hf_0                        <= 0;
                start_shift_hf_1                        <= 0;
                switch_shift_hf                         <= 0;
                shift_counter                           <= 0;
            end
            SEND_MATRIX_C_INIT : begin
                read_command_matrix_C_job_latched.valid <= 0;
                clear_data_ready                        <= 0;
                shift_limit_clear                       <= 0;
                setup_read_command                      <= 1;
            end
            SEND_MATRIX_C_IDLE : begin
                read_command_matrix_C_job_latched.valid <= 0;
                setup_read_command                      <= 0;
                shift_limit_clear                       <= 0;
                shift_counter                           <= 0;
            end
        endcase
    end // always_ff @(posedge clock)


endmodule : glay_kernel_control_input