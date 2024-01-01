// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_template.sv
// Create : 2023-06-14 20:53:28
// Revise : 2023-08-30 13:44:01
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_template #(
    `include "engine_parameters.vh"
    ) (
    // System Signals
    input  logic                  ap_clk                                                           ,
    input  logic                  areset                                                           ,
    input  KernelDescriptor       descriptor_in                                                    ,
    input  EnginePacket           response_engine_in[(1+ENGINE_MERGE_WIDTH)-1:0]                   ,
    input  FIFOStateSignalsInput  fifo_response_engine_in_signals_in[(1+ENGINE_MERGE_WIDTH)-1:0]   ,
    output FIFOStateSignalsOutput fifo_response_engine_in_signals_out[(1+ENGINE_MERGE_WIDTH)-1:0]  ,
    input  FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in[NUM_BACKTRACK_LANES-1:0],
    input  MemoryPacket           response_memory_in                                               ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in                               ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out                              ,
    input  ControlPacket          response_control_in                                              ,
    input  FIFOStateSignalsInput  fifo_response_control_in_signals_in                              ,
    output FIFOStateSignalsOutput fifo_response_control_in_signals_out                             ,
    output EnginePacket           request_engine_out[(1+ENGINE_CAST_WIDTH)-1:0]                    ,
    input  FIFOStateSignalsInput  fifo_request_engine_out_signals_in[(1+ENGINE_CAST_WIDTH)-1:0]    ,
    output FIFOStateSignalsOutput fifo_request_engine_out_signals_out[(1+ENGINE_CAST_WIDTH)-1:0]   ,
    output MemoryPacket           request_memory_out                                               ,
    input  FIFOStateSignalsInput  fifo_request_memory_out_signals_in                               ,
    output FIFOStateSignalsOutput fifo_request_memory_out_signals_out                              ,
    output ControlPacket          request_control_out                                              ,
    input  FIFOStateSignalsInput  fifo_request_control_out_signals_in                              ,
    output FIFOStateSignalsOutput fifo_request_control_out_signals_out                             ,
    output logic                  fifo_setup_signal                                                ,
    output logic                  done_out
);

genvar i;
// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_template_engine;
logic areset_engine         ;

KernelDescriptor descriptor_in_reg;

ControlPacket request_control_out_int;
EnginePacket  request_engine_out_int ;
MemoryPacket  request_memory_out_int ;
ControlPacket response_control_in_int;
ControlPacket response_control_in_reg;
EnginePacket  response_engine_in_int ;
EnginePacket  response_engine_in_reg ;
MemoryPacket  response_memory_in_int ;
MemoryPacket  response_memory_in_reg ;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
// Drive CAST output signals
// --------------------------------------------------------------------------------------
logic                  areset_engine_cast_arbiter_1_to_N                  ;
FIFOStateSignalsOutput engine_cast_arbiter_1_to_N_fifo_request_signals_out;
logic                  engine_cast_arbiter_1_to_N_fifo_setup_signal       ;

// --------------------------------------------------------------------------------------
// FIFO Engine INPUT Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_engine_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_response_control_in_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO Engine OUTPUT Request EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_engine_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory Request Memory EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_memory_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL Request Memory EnginePacket
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput fifo_request_control_out_signals_in_reg;

// --------------------------------------------------------------------------------------
// Generate FIFO backtrack signals - Signals: Lanes Response Generator
// --------------------------------------------------------------------------------------
FIFOStateSignalsOutput fifo_response_lanes_backtrack_signals_in_reg[NUM_BACKTRACK_LANES-1:0];

// --------------------------------------------------------------------------------------
// Generate Bundles
// --------------------------------------------------------------------------------------
FIFOStateSignalsInput  template_fifo_request_control_out_signals_in                                 ;
FIFOStateSignalsInput  template_fifo_request_engine_out_signals_in                                  ;
FIFOStateSignalsInput  template_fifo_request_memory_out_signals_in                                  ;
FIFOStateSignalsInput  template_fifo_response_control_in_signals_in                                 ;
FIFOStateSignalsInput  template_fifo_response_engine_in_signals_in      [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsInput  template_fifo_response_memory_in_signals_in                                  ;
FIFOStateSignalsOutput template_fifo_request_control_out_signals_out                                ;
FIFOStateSignalsOutput template_fifo_request_engine_out_signals_out                                 ;
FIFOStateSignalsOutput template_fifo_request_memory_out_signals_out                                 ;
FIFOStateSignalsOutput template_fifo_response_control_in_signals_out                                ;
FIFOStateSignalsOutput template_fifo_response_engine_in_signals_out     [(1+ENGINE_MERGE_WIDTH)-1:0];
FIFOStateSignalsOutput template_fifo_response_memory_in_signals_out                                 ;
FIFOStateSignalsOutput template_fifo_response_lanes_backtrack_signals_in[   NUM_BACKTRACK_LANES-1:0];

KernelDescriptor template_descriptor_in    ;
logic            areset_template           ;
logic            template_done_out         ;
logic            template_fifo_setup_signal;

ControlPacket template_request_control_out                            ;
EnginePacket  template_request_engine_out                             ;
MemoryPacket  template_request_memory_out                             ;
ControlPacket template_response_control_in                            ;
EnginePacket  template_response_engine_in [(1+ENGINE_MERGE_WIDTH)-1:0];
MemoryPacket  template_response_memory_in                             ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_template_engine            <= areset;
    areset_engine                     <= areset;
    areset_engine_cast_arbiter_1_to_N <= areset;
end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_template_engine) begin
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
    if (areset_template_engine) begin
        fifo_request_control_out_signals_in_reg <= 0;
        fifo_request_engine_out_signals_in_reg  <= 0;
        fifo_request_memory_out_signals_in_reg  <= 0;
        fifo_response_control_in_signals_in_reg <= 0;
        fifo_response_engine_in_signals_in_reg  <= 0;
        fifo_response_memory_in_signals_in_reg  <= 0;
        response_control_in_reg.valid           <= 1'b0;
        response_engine_in_reg.valid            <= 1'b0;
        response_memory_in_reg.valid            <= 1'b0;
    end
    else begin
        fifo_request_control_out_signals_in_reg <= fifo_request_control_out_signals_in;
        fifo_request_engine_out_signals_in_reg  <= fifo_request_engine_out_signals_in[0];
        fifo_request_memory_out_signals_in_reg  <= fifo_request_memory_out_signals_in;
        fifo_response_control_in_signals_in_reg <= fifo_response_control_in_signals_in;
        fifo_response_engine_in_signals_in_reg  <= fifo_response_engine_in_signals_in[0];
        fifo_response_memory_in_signals_in_reg  <= fifo_response_memory_in_signals_in;
        response_control_in_reg.valid           <= response_control_in.valid ;
        response_engine_in_reg.valid            <= response_engine_in[0].valid;
        response_memory_in_reg.valid            <= response_memory_in.valid ;
    end
end

always_ff @(posedge ap_clk) begin
    response_control_in_reg.payload <= response_control_in.payload;
    response_engine_in_reg.payload  <= response_engine_in[0].payload;
    response_memory_in_reg.payload  <= response_memory_in.payload;
end

generate
    for (i=0; i<NUM_BACKTRACK_LANES; i++) begin  : generate_response_lanes_backtrack_signals
        always_ff @(posedge ap_clk) begin
            fifo_response_lanes_backtrack_signals_in_reg[i] <= fifo_response_lanes_backtrack_signals_in[i];
        end
    end
endgenerate

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_template_engine) begin
        done_out                  <= 1'b0;
        fifo_empty_reg            <= 1'b1;
        fifo_setup_signal         <= 1'b1;
        request_control_out.valid <= 1'b0;
        request_engine_out[0].valid <= 1'b0;
        request_memory_out.valid  <= 1'b0;
    end
    else begin
        done_out                  <= template_done_out & fifo_empty_reg;
        fifo_empty_reg            <= fifo_empty_int;
        fifo_setup_signal         <= engine_cast_arbiter_1_to_N_fifo_setup_signal | template_fifo_setup_signal;
        request_control_out.valid <= request_control_out_int.valid;
        request_engine_out[0].valid <= request_engine_out_int.valid & (|request_engine_out_int.payload.meta.route.packet_destination);
        request_memory_out.valid  <= request_memory_out_int.valid;
    end
end

assign fifo_empty_int = engine_cast_arbiter_1_to_N_fifo_request_signals_out.empty;

always_ff @(posedge ap_clk) begin
    fifo_request_control_out_signals_out   <= template_fifo_request_control_out_signals_out;
    fifo_request_engine_out_signals_out[0] <= template_fifo_request_engine_out_signals_out & engine_cast_arbiter_1_to_N_fifo_request_signals_out;
    fifo_request_memory_out_signals_out    <= template_fifo_request_memory_out_signals_out;
    fifo_response_control_in_signals_out   <= template_fifo_response_control_in_signals_out;
    fifo_response_engine_in_signals_out[0] <= template_fifo_response_engine_in_signals_out[0];
    fifo_response_memory_in_signals_out    <= template_fifo_response_memory_in_signals_out;
    request_control_out.payload            <= request_control_out_int.payload ;
    request_engine_out[0].payload          <= request_engine_out_int.payload;
    request_memory_out.payload             <= request_memory_out_int.payload ;
end

// --------------------------------------------------------------------------------------
// Drive CAST output signals
// --------------------------------------------------------------------------------------
// Generate CAST - Arbiter Signals: CAST Request Generator
// --------------------------------------------------------------------------------------
generate
    if(ENGINE_CAST_WIDTH>0) begin
// --------------------------------------------------------------------------------------
        FIFOStateSignalsInput  engine_cast_arbiter_1_to_N_fifo_request_signals_in[ENGINE_CAST_WIDTH-1:0];
        FIFOStateSignalsInput  fifo_request_engine_cast_signals_in               [ENGINE_CAST_WIDTH-1:0];
        FIFOStateSignalsOutput fifo_request_engine_cast_signals_out              [ENGINE_CAST_WIDTH-1:0];
        EnginePacket           engine_cast_arbiter_1_to_N_request_out            [ENGINE_CAST_WIDTH-1:0];
        EnginePacket           request_engine_cast                               [ENGINE_CAST_WIDTH-1:0];
        EnginePacket           engine_cast_arbiter_1_to_N_request_in                                    ;
// --------------------------------------------------------------------------------------
        for (i=0; i<ENGINE_CAST_WIDTH; i++) begin : generate_engine_cast_drivers
            always_ff @(posedge ap_clk) begin
                if (areset_template_engine) begin
                    fifo_request_engine_cast_signals_in[i].rd_en <= 1'b0;
                    request_engine_out[i+1].valid <= 1'b0;
                end
                else begin
                    fifo_request_engine_cast_signals_in[i].rd_en <= fifo_request_engine_out_signals_in[i+1].rd_en & fifo_request_engine_out_signals_in_reg.rd_en;
                    request_engine_out[i+1].valid <= request_engine_cast[i].valid;
                end
            end

            always_ff @(posedge ap_clk) begin
                fifo_request_engine_out_signals_out[i+1] <= fifo_request_engine_cast_signals_out[i];
                request_engine_out[i+1].payload          <= request_engine_cast[i].payload;
            end
        end
// --------------------------------------------------------------------------------------
        assign engine_cast_arbiter_1_to_N_request_in = request_engine_out_int;
        for (i=0; i<ENGINE_CAST_WIDTH; i++) begin : generate_engine_cast_arbiter_1_to_N_request
            assign engine_cast_arbiter_1_to_N_fifo_request_signals_in[i].rd_en = fifo_request_engine_cast_signals_in[i].rd_en;
            assign fifo_request_engine_cast_signals_out[i] = engine_cast_arbiter_1_to_N_fifo_request_signals_out;
            assign request_engine_cast[i]                  = engine_cast_arbiter_1_to_N_request_out[i];
        end
// --------------------------------------------------------------------------------------
        arbiter_1_to_N_response_engine #(
            .NUM_ENGINE_RECEIVER(ENGINE_CAST_WIDTH),
            .ID_LEVEL           (5                ),
            .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH ),
            .PROG_THRESH        (PROG_THRESH      )
        ) inst_engine_cast_arbiter_1_to_N_request (
            .ap_clk                   (ap_clk                                             ),
            .areset                   (areset_engine_cast_arbiter_1_to_N                  ),
            .response_in              (engine_cast_arbiter_1_to_N_request_in              ),
            .fifo_response_signals_in (engine_cast_arbiter_1_to_N_fifo_request_signals_in ),
            .fifo_response_signals_out(engine_cast_arbiter_1_to_N_fifo_request_signals_out),
            .response_out             (engine_cast_arbiter_1_to_N_request_out             ),
            .fifo_setup_signal        (engine_cast_arbiter_1_to_N_fifo_setup_signal       )
        );
// --------------------------------------------------------------------------------------
    end else begin
        assign engine_cast_arbiter_1_to_N_fifo_request_signals_out = 2'b10;
        assign engine_cast_arbiter_1_to_N_fifo_setup_signal        = 0;
    end
endgenerate


// --------------------------------------------------------------------------------------
// Drive MERGE input signals
// --------------------------------------------------------------------------------------
// Generate MERGE - Arbiter Signals: MERGE Response Generator
// --------------------------------------------------------------------------------------
generate
    if(ENGINE_MERGE_WIDTH>0) begin
// --------------------------------------------------------------------------------------
        EnginePacket           response_engine_merge                 [ENGINE_MERGE_WIDTH-1:0];
        FIFOStateSignalsInput  fifo_response_engine_merge_signals_in [ENGINE_MERGE_WIDTH-1:0];
        FIFOStateSignalsOutput fifo_response_engine_merge_signals_out[ENGINE_MERGE_WIDTH-1:0];
// --------------------------------------------------------------------------------------
        for (i=0; i<ENGINE_MERGE_WIDTH; i++) begin : generate_engine_merge_drivers
            always_ff @(posedge ap_clk) begin
                if (areset_template_engine) begin
                    fifo_response_engine_merge_signals_in[i] <= 0;
                    response_engine_merge[i].valid           <= 1'b0;
                end
                else begin
                    fifo_response_engine_merge_signals_in[i] <= fifo_response_engine_in_signals_in[i+1];
                    response_engine_merge[i].valid           <= response_engine_in[i+1].valid;
                end
            end

            always_ff @(posedge ap_clk) begin
                fifo_response_engine_in_signals_out[i+1] <= fifo_response_engine_merge_signals_out[i];
                response_engine_merge[i].payload <= response_engine_in[i+1].payload;
            end
        end
// --------------------------------------------------------------------------------------
        for (i=0; i<ENGINE_MERGE_WIDTH; i++) begin : response_merge_engine_in
            assign template_response_engine_in[i+1]          = response_engine_merge[i];
            assign template_fifo_response_engine_in_signals_in[i+1].rd_en = 1'b1;
            assign fifo_response_engine_merge_signals_out[i] = template_fifo_response_engine_in_signals_out[i+1];
        end
// --------------------------------------------------------------------------------------
    end
endgenerate

// --------------------------------------------------------------------------------------
// FIFO INPUT Engine Response EnginePacket
// --------------------------------------------------------------------------------------
// Pop
assign response_engine_in_int = response_engine_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT Memory Response EnginePacket
// --------------------------------------------------------------------------------------
// Pop
assign response_memory_in_int = response_memory_in_reg;

// --------------------------------------------------------------------------------------
// FIFO INPUT CONTROL Response EnginePacket
// --------------------------------------------------------------------------------------
assign response_control_in_int = response_control_in_reg;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Engine requests EnginePacket
// --------------------------------------------------------------------------------------
// Pop
assign request_engine_out_int = template_request_engine_out;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT Memory requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_memory_out_int = template_request_memory_out;

// --------------------------------------------------------------------------------------
// FIFO OUTPUT CONTROL requests EnginePacket
// --------------------------------------------------------------------------------------
assign request_control_out_int = template_request_control_out;

// --------------------------------------------------------------------------------------
// Generate Engine - instant
// --------------------------------------------------------------------------------------
generate
    case (ENGINES_CONFIG)
        0       : begin
// --------------------------------------------------------------------------------------
// ENGINE PIPELINE
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;

            engine_pipeline #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_pipeline (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in[0]                   ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in[0]   ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out[0]  ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
        1       : begin
// --------------------------------------------------------------------------------------
// ENGINE MEMORY R/W Generator
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;


            engine_read_write #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_read_write (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in[0]                   ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in[0]   ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out[0]  ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
        2       : begin
// --------------------------------------------------------------------------------------
// ENGINE CSR
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;


            engine_csr_index #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_csr_index (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in[0]                   ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in[0]   ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out[0]  ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
        3       : begin
// --------------------------------------------------------------------------------------
// ENGINE FILTER
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;


            engine_filter_cond #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_filter_cond (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in[0]                   ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in[0]   ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out[0]  ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
        4       : begin
// --------------------------------------------------------------------------------------
// ENGINE MERGE DATA
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;


            engine_merge_data #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_merge_data (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in                      ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in      ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out     ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
        5       : begin
// --------------------------------------------------------------------------------------
// ENGINE ALU
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;


            engine_alu_ops #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_alu_ops (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in[0]                   ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in[0]   ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out[0]  ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
        6       : begin
// --------------------------------------------------------------------------------------
// ENGINE FORWARD BUFFER
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;


            engine_forward_data #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_forward_data (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in[0]                   ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in[0]   ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out[0]  ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
        default : begin
// --------------------------------------------------------------------------------------
// ENGINE FORWARD BUFFER
// --------------------------------------------------------------------------------------
            assign areset_template = areset_engine;

            assign template_descriptor_in                             = descriptor_in_reg;
            assign template_fifo_response_control_in_signals_in.rd_en = 1'b1;
            assign template_fifo_response_engine_in_signals_in[0].rd_en = 1'b1;
            assign template_fifo_response_memory_in_signals_in.rd_en  = 1'b1;
            assign template_response_control_in                       = response_control_in_int;
            assign template_response_engine_in[0]                     = response_engine_in_int;
            assign template_response_memory_in                        = response_memory_in_int;

            assign template_fifo_request_engine_out_signals_in.rd_en  = fifo_request_engine_out_signals_in_reg.rd_en & ~engine_cast_arbiter_1_to_N_fifo_request_signals_out.prog_full;
            assign template_fifo_request_memory_out_signals_in.rd_en  = fifo_request_memory_out_signals_in_reg.rd_en;
            assign template_fifo_request_control_out_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
            assign template_fifo_response_lanes_backtrack_signals_in  = fifo_response_lanes_backtrack_signals_in_reg;


            engine_pipeline #(
                .ID_CU              (ID_CU              ),
                .ID_BUNDLE          (ID_BUNDLE          ),
                .ID_LANE            (ID_LANE            ),
                .ID_ENGINE          (ID_ENGINE          ),
                .ID_RELATIVE        (ID_RELATIVE        ),
                .ENGINE_CAST_WIDTH  (ENGINE_CAST_WIDTH  ),
                .ENGINE_MERGE_WIDTH (ENGINE_MERGE_WIDTH ),
                .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH   ),
                .PROG_THRESH        (PROG_THRESH        ),
                .NUM_BACKTRACK_LANES(NUM_BACKTRACK_LANES),
                .NUM_BUNDLES        (NUM_BUNDLES        ),
                .ENGINE_SEQ_WIDTH   (ENGINE_SEQ_WIDTH   ),
                .ENGINE_SEQ_MIN     (ENGINE_SEQ_MIN     ),
                .ENGINES_CONFIG     (ENGINES_CONFIG     )
            ) inst_engine_pipeline (
                .ap_clk                                  (ap_clk                                           ),
                .areset                                  (areset_template                                  ),
                .descriptor_in                           (template_descriptor_in                           ),
                .response_engine_in                      (template_response_engine_in[0]                   ),
                .fifo_response_engine_in_signals_in      (template_fifo_response_engine_in_signals_in[0]   ),
                .fifo_response_engine_in_signals_out     (template_fifo_response_engine_in_signals_out[0]  ),
                .fifo_response_lanes_backtrack_signals_in(template_fifo_response_lanes_backtrack_signals_in),
                .response_memory_in                      (template_response_memory_in                      ),
                .fifo_response_memory_in_signals_in      (template_fifo_response_memory_in_signals_in      ),
                .fifo_response_memory_in_signals_out     (template_fifo_response_memory_in_signals_out     ),
                .response_control_in                     (template_response_control_in                     ),
                .fifo_response_control_in_signals_in     (template_fifo_response_control_in_signals_in     ),
                .fifo_response_control_in_signals_out    (template_fifo_response_control_in_signals_out    ),
                .request_engine_out                      (template_request_engine_out                      ),
                .fifo_request_engine_out_signals_in      (template_fifo_request_engine_out_signals_in      ),
                .fifo_request_engine_out_signals_out     (template_fifo_request_engine_out_signals_out     ),
                .request_memory_out                      (template_request_memory_out                      ),
                .fifo_request_memory_out_signals_in      (template_fifo_request_memory_out_signals_in      ),
                .fifo_request_memory_out_signals_out     (template_fifo_request_memory_out_signals_out     ),
                .request_control_out                     (template_request_control_out                     ),
                .fifo_request_control_out_signals_in     (template_fifo_request_control_out_signals_in     ),
                .fifo_request_control_out_signals_out    (template_fifo_request_control_out_signals_out    ),
                .fifo_setup_signal                       (template_fifo_setup_signal                       ),
                .done_out                                (template_done_out                                )
            );

// --------------------------------------------------------------------------------------
        end
    endcase
endgenerate

endmodule : engine_template