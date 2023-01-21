/*
 * Copyright (c) 2008, Kendall Correll
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
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1ns / 1ps
import GLAY_FUNCTIONS_PKG::*;

// This bench simply applies the vectors in the pattern file,
// and tests that the output matches the expected values. This
// test is usful to verify basic behavior, but it is difficult
// to generate vectors for large configurations.

`define WIDTH 8
`define SELECT_WIDTH 8
`define TURNAROUND 3
//`define TURNAROUND 6 for arbiter x2
`define TICK 10
`define HALF_TICK 5
`define TEST_VEC_COUNT 241
`define TEST_VEC_MULT 2
`define PATTERN_FILE "../vivado_glay_ip/testbench/testbench_arbiter.txt"

module glay_kernel_testbench ();

logic areset;
logic ap_clk;

logic [`WIDTH-1:0] req;
logic [`WIDTH-1:0] grant;
logic [`SELECT_WIDTH-1:0] select;
logic valid;

logic [`WIDTH-1:0] pattern[(`TEST_VEC_MULT*`TEST_VEC_COUNT)-1:0];
logic [`WIDTH-1:0] grant_expected;

integer test_i;
integer grant_i;
integer grant_count;
integer failures;
integer monitor_exceptions;

//
// UUT
//

arbiter #(
	.width(`WIDTH),
	.select_width(`SELECT_WIDTH)
) arbiter (
	.enable(1'b1),
	.req(req),
	.grant(grant),
	.select(select),
	.valid(valid),
	
	.ap_clk(ap_clk),
	.areset(areset)
);

//
// ap_clk
//

always @(ap_clk)
	#`HALF_TICK ap_clk <= !ap_clk;

//
// test monitors
//

always @(grant)
begin
	grant_count = 0;
	for(grant_i = 0; grant_i < `WIDTH; grant_i = grant_i + 1)
	begin
		if(grant[grant_i])
		begin
			grant_count = grant_count + 1;
			
			if(!req[grant_i])
			begin
				monitor_exceptions = monitor_exceptions + 1;
				
				$display("%t - EXCEPTION @%e: grant line %d with no req", $time,
					$realtime, grant_i);
			end
			
			if(select != grant_i)
			begin
				monitor_exceptions = monitor_exceptions + 1;
				
				$display("%t - EXCEPTION @%e: select of %d does not match grant of line %d", $time,
					$realtime, select, grant_i);
			end
		end
	end
	
	if(grant_count > 1)
	begin
		monitor_exceptions = monitor_exceptions + 1;
		
		$display("%t - EXCEPTION @%e: grant %h asserts multiple lines", $time,
			$realtime, grant);
	end
end

//
// test sequence
//

initial
begin
	$readmemb(`PATTERN_FILE, pattern);
	failures = 0;
	monitor_exceptions = 0;
	
	ap_clk = 1;
	req = 0;
	areset = 1;
	#`TICK @(negedge ap_clk) areset = 0;
	
	// apply reqs, and test grants against exepcted values
	for(test_i = 0; test_i < `TEST_VEC_COUNT; test_i = test_i + 1)
	begin
		#`TICK;
		
		req = pattern[test_i*`TEST_VEC_MULT];
		grant_expected = pattern[test_i*`TEST_VEC_MULT + 1];
		
		#(`TURNAROUND*`TICK);
		
		if(grant != grant_expected)
		begin
			failures = failures + 1;
			
			$display("%t - FAILED %d: req %h, grant %h (expected %h)", $time,
				test_i, req, grant, grant_expected);
		end
		else
		begin
			$display("%t - ok %d: req %h, grant %h (expected %h)", $time,
				test_i, req, grant, grant_expected);
		end
	end
	
	$display("%t - %d failures", $time, failures);
	$display("%t - %d monitor exceptions", $time, monitor_exceptions);
	
	if(failures == 0 && monitor_exceptions == 0)
		$display("%t - PASS", $time);
	else
		$display("%t - FAIL", $time);

	 #1000  $finish;
end


// Waveform dump
    `ifdef DUMP_WAVEFORM
        initial begin
            $dumpfile("glay_kernel_testbench.vcd");
            $dumpvars(0,glay_kernel_testbench);
        end
    `endif

endmodule
`default_nettype wire