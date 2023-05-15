// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : vertex_cu.sv
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
import PKG_VERTEX::*;
import PKG_CACHE::*;

module vertex_cu #(
    parameter ENGINE_ID_VERTEX = 0 ,
    parameter ENGINE_ID_BUNDLE = 0 ,
    parameter ENGINE_ID_ENGINE = 0 ,
    parameter COUNTER_WIDTH    = 32
) (
    // System Signals
    input  logic                       ap_clk                   ,
    input  logic                       areset                   ,
    input  ControlChainInterfaceOutput control_state            ,
    input  KernelDescriptor            descriptor_in            ,
    output MemoryPacket                request_out              ,
    input  FIFOStateSignalsInput       fifo_request_signals_in  ,
    output FIFOStateSignalsOutput      fifo_request_signals_out ,
    input  MemoryPacket                response_in              ,
    input  FIFOStateSignalsInput       fifo_response_signals_in ,
    output FIFOStateSignalsOutput      fifo_response_signals_out,
    output logic                       fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic            areset_vertex_cu             ;
    logic            areset_stride_index_generator;
    logic            areset_fifo                  ;
    KernelDescriptor descriptor_reg               ;
    MemoryPacket     response_in_reg              ;
    MemoryPacket     response_out_int             ;
    MemoryPacket     request_out_reg              ;

// --------------------------------------------------------------------------------------
// Setup state machine signals
// --------------------------------------------------------------------------------------
    logic           done_int_reg ;
    vertex_cu_state current_state;
    vertex_cu_state next_state   ;

// --------------------------------------------------------------------------------------
// Request FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_request_din             ;
    MemoryPacketPayload    fifo_request_dout            ;
    FIFOStateSignalsInput  fifo_request_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_request_signals_in_int  ;
    FIFOStateSignalsOutput fifo_request_signals_out_int ;
    logic                  fifo_request_setup_signal_int;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_din             ;
    MemoryPacketPayload    fifo_response_dout            ;
    FIFOStateSignalsInput  fifo_response_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_signals_out_int ;
    logic                  fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// Serial Read Engine Signals
// --------------------------------------------------------------------------------------
    MemoryPacket                      engine_stride_index_generator_request_out             ;
    FIFOStateSignalsOutput            engine_stride_index_generator_fifo_request_signals_out;
    FIFOStateSignalsInput             engine_stride_index_generator_fifo_request_signals_in ;
    FIFOStateSignalsInput             engine_stride_index_generator_fifo_request_signals_reg;
    logic                             engine_stride_index_generator_start_in                ;
    logic                             engine_stride_index_generator_pause_in                ;
    logic                             engine_stride_index_generator_ready_out               ;
    logic                             engine_stride_index_generator_done_out                ;
    StrideIndexGeneratorConfiguration engine_stride_index_generator_configuration_in        ;
    logic                             engine_stride_index_generator_fifo_setup_signal       ;

// Serial Read Engine Configure
// --------------------------------------------------------------------------------------
    MemoryPacket                      engine_stride_index_generator_configure_response_in                   ;
    StrideIndexGeneratorConfiguration engine_stride_index_generator_configure_configuration_out             ;
    FIFOStateSignalsOutput            engine_stride_index_generator_configure_fifo_response_signals_out     ;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_fifo_response_signals_in      ;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_response_signals_reg          ;
    FIFOStateSignalsOutput            engine_stride_index_generator_configure_fifo_configuration_signals_out;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_fifo_configuration_signals_in ;
    FIFOStateSignalsInput             engine_stride_index_generator_configure_configuration_signals_reg     ;
    logic                             engine_stride_index_generator_configure_fifo_setup_signal             ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_vertex_cu              <= areset;
        areset_stride_index_generator <= areset;
        areset_fifo                   <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            descriptor_reg.valid <= 0;
        end
        else begin
            descriptor_reg.valid <= descriptor_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        descriptor_reg.payload <= descriptor_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            fifo_response_signals_in_reg <= 0;
            fifo_request_signals_in_reg  <= 0;
            response_in_reg.valid        <= 0;
        end
        else begin
            fifo_response_signals_in_reg <= fifo_response_signals_in;
            fifo_request_signals_in_reg  <= fifo_request_signals_in;
            response_in_reg.valid        <= response_in.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_in_reg.payload <= response_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (areset_vertex_cu) begin
            fifo_setup_signal         <= 1;
            fifo_response_signals_out <= 0;
            fifo_request_signals_out  <= 0;
            request_out.valid         <= 0;
        end
        else begin
            fifo_setup_signal         <= engine_stride_index_generator_fifo_setup_signal | fifo_request_setup_signal_int | fifo_response_setup_signal_int | engine_stride_index_generator_configure_fifo_setup_signal;
            fifo_response_signals_out <= fifo_response_signals_out_int;
            fifo_request_signals_out  <= fifo_request_signals_out_int;
            request_out.valid         <= request_out_reg.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        request_out.payload <= request_out_reg.payload;
    end

// --------------------------------------------------------------------------------------
// SETUP State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_vertex_cu)
            current_state <= VERTEX_CU_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            VERTEX_CU_RESET : begin
                next_state = VERTEX_CU_IDLE;
            end
            VERTEX_CU_IDLE : begin
                if(engine_stride_index_generator_configure_configuration_out.valid & descriptor_reg.valid & engine_stride_index_generator_done_out & engine_stride_index_generator_ready_out)
                    next_state = VERTEX_CU_REQ_START;
                else
                    next_state = VERTEX_CU_IDLE;
            end
            VERTEX_CU_REQ_START : begin
                if(engine_stride_index_generator_done_out & engine_stride_index_generator_ready_out) begin
                    next_state = VERTEX_CU_REQ_START;
                end else begin
                    next_state = VERTEX_CU_REQ_BUSY;
                end
            end
            VERTEX_CU_REQ_BUSY : begin
                if (done_int_reg)
                    next_state = VERTEX_CU_REQ_DONE;
                else if (fifo_request_signals_out_int.prog_full | fifo_response_signals_out_int.prog_full)
                    next_state = VERTEX_CU_REQ_PAUSE;
                else
                    next_state = VERTEX_CU_REQ_BUSY;
            end
            VERTEX_CU_REQ_PAUSE : begin
                if (~(fifo_request_signals_out_int.prog_full | fifo_response_signals_out_int.prog_full))
                    next_state = VERTEX_CU_REQ_BUSY;
                else
                    next_state = VERTEX_CU_REQ_PAUSE;
            end
            VERTEX_CU_REQ_DONE : begin
                if (descriptor_reg.valid)
                    next_state = VERTEX_CU_REQ_DONE;
                else
                    next_state = VERTEX_CU_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            VERTEX_CU_RESET : begin
                done_int_reg                                                 <= 1'b1;
                engine_stride_index_generator_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_stride_index_generator_start_in                       <= 1'b0;
                engine_stride_index_generator_pause_in                       <= 1'b0;
                engine_stride_index_generator_configuration_in.valid         <= 1'b0;
            end
            VERTEX_CU_IDLE : begin
                done_int_reg                                                 <= 1'b0;
                engine_stride_index_generator_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_stride_index_generator_start_in                       <= 1'b0;
                engine_stride_index_generator_pause_in                       <= 1'b0;
                engine_stride_index_generator_configuration_in.valid         <= 1'b0;
            end
            VERTEX_CU_REQ_START : begin
                done_int_reg                                                 <= 1'b0;
                engine_stride_index_generator_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_stride_index_generator_start_in                       <= 1'b1;
                engine_stride_index_generator_pause_in                       <= 1'b0;
                engine_stride_index_generator_configuration_in.valid         <= 1'b1;
            end
            VERTEX_CU_REQ_BUSY : begin
                done_int_reg                                                 <= engine_stride_index_generator_done_out & engine_stride_index_generator_fifo_request_signals_out.empty & fifo_request_signals_out_int.empty;
                engine_stride_index_generator_fifo_request_signals_reg.rd_en <= ~fifo_request_signals_out_int.prog_full;
                engine_stride_index_generator_start_in                       <= 1'b0;
                engine_stride_index_generator_pause_in                       <= 1'b0;
                engine_stride_index_generator_configuration_in.valid         <= 1'b1;
            end
            VERTEX_CU_REQ_PAUSE : begin
                done_int_reg                                                 <= 1'b0;
                engine_stride_index_generator_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_stride_index_generator_start_in                       <= 1'b0;
                engine_stride_index_generator_pause_in                       <= 1'b1;
                engine_stride_index_generator_configuration_in.valid         <= 1'b0;
            end
            VERTEX_CU_REQ_DONE : begin
                done_int_reg                                                 <= 1'b1;
                engine_stride_index_generator_fifo_request_signals_reg.rd_en <= 1'b0;
                engine_stride_index_generator_start_in                       <= 1'b0;
                engine_stride_index_generator_pause_in                       <= 1'b0;
                engine_stride_index_generator_configuration_in.valid         <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)


