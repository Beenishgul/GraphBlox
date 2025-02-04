// -----------------------------------------------------------------------------
//
//      "00_GraphBlox"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : graphCSR.c
// Create : 2022-06-29 12:31:24
// Revise : 2022-09-28 15:36:13
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <err.h>
#include <string.h>

#include "myMalloc.h"
#include "timer.h"
#include "graphConfig.h"

#include "edgeList.h"
#include "sortRun.h"
#include "vertex.h"

#include "graphCSR.h"
#include "reorder.h"

//edgelist prerpcessing
// #include "countsort.h"
// #include "radixsort.h"


void graphCSRFree (struct GraphCSR *graphCSR)
{
    if(graphCSR)
    {
        if(graphCSR->vertices)
            freeVertexArray(graphCSR->vertices);
        if(graphCSR->sorted_edges_array)
            freeEdgeList(graphCSR->sorted_edges_array);
#if DIRECTED
        if(graphCSR->inverse_vertices)
            freeVertexArray(graphCSR->inverse_vertices);
        if(graphCSR->inverse_sorted_edges_array)
            freeEdgeList(graphCSR->inverse_sorted_edges_array);
#endif
        free(graphCSR);
    }

}

void graphCSRPrint(struct GraphCSR *graphCSR)
{


    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "GraphCSR Properties");
    printf(" -----------------------------------------------------\n");
#if WEIGHTED
    printf("| %-51s | \n", "WEIGHTED");
    printf("| %-51s | \n", "MAX WEIGHT");
    printf("| %-51f | \n", graphCSR->max_weight);
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
    printf("| %-51u | \n", graphCSR->avg_degree);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Vertices (V)");
    printf("| %-51u | \n", graphCSR->num_vertices);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Edges (E)");
    printf("| %-51u | \n", graphCSR->num_edges);
    printf(" -----------------------------------------------------\n");



    vertexArrayMaxOutdegree(graphCSR->vertices, graphCSR->num_vertices);
#if DIRECTED
    vertexArrayMaxInDegree(graphCSR->inverse_vertices, graphCSR->num_vertices);
#endif

}


struct GraphCSR *graphCSRNew(uint32_t V, uint32_t E, uint8_t inverse)
{

    struct GraphCSR *graphCSR = (struct GraphCSR *) my_malloc( sizeof(struct GraphCSR));
    graphCSR->num_vertices = V;
    graphCSR->num_edges = E;
    graphCSR->avg_degree = E / V;
    graphCSR->sorted_edges_array = NULL; // sorted edge array
    graphCSR->vertices = NULL;

#if DIRECTED
    graphCSR->inverse_vertices = NULL;
    graphCSR->inverse_sorted_edges_array = NULL; // sorted edge array
#endif

#if WEIGHTED
    graphCSR->max_weight = 0;
#endif

    graphCSR->vertices = newVertexArray(V);

#if DIRECTED
    if (inverse)
    {
        graphCSR->inverse_vertices = newVertexArray(V);
    }
#endif

    return graphCSR;
}


struct GraphCSR *graphCSRAssignEdgeList (struct GraphCSR *graphCSR, struct EdgeList *edgeList, uint8_t inverse)
{


#if DIRECTED

    if(inverse)
        graphCSR->inverse_sorted_edges_array = edgeList;
    else
        graphCSR->sorted_edges_array = edgeList;

#else

    graphCSR->sorted_edges_array = edgeList;

#endif

#if WEIGHTED
    graphCSR->max_weight =  edgeList->max_weight;
#endif

    // return mapVerticesWithInOutDegree (graphCSR, inverse);
    return mapVerticesWithInOutDegree_base (graphCSR, inverse);
}

