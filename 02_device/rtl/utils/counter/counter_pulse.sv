// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : counter_pulse.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

module counter_pulse #(parameter int MASK_WIDTH = 8 // Default parameter, can be overridden to any size
) (
    input  logic                  ap_clk          , // Clock input for synchronous logic
    input  logic                  areset          , // Active-low asynchronous reset
    input  logic [MASK_WIDTH-1:0] valid_in        , // Valid signal indicating when the input should be processed
    input  logic [MASK_WIDTH-1:0] mask_in         , // Input vector of size N
    output logic                  pulse_out       , // Single valid_in bit asserted for 'count' number of cycles
    output logic [MASK_WIDTH-1:0] param_select_out  // Single valid_in bit asserted for 'count' number of cycles
);

// Derived parameter for counter size
    localparam int COUNTER_WIDTH = $clog2(MASK_WIDTH) + 1;

    logic [COUNTER_WIDTH-1:0] count               ; // To hold the count of '1's mask_in 'mask_in'
    logic [COUNTER_WIDTH-1:0] pulse_counter_reg   ; // Counter for the output pulse
    logic [   MASK_WIDTH-1:0] param_select_out_int;

    always_comb begin
        count     = 0;
        pulse_out = 1'b0;
        for (int i = 0; i < MASK_WIDTH; i++) begin
            count += mask_in[i] & valid_in[i];
        end
        pulse_out = (pulse_counter_reg > 2) | valid_in;
    end

    always_comb begin
        param_select_out    = 0;
        param_select_out[0] = param_select_out_int[0];
        for (int i = 1; i < MASK_WIDTH; i++) begin
            param_select_out[i] = |param_select_out ? 1'b0 : param_select_out_int[i];
        end
    end

    always_comb begin
        if(|valid_in) begin
            param_select_out_int = mask_in;
        end else if (pulse_counter_reg > 1) begin
            param_select_out_int = param_select_out_int & (param_select_out_int - 1);
        end else begin
            param_select_out_int = 0;
        end
    end

    always_ff @(posedge ap_clk) begin
        if(areset)begin
            pulse_counter_reg <= 0;
        end begin
            if(|valid_in) begin
                pulse_counter_reg <= count;
            end else if (pulse_counter_reg > 1) begin
                pulse_counter_reg <= pulse_counter_reg - 1;
            end
        end
    end

endmodule : counter_pulse
