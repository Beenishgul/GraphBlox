#ifndef BFS_H
#define BFS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "arrayQueue.h"
#include "bitmap.h"
#include "graphCSR.h"


// ********************************************************************************************
// ***************					Stats DataStructure							 **************
// ********************************************************************************************

struct BFSStats
{
    uint32_t *distances;
    int *parents;
    uint32_t *distances_DualOrder;
    int *parents_DualOrder;
    uint32_t  processed_nodes;
    uint32_t  num_vertices;
    uint32_t iteration;
    double time_total;
};

struct BFSStats *newBFSStatsGraphCSR(struct GraphCSR *graph);

void freeBFSStats(struct BFSStats *stats);

// ********************************************************************************************
// ***************					CSR DataStructure							 **************
// ********************************************************************************************

struct BFSStats *breadthFirstSearchGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct BFSStats *breadthFirstSearchPullGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct BFSStats *breadthFirstSearchPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct BFSStats *breadthFirstSearchDirectionOptimizedGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

uint32_t topDownStepGraphCSR(struct GraphCSR *graph, struct ArrayQueue *sharedFrontierQueue,  struct ArrayQueue **localFrontierQueues, struct BFSStats *stats);
uint32_t bottomUpStepGraphCSR(struct GraphCSR *graph, struct Bitmap *bitmapCurr, struct Bitmap *bitmapNext, struct BFSStats *stats);

#ifdef __cplusplus
}
#endif

#endif