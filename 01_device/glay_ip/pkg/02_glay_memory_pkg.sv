// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_memory_pkg.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


`timescale 1 ns / 1 ps

`include "iob_lib.vh"
`include "iob-cache.vh"

package GLAY_MEMORY_PKG;

import GLAY_GLOBALS_PKG::*;

// --------------------------------------------------------------------------------------
// FIFO Signals
// --------------------------------------------------------------------------------------

typedef struct packed {
  logic full        ;
  logic almost_full ;
  logic empty       ;
  logic almost_empty;
  logic valid       ;
  logic prog_full   ;
  logic prog_empty  ;
  logic wr_rst_busy ;
  logic rd_rst_busy ;
} FIFOStateSignalsOutput;

typedef struct packed {
  logic rd_en;
  logic wr_en;
} FIFOStateSignalsInput;

// --------------------------------------------------------------------------------------
//   Generic Memory request packet
// --------------------------------------------------------------------------------------

typedef enum int unsigned {
  CMD_INVALID,
  CMD_READ,
  CMD_WRITE,
  CMD_PREFETCH_READ,
  CMD_PREFETCH_WRITE
} command_type;

// --------------------------------------------------------------------------------------
//   Graph CSR structure types
// --------------------------------------------------------------------------------------

typedef enum int unsigned {
  STRUCT_INVALID,
  STRUCT_OUT_DEGREE,
  STRUCT_IN_DEGREE,
  STRUCT_EDGES_IDX,
  STRUCT_INV_OUT_DEGREE,
  STRUCT_INV_IN_DEGREE,
  STRUCT_INV_EDGES_IDX,
  STRUCT_AUXILIARY_1_DATA,
  STRUCT_AUXILIARY_2_DATA,
  STRUCT_KERNEL_SETUP
} structure_type;

// --------------------------------------------------------------------------------------
// Cache requests in GlayCacheRequestInterfaceOutput
// --------------------------------------------------------------------------------------

// SIZE = 516 bits
typedef struct packed {
  logic valid;
  `ifdef WORD_ADDR
    logic [CACHE_CTRL_CNT+CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W] addr;
  `else
    logic [CACHE_CTRL_CNT+CACHE_FRONTEND_ADDR_W-1:0] addr;
  `endif

  logic [CACHE_FRONTEND_DATA_W-1:0] wdata;
  logic [CACHE_FRONTEND_NBYTES-1:0] wstrb;
  `ifdef CTRL_IO
    //control-status io
    logic force_inv_in; //force 1'b0 if unused
    logic wtb_empty_in; //force 1'b1 if unused
  `endif
} GlayCacheRequestInterfaceInputPayload;


// SIZE = 644 - 6(CACHE_FRONTEND_BYTE_W) = 638 bits
typedef struct packed {
  logic                                 valid  ;
  GlayCacheRequestInterfaceInputPayload payload;
} GlayCacheRequestInterfaceInput;

// --------------------------------------------------------------------------------------
// Cache requests out GlayCacheRequestInterfaceOutput
// --------------------------------------------------------------------------------------

typedef struct packed {
  logic [CACHE_FRONTEND_DATA_W-1:0] rdata;
  logic                             ready;
  `ifdef CTRL_IO
    //control-status io
    logic force_inv_out;
    logic wtb_empty_out;
  `endif
} GlayCacheRequestInterfaceOutputPayload;


// SIZE = 516 bits
typedef struct packed {
  logic                                  valid  ;
  GlayCacheRequestInterfaceOutputPayload payload;
} GlayCacheRequestInterfaceOutput;

// --------------------------------------------------------------------------------------
//   Generic Memory request packet
// --------------------------------------------------------------------------------------

// SIZE = 167 bits
typedef struct packed{
  logic [             CU_ID_BITS-1:0] cu_id         ;
  logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] base_address  ;
  logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] address_offset;
  command_type                        cmd_type      ;
} MemoryRequestPacketPayload;

typedef struct packed{
  logic                      valid   ;
  MemoryRequestPacketPayload payload;
} MemoryRequestPacket;

// SIZE = 711 bits
typedef struct packed{
  logic [             CU_ID_BITS-1:0] cu_id         ;
  logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] base_address  ;
  logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] address_offset;
  logic [  CACHE_FRONTEND_DATA_W-1:0] data_field    ;
  command_type                        cmd_type      ;
  structure_type                      struct_type   ;
} MemoryResponsePacketPayload;

typedef struct packed{
  logic                       valid  ;
  MemoryResponsePacketPayload payload;
} MemoryResponsePacket;



endpackage