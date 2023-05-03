// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : hyper_pipeline.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

module hyper_pipeline #(
    parameter stages = 1 ,
    parameter width  = 32
) (
    input              ap_clk,
    input              areset,
    input  [width-1:0] din   ,
    output [width-1:0] dout
);

    reg [width-1:0] d[stages-1:0];
    genvar          i            ;

    always @(posedge ap_clk) begin
        if (areset) begin
            for (i = 0; i < stages; i++) begin
                d[i] <= 0;
            end
        end else begin
            d[0] <= din;
            for (i = 1; i < stages; i++) begin
                d[i] <= d[i-1];
            end
        end
    end

    assign dout = d[stages-1];

endmodule