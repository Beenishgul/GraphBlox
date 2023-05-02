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

    Edges_buffer_size_in_bytes  = graph->num_edges * sizeof(uint32_t);
    Vertex_buffer_size_in_bytes = graph->num_vertices * sizeof(uint32_t);
    graph_buffer_size_in_bytes  = 32 * sizeof(uint64_t);

    // Each Memory bank contains a Graph CSR segment
    graph_csr_struct_buffer     =  xrt::bo(glayHandle->deviceHandle, graph_buffer_size_in_bytes,  bank_grp_idx);
    vertex_out_degree_buffer    =  xrt::bo(glayHandle->deviceHandle, Vertex_buffer_size_in_bytes, bank_grp_idx);
    vertex_in_degree_buffer     =  xrt::bo(glayHandle->deviceHandle, Vertex_buffer_size_in_bytes, bank_grp_idx);
    vertex_edges_idx_buffer     =  xrt::bo(glayHandle->deviceHandle, Vertex_buffer_size_in_bytes, bank_grp_idx);
    edges_array_src_buffer      =  xrt::bo(glayHandle->deviceHandle, Edges_buffer_size_in_bytes,  bank_grp_idx);
    edges_array_dest_buffer     =  xrt::bo(glayHandle->deviceHandle, Edges_buffer_size_in_bytes,  bank_grp_idx);

#if WEIGHTED
    edges_array_weight_buffer   =  xrt::bo(glayHandle->deviceHandle, Edges_buffer_size_in_bytes, bank_grp_idx);
#endif

    auxiliary_1_buffer          =  xrt::bo(glayHandle->deviceHandle, 8, xrt::bo::flags::normal, bank_grp_idx);
    auxiliary_2_buffer          =  xrt::bo(glayHandle->deviceHandle, 8, xrt::bo::flags::normal, bank_grp_idx);

    buf_addr[0] = graph_csr_struct_buffer.address();
    buf_addr[1] = vertex_out_degree_buffer.address();
    buf_addr[2] = vertex_in_degree_buffer.address();
    buf_addr[3] = vertex_edges_idx_buffer.address();
    buf_addr[4] = edges_array_src_buffer.address();
    buf_addr[5] = edges_array_dest_buffer.address();
#if WEIGHTED
    buf_addr[6] = edges_array_weight_buffer.address();
#endif
    buf_addr[7] = 0; // endian mode 0-big endian 1-little endian
    buf_addr[8] = graph_buffer_size_in_bytes / 64; // not passing an address but number of cachelines to read from graph_csr_struct

}

int GLAYGraphCSRxrtBufferHandlePerBank::writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{


    uint32_t *overlay = (uint32_t *) malloc(graph_buffer_size_in_bytes);

    for (uint32_t i = 0; i < (graph_buffer_size_in_bytes / sizeof(uint32_t)); ++i)
    {
        overlay[i] = i;
    }

    graph_csr_struct_buffer.write(overlay, graph_buffer_size_in_bytes, 0);
    vertex_out_degree_buffer.write(graph->vertices->out_degree, Vertex_buffer_size_in_bytes, 0);
    vertex_in_degree_buffer.write(graph->vertices->in_degree, Vertex_buffer_size_in_bytes, 0);
    vertex_edges_idx_buffer.write(graph->vertices->edges_idx, Vertex_buffer_size_in_bytes, 0);
    edges_array_src_buffer.write(graph->sorted_edges_array->edges_array_src, Edges_buffer_size_in_bytes, 0);
    edges_array_dest_buffer.write(graph->sorted_edges_array->edges_array_dest, Edges_buffer_size_in_bytes, 0);
#if WEIGHTED
    edges_array_weight_buffer.write(graph->sorted_edges_array->edges_array_weight, Edges_buffer_size_in_bytes, 0);
#endif


    graph_csr_struct_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, graph_buffer_size_in_bytes, 0);
    vertex_out_degree_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Vertex_buffer_size_in_bytes, 0);
    vertex_in_degree_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Vertex_buffer_size_in_bytes, 0);
    vertex_edges_idx_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Vertex_buffer_size_in_bytes, 0);
    edges_array_src_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Edges_buffer_size_in_bytes, 0);
    edges_array_dest_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Edges_buffer_size_in_bytes, 0);
#if WEIGHTED
    edges_array_weight_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Edges_buffer_size_in_bytes, 0);
