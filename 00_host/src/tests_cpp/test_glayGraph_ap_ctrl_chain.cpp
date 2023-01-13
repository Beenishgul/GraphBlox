// -----------------------------------------------------------------------------
//
//      "00_GLay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : glay.c
// Create : 2022-06-21 17:15:17
// Revise : 2022-09-28 15:37:28
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

#include "glayenv.hpp"

#ifdef __cplusplus
extern "C" {
#endif

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <argp.h>
#include <stdbool.h>
#include <omp.h>
#include <stdint.h>

#include "myMalloc.h"
#include "timer.h"
#include "mt19937.h"
#include "graphConfig.h"
#include "graphRun.h"
#include "graphStats.h"
#include "edgeList.h"
#include "sortRun.h"
#include "reorder.h"

#include "graphCSRSegments.h"
#include "edgeList.h"

const char *argp_program_version =
    "GLay v1.0";
const char *argp_program_bug_address =
    "<atmughrabi@gmail.com>|<atmughra@virginia.edu>|<atmughra@alumni.ncsu.edu>";
/* Program documentation. */
static char doc[] =
    "GLay is an open source graph processing overlay framework, it is designed to be a benchmarking suite for various graph processing algorithms using pure C and GGDL.";

/* A description of the arguments we accept. */
static char args_doc[] = "-f <graph file> -d [data structure] -a [algorithm] -r [root] -n [num threads] [-h -c -s -w]";

/* The options we understand. */
static struct argp_option options[] =
{
    {
        "graph-file",          'f', "<FILE>",      0,
        "Edge list represents the graph binary format to run the algorithm textual format change graph-file-format."
    },
    {
        "graph-file-format",   'z', "[DEFAULT:[1]-binary-edgeList]",      0,
        "Specify file format to be read, is it textual edge list, or a binary file edge list. This is specifically useful if you have Graph CSR/Grid structure already saved in a binary file format to skip the preprocessing step. [0]-text edgeList [1]-binary edgeList [2]-graphCSR binary."
    },
    {
        "algorithm",          'a', "[DEFAULT:[0]-BFS]",      0,
        "[0]-BFS, [1]-Page-rank, [2]-SSSP-DeltaStepping, [3]-SSSP-BellmanFord, [4]-DFS,[5]-SPMV, [6]-Connected-Components, [7]-Betweenness-Centrality, [8]-Triangle Counting."
    },
    {
        "data-structure",     'd', "[DEFAULT:[0]-CSR]",      0,
        "[0]-CSR, [1]-CSR Segmented (use cache-size parameter)"
    },
    {
        "root",               'r', "[DEFAULT:0]",      0,
        "BFS, DFS, SSSP root"
    },
    {
        "direction",          'p', "[DEFAULT:[0]-PULL]",      0,
        "[0]-PULL, [1]-PUSH,[2]-HYBRID. NOTE: Please consult the function switch table for each algorithm."
    },
    {
        "sort",               'o', "[DEFAULT:[0]-radix-src]",      0,
        "[0]-radix-src [1]-radix-src-dest [2]-count-src [3]-count-src-dst."
    },
    {
        "pre-num-threads",    'n', "[DEFAULT:MAX]",      0,
        "Number of threads for preprocessing (graph structure) step "
    },
    {
        "algo-num-threads",   'N', "[DEFAULT:MAX]",      0,
        "Number of threads for graph processing (graph algorithm)"
    },
    {
        "Kernel-num-threads", 'K', "[DEFAULT:algo-num-threads]",      0,
        "Number of threads for graph processing kernel (critical-path) (graph algorithm)"
    },
    {
        "num-iterations",     'i', "[DEFAULT:20]",      0,
        "Number of iterations for page rank to converge [default:20] SSSP-BellmanFord [default:V-1]."
    },
    {
        "num-trials",         't', "[DEFAULT:[1 Trial]]",      0,
        "Number of trials for whole run (graph algorithm run) [default:1]."
    },
    {
        "tolerance",          'e', "[EPSILON:0.0001]",      0,
        "Tolerance value of for page rank [default:0.0001]."
    },
    {
        "delta",              'b', "[DEFAULT:1]",      0,
        "SSSP Delta value [Default:1]."
    },
    {
        "light-reorder-l1",   'l', "[DEFAULT:[0]-no-reordering]",      0,
        "Relabels the graph for better cache performance (first layer). [0]-no-reordering, [1]-out-degree, [2]-in-degree, [3]-(in+out)-degree, [4]-DBG-out, [5]-DBG-in, [6]-HUBSort-out, [7]-HUBSort-in, [8]-HUBCluster-out, [9]-HUBCluster-in, [10]-(random)-degree,  [11]-LoadFromFile (used for Rabbit order)."
    },
    {
        "light-reorder-l2",   'L', "[DEFAULT:[0]-no-reordering]",      0,
        "Relabels the graph for better cache performance (second layer). [0]-no-reordering, [1]-out-degree, [2]-in-degree, [3]-(in+out)-degree, [4]-DBG-out, [5]-DBG-in, [6]-HUBSort-out, [7]-HUBSort-in, [8]-HUBCluster-out, [9]-HUBCluster-in, [10]-(random)-degree,  [11]-LoadFromFile (used for Rabbit order)."
    },
    {
        "light-reorder-l3",   'O', "[DEFAULT:[0]-no-reordering]",      0,
        "Relabels the graph for better cache performance (third layer). [0]-no-reordering, [1]-out-degree, [2]-in-degree, [3]-(in+out)-degree, [4]-DBG-out, [5]-DBG-in, [6]-HUBSort-out, [7]-HUBSort-in, [8]-HUBCluster-out, [9]-HUBCluster-in, [10]-(random)-degree,  [11]-LoadFromFile (used for Rabbit order)."
    },
    {
        "convert-format",     'c', "[DEFAULT:[1]-binary-edgeList]",      0,
        "[serialize flag must be on --serialize to write] Serialize graph text format (edge list format) to binary graph file on load example:-f <graph file> -c this is specifically useful if you have Graph CSR/Grid structure and want to save in a binary file format to skip the preprocessing step for future runs. [0]-text-edgeList [1]-binary-edgeList [2]-graphCSR-binary [3]-graphCSR-test(5 files)."
    },
    {
        "generate-weights",   'w', 0,      0,
        "Load or Generate weights. Check ->graphConfig.h #define WEIGHTED 1 beforehand then recompile using this option."
    },
    {
        "symmetrize",         's', 0,      0,
        "Symmetric graph, create a set of incoming edges."
    },
    {
        "serialize",          'x', 0,      0,
        "Enable file conversion/serialization use with --convert-format."
    },
    {
        "stats",              'S', 0,      0,
        "Write algorithm stats to file. same directory as the graph.PageRank: Dumps top-k ranks matching using QPR similarity metrics."
    },
    {
        "bin-size",          'g', "[SIZE:512]",      0,
        "You bin vertices histogram according to this parameter, if you have a large graph you want to illustrate."
    },
    {
        "verbosity",         'j', "[DEFAULT:[0:no stats output]",      0,
        "For now it controls the output of .perf file and PageRank .stats (needs --stats enabled) filesPageRank .stat [1:top-k results] [2:top-k results and top-k ranked vertices listed."
    },
    {
        "remove-duplicate",  'k', 0,      0,
        "Removers duplicate edges and self loops from the graph."
    },
    {
        "mask-mode",         'M', "[DEFAULT:[0:disabled]]",      0,
        "Encodes [0:disabled] the last two bits of [1:out-degree]-Edgelist-labels [2:in-degree]-Edgelist-labels or [3:out-degree]-vertex-property-data  [4:in-degree]-vertex-property-data with hot/cold hints [11:HOT]|[10:WARM]|[01:LUKEWARM]|[00:COLD] to specialize caching. The algorithm needs to support value unmask to work."
    },
    {
        "labels-file",       'F', "<FILE>",      0,
        "Read and reorder vertex labels from a text file, Specify the file name for the new graph reorder, generated from Gorder, Rabbit-order, etc."
    },
    {
        "cache-size",        'C', "<LLC=32768/32KB>",      0,
        "LLC cache size for MASK vertex reordering"
    },
    {
        "kernel-name",            'Q', "[DEFAULT:NULL]\n",      0,
        "\nKernel package name.\n"
    },
    {
        "xclbin-path",            'm', "[DEFAULT:NULL]\n",      0,
        "\nHardware overlay (XCLBIN) file for hw or hw_emu mode.\n"
    },
    {
        "device-index",             'q', "[DEFAULT:0]\n",      0,
        "\nDevice ID of your target card use \"xbutil list\" command.\n"
    },
    { 0 }
};



/* Parse a single option. */
static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
    /* Get the input argument from argp_parse, which we
       know is a pointer to our arguments structure. */
    struct Arguments *arguments = (struct Arguments *)state->input;

    switch (key)
    {
    case 'f':
        arguments->fnameb = (char *) malloc((strlen(arg) + 10) * sizeof(char));
        arguments->fnameb  = strcpy (arguments->fnameb, arg);
        break;
    case 'F':
        arguments->fnamel = (char *) malloc((strlen(arg) + 10) * sizeof(char));
        arguments->fnamel  = strcpy (arguments->fnamel, arg);
        break;
    case 'z':
        arguments->fnameb_format = atoi(arg);
        break;
    case 'd':
        arguments->datastructure = atoi(arg);
        break;
    case 'a':
        arguments->algorithm = atoi(arg);
        break;
    case 'r':
        arguments->source = atoi(arg);
        break;
    case 'n':
        arguments->pre_numThreads = atoi(arg);
        break;
    case 'N':
        arguments->algo_numThreads = atoi(arg);
        break;
    case 'K':
        arguments->ker_numThreads = atoi(arg);
        break;
    case 'i':
        arguments->iterations = atoi(arg);
        break;
    case 't':
        arguments->trials = atoi(arg);
        break;
    case 'e':
        arguments->epsilon = atof(arg);
        break;
    case 'p':
        arguments->pushpull = atoi(arg);
        break;
    case 'o':
        arguments->sort = atoi(arg);
        break;
    case 'l':
        arguments->lmode = atoi(arg);
        break;
    case 'L':
        arguments->lmode_l2 = atoi(arg);
        break;
    case 'O':
        arguments->lmode_l3 = atoi(arg);
        break;
    case 'b':
        arguments->delta = atoi(arg);
        break;
    case 's':
        arguments->symmetric = 1;
        break;
    case 'S':
        arguments->Sflag = 1;
        break;
    case 'w':
        arguments->weighted = 1;
        break;
    case 'x':
        arguments->xflag = 1;
        break;
    case 'c':
        arguments->convert_format = atoi(arg);
        break;
    case 'C':
        arguments->cache_size = atoi(arg);
        break;
    case 'g':
        arguments->binSize = atoi(arg);
        break;
    case 'j':
        arguments->verbosity = atoi(arg);
        break;
    case 'k':
        arguments->dflag = 1;
        break;
    case 'M':
        arguments->mmode = atoi(arg);
        break;
    case 'm':
        arguments->device_index = atoi(arg);
        break;
    case 'Q':
        arguments->kernel_name = (char *) malloc((strlen(arg) + 10) * sizeof(char));
        arguments->kernel_name  = strcpy (arguments->kernel_name, arg);
        break;
    case 'q':
        arguments->xclbin_path = (char *) malloc((strlen(arg) + 10) * sizeof(char));
        arguments->xclbin_path  = strcpy (arguments->xclbin_path, arg);
        break;
    default:
        return ARGP_ERR_UNKNOWN;
    }
    return 0;
}

