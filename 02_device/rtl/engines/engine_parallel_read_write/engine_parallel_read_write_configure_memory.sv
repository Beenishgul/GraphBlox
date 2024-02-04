// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_parallel_read_write_configure_memory.sv
// Create : 2023-07-17 15:02:02
// Revise : 2023-08-28 15:42:14
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_parallel_read_write_configure_memory #(parameter
    ID_CU                 = 0                                ,
    ID_BUNDLE             = 0                                ,
    ID_LANE               = 0                                ,
    ID_ENGINE             = 0                                ,
    ID_RELATIVE           = 0                                ,
    ID_MODULE             = 0                                ,
    FIFO_ENABLE           = 0                                ,
    PIPELINE_STAGES_DEPTH = 1                                ,
    FIFO_WRITE_DEPTH      = 16                               ,
    PROG_THRESH           = 8                                ,
    ENGINE_SEQ_WIDTH      = 16                               ,
    ENGINE_SEQ_MIN        = ID_RELATIVE * ENGINE_SEQ_WIDTH   ,
    ENGINE_SEQ_MAX        = ENGINE_SEQ_WIDTH + ENGINE_SEQ_MIN
) (
    input  logic                          ap_clk                             ,
    input  logic                          areset                             ,
    input  MemoryPacketResponse           response_memory_in                 ,
    input  FIFOStateSignalsInput          fifo_response_memory_in_signals_in ,
    output FIFOStateSignalsOutput         fifo_response_memory_in_signals_out,
    output ParallelReadWriteConfiguration configure_memory_out               ,
    input  FIFOStateSignalsInput          fifo_configure_memory_signals_in   ,
    output FIFOStateSignalsOutput         fifo_configure_memory_signals_out  ,
    output logic                          fifo_setup_signal
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_read_write_generator;
logic areset_fifo                ;

MemoryPacketResponse               response_memory_in_reg                          ;
ParallelReadWriteConfigurationMeta configure_memory_meta_int                       ;
ParallelReadWriteConfiguration     configure_memory_reg                            ;
logic [ENGINE_SEQ_WIDTH-1:0]       configure_memory_valid_reg                      ;
logic                              configure_memory_valid_int                      ;
type_memory_response_offset        response_memory_in_reg_offset_sequence          ;
type_memory_response_offset        fifo_response_memory_in_dout_int_offset_sequence;

// --------------------------------------------------------------------------------------
// Response FIFO
// --------------------------------------------------------------------------------------
MemoryPacketResponse  fifo_response_memory_in_dout_int      ;
MemoryPacketResponse  fifo_response_memory_in_dout_reg      ;
FIFOStateSignalsInput fifo_response_memory_in_signals_in_reg;
logic                 fifo_response_memory_in_push_filter   ;

// --------------------------------------------------------------------------------------
// Configure FIFO
// --------------------------------------------------------------------------------------
ParallelReadWriteConfigurationPayload fifo_configure_memory_din             ;
ParallelReadWriteConfiguration        fifo_configure_memory_dout_int        ;
ParallelReadWriteConfigurationPayload fifo_configure_memory_dout            ;
FIFOStateSignalsInput                 fifo_configure_memory_signals_in_reg  ;
FIFOStateSignalsInputInternal         fifo_configure_memory_signals_in_int  ;
FIFOStateSignalsOutInternal           fifo_configure_memory_signals_out_int ;
logic                                 fifo_configure_memory_setup_signal_int;

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
assign response_memory_in_reg_offset_sequence           = response_memory_in_reg.payload.meta.address.offset;
assign fifo_response_memory_in_dout_int_offset_sequence = fifo_response_memory_in_dout_int.payload.meta.address.offset;

assign configure_memory_meta_int.route.packet_destination.id_cu     = 0;
assign configure_memory_meta_int.route.packet_destination.id_bundle = 0;
assign configure_memory_meta_int.route.packet_destination.id_lane   = 0;
assign configure_memory_meta_int.route.packet_destination.id_engine = 0;
assign configure_memory_meta_int.route.packet_destination.id_module = 1;

assign configure_memory_meta_int.address.id_channel      = 0;
assign configure_memory_meta_int.address.id_buffer       = 0;
assign configure_memory_meta_int.address.offset          = 0;
assign configure_memory_meta_int.address.burst_length    = 1;
assign configure_memory_meta_int.address.shift.amount    = 0;
assign configure_memory_meta_int.address.shift.direction = 1'b1;
assign configure_memory_meta_int.subclass.cmd            = CMD_MEM_INVALID;

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
    for (int i = 0; i < ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
        configure_memory_reg.payload.param.param_field[i].meta.address.burst_length <= configure_memory_meta_int.address.burst_length;
        configure_memory_reg.payload.param.param_field[i].meta.address.offset       <= configure_memory_meta_int.address.offset;
    end
end

always_ff @(posedge ap_clk) begin
    if(fifo_response_memory_in_dout_reg.valid) begin
        case (configure_memory_valid_reg)
            (1 << 0) : begin
                configure_memory_reg.payload.param.increment     <= fifo_response_memory_in_dout_reg.payload.data.field[0];
                configure_memory_reg.payload.param.decrement     <= fifo_response_memory_in_dout_reg.payload.data.field[1];
                configure_memory_reg.payload.param.mode_sequence <= fifo_response_memory_in_dout_reg.payload.data.field[2];
                configure_memory_reg.payload.param.mode_buffer   <= fifo_response_memory_in_dout_reg.payload.data.field[3];
                configure_memory_reg.payload.param.mode_counter  <= fifo_response_memory_in_dout_reg.payload.data.field[4];
                configure_memory_reg.payload.param.mode_merge    <= fifo_response_memory_in_dout_reg.payload.data.field[5];
                configure_memory_reg.payload.param.lane_mask     <= fifo_response_memory_in_dout_reg.payload.data.field[ENGINE_PACKET_DATA_NUM_FIELDS+5:6];
            end

            (1 << (1+(7*0))) : begin
                configure_memory_reg.payload.param.param_field[0].index_start <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (2+(7*0))) : begin
                configure_memory_reg.payload.param.param_field[0].granularity                  <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[0].direction                    <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
                configure_memory_reg.payload.param.param_field[0].meta.address.shift.amount    <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[0].meta.address.shift.direction <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
            end
            (1 << (3+(7*0))) : begin
                configure_memory_reg.payload.param.param_field[0].meta.subclass.cmd                       <= type_memory_cmd'(fifo_response_memory_in_dout_reg.payload.data.field[TYPE_MEMORY_CMD_BITS-1:0]);
                configure_memory_reg.payload.param.param_field[0].meta.route.packet_destination.id_module <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+NUM_MODULES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS)];
                configure_memory_reg.payload.param.param_field[0].meta.route.packet_destination.id_engine <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+NUM_ENGINES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[0].meta.address.id_channel                 <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[0].id_channel                              <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (4+(7*0))) : begin
                configure_memory_reg.payload.param.param_field[0].meta.route.packet_destination.id_cu     <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_CUS_WIDTH_BITS)-1:0];
                configure_memory_reg.payload.param.param_field[0].meta.route.packet_destination.id_bundle <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_BUNDLES_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:CU_KERNEL_COUNT_MAX_WIDTH_BITS];
                configure_memory_reg.payload.param.param_field[0].meta.route.packet_destination.id_lane   <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_LANES_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[0].meta.address.id_buffer                  <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[0].id_buffer                               <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (5+(7*0))) : begin
                configure_memory_reg.payload.param.param_field[0].const_mask <= fifo_response_memory_in_dout_reg.payload.data.field[ENGINE_PACKET_DATA_NUM_FIELDS-1:0];
            end
            (1 << (6+(7*0))) : begin
                configure_memory_reg.payload.param.param_field[0].const_value <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (7+(7*0))) : begin
                configure_memory_reg.payload.param.param_field[0].ops_mask <= fifo_response_memory_in_dout_reg.payload.data.field[(ENGINE_PACKET_DATA_NUM_FIELDS*ENGINE_PACKET_DATA_NUM_FIELDS)-1:0];
            end


            (1 << (1+(7*1))) : begin
                configure_memory_reg.payload.param.param_field[1].index_start <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (2+(7*1))) : begin
                configure_memory_reg.payload.param.param_field[1].granularity                  <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[1].direction                    <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
                configure_memory_reg.payload.param.param_field[1].meta.address.shift.amount    <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[1].meta.address.shift.direction <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
            end
            (1 << (3+(7*1))) : begin
                configure_memory_reg.payload.param.param_field[1].meta.subclass.cmd                       <= type_memory_cmd'(fifo_response_memory_in_dout_reg.payload.data.field[TYPE_MEMORY_CMD_BITS-1:0]);
                configure_memory_reg.payload.param.param_field[1].meta.route.packet_destination.id_module <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+NUM_MODULES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS)];
                configure_memory_reg.payload.param.param_field[1].meta.route.packet_destination.id_engine <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+NUM_ENGINES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[1].meta.address.id_channel                 <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[1].id_channel                              <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (4+(7*1))) : begin
                configure_memory_reg.payload.param.param_field[1].meta.route.packet_destination.id_cu     <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_CUS_WIDTH_BITS)-1:0];
                configure_memory_reg.payload.param.param_field[1].meta.route.packet_destination.id_bundle <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_BUNDLES_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:CU_KERNEL_COUNT_MAX_WIDTH_BITS];
                configure_memory_reg.payload.param.param_field[1].meta.route.packet_destination.id_lane   <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_LANES_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[1].meta.address.id_buffer                  <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[1].id_buffer                               <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (5+(7*1))) : begin
                configure_memory_reg.payload.param.param_field[1].const_mask <= fifo_response_memory_in_dout_reg.payload.data.field[ENGINE_PACKET_DATA_NUM_FIELDS-1:0];
            end
            (1 << (6+(7*1))) : begin
                configure_memory_reg.payload.param.param_field[1].const_value <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (7+(7*1))) : begin
                configure_memory_reg.payload.param.param_field[1].ops_mask <= fifo_response_memory_in_dout_reg.payload.data.field[(ENGINE_PACKET_DATA_NUM_FIELDS*ENGINE_PACKET_DATA_NUM_FIELDS)-1:0];
            end


            (1 << (1+(7*2))) : begin
                configure_memory_reg.payload.param.param_field[2].index_start <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (2+(7*2))) : begin
                configure_memory_reg.payload.param.param_field[2].granularity                  <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[2].direction                    <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
                configure_memory_reg.payload.param.param_field[2].meta.address.shift.amount    <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[2].meta.address.shift.direction <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
            end
            (1 << (3+(7*2))) : begin
                configure_memory_reg.payload.param.param_field[2].meta.subclass.cmd                       <= type_memory_cmd'(fifo_response_memory_in_dout_reg.payload.data.field[TYPE_MEMORY_CMD_BITS-1:0]);
                configure_memory_reg.payload.param.param_field[2].meta.route.packet_destination.id_module <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+NUM_MODULES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS)];
                configure_memory_reg.payload.param.param_field[2].meta.route.packet_destination.id_engine <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+NUM_ENGINES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[2].meta.address.id_channel                 <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[2].id_channel                              <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (4+(7*2))) : begin
                configure_memory_reg.payload.param.param_field[2].meta.route.packet_destination.id_cu     <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_CUS_WIDTH_BITS)-1:0];
                configure_memory_reg.payload.param.param_field[2].meta.route.packet_destination.id_bundle <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_BUNDLES_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:CU_KERNEL_COUNT_MAX_WIDTH_BITS];
                configure_memory_reg.payload.param.param_field[2].meta.route.packet_destination.id_lane   <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_LANES_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[2].meta.address.id_buffer                  <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[2].id_buffer                               <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (5+(7*2))) : begin
                configure_memory_reg.payload.param.param_field[2].const_mask <= fifo_response_memory_in_dout_reg.payload.data.field[ENGINE_PACKET_DATA_NUM_FIELDS-1:0];
            end
            (1 << (6+(7*2))) : begin
                configure_memory_reg.payload.param.param_field[2].const_value <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (7+(7*2))) : begin
                configure_memory_reg.payload.param.param_field[2].ops_mask <= fifo_response_memory_in_dout_reg.payload.data.field[(ENGINE_PACKET_DATA_NUM_FIELDS*ENGINE_PACKET_DATA_NUM_FIELDS)-1:0];
            end


            (1 << (1+(7*3))) : begin
                configure_memory_reg.payload.param.param_field[3].index_start <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (2+(7*3))) : begin
                configure_memory_reg.payload.param.param_field[3].granularity                  <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[3].direction                    <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
                configure_memory_reg.payload.param.param_field[3].meta.address.shift.amount    <= fifo_response_memory_in_dout_reg.payload.data.field[$clog2(M00_AXI4_FE_ADDR_W)-1:0];
                configure_memory_reg.payload.param.param_field[3].meta.address.shift.direction <= fifo_response_memory_in_dout_reg.payload.data.field[M00_AXI4_FE_DATA_W-1];
            end
            (1 << (3+(7*3))) : begin
                configure_memory_reg.payload.param.param_field[3].meta.subclass.cmd                       <= type_memory_cmd'(fifo_response_memory_in_dout_reg.payload.data.field[TYPE_MEMORY_CMD_BITS-1:0]);
                configure_memory_reg.payload.param.param_field[3].meta.route.packet_destination.id_module <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+NUM_MODULES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS)];
                configure_memory_reg.payload.param.param_field[3].meta.route.packet_destination.id_engine <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+NUM_ENGINES_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[3].meta.address.id_channel                 <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[3].id_channel                              <= fifo_response_memory_in_dout_reg.payload.data.field[(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS+NUM_CHANNELS_WIDTH_BITS)-1:(TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_MAX_WIDTH_BITS+CU_ENGINE_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (4+(7*3))) : begin
                configure_memory_reg.payload.param.param_field[3].meta.route.packet_destination.id_cu     <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_CUS_WIDTH_BITS)-1:0];
                configure_memory_reg.payload.param.param_field[3].meta.route.packet_destination.id_bundle <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_BUNDLES_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:CU_KERNEL_COUNT_MAX_WIDTH_BITS];
                configure_memory_reg.payload.param.param_field[3].meta.route.packet_destination.id_lane   <= fifo_response_memory_in_dout_reg.payload.data.field[(NUM_LANES_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[3].meta.address.id_buffer                  <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
                configure_memory_reg.payload.param.param_field[3].id_buffer                               <= fifo_response_memory_in_dout_reg.payload.data.field[(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)-1:(CU_LANE_COUNT_MAX_WIDTH_BITS+CU_BUNDLE_COUNT_MAX_WIDTH_BITS+CU_KERNEL_COUNT_MAX_WIDTH_BITS)];
            end
            (1 << (5+(7*3))) : begin
                configure_memory_reg.payload.param.param_field[3].const_mask <= fifo_response_memory_in_dout_reg.payload.data.field[ENGINE_PACKET_DATA_NUM_FIELDS-1:0];
            end
            (1 << (6+(7*3))) : begin
                configure_memory_reg.payload.param.param_field[3].const_value <= fifo_response_memory_in_dout_reg.payload.data.field;
            end
            (1 << (7+(7*3))) : begin
                configure_memory_reg.payload.param.param_field[3].ops_mask <= fifo_response_memory_in_dout_reg.payload.data.field[(ENGINE_PACKET_DATA_NUM_FIELDS*ENGINE_PACKET_DATA_NUM_FIELDS)-1:0];
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
// memory response out fifo EnginePacket
// --------------------------------------------------------------------------------------
// Push
assign fifo_response_memory_in_push_filter      = (response_memory_in_reg_offset_sequence < (ENGINE_SEQ_MAX)) & (response_memory_in_reg_offset_sequence >= ENGINE_SEQ_MIN);
assign fifo_response_memory_in_dout_int.valid   = response_memory_in_reg.valid & fifo_response_memory_in_push_filter;
assign fifo_response_memory_in_dout_int.payload = response_memory_in_reg.payload;

// --------------------------------------------------------------------------------------
generate
    if (FIFO_ENABLE == 1) begin : gen_fifo
// --------------------------------------------------------------------------------------
// FIFO memory configure_memory out fifo EnginePacket
// --------------------------------------------------------------------------------------
// FIFO is resetting
        assign fifo_configure_memory_setup_signal_int = fifo_configure_memory_signals_out_int.wr_rst_busy | fifo_configure_memory_signals_out_int.rd_rst_busy;

// Push
        assign fifo_configure_memory_signals_in_int.wr_en = configure_memory_reg.valid;
        assign fifo_configure_memory_din                  = configure_memory_reg.payload;

// Pop
        assign fifo_configure_memory_signals_in_int.rd_en = ~fifo_configure_memory_signals_out_int.empty & fifo_configure_memory_signals_in_reg.rd_en;
        assign fifo_configure_memory_dout_int.valid       = fifo_configure_memory_signals_out_int.valid;
        assign fifo_configure_memory_dout_int.payload     = fifo_configure_memory_dout;

        xpm_fifo_sync_wrapper #(
            .FIFO_WRITE_DEPTH(16                                          ),
            .WRITE_DATA_WIDTH($bits(ParallelReadWriteConfigurationPayload)),
            .READ_DATA_WIDTH ($bits(ParallelReadWriteConfigurationPayload)),
            .PROG_THRESH     (8                                           )
        ) inst_fifo_EnginePacketResponseConigurationInput (
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
    end else begin
// --------------------------------------------------------------------------------------
        ParallelReadWriteConfiguration fifo_request_din_reg;
// --------------------------------------------------------------------------------------
        assign fifo_configure_memory_dout                 = 0;
        assign fifo_configure_memory_signals_in_int.rd_en = ~fifo_configure_memory_signals_out_int.empty & fifo_configure_memory_signals_in_reg.rd_en;
        assign fifo_configure_memory_setup_signal_int     = 1'b0;

        always_ff @(posedge ap_clk) begin
            if(areset_fifo) begin
                fifo_configure_memory_signals_out_int      <= 6'b010000;
                fifo_configure_memory_signals_in_int.wr_en <= 1'b0;
                fifo_request_din_reg.valid                 <= 1'b0;
            end else begin
                if(configure_memory_reg.valid)begin
                    fifo_configure_memory_din                   <= configure_memory_reg.payload;
                    fifo_configure_memory_signals_in_int.wr_en  <= 1'b1;
                    fifo_configure_memory_signals_out_int.empty <= 1'b0;
                end

                if(fifo_configure_memory_signals_in_int.rd_en & fifo_configure_memory_signals_in_int.wr_en) begin
                    fifo_request_din_reg.valid                  <= 1'b1;
                    fifo_request_din_reg.payload                <= fifo_configure_memory_din;
                    fifo_configure_memory_signals_in_int.wr_en  <= 1'b0;
                    fifo_configure_memory_signals_out_int.empty <= 1'b1;
                end else begin
                    fifo_request_din_reg.valid <= 1'b0;
                end
            end
        end

        hyper_pipeline_noreset #(
            .STAGES(PIPELINE_STAGES_DEPTH        ),
            .WIDTH ($bits(ParallelReadWriteConfiguration))
        ) inst_hyper_pipeline (
            .ap_clk(ap_clk                        ),
            .din   (fifo_request_din_reg          ),
            .dout  (fifo_configure_memory_dout_int)
        );
    end
endgenerate

endmodule : engine_parallel_read_write_configure_memory