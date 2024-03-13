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
import PKG_MXX_AXI4_FE::*;
import PKG_DESCRIPTOR::*;
import PKG_CACHE::*;

// --------------------------------------------------------------------------------------
//   Generic Memory request type
// --------------------------------------------------------------------------------------
typedef logic [GLOBAL_BUFFER_SIZE_WIDTH_BITS-1:0]    type_memory_request_offset;
typedef logic [GLOBAL_OVERLAY_SIZE_WIDTH_BITS-1:0]   type_memory_response_offset;
typedef type_m00_axi4_fe_len                         type_memory_burst_length;

parameter TYPE_MEMORY_CMD_BITS = 6;
typedef enum logic[TYPE_MEMORY_CMD_BITS-1:0] {
  CMD_MEM_INVALID  = 1 << 0,
  CMD_MEM_READ     = 1 << 1,
  CMD_MEM_WRITE    = 1 << 2,
  CMD_STREAM_READ  = 1 << 3,
  CMD_STREAM_WRITE = 1 << 4,
  CMD_CACHE_FLUSH  = 1 << 5
} type_memory_cmd;

// --------------------------------------------------------------------------------------
//   Generic Engine request type
// --------------------------------------------------------------------------------------
parameter TYPE_ENGINE_CMD_BITS = 4;
typedef enum logic[TYPE_ENGINE_CMD_BITS-1:0] {
  CMD_ENGINE_INVALID = 1 << 0,
  CMD_ENGINE_DATA    = 1 << 1,
  CMD_ENGINE_PROGRAM = 1 << 2,
  CMD_CONTROL        = 1 << 3
} type_engine_cmd;

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
//   Generic set ops Type
// --------------------------------------------------------------------------------------
parameter TYPE_SET_OPERATION_BITS = 4;
typedef enum logic[TYPE_SET_OPERATION_BITS-1:0] {
  SET_NOP        = 1 << 0,
  SET_INTERSECT  = 1 << 1,
  SET_UNION      = 1 << 2,
  SET_COMPLIMENT = 1 << 3
} type_set_operation;

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
  logic                                  direction; // 0 - right, 1 left  1 bits
  logic [$clog2(M00_AXI4_FE_ADDR_W)-1:0] amount   ; // SIZE = clog2(offset) bits
} PacketDataAddressShift;

typedef struct packed{
  logic [   NUM_CHANNELS_WIDTH_BITS-1:0] id_channel  ; // SIZE = 8 bits  - up to 8 8 channels per cu
  logic [CU_BUFFER_COUNT_WIDTH_BITS-1:0] id_buffer   ; // SIZE = 8 bits  - up to 8 buffers in the descriptor
  type_memory_burst_length               burst_length;
  type_memory_request_offset             offset      ; // SIZE = clog2(4GB) bits
  PacketDataAddressShift                 shift       ; // SIZE = clog2(offset) bits + 1
} PacketRequestDataAddress;

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
  logic [M00_AXI4_FE_DATA_W-1:0] field;
} MemoryPacketData;

// --------------------------------------------------------------------------------------
// Request Memory Packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  MemoryPacketRouteAttributes route   ;
  PacketRequestDataAddress    address ;
  MemoryPacketType            subclass;
} MemoryPacketRequestMeta;

typedef struct packed{
  MemoryPacketRequestMeta meta;
  MemoryPacketData        data;
} MemoryPacketRequestPayload;

typedef struct packed{
  logic                      valid  ;
  MemoryPacketRequestPayload payload;
} MemoryPacketRequest;

// --------------------------------------------------------------------------------------
// Response Memory Packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  logic [CU_BUFFER_COUNT_WIDTH_BITS-1:0] id_buffer; // SIZE = 8 bits  - up to 8 buffers in the descriptor
  type_memory_response_offset            offset   ; // SIZE = clog2(4GB) bits
} PacketResponseDataAddress;

typedef struct packed{
  MemoryPacketRouteAttributes route  ;
  PacketResponseDataAddress   address;
} MemoryPacketResponseMeta;

typedef struct packed{
  MemoryPacketResponseMeta meta;
  MemoryPacketData         data;
} MemoryPacketResponsePayload;

typedef struct packed{
  logic                       valid  ;
  MemoryPacketResponsePayload payload;
} MemoryPacketResponse;

