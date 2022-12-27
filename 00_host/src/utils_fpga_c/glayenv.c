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

struct xrtGLAYHandle *setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath)
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
        return NULL;
    }

    //Load compiled kernel binary onto the device
    glayHandle->xclbinHandle = xrtXclbinAllocFilename(glayHandle->xclbinPath);
    if(glayHandle->xclbinHandle == NULL)
    {
        printf("ERROR:--> xrtXclbinAllocFilename\n");
        return NULL;
    }


    if(xrtDeviceLoadXclbinHandle(glayHandle->deviceHandle, glayHandle->xclbinHandle))
    {
        printf("ERROR:--> xrtDeviceLoadXclbinHandle\n");
        return NULL;
    }

    //Get UUID of xclbin handle
    if(xrtXclbinGetUUID(glayHandle->xclbinHandle, glayHandle->xclbinUUID))
    {
        printf("ERROR:--> xrtXclbinGetUUID(%p)", glayHandle->xclbinUUID);
        return NULL;
    }

    glayHandle->kernelHandle = xrtPLKernelOpenExclusive(glayHandle->deviceHandle, glayHandle->xclbinUUID, "glay_kernel");
    if(glayHandle->kernelHandle == NULL)
    {
        printf("ERROR:--> xrtPLKernelOpen\n");
        return NULL;
    }

    printf("UUID : %02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x \n",
           glayHandle->xclbinUUID[0],  glayHandle->xclbinUUID[1],  glayHandle->xclbinUUID[2],  glayHandle->xclbinUUID[3],
           glayHandle->xclbinUUID[4],  glayHandle->xclbinUUID[5],
           glayHandle->xclbinUUID[6],  glayHandle->xclbinUUID[7],
           glayHandle->xclbinUUID[8],  glayHandle->xclbinUUID[9],
           glayHandle->xclbinUUID[10],  glayHandle->xclbinUUID[11],  glayHandle->xclbinUUID[12],  glayHandle->xclbinUUID[13],  glayHandle->xclbinUUID[14],  glayHandle->xclbinUUID[15]);


    return glayHandle;

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

    // glayGraphCSRxrtBufferHandlePerBank->bank_grp_idx = xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx);

    // Each Memory bank contains a Graph CSR segment
    glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer     = xrtBOAlloc(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->graph_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx +0));
    glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer    = xrtBOAlloc(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE,xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx+ 1));
    glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer     = xrtBOAlloc(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE,xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx+ 2));
    glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer     = xrtBOAlloc(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE,xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx+ 3));
    glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer      = xrtBOAlloc(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx+ 4));
    glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer     = xrtBOAlloc(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx+ 5));

#if WEIGHTED
    glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer   = xrtBOAlloc(glayHandle->deviceHandle, glayGraphCSRxrtBufferHandlePerBank->Edges_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, (xrtMemoryGroup) xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx + 6));
#endif

    // glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer          = xrtBOAlloc(glayHandle->deviceHandle, glayGraph->auxiliary1, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, (xrtMemoryGroup) xrtKernelArgGroupId(glayHandle->kernelHandle, bank_grp_idx +7));
    // glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer          = xrtBOAlloc(glayHandle->deviceHandle, glayGraph->auxiliary2, Vertex_buffer_size_in_bytes, XRT_BO_FLAGS_NONE, (xrtMemoryGroup) xrtKernelArgGroupId(glayHandle->kernelHandle,bank_grp_idx + 8));

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

int writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

  
    xrtKernelWriteRegister(glayHandle->kernelHandle, GRAPH_CSR_STRUCT_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer));
    xrtKernelWriteRegister(glayHandle->kernelHandle, (GRAPH_CSR_STRUCT_OFFSET + 4), xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer) >> 32);

    xrtKernelWriteRegister(glayHandle->kernelHandle, VERTEX_OUT_DEGREE_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer));
    xrtKernelWriteRegister(glayHandle->kernelHandle, (VERTEX_OUT_DEGREE_OFFSET + 4), xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer) >> 32);

    xrtKernelWriteRegister(glayHandle->kernelHandle, VERTEX_IN_DEGREE_OFFSET, xrtBOAddress(glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer));
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

int freeGLAYGraphCSRHostToDeviceBuffersPerBank(struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{

    xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->graph_csr_struct_buffer);
    xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->vertex_out_degree_buffer);
    xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->vertex_in_degree_buffer);
    xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->vertex_edges_idx_buffer);
    xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->edges_array_src_buffer);
    xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->edges_array_dest_buffer);
#if WEIGHTED
    xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->edges_array_weight_buffer);
#endif
    // xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer);
    // xrtBOFree(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer);

    return 0;
}

int readGLAYGraphCSRDeviceToHostBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{
    // xrtBORead(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer, graph->auxiliary_1, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    // xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->auxiliary_1_buffer, XCL_BO_SYNC_BO_FROM_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0)

    // xrtBORead(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer, graph->auxiliary_2, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    // xrtBOSync(glayGraphCSRxrtBufferHandlePerBank->auxiliary_2_buffer, XCL_BO_SYNC_BO_FROM_DEVICE, glayGraphCSRxrtBufferHandlePerBank->Vertex_buffer_size_in_bytes, 0);
    return 0;
}


int setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSR *glayGraph, int bank_grp_idx)
{

    struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = allocateGLAYGraphCSRDeviceBuffersPerBank(glayHandle, graph, glayGraph, bank_grp_idx);
    writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);
    writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraph, glayGraphCSRxrtBufferHandlePerBank);

    return 0;
}

void startGLAYRun(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->kernelHandleRun = xrtKernelRun(glayHandle->kernelHandle);
}

void startGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    uint32_t glay_control_write = 0;
    uint32_t glay_control_read  = 0;
    glay_control_write = CONTROL_START;

    xrtKernelWriteRegister(glayHandle->kernelHandle, CONTROL_OFFSET, glay_control_write);

    do
    {
        xrtKernelReadRegister(glayHandle->kernelHandle, CONTROL_OFFSET, &glay_control_read);
    }
    while(!(glay_control_read & CONTROL_READY));

}

void waitGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    uint32_t glay_control_write = 0;
    uint32_t glay_control_read  = 0;
    glay_control_write = CONTROL_START;

    xrtKernelWriteRegister(glayHandle->kernelHandle, CONTROL_OFFSET, glay_control_write);

    do
    {
        xrtKernelReadRegister(glayHandle->kernelHandle, CONTROL_OFFSET, &glay_control_read);
    }
    while(!(glay_control_read & CONTROL_IDLE));
}

void waitGLAYRun(struct xrtGLAYHandle *glayHandle)
{
    xrtRunWait(glayHandle->kernelHandleRun);
}

void closeGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    xrtRunClose(glayHandle->kernelHandleRun);
}

void closeGLAYRun(struct xrtGLAYHandle *glayHandle)
{
    xrtRunClose(glayHandle->kernelHandleRun);
}

void releaseGLAY(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
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