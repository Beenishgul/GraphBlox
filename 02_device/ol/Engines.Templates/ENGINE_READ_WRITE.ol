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
// --------------------------------------------------------------------------------------