// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : counter_pulse.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

// module counter_pulse #(parameter int MASK_WIDTH = 8 // Default parameter, can be overridden to any size
// ) (
//     input  logic                  ap_clk          , // Clock input for synchronous logic
//     input  logic                  areset          , // Active-low asynchronous reset
//     input  logic [MASK_WIDTH-1:0] valid_in        , // Valid signal indicating when the input should be processed
//     input  logic [MASK_WIDTH-1:0] mask_in         , // Input vector of size N
//     output logic                  pulse_out       , // Single valid_in bit asserted for 'count' number of cycles
//     output logic [MASK_WIDTH-1:0] param_select_out  // Single valid_in bit asserted for 'count' number of cycles
// );

// // Derived parameter for counter size
//     localparam int COUNTER_WIDTH = $clog2(MASK_WIDTH) + 1;

//     logic [COUNTER_WIDTH-1:0] count               ; // To hold the count of '1's mask_in 'mask_in'
//     logic [COUNTER_WIDTH-1:0] pulse_counter_reg   ; // Counter for the output pulse
//     logic [   MASK_WIDTH-1:0] param_select_out_int;

//     always_comb begin
//         count     = 0;
//         pulse_out = 1'b0;
//         for (int i = 0; i < MASK_WIDTH; i++) begin
//             count += mask_in[i] & valid_in[i];
//         end
//         pulse_out = (pulse_counter_reg > 2) | valid_in;
//     end

//     always_comb begin
//         param_select_out    = 0;
//         param_select_out[0] = param_select_out_int[0];
//         for (int i = 1; i < MASK_WIDTH; i++) begin
//             param_select_out[i] = |param_select_out ? 1'b0 : param_select_out_int[i];
//         end
//     end

//     always_comb begin
//         if(|valid_in) begin
//             param_select_out_int = mask_in;
//         end else if (pulse_counter_reg > 1) begin
//             param_select_out_int = param_select_out_int & (param_select_out_int - 1);
//         end else begin
//             param_select_out_int = 0;
//         end
//     end

//     always_ff @(posedge ap_clk) begin
//         if(areset)begin
//             pulse_counter_reg <= 0;
//         end begin
//             if(|valid_in) begin
//                 pulse_counter_reg <= count;
//             end else if (pulse_counter_reg > 1) begin
//                 pulse_counter_reg <= pulse_counter_reg - 1;
//             end
//         end
//     end

// endmodule : counter_pulse


module config_params_select_pulse #(parameter int MASK_WIDTH = 8 // Default parameter, can be overridden to any size
) (
    input  logic                                        ap_clk                    , // Clock input for synchronous logic
    input  logic                                        areset                    , // Active-low asynchronous reset
    input  ParallelReadWriteConfiguration               config_params_in          ,
    input  EnginePacket                                 response_engine_in        ,
    output logic                                        pulse_out                 , // Single valid_in bit asserted for 'count' number of cycles
    output ParallelReadWriteConfigurationParameterField config_params_out         ,
    output ParallelReadWriteConfigurationMeta           config_meta_out           ,
    output logic [MASK_WIDTH-1:0]                       config_params_kernel_valid
);
// Derived parameter for counter size
    localparam int COUNTER_WIDTH = $clog2(MASK_WIDTH) + 1;

    logic [   MASK_WIDTH-1:0] config_params_cast_valid;
    logic [   MASK_WIDTH-1:0] config_params_lane_valid;
    logic [   MASK_WIDTH-1:0] param_select_out_int    ;
    logic [   MASK_WIDTH-1:0] param_select_out        ;
    logic [COUNTER_WIDTH-1:0] count                   ; // To hold the count of '1's mask_in 'mask_in'
    logic [COUNTER_WIDTH-1:0] pulse_counter_reg       ; // Counter for the output pulse

    always_comb begin
        count     = {COUNTER_WIDTH{1'b0}};
        pulse_out = 1'b0;
        for (int i = 0; i < MASK_WIDTH; i++) begin
            count += config_params_in.payload.param.cast_mask[i] & config_params_cast_valid[i];
        end
        pulse_out = (pulse_counter_reg > 2) | config_params_cast_valid;
    end

    always_comb begin
        param_select_out    = {MASK_WIDTH{1'b0}};
        param_select_out[0] = param_select_out_int[0];
        for (int i = 1; i < MASK_WIDTH; i++) begin
            param_select_out[i] = param_select_out_int[i] & ~param_select_out[i-1];
        end
    end

    always_comb begin
        if(|config_params_cast_valid) begin
            param_select_out_int = config_params_in.payload.param.cast_mask;
        end else if (pulse_counter_reg > 1) begin
            param_select_out_int = param_select_out_int & (param_select_out_int - 1);
        end else begin
            param_select_out_int = 0;
        end
    end

    always_ff @(posedge ap_clk) begin
        if(areset)begin
            pulse_counter_reg <= {COUNTER_WIDTH{1'b0}};
        end begin
            if(|config_params_cast_valid) begin
                pulse_counter_reg <= count;
            end else if (pulse_counter_reg > 1) begin
                pulse_counter_reg <= pulse_counter_reg - 1;
            end
        end
    end

    // --------------------------------------------------------------------------------------
    always_comb begin
        config_params_kernel_valid    = {MASK_WIDTH{1'b0}};
        config_params_out             = config_params_in.payload.param.param_field[0];
        config_meta_out               = config_params_in.payload.param.meta[0];
        config_params_kernel_valid[0] = param_select_out[0] | config_params_lane_valid[0];
        for (int i = 1; i < MASK_WIDTH; i++) begin
            if((param_select_out[i] | config_params_lane_valid[i]) & ~config_params_kernel_valid[i-1]) begin
                config_params_out = config_params_in.payload.param.param_field[i];
                config_meta_out   = config_params_in.payload.param.meta[i];
                config_params_kernel_valid[i] = 1'b1;
            end
            if(config_params_kernel_valid[i-1]) begin
                config_params_kernel_valid[i] = 1'b1;
            end
        end
    end

    // --------------------------------------------------------------------------------------
    always_comb begin
        config_params_cast_valid = {MASK_WIDTH{1'b0}};
        config_params_lane_valid = {MASK_WIDTH{1'b0}};
        for (int i = 0; i < MASK_WIDTH; i++) begin
            config_params_cast_valid[i] = response_engine_in.valid & config_params_in.payload.param.cast_mask[i] & (response_engine_in.payload.meta.route.sequence_source.id_bundle == config_params_in.payload.param.meta[i].ops_bundle) & (response_engine_in.payload.meta.route.sequence_source.id_lane == config_params_in.payload.param.meta[i].ops_lane);
            config_params_lane_valid[i] = response_engine_in.valid & config_params_in.payload.param.lane_mask[i] & (response_engine_in.payload.meta.route.sequence_source.id_bundle == config_params_in.payload.param.meta[i].ops_bundle) & (response_engine_in.payload.meta.route.sequence_source.id_lane == config_params_in.payload.param.meta[i].ops_lane);
        end
    end

endmodule : config_params_select_pulse