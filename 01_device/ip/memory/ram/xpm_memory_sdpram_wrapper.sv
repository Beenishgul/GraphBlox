// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : xpm_memory_sdpram_wrapper.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`timescale 1ns/1ps

module xpm_memory_sdpram_wrapper #(
  parameter HEXFILE = "none",
  parameter DATA_W  = 8     ,
  parameter ADDR_W  = 14
) (
  input  logic              ap_clk,
  input  logic              rstb  ,
  //write port
  input  logic              w_en  ,
  input  logic [ADDR_W-1:0] w_addr,
  input  logic [DATA_W-1:0] w_data,
  //read port
  input  logic              r_en  ,
  input  logic [ADDR_W-1:0] r_addr,
  output logic [DATA_W-1:0] r_data
);

  //this allows ISE 14.7 to work; do not remove
  localparam MEMORY_SIZE       = DATA_W * (2**ADDR_W);
  localparam mem_init_file_int = HEXFILE             ;

  // xpm_memory_sdpram: Simple Dual Port RAM
// Xilinx Parameterized Macro, version 2021.2

  xpm_memory_sdpram #(
    .ADDR_WIDTH_A           (DATA_W           ), // DECIMAL
    .ADDR_WIDTH_B           (DATA_W           ), // DECIMAL
    .AUTO_SLEEP_TIME        (0                ), // DECIMAL
    .BYTE_WRITE_WIDTH_A     (DATA_W           ), // DECIMAL
    .CASCADE_HEIGHT         (0                ), // DECIMAL
    .CLOCKING_MODE          ("common_clock"   ), // String
    .ECC_MODE               ("no_ecc"         ), // String
    .MEMORY_INIT_FILE       (mem_init_file_int), // String
    .MEMORY_INIT_PARAM      ("0"              ), // String
    .MEMORY_OPTIMIZATION    ("true"           ), // String
    .MEMORY_PRIMITIVE       ("auto"           ), // String
    .MEMORY_SIZE            (MEMORY_SIZE      ), // DECIMAL
    .MESSAGE_CONTROL        (0                ), // DECIMAL
    .READ_DATA_WIDTH_B      (DATA_W           ), // DECIMAL
    .READ_LATENCY_B         (1                ), // DECIMAL
    .READ_RESET_VALUE_B     ("0"              ), // String
    .RST_MODE_A             ("SYNC"           ), // String
    .RST_MODE_B             ("SYNC"           ), // String
    .SIM_ASSERT_CHK         (0                ), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .USE_EMBEDDED_CONSTRAINT(0                ), // DECIMAL
    .USE_MEM_INIT           (1                ), // DECIMAL
    .USE_MEM_INIT_MMI       (0                ), // DECIMAL
    .WAKEUP_TIME            ("disable_sleep"  ), // String
    .WRITE_DATA_WIDTH_A     (DATA_W           ), // DECIMAL
    .WRITE_MODE_B           ("no_change"      ), // String
    .WRITE_PROTECT          (1                )  // DECIMAL
  ) xpm_memory_sdpram_inst (
    .dbiterrb      (      ), // 1-bit output: Status signal to indicate double bit error occurrence
    // on the data output of port B.
    
    .doutb         (r_data), // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
    .sbiterrb      (      ), // 1-bit output: Status signal to indicate single bit error occurrence
    // on the data output of port B.
    
    .addra         (w_addr), // ADDR_WIDTH_A-bit input: Address for port A write operations.
    .addrb         (r_addr), // ADDR_WIDTH_B-bit input: Address for port B read operations.
    .clka          (ap_clk), // 1-bit input: Clock signal for port A. Also clocks port B when
    // parameter CLOCKING_MODE is "common_clock".
    
    .clkb          (ap_clk), // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
    // "independent_clock". Unused when parameter CLOCKING_MODE is
    // "common_clock".
    
    .dina          (w_data), // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
    .ena           (w_en  ), // 1-bit input: Memory enable signal for port A. Must be high on clock
    // cycles when write operations are initiated. Pipelined internally.
    
    .enb           (r_en  ), // 1-bit input: Memory enable signal for port B. Must be high on clock
    // cycles when read operations are initiated. Pipelined internally.
    
    .injectdbiterra(1'b0  ), // 1-bit input: Controls double bit error injection on input data when
    // ECC enabled (Error injection capability is not available in
    // "decode_only" mode).
    
    .injectsbiterra(1'b0  ), // 1-bit input: Controls single bit error injection on input data when
    // ECC enabled (Error injection capability is not available in
    // "decode_only" mode).
    
    .regceb        (1'b0  ), // 1-bit input: Clock Enable for the last register stage on the output
    // data path.
    
    .rstb          (rstb  ), // 1-bit input: Reset signal for the final port B output register stage.
    // Synchronously resets output port doutb to the value specified by
    // parameter READ_RESET_VALUE_B.
    
    .sleep         (1'b0  ), // 1-bit input: sleep signal to enable the dynamic power saving feature.
    .wea           (1'b1  )  // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
    // for port A input data port dina. 1 bit wide when word-wide writes are
    // used. In byte-wide write configurations, each bit controls the
    // writing one byte of dina to address addra. For example, to
    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
    // is 32, wea would be 4'b0010.
  );

// End of xpm_memory_sdpram_inst instantiation

endmodule : xpm_memory_sdpram_wrapper