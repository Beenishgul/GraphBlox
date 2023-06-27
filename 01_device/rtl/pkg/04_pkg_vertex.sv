// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_VERTEX.sv
// Create : 2022-11-16 19:43:34
// Revise : 2022-11-16 19:43:34
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------
`timescale 1 ns / 1 ps
package PKG_VERTEX;

  import PKG_GLOBALS::*;

// --------------------------------------------------------------------------------------
//   State Machine Vertex CU
// --------------------------------------------------------------------------------------
  typedef enum logic[5:0] {
    VERTEX_CU_RESET,
    VERTEX_CU_IDLE,
    VERTEX_CU_REQ_START,
    VERTEX_CU_REQ_BUSY,
    VERTEX_CU_REQ_PAUSE,
    VERTEX_CU_REQ_DONE
  } vertex_cu_state;

// --------------------------------------------------------------------------------------
//   State Machine Vertex Bundles
// --------------------------------------------------------------------------------------
  typedef enum logic[5:0] {
    VERTEX_BUNDLES_RESET,
    VERTEX_BUNDLES_IDLE,
    VERTEX_BUNDLES_REQ_START,
    VERTEX_BUNDLES_REQ_BUSY,
    VERTEX_BUNDLES_REQ_PAUSE,
    VERTEX_BUNDLES_REQ_DONE
  } vertex_bundles_state;

endpackage