
GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay
===============================================================

Abstract
--------

FPGA reconfiguration time between accelerated graph processing
algorithms is becoming a top priority requirement. It is of prime
importance to rethink today\'s graph algorithm acceleration design on
FPGAs for faster reconfiguration between algorithms while maintaining
execution performance and custom memory optimizations. For instance, the
reconfiguration of the FPGA graph processing algorithms causes
substantial pauses to reprogram the FPGA chip when switching from one
graph algorithm to another, affecting the algorithm\'s critical path and
performance. Such a paradigm heavily exists in virtual systems that
demand generic support for graph processing to cover a wide range of
use-cases while being managed efficiently by the hypervisor. In this
work, we propose a coarse-grain overlay for graph processing GraphBlox. This
overlay extracts the typical access patterns in many graph algorithms
and abstracts them into domain-specific graph Processing Elements (PE)
interconnect. Compared to the classical FPGA ms-s reconfiguration time,
GraphBlox achieves ns-us reconfiguration time between graph algorithms. While
maintaining the performance and power optimizations, an FPGA provides.

![Figure 1: Graph fundamental Compressed Sparse
Row Matrix (CSR) structure](./fig/graphBlox/fig1.png "Figure 1: Graph fundamental Compressed Sparse
Row Matrix (CSR) structure")


Identifying Access Patterns and Control Flow in Graph Algorithms
----------------------------------------------------------------

Graph processing kernels share common behaviors. GraphBlox's primary purpose
is to abstract such access flows into engines for faster programmability
between graph algorithms instead of having a fixed accelerator. Such
overlay architecture reduces the reconfiguration time from typical FPGA
flow, taking ms-s into ns-us. Figure 2 and Figure 3 highlight the
Breadth-First Search (BFS) bottom-up approach graph algorithm
analysis and its correlation to the GraphBlox architecture design. For
instance, a graph algorithm needs to interact with the graph structure
commonly represented in the Compressed Sparse Row Matrix (CSR), as shown
in Figure 1. Such behaviors are abstracted into sequential accesses and
usually relate to accessing the graph CSR structure data, for example,
the degree, vertex offset data, and the neighbor list for the processed
vertex as shown in Figure 3 step A.

As illustrated in steps C and E, the graph property data is most often
accessed randomly and has high cache miss rates. Both behaviors will be
supported and optimized with specialized read/write engines in GraphBlox
architecture. Other behaviors such as mathematical operations and
branches are kept in a dataflow approach. As each vertex read/write
request is filtered or processed based on a conditional reprogrammable
module for each engine, while an ALU handles simple mathematical
operations if needed. Figure 4 displays the final analysis for BFS and
the proposed Processing Elements (PEs).

![Figure 2: Breadth-First Search (BFS) algorithm](./fig/graphBlox/fig2.png "Figure 2: Breadth-First Search (BFS) algorithm")


![Figure 3: BFS bottom-up approach, a graph
kernel contains identifiable behaviors that can be abstracted into FPGA
overlay engines.
](./fig/graphBlox/fig3.png "Figure 3: BFS bottom-up approach, a graph kernel contains identifiable behaviors that can be abstracted into FPGA
overlay engines.")


![Figure 4: Proposed Vertex Processing Elements
(PEs) for graph processing kernels.](./fig/graphBlox/fig4.png "Figure 4: Proposed Vertex Processing Elements (PEs) for graph processing kernels.")


GraphBlox Architecture 
------------------

Figure 5 illustrates an abstract overview of GraphBlox vertex-centric graph
processing overlay. The Vertex CU supports multiple programmable engines
and processing elements (PEs). These engines and PEs are bundled within
the Vertex CU, where each PE bundle is pipelined in a step manner. A PE
bundle contains read/write engines, conditional modules, ALU, and
arbitration units to forward the data to the next cluster.

Vertex CU clusters are hierarchically grouped for scalability, where
each set is handled by a level of arbitration that forwards/receives
commands from the memory interfaces. Vertex property data reuse or
atomic instruction is forwarded to the CXL interface cache. In contrast,
structure data or read-only data with low reuse are utilized via HBM.
Furthermore, a simple caching mechanism is provided on-chip for
read-only data with high reuse to enhance response time and reduce the
pressure on the HBM/CXL interfaces.

Figure 4 and Figure 6 showcase how BFS maps on each Vertex CU, step-A
vertex-IDs are scheduled to each CU and processed in a vertex-centric
manner. The first PE bundle is configured for step B to read the CSR
offset and other structural data. The conditional statement filters the
vertices visited from the next PE bundle in step C. Next, step D read
the graph neighbor list from the CSR structure. Finally, in steps E and
F, a conditional break halts the engine from processing the vertex
neighbor list and updates the frontier data.

![Figure 6: BFS algorithm on GraphBlox](./fig/graphBlox/fig6.png "Figure 6: BFS algorithm on GraphBlox")

GraphBlox Graph Description Language (GGDL)
======================================

GGDL is a description language that helps compile and port any graph
algorithm to GraphBlox graph processing overlay. This chapter describes some
of the features of GraphBlox architecture combined with a description
language that can be compiled to reprogram the graph overlay.

Serial\_Read\_Engine
--------------------

### Input :array\_pointer, array\_size, start\_read, end\_read, stride, granularity

The serial read engine sends read commands to the memory control layer.
Each read or write requests a chunk of data specified with the
"granularity" parameter -- alignment should be honored for a cache line.
The "stride" parameter sets the offset taken by each consecutive read;
strides should also honor alignment restrictions. This behavior is
related to reading CSR structure data, for example, reading the offsets
array.

Serial\_Write\_Engine
---------------------

### Input :array\_pointer, array\_size, index, granularity

The serial write engine sends coalesced write commands to the memory
control layer. Each write-request groups a chunk of data (group of
vertices) intended to be written in a serial pattern. The serial write
engine is simpler to design as it plans only to group serial data and
write them in single bursts depending on the "granularity" parameter.
This behavior can be found in iterative SpMV-based graph algorithms like
PageRank.

Random\_Read\_Engine / Random\_Write\_Engine
--------------------------------------------

### Input: array\_pointer, array\_size, index, granularity

A random read engine does not require a stride access pattern. Instead,
arbitrary fine-grain commands are sent straight to a caching element in
a fine-grained manner. Optimizations can occur on the caching level with
grouping or reordering. The main challenge would be designing an engine
that supports fine-grain accesses while balancing the design complexity
if such optimizations were to be kept.

Stride\_Index\_Generator
------------------------

### Input: index\_start, index\_end, stride, granularity

The stride index generator serves two purposes. First, it generates a
sequence of indices or Vertex-IDs scheduled to the Vertex Compute Units
(CUs). For each Vertex-CU, a batch of Vertex-IDs is sent to be processed
based on the granularity. For example, if granularity is (8), each CU
(Compute Units) would get eight vertex IDs in chunks.

CSR\_Index\_Generator
---------------------

### Input: array\_pointer, array\_size, offset, degree

When reading the edge list of the Graph CSR structure, a sequence of
Vertex-IDs is generated based on the edges\_index and the degree size of
the processed vertex. The read engines can connect to the
CSR\_Index\_Generator to acquire the neighbor IDs for further
processing, in this scenario reading the data of the vertex neighbors.

ALU\_Operation\_\<Mul, Add, Sub, Acc\>
--------------------------------------

### Input: op1, op2, id

A simple ALU reprogrammable pipeline is responsible for multiple basic
arithmetic operations. Each output is coupled with an ID that can be
used for writing the result to the correct index if needed.

Conditional\_Break\_\<GT, LT, EQ\>
----------------------------------

### Input: op1, op2

A conditional statement module aims to break or stop the read/write
engines from generating commands/sequences based on a trigger. The
module is reprogrammable to implement Less Than (LT), Greater Than (GT),
and Equal (EQ) operations.

Conditional\_Filter\_\<GT, LT, EQ\>
-----------------------------------

Input: op1, op2
---------------

Like Conditional\_Break, a filter would filter out results forwarded to
other engines in the overlay based on a condition.

Conditional\_Continue\_\<GT, LT, EQ\>
-------------------------------------

### Input: op1, op2, id

A conditional continue would mean for a specific command, a filter will
be applied in order not to generate any subsequent dependent commands,
for example, reads/writes correlated with a vertex ID.

Example Graph Algorithm GGDL Transformations
============================================

BFS
---

![Figure 7: Transforming BFS algorithm to GGDL](./fig/graphBlox/fig7.png "Figure 7: Transforming BFS algorithm to GGDL")