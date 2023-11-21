// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_DESCRIPTOR.sv
// Create : 2022-11-29 16:14:59
// Revise : 2022-11-29 16:14:59
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

`include "global_timescale.vh"
package PKG_DESCRIPTOR;

    import PKG_GLOBALS::*;

    typedef struct packed{
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_0; // graph overlay program
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_1; // vertex in degree
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_2; // vertex out degree
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_3; // vertex edges CSR index
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_4; // edges array src
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_5; // edges array dest
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_6; // edges array weight
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_7; // auxiliary 1
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_8; // auxiliary 2
        logic [M_AXI_MEMORY_ADDR_WIDTH-1:0] buffer_9; // auxiliary 3
    } KernelDescriptorPayload;


    typedef struct packed{
        logic                   valid  ;
        KernelDescriptorPayload payload;
    } KernelDescriptor;

endpackage