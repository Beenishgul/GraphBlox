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

#include "glayenv.h"
#include "myMalloc.h"

// ********************************************************************************************
// ***************                  XRT General                                  **************
// ********************************************************************************************

int setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath)
{

    glayHandle = (struct xrtGLAYHandle *) my_malloc(sizeof(struct xrtGLAYHandle));
    glayHandle->deviceIndex = deviceIndex;
    glayHandle->xclbinPath = xclbinPath;
    glayHandle->deviceHandle = NULL;
    glayHandle->xclbinHandle = NULL;
    glayHandle->kernelHandle = NULL;
    // glayHandle->xclbinUUID

    //Open a Device (use "xbutil scan" to show the available devices)
    glayHandle->deviceHandle = xrtDeviceOpen(glayHandle->deviceIndex);
    if(glayHandle->deviceHandle == NULL)
    {
        printf("ERROR:--> xrtDeviceOpen\n");
        return -1;
    }

    //Load compiled kernel binary onto the device
    glayHandle->xclbinHandle = xrtXclbinAllocFilename(glayHandle->xclbinPath);
    if(glayHandle->xclbinHandle == NULL)
    {
        printf("ERROR:--> xrtXclbinAllocFilename\n");
        return -1;
    }


    if(xrtDeviceLoadXclbinHandle(glayHandle->deviceHandle, glayHandle->xclbinHandle))
    {
        printf("ERROR:--> xrtDeviceLoadXclbinHandle\n");
        return -1;
    }

    //Get UUID of xclbin handle
    if(xrtXclbinGetUUID(glayHandle->xclbinHandle, glayHandle->xclbinUUID))
    {
        printf("ERROR:--> xrtXclbinGetUUID(%p)", glayHandle->xclbinUUID);
        return -1;
    }


    glayHandle->kernelHandle = xrtPLKernelOpenExclusive(glayHandle->deviceHandle, glayHandle->xclbinUUID, "glay_kernel");
    if(glayHandle->kernelHandle == NULL)
    {
        printf("ERROR:--> xrtPLKernelOpen\n");
        return -1;
    }


    return 0;

}



// ********************************************************************************************
// ***************                  GLAY General                                 **************
// ********************************************************************************************

struct GLAYGraphCSRxrtBufferHandlePerBank *allocateGLAYGraphCSRDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx)
{

    struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = (struct GLAYGraphCSRxrtBufferHandlePerBank *) my_malloc(sizeof(struct GLAYGraphCSRxrtBufferHandlePerBank));

    glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes  = graph->num_edges * sizeof(uint32_t);
    glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes = graph->num_vertices * sizeof(uint32_t);
    glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes = sizeof(struct GLAYGraphCSR);

    glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx = xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx);

    // Each Memory bank contains a Graph CSR segment
    glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer     = xrtBOAllocUserPtr(glayHandle->deviceHandle, (void *)glayGraph, glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer    = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->vertex_out_degree, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer     = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->vertex_in_degree, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer     = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->vertex_edges_idx, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer      = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->edges_array_src, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer     = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->edges_array_dest, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);

#if WEIGHTED
    glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer   = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->edges_array_weight, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);
#endif

    glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer          = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->auxiliary1, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);
    glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer          = xrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->auxiliary2, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx);

    return glayGraphCSRxrtBufferHandlePerBank;
}


int writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer, glayGraph, glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes, 0);
    xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes, 0);

    xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer, graph->vertices->out_degree, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);

    xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer, graph->vertices->in_degree, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);

    xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer, graph->vertices->edges_idx, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);

    xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer, graph->sorted_edges_array->edges_array_src, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
    xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);

    xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer, graph->sorted_edges_array->edges_array_dest, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
    xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);

#if WEIGHTED
    xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer, graph->sorted_edges_array->edges_array_weight, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
    xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, 0);
#endif

    // xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer, graph->auxiliary_1, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    // xrtSyncBO(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0)

    // xrtBOWrite(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer, graph->auxiliary_2, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    // xrtSyncBO(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer, XCL_BO_SYNC_BO_TO_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0)

    return 0;
}

int readGLAYGraphCSRDeviceToHostBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph)
{


    xrtBORead(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer, graph->auxiliary_1, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    xrtSyncBO(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer, XCL_BO_SYNC_BO_FROM_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0)

    xrtBORead(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer, graph->auxiliary_2, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    xrtSyncBO(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer, XCL_BO_SYNC_BO_FROM_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0)

    return 0;
}


int setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx)
{

    struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = allocateGLAYGraphCSRDeviceBuffersPerBank(glayHandle, graph, glayGraph, bank_grp_idx);
    writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);

    return 0;
}


void startGLAY(struct xrtGLAYHandle *glayHandle, struct GLAYGraphCSR *glayGraphCSR)
{

}


void startGLAYCU(struct xrtGLAYHandle *glayHandle, struct GLAYGraphCSR *glayGraphCSR)
{

}

void waitGLAY(struct xrtGLAYHandle *glayHandle)
{


}

void releaseGLAY(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    xrtKernelClose(glayHandle->kernelHandle);
    xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}

void freeGlayHandle(struct xrtGLAYHandle *glayHandle)
{

    //Close an opened device
    if(glayHandle)
        free(glayHandle);

}

void printGLAYDeviceInfo(struct xrtGLAYHandle *glayHandle)
{

}

// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

void printGLAYGraphCSRPointers(struct GLAYGraphCSR *glayGraphCSR)
{
    printf("*-----------------------------------------------------*\n");
    printf("| %-12s %-24s %-12s | \n", " ", "GLay GraphCSR structure", " ");
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24p| \n", "glayGraphCSR",   glayGraphCSR);
    printf("| %-25s | %-24u| \n", "num_edges", glayGraphCSR->num_edges);
    printf("| %-25s | %-24u| \n", "num_vertices", glayGraphCSR->num_vertices);
    printf("| %-25s | %-24f| \n", "max_weight", glayGraphCSR->max_weight);
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24p| \n", "vertex_in_degree", glayGraphCSR->vertex_in_degree);
    printf("| %-25s | %-24p| \n", "vertex_out_degree", glayGraphCSR->vertex_out_degree);
    printf("| %-25s | %-24p| \n", "vertex_edges_idx", glayGraphCSR->vertex_edges_idx);
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24p| \n", "edges_array_src", glayGraphCSR->edges_array_src);
    printf("| %-25s | %-24p| \n", "edges_array_dest", glayGraphCSR->edges_array_dest);
    printf("| %-25s | %-24p| \n", "edges_array_weight", glayGraphCSR->edges_array_weight);
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24p| \n", "auxiliary1", glayGraphCSR->auxiliary1);
    printf("| %-25s | %-24p| \n", "auxiliary2", glayGraphCSR->auxiliary2);
    printf(" -----------------------------------------------------\n");
}