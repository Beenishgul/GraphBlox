
`timescale 1ns/1ps

module tb_iob_cache_axi (); /* this is automatically generated */

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

	parameter             FE_ADDR_W = 64;
	parameter             FE_DATA_W = 64;
	parameter                N_WAYS = 2;
	parameter            LINE_OFF_W = 7;
	parameter            WORD_OFF_W = 3;
	parameter         WTBUF_DEPTH_W = 5;
	parameter            REP_POLICY = `PLRU_tree;
	parameter                NWAY_W = $clog2(N_WAYS);
	parameter             FE_NBYTES = FE_DATA_W/8;
	parameter             FE_BYTE_W = $clog2(FE_NBYTES);
	parameter             BE_ADDR_W = FE_ADDR_W;
	parameter             BE_DATA_W = FE_DATA_W;
	parameter             BE_NBYTES = BE_DATA_W/8;
	parameter             BE_BYTE_W = $clog2(BE_NBYTES);
	parameter            LINE2MEM_W = WORD_OFF_W-$clog2(BE_DATA_W/FE_DATA_W);
	parameter             WRITE_POL = `WRITE_THROUGH;
	parameter            AXI_ADDR_W = BE_ADDR_W;
	parameter            AXI_DATA_W = BE_DATA_W;
	parameter              AXI_ID_W = 1;
	parameter             AXI_LEN_W = 8;
	parameter [AXI_ID_W-1:0] AXI_ID = 0;
	parameter            CTRL_CACHE = 0;
	parameter              CTRL_CNT = 1;

	logic                                       valid;
	logic [CTRL_CACHE + FE_ADDR_W -1:FE_BYTE_W] addr;
	logic         [CTRL_CACHE + FE_ADDR_W -1:0] addr;
	logic                       [FE_DATA_W-1:0] wdata;
	logic                       [FE_NBYTES-1:0] wstrb;
	logic                       [FE_DATA_W-1:0] rdata;
	logic                                       ready;
	logic                                       force_inv_in;
	logic                                       force_inv_out;
	logic                                       wtb_empty_in;
	logic                                       wtb_empty_out;
	logic                                       reset;

	iob_cache_axi #(
			.FE_ADDR_W(FE_ADDR_W),
			.FE_DATA_W(FE_DATA_W),
			.N_WAYS(N_WAYS),
			.LINE_OFF_W(LINE_OFF_W),
			.WORD_OFF_W(WORD_OFF_W),
			.WTBUF_DEPTH_W(WTBUF_DEPTH_W),
			.REP_POLICY(REP_POLICY),
			.NWAY_W(NWAY_W),
			.FE_NBYTES(FE_NBYTES),
			.FE_BYTE_W(FE_BYTE_W),
			.BE_ADDR_W(BE_ADDR_W),
			.BE_DATA_W(BE_DATA_W),
			.BE_NBYTES(BE_NBYTES),
			.BE_BYTE_W(BE_BYTE_W),
			.LINE2MEM_W(LINE2MEM_W),
			.WRITE_POL(WRITE_POL),
			.AXI_ADDR_W(AXI_ADDR_W),
			.AXI_DATA_W(AXI_DATA_W),
			.AXI_ID_W(AXI_ID_W),
			.AXI_LEN_W(AXI_LEN_W),
			.AXI_ID(AXI_ID),
			.CTRL_CACHE(CTRL_CACHE),
			.CTRL_CNT(CTRL_CNT)
		) inst_iob_cache_axi (
			.valid         (valid),
			.addr          (addr),
			.addr          (addr),
			.wdata         (wdata),
			.wstrb         (wstrb),
			.rdata         (rdata),
			.ready         (ready),
			.force_inv_in  (force_inv_in),
			.force_inv_out (force_inv_out),
			.wtb_empty_in  (wtb_empty_in),
			.wtb_empty_out (wtb_empty_out),
			.clk           (clk),
			.reset         (reset)
		);

	task init();
		valid        <= '0;
		addr         <= '0;
		addr         <= '0;
		wdata        <= '0;
		wstrb        <= '0;
		force_inv_in <= '0;
		wtb_empty_in <= '0;
		reset        <= '0;
	endtask

	task drive(int iter);
		for(int it = 0; it < iter; it++) begin
			valid        <= '0;
			addr         <= '0;
			addr         <= '0;
			wdata        <= '0;
			wstrb        <= '0;
			force_inv_in <= '0;
			wtb_empty_in <= '0;
			reset        <= '0;
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
			$fsdbDumpfile("tb_iob_cache_axi.fsdb");
			$fsdbDumpvars(0, "tb_iob_cache_axi", "+mda", "+functions");
		end
	end

endmodule
