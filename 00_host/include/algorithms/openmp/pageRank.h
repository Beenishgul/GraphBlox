#ifndef PAGERANK_H
#define PAGERANK_H


#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "graphCSR.h"

#define Damp 0.85f

// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************

struct PageRankStats
{
    float damp;
    float base_pr;
    uint32_t iterations;
    uint32_t num_vertices;
    uint32_t activeVertices;
    uint32_t *realRanks;
    float *pageRanks;
    double time_total;
    double error_total;
};

struct PageRankStats *newPageRankStatsGraphCSR(struct GraphCSR *graph);

void freePageRankStats(struct PageRankStats *stats);


// ********************************************************************************************
// ***************                  Auxiliary functions                          **************
// ********************************************************************************************

void addAtomicFixedPoint(uint64_t *num, uint64_t value);
void addAtomicFloat(float *num, float value);
void addAtomicDouble(double *num, double value);
void setAtomic(uint64_t *num, uint64_t value);

void pageRankPrint(float *pageRankArray, uint32_t num_vertices);
void pageRankCompare(float *pageRankArrayOp1, float *pageRankArrayOp2);
void swapWorkLists (uint8_t **workList1, uint8_t **workList2);
void resetWorkList(uint8_t *workList, uint32_t size);
void setWorkList(uint8_t *workList,  uint32_t size);


// ********************************************************************************************
// ***************                  CSR DataStructure                            **************
// ********************************************************************************************

struct PageRankStats *pageRankGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPullGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct PageRankStats *pageRankPullFixedPoint64BitGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPullFixedPoint32BitGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPullFixedPoint16BitGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPullFixedPoint8BitGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPushFixedPointGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct PageRankStats *pageRankPullQuant32BitGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPullQuant16BitGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPullQuant8BitGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankPushQuantGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct PageRankStats *pageRankDataDrivenPullGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankDataDrivenPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct PageRankStats *pageRankDataDrivenPullPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

#ifdef __cplusplus
}
#endif


#endif