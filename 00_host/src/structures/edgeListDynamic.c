// -----------------------------------------------------------------------------
//
//      "00_GLay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@virginia||atmughrabi@gmail.com
// File   : edgeListDynamic.c
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
#include "edgeListDynamic.h"



uint32_t maxTwoIntegersDynamic(uint32_t num1, uint32_t num2)
{

    if(num1 >= num2)
        return num1;
    else
        return num2;

}

float maxTwoFloatsDynamic(float num1, float num2)
{

    if(num1 >= num2)
        return num1;
    else
        return num2;

}


void writeEdgeListDynamicToTXTFile(struct EdgeListDynamic *edgeListDynamic, const char *fname)
{

    FILE *fp;
    uint32_t i;


    char *fname_txt = (char *) malloc((strlen(fname) + 10) * sizeof(char));

    fname_txt = strcpy (fname_txt, fname);
    fname_txt = strcat (fname_txt, ".txt");

    fp = fopen (fname_txt, "w");


    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Average Degree");
    printf("| %-51u | \n", edgeListDynamic->avg_degree);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Vertices (V)");
    printf("| %-51u | \n", edgeListDynamic->num_vertices);
    printf(" -----------------------------------------------------\n");
    printf("| %-51s | \n", "Number of Edges (E)");
    printf("| %-51u | \n", edgeListDynamic->num_edges);
    printf(" -----------------------------------------------------\n");


    for(i = 0; i < edgeListDynamic->num_edges; i++)
    {
#if WEIGHTED
        fprintf(fp, "%u %u %f\n", edgeListDynamic->edges_array_src[i], edgeListDynamic->edges_array_dest[i], edgeListDynamic->edges_array_weight[i]);
#else
        fprintf(fp, "%u %u\n", edgeListDynamic->edges_array_src[i], edgeListDynamic->edges_array_dest[i]);
#endif
    }

    fclose (fp);
}

// read edge file to edge_array in memory
struct EdgeListDynamic *newEdgeListDynamic( uint32_t num_edges)
{


    struct EdgeListDynamic *newEdgeListDynamic = (struct EdgeListDynamic *) my_malloc(sizeof(struct EdgeListDynamic));
    newEdgeListDynamic->edges_array_src = (uint32_t *) my_malloc(num_edges * sizeof(uint32_t));
    newEdgeListDynamic->edges_array_dest = (uint32_t *) my_malloc(num_edges * sizeof(uint32_t));
    newEdgeListDynamic->edges_array_time = (uint32_t *) my_malloc(num_edges * sizeof(uint32_t));
    newEdgeListDynamic->edges_array_operation = (uint8_t *) my_malloc(num_edges * sizeof(uint8_t));

#if WEIGHTED
    newEdgeListDynamic->edges_array_weight = (float *) my_malloc(num_edges * sizeof(float));
#endif

    uint32_t i;
    #pragma omp parallel for
    for(i = 0; i < num_edges; i++)
    {
        newEdgeListDynamic->edges_array_dest[i] = 0;
        newEdgeListDynamic->edges_array_src[i] = 0;
        newEdgeListDynamic->edges_array_time[i] = 0;
        newEdgeListDynamic->edges_array_operation[i] = 0;
#if WEIGHTED
        newEdgeListDynamic->edges_array_weight[i] = 0;
#endif
    }

    newEdgeListDynamic->mask_array = NULL;
    newEdgeListDynamic->label_array = NULL;
    newEdgeListDynamic->inverse_label_array = NULL;
    newEdgeListDynamic->num_edges = num_edges;
    newEdgeListDynamic->num_vertices = 0;
    newEdgeListDynamic->avg_degree = 0;
    // newEdgeListDynamic->edges_array = newEdgeListDynamic(num_edges);

#if WEIGHTED
    newEdgeListDynamic->max_weight = 0;
#endif

    return newEdgeListDynamic;

}


struct EdgeListDynamic *removeDulpicatesSelfLoopEdgesDynamic( struct EdgeListDynamic *edgeListDynamic)
{

