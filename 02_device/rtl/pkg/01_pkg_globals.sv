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
`include "global_timescale.vh"
package PKG_GLOBALS;

// ********************************************************************************************
// ***************                  GLOBAL MEMORY(DDR4/HBM)                      **************
// ***************                  ALVEO 250 -> 4  banks (300MHz)               **************
// ***************                  ALVEO 280 -> 32 banks (300/500MHz)           **************
// ********************************************************************************************

// --------------------------------------------------------------------------------------
//  COMPUTE UNITS GLOBALS
// --------------------------------------------------------------------------------------
//  Topology config-- include is auto generated
// --------------------------------------------------------------------------------------
`include "config_parameters.vh"
// -- include is auto generated
// parameter NUM_CUS     = 1;
// parameter NUM_BUNDLES = 4;
// parameter NUM_LANES   = 4;
// parameter NUM_ENGINES = 2;
// parameter NUM_MODULES = 3;
// parameter NUM_CUS_WIDTH_BITS     = 1;
// parameter NUM_BUNDLES_WIDTH_BITS = 4;
// parameter NUM_LANES_WIDTH_BITS   = 4;
// parameter NUM_ENGINES_WIDTH_BITS = 2;
// parameter NUM_MODULES_WIDTH_BITS = 3;
// parameter NUM_CHANNELS           = 1;
// parameter CU_PACKET_SEQUENCE_ID_WIDTH_BITS = $clog2((CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE*NUM_BUNDLES)+(16*NUM_BUNDLES));
// parameter BUFFER_0_WIDTH_BITS = 64;
// parameter BUFFER_1_WIDTH_BITS = 64;
// parameter BUFFER_2_WIDTH_BITS = 64;
// parameter BUFFER_3_WIDTH_BITS = 64;
// parameter BUFFER_4_WIDTH_BITS = 64;
// parameter BUFFER_5_WIDTH_BITS = 64;
// parameter BUFFER_6_WIDTH_BITS = 64;
// parameter BUFFER_7_WIDTH_BITS = 64;
// parameter BUFFER_8_WIDTH_BITS = 64;
// parameter BUFFER_9_WIDTH_BITS = 64;
// -- include is auto generated --
// --------------------------------------------------------------------------------------
// Maximum supported engines/lanes/bundles/buffers
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
parameter CU_KERNEL_COUNT_MAX_WIDTH_BITS   = 8;
parameter CU_BUNDLE_COUNT_MAX_WIDTH_BITS   = 8;
parameter CU_LANE_COUNT_MAX_WIDTH_BITS     = 8;
parameter CU_ENGINE_COUNT_MAX_WIDTH_BITS   = 8;
parameter CU_MODULE_COUNT_MAX_WIDTH_BITS   = 8;
parameter CU_CHANNELS_COUNT_MAX_WIDTH_BITS = 8;
parameter CU_BUFFER_COUNT_WIDTH_BITS       = 8;

parameter GLOBAL_OVERLAY_SIZE_WIDTH_BITS = 12; // 4*2^10 entries max or 4KB
parameter GLOBAL_BUFFER_SIZE_WIDTH_BITS  = 32; // 4*2^30 Buffers max or 4GB

// --------------------------------------------------------------------------------------
//  KERNEL COMMON GLOBALS
// --------------------------------------------------------------------------------------
//  CU -> Cache Changing these values would change the cache front end
// --------------------------------------------------------------------------------------
parameter GLOBAL_SYSTEM_CACHE_IP = 1;
parameter GLOBAL_CU_CACHE_IP     = 1;
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
//  KERNEL COMMON GLOBALS
// --------------------------------------------------------------------------------------
//  CU -> Cache Changing these values would change the cache front end
// --------------------------------------------------------------------------------------
parameter GLOBAL_SYSTEM_STREAM_IP = 0;
parameter GLOBAL_CU_STREAM_IP     = 1;
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
//   State Machine input sync
// --------------------------------------------------------------------------------------
typedef enum logic[4:0] {
	CU_ENGINE_M_AXI_RESET     = 1 << 0,
	CU_ENGINE_M_AXI_READY     = 1 << 1,
	CU_ENGINE_M_AXI_CMD_TRANS = 1 << 2,
	CU_ENGINE_M_AXI_PEND      = 1 << 3,
	CU_ENGINE_M_AXI_DONE      = 1 << 4
} cu_engine_m_axi_state;

endpackage