// -----------------------------------------------------------------------------
//
//      "00_GraphBlox"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : edgeList.c
// Create : 2022-06-29 12:31:24
// Revise : 2022-09-28 15:36:13
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>
#include <err.h>
#include <string.h>
#include <stdint.h>
#include <omp.h>
#include <math.h>

#include "reorder.h"
#include "mt19937.h"
#include "myMalloc.h"
#include "graphConfig.h"
#include "edgeList.h"



uint32_t maxTwoIntegers(uint32_t num1, uint32_t num2)
{

    if(num1 >= num2)
        return num1;
    else
        return num2;

}

float maxTwoFloats(float num1, float num2)
{

    if(num1 >= num2)
        return num1;
    else
        return num2;

}


void writeEdgeListToTXTFile(struct EdgeList *edgeList, const char *fname)
{

    FILE *fp;
    uint32_t i;


    char *fname_txt = (char *) malloc((strlen(fname) + 10) * sizeof(char));

    fname_txt = strcpy (fname_txt, fname);
    fname_txt = strcat (fname_txt, ".txt");

    fp = fopen (fname_txt, "w");


    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Average Degree");
    printf("| %-51u | \n", edgeList->avg_degree);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Vertices (V)");
    printf("| %-51u | \n", edgeList->num_vertices);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Edges (E)");
    printf("| %-51u | \n", edgeList->num_edges);
    printf(" -----------------------------------------------------\n");


    for(i = 0; i < edgeList->num_edges; i++)
    {
#if WEIGHTED
        fprintf(fp, "%u %u %f\n", edgeList->edges_array_src[i], edgeList->edges_array_dest[i], edgeList->edges_array_weight[i]);
#else
        fprintf(fp, "%u %u\n", edgeList->edges_array_src[i], edgeList->edges_array_dest[i]);
#endif
    }

    fclose (fp);
}

// read edge file to edge_array in memory
struct EdgeList *newEdgeList( uint32_t num_edges)
{


    struct EdgeList *newEdgeList = (struct EdgeList *) my_malloc(sizeof(struct EdgeList));
    newEdgeList->edges_array_src = (uint32_t *) my_malloc(num_edges * sizeof(uint32_t));
    newEdgeList->edges_array_dest = (uint32_t *) my_malloc(num_edges * sizeof(uint32_t));
    newEdgeList->edges_array_weight = (float *) my_malloc(num_edges * sizeof(float));

    uint32_t i;
    #pragma omp parallel for
    for(i = 0; i < num_edges; i++)
    {
        newEdgeList->edges_array_dest[i] = 0;
        newEdgeList->edges_array_src[i] = 0;
        newEdgeList->edges_array_weight[i] = 1;
    }

    newEdgeList->mask_array = NULL;
    newEdgeList->label_array = NULL;
    newEdgeList->inverse_label_array = NULL;
    newEdgeList->num_edges = num_edges;
    newEdgeList->num_vertices = 0;
    newEdgeList->avg_degree = 0;
    // newEdgeList->edges_array = newEdgeList(num_edges);

    newEdgeList->max_weight = 1;

    return newEdgeList;

}

// read edge file to edge_array in memory
struct EdgeList *newEdgeListIncremental( uint32_t num_edges)
{


    struct EdgeList *newEdgeList = (struct EdgeList *) my_malloc(sizeof(struct EdgeList));
    newEdgeList->edges_array_src = (uint32_t *) my_malloc(num_edges * sizeof(uint32_t));
    newEdgeList->edges_array_dest = (uint32_t *) my_malloc(num_edges * sizeof(uint32_t));
    newEdgeList->edges_array_weight = (float *) my_malloc(num_edges * sizeof(float));


    uint32_t i;
    #pragma omp parallel for
    for(i = 0; i < num_edges; i++)
    {
        newEdgeList->edges_array_dest[i] = 0;
        newEdgeList->edges_array_src[i] = 0;
        newEdgeList->edges_array_weight[i] = 1;

    }

    newEdgeList->mask_array = NULL;
    newEdgeList->label_array = NULL;
    newEdgeList->inverse_label_array = NULL;
    newEdgeList->num_edges = 0;
    newEdgeList->num_vertices = 0;
    newEdgeList->avg_degree = 0;
    // newEdgeList->edges_array = newEdgeList(num_edges);
    newEdgeList->max_weight = 0;