static struct argp argp = { options, parse_opt, args_doc, doc };

int
main (int argc, char **argv)
{
    struct Arguments *arguments = argumentsNew();
    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    argp_parse (&argp, argc, argv, 0, 0, arguments);

    int bank_grp_idx = 1;
    struct GLAYGraphCSR *glayGraph = (struct GLAYGraphCSR *) my_malloc(sizeof(struct GLAYGraphCSR));
    struct GraphCSR *graph = (struct GraphCSR *)generateGraphDataStructure(arguments);
    arguments->glayHandle = setupGLAYDevice(arguments->glayHandle, arguments->device_index, arguments->xclbin_path);
   
    if(arguments->glayHandle == NULL)
    {
        printf("ERROR:--> setupGLAYDevice\n");
    }

    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank;
    glayGraphCSRxrtBufferHandlePerBank = setupGLAYGraphCSR(arguments->glayHandle, graph, glayGraph, bank_grp_idx);

    startGLAYUserManaged(arguments->glayHandle);

    waitGLAYUserManaged(arguments->glayHandle);

    // closeGLAYUserManaged(arguments->glayHandle);

    // releaseGLAY(arguments->glayHandle);
    free(timer);
    free(glayGraph);
    argumentsFree(arguments);
    exit (0);
}


#ifdef __cplusplus
}
#endif



