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

module vertex_cu #(
    parameter NUM_GRAPH_CLUSTERS = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE       = CU_COUNT_LOCAL ,
    parameter ENGINE_ID          = 0              ,
    parameter COUNTER_WIDTH      = 32
) (
    // System Signals
    input  logic                       ap_clk               ,
    input  logic                       areset               ,
    input  ControlChainInterfaceOutput control_state        ,
    input  DescriptorInterface         descriptor           ,
    input  MemoryPacket                vertex_cu_mem_resp_in,
    output FIFOStateSignalsOutput      resp_fifo_out_signals,
    input  FIFOStateSignalsInput       resp_fifo_in_signals ,
    output MemoryPacket                vertex_cu_mem_req_out,
    output FIFOStateSignalsOutput      req_fifo_out_signals ,
    input  FIFOStateSignalsInput       req_fifo_in_signals  ,
    output logic                       fifo_setup_signal
);

    logic vertex_cu_areset;
    logic counter_areset  ;
    logic fifo_areset     ;

// --------------------------------------------------------------------------------------
//   vertex_cu state machine signals
// --------------------------------------------------------------------------------------
    vertex_cu_state current_state;
    vertex_cu_state next_state   ;

    logic vertex_cu_done ;
    logic vertex_cu_start;

// --------------------------------------------------------------------------------------
//   FIFO signals
// --------------------------------------------------------------------------------------
    DescriptorInterface descriptor_reg;

    MemoryPacket vertex_cu_mem_resp_dout;
    MemoryPacket vertex_cu_mem_resp_din ;

    MemoryPacket vertex_cu_mem_req_dout;
    MemoryPacket vertex_cu_mem_req_din ;

    FIFOStateSignalsOutput resp_fifo_out_signals_reg;
    FIFOStateSignalsOutput req_fifo_out_signals_reg ;

    FIFOStateSignalsInput resp_fifo_in_signals_reg;
    FIFOStateSignalsInput req_fifo_in_signals_reg ;

    logic fifo_MemoryPacketResponse_vertex_cu_signal;
    logic fifo_MemoryPacketRequest_vertex_cu_signal ;

// --------------------------------------------------------------------------------------
//  Serial Read Engine Signals
// --------------------------------------------------------------------------------------
    SerialReadEngineConfiguration serial_read_config_reg                 ;
    SerialReadEngineConfiguration serial_read_config_comb                ;
    MemoryPacket                  engine_serial_read_req                 ;
    FIFOStateSignalsOutput        engine_serial_read_fifo_out_signals_reg;
    FIFOStateSignalsInput         engine_serial_read_fifo_in_signals_reg ;
    logic                         engine_serial_read_in_start_reg        ;
    logic                         engine_serial_read_out_ready_reg       ;
    logic                         engine_serial_read_out_done_reg        ;
    logic                         engine_serial_read_out_pause_reg       ;
    logic                         engine_serial_read_fifo_setup_signal   ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        vertex_cu_areset <= areset;
        counter_areset   <= areset;
        fifo_areset      <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (vertex_cu_areset) begin
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
        if (vertex_cu_areset) begin
            vertex_cu_mem_resp_din.valid   <= 0;
            resp_fifo_in_signals_reg.rd_en <= 0;
            req_fifo_in_signals_reg.rd_en  <= 0;
        end
        else begin
            vertex_cu_mem_resp_din.valid   <= vertex_cu_mem_resp_in.valid;
            resp_fifo_in_signals_reg.rd_en <= resp_fifo_in_signals.rd_en;
            req_fifo_in_signals_reg.rd_en  <= req_fifo_in_signals.rd_en;
        end
    end

    always_ff @(posedge ap_clk) begin
        vertex_cu_mem_resp_din.payload <= vertex_cu_mem_resp_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (vertex_cu_areset) begin
            fifo_setup_signal           <= 1;
            vertex_cu_mem_req_out.valid <= 0;
        end
        else begin
            fifo_setup_signal           <= engine_serial_read_fifo_setup_signal | fifo_MemoryPacketRequest_vertex_cu_signal |fifo_MemoryPacketResponse_vertex_cu_signal;
            vertex_cu_mem_req_out.valid <= req_fifo_out_signals_reg.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        req_fifo_out_signals          <= req_fifo_out_signals_reg;
        resp_fifo_out_signals         <= resp_fifo_out_signals_reg;
        vertex_cu_mem_req_out.payload <= vertex_cu_mem_req_dout.payload;
    end

