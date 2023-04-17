// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : engine_pkg.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps
package ENGINE_PKG;

    import GLOBALS_PKG::*;

// Stride\_Index\_Generator
// ------------------------

// ### Input: index\_start, index\_end, stride, granularity

// The stride index generator serves two purposes. First, it generates a
// sequence of indices or Vertex-IDs scheduled to the Vertex Compute Units
// (CUs). For each Vertex-CU, a batch of Vertex-IDs is sent to be processed
// based on the granularity. For example, if granularity is (8), each CU
// (Compute Units) would get eight vertex IDs in chunks.

    typedef struct packed{
        logic                               increment  ;
        logic                               decrement  ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index_start;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index_end  ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity;
    } StrideIndexGeneratorConfigurationPayload;

    typedef struct packed{
        logic                                    valid  ;
        StrideIndexGeneratorConfigurationPayload payload;
    } StrideIndexGeneratorConfiguration;

// CSR\_Index\_Generator
// ---------------------

// ### Input: array\_pointer, array\_size, offset, degree

// When reading the edge list of the Graph CSR structure, a sequence of
// Vertex-IDs is generated based on the edges\_index and the degree size of
// the processed vertex. The read engines can connect to the
// CSR\_Index\_Generator to acquire the neighbor IDs for further
// processing, in this scenario reading the data of the vertex neighbors.

    typedef struct packed{
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] offset       ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] degree       ;
    } CSRIndexGeneratorConfigurationPayload;

    typedef struct packed{
        logic                                 valid  ;
        CSRIndexGeneratorConfigurationPayload payload;
    } CSRIndexGeneratorConfiguration;

// Serial\_Read\_Engine
// --------------------

// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity

// The serial read engine sends read commands to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array.

    typedef enum int unsigned {
        SERIAL_READ_ENGINE_RESET,
        SERIAL_READ_ENGINE_IDLE,
        SERIAL_READ_ENGINE_SETUP,
        SERIAL_READ_ENGINE_START,
        SERIAL_READ_ENGINE_BUSY,
        SERIAL_READ_ENGINE_PAUSE,
        SERIAL_READ_ENGINE_DONE
    } serial_read_engine_state;

    typedef struct packed{
        logic                               increment    ;
        logic                               decrement    ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] start_read   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] end_read     ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] stride       ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } SerialReadEngineConfigurationPayload;

    typedef struct packed{
        logic                                valid  ;
        SerialReadEngineConfigurationPayload payload;
    } SerialReadEngineConfiguration;

// Serial\_Write\_Engine
// ---------------------

// ### Input :array\_pointer, array\_size, index, granularity

// The serial write engine sends coalesced write commands to the memory
// control layer. Each write-request groups a chunk of data (group of
// vertices) intended to be written in a serial pattern. The serial write
// engine is simpler to design as it plans only to group serial data and
// write them in single bursts depending on the "granularity" parameter.
// This behavior can be found in iterative SpMV-based graph algorithms like
// PageRank.

    typedef struct packed{
        logic                               increment    ;
        logic                               decrement    ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index        ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } SerialWriteEngineConfigurationPayload;

    typedef struct packed{
        logic                                 valid  ;
        SerialWriteEngineConfigurationPayload payload;
    } SerialWriteEngineConfiguration;

// Random\_Read\_Engine
// --------------------------------------------

// ### Input: array\_pointer, array\_size, index, granularity

// A random read engine does not require a stride access pattern. Instead,
// arbitrary fine-grain commands are sent straight to a caching element in
// a fine-grained manner. Optimizations can occur on the caching level with
// grouping or reordering. The main challenge would be designing an engine
// that supports fine-grain accesses while balancing the design complexity
// if such optimizations were to be kept.

    typedef struct packed{
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index        ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } RandomReadEngineConfigurationPayload;

    typedef struct packed{
        logic                                valid  ;
        RandomReadEngineConfigurationPayload payload;
    } RandomReadEngineConfiguration;

// Random\_Write\_Engine
// --------------------------------------------

// ### Input: array\_pointer, array\_size, index, granularity

// A random read engine does not require a stride access pattern. Instead,
// arbitrary fine-grain commands are sent straight to a caching element in
// a fine-grained manner. Optimizations can occur on the caching level with
// grouping or reordering. The main challenge would be designing an engine
// that supports fine-grain accesses while balancing the design complexity
// if such optimizations were to be kept.

    typedef struct packed{
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] index        ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } RandomWriteEngineConfigurationPayload;


    typedef struct packed{
        logic                                 valid  ;
        RandomWriteEngineConfigurationPayload payload;
    } RandomWriteEngineConfiguration;


endpackage