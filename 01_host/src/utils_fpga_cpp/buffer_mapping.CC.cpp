#include "graphbloxenv.hpp"
void GRAPHBLOXxrtBufferHandlePerKernel::mapGRAPHBLOXOverlayProgramBuffersCC(struct GraphCSR *graph)
{
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX              ID 0    mapping 2    cycles 11   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[1] = ( 0 );
   // --  2  - Index_End
    overlay_program[2] = ( graph->num_vertices );
   // --  7  - Array_size
    overlay_program[7] = (( graph->num_vertices )-( 0 ))/1;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE             ID 1    mapping 1    cycles 7    buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  0  - Index_Start
    overlay_program[11] = ( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND            ID 2    mapping 3    cycles 10   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 3    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_PARALLEL_READ_WRITE    ID 4    mapping 7    cycles 29   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[29] = ( 0 );
   // --  2  - Index_Start
    overlay_program[36] = ( 0 );
   // --  3  - Index_Start
    overlay_program[43] = ( 0 );
   // --  4  - Index_Start
    overlay_program[50] = ( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 5    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_PARALLEL_READ_WRITE    ID 6    mapping 7    cycles 29   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[58] = ( 0 );
   // --  2  - Index_Start
    overlay_program[65] = ( 0 );
   // --  3  - Index_Start
    overlay_program[72] = ( 0 );
   // --  4  - Index_Start
    overlay_program[79] = ( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX              ID 7    mapping 2    cycles 11   buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[87] = ( 0 );
   // --  2  - Index_End
    overlay_program[88] = ( graph->num_edges );
   // --  7  - Array_size
    overlay_program[93] = (( graph->num_edges )-( 0 ))/1;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 8    mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE             ID 9    mapping 1    cycles 7    buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  0  - Index_Start
    overlay_program[97] = ( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND            ID 10   mapping 3    cycles 10   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND            ID 11   mapping 3    cycles 10   None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA           ID 12   mapping 6    cycles 0    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// --------------------------------------------------------------------------------------
// -->  CPP.Single.CC  <-- 
// Number of entries 124
// CU vector 1
