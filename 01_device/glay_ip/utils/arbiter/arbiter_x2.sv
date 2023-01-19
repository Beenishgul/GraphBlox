// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_x2.sv
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

`timescale 1ns / 1ps

// Two synchronous arbiter implementations are provided:
// 'arbiter' and 'arbiter_x2'. Both are round-robin arbiters
// with a configurable number of inputs. The algorithm used is
// recursive in that you can build a larger arbiter from a
// tree of smaller arbiters. 'arbiter_x2' is a tree of
// 'arbiter' modules, 'arbiter' is a tree of 'arbiter_node'
// modules, and 'arbiter_node' is the primitive of the
// algorithm, a two input round-robin arbiter.
//
// Both 'arbiter' and 'arbiter_x2' can take multiple ap_clks
// to grant a request. (Of course, neither arbiter should
// assert an invalid grant while changing state.) 'arbiter'
// can take up to three ap_clks to grant a req, and 'arbiter_x2'
// can take up to five ap_clks. 'arbiter_x2' is probably only
// necessary for configurations over a thousand inputs.
// Presently, the width of both 'arbiter' and 'arbiter_x2'
// must be power of two due to the way they instantiate a tree
// of sub-arbiters. Extra inputs can be assigned to zero, and
// extra outputs can be left disconnected.
//
// Parameters for 'arbiter' and 'arbiter_x2':
//   'width' is width of the 'req' and 'grant' ports, which
//     must be a power of two.
//   'select_width' is the width of the 'select' port, which
//     should be the log base two of 'width'.
//
// Ports for 'arbiter' and 'arbiter_x2':
//   'enable' masks the 'grant' outputs. It is used to chain
//     arbiters together, but it might be useful otherwise.
//     It can be left disconnected if not needed.
//   'req' are the input lines asserted to request access to
//     the arbitrated resource.
//   'grant' are the output lines asserted to grant each
//     requestor access to the arbitrated resource.
//   'select' is a binary encoding of the bitwise 'grant'
//     output. It is useful to control a mux that connects
//     requestor outputs to the arbitrated resource. It can
//     be left disconnected if not needed.
//   'valid' is asserted when any 'req' is asserted. It is
//     used to chain arbiters together, but it might be
//     otherwise useful. It can be left disconnected if not
//     needed.

// 'arbiter_x2' is a two-level tree of arbiters made from
// registered 'arbiter' modules. It allows a faster ap_clk in
// large configurations by breaking the arbiter into two
// registered stages. For most uses, the standard 'arbiter'
// module is plenty fast. See the 'demo_arbiter' module for
// some implemntation results.

import GLAY_FUNCTIONS_PKG::*;

module arbiter_x2 #(
	parameter width        = 0,
	parameter select_width = 1
) (
	input  logic                    enable,
	input  logic [       width-1:0] req   ,
	output logic [       width-1:0] grant ,
	output logic [select_width-1:0] select,
	output logic                    valid ,
	input  logic                    ap_clk,
	input  logic                    areset
);

	// 'width1' is the width of the first stage arbiters, which
// is the square root of 'width' rounded up to the nearest
// power of 2, calculated as: exp2(ceiling(log2(width)/2))
	parameter width1        = 1 << ((clog2(width)/2) + (clog2(width)%2));
	parameter select_width1 = clog2(width1)                             ;

// 'width0' is the the width of the second stage arbiter,
// which is the number of arbiters in the first stage.
	parameter width0        = width/width1 ;
	parameter select_width0 = clog2(width0);

	genvar g;

	logic [                 width-1:0] grant1                ;
	logic [(width0*select_width1)-1:0] select1               ;
	logic [                width0-1:0] enable1               ;
	logic [                width0-1:0] req0                  ;
	logic [                width0-1:0] grant0                ;
	logic [         select_width0-1:0] select0               ;
	logic                              valid0                ;
	logic [         select_width1-1:0] select_mux[width0-1:0];

	assign enable1 = grant0 & req0;

// Register the outputs.
	always @(posedge ap_clk, posedge areset)
		begin
			if(areset)
				begin
					valid  <= 0;
					grant  <= 0;
					select <= 0;
				end
			else
				begin
					valid  <= valid0;
					grant  <= grant1;
					select <= { select0, select_mux[select0] };
				end
		end

// Instantiate the first stage of the arbiter tree.
	arbiter #(
		.width(width1),
		.select_width(select_width1)
	) stage1_arbs[width0-1:0] (
		.enable(enable1),
		.req(req),
		.grant(grant1),
		.select(select1),
		.valid(req0),

		.ap_clk(ap_clk),
		.areset(areset)
	);

// Instantiate the second stage of the arbiter tree.
	arbiter #(
		.width       (width0       ),
		.select_width(select_width0)
	) stage0_arb (
		.enable(enable ),
		.req   (req0   ),
		.grant (grant0 ),
		.select(select0),
		.valid (valid0 ),
		
		.ap_clk(ap_clk ),
		.areset(areset )
	);

// Generate muxes for the select outputs.
	generate
		for(g = 0; g < width0; g = g + 1)
			begin: gen_mux
				assign select_mux[g] = select1[((g+1)*select_width1)-1-:select_width1];
			end
	endgenerate

endmodule



