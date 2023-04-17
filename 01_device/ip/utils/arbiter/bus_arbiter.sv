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
// contains (WIDTH - 1) nodes, so resource usage of the
// arbiter grows linearly. The number of levels and thus the
// propogation delay down the tree grows with log2(WIDTH).
// The logarithmic delay scaling makes this arbiter suitable
// for large configurations. This module can take up to three
// ap_clks to arbiter_grant the next arbiter_requestor after its inputs change
// (two ap_clks for the 'arbiter_node' modules and one ap_clk
// for the output registers).

`timescale 1ns / 1ps
import FUNCTIONS_PKG::*;

module bus_arbiter_N_in_1_out #(
    parameter WIDTH        = 2            ,
    parameter SELECT_WIDTH = $clog2(WIDTH),
    parameter BUS_WIDTH    = 8            ,
    parameter BUS_NUM      = 2
) (
    input  logic                 ap_clk                      ,
    input  logic                 areset                      ,
    input  logic                 arbiter_enable              ,
    input  logic [    WIDTH-1:0] arbiter_req                 ,
    input  logic [BUS_WIDTH-1:0] arbiter_bus_in [0:BUS_NUM-1],
    output logic [    WIDTH-1:0] arbiter_grant               ,
    output logic [BUS_WIDTH-1:0] arbiter_bus_out
);

    logic                      arbiter_areset                 ;
    logic   [SELECT_WIDTH-1:0] select                         ;
    logic                      valid                          ;
    logic                      arbiter_enable_reg             ;
    logic   [       WIDTH-1:0] arbiter_grant_reg              ;
    logic   [   BUS_WIDTH-1:0] arbiter_bus_reg   [0:BUS_NUM-1];
    integer                    i                              ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        arbiter_areset <= areset;
    end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (arbiter_areset) begin
            arbiter_enable_reg <= 0;
        end
        else begin
            arbiter_enable_reg <= arbiter_enable;
        end
    end

    always_ff @(posedge ap_clk) begin
        arbiter_bus_reg <= arbiter_bus_in;
    end

// --------------------------------------------------------------------------------------
// Drive output bus
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if (arbiter_areset) begin
            arbiter_bus_out <= 0;
            arbiter_grant   <= 0;
        end else begin
            if (arbiter_enable_reg) begin
                for ( i = 0; i < BUS_NUM; i++) begin
                    if (arbiter_grant_reg[i]) begin
                        arbiter_bus_out <= arbiter_bus_reg[i];
                    end
                    arbiter_grant <= arbiter_grant_reg;
                end
                if (~(|arbiter_grant_reg)) begin
                    arbiter_bus_out <= 0;
                end
            end
        end
    end

// --------------------------------------------------------------------------------------
// Arbiter instance output
// --------------------------------------------------------------------------------------
    arbiter #(
        .WIDTH       (WIDTH       ),
        .SELECT_WIDTH(SELECT_WIDTH)
    ) inst_arbiter (
        .enable(arbiter_enable_reg),
        .req   (arbiter_req       ),
        .grant  (arbiter_grant_reg ),
        .select(select            ),
        .valid (valid             ),
        .ap_clk(ap_clk            ),
        .areset(arbiter_areset    )
    );

endmodule : bus_arbiter_N_in_1_out
