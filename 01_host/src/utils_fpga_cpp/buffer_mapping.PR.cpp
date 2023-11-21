#include "glayenv.hpp"
void GLAYGraphCSRxrtBufferHandlePerBank::mapGLAYOverlayProgramBuffersPR(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
{
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 1    mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[1] = ( 0 );
   // --  2  - Index_End
    overlay_program[2] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[7] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[8] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[9] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 2    mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[14] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[15] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[20] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[21] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[22] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 3    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[27] = ( 0 );
   // --  2  - Index_End
    overlay_program[28] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[33] = 0;
   // --  8  - Array_Pointer_RHS
    overlay_program[34] = 0;
   // --  9  - Array_size
    overlay_program[35] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 4    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 5    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[38] = ( 0 );
   // --  2  - Index_End
    overlay_program[39] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[44] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[45] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[46] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 6    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 7    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 8    mapping 1    cycles 13   buffer_1-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[62] = ( 0 );
   // --  2  - Index_End
    overlay_program[63] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[68] = xrt_buffer_device[1];
   // --  8  - Array_Pointer_RHS
    overlay_program[69] = xrt_buffer_device[1] >> 32;
   // --  9  - Array_size
    overlay_program[70] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 9    mapping 1    cycles 13   buffer_8-auxiliary_2 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[75] = ( 0 );
   // --  2  - Index_End
    overlay_program[76] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[81] = xrt_buffer_device[8];
   // --  8  - Array_Pointer_RHS
    overlay_program[82] = xrt_buffer_device[8] >> 32;
   // --  9  - Array_size
    overlay_program[83] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 11   mapping 2    cycles 10   buffer_4-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[89] = ( 0 );
   // --  2  - Index_End
    overlay_program[90] = ( graph->num_edges );
   // --  7  - Array_Pointer_LHS
    overlay_program[95] = xrt_buffer_device[4];
   // --  8  - Array_Pointer_RHS
    overlay_program[96] = xrt_buffer_device[4] >> 32;
   // --  9  - Array_size
    overlay_program[97] = ( graph->num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 13   mapping 1    cycles 13   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[100] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[101] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[106] = xrt_buffer_device[8];
   // --  8  - Array_Pointer_RHS
    overlay_program[107] = xrt_buffer_device[8] >> 32;
   // --  9  - Array_size
    overlay_program[108] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 14   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 15   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// Number of entries 122
