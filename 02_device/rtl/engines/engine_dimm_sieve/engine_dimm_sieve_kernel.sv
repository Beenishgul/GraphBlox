//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_dimm_sieve_kernel.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-09-07 23:47:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module engine_dimm_sieve_kernel (
  input  logic                         ap_clk             ,
  input  logic                         areset             ,
  input  logic                         clear              ,
  input  logic                         config_params_valid,
  input  ALUOpsConfigurationParameters config_params      ,
  input  logic                         data_valid         ,
  input  EnginePacketData              data               ,
  output logic                         result_flag        ,
  output EnginePacketData              result
);

// Define internal signals
EnginePacketData ops_value_reg  ;
EnginePacketData result_reg     ;
EnginePacketData org_value_reg  ;
logic            data_valid_reg ;
logic            result_flag_reg;

localparam RANKS     = 1 ;
localparam CHIPS     = 1 ;
localparam BGWIDTH   = 2 ;
localparam BAWIDTH   = 2 ;
localparam ADDRWIDTH = 17;
localparam BL        = 8 ; // not sure how to use this

localparam CHWIDTH          = 10;
localparam COLWIDTH         = 7 ;
localparam DEVICE_WIDTH     = 16;
localparam log_DEVICE_WIDTH = 4 ;

localparam DQWIDTH       = DEVICE_WIDTH*CHIPS                                             ;
localparam BANKGROUPS    = 2**BGWIDTH                                                     ;
localparam BANKSPERGROUP = 2**BAWIDTH                                                     ;
localparam ROWS          = 2**ADDRWIDTH                                                   ;
localparam COLS          = 2**COLWIDTH                                                    ;
localparam CHIPSIZE      = (DEVICE_WIDTH*COLS*(ROWS/1024)*BANKSPERGROUP*BANKGROUPS)/(1024); // Mbit
localparam DIMMSIZE      = (CHIPSIZE*CHIPS)/(1024*8)                                      ; // GB

// logic reset_n;

// `ifdef DDR4
//   logic ck_c;
//   logic ck_t;
// `elsif DDR3
//   logic ck_n;
//   logic ck_p;
// `endif
// logic             cke ;
// logic [RANKS-1:0] cs_n;
// `ifdef DDR4
//   //logic act_n;
// `endif
// `ifdef DDR3
//   logic ras_n;
//   logic cas_n;
//   logic we_n ;
// `endif
// //logic [ADDRWIDTH-1:0]A;
// logic [BAWIDTH-1:0] ba;
// `ifdef DDR4
//   logic [BGWIDTH-1:0] bg; // todo: explore adding one bit that is always ignored
// `endif
// logic [DQWIDTH-1:0] dq    ;
// logic [DQWIDTH-1:0] dq_reg;
// `ifdef DDR4
//   logic [CHIPS-1:0] dqs_c    ;
//   logic [CHIPS-1:0] dqs_c_reg;
//   logic [CHIPS-1:0] dqs_t    ;
//   logic [CHIPS-1:0] dqs_t_reg;
// `elsif DDR3
//   logic [CHIPS-1:0] dqs_n    ;
//   logic [CHIPS-1:0] dqs_n_reg;
//   logic [CHIPS-1:0] dqs_p    ;
//   logic [CHIPS-1:0] dqs_p_reg;
// `endif
// logic odt;
// `ifdef DDR4
//   logic parity;
// `endif

// always_ff @(posedge ap_clk ) begin
//   reset_n <= ~areset;
// end

// //DIMM #(.RANKS(RANKS),
// DIMM_fsm #(
//   .RANKS       (RANKS       ),
//   .CHIPS       (CHIPS       ),
//   .BGWIDTH     (BGWIDTH     ),
//   .BAWIDTH     (BAWIDTH     ),
//   .ADDRWIDTH   (ADDRWIDTH   ),
//   .COLWIDTH    (COLWIDTH    ),
//   .DEVICE_WIDTH(DEVICE_WIDTH),
//   .BL          (BL          ),
//   .CHWIDTH     (CHWIDTH     )
// ) dut (
//   .reset_n  (reset_n  ),
//   .ck2x     (ap_clk   ),
//   `ifdef DDR4
//   .ck_c     (ck_c     ),
//   .ck_t     (ck_t     ),
//   `elsif DDR3
//   .ck_n     (ck_n     ),
//   .ck_p     (ck_p     ),
//   `endif
//   .cke      (cke      ),
//   .cs_n     (cs_n     ),
//   `ifndef Sieve
//   `ifdef DDR4
//   .act_n    (act_n    ), // not needed for ifndef Sieve
//   `endif
//   `endif
//   `ifdef DDR3
//   .ras_n    (ras_n    ),
//   .cas_n    (cas_n    ),
//   .we_n     (we_n     ),
//   `endif
//   //.A(A), // A fix pattern that gives control to RLU
//   .ba       (ba       ),
//   `ifdef DDR4
//   .bg       (bg       ),
//   `endif
//   .dq       (dq       ),
//   `ifdef DDR4
//   .dqs_c    (dqs_c    ),
//   .dqs_t    (dqs_t    ),
//   `elsif DDR3
//   .dqs_n    (dqs_n    ),
//   .dqs_p    (dqs_p    ),
//   `endif
//   .odt      (odt      ),
//   `ifdef DDR4
//   .parity   (parity   ),
//   `endif
//   `ifdef Sieve
//   .match_en (match_en ),
//   .match_col(match_col), // added new
//   `endif
//   .sync     (sync     )
// );


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
  end else begin
    if (config_params_valid & data_valid_reg) begin
      result_flag_reg <= 1'b1;
      case (config_params.alu_operation)
// --------------------------------------------------------------------------------------
        ALU_NOP : begin
          result_reg <= ops_value_reg; // No operation
        end
// --------------------------------------------------------------------------------------
        ALU_ADD : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            if (config_params.alu_mask[i]) begin
              result_reg <= ops_value_reg.field[i] + ops_value_reg.field[i+1];
            end
          end
        end
// --------------------------------------------------------------------------------------
        ALU_SUB : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS-1; i++) begin
            if (config_params.alu_mask[i]) begin
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
            if (config_params.alu_mask[i]) begin
              result_reg <= ops_value_reg.field[i] * ops_value_reg.field[i+1];
            end
          end
        end
// --------------------------------------------------------------------------------------
        ALU_ACC : begin
          for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
            if (config_params.alu_mask[i]) begin
              result_reg <= result_reg + ops_value_reg.field[i];
            end
          end
        end
// --------------------------------------------------------------------------------------
        ALU_DIV : begin
          result_reg <= ops_value_reg; // Undefined operations reset result
        end
// --------------------------------------------------------------------------------------
        default : begin
          result_reg <= ops_value_reg; // Undefined operations reset result
        end
// --------------------------------------------------------------------------------------
      endcase
    end else begin
      result_flag_reg <= 1'b0;
    end
  end
end

// Output assignment logic
always_ff @(posedge ap_clk) begin
  if (areset) begin
    result      <= 0;
    result_flag <= 0;
  end else begin
    for (int i = 0; i<ENGINE_PACKET_DATA_NUM_FIELDS/2; i++) begin
      result.field[i] <= result_reg.field[i];
    end
    for (int i = ENGINE_PACKET_DATA_NUM_FIELDS/2; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
      result.field[i] <= org_value_reg.field[i];
    end
    result_flag <= result_flag_reg;
  end
end

endmodule : engine_dimm_sieve_kernel