struct GraphCSR *graphCSRPreProcessingStepFromEdgelist (struct Arguments *arguments, struct EdgeList *edgeList)
{

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    Start(timer);
    struct EdgeList *edgeList_internal = readEdgeListsMem(edgeList, 0, 0, arguments->weighted); // read edglist from memory
    Stop(timer);
    graphCSRPrintMessageWithtime("Read Edge List From Memory (Seconds)", Seconds(timer));

    edgeList_internal = sortRunAlgorithms(edgeList_internal, arguments->sort);

    if(arguments->dflag)
    {
        Start(timer);
        edgeList_internal = removeDulpicatesSelfLoopEdges(edgeList_internal);
        Stop(timer);
        graphCSRPrintMessageWithtime("Removing duplicate edges (Seconds)", Seconds(timer));
    }

    if(arguments->lmode)
    {
        edgeList_internal = reorderGraphProcess(edgeList_internal, arguments);
        edgeList_internal = sortRunAlgorithms(edgeList_internal, arguments->sort);
    }

    // add another layer 2 of reordering to test how DBG affect Gorder, or Gorder affect Rabbit order ...etc
    arguments->lmode = arguments->lmode_l2;
    if(arguments->lmode)
    {
        edgeList_internal = reorderGraphProcess(edgeList_internal, arguments);
        edgeList_internal = sortRunAlgorithms(edgeList_internal, arguments->sort);
    }

    arguments->lmode = arguments->lmode_l3;
    if(arguments->lmode)
    {
        edgeList_internal = reorderGraphProcess(edgeList_internal, arguments);
        edgeList_internal = sortRunAlgorithms(edgeList_internal, arguments->sort);
    }

    if(arguments->mmode)
        edgeList_internal = maskGraphProcess(edgeList_internal, arguments);

#if DIRECTED
    struct GraphCSR *graphCSR = graphCSRNew(edgeList_internal->num_vertices, edgeList_internal->num_edges, 1);
#else
    struct GraphCSR *graphCSR = graphCSRNew(edgeList_internal->num_vertices, edgeList_internal->num_edges, 0);
#endif

    // edgeListPrint(edgeList);
    Start(timer);
    graphCSR = graphCSRAssignEdgeList (graphCSR, edgeList_internal, 0);
    Stop(timer);

    graphCSRPrintMessageWithtime("Mappign Vertices to CSR (Seconds)", Seconds(timer));

#if DIRECTED

    Start(timer);
    struct EdgeList *inverse_edgeList = readEdgeListsMem(edgeList_internal, 1, 0, 0); // read edglist from memory since we pre loaded it
    Stop(timer);

    graphCSRPrintMessageWithtime("Read Inverse Edge List From Memory (Seconds)", Seconds(timer));

    inverse_edgeList = sortRunAlgorithms(inverse_edgeList, arguments->sort);

    Start(timer);
    graphCSR = graphCSRAssignEdgeList (graphCSR, inverse_edgeList, 1);
    Stop(timer);
    graphCSRPrintMessageWithtime("Process In/Out degrees of Inverse Nodes (Seconds)", Seconds(timer));

#endif


    graphCSRPrint(graphCSR);



    free(timer);

    return graphCSR;


}


struct GraphCSR *graphCSRPreProcessingStep (struct Arguments *arguments)
{

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    Start(timer);
    struct EdgeList *edgeList = readEdgeListsbin(arguments->fnameb, 0, arguments->symmetric, arguments->weighted); // read edglist from binary file
    Stop(timer);
    // edgeListPrint(edgeList);
    graphCSRPrintMessageWithtime("Read Edge List From File (Seconds)", Seconds(timer));

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

#if DIRECTED
    struct GraphCSR *graphCSR = graphCSRNew(edgeList->num_vertices, edgeList->num_edges, 1);
#else
    struct GraphCSR *graphCSR = graphCSRNew(edgeList->num_vertices, edgeList->num_edges, 0);
#endif

    // edgeListPrint(edgeList);
    Start(timer);
    graphCSR = graphCSRAssignEdgeList (graphCSR, edgeList, 0);
    Stop(timer);

