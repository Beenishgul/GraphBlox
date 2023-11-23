// --------------------------------------------------------------------------------------
// -->  Lite  <-- 
// Number of entries 84
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  2  - Index_End
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[31:0];
// --------------------------------------------------------------------------------------
   // --  8  - Array_Pointer_RHS
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[63:32];
// --------------------------------------------------------------------------------------
   // --  9  - Array_size
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 5    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 1    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
// --------------------------------------------------------------------------------------
   // --  2  - Index_End
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_1-out_degree ( 0 )-( graph->num_vertices )
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 );
// --------------------------------------------------------------------------------------
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[31:0];
   // --  1  - Index_Start
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*1)+:M_AXI4_FE_DATA_W]  = ( 0 );
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[63:32];
// --------------------------------------------------------------------------------------
   // --  2  - Index_End
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
   // --  9  - Array_size
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*2)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
// --------------------------------------------------------------------------------------
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
   // --  7  - Array_Pointer_LHS
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = buffer_1_ptr[31:0];
   // --  1  - Index_Start
// -->  Lite  <-- 
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  8  - Array_Pointer_RHS
// Number of entries 84
   // --  2  - Index_End
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = buffer_1_ptr[63:32];
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 );
   // --  9  - Array_size
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[31:0];
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*9)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices )-( 0 );
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[63:32];
// --------------------------------------------------------------------------------------
   // --  9  - Array_size
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 2    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Lite  <-- 
// --------------------------------------------------------------------------------------
// Number of entries 84
   // --  1  - Index_Start
    graph.overlay_program[0][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[0][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  7  - Array_Pointer_LHS
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 7    mapping 1    cycles 13   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
    graph.overlay_program[0][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = 0;
// -->  Lite  <-- 
// --------------------------------------------------------------------------------------
// Number of entries 84
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[0][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = 0;
   // --  1  - Index_Start
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  9  - Array_size
   // --  2  - Index_End
    graph.overlay_program[0][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices )-( 0 );
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 );
// --------------------------------------------------------------------------------------
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*4)+:M_AXI4_FE_DATA_W]  = buffer_8_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*5)+:M_AXI4_FE_DATA_W]  = buffer_8_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*6)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 8    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// Name ENGINE_FORWARD_DATA ID 3    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 9    mapping 2    cycles 10   buffer_4-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*12)+:M_AXI4_FE_DATA_W]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = ( graph.num_edges );
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*2)+:M_AXI4_FE_DATA_W]  = buffer_4_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*3)+:M_AXI4_FE_DATA_W]  = buffer_4_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*4)+:M_AXI4_FE_DATA_W]  = ( graph.num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 4    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[1][(M_AXI4_FE_DATA_W*2)+:M_AXI4_FE_DATA_W]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[1][(M_AXI4_FE_DATA_W*3)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[1][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = buffer_3_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[1][(M_AXI4_FE_DATA_W*9)+:M_AXI4_FE_DATA_W]  = buffer_3_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[1][(M_AXI4_FE_DATA_W*10)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  2  - Index_End
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
// --------------------------------------------------------------------------------------
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[31:0];
   // --  8  - Array_Pointer_RHS
// Name ENGINE_MERGE_DATA   ID 5    mapping 4    cycles 2    None-None ( 0 )-( 0 )
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[63:32];
// --------------------------------------------------------------------------------------
   // --  9  - Array_size
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Lite  <-- 
// Number of entries 84
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_1-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*1)+:M_AXI4_FE_DATA_W]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*2)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = buffer_1_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = buffer_1_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*9)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 7    mapping 1    cycles 13   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  2  - Index_End
    graph.overlay_program[2][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*4)+:M_AXI4_FE_DATA_W]  = buffer_8_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*5)+:M_AXI4_FE_DATA_W]  = buffer_8_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*6)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 8    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 9    mapping 2    cycles 10   buffer_4-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*12)+:M_AXI4_FE_DATA_W]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[3][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = ( graph.num_edges );
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*2)+:M_AXI4_FE_DATA_W]  = buffer_4_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*3)+:M_AXI4_FE_DATA_W]  = buffer_4_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*4)+:M_AXI4_FE_DATA_W]  = ( graph.num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*7)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices );
   // --  2  - Index_End
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*8)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*13)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[31:0];
   // --  8  - Array_Pointer_RHS
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*14)+:M_AXI4_FE_DATA_W]  = buffer_7_ptr[63:32];
   // --  9  - Array_size
    graph.overlay_program[4][(M_AXI4_FE_DATA_W*15)+:M_AXI4_FE_DATA_W]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Lite  <-- 
// Number of entries 84
