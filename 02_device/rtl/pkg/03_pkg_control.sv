// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_CONTROL.sv
// Create : 2022-12-20 21:55:24
// Revise : 2022-12-20 21:55:24
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------


`include "global_timescale.vh"
package PKG_CONTROL;

    typedef struct packed{
        logic ap_start   ;
        logic ap_continue;
        logic setup      ;
        logic done       ;
    } ControlChainInterfaceInput;

    typedef struct packed{
        logic ap_ready;
        logic ap_done ;
        logic ap_idle ;
        logic start   ;
        logic endian  ;
    } ControlChainInterfaceOutput;

// --------------------------------------------------------------------------------------
//   State Machine USER_MANAGED input sync
// --------------------------------------------------------------------------------------

    typedef enum logic[6:0] {
        USER_MANAGED_SYNC_RESET = 1 << 0,
        USER_MANAGED_SYNC_IDLE  = 1 << 1,
        USER_MANAGED_SYNC_SETUP = 1 << 2,
        USER_MANAGED_SYNC_READY = 1 << 3,
        USER_MANAGED_SYNC_START = 1 << 4,
        USER_MANAGED_SYNC_BUSY  = 1 << 5,
        USER_MANAGED_SYNC_DONE  = 1 << 6
    } control_sync_state_user_managed;

// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_CHAIN input sync
// --------------------------------------------------------------------------------------

    typedef enum logic[6:0] {
        CTRL_CHAIN_SYNC_RESET = 1 << 0,
        CTRL_CHAIN_SYNC_IDLE  = 1 << 1,
        CTRL_CHAIN_SYNC_SETUP = 1 << 2,
        CTRL_CHAIN_SYNC_READY = 1 << 3,
        CTRL_CHAIN_SYNC_START = 1 << 4,
        CTRL_CHAIN_SYNC_BUSY  = 1 << 5,
        CTRL_CHAIN_SYNC_DONE  = 1 << 6
    } control_sync_state_ap_ctrl_chain;


// --------------------------------------------------------------------------------------
//   State Machine AP_CTRL_HS input sync
// --------------------------------------------------------------------------------------

    typedef enum logic[6:0] {
        CTRL_HS_SYNC_RESET = 1 << 0,
        CTRL_HS_SYNC_IDLE  = 1 << 1,
        CTRL_HS_SYNC_SETUP = 1 << 2,
        CTRL_HS_SYNC_READY = 1 << 3,
        CTRL_HS_SYNC_START = 1 << 4,
        CTRL_HS_SYNC_BUSY  = 1 << 5,
        CTRL_HS_SYNC_DONE  = 1 << 6
    } control_sync_state_ap_ctrl_hs;


endpackage