    graphCSRPrintMessageWithtime("Mappign Vertices to CSR (Seconds)", Seconds(timer));

#if DIRECTED

    Start(timer);
    struct EdgeList *inverse_edgeList = readEdgeListsMem(edgeList, 1, 0, 0); // read edglist from memory since we pre loaded it
    Stop(timer);

    graphCSRPrintMessageWithtime("Read Inverse Edge List From Memory (Seconds)", Seconds(timer));

    inverse_edgeList = sortRunAlgorithms(inverse_edgeList, arguments->sort);

    Start(timer);
    graphCSR = graphCSRAssignEdgeList (graphCSR, inverse_edgeList, 1);
    Stop(timer);
    graphCSRPrintMessageWithtime("Process In/Out degrees of Inverse Nodes (Seconds)", Seconds(timer));

#endif


    graphCSRPrint(graphCSR);
    // edgeListPrint(graphCSR->sorted_edges_array);

    free(timer);

    return graphCSR;


}

struct GraphCSR *graphCSRPreProcessingStepDualOrder (struct Arguments *arguments)
{

    struct Timer *timer = (struct Timer *) malloc(sizeof(struct Timer));

    Start(timer);
    struct EdgeList *edgeList = readEdgeListsbin(arguments->fnameb, 0, arguments->symmetric, arguments->weighted); // read edglist from binary file
    Stop(timer);
    // edgeListPrint(edgeList);
    graphCSRPrintMessageWithtime("Read Edge List From File (Seconds)", Seconds(timer));

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


#if DIRECTED
    struct GraphCSR *graphCSR = graphCSRNew(edgeList->num_vertices, edgeList->num_edges, 1);
#else
    struct GraphCSR *graphCSR = graphCSRNew(edgeList->num_vertices, edgeList->num_edges, 0);
#endif

#if DIRECTED
    Start(timer);
    struct EdgeList *inverse_edgeList = readEdgeListsMem(edgeList, 1, 0, 0); // read edglist from memory since we pre loaded it
    Stop(timer);

    graphCSRPrintMessageWithtime("Read Inverse Edge List From Memory (Seconds)", Seconds(timer));

    inverse_edgeList = sortRunAlgorithms(inverse_edgeList, arguments->sort);

    // add another layer 2 of reordering to test how DBG affect Gorder, or Gorder affect Rabbit order ...etc
    arguments->lmode = arguments->lmode_l2;
    if(arguments->lmode)
    {
        inverse_edgeList = reorderGraphProcess(inverse_edgeList, arguments);
        inverse_edgeList = sortRunAlgorithms(inverse_edgeList, arguments->sort);
    }
    // edgeListPrint(inverse_edgeList);

    Start(timer);
    graphCSR = graphCSRAssignEdgeList (graphCSR, inverse_edgeList, 1);
    Stop(timer);
    graphCSRPrintMessageWithtime("Process In/Out degrees of Inverse Nodes (Seconds)", Seconds(timer));
#endif


    // add another layer 2 of reordering to test how DBG affect Gorder, or Gorder affect Rabbit order ...etc
    arguments->lmode = arguments->lmode_l2;
    if(arguments->lmode)
    {
        edgeList = reorderGraphProcess(edgeList, arguments);
        edgeList = sortRunAlgorithms(edgeList, arguments->sort);
    }

    // edgeListPrint(edgeList);
    Start(timer);
    graphCSR = graphCSRAssignEdgeList (graphCSR, edgeList, 0);
    graphCSRVertexLabelRemappingDualOrder (graphCSR);
    Stop(timer);

    graphCSRPrintMessageWithtime("Mappign Vertices to CSR (Seconds)", Seconds(timer));

    // edgeListPrint(edgeList);

    graphCSRPrint(graphCSR);


    free(timer);

    return graphCSR;


}