// --------------------------------------------------------------------------------------
// Drive Response Packet Setup Engine Configuration
// 0 - increment/decrement
// 1 - index_start
// 2 - index_end
// 3 - stride
// 4 - granularity - $clog2(BIT_WIDTH) used to shift
// --------------------------------------------------------------------------------------
    assign engine_stride_index_generator_configure_response_in = response_out_int;

    engine_stride_index_generator_configure #(
        .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
        .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE),
        .ENGINE_ID_ENGINE(1               )
    ) inst_engine_stride_index_generator_configure (
        .ap_clk           (ap_clk                                                   ),
        .areset           (areset_stride_index_generator                            ),
        .response_in      (engine_stride_index_generator_configure_response_in      ),
        .configuration_out(engine_stride_index_generator_configure_configuration_out)
    );

    engine_stride_index_generator_configure #(
        .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
        .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE),
        .ENGINE_ID_ENGINE(1               )
    ) inst_engine_stride_index_generator_configure (
        .ap_clk                        (ap_clk                                                                ),
        .areset                        (areset_stride_index_generator                                         ),
        .response_in                   (engine_stride_index_generator_configure_response_in                   ),
        .fifo_response_signals_in      (engine_stride_index_generator_configure_fifo_response_signals_in      ),
        .fifo_response_signals_out     (engine_stride_index_generator_configure_fifo_response_signals_out     ),
        .configuration_out             (engine_stride_index_generator_configure_configuration_out             ),
        .fifo_configuration_signals_in (engine_stride_index_generator_configure_fifo_configuration_signals_in ),
        .fifo_configuration_signals_out(engine_stride_index_generator_configure_fifo_configuration_signals_out),
        .fifo_setup_signal             (engine_stride_index_generator_configure_fifo_setup_signal             )
    );

