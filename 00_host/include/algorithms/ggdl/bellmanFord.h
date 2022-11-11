#ifndef BELLMANFORD_H
#define BELLMANFORD_H


#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "edgeList.h"
#include "graphCSR.h"


// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************

struct BellmanFordStats
{
    uint32_t *distances;
    uint32_t *parents;
    uint32_t  processed_nodes;
    uint32_t num_vertices;
    double time_total;
};

struct BellmanFordStats *newBellmanFordStatsGraphCSR(struct GraphCSR *graph);

void freeBellmanFordStats(struct BellmanFordStats *stats);


// ********************************************************************************************
// ***************					Auxiliary functions  	  					 **************
// ********************************************************************************************
uint32_t bellmanFordAtomicMin(uint32_t *dist, uint32_t newValue);
uint32_t bellmanFordCompareDistanceArrays(struct BellmanFordStats *stats1, struct BellmanFordStats *stats2);
int bellmanFordAtomicRelax(uint32_t src, uint32_t dest, float weight, struct BellmanFordStats *stats, struct Bitmap *bitmapNext);
int bellmanFordRelax(uint32_t src, uint32_t dest, float weight, struct BellmanFordStats *stats, struct Bitmap *bitmapNext);
void durstenfeldShuffle(mt19937state *mt19937var, uint32_t *vertices, uint32_t size);


// ********************************************************************************************
// ***************					CSR DataStructure							 **************
// ********************************************************************************************

struct BellmanFordStats *bellmanFordGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct BellmanFordStats *bellmanFordDataDrivenPullGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct BellmanFordStats *bellmanFordDataDrivenPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct BellmanFordStats *bellmanFordRandomizedDataDrivenPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
void bellmanFordSpiltGraphCSR(struct GraphCSR *graph, struct GraphCSR **graphPlus, struct GraphCSR **graphMinus);


#ifdef __cplusplus
}
#endif

#endif