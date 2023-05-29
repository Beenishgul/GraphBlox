// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_csr_index_configure.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

module engine_csr_index_configure #(
    parameter ENGINE_ID_VERTEX = 0,
    parameter ENGINE_ID_BUNDLE = 0,
    parameter ENGINE_ID_ENGINE = 0
) (
    input  logic                    ap_clk                        ,
    input  logic                    areset                        ,
    input  MemoryPacket             response_in                   ,
    input  FIFOStateSignalsInput    fifo_response_signals_in      ,
    output FIFOStateSignalsOutput   fifo_response_signals_out     ,
    output StrideIndexConfiguration configuration_out             ,
    input  FIFOStateSignalsInput    fifo_configuration_signals_in ,
    output FIFOStateSignalsOutput   fifo_configuration_signals_out,
    output logic                    fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_stride_index_generator;
    logic areset_fifo                  ;

    MemoryPacket             response_in_reg        ;
    MemoryPacketMeta         configuration_meta_int ;
    StrideIndexConfiguration configuration_reg      ;
    logic [6:0]              configuration_reg_valid;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
    MemoryPacketPayload    fifo_response_din             ;
    MemoryPacket           fifo_response_dout_int        ;
    MemoryPacketPayload    fifo_response_dout            ;
    FIFOStateSignalsInput  fifo_response_signals_in_reg  ;
    FIFOStateSignalsInput  fifo_response_signals_in_int  ;
    FIFOStateSignalsOutput fifo_response_signals_out_int ;
    logic                  fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// Configure FIFO
// --------------------------------------------------------------------------------------
    StrideIndexConfigurationPayload fifo_configuration_din             ;
    StrideIndexConfiguration        fifo_configuration_dout_int        ;
    StrideIndexConfigurationPayload fifo_configuration_dout            ;
    FIFOStateSignalsInput           fifo_configuration_signals_in_reg  ;
    FIFOStateSignalsInput           fifo_configuration_signals_in_int  ;
    FIFOStateSignalsOutput          fifo_configuration_signals_out_int ;
    logic                           fifo_configuration_setup_signal_int;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_stride_index_generator <= areset;
        areset_fifo                   <= areset;
    end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_stride_index_generator) begin
            response_in_reg.valid             <= 1'b0;
            fifo_response_signals_in_reg      <= 0;
            fifo_configuration_signals_in_reg <= 0;
        end else begin
            response_in_reg.valid                   <= response_in.valid ;
            fifo_response_signals_in_reg.rd_en      <= fifo_response_signals_in.rd_en;
            fifo_configuration_signals_in_reg.rd_en <= fifo_configuration_signals_in.rd_en;
        end
    end

    always_ff @(posedge ap_clk) begin
        response_in_reg.payload <= response_in.payload;
    end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_stride_index_generator) begin
            fifo_setup_signal       <= 1'b1;
            configuration_out.valid <= 0;
        end else begin
            fifo_setup_signal       <= fifo_response_setup_signal_int | fifo_configuration_setup_signal_int;
            configuration_out.valid <= fifo_configuration_dout_int.valid;
        end
    end

    always_ff @(posedge ap_clk) begin
        fifo_response_signals_out      <= fifo_response_signals_out_int;
        fifo_configuration_signals_out <= fifo_configuration_signals_out_int;
        configuration_out.payload      <= fifo_configuration_dout_int.payload;
    end


