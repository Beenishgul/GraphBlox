// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_csr_index_configure_memory.sv
// Create : 2023-07-17 15:02:02
// Revise : 2023-08-28 15:42:14
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_CACHE::*;

module engine_csr_index_configure_memory #(parameter
    ID_CU            = 0                                ,
    ID_BUNDLE        = 0                                ,
    ID_LANE          = 0                                ,
    ID_ENGINE        = 0                                ,
    ID_RELATIVE      = 0                                ,
    ID_MODULE        = 0                                ,
    ENGINE_SEQ_WIDTH = 16                               ,
    ENGINE_SEQ_MIN   = ID_RELATIVE * ENGINE_SEQ_WIDTH   ,
    ENGINE_SEQ_MAX   = ENGINE_SEQ_WIDTH + ENGINE_SEQ_MIN
) (
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output CSRIndexConfiguration  configure_memory_out               ,
    input  FIFOStateSignalsInput  fifo_configure_memory_signals_in   ,
    output FIFOStateSignalsOutput fifo_configure_memory_signals_out  ,
    output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_csr_index_generator;
    logic areset_fifo               ;

    MemoryPacket                      response_memory_in_reg                          ;
    MemoryPacketMeta                  configure_memory_meta_int                       ;
    CSRIndexConfiguration             configure_memory_reg                            ;
    logic [     ENGINE_SEQ_WIDTH-1:0] configure_memory_valid_reg                      ;
    logic                             configure_memory_valid_int                      ;
    logic [CACHE_FRONTEND_ADDR_W-1:0] response_memory_in_reg_offset_sequence          ;
    logic [CACHE_FRONTEND_ADDR_W-1:0] fifo_response_memory_in_dout_int_offset_sequence;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_memory_in_din             ;
    MemoryPacket           fifo_response_memory_in_dout_int        ;
    MemoryPacketPayload    fifo_response_memory_in_dout            ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_memory_in_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_memory_in_signals_out_int ;
    logic                  fifo_response_memory_in_setup_signal_int;
    logic                  fifo_response_memory_in_push_filter     ;

// --------------------------------------------------------------------------------------
// Configure FIFO
// --------------------------------------------------------------------------------------
    CSRIndexConfigurationPayload fifo_configure_memory_din             ;
    CSRIndexConfiguration        fifo_configure_memory_dout_int        ;
    CSRIndexConfigurationPayload fifo_configure_memory_dout            ;
    FIFOStateSignalsInput        fifo_configure_memory_signals_in_reg  ;
    FIFOStateSignalsInput        fifo_configure_memory_signals_in_int  ;
    FIFOStateSignalsOutput       fifo_configure_memory_signals_out_int ;
    logic                        fifo_configure_memory_setup_signal_int;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_csr_index_generator <= areset;
        areset_fifo                <= areset;
    end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_csr_index_generator) begin
            response_memory_in_reg.valid           <= 1'b0;
            fifo_response_memory_in_signals_in_reg <= 0;
            fifo_configure_memory_signals_in_reg   <= 0;
        end else begin
            response_memory_in_reg.valid                 <= response_memory_in.valid ;
            fifo_response_memory_in_signals_in_reg.rd_en <= fifo_response_memory_in_signals_in.rd_en;
            fifo_configure_memory_signals_in_reg.rd_en   <= fifo_configure_memory_signals_in.rd_en;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_memory_in_reg.payload <= response_memory_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_csr_index_generator) begin
            fifo_setup_signal          <= 1'b1;
            configure_memory_out.valid <= 0;
        end else begin
            fifo_setup_signal          <= fifo_response_memory_in_setup_signal_int | fifo_configure_memory_setup_signal_int;
            configure_memory_out.valid <= fifo_configure_memory_dout_int.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_memory_in_signals_out <= fifo_response_memory_in_signals_out_int;
        fifo_configure_memory_signals_out   <= fifo_configure_memory_signals_out_int;
        configure_memory_out.payload        <= fifo_configure_memory_dout_int.payload;
    end


