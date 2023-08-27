// -----------------------------------------------------------------------------
//
//      "00_GLay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : graphConfig.c
// Create : 2022-06-29 12:31:24
// Revise : 2022-09-28 15:36:13
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "graphConfig.h"
#include "myMalloc.h"

void argumentsFree (struct Arguments *arguments)
{
    if(arguments)
    {
        if(arguments->fnameb)
            free(arguments->fnameb);
        if(arguments->fnamel)
            free(arguments->fnamel);
        if(arguments->kernel_name)
            free(arguments->kernel_name);
        if(arguments->xclbin_path)
            free(arguments->xclbin_path);
        if(arguments->overlay_path)
            free(arguments->overlay_path);
        free(arguments);
    }
}

void argumentsPrint (struct Arguments *arguments)
{


}

struct Arguments *argumentsNew()
{

    struct Arguments *arguments = (struct Arguments *)my_malloc(sizeof(struct Arguments));
    /* Default values. */
    arguments->wflag = 0;
    arguments->xflag = 0;
    arguments->sflag = 0;
    arguments->Sflag = 0;
    arguments->dflag = 0;
    arguments->binSize = 512;
    arguments->verbosity = 0;
    arguments->iterations = 20;
    arguments->trials = 1;
    arguments->epsilon = 0.0001;
    arguments->source = 0;
    arguments->algorithm = 0;
    arguments->datastructure = 0;
    arguments->pushpull = 0;
    arguments->sort = 0;
    arguments->mmode = 0;
    arguments->cache_size = 32768; // 32KB for DBG reordering or GRID based structures

    arguments->lmode = 0;
    arguments->lmode_l2 = 0;
    arguments->lmode_l3 = 0;

    arguments->symmetric = 0;
    arguments->weighted = 0;
    arguments->delta = 1;
    arguments->pre_numThreads  = 1;
    arguments->algo_numThreads = 1;
    arguments->ker_numThreads  = 1;
    arguments->fnameb = NULL;
    arguments->fnamel = NULL;
    arguments->fnameb_format = 1;
    arguments->convert_format = 1;
    initializeMersenneState (&(arguments->mt19937var), 27491095);
    // GLay Xilinx Parameters

    arguments->kernel_name = NULL;
    arguments->device_index = 0;
    arguments->xclbin_path = NULL;
    arguments->overlay_path = NULL;
    arguments->glayHandle = NULL;

    return arguments;

}


void argumentsCopy (struct Arguments *argFrom, struct Arguments *argTo)
{
    argTo->wflag = argFrom->wflag;
    argTo->xflag = argFrom->xflag;
    argTo->sflag = argFrom->sflag;
    argTo->Sflag = argFrom->Sflag;
    argTo->dflag = argFrom->dflag;
    argTo->binSize = argFrom->binSize;
    argTo->verbosity = argFrom->verbosity;
    argTo->iterations = argFrom->iterations;
    argTo->trials = argFrom->trials;
    argTo->epsilon = argFrom->epsilon;
    argTo->source = argFrom->source;
    argTo->algorithm = argFrom->algorithm;
    argTo->datastructure = argFrom->datastructure;
    argTo->pushpull = argFrom->pushpull;
    argTo->sort = argFrom->sort;
    argTo->mmode = argFrom->mmode;
    argTo->cache_size = argFrom->cache_size; // 32KB for DBG reordering or GRID based structures

    argTo->lmode = argFrom->lmode;
    argTo->lmode_l2 = argFrom->lmode_l2;
    argTo->lmode_l3 = argFrom->lmode_l3;

    argTo->symmetric = argFrom->symmetric;
    argTo->weighted = argFrom->weighted;
    argTo->delta = argFrom->delta;
    argTo->pre_numThreads  = argFrom->pre_numThreads;
    argTo->algo_numThreads = argFrom->algo_numThreads;
    argTo->ker_numThreads  = argFrom->ker_numThreads;

    argTo->fnameb = (char *) malloc((strlen(argFrom->fnameb) + 10) * sizeof(char));
    argTo->fnamel = (char *) malloc((strlen(argFrom->fnamel) + 10) * sizeof(char));

    argTo->fnameb  = strcpy (argTo->fnameb, argFrom->fnameb);
    argTo->fnamel  = strcpy (argTo->fnamel, argFrom->fnamel);

    argTo->fnameb_format =  argFrom->fnameb_format;
    argTo->fnameb_format = argFrom->fnameb_format;
}