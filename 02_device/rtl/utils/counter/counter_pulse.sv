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
    input  logic                  ap_clk   , // Clock input for synchronous logic
    input  logic                  areset   , // Active-low asynchronous reset
    input  logic                  valid_in , // Valid signal indicating when the input should be processed
    input  logic [MASK_WIDTH-1:0] mask_in  , // Input vector of size N
    output logic                  pulse_out  // Single valid_in bit asserted for 'count' number of cycles
);

// Derived parameter for counter size
    localparam int COUNTER_WIDTH = $clog2(MASK_WIDTH) + 1;

    logic [COUNTER_WIDTH-1:0] count        ; // To hold the count of '1's mask_in 'mask_in'
    logic [COUNTER_WIDTH-1:0] pulse_counter; // Counter for the output pulse

    always_comb begin
        foreach (mask_in[i]) count += mask_in[i]; // Accumulate count of '1's
    end

    always_comb pulse_out = (pulse_counter > 0) ? 1'b1 : 1'b0;

    always_ff @(posedge ap_clk) begin
        if(valid_in) begin
            pulse_counter <= count;
        end else if (pulse_counter > 0) begin
            pulse_counter <= pulse_counter - 1;
        end
    end

endmodule : counter_pulse
