import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_CACHE::*;

module engine_alu_ops_kernel #(
  parameter TYPE_ALU_OPERATION_BITS     = 6,
  parameter NUM_FIELDS_MEMORYPACKETDATA = 4,
  parameter CACHE_FRONTEND_DATA_W       = 32
) (
  input  logic                                   ap_clk,
  input  logic                                   areset,
  input  logic                                   clear,
  input  type_ALU_operation                      alu_operation,
  input  MemoryPacketData                        data,
  input  logic [NUM_FIELDS_MEMORYPACKETDATA-1:0] alu_mask,
  input  logic [NUM_FIELDS_MEMORYPACKETDATA-1:0] field_mask,
  output reg [CACHE_FRONTEND_DATA_W-1:0]         result [NUM_FIELDS_MEMORYPACKETDATA]
);

  // Define internal signals
  logic [CACHE_FRONTEND_DATA_W-1:0] field_values[NUM_FIELDS_MEMORYPACKETDATA];
  logic [CACHE_FRONTEND_DATA_W*2-1:0] alu_result;

  // Process input data and mask
  always_ff @(posedge ap_clk) begin
    if (areset) begin
      for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        field_values[i] <= 0;
      end
    end else begin
      for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        field_values[i] <= data.field[i];
      end
    end
  end

  // ALU operations logic
  always_ff @(posedge ap_clk or posedge areset) begin
    if (areset || clear) begin
      alu_result <= 0;
    end else begin
      // Process the ALU operation
      case (alu_operation)
        ALU_NOP: alu_result <= field_values[0]; // No operation

        ALU_ADD: begin
          alu_result <= field_values[0];
          for (int i = 1; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (alu_mask[i]) begin
              alu_result = alu_result + field_values[i];
            end
          end
        end

        ALU_SUB: begin
          alu_result <= field_values[0];
          for (int i = 1; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (alu_mask[i]) begin
              alu_result = alu_result - field_values[i];
            end
          end
        end

        ALU_MUL: begin
          // Assuming we're multiplying field[0] and field[1]
          // Here, we assume synthesis tool will map this to DSP blocks.
          alu_result <= field_values[0] * field_values[1];
        end

        ALU_ACC: begin
          alu_result <= alu_result + field_values[0];
          for (int i = 1; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
            if (alu_mask[i]) begin
              alu_result = alu_result + field_values[i];
            end
          end
        end

        ALU_DIV: begin
          // Division is typically not implemented in DSP blocks
          // Implementing a non-restoring or restoring division algorithm is required
          // This example simply assigns a 0, you will need to implement division if needed
          alu_result <= 0;
        end

        default: alu_result <= 0; // Undefined operations reset result
      endcase
    end
  end

  // Output assignment logic
  always_ff @(posedge ap_clk) begin
    if (areset || clear) begin
      // Clear all result fields on reset or clear
      for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        result[i] <= 0;
      end
    end else begin
      // Assign the ALU result to the output fields
      for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
        result[i] <= alu_result[CACHE_FRONTEND_DATA_W*i+:CACHE_FRONTEND_DATA_W];
      end
    end
  end

endmodule : engine_alu_ops_kernel


// // The operations for subtraction, multiplication, accumulation, and division have been added with some simplifying assumptions.
// // Specifically:
// // SUB is performed as a series of 32-bit subtractions.
// // MUL is performed as a series of 32-bit multiplications.
// // ACC is the same as ADD but without the reset to zero at the beginning.
// // DIV is a simple 32-bit division, taking the first two operands into account. If the divisor is zero,
// // the result is set to an indeterminate value.
// // Note that handling overflow, underflow, and division by zero properly requires additional
// // logic not included in this example. This code also assumes that the first operand is the starting
// // point for the SUB, MUL, and DIV operations when multiple fields are selected in the mask. In a real-world scenario,
// // more complex handling of these cases might be required.

// module engine_alu_ops_kernel_v2 #(
//   parameter TYPE_ALU_OPERATION_BITS     = 6 ,
//   parameter NUM_FIELDS_MEMORYPACKETDATA = 4 ,
//   parameter CACHE_FRONTEND_DATA_W       = 32
// ) (
//   input  logic                                                         ap_clk    ,
//   input  logic                                                         areset    ,
//   input  type_ALU_operation                                            op        ,
//   input  MemoryPacketData                                              operands  ,
//   input  logic [                      NUM_FIELDS_MEMORYPACKETDATA-1:0] alu_mask  ,
//   input  logic [                      NUM_FIELDS_MEMORYPACKETDATA-1:0] field_mask,
//   output logic [CACHE_FRONTEND_DATA_W*NUM_FIELDS_MEMORYPACKETDATA-1:0] result
// );

//   logic [CACHE_FRONTEND_DATA_W*2-1:0] operand_extended[1:0]; // Only two extended operands possible

//   function automatic logic [CACHE_FRONTEND_DATA_W*2-1:0] concatenate_fields(
//       MemoryPacketData data,
//       logic [NUM_FIELDS_MEMORYPACKETDATA-1:0] mask
//     );
//     logic [CACHE_FRONTEND_DATA_W*2-1:0] concatenated_value;
//     concatenated_value = 0;

//     for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
//       if (mask[i]) begin
//         concatenated_value <<= CACHE_FRONTEND_DATA_W;
//         concatenated_value |= data.field[i];
//       end
//     end

//     return concatenated_value;
//   endfunction

//   always_comb begin
//     operand_extended[0] = concatenate_fields(operands, field_mask[1:0]);
//     operand_extended[1] = concatenate_fields(operands, field_mask[3:2]);

//     extended_result = '0; // Clear the extended result

//     // Calculate ALU operation
//     case (op)
//       ALU_ADD: begin
//         extended_result = operand_extended[0] + operand_extended[1];
//       end
//       ALU_SUB: begin
//         extended_result = operand_extended[0] - operand_extended[1];
//       end
//       ALU_MUL: begin
//         extended_result = operand_extended[0] * operand_extended[1];
//       end
//       ALU_ACC: begin
//         extended_result += operand_extended[0] + operand_extended[1];
//       end
//       ALU_DIV: begin
//         // Protection against division by zero
//         if (operand_extended[1] != 0) {
//           extended_result = operand_extended[0] / operand_extended[1];
//         } else {
//           extended_result = 'x; // Undefined or handle as required
//         }
//       end
//       ALU_NOP: begin
//         extended_result = operand_extended[0]; // Pass-through for no operation
//       end
//       default: begin
//         extended_result = 'x; // Undefined operation
//       end
//     endcase

//     // Prepare the final result, using a loop to handle different field widths
//     result = '0; // Clear the result
//     for (int i = 0; i < NUM_FIELDS_MEMORYPACKETDATA; i++) begin
//       result <<= CACHE_FRONTEND_DATA_W;
//       result |= extended_result[CACHE_FRONTEND_DATA_W*(i+1)-1 -: CACHE_FRONTEND_DATA_W];
//       }
//     end

//     // Sequential logic for result update
//     always_ff @(posedge ap_clk or negedge areset) begin
//       if (!areset) begin
//         result <= '0;
//       end else begin
//         result <= result;
//       end
//     end
// endmodule : engine_alu_ops_kernel_v2


