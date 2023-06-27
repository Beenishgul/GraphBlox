// -----------------------------------------------------------------------------
//
//      "00_GLay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : csrSegments.c
// Create : 2019-06-21 17:15:17
// Revise : 2019-09-28 15:36:13
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <omp.h>

#include "csrSegments.h"
#include "edgeList.h"
#include "vertex.h"
#include "myMalloc.h"
#include "graphConfig.h"
#include "bitmap.h"
#include "timer.h"

void csrSegmentsPrint(struct CSRSegments *csrSegments)
{


    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "CSRSegments Properties");
    printf(" -----------------------------------------------------\n");
#if WEIGHTED
    printf("| %-51s | \n", "WEIGHTED");
#else
    printf("| %-51s | \n", "UN-WEIGHTED");
#endif

#if DIRECTED
    printf("| %-51s | \n", "DIRECTED");
#else
    printf("| %-51s | \n", "UN-DIRECTED");
#endif
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Vertices (V)");
    printf("| %-51u | \n", csrSegments->num_vertices);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Edges (E)");
    printf("| %-51u | \n", csrSegments->num_edges);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Segments (S)");
    printf("| %-51u | \n", csrSegments->num_segments);
    printf(" -----------------------------------------------------\n");

    // uint32_t i;
    // for ( i = 0; i < csrSegments->num_vertices; ++i)
    // {

    //     uint32_t begin = getSegmentRangeBegin();
    //     uint32_t end = getSegmentRangeEnd();

    // }

    // uint32_t i;
    // for ( i = 0; i < (csrSegments->num_segments * csrSegments->num_segments); ++i)
    // {

    //     uint32_t x = i % csrSegments->num_segments;    // % is the "modulo operator", the remainder of i / width;
    //     uint32_t y = i / csrSegments->num_segments;


    //     printf("| %-11s (%u,%u)   | \n", "Segment: ", y, x);
    //     printf("| %-11s %-40u  | \n", "Edges: ", csrSegments->segments[i].num_edges);
    //     printf("| %-11s %-40u  | \n", "Vertices: ", csrSegments->segments[i].num_vertices);
    //     edgeListPrint(csrSegments->segments[i].edgeList);
    // }


}

void   graphCSRSegmentsResetActiveSegments(struct CSRSegments *csrSegments)
{

    uint32_t totalSegments = 0;
    totalSegments = csrSegments->num_segments;
    uint32_t i;

    #pragma omp parallel for default(none) shared(csrSegments,totalSegments) private(i)
    for (i = 0; i < totalSegments; ++i)
    {
        csrSegments->activeSegments[i] = 0;
    }



}

void   graphCSRSegmentsResetActiveSegmentsMap(struct CSRSegments *csrSegments)
{

    clearBitmap(csrSegments->activeSegmentsMap);

}

void   graphCSRSegmentsSetActiveSegmentsMap(struct CSRSegments *csrSegments, uint32_t vertex)
{

    // uint32_t row = getSegmentID(csrSegments->num_vertices, csrSegments->num_segments, vertex);
    uint32_t Segment_idx = 0;
    uint32_t i;
    uint32_t totalSegments = 0;
    totalSegments = csrSegments->num_segments;

    // #pragma omp parallel for default(none) shared(csrSegments,totalSegments,row) private(i,Segment_idx)

    for ( i = 0; i < totalSegments; ++i)
    {

        Segment_idx = i;

        if(csrSegments->segments[Segment_idx].edgeList->num_edges)
        {
            if(!getBit(csrSegments->activeSegmentsMap, Segment_idx))
            {
                setBitAtomic(csrSegments->activeSegmentsMap, Segment_idx);
            }
        }
    }
}

