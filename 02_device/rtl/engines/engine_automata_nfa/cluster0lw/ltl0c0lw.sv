




/*
******************** Summary ********************
report for ltl0c0lw
Number of nodes = 11
Number of edges = 22
Average edge per node = 0.5
Number of start nodes = 4
Number of report nodes = 4
does have all_input = False
does have special element = False
is Homogenous = True
stride value = 1
Max Fan-in = 4
Max Fan-out = 4
Max value in dim = 255
average number of intervals per STE = 1.72727272727
#######################################################
*/

 



module LUT_Match_ltl0c0lw_1 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd0) &&(input_capture[7:0] <= 8'd7) && 1'b1) ||
     ((input_capture[7:0] >= 8'd16) &&(input_capture[7:0] <= 8'd23) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_2 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd8) &&(input_capture[7:0] <= 8'd15) && 1'b1) ||
     ((input_capture[7:0] >= 8'd24) &&(input_capture[7:0] <= 8'd31) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_3 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd32) &&(input_capture[7:0] <= 8'd39) && 1'b1) ||
     ((input_capture[7:0] >= 8'd48) &&(input_capture[7:0] <= 8'd55) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_4 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd40) &&(input_capture[7:0] <= 8'd47) && 1'b1) ||
     ((input_capture[7:0] >= 8'd56) &&(input_capture[7:0] <= 8'd63) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_5 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd0) &&(input_capture[7:0] <= 8'd31) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_6 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd32) &&(input_capture[7:0] <= 8'd63) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_7 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd0) &&(input_capture[7:0] <= 8'd7) && 1'b1) ||
     ((input_capture[7:0] >= 8'd16) &&(input_capture[7:0] <= 8'd23) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_8 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd8) &&(input_capture[7:0] <= 8'd15) && 1'b1) ||
     ((input_capture[7:0] >= 8'd24) &&(input_capture[7:0] <= 8'd31) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_9 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd0) &&(input_capture[7:0] <= 8'd63) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_10 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd0) &&(input_capture[7:0] <= 8'd7) && 1'b1) ||
     ((input_capture[7:0] >= 8'd16) &&(input_capture[7:0] <= 8'd23) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule

 



module LUT_Match_ltl0c0lw_11 #(parameter integer width = 8)(
        input clk,
        input [width-1:0] symbols,
        output match);

wire match_internal;
wire [width-1:0] input_capture;
assign input_capture = symbols;
assign match = match_internal;

assign match_internal = (((input_capture[7:0] >= 8'd8) &&(input_capture[7:0] <= 8'd15) && 1'b1) ||
     ((input_capture[7:0] >= 8'd24) &&(input_capture[7:0] <= 8'd63) && 1'b1) ||
      1'b0) ? 1'b1 : 1'b0;


endmodule



module Automata_ltl0c0lw(input clk,
           input run,
           input reset,
           input [7 : 0] symbols
           
           , output ltl0c0lw_w_out_4
           , output ltl0c0lw_w_out_6
           , output ltl0c0lw_w_out_9
           , output ltl0c0lw_w_out_11);

wire all_input;

assign all_input = 1'b1;
logic start_of_data;
logic start_of_data_reg;
logic start_of_data_reg_ne;

always_ff @ (posedge clk) begin
    if (reset) begin
        start_of_data_reg <= 1;
    end
    else begin
        start_of_data_reg <= 0;
    end
end

always_ff @ (negedge clk) begin
    if (reset) begin
        start_of_data_reg_ne <= 1;
    end
    else begin
        start_of_data_reg_ne <= 0;
    end
end
assign start_of_data = start_of_data_reg & start_of_data_reg_ne & ~reset;


wire ltl0c0lw_w_out_1;
wire ltl0c0lw_lut_match_1;
wire ltl0c0lw_w_match_1;

    
    
    

LUT_Match_ltl0c0lw_1 #(8) lut_match_ltl0c0lw_1(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_1));


assign ltl0c0lw_w_match_1 = ltl0c0lw_lut_match_1 ;

STE #(.fan_in(2),.START_TYPE(1)) ltl0c0lw_ste_1 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ start_of_data, ltl0c0lw_w_out_1 }),
                .match(ltl0c0lw_w_match_1) ,
                .active_state(ltl0c0lw_w_out_1));


wire ltl0c0lw_w_out_2;
wire ltl0c0lw_lut_match_2;
wire ltl0c0lw_w_match_2;

    
    
    

LUT_Match_ltl0c0lw_2 #(8) lut_match_ltl0c0lw_2(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_2));


assign ltl0c0lw_w_match_2 = ltl0c0lw_lut_match_2 ;

STE #(.fan_in(2),.START_TYPE(1)) ltl0c0lw_ste_2 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ start_of_data, ltl0c0lw_w_out_1 }),
                .match(ltl0c0lw_w_match_2) ,
                .active_state(ltl0c0lw_w_out_2));


wire ltl0c0lw_w_out_3;
wire ltl0c0lw_lut_match_3;
wire ltl0c0lw_w_match_3;

    
    
    

LUT_Match_ltl0c0lw_3 #(8) lut_match_ltl0c0lw_3(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_3));


assign ltl0c0lw_w_match_3 = ltl0c0lw_lut_match_3 ;

STE #(.fan_in(2),.START_TYPE(1)) ltl0c0lw_ste_3 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ start_of_data, ltl0c0lw_w_out_1 }),
                .match(ltl0c0lw_w_match_3) ,
                .active_state(ltl0c0lw_w_out_3));


