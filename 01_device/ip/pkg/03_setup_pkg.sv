// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : setup_pkg.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


`timescale 1 ns / 1 ps
package SETUP_PKG;

import GLOBALS_PKG::*;

// --------------------------------------------------------------------------------------
//   State Machine Setup Requests
// --------------------------------------------------------------------------------------

typedef enum int unsigned {
  SETUP_KERNEL_RESET,
  SETUP_KERNEL_IDLE,
  SETUP_KERNEL_REQ_START,
  SETUP_KERNEL_REQ_BUSY,
  SETUP_KERNEL_REQ_DONE
} kernel_setup_state;


endpackage
