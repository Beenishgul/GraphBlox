// -----------------------------------------------------------------------------
//
//      "00_GraphBlox"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : graphBlox.c
// Create : 2022-06-21 17:15:17
// Revise : 2022-09-28 15:37:28
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

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
#include "edgeListDynamic.h"

const char *argp_program_version =
    "GraphBlox v1.0";
const char *argp_program_bug_address =
    "<atmughrabi@gmail.com>|<atmughra@virginia.edu>|<atmughra@alumni.ncsu.edu>";
/* Program documentation. */
static char doc[] =
    "GraphBlox is an open source graph processing overlay framework, it is designed to be a benchmarking suite for various graph processing algorithms using pure C and GGDL.";

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
    arguments->pre_numThreads  = omp_get_max_threads();
    arguments->algo_numThreads = omp_get_max_threads();
    arguments->ker_numThreads  = arguments->algo_numThreads;
    arguments->fnameb = NULL;
    arguments->fnamel = NULL;
    arguments->fnameb_format = 1;
    arguments->convert_format = 1;
    initializeMersenneState (&(arguments->mt19937var), 27491095);
    omp_set_nested(1);

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    argp_parse (&argp, argc, argv, 0, 0, arguments);

    if(arguments->dflag)
        arguments->sort = 1;

    if(arguments->algorithm == 8)  // Triangle counting depends on order
    {

        arguments->sort = 1;
        // arguments->lmode = 2;
    }

    if(arguments->algorithm == 9)  // Incremental aggregation order
    {

        arguments->sort = 1;
        // arguments->lmode = 2;
    }

    if(arguments->fnameb_format == 0)  // for now it edge list is text only convert to binary
    {
        Start(timer);
        arguments->fnameb = readEdgeListsDynamictxt(arguments->fnameb, arguments->weighted);
        arguments->fnamel = readEdgeListsDynamictxt(arguments->fnamel, arguments->weighted);
        arguments->fnameb_format = 1; // now you have a bin file
#if WEIGHTED
        arguments->weighted = 1; // no need to generate weights again this affects readedgelistDynamicbin
#else
        arguments->weighted = 0;
#endif
        Stop(timer);
        generateGraphPrintMessageWithtime("Serialize EdgeListDynamic text to binary (Seconds)", Seconds(timer));
    }

    printf("Filename : %s \n", arguments->fnameb);

    Start(timer);
    struct EdgeListDynamic *edgeListDynamic = readEdgeListsDynamicbin(arguments->fnameb, 0, arguments->symmetric, arguments->weighted);
    struct EdgeList *edgeList = newEdgeListFromDynamic(edgeListDynamic);
    freeEdgeListDynamic(edgeListDynamic);
    edgeListPrintBasic(edgeList);

    struct EdgeListDynamic *edgeListDynamic_actions = readEdgeListsDynamicbin(arguments->fnamel, 0, arguments->symmetric, arguments->weighted);
    Stop(timer);
    // // edgeListDynamicPrint(edgeListDynamic);
    // graphCSRSegmentsPrintMessageWithtime("Read Edge List From File (Seconds)", Seconds(timer));

    // Start(timer);
    edgeList = sortRunAlgorithms(edgeList, arguments->sort);
    // edgeListPrint(edgeList);
    if(arguments->dflag)
    {
        Start(timer);
        // edgeList = removeDulpicatesSelfLoopEdges(edgeList);
        Stop(timer);
        graphCSRPrintMessageWithtime("Removing duplicate edges (Seconds)", Seconds(timer));
    }


    Start(timer);
    struct GraphCSRSegments *graphCSRSegments = graphCSRSegmentsNew(edgeList, arguments);
    Stop(timer);
    graphCSRSegmentsPrintMessageWithtime("Create Graph Grid (Seconds)", Seconds(timer));


    uint32_t i;

    for ( i = 0; i < (graphCSRSegments->csrSegments->num_vertices); ++i)
    {
        // printf("v:%u --> s:%u \n", i, graphCSRSegments->csrSegments->vertex_segment_index[i]);
        // edgeListPrintBasic(graphCSRSegments->csrSegments->segments[i].edgeList);
    }


    uint32_t *activeSegments = (uint32_t *) my_malloc( graphCSRSegments->csrSegments->num_segments * sizeof(uint32_t));
    uint32_t *activeSegments2 = (uint32_t *) my_malloc( graphCSRSegments->csrSegments->num_segments * sizeof(uint32_t));

    for (i = 0; i < graphCSRSegments->csrSegments->num_segments ; ++i)
    {
        activeSegments[i] = 0;
        activeSegments2[i] = 0;
    }

    for(i = 0; i < edgeListDynamic_actions->num_edges; i++)
    {

        // src  = edgeList->edges_array_src[i];
        uint32_t dest = edgeListDynamic_actions->edges_array_dest[i];
        uint32_t operation = edgeListDynamic_actions->edges_array_operation[i];
        uint32_t col = getSegmentID(graphCSRSegments->csrSegments->num_vertices, graphCSRSegments->csrSegments->num_segments, dest);
        uint32_t Segment_idx = graphCSRSegments->csrSegments->vertex_segment_index[dest];


        if(!operation)
        {
            activeSegments[col]++;
            activeSegments2[Segment_idx]++;
        }
    }

    for (i = 0; i < graphCSRSegments->csrSegments->num_segments ; ++i)
    {
        printf("%u - %u\n", activeSegments[i],  activeSegments2[i]);
    }

    for (i = 0; i < graphCSRSegments->csrSegments->num_segments ; ++i)
    {
        activeSegments[i] = 0;
        activeSegments2[i] = 0;
    }


    printf("First 100K \n");

    for(i = 0; i < 100000; i++)
    {

        // src  = edgeList->edges_array_src[i];
        uint32_t dest = edgeListDynamic_actions->edges_array_dest[i];
        uint32_t operation = edgeListDynamic_actions->edges_array_operation[i];
        uint32_t col = getSegmentID(graphCSRSegments->csrSegments->num_vertices, graphCSRSegments->csrSegments->num_segments, dest);
        uint32_t Segment_idx = graphCSRSegments->csrSegments->vertex_segment_index[dest];


        if(!operation)
        {
            activeSegments[col]++;
            activeSegments2[Segment_idx]++;
        }
    }

    for (i = 0; i < graphCSRSegments->csrSegments->num_segments ; ++i)
    {
        printf("%u - %u\n", activeSegments[i],  activeSegments2[i]);
    }


    for (i = 0; i < graphCSRSegments->csrSegments->num_segments ; ++i)
    {
        activeSegments[i] = 0;
        activeSegments2[i] = 0;
    }


    printf("Last 100K \n");

    for(i = edgeListDynamic_actions->num_edges - 100000; i < edgeListDynamic_actions->num_edges; i++)
    {

        // src  = edgeList->edges_array_src[i];
        uint32_t dest = edgeListDynamic_actions->edges_array_dest[i];
        uint32_t operation = edgeListDynamic_actions->edges_array_operation[i];
        uint32_t col = getSegmentID(graphCSRSegments->csrSegments->num_vertices, graphCSRSegments->csrSegments->num_segments, dest);
        uint32_t Segment_idx = graphCSRSegments->csrSegments->vertex_segment_index[dest];


        if(!operation)
        {
            activeSegments[col]++;
            activeSegments2[Segment_idx]++;
        }
    }

    for (i = 0; i < graphCSRSegments->csrSegments->num_segments ; ++i)
    {
        printf("%u - %u\n", activeSegments[i],  activeSegments2[i]);
    }



    graphCSRSegmentsPrint(graphCSRSegments);


    // freeEdgeListDynamic(edgeListDynamic);
    freeEdgeListDynamic(edgeListDynamic_actions);
    freeEdgeList(edgeList);
    free(timer);

    argumentsFree(arguments);
    exit (0);
}


#ifdef __cplusplus
}
#endif