// --------------------------------------------------------------------------------------
// Create Configuration Packet
// --------------------------------------------------------------------------------------
    always_comb begin
        configuration_meta_int.id_vertex      = ENGINE_ID_VERTEX;
        configuration_meta_int.id_bundle      = ENGINE_ID_BUNDLE;
        configuration_meta_int.id_engine      = ENGINE_ID_ENGINE;
        configuration_meta_int.address_base   = 0;
        configuration_meta_int.address_offset = $clog2(CACHE_FRONTEND_DATA_W/8);
        configuration_meta_int.type_cmd       = CMD_INVALID;
        configuration_meta_int.type_struct    = STRUCT_STRIDE_INDEX;
        configuration_meta_int.type_operand   = OP_LOCATION_0;
        configuration_meta_int.type_filter    = FILTER_NOP;
        configuration_meta_int.type_ALU       = ALU_NOP;
    end

    always_ff @(posedge ap_clk) begin
        if(areset_stride_index_generator) begin
            configuration_reg       <= 0;
            configuration_reg_valid <= 0;
        end else begin
            configuration_reg.valid                       <= &configuration_reg_valid;
            configuration_reg.payload.meta.id_vertex      <= configuration_meta_int.id_vertex ;
            configuration_reg.payload.meta.id_bundle      <= configuration_meta_int.id_bundle ;
            configuration_reg.payload.meta.id_engine      <= configuration_meta_int.id_engine ;
            configuration_reg.payload.meta.address_base   <= configuration_meta_int.address_base ;
            configuration_reg.payload.meta.address_offset <= configuration_meta_int.address_offset ;

            if(fifo_response_dout_int.valid & (fifo_response_dout_int.payload.meta.type_struct == STRUCT_KERNEL_SETUP)) begin
                case (fifo_response_dout_int.payload.meta.address_offset >> $clog2(CACHE_FRONTEND_DATA_W/8))
                    0 : begin
                        configuration_reg.payload.param.increment <= fifo_response_dout_int.payload.data.field[0];
                        configuration_reg.payload.param.decrement <= fifo_response_dout_int.payload.data.field[1];
                        configuration_reg_valid[0]                <= 1'b1  ;
                    end
                    1 : begin
                        configuration_reg.payload.param.index_start <= fifo_response_dout_int.payload.data.field;
                        configuration_reg_valid[1]                  <= 1'b1  ;
                    end
                    2 : begin
                        configuration_reg.payload.param.index_end <= fifo_response_dout_int.payload.data.field;
                        configuration_reg_valid[2]                <= 1'b1  ;
                    end
                    3 : begin
                        configuration_reg.payload.param.stride <= fifo_response_dout_int.payload.data.field;
                        configuration_reg_valid[3]             <= 1'b1  ;
                    end
                    4 : begin
                        configuration_reg.payload.param.granularity <= fifo_response_dout_int.payload.data.field;
                        configuration_reg_valid[4]                  <= 1'b1  ;
                    end
                    5 : begin
                        configuration_reg.payload.meta.type_cmd    <= type_memory_cmd'(fifo_response_dout_int.payload.data.field[TYPE_MEMORY_CMD_BITS-1:0]);
                        configuration_reg.payload.meta.type_struct <= type_data_buffer'(fifo_response_dout_int.payload.data.field[(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS)-1:TYPE_MEMORY_CMD_BITS]);
                        configuration_reg_valid[5]                 <= 1'b1  ;
                    end
                    6 : begin
                        configuration_reg.payload.meta.type_operand <= type_engine_operand'(fifo_response_dout_int.payload.data.field[TYPE_ENGINE_OPERAND_BITS-1:0]);
                        configuration_reg.payload.meta.type_filter  <= type_filter_operation'(fifo_response_dout_int.payload.data.field[(TYPE_FILTER_OPERATION_BITS+TYPE_ENGINE_OPERAND_BITS)-1:TYPE_ENGINE_OPERAND_BITS]);
                        configuration_reg.payload.meta.type_ALU     <= type_ALU_operation'(fifo_response_dout_int.payload.data.field[(TYPE_ALU_OPERATION_BITS+TYPE_FILTER_OPERATION_BITS+TYPE_ENGINE_OPERAND_BITS)-1:(TYPE_FILTER_OPERATION_BITS+TYPE_ENGINE_OPERAND_BITS)]);
                        configuration_reg_valid[6]                  <= 1'b1  ;
                    end
                    default : begin
                        configuration_reg.payload.param <= configuration_reg.payload.param;
                        if(&configuration_reg_valid)
                            configuration_reg_valid <= 0;
                        else
                            configuration_reg_valid <= configuration_reg_valid;
                    end
                endcase
            end else begin
                configuration_reg.payload.param <= configuration_reg.payload.param;
                if(&configuration_reg_valid)
                    configuration_reg_valid <= 0;
                else
                    configuration_reg_valid <= configuration_reg_valid;
            end
        end
    end

// --------------------------------------------------------------------------------------
// FIFO memory response out fifo MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy  | fifo_response_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_response_signals_in_int.wr_en = response_in_reg.valid;
    assign fifo_response_din                  = response_in_reg.payload;

    // Pop
    assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en & ~(&configuration_reg_valid) & ~fifo_configuration_signals_out_int.prog_full ;
    assign fifo_response_dout_int.valid       = fifo_response_signals_out_int.valid;
    assign fifo_response_dout_int.payload     = fifo_response_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                        ),
        .WRITE_DATA_WIDTH($bits(MemoryPacketPayload)),
        .READ_DATA_WIDTH ($bits(MemoryPacketPayload)),
        .PROG_THRESH     (8                         )
    ) inst_fifo_MemoryPacket_response (
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
// FIFO memory configuration out fifo MemoryPacket
// --------------------------------------------------------------------------------------
    // FIFO is resetting
    assign fifo_configuration_setup_signal_int = fifo_configuration_signals_out_int.wr_rst_busy  | fifo_configuration_signals_out_int.rd_rst_busy;

    // Push
    assign fifo_configuration_signals_in_int.wr_en = configuration_reg.valid;
    assign fifo_configuration_din                  = configuration_reg.payload;

    // Pop
    assign fifo_configuration_signals_in_int.rd_en = ~fifo_configuration_signals_out_int.empty & fifo_configuration_signals_in_reg.rd_en;
    assign fifo_configuration_dout_int.valid       = fifo_configuration_signals_out_int.valid;
    assign fifo_configuration_dout_int.payload     = fifo_configuration_dout;

    xpm_fifo_sync_wrapper #(
        .FIFO_WRITE_DEPTH(32                                    ),
        .WRITE_DATA_WIDTH($bits(StrideIndexConfigurationPayload)),
        .READ_DATA_WIDTH ($bits(StrideIndexConfigurationPayload)),
        .PROG_THRESH     (8                                     )
    ) inst_fifo_MemoryPacket_configuration (
        .clk         (ap_clk                                         ),
        .srst        (areset_fifo                                    ),
        .din         (fifo_configuration_din                         ),
        .wr_en       (fifo_configuration_signals_in_int.wr_en        ),
        .rd_en       (fifo_configuration_signals_in_int.rd_en        ),
        .dout        (fifo_configuration_dout                        ),
        .full        (fifo_configuration_signals_out_int.full        ),
        .almost_full (fifo_configuration_signals_out_int.almost_full ),
        .empty       (fifo_configuration_signals_out_int.empty       ),
        .almost_empty(fifo_configuration_signals_out_int.almost_empty),
        .valid       (fifo_configuration_signals_out_int.valid       ),
        .prog_full   (fifo_configuration_signals_out_int.prog_full   ),
        .prog_empty  (fifo_configuration_signals_out_int.prog_empty  ),
        .wr_rst_busy (fifo_configuration_signals_out_int.wr_rst_busy ),
        .rd_rst_busy (fifo_configuration_signals_out_int.rd_rst_busy )
    );

endmodule : engine_csr_index_configure