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
// Revise : 2023-06-18 22:43:03
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
#ifndef PKG_CACHE_HPP
#define PKG_CACHE_HPP

#include <cmath>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <cstdlib>
using namespace std

#include “ap_int.h”
#include “00_pkg_axi4.hpp”
#include “01_pkg_gloabals.hpp”
#include “03_pkg_functions.hpp”

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// CACHE PARAMETERS GENERAL
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

//Replacement Policy
	#define CACHE_LRU        0 // Least Recently Used -- more resources intensive - N*log2(N) bits per cache line - Uses counters
	#define CACHE_PLRU_MRU   1 // bit-based Pseudo-Least-Recently-Used, a simpler replacement policy than LRU, using a much lower complexity (lower resources) - N bits per cache line
	#define CACHE_PLRU_TREE  2 // tree-based Pseudo-Least-Recently-Used, uses a tree that updates after any way received an hit, and points towards the oposing one. Uses less resources than bit-pseudo-lru - N-1 bits per cache line

//Write Policy
	#define CACHE_WRITE_THROUGH  0 //write-through not allocate: implements a write-through buffer
	#define CACHE_WRITE_BACK     1 //write-back allocate: implemented a dirty-memory

// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// CACHE PARAMETERS
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
	#define CACHE_FRONTEND_ADDR_W  GLOBAL_ADDR_WIDTH_BITS //Address width - width of the Master's entire access address (including the LSBs that are discarded, but discarding the Controller's)
	#define CACHE_FRONTEND_DATA_W  GLOBAL_DATA_WIDTH_BITS //Data width - word size used for the cache
	#define CACHE_N_WAYS           4                      //Number of Cache Ways (Needs to be Potency of 2: 1, 2, 4, 8, ..)
	#define CACHE_LINE_OFF_W       4                      //Line-Offset Width - 2**NLINE_W total cache lines
	#define CACHE_WTBUF_DEPTH_W    pkg_clog2(32)             //Depth Width of Write-Through Buffer
//Replacement policy (CACHE_N_WAYS > 1)
	#define CACHE_REP_POLICY  CACHE_PLRU_TREE //LRU - Least Recently Used PLRU_mru (1) - MRU-based pseudoLRU PLRU_tree (3) - tree-based pseudoLRU
//Do NOT change - memory cache's #defines - dependency
	#define CACHE_NWAY_W           pkg_clog2(CACHE_N_WAYS)          //Cache Ways Width
	#define CACHE_FRONTEND_NBYTES  CACHE_FRONTEND_DATA_W/8       //Number of Bytes per Word
	#define CACHE_FRONTEND_BYTE_W  pkg_clog2(CACHE_FRONTEND_NBYTES) //Byte Offset
/*---------------------------------------------------*/
//Higher hierarchy memory (slave) interface #defines
	#define CACHE_BACKEND_ADDR_W  M_AXI_MEMORY_ADDR_WIDTH      //Address width of the higher hierarchy memory
	#define CACHE_BACKEND_DATA_W  M_AXI_MEMORY_DATA_WIDTH_BITS //Data width of the memory
	#define CACHE_BACKEND_NBYTES  CACHE_BACKEND_DATA_W/8       //Number of bytes
	#define CACHE_BACKEND_BYTE_W  pkg_clog2(CACHE_BACKEND_NBYTES) //Offset of Number of Bytes
//Cache-Memory base Offset
	#define CACHE_WORD_OFF_W  pkg_clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W) //Word-Offset Width - 2**OFFSET_W total CACHE_FRONTEND_DATA_W words per line - WARNING about LINE2MEM_DATA_RATIO_W (can cause word_counter [-1:0]
/*---------------------------------------------------*/
//Write Policy
	// #define CACHE_WRITE_POL  CACHE_WRITE_BACK //write policy: write-through (0), write-back (1)
	#define CACHE_WRITE_POL  CACHE_WRITE_THROUGH //write policy: write-through (0), write-back (1)
//Controller's options
	#define CACHE_CTRL_CACHE  0 //Adds a Controller to the cache, to use functions sent by the master or count the hits and misses
	#define CACHE_CTRL_CNT    0 //Counters for Cache Hits and Misses - Disabling this and previous, the Controller only store the buffer states and allows cache invalidation

/*---------------------------------------------------*/
//AXI specific #defines
	#define                      CACHE_AXI_ADDR_W   CACHE_BACKEND_ADDR_W
	#define                      CACHE_AXI_DATA_W   CACHE_BACKEND_DATA_W
	#define                      CACHE_AXI_ID_W     M_AXI_MEMORY_ID_W    //AXI ID (identification) width
	#define                      CACHE_AXI_LEN_W    M_AXI_MEMORY_LEN_W   //AXI ID burst length (log2)
	#define                      CACHE_AXI_LOCK_W   M_AXI_MEMORY_LOCK_W 
	#define                      CACHE_AXI_CACHE_W  M_AXI_MEMORY_CACHE_W
	#define                      CACHE_AXI_PROT_W   M_AXI_MEMORY_PROT_W 
	#define                      CACHE_AXI_QOS_W    M_AXI_MEMORY_QOS_W  
	#define                      CACHE_AXI_BURST_W  M_AXI_MEMORY_BURST_W
	#define                      CACHE_AXI_RESP_W   M_AXI_MEMORY_RESP_W 
	#define                      CACHE_AXI_SIZE_W   M_AXI_MEMORY_SIZE_W 

	typedef ap_uint<CACHE_AXI_ID_W> CACHE_AXI_ID;//AXI ID value


#endif