void graphCSRVertexLabelRemappingDualOrder (struct GraphCSR *graphCSR)
{

    uint32_t *label_array_el = NULL;
    uint32_t *label_array_iel = NULL;
    uint32_t *inverse_label_array_el = NULL;
    uint32_t num_vertices = graphCSR->num_vertices;
    uint32_t v;

#if DIRECTED
    uint32_t *inverse_label_array_iel = NULL;
    inverse_label_array_iel = graphCSR->inverse_sorted_edges_array->inverse_label_array;
    label_array_iel = graphCSR->inverse_sorted_edges_array->label_array;
#else
    label_array_iel = graphCSR->sorted_edges_array->label_array;
#endif

    inverse_label_array_el = graphCSR->sorted_edges_array->inverse_label_array;
    label_array_el = graphCSR->sorted_edges_array->label_array;

    #pragma omp parallel for
    for (v = 0; v < num_vertices; ++v)
    {
        uint32_t u = label_array_el[v];
        uint32_t t = label_array_iel[v];

        inverse_label_array_el[u] = t;
    }

#if DIRECTED
    #pragma omp parallel for
    for (v = 0; v < num_vertices; ++v)
    {
        uint32_t u = label_array_el[v];
        uint32_t t = label_array_iel[v];

        inverse_label_array_iel[t] = u;
    }
#endif

}

void writeToBinFileGraphCSR (const char *fname, struct GraphCSR *graphCSR)
{


    FILE  *pBinary;
    uint32_t vertex_id;

    char *fname_txt = (char *) malloc((strlen(fname) + 10) * sizeof(char));
    char *fname_bin = (char *) malloc((strlen(fname) + 10) * sizeof(char));

    fname_txt = strcpy (fname_txt, fname);
    fname_bin = strcat (fname_txt, ".csr");

    pBinary = fopen(fname_bin, "wb");

    if (pBinary == NULL)
    {
        err(1, "open: %s", fname_bin);
        return ;
    }

    fwrite(&(graphCSR->num_edges), sizeof (graphCSR->num_edges), 1, pBinary);
    fwrite(&(graphCSR->num_vertices), sizeof (graphCSR->num_vertices), 1, pBinary);
#if WEIGHTED
    fwrite(&(graphCSR->max_weight), sizeof (graphCSR->max_weight), 1, pBinary);
#endif

    for(vertex_id = 0; vertex_id < graphCSR->num_vertices ; vertex_id++)
    {

        fwrite(&(graphCSR->vertices->out_degree[vertex_id]), sizeof (graphCSR->vertices->out_degree[vertex_id]), 1, pBinary);
        fwrite(&(graphCSR->vertices->in_degree[vertex_id]), sizeof (graphCSR->vertices->in_degree[vertex_id]), 1, pBinary);
        fwrite(&(graphCSR->vertices->edges_idx[vertex_id]), sizeof (graphCSR->vertices->edges_idx[vertex_id]), 1, pBinary);

#if DIRECTED
        if(graphCSR->inverse_vertices)
        {
            fwrite(&(graphCSR->inverse_vertices->out_degree[vertex_id]), sizeof (graphCSR->inverse_vertices->out_degree[vertex_id]), 1, pBinary);
            fwrite(&(graphCSR->inverse_vertices->in_degree[vertex_id]), sizeof (graphCSR->inverse_vertices->in_degree[vertex_id]), 1, pBinary);
            fwrite(&(graphCSR->inverse_vertices->edges_idx[vertex_id]), sizeof (graphCSR->inverse_vertices->edges_idx[vertex_id]), 1, pBinary);
        }
#endif
    }

    for(vertex_id = 0; vertex_id < graphCSR->num_edges ; vertex_id++)
    {

        fwrite(&(graphCSR->sorted_edges_array->edges_array_src[vertex_id]), sizeof (graphCSR->sorted_edges_array->edges_array_src[vertex_id]), 1, pBinary);
        fwrite(&(graphCSR->sorted_edges_array->edges_array_dest[vertex_id]), sizeof (graphCSR->sorted_edges_array->edges_array_dest[vertex_id]), 1, pBinary);

#if WEIGHTED
        fwrite(&(graphCSR->sorted_edges_array->edges_array_weight[vertex_id]), sizeof (graphCSR->sorted_edges_array->edges_array_weight[vertex_id]), 1, pBinary);
#endif

#if DIRECTED
        if(graphCSR->inverse_vertices)
        {
            fwrite(&(graphCSR->inverse_sorted_edges_array->edges_array_src[vertex_id]), sizeof (graphCSR->inverse_sorted_edges_array->edges_array_src[vertex_id]), 1, pBinary);
            fwrite(&(graphCSR->inverse_sorted_edges_array->edges_array_dest[vertex_id]), sizeof (graphCSR->inverse_sorted_edges_array->edges_array_dest[vertex_id]), 1, pBinary);
#if WEIGHTED
            fwrite(&(graphCSR->inverse_sorted_edges_array->edges_array_weight[vertex_id]), sizeof (graphCSR->inverse_sorted_edges_array->edges_array_weight[vertex_id]), 1, pBinary);
#endif
        }
#endif
    }

    fclose(pBinary);


}

