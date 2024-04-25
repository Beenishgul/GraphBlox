//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_automata_nfa_kernel.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_automata_nfa_kernel (
  input  logic                             ap_clk,
  input  logic                             areset,
  input  logic                             clear,
  input  logic                             config_params_valid,
  input  FilterCondConfigurationParameters config_params,
  input  logic                             data_valid,
  input  EnginePacketData                  data,
  output logic                             result_flag,
  output EnginePacketData                  result,
  output logic                             result_bool
);

// Define internal signals
EnginePacketData ops_value_reg  ;
EnginePacketData result_reg     ;
EnginePacketData org_value_reg  ;
logic            data_valid_reg ;
logic            result_flag_reg;
logic[ENGINE_PACKET_DATA_NUM_FIELDS-1:0] result_bool_reg;

// Process input data and mask
always_ff @(posedge ap_clk) begin
  if (areset) begin
    data_valid_reg <= 1'b0;
    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      ops_value_reg.field[i] <= 0;
      org_value_reg.field[i] <= 0;
    end
  end else begin
    data_valid_reg <= data_valid;
    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      if(config_params.const_mask[i] & config_params_valid) begin
        ops_value_reg.field[i] <= config_params.const_value;
      end else if (data_valid & config_params_valid) begin
        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
          if(config_params.ops_mask[i][j]) begin
            ops_value_reg.field[i] <= data.field[j];
          end
        end
      end else begin
        ops_value_reg.field[i] <= 0;
      end
    end

    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      if (config_params_valid) begin
        for (int j = 0; j<ENGINE_PACKET_DATA_NUM_FIELDS; j++) begin
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

// ALU operations logic
always_ff @(posedge ap_clk) begin
  if (areset | clear) begin
    result_flag_reg <= 1'b0;
    result_reg      <= 0;
    result_bool_reg <= ~0;
  end else begin
    if (config_params_valid & data_valid_reg) begin
      result_flag_reg <= 1'b1;
      case (config_params.filter_operation)
// --------------------------------------------------------------------------------------
        FILTER_NOP : begin
          result_reg      <= ops_value_reg; // No operation
          result_bool_reg <= ~0;
        end
// --------------------------------------------------------------------------------------
        FILTER_GT : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            result_reg.field[i] <= org_value_reg.field[i];
            if (config_params.filter_mask[i]) begin
              result_bool_reg[i] <= ops_value_reg.field[i] > ops_value_reg.field[i+1];
            end
          end
          result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] > ops_value_reg.field[0];
          end
        end
// --------------------------------------------------------------------------------------
        FILTER_LT : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            result_reg.field[i] <= org_value_reg.field[i];
            if (config_params.filter_mask[i]) begin
              result_bool_reg[i] <= ops_value_reg.field[i] < ops_value_reg.field[i+1];
            end
          end
          result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] < ops_value_reg.field[0];
          end
        end
// --------------------------------------------------------------------------------------
        FILTER_EQ : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            result_reg.field[i] <= org_value_reg.field[i];
            if (config_params.filter_mask[i]) begin
              result_bool_reg[i] <= ops_value_reg.field[i] == ops_value_reg.field[i+1];
            end
          end
          result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] == ops_value_reg.field[0];
          end
        end
// --------------------------------------------------------------------------------------
        FILTER_NOT_EQ : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            result_reg.field[i] <= org_value_reg.field[i];
            if (config_params.filter_mask[i]) begin
              result_bool_reg[i] <= ops_value_reg.field[i] != ops_value_reg.field[i+1];
            end
          end
          result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= org_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            result_bool_reg[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] != ops_value_reg.field[0];
          end
        end
// --------------------------------------------------------------------------------------
        FILTER_GT_TERN : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(ops_value_reg.field[i] > ops_value_reg.field[i+1]) begin
                result_reg.field[0] <= ops_value_reg.field[i];
                result_reg.field[i] <= ops_value_reg.field[0];
              end else begin
                result_reg.field[0]   <= ops_value_reg.field[i+1];
                result_reg.field[i+1] <= ops_value_reg.field[0];
              end
            end else begin
              result_reg.field[i] <= ops_value_reg.field[i];
            end
          end
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            if(ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] > ops_value_reg.field[0]) begin
              result_reg.field[0]                               <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
              result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[0];
            end else begin
              result_reg.field[0] <= ops_value_reg.field[0];
            end
          end else begin
            result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          end
          result_bool_reg <= ~0;
        end
