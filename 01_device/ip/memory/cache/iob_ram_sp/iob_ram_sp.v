`timescale 1ns / 1ps

// module iob_ram_sp #(
//   parameter HEXFILE = "none",
//   parameter DATA_W  = 8     ,
//   parameter ADDR_W  = 14
// ) (
//   input                     ap_clk,
//   input                     en    ,
//   input                     we    ,
//   input      [(ADDR_W-1):0] addr  ,
//   output reg [(DATA_W-1):0] dout  ,
//   input      [(DATA_W-1):0] din
// );

//   //this allows ISE 14.7 to work; do not remove
//   localparam mem_init_file_int = HEXFILE;

//   // Declare the RAM
//   reg [DATA_W-1:0] ram[2**ADDR_W-1:0];

//   // Initialize the RAM
//   initial
//     if(mem_init_file_int != "none")
//       $readmemh(mem_init_file_int, ram, 0, 2**ADDR_W - 1);

//   // Operate the RAM
//   always @ (posedge ap_clk)
//     if(en)
//       if (we)
//         ram[addr] <= din;
//     else
//       dout <= ram[addr];

// endmodule

module iob_ram_sp #(
  parameter HEXFILE = "none",
  parameter DATA_W  = 8     ,
  parameter ADDR_W  = 14
) (
  input                     ap_clk,
  input                     rsta  ,
  input                     en    ,
  input                     we    ,
  input      [(ADDR_W-1):0] addr  ,
  output     [(DATA_W-1):0] dout  ,
  input      [(DATA_W-1):0] din
);

  localparam MEMORY_SIZE       = DATA_W * (2**ADDR_W);
  localparam mem_init_file_int = HEXFILE             ;

  // xpm_memory_spram: Single Port RAM
  // Xilinx Parameterized Macro, Version 2017.4
  xpm_memory_spram #(
    // Common module parameters
    .MEMORY_SIZE        (MEMORY_SIZE      ), //positive integer
    .MEMORY_PRIMITIVE   ("auto"           ), //string; "auto", "distributed", "block" or "ultra";
    .MEMORY_INIT_FILE   (mem_init_file_int), //string; "none" or "<filename>.mem"
    .MEMORY_INIT_PARAM  (""               ), //string;
    .USE_MEM_INIT       (1                ), //integer; 0,1
    .WAKEUP_TIME        ("disable_sleep"  ), //string; "disable_sleep" or "use_sleep_pin"
    .MESSAGE_CONTROL    (0                ), //integer; 0,1
    .MEMORY_OPTIMIZATION("true"           ), //string; "true", "false"
    // Port A module parameters
    .WRITE_DATA_WIDTH_A (DATA_W           ), //positive integer
    .READ_DATA_WIDTH_A  (DATA_W           ), //positive integer
    .BYTE_WRITE_WIDTH_A (DATA_W           ), //integer; 8, 9, or WRITE_DATA_WIDTH_A value
    .ADDR_WIDTH_A       (ADDR_W           ), //positive integer
    .READ_RESET_VALUE_A ("0"              ), //string
    .ECC_MODE           ("no_ecc"         ), //string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode"
    .AUTO_SLEEP_TIME    (0                ), //Do not Change
    .READ_LATENCY_A     (1                ), //non-negative integer
    .WRITE_MODE_A       ("write_first"    )  //string; "write_first", "read_first", "no_change"
  ) xpm_memory_spram_inst (
    // Common module ports
    .sleep         (1'b0  ),
    // Port A module ports
    .clka          (ap_clk),
    .rsta          (rsta  ),
    .ena           (en    ),
    .regcea        (1'b0  ),
    .wea           (we    ),
    .addra         (addr  ),
    .dina          (din   ),
    .injectsbiterra(1'b0  ),
    .injectdbiterra(1'b0  ),
    .douta         (dout  ),
    .sbiterra      (      ),
    .dbiterra      (      )
  );

endmodule




