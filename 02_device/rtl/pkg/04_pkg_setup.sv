// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : 04_pkg_setup.sv
// Create : 2022-11-29 16:14:59
// Revise : 2023-06-19 00:22:31
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------


`include "global_timescale.vh"
package PKG_SETUP;

// --------------------------------------------------------------------------------------
//   State Machine Setup Requests
// --------------------------------------------------------------------------------------

  typedef enum logic[9:0] {
    CU_SETUP_RESET       = 1 << 0, // 000001
    CU_SETUP_IDLE        = 1 << 1, // 000010
    CU_SETUP_REQ_START   = 1 << 2, // 000100
    CU_SETUP_REQ_BUSY    = 1 << 3, // 001000
    CU_SETUP_REQ_PAUSE   = 1 << 4, // 010000
    CU_SETUP_REQ_DONE    = 1 << 5, // 100000
    CU_SETUP_FLUSH_START = 1 << 6, // 000100
    CU_SETUP_FLUSH_BUSY  = 1 << 7, // 001000
    CU_SETUP_FLUSH_PAUSE = 1 << 8, // 010000
    CU_SETUP_FLUSH_DONE  = 1 << 9  // 100000
  } cu_setup_state;

endpackage
