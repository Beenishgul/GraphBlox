// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 0    mapping 2    cycles 10   None-NONE 0-num_vertices
// --------------------------------------------------------------------------------------
0x0000000D // entry 0    cacheline 0    offset 0    -- //  0  - Increment/Decrement
0x00000000 // entry 1    cacheline 0    offset 1    -- //  1  - Index_start
0x00000000 // entry 2    cacheline 0    offset 2    -- //  2  - Index_end
0x00000001 // entry 3    cacheline 0    offset 3    -- //  3  - Stride
0x80000002 // entry 4    cacheline 0    offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 5    cacheline 0    offset 5    -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 6    cacheline 0    offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 7    cacheline 0    offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 8    cacheline 0    offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 9    cacheline 0    offset 9    -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 1    mapping 5    cycles 6    None-None 0-0
// --------------------------------------------------------------------------------------
0x00000001 // entry 10   cacheline 0    offset 10   -- //  0  - alu_operation
0x00000003 // entry 11   cacheline 0    offset 11   -- //  1  - alu_mask
0x00000001 // entry 12   cacheline 0    offset 12   -- //  2  - const_mask
0x00000003 // entry 13   cacheline 0    offset 13   -- //  3  - const_value
0x00000041 // entry 14   cacheline 0    offset 14   -- //  4  - ops_mask
0xcf257000 // entry 15   cacheline 0    offset 15   -- //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 2    mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
0x00000001 // entry 16   cacheline 1    offset 0    -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 3    mapping 1    cycles 13   buffer_3-edges_idx 0-num_vertices
// --------------------------------------------------------------------------------------
0x00000000 // entry 17   cacheline 1    offset 1    -- //  0  - Increment/Decrement
0x00000000 // entry 18   cacheline 1    offset 2    -- //  1  - Index_start
0x00000033 // entry 19   cacheline 1    offset 3    -- //  2  - Index_end
0x00000001 // entry 20   cacheline 1    offset 4    -- //  3  - Stride
0x80000002 // entry 21   cacheline 1    offset 5    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 22   cacheline 1    offset 6    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 23   cacheline 1    offset 7    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 24   cacheline 1    offset 8    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 25   cacheline 1    offset 9    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 26   cacheline 1    offset 10   -- //  9  - BUFFER size
0x00000000 // entry 27   cacheline 1    offset 11   -- //  10 - const_mask
0x00000000 // entry 28   cacheline 1    offset 12   -- //  11 - const_value
0x00008412 // entry 29   cacheline 1    offset 13   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 4    mapping 4    cycles 2    None-None 0-0
// --------------------------------------------------------------------------------------
0x00000007 // entry 30   cacheline 1    offset 14   -- //  0  - merge mask (W:2)
0x00000000 // entry 31   cacheline 1    offset 15   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 5    mapping 1    cycles 13   buffer_1-out_degree 0-num_vertices
// --------------------------------------------------------------------------------------
0x00000000 // entry 32   cacheline 2    offset 0    -- //  0  - Increment/Decrement
0x00000000 // entry 33   cacheline 2    offset 1    -- //  1  - Index_start
0x00000033 // entry 34   cacheline 2    offset 2    -- //  2  - Index_end
0x00000001 // entry 35   cacheline 2    offset 3    -- //  3  - Stride
0x80000002 // entry 36   cacheline 2    offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 37   cacheline 2    offset 5    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 38   cacheline 2    offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 39   cacheline 2    offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 40   cacheline 2    offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 41   cacheline 2    offset 9    -- //  9  - BUFFER size
0x00000000 // entry 42   cacheline 2    offset 10   -- //  10 - const_mask
0x00000000 // entry 43   cacheline 2    offset 11   -- //  11 - const_value
0x00008412 // entry 44   cacheline 2    offset 12   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_7-auxiliary_1 0-num_vertices
// --------------------------------------------------------------------------------------
0x00000000 // entry 45   cacheline 2    offset 13   -- //  0  - Increment/Decrement
0x00000000 // entry 46   cacheline 2    offset 14   -- //  1  - Index_start
0x00000033 // entry 47   cacheline 2    offset 15   -- //  2  - Index_end
0x00000001 // entry 48   cacheline 3    offset 0    -- //  3  - Stride
0x80000002 // entry 49   cacheline 3    offset 1    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 50   cacheline 3    offset 2    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 51   cacheline 3    offset 3    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 52   cacheline 3    offset 4    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 53   cacheline 3    offset 5    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 54   cacheline 3    offset 6    -- //  9  - BUFFER size
0x00000000 // entry 55   cacheline 3    offset 7    -- //  10 - const_mask
0x00000000 // entry 56   cacheline 3    offset 8    -- //  11 - const_value
0x00008412 // entry 57   cacheline 3    offset 9    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 7    mapping 2    cycles 10   None-NONE 0-num_vertices
// --------------------------------------------------------------------------------------
0x0000000D // entry 58   cacheline 3    offset 10   -- //  0  - Increment/Decrement
0x00000000 // entry 59   cacheline 3    offset 11   -- //  1  - Index_start
0x00000000 // entry 60   cacheline 3    offset 12   -- //  2  - Index_end
0x00000001 // entry 61   cacheline 3    offset 13   -- //  3  - Stride
0x80000002 // entry 62   cacheline 3    offset 14   -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 63   cacheline 3    offset 15   -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 64   cacheline 4    offset 0    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 65   cacheline 4    offset 1    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 66   cacheline 4    offset 2    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 67   cacheline 4    offset 3    -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 8    mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
0x00000001 // entry 68   cacheline 4    offset 4    -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 9    mapping 2    cycles 10   buffer_4-edges_array_dest 0-num_edges
// --------------------------------------------------------------------------------------
0x0000000D // entry 69   cacheline 4    offset 5    -- //  0  - Increment/Decrement
0x00000000 // entry 70   cacheline 4    offset 6    -- //  1  - Index_start
0x00000000 // entry 71   cacheline 4    offset 7    -- //  2  - Index_end
0x00000001 // entry 72   cacheline 4    offset 8    -- //  3  - Stride
0x80000002 // entry 73   cacheline 4    offset 9    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 74   cacheline 4    offset 10   -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 75   cacheline 4    offset 11   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 76   cacheline 4    offset 12   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 77   cacheline 4    offset 13   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 78   cacheline 4    offset 14   -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
0x00000001 // entry 79   cacheline 4    offset 15   -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_3-edges_idx 0-num_vertices
// --------------------------------------------------------------------------------------
0x00000000 // entry 80   cacheline 5    offset 0    -- //  0  - Increment/Decrement
0x00000000 // entry 81   cacheline 5    offset 1    -- //  1  - Index_start
0x00000033 // entry 82   cacheline 5    offset 2    -- //  2  - Index_end
0x00000001 // entry 83   cacheline 5    offset 3    -- //  3  - Stride
0x80000002 // entry 84   cacheline 5    offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 85   cacheline 5    offset 5    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 86   cacheline 5    offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 87   cacheline 5    offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 88   cacheline 5    offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 89   cacheline 5    offset 9    -- //  9  - BUFFER size
0x00000000 // entry 90   cacheline 5    offset 10   -- //  10 - const_mask
0x00000000 // entry 91   cacheline 5    offset 11   -- //  11 - const_value
0x00008412 // entry 92   cacheline 5    offset 12   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 12   mapping 4    cycles 2    None-None 0-0
// --------------------------------------------------------------------------------------
0x00000007 // entry 93   cacheline 5    offset 13   -- //  0  - merge mask (W:2)
0x00000000 // entry 94   cacheline 5    offset 14   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 13   mapping 1    cycles 13   buffer_1-out_degree 0-num_vertices
// --------------------------------------------------------------------------------------
0x00000000 // entry 95   cacheline 5    offset 15   -- //  0  - Increment/Decrement
0x00000000 // entry 96   cacheline 6    offset 0    -- //  1  - Index_start
0x00000033 // entry 97   cacheline 6    offset 1    -- //  2  - Index_end
0x00000001 // entry 98   cacheline 6    offset 2    -- //  3  - Stride
0x80000002 // entry 99   cacheline 6    offset 3    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 100  cacheline 6    offset 4    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 101  cacheline 6    offset 5    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 102  cacheline 6    offset 6    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 103  cacheline 6    offset 7    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 104  cacheline 6    offset 8    -- //  9  - BUFFER size
0x00000000 // entry 105  cacheline 6    offset 9    -- //  10 - const_mask
0x00000000 // entry 106  cacheline 6    offset 10   -- //  11 - const_value
0x00008412 // entry 107  cacheline 6    offset 11   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 14   mapping 2    cycles 10   buffer_4-edges_array_dest 0-num_edges
// --------------------------------------------------------------------------------------
0x0000000D // entry 108  cacheline 6    offset 12   -- //  0  - Increment/Decrement
0x00000000 // entry 109  cacheline 6    offset 13   -- //  1  - Index_start
0x00000000 // entry 110  cacheline 6    offset 14   -- //  2  - Index_end
0x00000001 // entry 111  cacheline 6    offset 15   -- //  3  - Stride
0x80000002 // entry 112  cacheline 7    offset 0    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 113  cacheline 7    offset 1    -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 114  cacheline 7    offset 2    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 115  cacheline 7    offset 3    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 116  cacheline 7    offset 4    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 117  cacheline 7    offset 5    -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 15   mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
0x00000001 // entry 118  cacheline 7    offset 6    -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// Number of entries 119