    return newEdgeList;

}


// read edge file to edge_array in memory
struct EdgeList *deepCopyEdgeList( struct EdgeList *edgeListFrom, struct EdgeList *edgeListTo)
{

    if(edgeListFrom->num_edges > edgeListTo->num_edges)
        return NULL;

    edgeListTo->num_edges = edgeListTo->num_edges;
    edgeListTo->num_vertices = edgeListTo->num_vertices;
    edgeListTo->avg_degree = edgeListTo->avg_degree;

    uint32_t i;
    #pragma omp parallel for
    for(i = 0; i < edgeListFrom->num_edges; i++)
    {
        edgeListTo->edges_array_dest[i] = edgeListFrom->edges_array_dest[i];
        edgeListTo->edges_array_src[i] = edgeListFrom->edges_array_src[i];
        edgeListTo->edges_array_weight[i] = edgeListFrom->edges_array_weight[i];
    }

    edgeListTo->mask_array = NULL;
    edgeListTo->label_array = NULL;
    edgeListTo->inverse_label_array = NULL;

    edgeListTo->max_weight = edgeListFrom->max_weight;

    return edgeListTo;

}

// read edge file to edge_array in memory
struct EdgeList *resizeEdgeList( struct EdgeList *edgeListFrom, uint32_t num_edges)
{

    if(edgeListFrom->num_edges > num_edges)
        return NULL;

    struct EdgeList *edgeListTo = newEdgeList(num_edges);

    edgeListTo->num_edges = edgeListFrom->num_edges;
    edgeListTo = deepCopyEdgeList(edgeListFrom, edgeListTo);

    freeEdgeList(edgeListFrom);

    return edgeListTo;

}

void insertEdgeInEdgeList( struct EdgeList *edgeList,  uint32_t src,  uint32_t dest,  float weight)
{
    uint32_t num_vertices = edgeList->num_vertices;

    float max_weight = edgeList->max_weight;

    edgeList->edges_array_dest[edgeList->num_edges] = dest;
    edgeList->edges_array_src[edgeList->num_edges] = src;
    edgeList->edges_array_weight[edgeList->num_edges] = weight;

    num_vertices = maxTwoIntegers(num_vertices, maxTwoIntegers(src, dest));
    max_weight = maxTwoFloats(max_weight, weight);

    edgeList->num_vertices = num_vertices;
    edgeList->max_weight = max_weight;

    edgeList->num_edges++;
}

struct EdgeList *finalizeInsertEdgeInEdgeList( struct EdgeList *edgeList)
{

    uint32_t i;
    edgeList->mask_array = (uint32_t *) my_malloc((edgeList->num_vertices + 1) * sizeof(uint32_t));
    edgeList->label_array = (uint32_t *) my_malloc((edgeList->num_vertices + 1) * sizeof(uint32_t));
    edgeList->inverse_label_array = (uint32_t *) my_malloc((edgeList->num_vertices + 1) * sizeof(uint32_t));
    edgeList->num_vertices++;
    edgeList->avg_degree = edgeList->num_edges / edgeList->num_vertices;

    #pragma omp parallel for
    for (i = 0; i < (edgeList->num_vertices); ++i)
    {
        edgeList->mask_array[i] = 0;
        edgeList->label_array[i] =  i;
        edgeList->inverse_label_array[i] =  i;
    }


    return edgeList;
}


struct EdgeList *removeDulpicatesSelfLoopEdges( struct EdgeList *edgeList)
{

    struct EdgeList *tempEdgeList = newEdgeList(edgeList->num_edges);
    uint32_t tempSrc = 0;
    uint32_t tempDest = 0;
    uint32_t tempWeight = 0;

    uint32_t j = 0;
    uint32_t i = 0;

    do
    {
        tempSrc = edgeList->edges_array_src[i];
        tempDest = edgeList->edges_array_dest[i];
        tempWeight = edgeList->edges_array_weight[i];

        i++;
    }
    while(tempSrc == tempDest);

