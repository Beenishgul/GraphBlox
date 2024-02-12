// --------------------------------------------------------------------------------------
// Name ENGINE_PARALLEL_READ_WRITE    ID 0    mapping 8    cycles 29   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[1] = ( graph.num_vertices );
   // --  2  - Index_Start
    graph.overlay_program[8] = ( 0 );
   // --  3  - Index_Start
    graph.overlay_program[15] = ( 0 );
   // --  4  - Index_Start
    graph.overlay_program[22] = ( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX              ID 1    mapping 2    cycles 8    None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[30]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[31]  = ( graph.num_vertices );
   // --  7  - Array_size
    graph.overlay_program[36]  = ( graph.num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 2    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_PARALLEL_READ_WRITE    ID 3    mapping 8    cycles 29   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[38] = ( 0 );
   // --  2  - Index_Start
    graph.overlay_program[45] = ( 0 );
   // --  3  - Index_Start
    graph.overlay_program[52] = ( 0 );
   // --  4  - Index_Start
    graph.overlay_program[59] = ( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND            ID 4    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 5    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX              ID 6    mapping 2    cycles 8    buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[76]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[77]  = ( graph.num_edges );
   // --  7  - Array_size
    graph.overlay_program[82]  = ( graph.num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 7    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE             ID 8    mapping 1    cycles 11   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[84]  = ( graph.num_vertices );
   // --  2  - Index_End
    graph.overlay_program[85]  = ( graph.num_vertices * 2 );
   // --  7  - Array_size
    graph.overlay_program[90]  = ( graph.num_vertices * 2 )-( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND            ID 9    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 10   mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Benchmark.Single.BFS  <-- 
// Number of entries 103
