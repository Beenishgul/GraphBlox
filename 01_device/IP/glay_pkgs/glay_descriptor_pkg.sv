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

package GLAY_DESCRIPTOR_PKG;

    import GLOBALS_AFU_PKG::*;

    typedef enum int unsigned {
        GLAY_RESET,
        GLAY_IDLE,
        GLAY_REQ,
        GLAY_WAITING_FOR_REQUEST,
        GLAY_READ_DATA,
        GLAY_DONE_REQ
    } glay_descriptor_state;

    typedef struct packed{
        logic   [64-1:0]    graph_csr_struct  ,
        logic   [64-1:0]    vertex_out_degree ,
        logic   [64-1:0]    vertex_in_degree  ,
        logic   [64-1:0]    vertex_edges_idx  ,
        logic   [64-1:0]    edges_array_weight,
        logic   [64-1:0]    edges_array_src   ,
        logic   [64-1:0]    edges_array_dest  ,
        logic   [64-1:0]    auxiliary_1       ,
        logic   [64-1:0]    auxiliary_2
    } glay_descriptor_request;


    typedef struct packed{
        logic [0:63]            address        ;
        glay_descriptor_request glay_descriptor;
    } GLAYDescriptorInterfacePayload;


    typedef struct packed{
        logic                          valid  ;
        GLAYDescriptorInterfacePayload payload;
    } GLAYDescriptorInterface;

endpackage