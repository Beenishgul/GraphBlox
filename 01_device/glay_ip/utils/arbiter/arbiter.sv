// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter.sv
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

module arbiter #(
	parameter WIDTH        = 2,
	parameter SELECT_WIDTH = $clog2(WIDTH)
) (
	input  logic                    enable,
	input  logic [       WIDTH-1:0] req   ,
	output logic [       WIDTH-1:0] grant ,
	output logic [SELECT_WIDTH-1:0] select,
	output logic                    valid ,
	input  logic                    ap_clk,
	input  logic                    areset
);

	genvar g;

// These logics interconnect arbiter nodes.
	logic [2*WIDTH-2:0] interconnect_req   ;
	logic [2*WIDTH-2:0] interconnect_grant ;
	logic [  WIDTH-2:0] interconnect_select;
	logic [mux_sum(WIDTH,$clog2(WIDTH))-1:0] interconnect_mux   ;

// Assign inputs to some interconnects.
	assign interconnect_req[2*WIDTH-2-:WIDTH] = req;
	assign interconnect_grant[0]              = enable;

// Assign the select outputs of the first arbiter stage to
// the first mux stage.
	assign interconnect_mux[mux_sum(WIDTH,$clog2(WIDTH))-1-:WIDTH/2] = interconnect_select[WIDTH-2-:WIDTH/2];

// Register some interconnects as outputs.
	always_ff @(posedge ap_clk)
		begin
			if(areset)
				begin
					valid  <= 0;
					grant  <= 0;
					select <= 0;
				end
			else
				begin
					valid  <= interconnect_req[0];
					grant  <= interconnect_grant[2*WIDTH-2-:WIDTH];
					select <= interconnect_mux[$clog2(WIDTH)-1:0];
				end
		end

// Generate the stages of the arbiter tree. Each stage is
// instantiated as an array of 'abiter_node' modules and
// is half the WIDTH of the previous stage. Some simple
// arithmetic part-selects the interconnects for each stage.
// See the "Request/Grant Interconnections" diagram of an
// arbiter in the documentation.
	generate
		for(g = WIDTH; g >= 2; g = g / 2)
			begin: gen_arb
				arbiter_node nodes[(g/2)-1:0] (
					.enable(interconnect_grant[g-2-:g/2]),
					.req(interconnect_req[2*g-2-:g]),
					.grant(interconnect_grant[2*g-2-:g]),
					.select(interconnect_select[g-2-:g/2]),
					.valid(interconnect_req[g-2-:g/2]),

					.ap_clk(ap_clk),
					.areset(areset)
				);
			end
	endgenerate

// Generate the select muxes for each stage of the arbiter
// tree. The generate begins on the second stage because
// there are no muxes in the first stage. Each stage is
// a two dimensional array of muxes, where the dimensions
// are number of arbiter nodes in the stage times the
// number of preceeding stages. It takes some tricky
// arithmetic to part-select the interconnects for each
// stage. See the "Select Interconnections" diagram of an
// arbiter in the documentation.
	generate
		for(g = WIDTH/2; g >= 2; g = g / 2)
			begin: gen_mux
				mux_array #(
					.WIDTH(g/2)
				) mux_array[$clog2(WIDTH/g)-1:0] (
					.in(interconnect_mux[mux_sum(g,$clog2(WIDTH))-1-:$clog2(WIDTH/g)*g]),
					.select(interconnect_select[g-2-:g/2]),
					.out(interconnect_mux[mux_sum(g/2,$clog2(WIDTH))-(g/2)-1-:$clog2(WIDTH/g)*g/2])
				);
				assign interconnect_mux[mux_sum(g/2,$clog2(WIDTH))-1-:g/2] = interconnect_select[g-2-:g/2];
			end
	endgenerate

endmodule : arbiter