// --------------------------------------------------------------------------------------
// Create Configuration Packet
// --------------------------------------------------------------------------------------
    assign configure_memory_valid_int                       = &configure_memory_valid_reg;
    assign response_memory_in_reg_offset_sequence           = (response_memory_in_reg.payload.meta.address.offset >> response_memory_in_reg.payload.meta.address.shift.amount);
    assign fifo_response_memory_in_dout_int_offset_sequence = (fifo_response_memory_in_dout_int.payload.meta.address.offset >> fifo_response_memory_in_dout_int.payload.meta.address.shift.amount);

    always_comb begin
        configure_memory_meta_int.route.from.id_cu        = 1'b1 << ID_CU;
        configure_memory_meta_int.route.from.id_bundle    = 1'b1 << ID_BUNDLE;
        configure_memory_meta_int.route.from.id_lane      = 1'b1 << ID_LANE;
        configure_memory_meta_int.route.from.id_engine    = 1'b1 << ID_ENGINE;
        configure_memory_meta_int.route.from.id_module    = 1'b1 << ID_MODULE;
        configure_memory_meta_int.route.from.id_buffer    = 0;
        configure_memory_meta_int.route.to.id_cu          = 0;
        configure_memory_meta_int.route.to.id_bundle      = 0;
        configure_memory_meta_int.route.to.id_lane        = 0;
        configure_memory_meta_int.route.to.id_engine      = 0;
        configure_memory_meta_int.route.to.id_module      = 1;
        configure_memory_meta_int.route.to.id_buffer      = 0;
        configure_memory_meta_int.route.forward_value     = CU_BUNDLE_COUNT_WIDTH_BITS;
        configure_memory_meta_int.address.base            = 0;
        configure_memory_meta_int.address.offset          = $clog2(CACHE_FRONTEND_DATA_W/8);
        configure_memory_meta_int.address.shift.amount    = 0;
        configure_memory_meta_int.address.shift.direction = 1'b1;
        configure_memory_meta_int.subclass.cmd            = CMD_INVALID;
        configure_memory_meta_int.subclass.buffer         = STRUCT_INVALID;
        configure_memory_meta_int.subclass.operand        = OP_LOCATION_0;
        configure_memory_meta_int.subclass.filter         = FILTER_NOP;
        configure_memory_meta_int.subclass.alu            = ALU_NOP;
    end

    always_ff @(posedge ap_clk) begin
        if(areset_csr_index_generator) begin
            configure_memory_reg       <= 0;
            configure_memory_valid_reg <= 0;
        end else begin
            configure_memory_reg.valid                       <= configure_memory_valid_int;
            configure_memory_reg.payload.meta.route.from     <= configure_memory_meta_int.route.from;
            configure_memory_reg.payload.meta.address.base   <= configure_memory_meta_int.address.base;
            configure_memory_reg.payload.meta.address.offset <= configure_memory_meta_int.address.offset;

            if(fifo_response_memory_in_dout_int.valid) begin
                case (fifo_response_memory_in_dout_int_offset_sequence)
                    (ENGINE_SEQ_MIN+0) : begin
                        configure_memory_reg.payload.param.increment     <= fifo_response_memory_in_dout_int.payload.data.field[0][0];
                        configure_memory_reg.payload.param.decrement     <= fifo_response_memory_in_dout_int.payload.data.field[0][1];
                        configure_memory_reg.payload.param.mode_sequence <= fifo_response_memory_in_dout_int.payload.data.field[0][2];
                        configure_memory_reg.payload.param.mode_buffer   <= fifo_response_memory_in_dout_int.payload.data.field[0][3];
                        configure_memory_valid_reg[0]                    <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+1) : begin
                        configure_memory_reg.payload.param.index_start <= fifo_response_memory_in_dout_int.payload.data.field[0];
                        configure_memory_valid_reg[1]                  <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+2) : begin
                        configure_memory_reg.payload.param.index_end <= fifo_response_memory_in_dout_int.payload.data.field[0];
                        configure_memory_valid_reg[2]                <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+3) : begin
                        configure_memory_reg.payload.param.stride <= fifo_response_memory_in_dout_int.payload.data.field[0];
                        configure_memory_valid_reg[3]             <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+4) : begin
                        configure_memory_reg.payload.param.granularity            <= fifo_response_memory_in_dout_int.payload.data.field[0][CACHE_FRONTEND_DATA_W-2:0];
                        configure_memory_reg.payload.meta.address.shift.amount    <= fifo_response_memory_in_dout_int.payload.data.field[0][CACHE_FRONTEND_DATA_W-2:0];
                        configure_memory_reg.payload.meta.address.shift.direction <= fifo_response_memory_in_dout_int.payload.data.field[0][CACHE_FRONTEND_DATA_W-1];
                        configure_memory_valid_reg[4]                             <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+5) : begin
                        configure_memory_reg.payload.meta.subclass.cmd    <= type_memory_cmd'(fifo_response_memory_in_dout_int.payload.data.field[0][TYPE_MEMORY_CMD_BITS-1:0]);
                        configure_memory_reg.payload.meta.subclass.buffer <= type_data_buffer'(fifo_response_memory_in_dout_int.payload.data.field[0][(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS)-1:TYPE_MEMORY_CMD_BITS]);
                        configure_memory_valid_reg[5]                     <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+6) : begin
                        configure_memory_reg.payload.meta.subclass.operand <= type_engine_operand'(fifo_response_memory_in_dout_int.payload.data.field[0][TYPE_ENGINE_OPERAND_BITS-1:0]);
                        configure_memory_reg.payload.meta.subclass.filter  <= type_filter_operation'(fifo_response_memory_in_dout_int.payload.data.field[0][(TYPE_FILTER_OPERATION_BITS+TYPE_ENGINE_OPERAND_BITS)-1:TYPE_ENGINE_OPERAND_BITS]);
                        configure_memory_reg.payload.meta.subclass.alu     <= type_ALU_operation'(fifo_response_memory_in_dout_int.payload.data.field[0][(TYPE_ALU_OPERATION_BITS+TYPE_FILTER_OPERATION_BITS+TYPE_ENGINE_OPERAND_BITS)-1:(TYPE_FILTER_OPERATION_BITS+TYPE_ENGINE_OPERAND_BITS)]);
                        configure_memory_valid_reg[6]                      <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+7) : begin
                        configure_memory_reg.payload.meta.route.to.id_cu     <= fifo_response_memory_in_dout_int.payload.data.field[0][(CU_KERNEL_COUNT_WIDTH_BITS)-1:0];
                        configure_memory_reg.payload.meta.route.to.id_bundle <= fifo_response_memory_in_dout_int.payload.data.field[0][(CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)-1:CU_KERNEL_COUNT_WIDTH_BITS];
                        configure_memory_reg.payload.meta.route.to.id_lane   <= fifo_response_memory_in_dout_int.payload.data.field[0][(CU_LANE_COUNT_WIDTH_BITS+CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)-1:(CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)];
                        configure_memory_reg.payload.meta.route.to.id_buffer <= fifo_response_memory_in_dout_int.payload.data.field[0][(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_WIDTH_BITS+CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)-1:(CU_LANE_COUNT_WIDTH_BITS+CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)];
                        configure_memory_valid_reg[7]                        <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+8) : begin
                        configure_memory_reg.payload.param.array_pointer[(CACHE_FRONTEND_DATA_W)-1:0] <= fifo_response_memory_in_dout_int.payload.data.field[0];
                        configure_memory_valid_reg[8]                                                 <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+9) : begin
                        configure_memory_reg.payload.param.array_pointer[(M_AXI_MEMORY_ADDR_WIDTH)-1:CACHE_FRONTEND_DATA_W] <= fifo_response_memory_in_dout_int.payload.data.field[0];
                        configure_memory_valid_reg[9]                                                                       <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+10) : begin
                        configure_memory_reg.payload.param.array_size <= fifo_response_memory_in_dout_int.payload.data.field[0];
                        configure_memory_valid_reg[10]                <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+11) : begin
                        configure_memory_valid_reg[11] <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+12) : begin
                        configure_memory_valid_reg[12] <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+13) : begin
                        configure_memory_valid_reg[13] <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+14) : begin
                        configure_memory_valid_reg[14] <= 1'b1  ;
                    end
                    (ENGINE_SEQ_MIN+15) : begin
                        configure_memory_valid_reg[15] <= 1'b1  ;
                    end
                    default : begin
                        configure_memory_reg.payload.param <= configure_memory_reg.payload.param;
                        if(configure_memory_valid_int)
                            configure_memory_valid_reg <= 0;
                        else
                            configure_memory_valid_reg <= configure_memory_valid_reg;
                    end
                endcase
            end else begin
                configure_memory_reg.payload.param <= configure_memory_reg.payload.param;
                if(configure_memory_valid_int)
                    configure_memory_valid_reg <= 0;
                else
                    configure_memory_valid_reg <= configure_memory_valid_reg;
            end
        end
    end

