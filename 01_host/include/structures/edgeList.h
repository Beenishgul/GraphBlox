#ifndef EDGELIST_H
#define EDGELIST_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "edgeList.h"

struct  EdgeList
{

    uint32_t num_edges;
    uint32_t num_vertices;
    uint32_t avg_degree;
    float max_weight;
    float *edges_array_weight;
    uint32_t *edges_array_src;
    uint32_t *edges_array_dest;
    uint32_t *mask_array;
    uint32_t *label_array;
    uint32_t *inverse_label_array;
};


uint32_t maxTwoIntegers(uint32_t num1, uint32_t num2);
float maxTwoFloats(float num1, float num2);


void edgeListPrint(struct EdgeList *edgeList);
void edgeListPrintBasic(struct EdgeList *edgeList);
void freeEdgeList( struct EdgeList *edgeList);
char *readEdgeListstxt(const char *fname, uint32_t weighted);
struct EdgeList *readEdgeListsbin(const char *fname, uint8_t inverse, uint32_t symmetric, uint32_t weighted);
struct EdgeList *readEdgeListsMem( struct EdgeList *edgeListmem,  uint8_t inverse, uint32_t symmetric, uint32_t weighted);
struct EdgeList *newEdgeList(uint32_t num_edges);
struct EdgeList *newEdgeListIncremental( uint32_t num_edges);
void writeEdgeListToTXTFile(struct EdgeList *edgeList, const char *fname);
struct EdgeList *removeDulpicatesSelfLoopEdges( struct EdgeList *edgeList);
struct EdgeList *deepCopyEdgeList( struct EdgeList *edgeListFrom, struct EdgeList *edgeListTo);
void insertEdgeInEdgeList( struct EdgeList *edgeList,  uint32_t src,  uint32_t dest,  float weight);
struct EdgeList *finalizeInsertEdgeInEdgeList( struct EdgeList *edgeList);
struct EdgeList *resizeEdgeList( struct EdgeList *edgeListFrom, uint32_t num_edges);

#ifdef __cplusplus
}
#endif


#endif