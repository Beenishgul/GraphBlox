// -----------------------------------------------------------------------------
//
//      "GLAY"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@ncsu.edu||atmughrabi@gmail.com
// File   : glayenv.c
// Create : 2019-10-09 19:20:39
// Revise : 2019-12-01 00:12:59
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

#include "glayenv.hpp"
#include "myMalloc.h"

// ********************************************************************************************
// ***************                  XRT General                                  **************
// ********************************************************************************************

struct xrtGLAYHandle *setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath, char *kernelName, int ctrl_mode)
{

    glayHandle = (struct xrtGLAYHandle *) my_malloc(sizeof(struct xrtGLAYHandle));
    glayHandle->deviceIndex = deviceIndex;
    glayHandle->xclbinPath = xclbinPath;
    glayHandle->kernelName = kernelName;
    glayHandle->ctrl_mode  = ctrl_mode;
    //Open a Device (use "xbutil scan" to show the available devices)
    std::cout << "Open the device :" << glayHandle->deviceIndex << std::endl;
    glayHandle->deviceHandle = xrt::device(glayHandle->deviceIndex);

    std::cout << "Load the xclbin : " << glayHandle->xclbinPath << std::endl;
    glayHandle->xclbinUUID = glayHandle->deviceHandle.load_xclbin(glayHandle->xclbinPath);

    glayHandle->xclbinHandle  = xrt::xclbin(glayHandle->xclbinPath);

    switch (glayHandle->ctrl_mode)
    {
    case 0:
        glayHandle->ipHandle = xrt::ip(glayHandle->deviceHandle, glayHandle->xclbinUUID, glayHandle->kernelName);
        break;
    case 1:
    case 2:
        glayHandle->kernelHandle = xrt::kernel(glayHandle->deviceHandle, glayHandle->xclbinUUID, glayHandle->kernelName);
        break;
    default:
        glayHandle->ipHandle = xrt::ip(glayHandle->deviceHandle, glayHandle->xclbinUUID, glayHandle->kernelName);
    }


    std::cout << "Fetch compute Units" << std::endl;
    for (auto &kernel : glayHandle->xclbinHandle.get_kernels())
    {
        if (kernel.get_name() == glayHandle->kernelName)
        {
            glayHandle->cuHandles = kernel.get_cus();
        }
    }

    if (glayHandle->cuHandles.empty()) throw std::runtime_error(std::string("IP ") + glayHandle->kernelName + std::string(" not found in the provided xclbin"));

    // std::cout << "Determine memory index\n";
    // for (auto &mem : glayHandle->xclbinHandle.get_mems())
    // {
    //     if (mem.get_used())
    //     {
    //         glayHandle->mem_used = mem;
    //         break;
    //     }
    // }

    // glayHandle->interruptHandle = glayHandle->ipHandle.create_interrupt_notify();
    // glayHandle->interruptHandle.disable();

    std::cout << "device name                   :     " << glayHandle->deviceHandle.get_info<xrt::info::device::name>() << "\n";
    std::cout << "device bdf                    :     " << glayHandle->deviceHandle.get_info<xrt::info::device::bdf>() << "\n";
    std::cout << "device max_clock_frequency_mhz:     " << glayHandle->deviceHandle.get_info<xrt::info::device::max_clock_frequency_mhz>() << "\n";

    // glayHandle->cuHandles[0].
    std::cout << "Kernel Arguments Offsets:" << "\n";
    for (auto i : glayHandle->cuHandles[0].get_args())
        std::cout << std::hex << std::uppercase << i.get_offset() << "\n";



    return glayHandle;

}



