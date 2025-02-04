// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : 04_pkg_engine.sv
// Create : 2022-11-29 16:14:59
// Revise : 2023-09-07 23:45:46
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_timescale.vh"
package PKG_ENGINE;

import PKG_GLOBALS::*;
import PKG_MEMORY::*;
import PKG_MXX_AXI4_FE::*;

// --------------------------------------------------------------------------------------
// CSR\_Index\_Generator
// --------------------------------------------------------------------------------------
// ### Input: array\_pointer, array\_size, offset, degree

// When reading the edge list of the Graph CSR structure, a sequence of
// Vertex-IDs is generated based on the edges\_index and the degree size of
// the processed vertex. The read engines can connect to the
// CSR\_Index\_Generator to acquire the neighbor IDs for further
// processing, in this scenario reading the data of the vertex neighbors.

typedef enum logic[16:0] {
    ENGINE_CSR_INDEX_GEN_RESET              = 1 << 0,
    ENGINE_CSR_INDEX_GEN_IDLE               = 1 << 1,
    ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_CSR_INDEX_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_CSR_INDEX_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_IDLE  = 1 << 5,
    ENGINE_CSR_INDEX_GEN_SETUP_ENGINE_TRANS = 1 << 6,
    ENGINE_CSR_INDEX_GEN_SETUP_ENGINE       = 1 << 7,
    ENGINE_CSR_INDEX_GEN_START_TRANS        = 1 << 8,
    ENGINE_CSR_INDEX_GEN_START              = 1 << 9,
    ENGINE_CSR_INDEX_GEN_BUSY_TRANS         = 1 << 10,
    ENGINE_CSR_INDEX_GEN_BUSY               = 1 << 11,
    ENGINE_CSR_INDEX_GEN_PAUSE_TRANS        = 1 << 12,
    ENGINE_CSR_INDEX_GEN_PAUSE              = 1 << 13,
    ENGINE_CSR_INDEX_GEN_DONE_TRANS         = 1 << 14,
    ENGINE_CSR_INDEX_GEN_DONE_PACKET        = 1 << 15,
    ENGINE_CSR_INDEX_GEN_DONE               = 1 << 16
} engine_csr_index_generator_state;

typedef struct packed{
    logic                                                                        increment    ;
    logic                                                                        decrement    ;
    logic                                                                        mode_sequence;
    logic                                                                        mode_buffer  ;
    logic                                                                        mode_break   ;
    logic                                                                        mode_parallel;
    logic [      NUM_CHANNELS_WIDTH_BITS-1:0]                                    id_channel   ;
    logic [   CU_BUFFER_COUNT_WIDTH_BITS-1:0]                                    id_buffer    ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    array_size   ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    index_start  ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    index_end    ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    stride       ;
    logic [   $clog2(M00_AXI4_FE_ADDR_W)-1:0]                                    granularity  ;
    logic                                                                        direction    ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    const_mask   ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    const_value  ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][ENGINE_PACKET_DATA_NUM_FIELDS-1:0] ops_mask     ;
    type_memory_cache_mode                                                       mode_cache   ;
} CSRIndexConfigurationParameters;

typedef struct packed{
    PacketRouteAddress packet_destination;
} CSRIndexConfigurationRouteAttributes;

typedef struct packed{
    type_memory_cmd cmd;
} CSRIndexConfigurationType;

typedef struct packed{
    CSRIndexConfigurationRouteAttributes route   ;
    CSRIndexConfigurationType            subclass;
    PacketRequestDataAddress             address ;
} CSRIndexConfigurationMeta;

typedef struct packed{
    CSRIndexConfigurationParameters param;
    CSRIndexConfigurationMeta       meta ;
    EnginePacketData                data ;
} CSRIndexConfigurationPayload;

typedef struct packed{
    logic                        valid  ;
    CSRIndexConfigurationPayload payload;
} CSRIndexConfiguration;

// --------------------------------------------------------------------------------------
// Merge\_Data\_Engine
// --------------------------------------------------------------------------------------
// Forward the data in a lane and merges it with other data from other lanes
// Keeps the original meta data for that lane

typedef enum logic[10:0] {
    ENGINE_MERGE_DATA_GEN_RESET              = 1 << 0,
    ENGINE_MERGE_DATA_GEN_IDLE               = 1 << 1,
    ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_MERGE_DATA_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_MERGE_DATA_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_MERGE_DATA_GEN_START_TRANS        = 1 << 5,
    ENGINE_MERGE_DATA_GEN_START              = 1 << 6,
    ENGINE_MERGE_DATA_GEN_PAUSE_TRANS        = 1 << 7,
    ENGINE_MERGE_DATA_GEN_BUSY               = 1 << 8,
    ENGINE_MERGE_DATA_GEN_BUSY_TRANS         = 1 << 9,
    ENGINE_MERGE_DATA_GEN_PAUSE              = 1 << 10
} engine_merge_data_generator_state;

