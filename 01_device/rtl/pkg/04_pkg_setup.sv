// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
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


`timescale 1 ns / 1 ps
package PKG_SETUP;

  import PKG_GLOBALS::*;

// --------------------------------------------------------------------------------------
//   State Machine Setup Requests
// --------------------------------------------------------------------------------------

  typedef enum logic[5:0] {
    CU_SETUP_RESET,
    CU_SETUP_IDLE,
    CU_SETUP_REQ_START,
    CU_SETUP_REQ_BUSY,
    CU_SETUP_REQ_PAUSE,
    CU_SETUP_REQ_DONE
  } cu_setup_state;


endpackage
