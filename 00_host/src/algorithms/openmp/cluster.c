/*
* @Author: Abdullah
* @Date:   2023-02-07 17:28:50
* @Last Modified by:   Abdullah
* @Last Modified time: 2023-02-14 18:33:28
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
    uint32_t edge_id;
    long double total_weight = 0.0;

    struct ClusterStats *stats = (struct ClusterStats *) my_malloc(sizeof(struct ClusterStats));

    stats->partitions = (uint32_t *) my_malloc(graph->num_vertices * sizeof(uint32_t));
    stats->processed_nodes = 0;
    stats->iteration = 0;
    stats->num_vertices = graph->num_vertices;
    stats->time_total = 0.0f;


#if WEIGHTED
    float *edges_array_weight = NULL;
#endif

#if DIRECTED
#if WEIGHTED
    edges_array_weight = graph->inverse_sorted_edges_array->edges_array_weight;
#endif
#else
#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
#endif
#endif


#if WEIGHTED
    #pragma omp parallel for default(none) private(edge_id) shared(graph,edges_array_weight) reduction(+ : total_weight)
#else
    #pragma omp parallel for default(none) private(edge_id) shared(graph) reduction(+ : total_weight)
#endif
    for(edge_id = 0 ; edge_id < graph->num_edges ; edge_id++)
    {
#if WEIGHTED
        total_weight +=  edges_array_weight[edge_id];
#else
        total_weight += 1.0 ;
#endif
    }

    stats->total_weight = total_weight;

    // optimization for BFS implentaion instead of -1 we use -out degree to for hybrid approach counter
    #pragma omp parallel for default(none) private(vertex_id) shared(stats,graph)
    for(vertex_id = 0; vertex_id < graph->num_vertices ; vertex_id++)
    {
        stats->partitions[vertex_id] = vertex_id;
    }

    return stats;

}



inline long double degreeWeightedGraphCSR(struct GraphCSR *graph, uint32_t node)
{
    struct Vertex *vertices = NULL;
    uint32_t degree;

    long double res = 0.0L;

#if DIRECTED
    vertices = graph->inverse_vertices;
#else
    vertices = graph->vertices;
#endif

    degree = vertices->out_degree[node];


#if WEIGHTED
    uint32_t edge_idx;
    uint32_t j;
    edge_idx = vertices->edges_idx[node];
    for(j = edge_idx ; j < (edge_idx + degree) ; j++)
    {
        res += edges_array_weight[j];
    }
#else
    res = 1.*(degree);
#endif

    return res;
}


inline long double selfloopWeightedGraphCSR(struct GraphCSR *graph, uint32_t node)
{
    uint32_t u;
    uint32_t j;
    uint32_t degree;
    uint32_t edge_idx;

    long double weights;
    struct Vertex *vertices = NULL;
    uint32_t *sorted_edges_array = NULL;

#if WEIGHTED
    float *edges_array_weight = NULL;
#endif

    weights = 0.0;

#if DIRECTED
    vertices = graph->inverse_vertices;
    sorted_edges_array = graph->inverse_sorted_edges_array->edges_array_dest;
#if WEIGHTED
    edges_array_weight = graph->inverse_sorted_edges_array->edges_array_weight;
#endif
#else
    vertices = graph->vertices;
    sorted_edges_array = graph->sorted_edges_array->edges_array_dest;
#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
#endif
#endif

    degree = vertices->out_degree[node];
    edge_idx = vertices->edges_idx[node];

    for(j = edge_idx ; j < (edge_idx + degree) ; j++)
    {
        u = EXTRACT_VALUE(sorted_edges_array[j]);
        if(u == node)
        {
#if WEIGHTED
            weights +=  edges_array_weight[j];
#else
            weights += 1.0 ;
#endif
        }
    }

    return weights;
}

struct ClusterPartition *newClusterPartitionGraphCSR(struct GraphCSR *graph)
{

    uint32_t v;

    struct ClusterPartition *partition = (struct ClusterPartition *) my_malloc(sizeof(struct ClusterPartition));

    partition->size = graph->num_vertices;

    partition->node2Community = (uint32_t *) my_malloc(partition->size * sizeof(uint32_t));
    partition->in = (long double *) my_malloc(partition->size * sizeof(long double));
    partition->tot = (long double *) my_malloc(partition->size * sizeof(long double));

    partition->neighCommWeights = (long double *) my_malloc(partition->size * sizeof(long double));
    partition->neighCommPos = (uint32_t *) my_malloc(partition->size * sizeof(uint32_t));
    partition->neighCommNb = 0;

    for (v = 0; v < partition->size; v++)
    {
        partition->node2Community[v] = v;
        partition->in[v]  = selfloopWeightedGraphCSR(graph, v);
        partition->tot[v] = degreeWeightedGraphCSR(graph, v);
        partition->neighCommWeights[v] = -1;
        partition->neighCommPos[v] = 0;
    }

    return partition;

}

void neighboringCommunitiesInitialize(struct ClusterPartition *partition)
{
    uint32_t i;
    for (i = 0; i < partition->neighCommNb; i++)
    {
        partition->neighCommWeights[partition->neighCommPos[i]] = -1;
    }
    partition->neighCommNb = 0;
}

/*
Computes the set of neighbor communities of a given node (excluding self-loops)
*/
void neighboringCommunities(struct ClusterPartition *partition, struct GraphCSR *graph, uint32_t node)
{
    unsigned long long i;
    unsigned long neigh, neighComm;
    long double neighW;
    partition->neighCommPos[0] = partition->node2Community[node];
    partition->neighCommWeights[partition->neighCommPos[0]] = 0.;
    partition->neighCommNb = 1;


    uint32_t degree;
    uint32_t edge_idx;

    long double weights;
    struct Vertex *vertices = NULL;
    uint32_t *sorted_edges_array = NULL;

#if WEIGHTED
    float *edges_array_weight = NULL;
#endif

    weights = 0.0;

#if DIRECTED
    vertices = graph->inverse_vertices;
    sorted_edges_array = graph->inverse_sorted_edges_array->edges_array_dest;
#if WEIGHTED
    edges_array_weight = graph->inverse_sorted_edges_array->edges_array_weight;
#endif
#else
    vertices = graph->vertices;
    sorted_edges_array = graph->sorted_edges_array->edges_array_dest;
#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
#endif
#endif

    // for all neighbors of node, add weight to the corresponding community
    for (i = g->cd[node]; i < g->cd[node + 1]; i++)
    {
        neigh  = g->adj[i];
        neighComm = partition->node2Community[neigh];
        neighW = (g->weights == NULL) ? 1.0 : g->weights[i];

        // if not a self-loop
        if (neigh != node)
        {
            // if community is new (weight == -1)
            if (partition->neighCommWeights[neighComm] == -1)
            {
                partition->neighCommPos[partition->neighCommNb] = neighComm;
                partition->neighCommWeights[neighComm] = 0.;
                partition->neighCommNb++;
            }
            partition->neighCommWeights[neighComm] += neighW;
        }
    }
}