wire ltl0c0lw_lut_match_4;
wire ltl0c0lw_w_match_4;

    
    
    

LUT_Match_ltl0c0lw_4 #(8) lut_match_ltl0c0lw_4(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_4));


assign ltl0c0lw_w_match_4 = ltl0c0lw_lut_match_4 ;

STE #(.fan_in(2),.START_TYPE(1)) ltl0c0lw_ste_4 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ start_of_data, ltl0c0lw_w_out_1 }),
                .match(ltl0c0lw_w_match_4) ,
                .active_state(ltl0c0lw_w_out_4));


wire ltl0c0lw_w_out_5;
wire ltl0c0lw_lut_match_5;
wire ltl0c0lw_w_match_5;

    
    
    

LUT_Match_ltl0c0lw_5 #(8) lut_match_ltl0c0lw_5(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_5));


assign ltl0c0lw_w_match_5 = ltl0c0lw_lut_match_5 ;

STE #(.fan_in(2)) ltl0c0lw_ste_5 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ ltl0c0lw_w_out_2, ltl0c0lw_w_out_5 }),
                .match(ltl0c0lw_w_match_5) ,
                .active_state(ltl0c0lw_w_out_5));


wire ltl0c0lw_lut_match_6;
wire ltl0c0lw_w_match_6;

    
    
    

LUT_Match_ltl0c0lw_6 #(8) lut_match_ltl0c0lw_6(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_6));


assign ltl0c0lw_w_match_6 = ltl0c0lw_lut_match_6 ;

wire ltl0c0lw_w_out_7;

STE #(.fan_in(4)) ltl0c0lw_ste_6 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ ltl0c0lw_w_out_2, ltl0c0lw_w_out_3, ltl0c0lw_w_out_5, ltl0c0lw_w_out_7 }),
                .match(ltl0c0lw_w_match_6) ,
                .active_state(ltl0c0lw_w_out_6));



wire ltl0c0lw_lut_match_7;
wire ltl0c0lw_w_match_7;

    
    
    

LUT_Match_ltl0c0lw_7 #(8) lut_match_ltl0c0lw_7(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_7));


assign ltl0c0lw_w_match_7 = ltl0c0lw_lut_match_7 ;

STE #(.fan_in(2)) ltl0c0lw_ste_7 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ ltl0c0lw_w_out_3, ltl0c0lw_w_out_7 }),
                .match(ltl0c0lw_w_match_7) ,
                .active_state(ltl0c0lw_w_out_7));


wire ltl0c0lw_w_out_8;
wire ltl0c0lw_lut_match_8;
wire ltl0c0lw_w_match_8;

    
    
    

LUT_Match_ltl0c0lw_8 #(8) lut_match_ltl0c0lw_8(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_8));


assign ltl0c0lw_w_match_8 = ltl0c0lw_lut_match_8 ;

STE #(.fan_in(2)) ltl0c0lw_ste_8 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ ltl0c0lw_w_out_3, ltl0c0lw_w_out_7 }),
                .match(ltl0c0lw_w_match_8) ,
                .active_state(ltl0c0lw_w_out_8));


wire ltl0c0lw_lut_match_9;
wire ltl0c0lw_w_match_9;

    
    
    

LUT_Match_ltl0c0lw_9 #(8) lut_match_ltl0c0lw_9(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_9));


assign ltl0c0lw_w_match_9 = ltl0c0lw_lut_match_9 ;

STE #(.fan_in(4)) ltl0c0lw_ste_9 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ ltl0c0lw_w_out_9, ltl0c0lw_w_out_11, ltl0c0lw_w_out_4, ltl0c0lw_w_out_6 }),
                .match(ltl0c0lw_w_match_9) ,
                .active_state(ltl0c0lw_w_out_9));


wire ltl0c0lw_w_out_10;
wire ltl0c0lw_lut_match_10;
wire ltl0c0lw_w_match_10;

    
    
    

LUT_Match_ltl0c0lw_10 #(8) lut_match_ltl0c0lw_10(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_10));


assign ltl0c0lw_w_match_10 = ltl0c0lw_lut_match_10 ;

STE #(.fan_in(2)) ltl0c0lw_ste_10 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ ltl0c0lw_w_out_8, ltl0c0lw_w_out_10 }),
                .match(ltl0c0lw_w_match_10) ,
                .active_state(ltl0c0lw_w_out_10));


wire ltl0c0lw_lut_match_11;
wire ltl0c0lw_w_match_11;

    
    
    

LUT_Match_ltl0c0lw_11 #(8) lut_match_ltl0c0lw_11(
                .clk(clk),
                .symbols(symbols),
                .match(ltl0c0lw_lut_match_11));


assign ltl0c0lw_w_match_11 = ltl0c0lw_lut_match_11 ;

STE #(.fan_in(2)) ltl0c0lw_ste_11 (
                .clk(clk),
                .run(run),
                .reset(reset),
		.start_of_data,
                .income_edges({ ltl0c0lw_w_out_8, ltl0c0lw_w_out_10 }),
                .match(ltl0c0lw_w_match_11) ,
                .active_state(ltl0c0lw_w_out_11));




endmodule

