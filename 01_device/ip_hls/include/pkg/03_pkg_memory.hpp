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
// Revise : 2023-06-19 00:25:39
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

#ifndef PKG_MEMORY_HPP
#define PKG_MEMORY_HPP

#include <cmath>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <cstdlib>
using namespace std;

#include “ap_int.h”
#include “01_pkg_gloabals.hpp”
#include “02_pkg_cache.hpp”

// --------------------------------------------------------------------------------------
// FIFO Signals
// --------------------------------------------------------------------------------------
typedef struct {
  ap_uint<1> full       ;
  ap_uint<1> empty      ;
  ap_uint<1> valid      ;
  ap_uint<1> prog_full  ;
  ap_uint<1> wr_rst_busy;
  ap_uint<1> rd_rst_busy;
} FIFOStateSignalsOutput;

typedef struct {
  ap_uint<1> rd_en;
  ap_uint<1> wr_en;
} FIFOStateSignalsInput;

// --------------------------------------------------------------------------------------
//   Generic Memory request packet
// --------------------------------------------------------------------------------------
#define TYPE_MEMORY_CMD_BITS 6
typedef enum ap_uint<TYPE_MEMORY_CMD_BITS> {
  CMD_INVALID,
  CMD_READ,
  CMD_WRITE,
  CMD_MEM_RESPONSE,
  CMD_CONFIGURE,
  CMD_ENGINE
} type_memory_cmd;

// --------------------------------------------------------------------------------------
//   Generic Memory Operand location
// --------------------------------------------------------------------------------------
#define TYPE_ENGINE_OPERAND_BITS 4
typedef enum ap_uint<TYPE_ENGINE_OPERAND_BITS> {
  OP_LOCATION_0,
  OP_LOCATION_1,
  OP_LOCATION_2,
  OP_LOCATION_3
} type_engine_operand;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
#define TYPE_FILTER_OPERATION_BITS 4
typedef enum ap_uint<TYPE_FILTER_OPERATION_BITS>{
  FILTER_NOP,
  FILTER_GT,
  FILTER_LT,
  FILTER_EQ
} type_filter_operation;

