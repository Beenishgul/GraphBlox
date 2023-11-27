// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : 02_pkg_cache.sv
// Create : 2022-11-16 19:43:34
// Revise : 2023-08-21 04:07:30
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
`include "global_timescale.vh"
package PKG_CACHE;

import PKG_GLOBALS::*;
import PKG_AXI4_FE::*;
import PKG_AXI4_MID::*;
import PKG_AXI4_BE::*;

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// CACHE PARAMETERS GENERAL
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

//Replacement Policy
parameter CACHE_LRU       = 0; // Least Recently Used -- more resources intensive - N*log2(N) bits per cache line - Uses counters
parameter CACHE_PLRU_MRU  = 1; // bit-based Pseudo-Least-Recently-Used, a simpler replacement policy than LRU, using a much lower complexity (lower resources) - N bits per cache line
parameter CACHE_PLRU_TREE = 2; // tree-based Pseudo-Least-Recently-Used, uses a tree that updates after any way received an hit, and points towards the oposing one. Uses less resources than bit-pseudo-lru - N-1 bits per cache line

//Write Policy
parameter CACHE_WRITE_THROUGH = 0; //write-through not allocate: implements a write-through buffer
parameter CACHE_WRITE_BACK    = 1; //write-back allocate: implemented a dirty-memory

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// CACHE PARAMETERS
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
parameter CACHE_FRONTEND_ADDR_W = M_AXI4_FE_ADDR_W; //Address width - width of the Master's entire access address (including the LSBs that are discarded, but discarding the Controller's)
parameter CACHE_FRONTEND_DATA_W = M_AXI4_FE_DATA_W; //Data width - word size used for the cache
parameter CACHE_N_WAYS          = 1               ; //Number of Cache Ways (Needs to be Potency of 2: 1, 2, 4, 8, ..)
parameter CACHE_LINE_OFF_W      = 12              ; //Line-Offset Width - 2**NLINE_W total cache lines
parameter CACHE_WTBUF_DEPTH_W   = $clog2(32)      ; //Depth Width of Write-Through Buffer
//Replacement policy (CACHE_N_WAYS > 1)
parameter CACHE_REP_POLICY = CACHE_PLRU_TREE; //LRU - Least Recently Used; PLRU_mru (1) - MRU-based pseudoLRU; PLRU_tree (3) - tree-based pseudoLRU
//Do NOT change - memory cache's parameters - dependency
parameter CACHE_NWAY_W          = $clog2(CACHE_N_WAYS)         ; //Cache Ways Width
parameter CACHE_FRONTEND_NBYTES = CACHE_FRONTEND_DATA_W/8      ; //Number of Bytes per Word
parameter CACHE_FRONTEND_BYTE_W = $clog2(CACHE_FRONTEND_NBYTES); //Byte Offset
/*---------------------------------------------------*/
//Higher hierarchy memory (slave) interface parameters
parameter CACHE_BACKEND_ADDR_W = M_AXI4_MID_ADDR_W           ; //Address width of the higher hierarchy memory
parameter CACHE_BACKEND_DATA_W = M_AXI4_MID_DATA_W           ; //Data width of the memory
parameter CACHE_BACKEND_NBYTES = CACHE_BACKEND_DATA_W/8      ; //Number of bytes
parameter CACHE_BACKEND_BYTE_W = $clog2(CACHE_BACKEND_NBYTES); //Offset of Number of Bytes
//Cache-Memory base Offset
parameter CACHE_WORD_OFF_W = $clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W); //Word-Offset Width - 2**OFFSET_W total CACHE_FRONTEND_DATA_W words per line - WARNING about LINE2MEM_DATA_RATIO_W (can cause word_counter [-1:0]
/*---------------------------------------------------*/
//Write Policy
// parameter CACHE_WRITE_POL = CACHE_WRITE_BACK; //write policy: write-through (0), write-back (1)
parameter CACHE_WRITE_POL = CACHE_WRITE_THROUGH; //write policy: write-through (0), write-back (1)
//Controller's options
parameter CACHE_CTRL_CACHE = 0; //Adds a Controller to the cache, to use functions sent by the master or count the hits and misses
parameter CACHE_CTRL_CNT   = 0; //Counters for Cache Hits and Misses - Disabling this and previous, the Controller only store the buffer states and allows cache invalidation

/*---------------------------------------------------*/
//AXI specific parameters
parameter                      CACHE_AXI_ADDR_W  = CACHE_BACKEND_ADDR_W;
parameter                      CACHE_AXI_DATA_W  = CACHE_BACKEND_DATA_W;
parameter                      CACHE_AXI_ID_W    = M_AXI4_MID_ID_W     ; //AXI ID (identification) width
parameter                      CACHE_AXI_LEN_W   = M_AXI4_MID_LEN_W    ; //AXI ID burst length (log2)
parameter                      CACHE_AXI_LOCK_W  = M_AXI4_MID_LOCK_W   ;
parameter                      CACHE_AXI_CACHE_W = M_AXI4_MID_CACHE_W  ;
parameter                      CACHE_AXI_PROT_W  = M_AXI4_MID_PROT_W   ;
parameter                      CACHE_AXI_QOS_W   = M_AXI4_MID_QOS_W    ;
parameter                      CACHE_AXI_BURST_W = M_AXI4_MID_BURST_W  ;
parameter                      CACHE_AXI_RESP_W  = M_AXI4_MID_RESP_W   ;
parameter                      CACHE_AXI_SIZE_W  = M_AXI4_MID_SIZE_W   ;

parameter [CACHE_AXI_ID_W-1:0] CACHE_AXI_ID      = 0                   ; //AXI ID value

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// CACHE FLUSH GENERAL
// --------------------------------------------------------------------------------------
parameter SYSTEM_CACHE_NUM_WAYS       = 4                                                                                  ;
parameter SYSTEM_CACHE_ADDR_WIDTH     = 63                                                                                 ;
parameter SYSTEM_CACHE_DATA_WIDTH     = CACHE_BACKEND_NBYTES                                                               ;
parameter SYSTEM_CACHE_LINE_SIZE_LOG  = $clog2(SYSTEM_CACHE_DATA_WIDTH)                                                    ;
parameter SYSTEM_CACHE_SIZE           = 65536    
// parameter SYSTEM_CACHE_SIZE           = __SYSTEM_CACHE_SIZE_B__                                                                           ; // Define the total size of the cache
parameter SYSTEM_CACHE_NUM_SETS       = (SYSTEM_CACHE_SIZE >> (SYSTEM_CACHE_LINE_SIZE_LOG + $clog2(SYSTEM_CACHE_NUM_WAYS))); // Adjusted for shift operations
parameter SYSTEM_CACHE_SIZE_ITERAIONS = SYSTEM_CACHE_NUM_WAYS * SYSTEM_CACHE_NUM_SETS                                      ;
parameter SYSTEM_CACHE_COUNT          = SYSTEM_CACHE_NUM_SETS * SYSTEM_CACHE_NUM_WAYS                                      ;

// Optimized address calculation using shift operations
// read char *addr = base_address + (((counter >> $clog2(SYSTEM_CACHE_NUM_WAYS)) << (SYSTEM_CACHE_LINE_SIZE_LOG + $clog2(SYSTEM_CACHE_NUM_WAYS))) | (counter & (SYSTEM_CACHE_NUM_WAYS-1) << SYSTEM_CACHE_LINE_SIZE_LOG));
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
//   State Machine input sync
// --------------------------------------------------------------------------------------
typedef enum logic[9:0] {
	CU_CACHE_CMD_RESET        = 1 << 0,
	CU_CACHE_CMD_READY        = 1 << 1,
	CU_CACHE_CMD_READ_TRANS   = 1 << 2,
	CU_CACHE_CMD_READ         = 1 << 3,
	CU_CACHE_CMD_WRITE_TRANS  = 1 << 4,
	CU_CACHE_CMD_WRITE        = 1 << 5,
	CU_CACHE_CMD_PENDING      = 1 << 6,
	CU_CACHE_CMD_POP_TRANS    = 1 << 7,
	CU_CACHE_CMD_POP          = 1 << 8,
	CU_CACHE_CMD_DONE         = 1 << 9
} cu_cache_command_generator_state;




endpackage