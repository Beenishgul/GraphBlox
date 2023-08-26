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
// Revise : 2023-08-26 00:27:01
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1 ns / 1 ps
package PKG_GLOBALS;

	import PKG_AXI4::*;
// --------------------------------------------------------------------------------------
//  COMPUTE UNITS GLOBALS
// --------------------------------------------------------------------------------------
// Kernel current settings engines/lanes/bundles/buffers
	parameter KERNEL_CU_COUNT = 1 ;
	parameter CU_BUNDLE_COUNT = 4 ;
	parameter CU_ENGINE_COUNT = 8 ;
	parameter CU_BUFFER_COUNT = 10;

// Maximum supported engines/lanes/bundles/buffers
	parameter CU_KERNEL_COUNT_TOTAL = 8 ;
	parameter CU_BUNDLE_COUNT_TOTAL = 8 ;
	parameter CU_LANE_COUNT_TOTAL   = 8 ;
	parameter CU_ENGINE_COUNT_TOTAL = 8 ;
	parameter CU_BUFFER_COUNT_TOTAL = 10;

	parameter CU_KERNEL_COUNT_WIDTH_BITS = CU_KERNEL_COUNT_TOTAL; // 5
	parameter CU_BUNDLE_COUNT_WIDTH_BITS = CU_BUNDLE_COUNT_TOTAL        ;
	parameter CU_LANE_COUNT_WIDTH_BITS   = CU_LANE_COUNT_TOTAL          ;
	parameter CU_ENGINE_COUNT_WIDTH_BITS = CU_ENGINE_COUNT_TOTAL        ;
	parameter CU_BUFFER_COUNT_WIDTH_BITS = CU_BUFFER_COUNT_TOTAL        ;

// --------------------------------------------------------------------------------------
//  KERNEL COMMON GLOBALS 
// --------------------------------------------------------------------------------------
//  CU -> Cache Changing these values would change the cache front end 
// --------------------------------------------------------------------------------------
	parameter GLOBAL_ADDR_WIDTH_BITS = 64;
	parameter GLOBAL_DATA_WIDTH_BITS = 32;

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
	parameter S_AXI_CONTROL_ADDR_WIDTH_BITS = S_AXI_ADDR_WIDTH_BITS;
	parameter S_AXI_CONTROL_DATA_WIDTH      = S_AXI_DATA_WIDTH     ;

	parameter M_AXI_MEMORY_ADDR_WIDTH      = M_AXI4_ADDR_W  ;
	parameter M_AXI_MEMORY_DATA_WIDTH_BITS = M_AXI4_DATA_W  ;
	parameter M_AXI_MEMORY_BURST_W         = M_AXI4_BURST_W ;
	parameter M_AXI_MEMORY_CACHE_W         = M_AXI4_CACHE_W ;
	parameter M_AXI_MEMORY_PROT_W          = M_AXI4_PROT_W  ;
	parameter M_AXI_MEMORY_REGION_W        = M_AXI4_REGION_W;
	parameter M_AXI_MEMORY_USER_W          = M_AXI4_USER_W  ;
	parameter M_AXI_MEMORY_LOCK_W          = M_AXI4_LOCK_W  ;
	parameter M_AXI_MEMORY_QOS_W           = M_AXI4_QOS_W   ;
	parameter M_AXI_MEMORY_LEN_W           = M_AXI4_LEN_W   ;
	parameter M_AXI_MEMORY_SIZE_W          = M_AXI4_SIZE_W  ;
	parameter M_AXI_MEMORY_RESP_W          = M_AXI4_RESP_W  ;
	parameter M_AXI_MEMORY_ID_W            = M_AXI4_ID_W    ;

endpackage