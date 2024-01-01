// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_read_write_configure_memory.sv
// Create : 2023-07-17 15:02:02
// Revise : 2023-08-28 15:42:14
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_read_write_configure_memory #(parameter
    ID_CU            = 0                                ,
    ID_BUNDLE        = 0                                ,
    ID_LANE          = 0                                ,
    ID_ENGINE        = 0                                ,
    ID_RELATIVE      = 0                                ,
    ID_MODULE        = 0                                ,
    FIFO_WRITE_DEPTH = 16                               ,
    PROG_THRESH      = 8                                ,
    ENGINE_SEQ_WIDTH = 16                               ,
    ENGINE_SEQ_MIN   = ID_RELATIVE * ENGINE_SEQ_WIDTH   ,
    ENGINE_SEQ_MAX   = ENGINE_SEQ_WIDTH + ENGINE_SEQ_MIN
) (
    input  logic                  ap_clk                             ,
    input  logic                  areset                             ,
    input  MemoryPacket           response_memory_in                 ,
    input  FIFOStateSignalsInput  fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput fifo_response_memory_in_signals_out,
    output ReadWriteConfiguration configure_memory_out               ,
    input  FIFOStateSignalsInput  fifo_configure_memory_signals_in   ,
    output FIFOStateSignalsOutput fifo_configure_memory_signals_out  ,
    output logic                  fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_read_write_generator;
logic areset_fifo                ;

MemoryPacket                 response_memory_in_reg                          ;
MemoryPacketMeta             configure_memory_meta_int                       ;
ReadWriteConfiguration       configure_memory_reg                            ;
logic [ENGINE_SEQ_WIDTH-1:0] configure_memory_valid_reg                      ;
logic                        configure_memory_valid_int                      ;
logic [M_AXI4_FE_ADDR_W-1:0] response_memory_in_reg_offset_sequence          ;
logic [M_AXI4_FE_ADDR_W-1:0] fifo_response_memory_in_dout_int_offset_sequence;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
MemoryPacketPayload           fifo_response_memory_in_din             ;
MemoryPacket                  fifo_response_memory_in_dout_int        ;
MemoryPacket                  fifo_response_memory_in_dout_reg        ;
MemoryPacketPayload           fifo_response_memory_in_dout            ;
FIFOStateSignalsInput         fifo_response_memory_in_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_memory_in_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_response_memory_in_signals_out_int ;
logic                         fifo_response_memory_in_setup_signal_int;
logic                         fifo_response_memory_in_push_filter     ;

// --------------------------------------------------------------------------------------
// Configure FIFO
// --------------------------------------------------------------------------------------
ReadWriteConfigurationPayload fifo_configure_memory_din             ;
ReadWriteConfiguration        fifo_configure_memory_dout_int        ;
ReadWriteConfigurationPayload fifo_configure_memory_dout            ;
FIFOStateSignalsInput         fifo_configure_memory_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_configure_memory_signals_in_int  ;
FIFOStateSignalsOutInternal   fifo_configure_memory_signals_out_int ;
logic                         fifo_configure_memory_setup_signal_int;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_read_write_generator <= areset;
    areset_fifo                 <= areset;
end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(areset_read_write_generator) begin
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
    if(areset_read_write_generator) begin
        fifo_setup_signal          <= 1'b1;
        configure_memory_out.valid <= 0;
    end else begin
        fifo_setup_signal          <= fifo_configure_memory_setup_signal_int;
        configure_memory_out.valid <= fifo_configure_memory_dout_int.valid;
    end
end

always_ff @(posedge ap_clk) begin
    fifo_response_memory_in_signals_out <= map_internal_fifo_signals_to_output(fifo_configure_memory_signals_out_int);
    fifo_configure_memory_signals_out   <= map_internal_fifo_signals_to_output(fifo_configure_memory_signals_out_int);
    configure_memory_out.payload        <= fifo_configure_memory_dout_int.payload;
end


// --------------------------------------------------------------------------------------
// Create Configuration Packet
// --------------------------------------------------------------------------------------
assign response_memory_in_reg_offset_sequence           = (response_memory_in_reg.payload.meta.address.offset >> response_memory_in_reg.payload.meta.address.shift.amount);
assign fifo_response_memory_in_dout_int_offset_sequence = (fifo_response_memory_in_dout_int.payload.meta.address.offset >> fifo_response_memory_in_dout_int.payload.meta.address.shift.amount);

always_comb begin
    configure_memory_meta_int.route.packet_source.id_cu     = 1 << ID_CU;
    configure_memory_meta_int.route.packet_source.id_bundle = 1 << ID_BUNDLE;
    configure_memory_meta_int.route.packet_source.id_lane   = 1 << ID_LANE;
    configure_memory_meta_int.route.packet_source.id_engine = 1 << ID_ENGINE;
    configure_memory_meta_int.route.packet_source.id_module = 1 << ID_MODULE;

    configure_memory_meta_int.route.packet_destination.id_cu     = 0;
    configure_memory_meta_int.route.packet_destination.id_bundle = 0;
    configure_memory_meta_int.route.packet_destination.id_lane   = 0;
    configure_memory_meta_int.route.packet_destination.id_engine = 0;
    configure_memory_meta_int.route.packet_destination.id_module = 1;

    configure_memory_meta_int.route.sequence_source.id_cu     = 1 << ID_CU;
    configure_memory_meta_int.route.sequence_source.id_bundle = 1 << ID_BUNDLE;
    configure_memory_meta_int.route.sequence_source.id_lane   = 1 << ID_LANE;
    configure_memory_meta_int.route.sequence_source.id_engine = 1 << ID_ENGINE;
    configure_memory_meta_int.route.sequence_source.id_module = 1 << ID_MODULE;

    configure_memory_meta_int.route.sequence_state    = SEQUENCE_INVALID;
    configure_memory_meta_int.route.sequence_id       = 0;
    configure_memory_meta_int.route.hops              = NUM_BUNDLES_WIDTH_BITS;
    configure_memory_meta_int.address.id_buffer       = 0;
    configure_memory_meta_int.address.offset          = $clog2(M_AXI4_FE_DATA_W/8);
    configure_memory_meta_int.address.shift.amount    = 0;
    configure_memory_meta_int.address.shift.direction = 1'b1;
    configure_memory_meta_int.subclass.cmd            = CMD_INVALID;
    configure_memory_meta_int.subclass.buffer         = STRUCT_INVALID;
end

always_ff @(posedge ap_clk) begin
    if(areset_read_write_generator) begin
        configure_memory_reg.valid             <= 1'b0;
        configure_memory_valid_reg             <= 0;
        fifo_response_memory_in_dout_reg.valid <= 1'b0;
        configure_memory_valid_int             <= 1'b0;
    end else begin
        configure_memory_valid_int             <= configure_memory_valid_reg[(ENGINE_SEQ_WIDTH-1)] & ~configure_memory_valid_int;
        configure_memory_reg.valid             <= configure_memory_valid_int;
        fifo_response_memory_in_dout_reg.valid <= fifo_response_memory_in_dout_int.valid;

        if(fifo_response_memory_in_dout_int.valid) begin
            if ((fifo_response_memory_in_dout_int_offset_sequence == ENGINE_SEQ_MIN) & ~(|configure_memory_valid_reg)) begin
                configure_memory_valid_reg[0] <= 1'b1  ;
            end else begin
                configure_memory_valid_reg <= configure_memory_valid_reg << 1'b1;
            end
        end else begin
            if(configure_memory_valid_int)
                configure_memory_valid_reg <= 0;
            else
                configure_memory_valid_reg <= configure_memory_valid_reg;
        end
    end
end

always_ff @(posedge ap_clk) begin
    fifo_response_memory_in_dout_reg.payload <= fifo_response_memory_in_dout_int.payload;
end

always_ff @(posedge ap_clk) begin
    configure_memory_reg.payload.meta.route.packet_source   <= configure_memory_meta_int.route.packet_source;
    configure_memory_reg.payload.meta.route.sequence_source <= configure_memory_meta_int.route.sequence_source;
    configure_memory_reg.payload.meta.route.sequence_state  <= configure_memory_meta_int.route.sequence_state;
    configure_memory_reg.payload.meta.route.sequence_id     <= configure_memory_meta_int.route.sequence_id;
    configure_memory_reg.payload.meta.route.hops            <= configure_memory_meta_int.route.hops;
    configure_memory_reg.payload.meta.address.offset        <= configure_memory_meta_int.address.offset;
end

always_ff @(posedge ap_clk) begin
    if(fifo_response_memory_in_dout_reg.valid) begin
        case (configure_memory_valid_reg)
            (1 << 0) : begin
                configure_memory_reg.payload.param.increment     <= fifo_response_memory_in_dout_reg.payload.data.field[0][0];
                configure_memory_reg.payload.param.decrement     <= fifo_response_memory_in_dout_reg.payload.data.field[0][1];
                configure_memory_reg.payload.param.mode_sequence <= fifo_response_memory_in_dout_reg.payload.data.field[0][2];
                configure_memory_reg.payload.param.mode_buffer   <= fifo_response_memory_in_dout_reg.payload.data.field[0][3];
                configure_memory_reg.payload.param.mode_counter  <= fifo_response_memory_in_dout_reg.payload.data.field[0][4];
            end
            (1 << 1) : begin
                configure_memory_reg.payload.param.index_start <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 2) : begin
                configure_memory_reg.payload.param.index_end <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 3) : begin
                configure_memory_reg.payload.param.stride <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 4) : begin
                configure_memory_reg.payload.param.granularity            <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-2:0];
                configure_memory_reg.payload.param.direction              <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-1];
                configure_memory_reg.payload.meta.address.shift.amount    <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-2:0];
                configure_memory_reg.payload.meta.address.shift.direction <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-1];
            end
            (1 << 5) : begin
                configure_memory_reg.payload.meta.subclass.cmd                       <= type_memory_cmd'(fifo_response_memory_in_dout_reg.payload.data.field[0][TYPE_MEMORY_CMD_BITS-1:0]);
                configure_memory_reg.payload.meta.subclass.buffer                    <= type_data_buffer'(fifo_response_memory_in_dout_reg.payload.data.field[0][(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS)-1:TYPE_MEMORY_CMD_BITS]);
                configure_memory_reg.payload.meta.route.packet_destination.id_module <= fifo_response_memory_in_dout_reg.payload.data.field[0][(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS+NUM_MODULES_WIDTH_BITS)-1:(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS)];
                configure_memory_reg.payload.meta.route.packet_destination.id_engine <= fifo_response_memory_in_dout_reg.payload.data.field[0][(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+NUM_ENGINES_WIDTH_BITS)-1:(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << 6) : begin
                configure_memory_reg.payload.meta.route.packet_destination.id_cu     <= fifo_response_memory_in_dout_reg.payload.data.field[0][(NUM_CUS_WIDTH_BITS)-1:0];
                configure_memory_reg.payload.meta.route.packet_destination.id_bundle <= fifo_response_memory_in_dout_reg.payload.data.field[0][(NUM_BUNDLES_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:CU_KERNEL_COUNT_MAX_WIDTH_BITS];
                configure_memory_reg.payload.meta.route.packet_destination.id_lane   <= fifo_response_memory_in_dout_reg.payload.data.field[0][(NUM_LANES_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.meta.address.id_buffer                  <= fifo_response_memory_in_dout_reg.payload.data.field[0][(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.id_buffer                         <= fifo_response_memory_in_dout_reg.payload.data.field[0][(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << 7) : begin
                configure_memory_reg.payload.param.array_size <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 8) : begin
                configure_memory_reg.payload.param.const_mask <= fifo_response_memory_in_dout_reg.payload.data.field[0][NUM_FIELDS_MEMORYPACKETDATA-1:0];
            end
            (1 << 9) : begin
                configure_memory_reg.payload.param.const_value <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 10) : begin
                configure_memory_reg.payload.param.ops_mask <= fifo_response_memory_in_dout_reg.payload.data.field[0][(NUM_FIELDS_MEMORYPACKETDATA*NUM_FIELDS_MEMORYPACKETDATA)-1:0];
            end
            // (1 << 11) : begin
            // end
            // (1 << 12) : begin
            // end
            // (1 << 13) : begin
            // end
            // (1 << 14) : begin
            // end
            // (1 << 15) : begin
            // end
            default : begin
                configure_memory_reg.payload.param <= configure_memory_reg.payload.param;
            end
        endcase
    end else begin
        configure_memory_reg.payload.param <= configure_memory_reg.payload.param;
    end
end

// --------------------------------------------------------------------------------------
// memory response out fifo MemoryPacket
// --------------------------------------------------------------------------------------
// Push
assign fifo_response_memory_in_push_filter      = ((response_memory_in_reg.payload.meta.subclass.buffer == STRUCT_CU_SETUP)|(response_memory_in_reg.payload.meta.subclass.buffer == STRUCT_ENGINE_SETUP)) & (response_memory_in_reg_offset_sequence < (ENGINE_SEQ_MAX)) & (response_memory_in_reg_offset_sequence >= ENGINE_SEQ_MIN);
assign fifo_response_memory_in_dout_int.valid   = response_memory_in_reg.valid & fifo_response_memory_in_push_filter;
assign fifo_response_memory_in_dout_int.payload = response_memory_in_reg.payload;

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
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                    ),
    .WRITE_DATA_WIDTH($bits(ReadWriteConfigurationPayload)),
    .READ_DATA_WIDTH ($bits(ReadWriteConfigurationPayload)),
    .PROG_THRESH     (PROG_THRESH                         )
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

endmodule : engine_read_write_configure_memory