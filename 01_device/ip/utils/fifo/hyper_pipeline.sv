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
    parameter STAGES = 1 ,
    parameter WIDTH  = 32
) (
    input  logic             ap_clk,
    input  logic             areset,
    input  logic [WIDTH-1:0] din   ,
    output logic [WIDTH-1:0] dout
);

    generate
        if(STAGES > 0) begin
            logic [WIDTH-1:0] d[STAGES-1:0];

            always_ff @(posedge ap_clk) begin
                if (areset) begin
                    for (int i = 0; i < STAGES; i++) begin
                        d[i] <= 0;
                    end
                end else begin
                    d[0] <= din;
                    for (int i = 1; i < STAGES; i++) begin
                        d[i] <= d[i-1];
                    end
                end
            end
            assign dout = d[STAGES-1];
        end else begin
            assign dout = din;
        end
    endgenerate

endmodule : hyper_pipeline