void   graphCSRSegmentsSetActiveSegments(struct CSRSegments *csrSegments, uint32_t vertex)
{

    // uint32_t row = getSegmentID(csrSegments->num_vertices, csrSegments->num_segments, vertex);
    uint32_t Segment_idx = 0;
    uint32_t i;
    uint32_t totalSegments = 0;
    totalSegments = csrSegments->num_segments;

    // #pragma omp parallel for default(none) shared(csrSegments,totalSegments,row) private(i,Segment_idx)
    for ( i = 0; i < totalSegments; ++i)
    {

        Segment_idx =  i;
        if(csrSegments->segments[Segment_idx].edgeList->num_edges)
        {
            csrSegments->activeSegments[Segment_idx] = 1;
        }
    }
}



struct CSRSegments *csrSegmentsNew(struct EdgeList *edgeList, struct Arguments *arguments)
{


    uint32_t totalSegments = 0;


    struct CSRSegments *csrSegments = (struct CSRSegments *) my_malloc( sizeof(struct CSRSegments));


    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    csrSegments->num_edges = edgeList->num_edges;
    csrSegments->num_vertices = edgeList->num_vertices;
    csrSegments->num_segments = csrSegmentsCalculateSegments(edgeList, arguments->cache_size);
    totalSegments = csrSegments->num_segments;

    csrSegments->segments = (struct Segment *) my_malloc(totalSegments * sizeof(struct Segment));
    csrSegments->activeSegments = (uint32_t *) my_malloc(totalSegments * sizeof(uint32_t));
    csrSegments->out_degree = (uint32_t *) my_malloc((csrSegments->num_vertices) * sizeof(uint32_t));
    csrSegments->in_degree = (uint32_t *) my_malloc((csrSegments->num_vertices) * sizeof(uint32_t));
    csrSegments->vertex_segment_index = (uint32_t *) my_malloc((csrSegments->num_vertices) * sizeof(uint32_t));

    // csrSegments->activeVertices = newBitmap(csrSegments->num_vertices);
    csrSegments->activeSegmentsMap = newBitmap(totalSegments);

    uint32_t i;
    #pragma omp parallel for default(none) private(i) shared(totalSegments,csrSegments)
    for (i = 0; i < totalSegments; ++i)
    {
        csrSegments->segments[i].num_edges = 0;
        csrSegments->segments[i].num_vertices = 0;
        csrSegments->segments[i].edgeList = NULL;
        csrSegments->segments[i].graphCSR = NULL;
        csrSegments->activeSegments[i] = 0;
    }


    #pragma omp parallel for default(none) private(i) shared(csrSegments)
    for (i = 0; i < csrSegments->num_vertices ; ++i)
    {
        csrSegments->out_degree[i] = 0;
        csrSegments->in_degree[i] = 0;
        csrSegments->vertex_segment_index[i] = 0;
    }


    Start(timer);
    csrSegments = graphCSRSegmentsProcessInOutDegrees(csrSegments, edgeList);
    Stop(timer);
    csrSegmentsPrintMessageWithtime("CSRSegments Process In Out Degrees (Seconds)", Seconds(timer));

    Start(timer);
    csrSegments = csrSegmentsSegmentEdgeListSizePreprocessing(csrSegments, edgeList);
    Stop(timer);
    csrSegmentsPrintMessageWithtime("Segment EdgeList Size (Seconds)", Seconds(timer));

    Start(timer);
    csrSegments = csrSegmentsSegmentsMemoryAllocations(csrSegments);
    Stop(timer);
    csrSegmentsPrintMessageWithtime("Segments Memory Allocations (Seconds)", Seconds(timer));

    Start(timer);
    csrSegments = csrSegmentsSegmentEdgePopulation(csrSegments, edgeList);
    Stop(timer);
    csrSegmentsPrintMessageWithtime("Segment Edge Population (Seconds)", Seconds(timer));

    Start(timer);
    csrSegments = csrSegmentsSegmentVertexSizePreprocessing(csrSegments);
    Stop(timer);
    csrSegmentsPrintMessageWithtime("Segment Vertex Size (Seconds)", Seconds(timer));

