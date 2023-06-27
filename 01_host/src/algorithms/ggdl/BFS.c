// -----------------------------------------------------------------------------
//
//      "00_GLay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@avirginia.edu||atmughra@virginia||atmughrabi@gmail.com
// File   : BFS.c
// Create : 2022-09-28 15:20:58
// Revise : 2022-09-28 15:34:05
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

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




#include "BFS.h"


// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************

struct BFSStats *newBFSStatsGraphCSR(struct GraphCSR *graph)
{

    uint32_t vertex_id;

    struct BFSStats *stats = (struct BFSStats *) my_malloc(sizeof(struct BFSStats));

    stats->distances  = (uint32_t *) my_malloc(graph->num_vertices * sizeof(uint32_t));
    stats->distances_DualOrder  = (uint32_t *) my_malloc(graph->num_vertices * sizeof(uint32_t));
    stats->parents = (int *) my_malloc(graph->num_vertices * sizeof(int));
    stats->parents_DualOrder = (int *) my_malloc(graph->num_vertices * sizeof(int));
    stats->processed_nodes = 0;
    stats->iteration = 0;
    stats->num_vertices = graph->num_vertices;
    stats->time_total = 0.0f;

    // optimization for BFS implentaion instead of -1 we use -out degree to for hybrid approach counter
    #pragma omp parallel for default(none) private(vertex_id) shared(stats,graph)
    for(vertex_id = 0; vertex_id < graph->num_vertices ; vertex_id++)
    {
        stats->distances[vertex_id] = 0;
        // stats->parents_DualOrder[vertex_id] = 0;
        if(graph->vertices->out_degree[vertex_id])
        {
            stats->parents[vertex_id] = graph->vertices->out_degree[vertex_id] * (-1);
            stats->parents_DualOrder[vertex_id] = graph->vertices->out_degree[vertex_id] * (-1);
        }
        else
        {
            stats->parents[vertex_id] = -1;
            stats->parents_DualOrder[vertex_id] = -1;
        }
    }

    return stats;

}

void freeBFSStats(struct BFSStats *stats)
{


    if(stats)
    {
        if(stats->distances)
            free(stats->distances);
        if(stats->parents)
            free(stats->parents);
        if(stats->distances_DualOrder)
            free(stats->distances_DualOrder);
        if(stats->parents_DualOrder)
            free(stats->parents_DualOrder);
        free(stats);
    }

}


// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************
struct BFSStats *breadthFirstSearchGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct BFSStats *stats = NULL;

    switch (arguments->pushpull)
    {
    case 0: // pull
        stats = breadthFirstSearchPullGraphCSR(arguments, graph);
        break;
    case 1: // push
        stats = breadthFirstSearchPushGraphCSR(arguments, graph);
        break;
    case 2: // pull/push
        stats = breadthFirstSearchDirectionOptimizedGraphCSR(arguments, graph);
        break;
    default:// push
        stats = breadthFirstSearchDirectionOptimizedGraphCSR(arguments, graph);
        break;
    }


    return stats;

}

// breadth-first-search(graph, arguments->source)
//  sharedFrontierQueue ← {arguments->source}
//  next ← {}
//  parents ← [-1,-1,. . . -1]
//      while sharedFrontierQueue 6= {} do
//          top-down-step(graph, sharedFrontierQueue, next, parents)
//          sharedFrontierQueue ← next
//          next ← {}
//      end while
//  return parents

