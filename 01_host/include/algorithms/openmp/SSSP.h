#ifndef SSSP_H
#define SSSP_H


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

struct SSSPStats
{
    uint32_t *distances;
    uint32_t *parents;
    uint32_t *buckets_map;
    uint32_t  bucket_counter;
    uint32_t  bucket_current;
    uint32_t  buckets_total;
    uint32_t  processed_nodes;
    uint32_t  delta;
    uint32_t num_vertices;
    double time_total;
};

struct SSSPStats *newSSSPStatsGeneral(uint32_t num_vertices, uint32_t delta);
struct SSSPStats *newSSSPStatsGraphCSR(struct GraphCSR *graph, uint32_t delta);

void freeSSSPStats(struct SSSPStats *stats);

// ********************************************************************************************
// ***************                  Auxiliary functions                          **************
// ********************************************************************************************
uint32_t SSSPAtomicMin(uint32_t *dist, uint32_t newValue);
uint32_t SSSPCompareDistanceArrays(struct SSSPStats *stats1, struct SSSPStats *stats2);
int SSSPAtomicRelax(uint32_t src, uint32_t dest, float weight, struct SSSPStats *stats);
int SSSPRelax(uint32_t src, uint32_t dest, float weight, struct SSSPStats *stats);

// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct SSSPStats *SSSPGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct SSSPStats *SSSPDataDrivenPullGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct SSSPStats *SSSPDataDrivenPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct SSSPStats *SSSPDataDrivenSplitPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
void SSSPSpiltGraphCSR(struct GraphCSR *graph, struct GraphCSR **graphPlus, struct GraphCSR **graphMinus, uint32_t delta);

#ifdef __cplusplus
}
#endif

#endif