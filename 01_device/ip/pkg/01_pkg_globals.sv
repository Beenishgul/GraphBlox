// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_GLOBALS.sv
// Create : 2022-11-16 19:43:34
// Revise : 2022-11-16 19:43:34
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1 ns / 1 ps
package PKG_GLOBALS;

	import PKG_AXI4::*;
// --------------------------------------------------------------------------------------
//  COMPUTE UNITS COUNT GLOBALS
// --------------------------------------------------------------------------------------

	parameter CU_COUNT_GLOBAL     = 1                                      ;
	parameter CU_COUNT_LOCAL      = 1                                      ;
	parameter CU_CACHE_SIZE_BYTES = 32768                                  ; // size in Bytes 32KB
	parameter CU_CACHE_LINES_NUM  = CU_CACHE_SIZE_BYTES / (M_AXI4_DATA_W/8); // size in lines 512 (cacheline 64Bytes)

	parameter CU_ENGINES_COUNT_TOTAL = 64                            ;
	parameter CU_ENGINE_ID_BITS      = $clog2(CU_ENGINES_COUNT_TOTAL);

// --------------------------------------------------------------------------------------
//  GLay COMMON graph GLOBALS
// --------------------------------------------------------------------------------------
	parameter GLOBAL_ADDR_WIDTH_BITS = 64;
	parameter GLOBAL_DATA_WIDTH_BITS = 32;

// --------------------------------------------------------------------------------------
// AXI4 PARAMETERS
// --------------------------------------------------------------------------------------

	parameter S_AXI_CONTROL_ADDR_WIDTH_BITS = S_AXI_ADDR_WIDTH_BITS;
	parameter S_AXI_CONTROL_DATA_WIDTH      = S_AXI_DATA_WIDTH     ;

	parameter M_AXI_MEMORY_ADDR_WIDTH      = M_AXI4_ADDR_W  ;
	parameter M_AXI_MEMORY_DATA_WIDTH_BITS = M_AXI4_DATA_W  ;
	parameter M_AXI_MEMORY_ID_WIDTH        = M_AXI4_ID_W    ;
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

// ********************************************************************************************
// ***************                  MMIO/Scalar General                          **************
// ********************************************************************************************

	parameter BUFFER_1_OFFSET = 7'h10; // GRAPH_CSR_STRUCT_OFFSET
	parameter BUFFER_2_OFFSET = 7'h1c; // VERTEX_OUT_DEGREE_OFFSET
	parameter BUFFER_3_OFFSET = 7'h28; // VERTEX_IN_DEGREE_OFFSET
	parameter BUFFER_4_OFFSET = 7'h34; // VERTEX_EDGES_IDX_OFFSET
	parameter BUFFER_5_OFFSET = 7'h40; // EDGES_ARRAY_WEIGHT_OFFSET
	parameter BUFFER_6_OFFSET = 7'h4c; // EDGES_ARRAY_SRC_OFFSET
	parameter BUFFER_7_OFFSET = 7'h58; // EDGES_ARRAY_DEST_OFFSET
	parameter BUFFER_8_OFFSET = 7'h64; // AUXILIARY_1_OFFSET
	parameter BUFFER_9_OFFSET = 7'h70; // AUXILIARY_2_OFFSET

// ********************************************************************************************
// ***************                  GLOBAL MEMORY(DDR4/HBM)                      **************
// ***************                  ALVEO 250 -> 4  banks (300MHz)               **************
// ***************                  ALVEO 250 -> 32 banks (300/500MHz)           **************
// ********************************************************************************************



endpackage