// --------------------------------------------------------------------------------------
// Generic Engine Packet
// --------------------------------------------------------------------------------------
typedef struct packed{
  PacketRouteAddress                           packet_destination;
  PacketRouteAddress                           sequence_source   ;
  type_sequence_state                          sequence_state    ;
  logic [CU_PACKET_SEQUENCE_ID_WIDTH_BITS-1:0] sequence_id       ;
  logic [          NUM_BUNDLES_WIDTH_BITS-1:0] hops              ;
} EnginePacketRouteAttributes;

typedef struct packed{
  type_engine_cmd cmd;
} EnginePacketType;

typedef struct packed{
  EnginePacketRouteAttributes route;
} EnginePacketMeta;

typedef struct packed{
  EnginePacketRouteAttributes route   ;
  PacketRequestDataAddress    address ;
  MemoryPacketType            subclass;
} EnginePacketMetaFull;

parameter ENGINE_PACKET_DATA_NUM_FIELDS = 5;
typedef struct packed{
  logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][M00_AXI4_FE_DATA_W-1:0] field;
} EnginePacketData;

typedef struct packed{
  EnginePacketMeta meta;
  EnginePacketData data;
} EnginePacketPayload;

typedef struct packed{
  EnginePacketMetaFull meta;
  EnginePacketData     data;
} EnginePacketFullPayload;

typedef struct packed{
  logic               valid  ;
  EnginePacketPayload payload;
} EnginePacket;

typedef struct packed{
  logic                   valid  ;
  EnginePacketFullPayload payload;
} EnginePacketFull;

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
  logic                          valid;
  logic [M00_AXI4_FE_ADDR_W-1:0] addr ;
  logic [M00_AXI4_FE_DATA_W-1:0] wdata;
  logic [M00_AXI4_FE_STRB_W-1:0] wstrb;
} CacheRequestIOB;

typedef struct packed {
  CacheRequestIOB         iob ;
  MemoryPacketRequestMeta meta;
  MemoryPacketData        data;
} CacheRequestPayload;

typedef struct packed {
  logic               valid  ;
  CacheRequestPayload payload;
} CacheRequest;

// --------------------------------------------------------------------------------------
// Cache response out CacheResponse
// --------------------------------------------------------------------------------------
typedef struct packed {
  logic                          valid;
  logic                          ready;
  logic [M00_AXI4_FE_DATA_W-1:0] rdata;
} CacheResponseIOB;