struct BFSStats *breadthFirstSearchPullGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct BFSStats *stats = newBFSStatsGraphCSR(graph);

    if(arguments->source > graph->num_vertices)
    {
        printf(" -----------------------------------------------------\n");
        printf("| %-51s | \n", "ERROR!! CHECK SOURCE RANGE");
        printf(" -----------------------------------------------------\n");
        return stats;
    }

    arguments->source = graph->sorted_edges_array->label_array[arguments->source];

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Starting BFS PULL/BU (SOURCE NODE)");
    printf(" -----------------------------------------------------\n");
    printf("| %-51u | \n", arguments->source);
    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15s | %-15s | \n", "Iteration", "Nodes", "Time (Seconds)");
    printf(" -----------------------------------------------------\n");

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));
    struct Timer *timer_inner = (struct Timer *) malloc(sizeof(struct Timer));

    struct ArrayQueue *sharedFrontierQueue = newArrayQueue(graph->num_vertices);

    uint32_t nf = 0; // number of vertices in sharedFrontierQueue


    Start(timer_inner);
    setBit(sharedFrontierQueue->q_bitmap_next, arguments->source);
    sharedFrontierQueue->q_bitmap_next->numSetBits = 1;
    stats->parents[arguments->source] = arguments->source;

    swapBitmaps(&sharedFrontierQueue->q_bitmap, &sharedFrontierQueue->q_bitmap_next);
    clearBitmap(sharedFrontierQueue->q_bitmap_next);
    Stop(timer_inner);
    stats->time_total +=  Seconds(timer_inner);

    printf("| BU %-12u | %-15u | %-15f | \n", stats->iteration++, ++stats->processed_nodes, Seconds(timer_inner));

    Start(timer);



    while (sharedFrontierQueue->q_bitmap->numSetBits)
    {

        Start(timer_inner);

        nf = bottomUpStepGraphCSR(graph, sharedFrontierQueue->q_bitmap, sharedFrontierQueue->q_bitmap_next, stats);

        sharedFrontierQueue->q_bitmap_next->numSetBits = nf;
        swapBitmaps(&sharedFrontierQueue->q_bitmap, &sharedFrontierQueue->q_bitmap_next);
        clearBitmap(sharedFrontierQueue->q_bitmap_next);
        Stop(timer_inner);

        //stats
        stats->time_total +=  Seconds(timer_inner);
        stats->processed_nodes += nf;
        printf("| BU %-12u | %-15u | %-15f | \n", stats->iteration++, nf, Seconds(timer_inner));

    } // end while

    Stop(timer);


    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15u | %-15f | \n", "No OverHead", stats->processed_nodes, stats->time_total);
    printf(" -----------------------------------------------------\n");
    stats->time_total =  Seconds(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15u | %-15f | \n", "total", stats->processed_nodes, Seconds(timer));
    printf(" -----------------------------------------------------\n");
    freeArrayQueue(sharedFrontierQueue);
    free(timer);
    free(timer_inner);

    return stats;
}

// breadth-first-search(graph, arguments->source)
//  sharedFrontierQueue ← {arguments->source}
//  next ← {}
//  parents ← [-1,-1,. . . -1]
//      while sharedFrontierQueue 6= {} do
//          top-down-step(graph, sharedFrontierQueue, next, parents)
//          sharedFrontierQueue ← next
//          next ← {}
//      end while
//  return parents

