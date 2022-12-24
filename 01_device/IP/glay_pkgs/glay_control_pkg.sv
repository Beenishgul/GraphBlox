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

    typedef struct packed{
        logic glay_ready;
    } GlayControlChainInputSyncInterfaceOutput;

    typedef enum int unsigned {
        CTRL_IN_RESET,
        CTRL_IN_IDLE,
        CTRL_IN_START_S1,
        CTRL_IN_READY,
        CTRL_IN_START_S2,
        CTRL_IN_BUSY
    } control_input_state;

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN output sync
// --------------------------------------------------------------------------------------

    typedef struct packed{
        logic glay_done    ;
        logic glay_idle    ;
    } GlayControlChainOutputSyncInterfaceOutput;

    typedef enum int unsigned {
        CTRL_OUT_RESET,
        CTRL_OUT_IDLE,
        CTRL_OUT_DONE,
        CTRL_OUT_CONTINUE,
        CTRL_OUT_BUSY
    } control_output_state;

endpackage
