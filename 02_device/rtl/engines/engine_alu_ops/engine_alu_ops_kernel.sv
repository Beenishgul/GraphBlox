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
      for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        field_values[i] <= 0;
      end
    end else begin
      for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        field_values[i] <= config_params.operate_on_constant&&config_params_valid?config_params.constant_value:data_valid?data.field[i] : 0;
      end
    end
  end

  // ALU operations logic
  always_ff @(posedge ap_clk) begin
    if (areset || clear) begin
      alu_result <= 0;
    end else begin
      // Process the ALU operation if both config_params and data are valid
      if (config_params_valid && data_valid) begin
        case (config_params.alu_operation)
          ALU_NOP : alu_result <= field_values[0]; // No operation

          ALU_ADD : begin
            alu_result <= field_values[0];
            for (int i = 1; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
              if (config_params.alu_mask[i]) begin
                alu_result <= alu_result + field_values[i];
              end
            end
          end

          ALU_SUB : begin
            alu_result <= field_values[0];
            for (int i = 1; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
              if (config_params.alu_mask[i]) begin
                alu_result <= alu_result - field_values[i];
              end
            end
          end

          ALU_MUL : begin
            // Assuming we're multiplying field[0] and field[1]
            // Here, we assume synthesis tool will map this to DSP blocks.
            alu_result <= field_values[0] * field_values[1];
          end

          ALU_ACC : begin
            alu_result <= alu_result + field_values[0];
            for (int i = 1; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
              if (config_params.alu_mask[i]) begin
                alu_result <= alu_result + field_values[i];
              end
            end
          end

          ALU_DIV : begin
            // Division logic
            // Insert your division logic here, for example, using the non-restoring divider module
          end

          default : alu_result <= 0; // Undefined operations reset result
        endcase
      end
    end
  end

  // Output assignment logic
  always_ff @(posedge ap_clk) begin
    if (areset || clear) begin
      // Clear all result fields on reset or clear
      result <= 0;
    end else begin
      // Assign the ALU result to the output MemoryPacketData
      for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        result.field[i] <= alu_result[CACHE_FRONTEND_DATA_W * i +: CACHE_FRONTEND_DATA_W];
      end
    end
  end

endmodule : engine_alu_ops_kernel