struct BFSStats *breadthFirstSearchPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct BFSStats *stats = newBFSStatsGraphCSR(graph);

    if(arguments->source > graph->num_vertices)
    {
        printf(" -----------------------------------------------------\n");
        printf("| %-51s | \n", "ERROR!! CHECK SOURCE RANGE");
        printf(" -----------------------------------------------------\n");
        return stats;
    }

    arguments->source = graph->sorted_edges_array->label_array[arguments->source];

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Starting BFS PUSH/TD (SOURCE NODE)");
    printf(" -----------------------------------------------------\n");
    printf("| %-51u | \n", arguments->source);
    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15s | %-15s | \n", "Iteration", "Nodes", "Time (Seconds)");
    printf(" -----------------------------------------------------\n");


    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));
    struct Timer *timer_inner = (struct Timer *) malloc(sizeof(struct Timer));

    struct ArrayQueue *sharedFrontierQueue = newArrayQueue(graph->num_vertices);

    uint32_t P = arguments->algo_numThreads;

    struct ArrayQueue **localFrontierQueues = (struct ArrayQueue **) my_malloc( P * sizeof(struct ArrayQueue *));


    uint32_t i;
    for(i = 0 ; i < P ; i++)
    {
        localFrontierQueues[i] = newArrayQueue(graph->num_vertices);

    }

    Start(timer_inner);
    enArrayQueue(sharedFrontierQueue, arguments->source);
    // setBit(sharedFrontierQueue->q_bitmap,arguments->source);
    stats->parents[arguments->source] = arguments->source;
    Stop(timer_inner);
    stats->time_total +=  Seconds(timer_inner);
    // graph->vertices[arguments->source].visited = 1;


    printf("| TD %-12u | %-15u | %-15f | \n", stats->iteration++, ++stats->processed_nodes, Seconds(timer_inner));

    Start(timer);
    while(!isEmptyArrayQueue(sharedFrontierQueue))  // start while
    {

        Start(timer_inner);
        topDownStepGraphCSR(graph, sharedFrontierQueue, localFrontierQueues, stats);
        slideWindowArrayQueue(sharedFrontierQueue);
        Stop(timer_inner);

        //stats collection
        stats->time_total +=  Seconds(timer_inner);
        stats->processed_nodes += sharedFrontierQueue->tail - sharedFrontierQueue->head;
        printf("| TD %-12u | %-15u | %-15f | \n", stats->iteration++, sharedFrontierQueue->tail - sharedFrontierQueue->head, Seconds(timer_inner));

    } // end while
    Stop(timer);

    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15u | %-15f | \n", "No OverHead", stats->processed_nodes, stats->time_total);
    printf(" -----------------------------------------------------\n");
    stats->time_total =  Seconds(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15u | %-15f | \n", "total", stats->processed_nodes, Seconds(timer));
    printf(" -----------------------------------------------------\n");

    for(i = 0 ; i < P ; i++)
    {
        freeArrayQueue(localFrontierQueues[i]);
    }
    free(localFrontierQueues);
    freeArrayQueue(sharedFrontierQueue);
    free(timer);
    free(timer_inner);


    return stats;
}

// breadth-first-search(graph, arguments->source)
//  sharedFrontierQueue ← {arguments->source}
//  next ← {}
//  parents ← [-1,-1,. . . -1]
//      while sharedFrontierQueue 6= {} do
//          top-down-step(graph, sharedFrontierQueue, next, parents)
//          sharedFrontierQueue ← next
//          next ← {}
//      end while
//  return parents

struct BFSStats *breadthFirstSearchDirectionOptimizedGraphCSR(struct Arguments *arguments, struct GraphCSR *graph)
{

    struct BFSStats *stats = newBFSStatsGraphCSR(graph);


    if(arguments->source > graph->num_vertices)
    {
        printf(" -----------------------------------------------------\n");
        printf("| %-51s | \n", "ERROR!! CHECK SOURCE RANGE");
        printf(" -----------------------------------------------------\n");
        return stats;
    }

