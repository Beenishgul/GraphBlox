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

struct xrtGLAYHandle *setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath)
{

    glayHandle = (struct xrtGLAYHandle *) my_malloc(sizeof(struct xrtGLAYHandle));
    glayHandle->deviceIndex = deviceIndex;
    glayHandle->xclbinPath = xclbinPath;

    //Open a Device (use "xbutil scan" to show the available devices)
    std::cout << "Open the device :" << glayHandle->deviceIndex << std::endl;
    glayHandle->deviceHandle = xrt::device(glayHandle->deviceIndex);

    std::cout << "Load the xclbin : " << glayHandle->xclbinPath << std::endl;
    glayHandle->xclbinUUID = glayHandle->deviceHandle.load_xclbin(glayHandle->xclbinPath);

    glayHandle->ipHandle      = xrt::ip(glayHandle->deviceHandle, glayHandle->xclbinUUID, "glay_kernel");
    glayHandle->xclbinHandle  = xrt::xclbin(glayHandle->xclbinPath);

    std::cout << "Fetch compute Units" << std::endl;
    for (auto &kernel : glayHandle->xclbinHandle.get_kernels())
    {
        if (kernel.get_name() == "glay_kernel")
        {
            glayHandle->cuHandles = kernel.get_cus();
        }
    }

    if (glayHandle->cuHandles.empty()) throw std::runtime_error("IP glay_kernel not found in the provided xclbin");

    std::cout << "Determine memory index\n";
    for (auto &mem : glayHandle->xclbinHandle.get_mems())
    {
        if (mem.get_used())
        {
            glayHandle->mem_used = mem;
            break;
        }
    }

    // glayHandle->interruptHandle = glayHandle->ipHandle.create_interrupt_notify();
    // glayHandle->interruptHandle.disable();

    std::cout << "device name                   :     " << glayHandle->deviceHandle.get_info<xrt::info::device::name>() << "\n";
    std::cout << "device bdf                    :     " << glayHandle->deviceHandle.get_info<xrt::info::device::bdf>() << "\n";
    std::cout << "device max_clock_frequency_mhz:     " << glayHandle->deviceHandle.get_info<xrt::info::device::max_clock_frequency_mhz>() << "\n";

    // glayHandle->cuHandles[0].
    std::cout << "Kernel Arguments Offsets:" << "\n"; 
    for (auto i: glayHandle->cuHandles[0].get_args())
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
    graph_buffer_size_in_bytes = sizeof(struct GLAYGraphCSR);

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

    // auxiliary_1_buffer          =  xrt::bo(glayHandle->deviceHandle, Vertex_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
    // auxiliary_2_buffer          =  xrt::bo(glayHandle->deviceHandle, Vertex_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);

    buf_addr[0] = graph_csr_struct_buffer.address();
    buf_addr[1] = vertex_out_degree_buffer.address();
    buf_addr[2] = vertex_in_degree_buffer.address();
    buf_addr[3] = vertex_edges_idx_buffer.address();
    buf_addr[4] = edges_array_src_buffer.address();
    buf_addr[5] = edges_array_dest_buffer.address();
#if WEIGHTED
    buf_addr[6] = edges_array_weight_buffer.address();
#endif
    // buf_addr[7] = auxiliary_1_buffer.address();
    // buf_addr[8] = auxiliary_2_buffer.address();

}

int GLAYGraphCSRxrtBufferHandlePerBank::writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    graph_csr_struct_buffer.write(glayGraph, graph_buffer_size_in_bytes, 0);
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

    // auxiliary_1_buffer.write(graph->auxiliary_1, Vertex_buffer_size_in_bytes, 0);
    // xrtSyncBO(auxiliary_1_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Vertex_buffer_size_in_bytes, 0)

    // auxiliary_2_buffer.write(graph->auxiliary_2, Vertex_buffer_size_in_bytes, 0);
    // xrtSyncBO(auxiliary_2_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, Vertex_buffer_size_in_bytes, 0)

    return 0;
}

int GLAYGraphCSRxrtBufferHandlePerBank::writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
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

    // glayHandle->ipHandle.write_register(AUXILIARY_1_OFFSET, buf_addr[7]);
    // glayHandle->ipHandle.write_register((AUXILIARY_1_OFFSET + 4), buf_addr[7] >> 32);

    // glayHandle->ipHandle.write_register(AUXILIARY_2_OFFSET, buf_addr[8]);
    // glayHandle->ipHandle.write_register((AUXILIARY_2_OFFSET + 4), buf_addr[8] >> 32);

    return 0;
}

GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx)
{

    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = new GLAYGraphCSRxrtBufferHandlePerBank(glayHandle, graph, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);
    glayGraphCSRxrtBufferHandlePerBank->writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);

    return glayGraphCSRxrtBufferHandlePerBank;
}



// ********************************************************************************************
// ***************                  GLAY Control                                 **************
// ********************************************************************************************

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
    uint32_t glay_control_write = 0;
    uint32_t glay_control_read  = 0;
    glay_control_write = CONTROL_START;

    glayHandle->ipHandle.write_register(CONTROL_OFFSET, glay_control_write);

    do
    {
        glay_control_read = glayHandle->ipHandle.read_register(CONTROL_OFFSET);
        printf("wait %x \n", glay_control_read);
    }
    while(!(glay_control_read & CONTROL_IDLE));

    printf("wait %x \n", glay_control_read);
}

// void releaseGLAY(struct xrtGLAYHandle *glayHandle)
// {
//     //Close an opened device
//     // xrtKernelClose(glayHandle->kernelHandle);
//     xrtDeviceClose(glayHandle->deviceHandle);
//     freeGlayHandle(glayHandle);
// }

void freeGlayHandle(struct xrtGLAYHandle *glayHandle)
{

    //Close an opened device
    if(glayHandle)
        free(glayHandle);

}