// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_descriptor_pkg.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps
package GLAY_DESCRIPTOR_PKG;

    import GLAY_GLOBALS_PKG::*;

    typedef enum int unsigned {
        GLAY_RESET,
        GLAY_IDLE,
        GLAY_REQ,
        GLAY_WAITING_FOR_REQUEST,
        GLAY_READ_DATA,
        GLAY_DONE_REQ
    } glay_descriptor_state;

    typedef struct packed{
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   graph_csr_struct  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   vertex_out_degree ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   vertex_in_degree  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   vertex_edges_idx  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   edges_array_weight;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   edges_array_src   ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   edges_array_dest  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   auxiliary_1       ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   auxiliary_2       ;
    } glay_descriptor_request;


    typedef struct packed{
        logic                   valid  ;
        glay_descriptor_request payload;
    } GLAYDescriptorInterface;

endpackage