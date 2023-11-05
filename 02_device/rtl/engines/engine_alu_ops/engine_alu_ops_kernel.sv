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
  logic [  CACHE_FRONTEND_DATA_W-1:0] field_values[NUM_FIELDS_MEMORYPACKETDATA];
  logic [CACHE_FRONTEND_DATA_W*2-1:0] alu_result                               ;

  // Process input data and mask
  always_ff @(posedge ap_clk) begin
    if (areset) begin
      for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        field_values[i] <= 0;
      end
    end else begin
      for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        field_values[i] <= config_params.operate_on_constant&&config_params_valid?config_params.constant_value:data_valid?data.field[i] : 0;
      end
    end
  end

  // ALU operations logic
  always_comb begin
    alu_result = 0;
    // Process the ALU operation if both config_params and data are valid
    if (config_params_valid && data_valid) begin
      case (config_params.alu_operation)
        ALU_NOP : begin
          alu_result = field_values[0]; // No operation
        end

        ALU_ADD : begin
          alu_result = field_values[0];
          for (int i = 1; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (config_params.alu_mask[i]) begin
              alu_result = alu_result + field_values[i];
            end
          end
        end

        ALU_SUB : begin
          alu_result = field_values[0];
          for (int i = 1; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (config_params.alu_mask[i]) begin
              alu_result = alu_result - field_values[i];
            end
          end
        end

        ALU_MUL : begin
          // Assuming we're multiplying field[0] and field[1]
          // Here, we assume synthesis tool will map this to DSP blocks.
          alu_result = field_values[0] * field_values[1];
        end

        ALU_ACC : begin
          alu_result = alu_result + field_values[0];
          for (int i = 1; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (config_params.alu_mask[i]) begin
              alu_result = alu_result + field_values[i];
            end
          end
        end

        ALU_DIV : begin
          // Division logic
          // Insert your division logic here, for example, using the non-restoring divider module
        end

        default : begin
          alu_result = 0; // Undefined operations reset result
        end
      endcase
    end
  end

  // Output assignment logic
  always_ff @(posedge ap_clk) begin
    if (areset || clear) begin
      // Clear all result fields on reset or clear
      result <= 0;
    end else begin
      // Assign the ALU result to the output MemoryPacketData
      for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        result.field[i] <= alu_result[CACHE_FRONTEND_DATA_W * i +: CACHE_FRONTEND_DATA_W];
      end
    end
  end

endmodule : engine_alu_ops_kernel
