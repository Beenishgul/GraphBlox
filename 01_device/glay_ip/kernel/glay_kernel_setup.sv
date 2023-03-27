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
    input  logic                           ap_clk                  ,
    input  logic                           areset                  ,
    input  GlayControlChainInterfaceOutput glay_control_state      ,
    input  GLAYDescriptorInterface         glay_descriptor         ,
    input  GlayCacheRequestInterfaceOutput glay_setup_cache_req_in ,
    output FIFOStateSignalsOutput          req_in_fifo_out_signals ,
    input  FIFOStateSignalsInput           req_in_fifo_in_signals  ,
    output GlayCacheRequestInterfaceInput  glay_setup_cache_req_out,
    output FIFOStateSignalsOutput          req_out_fifo_out_signals,
    input  FIFOStateSignalsInput           req_out_fifo_in_signals ,
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
            glay_setup_cache_req_in_din.valid <= 0;
            req_in_fifo_in_signals_reg        <= 0;
            req_out_fifo_in_signals_reg       <= 0;
        end
        else begin
            glay_setup_cache_req_in_din.valid <= glay_setup_cache_req_in.valid;
            req_in_fifo_in_signals_reg        <= req_in_fifo_in_signals;
            req_out_fifo_in_signals_reg       <= req_out_fifo_in_signals;
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
                if(glay_descriptor_reg.valid)
                    next_state = SETUP_KERNEL_REQ_START;
                else
                    next_state = SETUP_KERNEL_IDLE;
            end
            SETUP_KERNEL_REQ_START : begin
                next_state = SETUP_KERNEL_REQ_BUSY;
            end
            SETUP_KERNEL_REQ_BUSY : begin
                if (kernel_setup_done)
                    next_state = SETUP_KERNEL_REQ_DONE;
                else
                    next_state = SETUP_KERNEL_REQ_BUSY;
            end
            SETUP_KERNEL_REQ_DONE : begin
                next_state = SETUP_KERNEL_IDLE;
            end
        endcase
    end // always_comb

    always_ff @(posedge ap_clk) begin
        case (current_state)
            SETUP_KERNEL_RESET : begin
                glay_setup_cache_req_out_din.valid           <= 1'b0;
                kernel_setup_done                            <= 1'b1;
                kernel_setup_start                           <= 1'b0;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
            end
            SETUP_KERNEL_IDLE : begin
                glay_setup_cache_req_out_din.valid           <= 1'b0;
                kernel_setup_done                            <= 1'b0;
                kernel_setup_start                           <= 1'b0;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
            end
            SETUP_KERNEL_REQ_START : begin
                glay_setup_cache_req_out_din.valid           <= 1'b0;
                kernel_setup_done                            <= 1'b0;
                kernel_setup_start                           <= 1'b1;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
            end
            SETUP_KERNEL_REQ_BUSY : begin
                glay_setup_cache_req_out_din.valid           <= 1'b0;
                kernel_setup_done                            <= serial_read_engine_done_reg;
                kernel_setup_start                           <= 1'b1;
                serial_read_engine_fifo_in_signals_reg.rd_en <= ~req_out_fifo_out_signals_reg.almost_full && ~serial_read_engine_fifo_out_signals_reg.empty;
            end
            SETUP_KERNEL_REQ_DONE : begin
                glay_setup_cache_req_out_din.valid           <= 1'b0;
                kernel_setup_done                            <= 1'b1;
                kernel_setup_start                           <= 1'b0;
                serial_read_engine_fifo_in_signals_reg.rd_en <= 1'b0;
            end
        endcase
    end // always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
// Generate Requests Logic
// --------------------------------------------------------------------------------------

    SerialReadEngineConfiguration serial_read_config_reg                  ;
    MemoryRequestPacket           serial_read_engine_req_out_reg          ;
    FIFOStateSignalsOutput        serial_read_engine_fifo_out_signals_reg ;
    FIFOStateSignalsInput         serial_read_engine_fifo_in_signals_reg  ;
    logic                         serial_read_engine_fifo_setup_signal_reg;
    logic                         serial_read_engine_in_start_reg         ;
    logic                         serial_read_engine_out_ready_reg        ;
    logic                         serial_read_engine_done_reg             ;

    always_ff @(posedge ap_clk) begin
        if (setup_areset) begin
            serial_read_config_reg.valid <= 0;
        end
        else begin
            serial_read_config_reg.valid <= glay_descriptor_reg.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        serial_read_config_reg.payload.increment     <= 1'b1;
        serial_read_config_reg.payload.decrement     <= 1'b0;
        serial_read_config_reg.payload.array_pointer <= glay_descriptor_reg.payload.graph_csr_struct;
        serial_read_config_reg.payload.array_size    <= 2;
        serial_read_config_reg.payload.start_read    <= 0;
        serial_read_config_reg.payload.end_read      <= 2;
        serial_read_config_reg.payload.stride        <= 1;
        serial_read_config_reg.payload.granularity   <= 64;
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
        .serial_read_engine_req_out  (serial_read_engine_req_out_reg          ),
        .req_out_fifo_out_signals    (serial_read_engine_fifo_out_signals_reg ),
        .req_out_fifo_in_signals     (serial_read_engine_fifo_in_signals_reg  ),
        .fifo_setup_signal           (serial_read_engine_fifo_setup_signal_reg),
        .serial_read_engine_in_start (serial_read_engine_in_start_reg         ),
        .serial_read_engine_out_ready(serial_read_engine_out_ready_reg        ),
        .serial_read_engine_done     (serial_read_engine_done_reg             )
    );

// --------------------------------------------------------------------------------------
// FIFO cache Ready
// --------------------------------------------------------------------------------------
    assign fifo_setup_signal_reg = serial_read_engine_fifo_setup_signal_reg | req_out_fifo_out_signals_reg.wr_rst_busy | req_out_fifo_out_signals_reg.rd_rst_busy | req_in_fifo_out_signals_reg.wr_rst_busy | req_in_fifo_out_signals_reg.rd_rst_busy;

// --------------------------------------------------------------------------------------
// FIFO cache requests in fifo_638x32_GlaySetupRequestInterfaceInput
// --------------------------------------------------------------------------------------
    assign req_in_fifo_in_signals_reg.wr_en   = glay_setup_cache_req_in_din.valid;
    assign glay_setup_cache_req_in_dout.valid = req_in_fifo_out_signals_reg.valid;

    fifo_638x32 inst_fifo_638x32_GlaySetupRequestInterfaceInput (
        .clk         (ap_clk                                  ),
        .srst        (fifo_areset                             ),
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
    assign req_out_fifo_in_signals_reg.wr_en  = glay_setup_cache_req_out_din.valid;
    assign glay_setup_cache_req_in_dout.valid = req_out_fifo_out_signals_reg.valid;

    fifo_516x32 inst_fifo_516x32_GlaySetupRequestInterfaceOutput (
        .clk         (ap_clk                                   ),
        .srst        (fifo_areset                              ),
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