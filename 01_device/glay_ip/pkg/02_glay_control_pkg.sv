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
        logic glay_setup   ;
    } GlayControlChainInterfaceInput;

    typedef struct packed{
        logic glay_ready ;
        logic glay_done  ;
        logic glay_idle  ;
        logic glay_enable;
    } GlayControlChainInterfaceOutput;

// --------------------------------------------------------------------------------------
//   State Machine USER_MANAGED input sync
// --------------------------------------------------------------------------------------

    typedef enum int unsigned {
        USER_MANAGED_SYNC_RESET,
        USER_MANAGED_SYNC_IDLE,
        USER_MANAGED_SYNC_SETUP,
        USER_MANAGED_SYNC_READY,
        USER_MANAGED_SYNC_START,
        USER_MANAGED_SYNC_BUSY,
        USER_MANAGED_SYNC_DONE
    } control_sync_state_user_managed;

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN input sync
// --------------------------------------------------------------------------------------

    typedef enum int unsigned {
        CTRL_CHAIN_SYNC_RESET,
        CTRL_CHAIN_SYNC_IDLE,
        CTRL_CHAIN_SYNC_SETUP,
        CTRL_CHAIN_SYNC_READY,
        CTRL_CHAIN_SYNC_START,
        CTRL_CHAIN_SYNC_BUSY,
        CTRL_CHAIN_SYNC_DONE
    } control_sync_state_ap_ctrl_chain;


// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_HS input sync
// --------------------------------------------------------------------------------------

    typedef enum int unsigned {
        CTRL_HS_SYNC_RESET,
        CTRL_HS_SYNC_IDLE,
        CTRL_HS_SYNC_SETUP,
        CTRL_HS_SYNC_READY,
        CTRL_HS_SYNC_START,
        CTRL_HS_SYNC_BUSY,
        CTRL_HS_SYNC_DONE
    } control_sync_state_ap_ctrl_hs;


endpackage