typedef struct packed{
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    merge_mask;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    merge_type;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][ENGINE_PACKET_DATA_NUM_FIELDS-1:0] ops_mask  ;
} MergeDataConfigurationParameters;

typedef struct packed{
    MergeDataConfigurationParameters param;
} MergeDataConfigurationPayload;

typedef struct packed{
    logic                         valid  ;
    MergeDataConfigurationPayload payload;
} MergeDataConfiguration;

// --------------------------------------------------------------------------------------
// set operations Engine
// --------------------------------------------------------------------------------------
// Forward the data in a lane and union/intersect it with other data from other lanes
// Keeps the original meta data for that lane

typedef enum logic[10:0] {
    ENGINE_SET_OPS_GEN_RESET              = 1 << 0,
    ENGINE_SET_OPS_GEN_IDLE               = 1 << 1,
    ENGINE_SET_OPS_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_SET_OPS_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_SET_OPS_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_SET_OPS_GEN_START_TRANS        = 1 << 5,
    ENGINE_SET_OPS_GEN_START              = 1 << 6,
    ENGINE_SET_OPS_GEN_PAUSE_TRANS        = 1 << 7,
    ENGINE_SET_OPS_GEN_BUSY               = 1 << 8,
    ENGINE_SET_OPS_GEN_BUSY_TRANS         = 1 << 9,
    ENGINE_SET_OPS_GEN_PAUSE              = 1 << 10
} engine_set_ops_generator_state;

typedef struct packed{
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0] set_mask     ;
    type_set_operation                        set_operation;
} SetOpsConfigurationParameters;

typedef struct packed{
    SetOpsConfigurationParameters param;
} SetOpsConfigurationPayload;

typedef struct packed{
    logic                      valid  ;
    SetOpsConfigurationPayload payload;
} SetOpsConfiguration;

// --------------------------------------------------------------------------------------
// Forward\_Data\_Engine
// --------------------------------------------------------------------------------------
// Forward the data in a lane it with other data from other lanes
// Keeps the original meta data for that lane

typedef enum logic[9:0] {
    ENGINE_FORWARD_DATA_GEN_RESET       = 1 << 0,
    ENGINE_FORWARD_DATA_GEN_IDLE        = 1 << 1,
    ENGINE_FORWARD_DATA_GEN_START_TRANS = 1 << 2,
    ENGINE_FORWARD_DATA_GEN_START       = 1 << 3,
    ENGINE_FORWARD_DATA_GEN_PAUSE_TRANS = 1 << 4,
    ENGINE_FORWARD_DATA_GEN_BUSY        = 1 << 5,
    ENGINE_FORWARD_DATA_GEN_BUSY_TRANS  = 1 << 6,
    ENGINE_FORWARD_DATA_GEN_PAUSE       = 1 << 7,
    ENGINE_FORWARD_DATA_GEN_DONE_TRANS  = 1 << 8,
    ENGINE_FORWARD_DATA_GEN_DONE        = 1 << 9
} engine_forward_data_generator_state;

typedef struct packed{
    logic [NUM_BUNDLES_WIDTH_BITS-1:0] hops;
} ForwardDataConfigurationParameters;

typedef struct packed{
    ForwardDataConfigurationParameters param;
} ForwardDataConfigurationPayload;

typedef struct packed{
    logic                           valid  ;
    ForwardDataConfigurationPayload payload;
} ForwardDataConfiguration;

// --------------------------------------------------------------------------------------
// ALU\_Ops\_Engine
// --------------------------------------------------------------------------------------
// Forward the data in a lane and operate
// Keeps the original meta data for that lane

typedef enum logic[10:0] {
    ENGINE_ALU_OPS_GEN_RESET              = 1 << 0,
    ENGINE_ALU_OPS_GEN_IDLE               = 1 << 1,
    ENGINE_ALU_OPS_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_ALU_OPS_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_ALU_OPS_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_ALU_OPS_GEN_START_TRANS        = 1 << 5,
    ENGINE_ALU_OPS_GEN_START              = 1 << 6,
    ENGINE_ALU_OPS_GEN_PAUSE_TRANS        = 1 << 7,
    ENGINE_ALU_OPS_GEN_BUSY               = 1 << 8,
    ENGINE_ALU_OPS_GEN_BUSY_TRANS         = 1 << 9,
    ENGINE_ALU_OPS_GEN_PAUSE              = 1 << 10
} engine_alu_ops_generator_state;

