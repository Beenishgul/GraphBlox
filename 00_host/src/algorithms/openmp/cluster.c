/*
* @Author: Abdullah
* @Date:   2023-02-07 17:28:50
* @Last Modified by:   Abdullah
* @Last Modified time: 2023-02-09 17:51:23
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <omp.h>

#include "timer.h"
#include "myMalloc.h"
#include "boolean.h"
#include "arrayQueue.h"
#include "bitmap.h"
#include "graphConfig.h"
#include "reorder.h"

#include "graphCSR.h"


#include "cluster.h"


// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************

struct ClusterStats *newClusterStatsGraphCSR(struct GraphCSR *graph)
{

    uint32_t vertex_id;

    struct ClusterStats *stats = (struct ClusterStats *) my_malloc(sizeof(struct ClusterStats));

    stats->parents = (int *) my_malloc(graph->num_vertices * sizeof(int));
    stats->processed_nodes = 0;
    stats->iteration = 0;
    stats->num_vertices = graph->num_vertices;
    stats->time_total = 0.0f;

    // optimization for BFS implentaion instead of -1 we use -out degree to for hybrid approach counter
    #pragma omp parallel for default(none) private(vertex_id) shared(stats,graph)
    for(vertex_id = 0; vertex_id < graph->num_vertices ; vertex_id++)
    {
        if(graph->vertices->out_degree[vertex_id])
        {
            stats->parents[vertex_id] = graph->vertices->out_degree[vertex_id] * (-1);
        }
        else
        {
            stats->parents[vertex_id] = -1;
        }
    }

    return stats;

}

struct ClusterPartition *newClusterPartitionGraphCSR(struct GraphCSR *graph)
{

    uint32_t i;

    struct ClusterPartition *partition = (struct ClusterPartition *) my_malloc(sizeof(struct ClusterPartition));

    partition->size = graph->num_vertices;

    partition->node2Community = (uint32_t *) my_malloc(partition->size * sizeof(uint32_t));
    partition->in = (long double *) my_malloc(partition->size * sizeof(long double));
    partition->tot = (long double *) my_malloc(partition->size * sizeof(long double));

    partition->neighCommWeights = (long double *) my_malloc(partition->size * sizeof(long double));
    partition->neighCommPos = (uint32_t *) my_malloc(partition->size * sizeof(uint32_t));
    partition->neighCommNb = 0;

    for (i = 0; i < partition->size; i++)
    {
        partition->node2Community[i] = i;
        // partition->in[i]  = selfloopWeighted(g, i);
        // partition->tot[i] = degreeWeighted(g, i);
        partition->neighCommWeights[i] = -1;
        partition->neighCommPos[i] = 0;
    }

    return partition;

}

void freeClusterStats(struct ClusterStats *stats)
{
    if(stats)
    {
        if(stats->parents)
            free(stats->parents);
        free(stats);
    }
}

void freeClusterPartition(struct ClusterPartition *partition)
{
    if(partition)
    {
        if(partition->in)
            free(partition->in);
        if(partition->tot)
            free(partition->tot);
        if(partition->neighCommWeights)
            free(partition->neighCommWeights);
        if(partition->neighCommPos)
            free(partition->neighCommPos);
        if(partition->node2Community)
            free(partition->node2Community);
        free(partition);
    }
}


// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************
struct ClusterStats *clusterGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct ClusterStats *stats = NULL;

    switch (arguments->pushpull)
    {
    case 0: // louvain
        stats = louvainGraphCSR(arguments, graph);
        break;
    case 1: // leiden
        stats = leidenGraphCSR(arguments, graph);
        break;
    case 2: // Incremental Aggregation
        stats = incrementalAggregationGraphCSR(arguments, graph);
        break;
    default:// louvain
        stats = louvainGraphCSR(arguments, graph);
        break;
    }


    return stats;

}


struct ClusterStats *louvainGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct ClusterStats *stats = newClusterStatsGraphCSR(graph);

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Starting Louvain");
    printf(" -----------------------------------------------------\n");

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    free(timer);

    return stats;
}


struct ClusterStats *leidenGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct ClusterStats *stats = newClusterStatsGraphCSR(graph);

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Starting Leiden");
    printf(" -----------------------------------------------------\n");

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    free(timer);

    return stats;
}

struct ClusterStats *incrementalAggregationGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct ClusterStats *stats = newClusterStatsGraphCSR(graph);

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Starting Incremental Aggregation");
    printf(" ------------------s-----------------------------------\n");

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    free(timer);

    return stats;
}