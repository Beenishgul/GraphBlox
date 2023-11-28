#include "glayenv.hpp"
void GLAYGraphCSRxrtBufferHandlePerKernel::mapGLAYOverlayProgramBuffersCC(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
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
// Name ENGINE_FILTER_COND  ID 2    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
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
    overlay_program[33] = ( 0 );
   // --  2  - Index_End
    overlay_program[34] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[39] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[40] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[41] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 7    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 8    mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[48] = ( 0 );
   // --  2  - Index_End
    overlay_program[49] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[54] = xrt_buffer_device[2];
   // --  8  - Array_Pointer_RHS
    overlay_program[55] = xrt_buffer_device[2] >> 32;
   // --  9  - Array_size
    overlay_program[56] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 9    mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[61] = ( 0 );
   // --  2  - Index_End
    overlay_program[62] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[67] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[68] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[69] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 10   mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[74] = ( 0 );
   // --  2  - Index_End
    overlay_program[75] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[80] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[81] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[82] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 11   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 13   mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[97] = ( 0 );
   // --  2  - Index_End
    overlay_program[98] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[103] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[104] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[105] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 14   mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[110] = ( 0 );
   // --  2  - Index_End
    overlay_program[111] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[116] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[117] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[118] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 15   mapping 2    cycles 10   buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[123] = ( 0 );
   // --  2  - Index_End
    overlay_program[124] = ( graph->num_edges );
   // --  7  - Array_Pointer_LHS
    overlay_program[129] = xrt_buffer_device[5];
   // --  8  - Array_Pointer_RHS
    overlay_program[130] = xrt_buffer_device[5] >> 32;
   // --  9  - Array_size
    overlay_program[131] = ( graph->num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 16   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 17   mapping 1    cycles 13   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[134] = ( graph->num_vertices );
   // --  2  - Index_End
    overlay_program[135] = ( graph->num_vertices * 2 );
   // --  7  - Array_Pointer_LHS
    overlay_program[140] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[141] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[142] = ( graph->num_vertices * 2 )-( graph->num_vertices );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 18   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 19   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// --------------------------------------------------------------------------------------
// -->  CPP.Single.CC  <-- 
// Number of entries 156
