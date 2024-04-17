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

`include "global_package.vh"

module engine_filter_cond_kernel (
  input  logic                             ap_clk,
  input  FilterCondConfigurationParameters config_params_in,
  input  EnginePacketData                  data_in,
  output EnginePacketData                  result_out,
  output logic                             result_bool
);

// Define internal signals
EnginePacketData                  ops_value_reg    ;
EnginePacketData                  result_reg       ;
EnginePacketData                  org_value_reg    ;
FilterCondConfigurationParameters config_params_reg;

logic[ENGINE_PACKET_DATA_NUM_FIELDS-1:0] result_bool_reg;

always_ff @(posedge ap_clk) begin
  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    if(config_params_in.const_mask[i]) begin
      ops_value_reg.field[i]       <= config_params_in.const_value;
      ops_value_reg.field_state[i] <= SEQUENCE_RUNNING;
    end else  begin
      if(|config_params_in.ops_mask[i])begin
        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
          if(config_params_in.ops_mask[i][j]) begin
            ops_value_reg.field[i]       <= data_in.field[j];
            ops_value_reg.field_state[i] <= data_in.field_state[j];
          end
        end
      end else begin
        ops_value_reg.field[i]       <= 0;
        ops_value_reg.field_state[i] <= SEQUENCE_INVALID;
      end
    end
  end

  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    if(config_params_in.const_mask[i] & (|config_params_in.set_mask)) begin
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

// ALU operations logic
always_ff @(posedge ap_clk) begin
  config_params_reg.filter_mask      <= config_params_in.filter_mask;
  config_params_reg.filter_operation <= config_params_in.filter_operation;
  config_params_reg.equal_flag       <= config_params_in.equal_flag;
  result_reg.field_state             <= org_value_reg.field_state; // Undefined operations reset result_out
  case (config_params_reg.filter_operation)
// --------------------------------------------------------------------------------------
    FILTER_NOP : begin
      result_reg.field  <= org_value_reg.field; // No operation
      result_bool_reg   <= ~0;
    end
// --------------------------------------------------------------------------------------
    FILTER_GT : begin
      for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
        result_reg.field[i] <= org_value_reg.field[i];
        if (config_params_reg.filter_mask[i]) begin
          result_bool_reg[i] <= (ops_value_reg.field[i] > ops_value_reg.field[i+1]) | (config_params_reg.equal_flag & (ops_value_reg.field[i] == ops_value_reg.field[i+1]));
        end
      end
      result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
      if (config_params_reg.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
        result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= (ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] > ops_value_reg.field[0]) | (config_params_reg.equal_flag & (ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] == ops_value_reg.field[0]));
      end
    end
// --------------------------------------------------------------------------------------
    FILTER_LT : begin
      for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
        result_reg.field[i] <= org_value_reg.field[i];
        if (config_params_reg.filter_mask[i]) begin
          result_bool_reg[i] <= (ops_value_reg.field[i] < ops_value_reg.field[i+1]) | (config_params_reg.equal_flag & (ops_value_reg.field[i] == ops_value_reg.field[i+1]));
        end
      end
      result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
      if (config_params_reg.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
        result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= (ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] < ops_value_reg.field[0]) | (config_params_reg.equal_flag & (ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] == ops_value_reg.field[0]));
      end
    end
// --------------------------------------------------------------------------------------
    FILTER_EQ : begin
      for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
        result_reg.field[i] <= org_value_reg.field[i];
        if (config_params_reg.filter_mask[i]) begin
          result_bool_reg[i] <= ops_value_reg.field[i] == ops_value_reg.field[i+1];
        end
      end
      result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
      if (config_params_reg.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
        result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] == ops_value_reg.field[0];
      end
    end
// --------------------------------------------------------------------------------------
    FILTER_NOT_EQ : begin
      for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
        result_reg.field[i] <= org_value_reg.field[i];
        if (config_params_reg.filter_mask[i]) begin
          result_bool_reg[i] <= ops_value_reg.field[i] != ops_value_reg.field[i+1];
        end
      end
      result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
      if (config_params_reg.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
        result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] != ops_value_reg.field[0];
      end
    end
// --------------------------------------------------------------------------------------
    FILTER_GT_TERN : begin
      if((ops_value_reg.field[0] > ops_value_reg.field[1]) | (config_params_reg.equal_flag & (ops_value_reg.field[0] == ops_value_reg.field[1]))) begin
        result_reg.field[0] <= ops_value_reg.field[0];
        result_reg.field[1] <= ops_value_reg.field[1];
      end else begin
        result_reg.field[0] <= ops_value_reg.field[1];
        result_reg.field[1] <= ops_value_reg.field[0];
      end
      for (int i = 2; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
        result_reg.field[i] <= ops_value_reg.field[i];
      end
      result_bool_reg <= ~0;
    end
// --------------------------------------------------------------------------------------
    FILTER_LT_TERN : begin
      if((ops_value_reg.field[0] < ops_value_reg.field[1]) | (config_params_reg.equal_flag & (ops_value_reg.field[0] == ops_value_reg.field[1]))) begin
        result_reg.field[0] <= ops_value_reg.field[0];
        result_reg.field[1] <= ops_value_reg.field[1];
      end else begin
        result_reg.field[0] <= ops_value_reg.field[1];
        result_reg.field[1] <= ops_value_reg.field[0];
      end
      for (int i = 2; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
        result_reg.field[i] <= ops_value_reg.field[i];
      end
      result_bool_reg <= ~0;
    end
// --------------------------------------------------------------------------------------
    FILTER_EQ_TERN : begin
      if(ops_value_reg.field[0] == ops_value_reg.field[1]) begin
        result_reg.field[0]                               <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
        result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[0];
      end else begin
        result_reg.field[0]                               <= ops_value_reg.field[0];
        result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
      end
      for (int i = 1; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
        result_reg.field[i] <= ops_value_reg.field[i];
      end
      result_bool_reg <= ~0;
    end
// --------------------------------------------------------------------------------------
    FILTER_NOT_EQ_TERN : begin
      if(ops_value_reg.field[0] != ops_value_reg.field[1]) begin
        result_reg.field[0]                               <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
        result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[0];
      end else begin
        result_reg.field[0]                               <= ops_value_reg.field[0];
        result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
      end
      for (int i = 1; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
        result_reg.field[i] <= ops_value_reg.field[i];
      end
      result_bool_reg <= ~0;
    end
// --------------------------------------------------------------------------------------
    default : begin
      result_reg.field <= org_value_reg.field; // Undefined operations reset result_out
      result_bool_reg  <= ~0;
    end
// --------------------------------------------------------------------------------------
  endcase
end

// Output assignment logic
always_ff @(posedge ap_clk) begin
  for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    result_out.field[i]       <= result_reg.field[i];
    result_out.field_state[i] <= result_reg.field_state[i];
  end
  result_bool <= &(result_bool_reg | ~config_params_reg.filter_mask);
end

endmodule : engine_filter_cond_kernel
