// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : 04_pkg_engine.sv
// Create : 2022-11-29 16:14:59
// Revise : 2023-06-28 21:34:16
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps
package PKG_ENGINE;

    import PKG_GLOBALS::*;
    import PKG_MEMORY::*;
    import PKG_CACHE::*;

// Stride\_Index\_Generator
// ------------------------

// ### Input: index\_start, index\_end, stride, granularity

// The stride index generator serves two purposes. First, it generates a
// sequence of indices or Vertex-IDs scheduled to the Vertex Compute Units
// (CUs). For each Vertex-CU, a batch of Vertex-IDs is sent to be processed
// based on the granularity. For example, if granularity is (8), each CU
// (Compute Units) would get eight vertex IDs in chunks.

    typedef enum logic[8:0] {
        ENGINE_STRIDE_INDEX_RESET,
        ENGINE_STRIDE_INDEX_IDLE,
        ENGINE_STRIDE_INDEX_SETUP,
        ENGINE_STRIDE_INDEX_START,
        ENGINE_STRIDE_INDEX_START_TRANS,
        ENGINE_STRIDE_INDEX_BUSY,
        ENGINE_STRIDE_INDEX_PAUSE_TRANS,
        ENGINE_STRIDE_INDEX_PAUSE,
        ENGINE_STRIDE_INDEX_DONE
    } engine_stride_index_state;

    typedef enum logic[8:0] {
        ENGINE_STRIDE_INDEX_GEN_RESET,
        ENGINE_STRIDE_INDEX_GEN_IDLE,
        ENGINE_STRIDE_INDEX_GEN_SETUP,
        ENGINE_STRIDE_INDEX_GEN_START,
        ENGINE_STRIDE_INDEX_GEN_BUSY_TRANS,
        ENGINE_STRIDE_INDEX_GEN_BUSY,
        ENGINE_STRIDE_INDEX_GEN_PAUSE_TRANS,
        ENGINE_STRIDE_INDEX_GEN_PAUSE,
        ENGINE_STRIDE_INDEX_GEN_DONE
    } engine_stride_index_generator_state;

    typedef struct packed{
        logic                               increment  ;
        logic                               decrement  ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index_start;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index_end  ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] stride     ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity;
    } StrideIndexConfigurationParameters;

    typedef struct packed{
        StrideIndexConfigurationParameters param;
        MemoryPacketMeta                   meta ;
    } StrideIndexConfigurationPayload;

    typedef struct packed{
        logic                           valid  ;
        StrideIndexConfigurationPayload payload;
    } StrideIndexConfiguration;

// CSR\_Index\_Generator
// ---------------------

// ### Input: array\_pointer, array\_size, offset, degree

// When reading the edge list of the Graph CSR structure, a sequence of
// Vertex-IDs is generated based on the edges\_index and the degree size of
// the processed vertex. The read engines can connect to the
// CSR\_Index\_Generator to acquire the neighbor IDs for further
// processing, in this scenario reading the data of the vertex neighbors.

    typedef enum logic[8:0] {
        ENGINE_CSR_INDEX_RESET,
        ENGINE_CSR_INDEX_IDLE,
        ENGINE_CSR_INDEX_SETUP,
        ENGINE_CSR_INDEX_START,
        ENGINE_CSR_INDEX_START_TRANS,
        ENGINE_CSR_INDEX_BUSY,
        ENGINE_CSR_INDEX_PAUSE_TRANS,
        ENGINE_CSR_INDEX_PAUSE,
        ENGINE_CSR_INDEX_DONE
    } engine_csr_index_state;

    typedef enum logic[8:0] {
        ENGINE_CSR_INDEX_GEN_RESET,
        ENGINE_CSR_INDEX_GEN_IDLE,
        ENGINE_CSR_INDEX_GEN_SETUP,
        ENGINE_CSR_INDEX_GEN_START,
        ENGINE_CSR_INDEX_GEN_BUSY_TRANS,
        ENGINE_CSR_INDEX_GEN_BUSY,
        ENGINE_CSR_INDEX_GEN_PAUSE_TRANS,
        ENGINE_CSR_INDEX_GEN_PAUSE,
        ENGINE_CSR_INDEX_GEN_DONE
    } engine_csr_index_generator_state;

    typedef struct packed{
        logic                               increment    ;
        logic                               decrement    ;
        logic                               mode_sequence;
        logic                               mode_buffer  ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index_start  ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index_end    ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] stride       ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } CSRIndexConfigurationParameters;

    typedef struct packed{
        CSRIndexConfigurationParameters param;
        MemoryPacketMeta                meta ;
    } CSRIndexConfigurationPayload;

    typedef struct packed{
        logic                        valid  ;
        CSRIndexConfigurationPayload payload;
    } CSRIndexConfiguration;

