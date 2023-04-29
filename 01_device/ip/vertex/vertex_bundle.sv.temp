// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : vertex_bundle.sv
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
import PKG_VERTEX::*;

module vertex_bundle #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL,
    parameter ENGINE_ID          = 0,
    parameter COUNTER_WIDTH      = 32
) (
    // System Signals
    input  logic                       ap_clk,
    input  logic                       areset,
    input  ControlChainInterfaceOutput control_state,
    input  KernelDescriptor         descriptor,
    input  MemoryPacket                vertex_bundle_memory_response_in,
    output FIFOStateSignalsOutput      fifo_response_signals_out,
    input  FIFOStateSignalsInput       resp_fifo_in_signals,
    output MemoryPacket                vertex_bundle_memory_request_out,
    output FIFOStateSignalsOutput      fifo_request_signals_out,
    input  FIFOStateSignalsInput       fifo_request_signals_in,
    output logic                       fifo_setup_signal
);

    logic vertex_bundle_areset;
    logic areset_counter;
    logic areset_fifo;

// --------------------------------------------------------------------------------------
//   vertex_bundle state machine signals
// --------------------------------------------------------------------------------------
    vertex_bundle_state current_state;
    vertex_bundle_state next_state;

    logic vertex_bundle_done;
    logic vertex_bundle_start;

// --------------------------------------------------------------------------------------
//   FIFO signals
// --------------------------------------------------------------------------------------
    KernelDescriptor descriptor_reg;

    MemoryPacket vertex_bundle_mem_resp_dout;
    MemoryPacket vertex_bundle_mem_resp_din;

    MemoryPacket vertex_bundle_mem_req_dout;
    MemoryPacket vertex_bundle_mem_req_din;

    FIFOStateSignalsOutput fifo_response_signals_out_reg;
    FIFOStateSignalsOutput fifo_request_signals_out_reg;

    FIFOStateSignalsInput resp_fifo_in_signals_reg;
    FIFOStateSignalsInput fifo_request_signals_in_reg;

    logic fifo_MemoryPacketResponse_vertex_bundle_signal;
    logic fifo_MemoryPacketRequest_vertex_bundle_signal;

// --------------------------------------------------------------------------------------
//  Serial Read Engine Signals
// --------------------------------------------------------------------------------------
    SerialReadEngineConfiguration serial_read_config_reg;
    SerialReadEngineConfiguration serial_read_config_comb;
    MemoryPacket                  engine_serial_read_req;
    FIFOStateSignalsOutput        engine_serial_read_fifo_out_signals_reg;
    FIFOStateSignalsInput         engine_serial_read_fifo_in_signals_reg;
    logic                         engine_serial_read_in_start_reg;
    logic                         engine_serial_read_out_ready_reg;
    logic                         engine_serial_read_out_done_reg;
    logic                         engine_serial_read_out_pause_reg;
    logic                         engine_serial_read_fifo_setup_signal;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        vertex_bundle_areset <= areset;
        areset_counter       <= areset;
        areset_fifo          <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (vertex_bundle_areset) begin
            descriptor_reg.valid <= 0;
        end
        else begin
            descriptor_reg.valid <= descriptor.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        descriptor_reg.payload <= descriptor.payload;
    end

// --------------------------------------------------------------------------------------
// Drive input signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (vertex_bundle_areset) begin
            vertex_bundle_mem_resp_din.valid  <= 0;
            resp_fifo_in_signals_reg.rd_en    <= 0;
            fifo_request_signals_in_reg.rd_en <= 0;
        end
        else begin
            vertex_bundle_mem_resp_din.valid  <= vertex_bundle_memory_response_in.valid;
            resp_fifo_in_signals_reg.rd_en    <= resp_fifo_in_signals.rd_en;
            fifo_request_signals_in_reg.rd_en <= fifo_request_signals_in.rd_en;
        end
    end

    always_ff @(posedge ap_clk) begin
        vertex_bundle_mem_resp_din.payload <= vertex_bundle_memory_response_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (vertex_bundle_areset) begin
            fifo_setup_signal                      <= 1;
            vertex_bundle_memory_request_out.valid <= 0;
        end
        else begin
            fifo_setup_signal                      <= engine_serial_read_fifo_setup_signal | fifo_MemoryPacketRequest_vertex_bundle_signal |fifo_MemoryPacketResponse_vertex_bundle_signal;
            vertex_bundle_memory_request_out.valid <= fifo_request_signals_out_reg.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_request_signals_out                 <= fifo_request_signals_out_reg;
        fifo_response_signals_out                <= fifo_response_signals_out_reg;
        vertex_bundle_memory_request_out.payload <= vertex_bundle_mem_req_dout.payload;
    end

