// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_globals_pkg.sv
// Create : 2022-11-12 20:24:25
// Revise : 2022-11-12 20:24:25
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

package GLAY_GLOBALS_PKG;

////////////////////////////////////////////////////////////////////////////
//  GLay COMMON GLOBALS
////////////////////////////////////////////////////////////////////////////
    parameter PAGE_SIZE                   = 4096                  ;// Page size default is 4KB
    parameter PAGE_SIZE_BITS              = (PAGE_SIZE * 8)        ;
    parameter CACHELINE_SIZE              = 64                     ; // cacheline is 64bytes
    parameter CACHELINE_SIZE_BITS         = (CACHELINE_SIZE * 8)   ;
    parameter CACHELINE_SIZE_HF           = (CACHELINE_SIZE >> 1)  ; // cacheline is 32bytes
    parameter CACHELINE_SIZE_BITS_HF      = (CACHELINE_SIZE_HF * 8);

    parameter WORD                        = 4              ;
    parameter WORD_BITS                   = WORD * 8       ;
    parameter WORD_DOUBLE                 = WORD * 2       ;
    parameter WORD_DOUBLE_BITS            = WORD_DOUBLE * 8;

////////////////////////////////////////////////////////////////////////////
// AXI4 PARAMETERS
////////////////////////////////////////////////////////////////////////////

    parameter S_AXI_CONTROL_ADDR_WIDTH_BITS = 12 ;
    parameter S_AXI_CONTROL_DATA_WIDTH      = 32 ;
    parameter M_AXI_MEMORY_ADDR_WIDTH       = 64 ;
    parameter M_AXI_MEMORY_DATA_WIDTH_BITS  = 512;
    parameter M_AXI_MEMORY_ID_WIDTH         = 1;
    parameter M_AXI_MEMORY_ID_VALUE         = 0;
    parameter M_AXI_MEMORY_BURST_LEN        = 8; 

////////////////////////////////////////////////////////////////////////////
// AXI4 CACHE PARAMETERS
////////////////////////////////////////////////////////////////////////////

    parameter FE_ADDR_W             = 64,       //Address width - width of the Master's entire access address (including the LSBs that are discarded, but discarding the Controller's)
    parameter FE_DATA_W             = 64,       //Data width - word size used for the cache
    parameter N_WAYS                = 2,        //Number of Cache Ways (Needs to be Potency of 2: 1, 2, 4, 8, ..)
    parameter LINE_OFF_W            = 7,     //Line-Offset Width - 2**NLINE_W total cache lines
    parameter WORD_OFF_W            = 3,      //Word-Offset Width - 2**OFFSET_W total FE_DATA_W words per line - WARNING about LINE2MEM_DATA_RATIO_W (can cause word_counter [-1:0]
    parameter WTBUF_DEPTH_W         = 5,   //Depth Width of Write-Through Buffer
    //Replacement policy (N_WAYS > 1)
    parameter REP_POLICY            = `PLRU_tree, //LRU - Least Recently Used; PLRU_mru (1) - MRU-based pseudoLRU; PLRU_tree (3) - tree-based pseudoLRU 
    //Do NOT change - memory cache's parameters - dependency
    parameter NWAY_W                = $clog2(N_WAYS),  //Cache Ways Width
    parameter FE_NBYTES             = FE_DATA_W/8,        //Number of Bytes per Word
    parameter FE_BYTE_W             = $clog2(FE_NBYTES), //Byte Offset
    /*---------------------------------------------------*/
    //Higher hierarchy memory (slave) interface parameters 
    parameter BE_ADDR_W             = FE_ADDR_W, //Address width of the higher hierarchy memory
    parameter BE_DATA_W             = FE_DATA_W, //Data width of the memory 
    parameter BE_NBYTES             = BE_DATA_W/8, //Number of bytes
    parameter BE_BYTE_W             = $clog2(BE_NBYTES), //Offset of Number of Bytes
    //Cache-Memory base Offset
    parameter LINE2MEM_W            = WORD_OFF_W-$clog2(BE_DATA_W/FE_DATA_W),//Logarithm Ratio between the size of the cache-line and the BE's data width 
    /*---------------------------------------------------*/
    //Write Policy 
    parameter WRITE_POL             = `WRITE_THROUGH, //write policy: write-through (0), write-back (1)
    /*---------------------------------------------------*/
    //AXI specific parameters
    parameter AXI_ADDR_W            = BE_ADDR_W,
    parameter AXI_DATA_W            = BE_DATA_W,
    parameter AXI_ID_W              = 1, //AXI ID (identification) width
    parameter AXI_LEN_W             = 8, //AXI ID burst length (log2)
    parameter [AXI_ID_W-1:0] AXI_ID = 0, //AXI ID value
    //Controller's options
    parameter CTRL_CACHE            = 0, //Adds a Controller to the cache, to use functions sent by the master or count the hits and misses
    parameter CTRL_CNT              = 1  //Counters for Cache Hits and Misses - Disabling this and previous, the Controller only store the buffer states and allows cache invalidation

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