void writetoTextFilesGraphCSR (const char *fname, struct GraphCSR *graphCSR)
{

    uint32_t vertex_id;

    FILE *fptr_out_degree;
    FILE *fptr_in_degree;
    FILE *fptr_edges_idx;
    FILE *fptr_edges_array_src;
    FILE *fptr_edges_array_dest;
#if WEIGHTED
    FILE *fptr_edges_array_weight;
#endif

    char *fname_txt_out_degree = (char *) malloc((strlen(fname) + 20) * sizeof(char));
    char *fname_bin_out_degree = (char *) malloc((strlen(fname) + 20) * sizeof(char));

    fname_txt_out_degree = strcpy (fname_txt_out_degree, fname);
    fname_bin_out_degree = strcat (fname_txt_out_degree, ".out_degree");

    char *fname_txt_in_degree = (char *) malloc((strlen(fname) + 20) * sizeof(char));
    char *fname_bin_in_degree = (char *) malloc((strlen(fname) + 20) * sizeof(char));

    fname_txt_in_degree = strcpy (fname_txt_in_degree, fname);
    fname_bin_in_degree = strcat (fname_txt_in_degree, ".in_degree");

    char *fname_txt_edges_idx = (char *) malloc((strlen(fname) + 20) * sizeof(char));
    char *fname_bin_edges_idx = (char *) malloc((strlen(fname) + 20) * sizeof(char));

    fname_txt_edges_idx = strcpy (fname_txt_edges_idx, fname);
    fname_bin_edges_idx = strcat (fname_txt_edges_idx, ".edges_idx");

    char *fname_txt_edges_array_src = (char *) malloc((strlen(fname) + 20) * sizeof(char));
    char *fname_bin_edges_array_src = (char *) malloc((strlen(fname) + 20) * sizeof(char));

    fname_txt_edges_array_src = strcpy (fname_txt_edges_array_src, fname);
    fname_bin_edges_array_src = strcat (fname_txt_edges_array_src, ".edges_array_src");

    char *fname_txt_edges_array_dest = (char *) malloc((strlen(fname) + 20) * sizeof(char));
    char *fname_bin_edges_array_dest = (char *) malloc((strlen(fname) + 20) * sizeof(char));

    fname_txt_edges_array_dest = strcpy (fname_txt_edges_array_dest, fname);
    fname_bin_edges_array_dest = strcat (fname_txt_edges_array_dest, ".edges_array_dest");

#if WEIGHTED
    char *fname_txt_edges_array_weight = (char *) malloc((strlen(fname) + 20) * sizeof(char));
    char *fname_bin_edges_array_weight = (char *) malloc((strlen(fname) + 20) * sizeof(char));

    fname_txt_edges_array_weight = strcpy (fname_txt_edges_array_weight, fname);
    fname_bin_edges_array_weight = strcat (fname_txt_edges_array_weight, ".edges_array_weight");
#endif

    fptr_out_degree = fopen(fname_bin_out_degree, "w");
    fptr_in_degree = fopen(fname_bin_in_degree, "w");
    fptr_edges_idx = fopen(fname_bin_edges_idx, "w");
    fptr_edges_array_src = fopen(fname_bin_edges_array_src, "w");
    fptr_edges_array_dest = fopen(fname_bin_edges_array_dest, "w");
#if WEIGHTED
    fptr_edges_array_weight = fopen(fname_bin_edges_array_weight, "w");
#endif

    fprintf(fptr_out_degree, "%u\n", graphCSR->num_vertices);
    for(vertex_id = 0; vertex_id < graphCSR->num_vertices ; vertex_id++)
    {
        fprintf(fptr_out_degree, "%u\n", graphCSR->vertices->out_degree[vertex_id]);
        fprintf(fptr_in_degree, "%u\n", graphCSR->vertices->in_degree[vertex_id]);
        fprintf(fptr_edges_idx, "%u\n", graphCSR->vertices->edges_idx[vertex_id]);
    }

    fprintf(fptr_edges_array_src, "%u\n", graphCSR->num_edges);
    for(vertex_id = 0; vertex_id < graphCSR->num_edges ; vertex_id++)
    {
        fprintf(fptr_edges_array_src, "%u\n", graphCSR->sorted_edges_array->edges_array_src[vertex_id]);
        fprintf(fptr_edges_array_dest, "%u\n", graphCSR->sorted_edges_array->edges_array_dest[vertex_id]);
#if WEIGHTED
        fprintf(fptr_edges_array_weight, "%f\n", graphCSR->sorted_edges_array->edges_array_weight[vertex_id]);
#endif
    }

    fclose(fptr_out_degree);
    fclose(fptr_in_degree);
    fclose(fptr_edges_idx);
    fclose(fptr_edges_array_src);
    fclose(fptr_edges_array_dest);
#if WEIGHTED
    fclose(fptr_edges_array_weight);
#endif


    free(fname_txt_out_degree);
    // free(fname_bin_out_degree);
    free(fname_txt_in_degree);
    //     free(fname_bin_in_degree);
    free(fname_txt_edges_idx);
    //     free(fname_bin_edges_idx);
    free(fname_txt_edges_array_src);
    //     free(fname_bin_edges_array_src);
    free(fname_txt_edges_array_dest);
    //     free(fname_bin_edges_array_dest);

#if WEIGHTED
    free(fname_txt_edges_array_weight);
    //     free(fname_bin_edges_array_weight);
#endif


}


