#ifndef DFS_H
#define DFS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "arrayStack.h"
#include "bitmap.h"
#include "graphCSR.h"

// ********************************************************************************************
// ***************					Stats DataStructure							 **************
// ********************************************************************************************

struct DFSStats
{
    uint32_t *distances;
    int *parents;
    uint32_t  processed_nodes;
    uint32_t  num_vertices;
    double time_total;
};

struct DFSStats *newDFSStatsGraphCSR(struct GraphCSR *graph);

void freeDFSStats(struct DFSStats *stats);


// ********************************************************************************************
// ***************					CSR DataStructure							 **************
// ********************************************************************************************

struct DFSStats  *depthFirstSearchGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct DFSStats  *depthFirstSearchGraphCSRBase(struct Arguments *arguments, struct GraphCSR *graph);
struct DFSStats  *pDepthFirstSearchGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
void parallelDepthFirstSearchGraphCSRTask(struct Arguments *arguments, struct GraphCSR *graph, struct DFSStats *stats);

#ifdef __cplusplus
}
#endif

#endif