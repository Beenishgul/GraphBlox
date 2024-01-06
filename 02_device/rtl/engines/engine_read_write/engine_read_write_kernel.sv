//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_read_write_kernel.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_read_write_kernel (
  input  logic                            ap_clk                ,
  input  logic                            areset                ,
  input  logic                            clear_in              ,
  input  logic                            config_params_valid_in,
  input  ReadWriteConfigurationParameters config_params_in      ,
  input  logic                            data_valid_in         ,
  input  EnginePacketData                 data_in               ,
  output PacketDataAddress              address_out           ,
  output EnginePacketData                 result_out
);

// Define internal signals
EnginePacketData  ops_value_reg ;
PacketDataAddress address_int   ;
EnginePacketData  org_value_reg ;
EnginePacketData  org_data_int  ;
logic             data_valid_reg;

// Process input data and mask
always_ff @(posedge ap_clk) begin
  if (areset) begin
    data_valid_reg <= 1'b0;
    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      ops_value_reg.field[i] <= 0;
      org_value_reg.field[i] <= 0;
    end
  end else begin
    data_valid_reg <= data_valid_in;
    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      if(config_params_in.const_mask[i] & config_params_valid_in) begin
        ops_value_reg.field[i] <= config_params_in.const_value;
      end else if (config_params_valid_in) begin
        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
          if(config_params_in.ops_mask[i][j]) begin
            ops_value_reg.field[i] <= data_in.field[j];
          end
        end
      end else begin
        ops_value_reg.field[i] <= 0;
      end
    end

    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      if (config_params_valid_in) begin
        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
          if(config_params_in.ops_mask[i][j]) begin
            org_value_reg.field[i] <= data_in.field[j];
          end
        end
      end else begin
        org_value_reg.field[i] <= 0;
      end
    end
  end
end

assign org_data_int = org_value_reg;

always_comb begin
  // Process the ALU operation if both config_params_in and data are valid field 1 used for offset and field 0 for data write, mask data accordingly
  address_int = 0;
  if (config_params_valid_in & data_valid_reg) begin
    address_int.shift.amount    = config_params_in.granularity;
    address_int.shift.direction = config_params_in.direction;
    address_int.id_buffer       = config_params_in.id_buffer;
    if(address_int.shift.direction) begin
      address_int.offset = (config_params_in.index_start + ops_value_reg.field[1]) << address_int.shift.amount;
    end else begin
      address_int.offset = (config_params_in.index_start + ops_value_reg.field[1]) >> address_int.shift.amount;
    end
  end
end

// Output assignment logic
always_ff @(posedge ap_clk) begin
  if (areset || clear_in) begin
    result_out  <= 0;
    address_out <= 0;
  end else begin
    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      result_out.field[i] <= org_data_int.field[i];
    end
    address_out <= address_int;
  end
end

endmodule : engine_read_write_kernel