// ********************************************************************************************
// ***************                  GLAY General                                 **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank::GLAYGraphCSRxrtBufferHandlePerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, int bank_grp_idx)
{

    edges_buffer_size_in_bytes  = graph->num_edges * sizeof(uint32_t);
    vertex_buffer_size_in_bytes = graph->num_vertices * sizeof(uint32_t);
    overlay_buffer_size_in_bytes  = 64 * 4 * sizeof(uint32_t); // (4 cachelines 64-bytes / 4 bytes)

    // Each Memory bank contains a Graph CSR segment
    xrt_buffer[0]   =  xrt::bo(glayHandle->deviceHandle, overlay_buffer_size_in_bytes,  bank_grp_idx);
    xrt_buffer[1]   =  xrt::bo(glayHandle->deviceHandle, vertex_buffer_size_in_bytes, bank_grp_idx);
    xrt_buffer[2]   =  xrt::bo(glayHandle->deviceHandle, vertex_buffer_size_in_bytes, bank_grp_idx);
    xrt_buffer[3]   =  xrt::bo(glayHandle->deviceHandle, vertex_buffer_size_in_bytes, bank_grp_idx);
    xrt_buffer[4]   =  xrt::bo(glayHandle->deviceHandle, edges_buffer_size_in_bytes,  bank_grp_idx);
    xrt_buffer[5]   =  xrt::bo(glayHandle->deviceHandle, edges_buffer_size_in_bytes,  bank_grp_idx);
#if WEIGHTED
    xrt_buffer[6]   =  xrt::bo(glayHandle->deviceHandle, edges_buffer_size_in_bytes, bank_grp_idx);
#endif
    xrt_buffer[7]   =  xrt::bo(glayHandle->deviceHandle, 8, xrt::bo::flags::normal, bank_grp_idx);
    xrt_buffer[8]   =  xrt::bo(glayHandle->deviceHandle, 8, xrt::bo::flags::normal, bank_grp_idx);
    xrt_buffer[9]   =  xrt::bo(glayHandle->deviceHandle, 8, xrt::bo::flags::normal, bank_grp_idx);

    buf_addr[0] = xrt_buffer[0].address();
    buf_addr[1] = xrt_buffer[1].address();
    buf_addr[2] = xrt_buffer[2].address();
    buf_addr[3] = xrt_buffer[3].address();
    buf_addr[4] = xrt_buffer[4].address();
    buf_addr[5] = xrt_buffer[5].address();
#if WEIGHTED
    buf_addr[6] = xrt_buffer[6].address();
#endif
    buf_addr[7] = 0; // endian mode 0-big endian 1-little endian
    buf_addr[8] = overlay_buffer_size_in_bytes / sizeof(uint32_t); // not passing an address but number of cachelines to read from graph_csr_struct
    buf_addr[9] = 0;


    // initialize overlay
    overlay = (uint32_t *) malloc(overlay_buffer_size_in_bytes);

    for (uint32_t i = 0; i < (overlay_buffer_size_in_bytes / sizeof(uint32_t)); ++i)
    {
        overlay[i] = 0;
    }

    overlay[0] = 1; // 0 - increment/decrement
    overlay[1] = 0; // 1 - index_start
    overlay[2] = graph->num_vertices; // 2 - index_end
    overlay[3] = 1; // 3 - stride
    overlay[4] = 0x80000002; // 4 - granularity - log2 value for shifting
    overlay[5] = 0x000002C5; // 5 - STRUCT_ENGINE_SETUP - CMD_CONFIGURE
    overlay[6] = 0x00000000; // 6 - ALU_NOP - FILTER_NOP - OP_LOCATION_0
    overlay[7] = 0x00007011;//  7 - BUFFER | Configure first 3 engines | BUNDLE | VERTEX

}

int GLAYGraphCSRxrtBufferHandlePerBank::writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    xrt_buffer[0].write(overlay, overlay_buffer_size_in_bytes, 0);
    xrt_buffer[1].write(graph->vertices->in_degree, vertex_buffer_size_in_bytes, 0);
    xrt_buffer[2].write(graph->vertices->out_degree, vertex_buffer_size_in_bytes, 0);
    xrt_buffer[3].write(graph->vertices->edges_idx, vertex_buffer_size_in_bytes, 0);
    xrt_buffer[4].write(graph->sorted_edges_array->edges_array_src, edges_buffer_size_in_bytes, 0);
    xrt_buffer[5].write(graph->sorted_edges_array->edges_array_dest, edges_buffer_size_in_bytes, 0);
#if WEIGHTED
    xrt_buffer[6].write(graph->sorted_edges_array->edges_array_weight, edges_buffer_size_in_bytes, 0);
#endif

    xrt_buffer[0].sync(XCL_BO_SYNC_BO_TO_DEVICE, overlay_buffer_size_in_bytes, 0);
    xrt_buffer[1].sync(XCL_BO_SYNC_BO_TO_DEVICE, vertex_buffer_size_in_bytes, 0);
    xrt_buffer[2].sync(XCL_BO_SYNC_BO_TO_DEVICE, vertex_buffer_size_in_bytes, 0);
    xrt_buffer[3].sync(XCL_BO_SYNC_BO_TO_DEVICE, vertex_buffer_size_in_bytes, 0);
    xrt_buffer[4].sync(XCL_BO_SYNC_BO_TO_DEVICE, edges_buffer_size_in_bytes, 0);
    xrt_buffer[5].sync(XCL_BO_SYNC_BO_TO_DEVICE, edges_buffer_size_in_bytes, 0);
#if WEIGHTED
    xrt_buffer[6].sync(XCL_BO_SYNC_BO_TO_DEVICE, edges_buffer_size_in_bytes, 0);
#endif

    xrt_buffer[7].write(&buf_addr[7], 8, 0);
    xrt_buffer[7].sync(XCL_BO_SYNC_BO_TO_DEVICE, 8, 0);

    xrt_buffer[8].write(&buf_addr[8], 8, 0);
    xrt_buffer[8].sync(XCL_BO_SYNC_BO_TO_DEVICE, 8, 0);

    xrt_buffer[9].write(&buf_addr[9], 8, 0);
    xrt_buffer[9].sync(XCL_BO_SYNC_BO_TO_DEVICE, 8, 0);

    return 0;
}

