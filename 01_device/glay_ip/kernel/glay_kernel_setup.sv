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
import GLAY_MEMORY_PKG::*;
import GLAY_ENGINE_PKG::*;
import GLAY_SETUP_PKG::*;

module glay_kernel_setup #(
    parameter NUM_GRAPH_CLUSTERS  = CU_COUNT_GLOBAL,
    parameter NUM_GRAPH_PE        = CU_COUNT_LOCAL ,
    parameter NUM_SETUP_CACHELINE = 2              ,
    parameter ENGINE_ID           = 0              ,
    parameter COUNTER_WIDTH       = 32
) (
    // System Signals
    input  logic                           ap_clk                       ,
    input  logic                           areset                       ,
    input  GlayControlChainInterfaceOutput glay_control_state           ,
    input  GLAYDescriptorInterface         glay_descriptor              ,
    input  MemoryResponsePacket            glay_setup_mem_resp_in       ,
    output FIFOStateSignalsOutput          resp_fifo_out_signals        ,
    input  FIFOStateSignalsInput           resp_fifo_in_signals         ,
    output MemoryRequestPacket             glay_kernel_setup_mem_req_out,
    output FIFOStateSignalsOutput          req_fifo_out_signals         ,
    input  FIFOStateSignalsInput           req_fifo_in_signals          ,
    output logic                           fifo_setup_signal
);

    logic setup_areset  ;
    logic counter_areset;
    logic fifo_areset   ;

// --------------------------------------------------------------------------------------
//   Setup state machine signals
// --------------------------------------------------------------------------------------
    kernel_setup_state current_state;
    kernel_setup_state next_state   ;

    logic kernel_setup_done ;
    logic kernel_setup_start;



// --------------------------------------------------------------------------------------
//   AXI Cache FIFO signals
// --------------------------------------------------------------------------------------
    GLAYDescriptorInterface glay_descriptor_reg;

    MemoryResponsePacket glay_setup_mem_resp_dout;
    MemoryResponsePacket glay_setup_mem_resp_din ;

    MemoryRequestPacket glay_setup_mem_req_dout;
    MemoryRequestPacket glay_setup_mem_req_din ;

    FIFOStateSignalsOutput resp_fifo_out_signals_reg;
    FIFOStateSignalsOutput req_fifo_out_signals_reg ;

    FIFOStateSignalsInput resp_fifo_in_signals_reg;
    FIFOStateSignalsInput req_fifo_in_signals_reg ;

    logic fifo_setup_signal_reg;

// --------------------------------------------------------------------------------------
//  Serial Read Engine Signals
// --------------------------------------------------------------------------------------

    SerialReadEngineConfiguration serial_read_config_reg                  ;
    SerialReadEngineConfiguration serial_read_config_comb                 ;
    MemoryRequestPacket           serial_read_engine_req                  ;
    FIFOStateSignalsOutput        serial_read_engine_fifo_out_signals_reg ;
    FIFOStateSignalsInput         serial_read_engine_fifo_in_signals_reg  ;
    logic                         serial_read_engine_fifo_setup_signal_reg;
    logic                         serial_read_engine_in_start_reg         ;
    logic                         serial_read_engine_out_ready_reg        ;
    logic                         serial_read_engine_out_done_reg         ;
    logic                         serial_read_engine_out_pause_reg        ;


// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        setup_areset   <= areset;
        counter_areset <= areset;
        fifo_areset    <= areset;
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
            glay_setup_mem_resp_din.valid  <= 0;
            resp_fifo_in_signals_reg.rd_en <= 0;
            req_fifo_in_signals_reg.rd_en  <= 0;
        end
        else begin
            glay_setup_mem_resp_din.valid  <= glay_setup_mem_resp_in.valid;
            resp_fifo_in_signals_reg.rd_en <= resp_fifo_in_signals.rd_en;
            req_fifo_in_signals_reg.rd_en  <= req_fifo_in_signals.rd_en;
        end
    end

    always_ff @(posedge ap_clk) begin
        glay_setup_mem_resp_din.payload <= glay_setup_mem_resp_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output signals
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if (setup_areset) begin
            fifo_setup_signal                   <= 1;
            glay_kernel_setup_mem_req_out.valid <= 0;
        end
        else begin
            fifo_setup_signal                   <= fifo_setup_signal_reg;
            glay_kernel_setup_mem_req_out.valid <= req_fifo_out_signals_reg.valid ;
        end
    end

    always_ff @(posedge ap_clk) begin
        req_fifo_out_signals                  <= req_fifo_out_signals_reg;
        resp_fifo_out_signals                 <= resp_fifo_out_signals_reg;
        glay_kernel_setup_mem_req_out.payload <= glay_setup_mem_req_dout.payload;
    end

