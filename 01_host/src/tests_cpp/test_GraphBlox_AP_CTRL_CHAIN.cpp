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

#include "graphbloxenv.hpp"

#ifdef __cplusplus
extern "C" {
#endif

#include <argp.h>
#include <ctype.h>
#include <omp.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "edgeList.h"
#include "graphConfig.h"
#include "mt19937.h"
#include "myMalloc.h"
#include "sortRun.h"
#include "timer.h"

#include "graphCSRSegments.h"

#include "BFS.h"
#include "SPMV.h"
#include "connectedComponents.h"
#include "pageRank.h"
#include "triangleCount.h"

#include "graphRun.h"
#include "graphStats.h"
#include "reorder.h"
// #include "graphBloxGDL_emu.h"

void initialize_PR_auxiliary_struct(struct GraphCSR *graph,
                                    struct GraphAuxiliary *graphAuxiliary,
                                    struct Arguments *arguments);
void multiple_iteration_PR(struct GraphCSR *graph,
                           struct GraphAuxiliary *graphAuxiliary,
                           struct Arguments *arguments, struct Timer *timer);
void initialize_BFS_auxiliary_struct(struct GraphCSR *graph,
                                     struct GraphAuxiliary *graphAuxiliary,
                                     struct Arguments *arguments);
void multiple_iteration_BFS(struct GraphCSR *graph,
                            struct GraphAuxiliary *graphAuxiliary,
                            struct Arguments *arguments, struct Timer *timer);
void initialize_CC_auxiliary_struct(struct GraphCSR *graph,
                                    struct GraphAuxiliary *graphAuxiliary,
                                    struct Arguments *arguments);
void multiple_iteration_CC(struct GraphCSR *graph,
                           struct GraphAuxiliary *graphAuxiliary,
                           struct Arguments *arguments, struct Timer *timer);
void initialize_TC_auxiliary_struct(struct GraphCSR *graph,
                                    struct GraphAuxiliary *graphAuxiliary,
                                    struct Arguments *arguments);
void multiple_iteration_TC(struct GraphCSR *graph,
                           struct GraphAuxiliary *graphAuxiliary,
                           struct Arguments *arguments, struct Timer *timer);
void free_auxiliary_struct(struct GraphAuxiliary *graphAuxiliary);

const char *argp_program_version = "GraphBlox v1.0";
const char *argp_program_bug_address =
    "<atmughrabi@gmail.com>|<atmughra@virginia.edu>|<atmughra@alumni.ncsu.edu>";
/* Program documentation. */
static char doc[] =
    "GraphBlox is an open source graph processing overlay framework, it is designed "
    "to be a benchmarking suite for various graph processing algorithms using "
    "pure C and GGDL.";

/* A description of the arguments we accept. */
static char args_doc[] = "-f <graph file> -d [data structure] -a [algorithm] "
                         "-r [root] -n [num threads] [-h -c -s -w]";

/* The options we understand. */
static struct argp_option options[] = {
    {"graph-file", 'f', "<FILE>", 0,
     "Edge list represents the graph binary format to run the algorithm "
     "textual format change graph-file-format."},
    {"graph-file-format", 'z', "[DEFAULT:[1]-binary-edgeList]", 0,
     "Specify file format to be read, is it textual edge list, or a binary "
     "file edge list. This is specifically useful if you have Graph CSR/Grid "
     "structure already saved in a binary file format to skip the "
     "preprocessing step. [0]-text edgeList [1]-binary edgeList [2]-graphCSR "
     "binary."},
    {"algorithm", 'a', "[DEFAULT:[0]-BFS]", 0,
     "[0]-BFS, [1]-Page-rank, [2]-SSSP-DeltaStepping, [3]-SSSP-BellmanFord, "
     "[4]-DFS,[5]-SPMV, [6]-Connected-Components, [7]-Betweenness-Centrality, "
     "[8]-Triangle Counting."},
    {"data-structure", 'd', "[DEFAULT:[0]-CSR]", 0,
     "[0]-CSR, [1]-CSR Segmented (use cache-size parameter)"},
    {"root", 'r', "[DEFAULT:0]", 0, "BFS, DFS, SSSP root"},
    {"direction", 'p', "[DEFAULT:[0]-PULL]", 0,
     "[0]-PULL, [1]-PUSH,[2]-HYBRID. NOTE: Please consult the function switch "
     "table for each algorithm."},
    {"sort", 'o', "[DEFAULT:[0]-radix-src]", 0,
     "[0]-radix-src [1]-radix-src-dest [2]-count-src [3]-count-src-dst."},
    {"pre-num-threads", 'n', "[DEFAULT:MAX]", 0,
     "Number of threads for preprocessing (graph structure) step "},
    {"algo-num-threads", 'N', "[DEFAULT:MAX]", 0,
     "Number of threads for graph processing (graph algorithm)"},
    {"Kernel-num-threads", 'K', "[DEFAULT:algo-num-threads]", 0,
     "Number of threads for graph processing kernel (critical-path) (graph "
     "algorithm)"},
    {"num-iterations", 'i', "[DEFAULT:20]", 0,
     "Number of iterations for page rank to converge [default:20] "
     "SSSP-BellmanFord [default:V-1]."},
    {"num-trials", 't', "[DEFAULT:[1 Trial]]", 0,
     "Number of trials for whole run (graph algorithm run) [default:1]."},
    {"tolerance", 'e', "[EPSILON:0.0001]", 0,
     "Tolerance value of for page rank [default:0.0001]."},
    {"delta", 'b', "[DEFAULT:1]", 0, "SSSP Delta value [Default:1]."},
    {"light-reorder-l1", 'l', "[DEFAULT:[0]-no-reordering]", 0,
     "Relabels the graph for better cache performance (first layer). "
     "[0]-no-reordering, [1]-out-degree, [2]-in-degree, [3]-(in+out)-degree, "
     "[4]-DBG-out, [5]-DBG-in, [6]-HUBSort-out, [7]-HUBSort-in, "
     "[8]-HUBCluster-out, [9]-HUBCluster-in, [10]-(random)-degree,  "
     "[11]-LoadFromFile (used for Rabbit order)."},
    {"light-reorder-l2", 'L', "[DEFAULT:[0]-no-reordering]", 0,
     "Relabels the graph for better cache performance (second layer). "
     "[0]-no-reordering, [1]-out-degree, [2]-in-degree, [3]-(in+out)-degree, "
     "[4]-DBG-out, [5]-DBG-in, [6]-HUBSort-out, [7]-HUBSort-in, "
     "[8]-HUBCluster-out, [9]-HUBCluster-in, [10]-(random)-degree,  "
     "[11]-LoadFromFile (used for Rabbit order)."},
    {"light-reorder-l3", 'O', "[DEFAULT:[0]-no-reordering]", 0,
     "Relabels the graph for better cache performance (third layer). "
     "[0]-no-reordering, [1]-out-degree, [2]-in-degree, [3]-(in+out)-degree, "
     "[4]-DBG-out, [5]-DBG-in, [6]-HUBSort-out, [7]-HUBSort-in, "
     "[8]-HUBCluster-out, [9]-HUBCluster-in, [10]-(random)-degree,  "
     "[11]-LoadFromFile (used for Rabbit order)."},
    {"convert-format", 'c', "[DEFAULT:[1]-binary-edgeList]", 0,
     "[serialize flag must be on --serialize to write] Serialize graph text "
     "format (edge list format) to binary graph file on load example:-f <graph "
     "file> -c this is specifically useful if you have Graph CSR/Grid "
     "structure and want to save in a binary file format to skip the "
     "preprocessing step for future runs. [0]-text-edgeList "
     "[1]-binary-edgeList [2]-graphCSR-binary [3]-graphCSR-test(5 files)."},
    {"generate-weights", 'w', 0, 0,
     "Load or Generate weights. Check ->graphConfig.h #define WEIGHTED 1 "
     "beforehand then recompile using this option."},
    {"symmetrize", 's', 0, 0,
     "Symmetric graph, create a set of incoming edges."},
    {"serialize", 'x', 0, 0,
     "Enable file conversion/serialization use with --convert-format."},
    {"stats", 'S', 0, 0,
     "Write algorithm stats to file. same directory as the graph.PageRank: "
     "Dumps top-k ranks matching using QPR similarity metrics."},
    {"bin-size", 'g', "[SIZE:512]", 0,
     "You bin vertices histogram according to this parameter, if you have a "
     "large graph you want to illustrate."},
    {"verbosity", 'j', "[DEFAULT:[0:no stats output]", 0,
     "For now it controls the output of .perf file and PageRank .stats (needs "
     "--stats enabled) filesPageRank .stat [1:top-k results] [2:top-k results "
     "and top-k ranked vertices listed."},
    {"remove-duplicate", 'k', 0, 0,
     "Removers duplicate edges and self loops from the graph."},
    {"mask-mode", 'M', "[DEFAULT:[0:disabled]]", 0,
     "Encodes [0:disabled] the last two bits of [1:out-degree]-Edgelist-labels "
     "[2:in-degree]-Edgelist-labels or [3:out-degree]-vertex-property-data  "
     "[4:in-degree]-vertex-property-data with hot/cold hints "
     "[11:HOT]|[10:WARM]|[01:LUKEWARM]|[00:COLD] to specialize caching. The "
     "algorithm needs to support value unmask to work."},
    {"labels-file", 'F', "<FILE>", 0,
     "Read and reorder vertex labels from a text file, Specify the file name "
     "for the new graph reorder, generated from Gorder, Rabbit-order, etc."},
    {"cache-size", 'C', "<LLC=32768/32KB>", 0,
     "LLC cache size for MASK vertex reordering"},
    {"kernel-name", 'Q', "[DEFAULT:NULL]\n", 0, "\nKernel package name.\n"},
    {"xclbin-path", 'm', "[DEFAULT:NULL]\n", 0,
     "\nHardware overlay (XCLBIN) file for hw or hw_emu mode.\n"},
    {"overlay-path", 'X', "[DEFAULT:NULL]\n", 0,
     "\nHardware overlay algorithm configuration path file filename.ol.\n"},
    {"device-index", 'q', "[DEFAULT:0]\n", 0,
     "\nDevice ID of your target card use \"xbutil list\" command.\n"},
    {0}};

/* Parse a single option. */
static error_t parse_opt(int key, char *arg, struct argp_state *state) {
  /* Get the input argument from argp_parse, which we
     know is a pointer to our arguments structure. */
  struct Arguments *arguments = (struct Arguments *)state->input;

  switch (key) {
  case 'f':
    arguments->fnameb = (char *)malloc((strlen(arg) + 10) * sizeof(char));
    arguments->fnameb = strcpy(arguments->fnameb, arg);
    break;
  case 'F':
    arguments->fnamel = (char *)malloc((strlen(arg) + 10) * sizeof(char));
    arguments->fnamel = strcpy(arguments->fnamel, arg);
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
    arguments->kernel_name = (char *)malloc(strlen(arg) + 1 + 20);

    if (arguments->kernel_name == NULL) {
      // Handle memory allocation failure
      fprintf(stderr, "Memory allocation failed for kernel_name\n");
      exit(1);
    }

    // Copy the arg string into kernel_name
    strcpy(arguments->kernel_name, arg);

    // Append "_1" to the string if ker_numThreads is greater than one
    // if (arguments->ker_numThreads > 1)
    // {
    //     strcat(arguments->kernel_name, "_1");
    // }
    break;
  case 'q':
    arguments->xclbin_path = (char *)malloc((strlen(arg) + 20) * sizeof(char));
    arguments->xclbin_path = strcpy(arguments->xclbin_path, arg);
    break;
  case 'X':
    arguments->overlay_path = (char *)malloc((strlen(arg) + 20) * sizeof(char));
    arguments->overlay_path = strcpy(arguments->overlay_path, arg);
    break;

  default:
    return ARGP_ERR_UNKNOWN;
  }
  return 0;
}

static struct argp argp = {options, parse_opt, args_doc, doc};

int main(int argc, char **argv) {
  struct Arguments *arguments = argumentsNew();
  struct Timer *timer = (struct Timer *)malloc(sizeof(struct Timer));

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
  arguments->cache_size =
      32768; // 32KB for DBG reordering or GRID based structures

  arguments->lmode = 0;
  arguments->lmode_l2 = 0;
  arguments->lmode_l3 = 0;

  arguments->symmetric = 0;
  arguments->weighted = 0;
  arguments->delta = 1;
  arguments->pre_numThreads = omp_get_max_threads();
  arguments->algo_numThreads = omp_get_max_threads();
  arguments->ker_numThreads = arguments->algo_numThreads;
  arguments->fnameb = NULL;
  arguments->fnamel = NULL;
  arguments->fnameb_format = 1;
  arguments->convert_format = 1;
  initializeMersenneState(&(arguments->mt19937var), 27491095);

  // GraphBlox Xilinx Parameters
  arguments->kernel_name = NULL;
  arguments->device_index = 0;
  arguments->xclbin_path = NULL;
  arguments->overlay_path = NULL;
  arguments->ctrl_mode = 0;
  arguments->endian_read = 0;
  arguments->endian_write = 0;
  arguments->flush_cache = 1;
  arguments->bankGroupIndex = 0;

  omp_set_nested(1);
  argp_parse(&argp, argc, argv, 0, 0, arguments);

  arguments->trials = 1;
  if (arguments->dflag)
    arguments->sort = 1;

  arguments->ctrl_mode = 2;
  struct GraphAuxiliary *graphAuxiliary =
      (struct GraphAuxiliary *)my_malloc(sizeof(struct GraphAuxiliary));
  struct GraphCSR *graph =
      (struct GraphCSR *)generateGraphDataStructure(arguments);

  switch (arguments->algorithm) {
  case 0: // bfs
  {
    // struct BFSStats *stats = runBreadthFirstSearchAlgorithm(arguments,
    // graph);
    initialize_BFS_auxiliary_struct(graph, graphAuxiliary, arguments);
    multiple_iteration_BFS(graph, graphAuxiliary, arguments, timer);
    // freeBFSStats(stats);
  } break;
  case 1: // pagerank
  {
    // struct PageRankStats *stats = runPageRankAlgorithm(arguments, graph);
    initialize_PR_auxiliary_struct(graph, graphAuxiliary, arguments);
    multiple_iteration_PR(graph, graphAuxiliary, arguments, timer);
    // freePageRankStats(stats);
  } break;
  case 5: // SPMV
  {
    struct SPMVStats *stats = runSPMVAlgorithm(arguments, graph);
    freeSPMVStats(stats);
  } break;
  case 6: // Connected Components (CC)
  {
    struct CCStats *stats = runConnectedComponentsAlgorithm(arguments, graph);
    initialize_CC_auxiliary_struct(graph, graphAuxiliary, arguments);
    multiple_iteration_CC(graph, graphAuxiliary, arguments, timer);
    freeCCStats(stats);
  } break;
  case 8: // Triangle Counting
  {
    struct TCStats *stats = runTriangleCountAlgorithm(arguments, graph);
    initialize_TC_auxiliary_struct(graph, graphAuxiliary, arguments);
    multiple_iteration_TC(graph, graphAuxiliary, arguments, timer);
    freeTCStats(stats);
  } break;
  default: // BFS
  {
    struct BFSStats *stats = runBreadthFirstSearchAlgorithm(arguments, graph);
    initialize_BFS_auxiliary_struct(graph, graphAuxiliary, arguments);
    multiple_iteration_BFS(graph, graphAuxiliary, arguments, timer);
    freeBFSStats(stats);
  } break;
  }

  // uint32_t i;
  // printf(" -----------------------------------------------------\n");
  // for(i = graph->num_vertices; i < graph->num_vertices * 2 ; i++)
  // {
  //     printf("%u \n", static_cast<uint32_t
  //     *>(graphAuxiliary->auxiliary_1)[i]);
  // }
  // printf(" -----------------------------------------------------\n");
  // for(i = 0; i < graph->num_vertices ; i++)
  // {
  //     printf("%u \n", static_cast<uint32_t
  //     *>(graphAuxiliary->auxiliary_2)[i]);
  // }
  // printf(" -----------------------------------------------------\n");
  // for(i = graph->num_vertices; i < graph->num_vertices * 2 ; i++)
  // {
  //     printf("%u \n", static_cast<uint32_t
  //     *>(graphAuxiliary->auxiliary_2)[i]);
  // }
  // printf(" -----------------------------------------------------\n");
  // closeGRAPHBLOXUserManaged();

  // releaseGRAPHBLOX();
  free(timer);
  free_auxiliary_struct(graphAuxiliary);
  freeGraphDataStructure((void *)graph, arguments->datastructure);
  argumentsFree(arguments);
  exit(0);
}

void multiple_iteration_PR(struct GraphCSR *graph,
                           struct GraphAuxiliary *graphAuxiliary,
                           struct Arguments *arguments, struct Timer *timer) {
  GRAPHBLOXxrtBufferHandlePerKernel *graphBloxGraphCSRxrtBufferHandlePerKernel;
  Start(timer);
  printf("-----------------------------------------------------\n");
  printf(" Start PR Iterations\n");
  printf("-----------------------------------------------------\n");
  graphBloxGraphCSRxrtBufferHandlePerKernel =
      new GRAPHBLOXxrtBufferHandlePerKernel(arguments, graph, graphAuxiliary);
  graphBloxGraphCSRxrtBufferHandlePerKernel->setupGRAPHBLOX();
  graphBloxGraphCSRxrtBufferHandlePerKernel->printGRAPHBLOXxrtBufferHandlePerKernel();
  printf("-----------------------------------------------------\n");
  printf(" setupGRAPHBLOXUserManaged\n");
  printf("-----------------------------------------------------\n");

  graphBloxGraphCSRxrtBufferHandlePerKernel->startGRAPHBLOX();
  Stop(timer);
  printf(" -----------------------------------------------------\n");
  printf("| %-9s | \n", "Setup Time (S)");
  printf(" -----------------------------------------------------\n");
  printf("| %-9f | \n", Seconds(timer));
  printf(" -----------------------------------------------------\n");

  Start(timer);
  graphBloxGraphCSRxrtBufferHandlePerKernel->waitGRAPHBLOX();
  Stop(timer);
  printf(" -----------------------------------------------------\n");
  printf("| %-9s | \n", "Algorithm Time (S)");
  printf(" -----------------------------------------------------\n");
  printf("| %-9f | \n", Seconds(timer));
  printf(" -----------------------------------------------------\n");

  Start(timer);
  graphBloxGraphCSRxrtBufferHandlePerKernel->readGRAPHBLOXDeviceToHostBuffersPerKernel();
  Stop(timer);
  printf(" -----------------------------------------------------\n");
  printf("| %-9s | \n", "Result Time (S)");
  printf(" -----------------------------------------------------\n");
  printf("| %-9f | \n", Seconds(timer));
  printf(" -----------------------------------------------------\n");
  for (uint32_t i = 0; i < graph->num_vertices; i++) {
    DEBUG_PRINT("%u \n",
                static_cast<uint32_t *>(
                    graphAuxiliary->auxiliary_2)[i + graph->num_vertices]);
  }
  DEBUG_PRINT(" -----------------------------------------------------\n");
}

void multiple_iteration_TC(struct GraphCSR *graph,
                           struct GraphAuxiliary *graphAuxiliary,
                           struct Arguments *arguments, struct Timer *timer) {
  uint32_t count = 0;
  GRAPHBLOXxrtBufferHandlePerKernel *graphBloxGraphCSRxrtBufferHandlePerKernel;
  Start(timer);
  printf("-----------------------------------------------------\n");
  printf(" Start TC Iterations\n");
  printf("-----------------------------------------------------\n");
  graphBloxGraphCSRxrtBufferHandlePerKernel =
      new GRAPHBLOXxrtBufferHandlePerKernel(arguments, graph, graphAuxiliary);
  graphBloxGraphCSRxrtBufferHandlePerKernel->setupGRAPHBLOX();
  graphBloxGraphCSRxrtBufferHandlePerKernel->printGRAPHBLOXxrtBufferHandlePerKernel();
  printf(" setupGRAPHBLOXUserManaged\n");
  printf("-----------------------------------------------------\n");
  graphBloxGraphCSRxrtBufferHandlePerKernel->startGRAPHBLOX();
  Stop(timer);
  printf(" -----------------------------------------------------\n");
  printf("| %-9s | \n", "Setup Time (S)");
  printf(" -----------------------------------------------------\n");
  printf("| %-9f | \n", Seconds(timer));
  printf(" -----------------------------------------------------\n");

  Start(timer);
  graphBloxGraphCSRxrtBufferHandlePerKernel->waitGRAPHBLOX();
  Stop(timer);
  printf(" -----------------------------------------------------\n");
  printf("| %-9s | \n", "Algorithm Time (S)");
  printf(" -----------------------------------------------------\n");
  printf("| %-9f | \n", Seconds(timer));
  printf(" -----------------------------------------------------\n");

  Start(timer);
  graphBloxGraphCSRxrtBufferHandlePerKernel->readGRAPHBLOXDeviceToHostBuffersPerKernel();
  Stop(timer);
  printf(" -----------------------------------------------------\n");
  printf("| %-9s | \n", "Result Time (S)");
  printf(" -----------------------------------------------------\n");
  printf("| %-9f | \n", Seconds(timer));
  printf(" -----------------------------------------------------\n");
  for (uint32_t i = 0; i < graph->num_vertices; i++) {
    DEBUG_PRINT("%u \n",
                static_cast<uint32_t *>(
                    graphAuxiliary->auxiliary_2)[i + graph->num_vertices]);
  }
  DEBUG_PRINT(" -----------------------------------------------------\n");

  count = static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[1];
  printf("| count %-9u | \n", count);
  printf(" -----------------------------------------------------\n");
}

void multiple_iteration_BFS(struct GraphCSR *graph,
                            struct GraphAuxiliary *graphAuxiliary,
                            struct Arguments *arguments, struct Timer *timer) {
  uint32_t frontier = 1;
  GRAPHBLOXxrtBufferHandlePerKernel *graphBloxGraphCSRxrtBufferHandlePerKernel;
  printf("-----------------------------------------------------\n");
  printf(" Start BFS Iterations\n");
  printf("-----------------------------------------------------\n");
  do {
    frontier = 0;
    Start(timer);
    graphBloxGraphCSRxrtBufferHandlePerKernel =
        new GRAPHBLOXxrtBufferHandlePerKernel(arguments, graph, graphAuxiliary);
    graphBloxGraphCSRxrtBufferHandlePerKernel->setupGRAPHBLOX();
    graphBloxGraphCSRxrtBufferHandlePerKernel->printGRAPHBLOXxrtBufferHandlePerKernel();
    printf(" setupGRAPHBLOXUserManaged\n");
    printf("-----------------------------------------------------\n");

    graphBloxGraphCSRxrtBufferHandlePerKernel->startGRAPHBLOX();
    Stop(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-9s | \n", "Setup Time (S)");
    printf(" -----------------------------------------------------\n");
    printf("| %-9f | \n", Seconds(timer));
    printf(" -----------------------------------------------------\n");

    Start(timer);
    graphBloxGraphCSRxrtBufferHandlePerKernel->waitGRAPHBLOX();
    Stop(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-9s | \n", "Algorithm Time (S)");
    printf(" -----------------------------------------------------\n");
    printf("| %-9f | \n", Seconds(timer));
    printf(" -----------------------------------------------------\n");

    Start(timer);
    graphBloxGraphCSRxrtBufferHandlePerKernel
        ->readGRAPHBLOXDeviceToHostBuffersPerKernel();
    Stop(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-9s | \n", "Result Time (S)");
    printf(" -----------------------------------------------------\n");
    printf("| %-9f | \n", Seconds(timer));
    printf(" -----------------------------------------------------\n");
    for (uint32_t i = 0; i < graph->num_vertices; i++) {
      DEBUG_PRINT("%u \n",
                  static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i]);
      frontier += static_cast<uint32_t *>(
          graphAuxiliary->auxiliary_2)[graph->num_vertices + i];
      static_cast<uint32_t *>(
          graphAuxiliary->auxiliary_1)[graph->num_vertices + i] =
          static_cast<uint32_t *>(
              graphAuxiliary->auxiliary_2)[graph->num_vertices + i];
      static_cast<uint32_t *>(
          graphAuxiliary->auxiliary_2)[graph->num_vertices + i] = 0;
    }
    printf("| %-9u | \n", frontier);
    printf(" -----------------------------------------------------\n");
  } while (frontier);
}

void multiple_iteration_CC(struct GraphCSR *graph,
                           struct GraphAuxiliary *graphAuxiliary,
                           struct Arguments *arguments, struct Timer *timer) {
  uint32_t change = 0;
  GRAPHBLOXxrtBufferHandlePerKernel *graphBloxGraphCSRxrtBufferHandlePerKernel;
  printf("-----------------------------------------------------\n");
  printf(" Start CC Iterations\n");
  printf("-----------------------------------------------------\n");
  do {
    change = 0;
    Start(timer);
    graphBloxGraphCSRxrtBufferHandlePerKernel =
        new GRAPHBLOXxrtBufferHandlePerKernel(arguments, graph, graphAuxiliary);
    graphBloxGraphCSRxrtBufferHandlePerKernel->setupGRAPHBLOX();
    graphBloxGraphCSRxrtBufferHandlePerKernel->printGRAPHBLOXxrtBufferHandlePerKernel();
    printf(" setupGRAPHBLOXUserManaged\n");
    printf("-----------------------------------------------------\n");
    graphBloxGraphCSRxrtBufferHandlePerKernel->startGRAPHBLOX();
    Stop(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-9s | \n", "Setup Time (S)");
    printf(" -----------------------------------------------------\n");
    printf("| %-9f | \n", Seconds(timer));
    printf(" -----------------------------------------------------\n");

    Start(timer);
    graphBloxGraphCSRxrtBufferHandlePerKernel->waitGRAPHBLOX();
    Stop(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-9s | \n", "Algorithm Time (S)");
    printf(" -----------------------------------------------------\n");
    printf("| %-9f | \n", Seconds(timer));
    printf(" -----------------------------------------------------\n");

    Start(timer);
    graphBloxGraphCSRxrtBufferHandlePerKernel
        ->readGRAPHBLOXDeviceToHostBuffersPerKernel();
    Stop(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-9s | \n", "Result Time (S)");
    printf(" -----------------------------------------------------\n");
    printf("| %-9f | \n", Seconds(timer));
    printf(" -----------------------------------------------------\n");
    for (uint32_t i = 0; i < graph->num_vertices; i++) {
      DEBUG_PRINT("%u \n",
                  static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i]);
    }
    change = static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[1];
    printf("| change %-9u | \n", change);
    printf(" -----------------------------------------------------\n");
  } while (change);
}

void initialize_PR_auxiliary_struct(struct GraphCSR *graph,
                                    struct GraphAuxiliary *graphAuxiliary,
                                    struct Arguments *arguments) {
  // Check for NULL pointer
  if (graph == NULL) {
    return;
  }

  graphAuxiliary->num_auxiliary_1 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_1 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_1 * sizeof(uint32_t));

  graphAuxiliary->num_auxiliary_2 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_2 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_2 * sizeof(uint32_t));

  printf("-----------------------------------------------------\n");
  printf(" Initialize PR Auxiliary Struct\n");
  printf("-----------------------------------------------------\n");
// Backdoor fill the memory with the content.
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graphAuxiliary->num_auxiliary_1 / 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 0;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graphAuxiliary->num_auxiliary_1 / 2;
       i < graphAuxiliary->num_auxiliary_1; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 1;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graphAuxiliary->num_auxiliary_2 / 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graphAuxiliary->num_auxiliary_2 / 2;
       i < graphAuxiliary->num_auxiliary_2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0;
  }
}

void initialize_TC_auxiliary_struct(struct GraphCSR *graph,
                                    struct GraphAuxiliary *graphAuxiliary,
                                    struct Arguments *arguments) {
  // Check for NULL pointer
  if (graph == NULL) {
    return;
  }
  printf("-----------------------------------------------------\n");
  printf(" Initialize TC Auxiliary Struct\n");
  printf("-----------------------------------------------------\n");
  graphAuxiliary->num_auxiliary_1 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_1 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_1 * sizeof(uint32_t));

  graphAuxiliary->num_auxiliary_2 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_2 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_2 * sizeof(uint32_t));

// Backdoor fill the memory with the content.
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graphAuxiliary->num_auxiliary_1 / 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 0;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graphAuxiliary->num_auxiliary_1 / 2;
       i < graphAuxiliary->num_auxiliary_1; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 0;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graphAuxiliary->num_auxiliary_2 / 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graphAuxiliary->num_auxiliary_2 / 2;
       i < graphAuxiliary->num_auxiliary_2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0;
  }
}

