// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 0    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x0000000D // entry 0    cacheline 0    offset 0    -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
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
// Name ENGINE_FILTER_COND  ID 1    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 10   cacheline 0    offset 10   -- // --  0  - filter_operation
0x00000004 // entry 11   cacheline 0    offset 11   -- // --  1  - filter_mask
0x00000004 // entry 12   cacheline 0    offset 12   -- // --  2  - const_mask
0x00000001 // entry 13   cacheline 0    offset 13   -- // --  3  - const_value
0x00004821 // entry 14   cacheline 0    offset 14   -- // --  5  - ops_mask
0x00000001 // entry 15   cacheline 0    offset 15   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 16   cacheline 1    offset 0    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 17   cacheline 1    offset 1    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 18   cacheline 1    offset 2    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 2    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x0000000D // entry 19   cacheline 1    offset 3    -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
0x00000000 // entry 20   cacheline 1    offset 4    -- //  1  - Index_start
0x00000000 // entry 21   cacheline 1    offset 5    -- //  2  - Index_end
0x00000001 // entry 22   cacheline 1    offset 6    -- //  3  - Stride
0x80000002 // entry 23   cacheline 1    offset 7    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 24   cacheline 1    offset 8    -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 25   cacheline 1    offset 9    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 26   cacheline 1    offset 10   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 27   cacheline 1    offset 11   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 28   cacheline 1    offset 12   -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 3    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 29   cacheline 1    offset 13   -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 4    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 30   cacheline 1    offset 14   -- //  0  - Increment/Decrement
0x00000000 // entry 31   cacheline 1    offset 15   -- //  1  - Index_start
0x00000033 // entry 32   cacheline 2    offset 0    -- //  2  - Index_end
0x00000001 // entry 33   cacheline 2    offset 1    -- //  3  - Stride
0x80000002 // entry 34   cacheline 2    offset 2    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 35   cacheline 2    offset 3    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 36   cacheline 2    offset 4    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 37   cacheline 2    offset 5    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 38   cacheline 2    offset 6    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 39   cacheline 2    offset 7    -- //  9  - BUFFER size
0x00000000 // entry 40   cacheline 2    offset 8    -- //  10 - const_mask
0x00000000 // entry 41   cacheline 2    offset 9    -- //  11 - const_value
0x00008412 // entry 42   cacheline 2    offset 10   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 5    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 43   cacheline 2    offset 11   -- //  0  - merge mask (W:2)
0x00000000 // entry 44   cacheline 2    offset 12   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
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
// Name ENGINE_CSR_INDEX    ID 7    mapping 2    cycles 10   buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
0x0000000D // entry 58   cacheline 3    offset 10   -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
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
// Name ENGINE_FILTER_COND  ID 8    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 68   cacheline 4    offset 4    -- // --  0  - filter_operation
0x00000004 // entry 69   cacheline 4    offset 5    -- // --  1  - filter_mask
0x00000004 // entry 70   cacheline 4    offset 6    -- // --  2  - const_mask
0x00000001 // entry 71   cacheline 4    offset 7    -- // --  3  - const_value
0x00004821 // entry 72   cacheline 4    offset 8    -- // --  5  - ops_mask
0x00000001 // entry 73   cacheline 4    offset 9    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 74   cacheline 4    offset 10   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 75   cacheline 4    offset 11   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 76   cacheline 4    offset 12   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 9    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 77   cacheline 4    offset 13   -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 10   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 78   cacheline 4    offset 14   -- // --  0  - filter_operation
0x00000004 // entry 79   cacheline 4    offset 15   -- // --  1  - filter_mask
0x00000004 // entry 80   cacheline 5    offset 0    -- // --  2  - const_mask
0x00000001 // entry 81   cacheline 5    offset 1    -- // --  3  - const_value
0x00004821 // entry 82   cacheline 5    offset 2    -- // --  5  - ops_mask
0x00000001 // entry 83   cacheline 5    offset 3    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 84   cacheline 5    offset 4    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 85   cacheline 5    offset 5    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 86   cacheline 5    offset 6    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 11   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 87   cacheline 5    offset 7    -- //  0  - alu_operation
0x00000003 // entry 88   cacheline 5    offset 8    -- //  1  - alu_mask
0x00000001 // entry 89   cacheline 5    offset 9    -- //  2  - const_mask
0x00000003 // entry 90   cacheline 5    offset 10   -- //  3  - const_value
0x00000041 // entry 91   cacheline 5    offset 11   -- //  4  - ops_mask
0xcf257000 // entry 92   cacheline 5    offset 12   -- //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 12   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 93   cacheline 5    offset 13   -- //  0  - alu_operation
0x00000003 // entry 94   cacheline 5    offset 14   -- //  1  - alu_mask
0x00000001 // entry 95   cacheline 5    offset 15   -- //  2  - const_mask
0x00000003 // entry 96   cacheline 6    offset 0    -- //  3  - const_value
0x00000041 // entry 97   cacheline 6    offset 1    -- //  4  - ops_mask
0xcf257000 // entry 98   cacheline 6    offset 2    -- //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 13   mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 99   cacheline 6    offset 3    -- //  0  - Increment/Decrement
0x00000000 // entry 100  cacheline 6    offset 4    -- //  1  - Index_start
0x00000033 // entry 101  cacheline 6    offset 5    -- //  2  - Index_end
0x00000001 // entry 102  cacheline 6    offset 6    -- //  3  - Stride
0x80000002 // entry 103  cacheline 6    offset 7    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 104  cacheline 6    offset 8    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 105  cacheline 6    offset 9    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 106  cacheline 6    offset 10   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 107  cacheline 6    offset 11   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 108  cacheline 6    offset 12   -- //  9  - BUFFER size
0x00000000 // entry 109  cacheline 6    offset 13   -- //  10 - const_mask
0x00000000 // entry 110  cacheline 6    offset 14   -- //  11 - const_value
0x00008412 // entry 111  cacheline 6    offset 15   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 14   mapping 2    cycles 10   buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
0x0000000D // entry 112  cacheline 7    offset 0    -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
0x00000000 // entry 113  cacheline 7    offset 1    -- //  1  - Index_start
0x00000000 // entry 114  cacheline 7    offset 2    -- //  2  - Index_end
0x00000001 // entry 115  cacheline 7    offset 3    -- //  3  - Stride
0x80000002 // entry 116  cacheline 7    offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 117  cacheline 7    offset 5    -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 118  cacheline 7    offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 119  cacheline 7    offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 120  cacheline 7    offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 121  cacheline 7    offset 9    -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 15   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 122  cacheline 7    offset 10   -- // --  0  - filter_operation
0x00000004 // entry 123  cacheline 7    offset 11   -- // --  1  - filter_mask
0x00000004 // entry 124  cacheline 7    offset 12   -- // --  2  - const_mask
0x00000001 // entry 125  cacheline 7    offset 13   -- // --  3  - const_value
0x00004821 // entry 126  cacheline 7    offset 14   -- // --  5  - ops_mask
0x00000001 // entry 127  cacheline 7    offset 15   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 128  cacheline 8    offset 0    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 129  cacheline 8    offset 1    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 130  cacheline 8    offset 2    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 16   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 131  cacheline 8    offset 3    -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 17   mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 132  cacheline 8    offset 4    -- //  0  - Increment/Decrement
0x00000000 // entry 133  cacheline 8    offset 5    -- //  1  - Index_start
0x00000033 // entry 134  cacheline 8    offset 6    -- //  2  - Index_end
0x00000001 // entry 135  cacheline 8    offset 7    -- //  3  - Stride
0x80000002 // entry 136  cacheline 8    offset 8    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 137  cacheline 8    offset 9    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 138  cacheline 8    offset 10   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 139  cacheline 8    offset 11   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 140  cacheline 8    offset 12   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 141  cacheline 8    offset 13   -- //  9  - BUFFER size
0x00000000 // entry 142  cacheline 8    offset 14   -- //  10 - const_mask
0x00000000 // entry 143  cacheline 8    offset 15   -- //  11 - const_value
0x00008412 // entry 144  cacheline 9    offset 0    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 18   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 145  cacheline 9    offset 1    -- //  0  - merge mask (W:2)
0x00000000 // entry 146  cacheline 9    offset 2    -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 19   mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 147  cacheline 9    offset 3    -- //  0  - Increment/Decrement
0x00000000 // entry 148  cacheline 9    offset 4    -- //  1  - Index_start
0x00000033 // entry 149  cacheline 9    offset 5    -- //  2  - Index_end
0x00000001 // entry 150  cacheline 9    offset 6    -- //  3  - Stride
0x80000002 // entry 151  cacheline 9    offset 7    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 152  cacheline 9    offset 8    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 153  cacheline 9    offset 9    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 154  cacheline 9    offset 10   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 155  cacheline 9    offset 11   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 156  cacheline 9    offset 12   -- //  9  - BUFFER size
0x00000000 // entry 157  cacheline 9    offset 13   -- //  10 - const_mask
0x00000000 // entry 158  cacheline 9    offset 14   -- //  11 - const_value
0x00008412 // entry 159  cacheline 9    offset 15   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 20   mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 160  cacheline 10   offset 0    -- //  0  - Increment/Decrement
0x00000000 // entry 161  cacheline 10   offset 1    -- //  1  - Index_start
0x00000033 // entry 162  cacheline 10   offset 2    -- //  2  - Index_end
0x00000001 // entry 163  cacheline 10   offset 3    -- //  3  - Stride
0x80000002 // entry 164  cacheline 10   offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 165  cacheline 10   offset 5    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 166  cacheline 10   offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 167  cacheline 10   offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 168  cacheline 10   offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 169  cacheline 10   offset 9    -- //  9  - BUFFER size
0x00000000 // entry 170  cacheline 10   offset 10   -- //  10 - const_mask
0x00000000 // entry 171  cacheline 10   offset 11   -- //  11 - const_value
0x00008412 // entry 172  cacheline 10   offset 12   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 21   mapping 1    cycles 13   buffer_8-auxiliary_2 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 173  cacheline 10   offset 13   -- //  0  - Increment/Decrement
0x00000000 // entry 174  cacheline 10   offset 14   -- //  1  - Index_start
0x00000033 // entry 175  cacheline 10   offset 15   -- //  2  - Index_end
0x00000001 // entry 176  cacheline 11   offset 0    -- //  3  - Stride
0x80000002 // entry 177  cacheline 11   offset 1    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 178  cacheline 11   offset 2    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 179  cacheline 11   offset 3    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 180  cacheline 11   offset 4    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 181  cacheline 11   offset 5    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 182  cacheline 11   offset 6    -- //  9  - BUFFER size
0x00000000 // entry 183  cacheline 11   offset 7    -- //  10 - const_mask
0x00000000 // entry 184  cacheline 11   offset 8    -- //  11 - const_value
0x00008412 // entry 185  cacheline 11   offset 9    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 22   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 186  cacheline 11   offset 10   -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Template.Single.TC  <-- 
// Number of entries 187