    tempEdgeList->edges_array_src[j] = tempSrc;
    tempEdgeList->edges_array_dest[j] = tempDest;
    tempEdgeList->edges_array_weight[j] = tempWeight;

    j++;

    for(; i < tempEdgeList->num_edges; i++)
    {
        tempSrc = edgeList->edges_array_src[i];
        tempDest = edgeList->edges_array_dest[i];
        tempWeight = edgeList->edges_array_weight[i];

        if(tempSrc != tempDest)
        {
            if(tempEdgeList->edges_array_src[j - 1] != tempSrc || tempEdgeList->edges_array_dest[j - 1] != tempDest )
            {
                tempEdgeList->edges_array_src[j] = tempSrc;
                tempEdgeList->edges_array_dest[j] = tempDest;
                tempEdgeList->edges_array_weight[j] = tempWeight;

                j++;
            }
        }
    }

    tempEdgeList->num_edges = j;
    tempEdgeList->num_vertices = edgeList->num_vertices;
    tempEdgeList->max_weight = edgeList->max_weight;

    tempEdgeList->avg_degree = tempEdgeList->num_edges / tempEdgeList->num_vertices;

    tempEdgeList->mask_array = (uint32_t *) my_malloc((tempEdgeList->num_vertices + 1) * sizeof(uint32_t));
    tempEdgeList->label_array = (uint32_t *) my_malloc((tempEdgeList->num_vertices + 1) * sizeof(uint32_t));
    tempEdgeList->inverse_label_array = (uint32_t *) my_malloc((tempEdgeList->num_vertices + 1) * sizeof(uint32_t));

    #pragma omp parallel for
    for (i = 0; i < (edgeList->num_vertices); ++i)
    {
        tempEdgeList->mask_array[i] = edgeList->mask_array[i];
        tempEdgeList->label_array[i] =  edgeList->label_array[i];
        tempEdgeList->inverse_label_array[i] =  edgeList->inverse_label_array[i];
    }

    freeEdgeList(edgeList);
    return tempEdgeList;
}

void freeEdgeList( struct EdgeList *edgeList)
{

    if(edgeList)
    {
        if(edgeList->num_edges)
        {
            // freeEdgeArray(edgeList->edges_array);
            if(edgeList->edges_array_src)
                free(edgeList->edges_array_src);
            if(edgeList->edges_array_dest)
                free(edgeList->edges_array_dest);
            if(edgeList->mask_array)
                free(edgeList->mask_array);
            if(edgeList->label_array)
                free(edgeList->label_array);
            if(edgeList->inverse_label_array)
                free(edgeList->inverse_label_array);
            if(edgeList->edges_array_weight)
                free(edgeList->edges_array_weight);
        }

        free(edgeList);
    }


}


char *readEdgeListstxt(const char *fname, uint32_t weighted)
{

    FILE *pText, *pBinary;
    uint32_t size = 0;
    int32_t i = 0;
    uint32_t src = 0, dest = 0;
    float weight = 1.0;



    char *fname_txt = (char *) malloc((strlen(fname) + 10) * sizeof(char));
    char *fname_bin = (char *) malloc((strlen(fname) + 10) * sizeof(char));

    fname_txt = strcpy (fname_txt, fname);

#if WEIGHTED
    fname_bin = strcat (fname_txt, ".wbin");
    mt19937state *mt19937var = (mt19937state *) my_malloc(sizeof(mt19937state));
    initializeMersenneState (mt19937var, 27491095);
#else
    fname_bin = strcat (fname_txt, ".bin");
#endif



    // printf("Filename : %s \n",fname);
    // printf("Filename : %s \n",fname_bin);


    pText = fopen(fname, "r");
    pBinary = fopen(fname_bin, "wb");



    if (pText == NULL)
    {
        err(1, "open: %s", fname);
        return NULL;
    }
    if (pBinary == NULL)
    {
        err(1, "open: %s", fname_bin);
        return NULL;
    }

    while (1)
    {

        // if(size > 48){
#if WEIGHTED
        if(weighted)
        {
            i = fscanf(pText, "%u\t%u\t%f\n", &src, &dest, &weight);
        }
        else
        {
            i = fscanf(pText, "%u\t%u\n", &src, &dest);
            weight = 1.0;
        }
#else
        if(weighted)
        {
            i = fscanf(pText, "%u\t%u\t%f\n", &src, &dest, &weight);
        }
        else
        {
            i = fscanf(pText, "%u\t%u\n", &src, &dest);
        }
#endif

        if( i == EOF )
            break;


        fwrite(&src, sizeof (src), 1, pBinary);
        fwrite(&dest, sizeof (dest), 1, pBinary);

#if WEIGHTED
        if(weighted)
        {
            fwrite(&weight, sizeof (weight), 1, pBinary);
        }
#endif
        size++;
    }


    fclose(pText);
    fclose(pBinary);

#if WEIGHTED
    free(mt19937var);
#endif

    return fname_bin;
}

