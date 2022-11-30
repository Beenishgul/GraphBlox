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
    if(glayHandle->glay_kernel == NULL)
    {
        printf("ERROR:--> xrtPLKernelOpen\n");
        return -1;
    }


    return 0;

}



// ********************************************************************************************
// ***************                  GLAY General                                 **************
// ********************************************************************************************

struct GLAYGraphCSRxrtBufferHandle *allocateGLAYGraphCSRDeviceBuffers(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph)
{


    struct GLAYGraphCSRxrtBufferHandle *glayGraphxrtBufferHandle = (struct GLAYGraphCSRxrtBufferHandle *) my_malloc(sizeof(struct GLAYGraphCSRxrtBufferHandle));

    glayGraphxrtBufferHandle->Edges_buffer_size_in_bytes  = graph->num_edges * sizeof(uint32_t);
    glayGraphxrtBufferHandle->Vertex_buffer_size_in_bytes = graph->num_vertices * sizeof(uint32_t);
    glayGraphxrtBufferHandle->graph_buffer_size_in_bytes = sizeof(struct GLAYGraphCSR);

    // Each Memory bank contains a Graph CSR segment

    glayGraphxrtBufferHandle->graph_csr_struct_buffer     = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, (void *)glayGraph, graph_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_0);
    glayGraphxrtBufferHandle->vertex_out_degree_buffer    = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->vertex_out_degree, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_1);
    glayGraphxrtBufferHandle->vertex_in_degree_buffer     = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->vertex_in_degree, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_2);
    glayGraphxrtBufferHandle->vertex_edges_idx_buffer     = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->vertex_edges_idx, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_3);
    glayGraphxrtBufferHandle->edges_array_weight_buffer   = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->edges_array_weight, Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_4);
    glayGraphxrtBufferHandle->edges_array_src_buffer      = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->edges_array_src, Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_5);
    glayGraphxrtBufferHandle->edges_array_dest_buffer     = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->edges_array_dest, Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_6);
    glayGraphxrtBufferHandle->auxiliary_1_buffer          = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->auxiliary1, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_7);
    glayGraphxrtBufferHandle->auxiliary_2_buffer          = xrtBufferHandlexrtBOAllocUserPtr(glayHandle->deviceHandle, glayGraph->auxiliary2, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_8);


    return glayHandlexrtBufferHandle;
}


int writeGLAYGraphCSRHostToDeviceBuffers(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandle *glayGraphxrtBufferHandle)
{

    xrtBufferHandle input_buffer = xrtBOAlloc(device, buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_0);

    xrtBOWrite(input_buffer, buff_data, data_size * sizeof(int), 0);
    xrtSyncBO(input_buffer, XCL_BO_SYNC_BO_TO_DEVICE, data_size * sizeof(int), 0)

    return 0;
}

int writeGLAYGraphCSRDeviceToHostBuffers(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph)
{

    xrtBufferHandle input_buffer = xrtBOAlloc(device, buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_0);


    xrtBOWrite(input_buffer, buff_data, data_size * sizeof(int), 0);
    xrtSyncBO(input_buffer, XCL_BO_SYNC_BO_TO_DEVICE, data_size * sizeof(int), 0)

    return 0;
}


int setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph)
{

    xrtBufferHandle input_buffer = xrtBOAlloc(device, buffer_size_in_bytes, XRT_BO_FLAGS_NONE, bank_grp_idx_0);


    xrtBOWrite(input_buffer, buff_data, data_size * sizeof(int), 0);
    xrtSyncBO(input_buffer, XCL_BO_SYNC_BO_TO_DEVICE, data_size * sizeof(int), 0)

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