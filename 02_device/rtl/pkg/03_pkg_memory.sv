// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : 03_pkg_memory.sv
// Create : 2022-11-29 16:14:59
// Revise : 2023-08-26 00:27:04
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------


`include "global_timescale.vh"

// `include "iob_lib.vh"
// `include "iob-cache.vh"

package PKG_MEMORY;

import PKG_GLOBALS::*;
import PKG_AXI4_FE::*;

// --------------------------------------------------------------------------------------
// FIFO Signals
// --------------------------------------------------------------------------------------
typedef struct packed {
  logic empty    ;
  logic prog_full;
} FIFOStateSignalsOutput;

typedef struct packed {
  logic full       ;
  logic empty      ;
  logic valid      ;
  logic prog_full  ;
  logic wr_rst_busy;
  logic rd_rst_busy;
} FIFOStateSignalsOutInternal;

typedef struct packed {
  logic rd_en;
} FIFOStateSignalsInput;

typedef struct packed {
  logic rd_en;
  logic wr_en;
} FIFOStateSignalsInputInternal;

// --------------------------------------------------------------------------------------
//   Generic Memory request packet
// --------------------------------------------------------------------------------------
parameter TYPE_MEMORY_CMD_BITS = 7;
typedef enum logic[TYPE_MEMORY_CMD_BITS-1:0] {
  CMD_INVALID       = 1 << 0,
  CMD_MEM_READ      = 1 << 1,
  CMD_MEM_WRITE     = 1 << 2,
  CMD_MEM_RESPONSE  = 1 << 3,
  CMD_MEM_CONFIGURE = 1 << 4,
  CMD_ENGINE        = 1 << 5,
  CMD_CONTROL       = 1 << 6
} type_memory_cmd;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
parameter TYPE_FILTER_OPERATION_BITS = 9;
typedef enum logic[TYPE_FILTER_OPERATION_BITS-1:0]{
  FILTER_NOP         = 1 << 0,
  FILTER_GT          = 1 << 1,
  FILTER_LT          = 1 << 2,
  FILTER_EQ          = 1 << 3,
  FILTER_NOT_EQ      = 1 << 4,
  FILTER_GT_TERN     = 1 << 5,
  FILTER_LT_TERN     = 1 << 6,
  FILTER_EQ_TERN     = 1 << 7,
  FILTER_NOT_EQ_TERN = 1 << 8
} type_filter_operation;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
parameter TYPE_ALU_OPERATION_BITS = 6;
typedef enum logic[TYPE_ALU_OPERATION_BITS-1:0] {
  ALU_NOP = 1 << 0,
  ALU_ADD = 1 << 1,
  ALU_SUB = 1 << 2,
  ALU_MUL = 1 << 3,
  ALU_ACC = 1 << 4,
  ALU_DIV = 1 << 5
} type_ALU_operation;

// --------------------------------------------------------------------------------------
//   Graph CSR structure types
// --------------------------------------------------------------------------------------
parameter TYPE_DATA_STRUCTURE_BITS = 6;
typedef enum logic[TYPE_DATA_STRUCTURE_BITS-1:0] {
  STRUCT_INVALID      = 1 << 0,
  STRUCT_CU_DATA      = 1 << 1,
  STRUCT_ENGINE_DATA  = 1 << 2,
  STRUCT_CU_SETUP     = 1 << 3,
  STRUCT_ENGINE_SETUP = 1 << 4,
  STRUCT_CU_FLUSH     = 1 << 5
} type_data_buffer;

// --------------------------------------------------------------------------------------
//   Graph CSR structure types
// --------------------------------------------------------------------------------------
parameter TYPE_SEQUENCE_STATE_BITS = 4;
typedef enum logic[TYPE_SEQUENCE_STATE_BITS-1:0] {
  SEQUENCE_INVALID = 1 << 0, // 0001
  SEQUENCE_RUNNING = 1 << 1, // 0010
  SEQUENCE_DONE    = 1 << 2, // 0100
  SEQUENCE_BREAK   = 1 << 3  // 1000
} type_sequence_state;

