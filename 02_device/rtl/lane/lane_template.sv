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
// Revise : 2023-08-28 14:16:13
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
    `include "lane_parameters.vh"
    ) (
    // System Signals
    input  logic                  ap_clk                                                     ,
    input  logic                  areset                                                     ,
    input  KernelDescriptor       descriptor_in                                              ,
    input  MemoryPacket           response_lane_in[(1+LANE_MERGE_WIDTH)-1:0]                 ,
    input  FIFOStateSignalsInput  fifo_response_lane_in_signals_in[(1+LANE_MERGE_WIDTH)-1:0] ,
    output FIFOStateSignalsOutput fifo_response_lane_in_signals_out[(1+LANE_MERGE_WIDTH)-1:0],
    input  MemoryPacket           response_memory_in                                         ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                         ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                        ,
    output MemoryPacket           request_lane_out[ (1+LANE_CAST_WIDTH)-1:0]                 ,
    input  FIFOStateSignalsInput  fifo_request_lane_out_signals_in[ (1+LANE_CAST_WIDTH)-1:0] ,
    output FIFOStateSignalsOutput fifo_request_lane_out_signals_out[ (1+LANE_CAST_WIDTH)-1:0],
    output MemoryPacket           request_memory_out                                         ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                         ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                        ,
    output logic                  fifo_setup_signal                                          ,
    output logic                  done_out
);

    genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_lane_template;
    logic areset_fifo         ;

    KernelDescriptor descriptor_in_reg;

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
// Generate Engines - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    logic                   areset_engine_arbiter_N_to_1_memory                                    ;
    MemoryPacket            engine_arbiter_N_to_1_memory_request_in               [NUM_ENGINES-1:0];
    FIFOStateSignalsInput   engine_arbiter_N_to_1_memory_fifo_request_signals_in                   ;
    FIFOStateSignalsOutput  engine_arbiter_N_to_1_memory_fifo_request_signals_out                  ;
    logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_memory_engine_arbiter_request_in                 ;
    logic [NUM_ENGINES-1:0] engine_arbiter_N_to_1_memory_engine_arbiter_grant_out                  ;
    MemoryPacket            engine_arbiter_N_to_1_memory_request_out                               ;
    logic                   engine_arbiter_N_to_1_memory_fifo_setup_signal                         ;

// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    logic                  areset_engine_arbiter_1_to_N_memory                                    ;
    MemoryPacket           engine_arbiter_1_to_N_memory_response_in                               ;
    FIFOStateSignalsInput  engine_arbiter_1_to_N_memory_fifo_response_signals_in [NUM_ENGINES-1:0];
    FIFOStateSignalsOutput engine_arbiter_1_to_N_memory_fifo_response_signals_out                 ;
    MemoryPacket           engine_arbiter_1_to_N_memory_response_out             [NUM_ENGINES-1:0];
    logic                  engine_arbiter_1_to_N_memory_fifo_setup_signal                         ;

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
        areset_lane_template                <= areset;
        areset_fifo                         <= areset;
        areset_engine_arbiter_N_to_1_memory <= areset;
        areset_engine_arbiter_1_to_N_memory <= areset;
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
            fifo_response_lane_in_signals_in_reg   <= fifo_response_lane_in_signals_in[0];
            fifo_request_lane_out_signals_in_reg   <= fifo_request_lane_out_signals_in[0];
            fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
            fifo_request_memory_out_signals_in_reg <= fifo_request_memory_out_signals_in;
            response_lane_in_reg.valid             <= response_lane_in[0].valid;
            response_memory_in_reg.valid           <= response_memory_in.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_lane_in_reg.payload   <= response_lane_in[0].payload;
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_lane_template) begin
            fifo_setup_signal         <= 1'b1;
            request_lane_out[0].valid <= 1'b0;
            request_memory_out.valid  <= 1'b0;
            done_out                  <= 1'b1;
        end
        else begin
            fifo_setup_signal         <= fifo_response_lane_in_setup_signal_int | fifo_response_memory_in_setup_signal_int | fifo_request_lane_out_setup_signal_int | fifo_request_memory_out_setup_signal_int | (|engines_fifo_setup_signal_reg);
            request_lane_out[0].valid <= request_lane_out_int.valid ;
            request_memory_out.valid  <= request_memory_out_int.valid;
            done_out                  <= (&engines_done_out_reg);
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_lane_in_signals_out[0] <= fifo_response_lane_in_signals_out_int;
        fifo_request_lane_out_signals_out[0] <= fifo_request_lane_out_signals_out_int;
        fifo_response_memory_in_signals_out  <= fifo_response_memory_in_signals_out_int;
        fifo_request_memory_out_signals_out  <= fifo_request_memory_out_signals_out_int;
        request_lane_out[0].payload          <= request_lane_out_int.payload;
        request_memory_out.payload           <= request_memory_out_int.payload ;
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
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketResponseEnginesInput (
        .clk        (ap_clk                                           ),
        .srst       (areset_fifo                                      ),
        .din        (fifo_response_lane_in_din                        ),
        .wr_en      (fifo_response_lane_in_signals_in_int.wr_en       ),
        .rd_en      (fifo_response_lane_in_signals_in_int.rd_en       ),
        .dout       (fifo_response_lane_in_dout                       ),
        .full       (fifo_response_lane_in_signals_out_int.full       ),
        .empty      (fifo_response_lane_in_signals_out_int.empty      ),
        .valid      (fifo_response_lane_in_signals_out_int.valid      ),
        .prog_full  (fifo_response_lane_in_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_response_lane_in_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_response_lane_in_signals_out_int.rd_rst_busy)
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
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketResponseMemoryInput (
        .clk        (ap_clk                                             ),
        .srst       (areset_fifo                                        ),
        .din        (fifo_response_memory_in_din                        ),
        .wr_en      (fifo_response_memory_in_signals_in_int.wr_en       ),
        .rd_en      (fifo_response_memory_in_signals_in_int.rd_en       ),
        .dout       (fifo_response_memory_in_dout                       ),
        .full       (fifo_response_memory_in_signals_out_int.full       ),
        .empty      (fifo_response_memory_in_signals_out_int.empty      ),
        .valid      (fifo_response_memory_in_signals_out_int.valid      ),
        .prog_full  (fifo_response_memory_in_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_response_memory_in_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_response_memory_in_signals_out_int.rd_rst_busy)
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
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketRequestEnginesOutput (
        .clk        (ap_clk                                           ),
        .srst       (areset_fifo                                      ),
        .din        (fifo_request_lane_out_din                        ),
        .wr_en      (fifo_request_lane_out_signals_in_int.wr_en       ),
        .rd_en      (fifo_request_lane_out_signals_in_int.rd_en       ),
        .dout       (fifo_request_lane_out_dout                       ),
        .full       (fifo_request_lane_out_signals_out_int.full       ),
        .empty      (fifo_request_lane_out_signals_out_int.empty      ),
        .valid      (fifo_request_lane_out_signals_out_int.valid      ),
        .prog_full  (fifo_request_lane_out_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_request_lane_out_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_request_lane_out_signals_out_int.rd_rst_busy)
    );

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_memory_out_signals_in_int.wr_en = engine_arbiter_N_to_1_memory_request_out.valid;
    assign fifo_request_memory_out_din                  = engine_arbiter_N_to_1_memory_request_out.payload;

    // Pop
    assign fifo_request_memory_out_signals_in_int.rd_en = ~fifo_request_memory_out_signals_out_int.empty & fifo_request_memory_out_signals_in_reg.rd_en;
    assign request_memory_out_int.valid                 = fifo_request_memory_out_signals_out_int.valid;
    assign request_memory_out_int.payload               = fifo_request_memory_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (PROG_THRESH               )
    ) inst_fifo_MemoryPacketRequestMemoryOutput (
        .clk        (ap_clk                                             ),
        .srst       (areset_fifo                                        ),
        .din        (fifo_request_memory_out_din                        ),
        .wr_en      (fifo_request_memory_out_signals_in_int.wr_en       ),
        .rd_en      (fifo_request_memory_out_signals_in_int.rd_en       ),
        .dout       (fifo_request_memory_out_dout                       ),
        .full       (fifo_request_memory_out_signals_out_int.full       ),
        .empty      (fifo_request_memory_out_signals_out_int.empty      ),
        .valid      (fifo_request_memory_out_signals_out_int.valid      ),
        .prog_full  (fifo_request_memory_out_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_request_memory_out_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_request_memory_out_signals_out_int.rd_rst_busy)
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
    assign engines_fifo_response_lane_in_signals_in[0].rd_en = 1'b1;

    generate
        for (i=1; i<NUM_ENGINES; i++) begin : generate_lane_template_intra_signals
            assign engines_response_lane_in[i] = engines_request_lane_out[i-1];
            assign engines_fifo_request_lane_out_signals_in[i-1].rd_en = ~engines_fifo_response_lane_in_signals_out[i].prog_full;
            assign engines_fifo_response_lane_in_signals_in[i].rd_en = 1'b1;
        end
    endgenerate

    assign engines_request_lane_out_int = engines_request_lane_out[NUM_ENGINES-1];
    assign engines_fifo_request_lane_out_signals_in[NUM_ENGINES-1].rd_en = ~fifo_request_lane_out_signals_out_int.prog_full;

// --------------------------------------------------------------------------------------
// Generate Engines - Memory Arbitration
// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_N_to_1_memory_request_in
            assign engine_arbiter_N_to_1_memory_request_in[i]                = engines_request_memory_out[i];
            assign engine_arbiter_N_to_1_memory_engine_arbiter_request_in[i] = ~engines_fifo_request_memory_out_signals_out[i].empty & ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full;
            assign engines_fifo_request_memory_out_signals_in[i].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[i];
        end
    endgenerate

    assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = ~fifo_request_memory_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(NUM_ENGINES)) inst_engine_arbiter_N_to_1_memory_request_out (
        .ap_clk                  (ap_clk                                                ),
        .areset                  (areset_engine_arbiter_N_to_1_memory                   ),
        .request_in              (engine_arbiter_N_to_1_memory_request_in               ),
        .fifo_request_signals_in (engine_arbiter_N_to_1_memory_fifo_request_signals_in  ),
        .fifo_request_signals_out(engine_arbiter_N_to_1_memory_fifo_request_signals_out ),
        .arbiter_request_in      (engine_arbiter_N_to_1_memory_engine_arbiter_request_in),
        .arbiter_grant_out       (engine_arbiter_N_to_1_memory_engine_arbiter_grant_out ),
        .request_out             (engine_arbiter_N_to_1_memory_request_out              ),
        .fifo_setup_signal       (engine_arbiter_N_to_1_memory_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Engines - Signals
// --------------------------------------------------------------------------------------
// Generate Engines - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    assign engine_arbiter_1_to_N_memory_response_in = response_memory_in_int;
    generate
        for (i=0; i<NUM_ENGINES; i++) begin : generate_engine_arbiter_1_to_N_memory_response
            assign engine_arbiter_1_to_N_memory_fifo_response_signals_in[i].rd_en = ~engines_fifo_response_memory_in_signals_out[i].prog_full;
            assign engines_response_memory_in[i] = engine_arbiter_1_to_N_memory_response_out[i];
            assign engines_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
        end
    endgenerate

// --------------------------------------------------------------------------------------
    arbiter_1_to_N_response #(
        .NUM_MEMORY_REQUESTOR(NUM_ENGINES),
        .ID_LEVEL            (3          )
    ) inst_engine_arbiter_1_to_N_memory_response_in (
        .ap_clk                   (ap_clk                                                ),
        .areset                   (areset_engine_arbiter_1_to_N_memory                   ),
        .response_in              (engine_arbiter_1_to_N_memory_response_in              ),
        .fifo_response_signals_in (engine_arbiter_1_to_N_memory_fifo_response_signals_in ),
        .fifo_response_signals_out(engine_arbiter_1_to_N_memory_fifo_response_signals_out),
        .response_out             (engine_arbiter_1_to_N_memory_response_out             ),
        .fifo_setup_signal        (engine_arbiter_1_to_N_memory_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< NUM_ENGINES; i++) begin : generate_engine_template
            engine_template #(
                `include"set_engine_parameters.vh"
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


    MemoryPacket           engines_response_merge_engine_in               [NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];
    FIFOStateSignalsInput  engines_fifo_response_merge_lane_in_signals_in [NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];
    FIFOStateSignalsOutput engines_fifo_response_merge_lane_in_signals_out[NUM_ENGINES-1:0][(1+ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY)-1:0];
    MemoryPacket           engines_request_cast_lane_out                  [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
    FIFOStateSignalsInput  engines_fifo_request_cast_lane_out_signals_in  [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];
    FIFOStateSignalsOutput engines_fifo_request_cast_lane_out_signals_out [NUM_ENGINES-1:0][ (1+ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY)-1:0];

endmodule : lane_template


    // MemoryPacket           lanes_response_merge_engine_in               [NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0];
    // FIFOStateSignalsInput  lanes_fifo_response_merge_lane_in_signals_in [NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0];
    // FIFOStateSignalsOutput lanes_fifo_response_merge_lane_in_signals_out[NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0];
    // MemoryPacket           lanes_request_cast_lane_out                  [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:0];
    // FIFOStateSignalsInput  lanes_fifo_request_cast_lane_out_signals_in  [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:0];
    // FIFOStateSignalsOutput lanes_fifo_request_cast_lane_out_signals_out [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:0];

// always_comb begin : generate_lane_topology
//     int lane_merge,lane_cast,engine_idx,cast_idx,merge_count= 0;
//     integer cast_count[0:NUM_LANES] = '{default: 0};

//     for (lane_merge=0; lane_merge< NUM_LANES; lane_merge++) begin

//         lanes_response_merge_engine_in[lane_merge][0]               = lanes_response_engine_in[lane_merge];
//         lanes_fifo_response_merge_lane_in_signals_in[lane_merge][0] = lanes_fifo_response_lane_in_signals_in[lane_merge];
//         lanes_fifo_response_lane_in_signals_out[lane_merge]         = lanes_fifo_response_merge_lane_in_signals_out[lane_merge][0];

//         lanes_request_lane_out[lane_merge]                         = lanes_request_cast_lane_out[lane_merge][0];
//         lanes_fifo_request_cast_lane_out_signals_in[lane_merge][0] = lanes_fifo_request_lane_out_signals_in[lane_merge];
//         lanes_fifo_request_lane_out_signals_out[lane_merge]        = lanes_fifo_request_cast_lane_out_signals_out [lane_merge][0];

//         if(LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[lane_merge] != 0) begin
//             merge_count = 0;
//             for (lane_cast = 0; lane_cast < NUM_LANES; lane_cast++) begin
//                 if(LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[lane_cast] != 0 && lane_cast != lane_merge) begin
//                     $display("MSG: - Lane number lane_cast: %0d - ENGINES_COUNT_ARRAY = %0d", lane_cast, ENGINES_COUNT_ARRAY[lane_cast]);
//                     for (engine_idx = 0; engine_idx < ENGINES_COUNT_ARRAY[lane_cast]; engine_idx++) begin
//                         $display("MSG: ++ Engine number engine_idx: %0d - LANES_CONFIG_CAST_WIDTH_ARRAY = %0d", engine_idx, LANES_CONFIG_CAST_WIDTH_ARRAY[lane_cast][engine_idx]);
//                         for (cast_idx = 0; cast_idx < LANES_CONFIG_CAST_WIDTH_ARRAY[lane_cast][engine_idx]; cast_idx++) begin
//                             $display("MSG: *** Cast number cast_idx: %0d - LANES_CONFIG_MERGE_CONNECT_ARRAY = %0d",cast_idx, LANES_CONFIG_MERGE_CONNECT_ARRAY[lane_cast][engine_idx][cast_idx]);
//                             if(LANES_CONFIG_MERGE_CONNECT_ARRAY[lane_cast][engine_idx][cast_idx] == lane_merge) begin
//                                 merge_count                                             = merge_count + 1;
//                                 cast_count[lane_cast]                                   = cast_count[lane_cast] + 1;
//                                 $display("MSG: >>> lane_cast:%0d -> lane_merge:%0d merge_count:%0d cast_count[%0d]:%0d",lane_cast,lane_merge,merge_count, lane_cast,cast_count[lane_cast]);
//                                 lanes_response_merge_engine_in[lane_merge][merge_count]                                = lanes_request_cast_lane_out[lane_cast][ cast_count[lane_cast]];
//                                 lanes_fifo_response_merge_lane_in_signals_in[lane_merge][merge_count].rd_en            = ~lanes_fifo_request_cast_lane_out_signals_out[lane_cast][cast_count[lane_cast]].empty;
//                                 lanes_fifo_request_cast_lane_out_signals_in[lane_cast][ cast_count[lane_cast]].rd_en   = ~lanes_fifo_response_merge_lane_in_signals_out[lane_merge][merge_count].prog_full;
//                             end
//                         end
//                     end
//                 end
//             end
//         end
//     end
// end
    