// --------------------------------------------------------------------------------------
// vertex_bundle State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(vertex_bundle_areset)
            current_state <= VERTEX_BUNDLE_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            VERTEX_BUNDLE_RESET : begin
                next_state = VERTEX_BUNDLE_IDLE;
            end
            VERTEX_BUNDLE_IDLE : begin
                if(descriptor_reg.valid && engine_serial_read_out_done_reg && engine_serial_read_out_ready_reg)
                    next_state = VERTEX_BUNDLE_REQ_START;
                else
                    next_state = VERTEX_BUNDLE_IDLE;
            end
            VERTEX_BUNDLE_REQ_START : begin
                if(engine_serial_read_out_done_reg && engine_serial_read_out_ready_reg) begin
                    next_state = VERTEX_BUNDLE_REQ_START;
                end else begin
                    next_state = VERTEX_BUNDLE_REQ_BUSY;
                end
            end
            VERTEX_BUNDLE_REQ_BUSY : begin
                if (vertex_bundle_done)
                    next_state = VERTEX_BUNDLE_REQ_DONE;
                else
                    next_state = VERTEX_BUNDLE_REQ_BUSY;
            end
            VERTEX_BUNDLE_REQ_DONE : begin
                if (descriptor_reg.valid)
                    next_state = VERTEX_BUNDLE_REQ_DONE;
                else
                    next_state = VERTEX_BUNDLE_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            VERTEX_BUNDLE_RESET : begin
                vertex_bundle_done                           <= 1'b1;
                vertex_bundle_start                          <= 1'b0;
                engine_serial_read_fifo_in_signals_reg.rd_en <= 1'b0;
                engine_serial_read_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b0;
            end
            VERTEX_BUNDLE_IDLE : begin
                vertex_bundle_done                           <= 1'b0;
                vertex_bundle_start                          <= 1'b0;
                engine_serial_read_fifo_in_signals_reg.rd_en <= 1'b0;
                engine_serial_read_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b0;
            end
            VERTEX_BUNDLE_REQ_START : begin
                vertex_bundle_done                           <= 1'b0;
                vertex_bundle_start                          <= 1'b1;
                engine_serial_read_fifo_in_signals_reg.rd_en <= 1'b0;
                engine_serial_read_in_start_reg              <= 1'b1;
                serial_read_config_reg.valid                 <= 1'b1;
            end
            VERTEX_BUNDLE_REQ_BUSY : begin
                vertex_bundle_done                           <= engine_serial_read_out_done_reg & engine_serial_read_fifo_out_signals_reg.empty;
                vertex_bundle_start                          <= 1'b0;
                engine_serial_read_fifo_in_signals_reg.rd_en <= ~engine_serial_read_fifo_out_signals_reg.empty & ~fifo_request_signals_out_reg.prog_full;
                engine_serial_read_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b1;
            end
            VERTEX_BUNDLE_REQ_DONE : begin
                vertex_bundle_done                           <= 1'b1;
                vertex_bundle_start                          <= 1'b0;
                engine_serial_read_fifo_in_signals_reg.rd_en <= 1'b0;
                engine_serial_read_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)


