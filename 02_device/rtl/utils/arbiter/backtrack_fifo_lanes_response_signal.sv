// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : backtrack_fifo_lanes_response_signal.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module backtrack_fifo_lanes_response_signal #(parameter
    ID_CU               = 0,
    ID_BUNDLE           = 0,
    ID_LANE             = 0,
    ID_ENGINE           = 0,
    ID_MODULE           = 0,
    NUM_BACKTRACK_LANES = 4,
    NUM_BUNDLES         = 4
) (
    // System Signals
    input  logic                  ap_clk                                                           ,
    input  logic                  areset                                                           ,
    input  logic                  configure_route_valid                                            ,
    input  PacketRouteAddress     configure_route_in                                               ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES-1:0],
    output FIFOStateSignalsInput  fifo_response_engine_in_signals_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic [        NUM_BUNDLES-1:0] next_module_id_bundle;
logic [NUM_BACKTRACK_LANES-1:0] signals_out_reg_rd_en;

assign next_module_id_bundle = (1 << (ID_BUNDLE+1)) | ( 1 >> (NUM_BUNDLES-(ID_BUNDLE+1)));


// --------------------------------------------------------------------------------------
// Drive Response FIFO signals
// --------------------------------------------------------------------------------------
always_comb begin
    signals_out_reg_rd_en = 0;
    if(configure_route_valid & (next_module_id_bundle == configure_route_in.id_bundle[NUM_BUNDLES-1:0]) & (|configure_route_in.id_lane)) begin
        for (int i = 0; i < NUM_BACKTRACK_LANES; i = i + 1) begin
            signals_out_reg_rd_en[i] = configure_route_in.id_lane[i] ? ~fifo_response_lanes_backtrack_signals_in[i].prog_full : 1'b1;
        end
    end

    if(configure_route_valid & (next_module_id_bundle != configure_route_in.id_bundle[NUM_BUNDLES-1:0]) & (|configure_route_in.id_lane)) begin
        signals_out_reg_rd_en[NUM_BACKTRACK_LANES-2:0] = {(NUM_BACKTRACK_LANES-1){1'b1}};
        signals_out_reg_rd_en[NUM_BACKTRACK_LANES-1]   = configure_route_in.id_lane[NUM_BACKTRACK_LANES-1] ? ~fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES-1].prog_full : 1'b1;
    end

    if(configure_route_valid & ~(|configure_route_in.id_lane)) begin
        signals_out_reg_rd_en[NUM_BACKTRACK_LANES-1:0] = {NUM_BACKTRACK_LANES{1'b1}};
    end
end

assign fifo_response_engine_in_signals_out.rd_en = &signals_out_reg_rd_en;

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------

endmodule : backtrack_fifo_lanes_response_signal