typedef struct packed{
    type_ALU_operation                                                           alu_operation;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    alu_mask     ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    const_mask   ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    const_value  ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][ENGINE_PACKET_DATA_NUM_FIELDS-1:0] ops_mask     ;
} ALUOpsConfigurationParameters;

typedef struct packed{
    PacketRouteAddress packet_destination;
} ALUOpsConfigurationRouteAttributes;

typedef struct packed{
    ALUOpsConfigurationRouteAttributes route;
} ALUOpsConfigurationMeta;

typedef struct packed{
    ALUOpsConfigurationParameters param;
    ALUOpsConfigurationMeta       meta ;
} ALUOpsConfigurationPayload;

typedef struct packed{
    logic                      valid  ;
    ALUOpsConfigurationPayload payload;
} ALUOpsConfiguration;

// --------------------------------------------------------------------------------------
// Filter\_Cond\_Engine
// --------------------------------------------------------------------------------------
// Forward the data in a lane and operate if condition is true
// Keeps the original meta data for that lane

typedef enum logic[12:0] {
    ENGINE_FILTER_COND_GEN_RESET              = 1 << 0,
    ENGINE_FILTER_COND_GEN_IDLE               = 1 << 1,
    ENGINE_FILTER_COND_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_FILTER_COND_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_FILTER_COND_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_FILTER_COND_GEN_START_TRANS        = 1 << 5,
    ENGINE_FILTER_COND_GEN_START              = 1 << 6,
    ENGINE_FILTER_COND_GEN_PAUSE_TRANS        = 1 << 7,
    ENGINE_FILTER_COND_GEN_BREAK_TRANS        = 1 << 8,
    ENGINE_FILTER_COND_GEN_BREAK              = 1 << 9,
    ENGINE_FILTER_COND_GEN_BUSY               = 1 << 10,
    ENGINE_FILTER_COND_GEN_BUSY_TRANS         = 1 << 11,
    ENGINE_FILTER_COND_GEN_PAUSE              = 1 << 12
} engine_filter_cond_generator_state;

typedef struct packed{
    PacketRouteAddress _if  ;
    PacketRouteAddress _else;
} FilterCondEnginePacketRoute;

typedef struct packed{
    type_filter_operation                                                        filter_operation;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    filter_mask     ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    const_mask      ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    set_mask        ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    const_value     ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    set_value       ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][ENGINE_PACKET_DATA_NUM_FIELDS-1:0] ops_mask        ;
    logic                                                                        break_flag      ;
    logic                                                                        break_pass      ;
    logic                                                                        filter_post     ;
    logic                                                                        filter_pass     ;
    logic                                                                        continue_flag   ;
    logic                                                                        ternary_flag    ;
    logic                                                                        conditional_flag;
    logic                                                                        equal_flag      ;
    FilterCondEnginePacketRoute                                                  filter_route    ;
} FilterCondConfigurationParameters;

typedef struct packed{
    FilterCondConfigurationParameters param;
} FilterCondConfigurationPayload;

typedef struct packed{
    logic                          valid  ;
    FilterCondConfigurationPayload payload;
} FilterCondConfiguration;

// --------------------------------------------------------------------------------------
// Read\_Write\_Engine
// --------------------------------------------------------------------------------------
// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity, mode

// The read/write recieves a sequence and trnsformes it to memory commands
// sent to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array. Mode parameter would decide the engine read/write mode.

typedef enum logic[10:0] {
    ENGINE_READ_WRITE_GEN_RESET              = 1 << 0,
    ENGINE_READ_WRITE_GEN_IDLE               = 1 << 1,
    ENGINE_READ_WRITE_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_READ_WRITE_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_READ_WRITE_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_READ_WRITE_GEN_START_TRANS        = 1 << 5,
    ENGINE_READ_WRITE_GEN_START              = 1 << 6,
    ENGINE_READ_WRITE_GEN_BUSY_TRANS         = 1 << 7,
    ENGINE_READ_WRITE_GEN_BUSY               = 1 << 8,
    ENGINE_READ_WRITE_GEN_PAUSE_TRANS        = 1 << 9,
    ENGINE_READ_WRITE_GEN_PAUSE              = 1 << 10
} engine_read_write_generator_state;