void initialize_CC_auxiliary_struct(struct GraphCSR *graph,
                                    struct GraphAuxiliary *graphAuxiliary,
                                    struct Arguments *arguments) {
  // Check for NULL pointer
  if (graph == NULL) {
    return;
  }
  printf("-----------------------------------------------------\n");
  printf(" Initialize CC Auxiliary Struct\n");
  printf("-----------------------------------------------------\n");
  graphAuxiliary->num_auxiliary_1 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_1 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_1 * sizeof(uint32_t));

  graphAuxiliary->num_auxiliary_2 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_2 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_2 * sizeof(uint32_t));

// Backdoor fill the memory with the content.
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graphAuxiliary->num_auxiliary_1 / 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = i;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graphAuxiliary->num_auxiliary_1 / 2;
       i < graphAuxiliary->num_auxiliary_1; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 0;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graphAuxiliary->num_auxiliary_2 / 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graphAuxiliary->num_auxiliary_2 / 2;
       i < graphAuxiliary->num_auxiliary_2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0;
  }
}

void initialize_BFS_auxiliary_struct(struct GraphCSR *graph,
                                     struct GraphAuxiliary *graphAuxiliary,
                                     struct Arguments *arguments) {
  // Check for NULL pointer
  if (graph == NULL) {
    return;
  }
  printf("-----------------------------------------------------\n");
  printf(" Initialize BFS Auxiliary Struct\n");
  printf("-----------------------------------------------------\n");
  graphAuxiliary->num_auxiliary_1 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_1 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_1 * sizeof(uint32_t));

  graphAuxiliary->num_auxiliary_2 = graph->num_vertices * 2;
  graphAuxiliary->auxiliary_2 =
      (uint32_t *)my_malloc(graphAuxiliary->num_auxiliary_2 * sizeof(uint32_t));

