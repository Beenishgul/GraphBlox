// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 0    mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 0    cacheline 0    offset 0    -- //  0  - Increment/Decrement
0x00000000 // entry 1    cacheline 0    offset 1    -- //  1  - Index_start
0x00000033 // entry 2    cacheline 0    offset 2    -- //  2  - Index_end
0x00000001 // entry 3    cacheline 0    offset 3    -- //  3  - Stride
0x80000002 // entry 4    cacheline 0    offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 5    cacheline 0    offset 5    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 6    cacheline 0    offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 7    cacheline 0    offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 8    cacheline 0    offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 9    cacheline 0    offset 9    -- //  9  - BUFFER size
0x00000000 // entry 10   cacheline 0    offset 10   -- //  10 - const_mask
0x00000000 // entry 11   cacheline 0    offset 11   -- //  11 - const_value
0x00008412 // entry 12   cacheline 0    offset 12   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 1    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 13   cacheline 0    offset 13   -- //  0  - merge mask (W:2)
0x00000000 // entry 14   cacheline 0    offset 14   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 2    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 15   cacheline 0    offset 15   -- // --  0  - filter_operation
0x00000004 // entry 16   cacheline 1    offset 0    -- // --  1  - filter_mask
0x00000004 // entry 17   cacheline 1    offset 1    -- // --  2  - const_mask
0x00000001 // entry 18   cacheline 1    offset 2    -- // --  3  - const_value
0x00004821 // entry 19   cacheline 1    offset 3    -- // --  5  - ops_mask
0x00000001 // entry 20   cacheline 1    offset 4    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 21   cacheline 1    offset 5    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 22   cacheline 1    offset 6    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 23   cacheline 1    offset 7    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 3    mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 24   cacheline 1    offset 8    -- //  0  - Increment/Decrement
0x00000000 // entry 25   cacheline 1    offset 9    -- //  1  - Index_start
0x00000033 // entry 26   cacheline 1    offset 10   -- //  2  - Index_end
0x00000001 // entry 27   cacheline 1    offset 11   -- //  3  - Stride
0x80000002 // entry 28   cacheline 1    offset 12   -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 29   cacheline 1    offset 13   -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 30   cacheline 1    offset 14   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 31   cacheline 1    offset 15   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 32   cacheline 2    offset 0    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 33   cacheline 2    offset 1    -- //  9  - BUFFER size
0x00000000 // entry 34   cacheline 2    offset 2    -- //  10 - const_mask
0x00000000 // entry 35   cacheline 2    offset 3    -- //  11 - const_value
0x00008412 // entry 36   cacheline 2    offset 4    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 4    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 37   cacheline 2    offset 5    -- //  0  - merge mask (W:2)
0x00000000 // entry 38   cacheline 2    offset 6    -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 5    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 39   cacheline 2    offset 7    -- // --  0  - filter_operation
0x00000004 // entry 40   cacheline 2    offset 8    -- // --  1  - filter_mask
0x00000004 // entry 41   cacheline 2    offset 9    -- // --  2  - const_mask
0x00000001 // entry 42   cacheline 2    offset 10   -- // --  3  - const_value
0x00004821 // entry 43   cacheline 2    offset 11   -- // --  5  - ops_mask
0x00000001 // entry 44   cacheline 2    offset 12   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 45   cacheline 2    offset 13   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 46   cacheline 2    offset 14   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 47   cacheline 2    offset 15   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 48   cacheline 3    offset 0    -- //  0  - Increment/Decrement
0x00000000 // entry 49   cacheline 3    offset 1    -- //  1  - Index_start
0x00000033 // entry 50   cacheline 3    offset 2    -- //  2  - Index_end
0x00000001 // entry 51   cacheline 3    offset 3    -- //  3  - Stride
0x80000002 // entry 52   cacheline 3    offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 53   cacheline 3    offset 5    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 54   cacheline 3    offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 55   cacheline 3    offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 56   cacheline 3    offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 57   cacheline 3    offset 9    -- //  9  - BUFFER size
0x00000000 // entry 58   cacheline 3    offset 10   -- //  10 - const_mask
0x00000000 // entry 59   cacheline 3    offset 11   -- //  11 - const_value
0x00008412 // entry 60   cacheline 3    offset 12   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 7    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 61   cacheline 3    offset 13   -- //  0  - merge mask (W:2)
0x00000000 // entry 62   cacheline 3    offset 14   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 8    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 63   cacheline 3    offset 15   -- // --  0  - filter_operation
0x00000004 // entry 64   cacheline 4    offset 0    -- // --  1  - filter_mask
0x00000004 // entry 65   cacheline 4    offset 1    -- // --  2  - const_mask
0x00000001 // entry 66   cacheline 4    offset 2    -- // --  3  - const_value
0x00004821 // entry 67   cacheline 4    offset 3    -- // --  5  - ops_mask
0x00000001 // entry 68   cacheline 4    offset 4    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 69   cacheline 4    offset 5    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 70   cacheline 4    offset 6    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 71   cacheline 4    offset 7    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 9    mapping 2    cycles 10   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x0000000D // entry 72   cacheline 4    offset 8    -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
0x00000000 // entry 73   cacheline 4    offset 9    -- //  1  - Index_start
0x00000000 // entry 74   cacheline 4    offset 10   -- //  2  - Index_end
0x00000001 // entry 75   cacheline 4    offset 11   -- //  3  - Stride
0x80000002 // entry 76   cacheline 4    offset 12   -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 77   cacheline 4    offset 13   -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 78   cacheline 4    offset 14   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 79   cacheline 4    offset 15   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 80   cacheline 5    offset 0    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 81   cacheline 5    offset 1    -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 10   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 82   cacheline 5    offset 2    -- // --  0  - filter_operation
0x00000004 // entry 83   cacheline 5    offset 3    -- // --  1  - filter_mask
0x00000004 // entry 84   cacheline 5    offset 4    -- // --  2  - const_mask
0x00000001 // entry 85   cacheline 5    offset 5    -- // --  3  - const_value
0x00004821 // entry 86   cacheline 5    offset 6    -- // --  5  - ops_mask
0x00000001 // entry 87   cacheline 5    offset 7    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 88   cacheline 5    offset 8    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 89   cacheline 5    offset 9    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 90   cacheline 5    offset 10   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 11   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 91   cacheline 5    offset 11   -- //  0  - alu_operation
0x00000003 // entry 92   cacheline 5    offset 12   -- //  1  - alu_mask
0x00000001 // entry 93   cacheline 5    offset 13   -- //  2  - const_mask
0x00000003 // entry 94   cacheline 5    offset 14   -- //  3  - const_value
0x00000041 // entry 95   cacheline 5    offset 15   -- //  4  - ops_mask
0xcf257000 // entry 96   cacheline 6    offset 0    -- //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 12   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 97   cacheline 6    offset 1    -- // --  0  - filter_operation
0x00000004 // entry 98   cacheline 6    offset 2    -- // --  1  - filter_mask
0x00000004 // entry 99   cacheline 6    offset 3    -- // --  2  - const_mask
0x00000001 // entry 100  cacheline 6    offset 4    -- // --  3  - const_value
0x00004821 // entry 101  cacheline 6    offset 5    -- // --  5  - ops_mask
0x00000001 // entry 102  cacheline 6    offset 6    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 103  cacheline 6    offset 7    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 104  cacheline 6    offset 8    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 105  cacheline 6    offset 9    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 13   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 106  cacheline 6    offset 10   -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 14   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 107  cacheline 6    offset 11   -- // --  0  - filter_operation
0x00000004 // entry 108  cacheline 6    offset 12   -- // --  1  - filter_mask
0x00000004 // entry 109  cacheline 6    offset 13   -- // --  2  - const_mask
0x00000001 // entry 110  cacheline 6    offset 14   -- // --  3  - const_value
0x00004821 // entry 111  cacheline 6    offset 15   -- // --  5  - ops_mask
0x00000001 // entry 112  cacheline 7    offset 0    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 113  cacheline 7    offset 1    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 114  cacheline 7    offset 2    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 115  cacheline 7    offset 3    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 15   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 116  cacheline 7    offset 4    -- //  0  - Increment/Decrement
0x00000000 // entry 117  cacheline 7    offset 5    -- //  1  - Index_start
0x00000033 // entry 118  cacheline 7    offset 6    -- //  2  - Index_end
0x00000001 // entry 119  cacheline 7    offset 7    -- //  3  - Stride
0x80000002 // entry 120  cacheline 7    offset 8    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 121  cacheline 7    offset 9    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 122  cacheline 7    offset 10   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 123  cacheline 7    offset 11   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 124  cacheline 7    offset 12   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 125  cacheline 7    offset 13   -- //  9  - BUFFER size
0x00000000 // entry 126  cacheline 7    offset 14   -- //  10 - const_mask
0x00000000 // entry 127  cacheline 7    offset 15   -- //  11 - const_value
0x00008412 // entry 128  cacheline 8    offset 0    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 16   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 129  cacheline 8    offset 1    -- //  0  - merge mask (W:2)
0x00000000 // entry 130  cacheline 8    offset 2    -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 17   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 131  cacheline 8    offset 3    -- // --  0  - filter_operation
0x00000004 // entry 132  cacheline 8    offset 4    -- // --  1  - filter_mask
0x00000004 // entry 133  cacheline 8    offset 5    -- // --  2  - const_mask
0x00000001 // entry 134  cacheline 8    offset 6    -- // --  3  - const_value
0x00004821 // entry 135  cacheline 8    offset 7    -- // --  5  - ops_mask
0x00000001 // entry 136  cacheline 8    offset 8    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 137  cacheline 8    offset 9    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 138  cacheline 8    offset 10   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 139  cacheline 8    offset 11   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 18   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 140  cacheline 8    offset 12   -- //  0  - Increment/Decrement
0x00000000 // entry 141  cacheline 8    offset 13   -- //  1  - Index_start
0x00000033 // entry 142  cacheline 8    offset 14   -- //  2  - Index_end
0x00000001 // entry 143  cacheline 8    offset 15   -- //  3  - Stride
0x80000002 // entry 144  cacheline 9    offset 0    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 145  cacheline 9    offset 1    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 146  cacheline 9    offset 2    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 147  cacheline 9    offset 3    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 148  cacheline 9    offset 4    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 149  cacheline 9    offset 5    -- //  9  - BUFFER size
0x00000000 // entry 150  cacheline 9    offset 6    -- //  10 - const_mask
0x00000000 // entry 151  cacheline 9    offset 7    -- //  11 - const_value
0x00008412 // entry 152  cacheline 9    offset 8    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 19   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 153  cacheline 9    offset 9    -- //  0  - merge mask (W:2)
0x00000000 // entry 154  cacheline 9    offset 10   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 20   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 155  cacheline 9    offset 11   -- // --  0  - filter_operation
0x00000004 // entry 156  cacheline 9    offset 12   -- // --  1  - filter_mask
0x00000004 // entry 157  cacheline 9    offset 13   -- // --  2  - const_mask
0x00000001 // entry 158  cacheline 9    offset 14   -- // --  3  - const_value
0x00004821 // entry 159  cacheline 9    offset 15   -- // --  5  - ops_mask
0x00000001 // entry 160  cacheline 10   offset 0    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 161  cacheline 10   offset 1    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 162  cacheline 10   offset 2    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 163  cacheline 10   offset 3    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 21   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 164  cacheline 10   offset 4    -- //  0  - Increment/Decrement
0x00000000 // entry 165  cacheline 10   offset 5    -- //  1  - Index_start
0x00000033 // entry 166  cacheline 10   offset 6    -- //  2  - Index_end
0x00000001 // entry 167  cacheline 10   offset 7    -- //  3  - Stride
0x80000002 // entry 168  cacheline 10   offset 8    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 169  cacheline 10   offset 9    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 170  cacheline 10   offset 10   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 171  cacheline 10   offset 11   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 172  cacheline 10   offset 12   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 173  cacheline 10   offset 13   -- //  9  - BUFFER size
0x00000000 // entry 174  cacheline 10   offset 14   -- //  10 - const_mask
0x00000000 // entry 175  cacheline 10   offset 15   -- //  11 - const_value
0x00008412 // entry 176  cacheline 11   offset 0    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 22   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 177  cacheline 11   offset 1    -- //  0  - merge mask (W:2)
0x00000000 // entry 178  cacheline 11   offset 2    -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 23   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 179  cacheline 11   offset 3    -- // --  0  - filter_operation
0x00000004 // entry 180  cacheline 11   offset 4    -- // --  1  - filter_mask
0x00000004 // entry 181  cacheline 11   offset 5    -- // --  2  - const_mask
0x00000001 // entry 182  cacheline 11   offset 6    -- // --  3  - const_value
0x00004821 // entry 183  cacheline 11   offset 7    -- // --  5  - ops_mask
0x00000001 // entry 184  cacheline 11   offset 8    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 185  cacheline 11   offset 9    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 186  cacheline 11   offset 10   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 187  cacheline 11   offset 11   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 24   mapping 2    cycles 10   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x0000000D // entry 188  cacheline 11   offset 12   -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
0x00000000 // entry 189  cacheline 11   offset 13   -- //  1  - Index_start
0x00000000 // entry 190  cacheline 11   offset 14   -- //  2  - Index_end
0x00000001 // entry 191  cacheline 11   offset 15   -- //  3  - Stride
0x80000002 // entry 192  cacheline 12   offset 0    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 193  cacheline 12   offset 1    -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 194  cacheline 12   offset 2    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 195  cacheline 12   offset 3    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 196  cacheline 12   offset 4    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 197  cacheline 12   offset 5    -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 25   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 198  cacheline 12   offset 6    -- // --  0  - filter_operation
0x00000004 // entry 199  cacheline 12   offset 7    -- // --  1  - filter_mask
0x00000004 // entry 200  cacheline 12   offset 8    -- // --  2  - const_mask
0x00000001 // entry 201  cacheline 12   offset 9    -- // --  3  - const_value
0x00004821 // entry 202  cacheline 12   offset 10   -- // --  5  - ops_mask
0x00000001 // entry 203  cacheline 12   offset 11   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 204  cacheline 12   offset 12   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 205  cacheline 12   offset 13   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 206  cacheline 12   offset 14   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 26   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 207  cacheline 12   offset 15   -- //  0  - alu_operation
0x00000003 // entry 208  cacheline 13   offset 0    -- //  1  - alu_mask
0x00000001 // entry 209  cacheline 13   offset 1    -- //  2  - const_mask
0x00000003 // entry 210  cacheline 13   offset 2    -- //  3  - const_value
0x00000041 // entry 211  cacheline 13   offset 3    -- //  4  - ops_mask
0xcf257000 // entry 212  cacheline 13   offset 4    -- //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 27   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 213  cacheline 13   offset 5    -- // --  0  - filter_operation
0x00000004 // entry 214  cacheline 13   offset 6    -- // --  1  - filter_mask
0x00000004 // entry 215  cacheline 13   offset 7    -- // --  2  - const_mask
0x00000001 // entry 216  cacheline 13   offset 8    -- // --  3  - const_value
0x00004821 // entry 217  cacheline 13   offset 9    -- // --  5  - ops_mask
0x00000001 // entry 218  cacheline 13   offset 10   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 219  cacheline 13   offset 11   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 220  cacheline 13   offset 12   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 221  cacheline 13   offset 13   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 28   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 222  cacheline 13   offset 14   -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 29   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 223  cacheline 13   offset 15   -- // --  0  - filter_operation
0x00000004 // entry 224  cacheline 14   offset 0    -- // --  1  - filter_mask
0x00000004 // entry 225  cacheline 14   offset 1    -- // --  2  - const_mask
0x00000001 // entry 226  cacheline 14   offset 2    -- // --  3  - const_value
0x00004821 // entry 227  cacheline 14   offset 3    -- // --  5  - ops_mask
0x00000001 // entry 228  cacheline 14   offset 4    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 229  cacheline 14   offset 5    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 230  cacheline 14   offset 6    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 231  cacheline 14   offset 7    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 30   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 232  cacheline 14   offset 8    -- //  0  - Increment/Decrement
0x00000000 // entry 233  cacheline 14   offset 9    -- //  1  - Index_start
0x00000033 // entry 234  cacheline 14   offset 10   -- //  2  - Index_end
0x00000001 // entry 235  cacheline 14   offset 11   -- //  3  - Stride
0x80000002 // entry 236  cacheline 14   offset 12   -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 237  cacheline 14   offset 13   -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 238  cacheline 14   offset 14   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 239  cacheline 14   offset 15   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 240  cacheline 15   offset 0    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 241  cacheline 15   offset 1    -- //  9  - BUFFER size
0x00000000 // entry 242  cacheline 15   offset 2    -- //  10 - const_mask
0x00000000 // entry 243  cacheline 15   offset 3    -- //  11 - const_value
0x00008412 // entry 244  cacheline 15   offset 4    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 31   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 245  cacheline 15   offset 5    -- //  0  - merge mask (W:2)
0x00000000 // entry 246  cacheline 15   offset 6    -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 32   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 247  cacheline 15   offset 7    -- // --  0  - filter_operation
0x00000004 // entry 248  cacheline 15   offset 8    -- // --  1  - filter_mask
0x00000004 // entry 249  cacheline 15   offset 9    -- // --  2  - const_mask
0x00000001 // entry 250  cacheline 15   offset 10   -- // --  3  - const_value
0x00004821 // entry 251  cacheline 15   offset 11   -- // --  5  - ops_mask
0x00000001 // entry 252  cacheline 15   offset 12   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 253  cacheline 15   offset 13   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 254  cacheline 15   offset 14   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 255  cacheline 15   offset 15   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 33   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 256  cacheline 16   offset 0    -- //  0  - Increment/Decrement
0x00000000 // entry 257  cacheline 16   offset 1    -- //  1  - Index_start
0x00000033 // entry 258  cacheline 16   offset 2    -- //  2  - Index_end
0x00000001 // entry 259  cacheline 16   offset 3    -- //  3  - Stride
0x80000002 // entry 260  cacheline 16   offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 261  cacheline 16   offset 5    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 262  cacheline 16   offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 263  cacheline 16   offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 264  cacheline 16   offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 265  cacheline 16   offset 9    -- //  9  - BUFFER size
0x00000000 // entry 266  cacheline 16   offset 10   -- //  10 - const_mask
0x00000000 // entry 267  cacheline 16   offset 11   -- //  11 - const_value
0x00008412 // entry 268  cacheline 16   offset 12   -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 34   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 269  cacheline 16   offset 13   -- //  0  - merge mask (W:2)
0x00000000 // entry 270  cacheline 16   offset 14   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 35   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 271  cacheline 16   offset 15   -- // --  0  - filter_operation
0x00000004 // entry 272  cacheline 17   offset 0    -- // --  1  - filter_mask
0x00000004 // entry 273  cacheline 17   offset 1    -- // --  2  - const_mask
0x00000001 // entry 274  cacheline 17   offset 2    -- // --  3  - const_value
0x00004821 // entry 275  cacheline 17   offset 3    -- // --  5  - ops_mask
0x00000001 // entry 276  cacheline 17   offset 4    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 277  cacheline 17   offset 5    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 278  cacheline 17   offset 6    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 279  cacheline 17   offset 7    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 36   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 280  cacheline 17   offset 8    -- //  0  - Increment/Decrement
0x00000000 // entry 281  cacheline 17   offset 9    -- //  1  - Index_start
0x00000033 // entry 282  cacheline 17   offset 10   -- //  2  - Index_end
0x00000001 // entry 283  cacheline 17   offset 11   -- //  3  - Stride
0x80000002 // entry 284  cacheline 17   offset 12   -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 285  cacheline 17   offset 13   -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 286  cacheline 17   offset 14   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 287  cacheline 17   offset 15   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 288  cacheline 18   offset 0    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 289  cacheline 18   offset 1    -- //  9  - BUFFER size
0x00000000 // entry 290  cacheline 18   offset 2    -- //  10 - const_mask
0x00000000 // entry 291  cacheline 18   offset 3    -- //  11 - const_value
0x00008412 // entry 292  cacheline 18   offset 4    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 37   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 293  cacheline 18   offset 5    -- //  0  - merge mask (W:2)
0x00000000 // entry 294  cacheline 18   offset 6    -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 38   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 295  cacheline 18   offset 7    -- // --  0  - filter_operation
0x00000004 // entry 296  cacheline 18   offset 8    -- // --  1  - filter_mask
0x00000004 // entry 297  cacheline 18   offset 9    -- // --  2  - const_mask
0x00000001 // entry 298  cacheline 18   offset 10   -- // --  3  - const_value
0x00004821 // entry 299  cacheline 18   offset 11   -- // --  5  - ops_mask
0x00000001 // entry 300  cacheline 18   offset 12   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 301  cacheline 18   offset 13   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 302  cacheline 18   offset 14   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 303  cacheline 18   offset 15   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 39   mapping 2    cycles 10   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x0000000D // entry 304  cacheline 19   offset 0    -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
0x00000000 // entry 305  cacheline 19   offset 1    -- //  1  - Index_start
0x00000000 // entry 306  cacheline 19   offset 2    -- //  2  - Index_end
0x00000001 // entry 307  cacheline 19   offset 3    -- //  3  - Stride
0x80000002 // entry 308  cacheline 19   offset 4    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 309  cacheline 19   offset 5    -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 310  cacheline 19   offset 6    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 311  cacheline 19   offset 7    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 312  cacheline 19   offset 8    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 313  cacheline 19   offset 9    -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 40   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 314  cacheline 19   offset 10   -- // --  0  - filter_operation
0x00000004 // entry 315  cacheline 19   offset 11   -- // --  1  - filter_mask
0x00000004 // entry 316  cacheline 19   offset 12   -- // --  2  - const_mask
0x00000001 // entry 317  cacheline 19   offset 13   -- // --  3  - const_value
0x00004821 // entry 318  cacheline 19   offset 14   -- // --  5  - ops_mask
0x00000001 // entry 319  cacheline 19   offset 15   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 320  cacheline 20   offset 0    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 321  cacheline 20   offset 1    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 322  cacheline 20   offset 2    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 41   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 323  cacheline 20   offset 3    -- //  0  - alu_operation
0x00000003 // entry 324  cacheline 20   offset 4    -- //  1  - alu_mask
0x00000001 // entry 325  cacheline 20   offset 5    -- //  2  - const_mask
0x00000003 // entry 326  cacheline 20   offset 6    -- //  3  - const_value
0x00000041 // entry 327  cacheline 20   offset 7    -- //  4  - ops_mask
0xcf257000 // entry 328  cacheline 20   offset 8    -- //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 42   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 329  cacheline 20   offset 9    -- // --  0  - filter_operation
0x00000004 // entry 330  cacheline 20   offset 10   -- // --  1  - filter_mask
0x00000004 // entry 331  cacheline 20   offset 11   -- // --  2  - const_mask
0x00000001 // entry 332  cacheline 20   offset 12   -- // --  3  - const_value
0x00004821 // entry 333  cacheline 20   offset 13   -- // --  5  - ops_mask
0x00000001 // entry 334  cacheline 20   offset 14   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 335  cacheline 20   offset 15   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 336  cacheline 21   offset 0    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 337  cacheline 21   offset 1    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 43   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 338  cacheline 21   offset 2    -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 44   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 339  cacheline 21   offset 3    -- // --  0  - filter_operation
0x00000004 // entry 340  cacheline 21   offset 4    -- // --  1  - filter_mask
0x00000004 // entry 341  cacheline 21   offset 5    -- // --  2  - const_mask
0x00000001 // entry 342  cacheline 21   offset 6    -- // --  3  - const_value
0x00004821 // entry 343  cacheline 21   offset 7    -- // --  5  - ops_mask
0x00000001 // entry 344  cacheline 21   offset 8    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 345  cacheline 21   offset 9    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 346  cacheline 21   offset 10   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 347  cacheline 21   offset 11   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 45   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 348  cacheline 21   offset 12   -- //  0  - Increment/Decrement
0x00000000 // entry 349  cacheline 21   offset 13   -- //  1  - Index_start
0x00000033 // entry 350  cacheline 21   offset 14   -- //  2  - Index_end
0x00000001 // entry 351  cacheline 21   offset 15   -- //  3  - Stride
0x80000002 // entry 352  cacheline 22   offset 0    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 353  cacheline 22   offset 1    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 354  cacheline 22   offset 2    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 355  cacheline 22   offset 3    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 356  cacheline 22   offset 4    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 357  cacheline 22   offset 5    -- //  9  - BUFFER size
0x00000000 // entry 358  cacheline 22   offset 6    -- //  10 - const_mask
0x00000000 // entry 359  cacheline 22   offset 7    -- //  11 - const_value
0x00008412 // entry 360  cacheline 22   offset 8    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 46   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 361  cacheline 22   offset 9    -- //  0  - merge mask (W:2)
0x00000000 // entry 362  cacheline 22   offset 10   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 47   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 363  cacheline 22   offset 11   -- // --  0  - filter_operation
0x00000004 // entry 364  cacheline 22   offset 12   -- // --  1  - filter_mask
0x00000004 // entry 365  cacheline 22   offset 13   -- // --  2  - const_mask
0x00000001 // entry 366  cacheline 22   offset 14   -- // --  3  - const_value
0x00004821 // entry 367  cacheline 22   offset 15   -- // --  5  - ops_mask
0x00000001 // entry 368  cacheline 23   offset 0    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 369  cacheline 23   offset 1    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 370  cacheline 23   offset 2    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 371  cacheline 23   offset 3    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 48   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 372  cacheline 23   offset 4    -- //  0  - Increment/Decrement
0x00000000 // entry 373  cacheline 23   offset 5    -- //  1  - Index_start
0x00000033 // entry 374  cacheline 23   offset 6    -- //  2  - Index_end
0x00000001 // entry 375  cacheline 23   offset 7    -- //  3  - Stride
0x80000002 // entry 376  cacheline 23   offset 8    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 377  cacheline 23   offset 9    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 378  cacheline 23   offset 10   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 379  cacheline 23   offset 11   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 380  cacheline 23   offset 12   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 381  cacheline 23   offset 13   -- //  9  - BUFFER size
0x00000000 // entry 382  cacheline 23   offset 14   -- //  10 - const_mask
0x00000000 // entry 383  cacheline 23   offset 15   -- //  11 - const_value
0x00008412 // entry 384  cacheline 24   offset 0    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 49   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 385  cacheline 24   offset 1    -- //  0  - merge mask (W:2)
0x00000000 // entry 386  cacheline 24   offset 2    -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 50   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 387  cacheline 24   offset 3    -- // --  0  - filter_operation
0x00000004 // entry 388  cacheline 24   offset 4    -- // --  1  - filter_mask
0x00000004 // entry 389  cacheline 24   offset 5    -- // --  2  - const_mask
0x00000001 // entry 390  cacheline 24   offset 6    -- // --  3  - const_value
0x00004821 // entry 391  cacheline 24   offset 7    -- // --  5  - ops_mask
0x00000001 // entry 392  cacheline 24   offset 8    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 393  cacheline 24   offset 9    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 394  cacheline 24   offset 10   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 395  cacheline 24   offset 11   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 51   mapping 1    cycles 13   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 396  cacheline 24   offset 12   -- //  0  - Increment/Decrement
0x00000000 // entry 397  cacheline 24   offset 13   -- //  1  - Index_start
0x00000033 // entry 398  cacheline 24   offset 14   -- //  2  - Index_end
0x00000001 // entry 399  cacheline 24   offset 15   -- //  3  - Stride
0x80000002 // entry 400  cacheline 25   offset 0    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 401  cacheline 25   offset 1    -- //  5  - STRUCT_ENGINE_DATA | CMD_MEM_READ | id moddule | id engine
0x00010401 // entry 402  cacheline 25   offset 2    -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 403  cacheline 25   offset 3    -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 404  cacheline 25   offset 4    -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 405  cacheline 25   offset 5    -- //  9  - BUFFER size
0x00000000 // entry 406  cacheline 25   offset 6    -- //  10 - const_mask
0x00000000 // entry 407  cacheline 25   offset 7    -- //  11 - const_value
0x00008412 // entry 408  cacheline 25   offset 8    -- //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 52   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000007 // entry 409  cacheline 25   offset 9    -- //  0  - merge mask (W:2)
0x00000000 // entry 410  cacheline 25   offset 10   -- //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 53   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 411  cacheline 25   offset 11   -- // --  0  - filter_operation
0x00000004 // entry 412  cacheline 25   offset 12   -- // --  1  - filter_mask
0x00000004 // entry 413  cacheline 25   offset 13   -- // --  2  - const_mask
0x00000001 // entry 414  cacheline 25   offset 14   -- // --  3  - const_value
0x00004821 // entry 415  cacheline 25   offset 15   -- // --  5  - ops_mask
0x00000001 // entry 416  cacheline 26   offset 0    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 417  cacheline 26   offset 1    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 418  cacheline 26   offset 2    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 419  cacheline 26   offset 3    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 54   mapping 2    cycles 10   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x0000000D // entry 420  cacheline 26   offset 4    -- //  0  - Increment | Decrement | mode_sequence | mode_buffer | mode_break | mode_filter
0x00000000 // entry 421  cacheline 26   offset 5    -- //  1  - Index_start
0x00000000 // entry 422  cacheline 26   offset 6    -- //  2  - Index_end
0x00000001 // entry 423  cacheline 26   offset 7    -- //  3  - Stride
0x80000002 // entry 424  cacheline 26   offset 8    -- //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000102 // entry 425  cacheline 26   offset 9    -- //  5  - CMD_MEM_READ | STRUCT_ENGINE_DATA | id moddule | id engine
0x01010801 // entry 426  cacheline 26   offset 10   -- //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 427  cacheline 26   offset 11   -- //  7  - BUFFER Array Pointer LHS
0x00000000 // entry 428  cacheline 26   offset 12   -- //  8  - BUFFER Array Pointer RHS
0x00000033 // entry 429  cacheline 26   offset 13   -- //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 55   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 430  cacheline 26   offset 14   -- // --  0  - filter_operation
0x00000004 // entry 431  cacheline 26   offset 15   -- // --  1  - filter_mask
0x00000004 // entry 432  cacheline 27   offset 0    -- // --  2  - const_mask
0x00000001 // entry 433  cacheline 27   offset 1    -- // --  3  - const_value
0x00004821 // entry 434  cacheline 27   offset 2    -- // --  5  - ops_mask
0x00000001 // entry 435  cacheline 27   offset 3    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 436  cacheline 27   offset 4    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 437  cacheline 27   offset 5    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 438  cacheline 27   offset 6    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 56   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 439  cacheline 27   offset 7    -- //  0  - alu_operation
0x00000003 // entry 440  cacheline 27   offset 8    -- //  1  - alu_mask
0x00000001 // entry 441  cacheline 27   offset 9    -- //  2  - const_mask
0x00000003 // entry 442  cacheline 27   offset 10   -- //  3  - const_value
0x00000041 // entry 443  cacheline 27   offset 11   -- //  4  - ops_mask
0xcf257000 // entry 444  cacheline 27   offset 12   -- //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 57   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 445  cacheline 27   offset 13   -- // --  0  - filter_operation
0x00000004 // entry 446  cacheline 27   offset 14   -- // --  1  - filter_mask
0x00000004 // entry 447  cacheline 27   offset 15   -- // --  2  - const_mask
0x00000001 // entry 448  cacheline 28   offset 0    -- // --  3  - const_value
0x00004821 // entry 449  cacheline 28   offset 1    -- // --  5  - ops_mask
0x00000001 // entry 450  cacheline 28   offset 2    -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 451  cacheline 28   offset 3    -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 452  cacheline 28   offset 4    -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 453  cacheline 28   offset 5    -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 58   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 454  cacheline 28   offset 6    -- //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 59   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000008 // entry 455  cacheline 28   offset 7    -- // --  0  - filter_operation
0x00000004 // entry 456  cacheline 28   offset 8    -- // --  1  - filter_mask
0x00000004 // entry 457  cacheline 28   offset 9    -- // --  2  - const_mask
0x00000001 // entry 458  cacheline 28   offset 10   -- // --  3  - const_value
0x00004821 // entry 459  cacheline 28   offset 11   -- // --  5  - ops_mask
0x00000001 // entry 460  cacheline 28   offset 12   -- // --  4  - break_flag | filter_post | continue_flag | ternary_flag | conditional_flag
0x00030101 // entry 461  cacheline 28   offset 13   -- // --  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00030101 // entry 462  cacheline 28   offset 14   -- // --  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 // entry 463  cacheline 28   offset 15   -- // --  8  - if -> id_engine id_module | else -> id_engine id_module
// --------------------------------------------------------------------------------------
// Number of entries 464