struct EdgeList *readEdgeListsbin(const char *fname, uint8_t inverse, uint32_t symmetric, uint32_t weighted)
{
    int fd = open(fname, O_RDONLY);
    struct stat fs;
    char *buf_addr;
    uint32_t  *buf_pointer;
#if WEIGHTED
    float    *buf_pointer_float;
    mt19937state *mt19937var = (mt19937state *) my_malloc(sizeof(mt19937state));
    initializeMersenneState (mt19937var, 27491095);
#endif
    uint32_t src = 0, dest = 0;
    uint32_t offset = 0;
    uint32_t offset_size;


    if (fd == -1)
    {
        err(1, "open: %s", fname);
        return 0;
    }

    if (fstat(fd, &fs) == -1)
    {
        err(1, "stat: %s", fname);
        return 0;
    }

    /* fs.st_size could have been 0 actually */
    buf_addr = (char *)mmap(0, fs.st_size, PROT_WRITE, MAP_PRIVATE, fd, 0);

    if (buf_addr == (void *) -1)
    {
        err(1, "mmap: %s", fname);
        close(fd);
        return 0;
    }


    buf_pointer = (uint32_t *) buf_addr;

#if WEIGHTED
    buf_pointer_float = (float *) buf_addr;
#endif

#if WEIGHTED
    if(weighted)
    {
        offset = 3;
        offset_size = (2 * sizeof(uint32_t)) + sizeof(float);
    }
    else
    {
        offset = 2;
        offset_size = (2 * sizeof(uint32_t));
    }
#else
    if(weighted) // you will skip the weights
    {
        offset = 3;
        offset_size = (2 * sizeof(uint32_t)) + sizeof(float);
    }
    else
    {
        offset = 2;
        offset_size = (2 * sizeof(uint32_t));
    }
#endif

    uint32_t num_edges = (uint64_t)fs.st_size / offset_size;
    // uint32_t num_edges = 32;
    struct EdgeList *edgeList;

#if DIRECTED
    if(symmetric)
    {
        edgeList = newEdgeList((num_edges) * 2);
    }
    else
    {
        edgeList = newEdgeList(num_edges);
    }
#else
    if(symmetric)
    {
        edgeList = newEdgeList((num_edges) * 2);
    }
    else
    {
        edgeList = newEdgeList(num_edges);
    }
#endif

    uint32_t i;
    uint32_t num_vertices = 0;

#if WEIGHTED
    float max_weight = 0;
#endif

