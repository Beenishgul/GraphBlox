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
// File   : glay_transactions_counter.sv
// Create : 2023-01-23 16:17:05
// Revise : 2023-01-23 16:17:05
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1ns / 1ps
import GLAY_FUNCTIONS_PKG::*;

module glay_transactions_counter #(
  parameter integer               C_WIDTH = 4              ,
  parameter         [C_WIDTH-1:0] C_INIT  = {C_WIDTH{1'b0}}
) (
  input  logic               ap_clk    ,
  input  logic               ap_clken  ,
  input  logic               areset    ,
  input  logic               load      ,
  input  logic               incr      ,
  input  logic               decr      ,
  input  logic [C_WIDTH-1:0] load_value,
  output logic [C_WIDTH-1:0] count     ,
  output logic               is_zero
);

  // timeunit 1ps;
  // timeprecision 1ps;

/////////////////////////////////////////////////////////////////////////////
// Local Parameters
/////////////////////////////////////////////////////////////////////////////
  localparam [C_WIDTH-1:0] LP_ZERO = {C_WIDTH{1'b0}}         ;
  localparam [C_WIDTH-1:0] LP_ONE  = {{C_WIDTH-1{1'b0}},1'b1};
  localparam [C_WIDTH-1:0] LP_MAX  = {C_WIDTH{1'b1}}         ;

/////////////////////////////////////////////////////////////////////////////
// Variables
/////////////////////////////////////////////////////////////////////////////
  reg [C_WIDTH-1:0] count_r   = C_INIT             ;
  reg               is_zero_r = (C_INIT == LP_ZERO);

/////////////////////////////////////////////////////////////////////////////
// Begin RTL
/////////////////////////////////////////////////////////////////////////////
  assign count = count_r;

  always @(posedge ap_clk) begin
    if (areset) begin
      count_r <= C_INIT;
    end
    else if (ap_clken) begin
      if (load) begin
        count_r <= load_value;
      end
      else if (incr & ~decr) begin
        count_r <= count_r + 1'b1;
      end
      else if (~incr & decr) begin
        count_r <= count_r - 1'b1;
      end
      else
        count_r <= count_r;
    end
  end

  assign is_zero = is_zero_r;

  always @(posedge ap_clk) begin
    if (areset) begin
      is_zero_r <= (C_INIT == LP_ZERO);
    end
    else if (ap_clken) begin
      if (load) begin
        is_zero_r <= (load_value == LP_ZERO);
      end
      else begin
        is_zero_r <= incr ^ decr ? (decr && (count_r == LP_ONE)) || (incr && (count_r == LP_MAX)) : is_zero_r;
      end
    end
    else begin
      is_zero_r <= is_zero_r;
    end
  end

endmodule : glay_transactions_counter

