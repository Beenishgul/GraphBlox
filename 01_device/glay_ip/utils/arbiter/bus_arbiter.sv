// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : bus_arbiter.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

/*
* Copyright (c) 2008-2009, Kendall Correll
*
* Permission to use, copy, modify, and distribute this software for any
* purpose with or without fee is hereby granted, provided that the above
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
// contains (WIDTH - 1) nodes, so resource usage of the
// arbiter grows linearly. The number of levels and thus the
// propogation delay down the tree grows with log2(WIDTH).
// The logarithmic delay scaling makes this arbiter suitable
// for large configurations. This module can take up to three
// ap_clks to grant the next requestor after its inputs change
// (two ap_clks for the 'arbiter_node' modules and one ap_clk
// for the output registers).

`timescale 1ns / 1ps
import GLAY_FUNCTIONS_PKG::*;

module bus_arbiter_N_in_1_out #(
    parameter WIDTH        = 2            ,
    parameter SELECT_WIDTH = $clog2(WIDTH),
    parameter BUS_WIDTH    = 8            ,
    parameter BUS_NUM      = 2
) (
    input  logic             enable                   ,
    input  logic [WIDTH-1:0] req                      ,
    input  logic [WIDTH-1:0] bus_in [0:NUM_REQUESTS-1],
    output logic [WIDTH-1:0] grant                    ,
    output logic [WIDTH-1:0] bus_out                  ,
    input  logic             ap_clk                   ,
    input  logic             areset
);

    logic [SELECT_WIDTH-1:0] select    ;
    logic                    valid     ;
    logic                    enable_reg;
    logic [       WIDTH-1:0] grant_reg ;

    arbiter #(
        .WIDTH       (WIDTH       ),
        .SELECT_WIDTH(SELECT_WIDTH)
    ) inst_arbiter (
        .enable(enable_reg),
        .req   (req       ),
        .grant (grant_reg ),
        .select(select    ),
        .valid (valid     ),
        .ap_clk(ap_clk    ),
        .areset(areset    )
    );

    always_ff @(posedge clock) begin
        if (areset) begin
            bus_out <= 0;
            grant   <= 0;
        end else begin
            if (enable_reg) begin
                for ( i = 0; i < NUM_REQUESTS; i++) begin
                    if (select[i]) begin
                        bus_out <= bus_in[i];
                    end
                    grant <= grant_reg;
                end
                if (~(|select)) begin
                    bus_out <= 0;
                end
            end
        end
    end

endmodule : bus_arbiter_N_in_1_out
