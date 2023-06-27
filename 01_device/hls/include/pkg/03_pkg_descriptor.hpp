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
#ifndef PKG_DESCRIPTOR_HPP
#define PKG_DESCRIPTOR_HPP

#include <cmath>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <cstdlib>
using namespace std

#include “ap_int.h”
#include “01_pkg_gloabals.hpp”

    typedef struct {
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_0; // graph overlay program
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_1; // vertex in degree
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_2; // vertex out degree
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_3; // vertex edges CSR index
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_4; // edges array src
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_5; // edges array dest
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_6; // edges array weight
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_7; // auxiliary 1
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_8; // auxiliary 2
        ap_uint<M_AXI_MEMORY_ADDR_WIDTH> buffer_9; // auxiliary 3
    } KernelDescriptorPayload;


    typedef struct {
        ap_uint<1>              valid  ;
        KernelDescriptorPayload payload;
    } KernelDescriptor;

#endif