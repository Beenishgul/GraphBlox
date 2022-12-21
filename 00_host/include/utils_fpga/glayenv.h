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

// ********************************************************************************************
// ***************                      DataStructure CSR                        **************
// ********************************************************************************************

struct __attribute__((__packed__)) GLAYGraphCSR
{
    uint32_t num_edges;                 // 4-Bytes
    uint32_t num_vertices;              // 4-Bytes
    void *vertex_out_degree;            // 8-Bytes
    void *vertex_in_degree;             // 8-Bytes
    void *vertex_edges_idx;             // 8-Bytes
    void *edges_array_src;              // 8-Bytes
    void *edges_array_dest;             // 8-Bytes
    void *edges_array_weight;           // 8-Bytes
    void *auxiliary1;                   // 8-Bytes
    //---------------------------------------------------//--// 64bytes
    void *auxiliary2;                   // 8-Bytes
    float max_weight;                   // 4-Bytes
};


struct __attribute__((__packed__)) GLAYGraphCSRxrtBufferHandlePerBank
{
    size_t Edges_buffer_size_in_bytes;
    size_t Vertex_buffer_size_in_bytes;
    size_t graph_buffer_size_in_bytes;
    // Each Memory bank contains a Graph CSR segment
    xrtBufferHandle graph_csr_struct_buffer;
    xrtBufferHandle vertex_out_degree_buffer;
    xrtBufferHandle vertex_in_degree_buffer;
    xrtBufferHandle vertex_edges_idx_buffer;
    xrtBufferHandle edges_array_weight_buffer;
    xrtBufferHandle edges_array_src_buffer;
    xrtBufferHandle edges_array_dest_buffer;
    xrtBufferHandle auxiliary_1_buffer;
    xrtBufferHandle auxiliary_2_buffer;
    xrtMemoryGroup bank_grp_idx;
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
    xrtKernelHandle kernelHandle;
    xrtRunHandle kernelHandleRun;
    xuid_t xclbinUUID;
};


int setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath);
int setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx);
void startGLAYRun(struct xrtGLAYHandle *glayHandle);
void waitGLAYRun(struct xrtGLAYHandle *glayHandle);
void closeGLAYRun(struct xrtGLAYHandle *glayHandle);
void releaseGLAY(struct xrtGLAYHandle *glayHandle);
void freeGlayHandle(struct xrtGLAYHandle *glayHandle);
void printGLAYGraphCSRPointers(struct  GLAYGraphCSR *glayGraphCSR);
struct GLAYGraphCSRxrtBufferHandlePerBank *allocateGLAYGraphCSRDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx);
int writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);
int readGLAYGraphCSRDeviceToHostBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);
int freeGLAYGraphCSRHostToDeviceBuffersPerBank(struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);

#ifdef __cplusplus
}
#endif


#endif