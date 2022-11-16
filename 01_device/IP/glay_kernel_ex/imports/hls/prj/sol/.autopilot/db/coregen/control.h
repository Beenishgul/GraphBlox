// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 4  - ap_continue (Read/Write/SC)
//        bit 7  - auto_restart (Read/Write)
//        bit 9  - interrupt (Read)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/COR)
//        bit 0 - ap_done (Read/COR)
//        bit 1 - ap_ready (Read/COR)
//        others - reserved
// 0x10 : Data signal of graph_csr_struct
//        bit 31~0 - graph_csr_struct[31:0] (Read/Write)
// 0x14 : Data signal of graph_csr_struct
//        bit 31~0 - graph_csr_struct[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of vertex_out_degree
//        bit 31~0 - vertex_out_degree[31:0] (Read/Write)
// 0x20 : Data signal of vertex_out_degree
//        bit 31~0 - vertex_out_degree[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of vertex_in_degree
//        bit 31~0 - vertex_in_degree[31:0] (Read/Write)
// 0x2c : Data signal of vertex_in_degree
//        bit 31~0 - vertex_in_degree[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of vertex_edges_idx
//        bit 31~0 - vertex_edges_idx[31:0] (Read/Write)
// 0x38 : Data signal of vertex_edges_idx
//        bit 31~0 - vertex_edges_idx[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of edges_array_weight
//        bit 31~0 - edges_array_weight[31:0] (Read/Write)
// 0x44 : Data signal of edges_array_weight
//        bit 31~0 - edges_array_weight[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of edges_array_src
//        bit 31~0 - edges_array_src[31:0] (Read/Write)
// 0x50 : Data signal of edges_array_src
//        bit 31~0 - edges_array_src[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of edges_array_dest
//        bit 31~0 - edges_array_dest[31:0] (Read/Write)
// 0x5c : Data signal of edges_array_dest
//        bit 31~0 - edges_array_dest[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of auxiliary_1
//        bit 31~0 - auxiliary_1[31:0] (Read/Write)
// 0x68 : Data signal of auxiliary_1
//        bit 31~0 - auxiliary_1[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of auxiliary_2
//        bit 31~0 - auxiliary_2[31:0] (Read/Write)
// 0x74 : Data signal of auxiliary_2
//        bit 31~0 - auxiliary_2[63:32] (Read/Write)
// 0x78 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define CONTROL_ADDR_AP_CTRL                 0x00
#define CONTROL_ADDR_GIE                     0x04
#define CONTROL_ADDR_IER                     0x08
#define CONTROL_ADDR_ISR                     0x0c
#define CONTROL_ADDR_GRAPH_CSR_STRUCT_DATA   0x10
#define CONTROL_BITS_GRAPH_CSR_STRUCT_DATA   64
#define CONTROL_ADDR_VERTEX_OUT_DEGREE_DATA  0x1c
#define CONTROL_BITS_VERTEX_OUT_DEGREE_DATA  64
#define CONTROL_ADDR_VERTEX_IN_DEGREE_DATA   0x28
#define CONTROL_BITS_VERTEX_IN_DEGREE_DATA   64
#define CONTROL_ADDR_VERTEX_EDGES_IDX_DATA   0x34
#define CONTROL_BITS_VERTEX_EDGES_IDX_DATA   64
#define CONTROL_ADDR_EDGES_ARRAY_WEIGHT_DATA 0x40
#define CONTROL_BITS_EDGES_ARRAY_WEIGHT_DATA 64
#define CONTROL_ADDR_EDGES_ARRAY_SRC_DATA    0x4c
#define CONTROL_BITS_EDGES_ARRAY_SRC_DATA    64
#define CONTROL_ADDR_EDGES_ARRAY_DEST_DATA   0x58
#define CONTROL_BITS_EDGES_ARRAY_DEST_DATA   64
#define CONTROL_ADDR_AUXILIARY_1_DATA        0x64
#define CONTROL_BITS_AUXILIARY_1_DATA        64
#define CONTROL_ADDR_AUXILIARY_2_DATA        0x70
#define CONTROL_BITS_AUXILIARY_2_DATA        64
