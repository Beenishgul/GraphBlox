// --------------------------------------------------------------------------------------
// Engine: ENGINE_ALU_OPS_0, Number of entries: 6
// --------------------------------------------------------------------------------------
0x00000010 // entry_0    < 6b>: alu_operation[0:5]=ALU_ACC
0x00000001 // entry_1    <20b>: alu_mask[0:3]=0x1 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000001 // entry_2    < 4b>: const_mask[0:3]=0x1
0x00000001 // entry_3    <32b>: const_value[0:31]=0x00000001
0x00008421 // entry_4    <16b>: ops_mask[0:15]=0x8421
0x00040201 // entry_5    <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x04 || id_buffer[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_1, Number of entries: 10
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    < 5b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    <32b>: stride[0:31]=0x00000001
0x00000000 // entry_4    <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000120 // entry_5    <29b>: cmd[0:6]=CMD_ENGINE || buffer[7:12]=STRUCT_CU_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x01030201 // entry_6    <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x03 || id_buffer[24:31]=0x01
0x00000000 // entry_7    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_2, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    < 4b>: hops[0:3]=0x1
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_3, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    <32b>: stride[0:31]=0x1
0x80000002 // entry_4    <32b>: shift.amount[0:30]=0x2 || shift.direction[31:31]=0x1
0x00002202 // entry_5    <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x01 || id_engine[21:28]=0x00
0x00010401 // entry_6    <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x00
0x00000000 // entry_7    <32b>: array_pointer_lhs[0:31]=0x00000000
0x00000000 // entry_8    <32b>: array_pointer_rhs[0:31]=0x00000000
0x00000000 // entry_9    <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_12   <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_MERGE_DATA_4, Number of entries: 2
// --------------------------------------------------------------------------------------
0x00000003 // entry_0    < 4b>: merge_mask[0:3]=0x3
0x00000000 // entry_1    < 4b>: merge_type[0:3]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_5, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00002202 // entry_5    <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x01 || id_engine[21:28]=0x00
0x00000000 // entry_6    <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_12   <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_6, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    <32b>: shift.amount[0:30]=0x2 || shift.direction[31:31]=1
0x00000204 // entry_5    <29b>: cmd[0:6]=CMD_MEM_WRITE || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry_6    <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   <32b>: const_value[0:31]=0x00000000
0x00002481 // entry_12   <16b>: ops_mask[0:15]=0x2481
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_7, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_8, Number of entries: 10
// --------------------------------------------------------------------------------------
0x0000000D // entry_0    < 5b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=1 || mode_buffer[3:3]=1 || mode_break[4:4]=0
0x00000000 // entry_1    <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00000202 // entry_5    <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x01010101 // entry_6    <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x01 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x01
0x00000000 // entry_7    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_9, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    < 4b>: hops[0:3]=0x1
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_10, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00000202 // entry_5    <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x01010101 // entry_6    <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x01 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x01
0x00000000 // entry_7    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   <32b>: const_value[0:31]=0x00000000
0x00004812 // entry_12   <16b>: ops_mask[0:15]=0x4812
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_11, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    < 4b>: hops[0:3]=0x1
// --------------------------------------------------------------------------------------
// -->  Load.Single.PR  <-- 
// Number of entries 84
