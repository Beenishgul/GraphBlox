





/*
******************** Summary {}********************
total nodes = 77
total reports = 28
total edges = 154
average symbols len = 5.72727272727
#######################################################
*/

module Automata_Stage0C0lw(input clk,
                    input run,
                    input reset,
                    input [7 : 0] top_symbols
                    , output ltl4c0lw_w_out_4
                    , output ltl4c0lw_w_out_6
                    , output ltl4c0lw_w_out_9
                    , output ltl4c0lw_w_out_11
                    
                    , output ltl6c0lw_w_out_4
                    , output ltl6c0lw_w_out_6
                    , output ltl6c0lw_w_out_9
                    , output ltl6c0lw_w_out_11
                    
                    , output ltl2c0lw_w_out_4
                    , output ltl2c0lw_w_out_6
                    , output ltl2c0lw_w_out_9
                    , output ltl2c0lw_w_out_11
                    
                    , output ltl3c0lw_w_out_4
                    , output ltl3c0lw_w_out_6
                    , output ltl3c0lw_w_out_9
                    , output ltl3c0lw_w_out_11
                    
                    , output ltl1c0lw_w_out_4
                    , output ltl1c0lw_w_out_6
                    , output ltl1c0lw_w_out_9
                    , output ltl1c0lw_w_out_11
                    
                    , output ltl0c0lw_w_out_4
                    , output ltl0c0lw_w_out_6
                    , output ltl0c0lw_w_out_9
                    , output ltl0c0lw_w_out_11
                    
                    , output ltl5c0lw_w_out_4
                    , output ltl5c0lw_w_out_6
                    , output ltl5c0lw_w_out_9
                    , output ltl5c0lw_w_out_11
                    ,
                    output reg[7 : 0] out_symbols,
                    output reg out_reset
                    );

always @(posedge clk)
begin
    if (run == 1)
        out_symbols <= top_symbols;
        out_reset <= reset;
end



Automata_ltl4c0lw automata_ltl4c0lw (
                     .clk(clk),
                     .run(run),
                     .reset(reset),
                        .symbols(top_symbols )
                        , .ltl4c0lw_w_out_4(ltl4c0lw_w_out_4)
                        , .ltl4c0lw_w_out_6(ltl4c0lw_w_out_6)
                        , .ltl4c0lw_w_out_9(ltl4c0lw_w_out_9)
                        , .ltl4c0lw_w_out_11(ltl4c0lw_w_out_11)
                    );

Automata_ltl6c0lw automata_ltl6c0lw (
                     .clk(clk),
                     .run(run),
                     .reset(reset),
                        .symbols(top_symbols )
                        , .ltl6c0lw_w_out_4(ltl6c0lw_w_out_4)
                        , .ltl6c0lw_w_out_6(ltl6c0lw_w_out_6)
                        , .ltl6c0lw_w_out_9(ltl6c0lw_w_out_9)
                        , .ltl6c0lw_w_out_11(ltl6c0lw_w_out_11)
                    );

Automata_ltl2c0lw automata_ltl2c0lw (
                     .clk(clk),
                     .run(run),
                     .reset(reset),
                        .symbols(top_symbols )
                        , .ltl2c0lw_w_out_4(ltl2c0lw_w_out_4)
                        , .ltl2c0lw_w_out_6(ltl2c0lw_w_out_6)
                        , .ltl2c0lw_w_out_9(ltl2c0lw_w_out_9)
                        , .ltl2c0lw_w_out_11(ltl2c0lw_w_out_11)
                    );

Automata_ltl3c0lw automata_ltl3c0lw (
                     .clk(clk),
                     .run(run),
                     .reset(reset),
                        .symbols(top_symbols )
                        , .ltl3c0lw_w_out_4(ltl3c0lw_w_out_4)
                        , .ltl3c0lw_w_out_6(ltl3c0lw_w_out_6)
                        , .ltl3c0lw_w_out_9(ltl3c0lw_w_out_9)
                        , .ltl3c0lw_w_out_11(ltl3c0lw_w_out_11)
                    );

Automata_ltl1c0lw automata_ltl1c0lw (
                     .clk(clk),
                     .run(run),
                     .reset(reset),
                        .symbols(top_symbols )
                        , .ltl1c0lw_w_out_4(ltl1c0lw_w_out_4)
                        , .ltl1c0lw_w_out_6(ltl1c0lw_w_out_6)
                        , .ltl1c0lw_w_out_9(ltl1c0lw_w_out_9)
                        , .ltl1c0lw_w_out_11(ltl1c0lw_w_out_11)
                    );

Automata_ltl0c0lw automata_ltl0c0lw (
                     .clk(clk),
                     .run(run),
                     .reset(reset),
                        .symbols(top_symbols )
                        , .ltl0c0lw_w_out_4(ltl0c0lw_w_out_4)
                        , .ltl0c0lw_w_out_6(ltl0c0lw_w_out_6)
                        , .ltl0c0lw_w_out_9(ltl0c0lw_w_out_9)
                        , .ltl0c0lw_w_out_11(ltl0c0lw_w_out_11)
                    );

Automata_ltl5c0lw automata_ltl5c0lw (
                     .clk(clk),
                     .run(run),
                     .reset(reset),
                        .symbols(top_symbols )
                        , .ltl5c0lw_w_out_4(ltl5c0lw_w_out_4)
                        , .ltl5c0lw_w_out_6(ltl5c0lw_w_out_6)
                        , .ltl5c0lw_w_out_9(ltl5c0lw_w_out_9)
                        , .ltl5c0lw_w_out_11(ltl5c0lw_w_out_11)
                    );


















    



 










endmodule
