// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_SETUP.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


`timescale 1 ns / 1 ps
package PKG_SETUP;

import PKG_GLOBALS::*;

// --------------------------------------------------------------------------------------
//   State Machine Setup Requests
// --------------------------------------------------------------------------------------

typedef enum int unsigned {
  KERNEL_SETUP_RESET,
  KERNEL_SETUP_IDLE,
  KERNEL_SETUP_REQ_START,
  KERNEL_SETUP_REQ_BUSY,
  KERNEL_SETUP_REQ_DONE
} kernel_setup_state;


endpackage