    arguments->source = graph->sorted_edges_array->label_array[arguments->source];

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Starting BFS PUSH/PULL(SOURCE NODE)");
    printf(" -----------------------------------------------------\n");
    printf("| %-51u | \n", arguments->source);
    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15s | %-15s | \n", "Iteration", "Nodes", "Time (Seconds)");
    printf(" -----------------------------------------------------\n");



    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));
    struct Timer *timer_inner = (struct Timer *) malloc(sizeof(struct Timer));

    struct ArrayQueue *sharedFrontierQueue = newArrayQueue(graph->num_vertices);
    struct Bitmap *bitmapCurr = newBitmap(graph->num_vertices);
    struct Bitmap *bitmapNext = newBitmap(graph->num_vertices);

    uint32_t P = arguments->algo_numThreads;
    uint32_t mu = graph->num_edges; // number of edges to check from sharedFrontierQueue
    uint32_t mf = graph->vertices->out_degree[arguments->source]; // number of edges from unexplored verticies
    uint32_t nf = 0; // number of vertices in sharedFrontierQueue
    uint32_t nf_prev = 0; // number of vertices in sharedFrontierQueue
    uint32_t n = graph->num_vertices; // number of nodes
    uint32_t alpha = 15;
    uint32_t beta = 18;

    struct ArrayQueue **localFrontierQueues = (struct ArrayQueue **) my_malloc( P * sizeof(struct ArrayQueue *));


    uint32_t i;
    for(i = 0 ; i < P ; i++)
    {
        localFrontierQueues[i] = newArrayQueue(graph->num_vertices);

    }



    Start(timer_inner);
    enArrayQueue(sharedFrontierQueue, arguments->source);
    // setBit(sharedFrontierQueue->q_bitmap,arguments->source);
    stats->parents[arguments->source] = arguments->source;
    Stop(timer_inner);
    stats->time_total +=  Seconds(timer_inner);
    // graph->vertices[arguments->source].visited = 1;


    printf("| TD %-12u | %-15u | %-15f | \n", stats->iteration++, ++stats->processed_nodes, Seconds(timer_inner));

    Start(timer);

    while(!isEmptyArrayQueue(sharedFrontierQueue))  // start while
    {

        if(mf > (mu / alpha))
        {

            Start(timer_inner);
            arrayQueueToBitmap(sharedFrontierQueue, bitmapCurr);
            nf = sizeArrayQueue(sharedFrontierQueue);
            Stop(timer_inner);
            printf("| E  %-12s | %-15s | %-15f | \n", " ", " ", Seconds(timer_inner));

            do
            {
                Start(timer_inner);
                nf_prev = nf;
                nf = bottomUpStepGraphCSR(graph, bitmapCurr, bitmapNext, stats);

                swapBitmaps(&bitmapCurr, &bitmapNext);
                clearBitmap(bitmapNext);
                Stop(timer_inner);

                //stats collection
                stats->time_total +=  Seconds(timer_inner);
                stats->processed_nodes += nf;
                printf("| BU %-12u | %-15u | %-15f | \n", stats->iteration++, nf, Seconds(timer_inner));

            }
            while(( nf > nf_prev) ||  // growing;
                    ( nf > (n / beta)));

            Start(timer_inner);
            bitmapToArrayQueue(bitmapCurr, sharedFrontierQueue, localFrontierQueues);
            Stop(timer_inner);
            printf("| C  %-12s | %-15s | %-15f | \n", " ", " ", Seconds(timer_inner));

            mf = 1;

        }
        else
        {

            Start(timer_inner);
            mu -= mf;
            mf = topDownStepGraphCSR(graph, sharedFrontierQueue, localFrontierQueues, stats);

            slideWindowArrayQueue(sharedFrontierQueue);
            Stop(timer_inner);

            //stats collection
            stats->time_total +=  Seconds(timer_inner);
            stats->processed_nodes += sharedFrontierQueue->tail - sharedFrontierQueue->head;
            printf("| TD %-12u | %-15u | %-15f | \n", stats->iteration++, sharedFrontierQueue->tail - sharedFrontierQueue->head, Seconds(timer_inner));

        }



    } // end while

    Stop(timer);
    // stats->time_total =  Seconds(timer);

    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15u | %-15f | \n", "No OverHead", stats->processed_nodes, stats->time_total);
    printf(" -----------------------------------------------------\n");
    stats->time_total =  Seconds(timer);
    printf(" -----------------------------------------------------\n");
    printf("| %-15s | %-15u | %-15f | \n", "total", stats->processed_nodes, Seconds(timer));
    printf(" -----------------------------------------------------\n");

    for(i = 0 ; i < P ; i++)
    {
        freeArrayQueue(localFrontierQueues[i]);
    }
    free(localFrontierQueues);
    freeArrayQueue(sharedFrontierQueue);
    freeBitmap(bitmapNext);
    freeBitmap(bitmapCurr);
    free(timer);
    free(timer_inner);

    return stats;
}


// top-down-step(graph, sharedFrontierQueue, next, parents)
//  for v ∈ sharedFrontierQueue do
//      for u ∈ neighbors[v] do
//          if parents[u] = -1 then
//              parents[u] ← v
//              next ← next ∪ {u}
//          end if
//      end for
//  end for

