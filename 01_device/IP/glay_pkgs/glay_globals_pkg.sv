// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_globals_pkg.sv
// Create : 2022-11-16 19:43:34
// Revise : 2022-11-16 19:43:34
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


package GLAY_GLOBALS_PKG;

    `include "iob_lib.vh"
    `include "iob-cache.vh"
////////////////////////////////////////////////////////////////////////////
//  COMPUTE UNITS COUNT GLOBALS
////////////////////////////////////////////////////////////////////////////

    parameter CU_COUNT_GLOBAL = 1;
    parameter CU_COUNT_LOCAL  = 1;

////////////////////////////////////////////////////////////////////////////
//  GLay COMMON GLOBALS
////////////////////////////////////////////////////////////////////////////

    parameter PAGE_SIZE              = 4096                   ; // Page size default is 4KB
    parameter PAGE_SIZE_BITS         = (PAGE_SIZE * 8)        ;
    parameter CACHELINE_SIZE         = 64                     ; // cacheline is 64bytes
    parameter CACHELINE_SIZE_BITS    = (CACHELINE_SIZE * 8)   ;
    parameter CACHELINE_SIZE_HF      = (CACHELINE_SIZE >> 1)  ; // cacheline is 32bytes
    parameter CACHELINE_SIZE_BITS_HF = (CACHELINE_SIZE_HF * 8);

    parameter WORD             = 4              ;
    parameter WORD_BITS        = WORD * 8       ;
    parameter WORD_DOUBLE      = WORD * 2       ;
    parameter WORD_DOUBLE_BITS = WORD_DOUBLE * 8;

////////////////////////////////////////////////////////////////////////////
// AXI4 PARAMETERS
////////////////////////////////////////////////////////////////////////////

    parameter S_AXI_CONTROL_ADDR_WIDTH_BITS = 12 ;
    parameter S_AXI_CONTROL_DATA_WIDTH      = 32 ;
    parameter M_AXI_MEMORY_ADDR_WIDTH       = 64 ;
    parameter M_AXI_MEMORY_DATA_WIDTH_BITS  = 512;
    parameter M_AXI_MEMORY_ID_WIDTH         = 1  ;
    parameter M_AXI_MEMORY_ID_VALUE         = 0  ;
    parameter M_AXI_MEMORY_BURST_LEN        = 8  ;

////////////////////////////////////////////////////////////////////////////
// AXI4 IOB-CACHE PARAMETERS
////////////////////////////////////////////////////////////////////////////

    parameter CACHE_FRONTEND_ADDR_W = 64; //Address width - width of the Master's entire access address (including the LSBs that are discarded, but discarding the Controller's)
    parameter CACHE_FRONTEND_DATA_W = 64; //Data width - word size used for the cache
    parameter CACHE_N_WAYS          = 4 ; //Number of Cache Ways (Needs to be Potency of 2: 1, 2, 4, 8, ..)
    parameter CACHE_LINE_OFF_W      = 7 ; //Line-Offset Width - 2**NLINE_W total cache lines
    parameter CACHE_WORD_OFF_W      = 3 ; //Word-Offset Width - 2**OFFSET_W total FE_DATA_W words per line - WARNING about LINE2MEM_DATA_RATIO_W (can cause word_counter [-1:0]
    parameter CACHE_WTBUF_DEPTH_W   = 5 ; //Depth Width of Write-Through Buffer
    //Replacement policy (N_WAYS > 1)
    parameter CACHE_REP_POLICY = `PLRU_tree; //LRU - Least Recently Used; PLRU_mru (1) - MRU-based pseudoLRU; PLRU_tree (3) - tree-based pseudoLRU
    //Do NOT change - memory cache's parameters - dependency
    parameter CACHE_NWAY_W          = $clog2(CACHE_N_WAYS)         ; //Cache Ways Width
    parameter CACHE_FRONTEND_NBYTES = CACHE_FRONTEND_DATA_W/8      ; //Number of Bytes per Word
    parameter CACHE_FRONTEND_BYTE_W = $clog2(CACHE_FRONTEND_NBYTES); //Byte Offset
    /*---------------------------------------------------*/
    //Higher hierarchy memory (slave) interface parameters
    parameter CACHE_BACKEND_ADDR_W = CACHE_FRONTEND_ADDR_W       ; //Address width of the higher hierarchy memory
    parameter CACHE_BACKEND_DATA_W = CACHE_FRONTEND_DATA_W       ; //Data width of the memory
    parameter CACHE_BACKEND_NBYTES = CACHE_BACKEND_DATA_W/8      ; //Number of bytes
    parameter CACHE_BACKEND_BYTE_W = $clog2(CACHE_BACKEND_NBYTES); //Offset of Number of Bytes
    //Cache-Memory base Offset
    parameter CACHE_LINE2MEM_W = CACHE_WORD_OFF_W-$clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W); //Logarithm Ratio between the size of the cache-line and the BACKEND's data width
    /*---------------------------------------------------*/
    //Write Policy
    parameter CACHE_WRITE_POL = `WRITE_BACK; //write policy: write-through (0), write-back (1)
    /*---------------------------------------------------*/
    //AXI specific parameters
    parameter                      CACHE_AXI_ADDR_W = CACHE_BACKEND_ADDR_W;
    parameter                      CACHE_AXI_DATA_W = CACHE_BACKEND_ADDR_W;
    parameter                      CACHE_AXI_ID_W   = 1                   ; //AXI ID (identification) width
    parameter                      CACHE_AXI_LEN_W  = 8                   ; //AXI ID burst length (log2)
    parameter [CACHE_AXI_ID_W-1:0] CACHE_AXI_ID     = 0                   ; //AXI ID value
    //Controller's options
    parameter CACHE_CTRL_CACHE = 0; //Adds a Controller to the cache, to use functions sent by the master or count the hits and misses
    parameter CACHE_CTRL_CNT   = 0; //Counters for Cache Hits and Misses - Disabling this and previous, the Controller only store the buffer states and allows cache invalidation

////////////////////////////////////////////////////////////////////////////
// GLay ADDRESS Mappings on AFU and HOST
////////////////////////////////////////////////////////////////////////////

// ********************************************************************************************
// ***************                  MMIO/Scalar General                          **************
// ********************************************************************************************

    parameter GRAPH_CSR_STRUCT_OFFSET   = 7'h10;
    parameter VERTEX_OUT_DEGREE_OFFSET  = 7'h1c;
    parameter VERTEX_IN_DEGREE_OFFSET   = 7'h28;
    parameter VERTEX_EDGES_IDX_OFFSET   = 7'h34;
    parameter EDGES_ARRAY_WEIGHT_OFFSET = 7'h40;
    parameter EDGES_ARRAY_SRC_OFFSET    = 7'h4c;
    parameter EDGES_ARRAY_DEST_OFFSET   = 7'h58;
    parameter AUXILIARY_1_OFFSET        = 7'h64;
    parameter AUXILIARY_2_OFFSET        = 7'h70;

// ********************************************************************************************
// ***************                  GLOBAL MEMORY(DDR4/HBM)                      **************
// ***************                  ALVEO 250 -> 4  banks (300MHz)               **************
// ***************                  ALVEO 250 -> 32 banks (300/500MHz)           **************
// ********************************************************************************************



endpackage