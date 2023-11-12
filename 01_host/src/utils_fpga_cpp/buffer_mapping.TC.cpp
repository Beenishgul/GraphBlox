#include "glayenv.hpp"
void GLAYGraphCSRxrtBufferHandlePerBank::mapGLAYOverlayProgramBuffersTC(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
{
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 1    mapping 2    cycles 10   None-NONE 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[1] = 0;
   // --  2  - Index_End
    overlay_program[2] = graph->num_vertices;
   // --  7  - Array_Pointer_LHS
    overlay_program[7] = 0;
   // --  8  - Array_Pointer_RHS
    overlay_program[8] = 0;
   // --  9  - Array_size
    overlay_program[9] = graph->num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 2    mapping 5    cycles 6    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 3    mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 4    mapping 1    cycles 13   buffer_3-edges_idx 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[18] = 0;
   // --  2  - Index_End
    overlay_program[19] = graph->num_vertices;
   // --  7  - Array_Pointer_LHS
    overlay_program[24] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[25] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[26] = graph->num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 5    mapping 4    cycles 2    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 13   buffer_1-out_degree 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[33] = 0;
   // --  2  - Index_End
    overlay_program[34] = graph->num_vertices;
   // --  7  - Array_Pointer_LHS
    overlay_program[39] = xrt_buffer_device[1];
   // --  8  - Array_Pointer_RHS
    overlay_program[40] = xrt_buffer_device[1] >> 32;
   // --  9  - Array_size
    overlay_program[41] = graph->num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 7    mapping 1    cycles 13   buffer_7-auxiliary_1 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[46] = 0;
   // --  2  - Index_End
    overlay_program[47] = graph->num_vertices;
   // --  7  - Array_Pointer_LHS
    overlay_program[52] = xrt_buffer_device[7];
   // --  8  - Array_Pointer_RHS
    overlay_program[53] = xrt_buffer_device[7] >> 32;
   // --  9  - Array_size
    overlay_program[54] = graph->num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 8    mapping 2    cycles 10   None-NONE 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[59] = 0;
   // --  2  - Index_End
    overlay_program[60] = graph->num_vertices;
   // --  7  - Array_Pointer_LHS
    overlay_program[65] = 0;
   // --  8  - Array_Pointer_RHS
    overlay_program[66] = 0;
   // --  9  - Array_size
    overlay_program[67] = graph->num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 9    mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 10   mapping 2    cycles 10   buffer_4-edges_array_dest 0-num_edges
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[70] = 0;
   // --  2  - Index_End
    overlay_program[71] = graph->num_edges;
   // --  7  - Array_Pointer_LHS
    overlay_program[76] = xrt_buffer_device[4];
   // --  8  - Array_Pointer_RHS
    overlay_program[77] = xrt_buffer_device[4] >> 32;
   // --  9  - Array_size
    overlay_program[78] = graph->num_edges;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 11   mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 12   mapping 1    cycles 13   buffer_3-edges_idx 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[81] = 0;
   // --  2  - Index_End
    overlay_program[82] = graph->num_vertices;
   // --  7  - Array_Pointer_LHS
    overlay_program[87] = xrt_buffer_device[3];
   // --  8  - Array_Pointer_RHS
    overlay_program[88] = xrt_buffer_device[3] >> 32;
   // --  9  - Array_size
    overlay_program[89] = graph->num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 13   mapping 4    cycles 2    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 14   mapping 1    cycles 13   buffer_1-out_degree 0-num_vertices
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[96] = 0;
   // --  2  - Index_End
    overlay_program[97] = graph->num_vertices;
   // --  7  - Array_Pointer_LHS
    overlay_program[102] = xrt_buffer_device[1];
   // --  8  - Array_Pointer_RHS
    overlay_program[103] = xrt_buffer_device[1] >> 32;
   // --  9  - Array_size
    overlay_program[104] = graph->num_vertices;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 15   mapping 2    cycles 10   buffer_4-edges_array_dest 0-num_edges
// --------------------------------------------------------------------------------------
   // --  1  - Index_Start
    overlay_program[109] = 0;
   // --  2  - Index_End
    overlay_program[110] = graph->num_edges;
   // --  7  - Array_Pointer_LHS
    overlay_program[115] = xrt_buffer_device[4];
   // --  8  - Array_Pointer_RHS
    overlay_program[116] = xrt_buffer_device[4] >> 32;
   // --  9  - Array_size
    overlay_program[117] = graph->num_edges;
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 16   mapping 6    cycles 1    None-None 0-0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
}
// Number of entries 119
