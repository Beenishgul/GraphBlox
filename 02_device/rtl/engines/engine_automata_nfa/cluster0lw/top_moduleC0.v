

module Top_ModuleC0lw(
                  input clk,
                  input reset,
                  input run,
                  input [7 : 0] symbols
                   , output wire ltl4c0lw
                   , output wire ltl6c0lw
                   , output wire ltl2c0lw
                   , output wire ltl3c0lw
                   , output wire ltl1c0lw
                   , output wire ltl0c0lw
                   , output wire ltl5c0lw
                  
                  );
  wire ltl4c0lw_w_out_4;
  wire ltl4c0lw_w_out_6;
  wire ltl4c0lw_w_out_9;
  wire ltl4c0lw_w_out_11;
  wire ltl6c0lw_w_out_4;
  wire ltl6c0lw_w_out_6;
  wire ltl6c0lw_w_out_9;
  wire ltl6c0lw_w_out_11;
  wire ltl2c0lw_w_out_4;
  wire ltl2c0lw_w_out_6;
  wire ltl2c0lw_w_out_9;
  wire ltl2c0lw_w_out_11;
  wire ltl3c0lw_w_out_4;
  wire ltl3c0lw_w_out_6;
  wire ltl3c0lw_w_out_9;
  wire ltl3c0lw_w_out_11;
  wire ltl1c0lw_w_out_4;
  wire ltl1c0lw_w_out_6;
  wire ltl1c0lw_w_out_9;
  wire ltl1c0lw_w_out_11;
  wire ltl0c0lw_w_out_4;
  wire ltl0c0lw_w_out_6;
  wire ltl0c0lw_w_out_9;
  wire ltl0c0lw_w_out_11;
  wire ltl5c0lw_w_out_4;
  wire ltl5c0lw_w_out_6;
  wire ltl5c0lw_w_out_9;
  wire ltl5c0lw_w_out_11;

assign ltl4c0lw =
  ltl4c0lw_w_out_4 |
  ltl4c0lw_w_out_6 |
  ltl4c0lw_w_out_9 |
  ltl4c0lw_w_out_11 |
1'b0;
assign ltl6c0lw =
  ltl6c0lw_w_out_4 |
  ltl6c0lw_w_out_6 |
  ltl6c0lw_w_out_9 |
  ltl6c0lw_w_out_11 |
1'b0;
assign ltl2c0lw =
  ltl2c0lw_w_out_4 |
  ltl2c0lw_w_out_6 |
  ltl2c0lw_w_out_9 |
  ltl2c0lw_w_out_11 |
1'b0;
assign ltl3c0lw =
  ltl3c0lw_w_out_4 |
  ltl3c0lw_w_out_6 |
  ltl3c0lw_w_out_9 |
  ltl3c0lw_w_out_11 |
1'b0;
assign ltl1c0lw =
  ltl1c0lw_w_out_4 |
  ltl1c0lw_w_out_6 |
  ltl1c0lw_w_out_9 |
  ltl1c0lw_w_out_11 |
1'b0;
assign ltl0c0lw =
  ltl0c0lw_w_out_4 |
  ltl0c0lw_w_out_6 |
  ltl0c0lw_w_out_9 |
  ltl0c0lw_w_out_11 |
1'b0;
assign ltl5c0lw =
  ltl5c0lw_w_out_4 |
  ltl5c0lw_w_out_6 |
  ltl5c0lw_w_out_9 |
  ltl5c0lw_w_out_11 |
1'b0;





Automata_Stage0C0lw automata_stage0(.clk(clk),
                                             .run(run),
                                             .reset(reset),
                                             .top_symbols( symbols ),
                                              .ltl4c0lw_w_out_4(ltl4c0lw_w_out_4),
                                              .ltl4c0lw_w_out_6(ltl4c0lw_w_out_6),
                                              .ltl4c0lw_w_out_9(ltl4c0lw_w_out_9),
                                              .ltl4c0lw_w_out_11(ltl4c0lw_w_out_11),
                                             
                                              .ltl6c0lw_w_out_4(ltl6c0lw_w_out_4),
                                              .ltl6c0lw_w_out_6(ltl6c0lw_w_out_6),
                                              .ltl6c0lw_w_out_9(ltl6c0lw_w_out_9),
                                              .ltl6c0lw_w_out_11(ltl6c0lw_w_out_11),
                                             
                                              .ltl2c0lw_w_out_4(ltl2c0lw_w_out_4),
                                              .ltl2c0lw_w_out_6(ltl2c0lw_w_out_6),
                                              .ltl2c0lw_w_out_9(ltl2c0lw_w_out_9),
                                              .ltl2c0lw_w_out_11(ltl2c0lw_w_out_11),
                                             
                                              .ltl3c0lw_w_out_4(ltl3c0lw_w_out_4),
                                              .ltl3c0lw_w_out_6(ltl3c0lw_w_out_6),
                                              .ltl3c0lw_w_out_9(ltl3c0lw_w_out_9),
                                              .ltl3c0lw_w_out_11(ltl3c0lw_w_out_11),
                                             
                                              .ltl1c0lw_w_out_4(ltl1c0lw_w_out_4),
                                              .ltl1c0lw_w_out_6(ltl1c0lw_w_out_6),
                                              .ltl1c0lw_w_out_9(ltl1c0lw_w_out_9),
                                              .ltl1c0lw_w_out_11(ltl1c0lw_w_out_11),
                                             
                                              .ltl0c0lw_w_out_4(ltl0c0lw_w_out_4),
                                              .ltl0c0lw_w_out_6(ltl0c0lw_w_out_6),
                                              .ltl0c0lw_w_out_9(ltl0c0lw_w_out_9),
                                              .ltl0c0lw_w_out_11(ltl0c0lw_w_out_11),
                                             
                                              .ltl5c0lw_w_out_4(ltl5c0lw_w_out_4),
                                              .ltl5c0lw_w_out_6(ltl5c0lw_w_out_6),
                                              .ltl5c0lw_w_out_9(ltl5c0lw_w_out_9),
                                              .ltl5c0lw_w_out_11(ltl5c0lw_w_out_11),
                                             
                                             .out_symbols(),
                                             .out_reset()
                                             );




endmodule