#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graph->num_vertices; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 0xFFFFFFFF;

    if (i == arguments->source)
      static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] =
          arguments->source;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graph->num_vertices; i < graph->num_vertices * 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 0;

    if (i == (graph->num_vertices + arguments->source))
      static_cast<uint32_t *>(graphAuxiliary->auxiliary_1)[i] = 1;
  }

// optimization for BFS implentaion instead of -1 we use -out degree to for
// hybrid approach counter
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = 0; i < graph->num_vertices; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0xFFFFFFFF;
  }
#pragma omp parallel for default(none) shared(graphAuxiliary, graph, arguments)
  for (uint32_t i = graph->num_vertices; i < graph->num_vertices * 2; i++) {
    static_cast<uint32_t *>(graphAuxiliary->auxiliary_2)[i] = 0;
  }
}

void free_auxiliary_struct(struct GraphAuxiliary *graphAuxiliary) {
  if (graphAuxiliary) {
    if (graphAuxiliary->auxiliary_1) {
      free(graphAuxiliary->auxiliary_1); // Use free for memory allocated with
                                         // aligned_alloc
    }
    if (graphAuxiliary->auxiliary_2) {
      free(graphAuxiliary->auxiliary_2); // Use free for memory allocated with
                                         // aligned_alloc
    }
    free(graphAuxiliary);
  }
}

#ifdef __cplusplus
}
#endif