uint32_t topDownStepGraphCSR(struct GraphCSR *graph, struct ArrayQueue *sharedFrontierQueue, struct ArrayQueue **localFrontierQueues, struct BFSStats *stats)
{



    uint32_t v;
    uint32_t u;
    uint32_t i;
    uint32_t j;
    uint32_t edge_idx;
    uint32_t mf = 0;



    #pragma omp parallel default (none) private(u,v,j,i,edge_idx) shared(stats,localFrontierQueues,graph,sharedFrontierQueue,mf)
    {
        uint32_t t_id = omp_get_thread_num();
        struct ArrayQueue *localFrontierQueue = localFrontierQueues[t_id];


        #pragma omp for reduction(+:mf) schedule(auto)
        for(i = sharedFrontierQueue->head ; i < sharedFrontierQueue->tail; i++)
        {
            v = sharedFrontierQueue->queue[i];
            edge_idx = graph->vertices->edges_idx[v];

            for(j = edge_idx ; j < (edge_idx + graph->vertices->out_degree[v]) ; j++)
            {

                u = EXTRACT_VALUE(graph->sorted_edges_array->edges_array_dest[j]);
                int u_parent = stats->parents[u];
                if(u_parent < 0 )
                {
                    if(__sync_bool_compare_and_swap(&stats->parents[u], u_parent, v))
                    {
                        enArrayQueue(localFrontierQueue, u);
                        mf +=  -(u_parent);
                        stats->distances[u] = stats->distances[v] + 1;
                    }
                }
            }

        }

        flushArrayQueueToShared(localFrontierQueue, sharedFrontierQueue);
    }

    return mf;
}


// bottom-up-step(graph, sharedFrontierQueue, next, parents) //pull
//  for v ∈ vertices do
//      if parents[v] = -1 then
//          for u ∈ neighbors[v] do
//              if u ∈ sharedFrontierQueue then
//              parents[v] ← u
//              next ← next ∪ {v}
//              break
//              end if
//          end for
//      end if
//  end for

uint32_t bottomUpStepGraphCSR(struct GraphCSR *graph, struct Bitmap *bitmapCurr, struct Bitmap *bitmapNext, struct BFSStats *stats)
{


    uint32_t v;
    uint32_t u;
    uint32_t j;
    uint32_t edge_idx;
    uint32_t out_degree;
    struct Vertex *vertices = NULL;
    uint32_t *sorted_edges_array = NULL;

    // uint32_t processed_nodes = bitmapCurr->numSetBits;
    uint32_t nf = 0; // number of vertices in sharedFrontierQueue
    // stats->processed_nodes += processed_nodes;

#if DIRECTED
    vertices = graph->inverse_vertices;
    sorted_edges_array = graph->inverse_sorted_edges_array->edges_array_dest;
#else
    vertices = graph->vertices;
    sorted_edges_array = graph->sorted_edges_array->edges_array_dest;
#endif


    #pragma omp parallel for default(none) private(j,u,v,out_degree,edge_idx) shared(stats,bitmapCurr,bitmapNext,graph,vertices,sorted_edges_array) reduction(+:nf) schedule(dynamic, 1024)
    for(v = 0 ; v < graph->num_vertices ; v++)
    {
        out_degree = vertices->out_degree[v];
        if(stats->parents[v] < 0)  // optmization
        {
            edge_idx = vertices->edges_idx[v];

            for(j = edge_idx ; j < (edge_idx + out_degree) ; j++)
            {
                u = EXTRACT_VALUE(sorted_edges_array[j]);
                if(getBit(bitmapCurr, u))
                {
                    stats->parents[v] = u;
                    //we are not considering distance array as it is not implemented in AccelGraph
                    stats->distances[v] = stats->distances[u] + 1;
                    setBitAtomic(bitmapNext, v);
                    nf++;
                    break;
                }
            }

        }

    }
    return nf;
}
