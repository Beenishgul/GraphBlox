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

import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_CACHE::*;

module engine_alu_ops_kernel (
  input  logic                         ap_clk             ,
  input  logic                         areset             ,
  input  logic                         clear              ,
  input  logic                         config_params_valid,
  input  ALUOpsConfigurationParameters config_params      ,
  input  logic                         data_valid         ,
  input  MemoryPacketData              data               ,
  output MemoryPacketData              result
);

  // Define internal signals
  MemoryPacketData ops_value_reg;
  MemoryPacketData result_int   ;

  // Process input data and mask
  always_ff @(posedge ap_clk) begin
    if (areset) begin
      for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        ops_value_reg.field[i] <= 0;
      end
    end else begin
      for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        if(config_params.const_mask[i] & config_params_valid) begin
          ops_value_reg.field[i] <= config_params.const_value;
        end else if (data_valid & config_params_valid) begin
          for (int j = 0; j<NUM_FIELDS_MEMORYPACKETDATA; j++) begin
            if(config_params.ops_mask[i][j]) begin
              ops_value_reg.field[i] <= data.field[j];
            end
          end
        end else begin
          ops_value_reg.field[i] <= 0;
        end
      end
    end
  end

  // ALU operations logic
  always_comb begin
    // Process the ALU operation if both config_params and data are valid
    if (config_params_valid & data_valid) begin
      case (config_params.alu_operation)
        ALU_NOP : begin
          result_int = ops_value_reg.field[0]; // No operation
        end

        ALU_ADD : begin
          result_int = ops_value_reg.field[0];
          for (int i = 1; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (config_params.alu_mask[i]) begin
              result_int = result_int + ops_value_reg.field[i];
            end else begin
              result_int = result_int;
            end
          end
        end

        ALU_SUB : begin
          result_int = ops_value_reg.field[0];
          for (int i = 1; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (config_params.alu_mask[i]) begin
              result_int = result_int - ops_value_reg.field[i];
            end else begin
              result_int = result_int;
            end
          end
        end

        ALU_MUL : begin
          result_int = ops_value_reg.field[0];
          for (int i = 1; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (config_params.alu_mask[i]) begin
              result_int = result_int * ops_value_reg.field[i];
            end else begin
              result_int = result_int;
            end
          end
        end

        ALU_ACC : begin
          result_int = result_int + ops_value_reg.field[0];
          for (int i = 1; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (config_params.alu_mask[i]) begin
              result_int = result_int + ops_value_reg.field[i];
            end else begin
              result_int = result_int;
            end
          end
        end

        ALU_DIV : begin
          result_int = ops_value_reg.field[0];
          result_int = result_int >> ops_value_reg.field[1]; // Undefined operations reset result
        end

        default : begin
          result_int = 0; // Undefined operations reset result
        end
      endcase
    end
  end

  // Output assignment logic
  always_ff @(posedge ap_clk) begin
    if (areset || clear) begin
      result <= 0;
    end else begin
      for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        result.field[i] <= result_int.field[i];
      end
    end
  end

endmodule : engine_alu_ops_kernel