// --------------------------------------------------------------------------------------
// vertex_cu State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(vertex_cu_areset)
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
                if(descriptor_reg.valid && engine_serial_read_out_done_reg && engine_serial_read_out_ready_reg)
                    next_state = VERTEX_CU_REQ_START;
                else
                    next_state = VERTEX_CU_IDLE;
            end
            VERTEX_CU_REQ_START : begin
                if(engine_serial_read_out_done_reg && engine_serial_read_out_ready_reg) begin
                    next_state = VERTEX_CU_REQ_START;
                end else begin
                    next_state = VERTEX_CU_REQ_BUSY;
                end
            end
            VERTEX_CU_REQ_BUSY : begin
                if (vertex_cu_done)
                    next_state = VERTEX_CU_REQ_DONE;
                else
                    next_state = VERTEX_CU_REQ_BUSY;
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
                vertex_cu_done                               <= 1'b1;
                vertex_cu_start                              <= 1'b0;
                engine_serial_read_fifo_in_signals_reg.rd_en <= 1'b0;
                engine_serial_read_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b0;
            end
            VERTEX_CU_IDLE : begin
                vertex_cu_done                               <= 1'b0;
                vertex_cu_start                              <= 1'b0;
                engine_serial_read_fifo_in_signals_reg.rd_en <= 1'b0;
                engine_serial_read_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b0;
            end
            VERTEX_CU_REQ_START : begin
                vertex_cu_done                               <= 1'b0;
                vertex_cu_start                              <= 1'b1;
                engine_serial_read_fifo_in_signals_reg.rd_en <= 1'b0;
                engine_serial_read_in_start_reg              <= 1'b1;
                serial_read_config_reg.valid                 <= 1'b1;
            end
            VERTEX_CU_REQ_BUSY : begin
                vertex_cu_done                               <= engine_serial_read_out_done_reg & engine_serial_read_fifo_out_signals_reg.empty;
                vertex_cu_start                              <= 1'b0;
                engine_serial_read_fifo_in_signals_reg.rd_en <= ~engine_serial_read_fifo_out_signals_reg.empty & ~req_fifo_out_signals_reg.prog_full;
                engine_serial_read_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b1;
            end
            VERTEX_CU_REQ_DONE : begin
                vertex_cu_done                               <= 1'b1;
                vertex_cu_start                              <= 1'b0;
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
        serial_read_config_comb.payload.stride        = 64;
        serial_read_config_comb.payload.granularity   = 64;
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
        .areset                      (counter_areset                         ),
        .serial_read_config          (serial_read_config_reg                 ),
        .engine_serial_read_req_out  (engine_serial_read_req                 ),
        .req_fifo_out_signals        (engine_serial_read_fifo_out_signals_reg),
        .req_fifo_in_signals         (engine_serial_read_fifo_in_signals_reg ),
        .fifo_setup_signal           (engine_serial_read_fifo_setup_signal   ),
        .engine_serial_read_in_start (engine_serial_read_in_start_reg        ),
        .engine_serial_read_out_ready(engine_serial_read_out_ready_reg       ),
        .engine_serial_read_out_done (engine_serial_read_out_done_reg        ),
        .engine_serial_read_out_pause(engine_serial_read_out_pause_reg       )
    );

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
    assign fifo_MemoryPacketRequest_vertex_cu_signal  = req_fifo_out_signals_reg.wr_rst_busy | req_fifo_out_signals_reg.rd_rst_busy;
    assign fifo_MemoryPacketResponse_vertex_cu_signal = resp_fifo_out_signals_reg.wr_rst_busy | resp_fifo_out_signals_reg.rd_rst_busy;

// --------------------------------------------------------------------------------------
// FIFO cache requests in inst_fifo_812x16_MemoryPacket
// --------------------------------------------------------------------------------------
    assign resp_fifo_in_signals_reg.wr_en = vertex_cu_mem_resp_din.valid;
    assign vertex_cu_mem_resp_dout.valid  = resp_fifo_out_signals_reg.valid;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (4                         )
    ) inst_fifo_MemoryPacketResponse (
        .clk         (ap_clk                                ),
        .srst        (fifo_areset                           ),
        .din         (vertex_cu_mem_resp_din.payload        ),
        .wr_en       (resp_fifo_in_signals_reg.wr_en        ),
        .rd_en       (resp_fifo_in_signals_reg.rd_en        ),
        .dout        (vertex_cu_mem_resp_dout.payload       ),
        .full        (resp_fifo_out_signals_reg.full        ),
        .almost_full (resp_fifo_out_signals_reg.almost_full ),
        .empty       (resp_fifo_out_signals_reg.empty       ),
        .almost_empty(resp_fifo_out_signals_reg.almost_empty),
        .valid       (resp_fifo_out_signals_reg.valid       ),
        .prog_full   (resp_fifo_out_signals_reg.prog_full   ),
        .prog_empty  (resp_fifo_out_signals_reg.prog_empty  ),
        .wr_rst_busy (resp_fifo_out_signals_reg.wr_rst_busy ),
        .rd_rst_busy (resp_fifo_out_signals_reg.rd_rst_busy )
    );

// --------------------------------------------------------------------------------------
// FIFO cache requests out inst_fifo_812x16_MemoryPacket
// --------------------------------------------------------------------------------------
    assign req_fifo_in_signals_reg.wr_en = vertex_cu_mem_req_din.valid;
    assign vertex_cu_mem_req_dout.valid  = req_fifo_out_signals_reg.valid;
    assign vertex_cu_mem_req_din         = engine_serial_read_req;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(16                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (4                         )
    ) inst_fifo_MemoryPacketRequest (
        .clk         (ap_clk                               ),
        .srst        (fifo_areset                          ),
        .din         (vertex_cu_mem_req_din.payload        ),
        .wr_en       (req_fifo_in_signals_reg.wr_en        ),
        .rd_en       (req_fifo_in_signals_reg.rd_en        ),
        .dout        (vertex_cu_mem_req_dout.payload       ),
        .full        (req_fifo_out_signals_reg.full        ),
        .almost_full (req_fifo_out_signals_reg.almost_full ),
        .empty       (req_fifo_out_signals_reg.empty       ),
        .almost_empty(req_fifo_out_signals_reg.almost_empty),
        .valid       (req_fifo_out_signals_reg.valid       ),
        .prog_full   (req_fifo_out_signals_reg.prog_full   ),
        .prog_empty  (req_fifo_out_signals_reg.prog_empty  ),
        .wr_rst_busy (req_fifo_out_signals_reg.wr_rst_busy ),
        .rd_rst_busy (req_fifo_out_signals_reg.rd_rst_busy )
    );

endmodule : vertex_cu