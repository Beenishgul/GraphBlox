
`timescale 1ns/1ps

module tb_glay_kernel_example_counter (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(0.5) clk = ~clk;
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk);
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	parameter        integer C_WIDTH = 4;
	parameter   [C_WIDTH-1:0] C_INIT = {C_WIDTH{1'b0}};
	localparam [C_WIDTH-1:0] LP_ZERO = {C_WIDTH{1'b0}};
	localparam  [C_WIDTH-1:0] LP_ONE = {{C_WIDTH-1{1'b0}};
	localparam  [C_WIDTH-1:0] LP_MAX = {C_WIDTH{1'b1}};

	logic               clken;
	logic               rst;
	logic               load;
	logic               incr;
	logic               decr;
	logic [C_WIDTH-1:0] load_value;
	logic [C_WIDTH-1:0] count;
	logic               is_zero;

	glay_kernel_example_counter #(
			.C_WIDTH(C_WIDTH),
			.C_INIT(C_INIT)
		) inst_glay_kernel_example_counter (
			.clk        (clk),
			.clken      (clken),
			.rst        (rst),
			.load       (load),
			.incr       (incr),
			.decr       (decr),
			.load_value (load_value),
			.count      (count),
			.is_zero    (is_zero)
		);

	task init();
		clken      <= '0;
		rst        <= '0;
		load       <= '0;
		incr       <= '0;
		decr       <= '0;
		load_value <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			clken      <= '0;
			rst        <= '0;
			load       <= '0;
			incr       <= '0;
			decr       <= '0;
			load_value <= '0;
			@(posedge clk);
		end
	endtask

	initial begin
		// do something

		init();
		repeat(10)@(posedge clk);

		drive(20);

		repeat(10)@(posedge clk);
		$finish;
	end

	// dump wave
	initial begin
		$display("random seed : %0d", $unsigned($get_initial_random_seed()));
		if ( $test$plusargs("fsdb") ) begin
			$fsdbDumpfile("tb_glay_kernel_example_counter.fsdb");
			$fsdbDumpvars(0, "tb_glay_kernel_example_counter", "+mda", "+functions");
		end
	end

endmodule