// --------------------------------------------------------------------------------------
        FILTER_LT_TERN : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(ops_value_reg.field[i] < ops_value_reg.field[i+1]) begin
                result_reg.field[0] <= ops_value_reg.field[i];
                result_reg.field[i] <= ops_value_reg.field[0];
              end else begin
                result_reg.field[0]   <= ops_value_reg.field[i+1];
                result_reg.field[i+1] <= ops_value_reg.field[0];
              end
            end else begin
              result_reg.field[i] <= ops_value_reg.field[i];
            end
          end
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            if(ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] < ops_value_reg.field[0]) begin
              result_reg.field[0]                               <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
              result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[0];
            end else begin
              result_reg.field[0] <= ops_value_reg.field[0];
            end
          end else begin
            result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          end
          result_bool_reg <= ~0;
        end
// --------------------------------------------------------------------------------------
        FILTER_EQ_TERN : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(ops_value_reg.field[i] == ops_value_reg.field[i+1]) begin
                result_reg.field[0] <= ops_value_reg.field[i];
                result_reg.field[i] <= ops_value_reg.field[0];
              end else begin
                result_reg.field[0]   <= ops_value_reg.field[i+1];
                result_reg.field[i+1] <= ops_value_reg.field[0];
              end
            end else begin
              result_reg.field[i] <= ops_value_reg.field[i];
            end
          end
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            if(ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] == ops_value_reg.field[0]) begin
              result_reg.field[0]                               <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
              result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[0];
            end else begin
              result_reg.field[0] <= ops_value_reg.field[0];
            end
          end else begin
            result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          end
          result_bool_reg <= ~0;
        end
// --------------------------------------------------------------------------------------
        FILTER_NOT_EQ_TERN : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            if (config_params.filter_mask[i]) begin
              if(ops_value_reg.field[i] != ops_value_reg.field[i+1]) begin
                result_reg.field[0] <= ops_value_reg.field[i];
                result_reg.field[i] <= ops_value_reg.field[0];
              end else begin
                result_reg.field[0]   <= ops_value_reg.field[i+1];
                result_reg.field[i+1] <= ops_value_reg.field[0];
              end
            end else begin
              result_reg.field[i] <= ops_value_reg.field[i];
            end
          end
          if (config_params.filter_mask[ENGINE_PACKET_DATA_NUM_FIELDS-1]) begin
            if(ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] != ops_value_reg.field[0]) begin
              result_reg.field[0]                               <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
              result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[0];
            end else begin
              result_reg.field[0] <= ops_value_reg.field[0];
            end
          end else begin
            result_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1] <= ops_value_reg.field[ENGINE_PACKET_DATA_NUM_FIELDS-1];
          end
          result_bool_reg <= ~0;
        end
// --------------------------------------------------------------------------------------
        default : begin
          result_reg      <= org_value_reg; // Undefined operations reset result
          result_flag_reg <= 1'b0;
          result_bool_reg <= ~0;;
        end
// --------------------------------------------------------------------------------------
      endcase
    end else begin
      result_reg      <= org_value_reg; // Undefined operations reset result
      result_flag_reg <= 1'b0;
      result_bool_reg <= ~0;;
    end
  end
end

logic [7:0] symbols      ;
logic [6:0] symbols_match;

assign symbols = ops_value_reg.field[0][7:0];

Top_ModuleC0lw inst_Top_ModuleC0lw_1 (
  .clk     (ap_clk  ),
  .reset   (areset  ),
  .run     (1'b1    ),
  .symbols (symbols ),
  .ltl4c0lw(symbols_match[0]),
  .ltl6c0lw(symbols_match[1]),
  .ltl2c0lw(symbols_match[2]),
  .ltl3c0lw(symbols_match[3]),
  .ltl1c0lw(symbols_match[4]),
  .ltl0c0lw(symbols_match[5]),
  .ltl5c0lw(symbols_match[6])
);

// Output assignment logic
always_ff @(posedge ap_clk) begin
  if (areset) begin
    result      <= 0;
    result_flag <= 1'b0;
    result_bool <= 1'b1;
  end else begin
    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      result.field[i] <= result_reg.field[i];
    end
    result_flag <= result_flag_reg;
    result_bool <= &(result_bool_reg | ~config_params.filter_mask);
  end
end

endmodule : engine_automata_nfa_kernel
