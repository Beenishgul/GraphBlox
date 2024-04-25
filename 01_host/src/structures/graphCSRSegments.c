// -----------------------------------------------------------------------------
//
//      "00_GraphBlox"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : graphCSRSegments.c
// Create : 2019-06-21 17:15:17
// Revise : 2019-09-28 15:36:13
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>

#include "timer.h"
#include "graphConfig.h"
#include "myMalloc.h"

#include "csrSegments.h"
#include "graphCSRSegments.h"
#include "edgeList.h"
#include "sortRun.h"
#include "reorder.h"




void  graphCSRSegmentsReset(struct GraphCSRSegments *graphCSRSegments)
{

    graphCSRSegmentsResetActiveSegmentsMap(graphCSRSegments->csrSegments);

}

void  graphCSRSegmentsPrint(struct GraphCSRSegments *graphCSRSegments)
{


    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Graph CSR Segments Properties");
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
    printf("| %-51s | \n", "Average Degree (D)");
    printf("| %-51u | \n", graphCSRSegments->avg_degree);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Vertices (V)");
    printf("| %-51u | \n", graphCSRSegments->csrSegments->num_vertices);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Edges (E)");
    printf("| %-51u | \n", graphCSRSegments->csrSegments->num_edges);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Segments (S)");
    printf("| %-51u | \n", graphCSRSegments->csrSegments->num_segments);
    printf(" -----------------------------------------------------\n");


    // uint32_t i;
    // for ( i = 0; i < (graphCSRSegments->csrSegments->num_segments); ++i)
    // {

    //     if(graphCSRSegments->csrSegments->segments[i].num_edges)
    //     {

    //         printf("| %-11s (%u) \n", "Segment: ", i);
    //         edgeListPrintBasic(graphCSRSegments->csrSegments->segments[i].edgeList);
    //     }

    // }


    // uint32_t i;
    // for ( i = 0; i < (graphCSRSegments->csrSegments->num_vertices); ++i)
    // {
    //         printf("v:%u --> s:%u \n",i, graphCSRSegments->csrSegments->vertex_segment_index[i]);
    //         // edgeListPrintBasic(graphCSRSegments->csrSegments->segments[i].edgeList);
    // }


}


struct GraphCSRSegments *graphCSRSegmentsNew(struct EdgeList *edgeList, struct Arguments *arguments)
{

    struct GraphCSRSegments *graphCSRSegments = (struct GraphCSRSegments *) my_malloc( sizeof(struct GraphCSRSegments));

#if WEIGHTED
    graphCSRSegments->max_weight =  edgeList->max_weight;
#endif

    graphCSRSegments->num_edges = edgeList->num_edges;
    graphCSRSegments->num_vertices = edgeList->num_vertices;
    graphCSRSegments->avg_degree = edgeList->num_edges / edgeList->num_vertices;

    graphCSRSegments->csrSegments = csrSegmentsNew(edgeList, arguments);


    return graphCSRSegments;

}

void graphCSRSegmentsFree(struct GraphCSRSegments *graphCSRSegments)
{

    if(graphCSRSegments)
    {

        if(graphCSRSegments->csrSegments)
            csrSegmentsFree(graphCSRSegments->csrSegments);

        free(graphCSRSegments);
    }

}



struct GraphCSRSegments *graphCSRSegmentsPreProcessingStep (struct Arguments *arguments)
{

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    printf("Filename : %s \n", arguments->fnameb);


    Start(timer);
    struct EdgeList *edgeList = readEdgeListsbin(arguments->fnameb, 0, arguments->symmetric, arguments->weighted);
    Stop(timer);
    // edgeListPrint(edgeList);
    graphCSRSegmentsPrintMessageWithtime("Read Edge List From File (Seconds)", Seconds(timer));

    // Start(timer);
    edgeList = sortRunAlgorithms(edgeList, arguments->sort);

    if(arguments->dflag)
    {
        Start(timer);
        edgeList = removeDulpicatesSelfLoopEdges(edgeList);
        Stop(timer);
        graphCSRPrintMessageWithtime("Removing duplicate edges (Seconds)", Seconds(timer));
    }

    if(arguments->lmode)
    {
        edgeList = reorderGraphProcess(edgeList, arguments);
        edgeList = sortRunAlgorithms(edgeList, arguments->sort);
    }

    // add another layer 2 of reordering to test how DBG affect Gorder, or Gorder affect Rabbit order ...etc
    arguments->lmode = arguments->lmode_l2;
    if(arguments->lmode)
    {
        edgeList = reorderGraphProcess(edgeList, arguments);
        edgeList = sortRunAlgorithms(edgeList, arguments->sort);
    }

    arguments->lmode = arguments->lmode_l3;
    if(arguments->lmode)
    {
        edgeList = reorderGraphProcess(edgeList, arguments);
        edgeList = sortRunAlgorithms(edgeList, arguments->sort);
    }

    if(arguments->mmode)
        edgeList = maskGraphProcess(edgeList, arguments);



    // if(arguments->mmode)
    //     edgeList = maskGraphProcess(edgeList, arguments);
    // Stop(timer);
    // graphCSRSegmentsPrintMessageWithtime("Radix Sort Edges By Source (Seconds)",Seconds(timer));

    Start(timer);
    struct GraphCSRSegments *graphCSRSegments = graphCSRSegmentsNew(edgeList, arguments);
    Stop(timer);
    graphCSRSegmentsPrintMessageWithtime("Create Graph Grid (Seconds)", Seconds(timer));


    graphCSRSegmentsPrint(graphCSRSegments);


    freeEdgeList(edgeList);
    free(timer);
    return graphCSRSegments;


}



void graphCSRSegmentsPrintMessageWithtime(const char *msg, double time)
{

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", msg);
    printf(" -----------------------------------------------------\n");
    printf("| %-51f | \n", time);
    printf(" -----------------------------------------------------\n");

}

