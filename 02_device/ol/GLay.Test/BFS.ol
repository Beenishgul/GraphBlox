// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// + BUNDLE 0
// --------------------------------------------------------------------------------------
// ** LANE 0 
// --------------------------------------------------------------------------------------
// --- ENGINE 0 ENGINE_READ_WRITE - PROGRAM 10-CYCLES
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00080101 //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - BUFFER Array Pointer LHS
0x00000000 //  8  - BUFFER Array Pointer RHS
0x00000033 //  9  - BUFFER size
0x00000000 //  10 - const_mask
0x00000003 //  11 - const_value
0x00000041 //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --- ENGINE 1 ENGINE_MERGE_DATA(W:2) - PROGRAM 2-CYCLES
// --------------------------------------------------------------------------------------
0x00000007 //  0  - merge mask (W:2)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --- ENGINE 2 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 1 
// --------------------------------------------------------------------------------------
// --- ENGINE 3 ENGINE_READ_WRITE(C:0) - PROGRAM 10-CYCLES
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0xcf257000 //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - BUFFER Array Pointer LHS
0x00000000 //  8  - BUFFER Array Pointer RHS
0x00000033 //  9  - BUFFER size
0x00000000 //  10 - const_mask
0x00000003 //  11 - const_value
0x00000041 //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --- ENGINE 4 ENGINE_MERGE_DATA(W:1) - PROGRAM 2-CYCLES
// --------------------------------------------------------------------------------------
0x00000003 //  0  - merge mask (W:1)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --- ENGINE 5 ENGINE_FILTER_COND  - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 2 
// --------------------------------------------------------------------------------------
// --- ENGINE 6 ENGINE_CSR_INDEX(C:0,1) - PROGRAM 10-CYCLES
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0xcf257000 //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - BUFFER Array Pointer LHS
0x00000000 //  8  - BUFFER Array Pointer RHS
0x00000033 //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --- ENGINE 7 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 3 
// --------------------------------------------------------------------------------------
// --- ENGINE 8 ENGINE_ALU_OPS - PROGRAM 6-CYCLES
// --------------------------------------------------------------------------------------
0x00000001 //  0  - alu_operation
0x00000003 //  1  - alu_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0xcf257000 //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --- ENGINE 9 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 4 
// --------------------------------------------------------------------------------------
// --- ENGINE 10 ENGINE_FORWARD_DATA - PROGRAM 1-CYCLES
// --------------------------------------------------------------------------------------
0x00000001 //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --- ENGINE 11 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// + BUNDLE 1
// --------------------------------------------------------------------------------------
// ** LANE 0 
// --------------------------------------------------------------------------------------
// --- ENGINE 0 ENGINE_READ_WRITE - PROGRAM 10-CYCLES
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00080101 //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - BUFFER Array Pointer LHS
0x00000000 //  8  - BUFFER Array Pointer RHS
0x00000033 //  9  - BUFFER size
0x00000000 //  10 - const_mask
0x00000003 //  11 - const_value
0x00000041 //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --- ENGINE 1 ENGINE_MERGE_DATA(W:2) - PROGRAM 2-CYCLES
// --------------------------------------------------------------------------------------
0x00000007 //  0  - merge mask (W:2)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --- ENGINE 2 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 1 
// --------------------------------------------------------------------------------------
// --- ENGINE 3 ENGINE_READ_WRITE(C:0) - PROGRAM 10-CYCLES
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0xcf257000 //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - BUFFER Array Pointer LHS
0x00000000 //  8  - BUFFER Array Pointer RHS
0x00000033 //  9  - BUFFER size
0x00000000 //  10 - const_mask
0x00000003 //  11 - const_value
0x00000041 //  12 - ops_mask
// --------------------------------------------------------------------------------------
// --- ENGINE 4 ENGINE_MERGE_DATA(W:1) - PROGRAM 2-CYCLES
// --------------------------------------------------------------------------------------
0x00000003 //  0  - merge mask (W:1)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
// --------------------------------------------------------------------------------------
// --- ENGINE 5 ENGINE_FILTER_COND  - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 2 
// --------------------------------------------------------------------------------------
// --- ENGINE 6 ENGINE_CSR_INDEX(C:0,1) - PROGRAM 10-CYCLES
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0xcf257000 //  6  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - BUFFER Array Pointer LHS
0x00000000 //  8  - BUFFER Array Pointer RHS
0x00000033 //  9  - BUFFER size
// --------------------------------------------------------------------------------------
// --- ENGINE 7 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 3 
// --------------------------------------------------------------------------------------
// --- ENGINE 8 ENGINE_ALU_OPS - PROGRAM 6-CYCLES
// --------------------------------------------------------------------------------------
0x00000001 //  0  - alu_operation
0x00000003 //  1  - alu_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0xcf257000 //  5  - route  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// --- ENGINE 9 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------
// ** LANE 4 
// --------------------------------------------------------------------------------------
// --- ENGINE 10 ENGINE_FORWARD_DATA - PROGRAM 1-CYCLES
// --------------------------------------------------------------------------------------
0x00000001 //  0  - number of hops (forward till discards)
// --------------------------------------------------------------------------------------
// --- ENGINE 11 ENGINE_FILTER_COND - PROGRAM 8-CYCLES
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  4  - ops_mask
0x00000000 //  5  - break_flag | continue_flag | ternary_flag | conditional_flag
0x00000000 //  6  - if   route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  7  - else route | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
// --------------------------------------------------------------------------------------