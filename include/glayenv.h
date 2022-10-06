#ifndef GLAYENV_H
#define GLAYENV_H

#include <stdint.h>

#include "experimental/xrt_kernel.h"
#include "experimental/xrt_aie.h"

#include "graphCSR.h" 

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
    uint32_t num_edges;                    // 4-Bytes
    uint32_t num_vertices;                 // 4-Bytes
    uint32_t avg_degree;

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
struct  GLAYGraphCSR *mapGraphCSRToGLAY(struct GLAYGraphCSR *glayGraphCSR);
void printGLAYGraphCSRPointers(struct  GLAYGraphCSR *glayGraphCSR);