void freeClusterStats(struct ClusterStats *stats)
{
    if(stats)
    {
        if(stats->partitions)
            free(stats->partitions);
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


// ********************************************************************************************
// ***************                  CSR Louvain                                  **************
// ********************************************************************************************

long double modularityGraphCSR(struct ClusterStats *stats, struct ClusterPartition *partition, struct GraphCSR *graph)
{
    long double q  = 0.0L;
    long double m2 = stats->total_weight;
    uint32_t i;

    for (i = 0; i < partition->size; i++)
    {
        if (partition->tot[i] > 0.0L)
            q += partition->in[i] - (partition->tot[i] * partition->tot[i]) / m2;
    }

    return q / m2;
}

long double louvainPassGraphCSR(struct ClusterStats *stats, struct ClusterPartition *partition, struct GraphCSR *graph)
{

    long double startModularity = modularityGraphCSR(stats, partition, graph);
    long double newModularity = startModularity;
    long double curModularity;
    long double degreeW, bestCommW, bestGain, newGain;
    uint32_t i, j, node;
    uint32_t oldComm, newComm, bestComm;
    uint32_t nbMoves;


    return startModularity;

}

struct ClusterStats *louvainGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct ClusterStats *stats = newClusterStatsGraphCSR(graph);

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Starting Louvain");
    printf(" -----------------------------------------------------\n");

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    struct ClusterPartition *partition;
    long double improvement;

    partition = newClusterPartitionGraphCSR(graph);

    improvement = louvainPassGraphCSR(stats, partition, graph);

    printf("improvement:%Lf - total_weight:%Lf \n", improvement, stats->total_weight);

    freeClusterPartition(partition);
    free(timer);

    return stats;
}

// ********************************************************************************************
// ***************                  CSR Leiden                                  **************
// ********************************************************************************************

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


// ********************************************************************************************
// ***************                  CSR Incremental Aggregation                  **************
// ********************************************************************************************

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