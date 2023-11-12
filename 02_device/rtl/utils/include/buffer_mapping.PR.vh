// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 1    mapping 2    cycles 10   None-NONE 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[0][(GLOBAL_DATA_WIDTH_BITS*1)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  2  - Index_End
    graph.overlay_program[0][(GLOBAL_DATA_WIDTH_BITS*2)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[0][(GLOBAL_DATA_WIDTH_BITS*7)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[0][(GLOBAL_DATA_WIDTH_BITS*8)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  9  - Array_size
    graph.overlay_program[0][(GLOBAL_DATA_WIDTH_BITS*9)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 2    mapping 5    cycles 6    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 3    mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 4    mapping 1    cycles 13   buffer_3-edges_idx 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[1][(GLOBAL_DATA_WIDTH_BITS*2)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  2  - Index_End
    graph.overlay_program[1][(GLOBAL_DATA_WIDTH_BITS*3)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[1][(GLOBAL_DATA_WIDTH_BITS*8)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_3_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[1][(GLOBAL_DATA_WIDTH_BITS*9)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_3_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[1][(GLOBAL_DATA_WIDTH_BITS*10)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 5    mapping 4    cycles 2    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_1-out_degree 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[2][(GLOBAL_DATA_WIDTH_BITS*1)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  2  - Index_End
    graph.overlay_program[2][(GLOBAL_DATA_WIDTH_BITS*2)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[2][(GLOBAL_DATA_WIDTH_BITS*7)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_1_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[2][(GLOBAL_DATA_WIDTH_BITS*8)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_1_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[2][(GLOBAL_DATA_WIDTH_BITS*9)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 7    mapping 1    cycles 13   buffer_7-auxiliary_1 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[2][(GLOBAL_DATA_WIDTH_BITS*14)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  2  - Index_End
    graph.overlay_program[2][(GLOBAL_DATA_WIDTH_BITS*15)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[3][(GLOBAL_DATA_WIDTH_BITS*4)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_7_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[3][(GLOBAL_DATA_WIDTH_BITS*5)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_7_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[3][(GLOBAL_DATA_WIDTH_BITS*6)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 8    mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 9    mapping 2    cycles 10   buffer_4-edges_array_dest 0-num_edges
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[3][(GLOBAL_DATA_WIDTH_BITS*12)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  2  - Index_End
    graph.overlay_program[3][(GLOBAL_DATA_WIDTH_BITS*13)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_edges;
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*2)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_4_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*3)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_4_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*4)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_edges;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*7)+:GLOBAL_DATA_WIDTH_BITS]  = 0;
   // --  2  - Index_End
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*8)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*13)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_7_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*14)+:GLOBAL_DATA_WIDTH_BITS]  = buffer_7_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[4][(GLOBAL_DATA_WIDTH_BITS*15)+:GLOBAL_DATA_WIDTH_BITS]  = graph.num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Number of entries 84
