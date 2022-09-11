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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "glayenv.h"




// ********************************************************************************************
// ***************                  XRT General                                  **************
// ********************************************************************************************



// ********************************************************************************************
// ***************                  GLAY General                                 **************
// ********************************************************************************************

int setupGLAYGraphCSR(struct xrtGLAYHandle *afu, struct GLAYGraphCSR *glayGraphCSR)
{


    return 0;

}


void startGLAY(struct xrtGLAYHandle *afu, struct GLAYGraphCSR *glayGraphCSR)
{

}


void startGLAYCU(struct cxl_afu_h **afu, struct AFUStatus *afu_status)
{

}

void waitGLAY(struct cxl_afu_h **afu, struct AFUStatus *afu_status)
{


}

void readGLAYStats(struct cxl_afu_h **afu, struct CmdResponseStats *cmdResponseStats)
{


}

void releaseGLAY(struct cxl_afu_h **afu)
{

}


// ********************************************************************************************
// ***************                   DataStructure                               **************
// ********************************************************************************************


// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct  GraphCSR *mapGraphCSRToGLAY(struct GraphCSR *graph)
{

    struct WEDGraphCSR *wed = malloc(sizeof(struct GraphCSR));

    wed->num_edges    = graph->num_edges;
    wed->num_vertices = graph->num_vertices;
#if WEIGHTED
    wed->max_weight   = graph->max_weight;
#else
    wed->max_weight   = 0;
#endif

    return wed;
}


void printGLAYGraphCSRPointers(struct  GraphCSR *wed)
{

    printf("*-----------------------------------------------------*\n");
    printf("| %-12s %-24s %-12s | \n", " ", "GraphCSR structure", " ");
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24p| \n", "wed",   wed);
    printf("| %-25s | %-24u| \n", "num_edges", wed->num_edges);
    printf("| %-25s | %-24u| \n", "num_vertices", wed->num_vertices);
    printf(" -----------------------------------------------------\n");
}