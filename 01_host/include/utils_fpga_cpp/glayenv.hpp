#ifndef GLAYENV_H
#define GLAYENV_H

#include <iostream>
#include <fstream>
#include <vector>
#include <cstdint>
#include <string>
#include <cstdlib> 
#include <bitset>

// XRT includes
#include "xrt/xrt_bo.h"
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"
#include <experimental/xrt_xclbin.h>
#include <experimental/xrt_ip.h>

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "graphCSR.h"
#include <time.h>


#ifdef __cplusplus
}
#endif



// ********************************************************************************************
// ***************                      XRT Device Management                    **************
// ********************************************************************************************
struct __attribute__((__packed__)) GraphAuxiliary
{
    uint32_t num_auxiliary_1;             
    uint32_t num_auxiliary_2;         
    //---------------------------------------------------
    void *auxiliary_1;               
    void *auxiliary_2;               
};

class xrtGLAYHandle {
public:
    bool endian_read;
    bool endian_write;
    bool flush_enable;
    int cacheSize;
    int ctrlMode;
    int numThreads;
    int overlay_algorithm;
    int overlay_program_entries;
    std::string kernelName;
    std::string overlayPath;
    std::string xclbinPath;
    std::vector<uint32_t> overlay_program;
    std::vector<xrt::xclbin::ip> cuHandles;
    unsigned int deviceIndex;
    xrt::device deviceHandle;
    xrt::ip ipHandle;
    xrt::kernel kernelHandle;
    xrt::run runKernelHandle;
    xrt::uuid xclbinUUID;
    xrt::xclbin xclbinHandle;
    xrt::xclbin::mem mem_used;

    // Constructor to initialize the device with arguments
    xrtGLAYHandle(struct Arguments *arguments);
    // Destructor to clean up resources if necessary
    ~xrtGLAYHandle() {
        // Implement any necessary cleanup
    }
    void setupGLAYDevice();
    void readGLAYDeviceEntriesFromFile();
    void printGLAYDevice() const;
    // Other methods as necessary for device interaction
};
// ********************************************************************************************
// ***************                      XRT Buffer Management                    **************
// ********************************************************************************************
class GLAYGraphCSRxrtBufferHandlePerKernel
{
public:
// User Managed Kernel MASK
static const uint32_t CONTROL_OFFSET = 0x00;
static const uint32_t CONTROL_START = 0x01;
static const uint32_t CONTROL_DONE = 0x02;
static const uint32_t CONTROL_IDLE = 0x04;
static const uint32_t CONTROL_READY = 0x08;
static const uint32_t CONTROL_CONTINUE = 0x10;
static const int MAX_XRT_BUFFERS = 32; // Adjust this to your maximum expected number of buffers

int  overlay_program_entries;
bool endian;
xrtGLAYHandle *glayHandle;
uint32_t *overlay_program;
// Each Memory bank contains a Graph CSR segment
int xrt_buffers_num = 10;
xrt::bo xrt_buffer_object[10];
std::bitset<MAX_XRT_BUFFERS> xrt_buffer_sync;
void *   xrt_buffer_map[10];
void *   xrt_buffer_host[10];
uint64_t xrt_buffer_device[10];
size_t xrt_buffer_size[10];

GLAYGraphCSRxrtBufferHandlePerKernel() : overlay_program(nullptr) {
}
~GLAYGraphCSRxrtBufferHandlePerKernel(){
    if (overlay_program) {
        free(overlay_program); // Use free for memory allocated with aligned_alloc
    }
    delete glayHandle;
    glayHandle = nullptr; // Good practice to avoid dangling pointer
}

GLAYGraphCSRxrtBufferHandlePerKernel(struct Arguments *arguments, struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary);
int writeGLAYGraphCSRHostToDeviceBuffersPerKernel();
int mapGLAYGraphCSRHostToDeviceBuffersPerKernel();
int readGLAYGraphCSRDeviceToHostBuffersPerKernel();
int writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerKernel();
int setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerKernel();
void initializeGLAYOverlayConfiguration(struct GraphCSR *graph);
void printGLAYGraphCSRxrtBufferHandlePerKernel();
void assignGraphtoXRTBufferHost(struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary);
void assignGraphtoXRTBufferSize(struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary);
void prinGraphtoXRTBufferSize() const;
void SetSyncBuffersBasedOnString(const std::string &syncPattern);

void mapGLAYOverlayProgramBuffersBFS(struct GraphCSR *graph);
void mapGLAYOverlayProgramBuffersPR(struct GraphCSR *graph);
void mapGLAYOverlayProgramBuffersTC(struct GraphCSR *graph);
void mapGLAYOverlayProgramBuffersSPMV(struct GraphCSR *graph);
void mapGLAYOverlayProgramBuffersCC(struct GraphCSR *graph);

// ********************************************************************************************
// ***************                  GLAY Control                                 **************
// ********************************************************************************************
void setupGLAYGraphCSR();
void startGLAY();
void waitGLAY();
void releaseGLAY();

// ********************************************************************************************
// ***************                  GLAY Control USER_MANAGED                    **************
// ********************************************************************************************
void setupGLAYGraphCSRUserManaged();
void startGLAYUserManaged();
void waitGLAYUserManaged();
void releaseGLAYUserManaged();

// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_HS                      **************
// ********************************************************************************************
void setupGLAYGraphCSRCtrlHs();
void startGLAYCtrlHs();
void waitGLAYCtrlHs();
void releaseGLAYCtrlHs();

// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_CHAIN                   **************
// ********************************************************************************************
void setupGLAYGraphCSRCtrlChain();
void startGLAYCtrlChain();
void waitGLAYCtrlChain();
void releaseGLAYCtrlChain();
};



#endif