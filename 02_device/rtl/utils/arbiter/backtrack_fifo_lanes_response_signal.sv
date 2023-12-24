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
    ID_CU           = 0,
    ID_BUNDLE       = 0,
    ID_LANE         = 0,
    ID_ENGINE       = 0,
    ID_MODULE       = 0,
    NUM_LANES_MAX   = 4,
    NUM_BUNDLES_MAX = 4
) (
    // System Signals
    input  logic                  ap_clk                                                     ,
    input  logic                  areset                                                     ,
    input  logic                  configure_route_valid                                      ,
    input  MemoryPacketArbitrate  configure_route_in                                         ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in                         ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_LANES_MAX-1:0],
    output FIFOStateSignalsInput  fifo_response_engine_in_signals_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_backtrack;

logic                       configure_route_valid_reg                                      ;
MemoryPacketArbitrate       configure_route_in_reg                                         ;
FIFOStateSignalsInput       fifo_response_engine_in_signals_in_reg                         ;
FIFOStateSignalsOutput      fifo_response_lanes_backtrack_signals_in_reg[NUM_LANES_MAX-1:0];
FIFOStateSignalsInput       fifo_response_engine_in_signals_out_reg                        ;
logic [NUM_BUNDLES_MAX-1:0] next_module_id_bundle                                       ;

assign next_module_id_bundle = (1 << (ID_BUNDLE+1)) | ( 1 >> (NUM_BUNDLES_MAX-(ID_BUNDLE+1)));

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_backtrack <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_backtrack) begin
        configure_route_valid_reg              <= 1'b0;
        fifo_response_engine_in_signals_in_reg <= 0;
    end
    else begin
        fifo_response_engine_in_signals_in_reg <= fifo_response_engine_in_signals_in;

        if(configure_route_valid) begin
            configure_route_valid_reg <= configure_route_valid;
            configure_route_in_reg    <= configure_route_in;
        end
    end
end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_backtrack) begin
        fifo_response_engine_in_signals_out <= 0;
    end else begin
        fifo_response_engine_in_signals_out <= fifo_response_engine_in_signals_out_reg;
    end
end

always_ff @(posedge ap_clk) begin
    fifo_response_lanes_backtrack_signals_in_reg <= fifo_response_lanes_backtrack_signals_in;
end

// --------------------------------------------------------------------------------------
// Drive Response FIFO signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(configure_route_valid_reg && (next_module_id_bundle == configure_route_in_reg.id_bundle[NUM_BUNDLES_MAX-1:0])) begin
        for (int i = 0; i < NUM_LANES_MAX; i = i + 1) begin
            if (configure_route_in_reg.id_lane == (1 << i)) begin
                fifo_response_engine_in_signals_out_reg.rd_en <= fifo_response_engine_in_signals_in_reg.rd_en & ~fifo_response_lanes_backtrack_signals_in_reg[i].prog_full;
            end
        end
    end else begin
        fifo_response_engine_in_signals_out_reg.rd_en <= 1'b0;;
    end
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------

endmodule : backtrack_fifo_lanes_response_signal