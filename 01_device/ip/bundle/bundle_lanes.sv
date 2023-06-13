// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : bundle_lanes.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-06-12 19:42:25
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

module bundle_lanes #(
    parameter ID_CU     = 0,
    parameter ID_BUNDLE = 0,
    parameter NUM_LANES = 6
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  MemoryPacket           response_engine_in                 ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output MemoryPacket           request_engine_out                 ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out,
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
    logic areset_lanes;
    logic areset_fifo ;

    KernelDescriptor descriptor_in_reg;

    MemoryPacket request_memory_out_reg;
    MemoryPacket response_engine_in_reg;
    MemoryPacket response_memory_in_reg;

    MemoryPacket request_engine_out_int;
    MemoryPacket request_memory_out_int;
    MemoryPacket response_engine_in_int;
    MemoryPacket response_memory_in_int;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_engine_in_din             ;
    MemoryPacketPayload    fifo_response_engine_in_dout            ;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_engine_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_engine_in_signals_out_int ;
    logic                  fifo_response_engine_in_setup_signal_int;

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
// FIFO Engine OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_engine_out_din             ;
    MemoryPacketPayload    fifo_request_engine_out_dout            ;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_engine_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_engine_out_signals_out_int ;
    logic                  fifo_request_engine_out_setup_signal_int;

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
// Generate Lanes - Arbiter Signals: Engine Request Generator
// --------------------------------------------------------------------------------------
    logic                  areset_arbiter_N_to_1_engine                                      ;
    MemoryPacket           lane_arbiter_N_to_1_engine_request_in              [NUM_LANES-1:0];
    FIFOStateSignalsInput  lane_arbiter_N_to_1_engine_fifo_request_signals_in                ;
    FIFOStateSignalsOutput lane_arbiter_N_to_1_engine_fifo_request_signals_out               ;
    logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_engine_arbiter_request_in                     ;
    logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_engine_arbiter_grant_out                      ;
    MemoryPacket           lane_arbiter_N_to_1_engine_request_out                            ;
    logic                  lane_arbiter_N_to_1_engine_fifo_setup_signal                      ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Engine Response Generator
// --------------------------------------------------------------------------------------
    logic                  areset_arbiter_1_to_N_engine                                       ;
    MemoryPacket           lane_arbiter_1_to_N_engine_response_in                             ;
    FIFOStateSignalsInput  lane_arbiter_1_to_N_engine_fifo_response_signals_in [NUM_LANES-1:0];
    FIFOStateSignalsOutput lane_arbiter_1_to_N_engine_fifo_response_signals_out               ;
    MemoryPacket           lane_arbiter_1_to_N_engine_response_out             [NUM_LANES-1:0];
    logic                  lane_arbiter_1_to_N_engine_fifo_setup_signal                       ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    logic                  areset_arbiter_N_to_1_memory                                      ;
    MemoryPacket           lane_arbiter_N_to_1_memory_request_in              [NUM_LANES-1:0];
    FIFOStateSignalsInput  lane_arbiter_N_to_1_memory_fifo_request_signals_in                ;
    FIFOStateSignalsOutput lane_arbiter_N_to_1_memory_fifo_request_signals_out               ;
    logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_memory_arbiter_request_in                     ;
    logic [NUM_LANES-1:0]  lane_arbiter_N_to_1_memory_arbiter_grant_out                      ;
    MemoryPacket           lane_arbiter_N_to_1_memory_request_out                            ;
    logic                  lane_arbiter_N_to_1_memory_fifo_setup_signal                      ;

// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    logic                  areset_arbiter_1_to_N_memory                                       ;
    MemoryPacket           lane_arbiter_1_to_N_memory_response_in                             ;
    FIFOStateSignalsInput  lane_arbiter_1_to_N_memory_fifo_response_signals_in [NUM_LANES-1:0];
    FIFOStateSignalsOutput lane_arbiter_1_to_N_memory_fifo_response_signals_out               ;
    MemoryPacket           lane_arbiter_1_to_N_memory_response_out             [NUM_LANES-1:0];
    logic                  lane_arbiter_1_to_N_memory_fifo_setup_signal                       ;

