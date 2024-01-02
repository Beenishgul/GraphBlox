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
import PKG_DESCRIPTOR::*;
import PKG_CACHE::*;

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
parameter TYPE_MEMORY_CMD_BITS = 9;
typedef enum logic[TYPE_MEMORY_CMD_BITS-1:0] {
  CMD_INVALID        = 1 << 0,
  CMD_MEM_READ       = 1 << 1,
  CMD_MEM_WRITE      = 1 << 2,
  CMD_MEM_RESPONSE   = 1 << 3,
  CMD_MEM_PROGRAM    = 1 << 4,
  CMD_MEM_FLUSH      = 1 << 5,
  CMD_ENGINE_DATA    = 1 << 6,
  CMD_ENGINE_PROGRAM = 1 << 7,
  CMD_CONTROL        = 1 << 8
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
//   Generic ALU ops Type
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
// SEQUENCE_STATE
// --------------------------------------------------------------------------------------
parameter TYPE_SEQUENCE_STATE_BITS = 4;
typedef enum logic[TYPE_SEQUENCE_STATE_BITS-1:0] {
  SEQUENCE_INVALID = 1 << 0, // 0001
  SEQUENCE_RUNNING = 1 << 1, // 0010
  SEQUENCE_DONE    = 1 << 2, // 0100
  SEQUENCE_BREAK   = 1 << 3  // 1000
} type_sequence_state;

// --------------------------------------------------------------------------------------
// Generic sequence_state
// --------------------------------------------------------------------------------------
typedef struct packed{
  logic [    NUM_CUS_WIDTH_BITS-1:0] id_cu    ; // SIZE = 8 bits  - up to 8 vertex cu - pending
  logic [NUM_BUNDLES_WIDTH_BITS-1:0] id_bundle; // SIZE = 8 bits  - up to 8 bundles
  logic [  NUM_LANES_WIDTH_BITS-1:0] id_lane  ; // SIZE = 8 bits  - up to 8 lanes per bundle
  logic [NUM_ENGINES_WIDTH_BITS-1:0] id_engine; // SIZE = 8 bits  - up to 8 engines per bundle
  logic [NUM_MODULES_WIDTH_BITS-1:0] id_module; // SIZE = 8 bits  - up to 8 modules per engine
} PacketRouteAddress;

typedef struct packed{
  logic                                direction; // 0 - right, 1 left  1 bits
  logic [$clog2(M_AXI4_FE_ADDR_W)-1:0] amount   ; // SIZE = clog2(offset) bits
} PacketDataAddressShift;

typedef struct packed{
  logic [CU_BUFFER_COUNT_WIDTH_BITS-1:0] id_buffer; // SIZE = 8 bits  - up to 8 buffers in the descriptor
  logic [          M_AXI4_FE_DATA_W-1:0] offset   ; // SIZE = clog2(4GB) bits
  PacketDataAddressShift                 shift    ; // SIZE = clog2(offset) bits + 1
} PacketDataAddress;

// --------------------------------------------------------------------------------------
// Generic Engine Packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  PacketRouteAddress                           packet_source     ;
  PacketRouteAddress                           packet_destination;
  PacketRouteAddress                           sequence_source   ;
  type_sequence_state                          sequence_state    ;
  logic [CU_PACKET_SEQUENCE_ID_WIDTH_BITS-1:0] sequence_id       ;
  logic [          NUM_BUNDLES_WIDTH_BITS-1:0] hops              ;
} EnginePacketRouteAttributes;

typedef struct packed{
  type_memory_cmd cmd;
} EnginePacketType;

typedef struct packed{
  EnginePacketRouteAttributes route   ;
  PacketDataAddress           address ;
  EnginePacketType            subclass;
} EnginePacketMeta;

parameter ENGINE_PACKET_DATA_NUM_FIELDS = 4;
typedef struct packed{
  logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][M_AXI4_FE_DATA_W-1:0] field;
} EnginePacketData;

typedef struct packed{
  EnginePacketMeta meta;
  EnginePacketData data;
} EnginePacketPayload;

typedef struct packed{
  logic               valid  ;
  EnginePacketPayload payload;
} EnginePacket;

// --------------------------------------------------------------------------------------
// Generic Memory Packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  type_memory_cmd cmd; // SIZE = 5 bits
} MemoryPacketType;

typedef struct packed{
  PacketRouteAddress packet_source;
} MemoryPacketRouteAttributes;

typedef struct packed{
  MemoryPacketRouteAttributes route   ;
  PacketDataAddress           address ;
  MemoryPacketType            subclass;
} MemoryPacketMeta;

typedef struct packed{
  logic [M_AXI4_FE_DATA_W-1:0] field;
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
  PacketRouteAddress                           packet_destination;
  type_sequence_state                          sequence_state    ;
  logic [CU_PACKET_SEQUENCE_ID_WIDTH_BITS-1:0] sequence_id       ;
} ControlPacketRouteAttributes;