    // #pragma omp parallel for reduction(max:num_vertices)
    for(i = 0; i < num_edges; i++)
    {
        src = buf_pointer[((offset) * i) + 0];
        dest = buf_pointer[((offset) * i) + 1];
        // printf(" %u %lu -> %lu \n",i,src,dest);
#if DIRECTED
        if(!inverse)
        {
            if(symmetric)
            {
                edgeList->edges_array_src[i] = src;
                edgeList->edges_array_dest[i] = dest;
                edgeList->edges_array_src[i + (num_edges)] = dest;
                edgeList->edges_array_dest[i + (num_edges)] = src;

#if WEIGHTED
                if(weighted)
                {
                    edgeList->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                    edgeList->edges_array_weight[i + (num_edges)] = edgeList->edges_array_weight[i];
                }
                else
                {
                    edgeList->edges_array_weight[i] = 1.0;
                    edgeList->edges_array_weight[i + (num_edges)] = edgeList->edges_array_weight[i];
                }
#endif

            }
            else
            {
                edgeList->edges_array_src[i] = src;
                edgeList->edges_array_dest[i] = dest;

#if WEIGHTED
                if(weighted)
                {
                    edgeList->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                }
                else
                {
                    edgeList->edges_array_weight[i] =  1.0;
                }
#endif
            } // symmetric
        } // inverse
        else
        {
            if(symmetric)
            {
                edgeList->edges_array_src[i] = dest;
                edgeList->edges_array_dest[i] = src;
                edgeList->edges_array_src[i + (num_edges)] = src;
                edgeList->edges_array_dest[i + (num_edges)] = dest;
#if WEIGHTED
                if(weighted)
                {
                    edgeList->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                    edgeList->edges_array_weight[i + (num_edges)] = edgeList->edges_array_weight[i];
                }
                else
                {
                    edgeList->edges_array_weight[i] = 1.0;
                    edgeList->edges_array_weight[i + (num_edges)] = edgeList->edges_array_weight[i];
                }
#endif
            }
            else
            {
                edgeList->edges_array_src[i] = dest;
                edgeList->edges_array_dest[i] = src;
#if WEIGHTED
                if(weighted)
                {
                    edgeList->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                }
                else
                {
                    edgeList->edges_array_weight[i] = 1.0;
                }
#endif
            }// symmetric
        }// inverse
#else
        if(symmetric)
        {
            edgeList->edges_array_src[i] = src;
            edgeList->edges_array_dest[i] = dest;
            edgeList->edges_array_src[i + (num_edges)] = dest;
            edgeList->edges_array_dest[i + (num_edges)] = src;
#if WEIGHTED
            if(weighted)
            {
                edgeList->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                edgeList->edges_array_weight[i + (num_edges)] = edgeList->edges_array_weight[i];
            }
            else
            {
                edgeList->edges_array_weight[i] = 1.0;
                edgeList->edges_array_weight[i + (num_edges)] = edgeList->edges_array_weight[i];
            }
#endif
        }
        else
        {
            edgeList->edges_array_src[i] = src;
            edgeList->edges_array_dest[i] = dest;
#if WEIGHTED
            if(weighted)
            {
                edgeList->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
            }
            else
            {
                edgeList->edges_array_weight[i] =  1.0;
            }
#endif
        }
#endif

        num_vertices = maxTwoIntegers(num_vertices, maxTwoIntegers(edgeList->edges_array_src[i], edgeList->edges_array_dest[i]));

#if WEIGHTED
        max_weight = maxTwoFloats(max_weight, edgeList->edges_array_weight[i]);
#endif

    }

    edgeList->num_vertices = num_vertices + 1; // max number of veritices Array[0-max]

    edgeList->avg_degree = edgeList->num_edges / edgeList->num_vertices;

#if WEIGHTED
    edgeList->max_weight = max_weight;
    free(mt19937var);
#endif
    // printf("DONE Reading EdgeList from file %s \n", fname);
    // edgeListPrint(edgeList);

    edgeList->mask_array = (uint32_t *) my_malloc((edgeList->num_vertices + 1) * sizeof(uint32_t));
    edgeList->label_array = (uint32_t *) my_malloc((edgeList->num_vertices + 1) * sizeof(uint32_t));
    edgeList->inverse_label_array = (uint32_t *) my_malloc((edgeList->num_vertices + 1) * sizeof(uint32_t));

    #pragma omp parallel for
    for (i = 0; i < (edgeList->num_vertices); ++i)
    {
        edgeList->mask_array[i] = 0;
        edgeList->label_array[i] = i;
        edgeList->inverse_label_array[i] = i;
    }

    munmap(buf_addr, fs.st_size);
    close(fd);

    return edgeList;
}


struct EdgeList *readEdgeListsMem( struct EdgeList *edgeListmem,  uint8_t inverse, uint32_t symmetric, uint32_t weighted)
{


    uint32_t num_edges = edgeListmem->num_edges;
    uint32_t num_vertices = edgeListmem->num_vertices;
    uint32_t i;
    uint32_t src = 0, dest = 0;

    struct EdgeList *edgeList;

    edgeList = newEdgeList((num_edges));

