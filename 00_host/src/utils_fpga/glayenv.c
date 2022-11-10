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
        printf("ERROR:--> xrtXclbinGetUUID");
        return -1;
    }

    return 0;

}



// ********************************************************************************************
// ***************                  GLAY General                                 **************
// ********************************************************************************************

int setupGLAYGraphCSR(struct xrtGLAYHandle *glayHandle)
{


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
    xrtDeviceClose(glayHandle->deviceHandle);

}

void printGLAYDeviceInfo(struct xrtGLAYHandle *glayHandle){

}

// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct  GLAYGraphCSR *mapGraphCSRToGLAY(struct GraphCSR *graph)
{

    struct GLAYGraphCSR *glayGraphCSR = (struct GLAYGraphCSR *) my_malloc(sizeof(struct GLAYGraphCSR));

    glayGraphCSR->num_edges    = graph->num_edges;
    glayGraphCSR->num_vertices = graph->num_vertices;
#if WEIGHTED
    glayGraphCSR->max_weight   = graph->max_weight;
#else
    glayGraphCSR->max_weight   = 0;
#endif

    glayGraphCSR->vertex_out_degree  = graph->vertices->out_degree;
    glayGraphCSR->vertex_in_degree   = graph->vertices->in_degree;
    glayGraphCSR->vertex_edges_idx   = graph->vertices->edges_idx;

    glayGraphCSR->edges_array_src    = graph->sorted_edges_array->edges_array_src;
    glayGraphCSR->edges_array_dest   = graph->sorted_edges_array->edges_array_dest;
#if WEIGHTED
    glayGraphCSR->edges_array_weight = graph->sorted_edges_array->edges_array_weight;
#else
    glayGraphCSR->edges_array_weight = 0;
#endif

#if DIRECTED
    glayGraphCSR->inverse_vertex_out_degree  = graph->inverse_vertices->out_degree;
    glayGraphCSR->inverse_vertex_in_degree   = graph->inverse_vertices->in_degree;
    glayGraphCSR->inverse_vertex_edges_idx   = graph->inverse_vertices->edges_idx;

    glayGraphCSR->inverse_edges_array_src    = graph->inverse_sorted_edges_array->edges_array_src;
    glayGraphCSR->inverse_edges_array_dest   = graph->inverse_sorted_edges_array->edges_array_dest;
#if WEIGHTED
    glayGraphCSR->inverse_edges_array_weight = graph->inverse_sorted_edges_array->edges_array_weight;
#else
    glayGraphCSR->inverse_edges_array_weight = 0;
#endif
#endif


    glayGraphCSR->auxiliary0 = 0;
    return glayGraphCSR;
}


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
    printf("| %-25s | %-24p| \n", "inverse_vertex_in_degree", glayGraphCSR->inverse_vertex_in_degree);
    printf("| %-25s | %-24p| \n", "inverse_vertex_out_degree", glayGraphCSR->inverse_vertex_out_degree);
    printf("| %-25s | %-24p| \n", "inverse_vertex_edges_idx", glayGraphCSR->inverse_vertex_edges_idx);
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24p| \n", "inverse_edges_array_src", glayGraphCSR->inverse_edges_array_src);
    printf("| %-25s | %-24p| \n", "inverse_edges_array_dest", glayGraphCSR->inverse_edges_array_dest);
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24u| \n", "auxiliary0", glayGraphCSR->auxiliary0);
    printf("| %-25s | %-24p| \n", "auxiliary1", glayGraphCSR->auxiliary1);
    printf("| %-25s | %-24p| \n", "auxiliary2", glayGraphCSR->auxiliary2);
    printf(" -----------------------------------------------------\n");
}