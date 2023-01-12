// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_control_pkg.sv
// Create : 2022-12-20 21:55:24
// Revise : 2022-12-20 21:55:24
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


`timescale 1 ns / 1 ps
package GLAY_CONTROL_PKG;

    import GLAY_GLOBALS_PKG::*;

    typedef struct packed{
        logic glay_start   ;
        logic glay_continue;
    } GlayControlChainInterfaceInput;

    typedef struct packed{
        logic glay_ready;
        logic glay_done ;
        logic glay_idle ;
    } GlayControlChainInterfaceOutput;

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN input sync
// --------------------------------------------------------------------------------------

    typedef enum int unsigned {
        CTRL_SYNC_RESET,
        CTRL_SYNC_IDLE,
        CTRL_SYNC_SETUP,
        CTRL_SYNC_READY,
        CTRL_SYNC_START,
        CTRL_SYNC_BUSY,
        CTRL_SYNC_DONE
    } control_sync_state;

endpackage
