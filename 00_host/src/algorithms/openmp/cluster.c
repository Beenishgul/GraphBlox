/*
* @Author: Abdullah
* @Date:   2023-02-07 17:28:50
* @Last Modified by:   Abdullah
* @Last Modified time: 2023-02-22 21:03:35
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

#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
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
        // printf("-------------> %f \n", edges_array_weight[edge_id]);
#else
        total_weight += 1.0 ;
#endif
    }

    stats->total_weight = total_weight;

    // printf("-------------> %Lf \n", total_weight);

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

#if WEIGHTED
    float *edges_array_weight = NULL;
#endif

    vertices = graph->vertices;
#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
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

    vertices = graph->vertices;
    sorted_edges_array = graph->sorted_edges_array->edges_array_dest;
#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
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

inline void removeNodeGraphCSR(struct ClusterPartition *partition, struct GraphCSR *graph, uint32_t node, uint32_t comm, long double dnodecomm)
{
    partition->in[comm]  -= 2.0L * dnodecomm + selfloopWeightedGraphCSR(graph, node);
    partition->tot[comm] -= degreeWeightedGraphCSR(graph, node);
}

inline void insertNodeGraphCSR(struct ClusterPartition *partition, struct GraphCSR *graph, uint32_t node, uint32_t comm, long double dnodecomm)
{
    partition->in[comm]  += 2.0L * dnodecomm + selfloopWeightedGraphCSR(graph, node);
    partition->tot[comm] += degreeWeightedGraphCSR(graph, node);

    partition->node2Community[node] = comm;
}

inline long double gainGraphCSR(struct ClusterPartition *partition, struct ClusterStats *stats, uint32_t comm, long double dnc, long double degc)
{
    long double totc = partition->tot[comm];
    long double m2   = stats->total_weight;

    return (dnc - totc * degc / m2);
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

uint32_t updateClusterPartitionGraphCSR(struct ClusterPartition *partition, uint32_t *partitions, uint32_t size)
{

    // Renumber the communities in partition
    uint32_t *renumber = (uint32_t *) calloc(partition->size, sizeof(uint32_t));
    uint32_t i, last = 1;
    for (i = 0; i < partition->size; i++)
    {
        if (renumber[partition->node2Community[i]] == 0)
        {
            renumber[partition->node2Community[i]] = last++;
        }
    }

    // Update partitions with the renumbered communities in partition
    for (i = 0; i < size; i++)
    {
        partitions[i] = renumber[partition->node2Community[partitions[i]]] - 1;
    }

    free(renumber);
    return last - 1;

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
    uint32_t j;
    uint32_t neigh, neighComm;
    long double neighW;
    partition->neighCommPos[0] = partition->node2Community[node];
    partition->neighCommWeights[partition->neighCommPos[0]] = 0.;
    partition->neighCommNb = 1;

    uint32_t degree;
    uint32_t edge_idx;

    struct Vertex *vertices = NULL;
    uint32_t *sorted_edges_array = NULL;

#if WEIGHTED
    float *edges_array_weight = NULL;
#endif

    vertices = graph->vertices;
    sorted_edges_array = graph->sorted_edges_array->edges_array_dest;
#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
#endif

    degree = vertices->out_degree[node];
    edge_idx = vertices->edges_idx[node];
    // for all neighbors of node, add weight to the corresponding community
    for(j = edge_idx ; j < (edge_idx + degree) ; j++)
    {
        neigh = EXTRACT_VALUE(sorted_edges_array[j]);
        neighComm = partition->node2Community[neigh];
#if WEIGHTED
        neighW =  edges_array_weight[j];
#else
        neighW = 1.0 ;
#endif
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

/*
Same behavior as neighCommunities except:
- self loop are counted
- data structure if not reinitialised
*/
void neighboringCommunitiesAll(struct ClusterPartition *partition, struct GraphCSR *graph, uint32_t node)
{
    uint32_t j;
    uint32_t neigh, neighComm;
    long double neighW;
    partition->neighCommPos[0] = partition->node2Community[node];
    partition->neighCommWeights[partition->neighCommPos[0]] = 0.;
    partition->neighCommNb = 1;

    uint32_t degree;
    uint32_t edge_idx;

    struct Vertex *vertices = NULL;
    uint32_t *sorted_edges_array = NULL;

#if WEIGHTED
    float *edges_array_weight = NULL;
#endif

    vertices = graph->vertices;
    sorted_edges_array = graph->sorted_edges_array->edges_array_dest;
#if WEIGHTED
    edges_array_weight = graph->sorted_edges_array->edges_array_weight;
#endif

    degree = vertices->out_degree[node];
    edge_idx = vertices->edges_idx[node];
    // for all neighbors of node, add weight to the corresponding community
    for(j = edge_idx ; j < (edge_idx + degree) ; j++)
    {
        neigh = EXTRACT_VALUE(sorted_edges_array[j]);
        neighComm = partition->node2Community[neigh];
#if WEIGHTED
        neighW =  edges_array_weight[j];
#else
        neighW = 1.0 ;
#endif

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


// Return the meta graph induced by a partition of a graph
// See Louvain article for more details
struct GraphCSR *louvainPartitionToGraphCSR(struct ClusterPartition *partition, struct GraphCSR *graph)
{

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

void printClusterPartition(struct ClusterPartition *partition)
{

    uint32_t v;

    printf(" -----------------------------------------------------\n");
    printf("| %-21s | %-27s | \n", "size", "neighCommNb");
    printf(" -----------------------------------------------------\n");
    printf("| %-21u | %-27u | \n",  partition->size, partition->neighCommNb);
    printf(" ----------------------------------------------------------------------------------------------------------\n");
    printf("| %-15s | %-15s | %-15s | %-15s | %-15s | %-15s | \n", "V", "node2Community", "in", "tot", "neighCommWeights", "neighCommPos");
    printf(" ----------------------------------------------------------------------------------------------------------\n");


    for (v = 0; v < partition->size; v++)
    {
        printf("| %-15u | %-15u | %-15Lf | %-15Lf | %-15Lf | %-15u | \n", v, partition->node2Community[v], partition->in[v], partition->tot[v], partition->neighCommWeights[v], partition->neighCommPos[v]);

    }
    printf(" ----------------------------------------------------------------------------------------------------------\n");
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

    // repeat while
    //   there are some nodes moving
    //   or there is an improvement of quality greater than a given epsilon
    do
    {

        curModularity = newModularity;
        nbMoves = 0;

        // for each node:
        //   remove the node from its community
        //   compute the gain for its insertion in all neighboring communities
        //   insert it in the best community with the highest gain
        for (i = 0; i < graph->num_vertices; i++)
        {
            node = i;
            oldComm = partition->node2Community[node];
            degreeW = degreeWeightedGraphCSR(graph, node);

            // computation of all neighboring communities of current node
            neighboringCommunitiesInitialize(partition);
            neighboringCommunities(partition, graph, node);

            // remove node from its current community
            removeNodeGraphCSR(partition, graph, node, oldComm, partition->neighCommWeights[oldComm]);

            // compute the gain for all neighboring communities
            // default choice is the former community
            bestComm = oldComm;
            bestCommW  = 0.0L;
            bestGain = 0.0L;

            for (j = 0; j < partition->neighCommNb; j++)
            {
                newComm = partition->neighCommPos[j];
                newGain = gainGraphCSR(partition, stats, newComm, partition->neighCommWeights[newComm], degreeW);

                if (newGain > bestGain)
                {
                    bestComm = newComm;
                    bestCommW = partition->neighCommWeights[newComm];
                    bestGain = newGain;
                }
            }

            // insert node in the nearest community
            insertNodeGraphCSR(partition, graph, node, bestComm, bestCommW);

            if (bestComm != oldComm)
            {
                nbMoves++;
            }

        }

        newModularity = modularityGraphCSR(stats, partition, graph);
    }
    while (nbMoves > 0 &&
            newModularity - curModularity > MIN_IMPROVEMENT);


    return newModularity - startModularity;

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
    uint32_t n;
    uint32_t originalSize = graph->num_vertices;

    partition = newClusterPartitionGraphCSR(graph);
    printClusterPartition(partition);

    improvement = louvainPassGraphCSR(stats, partition, graph);
    printClusterPartition(partition);

    n = updateClusterPartitionGraphCSR(partition, stats->partitions, originalSize);
    printClusterPartition(partition);

    if (improvement < MIN_IMPROVEMENT)
    {
        freeClusterPartition(partition);
        // break;
        return stats;
    }

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