    struct EdgeListDynamic *tempEdgeListDynamic = newEdgeListDynamic(edgeListDynamic->num_edges);
    uint32_t tempSrc = 0;
    uint32_t tempDest = 0;
#if WEIGHTED
    uint32_t tempWeight = 0;
#endif
    uint32_t j = 0;
    uint32_t i = 0;


    do
    {
        tempSrc = edgeListDynamic->edges_array_src[i];
        tempDest = edgeListDynamic->edges_array_dest[i];
#if WEIGHTED
        tempWeight = edgeListDynamic->edges_array_weight[i];
#endif
        i++;
    }
    while(tempSrc == tempDest);

    tempEdgeListDynamic->edges_array_src[j] = tempSrc;
    tempEdgeListDynamic->edges_array_dest[j] = tempDest;
#if WEIGHTED
    tempEdgeListDynamic->edges_array_weight[j] = tempWeight;
#endif
    j++;

    for(; i < tempEdgeListDynamic->num_edges; i++)
    {
        tempSrc = edgeListDynamic->edges_array_src[i];
        tempDest = edgeListDynamic->edges_array_dest[i];
#if WEIGHTED
        tempWeight = edgeListDynamic->edges_array_weight[i];
#endif
        if(tempSrc != tempDest)
        {
            if(tempEdgeListDynamic->edges_array_src[j - 1] != tempSrc || tempEdgeListDynamic->edges_array_dest[j - 1] != tempDest )
            {
                tempEdgeListDynamic->edges_array_src[j] = tempSrc;
                tempEdgeListDynamic->edges_array_dest[j] = tempDest;
#if WEIGHTED
                tempEdgeListDynamic->edges_array_weight[j] = tempWeight;
#endif
                j++;
            }
        }
    }

    tempEdgeListDynamic->num_edges = j;
    tempEdgeListDynamic->num_vertices = edgeListDynamic->num_vertices ;
#if WEIGHTED
    tempEdgeListDynamic->max_weight = edgeListDynamic->max_weight ;
#endif
    tempEdgeListDynamic->avg_degree = tempEdgeListDynamic->num_edges / tempEdgeListDynamic->num_vertices;

    tempEdgeListDynamic->mask_array = (uint32_t *) my_malloc((tempEdgeListDynamic->num_vertices + 1) * sizeof(uint32_t));
    tempEdgeListDynamic->label_array = (uint32_t *) my_malloc((tempEdgeListDynamic->num_vertices + 1) * sizeof(uint32_t));
    tempEdgeListDynamic->inverse_label_array = (uint32_t *) my_malloc((tempEdgeListDynamic->num_vertices + 1) * sizeof(uint32_t));

    #pragma omp parallel for
    for (i = 0; i < (edgeListDynamic->num_vertices); ++i)
    {
        tempEdgeListDynamic->mask_array[i] = edgeListDynamic->mask_array[i] ;
        tempEdgeListDynamic->label_array[i] =  edgeListDynamic->label_array[i];
        tempEdgeListDynamic->inverse_label_array[i] =  edgeListDynamic->inverse_label_array[i];
    }

    freeEdgeListDynamic(edgeListDynamic);
    return tempEdgeListDynamic;
}

void freeEdgeListDynamic( struct EdgeListDynamic *edgeListDynamic)
{

    if(edgeListDynamic)
    {
        // freeEdgeArray(edgeListDynamic->edges_array);
        if(edgeListDynamic->edges_array_src)
            free(edgeListDynamic->edges_array_src);
        if(edgeListDynamic->edges_array_dest)
            free(edgeListDynamic->edges_array_dest);
        if(edgeListDynamic->edges_array_time)
            free(edgeListDynamic->edges_array_time);
        if(edgeListDynamic->edges_array_operation)
            free(edgeListDynamic->edges_array_operation);
        if(edgeListDynamic->mask_array)
            free(edgeListDynamic->mask_array);
        if(edgeListDynamic->label_array)
            free(edgeListDynamic->label_array);
        if(edgeListDynamic->inverse_label_array)
            free(edgeListDynamic->inverse_label_array);

#if WEIGHTED
        if(edgeListDynamic->edges_array_weight)
            free(edgeListDynamic->edges_array_weight);
#endif

        free(edgeListDynamic);
    }


}