#endif

    auxiliary_1_buffer.write(&buf_addr[7], 8, 0);
    auxiliary_1_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Vertex_buffer_size_in_bytes, 0);

    auxiliary_2_buffer.write(&buf_addr[8], 8, 0);
    auxiliary_2_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Vertex_buffer_size_in_bytes, 0);

    return 0;
}

int GLAYGraphCSRxrtBufferHandlePerBank::writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle)
{

    glayHandle->ipHandle.write_register(GRAPH_CSR_STRUCT_OFFSET, (buf_addr[0]));
    glayHandle->ipHandle.write_register((GRAPH_CSR_STRUCT_OFFSET + 4), (buf_addr[0]) >> 32);

    glayHandle->ipHandle.write_register(VERTEX_OUT_DEGREE_OFFSET, (buf_addr[1]));
    glayHandle->ipHandle.write_register((VERTEX_OUT_DEGREE_OFFSET + 4), (buf_addr[1]) >> 32);

    glayHandle->ipHandle.write_register(VERTEX_IN_DEGREE_OFFSET, (buf_addr[2]));
    glayHandle->ipHandle.write_register((VERTEX_IN_DEGREE_OFFSET + 4), (buf_addr[2]) >> 32);

    glayHandle->ipHandle.write_register(VERTEX_EDGES_IDX_OFFSET, (buf_addr[3]));
    glayHandle->ipHandle.write_register((VERTEX_EDGES_IDX_OFFSET + 4), (buf_addr[3]) >> 32);

    glayHandle->ipHandle.write_register(EDGES_ARRAY_DEST_OFFSET, (buf_addr[4]));
    glayHandle->ipHandle.write_register((EDGES_ARRAY_DEST_OFFSET + 4), (buf_addr[4]) >> 32);

    glayHandle->ipHandle.write_register(EDGES_ARRAY_SRC_OFFSET, (buf_addr[5]));
    glayHandle->ipHandle.write_register((EDGES_ARRAY_SRC_OFFSET + 4), (buf_addr[5]) >> 32);


#if WEIGHTED
    glayHandle->ipHandle.write_register(EDGES_ARRAY_WEIGHT_OFFSET, (buf_addr[6]));
    glayHandle->ipHandle.write_register((EDGES_ARRAY_WEIGHT_OFFSET + 4), (buf_addr[6]) >> 32);
#endif

    glayHandle->ipHandle.write_register(AUXILIARY_1_OFFSET, buf_addr[7]);
    glayHandle->ipHandle.write_register((AUXILIARY_1_OFFSET + 4), buf_addr[7] >> 32);

    glayHandle->ipHandle.write_register(AUXILIARY_2_OFFSET, buf_addr[8]);
    glayHandle->ipHandle.write_register((AUXILIARY_2_OFFSET + 4), buf_addr[8] >> 32);

    return 0;
}

int GLAYGraphCSRxrtBufferHandlePerBank::setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    glayHandle->runKernelHandle = xrt::run(glayHandle->kernelHandle);
    glayHandle->runKernelHandle.set_arg(GRAPH_CSR_STRUCT_ID, glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer);
    glayHandle->runKernelHandle.set_arg(VERTEX_OUT_DEGREE_ID, glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer);
    glayHandle->runKernelHandle.set_arg(VERTEX_IN_DEGREE_ID, glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer);
    glayHandle->runKernelHandle.set_arg(VERTEX_EDGES_IDX_ID, glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer);

#if WEIGHTED
    glayHandle->runKernelHandle.set_arg(EDGES_ARRAY_WEIGHT_ID, glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer);
#endif

    glayHandle->runKernelHandle.set_arg(EDGES_ARRAY_DEST_ID, glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer);
    glayHandle->runKernelHandle.set_arg(EDGES_ARRAY_SRC_ID, glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer);

    glayHandle->runKernelHandle.set_arg(AUXILIARY_1_ID, glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer);
    glayHandle->runKernelHandle.set_arg(AUXILIARY_2_ID, glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer);

    return 0;
}


// ********************************************************************************************
// ***************                  GLAY Control                                 **************
// ********************************************************************************************

void freeGlayHandle(struct xrtGLAYHandle *glayHandle)
{

    //Close an opened device
    if(glayHandle)
        free(glayHandle);

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
    uint32_t glay_control_read  = 0;
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

