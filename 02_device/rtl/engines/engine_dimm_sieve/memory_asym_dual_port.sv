`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2023 09:30:34 AM
// Design Name: 
// Module Name: memory_dual_port
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//Asymmetric dual port
// Asymetric RAM - TDP 
// READ_FIRST MODE. 
// asym_ram_tdp_read_first.v 
//module asym_ram_tdp_read_first

module memory_asym_dual_port (clkA, clkB, enaA, weA, enaB, weB, addrA, addrB, diA, doA, diB, doB); 
//  parameter CHWIDTH = 6,
//  parameter COLWIDTH = 9,
//  parameter DEVICE_WIDTH = 16,
//  parameter RAM_WIDTH = DEVICE_WIDTH*2**COLWIDTH, //8192
//  parameter RAM_DEPTH = 2**CHWIDTH, //64, 
parameter INIT_FILE = "";     // Specify name/location of RAM initialization file if using one (leave blank if not)
parameter WIDTHB = 512; 
parameter SIZEB = 1024; 
parameter ADDRWIDTHB = 10; 
parameter WIDTHA = 16; 
parameter SIZEA = 32768; 
parameter ADDRWIDTHA = 15; 
input clkA; 
input clkB; 
input weA, weB; 
input enaA, enaB; 
input [ADDRWIDTHA-1:0] addrA; 
input [ADDRWIDTHB-1:0] addrB; 
input [WIDTHA-1:0] diA;
input [WIDTHB-1:0] diB; 
output [WIDTHA-1:0] doA; 
output [WIDTHB-1:0] doB; 

`define max(a,b) {(a) > (b) ? (a) : (b)} 
`define min(a,b) {(a) < (b) ? (a) : (b)} 

function integer log2; 
    input integer value; 
    reg [31:0] shifted; 
    integer res; 
    begin 
    if (value < 2) log2 = value; 
    else 
        begin 
        shifted = value-1; 
        for (res=0; shifted>0; res=res+1)  
            shifted = shifted>>1; 
        log2 = res; 
        end 
    end 
endfunction  

localparam maxSIZE = `max(SIZEA, SIZEB); 
localparam maxWIDTH = `max(WIDTHA, WIDTHB); 
localparam minWIDTH = `min(WIDTHA, WIDTHB); 
localparam RATIO = maxWIDTH / minWIDTH; 
localparam log2RATIO = log2(RATIO); 
reg [minWIDTH-1:0] RAM [maxSIZE-1:0]; 
reg [WIDTHA-1:0] readA; 
reg [WIDTHB-1:0] readB; 


