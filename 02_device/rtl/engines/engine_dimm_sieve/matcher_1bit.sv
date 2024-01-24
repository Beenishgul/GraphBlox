`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2023 11:28:47 PM
// Design Name: 
// Module Name: matcher_1bit
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


module matcher_1bit(
    input logic reference,
    input logic query,
    output logic match,
    input logic rsn,
    input logic match_en
    );
    
//logic l_data;

    //always@(*)
    always_latch begin
        if(rsn == 1'b0) 
            begin
            match <= 1'b1;
            end
        else begin

//the below implementation needs reset for every new batch of query 
            if(!(reference ^~ query))
            begin 
            match <= 1'b0;
            end
//          begin
//        //match <= match & (&(reference ^~ query)); //initial implementation ( match on LHS and RHS causing X propogation)
//          end
            end
    end   
endmodule