char *readEdgeListsDynamictxt(const char *fname, uint32_t weighted)
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
            weight = generateRandFloat(mt19937var);
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
        fwrite(&weight, sizeof (weight), 1, pBinary);
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

struct EdgeListDynamic *readEdgeListsDynamicbin(const char *fname, uint8_t inverse, uint32_t symmetric, uint32_t weighted)
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
    uint32_t  src = 0, dest = 0;
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
        offset = 3;
        offset_size = (2 * sizeof(uint32_t)) + sizeof(float);
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
    struct EdgeListDynamic *edgeListDynamic;

#if DIRECTED
    if(symmetric)
    {
        edgeListDynamic = newEdgeListDynamic((num_edges) * 2);
    }
    else
    {
        edgeListDynamic = newEdgeListDynamic(num_edges);
    }
#else
    if(symmetric)
    {
        edgeListDynamic = newEdgeListDynamic((num_edges) * 2);
    }
    else
    {
        edgeListDynamic = newEdgeListDynamic(num_edges);
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
                edgeListDynamic->edges_array_src[i] = src;
                edgeListDynamic->edges_array_dest[i] = dest;
                edgeListDynamic->edges_array_src[i + (num_edges)] = dest;
                edgeListDynamic->edges_array_dest[i + (num_edges)] = src;

#if WEIGHTED
                if(weighted)
                {
                    edgeListDynamic->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                    edgeListDynamic->edges_array_weight[i + (num_edges)] = edgeListDynamic->edges_array_weight[i];
                }
                else
                {
                    edgeListDynamic->edges_array_weight[i] = generateRandFloat(mt19937var);
                    edgeListDynamic->edges_array_weight[i + (num_edges)] = edgeListDynamic->edges_array_weight[i];
                }
#endif

            }
            else
            {
                edgeListDynamic->edges_array_src[i] = src;
                edgeListDynamic->edges_array_dest[i] = dest;

#if WEIGHTED
                if(weighted)
                {
                    edgeListDynamic->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                }
                else
                {
                    edgeListDynamic->edges_array_weight[i] =  generateRandFloat(mt19937var);
                }
#endif
            } // symmetric
        } // inverse
        else
        {
            if(symmetric)
            {
                edgeListDynamic->edges_array_src[i] = dest;
                edgeListDynamic->edges_array_dest[i] = src;
                edgeListDynamic->edges_array_src[i + (num_edges)] = src;
                edgeListDynamic->edges_array_dest[i + (num_edges)] = dest;
#if WEIGHTED
                if(weighted)
                {
                    edgeListDynamic->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                    edgeListDynamic->edges_array_weight[i + (num_edges)] = edgeListDynamic->edges_array_weight[i];
                }
                else
                {
                    edgeListDynamic->edges_array_weight[i] = generateRandFloat(mt19937var);
                    edgeListDynamic->edges_array_weight[i + (num_edges)] = edgeListDynamic->edges_array_weight[i];
                }
#endif
            }
            else
            {
                edgeListDynamic->edges_array_src[i] = dest;
                edgeListDynamic->edges_array_dest[i] = src;
#if WEIGHTED
                if(weighted)
                {
                    edgeListDynamic->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                }
                else
                {
                    edgeListDynamic->edges_array_weight[i] = generateRandFloat(mt19937var);
                }
#endif
            }// symmetric
        }// inverse
