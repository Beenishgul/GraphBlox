// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_0, Number of entries: 11
// --------------------------------------------------------------------------------------
0x00000021 // entry_0    cacheline[  0][ 0] < 6b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0 || mode_parallel[5:5]=1
0x00000000 // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000001
0x00000000 // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_5    cacheline[  0][ 5] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00010201 // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  0][ 8] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0
0x00000000 // entry_9    cacheline[  0][ 9] <32b>: const_value[0:31]=0x00000000
0x00000421 // entry_10   cacheline[  0][10] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_1, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  0][11] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_1    cacheline[  0][12] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00400002 // entry_2    cacheline[  0][13] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_7
0x40010401 // entry_3    cacheline[  0][14] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x01 || id_buffer[24:31]=buffer_7
0x00000000 // entry_4    cacheline[  0][15] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0
0x00000000 // entry_5    cacheline[  1][ 0] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_6    cacheline[  1][ 1] <16b>: field_1[0:3]=0x2 || field_2[4:7]=0x1 || field_3[8:11]=0x4 || field_4[12:15]=0x8
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_2, Number of entries: 10
// --------------------------------------------------------------------------------------
0x00000008 // entry_0    cacheline[  1][ 2] < 9b>: filter_operation[0:8]=FILTER_EQ
0x00000001 // entry_1    cacheline[  1][ 3] < 4b>: filter_mask[0:3]=0x1
0x00000000 // entry_2    cacheline[  1][ 4] < 8b>: const_mask[0:3]=0x0 || set_mask[4:7]=0x0
0x00000000 // entry_3    cacheline[  1][ 5] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  1][ 6] <32b>: set_value[0:31]=0x00000000
0x00008421 // entry_5    cacheline[  1][ 7] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000000 // entry_6    cacheline[  1][ 8] < 8b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0 || equal_flag[7:7]=0
0x00010401 // entry_7    cacheline[  1][ 9] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x04 || if_id_lane[16:23]=0x01 || if_id_buffer[24:31]=0x00
0x00000000 // entry_8    cacheline[  1][10] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry_9    cacheline[  1][11] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_3, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_PARALLEL_READ_WRITE_4, Number of entries: 29
// --------------------------------------------------------------------------------------
0x00000777 // entry_0    cacheline[  1][12] <16b>: lane_mask[0:3]=0x7 || cast_mask[4:7]=0x7 || merge_mask_1[8:11]=0x7 || merge_mask_2[12:15]=0x0
0x00000000 // entry_1    cacheline[  1][13] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_2    cacheline[  1][14] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400042 // entry_3    cacheline[  1][15] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x01 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_3
0x04020401 // entry_4    cacheline[  2][ 0] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x02 || id_buffer[24:31]=buffer_3
0x00010100 // entry_5    cacheline[  2][ 1] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x01 || op_lane[16:23]=0x01
0x00000000 // entry_6    cacheline[  2][ 2] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_7    cacheline[  2][ 3] <16b>: field_1[0:3]=0x2 || field_2[4:7]=0x1 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000000 // entry_8    cacheline[  2][ 4] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_9    cacheline[  2][ 5] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400042 // entry_10   cacheline[  2][ 6] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x01 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_2
0x02020401 // entry_11   cacheline[  2][ 7] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x02 || id_buffer[24:31]=buffer_2
0x00010100 // entry_12   cacheline[  2][ 8] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x01 || op_lane[16:23]=0x01
0x00000000 // entry_13   cacheline[  2][ 9] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_14   cacheline[  2][10] <16b>: field_1[0:3]=0x2 || field_2[4:7]=0x1 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000000 // entry_15   cacheline[  2][11] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_16   cacheline[  2][12] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400042 // entry_17   cacheline[  2][13] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x01 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_7
0x40020401 // entry_18   cacheline[  2][14] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x02 || id_buffer[24:31]=buffer_7
0x00010100 // entry_19   cacheline[  2][15] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x01 || op_lane[16:23]=0x01
0x00000000 // entry_20   cacheline[  3][ 0] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_21   cacheline[  3][ 1] <16b>: field_1[0:3]=0x2 || field_2[4:7]=0x1 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000000 // entry_22   cacheline[  3][ 2] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_23   cacheline[  3][ 3] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_24   cacheline[  3][ 4] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_25   cacheline[  3][ 5] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_26   cacheline[  3][ 6] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x00 || op_lane[16:23]=0x00
0x00000000 // entry_27   cacheline[  3][ 7] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_28   cacheline[  3][ 8] <16b>: field_1[0:3]=0x0 || field_2[4:7]=0x0 || field_3[8:11]=0x0 || field_4[12:15]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_5, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_PARALLEL_READ_WRITE_6, Number of entries: 29
// --------------------------------------------------------------------------------------
0x00000033 // entry_0    cacheline[  3][ 9] <16b>: lane_mask[0:3]=0x3 || cast_mask[4:7]=0x3 || merge_mask_1[8:11]=0x0 || merge_mask_2[12:15]=0x0
0x00000000 // entry_1    cacheline[  3][10] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_2    cacheline[  3][11] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400004 // entry_3    cacheline[  3][12] <30b>: cmd[0:5]=CMD_MEM_WRITE || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_7
0x40000000 // entry_4    cacheline[  3][13] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=buffer_7
0x00020430 // entry_5    cacheline[  3][14] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x3 || op_bundle[8:15]=0x04 || op_lane[16:23]=0x02
0x00000000 // entry_6    cacheline[  3][15] <32b>: const_value[0:31]=0x00000000
0x00008124 // entry_7    cacheline[  4][ 0] <16b>: field_1[0:3]=0x4 || field_2[4:7]=0x2 || field_3[8:11]=0x1 || field_4[12:15]=0x8
0x00000000 // entry_8    cacheline[  4][ 1] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_9    cacheline[  4][ 2] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400004 // entry_10   cacheline[  4][ 3] <30b>: cmd[0:5]=CMD_MEM_WRITE || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_8
0x80000000 // entry_11   cacheline[  4][ 4] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=buffer_8
0x00020433 // entry_12   cacheline[  4][ 5] <24b>: const_mask[0:3]=0x3 || mode_cache[4:7]=0x3 || op_bundle[8:15]=0x04 || op_lane[16:23]=0x02
0x00000001 // entry_13   cacheline[  4][ 6] <32b>: const_value[0:31]=0x00000001
0x00008421 // entry_14   cacheline[  4][ 7] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000000 // entry_15   cacheline[  4][ 8] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_16   cacheline[  4][ 9] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_17   cacheline[  4][10] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_18   cacheline[  4][11] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_19   cacheline[  4][12] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x00 || op_lane[16:23]=0x00
0x00000000 // entry_20   cacheline[  4][13] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_21   cacheline[  4][14] <16b>: field_1[0:3]=0x0 || field_2[4:7]=0x0 || field_3[8:11]=0x0 || field_4[12:15]=0x0
0x00000000 // entry_22   cacheline[  4][15] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_23   cacheline[  5][ 0] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_24   cacheline[  5][ 1] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_25   cacheline[  5][ 2] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_26   cacheline[  5][ 3] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x00 || op_lane[16:23]=0x00
0x00000000 // entry_27   cacheline[  5][ 4] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_28   cacheline[  5][ 5] <16b>: field_1[0:3]=0x0 || field_2[4:7]=0x0 || field_3[8:11]=0x0 || field_4[12:15]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_7, Number of entries: 11
// --------------------------------------------------------------------------------------
0x0000000D // entry_0    cacheline[  5][ 6] < 6b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=1 || mode_buffer[3:3]=1 || mode_break[4:4]=0 || mode_parallel[5:5]=0
0x00000000 // entry_1    cacheline[  5][ 7] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  5][ 8] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  5][ 9] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  5][10] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400002 // entry_5    cacheline[  5][11] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_5
0x10010801 // entry_6    cacheline[  5][12] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x08 || id_lane[16:23]=0x01 || id_buffer[24:31]=buffer_5
0x00000000 // entry_7    cacheline[  5][13] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  5][14] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0
0x00000000 // entry_9    cacheline[  5][15] <32b>: const_value[0:31]=0x00000000
0x00000421 // entry_10   cacheline[  6][ 0] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_8, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_9, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  6][ 1] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_1    cacheline[  6][ 2] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400002 // entry_2    cacheline[  6][ 3] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_7
0x40020101 // entry_3    cacheline[  6][ 4] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x01 || id_lane[16:23]=0x02 || id_buffer[24:31]=buffer_7
0x00000000 // entry_4    cacheline[  6][ 5] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0
0x00000000 // entry_5    cacheline[  6][ 6] <32b>: const_value[0:31]=0x00000000
0x00002418 // entry_6    cacheline[  6][ 7] <16b>: field_1[0:3]=0x8 || field_2[4:7]=0x1 || field_3[8:11]=0x4 || field_4[12:15]=0x2
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_10, Number of entries: 10
// --------------------------------------------------------------------------------------
0x00000010 // entry_0    cacheline[  6][ 8] < 9b>: filter_operation[0:8]=FILTER_NOT_EQ
0x00000001 // entry_1    cacheline[  6][ 9] < 4b>: filter_mask[0:3]=0x1
0x00000000 // entry_2    cacheline[  6][10] < 8b>: const_mask[0:3]=0x0 || set_mask[4:7]=0x0
0x00000000 // entry_3    cacheline[  6][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  6][12] <32b>: set_value[0:31]=0x00000000
0x00008421 // entry_5    cacheline[  6][13] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000010 // entry_6    cacheline[  6][14] < 8b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=1 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0 || equal_flag[7:7]=0
0x00020101 // entry_7    cacheline[  6][15] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x01 || if_id_lane[16:23]=0x02 || if_id_buffer[24:31]=0x00
0x00020101 // entry_8    cacheline[  7][ 0] <32b>: else_id_cu[0:7]=0x01 || else_id_bundle[8:15]=0x01 || else_id_lane[16:23]=0x02 || else_id_buffer[24:31]=0x00
0x00000000 // entry_9    cacheline[  7][ 1] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_11, Number of entries: 10
// --------------------------------------------------------------------------------------
0x00000020 // entry_0    cacheline[  7][ 2] < 9b>: filter_operation[0:8]=FILTER_GT_TERN
0x00000001 // entry_1    cacheline[  7][ 3] < 4b>: filter_mask[0:3]=0x1
0x00000000 // entry_2    cacheline[  7][ 4] < 8b>: const_mask[0:3]=0x0 || set_mask[4:7]=0x0
0x00000000 // entry_3    cacheline[  7][ 5] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  7][ 6] <32b>: set_value[0:31]=0x00000000
0x00008421 // entry_5    cacheline[  7][ 7] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000020 // entry_6    cacheline[  7][ 8] < 8b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=1 || conditional_flag[6:6]=0 || equal_flag[7:7]=0
0x00020101 // entry_7    cacheline[  7][ 9] <32b>: if_id_cu[0:7]=0x01 || if_id_bundle[8:15]=0x01 || if_id_lane[16:23]=0x02 || if_id_buffer[24:31]=0x00
0x00020101 // entry_8    cacheline[  7][10] <32b>: else_id_cu[0:7]=0x01 || else_id_bundle[8:15]=0x01 || else_id_lane[16:23]=0x02 || else_id_buffer[24:31]=0x00
0x00000000 // entry_9    cacheline[  7][11] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_12, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Number of entries 124
// CU vector 1
