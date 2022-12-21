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
        logic   glay_start;
        logic   glay_continue;
    } GlayControlChainIterfaceInput;

    typedef struct packed{
        logic glay_idle ;
        logic glay_ready;
        logic glay_done ;
    } GlayControlChainIterfaceOutput;

    typedef struct packed{
        logic   glay_start;
        logic   glay_ready;
    } glay_control_chain_input_sync;

    typedef struct packed{
        logic   glay_continue;
        logic   glay_done;
    } glay_control_chain_output_sync;

    typedef struct packed{
        logic glay_idle;  
        glay_control_chain_input_sync input_sync;
        glay_control_chain_output_sync output_sync;
    } glay_control_chain;

endpackage
