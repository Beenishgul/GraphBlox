#include "glayenv.hpp"
void GLAYGraphCSRxrtBufferHandlePerBank::mapGLAYOverlayProgramBuffersBFS(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
{
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 1    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[1] = ( 0 );
   // --  2  - Index_End
    overlay_program[2] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[7] = 0;
   // --  8  - Array_Pointer_RHS
    overlay_program[8] = 0;
   // --  9  - Array_size
    overlay_program[9] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 2    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 3    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[12] = ( 0 );
   // --  2  - Index_End
    overlay_program[13] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[18] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[19] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[20] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 4    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 5    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_1-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[36] = ( 0 );
   // --  2  - Index_End
    overlay_program[37] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[42] = xrt_buffer_device[1];
   // --  8  - Array_Pointer_RHS
    overlay_program[43] = xrt_buffer_device[1] >> 32;
   // --  9  - Array_size
    overlay_program[44] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 7    mapping 1    cycles 13   buffer_8-auxiliary_2 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[49] = ( 0 );
   // --  2  - Index_End
    overlay_program[50] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[55] = xrt_buffer_device[8];
   // --  8  - Array_Pointer_RHS
    overlay_program[56] = xrt_buffer_device[8] >> 32;
   // --  9  - Array_size
    overlay_program[57] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 8    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 9    mapping 2    cycles 10   buffer_4-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[63] = ( 0 );
   // --  2  - Index_End
    overlay_program[64] = ( graph->num_edges );
   // --  7  - Array_Pointer_LHS
    overlay_program[69] = xrt_buffer_device[4];
   // --  8  - Array_Pointer_RHS
    overlay_program[70] = xrt_buffer_device[4] >> 32;
   // --  9  - Array_size
    overlay_program[71] = ( graph->num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[74] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[75] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[80] = xrt_buffer_device[8];
   // --  8  - Array_Pointer_RHS
    overlay_program[81] = xrt_buffer_device[8] >> 32;
   // --  9  - Array_size
    overlay_program[82] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 12   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 13   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// Number of entries 96
