// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : arbiter_round_robin.sv
// Create : 2023-06-14 18:54:52
// Revise : 2023-06-14 19:27:35
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

module arbiter_round_robin #(
    parameter WIDTH         = 2               ,
    parameter ARBITER_WIDTH = 2**$clog2(WIDTH)
) (
    input logic                     areset,
    input logic                     ap_clk,
    input logic [ARBITER_WIDTH-1:0] req   ,
    input logic [ARBITER_WIDTH-1:0] grant
);

    logic                     areset_arbiter;
    logic [ARBITER_WIDTH-1:0] rotate_ptr    ;
    logic [ARBITER_WIDTH-1:0] mask_req      ;
    logic [ARBITER_WIDTH-1:0] mask_grant    ;
    logic [ARBITER_WIDTH-1:0] grant_comb    ;
    logic [ARBITER_WIDTH-1:0] grant         ;
    logic                     no_mask_req   ;
    logic [ARBITER_WIDTH-1:0] nomask_grant  ;
    logic                     update_ptr    ;
    genvar                    i             ;


// --------------------------------------------------------------------------------------
//  Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_arbiter <= areset;
    end

// --------------------------------------------------------------------------------------
// rotate pointer update logic
// --------------------------------------------------------------------------------------
    assign update_ptr = |grant[ARBITER_WIDTH-1:0];

    always_ff @ (posedge ap_clk) begin
        if (areset_arbiter) begin
            rotate_ptr[1:0] <= {2{1'b1}};
        end
        else begin
            if (update_ptr) begin
                // note: ARBITER_WIDTH must be at least 2
                rotate_ptr[0] <= grant[ARBITER_WIDTH-1];
                rotate_ptr[1] <= grant[ARBITER_WIDTH-1] | grant[0];
            end
            else begin
                rotate_ptr[0] <= rotate_ptr[0];
                rotate_ptr[1] <= rotate_ptr[1];
            end
        end
    end

    generate
        for (i=2;i<ARBITER_WIDTH;i=i+1) begin : gen_rotate_ptr
            always_ff @(posedge ap_clk) begin
                if (areset_arbiter) begin
                    rotate_ptr[i] <= 1'b1;
                end
                else begin
                    if (update_ptr) begin
                        rotate_ptr[i] <= grant[ARBITER_WIDTH-1] | (|grant[i-1:0]);
                    end else begin
                        rotate_ptr[i] <= rotate_ptr[i];
                    end
                end
            end
        end
    endgenerate

// --------------------------------------------------------------------------------------
// mask grant generation logic
// --------------------------------------------------------------------------------------
    assign mask_req[ARBITER_WIDTH-1:0] = req[ARBITER_WIDTH-1:0] & rotate_ptr[ARBITER_WIDTH-1:0];

    assign mask_grant[0] = mask_req[0];
    generate
        for (i=1;i<ARBITER_WIDTH;i=i+1) begin : gen_mask_grant
            assign mask_grant[i] = (~|mask_req[i-1:0]) & mask_req[i];
        end
    endgenerate

// --------------------------------------------------------------------------------------
// non-mask grant generation logic
// --------------------------------------------------------------------------------------
    assign nomask_grant[0] = req[0];
    generate
        for (i=1;i<ARBITER_WIDTH;i=i+1) begin : gen_nomask_grant
            assign nomask_grant[i] = (~|req[i-1:0]) & req[i];
        end
    endgenerate

// --------------------------------------------------------------------------------------
// grant generation logic
// --------------------------------------------------------------------------------------
    assign no_mask_req                   = ~|mask_req[ARBITER_WIDTH-1:0];
    assign grant_comb[ARBITER_WIDTH-1:0] = mask_grant[ARBITER_WIDTH-1:0] | (nomask_grant[ARBITER_WIDTH-1:0] & {ARBITER_WIDTH{no_mask_req}});

    always_ff @(posedge ap_clk) begin
        if (areset_arbiter) begin
            grant[ARBITER_WIDTH-1:0] <= {ARBITER_WIDTH{1'b0}};
        end
        else begin
            grant[ARBITER_WIDTH-1:0] <= grant_comb[ARBITER_WIDTH-1:0] & ~grant[ARBITER_WIDTH-1:0];
        end
    end
endmodule : arbiter_round_robin