#else
        if(symmetric)
        {
            edgeListDynamic->edges_array_src[i] = src;
            edgeListDynamic->edges_array_dest[i] = dest;
            edgeListDynamic->edges_array_src[i + (num_edges)] = dest;
            edgeListDynamic->edges_array_dest[i + (num_edges)] = src;
#if WEIGHTED
            if(weighted)
            {
                edgeListDynamic->edges_array_weight[i] = 1;
                edgeListDynamic->edges_array_weight[i + (num_edges)] = edgeListDynamic->edges_array_weight[i];
            }
            else
            {
                edgeListDynamic->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
                edgeListDynamic->edges_array_weight[i + (num_edges)] = edgeListDynamic->edges_array_weight[i];
            }
#endif
        }
        else
        {
            edgeListDynamic->edges_array_src[i] = src;
            edgeListDynamic->edges_array_dest[i] = dest;
#if WEIGHTED
            if(weighted)
            {
                edgeListDynamic->edges_array_weight[i] = buf_pointer_float[((offset) * i) + 2];
            }
            else
            {
                edgeListDynamic->edges_array_weight[i] =  generateRandFloat(mt19937var);
            }
#endif
        }
#endif

        num_vertices = maxTwoIntegers(num_vertices, maxTwoIntegers(edgeListDynamic->edges_array_src[i], edgeListDynamic->edges_array_dest[i]));

#if WEIGHTED
        max_weight = maxTwoFloats(max_weight, edgeListDynamic->edges_array_weight[i]);
#endif

    }

    edgeListDynamic->num_vertices = num_vertices + 1; // max number of veritices Array[0-max]

    edgeListDynamic->avg_degree = edgeListDynamic->num_edges / edgeListDynamic->num_vertices;

#if WEIGHTED
    edgeListDynamic->max_weight = max_weight;
    free(mt19937var);
#endif
    // printf("DONE Reading EdgeListDynamic from file %s \n", fname);
    // edgeListDynamicPrint(edgeListDynamic);

    edgeListDynamic->mask_array = (uint32_t *) my_malloc((edgeListDynamic->num_vertices + 1) * sizeof(uint32_t));
    edgeListDynamic->label_array = (uint32_t *) my_malloc((edgeListDynamic->num_vertices + 1) * sizeof(uint32_t));
    edgeListDynamic->inverse_label_array = (uint32_t *) my_malloc((edgeListDynamic->num_vertices + 1) * sizeof(uint32_t));

    #pragma omp parallel for
    for (i = 0; i < (edgeListDynamic->num_vertices); ++i)
    {
        edgeListDynamic->mask_array[i] = 0;
        edgeListDynamic->label_array[i] = i;
        edgeListDynamic->inverse_label_array[i] = i;
    }

    munmap(buf_addr, fs.st_size);
    close(fd);

    return edgeListDynamic;
}


struct EdgeListDynamic *readEdgeListsDynamicMem( struct EdgeListDynamic *edgeListDynamicmem,  uint8_t inverse, uint32_t symmetric, uint32_t weighted)
{


    uint32_t num_edges = edgeListDynamicmem->num_edges;
    uint32_t num_vertices = edgeListDynamicmem->num_vertices;
    uint32_t i;
    uint32_t  src = 0, dest = 0;

    struct EdgeListDynamic *edgeListDynamic;

    edgeListDynamic = newEdgeListDynamic((num_edges));

    if(edgeListDynamicmem->mask_array)
    {
        edgeListDynamic->mask_array = (uint32_t *) my_malloc((num_vertices + 1) * sizeof(uint32_t));

        #pragma omp parallel for
        for ( i = 0; i < (num_vertices); ++i)
        {
            edgeListDynamic->mask_array[i] = edgeListDynamicmem->mask_array[i];
        }

    }

    if(edgeListDynamicmem->label_array)
    {
        edgeListDynamic->label_array = (uint32_t *) my_malloc((num_vertices + 1) * sizeof(uint32_t));

        #pragma omp parallel for
        for ( i = 0; i < (num_vertices); ++i)
        {
            edgeListDynamic->label_array[i] = edgeListDynamicmem->label_array[i];
        }
    }

    if(edgeListDynamicmem->inverse_label_array)
    {
        edgeListDynamic->inverse_label_array = (uint32_t *) my_malloc((num_vertices + 1) * sizeof(uint32_t));

        #pragma omp parallel for
        for ( i = 0; i < (num_vertices); ++i)
        {
            edgeListDynamic->inverse_label_array[i] = edgeListDynamicmem->inverse_label_array[i];
        }
    }

