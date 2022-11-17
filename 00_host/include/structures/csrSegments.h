#ifndef CSRSEGMENTS_H
#define CSRSEGMENTS_H


#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "bitmap.h"
#include "graphConfig.h"
#include "edgeList.h"
#include "graphCSR.h"
#include "vertex.h"



// A structure to represent an adjacency list
struct  Segment
{

    // uint32_t vertex_start;
    // uint32_t vertex_end;
    uint32_t num_edges;
    uint32_t num_vertices;
    struct EdgeList *edgeList;

};


// A structure to represent an adjacency list
struct  CSRSegments
{

    uint32_t num_edges;
    uint32_t num_vertices;
    uint32_t num_segments;
    struct Segment *segments;
    uint32_t *activeSegments;
    uint32_t *out_degree;
    uint32_t *in_degree;
    struct Bitmap *activeSegmentsMap;
    // struct Bitmap* activeVertices;
};


void csrSegmentsPrint(struct CSRSegments *csrSegments);
struct CSRSegments *csrSegmentsNew(struct EdgeList *edgeList, uint32_t cache_size);
void  csrSegmentsFree(struct CSRSegments *csrSegments);
void csrSegmentsPrintMessageWithtime(const char *msg, double time);

struct CSRSegments *csrSegmentsSegmentEdgeListSizePreprocessing(struct CSRSegments *csrSegments, struct EdgeList *edgeList);
struct CSRSegments *csrSegmentsSegmentVertexSizePreprocessing(struct CSRSegments *csrSegments);
uint32_t csrSegmentsCalculateSegments(struct EdgeList *edgeList, uint32_t cache_size);
struct CSRSegments *csrSegmentsSegmentsMemoryAllocations(struct CSRSegments *csrSegments);
struct CSRSegments *csrSegmentsSegmentEdgePopulation(struct CSRSegments *csrSegments, struct EdgeList *edgeList);
struct CSRSegments *graphCSRSegmentsProcessInOutDegrees(struct CSRSegments *csrSegments, struct EdgeList *edgeList);
void   graphCSRSegmentsSetActiveSegments(struct CSRSegments *csrSegments, uint32_t vertex);
void   graphCSRSegmentsResetActiveSegments(struct CSRSegments *csrSegments);

void   graphCSRSegmentsResetActiveSegmentsMap(struct CSRSegments *csrSegments);
void   graphCSRSegmentsSetActiveSegmentsMap(struct CSRSegments *csrSegments, uint32_t vertex);

uint32_t getSegmentID(uint32_t vertices, uint32_t segments, uint32_t vertex_id);


#ifdef __cplusplus
}
#endif

#endif