    if(edgeListmem->mask_array)
    {
        edgeList->mask_array = (uint32_t *) my_malloc((num_vertices + 1) * sizeof(uint32_t));

        #pragma omp parallel for
        for ( i = 0; i < (num_vertices); ++i)
        {
            edgeList->mask_array[i] = edgeListmem->mask_array[i];
        }

    }

    if(edgeListmem->label_array)
    {
        edgeList->label_array = (uint32_t *) my_malloc((num_vertices + 1) * sizeof(uint32_t));

        #pragma omp parallel for
        for ( i = 0; i < (num_vertices); ++i)
        {
            edgeList->label_array[i] = edgeListmem->label_array[i];
        }
    }

    if(edgeListmem->inverse_label_array)
    {
        edgeList->inverse_label_array = (uint32_t *) my_malloc((num_vertices + 1) * sizeof(uint32_t));

        #pragma omp parallel for
        for ( i = 0; i < (num_vertices); ++i)
        {
            edgeList->inverse_label_array[i] = edgeListmem->inverse_label_array[i];
        }
    }

    #pragma omp parallel for private(src,dest)
    for(i = 0; i < num_edges; i++)
    {
        src = edgeListmem->edges_array_src[i];
        dest = edgeListmem->edges_array_dest[i];
        float weight = edgeListmem->edges_array_weight[i];

        // printf("%u %lu -> %lu \n",src,dest);
#if DIRECTED
        if(!inverse)
        {
            if(symmetric)
            {
                edgeList->edges_array_src[i] = src;
                edgeList->edges_array_dest[i] = dest;
                edgeList->edges_array_weight[i] = weight;

            }
            else
            {
                edgeList->edges_array_src[i] = src;
                edgeList->edges_array_dest[i] = dest;

                if(weighted)
                {
                    edgeList->edges_array_weight[i] = weight;
                }
                else
                {
                    edgeList->edges_array_weight[i] = weight;
                }
            } // symmetric
        } // inverse
        else
        {
            if(symmetric)
            {
                edgeList->edges_array_src[i] = dest;
                edgeList->edges_array_dest[i] = src;
                edgeList->edges_array_weight[i] = weight;
            }
            else
            {
                edgeList->edges_array_src[i] = dest;
                edgeList->edges_array_dest[i] = src;
                edgeList->edges_array_weight[i] = weight;
            }// symmetric
        }// inverse
#else
        if(symmetric)
        {
            edgeList->edges_array_src[i] = src;
            edgeList->edges_array_dest[i] = dest;
            edgeList->edges_array_weight[i] = weight;
        }
        else
        {
            edgeList->edges_array_src[i] = src;
            edgeList->edges_array_dest[i] = dest;
            edgeList->edges_array_weight[i] = weight;
        }
#endif
    }

    edgeList->num_vertices = edgeListmem->num_vertices; // max number of veritices Array[0-max]

    if(edgeListmem->num_vertices)
        edgeList->avg_degree = edgeListmem->num_edges / edgeListmem->num_vertices;

    edgeList->max_weight =  edgeListmem->max_weight;


    return edgeList;
}

void edgeListPrintBasic(struct EdgeList *edgeList)
{

    printf("Number of vertices (V) : %u \n", edgeList->num_vertices);
    printf("Number of edges    (E) : %u \n", edgeList->num_edges);
    printf("Average degree     (D) : %u \n", edgeList->avg_degree);

}

void edgeListPrint(struct EdgeList *edgeList)
{

    printf("Number of vertices (V) : %u \n", edgeList->num_vertices);
    printf("Number of edges    (E) : %u \n", edgeList->num_edges);
    printf("Average degree     (D) : %u \n", edgeList->avg_degree);

    uint32_t i;


    for(i = 0; i < edgeList->num_vertices; i++)
    {
        printf("label %-2u->%-2u - %-2u->%-2u \n",  i, edgeList->label_array[i], i, edgeList->inverse_label_array[i] );
    }

    for(i = 0; i < edgeList->num_edges; i++)
    {
#if WEIGHTED
        printf("%u -> %u w: %f \n", edgeList->edges_array_src[i], edgeList->edges_array_dest[i], edgeList->edges_array_weight[i]);
#else
        printf("%u -> %u \n", edgeList->edges_array_src[i], edgeList->edges_array_dest[i]);
#endif
    }

}