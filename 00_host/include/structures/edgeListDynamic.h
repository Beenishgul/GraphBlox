#ifndef EDGELISTDYNAMIC_H
#define EDGELISTDYNAMIC_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "edgeListDynamic.h"

struct  EdgeListDynamic
{

    uint32_t num_edges;
    uint32_t num_vertices;
    uint32_t avg_degree;
#if WEIGHTED
    float max_weight;
    float *edges_array_weight;
#endif
    uint32_t *edges_array_src;
    uint32_t *edges_array_dest;
    uint32_t *edges_array_time;
    uint8_t *edges_array_operation;
    uint32_t *mask_array;
    uint32_t *label_array;
    uint32_t *inverse_label_array;
};


uint32_t maxTwoIntegersDynamic(uint32_t num1, uint32_t num2);
float maxTwoFloatsDynamic(float num1, float num2);


void edgeListDynamicPrint(struct EdgeListDynamic *edgeListDynamic);
void edgeListDynamicPrintBasic(struct EdgeListDynamic *edgeListDynamic);
void freeEdgeListDynamic( struct EdgeListDynamic *edgeListDynamic);
char *readEdgeListsDynamictxt(const char *fname, uint32_t weighted);
struct EdgeListDynamic *readEdgeListsDynamicbin(const char *fname, uint8_t inverse, uint32_t symmetric, uint32_t weighted);
struct EdgeListDynamic *readEdgeListsDynamicMem( struct EdgeListDynamic *edgeListDynamicmem,  uint8_t inverse, uint32_t symmetric, uint32_t weighted);
struct EdgeListDynamic *newEdgeListDynamic(uint32_t num_edges);
void writeEdgeListDynamicToTXTFile(struct EdgeListDynamic *edgeListDynamic, const char *fname);
struct EdgeListDynamic *removeDulpicatesSelfLoopEdgesDynamic( struct EdgeListDynamic *edgeListDynamic);

#ifdef __cplusplus
}
#endif


#endif