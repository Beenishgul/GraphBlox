// -----------------------------------------------------------------------------
//
//      "GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay"
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

    import PKG_MXX_AXI4_BE::*;
    import PKG_GLOBALS::*;

    typedef struct packed{
        logic [BUFFER_0_WIDTH_BITS-1:0] buffer_0; // graph overlay program
        logic [BUFFER_1_WIDTH_BITS-1:0] buffer_1; // vertex in degree
        logic [BUFFER_2_WIDTH_BITS-1:0] buffer_2; // vertex out degree
        logic [BUFFER_3_WIDTH_BITS-1:0] buffer_3; // vertex edges CSR index
        logic [BUFFER_4_WIDTH_BITS-1:0] buffer_4; // edges array src
        logic [BUFFER_5_WIDTH_BITS-1:0] buffer_5; // edges array dest
        logic [BUFFER_6_WIDTH_BITS-1:0] buffer_6; // edges array weight
        logic [BUFFER_7_WIDTH_BITS-1:0] buffer_7; // auxiliary 1
        logic [BUFFER_8_WIDTH_BITS-1:0] buffer_8; // auxiliary 2
        logic [BUFFER_9_WIDTH_BITS-1:0] buffer_9; // auxiliary 3
    } KernelDescriptorPayload;


    typedef struct packed{
        logic                   valid  ;
        KernelDescriptorPayload payload;
    } KernelDescriptor;

endpackage