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
// Revise : 2023-06-14 19:37:17
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"
//------------------------------------------------------------------------
// vc_VariableArbChain
//------------------------------------------------------------------------
// The input priority signal is a one-hot signal where the one indicates
// which request should be given highest priority.

module vc_VariableArbChain #(parameter ARBITER_WIDTH = 2) (
    input  logic                     kin      , // kill in
    input  logic [ARBITER_WIDTH-1:0] priority_, // (one-hot) 1 is req w/ highest pri
    input  logic [ARBITER_WIDTH-1:0] reqs     , // 1 = making a req, 0 = no req
    output logic [ARBITER_WIDTH-1:0] grants   , // (one-hot) 1 is req won grant
    output logic                     kout       // kill out
);

    // The internal kills signals essentially form a kill chain from the
    // highest priority to the lowest priority requester. Unliked the fixed
    // arb, the priority input is used to determine which request has the
    // highest priority. We could use a circular kill chain, but static
    // timing analyzers would probably consider it a combinational loop
    // (which it is) and choke. Instead we replicate the kill chain. See
    // Principles and Practices of Interconnection Networks, Dally +
    // Towles, p354 for more info.

    logic [2*ARBITER_WIDTH:0] kills;
    assign kills[0] = 1'b1;

    logic [2*ARBITER_WIDTH-1:0] priority_int;
    assign priority_int = { {ARBITER_WIDTH{1'b0}}, priority_ };

    logic [2*ARBITER_WIDTH-1:0] reqs_int;
    assign reqs_int = { reqs, reqs };

    logic [2*ARBITER_WIDTH-1:0] grants_int;

    // The per requester logic first computes the grant signal and then
    // computes the kill signal for the next requester.

    localparam ARBITER_WIDTH_x2 = (ARBITER_WIDTH << 1);
    genvar i;
    generate
        for ( i = 0; i < 2*ARBITER_WIDTH; i = i + 1 )
            begin : per_req_logic

                // If this is the highest priority requester, then we ignore the
                // input kill signal, otherwise grant is true if this requester is
                // not killed and it is actually making a req.

                assign grants_int[i]
                    = priority_int[i] ? reqs_int[i] : (!kills[i] && reqs_int[i]);

                // If this is the highest priority requester, then we ignore the
                // input kill signal, otherwise kill is true if this requester was
                // either killed or it received the grant.

                assign kills[i+1]
                    = priority_int[i] ? grants_int[i] : (kills[i] || grants_int[i]);

            end
    endgenerate

    // To calculate final grants we OR the two grants from the replicated
    // kill chain. We also AND in the global kin signal.

    assign grants
        = (grants_int[ARBITER_WIDTH-1:0] | grants_int[2*ARBITER_WIDTH-1:ARBITER_WIDTH])
            & {ARBITER_WIDTH{~kin}};

    assign kout = kills[2*ARBITER_WIDTH] || kin;

endmodule : vc_VariableArbChain
//------------------------------------------------------------------------

module arbiter_round_robin #(
    parameter WIDTH         = 2               ,
    parameter ARBITER_WIDTH = 2**$clog2(WIDTH)
) (
    input  logic                     ap_clk,
    input  logic                     areset,
    input  logic [ARBITER_WIDTH-1:0] req   , // 1 = making a req, 0 = no req
    output logic [ARBITER_WIDTH-1:0] grant   // (one-hot) 1 is req won grant
);
    // We only update the priority if a requester actually received a grant

    logic                     priority_en  ;
    logic [ARBITER_WIDTH-1:0] priority_next;
    logic [ARBITER_WIDTH-1:0] priority_    ;

    assign priority_en = |grant;

    // Next priority is just the one-hot grant vector left rotated by one


    assign priority_next = { grant[ARBITER_WIDTH-2:0], grant[ARBITER_WIDTH-1] };

    // State for the one-hot priority vector
    always_ff @(posedge ap_clk) begin
        if(areset) begin
            priority_ <= 1;
        end else begin
            if(priority_en)
                priority_ <= priority_next;
        end
    end

    // Variable arbiter chain
    logic dummy_kout;

    vc_VariableArbChain #(.ARBITER_WIDTH(ARBITER_WIDTH)) variable_arb_chain (
        .kin      (1'b0      ),
        .priority_(priority_ ),
        .reqs     (req       ),
        .grants   (grant     ),
        .kout     (dummy_kout)
    );

endmodule : arbiter_round_robin