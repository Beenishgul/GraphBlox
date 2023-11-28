#include "glayenv.hpp"
void GLAYGraphCSRxrtBufferHandlePerKernel::mapGLAYOverlayProgramBuffersTC(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
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
// Name ENGINE_CSR_INDEX    ID 3    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[20] = ( 0 );
   // --  2  - Index_End
    overlay_program[21] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[26] = 0;
   // --  8  - Array_Pointer_RHS
    overlay_program[27] = 0;
   // --  9  - Array_size
    overlay_program[28] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 4    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 5    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[31] = ( 0 );
   // --  2  - Index_End
    overlay_program[32] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[37] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[38] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[39] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 6    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 7    mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[46] = ( 0 );
   // --  2  - Index_End
    overlay_program[47] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[52] = xrt_buffer_device[2];
   // --  8  - Array_Pointer_RHS
    overlay_program[53] = xrt_buffer_device[2] >> 32;
   // --  9  - Array_size
    overlay_program[54] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 8    mapping 2    cycles 10   buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[59] = ( 0 );
   // --  2  - Index_End
    overlay_program[60] = ( graph->num_edges );
   // --  7  - Array_Pointer_LHS
    overlay_program[65] = xrt_buffer_device[5];
   // --  8  - Array_Pointer_RHS
    overlay_program[66] = xrt_buffer_device[5] >> 32;
   // --  9  - Array_size
    overlay_program[67] = ( graph->num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 9    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 10   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 11   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 12   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 13   mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 14   mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[100] = ( 0 );
   // --  2  - Index_End
    overlay_program[101] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[106] = xrt_buffer_device[2];
   // --  8  - Array_Pointer_RHS
    overlay_program[107] = xrt_buffer_device[2] >> 32;
   // --  9  - Array_size
    overlay_program[108] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 15   mapping 2    cycles 10   buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[113] = ( 0 );
   // --  2  - Index_End
    overlay_program[114] = ( graph->num_edges );
   // --  7  - Array_Pointer_LHS
    overlay_program[119] = xrt_buffer_device[5];
   // --  8  - Array_Pointer_RHS
    overlay_program[120] = xrt_buffer_device[5] >> 32;
   // --  9  - Array_size
    overlay_program[121] = ( graph->num_edges )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 16   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 17   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 18   mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[133] = ( 0 );
   // --  2  - Index_End
    overlay_program[134] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[139] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[140] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[141] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 19   mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 20   mapping 1    cycles 13   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[148] = ( 0 );
   // --  2  - Index_End
    overlay_program[149] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[154] = xrt_buffer_device[2];
   // --  8  - Array_Pointer_RHS
    overlay_program[155] = xrt_buffer_device[2] >> 32;
   // --  9  - Array_size
    overlay_program[156] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 21   mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[161] = ( 0 );
   // --  2  - Index_End
    overlay_program[162] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[167] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[168] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[169] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 22   mapping 1    cycles 13   buffer_8-auxiliary_2 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[174] = ( 0 );
   // --  2  - Index_End
    overlay_program[175] = ( graph->num_vertices );
   // --  7  - Array_Pointer_LHS
    overlay_program[180] = xrt_buffer_device[8];
   // --  8  - Array_Pointer_RHS
    overlay_program[181] = xrt_buffer_device[8] >> 32;
   // --  9  - Array_size
    overlay_program[182] = ( graph->num_vertices )-( 0 );
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 23   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// --------------------------------------------------------------------------------------
// -->  CPP.Single.TC  <-- 
// Number of entries 187