    Start(timer);
    csrSegments = csrSegmentsCreationPreprocessing(csrSegments, arguments);
    Stop(timer);
    csrSegmentsPrintMessageWithtime("CSR Segments Creation Total (Seconds)", Seconds(timer));

    free(timer);
    return csrSegments;
}



void  csrSegmentsFree(struct CSRSegments *csrSegments)
{


    if(csrSegments)
    {
        uint32_t totalSegments = csrSegments->num_segments;
        uint32_t i;

        for (i = 0; i < totalSegments; ++i)
        {
            if(csrSegments->segments[i].edgeList)
            {
                freeEdgeList(csrSegments->segments[i].edgeList);
            }
            if(csrSegments->segments[i].graphCSR)
            {
                graphCSRFree(csrSegments->segments[i].graphCSR);
            }
        }

        if(csrSegments->activeSegmentsMap)
            freeBitmap(csrSegments->activeSegmentsMap);

        if(csrSegments->activeSegments)
            free(csrSegments->activeSegments);

        if(csrSegments->out_degree)
            free(csrSegments->out_degree);

        if(csrSegments->vertex_segment_index)
            free(csrSegments->vertex_segment_index);

        if(csrSegments->in_degree)
            free(csrSegments->in_degree);

        if(csrSegments->segments)
            free(csrSegments->segments);

        free(csrSegments);
    }
}


struct CSRSegments *graphCSRSegmentsProcessInOutDegrees(struct CSRSegments *csrSegments, struct EdgeList *edgeList)
{

    uint32_t i;
    uint32_t src;
    uint32_t dest;

    #pragma omp parallel for default(none) private(i,src,dest) shared(edgeList,csrSegments)
    for(i = 0; i < edgeList->num_edges; i++)
    {

        src  = edgeList->edges_array_src[i];
        dest = edgeList->edges_array_dest[i];

        #pragma omp atomic update
        csrSegments->out_degree[src]++;

        #pragma omp atomic update
        csrSegments->in_degree[dest]++;

    }

    return csrSegments;

}

struct CSRSegments *csrSegmentsSegmentVertexSizePreprocessing(struct CSRSegments *csrSegments)
{

    uint32_t i;
    uint32_t j;
    uint32_t src;
    uint32_t dest;
    uint32_t num_vertices = 0;
    uint32_t totalSegments = csrSegments->num_segments;

    // #pragma omp parallel for default(none) private(i) shared(totalSegments,csrSegments)
    #pragma omp parallel for default(none) private(i,src,dest,num_vertices) shared(totalSegments,csrSegments) schedule(dynamic,1024)
    for ( j = 0; j < totalSegments; ++j)
    {

        if(csrSegments->segments[j].num_edges)
        {
            num_vertices = 0;
            // #pragma omp parallel for default(none) private(i,src,dest) shared(j,csrSegments) schedule(dynamic,1024) reduction(max:num_vertices)
            for(i = 0; i <  csrSegments->segments[j].edgeList->num_edges; i++)
            {
                src  =  csrSegments->segments[j].edgeList->edges_array_src[i];
                dest =  csrSegments->segments[j].edgeList->edges_array_dest[i];
                num_vertices = maxTwoIntegers(num_vertices, maxTwoIntegers(src, dest));
            }
            csrSegments->segments[j].num_vertices = num_vertices;
            csrSegments->segments[j].edgeList->num_vertices = num_vertices;
        }
    }

