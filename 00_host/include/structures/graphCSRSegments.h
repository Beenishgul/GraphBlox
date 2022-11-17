#ifndef GRAPHGRID_H
#define GRAPHGRID_H



#ifdef __cplusplus
extern "C" {
#endif


#include <stdint.h>

#include "graphConfig.h"
#include "edgeList.h"
#include "csrSegments.h"

// A structure to represent an adjacency list
struct  GraphCSRSegments
{

    uint32_t num_edges;
    uint32_t num_vertices;
    uint32_t avg_degree;
#if WEIGHTED
    float max_weight;
#endif

    struct CSRSegments *csrSegments;

};

void  graphCSRSegmentsReset(struct GraphCSRSegments *graphCSRSegments);
void  graphCSRSegmentsPrint(struct GraphCSRSegments *graphCSRSegments);
struct GraphCSRSegments *graphCSRSegmentsNew(struct EdgeList *edgeList, uint32_t cache_size);
void   graphCSRSegmentsFree(struct GraphCSRSegments *graphCSRSegments);
void   graphCSRSegmentsPrintMessageWithtime(const char *msg, double time);
struct GraphCSRSegments *graphCSRSegmentsPreProcessingStep (struct Arguments *arguments);

#ifdef __cplusplus
}
#endif

#endif