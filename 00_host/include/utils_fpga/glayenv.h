#ifndef GLAYENV_H
#define GLAYENV_H

#include "experimental/xrt_kernel.h"
#include "experimental/xrt_aie.h"


#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "graphCSR.h"
#include <time.h>

#define DATA_SIZE 4096
#define IP_START 0x1
#define IP_IDLE 0x4
#define USER_OFFSET 0x0
#define A_OFFSET 0x18
#define B_OFFSET 0x24

// ********************************************************************************************
// ***************                      DataStructure CSR                        **************
// ********************************************************************************************

struct __attribute__((__packed__)) GLAYGraphCSR
{
    uint32_t num_edges;                 // 4-Bytes
    uint32_t num_vertices;              // 4-Bytes
    float max_weight;                   // 4-Bytes
    uint32_t auxiliary0;                // 4-Bytes
    void *vertex_out_degree;            // 8-Bytes
    void *vertex_in_degree;             // 8-Bytes
    void *vertex_edges_idx;             // 8-Bytes
    void *edges_array_weight;           // 8-Bytes
    void *edges_array_src;              // 8-Bytes
    void *edges_array_dest;             // 8-Bytes
    //---------------------------------------------------//--// 64bytes
    void *inverse_vertex_out_degree;    // 8-Bytes
    void *inverse_vertex_in_degree;     // 8-Bytes
    void *inverse_vertex_edges_idx;     // 8-Bytes
    void *inverse_edges_array_weight;   // 8-Bytes
    void *inverse_edges_array_src;      // 8-Bytes
    void *inverse_edges_array_dest;     // 8-Bytes
    void *auxiliary1;                   // 8-Bytes
    void *auxiliary2;                   // 8-Bytes
};


// ********************************************************************************************
// ***************                      XRT Device Management                    **************
// ********************************************************************************************

struct xrtGLAYHandle
{
    char *xclbinPath;
    int deviceIndex;
    xrtDeviceHandle deviceHandle;
    xrtXclbinHandle xclbinHandle;
    xuid_t xclbinUUID;
};


int setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath);
int setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle);
void startGLAY(struct xrtGLAYHandle *glayHandle, struct GLAYGraphCSR *glayGraphCSR);
void startGLAYCU(struct xrtGLAYHandle *glayHandle, struct GLAYGraphCSR *glayGraphCSR);
void waitGLAY(struct xrtGLAYHandle *glayHandle);
void releaseGLAY(struct xrtGLAYHandle *glayHandle);
void freeGlayHandle(struct xrtGLAYHandle *glayHandle);
struct  GLAYGraphCSR *mapGraphCSRToGLAY(struct GraphCSR *graph);
void printGLAYGraphCSRPointers(struct  GLAYGraphCSR *glayGraphCSR);

#ifdef __cplusplus
}
#endif


#endif