// --------------------------------------------------------------------------------------
// Generate Lanes
// --------------------------------------------------------------------------------------
    logic                  lanes_areset                             [NUM_LANES-1:0];
    KernelDescriptor       lanes_descriptor_in                      [NUM_LANES-1:0];
    MemoryPacket           lanes_response_engine_in                 [NUM_LANES-1:0];
    FIFOStateSignalsInput  lanes_fifo_response_engine_in_signals_in [NUM_LANES-1:0];
    FIFOStateSignalsOutput lanes_fifo_response_engine_in_signals_out[NUM_LANES-1:0];
    MemoryPacket           lanes_response_memory_in                 [NUM_LANES-1:0];
    FIFOStateSignalsInput  lanes_fifo_response_memory_in_signals_in [NUM_LANES-1:0];
    FIFOStateSignalsOutput lanes_fifo_response_memory_in_signals_out[NUM_LANES-1:0];
    MemoryPacket           lanes_request_engine_out                 [NUM_LANES-1:0];
    FIFOStateSignalsInput  lanes_fifo_request_engine_out_signals_in [NUM_LANES-1:0];
    FIFOStateSignalsOutput lanes_fifo_request_engine_out_signals_out[NUM_LANES-1:0];
    MemoryPacket           lanes_request_memory_out                 [NUM_LANES-1:0];
    FIFOStateSignalsInput  lanes_fifo_request_memory_out_signals_in [NUM_LANES-1:0];
    FIFOStateSignalsOutput lanes_fifo_request_memory_out_signals_out[NUM_LANES-1:0];
    logic                  lanes_fifo_setup_signal                  [NUM_LANES-1:0];
    logic                  lanes_done_out                           [NUM_LANES-1:0];

    logic [NUM_LANES-1:0] lanes_fifo_setup_signal_reg;
    logic [NUM_LANES-1:0] lanes_done_out_reg         ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_lanes                 <= areset;
        areset_fifo                  <= areset;
        areset_arbiter_N_to_1_engine <= areset;
        areset_arbiter_1_to_N_engine <= areset;
        areset_arbiter_N_to_1_memory <= areset;
        areset_arbiter_1_to_N_memory <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_lanes) begin
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
        if (areset_lanes) begin
            fifo_response_engine_in_signals_in_reg <= 0;
            fifo_request_engine_out_signals_in_reg <= 0;
            fifo_response_memory_in_signals_in_reg <= 0;
            fifo_request_memory_out_signals_in_reg <= 0;
            response_engine_in_reg.valid           <= 1'b0;
            response_memory_in_reg.valid           <= 1'b0;
        end
        else begin
            fifo_response_engine_in_signals_in_reg <= fifo_response_engine_in_signals_in;
            fifo_request_engine_out_signals_in_reg <= fifo_request_engine_out_signals_in;
            fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
            fifo_request_memory_out_signals_in_reg <= fifo_request_memory_out_signals_in;
            response_engine_in_reg.valid           <= response_engine_in.valid;
            response_memory_in_reg.valid           <= response_memory_in.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_engine_in_reg.payload <= response_engine_in.payload;
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_lanes) begin
            fifo_setup_signal        <= 1'b1;
            request_engine_out.valid <= 1'b0;
            request_memory_out.valid <= 1'b0 ;
        end
        else begin
            fifo_setup_signal        <= fifo_response_engine_in_setup_signal_int | fifo_response_memory_in_setup_signal_int | fifo_request_engine_out_setup_signal_int | fifo_request_memory_out_setup_signal_int | (|lanes_fifo_setup_signal_reg);
            request_engine_out.valid <= request_engine_out_int.valid ;
            request_memory_out.valid <= request_memory_out_int.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_engine_in_signals_out <= fifo_response_engine_in_signals_out_int;
        fifo_request_engine_out_signals_out <= fifo_request_engine_out_signals_out_int;
        fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_int;
        fifo_request_memory_out_signals_out <= fifo_request_memory_out_signals_out_int;
        request_engine_out.payload          <= request_engine_out_int.payload;
        request_memory_out.payload          <= request_memory_out_int.payload ;
    end

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_engine_in_setup_signal_int = fifo_response_engine_in_signals_out_int.wr_rst_busy | fifo_response_engine_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_engine_in_signals_in_int.wr_en = response_engine_in_reg.valid;
    assign fifo_response_engine_in_din                  = response_engine_in_reg.payload;

    // Pop
    assign fifo_response_engine_in_signals_in_int.rd_en = ~fifo_response_engine_in_signals_out_int.empty & fifo_response_engine_in_signals_in_reg.rd_en;;
    assign response_engine_in_int.valid                 = fifo_response_engine_in_signals_out_int.valid;
    assign response_engine_in_int.payload               = fifo_response_engine_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponseEngineInput (
        .clk         (ap_clk                                              ),
        .srst        (areset_fifo                                         ),
        .din         (fifo_response_engine_in_din                         ),
        .wr_en       (fifo_response_engine_in_signals_in_int.wr_en        ),
        .rd_en       (fifo_response_engine_in_signals_in_int.rd_en        ),
        .dout        (fifo_response_engine_in_dout                        ),
        .full        (fifo_response_engine_in_signals_out_int.full        ),
        .almost_full (fifo_response_engine_in_signals_out_int.almost_full ),
        .empty       (fifo_response_engine_in_signals_out_int.empty       ),
        .almost_empty(fifo_response_engine_in_signals_out_int.almost_empty),
        .valid       (fifo_response_engine_in_signals_out_int.valid       ),
        .prog_full   (fifo_response_engine_in_signals_out_int.prog_full   ),
        .prog_empty  (fifo_response_engine_in_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_response_engine_in_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_response_engine_in_signals_out_int.rd_rst_busy )
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
    assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en;;
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
// FIFO OUTPUT Engine requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_engine_out_setup_signal_int = fifo_request_engine_out_signals_out_int.wr_rst_busy | fifo_request_engine_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_engine_out_signals_in_int.wr_en = 1'b0;
    assign fifo_request_engine_out_din                  = 0;

    // Pop
    assign fifo_request_engine_out_signals_in_int.rd_en = ~fifo_request_engine_out_signals_out_int.empty & fifo_request_engine_out_signals_in_reg.rd_en;
    assign request_engine_out_int.valid                 = fifo_request_engine_out_signals_out_int.valid;
    assign request_engine_out_int.payload               = fifo_request_engine_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequestEngineOutput (
        .clk         (ap_clk                                              ),
        .srst        (areset_fifo                                         ),
        .din         (fifo_request_engine_out_din                         ),
        .wr_en       (fifo_request_engine_out_signals_in_int.wr_en        ),
        .rd_en       (fifo_request_engine_out_signals_in_int.rd_en        ),
        .dout        (fifo_request_engine_out_dout                        ),
        .full        (fifo_request_engine_out_signals_out_int.full        ),
        .almost_full (fifo_request_engine_out_signals_out_int.almost_full ),
        .empty       (fifo_request_engine_out_signals_out_int.empty       ),
        .almost_empty(fifo_request_engine_out_signals_out_int.almost_empty),
        .valid       (fifo_request_engine_out_signals_out_int.valid       ),
        .prog_full   (fifo_request_engine_out_signals_out_int.prog_full   ),
        .prog_empty  (fifo_request_engine_out_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_request_engine_out_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_request_engine_out_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_memory_out_signals_in_int.wr_en = 1'b0;
    assign fifo_request_memory_out_din                  = 0;

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
// Generate Lanes Arbitration|Instants|Signals
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Generate Lanes - Drive input signals
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< NUM_LANES; i++) begin : generate_bundle_reg_input
            always_ff @(posedge ap_clk) begin
                lanes_areset[i] <= areset;
            end

            always_ff @(posedge ap_clk) begin
                if (areset_lanes) begin
                    lanes_descriptor_in[i].valid <= 0;
                end
                else begin
                    lanes_descriptor_in[i].valid <= descriptor_in_reg.valid;
                end
            end

            always_ff @(posedge ap_clk) begin
                lanes_descriptor_in[i].payload <= descriptor_in_reg.payload;
            end
        end
    endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes - Drive output signals
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< NUM_LANES; i++) begin : generate_bundle_reg_output
            always_ff @(posedge ap_clk) begin
                if (areset_lanes) begin
                    lanes_fifo_setup_signal_reg[i] <= 1'b1;
                    lanes_done_out_reg[i]          <= 1'b1;
                end
                else begin
                    lanes_fifo_setup_signal_reg[i] <= lanes_fifo_setup_signal[i];
                    lanes_done_out_reg[i]          <= lanes_done_out[i];
                end
            end
        end
    endgenerate

// --------------------------------------------------------------------------------------
// Generate Lanes - Engine Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Engine Request Generator
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_N_to_1_engine_request_in
            assign lane_arbiter_N_to_1_engine_request_in[i]         = lanes_request_engine_out[i];
            assign lane_arbiter_N_to_1_engine_arbiter_request_in[i] = ~lanes_fifo_request_engine_out_signals_out[i].empty & ~lane_arbiter_N_to_1_engine_fifo_request_signals_out.prog_full;
            assign lanes_fifo_request_engine_out_signals_in[i].rd_en  = ~lane_arbiter_N_to_1_engine_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_engine_arbiter_grant_out[i];
        end
    endgenerate

    assign lane_arbiter_N_to_1_engine_fifo_request_signals_in.rd_en = ~fifo_request_engine_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_LANES)) inst_lane_arbiter_N_to_1_engine_request_out (
        .ap_clk                  (ap_clk                                             ),
        .areset                  (areset_arbiter_N_to_1_engine                       ),
        .request_in              (lane_arbiter_N_to_1_engine_request_in              ),
        .fifo_request_signals_in (lane_arbiter_N_to_1_engine_fifo_request_signals_in ),
        .fifo_request_signals_out(lane_arbiter_N_to_1_engine_fifo_request_signals_out),
        .arbiter_request_in      (lane_arbiter_N_to_1_engine_arbiter_request_in      ),
        .arbiter_grant_out       (lane_arbiter_N_to_1_engine_arbiter_grant_out       ),
        .request_out             (lane_arbiter_N_to_1_engine_request_out             ),
        .fifo_setup_signal       (lane_arbiter_N_to_1_engine_fifo_setup_signal       )
    );

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Engine Response Generator
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_1_to_N_engine_response
            assign lane_arbiter_1_to_N_engine_response_in[i] = response_engine_in_int;
            assign lane_arbiter_1_to_N_engine_fifo_response_signals_in[i].rd_en = ~lanes_fifo_response_engine_in_signals_out[i].prog_full;

            assign lanes_response_engine_in[i] = lane_arbiter_1_to_N_engine_response_out[i];
            assign lanes_fifo_response_engine_in_signals_in[i].rd_en = 1'b1;
        end
    endgenerate

