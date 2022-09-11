#ifndef GLAYENV_H
#define GLAYENV_H

#include <stdint.h>

#include "experimental/xrt_kernel.h"
#include "experimental/xrt_aie.h"

#include "graphCSR.h" 

// ********************************************************************************************
// ***************                      DataStructure CSR                        **************
// ********************************************************************************************

struct __attribute__((__packed__)) GLAYGraphCSR
{
    uint32_t num_edges;                    // 4-Bytes
    uint32_t num_vertices;                 // 4-Bytes
    uint32_t avg_degree;

};


// ********************************************************************************************
// ***************                      XRT Device Management                    **************
// ********************************************************************************************

struct xrtGLAYHandle
{
    char *xclbin_path;
    int device_index;
    xrtDeviceHandle device_handle;
    xrtXclbinHandle xclbin_handle;
    xuid_t xclbin_uuid;

};

#endif