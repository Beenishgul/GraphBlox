// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_MEMORY.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


`timescale 1 ns / 1 ps

`include "iob_lib.vh"
`include "iob-cache.vh"

package PKG_MEMORY;

import PKG_GLOBALS::*;
import PKG_CACHE::*;

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
//   Generic Memory Operand location
// --------------------------------------------------------------------------------------
typedef enum int unsigned {
  OP_LOCATION_0,
  OP_LOCATION_1,
  OP_LOCATION_2,
  OP_LOCATION_3,
  OP_LOCATION_4,
  OP_LOCATION_5,
  OP_LOCATION_6,
  OP_LOCATION_7,
  OP_LOCATION_8
} operand_location;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
typedef enum int unsigned {
  FILTER_NOP,
  FILTER_GT,
  FILTER_LT,
  FILTER_EQ,
  FILTER_GT_EQ,
  FILTER_LT_EQ,
  FILTER_NOT_EQ
} filter_operation;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
typedef enum int unsigned {
  ALU_NOP,
  ALU_ADD,
  ALU_SUB,
  ALU_MUL,
  ALU_ACC,
  ALU_DIV
} ALU_operation;

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
//   Generic Memory request packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  logic [       CU_ENGINE_ID_BITS-1:0] cu_engine_id_x; // SIZE = 6 bits
  logic [       CU_ENGINE_ID_BITS-1:0] cu_engine_id_y; // SIZE = 6 bits
  logic [CACHE_FRONTEND_ADDR_W-1:0] base_address  ; // SIZE = 64 bits
  logic [CACHE_FRONTEND_DATA_W-1:0] address_offset; // SIZE = 64 bits
  command_type                         cmd_type      ; // SIZE = 32 bits
  structure_type                       struct_type   ; // SIZE = 32 bits
  operand_location                     operand_loc   ; // SIZE = 32 bits
  filter_operation                     filter_op     ; // SIZE = 32 bits
  ALU_operation                        ALU_op        ; // SIZE = 32 bits
} MemoryPacketMeta;

typedef struct packed{
  logic [CACHE_FRONTEND_DATA_W-1:0] field; // SIZE = 512 bits
} MemoryPacketData;// SIZE = 512 bits

typedef struct packed{
  MemoryPacketMeta meta;
  MemoryPacketData data;
} MemoryPacketPayload;

typedef struct packed{
  logic               valid  ;
  MemoryPacketPayload payload;
} MemoryPacket;

// --------------------------------------------------------------------------------------
// Cache Control Signals
// --------------------------------------------------------------------------------------
typedef struct packed {
  logic force_inv; //force 1'b0 if unused
  logic wtb_empty; //force 1'b1 if unused
} CacheControlIOBInput;

typedef struct packed {
  logic force_inv;
  logic wtb_empty;
} CacheControlIOBOutput;

typedef struct packed {
  CacheControlIOBInput  in ; //force 1'b0 if unused
  CacheControlIOBOutput out;
} CacheControlIOB;

// --------------------------------------------------------------------------------------
// Cache requests in CacheRequest
// --------------------------------------------------------------------------------------
typedef struct packed {
  logic valid;
  `ifdef WORD_ADDR
    logic [CACHE_CTRL_CNT+CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W] addr;
  `else
    logic [CACHE_CTRL_CNT+CACHE_FRONTEND_ADDR_W-1:0] addr;
  `endif
  logic [CACHE_FRONTEND_DATA_W-1:0] wdata;
  logic [CACHE_FRONTEND_NBYTES-1:0] wstrb;
} CacheRequestIOB;

typedef struct packed {
  CacheRequestIOB  iob ;
  CacheControlIOB  ctrl;
  MemoryPacketMeta meta;
} CacheRequestPayload;

typedef struct packed {
  logic               valid  ;
  CacheRequestPayload payload;
} CacheRequest;

// --------------------------------------------------------------------------------------
// Cache response out CacheResponse
// --------------------------------------------------------------------------------------
typedef struct packed {
  logic                                ready;
  logic [CACHE_FRONTEND_DATA_W-1:0] rdata;
} CacheResponseIOB;

typedef struct packed {
  CacheResponseIOB iob ;
  CacheControlIOB  ctrl;
  MemoryPacketMeta meta;
} CacheResponsePayload;

typedef struct packed {
  logic                valid  ;
  CacheResponsePayload payload;
} CacheResponse;

// --------------------------------------------------------------------------------------
//   Cache Requests state machine
// --------------------------------------------------------------------------------------
typedef enum int unsigned {
  CACHE_REQUEST_GEN_RESET,
  CACHE_REQUEST_GEN_IDLE,
  CACHE_REQUEST_GEN_SEND_S1,
  CACHE_REQUEST_GEN_SEND_S2,
  CACHE_REQUEST_GEN_BUSY,
  CACHE_REQUEST_GEN_READY,
  CACHE_REQUEST_GEN_DONE
} cache_generator_request_state;


endpackage
