// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_engine_pkg.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps
package GLAY_ENGINE_PKG;

    import GLAY_GLOBALS_PKG::*;


// Serial\_Read\_Engine
// --------------------

// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity

// The serial read engine sends read commands to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array.

    typedef enum int unsigned {
        GLAY_RESET,
        GLAY_IDLE,
        GLAY_REQ,
        GLAY_WAITING_FOR_REQUEST,
        GLAY_READ_DATA,
        GLAY_DONE_REQ
    } serial_read_engine_state;

    typedef struct packed{
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_pointer;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] array_size   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] start_read   ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] end_read     ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] stride       ;
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] granularity  ;
    } serialReadEngineIntefaceInput;


endpackage