// --------------------------------------------------------------------------------------
    arbiter_1_to_N_response #(.NUM_MEMORY_REQUESTOR(NUM_LANES)) inst_lane_arbiter_1_to_N_engine_response_in (
        .ap_clk                   (ap_clk                                              ),
        .areset                   (areset_arbiter_1_to_N_engine                        ),
        .response_in              (lane_arbiter_1_to_N_engine_response_in              ),
        .fifo_response_signals_in (lane_arbiter_1_to_N_engine_fifo_response_signals_in ),
        .fifo_response_signals_out(lane_arbiter_1_to_N_engine_fifo_response_signals_out),
        .response_out             (lane_arbiter_1_to_N_engine_response_out             ),
        .fifo_setup_signal        (lane_arbiter_1_to_N_engine_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Lanes - Memory Arbitration
// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_N_to_1_memory_request_in
            assign lane_arbiter_N_to_1_memory_request_in[i]         = lanes_request_memory_out[i];
            assign lane_arbiter_N_to_1_memory_arbiter_request_in[i] = ~lanes_fifo_request_memory_out_signals_out[i].empty & ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full;
            assign lanes_fifo_request_memory_out_signals_in[i].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_arbiter_grant_out[i];
        end
    endgenerate

    assign lane_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = ~fifo_request_memory_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_LANES)) inst_lane_arbiter_N_to_1_memory_request_out (
        .ap_clk                  (ap_clk                                             ),
        .areset                  (areset_arbiter_N_to_1_memory                       ),
        .request_in              (lane_arbiter_N_to_1_memory_request_in              ),
        .fifo_request_signals_in (lane_arbiter_N_to_1_memory_fifo_request_signals_in ),
        .fifo_request_signals_out(lane_arbiter_N_to_1_memory_fifo_request_signals_out),
        .arbiter_request_in      (lane_arbiter_N_to_1_memory_arbiter_request_in      ),
        .arbiter_grant_out       (lane_arbiter_N_to_1_memory_arbiter_grant_out       ),
        .request_out             (lane_arbiter_N_to_1_memory_request_out             ),
        .fifo_setup_signal       (lane_arbiter_N_to_1_memory_fifo_setup_signal       )
    );

