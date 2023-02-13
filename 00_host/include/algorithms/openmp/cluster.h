#ifndef LOUVAIN_H
#define LOUVAIN_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "arrayQueue.h"
#include "bitmap.h"
#include "graphCSR.h"


#define K 5
#define MIN_IMPROVEMENT 0.005

// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************

struct ClusterStats
{
    uint32_t *partitions;
    uint32_t  processed_nodes;
    uint32_t  num_vertices;
    uint32_t iteration;
    long double total_weight;//total weight of the links
    double time_total;

};

struct ClusterPartition
{
    // size of the partition
    uint32_t size;

    // community to which each node belongs
    uint32_t *node2Community;

    // in and tot values of each node to compute modularity
    long double *in;
    long double *tot;

    // utility arrays to find communities adjacent to a node
    // communities are stored using three variables
    // - neighCommWeights: stores weights to communities
    // - neighCommPos: stores list of neighbor communities
    // - neighCommNb: stores the number of neighbor communities
    long double *neighCommWeights;
    uint32_t *neighCommPos;
    uint32_t neighCommNb;
};


struct ClusterStats *newClusterStatsGraphCSR(struct GraphCSR *graph);
struct ClusterPartition *newClusterPartitionGraphCSR(struct GraphCSR *graph);

void freeClusterStats(struct ClusterStats *stats);
void freeClusterPartition(struct ClusterPartition *partition);

// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct ClusterStats *clusterGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

long double modularityGraphCSR(struct ClusterStats *stats, struct ClusterPartition *partition, struct GraphCSR *graph);
long double louvainPassGraphCSR(struct ClusterStats *stats, struct ClusterPartition *partition, struct GraphCSR *graph);
struct ClusterStats *louvainGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct ClusterStats *leidenGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct ClusterStats *incrementalAggregationGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

#ifdef __cplusplus
}
#endif

#endif