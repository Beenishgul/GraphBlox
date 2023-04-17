// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : descriptor_pkg.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`timescale 1 ns / 1 ps
package DESCRIPTOR_PKG;

    import GLOBALS_PKG::*;

    typedef enum int unsigned {
        RESET,
        IDLE,
        REQ,
        WAITING_FOR_REQUEST,
        READ_DATA,
        DONE_REQ
    } descriptor_state;

    typedef struct packed{
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   graph_csr_struct  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   vertex_out_degree ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   vertex_in_degree  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   vertex_edges_idx  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   edges_array_weight;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   edges_array_src   ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   edges_array_dest  ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   auxiliary_1       ;
        logic   [M_AXI_MEMORY_ADDR_WIDTH-1:0]   auxiliary_2       ; // reads the next number of cache lines if set
    } descriptor_request;


    typedef struct packed{
        logic                   valid  ;
        descriptor_request payload;
    } DescriptorInterface;

endpackage