// --------------------------------------------------------------------------------------
// GLAY SETUP State Machine
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(setup_areset)
            current_state <= SETUP_KERNEL_RESET;
        else begin
            current_state <= next_state;
        end
    end // always_ff @(posedge ap_clk)

    always_comb begin
        next_state = current_state;
        case (current_state)
            SETUP_KERNEL_RESET : begin
                next_state = SETUP_KERNEL_IDLE;
            end
            SETUP_KERNEL_IDLE : begin
                if(glay_descriptor_reg.valid && serial_read_engine_out_done_reg && serial_read_engine_out_ready_reg)
                    next_state = SETUP_KERNEL_REQ_START;
                else
                    next_state = SETUP_KERNEL_IDLE;
            end
            SETUP_KERNEL_REQ_START : begin
                if(serial_read_engine_out_done_reg && serial_read_engine_out_ready_reg) begin
                    next_state = SETUP_KERNEL_REQ_START;
                end else begin
                    next_state = SETUP_KERNEL_REQ_BUSY;
                end
            end
            SETUP_KERNEL_REQ_BUSY : begin
                if (kernel_setup_done)
                    next_state = SETUP_KERNEL_REQ_DONE;
                else
                    next_state = SETUP_KERNEL_REQ_BUSY;
            end
            SETUP_KERNEL_REQ_DONE : begin
                if (glay_descriptor_reg.valid)
                    next_state = SETUP_KERNEL_REQ_DONE;
                else
                    next_state = SETUP_KERNEL_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            SETUP_KERNEL_RESET : begin
                kernel_setup_done                            <= 1'b1;
                kernel_setup_start                           <= 1'b0;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
                serial_read_engine_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b0;
            end
            SETUP_KERNEL_IDLE : begin
                kernel_setup_done                            <= 1'b0;
                kernel_setup_start                           <= 1'b0;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
                serial_read_engine_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b0;
            end
            SETUP_KERNEL_REQ_START : begin
                kernel_setup_done                            <= 1'b0;
                kernel_setup_start                           <= 1'b1;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
                serial_read_engine_in_start_reg              <= 1'b1;
                serial_read_config_reg.valid                 <= 1'b1;
            end
            SETUP_KERNEL_REQ_BUSY : begin
                kernel_setup_done                            <= serial_read_engine_out_done_reg & serial_read_engine_fifo_out_signals_reg.empty;
                kernel_setup_start                           <= 1'b0;
                serial_read_engine_fifo_in_signals_reg.rd_en <= ~serial_read_engine_fifo_out_signals_reg.empty & ~req_fifo_out_signals_reg.prog_full;
                serial_read_engine_in_start_reg              <= 1'b0;
                serial_read_config_reg.valid                 <= 1'b1;
            end
            SETUP_KERNEL_REQ_DONE : begin
                kernel_setup_done                            <= 1'b1;
                kernel_setup_start                           <= 1'b0;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
                serial_read_engine_in_start_reg              <= 1'b0;
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
        serial_read_config_comb.payload.array_pointer = glay_descriptor_reg.payload.graph_csr_struct;
        serial_read_config_comb.payload.array_size    = glay_descriptor_reg.payload.auxiliary_2;
        serial_read_config_comb.payload.start_read    = 0;
        serial_read_config_comb.payload.end_read      = glay_descriptor_reg.payload.auxiliary_2;
        serial_read_config_comb.payload.stride        = 64;
        serial_read_config_comb.payload.granularity   = 64;
    end

    always_ff @(posedge ap_clk) begin
        serial_read_config_reg.payload <= serial_read_config_comb.payload;
    end

    serial_read_engine #(
        .NUM_GRAPH_CLUSTERS(NUM_GRAPH_CLUSTERS),
        .NUM_GRAPH_PE      (NUM_GRAPH_PE      ),
        .ENGINE_ID         (ENGINE_ID         ),
        .COUNTER_WIDTH     (COUNTER_WIDTH     )
    ) inst_serial_read_engine (
        .ap_clk                      (ap_clk                                  ),
        .areset                      (counter_areset                          ),
        .serial_read_config          (serial_read_config_reg                  ),
        .serial_read_engine_req_out  (serial_read_engine_req                  ),
        .req_fifo_out_signals        (serial_read_engine_fifo_out_signals_reg ),
        .req_fifo_in_signals         (serial_read_engine_fifo_in_signals_reg  ),
        .fifo_setup_signal           (serial_read_engine_fifo_setup_signal_reg),
        .serial_read_engine_in_start (serial_read_engine_in_start_reg         ),
        .serial_read_engine_out_ready(serial_read_engine_out_ready_reg        ),
        .serial_read_engine_out_done (serial_read_engine_out_done_reg         ),
        .serial_read_engine_out_pause(serial_read_engine_out_pause_reg        )
    );

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
    assign fifo_setup_signal_reg = serial_read_engine_fifo_setup_signal_reg | req_fifo_out_signals_reg.wr_rst_busy | req_fifo_out_signals_reg.rd_rst_busy | resp_fifo_out_signals_reg.wr_rst_busy | resp_fifo_out_signals_reg.rd_rst_busy;

// --------------------------------------------------------------------------------------
// FIFO cache requests in inst_fifo_710x32_MemoryResponsePacket
// --------------------------------------------------------------------------------------
    assign resp_fifo_in_signals_reg.wr_en = glay_setup_mem_resp_din.valid;
    assign glay_setup_mem_resp_dout.valid = resp_fifo_out_signals_reg.valid;

    fifo_710x32 inst_fifo_710x32_MemoryResponsePacket (
        .clk         (ap_clk                                ),
        .srst        (fifo_areset                           ),
        .din         (glay_setup_mem_resp_din.payload       ),
        .wr_en       (resp_fifo_in_signals_reg.wr_en        ),
        .rd_en       (resp_fifo_in_signals_reg.rd_en        ),
        .dout        (glay_setup_mem_resp_dout.payload      ),
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
// FIFO cache requests out inst_fifo_166x32_MemoryRequestPacket
// --------------------------------------------------------------------------------------
    assign req_fifo_in_signals_reg.wr_en = glay_setup_mem_req_din.valid;
    assign glay_setup_mem_req_dout.valid = req_fifo_out_signals_reg.valid;
    assign glay_setup_mem_req_din        = serial_read_engine_req;

    fifo_166x32 inst_fifo_166x32_MemoryRequestPacket (
        .clk         (ap_clk                               ),
        .srst        (fifo_areset                          ),
        .din         (glay_setup_mem_req_din.payload       ),
        .wr_en       (req_fifo_in_signals_reg.wr_en        ),
        .rd_en       (req_fifo_in_signals_reg.rd_en        ),
        .dout        (glay_setup_mem_req_dout.payload      ),
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

endmodule : glay_kernel_setup