// --------------------------------------------------------------------------------------
//   Generic Memory Filter Type
// --------------------------------------------------------------------------------------
#define TYPE_ALU_OPERATION_BITS 6
typedef enum ap_uint<TYPE_ALU_OPERATION_BITS> {
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
#define TYPE_DATA_STRUCTURE_BITS 5
typedef enum ap_uint<TYPE_DATA_STRUCTURE_BITS>{
  STRUCT_INVALID,
  STRUCT_CU_DATA,
  STRUCT_ENGINE_DATA,
  STRUCT_CU_SETUP,
  STRUCT_ENGINE_SETUP
} type_data_buffer;

// --------------------------------------------------------------------------------------
//   Generic Memory request packet
// --------------------------------------------------------------------------------------
typedef struct{
  ap_uint<KERNEL_CU_COUNT_WIDTH_BITS> id_cu    ; // SIZE 4bits  - up to 4 vertex cu - pending
  ap_uint<CU_BUNDLE_COUNT_WIDTH_BITS> id_bundle; // SIZE 8bits  - up to 8 bundles
  ap_uint<  CU_LANE_COUNT_WIDTH_BITS> id_lane  ; // SIZE 8bits  - up to 8 lanes per bundle
  ap_uint<CU_ENGINE_COUNT_WIDTH_BITS> id_engine; // SIZE 8bits  - up to 8 engines per bundle
  ap_uint<CU_BUFFER_COUNT_WIDTH_BITS> id_buffer; // SIZE 1 bits - up to 12 buffers in the descriptor
} MemoryPacketArbitrate;

typedef struct{
  MemoryPacketArbitrate from;
  MemoryPacketArbitrate to  ;
} MemoryPacketRoute;

typedef struct{
  ap_uint<1>                             direction; // 0 - right, 1 left
  ap_uint<$clog2(CACHE_FRONTEND_ADDR_W)> amount   ; // SIZE 6 bits
} MemoryPacketAddressShift;

typedef struct{
  ap_uint<CACHE_FRONTEND_ADDR_W> base  ; // SIZE 6 bits
  ap_uint<CACHE_FRONTEND_ADDR_W> offset; // SIZE 6 bits
  MemoryPacketAddressShift          shift ; // SIZE 6 bits
} MemoryPacketAddress;

typedef struct{
  type_memory_cmd       cmd    ; // SIZE 5bits
  type_data_buffer      buffer ; // SIZE 1 bits
  type_engine_operand   operand; // SIZE 6bits
  type_filter_operation filter ; // SIZE 6bits
  type_ALU_operation    alu    ; // SIZE 6bits
} MemoryPacketType;

typedef struct{
  MemoryPacketRoute   route   ;
  MemoryPacketAddress address ;
  MemoryPacketType    subclass;
} MemoryPacketMeta;

typedef struct{
  ap_uint<CACHE_FRONTEND_DATA_W> field_0;
  ap_uint<CACHE_FRONTEND_DATA_W> field_1;
  ap_uint<CACHE_FRONTEND_DATA_W> field_2;
  ap_uint<CACHE_FRONTEND_DATA_W> field_3;
} MemoryPacketData;

typedef struct{
  MemoryPacketMeta meta;
  MemoryPacketData data;
} MemoryPacketPayload;

typedef struct{
  ap_uint<1>          valid  ;
  MemoryPacketPayload payload;
} MemoryPacket;

// --------------------------------------------------------------------------------------
// Cache Control Signals
// --------------------------------------------------------------------------------------
typedef struct {
  ap_uint<1> force_inv; //force 1'b0 if unused
  ap_uint<1> wtb_empty; //force 1'b1 if unused
} CacheControlIOBInput;

typedef struct {
  ap_uint<1> force_inv;
  ap_uint<1> wtb_empty;
} CacheControlIOBOutput;

typedef struct {
  CacheControlIOBInput  in ; //force 1'b0 if unused
  CacheControlIOBOutput out;
} CacheControlIOB;

// --------------------------------------------------------------------------------------
// Cache requests in CacheRequest
// --------------------------------------------------------------------------------------
typedef struct {
  ap_uint<1> valid;
  
  ap_uint<CACHE_FRONTEND_ADDR_W> addr;
  ap_uint<CACHE_FRONTEND_DATA_W> wdata;
  ap_uint<CACHE_FRONTEND_NBYTES> wstrb;
} CacheRequestIOB;

typedef struct {
  CacheRequestIOB  iob ;
  MemoryPacketMeta meta;
} CacheRequestPayload;

typedef struct {
  ap_uint<1>          valid  ;
  CacheRequestPayload payload;
} CacheRequest;

// --------------------------------------------------------------------------------------
// Cache response out CacheResponse
// --------------------------------------------------------------------------------------
typedef struct {
  ap_uint<1>                     ready;
  ap_uint<CACHE_FRONTEND_DATA_W> rdata;
} CacheResponseIOB;

typedef struct {
  CacheResponseIOB iob ;
  MemoryPacketMeta meta;
} CacheResponsePayload;

typedef struct {
  ap_uint<1>           valid  ;
  CacheResponsePayload payload;
} CacheResponse;

// --------------------------------------------------------------------------------------
//   Cache Requests state machine
// --------------------------------------------------------------------------------------
typedef enum ap_uint<6> {
  CACHE_REQUEST_GEN_RESET,
  CACHE_REQUEST_GEN_IDLE,
  CACHE_REQUEST_GEN_SEND_S1,
  CACHE_REQUEST_GEN_SEND_S2,
  CACHE_REQUEST_GEN_BUSY,
  CACHE_REQUEST_GEN_READY,
  CACHE_REQUEST_GEN_DONE
} cache_generator_request_state;

#endif