// --------------------------------------------------------------------------------------
// FIFO memory response out fifo MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_memory_in_setup_signal_int = fifo_response_memory_in_signals_out_int.wr_rst_busy  | fifo_response_memory_in_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_memory_in_push_filter          = ((response_memory_in_reg.payload.meta.subclass.buffer == STRUCT_CU_SETUP)|(response_memory_in_reg.payload.meta.subclass.buffer == STRUCT_ENGINE_SETUP)) & (response_memory_in_reg_offset_sequence < (ENGINE_SEQ_MAX)) & (response_memory_in_reg_offset_sequence >= ENGINE_SEQ_MIN);
    assign fifo_response_memory_in_signals_in_int.wr_en = response_memory_in_reg.valid & fifo_response_memory_in_push_filter;
    assign fifo_response_memory_in_din                  = response_memory_in_reg.payload;

    // Pop
    assign fifo_response_memory_in_signals_in_int.rd_en = ~fifo_response_memory_in_signals_out_int.empty & fifo_response_memory_in_signals_in_reg.rd_en & ~(configure_memory_valid_int) & ~fifo_configure_memory_signals_out_int.prog_full ;
    assign fifo_response_memory_in_dout_int.valid       = fifo_response_memory_in_signals_out_int.valid;
    assign fifo_response_memory_in_dout_int.payload     = fifo_response_memory_in_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (16                        )
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
// FIFO memory configure_memory out fifo MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_configure_memory_setup_signal_int = fifo_configure_memory_signals_out_int.wr_rst_busy  | fifo_configure_memory_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_configure_memory_signals_in_int.wr_en = configure_memory_reg.valid;
    assign fifo_configure_memory_din                  = configure_memory_reg.payload;

    // Pop
    assign fifo_configure_memory_signals_in_int.rd_en = ~fifo_configure_memory_signals_out_int.empty & fifo_configure_memory_signals_in_reg.rd_en;
    assign fifo_configure_memory_dout_int.valid       = fifo_configure_memory_signals_out_int.valid;
    assign fifo_configure_memory_dout_int.payload     = fifo_configure_memory_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                                 ),
        .WRITE_DATA_WIDTH($bits(CSRIndexConfigurationPayload)),
        .READ_DATA_WIDTH ($bits(CSRIndexConfigurationPayload)),
        .PROG_THRESH     (16                                 )
    ) inst_fifo_MemoryPacketResponseConigurationInput (
        .clk        (ap_clk                                           ),
        .srst       (areset_fifo                                      ),
        .din        (fifo_configure_memory_din                        ),
        .wr_en      (fifo_configure_memory_signals_in_int.wr_en       ),
        .rd_en      (fifo_configure_memory_signals_in_int.rd_en       ),
        .dout       (fifo_configure_memory_dout                       ),
        .full       (fifo_configure_memory_signals_out_int.full       ),
        .empty      (fifo_configure_memory_signals_out_int.empty      ),
        .valid      (fifo_configure_memory_signals_out_int.valid      ),
        .prog_full  (fifo_configure_memory_signals_out_int.prog_full  ),
        .wr_rst_busy(fifo_configure_memory_signals_out_int.wr_rst_busy),
        .rd_rst_busy(fifo_configure_memory_signals_out_int.rd_rst_busy)
    );

endmodule : engine_csr_index_configure_memory