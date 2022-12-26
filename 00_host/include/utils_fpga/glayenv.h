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

// User Managed Kernel masks

#define CONTROL_OFFSET             0x00
#define CONTROL_START              0x01
#define CONTROL_DONE               0x02
#define CONTROL_IDLE               0x04
#define CONTROL_READY              0x08
#define CONTROL_CONTINUE           0x10


// ********************************************************************************************
// ***************                      DataStructure CSR OFFSETS                **************
// ********************************************************************************************

// 0x10 : Data signal of graph_csr_struct
//        bit 31~0 - graph_csr_struct[31:0] (Read/Write)
// 0x14 : Data signal of graph_csr_struct
//        bit 31~0 - graph_csr_struct[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of vertex_out_degree
//        bit 31~0 - vertex_out_degree[31:0] (Read/Write)
// 0x20 : Data signal of vertex_out_degree
//        bit 31~0 - vertex_out_degree[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of vertex_in_degree
//        bit 31~0 - vertex_in_degree[31:0] (Read/Write)
// 0x2c : Data signal of vertex_in_degree
//        bit 31~0 - vertex_in_degree[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of vertex_edges_idx
//        bit 31~0 - vertex_edges_idx[31:0] (Read/Write)
// 0x38 : Data signal of vertex_edges_idx
//        bit 31~0 - vertex_edges_idx[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of edges_array_weight
//        bit 31~0 - edges_array_weight[31:0] (Read/Write)
// 0x44 : Data signal of edges_array_weight
//        bit 31~0 - edges_array_weight[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of edges_array_src
//        bit 31~0 - edges_array_src[31:0] (Read/Write)
// 0x50 : Data signal of edges_array_src
//        bit 31~0 - edges_array_src[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of edges_array_dest
//        bit 31~0 - edges_array_dest[31:0] (Read/Write)
// 0x5c : Data signal of edges_array_dest
//        bit 31~0 - edges_array_dest[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of auxiliary_1
//        bit 31~0 - auxiliary_1[31:0] (Read/Write)
// 0x68 : Data signal of auxiliary_1
//        bit 31~0 - auxiliary_1[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of auxiliary_2
//        bit 31~0 - auxiliary_2[31:0] (Read/Write)
// 0x74 : Data signal of auxiliary_2
//        bit 31~0 - auxiliary_2[63:32] (Read/Write)
// 0x78 : reserved

#define GRAPH_CSR_STRUCT_OFFSET      0x10
#define VERTEX_OUT_DEGREE_OFFSET     0x1c
#define VERTEX_IN_DEGREE_OFFSET      0x28
#define VERTEX_EDGES_IDX_OFFSET      0x34
#define EDGES_ARRAY_WEIGHT_OFFSET    0x40
#define EDGES_ARRAY_SRC_OFFSET       0x4c
#define EDGES_ARRAY_DEST_OFFSET      0x58
#define AUXILIARY_1_OFFSET           0x64
#define AUXILIARY_2_OFFSET           0x70

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


struct xrtGLAYHandle *setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath);
int setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx);
void startGLAYRun(struct xrtGLAYHandle *glayHandle);
void startGLAYUserManaged(struct xrtGLAYHandle *glayHandle);
void waitGLAYRun(struct xrtGLAYHandle *glayHandle);
void waitGLAYUserManaged(struct xrtGLAYHandle *glayHandle);
void closeGLAYRun(struct xrtGLAYHandle *glayHandle);
void closeGLAYUserManaged(struct xrtGLAYHandle *glayHandle);
void releaseGLAY(struct xrtGLAYHandle *glayHandle);
void freeGlayHandle(struct xrtGLAYHandle *glayHandle);
void printGLAYGraphCSRPointers(struct  GLAYGraphCSR *glayGraphCSR);
struct GLAYGraphCSRxrtBufferHandlePerBank *allocateGLAYGraphCSRDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx);
int writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);
int writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);
int readGLAYGraphCSRDeviceToHostBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);
int freeGLAYGraphCSRHostToDeviceBuffersPerBank(struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);

#ifdef __cplusplus
}
#endif


#endif