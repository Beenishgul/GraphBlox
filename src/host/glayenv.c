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

int setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath)
{

    int i;
    glayHandle = malloc(sizeof(struct xrtGLAYHandle));
    glayHandle->deviceIndex = deviceIndex;
    glayHandle->xclbinPath = xclbinPath;
    glayHandle->deviceHandle = NULL;
    glayHandle->xclbinHandle = NULL;
    glayHandle->xclbinUUID = 0;

    //Open a Device (use "xbutil scan" to show the available devices)
    glayHandle->deviceHandle = xrtDeviceOpen(glayHandle->deviceIndex);
    if(glayHandle->deviceHandle == NULL)
    {
        printf("ERROR: %s --> xrtDeviceOpen(%i)\n", glayHandle->deviceIndex, glayHandle->deviceIndex);
        return -1;
    }

    //Load compiled kernel binary onto the device
    glayHandle->xclbinHandle = xrtXclbinAllocFilename(glayHandle->xclbinPath);
    if(glayHandle->xclbinHandle == NULL)
    {
        printf("ERROR: %s --> xrtXclbinAllocFilename(%s)\n", glayHandle->deviceIndex, glayHandle->xclbinPath);
        return -1;
    }


    if(xrtDeviceLoadXclbinHandle(glayHandle->deviceHandle, glayHandle->xclbinHandle))
    {
        printf("ERROR: %s --> xrtDeviceLoadXclbinHandle()\n",glayHandle->xclbinHandle);
        return -1;
    }

    //Get UUID of xclbin handle
    if(xrtXclbinGetUUID(glayHandle->xclbinHandle, glayHandle->xclbinUUID))
    {
        printf("ERROR: %s --> xrtXclbinGetUUID()\n", glayHandle->xclbinUUID);
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


// ********************************************************************************************
// ***************                   DataStructure                               **************
// ********************************************************************************************


// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct  GLAYGraphCSR *mapGraphCSRToGLAY(struct GLAYGraphCSR *glayGraphCSR)
{

    struct GLAYGraphCSR *glayGraphCSR = malloc(sizeof(struct GLAYGraphCSR));

    glayGraphCSR->num_edges    = graph->num_edges;
    glayGraphCSR->num_vertices = graph->num_vertices;

    return glayGraphCSR;
}


void printGLAYDeviceInfo(struct xrtGLAYHandle *glayHandle){

    printf("ERROR: %s --> xrtDeviceOpen(%i)\n", glayHandle->deviceIndex, glayHandle->deviceIndex);
    printf("ERROR: %s --> xrtXclbinAllocFilename(%s)\n", glayHandle->deviceIndex, glayHandle->xclbinPath);
    printf("ERROR: %s --> xrtDeviceLoadXclbinHandle()\n",glayHandle->deviceIndex);
    printf("ERROR: %s --> xrtXclbinGetUUID()\n", glayHandle->deviceIndex);
}

void printGLAYGraphCSRPointers(struct  GLAYGraphCSR *glayGraphCSR)
{

    printf("*-----------------------------------------------------*\n");
    printf("| %-12s %-24s %-12s | \n", " ", "GraphCSR structure", " ");
    printf(" -----------------------------------------------------\n");
    printf("| %-25s | %-24p| \n", "wed",   glayGraphCSR);
    printf("| %-25s | %-24u| \n", "num_edges", glayGraphCSR->num_edges);
    printf("| %-25s | %-24u| \n", "num_vertices", glayGraphCSR->num_vertices);
    printf(" -----------------------------------------------------\n");
}