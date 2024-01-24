`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2023 04:01:22 PM
// Design Name: 
// Module Name: segment
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


module segment #(parameter SEG_SIZE = 256)( 
                 input logic [SEG_SIZE-1:0]latch,
                 output logic latch_OR,
                 input logic clk,
                 input logic rsn);

//always_ff @(posedge clk) begin
//     if(rsn == 1'b0) begin
//            latch_OR <= 1'b0;
//            end
//            else begin
//                 latch_OR <= |latch;
//                // assign RS = (latch_OR)? latch : 0;
//                 end
//end


assign latch_OR = |latch;

endmodule
