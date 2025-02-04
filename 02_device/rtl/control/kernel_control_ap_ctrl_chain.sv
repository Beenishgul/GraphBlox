// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_control_user_managed.sv
// Create : 2023-01-24 01:37:48
// Revise : 2023-01-24 01:37:48
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_package.vh"

module kernel_control (
    input  logic                       ap_clk        ,
    input  logic                       areset        ,
    input  ControlChainInterfaceInput  control_in    ,
    output ControlChainInterfaceOutput control_out   ,
    input  KernelDescriptorPayload     descriptor_in ,
    output KernelDescriptor            descriptor_out
);

// --------------------------------------------------------------------------------------
// kernel_control variables
// --------------------------------------------------------------------------------------
logic descriptor_valid_reg;
logic areset_control      ;
logic cu_done_reg         ;
logic cu_setup_reg        ;

logic start_reg       ;
logic endian_read_reg ;
logic endian_write_reg;
logic ap_start_reg    ;
logic ap_ready_reg    ;
logic ap_idle_reg     ;
logic ap_done_reg     ;

logic ap_continue_reg;

KernelDescriptorPayload descriptor_in_reg;

control_sync_state_ap_ctrl_chain current_state;
control_sync_state_ap_ctrl_chain next_state   ;

ControlChainInterfaceOutput control_out_reg;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    areset_control <= areset;
end

// --------------------------------------------------------------------------------------
//   Reset internal registers
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_control) begin
        cu_done_reg  <= 0;
        cu_setup_reg <= 1;
    end
    else begin
        cu_done_reg  <= control_in.done;
        cu_setup_reg <= control_in.setup;
    end
end

// --------------------------------------------------------------------------------------
//   Reset output registers
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_control) begin
        control_out.ap_ready     <= 1'b0;
        control_out.ap_done      <= 1'b0;
        control_out.ap_idle      <= 1'b1;
        control_out.start        <= 1'b0;
        control_out.endian_read  <= 1'b0;
        control_out.endian_write <= 1'b0;
    end
    else begin
        control_out <= control_out_reg;
    end
end

always_ff @(posedge ap_clk) begin
    if (areset_control) begin
        control_out_reg.ap_ready     <= 1'b0;
        control_out_reg.ap_done      <= 1'b0;
        control_out_reg.ap_idle      <= 1'b1;
        control_out_reg.start        <= 1'b0;
        control_out_reg.endian_read  <= 1'b0;
        control_out_reg.endian_write <= 1'b0;
    end
    else begin
        control_out_reg.ap_ready     <= ap_ready_reg;
        control_out_reg.ap_done      <= ap_done_reg;
        control_out_reg.ap_idle      <= ap_idle_reg;
        control_out_reg.start        <= start_reg;
        control_out_reg.endian_read  <= endian_read_reg;
        control_out_reg.endian_write <= endian_write_reg;
    end
end

// --------------------------------------------------------------------------------------
//   Reset input registers
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_control) begin
        ap_start_reg    <= 0;
        ap_continue_reg <= 0;
    end
    else begin
        ap_start_reg    <= control_in.ap_start;
        ap_continue_reg <= 1;
    end
end

// --------------------------------------------------------------------------------------
//   Descriptor LOGIC
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if (areset_control) begin
        descriptor_out.valid <= 1'b0;
    end
    else begin
        descriptor_out.valid <= descriptor_valid_reg;
    end
end

always_ff @(posedge ap_clk) begin
    descriptor_in_reg      <= descriptor_in;
    descriptor_out.payload <= descriptor_in_reg;
end

// --------------------------------------------------------------------------------------
//   State Machine AP_USER_MANAGED sync
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
    if(areset_control)
        current_state <= CTRL_CHAIN_SYNC_RESET;
    else begin
        current_state <= next_state;
    end
end // always_ff @(posedge ap_clk)

