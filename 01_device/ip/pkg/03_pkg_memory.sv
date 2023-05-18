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
parameter TYPE_KERNEL_CMD_BITS = 6;
typedef enum logic[TYPE_KERNEL_CMD_BITS-1:0] {
  CMD_INVALID,
  CMD_READ,
  CMD_WRITE,
  CMD_PREFETCH_READ,
  CMD_PREFETCH_WRITE,
  CMD_CONFIGURE
} type_memory_cmd;

// --------------------------------------------------------------------------------------
//   Generic Memory Operand location
// --------------------------------------------------------------------------------------
parameter TYPE_ENGINE_OPERAND_BITS = 8;
typedef enum logic[TYPE_ENGINE_OPERAND_BITS-1:0] {
  OP_LOCATION_0,
  OP_LOCATION_1,
  OP_LOCATION_2,
  OP_LOCATION_3,
  OP_LOCATION_4,
  OP_LOCATION_5,
  OP_LOCATION_6,
  OP_LOCATION_7
} type_engine_operand;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
parameter TYPE_FILTER_OPERATION_BITS = 7;
typedef enum logic[TYPE_FILTER_OPERATION_BITS-1:0]{
  FILTER_NOP,
  FILTER_GT,
  FILTER_LT,
  FILTER_EQ,
  FILTER_GT_EQ,
  FILTER_LT_EQ,
  FILTER_NOT_EQ
} type_filter_operation;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
parameter TYPE_ALU_OPERATION_BITS = 6;
typedef enum logic[TYPE_ALU_OPERATION_BITS-1:0] {
  ALU_NOP,
  ALU_ADD,
  ALU_SUB,
  ALU_MUL,
  ALU_ACC,
  ALU_DIV
} type_ALU_operation;

// --------------------------------------------------------------------------------------
//   Graph CSR structure types
// --------------------------------------------------------------------------------------
parameter TYPE_DATA_STRUCTURE_BITS = 13;
typedef enum logic[TYPE_DATA_STRUCTURE_BITS-1:0]{
  STRUCT_INVALID,
  STRUCT_OUT_DEGREE,
  STRUCT_IN_DEGREE,
  STRUCT_EDGES_IDX,
  STRUCT_INV_OUT_DEGREE,
  STRUCT_INV_IN_DEGREE,
  STRUCT_INV_EDGES_IDX,
  STRUCT_AUXILIARY_1_DATA,
  STRUCT_AUXILIARY_2_DATA,
  STRUCT_STRIDE_INDEX,
  STRUCT_KERNEL_SETUP,
  STRUCT_ENGINE_SETUP,
  STRUCT_VERTEX_CU
} type_data_structure;

// --------------------------------------------------------------------------------------
//   Generic Memory request packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  logic [ CU_VERTEX_WIDTH_BITS-1:0] id_vertex     ; // SIZE = 4 bits
  logic [ CU_BUNDLE_WIDTH_BITS-1:0] id_bundle     ; // SIZE = 2 bits
  logic [ CU_ENGINE_WIDTH_BITS-1:0] id_engine     ; // SIZE = 3 bits
  logic [CACHE_FRONTEND_ADDR_W-1:0] address_base  ; // SIZE = 64 bits
  logic [CACHE_FRONTEND_DATA_W-1:0] address_offset; // SIZE = 64 bits
  type_memory_cmd                   type_cmd      ; // SIZE = 5 bits
  type_data_structure               type_struct   ; // SIZE = 12 bits
  type_engine_operand               type_operand  ; // SIZE = 6 bits
  type_filter_operation             type_filter   ; // SIZE = 6 bits
  type_ALU_operation                type_ALU      ; // SIZE = 6 bits
} MemoryPacketMeta;

typedef struct packed{
  logic [CACHE_FRONTEND_DATA_W-1:0] field;
} MemoryPacketData;

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
  logic                             ready;
  logic [CACHE_FRONTEND_DATA_W-1:0] rdata;
} CacheResponseIOB;

typedef struct packed {
  CacheResponseIOB iob ;
  MemoryPacketMeta meta;
} CacheResponsePayload;

typedef struct packed {
  logic                valid  ;
  CacheResponsePayload payload;
} CacheResponse;

// --------------------------------------------------------------------------------------
//   Cache Requests state machine
// --------------------------------------------------------------------------------------
typedef enum logic[6:0] {
  CACHE_REQUEST_GEN_RESET,
  CACHE_REQUEST_GEN_IDLE,
  CACHE_REQUEST_GEN_SEND_S1,
  CACHE_REQUEST_GEN_SEND_S2,
  CACHE_REQUEST_GEN_BUSY,
  CACHE_REQUEST_GEN_READY,
  CACHE_REQUEST_GEN_DONE
} cache_generator_request_state;


endpackage