    #pragma omp parallel for default(none) private(i) shared(totalSegments,csrSegments)
    for ( j = 0; j < totalSegments; ++j)
    {
        if(csrSegments->segments[j].num_edges)
        {
            csrSegments->segments[j].edgeList->mask_array = (uint32_t *) my_malloc(csrSegments->segments[j].edgeList->num_vertices * sizeof(uint32_t));
            csrSegments->segments[j].edgeList->label_array = (uint32_t *) my_malloc(csrSegments->segments[j].edgeList->num_vertices * sizeof(uint32_t));
            csrSegments->segments[j].edgeList->inverse_label_array = (uint32_t *) my_malloc(csrSegments->segments[j].edgeList->num_vertices * sizeof(uint32_t));

            // #pragma omp parallel for
            for (i = 0; i < csrSegments->segments[j].edgeList->num_vertices; ++i)
            {
                csrSegments->segments[j].edgeList->mask_array[i] = 0;
                csrSegments->segments[j].edgeList->label_array[i] = i;
                csrSegments->segments[j].edgeList->inverse_label_array[i] = i;
            }

            if(csrSegments->segments[j].edgeList->num_vertices)
                csrSegments->segments[j].edgeList->avg_degree = csrSegments->segments[j].edgeList->num_edges / csrSegments->segments[j].edgeList->num_vertices;
        }
    }

    return csrSegments;
}

struct CSRSegments *csrSegmentsCreationPreprocessing(struct CSRSegments *csrSegments, struct Arguments *arguments)
{

    uint32_t j;
    uint32_t totalSegments = csrSegments->num_segments;

    struct Arguments *arguments_local = argumentsNew();
    // argumentsCopy(arguments, arguments_local);

    arguments_local->sflag         = 0;
    arguments_local->datastructure = 0;
    arguments_local->sort          = 0;
    arguments_local->lmode         = 0;
    arguments_local->lmode_l2      = 0;
    arguments_local->lmode_l3      = 0;

    // #pragma omp parallel for default(none) firstprivate(arguments_local, totalSegments) shared(csrSegments)
    for ( j = 0; j < totalSegments; ++j)
    {

        // edgeListPrint(csrSegments->segments[j].edgeList);
        arguments_local->sflag         = 0;
        arguments_local->datastructure = 0;
        arguments_local->sort          = 0;
        arguments_local->lmode         = 1;
        arguments_local->lmode_l2      = 0;
        arguments_local->lmode_l3      = 0;

        if(csrSegments->segments[j].num_edges)
        {
            printf(" ***************************************************** \n");
            printf(" ------------------ SEGMENT ID: %u -------------------- \n", j);
            csrSegments->segments[j].graphCSR = graphCSRPreProcessingStepFromEdgelist(arguments_local, csrSegments->segments[j].edgeList);
            // freeEdgeList(csrSegments->segments[j].edgeList);
            printf(" ***************************************************** \n");
        }

    }

    argumentsFree(arguments_local);
    return csrSegments;


}

struct CSRSegments *csrSegmentsSegmentEdgeListSizePreprocessing(struct CSRSegments *csrSegments, struct EdgeList *edgeList)
{

    uint32_t i;
    // uint32_t src;
    uint32_t dest;
    uint32_t Segment_idx;

    uint32_t num_segments = csrSegments->num_segments;
    uint32_t num_vertices = csrSegments->num_vertices;


    // uint32_t row;
    uint32_t col;

    #pragma omp parallel for default(none) private(i,col,dest,Segment_idx) shared(num_vertices, num_segments,edgeList,csrSegments)
    for(i = 0; i < edgeList->num_edges; i++)
    {

        // src  = edgeList->edges_array_src[i];
        dest = edgeList->edges_array_dest[i];

        // __sync_fetch_and_add(&csrSegments->out_degree[src],1);
        // __sync_fetch_and_add(&csrSegments->in_degree[dest],1);

        // row = getSegmentID(num_vertices, num_segments, src);
        col = getSegmentID(num_vertices, num_segments, dest);
        // Segment_idx = (row * num_segments) + col;
        Segment_idx = col;

        // __sync_fetch_and_add(&csrSegments->segments[Segment_idx].num_edges,1);

        #pragma omp atomic update
        csrSegments->segments[Segment_idx].num_edges++;

        // #pragma omp atomic write
        csrSegments->vertex_segment_index[dest] = Segment_idx;

    }

