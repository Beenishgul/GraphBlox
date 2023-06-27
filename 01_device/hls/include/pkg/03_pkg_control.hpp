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
#ifndef PKG_CONTROL_HPP
#define PKG_CONTROL_HPP

#ifndef PKG_CACHE_HPP
#define PKG_CACHE_HPP

#include <cmath>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <cstdlib>
using namespace std


    #include “ap_int.h”
    #include “01_pkg_gloabals.hpp”

    typedef struct{
        ap_uint<1>  ap_start   ;
        ap_uint<1>  ap_continue;
        ap_uint<1>  setup      ;
        ap_uint<1>  done       ;
    } ControlChainInterfaceInput;

    typedef struct{
        ap_uint<1>  ap_ready;
        ap_uint<1>  ap_done ;
        ap_uint<1>  ap_idle ;
        ap_uint<1>  start   ;
        ap_uint<1>  endian  ;
    } ControlChainInterfaceOutput;

// --------------------------------------------------------------------------------------
//   State Machine USER_MANAGED input sync
// --------------------------------------------------------------------------------------

    typedef enum ap_uint<6> {
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

    typedef enum ap_uint<6> {
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

    typedef enum ap_uint<6> {
        CTRL_HS_SYNC_RESET,
        CTRL_HS_SYNC_IDLE,
        CTRL_HS_SYNC_SETUP,
        CTRL_HS_SYNC_READY,
        CTRL_HS_SYNC_START,
        CTRL_HS_SYNC_BUSY,
        CTRL_HS_SYNC_DONE
    } control_sync_state_ap_ctrl_hs;


#endif
