// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_node.sv
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

// This is a two input round-robin arbiter with the
// addition of the 'valid' and 'enable' signals
// that allow multiple nodes to be connected to form a
// larger arbiter. Outputs are not registered to allow
// interconnected nodes to change state on the same ap_clk.

`timescale 1ns / 1ps
import GLAY_FUNCTIONS_PKG::*;

module arbiter_node (
	input  logic       enable,
	input  logic [1:0] req   ,
	output logic [1:0] grant ,
	output logic       select,
	output logic       valid ,
	input  logic       ap_clk,
	input  logic       areset
);

// The state determines which 'req' is granted. State '0'
// grants 'req[0]', state '1' grants 'req[1]'.
	logic grant_state;
	logic next_state ;

// The 'grant' of this stage is masked by 'enable', which
// carries the grants of the subsequent stages back to this
// stage. The 'grant' is also masked by 'req' to ensure that
// 'grant' is dropped as soon 'req' goes away.
	assign grant[0] = req[0] & ~grant_state & enable;
	assign grant[1] = req[1] & grant_state & enable;

// Select is a binary value that tracks grant. It could
// be used to control a mux on the arbitrated resource.
	assign select = grant_state;

// The 'valid' carries reqs to subsequent stages. It is
// high when the 'req's are high, except during 1-to-0 state
// transistions when it's dropped for a cycle to allow
// subsequent arbiter stages to make progress. This causes a
// two cycle turnaround for 1-to-0 state transistions.
/*
always @(grant_state, next_state, req)
begin
	if(grant_state & ~next_state)
	valid <= 0;
	else if(req[0] | req[1])
	valid <= 1;
	else
	valid <= 0;
end
*/
// reduced 'valid' logic
	assign valid = (req[0] & ~grant_state) | req[1];

// The 'next_state' logic implements round-robin fairness
// for two inputs. When both reqs are asserted, 'req[0]' is
// granted first. This state machine along with some output
// logic can be cascaded to implement round-robin fairness
// for many inputs.
/*
always @(grant_state, req)
begin
	case(grant_state)
	0:
	if(req[0])
	next_state <= 0;
	else if(req[1])
	next_state <= 1;
	else
	next_state <= 0;
	1:
	if(req[1])
	next_state <= 1;
	else
	next_state <= 0;
	endcase
end
*/
// reduced next state logic
	assign next_state = (req[1] & ~req[0]) | (req[1] & grant_state);

// state register
	always_ff @(posedge ap_clk)
		begin
			if(areset)
				grant_state <= 0;
			else
				grant_state <= next_state;
		end

endmodule