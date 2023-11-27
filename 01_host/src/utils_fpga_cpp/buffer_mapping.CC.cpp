#include "glayenv.hpp"
void GLAYGraphCSRxrtBufferHandlePerKernel::mapGLAYOverlayProgramBuffersCC(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
{
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 1    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[1] = ( 0 );
   // --  2  - Index_End
    overlay_program[2] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[7] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[8] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[9] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 2    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[14] = ( 0 );
   // --  2  - Index_End
    overlay_program[15] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[20] = 0;
   // --  8  - Array_Pointer_RHS
    overlay_program[21] = 0;
   // --  9  - Array_size
    overlay_program[22] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 3    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 4    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 5    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[37] = ( 0 );
   // --  2  - Index_End
    overlay_program[38] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[43] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[44] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[45] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 7    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 8    mapping 1    cycles 13   buffer_1-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[52] = ( 0 );
   // --  2  - Index_End
    overlay_program[53] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[58] = xrt_buffer_device[1];
   // --  8  - Array_Pointer_RHS
    overlay_program[59] = xrt_buffer_device[1] >> 32;
   // --  9  - Array_size
    overlay_program[60] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 9    mapping 1    cycles 13   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[65] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[66] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[71] = xrt_buffer_device[8];
   // --  8  - Array_Pointer_RHS
    overlay_program[72] = xrt_buffer_device[8] >> 32;
   // --  9  - Array_size
    overlay_program[73] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 11   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[79] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[80] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[85] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[86] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[87] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 12   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 13   mapping 2    cycles 10   buffer_4-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[101] = ( 0 );
   // --  2  - Index_End
    overlay_program[102] = ( graph->num_edges );
   // --  7  - Array_Pointer_LHS
    overlay_program[107] = xrt_buffer_device[4];
   // --  8  - Array_Pointer_RHS
    overlay_program[108] = xrt_buffer_device[4] >> 32;
   // --  9  - Array_size
    overlay_program[109] = ( graph->num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 14   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 15   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 16   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[121] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[122] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[127] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[128] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[129] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 17   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 18   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[143] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[144] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[149] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[150] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[151] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 19   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 20   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// --------------------------------------------------------------------------------------
// -->  Single.CC  <-- 
// Number of entries 165
