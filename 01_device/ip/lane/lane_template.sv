// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : lane_template.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-06-14 23:51:20
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_SETUP::*;
import PKG_CACHE::*;

module lane_template #(
    parameter ID_CU     = 0,
    parameter ID_BUNDLE = 0,
    parameter ID_LANE   = 0,
    `include "cu_parameters.vh"
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  MemoryPacket           response_lane_in                   ,
    input  FIFOStateSignalsInput  fifo_response_lane_in_signals_in   ,
    output FIFOStateSignalsOutput fifo_response_lane_in_signals_out  ,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output MemoryPacket           request_lane_out                   ,
    input  FIFOStateSignalsInput  fifo_request_lane_out_signals_in   ,
    output FIFOStateSignalsOutput fifo_request_lane_out_signals_out  ,
    output MemoryPacket           request_memory_out                 ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out,
    output logic                  fifo_setup_signal                  ,
    output logic                  done_out
);

    genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_lane_template;
    logic areset_fifo         ;

    KernelDescriptor descriptor_in_reg;

    MemoryPacket request_memory_out_reg;
    MemoryPacket response_lane_in_reg  ;
    MemoryPacket response_memory_in_reg;

    MemoryPacket request_lane_out_int  ;
    MemoryPacket request_memory_out_int;
    MemoryPacket response_lane_in_int  ;
    MemoryPacket response_memory_in_int;

// --------------------------------------------------------------------------------------
// FIFO Engines INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_lane_in_din             ;
    MemoryPacketPayload    fifo_response_lane_in_dout            ;
    FIFOStateSignalsInput  fifo_response_lane_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_lane_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_lane_in_signals_out_int ;
    logic                  fifo_response_lane_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_memory_in_din             ;
    MemoryPacketPayload    fifo_response_memory_in_dout            ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_int ;
    logic                  fifo_response_memory_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO Engines OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_lane_out_din             ;
    MemoryPacketPayload    fifo_request_lane_out_dout            ;
    FIFOStateSignalsInput  fifo_request_lane_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_lane_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_lane_out_signals_out_int ;
    logic                  fifo_request_lane_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_memory_out_din             ;
    MemoryPacketPayload    fifo_request_memory_out_dout            ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_memory_out_signals_out_int ;
    logic                  fifo_request_memory_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// Generate Engines
// --------------------------------------------------------------------------------------
    logic                   areset_engine                              [NUM_ENGINES-1:0];
    KernelDescriptor        engines_descriptor_in                      [NUM_ENGINES-1:0];
    MemoryPacket            engines_response_lane_in                   [NUM_ENGINES-1:0];
    FIFOStateSignalsInput   engines_fifo_response_lane_in_signals_in   [NUM_ENGINES-1:0];
    FIFOStateSignalsOutput  engines_fifo_response_lane_in_signals_out  [NUM_ENGINES-1:0];
    MemoryPacket            engines_response_memory_in                 [NUM_ENGINES-1:0];
    FIFOStateSignalsInput   engines_fifo_response_memory_in_signals_in [NUM_ENGINES-1:0];
    FIFOStateSignalsOutput  engines_fifo_response_memory_in_signals_out[NUM_ENGINES-1:0];
    MemoryPacket            engines_request_lane_out                   [NUM_ENGINES-1:0];
    FIFOStateSignalsInput   engines_fifo_request_lane_out_signals_in   [NUM_ENGINES-1:0];
    FIFOStateSignalsOutput  engines_fifo_request_lane_out_signals_out  [NUM_ENGINES-1:0];
    MemoryPacket            engines_request_memory_out                 [NUM_ENGINES-1:0];
    FIFOStateSignalsInput   engines_fifo_request_memory_out_signals_in [NUM_ENGINES-1:0];
    FIFOStateSignalsOutput  engines_fifo_request_memory_out_signals_out[NUM_ENGINES-1:0];
    logic                   engines_fifo_setup_signal                  [NUM_ENGINES-1:0];
    logic                   engines_done_out                           [NUM_ENGINES-1:0];
    MemoryPacket            engines_request_lane_out_int                                ;
    MemoryPacket            engines_request_memory_out_int                              ;
    logic [NUM_ENGINES-1:0] engines_fifo_setup_signal_reg                               ;
    logic [NUM_ENGINES-1:0] engines_done_out_reg                                        ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_lane_template <= areset;
        areset_fifo          <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_lane_template) begin
            descriptor_in_reg.valid <= 1'b0;
        end
        else begin
            descriptor_in_reg.valid <= descriptor_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        descriptor_in_reg.payload <= descriptor_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_lane_template) begin
            fifo_response_lane_in_signals_in_reg   <= 0;
            fifo_request_lane_out_signals_in_reg   <= 0;
            fifo_response_memory_in_signals_in_reg <= 0;
            fifo_request_memory_out_signals_in_reg <= 0;
            response_lane_in_reg.valid             <= 1'b0;
            response_memory_in_reg.valid           <= 1'b0;
        end
        else begin
            fifo_response_lane_in_signals_in_reg   <= fifo_response_lane_in_signals_in;
            fifo_request_lane_out_signals_in_reg   <= fifo_request_lane_out_signals_in;
            fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
            fifo_request_memory_out_signals_in_reg <= fifo_request_memory_out_signals_in;
            response_lane_in_reg.valid             <= response_lane_in.valid;
            response_memory_in_reg.valid           <= response_memory_in.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_lane_in_reg.payload   <= response_lane_in.payload;
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_lane_template) begin
            fifo_setup_signal        <= 1'b1;
            request_lane_out.valid   <= 1'b0;
            request_memory_out.valid <= 1'b0;
            done_out                 <= 1'b1;
        end
        else begin
            fifo_setup_signal        <= fifo_response_lane_in_setup_signal_int | fifo_response_memory_in_setup_signal_int | fifo_request_lane_out_setup_signal_int | fifo_request_memory_out_setup_signal_int | (|engines_fifo_setup_signal_reg);
            request_lane_out.valid   <= request_lane_out_int.valid ;
            request_memory_out.valid <= request_memory_out_int.valid;
            done_out                 <= (&engines_done_out_reg);
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_lane_in_signals_out   <= fifo_response_lane_in_signals_out_int;
        fifo_request_lane_out_signals_out   <= fifo_request_lane_out_signals_out_int;
        fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_int;
        fifo_request_memory_out_signals_out <= fifo_request_memory_out_signals_out_int;
        request_lane_out.payload            <= request_lane_out_int.payload;
        request_memory_out.payload          <= request_memory_out_int.payload ;
    end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engines Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_lane_in_setup_signal_int = fifo_response_lane_in_signals_out_int.wr_rst_busy | fifo_response_lane_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_lane_in_signals_in_int.wr_en = response_lane_in_reg.valid;
    assign fifo_response_lane_in_din                  = response_lane_in_reg.payload;

    // Pop
    assign fifo_response_lane_in_signals_in_int.rd_en = ~fifo_response_lane_in_signals_out_int.empty & fifo_response_lane_in_signals_in_reg.rd_en & ~engines_fifo_response_lane_in_signals_out[0].prog_full;
    assign response_lane_in_int.valid                 = fifo_response_lane_in_signals_out_int.valid;
    assign response_lane_in_int.payload               = fifo_response_lane_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponseEnginesInput (
        .clk         (ap_clk                                            ),
        .srst        (areset_fifo                                       ),
        .din         (fifo_response_lane_in_din                         ),
        .wr_en       (fifo_response_lane_in_signals_in_int.wr_en        ),
        .rd_en       (fifo_response_lane_in_signals_in_int.rd_en        ),
        .dout        (fifo_response_lane_in_dout                        ),
        .full        (fifo_response_lane_in_signals_out_int.full        ),
        .almost_full (fifo_response_lane_in_signals_out_int.almost_full ),
        .empty       (fifo_response_lane_in_signals_out_int.empty       ),
        .almost_empty(fifo_response_lane_in_signals_out_int.almost_empty),
        .valid       (fifo_response_lane_in_signals_out_int.valid       ),
        .prog_full   (fifo_response_lane_in_signals_out_int.prog_full   ),
        .prog_empty  (fifo_response_lane_in_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_response_lane_in_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_response_lane_in_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_memory_in_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy | fifo_response_memory_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid;
    assign fifo_response_memory_in_din                  = response_memory_in_reg.payload;

    // Pop
    assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~engines_fifo_response_memory_in_signals_out[0].prog_full;
    assign response_memory_in_int.valid                 = fifo_response_memory_in_signals_out_int.valid;
    assign response_memory_in_int.payload               = fifo_response_memory_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponseMemoryInput (
        .clk         (ap_clk                                              ),
        .srst        (areset_fifo                                         ),
        .din         (fifo_response_memory_in_din                         ),
        .wr_en       (fifo_response_memory_in_signals_in_int.wr_en        ),
        .rd_en       (fifo_response_memory_in_signals_in_int.rd_en        ),
        .dout        (fifo_response_memory_in_dout                        ),
        .full        (fifo_response_memory_in_signals_out_int.full        ),
        .almost_full (fifo_response_memory_in_signals_out_int.almost_full ),
        .empty       (fifo_response_memory_in_signals_out_int.empty       ),
        .almost_empty(fifo_response_memory_in_signals_out_int.almost_empty),
        .valid       (fifo_response_memory_in_signals_out_int.valid       ),
        .prog_full   (fifo_response_memory_in_signals_out_int.prog_full   ),
        .prog_empty  (fifo_response_memory_in_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_response_memory_in_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_response_memory_in_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engines requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_lane_out_setup_signal_int = fifo_request_lane_out_signals_out_int.wr_rst_busy | fifo_request_lane_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_lane_out_signals_in_int.wr_en = engines_request_lane_out_int.valid;
    assign fifo_request_lane_out_din                  = engines_request_lane_out_int.payload;

    // Pop
    assign fifo_request_lane_out_signals_in_int.rd_en = ~fifo_request_lane_out_signals_out_int.empty & fifo_request_lane_out_signals_in_reg.rd_en;
    assign request_lane_out_int.valid                 = fifo_request_lane_out_signals_out_int.valid;
    assign request_lane_out_int.payload               = fifo_request_lane_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequestEnginesOutput (
        .clk         (ap_clk                                            ),
        .srst        (areset_fifo                                       ),
        .din         (fifo_request_lane_out_din                         ),
        .wr_en       (fifo_request_lane_out_signals_in_int.wr_en        ),
        .rd_en       (fifo_request_lane_out_signals_in_int.rd_en        ),
        .dout        (fifo_request_lane_out_dout                        ),
        .full        (fifo_request_lane_out_signals_out_int.full        ),
        .almost_full (fifo_request_lane_out_signals_out_int.almost_full ),
        .empty       (fifo_request_lane_out_signals_out_int.empty       ),
        .almost_empty(fifo_request_lane_out_signals_out_int.almost_empty),
        .valid       (fifo_request_lane_out_signals_out_int.valid       ),
        .prog_full   (fifo_request_lane_out_signals_out_int.prog_full   ),
        .prog_empty  (fifo_request_lane_out_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_request_lane_out_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_request_lane_out_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_memory_out_signals_in_int.wr_en = engines_request_memory_out_int.valid;
    assign fifo_request_memory_out_din                  = engines_request_memory_out_int.payload;

    // Pop
    assign fifo_request_memory_out_signals_in_int.rd_en = ~fifo_request_memory_out_signals_out_int.empty & fifo_request_memory_out_signals_in_reg.rd_en;
    assign request_memory_out_int.valid                 = fifo_request_memory_out_signals_out_int.valid;
    assign request_memory_out_int.payload               = fifo_request_memory_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequestMemoryOutput (
        .clk         (ap_clk                                              ),
        .srst        (areset_fifo                                         ),
        .din         (fifo_request_memory_out_din                         ),
        .wr_en       (fifo_request_memory_out_signals_in_int.wr_en        ),
        .rd_en       (fifo_request_memory_out_signals_in_int.rd_en        ),
        .dout        (fifo_request_memory_out_dout                        ),
        .full        (fifo_request_memory_out_signals_out_int.full        ),
        .almost_full (fifo_request_memory_out_signals_out_int.almost_full ),
        .empty       (fifo_request_memory_out_signals_out_int.empty       ),
        .almost_empty(fifo_request_memory_out_signals_out_int.almost_empty),
        .valid       (fifo_request_memory_out_signals_out_int.valid       ),
        .prog_full   (fifo_request_memory_out_signals_out_int.prog_full   ),
        .prog_empty  (fifo_request_memory_out_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_request_memory_out_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_request_memory_out_signals_out_int.rd_rst_busy )
    );


// --------------------------------------------------------------------------------------
// Generate Engines
// --------------------------------------------------------------------------------------
// Generate Engines - Drive input signals
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< NUM_ENGINES; i++) begin : generate_engines_reg_input
            always_ff @(posedge ap_clk) begin
                areset_engine[i] <= areset;
            end

            always_ff @(posedge ap_clk) begin
                if (areset_lane_template) begin
                    engines_descriptor_in[i].valid <= 0;
                end
                else begin
                    engines_descriptor_in[i].valid <= descriptor_in_reg.valid;
                end
            end

            always_ff @(posedge ap_clk) begin
                engines_descriptor_in[i].payload <= descriptor_in_reg.payload;
            end
        end
    endgenerate

// --------------------------------------------------------------------------------------
// Generate Engines - Drive output signals
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< NUM_ENGINES; i++) begin : generate_engines_reg_output
            always_ff @(posedge ap_clk) begin
                if (areset_lane_template) begin
                    engines_fifo_setup_signal_reg[i] <= 1'b1;
                    engines_done_out_reg[i]          <= 1'b1;
                end
                else begin
                    engines_fifo_setup_signal_reg[i] <= engines_fifo_setup_signal[i];
                    engines_done_out_reg[i]          <= engines_done_out[i];
                end
            end
        end
    endgenerate

// --------------------------------------------------------------------------------------
// Generate Engines - Drive Intra-signals
// --------------------------------------------------------------------------------------
// Generate Engines - in->[0]->[1]->[2]->[3]->[4]->out
// --------------------------------------------------------------------------------------
    assign engines_response_lane_in[0] = response_lane_in_int;
    assign engines_response_memory_in[0] = response_memory_in_int;
    assign engines_fifo_response_lane_in_signals_in[0].rd_en = 1'b1;
    assign engines_fifo_response_memory_in_signals_in[0].rd_en = 1'b1;

    generate
        for (i=1; i<NUM_ENGINES; i++) begin : generate_lane_template_intra_signals
            assign engines_response_lane_in[i]   = engines_request_lane_out[i-1];
            assign engines_response_memory_in[i] = engines_request_memory_out[i-1];

            assign engines_fifo_request_lane_out_signals_in[i-1].rd_en = ~engines_fifo_response_lane_in_signals_out[i].prog_full;
            assign engines_fifo_request_memory_out_signals_in[i-1].rd_en = ~engines_fifo_response_memory_in_signals_out[i].prog_full;

            assign engines_fifo_response_lane_in_signals_in[i].rd_en = 1'b1;
            assign engines_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
        end
    endgenerate

    assign engines_request_lane_out_int   = engines_request_lane_out[NUM_ENGINES-1];
    assign engines_request_memory_out_int = engines_request_memory_out[NUM_ENGINES-1];
    assign engines_fifo_request_lane_out_signals_in[NUM_ENGINES-1].rd_en = ~fifo_request_lane_out_signals_out_int.prog_full;
    assign engines_fifo_request_memory_out_signals_in[NUM_ENGINES-1].rd_en = ~fifo_request_memory_out_signals_out_int.prog_full;

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< NUM_ENGINES; i++) begin : generate_bundles
            engine_template #(
                .ID_CU                    (ID_CU                    ),
                .ID_BUNDLE                (ID_BUNDLE                ),
                .ID_LANE                  (ID_LANE                  ),
                .ID_ENGINE                (i                        ),
                .ENGINES_CONFIG           (ENGINES_CONFIG_ARRAY[i]  ),
                .NUM_BUNDLES              (NUM_BUNDLES              ),
                .NUM_LANES                (NUM_LANES                ),
                .NUM_ENGINES              (NUM_ENGINES              ),
                .LANES_COUNT_ARRAY        (LANES_COUNT_ARRAY        ),
                .ENGINES_COUNT_ARRAY      (ENGINES_COUNT_ARRAY      ),
                .LANES_ENGINES_COUNT_ARRAY(LANES_ENGINES_COUNT_ARRAY),
                .ENGINES_CONFIG_ARRAY     (ENGINES_CONFIG_ARRAY     ),
                .LANES_CONFIG_ARRAY       (LANES_CONFIG_ARRAY       ),
                .BUNDLES_CONFIG_ARRAY     (BUNDLES_CONFIG_ARRAY     )
            ) inst_engine_template (
                .ap_clk                             (ap_clk                                        ),
                .areset                             (areset_engine[i]                              ),
                .descriptor_in                      (engines_descriptor_in[i]                      ),
                .response_engine_in                 (engines_response_lane_in[i]                   ),
                .fifo_response_engine_in_signals_in (engines_fifo_response_lane_in_signals_in[i]   ),
                .fifo_response_engine_in_signals_out(engines_fifo_response_lane_in_signals_out[i]  ),
                .response_memory_in                 (engines_response_memory_in[i]                 ),
                .fifo_response_memory_in_signals_in (engines_fifo_response_memory_in_signals_in[i] ),
                .fifo_response_memory_in_signals_out(engines_fifo_response_memory_in_signals_out[i]),
                .request_engine_out                 (engines_request_lane_out[i]                   ),
                .fifo_request_engine_out_signals_in (engines_fifo_request_lane_out_signals_in[i]   ),
                .fifo_request_engine_out_signals_out(engines_fifo_request_lane_out_signals_out[i]  ),
                .request_memory_out                 (engines_request_memory_out[i]                 ),
                .fifo_request_memory_out_signals_in (engines_fifo_request_memory_out_signals_in[i] ),
                .fifo_request_memory_out_signals_out(engines_fifo_request_memory_out_signals_out[i]),
                .fifo_setup_signal                  (engines_fifo_setup_signal[i]                  ),
                .done_out                           (engines_done_out[i]                           )
            );
        end
    endgenerate

endmodule : lane_template