// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : backtrack_fifo_request_memory_out_signals.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module backtrack_fifo_request_memory_out_signals #(parameter
    ID_CU        = 0,
    ID_BUNDLE    = 0,
    ID_LANE      = 0,
    ID_ENGINE    = 0,
    ID_MODULE    = 0,
    NUM_CHANNELS = 2
) (
    // System Signals
    input  logic                    ap_clk                                                        ,
    input  logic                    areset                                                        ,
    input  logic                    configure_address_valid                                       ,
    input  PacketRequestDataAddress configure_address_in                                          ,
    input  FIFOStateSignalsOutput   fifo_request_memory_out_backtrack_signals_in[NUM_CHANNELS-1:0],
    output FIFOStateSignalsInput    fifo_request_memory_out_signals_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic [NUM_CHANNELS-1:0] signals_out_reg_rd_en;

// --------------------------------------------------------------------------------------
// Drive Response FIFO signals
// --------------------------------------------------------------------------------------
always_comb begin
    signals_out_reg_rd_en = 0;
    if(configure_address_valid) begin
        for (int i = 0; i < NUM_CHANNELS; i = i + 1) begin
            signals_out_reg_rd_en[i] = configure_address_in.id_channel[i] ? ~fifo_request_memory_out_backtrack_signals_in[i].prog_full : 1'b1;
        end
    end
end

assign fifo_request_memory_out_signals_out.rd_en = &signals_out_reg_rd_en;

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------

endmodule : backtrack_fifo_request_memory_out_signals