// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_0, Number of entries: 10
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000001
0x00000000 // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000120 // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_ENGINE || buffer[7:12]=STRUCT_CU_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x01070201 // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x07 || id_buffer[24:31]=0x01
0x00000000 // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_1, Number of entries: 9
// --------------------------------------------------------------------------------------
0x00000040 // entry_0    cacheline[  0][10] < 9b>: filter_operation[0:8]=FILTER_LT_TERN
0x00000001 // entry_1    cacheline[  0][11] < 4b>: filter_mask[0:3]=0x1
0x00000000 // entry_2    cacheline[  0][12] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  0][13] <32b>: const_value[0:31]=0x00000000
0x00001428 // entry_4    cacheline[  0][14] <16b>: ops_mask[0:15]=0x1428
0x00000020 // entry_5    cacheline[  0][15] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=1 || conditional_flag[6:6]=0
0x00080201 // entry_6    cacheline[  1][ 0] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x02 || if_id_lane[16:23]=0x08 || if_id_buffer[24:31]=0x00
0x00080201 // entry_7    cacheline[  1][ 1] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x02 || if_id_lane[16:23]=0x08 || if_id_buffer[24:31]=0x00
0x00010001 // entry_8    cacheline[  1][ 2] <32b>: if_id_module[0:7]=0x01 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x01 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_ALU_OPS_2, Number of entries: 6
// --------------------------------------------------------------------------------------
0x00000004 // entry_0    cacheline[  1][ 3] < 6b>: alu_operation[0:5]=ALU_SUB
0x00000001 // entry_1    cacheline[  1][ 4] <20b>: alu_mask[0:3]=0x1 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000000 // entry_2    cacheline[  1][ 5] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  1][ 6] <32b>: const_value[0:31]=0x00000000
0x00008421 // entry_4    cacheline[  1][ 7] <16b>: ops_mask[0:15]=0x8421
0x00080201 // entry_5    cacheline[  1][ 8] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x08 || id_buffer[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_ALU_OPS_3, Number of entries: 6
// --------------------------------------------------------------------------------------
0x00000002 // entry_0    cacheline[  1][ 9] < 6b>: alu_operation[0:5]=ALU_ADD
0x00000001 // entry_1    cacheline[  1][10] <20b>: alu_mask[0:3]=0x1 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000000 // entry_2    cacheline[  1][11] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  1][12] <32b>: const_value[0:31]=0x00000000
0x00008241 // entry_4    cacheline[  1][13] <16b>: ops_mask[0:15]=0x8241
0x00080201 // entry_5    cacheline[  1][14] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x08 || id_buffer[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_4, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  1][15] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_5, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  2][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  2][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  2][ 2] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  2][ 3] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  2][ 4] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00002202 // entry_5    cacheline[  2][ 5] <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x01 || id_engine[21:28]=0x00
0x00010401 // entry_6    cacheline[  2][ 6] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  2][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  2][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  2][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   cacheline[  2][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   cacheline[  2][11] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_12   cacheline[  2][12] <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_MERGE_DATA_6, Number of entries: 2
// --------------------------------------------------------------------------------------
0x00000007 // entry_0    cacheline[  2][13] < 4b>: merge_mask[0:3]=0x7
0x00000000 // entry_1    cacheline[  2][14] < 4b>: merge_type[0:3]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_7, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  2][15] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  3][ 0] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  3][ 1] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  3][ 2] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  3][ 3] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00000202 // entry_5    cacheline[  3][ 4] <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry_6    cacheline[  3][ 5] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  3][ 6] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  3][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  3][ 8] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   cacheline[  3][ 9] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   cacheline[  3][10] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_12   cacheline[  3][11] <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_8, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  3][12] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  3][13] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  3][14] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  3][15] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  4][ 0] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00000202 // entry_5    cacheline[  4][ 1] <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry_6    cacheline[  4][ 2] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  4][ 3] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  4][ 4] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  4][ 5] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   cacheline[  4][ 6] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   cacheline[  4][ 7] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_12   cacheline[  4][ 8] <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_9, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  4][ 9] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  4][10] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  4][11] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  4][12] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  4][13] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00002202 // entry_5    cacheline[  4][14] <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x01 || id_engine[21:28]=0x00
0x00030401 // entry_6    cacheline[  4][15] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x03 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  5][ 0] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  5][ 1] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  5][ 2] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   cacheline[  5][ 3] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   cacheline[  5][ 4] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_12   cacheline[  5][ 5] <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_10, Number of entries: 9
// --------------------------------------------------------------------------------------
0x00000008 // entry_0    cacheline[  5][ 6] < 9b>: filter_operation[0:8]=FILTER_EQ
0x00000001 // entry_1    cacheline[  5][ 7] < 4b>: filter_mask[0:3]=0x1
0x00000000 // entry_2    cacheline[  5][ 8] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  5][ 9] <32b>: const_value[0:31]=0x00000000
0x00008421 // entry_4    cacheline[  5][10] <16b>: ops_mask[0:15]=0x8421
0x00000000 // entry_5    cacheline[  5][11] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00030401 // entry_6    cacheline[  5][12] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x04 || if_id_lane[16:23]=0x03 || if_id_buffer[24:31]=0x00
0x00030401 // entry_7    cacheline[  5][13] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x04 || if_id_lane[16:23]=0x03 || if_id_buffer[24:31]=0x00
0x00010001 // entry_8    cacheline[  5][14] <32b>: if_id_module[0:7]=0x01 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x01 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_11, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  5][15] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_12, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  6][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  6][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  6][ 2] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  6][ 3] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  6][ 4] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00002204 // entry_5    cacheline[  6][ 5] <29b>: cmd[0:6]=CMD_MEM_WRITE || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x01 || id_engine[21:28]=0x00
0x00000000 // entry_6    cacheline[  6][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  6][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  6][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  6][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   cacheline[  6][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   cacheline[  6][11] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_12   cacheline[  6][12] <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_13, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  6][13] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  6][14] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  6][15] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  7][ 0] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  7][ 1] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00002204 // entry_5    cacheline[  7][ 2] <29b>: cmd[0:6]=CMD_MEM_WRITE || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x01 || id_engine[21:28]=0x00
0x00000000 // entry_6    cacheline[  7][ 3] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  7][ 4] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  7][ 5] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  7][ 6] <32b>: array_size[0:31]=0x00000000
0x00000001 // entry_10   cacheline[  7][ 7] < 4b>: const_mask[0:3]=0x1
0x00000001 // entry_11   cacheline[  7][ 8] <32b>: const_value[0:31]=0x00000001
0x00008421 // entry_12   cacheline[  7][ 9] <16b>: ops_mask[0:15]=0x8421
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_14, Number of entries: 10
// --------------------------------------------------------------------------------------
0x0000000D // entry_0    cacheline[  7][10] < 5b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=1 || mode_buffer[3:3]=1 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  7][11] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  7][12] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  7][13] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  7][14] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00000202 // entry_5    cacheline[  7][15] <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00010801 // entry_6    cacheline[  8][ 0] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x08 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  8][ 1] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  8][ 2] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  8][ 3] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_15, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  8][ 4] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_16, Number of entries: 13
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  8][ 5] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  8][ 6] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  8][ 7] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  8][ 8] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  8][ 9] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00000202 // entry_5    cacheline[  8][10] <29b>: cmd[0:6]=CMD_MEM_READ || buffer[7:12]=STRUCT_ENGINE_DATA || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00020101 // entry_6    cacheline[  8][11] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x01 || id_lane[16:23]=0x02 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  8][12] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  8][13] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  8][14] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_10   cacheline[  8][15] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_11   cacheline[  9][ 0] <32b>: const_value[0:31]=0x00000000
0x00008421 // entry_12   cacheline[  9][ 1] <16b>: ops_mask[0:15]=0x8421
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_17, Number of entries: 9
// --------------------------------------------------------------------------------------
0x00000008 // entry_0    cacheline[  9][ 2] < 9b>: filter_operation[0:8]=FILTER_EQ
0x00000001 // entry_1    cacheline[  9][ 3] < 4b>: filter_mask[0:3]=0x1
0x00000000 // entry_2    cacheline[  9][ 4] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  9][ 5] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  9][ 6] <16b>: ops_mask[0:15]=0x0000
0x00000010 // entry_5    cacheline[  9][ 7] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=1 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00020101 // entry_6    cacheline[  9][ 8] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x01 || if_id_lane[16:23]=0x02 || if_id_buffer[24:31]=0x00
0x00020101 // entry_7    cacheline[  9][ 9] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x01 || if_id_lane[16:23]=0x02 || if_id_buffer[24:31]=0x00
0x00010001 // entry_8    cacheline[  9][10] <32b>: if_id_module[0:7]=0x01 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x01 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_18, Number of entries: 1
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  9][11] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// -->  Load.Single.CC  <-- 
// Number of entries 156