// --------------------------------------------------------------------------------------
// Serial Read Engine Generate
// --------------------------------------------------------------------------------------
    always_comb begin
        serial_read_config_comb.payload.increment     = 1'b1;
        serial_read_config_comb.payload.decrement     = 1'b0;
        serial_read_config_comb.payload.array_pointer = descriptor_reg.payload.graph_csr_struct;
        serial_read_config_comb.payload.array_size    = descriptor_reg.payload.auxiliary_2;
        serial_read_config_comb.payload.start_read    = 0;
        serial_read_config_comb.payload.end_read      = descriptor_reg.payload.auxiliary_2;
        serial_read_config_comb.payload.stride        = CACHE_FRONTEND_DATA_W/8;
        serial_read_config_comb.payload.granularity   = CACHE_FRONTEND_DATA_W/8;
    end

    always_ff @(posedge ap_clk) begin
        serial_read_config_reg.payload <= serial_read_config_comb.payload;
    end

    engine_serial_read #(
        .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
        .NUM_GRAPH_PE      (NUM_GRAPH_PE      ),
        .ENGINE_ID         (ENGINE_ID         ),
        .COUNTER_WIDTH     (COUNTER_WIDTH     )
    ) inst_engine_serial_read (
        .ap_clk                      (ap_clk                                 ),
        .areset                      (areset_counter                         ),
        .serial_read_config          (serial_read_config_reg                 ),
        .engine_serial_read_req_out  (engine_serial_read_req                 ),
        .fifo_request_signals_out    (engine_serial_read_fifo_out_signals_reg),
        .fifo_request_signals_in     (engine_serial_read_fifo_in_signals_reg ),
        .fifo_setup_signal           (engine_serial_read_fifo_setup_signal   ),
        .engine_serial_read_in_start (engine_serial_read_in_start_reg        ),
        .engine_serial_read_out_ready(engine_serial_read_out_ready_reg       ),
        .engine_serial_read_out_done (engine_serial_read_out_done_reg        ),
        .engine_serial_read_out_pause(engine_serial_read_out_pause_reg       )
    );

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
    assign fifo_MemoryPacketRequest_vertex_bundle_signal  = fifo_request_signals_out_reg.wr_rst_busy | fifo_request_signals_out_reg.rd_rst_busy;
    assign fifo_MemoryPacketResponse_vertex_bundle_signal = fifo_response_signals_out_reg.wr_rst_busy | fifo_response_signals_out_reg.rd_rst_busy;

// --------------------------------------------------------------------------------------
// FIFO cache requests in inst_fifo_812x16_MemoryPacket
// --------------------------------------------------------------------------------------
    assign resp_fifo_in_signals_reg.wr_en    = vertex_bundle_mem_resp_din.valid;
    assign vertex_bundle_mem_resp_dout.valid = fifo_response_signals_out_reg.valid;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (4                         )
    ) inst_fifo_MemoryPacketResponse (
        .clk         (ap_clk                                    ),
        .srst        (areset_fifo                               ),
        .din         (vertex_bundle_mem_resp_din.payload        ),
        .wr_en       (resp_fifo_in_signals_reg.wr_en            ),
        .rd_en       (resp_fifo_in_signals_reg.rd_en            ),
        .dout        (vertex_bundle_mem_resp_dout.payload       ),
        .full        (fifo_response_signals_out_reg.full        ),
        .almost_full (fifo_response_signals_out_reg.almost_full ),
        .empty       (fifo_response_signals_out_reg.empty       ),
        .almost_empty(fifo_response_signals_out_reg.almost_empty),
        .valid       (fifo_response_signals_out_reg.valid       ),
        .prog_full   (fifo_response_signals_out_reg.prog_full   ),
        .prog_empty  (fifo_response_signals_out_reg.prog_empty  ),
        .wr_rst_busy (fifo_response_signals_out_reg.wr_rst_busy ),
        .rd_rst_busy (fifo_response_signals_out_reg.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out inst_fifo_812x16_MemoryPacket
// --------------------------------------------------------------------------------------
    assign fifo_request_signals_in_reg.wr_en = vertex_bundle_mem_req_din.valid;
    assign vertex_bundle_mem_req_dout.valid  = fifo_request_signals_out_reg.valid;
    assign vertex_bundle_mem_req_din         = engine_serial_read_req;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (4                         )
    ) inst_fifo_MemoryPacketRequest (
        .clk         (ap_clk                                   ),
        .srst        (areset_fifo                              ),
        .din         (vertex_bundle_mem_req_din.payload        ),
        .wr_en       (fifo_request_signals_in_reg.wr_en        ),
        .rd_en       (fifo_request_signals_in_reg.rd_en        ),
        .dout        (vertex_bundle_mem_req_dout.payload       ),
        .full        (fifo_request_signals_out_reg.full        ),
        .almost_full (fifo_request_signals_out_reg.almost_full ),
        .empty       (fifo_request_signals_out_reg.empty       ),
        .almost_empty(fifo_request_signals_out_reg.almost_empty),
        .valid       (fifo_request_signals_out_reg.valid       ),
        .prog_full   (fifo_request_signals_out_reg.prog_full   ),
        .prog_empty  (fifo_request_signals_out_reg.prog_empty  ),
        .wr_rst_busy (fifo_request_signals_out_reg.wr_rst_busy ),
        .rd_rst_busy (fifo_request_signals_out_reg.rd_rst_busy )
    );

endmodule : vertex_bundle