// Read\_Write\_Engine
// --------------------

// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity, mode

// The read/write recieves a sequence and trnsformes it to memory commands
// sent to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array. Mode parameter would decide the engine read/write mode.

    typedef enum logic[8:0] {
        ENGINE_READ_WRITE_RESET,
        ENGINE_READ_WRITE_IDLE,
        ENGINE_READ_WRITE_SETUP,
        ENGINE_READ_WRITE_START,
        ENGINE_READ_WRITE_START_TRANS,
        ENGINE_READ_WRITE_BUSY,
        ENGINE_READ_WRITE_PAUSE_TRANS,
        ENGINE_READ_WRITE_PAUSE,
        ENGINE_READ_WRITE_DONE
    } engine_read_write_state;

    typedef enum logic[8:0] {
        ENGINE_READ_WRITE_GEN_RESET,
        ENGINE_READ_WRITE_GEN_IDLE,
        ENGINE_READ_WRITE_GEN_SETUP,
        ENGINE_READ_WRITE_GEN_START,
        ENGINE_READ_WRITE_GEN_BUSY_TRANS,
        ENGINE_READ_WRITE_GEN_BUSY,
        ENGINE_READ_WRITE_GEN_PAUSE_TRANS,
        ENGINE_READ_WRITE_GEN_PAUSE,
        ENGINE_READ_WRITE_GEN_DONE
    } engine_read_write_generator_state;

    typedef struct packed{
        logic                               increment    ;
        logic                               decrement    ;
        logic                               mode         ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] stride       ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } ReadWriteEngineConfigurationParameters;

    typedef struct packed{
        ReadWriteEngineConfigurationParameters param;
        MemoryPacketMeta                       meta ;
    } ReadWriteEngineConfigurationPayload;


    typedef struct packed{
        logic                               valid  ;
        ReadWriteEngineConfigurationPayload payload;
    } ReadWriteEngineConfiguration;


// CU\_Setup\_Engine
// --------------------

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
        ENGINE_CU_SETUP_RESET,
        ENGINE_CU_SETUP_IDLE,
        ENGINE_CU_SETUP_SETUP,
        ENGINE_CU_SETUP_START,
        ENGINE_CU_SETUP_BUSY_TRANS,
        ENGINE_CU_SETUP_BUSY,
        ENGINE_CU_SETUP_PAUSE_TRANS,
        ENGINE_CU_SETUP_PAUSE,
        ENGINE_CU_SETUP_DONE
    } engine_cu_setup_state;

    typedef struct packed{
        logic                               increment    ;
        logic                               decrement    ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] start_read   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] end_read     ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] stride       ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } CUSetupEngineConfigurationParameters;

    typedef struct packed{
        CUSetupEngineConfigurationParameters param;
        MemoryPacketMeta                     meta ;
    } CUSetupEngineConfigurationPayload;


    typedef struct packed{
        logic                             valid  ;
        CUSetupEngineConfigurationPayload payload;
    } CUSetupEngineConfiguration;

endpackage