typedef struct packed {
  CacheResponseIOB        iob ;
  MemoryPacketRequestMeta meta;
  MemoryPacketData        data;
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
function FIFOStateSignalsOutput map_internal_dual_fifo_signals_to_output_internal (input FIFOStateSignalsOutInternal internal_fifo_1, input FIFOStateSignalsOutInternal internal_fifo_2);

  FIFOStateSignalsOutput output_fifo;

  output_fifo.prog_full = internal_fifo_1.prog_full | internal_fifo_2.prog_full;
  output_fifo.empty     = internal_fifo_1.empty & internal_fifo_2.empty;

  return output_fifo;
endfunction : map_internal_dual_fifo_signals_to_output_internal

// --------------------------------------------------------------------------------------

function FIFOStateSignalsOutput map_internal_dual_fifo_signals_to_output_external (input FIFOStateSignalsOutput internal_fifo_1, input FIFOStateSignalsOutput internal_fifo_2);

  FIFOStateSignalsOutput output_fifo;

  output_fifo.prog_full = internal_fifo_1.prog_full | internal_fifo_2.prog_full;
  output_fifo.empty     = internal_fifo_1.empty & internal_fifo_2.empty;

  return output_fifo;
endfunction : map_internal_dual_fifo_signals_to_output_external

// --------------------------------------------------------------------------------------
// Memory Request Packet <-> Cache
// --------------------------------------------------------------------------------------
function CacheRequestPayload  map_MemoryRequestPacket_to_CacheRequest (input MemoryPacketRequestPayload input_packet, input KernelDescriptorPayload  descriptor, input input_packet_valid);

  CacheRequestPayload output_packet;
  logic [M00_AXI4_FE_ADDR_W-1:0] address_base;

  case (input_packet.meta.address.id_buffer)
    (1 << 0) : begin
      address_base = descriptor.buffer_1;
    end
    (1 << 1) : begin
      address_base = descriptor.buffer_2;
    end
    (1 << 2) : begin
      address_base = descriptor.buffer_3;
    end
    (1 << 3) : begin
      address_base = descriptor.buffer_4;
    end
    (1 << 4) : begin
      address_base = descriptor.buffer_5;
    end
    (1 << 5) : begin
      address_base = descriptor.buffer_6;
    end
    (1 << 6) : begin
      address_base = descriptor.buffer_7;
    end
    (1 << 7) : begin
      address_base = descriptor.buffer_8;
    end
    default : begin
      address_base = descriptor.buffer_0;
    end
  endcase

  output_packet.meta      = input_packet.meta;
  output_packet.data      = input_packet.data;
  output_packet.iob.valid = input_packet_valid;
  // output_packet.iob.addr  = address_base + (input_packet.meta.address.offset << input_packet.meta.address.shift.amount);
  // output_packet.iob.addr  = address_base + input_packet.meta.address.offset;
  output_packet.iob.addr  = address_base + input_packet.meta.address.offset;
  output_packet.iob.wdata = input_packet.data.field;

  case (input_packet.meta.subclass.cmd)
    CMD_MEM_WRITE : begin
      output_packet.iob.wstrb = {CACHE_FRONTEND_NBYTES{1'b1}};
    end
    default : begin
      output_packet.iob.wstrb = 0;
    end
  endcase

  return output_packet;
endfunction : map_MemoryRequestPacket_to_CacheRequest
// --------------------------------------------------------------------------------------
function MemoryPacketResponsePayload map_CacheResponse_to_MemoryResponsePacket (input CacheRequestPayload input_packet_req, input CacheResponsePayload input_packet_resp);

  MemoryPacketResponsePayload output_packet;

  output_packet.meta.route.packet_source  = input_packet_req.meta.route.packet_source ;
  output_packet.meta.address.id_buffer   = input_packet_req.meta.address.id_buffer;
  if(input_packet_req.meta.address.shift.direction) begin
    output_packet.meta.address.offset       = (input_packet_req.meta.address.offset >> input_packet_req.meta.address.shift.amount);
  end else begin
    output_packet.meta.address.offset       = (input_packet_req.meta.address.offset << input_packet_req.meta.address.shift.amount);
  end
  output_packet.data.field                = input_packet_resp.iob.rdata;

  return output_packet;
endfunction : map_CacheResponse_to_MemoryResponsePacket

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
function MemoryPacketResponsePayload  map_MemoryRequestPacket_to_MemoryResponsePacket (input MemoryPacketRequestPayload input_packet);

  MemoryPacketResponsePayload  output_packet;

  output_packet.meta.route.packet_source  = input_packet.meta.route.packet_source ;
  output_packet.meta.address.offset       = input_packet.meta.address.offset;
  output_packet.meta.address.id_buffer       = input_packet.meta.address.id_buffer;
  // output_packet.meta.address.offset       = input_packet.meta.address.offset >> input_packet.meta.address.shift.amount;
  output_packet.data.field                = input_packet.data.field;

  return output_packet;
endfunction : map_MemoryRequestPacket_to_MemoryResponsePacket
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
function MemoryPacketRequestPayload  map_EnginePacket_to_MemoryRequestPacket (input EnginePacketFullPayload  input_packet, input PacketRouteAddress packet_source);

  MemoryPacketRequestPayload  output_packet;

  output_packet.meta.route.packet_source  = packet_source;
  output_packet.meta.address              = input_packet.meta.address;
  output_packet.meta.subclass.cmd         = input_packet.meta.subclass.cmd;
  output_packet.data.field                = input_packet.data.field[0];

  return output_packet;
endfunction : map_EnginePacket_to_MemoryRequestPacket
// --------------------------------------------------------------------------------------
function EnginePacketPayload  map_EnginePacketFull_to_EnginePacket (input EnginePacketFullPayload  input_packet);

  EnginePacketPayload  output_packet;

  output_packet.meta.route     = input_packet.meta.route;
  output_packet.data           = input_packet.data;

  return output_packet;
endfunction : map_EnginePacketFull_to_EnginePacket
// --------------------------------------------------------------------------------------
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