struct GraphCSR *readFromBinFileGraphCSR (const char *fname)
{

    FILE  *pBinary;
    uint32_t vertex_id;
    uint32_t num_vertices;
    uint32_t num_edges;
#if WEIGHTED
    float max_weight;
#endif
    size_t ret;

    pBinary = fopen(fname, "rb");
    if (pBinary == NULL)
    {
        err(1, "open: %s", fname);
        return NULL;
    }


    ret = fread(&num_edges, sizeof(num_edges), 1, pBinary);
    ret = fread(&num_vertices, sizeof(num_vertices), 1, pBinary);
#if WEIGHTED
    ret = fread(&max_weight, sizeof(max_weight), 1, pBinary);
#endif


#if DIRECTED
    struct GraphCSR *graphCSR = graphCSRNew(num_vertices, num_edges, 1);
#else
    struct GraphCSR *graphCSR = graphCSRNew(num_vertices, num_edges, 0);
#endif


#if WEIGHTED
    graphCSR->max_weight = max_weight;
#endif

    struct EdgeList *sorted_edges_array = newEdgeList(num_edges);
    sorted_edges_array->num_vertices = num_vertices;
#if WEIGHTED
    sorted_edges_array->max_weight = max_weight;
#endif

    graphCSR->sorted_edges_array = sorted_edges_array;

#if DIRECTED
    struct EdgeList *inverse_sorted_edges_array = newEdgeList(num_edges);
    inverse_sorted_edges_array->num_vertices = num_vertices;
#if WEIGHTED
    inverse_sorted_edges_array->max_weight = max_weight;
#endif
    graphCSR->inverse_sorted_edges_array = inverse_sorted_edges_array;
#endif

