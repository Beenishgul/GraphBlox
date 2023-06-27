#ifndef SPMV_H
#define SPMV_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "graphConfig.h"
#include "graphCSR.h"

// ********************************************************************************************
// ***************                  Stats DataStructure                          **************
// ********************************************************************************************


struct SPMVStats
{

    uint32_t iterations;
    struct Arguments *arguments;
    uint32_t num_vertices;
    float *vector_output;
    float *vector_input;
    double time_total;
};

struct SPMVStats *newSPMVStatsGraphCSR(struct GraphCSR *graph);

void freeSPMVStats(struct SPMVStats *stats);


// ********************************************************************************************
// ***************					CSR DataStructure							 **************
// ********************************************************************************************

struct SPMVStats *SPMVGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct SPMVStats *SPMVPullGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct SPMVStats *SPMVPushGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);

struct SPMVStats *SPMVPullFixedPointGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);
struct SPMVStats *SPMVPushFixedPointGraphCSR(struct Arguments *arguments, struct GraphCSR *graph);


#ifdef __cplusplus
}
#endif

#endif