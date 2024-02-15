//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_alu_ops_kernel.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_alu_ops_kernel (
  input  logic                         ap_clk             ,
  input  logic                         areset             ,
  input  logic                         clear              ,
  input  ALUOpsConfigurationParameters config_params_in   ,
  input  logic                         data_valid         ,
  input  EnginePacketData              data_in            ,
  output EnginePacketData              result_out
);

// Define internal signals
EnginePacketData ops_value_reg ;
EnginePacketData result_reg    ;
EnginePacketData org_value_reg ;
logic            data_valid_reg;

// Process input data_in and mask
always_ff @(posedge ap_clk) begin
  if (areset) begin
    data_valid_reg <= 1'b0;
  end else begin
    data_valid_reg <= data_valid;
  end
end

always_ff @(posedge ap_clk) begin
  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    if(config_params_in.const_mask[i]) begin
      ops_value_reg.field[i] <= config_params_in.const_value;
    end else  begin
      if(|config_params_in.ops_mask[i])begin
        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
          if(config_params_in.ops_mask[i][j]) begin
            ops_value_reg.field[i] <= data_in.field[j];
          end
        end
      end else begin
        ops_value_reg.field[i] <= 0;
      end
    end
  end

  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    if(|config_params_in.ops_mask[i])begin
      for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
        if(config_params_in.ops_mask[i][j]) begin
          org_value_reg.field[i] <= data_in.field[j];
        end
      end
    end else begin
      org_value_reg.field[i] <= data_in.field[i];
    end
  end
end

// ALU operations logic
always_ff @(posedge ap_clk) begin
  if (clear) begin
    result_reg <= 0;
  end else begin
    case (config_params_in.alu_operation)
// --------------------------------------------------------------------------------------
      ALU_NOP : begin
        result_reg <= ops_value_reg; // No operation
      end
// --------------------------------------------------------------------------------------
      ALU_ADD : begin
        for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
          if (config_params_in.alu_mask[i]) begin
            result_reg <= ops_value_reg.field[i] + ops_value_reg.field[i+1];
          end
        end
      end
// --------------------------------------------------------------------------------------
      ALU_SUB : begin
        for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
          if (config_params_in.alu_mask[i]) begin
            if(ops_value_reg.field[i] > ops_value_reg.field[i+1])
              result_reg <= ops_value_reg.field[i] - ops_value_reg.field[i+1];
            else
              result_reg <= ops_value_reg.field[i+1] - ops_value_reg.field[i];
          end
        end
      end
// --------------------------------------------------------------------------------------
      ALU_MUL : begin
        for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
          if (config_params_in.alu_mask[i]) begin
            result_reg <= ops_value_reg.field[i] * ops_value_reg.field[i+1];
          end
        end
      end
// --------------------------------------------------------------------------------------
      ALU_ACC : begin
        if(data_valid_reg) begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
            if (config_params_in.alu_mask[i]) begin
              result_reg <= result_reg + ops_value_reg.field[i];
            end
          end
        end
      end
// --------------------------------------------------------------------------------------
      ALU_DIV : begin
        result_reg <= ops_value_reg; // Undefined operations reset result_out
      end
// --------------------------------------------------------------------------------------
      default : begin
        result_reg <= ops_value_reg; // Undefined operations reset result_out
      end
// --------------------------------------------------------------------------------------
    endcase
  end
end

// Output assignment logic
always_ff @(posedge ap_clk) begin
  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS/2; i++) begin
    result_out.field[i] <= result_reg.field[i];
  end
  for (int i = ENGINE_PACKET_DATA_NUM_FIELDS/2; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    result_out.field[i] <= org_value_reg.field[i];
  end
end

endmodule : engine_alu_ops_kernel