    for(vertex_id = 0; vertex_id < graphCSR->num_vertices ; vertex_id++)
    {

        ret = fread(&(graphCSR->vertices->out_degree[vertex_id]), sizeof (graphCSR->vertices->out_degree[vertex_id]), 1, pBinary);
        ret = fread(&(graphCSR->vertices->in_degree[vertex_id]), sizeof (graphCSR->vertices->in_degree[vertex_id]), 1, pBinary);
        ret = fread(&(graphCSR->vertices->edges_idx[vertex_id]), sizeof (graphCSR->vertices->edges_idx[vertex_id]), 1, pBinary);

#if DIRECTED
        if(graphCSR->inverse_vertices)
        {
            ret = fread(&(graphCSR->inverse_vertices->out_degree[vertex_id]), sizeof (graphCSR->inverse_vertices->out_degree[vertex_id]), 1, pBinary);
            ret = fread(&(graphCSR->inverse_vertices->in_degree[vertex_id]), sizeof (graphCSR->inverse_vertices->in_degree[vertex_id]), 1, pBinary);
            ret = fread(&(graphCSR->inverse_vertices->edges_idx[vertex_id]), sizeof (graphCSR->inverse_vertices->edges_idx[vertex_id]), 1, pBinary);
        }
#endif
    }

    for(vertex_id = 0; vertex_id < graphCSR->num_edges ; vertex_id++)
    {

        ret = fread(&(graphCSR->sorted_edges_array->edges_array_src[vertex_id]), sizeof (graphCSR->sorted_edges_array->edges_array_src[vertex_id]), 1, pBinary);
        ret = fread(&(graphCSR->sorted_edges_array->edges_array_dest[vertex_id]), sizeof (graphCSR->sorted_edges_array->edges_array_dest[vertex_id]), 1, pBinary);

#if WEIGHTED
        ret = fread(&(graphCSR->sorted_edges_array->edges_array_weight[vertex_id]), sizeof (graphCSR->sorted_edges_array->edges_array_weight[vertex_id]), 1, pBinary);
#endif

#if DIRECTED
        if(graphCSR->inverse_vertices)
        {
            ret = fread(&(graphCSR->inverse_sorted_edges_array->edges_array_src[vertex_id]), sizeof (graphCSR->inverse_sorted_edges_array->edges_array_src[vertex_id]), 1, pBinary);
            ret = fread(&(graphCSR->inverse_sorted_edges_array->edges_array_dest[vertex_id]), sizeof (graphCSR->inverse_sorted_edges_array->edges_array_dest[vertex_id]), 1, pBinary);
#if WEIGHTED
            ret = fread(&(graphCSR->inverse_sorted_edges_array->edges_array_weight[vertex_id]), sizeof (graphCSR->inverse_sorted_edges_array->edges_array_weight[vertex_id]), 1, pBinary);
#endif
        }
#endif
    }




    if(ret)
    {
        graphCSRPrint(graphCSR);
    }

    fclose(pBinary);

    return graphCSR;

}

void graphCSRPrintMessageWithtime(const char *msg, double time)
{

    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", msg);
    printf(" -----------------------------------------------------\n");
    printf("| %-51f | \n", time);
    printf(" -----------------------------------------------------\n");

}
