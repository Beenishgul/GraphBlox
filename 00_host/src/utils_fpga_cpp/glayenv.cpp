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

    std::vector<xrt::xclbin::ip> cu;
    glayHandle->ipHandle      = xrt::ip(glayHandle->deviceHandle, glayHandle->xclbinUUID, "glay_kernel");
    glayHandle->xclbinHandle  = xrt::xclbin(glayHandle->xclbinPath);

    std::cout << "Fetch compute Units" << std::endl;
    for (auto &kernel : glayHandle->xclbinHandle.get_kernels())
    {
        if (kernel.get_name() == "glay_kernel")
        {
            cu = kernel.get_cus();
        }
    }

    if (cu.empty()) throw std::runtime_error("IP glay_kernel not found in the provided xclbin");

    std::cout << "Determine memory index\n";
    for (auto &mem : glayHandle->xclbinHandle.get_mems())
    {
        if (mem.get_used())
        {
            glayHandle->mem_used = mem;
            break;
        }
    }

    std::cout << "device name                   :     " << glayHandle->deviceHandle.get_info<xrt::info::device::name>() << "\n";
    std::cout << "device bdf                    :     " << glayHandle->deviceHandle.get_info<xrt::info::device::bdf>() << "\n";
    std::cout << "device max_clock_frequency_mhz:     " << glayHandle->deviceHandle.get_info<xrt::info::device::max_clock_frequency_mhz>() << "\n";

    return glayHandle;

}



// ********************************************************************************************
// ***************                  GLAY General                                 **************
// ********************************************************************************************

struct GLAYGraphCSRxrtBufferHandlePerBank *allocateGLAYGraphCSRDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, int bank_grp_idx)
{

    struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = (struct GLAYGraphCSRxrtBufferHandlePerBank *) my_malloc(sizeof(struct GLAYGraphCSRxrtBufferHandlePerBank));

    glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes  = graph->num_edges * sizeof(uint32_t);
    glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes = graph->num_vertices * sizeof(uint32_t);
    glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes = sizeof(struct GLAYGraphCSR);

    // Each Memory bank contains a Graph CSR segment
    glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer     =  xrt::bo(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer    =  xrt::bo(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer     =  xrt::bo(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer     =  xrt::bo(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer      =  xrt::bo(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer     =  xrt::bo(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);

#if WEIGHTED
    glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer   =  xrt::bo(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
#endif

    // glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer          =  xrt::bo(glayHandle->deviceHandle, Vertex_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);
    // glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer          =  xrt::bo(glayHandle->deviceHandle, Vertex_buffer_size_in_bytes, xrt::bo::flags::normal, bank_grp_idx);

    glayGraphCSRxrtBufferHandlePerBank->buf_addr[0] = glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer.address();
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[1] = glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer.address();
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[2] = glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer.address();
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[3] = glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer.address();
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[4] = glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer.address();
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[5] = glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer.address();
#if WEIGHTED
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[6] = glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer.address();
#endif
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[7] = glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer.address();
    glayGraphCSRxrtBufferHandlePerBank->buf_addr[8] = glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer.address();

    return glayGraphCSRxrtBufferHandlePerBank;
}

int writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer.write(glayGraph, glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes, 0);
    glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes, 0);

    glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer.write(graph->vertices->out_degree, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);

    glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer.write(graph->vertices->in_degree, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);

    glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer.write(graph->vertices->edges_idx, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);

    glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer.write(graph->sorted_edges_array->edges_array_src, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
    glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);

    glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer.write(graph->sorted_edges_array->edges_array_dest, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
    glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);

#if WEIGHTED
    glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer.write(graph->sorted_edges_array->edges_array_weight, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
    glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
#endif

    // glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer.write(graph->auxiliary_1, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    // xrtSyncBO(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0)

    // glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer.write(graph->auxiliary_2, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    // xrtSyncBO(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer.sync(XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0)

    return 0;
}

int writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    xrtKernelWriteRegister(glayHandle->kernelHandle, GRAPH_CSR_STRUCT_OFFSET, glayGraphCSRxrtBufferHandlePerBank->buf_addr[0]);
    xrtKernelWriteRegister(glayHandle->kernelHandle, (GRAPH_CSR_STRUCT_OFFSET + 4), glayGraphCSRxrtBufferHandlePerBank->buf_addr[0] >> 32);

    xrtKernelWriteRegister(glayHandle->kernelHandle, VERTEX_OUT_DEGREE_OFFSET, glayGraphCSRxrtBufferHandlePerBank->buf_addr[0]);
    xrtKernelWriteRegister(glayHandle->kernelHandle, (VERTEX_OUT_DEGREE_OFFSET + 4), glayGraphCSRxrtBufferHandlePerBank->buf_addr[0] >> 32);

    xrtKernelWriteRegister(glayHandle->kernelHandle, VERTEX_IN_DEGREE_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->buf_addr[0]));
    xrtKernelWriteRegister(glayHandle->kernelHandle, (VERTEX_IN_DEGREE_OFFSET + 4), xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer) >> 32);

    xrtKernelWriteRegister(glayHandle->kernelHandle, VERTEX_EDGES_IDX_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer));
    xrtKernelWriteRegister(glayHandle->kernelHandle, (VERTEX_EDGES_IDX_OFFSET + 4), xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer) >> 32);

    xrtKernelWriteRegister(glayHandle->kernelHandle, EDGES_ARRAY_DEST_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer));
    xrtKernelWriteRegister(glayHandle->kernelHandle, (EDGES_ARRAY_DEST_OFFSET + 4), xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer) >> 32);

    xrtKernelWriteRegister(glayHandle->kernelHandle, EDGES_ARRAY_SRC_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer));
    xrtKernelWriteRegister(glayHandle->kernelHandle, (EDGES_ARRAY_SRC_OFFSET + 4), xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer) >> 32);


#if WEIGHTED
    xrtKernelWriteRegister(glayHandle->kernelHandle, EDGES_ARRAY_WEIGHT_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer));
    xrtKernelWriteRegister(glayHandle->kernelHandle, (EDGES_ARRAY_WEIGHT_OFFSET + 4), xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer) >> 32);
#endif

    // xrtKernelWriteRegister(glayHandle->kernelHandle, AUXILIARY_1_OFFSET, glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer);
    // xrtKernelWriteRegister(glayHandle->kernelHandle, (AUXILIARY_1_OFFSET + 4), glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer >> 32);

    // xrtKernelWriteRegister(glayHandle->kernelHandle, AUXILIARY_2_OFFSET, glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer);
    // xrtKernelWriteRegister(glayHandle->kernelHandle, (AUXILIARY_2_OFFSET + 4), glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer >> 32);

    return 0;
}