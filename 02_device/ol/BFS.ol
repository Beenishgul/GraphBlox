// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// + BUNDLE 0
// --------------------------------------------------------------------------------------
// ** LANE 0 
// --------------------------------------------------------------------------------------
// --- ENGINE 0 ENGINE_READ_WRITE
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00070101 //  6  - ALU_NOP | FILTER_NOP | OP_LOCATION_0
0x00080101 //  7  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  8  - BUFFER Array Pointer LHS
0x00000000 //  9  - BUFFER Array Pointer RHS
0x00000033 //  10 - BUFFER size
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 1 ENGINE_MERGE_DATA(W:2)
// --------------------------------------------------------------------------------------
0x00000007 //  0  - merge mask (W:2)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
0x00000000 //  2  - Reserved
0x00000000 //  3  - Reserved
0x00000000 //  4  - Reserved
0x00000000 //  5  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 2 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 1 
// --------------------------------------------------------------------------------------
// --- ENGINE 3 ENGINE_READ_WRITE(C:0)
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00070101 //  6  - ALU_NOP | FILTER_NOP | OP_LOCATION_0
0xcf257000 //  7  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  8  - BUFFER Array Pointer LHS
0x00000000 //  9  - BUFFER Array Pointer RHS
0x00000033 //  10 - BUFFER size
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 4 ENGINE_MERGE_DATA(W:1)
// --------------------------------------------------------------------------------------
0x00000003 //  0  - merge mask (W:1)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
0x00000000 //  2  - Reserved
0x00000000 //  3  - Reserved
0x00000000 //  4  - Reserved
0x00000000 //  5  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 5 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 2 
// --------------------------------------------------------------------------------------
// --- ENGINE 6 ENGINE_CSR(C:0,1)
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00070101 //  6  - ALU_NOP | FILTER_NOP | OP_LOCATION_0
0xcf257000 //  7  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  8  - BUFFER Array Pointer LHS
0x00000000 //  9  - BUFFER Array Pointer RHS
0x00000033 //  10 - BUFFER size
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved
// --------------------------------------------------------------------------------------
// --- ENGINE 7 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 3 
// --------------------------------------------------------------------------------------
// --- ENGINE 8 ENGINE_ALU_OPS
// --------------------------------------------------------------------------------------
0x00000001 //  0  - alu_operation
0x00000003 //  1  - alu_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0xcf257000 //  4  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 9 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 4 
// --------------------------------------------------------------------------------------
// --- ENGINE 10 ENGINE_FORWARD_DATA
// --------------------------------------------------------------------------------------
0x00000001 //  0  - number of hops (forward till discards)
0x00000000 //  1  - Reserved
0x00000000 //  2  - Reserved
0x00000000 //  3  - Reserved
0x00000000 //  4  - Reserved
0x00000000 //  5  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 11 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// + BUNDLE 0
// --------------------------------------------------------------------------------------
// ** LANE 0 
// --------------------------------------------------------------------------------------
// --- ENGINE 0 ENGINE_CSR
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00070101 //  6  - ALU_NOP | FILTER_NOP | OP_LOCATION_0
0x00080101 //  7  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  8  - BUFFER Array Pointer LHS
0x00000000 //  9  - BUFFER Array Pointer RHS
0x00000033 //  10 - BUFFER size
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 1 ENGINE_MERGE_DATA(W:2)
// --------------------------------------------------------------------------------------
0x00000007 //  0  - merge mask (W:2)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
0x00000000 //  2  - Reserved
0x00000000 //  3  - Reserved
0x00000000 //  4  - Reserved
0x00000000 //  5  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 2 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 1 
// --------------------------------------------------------------------------------------
// --- ENGINE 3 ENGINE_CSR(C:0)
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00070101 //  6  - ALU_NOP | FILTER_NOP | OP_LOCATION_0
0xcf257000 //  7  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  8  - BUFFER Array Pointer LHS
0x00000000 //  9  - BUFFER Array Pointer RHS
0x00000033 //  10 - BUFFER size
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 4 ENGINE_MERGE_DATA(W:1)
// --------------------------------------------------------------------------------------
0x00000003 //  0  - merge mask (W:1)
0x00000000 //  1  - merge type (Serial|Parallel|Both)
0x00000000 //  2  - Reserved
0x00000000 //  3  - Reserved
0x00000000 //  4  - Reserved
0x00000000 //  5  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 5 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 2 
// --------------------------------------------------------------------------------------
// --- ENGINE 6 ENGINE_CSR(C:0,1)
// --------------------------------------------------------------------------------------
0x00000009 //  0  - Increment/Decrement
0x00000000 //  1  - Index_start
0x00000033 //  2  - Index_end
0x00000001 //  3  - Stride
0x80000002 //  4  - Shift direction 1-left 0-right | (granularity - log2 value for shifting)
0x00000101 //  5  - STRUCT_ENGINE_SETUP | CMD_MEM_CONFIGURE
0x00070101 //  6  - ALU_NOP | FILTER_NOP | OP_LOCATION_0
0xcf257000 //  7  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  8  - BUFFER Array Pointer LHS
0x00000000 //  9  - BUFFER Array Pointer RHS
0x00000033 //  10 - BUFFER size
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved
// --------------------------------------------------------------------------------------
// --- ENGINE 7 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 3 
// --------------------------------------------------------------------------------------
// --- ENGINE 8 ENGINE_ALU_OPS
// --------------------------------------------------------------------------------------
0x00000001 //  0  - alu_operation
0x00000003 //  1  - alu_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0xcf257000 //  4  - BUFFER  | Cast to first 3 Lanes in next bundle | BUNDLE-0 | VERTEX-0
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 9 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// ** LANE 4 
// --------------------------------------------------------------------------------------
// --- ENGINE 10 ENGINE_FORWARD_DATA
// --------------------------------------------------------------------------------------
0x00000001 //  0  - number of hops (forward till discards)
0x00000000 //  1  - Reserved
0x00000000 //  2  - Reserved
0x00000000 //  3  - Reserved
0x00000000 //  4  - Reserved
0x00000000 //  5  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------
// --- ENGINE 11 ENGINE_FILTER
// --------------------------------------------------------------------------------------
0x00000000 //  0  - filter_operation
0x00000003 //  1  - filter_mask
0x00000001 //  2  - const_mask
0x00000003 //  3  - const_value
0x00000041 //  5  - ops_mask
0x00000000 //  4  - Reserved
0x00000000 //  6  - Reserved
0x00000000 //  7  - Reserved
0x00000000 //  8  - Reserved
0x00000000 //  9  - Reserved
0x00000000 //  10 - Reserved
0x00000000 //  11 - Reserved 
0x00000000 //  12 - Reserved 
0x00000000 //  13 - Reserved 
0x00000000 //  14 - Reserved 
0x00000000 //  15 - Reserved 
// --------------------------------------------------------------------------------------