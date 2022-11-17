// -----------------------------------------------------------------------------
//
//      "00_GLay"
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

    graphCSRSegmentsResetActivePartitionsMap(graphCSRSegments->csrSegments);

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
    printf("| %-51s | \n", "Number of Partitions (P)");
    printf("| %-51u | \n", graphCSRSegments->csrSegments->num_partitions);
    printf(" -----------------------------------------------------\n");




    //   uint32_t i;
    //    for ( i = 0; i < ( graphCSRSegments->csrSegments->num_partitions*graphCSRSegments->csrSegments->num_partitions); ++i)
    //       {

    //       uint32_t x = i % graphCSRSegments->csrSegments->num_partitions;    // % is the "modulo operator", the remainder of i / width;
    // uint32_t y = i / graphCSRSegments->csrSegments->num_partitions;

    //      if(graphCSRSegments->csrSegments->partitions[i].num_edges){

    //       printf("| %-11s (%u,%u) \n", "Partition: ", y, x);
    //      printf("| %-11s %-40u   \n", "Edges: ", graphCSRSegments->csrSegments->partitions[i].num_edges);
    //      printf("| %-11s %-40u   \n", "Vertices: ", graphCSRSegments->csrSegments->partitions[i].num_vertices);
    //      edgeListPrint(graphCSRSegments->csrSegments->partitions[i].edgeList);
    //       }

    //       }


}


struct GraphCSRSegments *graphCSRSegmentsNew(struct EdgeList *edgeList, uint32_t cache_size)
{


    struct GraphCSRSegments *graphCSRSegments = (struct GraphCSRSegments *) my_malloc( sizeof(struct GraphCSRSegments));

#if WEIGHTED
    graphCSRSegments->max_weight =  edgeList->max_weight;
#endif

    graphCSRSegments->num_edges = edgeList->num_edges;
    graphCSRSegments->num_vertices = edgeList->num_vertices;
    graphCSRSegments->avg_degree = edgeList->num_edges / edgeList->num_vertices;

    graphCSRSegments->csrSegments = csrSegmentsNew(edgeList, cache_size);


    return graphCSRSegments;

}

void   graphCSRSegmentsFree(struct GraphCSRSegments *graphCSRSegments)
{

    if(graphCSRSegments->csrSegments)
        csrSegmentsFree(graphCSRSegments->csrSegments);

    if(graphCSRSegments)
        free(graphCSRSegments);

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
    struct GraphCSRSegments *graphCSRSegments = graphCSRSegmentsNew(edgeList, arguments->cache_size);
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