// --------------------------------------------------------------------------------------
//   Generic Memory request packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  logic [CU_KERNEL_COUNT_WIDTH_BITS-1:0] id_cu    ; // SIZE = 8 bits  - up to 8 vertex cu - pending
  logic [CU_BUNDLE_COUNT_WIDTH_BITS-1:0] id_bundle; // SIZE = 8 bits  - up to 8 bundles
  logic [  CU_LANE_COUNT_WIDTH_BITS-1:0] id_lane  ; // SIZE = 8 bits  - up to 8 lanes per bundle
  logic [CU_ENGINE_COUNT_WIDTH_BITS-1:0] id_engine; // SIZE = 8 bits  - up to 8 engines per bundle
  logic [CU_MODULE_COUNT_WIDTH_BITS-1:0] id_module; // SIZE = 8 bits  - up to 8 modules per engine
} MemoryPacketArbitrate;

typedef struct packed{
  MemoryPacketArbitrate                   from     ;
  MemoryPacketArbitrate                   to       ;
  MemoryPacketArbitrate                   seq_src  ;
  type_sequence_state                     seq_state;
  logic [CU_PACKET_SEQ_ID_WIDTH_BITS-1:0] seq_id   ;
  logic [ CU_BUNDLE_COUNT_WIDTH_BITS-1:0] hops     ;
} MemoryPacketRoute;

typedef struct packed{
  logic                                direction; // 0 - right, 1 left
  logic [$clog2(M_AXI4_FE_ADDR_W)-1:0] amount   ; // SIZE = 64 bits
} MemoryPacketAddressShift;

typedef struct packed{
  logic [CU_BUFFER_COUNT_WIDTH_BITS-1:0] id_buffer; // SIZE = 8 bits  - up to 8 buffers in the descriptor
  logic [          M_AXI4_FE_DATA_W-1:0] offset   ; // SIZE = 64 bits
  MemoryPacketAddressShift               shift    ; // SIZE = 64 bits
} MemoryPacketAddress;

typedef struct packed{
  type_memory_cmd  cmd   ; // SIZE = 5 bits
  type_data_buffer buffer; // SIZE = 12 bits
} MemoryPacketType;

typedef struct packed{
  MemoryPacketRoute   route   ;
  MemoryPacketAddress address ;
  MemoryPacketType    subclass;
} MemoryPacketMeta;

parameter NUM_FIELDS_MEMORYPACKETDATA = 4;
typedef struct packed{
  logic [NUM_FIELDS_MEMORYPACKETDATA-1:0][M_AXI4_FE_DATA_W-1:0] field;
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
//   Generic Control packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  MemoryPacketRoute route   ;
  MemoryPacketType  subclass;
} ControlPacketPayload;

typedef struct packed{
  logic               valid  ;
  MemoryPacketPayload payload;
} ControlPacket;

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
  logic                        valid;
  logic [M_AXI4_FE_ADDR_W-1:0] addr ;
  logic [M_AXI4_FE_DATA_W-1:0] wdata;
  logic [M_AXI4_FE_STRB_W-1:0] wstrb;
} CacheRequestIOB;

typedef struct packed {
  CacheRequestIOB  iob ;
  MemoryPacketMeta meta;
  MemoryPacketData data;
} CacheRequestPayload;

typedef struct packed {
  logic               valid  ;
  CacheRequestPayload payload;
} CacheRequest;

// --------------------------------------------------------------------------------------
// Cache response out CacheResponse
// --------------------------------------------------------------------------------------
typedef struct packed {
  logic                        valid;
  logic                        ready;
  logic [M_AXI4_FE_DATA_W-1:0] rdata;
} CacheResponseIOB;

typedef struct packed {
  CacheResponseIOB iob ;
  MemoryPacketMeta meta;
  MemoryPacketData data;
} CacheResponsePayload;

typedef struct packed {
  logic                valid  ;
  CacheResponsePayload payload;
} CacheResponse;

function FIFOStateSignalsOutput map_internal_fifo_signals_to_output (FIFOStateSignalsOutInternal internal_fifo);

  FIFOStateSignalsOutput output_fifo;

  output_fifo.prog_full = internal_fifo.prog_full;
  output_fifo.empty     = internal_fifo.empty;

  return output_fifo;
endfunction : map_internal_fifo_signals_to_output

endpackage
