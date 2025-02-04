// -----------------------------------------------------------------------------
//
//    "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_bus.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

/*
* Copyright (c) 2008-2009, Kendall Correll
*
* Permission to use, copy, modify, and distribute this software for any
* purpose with or without fee is hereby arbiter_granted, provided that the above
* copyright notice and this permission notice appear in all copies.
*
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
* WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
* ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
* WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
* ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
* OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

// 'arbiter' is a tree made from unregistered 'arbiter_node'
// modules. Unregistered carries between nodes allows
// the tree to change state on the same ap_clk. The tree
// contains (ARBITER_WIDTH - 1) nodes, so resource usage of the
// arbiter grows linearly. The number of levels and thus the
// propogation delay down the tree grows with log2(ARBITER_WIDTH).
// The logarithmic delay scaling makes this arbiter suitable
// for large configurations. This module can take up to three
// ap_clks to arbiter_grant the next arbiter_requestor after its inputs change
// (two ap_clks for the 'arbiter_node' modules and one ap_clk
// for the output registers).

`include "global_package.vh"

module arbiter_bus_N_in_1_out #(
    parameter WIDTH            = 2                    ,
    parameter ARBITER_WIDTH    = 2**$clog2(WIDTH)     ,
    parameter SELECT_WIDTH     = $clog2(ARBITER_WIDTH),
    parameter BUS_WIDTH        = 8                    ,
    parameter ARBITER_FAIRNESS = 0
) (
    input  logic                     ap_clk                            ,
    input  logic                     areset                            ,
    input  logic [ARBITER_WIDTH-1:0] arbiter_req                       ,
    input  logic [ARBITER_WIDTH-1:0] arbiter_bus_valid                 ,
    input  logic [    BUS_WIDTH-1:0] arbiter_bus_in [ARBITER_WIDTH-1:0],
    output logic [ARBITER_WIDTH-1:0] arbiter_grant                     ,
    output logic                     arbiter_bus_out_valid             ,
    output logic [    BUS_WIDTH-1:0] arbiter_bus_out
);

integer i;
// --------------------------------------------------------------------------------------
logic                     areset_arbiter                          ;
logic [ARBITER_WIDTH-1:0] arbiter_grant_reg                       ;
logic [ARBITER_WIDTH-1:0] arbiter_bus_valid_reg                   ;
logic [    BUS_WIDTH-1:0] arbiter_bus_reg      [ARBITER_WIDTH-1:0];
logic [    BUS_WIDTH-1:0] arbiter_bus_out_int                     ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_arbiter <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_arbiter) begin
        arbiter_bus_valid_reg <= 0;
    end
    else begin
        arbiter_bus_valid_reg <= arbiter_bus_valid;
    end
end

always_ff @(posedge ap_clk) begin
    arbiter_bus_reg <= arbiter_bus_in;
end

// --------------------------------------------------------------------------------------
// Drive output bus
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_arbiter) begin
        arbiter_grant         <= 0;
        arbiter_bus_out_valid <= 1'b0;
    end else begin
        arbiter_grant         <= arbiter_grant_reg;
        arbiter_bus_out_valid <= |arbiter_bus_valid_reg;
    end
end

always_comb begin
    arbiter_bus_out_int = 0;
    for ( i = 0; i < ARBITER_WIDTH; i++) begin
        if(arbiter_bus_valid_reg[i]) arbiter_bus_out_int =  arbiter_bus_reg[i];
    end
end

always_ff @(posedge ap_clk) begin
    arbiter_bus_out <= arbiter_bus_out_int;
end

generate
    case (ARBITER_FAIRNESS)
        0       : begin
// --------------------------------------------------------------------------------------
// RR Arbiter instance output
// --------------------------------------------------------------------------------------
            if(ARBITER_WIDTH < 2) begin
                always_ff @ (posedge ap_clk) begin
                    if (areset_arbiter) begin
                        arbiter_grant_reg <= 0;
                    end
                    else begin
                        arbiter_grant_reg <= arbiter_req;
                    end
                end
            end else
            begin
                arbiter_round_robin #(
                    .WIDTH        (WIDTH        ),
                    .ARBITER_WIDTH(ARBITER_WIDTH)
                ) inst_arbiter_round_robin (
                    .areset(areset_arbiter      ),
                    .ap_clk(ap_clk              ),
                    .req   (arbiter_req         ),
                    .grant (arbiter_grant_reg)
                );
            end
        end
        default : begin
// --------------------------------------------------------------------------------------
// RR Arbiter instance output
// --------------------------------------------------------------------------------------
            if(ARBITER_WIDTH < 2) begin
                always_ff @ (posedge ap_clk) begin
                    if (areset_arbiter) begin
                        arbiter_grant_reg <= 0;
                    end
                    else begin
                        arbiter_grant_reg <= arbiter_req;
                    end
                end
            end else
            begin
                arbiter_round_robin #(
                    .WIDTH        (WIDTH        ),
                    .ARBITER_WIDTH(ARBITER_WIDTH)
                ) inst_arbiter_round_robin (
                    .areset(areset_arbiter      ),
                    .ap_clk(ap_clk              ),
                    .req   (arbiter_req         ),
                    .grant (arbiter_grant_reg)
                );
            end
        end
    endcase
endgenerate

endmodule : arbiter_bus_N_in_1_out
