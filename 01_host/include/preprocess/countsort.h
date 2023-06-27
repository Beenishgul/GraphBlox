#ifndef COUNTSORT_H
#define COUNTSORT_H

#ifdef __cplusplus
extern "C" {
#endif


#include "edgeList.h"

// A structure to represent an edge

struct EdgeList *countSortEdgesBySource (struct EdgeList *edgeList);
struct EdgeList *countSortEdgesByDestination (struct EdgeList *edgeList);
struct EdgeList *countSortEdgesBySourceAndDestination (struct EdgeList *edgeList);

#ifdef __cplusplus
}
#endif

#endif