// --------------------------------------------------------------------------------------
// Generate Lanes - Signals
// --------------------------------------------------------------------------------------
// Generate Lanes - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i<NUM_LANES; i++) begin : generate_lane_arbiter_1_to_N_memory_response
            assign lane_arbiter_1_to_N_memory_response_in[i] = response_memory_in_int;
            assign lane_arbiter_1_to_N_memory_fifo_response_signals_in[i].rd_en = ~lanes_fifo_response_memory_in_signals_out[i].prog_full;

            assign lanes_response_memory_in[i] = lane_arbiter_1_to_N_memory_response_out[i];
            assign lanes_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
        end
    endgenerate

// --------------------------------------------------------------------------------------
    arbiter_1_to_N_response #(.NUM_MEMORY_REQUESTOR(NUM_LANES)) inst_lane_arbiter_1_to_N_memory_response_in (
        .ap_clk                   (ap_clk                                              ),
        .areset                   (areset_arbiter_1_to_N_memory                        ),
        .response_in              (lane_arbiter_1_to_N_memory_response_in              ),
        .fifo_response_signals_in (lane_arbiter_1_to_N_memory_fifo_response_signals_in ),
        .fifo_response_signals_out(lane_arbiter_1_to_N_memory_fifo_response_signals_out),
        .response_out             (lane_arbiter_1_to_N_memory_response_out             ),
        .fifo_setup_signal        (lane_arbiter_1_to_N_memory_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Lanes
// --------------------------------------------------------------------------------------

    lane_rw_merge_filter #(
        .ID_CU    (ID_CU    ),
        .ID_BUNDLE(ID_BUNDLE),
        .ID_LANE  (0        )
    ) inst_lane_rw_merge_filter_0 (
        .ap_clk                             (ap_clk                                      ),
        .areset                             (lanes_areset[0]                             ),
        .descriptor_in                      (lanes_descriptor_in[0]                      ),
        .response_engine_in                 (lanes_response_engine_in[0]                 ),
        .fifo_response_engine_in_signals_in (lanes_fifo_response_engine_in_signals_in[0] ),
        .fifo_response_engine_in_signals_out(lanes_fifo_response_engine_in_signals_out[0]),
        .response_memory_in                 (lanes_response_memory_in[0]                 ),
        .fifo_response_memory_in_signals_in (lanes_fifo_response_memory_in_signals_in[0] ),
        .fifo_response_memory_in_signals_out(lanes_fifo_response_memory_in_signals_out[0]),
        .request_engine_out                 (lanes_request_engine_out[0]                 ),
        .fifo_request_engine_out_signals_in (lanes_fifo_request_engine_out_signals_in[0] ),
        .fifo_request_engine_out_signals_out(lanes_fifo_request_engine_out_signals_out[0]),
        .request_memory_out                 (lanes_request_memory_out[0]                 ),
        .fifo_request_memory_out_signals_in (lanes_fifo_request_memory_out_signals_in[0] ),
        .fifo_request_memory_out_signals_out(lanes_fifo_request_memory_out_signals_out[0]),
        .fifo_setup_signal                  (lanes_fifo_setup_signal[0]                  ),
        .done_out                           (lanes_done_out[0]                           )
    );
    lane_rw_merge_filter #(
        .ID_CU    (ID_CU    ),
        .ID_BUNDLE(ID_BUNDLE),
        .ID_LANE  (1        )
    ) inst_lane_rw_merge_filter_1 (
        .ap_clk                             (ap_clk                                      ),
        .areset                             (lanes_areset[1]                             ),
        .descriptor_in                      (lanes_descriptor_in[1]                      ),
        .response_engine_in                 (lanes_response_engine_in[1]                 ),
        .fifo_response_engine_in_signals_in (lanes_fifo_response_engine_in_signals_in[1] ),
        .fifo_response_engine_in_signals_out(lanes_fifo_response_engine_in_signals_out[1]),
        .response_memory_in                 (lanes_response_memory_in[1]                 ),
        .fifo_response_memory_in_signals_in (lanes_fifo_response_memory_in_signals_in[1] ),
        .fifo_response_memory_in_signals_out(lanes_fifo_response_memory_in_signals_out[1]),
        .request_engine_out                 (lanes_request_engine_out[1]                 ),
        .fifo_request_engine_out_signals_in (lanes_fifo_request_engine_out_signals_in[1] ),
        .fifo_request_engine_out_signals_out(lanes_fifo_request_engine_out_signals_out[1]),
        .request_memory_out                 (lanes_request_memory_out[1]                 ),
        .fifo_request_memory_out_signals_in (lanes_fifo_request_memory_out_signals_in[1] ),
        .fifo_request_memory_out_signals_out(lanes_fifo_request_memory_out_signals_out[1]),
        .fifo_setup_signal                  (lanes_fifo_setup_signal[1]                  ),
        .done_out                           (lanes_done_out[1]                           )
    );
    lane_rw_merge_filter #(
        .ID_CU    (ID_CU    ),
        .ID_BUNDLE(ID_BUNDLE),
        .ID_LANE  (2        )
    ) inst_lane_rw_merge_filter_2 (
        .ap_clk                             (ap_clk                                      ),
        .areset                             (lanes_areset[2]                             ),
        .descriptor_in                      (lanes_descriptor_in[2]                      ),
        .response_engine_in                 (lanes_response_engine_in[2]                 ),
        .fifo_response_engine_in_signals_in (lanes_fifo_response_engine_in_signals_in[2] ),
        .fifo_response_engine_in_signals_out(lanes_fifo_response_engine_in_signals_out[2]),
        .response_memory_in                 (lanes_response_memory_in[2]                 ),
        .fifo_response_memory_in_signals_in (lanes_fifo_response_memory_in_signals_in[2] ),
        .fifo_response_memory_in_signals_out(lanes_fifo_response_memory_in_signals_out[2]),
        .request_engine_out                 (lanes_request_engine_out[2]                 ),
        .fifo_request_engine_out_signals_in (lanes_fifo_request_engine_out_signals_in[2] ),
        .fifo_request_engine_out_signals_out(lanes_fifo_request_engine_out_signals_out[2]),
        .request_memory_out                 (lanes_request_memory_out[2]                 ),
        .fifo_request_memory_out_signals_in (lanes_fifo_request_memory_out_signals_in[2] ),
        .fifo_request_memory_out_signals_out(lanes_fifo_request_memory_out_signals_out[2]),
        .fifo_setup_signal                  (lanes_fifo_setup_signal[2]                  ),
        .done_out                           (lanes_done_out[2]                           )
    );
    lane_csr_merge_filter #(
        .ID_CU    (ID_CU    ),
        .ID_BUNDLE(ID_BUNDLE),
        .ID_LANE  (3        )
    ) inst_lane_csr_merge_filter (
        .ap_clk                             (ap_clk                                      ),
        .areset                             (lanes_areset[3]                             ),
        .descriptor_in                      (lanes_descriptor_in[3]                      ),
        .response_engine_in                 (lanes_response_engine_in[3]                 ),
        .fifo_response_engine_in_signals_in (lanes_fifo_response_engine_in_signals_in[3] ),
        .fifo_response_engine_in_signals_out(lanes_fifo_response_engine_in_signals_out[3]),
        .response_memory_in                 (lanes_response_memory_in[3]                 ),
        .fifo_response_memory_in_signals_in (lanes_fifo_response_memory_in_signals_in[3] ),
        .fifo_response_memory_in_signals_out(lanes_fifo_response_memory_in_signals_out[3]),
        .request_engine_out                 (lanes_request_engine_out[3]                 ),
        .fifo_request_engine_out_signals_in (lanes_fifo_request_engine_out_signals_in[3] ),
        .fifo_request_engine_out_signals_out(lanes_fifo_request_engine_out_signals_out[3]),
        .request_memory_out                 (lanes_request_memory_out[3]                 ),
        .fifo_request_memory_out_signals_in (lanes_fifo_request_memory_out_signals_in[3] ),
        .fifo_request_memory_out_signals_out(lanes_fifo_request_memory_out_signals_out[3]),
        .fifo_setup_signal                  (lanes_fifo_setup_signal[3]                  ),
        .done_out                           (lanes_done_out[3]                           )
    );
    lane_alu_filter #(
        .ID_CU    (ID_CU    ),
        .ID_BUNDLE(ID_BUNDLE),
        .ID_LANE  (4        )
    ) inst_lane_alu_filter (
        .ap_clk                             (ap_clk                                      ),
        .areset                             (lanes_areset[4]                             ),
        .descriptor_in                      (lanes_descriptor_in[4]                      ),
        .response_engine_in                 (lanes_response_engine_in[4]                 ),
        .fifo_response_engine_in_signals_in (lanes_fifo_response_engine_in_signals_in[4] ),
        .fifo_response_engine_in_signals_out(lanes_fifo_response_engine_in_signals_out[4]),
        .response_memory_in                 (lanes_response_memory_in[4]                 ),
        .fifo_response_memory_in_signals_in (lanes_fifo_response_memory_in_signals_in[4] ),
        .fifo_response_memory_in_signals_out(lanes_fifo_response_memory_in_signals_out[4]),
        .request_engine_out                 (lanes_request_engine_out[4]                 ),
        .fifo_request_engine_out_signals_in (lanes_fifo_request_engine_out_signals_in[4] ),
        .fifo_request_engine_out_signals_out(lanes_fifo_request_engine_out_signals_out[4]),
        .request_memory_out                 (lanes_request_memory_out[4]                 ),
        .fifo_request_memory_out_signals_in (lanes_fifo_request_memory_out_signals_in[4] ),
        .fifo_request_memory_out_signals_out(lanes_fifo_request_memory_out_signals_out[4]),
        .fifo_setup_signal                  (lanes_fifo_setup_signal[4]                  ),
        .done_out                           (lanes_done_out[4]                           )
    );
    lane_buffer_filter #(
        .ID_CU    (ID_CU    ),
        .ID_BUNDLE(ID_BUNDLE),
        .ID_LANE  (5        )
    ) inst_lane_buffer_filter (
        .ap_clk                             (ap_clk                                      ),
        .areset                             (lanes_areset[5]                             ),
        .descriptor_in                      (lanes_descriptor_in[5]                      ),
        .response_engine_in                 (lanes_response_engine_in[5]                 ),
        .fifo_response_engine_in_signals_in (lanes_fifo_response_engine_in_signals_in[5] ),
        .fifo_response_engine_in_signals_out(lanes_fifo_response_engine_in_signals_out[5]),
        .response_memory_in                 (lanes_response_memory_in[5]                 ),
        .fifo_response_memory_in_signals_in (lanes_fifo_response_memory_in_signals_in[5] ),
        .fifo_response_memory_in_signals_out(lanes_fifo_response_memory_in_signals_out[5]),
        .request_engine_out                 (lanes_request_engine_out[5]                 ),
        .fifo_request_engine_out_signals_in (lanes_fifo_request_engine_out_signals_in[5] ),
        .fifo_request_engine_out_signals_out(lanes_fifo_request_engine_out_signals_out[5]),
        .request_memory_out                 (lanes_request_memory_out[5]                 ),
        .fifo_request_memory_out_signals_in (lanes_fifo_request_memory_out_signals_in[5] ),
        .fifo_request_memory_out_signals_out(lanes_fifo_request_memory_out_signals_out[5]),
        .fifo_setup_signal                  (lanes_fifo_setup_signal[5]                  ),
        .done_out                           (lanes_done_out[5]                           )
    );

endmodule : bundle_lanes