int GLAYGraphCSRxrtBufferHandlePerBank::writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle)
{

    glayHandle->ipHandle.write_register(ADDR_BUFFER_0_DATA_0, (buf_addr[0]));
    glayHandle->ipHandle.write_register((ADDR_BUFFER_0_DATA_0 + 4), (buf_addr[0]) >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_1_DATA_0, (buf_addr[1]));
    glayHandle->ipHandle.write_register((ADDR_BUFFER_1_DATA_0 + 4), (buf_addr[1]) >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_2_DATA_0, (buf_addr[2]));
    glayHandle->ipHandle.write_register((ADDR_BUFFER_2_DATA_0 + 4), (buf_addr[2]) >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_3_DATA_0, (buf_addr[3]));
    glayHandle->ipHandle.write_register((ADDR_BUFFER_3_DATA_0 + 4), (buf_addr[3]) >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_4_DATA_0, (buf_addr[4]));
    glayHandle->ipHandle.write_register((ADDR_BUFFER_4_DATA_0 + 4), (buf_addr[4]) >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_5_DATA_0, (buf_addr[5]));
    glayHandle->ipHandle.write_register((ADDR_BUFFER_5_DATA_0 + 4), (buf_addr[5]) >> 32);

#if WEIGHTED
    glayHandle->ipHandle.write_register(ADDR_BUFFER_6_DATA_0, (buf_addr[6]));
    glayHandle->ipHandle.write_register((ADDR_BUFFER_6_DATA_0 + 4), (buf_addr[6]) >> 32);
#endif

    glayHandle->ipHandle.write_register(ADDR_BUFFER_7_DATA_0, buf_addr[7]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_7_DATA_0 + 4), buf_addr[7] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_8_DATA_0, buf_addr[8]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_8_DATA_0 + 4), buf_addr[8] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_9_DATA_0, buf_addr[9]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_9_DATA_0 + 4), buf_addr[9] >> 32);

    return 0;
}

int GLAYGraphCSRxrtBufferHandlePerBank::setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    glayHandle->runKernelHandle = xrt::run(glayHandle->kernelHandle);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_0_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[0]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_1_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[1]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_2_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[2]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_3_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[3]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_4_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[4]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_5_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[5]);
#if WEIGHTED
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_6_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[6]);
#endif
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_7_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[7]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_8_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[8]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_9_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[9]);

    return 0;
}


// ********************************************************************************************
// ***************                  GLAY Control                                 **************
// ********************************************************************************************

void freeGlayHandle (
    struct xrtGLAYHandle *glayHandle)
{

    //Close an opened device
    if(glayHandle)
        free(glayHandle
            );

}

void releaseGLAY(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}


// ********************************************************************************************
// ***************                  GLAY Control USER_MANAGED                    **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRUserManaged(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx)
{

    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = new GLAYGraphCSRxrtBufferHandlePerBank(glayHandle, graph, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);
    glayGraphCSRxrtBufferHandlePerBank->writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle);

    return glayGraphCSRxrtBufferHandlePerBank;
}

void startGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{

    uint32_t glay_control_write = 0;
    uint32_t glay_control_read  = 0;
    glay_control_write = CONTROL_START;

    glayHandle->ipHandle.write_register(CONTROL_OFFSET, glay_control_write);

    do
    {
        glay_control_read = glayHandle->ipHandle.read_register(CONTROL_OFFSET);
        printf("start %x \n", glay_control_read);
    }
    while(!(glay_control_read & CONTROL_READY));

    printf("wait %x \n", glay_control_read);

}

void waitGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    // uint32_t glay_control_write = 0;
    uint32_t glay_control_read = 0;
    // glay_control_write = CONTROL_START;

    // glayHandle->ipHandle.write_register(CONTROL_OFFSET, glay_control_write);

    do
    {
        glay_control_read = glayHandle->ipHandle.read_register(CONTROL_OFFSET);
        printf("wait %x \n", glay_control_read);
    }
    while(!(glay_control_read & CONTROL_IDLE));

    printf("wait %x \n", glay_control_read);
}

void releaseGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}


// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_HS                      **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRCtrlHs(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx)
{

    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = new GLAYGraphCSRxrtBufferHandlePerBank(glayHandle, graph, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);
    glayGraphCSRxrtBufferHandlePerBank->setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, glayGraphCSRxrtBufferHandlePerBank);

    return glayGraphCSRxrtBufferHandlePerBank;
}

void startGLAYCtrlHs(struct xrtGLAYHandle *glayHandle)
{

    glayHandle->runKernelHandle.start();

}

void waitGLAYCtrlHs(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->runKernelHandle.wait();
}

void releaseGLAYCtrlHs(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}


// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_CHAIN                   **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRCtrlChain(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx)
{

    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = new GLAYGraphCSRxrtBufferHandlePerBank(glayHandle, graph, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);
    glayGraphCSRxrtBufferHandlePerBank->setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, glayGraphCSRxrtBufferHandlePerBank);

    return glayGraphCSRxrtBufferHandlePerBank;
}

void startGLAYCtrlChain(struct xrtGLAYHandle *glayHandle)
{

    glayHandle->runKernelHandle.start();

}

void waitGLAYCtrlChain(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->runKernelHandle.wait();
}

void releaseGLAYCtrlChain(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}

