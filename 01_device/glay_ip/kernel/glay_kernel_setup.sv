// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_kernel_setup.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


import GLAY_AXI4_PKG::*;
import GLAY_GLOBALS_PKG::*;
import GLAY_DESCRIPTOR_PKG::*;
import GLAY_CONTROL_PKG::*;
import GLAY_REQ_PKG::*;

module glay_kernel_setup #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL
) (
    // System Signals
    input  logic                           ap_clk                  ,
    input  logic                           areset                  ,
    input  GlayControlChainInterfaceOutput glay_control_state      ,
    input  GLAYDescriptorInterface         glay_descriptor         ,
    input  GlayCacheRequestInterfaceOutput glay_setup_cache_req_in ,
    output FIFOStateSignalsOutput          req_in_fifo_out_signals ,
    output FIFOStateSignalsInput           req_in_fifo_in_signals  ,
    output GlayCacheRequestInterfaceInput  glay_setup_cache_req_out,
    output FIFOStateSignalsOutput          req_out_fifo_out_signals,
    output FIFOStateSignalsInput           req_out_fifo_in_signals ,
    output logic                           fifo_setup_signal
);

    logic setup_areset;
    
// --------------------------------------------------------------------------------------
//   AXI Cache FIFO signals
// --------------------------------------------------------------------------------------
    GlayControlChainInterfaceOutput glay_control_state_reg;
    GLAYDescriptorInterface         glay_descriptor_reg   ;

    GlayCacheRequestInterfaceInput glay_setup_cache_req_in_dout;
    GlayCacheRequestInterfaceInput glay_setup_cache_req_in_din ;

    GlayCacheRequestInterfaceOutput glay_setup_cache_req_out_dout;
    GlayCacheRequestInterfaceOutput glay_setup_cache_req_out_din ;

    FIFOStateSignalsOutput req_in_fifo_out_signals_reg ;
    FIFOStateSignalsOutput req_out_fifo_out_signals_reg;

    FIFOStateSignalsInput req_in_fifo_in_signals_reg ;
    FIFOStateSignalsInput req_out_fifo_in_signals_reg;

    logic fifo_setup_signal_reg;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        setup_areset <= areset;
    end

// --------------------------------------------------------------------------------------
// READ GLAY Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (setup_areset) begin
            glay_descriptor_reg.valid <= 0;
        end
        else begin
            glay_descriptor_reg.valid <= glay_descriptor.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        glay_descriptor_reg.payload <= glay_descriptor.payload;
    end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (setup_areset) begin
            glay_setup_cache_req_in_din.valid <= 0;
        end
        else begin
            glay_setup_cache_req_in_din.valid <= glay_setup_cache_req_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        glay_setup_cache_req_in_din.payload <= glay_setup_cache_req_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (setup_areset) begin
            fifo_setup_signal              <= 1;
            glay_setup_cache_req_out.valid <= 0;
        end
        else begin
            fifo_setup_signal              <= fifo_setup_signal_reg;
            glay_setup_cache_req_out.valid <= glay_setup_cache_req_out_dout.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        glay_setup_cache_req_out.payload <= glay_setup_cache_req_out_dout.payload;
    end

// --------------------------------------------------------------------------------------
// GLAY SETUP State Machine
// --------------------------------------------------------------------------------------
    assign glay_setup_cache_req_out_din     = 0;
    assign req_in_fifo_in_signals_reg.rd_en = 0;




// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
    assign fifo_setup_signal_reg = req_out_fifo_out_signals_reg.wr_rst_busy | req_out_fifo_out_signals_reg.rd_rst_busy | req_in_fifo_out_signals_reg.wr_rst_busy | req_in_fifo_out_signals_reg.rd_rst_busy;

// --------------------------------------------------------------------------------------
// FIFO cache requests in fifo_638x32_GlaySetupRequestInterfaceInput
// --------------------------------------------------------------------------------------
    assign req_in_fifo_in_signals_reg.wr_en   = glay_setup_cache_req_in_din.valid;
    assign glay_setup_cache_req_in_dout.valid = req_in_fifo_out_signals_reg.valid;

    fifo_638x32 inst_fifo_638x32_GlaySetupRequestInterfaceInput (
        .clk         (ap_clk                                  ),
        .srst        (setup_areset                            ),
        .din         (glay_setup_cache_req_in_din             ),
        .wr_en       (req_in_fifo_in_signals_reg.wr_en        ),
        .rd_en       (req_in_fifo_in_signals_reg.rd_en        ),
        .dout        (glay_setup_cache_req_in_dout            ),
        .full        (req_in_fifo_out_signals_reg.full        ),
        .almost_full (req_in_fifo_out_signals_reg.almost_full ),
        .empty       (req_in_fifo_out_signals_reg.empty       ),
        .almost_empty(req_in_fifo_out_signals_reg.almost_empty),
        .valid       (req_in_fifo_out_signals_reg.valid       ),
        .prog_full   (req_in_fifo_out_signals_reg.prog_full   ),
        .prog_empty  (req_in_fifo_out_signals_reg.prog_empty  ),
        .wr_rst_busy (req_in_fifo_out_signals_reg.wr_rst_busy ),
        .rd_rst_busy (req_in_fifo_out_signals_reg.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out fifo_516x32_GlaySetupRequestInterfaceOutput
// --------------------------------------------------------------------------------------
    assign req_out_fifo_in_signals_reg.wr_en  = glay_setup_cache_req_in_din.valid;
    assign glay_setup_cache_req_in_dout.valid = req_out_fifo_out_signals_reg.valid;

    fifo_516x32 inst_fifo_516x32_GlaySetupRequestInterfaceOutput (
        .clk         (ap_clk                                   ),
        .srst        (setup_areset                             ),
        .din         (glay_setup_cache_req_out_din             ),
        .wr_en       (req_out_fifo_in_signals_reg.wr_en        ),
        .rd_en       (req_out_fifo_in_signals_reg.rd_en        ),
        .dout        (glay_setup_cache_req_out_dout            ),
        .full        (req_out_fifo_out_signals_reg.full        ),
        .almost_full (req_out_fifo_out_signals_reg.almost_full ),
        .empty       (req_out_fifo_out_signals_reg.empty       ),
        .almost_empty(req_out_fifo_out_signals_reg.almost_empty),
        .valid       (req_out_fifo_out_signals_reg.valid       ),
        .prog_full   (req_out_fifo_out_signals_reg.prog_full   ),
        .prog_empty  (req_out_fifo_out_signals_reg.prog_empty  ),
        .wr_rst_busy (req_out_fifo_out_signals_reg.wr_rst_busy ),
        .rd_rst_busy (req_out_fifo_out_signals_reg.rd_rst_busy )
    );

endmodule : glay_kernel_setup