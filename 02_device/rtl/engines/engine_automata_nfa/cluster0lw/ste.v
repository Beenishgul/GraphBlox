



module STE #(
    parameter integer fan_in     = 1,
    parameter         START_TYPE = 0
) (
    input               clk          ,
    input               run          ,
    input               reset        ,
    input               start_of_data,
    input  [fan_in-1:0] income_edges ,
    input               match        ,
    output              active_state
);

    // START_TYPE:
    // 0 = none
    // 1 = start-of-data

    // This is the number of incoming edges


    reg internal_reg;
    always @ (posedge clk)
        begin
            if (reset == 1) begin
                if (START_TYPE == 0) begin
                    internal_reg <= 1'b0;
                end else begin
                    internal_reg <= 1'b1;
                end
            end
            else if (run == 1) begin
                internal_reg <= |income_edges;
                if(START_TYPE==1  && start_of_data)
                    internal_reg <= 1'b1;
            end
        end

    assign active_state = internal_reg & match;


endmodule