    #pragma omp parallel for private(src,dest)
    for(i = 0; i < num_edges; i++)
    {
        src = edgeListDynamicmem->edges_array_src[i];
        dest = edgeListDynamicmem->edges_array_dest[i];
#if WEIGHTED
        float weight = edgeListDynamicmem->edges_array_weight[i];
#endif
        // printf(" %u %lu -> %lu \n",src,dest);
#if DIRECTED
        if(!inverse)
        {
            if(symmetric)
            {
                edgeListDynamic->edges_array_src[i] = src;
                edgeListDynamic->edges_array_dest[i] = dest;


#if WEIGHTED

                edgeListDynamic->edges_array_weight[i] = weight;

#endif

            }
            else
            {
                edgeListDynamic->edges_array_src[i] = src;
                edgeListDynamic->edges_array_dest[i] = dest;

#if WEIGHTED
                if(weighted)
                {
                    edgeListDynamic->edges_array_weight[i] = weight;
                }
                else
                {
                    edgeListDynamic->edges_array_weight[i] = weight;
                }
#endif
            } // symmetric
        } // inverse
        else
        {
            if(symmetric)
            {
                edgeListDynamic->edges_array_src[i] = dest;
                edgeListDynamic->edges_array_dest[i] = src;

#if WEIGHTED

                edgeListDynamic->edges_array_weight[i] = weight;

#endif
            }
            else
            {
                edgeListDynamic->edges_array_src[i] = dest;
                edgeListDynamic->edges_array_dest[i] = src;
#if WEIGHTED

                edgeListDynamic->edges_array_weight[i] = weight;

#endif
            }// symmetric
        }// inverse
#else
        if(symmetric)
        {
            edgeListDynamic->edges_array_src[i] = src;
            edgeListDynamic->edges_array_dest[i] = dest;

#if WEIGHTED

            edgeListDynamic->edges_array_weight[i] = weight;

#endif
        }
        else
        {
            edgeListDynamic->edges_array_src[i] = src;
            edgeListDynamic->edges_array_dest[i] = dest;
#if WEIGHTED

            edgeListDynamic->edges_array_weight[i] = weight;

#endif
        }
#endif
    }

    edgeListDynamic->num_vertices = edgeListDynamicmem->num_vertices; // max number of veritices Array[0-max]

    if(edgeListDynamicmem->num_vertices)
        edgeListDynamic->avg_degree = edgeListDynamicmem->num_edges / edgeListDynamicmem->num_vertices;

#if WEIGHTED
    edgeListDynamic->max_weight =  edgeListDynamicmem->max_weight;
#endif

    return edgeListDynamic;
}

void edgeListDynamicPrintBasic(struct EdgeListDynamic *edgeListDynamic)
{

    printf("Number of vertices (V) : %u \n", edgeListDynamic->num_vertices);
    printf("Number of edges    (E) : %u \n", edgeListDynamic->num_edges);
    printf("Average degree     (D) : %u \n", edgeListDynamic->avg_degree);

}

void edgeListDynamicPrint(struct EdgeListDynamic *edgeListDynamic)
{

    printf("Number of vertices (V) : %u \n", edgeListDynamic->num_vertices);
    printf("Number of edges    (E) : %u \n", edgeListDynamic->num_edges);
    printf("Average degree     (D) : %u \n", edgeListDynamic->avg_degree);

    uint32_t i;


    for(i = 0; i < edgeListDynamic->num_vertices; i++)
    {
        printf("label %-2u->%-2u - %-2u->%-2u \n",  i, edgeListDynamic->label_array[i], i, edgeListDynamic->inverse_label_array[i] );
    }

    for(i = 0; i < edgeListDynamic->num_edges; i++)
    {
#if WEIGHTED
        printf("%u -> %u w: %f \n", edgeListDynamic->edges_array_src[i], edgeListDynamic->edges_array_dest[i], edgeListDynamic->edges_array_weight[i]);
#else
        printf("%u -> %u \n", edgeListDynamic->edges_array_src[i], edgeListDynamic->edges_array_dest[i]);
#endif
    }

}