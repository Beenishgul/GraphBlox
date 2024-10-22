#ifndef BETWEENNESSCENTRALITY_H
#define BETWEENNESSCENTRALITY_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "edgeList.h"
#include "bitmap.h"
#include "graphCSR.h"

// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************
struct Predecessor
{
    uint32_t *nodes;
    uint32_t  degree;
};

struct BetweennessCentralityStats
{
    struct Predecessor *stack;
    uint32_t *distances;
    uint32_t *realRanks;
    int *parents;
    int *sigma;
    float    *dependency;
    float    *betweennessCentrality;
    struct Predecessor *predecessors;
    uint32_t  iteration;
    uint32_t  processed_nodes;
    uint32_t  num_vertices;
    double time_total;

};

struct BetweennessCentralityStats *newBetweennessCentralityStatsGraphCSR(struct GraphCSR *graph);


void freeBetweennessCentralityStats(struct BetweennessCentralityStats *stats);
void clearBetweennessCentralityStats(struct BetweennessCentralityStats *stats);
void printRanksBetweennessCentralityStats(struct BetweennessCentralityStats *stats);
// ********************************************************************************************
// ***************                  Auxiliary functions                          **************
// ********************************************************************************************
uint32_t generateRandomRootBetweennessCentrality(mt19937state *mt19937var, struct GraphCSR *graph);
void copyBitmapToStack(struct Bitmap *q_bitmap, struct Predecessor *stack, uint32_t num_vertices);
struct Predecessor *creatNewPredecessorList(uint32_t *degrees, uint32_t num_vertices);
struct BetweennessCentralityStats *betweennessCentralityBFSPullGraphCSR(uint32_t source, struct GraphCSR *graph, struct BetweennessCentralityStats *stats);
uint32_t betweennessCentralityBottomUpStepGraphCSR(struct GraphCSR *graph, struct Bitmap *bitmapCurr, struct Bitmap *bitmapNext, struct BetweennessCentralityStats *stats);

// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct BetweennessCentralityStats *betweennessCentralityGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct BetweennessCentralityStats *betweennessCentralityBrandesGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

#ifdef __cplusplus
}
#endif

#endif