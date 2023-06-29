#ifndef GLAYGDL_EMU_H
#define GLAYGDL_EMU_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

// GGDL is a description language that helps compile and port any graph
// algorithm to GLay graph processing overlay. This chapter describes some
// of the features of GLay architecture combined with a description
// language that can be compiled to reprogram the graph overlay.

// Read\_Write\_Engine
// --------------------

// ### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity, mode

// The read/write recieves a sequence and trnsformes it to memory commands
// sent to the memory control layer.
// Each read or write requests a chunk of data specified with the
// "granularity" parameter -- alignment should be honored for a cache line.
// The "stride" parameter sets the offset taken by each consecutive read;
// strides should also honor alignment restrictions. This behavior is
// related to reading CSR structure data, for example, reading the offsets
// array. Mode parameter would decide the engine read/write mode.

uint32_t *ReadWriteEngine(uint32_t *arrayPointer, uint32_t arraySize, uint32_t startRead, uint32_t endRead, uint32_t stride, uint32_t granularity, uint32_t mode);


// Stride\_Index\_Generator
// ------------------------

// ### Input: index\_start, index\_end, stride, granularity

// The stride index generator serves two purposes. First, it generates a
// sequence of indices or Vertex-IDs scheduled to the Vertex Compute Units
// (CUs). For each Vertex-CU, a batch of Vertex-IDs is sent to be processed
// based on the granularity. For example, if granularity is (8), each CU
// (Compute Units) would get eight vertex IDs in chunks.

uint32_t *strideIndexGenerator(uint32_t indexStart, uint32_t indexEnd, uint32_t granularity);

// CSR\_Index\_Generator
// ---------------------

// ### Input: array\_pointer, array\_size, offset, degree

// When reading the edge list of the Graph CSR structure, a sequence of
// Vertex-IDs is generated based on the edges\_index and the degree size of
// the processed vertex. The read engines can connect to the
// CSR\_Index\_Generator to acquire the neighbor IDs for further
// processing, in this scenario reading the data of the vertex neighbors.

uint32_t *CSRIndexGenerator(uint32_t *arrayPointer, uint32_t arraySize, uint32_t offset, uint32_t granularity);

// ALU\_Operation\_\<Mul, Add, Sub, Acc\>
// --------------------------------------

// ### Input: op1, op2, id

// A simple ALU reprogrammable pipeline is responsible for multiple basic
// arithmetic operations. Each output is coupled with an ID that can be
// used for writing the result to the correct index if needed.

uint32_t *ALUOperation(uint32_t op1, uint32_t op2, uint32_t id, uint32_t mode);

// Conditional\_Break\_\<GT, LT, EQ\>
// ----------------------------------

// ### Input: op1, op2

// A conditional statement module aims to break or stop the read/write
// engines from generating commands/sequences based on a trigger. The
// module is reprogrammable to implement Less Than (LT), Greater Than (GT),
// and Equal (EQ) operations.

uint32_t *conditionalBreak(uint32_t op1, uint32_t op2, uint32_t id, uint32_t mode);

// Conditional\_Filter\_\<GT, LT, EQ\>
// -----------------------------------

// Input: op1, op2
// ---------------

// Like Conditional\_Break, a filter would filter out results forwarded to
// other engines in the overlay based on a condition.

uint32_t *conditionalFilter(uint32_t op1, uint32_t op2, uint32_t id, uint32_t mode);


// Conditional\_Continue\_\<GT, LT, EQ\>
// -------------------------------------

// ### Input: op1, op2, id

// A conditional continue would mean for a specific command, a filter will
// be applied in order not to generate any subsequent dependent commands,
// for example, reads/writes correlated with a vertex ID.

uint32_t *conditionalContinue(uint32_t op1, uint32_t op2, uint32_t id, uint32_t mode);

#ifdef __cplusplus
}
#endif

#endif