// The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemb(INIT_FILE, RAM, 0, maxSIZE-1);
    end else begin: init_bram_to_zero
      integer ram_index;
        initial
        for (ram_index = 0; ram_index < maxSIZE; ram_index = ram_index + 1)
          RAM[ram_index] = {minWIDTH{1'b0}}; //{RAM_WIDTH{$urandom}}; 
    end
   endgenerate
   
always @(posedge clkA) 
begin 
    if (enaA) 
    begin 
    readA <= RAM[addrA] ; 
    if (weA) 
        RAM[addrA] <= diA; 
    end 
end 

always @(posedge clkB) 
begin : portB
    integer i; 
    reg [log2RATIO-1:0] lsbaddr ; 
    for (i=0; i< RATIO; i= i+ 1)
        begin
        lsbaddr = i; 
        if (enaB) 
            begin 
            readB[(i+1)*minWIDTH -1 -: minWIDTH] <= RAM[{addrB, lsbaddr}]; 
            if (weB) 
                RAM[{addrB, lsbaddr}] <= diB[(i+1)*minWIDTH-1 -: minWIDTH]; 
            end 
        end 
end 

assign doA = readA; 
assign doB = readB; 

endmodule


//module memory_dual_port #(
//  parameter CHWIDTH = 6,
//  parameter COLWIDTH = 9,
//  parameter DEVICE_WIDTH = 16,
//  parameter RAM_WIDTH = DEVICE_WIDTH*2**COLWIDTH, //8192
//  parameter RAM_DEPTH = 2**CHWIDTH, //64,
//  parameter RAM_PERFORMANCE = "LOW_LATENCY",      // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
//  parameter INIT_FILE = "/home/vyn9mp/Model_Sieve/scripts/sieve_data_01.txt"                       // Specify name/location of RAM initialization file if using one (leave blank if not)
//) (
//  input logic [clogb2((RAM_DEPTH-1)*(2**COLWIDTH-1))-1:0] addra,  // Port A address bus, width determined from RAM_DEPTH //todo: normal row/column addressing
//  input logic [clogb2(RAM_DEPTH-1)-1:0] addrb,  // Port B address bus, width determined from RAM_DEPTH
//  input logic [DEVICE_WIDTH-1:0] dina,           // Port A RAM input data
//  input logic [RAM_WIDTH-1:0] dinb,           // Port B RAM input data
//  input logic clka,                           // Port A clock
//  input logic clkb,                           // Port B clock
//  input logic wea,                            // Port A write enable
//  input logic web,                            // Port B write enable
//  input logic ena,                            // Port A RAM Enable, for additional power savings, disable port when not in use
//  input logic enb,                            // Port B RAM Enable, for additional power savings, disable port when not in use
//  input logic rsta,                           // Port A output reset (does not affect memory contents)
//  input logic rstb,                           // Port B output reset (does not affect memory contents)
//  input logic regcea,                         // Port A output register enable
//  input logic regceb,                         // Port B output register enable
//  output logic [DEVICE_WIDTH-1:0] douta,         // Port A RAM output data
//  output logic [RAM_WIDTH-1:0] doutb          // Port B RAM output data
//);
//  logic [CHWIDTH-1:0] rowa;
//  logic [COLWIDTH-1:0] cola;
//  assign rowa = addra[CHWIDTH+COLWIDTH-1:COLWIDTH];
//  assign cola = addra[COLWIDTH-1:0];
//  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
//  reg [DEVICE_WIDTH-1:0] ram_data_a = {DEVICE_WIDTH{1'b0}};
//  reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};
//
//  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
//  generate
//    if (INIT_FILE != "") begin: use_init_file
//      initial
//        $readmemb(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
//    end else begin: init_bram_to_zero
//      integer ram_index;
//        initial
//        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
//          BRAM[ram_index] = {RAM_WIDTH{1'b0}}; //{RAM_WIDTH{$urandom}}; //RAM_WIDTH(1'b0}}
//    end
//  endgenerate
// 
// 
//  always @(posedge clka)
//    if (ena)
//      if (wea)
//        //BRAM[addra[clogb2((RAM_DEPTH-1)*(2**COLWIDTH-1))-1:clogb2((RAM_DEPTH-1)*(2**COLWIDTH-1))-1-(clogb2(RAM_DEPTH-1)-1)]][clogb2((RAM_DEPTH-1)*(2**COLWIDTH-1))-1-(clogb2(RAM_DEPTH-1)-1:(clogb2((RAM_DEPTH-1)*(2**COLWIDTH-1))-1-(clogb2(RAM_DEPTH-1)-1)-DEVICE_WIDTH] <= dina;
//          BRAM[rowa][(cola+1)*DEVICE_WIDTH -: DEVICE_WIDTH] <= dina; 
//      else
//        ram_data_a <= BRAM[rowa][((cola+1)*DEVICE_WIDTH-1) -: DEVICE_WIDTH]; //todo: how to concate column address, what if this is a register instead of a cell in the array?
//
//  always @(posedge clkb)
//    if (enb)
//      if (web)
//        BRAM[addrb] <= dinb;
//      else
//        ram_data_b <= BRAM[addrb];
//
//  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
//  generate
//    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register
//
//      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
//       assign douta = ram_data_a;
//       assign doutb = ram_data_b;
//
//    end else begin: output_register
//
//      // The following is a 2 clock cycle read latency with improve clock-to-out timing
//
//      //reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};
//      reg [DEVICE_WIDTH-1:0] douta_reg = {DEVICE_WIDTH{1'b0}};
//      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};
//
//      always @(posedge clka)
//        if (rsta)
//          //douta_reg <= {RAM_WIDTH{1'b0}};
//          douta_reg <= {DEVICE_WIDTH{1'b0}};
//        else if (regcea)
//          douta_reg <= ram_data_a;
//
//      always @(posedge clkb)
//        if (rstb)
//          doutb_reg <= {RAM_WIDTH{1'b0}};
//        else if (regceb)
//          doutb_reg <= ram_data_b;
//
//      assign douta = douta_reg;
//      assign doutb = doutb_reg;
//
//    end
//  endgenerate
//
//  //  The following function calculates the address width based on specified RAM depth
//  function integer clogb2;
//    input integer depth;
//      for (clogb2=0; depth>0; clogb2=clogb2+1)
//        depth = depth >> 1;
//  endfunction
//
//endmodule

