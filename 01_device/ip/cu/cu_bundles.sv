// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : cu_bundles.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
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

module cu_bundles #(
    parameter ENGINE_ID_VERTEX   = 0,
    parameter ENGINE_BUNDLES_NUM = 4
) (
    // System Signals
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  KernelDescriptor       descriptor_in                      ,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
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
    logic areset_cu_bundles;
    logic areset_fifo      ;

    KernelDescriptor descriptor_in_reg     ;
    MemoryPacket     response_memory_in_reg;
    MemoryPacket     response_memory_in_int;
    MemoryPacket     request_memory_out_int;

// --------------------------------------------------------------------------------------
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_memory_in_din             ;
    MemoryPacketPayload    fifo_response_memory_in_dout            ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_int ;
    logic                  fifo_response_memory_in_setup_signal_int;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Request MemoryPacket
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_memory_out_din             ;
    MemoryPacketPayload    fifo_request_memory_out_dout            ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_memory_out_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_memory_out_signals_out_int ;
    logic                  fifo_request_memory_out_setup_signal_int;

// --------------------------------------------------------------------------------------
// Generate Bundles
// --------------------------------------------------------------------------------------
    logic                  bundle_areset                                      [ENGINE_BUNDLES_NUM-1:0];
    KernelDescriptor       bundle_engines_descriptor_in                       [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_request_engine_in                   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_request_engine_in_signals_in   [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_request_engine_in_signals_out  [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_response_engine_in                  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_response_engine_in_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_response_engine_in_signals_out [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_response_memory_in                  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_response_memory_in_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_response_memory_in_signals_out [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_request_engine_out                  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_request_engine_out_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_request_engine_out_signals_out [ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_response_engine_out                 [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_response_engine_out_signals_in [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_response_engine_out_signals_out[ENGINE_BUNDLES_NUM-1:0];
    MemoryPacket           bundle_engines_request_memory_out                  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput  bundle_engines_fifo_request_memory_out_signals_in  [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_engines_fifo_request_memory_out_signals_out [ENGINE_BUNDLES_NUM-1:0];
    logic                  bundle_engines_fifo_setup_signal                   [ENGINE_BUNDLES_NUM-1:0];
    logic                  bundle_engines_done_out                            [ENGINE_BUNDLES_NUM-1:0];

    logic [ENGINE_BUNDLES_NUM-1:0] bundle_engines_fifo_setup_signal_reg;
    logic [ENGINE_BUNDLES_NUM-1:0] bundle_engines_done_out_reg         ;

// --------------------------------------------------------------------------------------
// Generate Bundles -  Memory Arbitration OUTPUT
// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    logic                          areset_arbiter_N_to_1                                                 ;
    MemoryPacket                   bundle_arbiter_N_to_1_request_in              [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsInput          bundle_arbiter_N_to_1_fifo_request_signals_in                         ;
    FIFOStateSignalsOutput         bundle_arbiter_N_to_1_fifo_request_signals_out                        ;
    logic [ENGINE_BUNDLES_NUM-1:0] bundle_arbiter_N_to_1_arbiter_request_in                              ;
    logic [ENGINE_BUNDLES_NUM-1:0] bundle_arbiter_N_to_1_arbiter_grant_out                               ;
    MemoryPacket                   bundle_arbiter_N_to_1_request_out                                     ;
    logic                          bundle_arbiter_N_to_1_fifo_setup_signal                               ;

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    logic                  areset_arbiter_1_to_N                                                  ;
    MemoryPacket           bundle_arbiter_1_to_N_response_in                                      ;
    FIFOStateSignalsInput  bundle_arbiter_1_to_N_fifo_response_signals_in [ENGINE_BUNDLES_NUM-1:0];
    FIFOStateSignalsOutput bundle_arbiter_1_to_N_fifo_response_signals_out                        ;
    MemoryPacket           bundle_arbiter_1_to_N_response_out             [ENGINE_BUNDLES_NUM-1:0];
    logic                  bundle_arbiter_1_to_N_fifo_setup_signal                                ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_cu_bundles     <= areset;
        areset_fifo           <= areset;
        areset_arbiter_N_to_1 <= areset;
        areset_arbiter_1_to_N <= areset;
    end

// --------------------------------------------------------------------------------------
// Done Logic (DUMMY) Variables
// --------------------------------------------------------------------------------------
    logic                              done_signal_reg;
    logic [GLOBAL_DATA_WIDTH_BITS-1:0] counter        ;

// --------------------------------------------------------------------------------------
// Done Logic (DUMMY)
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            done_signal_reg <= 1'b0;
            counter         <= 0;
        end
        else begin
            if (descriptor_in_reg.valid) begin
                if(counter >= 200) begin
                    done_signal_reg <= 1'b1;
                    counter         <= 0;
                end
                else begin
                    // if(engine_stride_index_request_out.valid & (engine_stride_index_request_out.payload.meta.subclass.buffer == STRUCT_ENGINE_SETUP)) begin
                    counter <= counter + 1;
                    // if (counter == 0)
                    //     $display("MSG:  VERTEX ID -> %0d", engine_stride_index_request_out.payload.data.field_0);
                    // end else
                    // counter <= counter;
                end
            end else begin
                done_signal_reg <= 1'b0;
                counter         <= 0;
            end
        end
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_cu_bundles) begin
            descriptor_in_reg.valid <= 0;
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
        if (areset_cu_bundles) begin
            fifo_response_memory_in_signals_in_reg <= 0;
            fifo_request_memory_out_signals_in_reg <= 0;
            response_memory_in_reg.valid           <= 0;
        end
        else begin
            fifo_response_memory_in_signals_in_reg <= fifo_response_memory_in_signals_in;
            fifo_request_memory_out_signals_in_reg <= fifo_request_memory_out_signals_in;
            response_memory_in_reg.valid           <= response_memory_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_cu_bundles) begin
            fifo_setup_signal        <= 1;
            request_memory_out.valid <= 0;
            done_out                 <= 0;
        end
        else begin
            fifo_setup_signal        <= fifo_request_memory_out_setup_signal_int | fifo_response_memory_in_setup_signal_int | (|bundle_engines_fifo_setup_signal_reg) | bundle_arbiter_N_to_1_fifo_setup_signal | bundle_arbiter_1_to_N_fifo_setup_signal;
            request_memory_out.valid <= request_memory_out_int.valid ;
            done_out                 <= (&bundle_engines_done_out_reg) | done_signal_reg;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_int;
        fifo_request_memory_out_signals_out <= fifo_request_memory_out_signals_out_int;
        request_memory_out.payload          <= request_memory_out_int.payload;
    end

// --------------------------------------------------------------------------------------
// FIFO INPUT Response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_memory_in_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy | fifo_response_memory_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid;
    assign fifo_response_memory_in_din                  = response_memory_in_reg.payload;

    // Pop
    assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~bundle_arbiter_1_to_N_fifo_response_signals_out.prog_full;
    assign response_memory_in_int.valid                 = fifo_response_memory_in_signals_out_int.valid;
    assign response_memory_in_int.payload               = fifo_response_memory_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponseInput (
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
// FIFO OUTPUT requests MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_memory_out_setup_signal_int = fifo_request_memory_out_signals_out_int.wr_rst_busy | fifo_request_memory_out_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_request_memory_out_signals_in_int.wr_en = bundle_arbiter_N_to_1_request_out.valid;
    assign fifo_request_memory_out_din                  = bundle_arbiter_N_to_1_request_out.payload;

    // Pop
    assign fifo_request_memory_out_signals_in_int.rd_en = ~fifo_request_memory_out_signals_out_int.empty & fifo_request_memory_out_signals_in_reg.rd_en;
    assign request_memory_out_int.valid                 = fifo_request_memory_out_signals_out_int.valid;
    assign request_memory_out_int.payload               = fifo_request_memory_out_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequestOutput (
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
// Generate Bundles Arbitration|Instants|Signals
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Generate Bundles - Drive input signals
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< ENGINE_BUNDLES_NUM; i++) begin : generate_bundle_reg_input
            always_ff @(posedge ap_clk) begin
                bundle_areset[i] <= areset;
            end

            always_ff @(posedge ap_clk) begin
                if (areset_cu_bundles) begin
                    bundle_engines_descriptor_in[i].valid <= 0;
                end
                else begin
                    bundle_engines_descriptor_in[i].valid <= descriptor_in_reg.valid;
                end
            end

            always_ff @(posedge ap_clk) begin
                bundle_engines_descriptor_in[i].payload <= descriptor_in_reg.payload;
            end
        end
    endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - Drive output signals
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< ENGINE_BUNDLES_NUM; i++) begin : generate_bundle_reg_output
            always_ff @(posedge ap_clk) begin
                if (areset_cu_bundles) begin
                    bundle_engines_fifo_setup_signal_reg[i] <= 1'b1;
                    bundle_engines_done_out_reg[i]          <= 1'b1;
                end
                else begin
                    bundle_engines_fifo_setup_signal_reg[i] <= bundle_engines_fifo_setup_signal[i];
                    bundle_engines_done_out_reg[i]          <= bundle_engines_done_out[i];
                end
            end
        end
    endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - Drive Intra-signals
// --------------------------------------------------------------------------------------
// Generate Bundles - [0]->[1]->[2]->[3]->[4]->[0]
// --------------------------------------------------------------------------------------
    assign bundle_engines_request_engine_in[0] = bundle_engines_response_engine_out[ENGINE_BUNDLES_NUM-1];
    assign bundle_engines_fifo_response_engine_out_signals_in[ENGINE_BUNDLES_NUM-1].rd_en = ~bundle_engines_fifo_request_engine_in_signals_out[0].prog_full;

    generate
        for (i=1; i<ENGINE_BUNDLES_NUM; i++) begin : generate_bundle_intra_signals
            assign bundle_engines_request_engine_in[i] = bundle_engines_response_engine_out[i-1];
            assign bundle_engines_fifo_response_engine_out_signals_in[i-1].rd_en = ~bundle_engines_fifo_request_engine_in_signals_out[i].prog_full;
        end
    endgenerate

// --------------------------------------------------------------------------------------
// Generate Bundles - Memory Arbitration OUTPUT
// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Request Generator
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i<ENGINE_BUNDLES_NUM; i++) begin : generate_bundle_arbiter_N_to_1_request_in
            assign bundle_arbiter_N_to_1_request_in[i]         = bundle_engines_request_memory_out[i];
            assign bundle_arbiter_N_to_1_arbiter_request_in[i] = ~bundle_engines_fifo_request_memory_out_signals_out[i].empty & ~bundle_arbiter_N_to_1_fifo_request_signals_out.prog_full;
            assign bundle_engines_fifo_request_memory_out_signals_in[i].rd_en  = ~bundle_arbiter_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_N_to_1_arbiter_grant_out[i];
        end
    endgenerate

    assign bundle_arbiter_N_to_1_fifo_request_signals_in.rd_en = ~fifo_request_memory_out_signals_out_int.prog_full;
// --------------------------------------------------------------------------------------
    bundle_arbiter_N_to_1_request #(.NUM_MEMORY_REQUESTOR(ENGINE_BUNDLES_NUM)) inst_bundle_arbiter_N_to_1_request_memory_out (
        .ap_clk                  (ap_clk                                        ),
        .areset                  (areset_arbiter_N_to_1                         ),
        .request_in              (bundle_arbiter_N_to_1_request_in              ),
        .fifo_request_signals_in (bundle_arbiter_N_to_1_fifo_request_signals_in ),
        .fifo_request_signals_out(bundle_arbiter_N_to_1_fifo_request_signals_out),
        .arbiter_request_in      (bundle_arbiter_N_to_1_arbiter_request_in      ),
        .arbiter_grant_out       (bundle_arbiter_N_to_1_arbiter_grant_out       ),
        .request_memory_out      (bundle_arbiter_N_to_1_request_out             ),
        .fifo_setup_signal       (bundle_arbiter_N_to_1_fifo_setup_signal       )
    );

// --------------------------------------------------------------------------------------
// Generate Bundles - Signals
// --------------------------------------------------------------------------------------
// Generate Bundles - Arbiter Signals: Memory Response Generator
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i<ENGINE_BUNDLES_NUM; i++) begin : generate_bundle_arbiter_1_to_N_response
            assign bundle_arbiter_1_to_N_response_in[i] = response_memory_in_int;
            assign bundle_arbiter_1_to_N_fifo_response_signals_in[i].rd_en = ~bundle_engines_fifo_response_memory_in_signals_out[i].prog_full;

            assign bundle_engines_response_memory_in[i] = bundle_arbiter_1_to_N_response_out[i];
            assign bundle_engines_fifo_response_memory_in_signals_in[i].rd_en = 1'b1;
        end
    endgenerate

// --------------------------------------------------------------------------------------
    bundle_arbiter_1_to_N_response #(.NUM_MEMORY_REQUESTOR(ENGINE_BUNDLES_NUM)) inst_bundle_arbiter_1_to_N_response_memory_in (
        .ap_clk                   (ap_clk                                         ),
        .areset                   (areset_arbiter_1_to_N                          ),
        .response_memory_in       (bundle_arbiter_1_to_N_response_in              ),
        .fifo_response_signals_in (bundle_arbiter_1_to_N_fifo_response_signals_in ),
        .fifo_response_signals_out(bundle_arbiter_1_to_N_fifo_response_signals_out),
        .response_out             (bundle_arbiter_1_to_N_response_out             ),
        .fifo_setup_signal        (bundle_arbiter_1_to_N_fifo_setup_signal        )
    );

// --------------------------------------------------------------------------------------
// Generate Bundles - instants
// --------------------------------------------------------------------------------------
    generate
        for (i=0; i< ENGINE_BUNDLES_NUM; i++) begin : generate_bundle_engines
            bundle_engines #(
                .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
                .ENGINE_ID_BUNDLE(i               )
            ) inst_bundle_engines (
                .ap_clk                              (ap_clk                                                ),
                .areset                              (bundle_areset[i]                                      ),
                .descriptor_in                       (bundle_engines_descriptor_in[i]                       ),
                .response_engine_in                  (bundle_engines_response_engine_in[i]                  ),
                .fifo_response_engine_in_signals_in  (bundle_engines_fifo_response_engine_in_signals_in[i]  ),
                .fifo_response_engine_in_signals_out (bundle_engines_fifo_response_engine_in_signals_out[i] ),
                .response_memory_in                  (bundle_engines_response_memory_in[i]                  ),
                .fifo_response_memory_in_signals_in  (bundle_engines_fifo_response_memory_in_signals_in[i]  ),
                .fifo_response_memory_in_signals_out (bundle_engines_fifo_response_memory_in_signals_out[i] ),
                .response_engine_out                 (bundle_engines_response_engine_out[i]                 ),
                .fifo_response_engine_out_signals_in (bundle_engines_fifo_response_engine_out_signals_in[i] ),
                .fifo_response_engine_out_signals_out(bundle_engines_fifo_response_engine_out_signals_out[i]),
                .request_memory_out                  (bundle_engines_request_memory_out[i]                  ),
                .fifo_request_memory_out_signals_in  (bundle_engines_fifo_request_memory_out_signals_in[i]  ),
                .fifo_request_memory_out_signals_out (bundle_engines_fifo_request_memory_out_signals_out[i] ),
                .fifo_setup_signal                   (bundle_engines_fifo_setup_signal[i]                   ),
                .done_out                            (bundle_engines_done_out[i]                            )
            );
        end
    endgenerate

endmodule : cu_bundles