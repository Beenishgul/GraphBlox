#ifndef GLAYENV_H
#define GLAYENV_H

#include <iostream>
#include <cstring>

#include "experimental/xrt_bo.h"
#include "experimental/xrt_ip.h"
#include "experimental/xrt_device.h"
#include "experimental/xrt_kernel.h"
#include "experimental/xrt_xclbin.h"

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "graphCSR.h"
#include <time.h>


#ifdef __cplusplus
}
#endif


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

//------------------------Address Info-------------------
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 4  - ap_continue (Read/Write/SC)
//        bit 7  - auto_restart (Read/Write)
//        bit 9  - interrupt (Read)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/COR)
//        bit 0 - ap_done (Read/COR)
//        bit 1 - ap_ready (Read/COR)
//        others - reserved
// 0x10 : Data signal of buffer_0
//        bit 31~0 - buffer_0[31:0] (Read/Write)
// 0x14 : Data signal of buffer_0
//        bit 31~0 - buffer_0[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of buffer_1
//        bit 31~0 - buffer_1[31:0] (Read/Write)
// 0x20 : Data signal of buffer_1
//        bit 31~0 - buffer_1[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of buffer_2
//        bit 31~0 - buffer_2[31:0] (Read/Write)
// 0x2c : Data signal of buffer_2
//        bit 31~0 - buffer_2[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of buffer_3
//        bit 31~0 - buffer_3[31:0] (Read/Write)
// 0x38 : Data signal of buffer_3
//        bit 31~0 - buffer_3[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of buffer_4
//        bit 31~0 - buffer_4[31:0] (Read/Write)
// 0x44 : Data signal of buffer_4
//        bit 31~0 - buffer_4[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of buffer_5
//        bit 31~0 - buffer_5[31:0] (Read/Write)
// 0x50 : Data signal of buffer_5
//        bit 31~0 - buffer_5[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of buffer_6
//        bit 31~0 - buffer_6[31:0] (Read/Write)
// 0x5c : Data signal of buffer_6
//        bit 31~0 - buffer_6[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of buffer_7
//        bit 31~0 - buffer_7[31:0] (Read/Write)
// 0x68 : Data signal of buffer_7
//        bit 31~0 - buffer_7[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of buffer_8
//        bit 31~0 - buffer_8[31:0] (Read/Write)
// 0x74 : Data signal of buffer_8
//        bit 31~0 - buffer_8[63:32] (Read/Write)
// 0x78 : reserved
// 0x7c : Data signal of buffer_9
//        bit 31~0 - buffer_9[31:0] (Read/Write)
// 0x80 : Data signal of buffer_9
//        bit 31~0 - buffer_9[63:32] (Read/Write)
// 0x84 : reserved

#define ADDR_BUFFER_0_DATA_0  0x10
#define ADDR_BUFFER_0_DATA_1  0x14

#define ADDR_BUFFER_1_DATA_0  0x1c
#define ADDR_BUFFER_1_DATA_1  0x20

#define ADDR_BUFFER_2_DATA_0  0x28
#define ADDR_BUFFER_2_DATA_1  0x2c

#define ADDR_BUFFER_3_DATA_0  0x34
#define ADDR_BUFFER_3_DATA_1  0x38

#define ADDR_BUFFER_4_DATA_0  0x40
#define ADDR_BUFFER_4_DATA_1  0x44

#define ADDR_BUFFER_5_DATA_0  0x4c
#define ADDR_BUFFER_5_DATA_1  0x50

#define ADDR_BUFFER_6_DATA_0  0x58
#define ADDR_BUFFER_6_DATA_1  0x5c

#define ADDR_BUFFER_7_DATA_0  0x64
#define ADDR_BUFFER_7_DATA_1  0x68

#define ADDR_BUFFER_8_DATA_0  0x70
#define ADDR_BUFFER_8_DATA_1  0x74

#define ADDR_BUFFER_9_DATA_0  0x7c
#define ADDR_BUFFER_9_DATA_1  0x80

#define ADDR_BUFFER_0_ID  0
#define ADDR_BUFFER_1_ID  1
#define ADDR_BUFFER_2_ID  2
#define ADDR_BUFFER_3_ID  3
#define ADDR_BUFFER_4_ID  4
#define ADDR_BUFFER_5_ID  5
#define ADDR_BUFFER_6_ID  6
#define ADDR_BUFFER_7_ID  7
#define ADDR_BUFFER_8_ID  8
#define ADDR_BUFFER_9_ID  9

