// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_stride_index_generator_configure.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

module engine_stride_index_generator_configure #(
    parameter ENGINE_ID_VERTEX = 0,
    parameter ENGINE_ID_BUNDLE = 0,
    parameter ENGINE_ID_ENGINE = 0
) (
    input  logic                             ap_clk           ,
    input  logic                             areset           ,
    input  MemoryPacket                      response_in      ,
    output StrideIndexGeneratorConfiguration configuration_out
);

// --------------------------------------------------------------------------------------
// Wires and Variables
// --------------------------------------------------------------------------------------
    logic                             areset_stride_index_generator;
    MemoryPacket                      response_in_reg              ;
    MemoryPacketMeta                  configuration_meta_int       ;
    StrideIndexGeneratorConfiguration configuration_reg            ;
    logic [4:0]                       configuration_reg_valid      ;

// --------------------------------------------------------------------------------------
// Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        areset_stride_index_generator <= areset;
    end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------

    always_ff @(posedge ap_clk) begin
        if(areset_stride_index_generator) begin
            response_in_reg <= 0;
        end else begin
            response_in_reg <= response_in;
        end
    end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
        if(areset_stride_index_generator) begin
            configuration_out <= 0;
        end else begin
            configuration_out <= configuration_reg;
        end
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
            configuration_reg.valid        <= &configuration_reg_valid;
            configuration_reg.payload.meta <= configuration_meta_int;

            if(response_in_reg.valid & (response_in_reg.payload.meta.type_struct == STRUCT_KERNEL_SETUP)) begin
                case (response_in_reg.payload.meta.address_offset >> $clog2(CACHE_FRONTEND_DATA_W/8))
                    0 : begin
                        configuration_reg.payload.param.increment <= response_in_reg.payload.data.field[0];
                        configuration_reg.payload.param.decrement <= response_in_reg.payload.data.field[1];
                        configuration_reg_valid[0]                <= 1;
                    end
                    1 : begin
                        configuration_reg.payload.param.index_start <= response_in_reg.payload.data.field;
                        configuration_reg_valid[1]                  <= 1;
                    end
                    2 : begin
                        configuration_reg.payload.param.index_end <= response_in_reg.payload.data.field;
                        configuration_reg_valid[2]                <= 1;
                    end
                    3 : begin
                        configuration_reg.payload.param.stride <= response_in_reg.payload.data.field;
                        configuration_reg_valid[3]             <= 1;
                    end
                    4 : begin
                        configuration_reg.payload.param.granularity <= response_in_reg.payload.data.field;
                        configuration_reg_valid[4]                  <= 1;
                    end
                    default : begin
                        configuration_reg.payload.param <= configuration_reg.payload.param;
                        configuration_reg_valid         <= configuration_reg_valid;
                    end
                endcase
            end else begin
                configuration_reg.payload.param <= configuration_reg.payload.param;
                configuration_reg_valid         <= configuration_reg_valid;
            end
        end
    end

endmodule : engine_stride_index_generator_configure