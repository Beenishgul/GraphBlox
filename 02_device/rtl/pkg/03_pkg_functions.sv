
// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_FUNCTIONS.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
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

`include "global_timescale.vh"
package PKG_FUNCTIONS;

import PKG_MXX_AXI4_FE::*;
import PKG_MXX_AXI4_MID::*;
import PKG_MXX_AXI4_BE::*;

function integer min (
		input integer a, b
	);
	begin
		min = a < b ? a : b;
	end
endfunction

function integer max (
		input integer a, b
	);
	begin
		max = a > b ? a : b;
	end
endfunction

// compute the log base 2 of a number, rounded down to the
// nearest whole number
function integer flog2 (
		input integer number
	);
	integer i;
	integer count;
	begin
		flog2 = 0;
		for(i = 0; i < 32; i = i + 1)
			begin
				if(number&(1<<i))
					flog2 = i;
			end
	end
endfunction


// compute the log base 2 of a number, rounded up to the
// nearest whole number
function integer clog2 (
		input integer number
	);
	integer i;
	integer count;
	begin
		clog2 = 0;
		count = 0;
		for(i = 0; i < 32; i = i + 1)
			begin
				if(number&(1<<i))
					begin
						clog2 = i;
						count = count + 1;
					end
			end
		// clog2 holds the largest set bit position and count
		// holds the number of bits set. More than one bit set
		// indicates that the input was not an even power of 2,
		// so round the result up.
		if(count > 1)
			clog2 = clog2 + 1;
	end
endfunction

// compute the size of the interconnect for the arbiter's
// 'select' muxes
function integer mux_sum (
		input integer width, select_width
	);
	integer i, number;
	begin
		mux_sum = 0;
		number = 1;
		for(i = select_width; i > 0 && number <= width; i = i - 1)
			begin
				mux_sum = mux_sum + i*(number);
				number = number * 2;
			end
	end
endfunction

function logic [M00_AXI4_BE_DATA_W-1:0] swap_endianness_cacheline_backend (logic [M00_AXI4_BE_DATA_W-1:0] in);

	logic [M00_AXI4_BE_DATA_W-1:0] out;

	integer i;
	for ( i = 0; i < M00_AXI4_BE_STRB_W; i++) begin
		out[i*8 +: 8] = in[((M00_AXI4_BE_DATA_W-1)-(i*8)) -:8];
	end

	return out;
endfunction : swap_endianness_cacheline_backend

function logic [M00_AXI4_MID_DATA_W-1:0] swap_endianness_cacheline_midend (logic [M00_AXI4_MID_DATA_W-1:0] in);

	logic [M00_AXI4_MID_DATA_W-1:0] out;

	integer i;
	for ( i = 0; i < M00_AXI4_MID_STRB_W; i++) begin
		out[i*8 +: 8] = in[((M00_AXI4_MID_DATA_W-1)-(i*8)) -:8];
	end

	return out;
endfunction : swap_endianness_cacheline_midend


function logic [M00_AXI4_FE_DATA_W-1:0] swap_endianness_cacheline_frontend (logic [M00_AXI4_FE_DATA_W-1:0] in);

	logic [M00_AXI4_FE_DATA_W-1:0] out;

	integer i;
	for ( i = 0; i < M00_AXI4_FE_STRB_W; i++) begin
		out[i*8 +: 8] = in[((M00_AXI4_FE_DATA_W-1)-(i*8)) -:8];
	end

	return out;
endfunction : swap_endianness_cacheline_frontend

endpackage