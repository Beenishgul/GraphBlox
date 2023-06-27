// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : demux_bus.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-01-11 23:47:45
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

module demux_bus #(
  parameter DATA_WIDTH = 32               ,
  parameter BUS_WIDTH  = 8                ,
  parameter SEL_WIDTH  = $clog2(BUS_WIDTH)
) (
  input  logic                  ap_clk                  ,
  input  logic                  areset                  ,
  input  logic [ SEL_WIDTH-1:0] sel_in                  ,
  input  logic [ BUS_WIDTH-1:0] data_in_valid           ,
  input  logic [DATA_WIDTH-1:0] data_in                 ,
  output logic [DATA_WIDTH-1:0] data_out [BUS_WIDTH-1:0],
  output logic [ BUS_WIDTH-1:0] data_out_valid
);

  logic [DATA_WIDTH-1:0] data_in_int                      ;
  logic [ SEL_WIDTH-1:0] sel_in_int                       ;
  logic [ BUS_WIDTH-1:0] data_in_valid_int                ;
  logic [DATA_WIDTH-1:0] data_out_int      [BUS_WIDTH-1:0];
  logic [ BUS_WIDTH-1:0] data_out_valid_int               ;
  logic [DATA_WIDTH-1:0] data_out_reg      [BUS_WIDTH-1:0];
  logic [ BUS_WIDTH-1:0] data_out_valid_reg               ;


// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
  // Use SCTLs in the latch logic.
  always_ff @(posedge ap_clk) begin
    if (areset) begin
      data_in_int       <= 0;
      sel_in_int        <= 0;
      data_in_valid_int <= 0;
    end else begin
      data_in_int       <= data_in;
      sel_in_int        <= sel_in;
      data_in_valid_int <= data_in_valid;
    end
  end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
  always_ff @(posedge ap_clk) begin
    if(areset) begin
      data_out_valid <= 0;
    end else begin
      data_out_valid <= data_out_valid_reg;
    end
  end

  always_ff @(posedge ap_clk) begin
    data_out <= data_out_reg;
  end

// --------------------------------------------------------------------------------------
// Demux Logic
// --------------------------------------------------------------------------------------
  // Use efficient data structures.
  assign data_out_reg       = data_out_int;
  assign data_out_valid_reg = data_out_valid_int;
  // Use parallelization in the demux logic.
  generate
    for (genvar i = 0; i < BUS_WIDTH; i++) begin : generate_demux
      assign data_out_valid_int[i] = (sel_in_int == i) & data_in_valid_int[i];
      assign data_out_int[i]       = data_in_int;
    end
  endgenerate

endmodule : demux_bus