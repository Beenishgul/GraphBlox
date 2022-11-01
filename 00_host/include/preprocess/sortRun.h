#ifndef SORTRUN_H
#define SORTRUN_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include "edgeList.h"

struct EdgeList *sortRunAlgorithms(struct EdgeList *edgeList, uint32_t sort);
void sortRunPrintMessageWithtime(const char *msg, double time);

#ifdef __cplusplus
}
#endif

#endif