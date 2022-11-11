#ifndef CONNECTEDCOMPONENTS_H
#define CONNECTEDCOMPONENTS_H


#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "graphCSR.h"

// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************

#ifndef HASHSIZE
#define HASHSIZE (1 << 16) // hash table size 256
#endif
#define JUDYERROR_SAMPLE 1

struct CCStats
{
    uint32_t iterations;
    uint32_t neighbor_rounds;
    struct Arguments *arguments;
    uint32_t num_vertices;
    uint32_t *components;
    uint32_t *counts;
    uint32_t *labels;
    double time_total;

};

struct CCStats *newCCStatsGraphCSR(struct GraphCSR *graph);

void printCCStats(struct CCStats *stats);
void freeCCStats(struct CCStats *stats);


void printComponents(struct CCStats *stats);
// ********************************************************************************************
// ***************                       Helper Functions                        **************
// ********************************************************************************************
uint32_t atomicMin(uint32_t *oldValue, uint32_t newValue);
void addSample(uint32_t id);
void linkNodes(uint32_t u, uint32_t v, uint32_t *components);
void compressNodes(uint32_t num_vertices, uint32_t *components);
uint32_t sampleFrequentNode(mt19937state *mt19937var, uint32_t num_vertices, uint32_t num_samples, uint32_t *components);

// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct CCStats *connectedComponentsGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct CCStats *connectedComponentsAfforestGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct CCStats *connectedComponentsShiloachVishkinGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct CCStats *connectedComponentsWeaklyGraphCSR( struct Arguments *arguments, struct GraphCSR *graph);
uint32_t connectedComponentsVerifyGraphCSR(struct CCStats *stats, struct GraphCSR *graph);

#ifdef __cplusplus
}
#endif

#endif