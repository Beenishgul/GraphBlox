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
// Revise : 2023-08-28 14:41:10
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
package PKG_GLOBALS;

// ********************************************************************************************
// ***************                  GLOBAL MEMORY(DDR4/HBM)                      **************
// ***************                  ALVEO 250 -> 4  banks (300MHz)               **************
// ***************                  ALVEO 280 -> 32 banks (300/500MHz)           **************
// ********************************************************************************************

// --------------------------------------------------------------------------------------
//  COMPUTE UNITS GLOBALS
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// Maximum supported engines/lanes/bundles/buffers
// --------------------------------------------------------------------------------------
	parameter CU_KERNEL_COUNT_TOTAL       = 8 ;
	parameter CU_BUNDLE_COUNT_TOTAL       = 8 ;
	parameter CU_LANE_COUNT_TOTAL         = 8 ;
	parameter CU_ENGINE_COUNT_TOTAL       = 8 ;
	parameter CU_MODULE_COUNT_TOTAL       = 8 ;
	parameter CU_BUFFER_COUNT_TOTAL       = 8 ;
	parameter CU_PACKET_SEQ_ID_WIDTH_BITS = 16;

// --------------------------------------------------------------------------------------
	parameter CU_KERNEL_COUNT_WIDTH_BITS = CU_KERNEL_COUNT_TOTAL;
	parameter CU_BUNDLE_COUNT_WIDTH_BITS = CU_BUNDLE_COUNT_TOTAL;
	parameter CU_LANE_COUNT_WIDTH_BITS   = CU_LANE_COUNT_TOTAL  ;
	parameter CU_ENGINE_COUNT_WIDTH_BITS = CU_ENGINE_COUNT_TOTAL;
	parameter CU_MODULE_COUNT_WIDTH_BITS = CU_MODULE_COUNT_TOTAL;
	parameter CU_BUFFER_COUNT_WIDTH_BITS = CU_BUFFER_COUNT_TOTAL;

// --------------------------------------------------------------------------------------
//  KERNEL COMMON GLOBALS
// --------------------------------------------------------------------------------------
//  CU -> Cache Changing these values would change the cache front end
// --------------------------------------------------------------------------------------
	parameter GLOBAL_SYSTEM_CACHE_IP = 1 ;
	parameter GLOBAL_CU_CACHE_IP     = 0 ;
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
//   State Machine input sync
// --------------------------------------------------------------------------------------
typedef enum logic[4:0] {
	CU_ENGINE_M_AXI_RESET        = 1 << 0,
	CU_ENGINE_M_AXI_READY        = 1 << 1,
	CU_ENGINE_M_AXI_CMD_TRANS    = 1 << 2,
	CU_ENGINE_M_AXI_PEND         = 1 << 3,
	CU_ENGINE_M_AXI_DONE         = 1 << 4
} cu_engine_m_axi_state;

endpackage