#ifndef MYMALLOC_H
#define MYMALLOC_H

// extern int errno ;
#ifdef __cplusplus
extern "C" {
#endif

#define ALIGNED 1
// #define CACHELINE_BYTES 64
#define CACHELINE_BYTES 4096

char *strerror(int errnum);
void *aligned_malloc( size_t size );
void *my_malloc( size_t size );
void *regular_malloc( size_t size );

#ifdef __cplusplus
}
#endif

#endif