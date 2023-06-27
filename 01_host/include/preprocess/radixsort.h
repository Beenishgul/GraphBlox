#ifndef RADIXSORT_H
#define RADIXSORT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "edgeList.h"

struct EdgeList* radixSortEdgesBySource (struct EdgeList* edgeList);
struct EdgeList* radixSortEdgesBySourceAndDestination (struct EdgeList* edgeList);
// struct EdgeList* radixSortEdgesBySourceOptimized (struct EdgeList* edgeList);
// struct EdgeList* radixSortEdgesBySourceOptimizedParallel (struct EdgeList* edgeList);
void radixSortCountSortEdgesBySource (struct EdgeList** sorted_edges_array, struct EdgeList** edgeList, uint32_t radix, uint32_t buckets, uint32_t* buckets_count);
void radixSortCountSortEdgesByDestination (struct EdgeList** sorted_edges_array, struct EdgeList** edgeList, uint32_t radix, uint32_t buckets, uint32_t* buckets_count);

#ifdef __cplusplus
}
#endif

#endif