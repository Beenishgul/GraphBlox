// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : 01_pkg_globals.sv
// Create : 2022-11-16 19:43:34
// Revise : 2023-06-17 00:42:31
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

#ifndef PKG_GLOBALS_HPP
#define PKG_GLOBALS_HPP

#include <cmath>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <cstdlib>
using namespace std;

	#include “00_pkg_axi4.hpp”
	#include “03_pkg_functions.hpp”
// --------------------------------------------------------------------------------------
//  COMPUTE UNITS GLOBALS
// --------------------------------------------------------------------------------------
 
// Kernel current settings engines/lanes/bundles/buffers
	#define KERNEL_CU_COUNT 1 
	#define CU_BUNDLE_COUNT 4 
	#define CU_ENGINE_COUNT 8 
	#define CU_BUFFER_COUNT 10

// Maximum supported engines/lanes/bundles/buffers
	#define KERNEL_CU_COUNT_TOTAL 64
	#define CU_BUNDLE_COUNT_TOTAL 8 
	#define CU_LANE_COUNT_TOTAL   8 
	#define CU_ENGINE_COUNT_TOTAL 8 
	#define CU_BUFFER_COUNT_TOTAL 10

	#define KERNEL_CU_COUNT_WIDTH_BITS pkg_clog2(KERNEL_CU_COUNT_TOTAL) //$clog(KERNEL_CU_COUNT_TOTAL) // 5
	#define CU_BUNDLE_COUNT_WIDTH_BITS CU_BUNDLE_COUNT_TOTAL        
	#define CU_LANE_COUNT_WIDTH_BITS   CU_LANE_COUNT_TOTAL          
	#define CU_ENGINE_COUNT_WIDTH_BITS CU_ENGINE_COUNT_TOTAL        
	#define CU_BUFFER_COUNT_WIDTH_BITS CU_BUFFER_COUNT_TOTAL        

// --------------------------------------------------------------------------------------
//  KERNEL COMMON GLOBALS 
// --------------------------------------------------------------------------------------
//  CU -> Cache Changing these values would change the cache front end 
// --------------------------------------------------------------------------------------
	#define GLOBAL_ADDR_WIDTH_BITS 64
	#define GLOBAL_DATA_WIDTH_BITS 32

// ********************************************************************************************
// ***************                  GLOBAL MEMORY(DDR4/HBM)                      **************
// ***************                  ALVEO 250 -> 4  banks (300MHz)               **************
// ***************                  ALVEO 280 -> 32 banks (300/500MHz)           **************
// ********************************************************************************************
// --------------------------------------------------------------------------------------
// AXI4 PARAMETERS
// --------------------------------------------------------------------------------------
// Derived from AXI PKG settings also changes cache back-end Cache->AXI
// --------------------------------------------------------------------------------------
	#define S_AXI_CONTROL_ADDR_WIDTH_BITS S_AXI_ADDR_WIDTH_BITS
	#define S_AXI_CONTROL_DATA_WIDTH      S_AXI_DATA_WIDTH     

	#define M_AXI_MEMORY_ADDR_WIDTH      M_AXI4_ADDR_W  
	#define M_AXI_MEMORY_DATA_WIDTH_BITS M_AXI4_DATA_W  
	#define M_AXI_MEMORY_BURST_W         M_AXI4_BURST_W 
	#define M_AXI_MEMORY_CACHE_W         M_AXI4_CACHE_W 
	#define M_AXI_MEMORY_PROT_W          M_AXI4_PROT_W  
	#define M_AXI_MEMORY_REGION_W        M_AXI4_REGION_W
	#define M_AXI_MEMORY_USER_W          M_AXI4_USER_W  
	#define M_AXI_MEMORY_LOCK_W          M_AXI4_LOCK_W  
	#define M_AXI_MEMORY_QOS_W           M_AXI4_QOS_W   
	#define M_AXI_MEMORY_LEN_W           M_AXI4_LEN_W   
	#define M_AXI_MEMORY_SIZE_W          M_AXI4_SIZE_W  
	#define M_AXI_MEMORY_RESP_W          M_AXI4_RESP_W  
	#define M_AXI_MEMORY_ID_W            M_AXI4_ID_W    

#endif