typedef struct packed{
    logic [      NUM_CHANNELS_WIDTH_BITS-1:0]                                    id_channel ;
    logic [   CU_BUFFER_COUNT_WIDTH_BITS-1:0]                                    id_buffer  ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    index_start;
    logic [   $clog2(M00_AXI4_FE_ADDR_W)-1:0]                                    granularity;
    logic                                                                        direction  ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    const_mask ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    const_value;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][ENGINE_PACKET_DATA_NUM_FIELDS-1:0] ops_mask   ;
    type_memory_cache_mode                                                       mode_cache ;
} ReadWriteConfigurationParameters;

typedef struct packed{
    PacketRouteAddress packet_destination;
} ReadWriteConfigurationRouteAttributes;

typedef struct packed{
    type_memory_cmd cmd;
} ReadWriteConfigurationType;

typedef struct packed{
    logic [   NUM_CHANNELS_WIDTH_BITS-1:0] id_channel ;
    logic [CU_BUFFER_COUNT_WIDTH_BITS-1:0] id_buffer  ;
    logic [        M00_AXI4_FE_DATA_W-1:0] index_start;
    logic [$clog2(M00_AXI4_FE_ADDR_W)-1:0] granularity;
    logic                                  direction  ;
} ReadWriteConfigurationParameterAddress;

typedef struct packed{
    ReadWriteConfigurationRouteAttributes route   ;
    ReadWriteConfigurationType            subclass;
    PacketRequestDataAddress              address ;
} ReadWriteConfigurationMeta;

typedef struct packed{
    ReadWriteConfigurationParameters param;
    ReadWriteConfigurationMeta       meta ;
} ReadWriteConfigurationPayload;

typedef struct packed{
    logic                         valid  ;
    ReadWriteConfigurationPayload payload;
} ReadWriteConfiguration;

// --------------------------------------------------------------------------------------
// Parallel Read\_Write\_Engine
// --------------------------------------------------------------------------------------
// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity, mode

// The read/write recieves a sequence and trnsformes it to memory commands
// sent to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array. Mode parameter would decide the engine read/write mode.

typedef enum logic[10:0] {
    ENGINE_PARALLEL_READ_WRITE_GEN_RESET              = 1 << 0,
    ENGINE_PARALLEL_READ_WRITE_GEN_IDLE               = 1 << 1,
    ENGINE_PARALLEL_READ_WRITE_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_PARALLEL_READ_WRITE_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_PARALLEL_READ_WRITE_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_PARALLEL_READ_WRITE_GEN_START_TRANS        = 1 << 5,
    ENGINE_PARALLEL_READ_WRITE_GEN_START              = 1 << 6,
    ENGINE_PARALLEL_READ_WRITE_GEN_BUSY_TRANS         = 1 << 7,
    ENGINE_PARALLEL_READ_WRITE_GEN_BUSY               = 1 << 8,
    ENGINE_PARALLEL_READ_WRITE_GEN_PAUSE_TRANS        = 1 << 9,
    ENGINE_PARALLEL_READ_WRITE_GEN_PAUSE              = 1 << 10
} engine_parallel_read_write_generator_state;

typedef struct packed{
    PacketRouteAddress packet_destination;
} ParallelReadWriteConfigurationRouteAttributes;

typedef struct packed{
    type_memory_cmd cmd;
} ParallelReadWriteConfigurationType;

typedef struct packed{
    ParallelReadWriteConfigurationRouteAttributes route     ;
    ParallelReadWriteConfigurationType            subclass  ;
    PacketRequestDataAddress                      address   ;
    logic [NUM_BUNDLES_WIDTH_BITS-1:0]            ops_bundle;
    logic [  NUM_LANES_WIDTH_BITS-1:0]            ops_lane  ;
} ParallelReadWriteConfigurationMeta;

typedef struct packed{
    logic [      NUM_CHANNELS_WIDTH_BITS-1:0]                                    id_channel ;
    logic [   CU_BUFFER_COUNT_WIDTH_BITS-1:0]                                    id_buffer  ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    index_start;
    logic [   $clog2(M00_AXI4_FE_ADDR_W)-1:0]                                    granularity;
    logic                                                                        direction  ;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    const_mask ;
    logic [           M00_AXI4_FE_DATA_W-1:0]                                    const_value;
    logic [ENGINE_PACKET_DATA_NUM_FIELDS-1:0][ENGINE_PACKET_DATA_NUM_FIELDS-1:0] ops_mask   ;
    type_memory_cache_mode                                                       mode_cache ;
} ParallelReadWriteConfigurationParameterField;

