//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_filter_cond_kernel.sv
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

module engine_filter_cond_kernel (
  input  logic                             ap_clk             ,
  input  logic                             areset             ,
  input  logic                             clear              ,
  input  logic                             config_params_valid,
  input  FilterCondConfigurationParameters config_params      ,
  input  logic                             data_valid         ,
  input  MemoryPacketData                  data               ,
  output logic                             result_flag        ,
  output MemoryPacketData                  result_data
);

  // Define internal signals
  MemoryPacketData ops_value_reg  ;
  MemoryPacketData result_data_int;
  MemoryPacketData org_value_reg  ;
  MemoryPacketData org_data_int   ;
  logic            result_flag_int;
  logic            data_valid_reg ;

  // Process input data and mask
  always_ff @(posedge ap_clk) begin
    if (areset) begin
      data_valid_reg <= 1'b0;
      for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        ops_value_reg.field[i] <= 0;
        org_value_reg.field[i] <= 0;
      end
    end else begin
      data_valid_reg <= data_valid;
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
          ops_value_reg.field[i] <= data.field[i];
        end

        for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA; i++) begin
          if (data_valid & config_params_valid) begin
            for (int j = 0; j<NUM_FIELDS_MEMORYPACKETDATA; j++) begin
              if(config_params.ops_mask[i][j]) begin
                org_value_reg.field[i] <= data.field[j];
              end
            end
          end else begin
            org_value_reg.field[i] <= data.field[i];
          end
        end
      end
    end
  end

  // FILTER operations logic
  always_comb begin
    // Process the FILTER operation if both config_params and data are valid
    result_flag_int = ~config_params.break_pass;
    result_data_int = ops_value_reg;
    org_data_int    = org_value_reg;

    if (config_params_valid & data_valid_reg) begin
      case (config_params.filter_operation)
        FILTER_NOP : begin
        end

        FILTER_GT : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              result_flag_int = result_flag_int & (result_data_int.field[i] > ops_value_reg.field[i+1]);
            end
          end
        end

        FILTER_LT : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              result_flag_int = result_flag_int & (result_data_int.field[i] < ops_value_reg.field[i+1]);
            end
          end
        end

        FILTER_EQ : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              result_flag_int = result_flag_int & (result_data_int.field[i] == ops_value_reg.field[i+1]);
            end
          end
        end

        FILTER_NOT_EQ : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              result_flag_int = result_flag_int & (result_data_int.field[i] != ops_value_reg.field[i+1]);
            end
          end
        end

        FILTER_GT_TERN : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(result_data_int.field[i] > ops_value_reg.field[i+1]) begin
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[i] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
              end
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[i+1] = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
            end
          end
          org_data_int = result_data_int;
        end

        FILTER_LT_TERN : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(result_data_int.field[i] < ops_value_reg.field[i+1]) begin
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[i] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
              end
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[i+1] = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
            end
          end
          org_data_int = result_data_int;
        end

        FILTER_EQ_TERN : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(result_data_int.field[i] == ops_value_reg.field[i+1]) begin
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[i] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
              end
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[i+1] = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
            end
          end
          org_data_int = result_data_int;
        end

        FILTER_NOT_EQ_TERN : begin
          for (int i = 0; i<NUM_FIELDS_MEMORYPACKETDATA-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(result_data_int.field[i] != ops_value_reg.field[i+1]) begin
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[i] = result_data_int.field[0] ^ result_data_int.field[i];
                result_data_int.field[0] = result_data_int.field[0] ^ result_data_int.field[i];
              end
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[i+1] = result_data_int.field[0] ^ result_data_int.field[i+1];
              result_data_int.field[0]   = result_data_int.field[0] ^ result_data_int.field[i+1];
            end
          end
          org_data_int = result_data_int;
        end

        default : begin
          result_data_int = 0; // Undefined operations reset result_data
        end
      endcase
    end
  end

  // Output assignment logic
  always_ff @(posedge ap_clk) begin
    if (areset || clear) begin
      result_data <= 0;
      result_flag <= ~config_params.break_pass;
    end else begin
      result_data <= org_data_int;
      result_flag <= result_flag_int;
    end
  end

endmodule : engine_filter_cond_kernel