#define GRAPH_CSR_STRUCT_OFFSET      0x10
#define VERTEX_IN_DEGREE_OFFSET      0x1c
#define VERTEX_OUT_DEGREE_OFFSET     0x28
#define VERTEX_EDGES_IDX_OFFSET      0x34
#define EDGES_ARRAY_SRC_OFFSET       0x40
#define EDGES_ARRAY_DEST_OFFSET      0x4c
#define EDGES_ARRAY_WEIGHT_OFFSET    0x58
#define AUXILIARY_1_OFFSET           0x64
#define AUXILIARY_2_OFFSET           0x70
#define AUXILIARY_3_OFFSET           0x7c

#define GRAPH_CSR_STRUCT_ID      0
#define VERTEX_IN_DEGREE_ID      1
#define VERTEX_OUT_DEGREE_ID     2
#define VERTEX_EDGES_IDX_ID      3
#define EDGES_ARRAY_SRC_ID       4
#define EDGES_ARRAY_DEST_ID      5
#define EDGES_ARRAY_WEIGHT_ID    6
#define AUXILIARY_1_ID           7
#define AUXILIARY_2_ID           8
#define AUXILIARY_3_ID           9

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
    void *auxiliary3;                   // 8-Bytes
    float max_weight;                   // 4-Bytes
};

// ********************************************************************************************
// ***************                      XRT Device Management                    **************
// ********************************************************************************************

struct xrtGLAYHandle
{
    int numThreads;
    int ctrlMode;
    char *kernelName;
    char *xclbinPath;
    unsigned int deviceIndex;
    xrt::device deviceHandle;
    xrt::xclbin xclbinHandle;
    xrt::ip ipHandle;
    xrt::uuid xclbinUUID;
    xrt::xclbin::mem mem_used;
    xrt::kernel kernelHandle;
    xrt::run runKernelHandle;
    std::vector<xrt::xclbin::ip> cuHandles;
    xrt::ip::interrupt interruptHandle;
};

struct xrtGLAYHandle *setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath, char *kernelName, int ctrlMode);

// ********************************************************************************************
// ***************                      XRT Buffer Management                    **************
// ********************************************************************************************

class GLAYGraphCSRxrtBufferHandlePerBank
{
public:
    size_t overlay_buffer_size_in_bytes;
    uint32_t *overlay_configuration;
    // Each Memory bank contains a Graph CSR segment
    xrt::bo  xrt_buffer[10];
    void *   xrt_buffer_host[10];
    uint64_t xrt_buffer_device[10];
    size_t   xrt_buffer_size[10];

    GLAYGraphCSRxrtBufferHandlePerBank()=default;
    ~GLAYGraphCSRxrtBufferHandlePerBank()=default;
    GLAYGraphCSRxrtBufferHandlePerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, int bankGroupIndex);
    int writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);
    int writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle);
    void InitializeGLAYOverlayProgram(size_t overlayBufferSizeInBytes, int algorithm, struct GraphCSR *graph);
    int setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank);
    void printGLAYGraphCSRxrtBufferHandlePerBank();

};

struct GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bankGroupIndex);

// ********************************************************************************************
// ***************                  GLAY Control                                 **************
// ********************************************************************************************

void freeGlayHandle(struct xrtGLAYHandle *glayHandle);
void releaseGLAY(struct xrtGLAYHandle *glayHandle);


// ********************************************************************************************
// ***************                  GLAY Control USER_MANAGED                    **************
// ********************************************************************************************
struct GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRUserManaged(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bankGroupIndex);
void startGLAYUserManaged(struct xrtGLAYHandle *glayHandle);
void waitGLAYUserManaged(struct xrtGLAYHandle *glayHandle);
void releaseGLAYUserManaged(struct xrtGLAYHandle *glayHandle);

// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_HS                      **************
// ********************************************************************************************
struct GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRCtrlHs(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bankGroupIndex);
void startGLAYCtrlHs(struct xrtGLAYHandle *glayHandle);
void waitGLAYCtrlHs(struct xrtGLAYHandle *glayHandle);
void releaseGLAYCtrlHs(struct xrtGLAYHandle *glayHandle);

// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_CHAIN                   **************
// ********************************************************************************************
struct GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRCtrlChain(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bankGroupIndex);
void startGLAYCtrlChain(struct xrtGLAYHandle *glayHandle);
void waitGLAYCtrlChain(struct xrtGLAYHandle *glayHandle);
void releaseGLAYCtrlChain(struct xrtGLAYHandle *glayHandle);

#endif