always_comb begin
    next_state = current_state;
    case (current_state)
        CTRL_CHAIN_SYNC_RESET : begin
            next_state = CTRL_CHAIN_SYNC_IDLE;
        end
        CTRL_CHAIN_SYNC_IDLE : begin
            next_state = CTRL_CHAIN_SYNC_SETUP;
        end
        CTRL_CHAIN_SYNC_SETUP : begin
            if(ap_start_reg)
                next_state = CTRL_CHAIN_SYNC_READY;
            else
                next_state = CTRL_CHAIN_SYNC_SETUP;
        end
        CTRL_CHAIN_SYNC_READY : begin
            if(cu_setup_reg)
                next_state = CTRL_CHAIN_SYNC_START;
            else
                next_state = CTRL_CHAIN_SYNC_READY;
        end
        CTRL_CHAIN_SYNC_START : begin
            next_state = CTRL_CHAIN_SYNC_BUSY;
        end
        CTRL_CHAIN_SYNC_BUSY : begin
            if (cu_done_reg)
                next_state = CTRL_CHAIN_SYNC_DONE;
            else
                next_state = CTRL_CHAIN_SYNC_BUSY;
        end
        CTRL_CHAIN_SYNC_DONE : begin
            if(ap_start_reg)
                next_state = CTRL_CHAIN_SYNC_READY;
            else
                next_state = CTRL_CHAIN_SYNC_DONE;
        end
        default : begin
            next_state = CTRL_CHAIN_SYNC_RESET;
        end
    endcase
end // always_comb

always_ff @(posedge ap_clk) begin
    case (current_state)
        CTRL_CHAIN_SYNC_RESET : begin
            ap_ready_reg         <= 1'b0;
            ap_done_reg          <= 1'b0;
            ap_idle_reg          <= 1'b1;
            descriptor_valid_reg <= 1'b0;
            start_reg            <= 1'b0;
            endian_read_reg      <= 1'b0;
            endian_write_reg     <= 1'b0;
        end
        CTRL_CHAIN_SYNC_IDLE : begin
            ap_ready_reg         <= 1'b0;
            ap_done_reg          <= 1'b0;
            ap_idle_reg          <= 1'b1;
            descriptor_valid_reg <= 1'b0;
            start_reg            <= 1'b0;
            endian_read_reg      <= 1'b0;
            endian_write_reg     <= 1'b0;
        end
        CTRL_CHAIN_SYNC_SETUP : begin
            ap_ready_reg         <= 1'b0;
            ap_done_reg          <= 1'b0;
            ap_idle_reg          <= 1'b1;
            descriptor_valid_reg <= 1'b0;
            start_reg            <= 1'b1;
            endian_read_reg      <= 1'b0;
            endian_write_reg     <= 1'b0;
        end
        CTRL_CHAIN_SYNC_READY : begin
            ap_ready_reg         <= 1'b1;
            ap_done_reg          <= 1'b0;
            ap_idle_reg          <= 1'b0;
            descriptor_valid_reg <= 1'b0;
            start_reg            <= 1'b1;
            endian_read_reg      <= 1'b0;
            endian_write_reg     <= 1'b0;
        end
        CTRL_CHAIN_SYNC_START : begin
            ap_ready_reg         <= 1'b0;
            ap_done_reg          <= 1'b0;
            ap_idle_reg          <= 1'b0;
            descriptor_valid_reg <= 1'b1;
            start_reg            <= 1'b1;
            endian_read_reg      <= descriptor_in_reg.buffer_9[0];
            endian_write_reg     <= descriptor_in_reg.buffer_9[1];
        end
        CTRL_CHAIN_SYNC_BUSY : begin
            ap_ready_reg         <= 1'b0;
            ap_done_reg          <= 1'b0;
            ap_idle_reg          <= 1'b0;
            descriptor_valid_reg <= 1'b1;
            start_reg            <= 1'b1;
            endian_read_reg      <= descriptor_in_reg.buffer_9[0];
            endian_write_reg     <= descriptor_in_reg.buffer_9[1];
        end
        CTRL_CHAIN_SYNC_DONE : begin
            ap_ready_reg         <= 1'b0;
            ap_done_reg          <= 1'b1;
            ap_idle_reg          <= 1'b1;
            descriptor_valid_reg <= 1'b0;
            start_reg            <= 1'b0;
            endian_read_reg      <= 1'b0;
            endian_write_reg     <= 1'b0;
        end
    endcase
end // always_ff @(posedge ap_clk)

endmodule : kernel_control
