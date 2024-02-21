// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS                ID 0    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX              ID 1    mapping 2    cycles 8    None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[7]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[8]  = ( graph.num_vertices );
   // --  7  - Array_size
    graph.overlay_program[13]  = ( graph.num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 2    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_PARALLEL_READ_WRITE    ID 3    mapping 7    cycles 29   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[15] = ( 0 );
   // --  2  - Index_Start
    graph.overlay_program[22] = ( 0 );
   // --  3  - Index_Start
    graph.overlay_program[29] = ( graph.num_vertices );
   // --  4  - Index_Start
    graph.overlay_program[36] = ( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 4    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX              ID 5    mapping 2    cycles 8    buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    graph.overlay_program[44]  = ( 0 );
   // --  2  - Index_End
    graph.overlay_program[45]  = ( graph.num_edges );
   // --  7  - Array_size
    graph.overlay_program[50]  = ( graph.num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 6    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE             ID 7    mapping 1    cycles 7    buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  0  - Index_Start
    graph.overlay_program[51]  = ( graph.num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 8    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Benchmark.Single.PR  <-- 
// Number of entries 58