    return csrSegments;

}


struct CSRSegments *csrSegmentsSegmentEdgePopulation(struct CSRSegments *csrSegments, struct EdgeList *edgeList)
{

    uint32_t i;
    // uint32_t src;
    uint32_t dest;
    uint32_t Segment_idx;
    uint32_t Edge_idx;

    uint32_t num_segments = csrSegments->num_segments;
    uint32_t num_vertices = csrSegments->num_vertices;

    // uint32_t row;
    uint32_t col;




    #pragma omp parallel for default(none) private(Edge_idx,i,col,dest,Segment_idx) shared(num_vertices, num_segments,edgeList,csrSegments)
    for(i = 0; i < edgeList->num_edges; i++)
    {


        // src  = edgeList->edges_array_src[i];
        dest = edgeList->edges_array_dest[i];

        // row = getSegmentID(num_vertices, num_segments, src);
        col = getSegmentID(num_vertices, num_segments, dest);
        // Segment_idx = (row * num_segments) + col;
        Segment_idx = col;

        Edge_idx = __sync_fetch_and_add(&csrSegments->segments[Segment_idx].num_edges, 1);

        csrSegments->segments[Segment_idx].edgeList->edges_array_src[Edge_idx] = edgeList->edges_array_src[i];
        csrSegments->segments[Segment_idx].edgeList->edges_array_dest[Edge_idx] = edgeList->edges_array_dest[i];

#if WEIGHTED
        csrSegments->segments[Segment_idx].edgeList->edges_array_weight[Edge_idx] = edgeList->edges_array_weight[i];
        csrSegments->segments[Segment_idx].edgeList->max_weight = maxTwoFloats( csrSegments->segments[Segment_idx].edgeList->max_weight, edgeList->edges_array_weight[i]);
#endif


    }



    return csrSegments;

}


struct CSRSegments *csrSegmentsSegmentsMemoryAllocations(struct CSRSegments *csrSegments)
{

    uint32_t i = 0;
    uint32_t totalSegments = csrSegments->num_segments;

    #pragma omp parallel for default(none) private(i) shared(totalSegments,csrSegments)
    for ( i = 0; i < totalSegments; ++i)
    {

        if(csrSegments->segments[i].num_edges)
        {
            csrSegments->segments[i].edgeList = newEdgeList(csrSegments->segments[i].num_edges);
            csrSegments->segments[i].edgeList->num_vertices = csrSegments->segments[i].num_vertices;
            csrSegments->segments[i].num_edges = 0;
        }

    }

    return csrSegments;


}

uint32_t csrSegmentsCalculateSegments(struct EdgeList *edgeList, uint32_t cache_size)
{
    //epfl everything graph
    uint32_t num_vertices  = edgeList->num_vertices;
    uint32_t num_Segments = (((num_vertices * 8) + cache_size - 1) / cache_size);

    // if(num_Segments > 512)
    //     num_Segments = 256;
    if(num_Segments < 4)
    {
        // cache_size = (32*1024);
        // num_Segments = (((num_vertices * 8) + (cache_size) - 1) / cache_size);
        num_Segments = 4;
    }

    return num_Segments;

}



inline uint32_t getSegmentID(uint32_t vertices, uint32_t segments, uint32_t vertex_id)
{

    uint32_t segment_size = vertices / segments;

    if (vertices % segments == 0)
    {

        return vertex_id / segment_size;
    }

    segment_size += 1;

    uint32_t split_point = vertices % segments * segment_size;

    return (vertex_id < split_point) ? vertex_id / segment_size : (vertex_id - split_point) / (segment_size - 1) + (vertices % segments);
}


void csrSegmentsPrintMessageWithtime(const char *msg, double time)
{

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", msg);
    printf(" -----------------------------------------------------\n");
    printf("| %-51f | \n", time);
    printf(" -----------------------------------------------------\n");

}