// --------------------------------------------------------------------------------------
// Stride engine generator instantiation
// --------------------------------------------------------------------------------------
    assign engine_stride_index_generator_configuration_in.payload = engine_stride_index_generator_configure_configuration_out.payload;
    assign engine_stride_index_generator_fifo_request_signals_in  = engine_stride_index_generator_fifo_request_signals_reg;

    engine_stride_index_generator #(.COUNTER_WIDTH(COUNTER_WIDTH)) inst_engine_stride_index_generator (
        .ap_clk                  (ap_clk                                                ),
        .areset                  (areset_stride_index_generator                         ),
        .configuration_in        (engine_stride_index_generator_configuration_in        ),
        .request_out             (engine_stride_index_generator_request_out             ),
        .fifo_request_signals_in (engine_stride_index_generator_fifo_request_signals_in ),
        .fifo_request_signals_out(engine_stride_index_generator_fifo_request_signals_out),
        .fifo_setup_signal       (engine_stride_index_generator_fifo_setup_signal       ),
        .start_in                (engine_stride_index_generator_start_in                ),
        .pause_in                (engine_stride_index_generator_pause_in                ),
        .ready_out               (engine_stride_index_generator_ready_out               ),
        .done_out                (engine_stride_index_generator_done_out                )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

    // Push
    // assign fifo_request_signals_in_int.wr_en = engine_stride_index_generator_request_out.valid;
    // assign fifo_request_din                  = engine_stride_index_generator_request_out.payload;

    assign fifo_request_signals_in_int.wr_en = 0;
    assign fifo_request_din                  = 0;

    // Pop
    assign fifo_request_signals_in_int.rd_en = ~fifo_request_signals_out_int.empty & fifo_request_signals_in_reg.rd_en;
    assign request_out_reg.valid             = fifo_request_signals_out_int.valid;
    assign request_out_reg.payload           = fifo_request_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketRequest (
        .clk         (ap_clk                                   ),
        .srst        (areset_fifo                              ),
        .din         (fifo_request_din                         ),
        .wr_en       (fifo_request_signals_in_int.wr_en        ),
        .rd_en       (fifo_request_signals_in_int.rd_en        ),
        .dout        (fifo_request_dout                        ),
        .full        (fifo_request_signals_out_int.full        ),
        .almost_full (fifo_request_signals_out_int.almost_full ),
        .empty       (fifo_request_signals_out_int.empty       ),
        .almost_empty(fifo_request_signals_out_int.almost_empty),
        .valid       (fifo_request_signals_out_int.valid       ),
        .prog_full   (fifo_request_signals_out_int.prog_full   ),
        .prog_empty  (fifo_request_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_request_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_request_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO cache response MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy | fifo_response_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_signals_in_int.wr_en = response_in_reg.valid;
    assign fifo_response_din                  = response_in_reg.payload;

    // Pop
    assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;;
    assign response_out_int.valid             = fifo_response_signals_out_int.valid;
    assign response_out_int.payload           = fifo_response_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacketResponse (
        .clk         (ap_clk                                    ),
        .srst        (areset_fifo                               ),
        .din         (fifo_response_din                         ),
        .wr_en       (fifo_response_signals_in_int.wr_en        ),
        .rd_en       (fifo_response_signals_in_int.rd_en        ),
        .dout        (fifo_response_dout                        ),
        .full        (fifo_response_signals_out_int.full        ),
        .almost_full (fifo_response_signals_out_int.almost_full ),
        .empty       (fifo_response_signals_out_int.empty       ),
        .almost_empty(fifo_response_signals_out_int.almost_empty),
        .valid       (fifo_response_signals_out_int.valid       ),
        .prog_full   (fifo_response_signals_out_int.prog_full   ),
        .prog_empty  (fifo_response_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_response_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_response_signals_out_int.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// instantiate vertex bundles
// --------------------------------------------------------------------------------------

    // vertex_cu_bundles #(
    //     .ENGINE_ID_VERTEX(ENGINE_ID_VERTEX),
    //     .ENGINE_ID_BUNDLE(ENGINE_ID_BUNDLE),
    //     .ENGINE_ID_ENGINE(ENGINE_ID_ENGINE)
    // ) inst_vertex_cu_bundles (
    //     .ap_clk                   (ap_clk                   ),
    //     .areset                   (areset                   ),
    //     .descriptor_in            (descriptor_in            ),
    //     .request_out              (request_out              ),
    //     .fifo_request_signals_in  (fifo_request_signals_in  ),
    //     .fifo_request_signals_out (fifo_request_signals_out ),
    //     .response_in              (response_in              ),
    //     .fifo_response_signals_in (fifo_response_signals_in ),
    //     .fifo_response_signals_out(fifo_response_signals_out),
    //     .fifo_setup_signal        (fifo_setup_signal        )
    // );


endmodule : vertex_cu