typedef struct packed{
  ControlPacketRouteAttributes route;
} ControlPacketMeta;

typedef struct packed{
  ControlPacketMeta meta;
} ControlPacketPayload;

typedef struct packed{
  logic                valid  ;
  ControlPacketPayload payload;
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

// --------------------------------------------------------------------------------------
// functions
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
function FIFOStateSignalsOutput map_internal_fifo_signals_to_output (input FIFOStateSignalsOutInternal internal_fifo);

  FIFOStateSignalsOutput output_fifo;

  output_fifo.prog_full = internal_fifo.prog_full;
  output_fifo.empty     = internal_fifo.empty;

  return output_fifo;
endfunction : map_internal_fifo_signals_to_output
// --------------------------------------------------------------------------------------
// Memory Request Packet <-> Cache
// --------------------------------------------------------------------------------------
function CacheRequest map_MemoryRequestPacket_to_CacheRequest (input MemoryPacket input_packet, input KernelDescriptor  descriptor);

  CacheRequest output_packet;
  logic [M_AXI4_FE_ADDR_W-1:0] address_base;

  if(input_packet.valid & descriptor.valid) begin
    case (input_packet.payload.meta.address.id_buffer)
      (1 << 0) : begin
        address_base = descriptor.payload.buffer_1;
      end
      (1 << 1) : begin
        address_base = descriptor.payload.buffer_2;
      end
      (1 << 2) : begin
        address_base = descriptor.payload.buffer_3;
      end
      (1 << 3) : begin
        address_base = descriptor.payload.buffer_4;
      end
      (1 << 4) : begin
        address_base = descriptor.payload.buffer_5;
      end
      (1 << 5) : begin
        address_base = descriptor.payload.buffer_6;
      end
      (1 << 6) : begin
        address_base = descriptor.payload.buffer_7;
      end
      (1 << 7) : begin
        address_base = descriptor.payload.buffer_8;
      end
      default : begin
        address_base = descriptor.payload.buffer_0;
      end
    endcase
  end

  output_packet.valid             = input_packet.valid;
  output_packet.payload.meta      = input_packet.payload.meta;
  output_packet.payload.data      = input_packet.payload.data;
  output_packet.payload.iob.valid = input_packet.valid;
  output_packet.payload.iob.addr  = address_base + input_packet.payload.meta.address.offset;
  output_packet.payload.iob.wdata = input_packet.payload.data.field;

  case (input_packet.payload.meta.subclass.cmd)
    CMD_MEM_WRITE : begin
      output_packet.payload.iob.wstrb = {CACHE_FRONTEND_NBYTES{1'b1}};
    end
    default : begin
      output_packet.payload.iob.wstrb = 0;
    end
  endcase

  return output_packet;
endfunction : map_MemoryRequestPacket_to_CacheRequest
// --------------------------------------------------------------------------------------
function MemoryPacketPayload map_CacheResponse_to_MemoryResponsePacket (input CacheResponsePayload input_packet);

  MemoryPacketPayload output_packet;

  output_packet.meta          = input_packet.meta;
  output_packet.data.field    = input_packet.iob.rdata;

  return output_packet;
endfunction : map_CacheResponse_to_MemoryResponsePacket
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
function MemoryPacketPayload  map_EnginePacket_to_MemoryRequestPacket (input EnginePacketPayload  input_packet);

  MemoryPacketPayload  output_packet;

  output_packet.meta.route.packet_source  = input_packet.meta.route.sequence_source;
  output_packet.meta.address              = input_packet.meta.address;
  output_packet.meta.subclass.cmd         = input_packet.meta.subclass.cmd;
  output_packet.data.field                = input_packet.data.field[0];

  return output_packet;
endfunction : map_EnginePacket_to_MemoryRequestPacket
// --------------------------------------------------------------------------------------
function EnginePacketData map_MemoryResponsePacketData_to_EnginePacketData (input MemoryPacketData input_packet, input EnginePacketData pending_packet);

  EnginePacketData output_packet;

  output_packet.field[0] = input_packet.field;
  for (int i = 1; i<ENGINE_PACKET_DATA_NUM_FIELDS; i++) begin
    output_packet.field[i] = pending_packet.field[i-1];
  end

  return output_packet;
endfunction : map_MemoryResponsePacketData_to_EnginePacketData
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
function ControlPacketPayload  map_EnginePacket_to_ControlPacket (input EnginePacketPayload  input_packet);

  ControlPacketPayload  output_packet;

  output_packet.meta.route.packet_destination  = input_packet.meta.route.sequence_source;
  output_packet.meta.route.sequence_state      = input_packet.meta.route.sequence_state;
  output_packet.meta.route.sequence_id         = input_packet.meta.route.sequence_id;

  return output_packet;
endfunction : map_EnginePacket_to_ControlPacket

endpackage
