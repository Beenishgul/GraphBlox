[![Build Status](https://app.travis-ci.com/atmughrabi/GraphBlox.svg?token=L3reAtGHdEVVPvzcVqQ6&branch=main)](https://app.travis-ci.com/atmughrabi/GraphBlox)
[<p align="center"><img src="./04_docs/fig/logo.svg" width="200" ></p>](#GraphBlox-benchmark-suite)

GraphBlox: A Vertex Centric Re-Configurable Graph Processing Overlay
===============================================================

Abstract
--------

GraphBlox is a vertex-centric reconfigurable graph processing overlay for FPGAs. It is designed to address the challenges of graph processing on FPGAs, such as long reconfiguration time, limited memory bandwidth, and high power consumption.

* GraphBlox achieves its performance and efficiency by:
  * Abstracting common access patterns in graph algorithms into engines for faster programmability.
  * Providing a scalable and flexible architecture that can be customized to the specific needs of a graph algorithm.
  * Using a high-performance memory system that can efficiently access large graphs.
  * Implementing efficient dataflow and control flow mechanisms.

GraphBlox has been evaluated on a variety of graph algorithms, including breadth-first search (BFS), depth-first search (DFS), and single source shortest path (SSSP). It has shown significant performance improvements over state-of-the-art FPGA-based graph processing systems.

* The following are some of the key features of GraphBlox:
  * **Vertex-centric programming model**: GraphBlox uses a vertex-centric programming model, which is a natural fit for many graph algorithms. In this model, each vertex is processed independently, and the results of processing one vertex are used to process the next vertex.
  * **Reconfigurable engines**: GraphBlox provides a set of reconfigurable engines that can be used to implement the common access patterns in graph algorithms. This allows GraphBlox to be quickly and easily reconfigured for different graph algorithms.
  * **Scalable architecture**: GraphBlox is designed to be scalable to large graphs. It can be easily scaled up by adding more processing elements.
  * **High-performance memory system**: GraphBlox uses a high-performance memory system that can efficiently access large graphs. This is achieved by using a distributed memory system with a high bandwidth interconnect HBM.
  * **Efficient dataflow and control flow mechanisms**: GraphBlox uses efficient dataflow and control flow mechanisms to minimize the overhead of processing graphs. This is achieved by using a pipelined execution model and by avoiding unnecessary data movement.

GraphBlox is a promising new approach to graph processing on FPGAs. It has the potential to significantly improve the performance and efficiency of graph processing on FPGAs.

![Figure 1: Graph Overlay (GraphBlox) Contributions](./04_docs/fig/design/figure0.svg "Figure 1: Graph Overlay (GraphBlox) Contributions")

# GraphBlox Benchmark Suite

## Overview

![Figure 4: Proposed Vertex Processing Elements (PEs) for graph processing kernels.](./04_docs/fig/design/figure29.svg "Figure 4: Proposed Vertex Processing Elements (PEs) for graph processing kernels.")

![Figure 2: GraphBlox, adding engines to be used for different Graph Algorithms same time](./04_docs/fig/design/figure31.svg "Figure 3: GraphBlox, adding engines to be used for different Graph Algorithms same time")

# Installation and Dependencies

## Xilinx Dependencies

The design has been verified with the following software/hardware environment and tool chain versions:  
* Hardware and Platform for your Alveo card (you need both the deployment and development platforms):
  * Alveo U250: xilinx_u250_gen3x16_xdma_4_1_202210_1
  * Alveo U280: xilinx_u280_gen3x16_xdma_1_202211_1
    * XRT: 2.15.225
    * Vitis: 2023.1
    * Operating Systems:
      * Ubuntu 22.04 (See [Additional Requirements for Ubuntu](#cpu-dependencies))
      * GCC 11+
* Perl package installed for Verilog simulation (**required**)

## CPU Dependencies

### OpenMP

1. Judy Arrays
```console
user@host:~$ sudo apt-get install libjudy-dev
```
2. OpenMP is already a feature of the compiler, so this step is not necessary.
```console
user@host:~$ sudo apt-get install libomp-dev
```

# Running GraphBlox

## Setting up GraphBlox for Emulation - Example

1. Clone GraphBlox.
```console
user@host:~$ git clone https://github.com/atmughrabi/GraphBlox.git
```
2. From the home directory go to the GraphBlox directory:
```console
user@host:~$ cd GraphBlox/
```
3. Make the source code, package kernel, and generate Xilinxs IPs (AXI/FIFOs).
```console
user@host:~GraphBlox$ make
```
4. Running GraphBlox overlay emulation
    1. Make xclbin file for emulation (cycle accurate emualtion of hw) -- Modify TARGET=hw_emu in Makefile or pass it in CLI:
    ```console
    user@host:~GraphBlox$ make build-hw TARGET=hw_emu
    ```
    2. Run in emulation mode:
    ```console
    user@host:~GraphBlox$ make run-emu TARGET=hw_emu
    ```
    3. View emulation waves:
    ```console
    user@host:~GraphBlox$ make run-emu-waves TARGET=hw_emu
    ```

## Xilinx Flow [<img src="./04_docs/fig/xilinx_logo.png" height="45" align="right" >](https://xilinx.github.io/XRT/2022.1/html/index.html)

* You can pass parameters or modify `Makefile` parameters (easiest way) at GraphBlox root directory, to control the FPGA development flow and support.

| PARAMETER  | VALUE | FUNCTION |
| :--- | :--- | :--- |
| PART  | xcu250-figd2104-2L-e | Part matching u250 Alveo card |
| PLATFORM  | xilinx_u250_gen3x16_xdma_4_1_202210_1 | Platform matching u250 Alveo card |
| TARGET  | hw_emu | Build target, hw or hw_emu |
| XILINX_CTRL_MODE  | USER_MANAGED | ctrl mode, AP_CTRL_HS or AP_CTRL_CHAIN |
| KERNEL_NAME  | graphBlox_kernel | packaged kernel |
| DEVICE_INDEX  | 0 | FPGA device index |
| XCLBIN_PATH  | file.xclbin | .xclbin filepath |


### Simulation Mode

#### Refreshing graphBlox_ip and scripts into xilinx_project directory
1. When modifying graphBlox_ip and scripts directories, especially in `simulation mode` use the following rule - this makes sure that the updated scripts and Verilog code are copied to the active `xilinx_project` directory:
```console
user@host:~GraphBlox$ make gen-scripts-dir
```
#### Simulation graphBlox_ip flow

1. Generate Xilinx IPs:
```console
user@host:~GraphBlox$ make gen-vip
```
2. Run simulation on xsim:
```console
user@host:~GraphBlox$ make run-sim
```
3. View simulation waves:
```console
user@host:~GraphBlox$ make run-sim-wave
```
### Hardware Emulation Mode (TARGET=hw_emu)

1. Generate Xilinx IPs:
```console
user@host:~GraphBlox$ make gen-vip
```
2. Package GraphBlox kernel:
```console
user@host:~GraphBlox$ make package-kernel
```
3. Build binary for emulation:
```console
user@host:~GraphBlox$ make build-hw TARGET=hw_emu
```
4. Run GraphBlox on emulated hw:
```console
user@host:~GraphBlox$ make run-emu
```
5. View emulation waves:
```console
user@host:~GraphBlox$ make run-emu-wave
```
### Hardware Mode (TARGET=hw)

1. Generate Xilinx IPs:
```console
user@host:~GraphBlox$ make gen-vip
```
2. Package GraphBlox kernel:
```console
user@host:~GraphBlox$ make package-kernel
```
3. Build binary for FPGA:
```console
user@host:~GraphBlox$ make build-hw TARGET=hw
```
4. Run GraphBlox on taget fgpa:
```console
user@host:~GraphBlox$ make run-fpga
```
#### Generate reports in hardware mode (TARGET=hw)

1. Generate Timing, Resource utilization and power reports:
```console
user@host:~GraphBlox$ make report_metrics 
```

#### Open Project in Vivado GUI hardware or emulation mode (TARGET=hw/hw_emu)

1. Generate Vivado project:
```console
user@host:~GraphBlox$ make open-vivado-project
```

## CPU Flow [<img src="./04_docs/fig/openmp_logo.png" height="45" align="right" >](https://www.openmp.org/)

### Initial compilation for the Graph framework with OpenMP

1. The default compilation is `openmp` mode:
```console
user@host:~GraphBlox$ make
```
2. From the root directory you can modify the Makefile with the [(parameters)](#GraphBlox-options) you need for OpenMP:
```console
user@host:~GraphBlox$ make run
```
* You can pass parameters modifying `Makefile` parameters (easiest way) - cross reference with [(parameters)](#GraphBlox-options) to pass the correct values.


| PARAMETER  | FUNCTION | 
| :--- | :--- |
| ARGS  | arguments passed to graphBlox |

| PARAMETER  | FUNCTION | 
| :--- | :--- |
| *Graph Files Directory* |
| FILE_BIN  | graph edge-list location |
| FILE_LABEL  | graph edge-list reorder list | 

| PARAMETER  | FUNCTION | 
| :--- | :--- |
| *Graph Structures PreProcessing* |
| SORT_TYPE  | graph edge-list sort (count/radix) |
| DATA_STRUCTURES  | CSR,Segmented |
| REORDER_LAYER1  | Reorder graph for cache optimization |

| PARAMETER  | FUNCTION | 
| :--- | :--- |
| *Algorithms General* |
| ALGORITHMS  | BFS, PR, DFS, etc |
| PULL_PUSH  | Direction push,pull,hybrid |

| PARAMETER  | FUNCTION | 
| :--- | :--- |
| *Algorithms Specific* |
| ROOT  | source node for BFS, etc |
| TOLERANCE  | PR tolerance for convergence |
| NUM_ITERATIONS  | PR iterations or convergence |
| DELTA  | SSSP delta step |

| PARAMETER  | FUNCTION | 
| :--- | :--- |
| *General Performance* |
| NUM_THREADS_PRE  | number of threads for the preprocess step (graph sorting, generation) |
| NUM_THREADS_ALGO  | number of threads for the algorithm step (BFS,PR, etc) |
| NUM_THREADS_KER  | (Optional) number of threads for the algorithm kernel (BFS,PR, etc) |
| NUM_TRIALS  | number of trials for the same algorithms | 


# Graph structure Input (Edge list)

* If you open the Makefile you will see the convention for graph directories : `BENCHMARKS_DIR/GRAPH_NAME/graph.wbin`.
* `.bin` stands to unweighted edge list, `.wbin` stands for wighted, `In binary format`. (This is only a convention you don't have to use it)
* The reason behind converting the edge-list from text to binary, it is simply takes less space on the drive for large graphs, and easier to use with the `mmap` function.

| Source  | Dest | Weight (Optional) |
| :---: | :---: | :---: |
| 30  | 3  |  1 |
| 3  | 4  |  1 |

* Example:
* INPUT: (unweighted textual edge-list)
* ../BENCHMARKS_DIR/GRAPH_NAME/graph
 ```
  30    3
  3     4
  25    5
  25    7
  6     3
  4     2
  6     12
  6     8
  6     11
  8     22
  9     27

 ```
* convert to binary format and add random weights, for this example all the weights are `1`.
* `--graph-file-format` is the type of graph you are reading, `--convert-format` is the type of format you are converting to.
* NOTE: you can read the file from text format without the convert step. By adding `--graph-file-format 0` to the argument list. The default is `1` assuming it is binary. please check `--help` for better explanation.
* `--stats` is a flag that enables conversion. It used also for collecting stats about the graph (but this feature is on hold for now).
* (unweighted graph)
```console
user@host:~GraphBlox$ make convert
```
* OR (weighted graph)
```console
user@host:~GraphBlox$ make convert-w
```
* OR (weighted graph)
```console
user@host:~GraphBlox$ ./bin/graphBlox-openmp  --generate-weights --stats --graph-file-format=0 --convert-format=1 --graph-file=../BENCHMARKS_DIR/GRAPH_NAME/graph
```

* `Makefile` parameters

| PARAMETER  | FUNCTION | 
| :--- | :--- |
| *File Formats* |
| FILE_FORMAT  | the type of graph read |
| CONVERT_FORMAT  | the type of graph converted |


* OUTPUT: (weighted binary edge-list)
*  ../BENCHMARKS_DIR/GRAPH_NAME/graph.wbin
```
1e00 0000 0300 0000 0100 0000 0300 0000
0400 0000 0100 0000 1900 0000 0500 0000
0100 0000 1900 0000 0700 0000 0100 0000
0600 0000 0300 0000 0100 0000 0400 0000
0200 0000 0100 0000 0600 0000 0c00 0000
0100 0000 0600 0000 0800 0000 0100 0000
0600 0000 0b00 0000 0100 0000 0800 0000
1600 0000 0100 0000 0900 0000 1b00 0000
0100 0000
```


Identifying Access Patterns and Control Flow in Graph Algorithms
----------------------------------------------------------------

Graph processing kernels share common behaviors. GraphBlox's primary purpose
is to abstract such access flows into engines for faster programmability
between graph algorithms instead of having a fixed accelerator. Such
overlay architecture reduces the reconfiguration time from typical FPGA
flow, taking ms-s into ns-us. Figure 4 highlight the
Breadth-First Search (BFS) bottom-up approach graph algorithm
analysis and its correlation to the GraphBlox architecture design. For
instance, a graph algorithm needs to interact with the graph structure
commonly represented in the Compressed Sparse Row Matrix (CSR), as shown
in Figure 2. Such behaviors are abstracted into sequential accesses and
usually relate to accessing the graph CSR structure data, for example,
the degree, vertex offset data, and the neighbor list for the processed
vertex as shown in Figure 4 step A.

As illustrated in steps C and E, the graph property data is most often
accessed randomly and has high cache miss rates. Both behaviors will be
supported and optimized with specialized read/write engines in GraphBlox
architecture. Other behaviors such as mathematical operations and
branches are kept in a dataflow approach. As each vertex read/write
request is filtered or processed based on a conditional reprogrammable
module for each engine, while an ALU handles simple mathematical
operations if needed. Figure 4 displays the final analysis for BFS and
the proposed Processing Elements (PEs).

![Figure 4: Graph fundamental Compressed Sparse Row Matrix (CSR) structure](./04_docs/fig/design/figure2.svg "Figure 2: Graph fundamental Compressed Sparse Row Matrix (CSR) structure")


![Figure 5: BFS bottom-up approach, a graph kernel contains identifiable behaviors that can be abstracted into FPGA overlay engines. ](./04_docs/fig/design/figure4.svg "Figure 4: BFS bottom-up approach, a graph kernel contains identifiable behaviors that can be abstracted into FPGA overlay engines.")



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

![Figure 6: BFS algorithm on GraphBlox](./04_docs/fig/design/figure3.svg "Figure 6: BFS algorithm on GraphBlox")

GraphIt integration ... Comming soon. -- GraphBlox Graph Description Language (GGDL)
======================================

# GraphBlox Options

## GraphBlox Host

```
Usage: graphBlox-openmp [OPTION...]
            -f <graph file> -d [data structure] -a [algorithm] -r [root] -n
            [num threads] [-h -c -s -w]

GraphBlox is an open source graph processing framework, it is designed to be a
benchmarking suite for various graph processing algorithms using pure C.

   -a, --algorithm=[DEFAULT:[0]-BFS]
                             [0]-BFS, 
                             [1]-Page-rank, 
                             [2]-SSSP-DeltaStepping,
                             [3]-SSSP-BellmanFord, 
                             [4]-DFS,
                             [5]-SPMV,
                             [6]-Connected-Components,
                             [7]-Betweenness-Centrality, 
                             [8]-Triangle Counting,

  -b, --delta=[DEFAULT:1]    
                             SSSP Delta value [Default:1].

  -c, --convert-format=[DEFAULT:[1]-binary-edgeList]
                             [serialize flag must be on --serialize to write]
                             Serialize graph text format (edge list format) to
                             binary graph file on load example:-f <graph file>
                             -c this is specifically useful if you have Graph
                             CSR/Grid structure and want to save in a binary
                             file format to skip the preprocessing step for
                             future runs. 
                             [0]-text-edgeList, 
                             [1]-binary-edgeList,
                             [2]-graphCSR-binary.

  -C, --cache-size=<LLC>     
                             LLC cache size for MASK vertex reodering

  -d, --data-structure=[DEFAULT:[0]-CSR]
                             [0]-CSR, 
                             [1]-CSR Segmented (use cache-size parameter)

  -e, --tolerance=[EPSILON:0.0001]
                             Tolerance value of for page rank
                             [default:0.0001].

  -f, --graph-file=<FILE>    
                             Edge list represents the graph binary format to
                             run the algorithm textual format change
                             graph-file-format.

  -F, --labels-file=<FILE>   
                             Read and reorder vertex labels from a text file,
                             Specify the file name for the new graph reorder,
                             generated from Gorder, Rabbit-order, etc.

  -g, --bin-size=[SIZE:512]  
                             You bin vertices's histogram according to this
                             parameter, if you have a large graph you want to
                             illustrate.

  -i, --num-iterations=[DEFAULT:20]
                             Number of iterations for page rank to converge
                             [default:20] SSSP-BellmanFord [default:V-1].

  -j, --verbosity=[DEFAULT:[0:no stats output]
                             For now it controls the output of .perf file and
                             PageRank .stats (needs --stats enabled)
                             filesPageRank .stat [1:top-k results] [2:top-k
                             results and top-k ranked vertices listed.

  -k, --remove-duplicate     
                             Removers duplicate edges and self loops from the
                             graph.

  -K, --Kernel-num-threads=[DEFAULT:algo-num-threads]
                             Number of threads for graph processing kernel
                             (critical-path) (graph algorithm)

  -l, --light-reorder-l1=[DEFAULT:[0]-no-reordering]
  -L, --light-reorder-l2=[DEFAULT:[0]-no-reordering]
  -O, --light-reorder-l3=[DEFAULT:[0]-no-reordering]
                             Relabels the graph for better cache performance (l1,l2,l3)
                             (third layer). 
                             [0]-no-reordering, 
                             [1]-out-degree,
                             [2]-in-degree, 
                             [3]-(in+out)-degree, 
                             [4]-DBG-out,
                             [5]-DBG-in, 
                             [6]-HUBSort-out, 
                             [7]-HUBSort-in,
                             [8]-HUBCluster-out, 
                             [9]-HUBCluster-in,
                             [10]-(random)-degree,  
                             [11]-LoadFromFile (used for Rabbit order).

  -M, --mask-mode=[DEFAULT:[0:disabled]]
                             Encodes [0:disabled] the last two bits of
                             [1:out-degree]-Edgelist-labels
                             [2:in-degree]-Edgelist-labels or
                             [3:out-degree]-vertex-property-data
                             [4:in-degree]-vertex-property-data with hot/cold
                             hints [11:HOT]|[10:WARM]|[01:LUKEWARM]|[00:COLD]
                             to specialize caching. The algorithm needs to
                             support value unmask to work.

  -n, --pre-num-threads=[DEFAULT:MAX]
                             Number of threads for preprocessing (graph
                             structure) step 

  -N, --algo-num-threads=[DEFAULT:MAX]
                             Number of threads for graph processing (graph
                             algorithm)

  -o, --sort=[DEFAULT:[0]-radix-src]
                             [0]-radix-src, 
                             [1]-radix-src-dest, 
                             [2]-count-src,
                             [3]-count-src-dst.

  -p, --direction=[DEFAULT:[0]-PULL]
                             [0]-PULL, 
                             [1]-PUSH,
                             [2]-HYBRID. 

                             NOTE: Please consult the function switch table for each
                             algorithm.

  -r, --root=[DEFAULT:0]     
                             BFS, DFS, SSSP root

  -s, --symmetrize           
                             Symmetric graph, create a set of incoming edges.

  -S, --stats                
                             Write algorithm stats to file. same directory as
                             the graph.PageRank: Dumps top-k ranks matching
                             using QPR similarity metrics.

  -t, --num-trials=[DEFAULT:[1 Trial]]
                             Number of trials for whole run (graph algorithm
                             run) [default:1].

  -w, --generate-weights     
                             Load or Generate weights. Check ->graphConfig.h
                             #define WEIGHTED 1 beforehand then recompile using
                             this option.

  -x, --serialize            
                             Enable file conversion/serialization use with
                             --convert-format.

  -z, --graph-file-format=[DEFAULT:[1]-binary-edgeList]
                             Specify file format to be read, is it textual edge
                             list, or a binary file edge list. This is
                             specifically useful if you have Graph CSR/Grid
                             structure already saved in a binary file format to
                             skip the preprocessing step. 
                             [0]-text edgeList,
                             [1]-binary edgeList, 
                             [2]-graphCSR binary.

  -?, --help                 Give this help list
      --usage                Give a short usage message
  -V, --version              Print program version


```
## GraphBlox Device

```
Usage: graphBlox-openmp [OPTION...]
            -m <xclbin file> -q [device-index=0]
   -Q, --kernel-name=[DEFAULT:NULL]
                             Kernel package name.

   -q, --device-index=[DEFAULT:0]
                             Device ID of your target card use "xbutil list"
                             command.

   -m, --xclbin-path=[DEFAULT:NULL]
                             Hardware overlay (XCLBIN) file for hw or hw_emu
                             mode.


```

# GraphBlox Organization

```console
.
├── 00_make
├── 01_host
│   ├── include
│   │   ├── algorithms
│   │   │   ├── ggdl
│   │   │   └── openmp
│   │   ├── config
│   │   ├── preprocess
│   │   ├── structures
│   │   ├── utils_fpga_cpp
│   │   └── utils_graph
│   └── src
│       ├── algorithms
│       │   ├── ggdl
│       │   └── openmp
│       ├── config
│       ├── main
│       ├── preprocess
│       ├── structures
│       ├── tests_c
│       ├── tests_cpp
│       ├── utils_fpga_cpp
│       └── utils_graph
├── 02_device
│   ├── hls
│   │   ├── include
│   │   │   ├── config
│   │   │   └── pkg
│   │   └── src
│   │       ├── engines
│   │       └── testbench
│   │           └── graphBlox
│   ├── ol
│   │   └── GraphBlox
│   │       ├── Engines
│   │       │   ├── Templates.json
│   │       │   └── Templates.ol
│   │       ├── Full
│   │       │   ├── Full.json
│   │       │   ├── Full.ol
│   │       │   └── Templates
│   │       ├── Lite
│   │       │   ├── Lite.json
│   │       │   ├── Lite.ol
│   │       │   └── Templates
│   │       └── Single
│   │           ├── Single.json
│   │           ├── Single.ol
│   │           └── Templates
│   ├── rtl
│   │   ├── bundle
│   │   ├── control
│   │   ├── cu
│   │   ├── engines
│   │   │   ├── engine_alu_ops
│   │   │   ├── engine_csr_index
│   │   │   ├── engine_cu_setup
│   │   │   ├── engine_filter_cond
│   │   │   ├── engine_forward_data
│   │   │   ├── engine_m_axi
│   │   │   ├── engine_merge_data
│   │   │   ├── engine_pipeline
│   │   │   ├── engine_read_write
│   │   │   └── engine_template
│   │   ├── kernel
│   │   ├── lane
│   │   ├── memory
│   │   │   ├── cache
│   │   │   │   └── iob_include
│   │   │   └── sram_axi
│   │   │       └── include
│   │   ├── pkg
│   │   ├── testbench
│   │   │   ├── integration
│   │   │   └── unit
│   │   │       ├── alu_operations
│   │   │       ├── arbiter
│   │   │       ├── bus_arbiter
│   │   │       ├── conditional_break
│   │   │       ├── conditional_continue
│   │   │       ├── conditional_filter
│   │   │       ├── integration_dual_ch
│   │   │       ├── kernel_setup
│   │   │       ├── random_read_engine
│   │   │       ├── random_write_engine
│   │   │       ├── serial_read_engine
│   │   │       ├── serial_write_engine
│   │   │       └── stride_index_generator
│   │   ├── top
│   │   └── utils
│   │       ├── arbiter
│   │       ├── counter
│   │       ├── fifo
│   │       ├── include
│   │       │   ├── global
│   │       │   ├── initialize
│   │       │   ├── mapping
│   │       │   ├── parameters
│   │       │   ├── portmaps
│   │       │   ├── testbench
│   │       │   └── topology
│   │       └── slice
│   └── utils
│       ├── utils.pl
│       ├── utils.py
│       ├── utils.sh
│       ├── utils.tcl
│       ├── utils.wcfg
│       └── utils.xdc
│           ├── U250
│           ├── U280
│           └── U55
├── 03_data
│   ├── LAW
│   │   ├── LAW-amazon-2008
│   │   ├── LAW-cnr-2000
│   │   ├── LAW-dblp-2010
│   │   └── LAW-enron
│   └── TEST
│       ├── graphbrew
│       ├── test
│       ├── v300_e2730
│       └── v51_e1021
└── 04_docs
    └── fig
        ├── datastructures
        └── graphBlox


```

# Tasks TODO:

- [x] Finish preprocessing sort
  - [x] Radix sort
- [x] Finish preprocessing Graph Data-structures
  - [x] CSR   (Compressed Sparse Row)
- [x] Add Light weight reordering
- [x] Finish graph algorithms suite OpenMP
  - [x] BFS   (Breadth First Search)
  - [x] PR    (Page-Rank)
  - [x] DFS   (Depth First Search)
  - [x] SSSP  (BellmanFord)
  - [x] SPMV  (Sparse Matrix Vector Multiplication)
  - [x] CC    (Connected Components)
  - [x] TC    (Triangle Counting)
  - [x] BC    (Betweenness Centrality)
- [x] Finish graph algorithms suite GraphBlox
  - [x] BFS   (Breadth First Search)
  - [x] PR    (Page-Rank)
  - [ ] DFS   (Depth First Search)
  - [ ] SSSP  (BellmanFord)
  - [x] SPMV  (Sparse Matrix Vector Multiplication)
  - [x] CC    (Connected Components)
  - [x] TC    (Triangle Counting)
  - [ ] BC    (Betweenness Centrality)
- [x] Finish graph algorithms suite GraphBlox FPGA
  - [x] BFS   (Breadth First Search)
  - [x] PR    (Page-Rank)
  - [ ] DFS   (Depth First Search)
  - [ ] SSSP  (BellmanFord)
  - [x] SPMV  (Sparse Matrix Vector Multiplication)
  - [x] CC    (Connected Components)
  - [x] TC    (Triangle Counting)
  - [ ] BC    (Betweenness Centrality)
- [x] Support testing


Report bugs to:
- <atmughrabi@gmail.com>
- <atmughra@virginia.edu>
[<p align="right"> <img src="./04_docs/fig/logo.svg" width="100" ></p>](#GraphBlox-benchmark-suite)