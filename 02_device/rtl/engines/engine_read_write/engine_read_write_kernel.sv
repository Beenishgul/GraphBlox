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
  input  ReadWriteConfigurationParameters config_params_in      ,
  input  EnginePacketData                 data_in               ,
  output PacketRequestDataAddress         address_out           ,
  output EnginePacketData                 result_out
);

// Define internal signals
PacketRequestDataAddress         address_int      ;
EnginePacketData                 org_value_reg    ;
EnginePacketData                 org_data_int     ;
ReadWriteConfigurationParameters config_params_reg;

always_ff @(posedge ap_clk) begin
  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    if(config_params_in.const_mask[i]) begin
      org_value_reg.field[i]       <= config_params_in.const_value;
      org_value_reg.field_state[i] <= SEQUENCE_RUNNING;
    end else  begin
      if(|config_params_in.ops_mask[i])begin
        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
          if(config_params_in.ops_mask[i][j]) begin
            org_value_reg.field[i]       <= data_in.field[j];
            org_value_reg.field_state[i] <= data_in.field_state[j];
          end
        end
      end else begin
        org_value_reg.field[i]       <= 0;
        org_value_reg.field_state[i] <= SEQUENCE_INVALID;
      end
    end
  end
end

always_ff @(posedge ap_clk) begin
  config_params_reg           <= config_params_in;
  // Process the ALU operation if both config_params_in and data are valid field 1 used for offset and field 0 for data write, mask data accordingly
  address_int.shift.amount    <= config_params_reg.granularity;
  address_int.shift.direction <= config_params_reg.direction;
  address_int.mode_cache      <= config_params_reg.mode_cache;
  address_int.id_channel      <= config_params_reg.id_channel;
  address_int.id_buffer       <= config_params_reg.id_buffer;
  address_int.burst_length    <= 1;
  if(config_params_reg.direction) begin
    address_int.offset <= (config_params_reg.index_start + org_value_reg.field[1]) << config_params_reg.granularity;
  end else begin
    address_int.offset <= (config_params_reg.index_start + org_value_reg.field[1]) >> config_params_reg.granularity;
  end
  org_data_int <= org_value_reg;
end

// Output assignment logic
always_ff @(posedge ap_clk) begin
  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    result_out.field[i]       <= org_data_int.field[i];
    result_out.field_state[i] <= org_data_int.field_state[i];
  end
  address_out <= address_int;
end

endmodule : engine_read_write_kernel
