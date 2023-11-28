#include "glayenv.hpp"
void GLAYGraphCSRxrtBufferHandlePerKernel::mapGLAYOverlayProgramBuffersPR(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
{
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 1    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 2    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[7] = ( 0 );
   // --  2  - Index_End
    overlay_program[8] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[13] = 0;
   // --  8  - Array_Pointer_RHS
    overlay_program[14] = 0;
   // --  9  - Array_size
    overlay_program[15] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 3    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 4    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[18] = ( 0 );
   // --  2  - Index_End
    overlay_program[19] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[24] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[25] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[26] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 5    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[33] = ( 0 );
   // --  2  - Index_End
    overlay_program[34] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[39] = xrt_buffer_device[2];
   // --  8  - Array_Pointer_RHS
    overlay_program[40] = xrt_buffer_device[2] >> 32;
   // --  9  - Array_size
    overlay_program[41] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 7    mapping 1    cycles 13   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[46] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[47] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[52] = xrt_buffer_device[8];
   // --  8  - Array_Pointer_RHS
    overlay_program[53] = xrt_buffer_device[8] >> 32;
   // --  9  - Array_size
    overlay_program[54] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 8    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 9    mapping 2    cycles 10   buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[60] = ( 0 );
   // --  2  - Index_End
    overlay_program[61] = ( graph->num_edges );
   // --  7  - Array_Pointer_LHS
    overlay_program[66] = xrt_buffer_device[5];
   // --  8  - Array_Pointer_RHS
    overlay_program[67] = xrt_buffer_device[5] >> 32;
   // --  9  - Array_size
    overlay_program[68] = ( graph->num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[71] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[72] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[77] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[78] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[79] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// --------------------------------------------------------------------------------------
// -->  CPP.Single.PR  <-- 
// Number of entries 84