typedef struct packed{
    logic                                        [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    lane_mask  ;
    logic                                        [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    cast_mask  ;
    logic                                        [                              1:0][ENGINE_PACKET_DATA_NUM_FIELDS-1:0] merge_mask ;
    ParallelReadWriteConfigurationParameterField [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    param_field;
    ParallelReadWriteConfigurationMeta           [ENGINE_PACKET_DATA_NUM_FIELDS-1:0]                                    meta       ;
} ParallelReadWriteConfigurationParameters;

typedef struct packed{
    ParallelReadWriteConfigurationParameters param;
} ParallelReadWriteConfigurationPayload;

typedef struct packed{
    logic                                 valid  ;
    ParallelReadWriteConfigurationPayload payload;
} ParallelReadWriteConfiguration;

// --------------------------------------------------------------------------------------
// CU\_Setup\_Engine
// --------------------------------------------------------------------------------------
// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity

// The cu setup acts like a serial read engine
// sends read commands to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array.
typedef enum logic[8:0] {
    ENGINE_CU_SETUP_RESET       = 1 << 0,
    ENGINE_CU_SETUP_IDLE        = 1 << 1,
    ENGINE_CU_SETUP_SETUP       = 1 << 2,
    ENGINE_CU_SETUP_START       = 1 << 3,
    ENGINE_CU_SETUP_BUSY_TRANS  = 1 << 4,
    ENGINE_CU_SETUP_BUSY        = 1 << 5,
    ENGINE_CU_SETUP_PAUSE_TRANS = 1 << 6,
    ENGINE_CU_SETUP_PAUSE       = 1 << 7,
    ENGINE_CU_SETUP_DONE        = 1 << 8
} engine_cu_setup_state;

typedef struct packed{
    logic                                  increment   ;
    logic                                  decrement   ;
    logic                                  flush_mode  ;
    logic                                  flush_enable;
    logic [                   NUM_CUS-1:0] cu_vector   ;
    logic [   NUM_CHANNELS_WIDTH_BITS-1:0] id_channel  ;
    logic [CU_BUFFER_COUNT_WIDTH_BITS-1:0] id_buffer   ;
    logic [        M00_AXI4_FE_DATA_W-1:0] array_size  ;
    logic [        M00_AXI4_FE_DATA_W-1:0] start_read  ;
    logic [        M00_AXI4_FE_DATA_W-1:0] end_read    ;
    logic [        M00_AXI4_FE_DATA_W-1:0] stride      ;
    logic [$clog2(M00_AXI4_FE_ADDR_W)-1:0] granularity ;
} CUSetupEngineConfigurationParameters;

typedef struct packed{
    CUSetupEngineConfigurationParameters param;
    MemoryPacketRequestMeta              meta ;
} CUSetupEngineConfigurationPayload;


typedef struct packed{
    logic                             valid  ;
    CUSetupEngineConfigurationPayload payload;
} CUSetupEngineConfiguration;

// --------------------------------------------------------------------------------------
// Automata\_NFA\_Engine
// --------------------------------------------------------------------------------------
// Forward the data in a lane and operate if condition is true
// Keeps the original meta data for that lane

typedef enum logic[12:0] {
    ENGINE_AUTOMATA_NFA_GEN_RESET              = 1 << 0,
    ENGINE_AUTOMATA_NFA_GEN_IDLE               = 1 << 1,
    ENGINE_AUTOMATA_NFA_GEN_SETUP_MEMORY_IDLE  = 1 << 2,
    ENGINE_AUTOMATA_NFA_GEN_SETUP_MEMORY_TRANS = 1 << 3,
    ENGINE_AUTOMATA_NFA_GEN_SETUP_MEMORY       = 1 << 4,
    ENGINE_AUTOMATA_NFA_GEN_START_TRANS        = 1 << 5,
    ENGINE_AUTOMATA_NFA_GEN_START              = 1 << 6,
    ENGINE_AUTOMATA_NFA_GEN_PAUSE_TRANS        = 1 << 7,
    ENGINE_AUTOMATA_NFA_GEN_BREAK_TRANS        = 1 << 8,
    ENGINE_AUTOMATA_NFA_GEN_BREAK              = 1 << 9,
    ENGINE_AUTOMATA_NFA_GEN_BUSY               = 1 << 10,
    ENGINE_AUTOMATA_NFA_GEN_BUSY_TRANS         = 1 << 11,
    ENGINE_AUTOMATA_NFA_GEN_PAUSE              = 1 << 12
} engine_automata_nfa_generator_state;

endpackage

