#ifndef HASH_H
#define HASH_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

uint32_t magicHash32(uint32_t x);
uint32_t magicHash32Reverse(uint32_t x);
uint64_t magicHash64(uint64_t x);
uint64_t magicHash64Reverse(uint64_t x);

#ifdef __cplusplus
}
#endif

#endif