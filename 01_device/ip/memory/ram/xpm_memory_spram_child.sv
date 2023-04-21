// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : xpm_memory_spram_child.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

module xpm_memory_spram_child #(
	parameter HEXFILE = "none",
	parameter DATA_W  = 8     ,
	parameter ADDR_W  = 14
) (
	input                       ap_clk,
	input                       rsta  ,
	input  logic                en    ,
	input  logic                we    ,
	input  logic [(ADDR_W-1):0] addr  ,
	output logic [(DATA_W-1):0] dout  ,
	input  logic [(DATA_W-1):0] din
);

	localparam MEMORY_SIZE       = DATA_W * (2**ADDR_W);
	localparam mem_init_file_int = HEXFILE             ;

	localparam ADDRESS_RANGE_VALUE = (2**ADDR_W)            ;
	localparam ADDRESS_RANGE_CHUNK = ADDRESS_RANGE_VALUE / 2;

	logic                en_0  ;
	logic                we_0  ;
	logic [(ADDR_W-2):0] addr_0;
	logic [(DATA_W-1):0] dout_0;
	logic [(DATA_W-1):0] din_0 ;

	logic                en_1  ;
	logic                we_1  ;
	logic [(ADDR_W-2):0] addr_1;
	logic [(DATA_W-1):0] dout_1;
	logic [(DATA_W-1):0] din_1 ;

	always_comb begin
		if(addr[ADDR_W-1]) begin
			en_1   = en;
			we_1   = we;
			addr_1 = addr[(ADDR_W-2):0];
			din_1  = din;
			en_0   = 0;
			we_0   = 0;
			addr_0 = 0;
			din_0  = 0;
			dout   = dout_1;
		end else begin
			en_1   = 0;
			we_1   = 0;
			addr_1 = 0;
			din_1  = 0;
			en_0   = en;
			we_0   = we;
			addr_0 = addr[(ADDR_W-2):0];
			din_0  = din;
			dout   = dout_0;
		end
	end

	xpm_memory_spram_wrapper #(
		.HEXFILE(HEXFILE ),
		.DATA_W (DATA_W  ),
		.ADDR_W (ADDR_W-1)
	) inst_xpm_memory_spram_wrapper_0 (
		.ap_clk(ap_clk),
		.rsta  (rsta  ),
		.en    (en_0  ),
		.we    (we_0  ),
		.addr  (addr_0),
		.dout  (dout_0),
		.din   (din_0 )
	);

	xpm_memory_spram_wrapper #(
		.HEXFILE(HEXFILE ),
		.DATA_W (DATA_W  ),
		.ADDR_W (ADDR_W-1)
	) inst_xpm_memory_spram_wrapper_1 (
		.ap_clk(ap_clk),
		.rsta  (rsta  ),
		.en    (en_1  ),
		.we    (we_1  ),
		.addr  (addr_1),
		.dout  (dout_1),
		.din   (din_1 )
	);

endmodule : xpm_memory_spram_child