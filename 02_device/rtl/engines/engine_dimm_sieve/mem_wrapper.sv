`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2023 03:50:21 PM
// Design Name: 
// Module Name: mem_wrapper
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


module mem_wrapper #(
  parameter CHWIDTH = 10,
  parameter COLWIDTH = 7,
  parameter DEVICE_WIDTH = 16,
  parameter RAM_WIDTH = DEVICE_WIDTH*2**COLWIDTH, //2048
  parameter RAM_DEPTH = 2**CHWIDTH,
  parameter int T_INIT_FILE[4] = {"/home/vyn9mp/Model_Sieve/scripts/split_data/sieve_data_ram_0.txt",
                            "/home/vyn9mp/Model_Sieve/scripts/split_data/sieve_data_ram_1.txt",
                            "/home/vyn9mp/Model_Sieve/scripts/split_data/sieve_data_ram_2.txt",
                            "/home/vyn9mp/Model_Sieve/scripts/split_data/sieve_data_ram_3.txt"}
) (
  input logic [CHWIDTH+COLWIDTH-1:0] addra,  // Port A address bus, width determined from RAM_DEPTH //todo: normal row/column addressing
  input logic [CHWIDTH-1:0] addrb,            // Port B address bus, width determined from RAM_DEPTH
  input logic [DEVICE_WIDTH-1:0] dina,        // Port A RAM input data
  input logic [RAM_WIDTH-1:0] dinb,        // Port B RAM input data
  input logic clka,                          // Port A clock
  input logic clkb,                           // Port B clock
  input logic host_write,                            // Port A write enable
  input logic sieve_write,                            // Port B write enable
  input logic host_en,                            // Port A RAM Enable, for additional power savings, disable port when not in use
  input logic sieve_en,                            // Port B RAM Enable, for additional power savings, disable port when not in use
  //input logic rsta,                           // Port A output reset (does not affect memory contents)
  //input logic rstb,  
  output logic [DEVICE_WIDTH-1:0] douta,         // Port A RAM output data
  output logic [RAM_WIDTH-1:0] doutb  
  //output logic douta_and,
  //output logic doutb_and
);

reg [3:0] ram_inst_en;
reg [15:0] douta_reg[3:0];

//reg [RAM_WIDTH-1:0] dinb;
//reg [DEVICE_WIDTH-1:0] douta;
//reg [RAM_WIDTH-1:0] doutb;

//assign dinb = 0;
//assign douta_and = &douta;
//assign doutb_and = &doutb;

always@(*) begin
    case(addra[1:0])
    4'h0: begin ram_inst_en = 4'h1; douta = douta_reg[0]; end
    4'h1: begin ram_inst_en = 4'h2; douta = douta_reg[1]; end
    4'h2: begin ram_inst_en = 4'h4; douta = douta_reg[2]; end
    4'h3: begin ram_inst_en = 4'h8; douta = douta_reg[3]; end
    //4'h4: begin ram_inst_en = 16'h0010; douta = douta_reg[4]; end
    //4'h5: begin ram_inst_en = 16'h0020; douta = douta_reg[5]; end
    //4'h6: begin ram_inst_en = 16'h0040; douta = douta_reg[6]; end
    //4'h7: begin ram_inst_en = 16'h0080; douta = douta_reg[7]; end
    //4'h8: begin ram_inst_en = 16'h0100; douta = douta_reg[8]; end
    //4'h9: begin ram_inst_en = 16'h0200; douta = douta_reg[9]; end
    //4'hA: begin ram_inst_en = 16'h0400; douta = douta_reg[10]; end
    //4'hB: begin ram_inst_en = 16'h0800; douta = douta_reg[11]; end
    //4'hC: begin ram_inst_en = 16'h1000; douta = douta_reg[12]; end
    //4'hD: begin ram_inst_en = 16'h2000; douta = douta_reg[13]; end
    //4'hE: begin ram_inst_en = 16'h4000; douta = douta_reg[14]; end
    //4'hF: begin ram_inst_en = 16'h8000; douta = douta_reg[15]; end
    default: begin ram_inst_en = 4'h0; douta = 16'hZZZZ; end
    endcase
end
genvar i;
generate for (i = 0; i < 4; i = i+1) 
begin
memory_asym_dual_port #(.INIT_FILE($sformatf("/home/vyn9mp/Model_Sieve/scripts/split_data/sieve_data_ram_%0d.txt",i))) mem (
//memory_asym_dual_port mem (
                     .addrA(addra[14:0]),
                     .addrB(addrb),
                     .diA(dina),
                     .diB(dinb[(512*(i+1)-1) -: 512]),
                     .clkA(clka),
                     .clkB(clkb),
                     .weA(host_write & ram_inst_en[i]),
                     .weB(sieve_write),
                     .enaA(host_en),
                     .enaB(sieve_en),
                     //.rsta(rsta),
                     //.rstb(rstb),
                     //.regcea(regcea),
                     //.regceb(regceb),
                     //.rst(rsn),
                     .doA(douta_reg[i]),
                     .doB(doutb[(512*(i+1)-1) -: 512])
                     );

end 
endgenerate    
  
endmodule
