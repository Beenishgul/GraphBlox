// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_0, Number of entries: 8
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_5    cacheline[  0][ 5] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_1, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  0][ 8] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_1    cacheline[  0][ 9] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_2    cacheline[  0][10] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_3    cacheline[  0][11] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_4    cacheline[  0][12] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_5    cacheline[  0][13] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_6    cacheline[  0][14] <16b>: ops_mask[0:15]=0x0000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_2, Number of entries: 9
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    cacheline[  0][15] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry_1    cacheline[  1][ 0] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry_2    cacheline[  1][ 1] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  1][ 2] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  1][ 3] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_5    cacheline[  1][ 4] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry_6    cacheline[  1][ 5] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  1][ 6] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry_8    cacheline[  1][ 7] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_3, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_PARALLEL_READ_WRITE_4, Number of entries: 29
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  1][ 8] <12b>: lane_mask[0:3]=0x0 || cast_mask[4:7]=0x0 || merge_mask[8:11]=0x0
0x00000000 // entry_1    cacheline[  1][ 9] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  1][10] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_3    cacheline[  1][11] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_4    cacheline[  1][12] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_5    cacheline[  1][13] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_6    cacheline[  1][14] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_7    cacheline[  1][15] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_8    cacheline[  2][ 0] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  2][ 1] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_10   cacheline[  2][ 2] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_11   cacheline[  2][ 3] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_12   cacheline[  2][ 4] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_13   cacheline[  2][ 5] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_14   cacheline[  2][ 6] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_15   cacheline[  2][ 7] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_16   cacheline[  2][ 8] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_17   cacheline[  2][ 9] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_18   cacheline[  2][10] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_19   cacheline[  2][11] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_20   cacheline[  2][12] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_21   cacheline[  2][13] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_22   cacheline[  2][14] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_23   cacheline[  2][15] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_24   cacheline[  3][ 0] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_25   cacheline[  3][ 1] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_26   cacheline[  3][ 2] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_27   cacheline[  3][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_28   cacheline[  3][ 4] <16b>: ops_mask[0:15]=0x0000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_5, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_PARALLEL_READ_WRITE_6, Number of entries: 29
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  3][ 5] <12b>: lane_mask[0:3]=0x0 || cast_mask[4:7]=0x0 || merge_mask[8:11]=0x0
0x00000000 // entry_1    cacheline[  3][ 6] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  3][ 7] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_3    cacheline[  3][ 8] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_4    cacheline[  3][ 9] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_5    cacheline[  3][10] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_6    cacheline[  3][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_7    cacheline[  3][12] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_8    cacheline[  3][13] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_9    cacheline[  3][14] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_10   cacheline[  3][15] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_11   cacheline[  4][ 0] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_12   cacheline[  4][ 1] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_13   cacheline[  4][ 2] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_14   cacheline[  4][ 3] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_15   cacheline[  4][ 4] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_16   cacheline[  4][ 5] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_17   cacheline[  4][ 6] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_18   cacheline[  4][ 7] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_19   cacheline[  4][ 8] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_20   cacheline[  4][ 9] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_21   cacheline[  4][10] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_22   cacheline[  4][11] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_23   cacheline[  4][12] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_24   cacheline[  4][13] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_25   cacheline[  4][14] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_26   cacheline[  4][15] <20b>: const_mask[0:3]=0x0 || op_bundle[4:11]=0x00 || op_lane[12:19]=0x00
0x00000000 // entry_27   cacheline[  5][ 0] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_28   cacheline[  5][ 1] <16b>: ops_mask[0:15]=0x0000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_7, Number of entries: 8
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  5][ 2] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  5][ 3] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  5][ 4] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry_3    cacheline[  5][ 5] <32b>: stride[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  5][ 6] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_5    cacheline[  5][ 7] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_6    cacheline[  5][ 8] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  5][ 9] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_8, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_9, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  5][10] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_1    cacheline[  5][11] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_2    cacheline[  5][12] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_3    cacheline[  5][13] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_4    cacheline[  5][14] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_5    cacheline[  5][15] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_6    cacheline[  6][ 0] <16b>: ops_mask[0:15]=0x0000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_10, Number of entries: 9
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    cacheline[  6][ 1] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry_1    cacheline[  6][ 2] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry_2    cacheline[  6][ 3] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  6][ 4] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  6][ 5] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_5    cacheline[  6][ 6] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry_6    cacheline[  6][ 7] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  6][ 8] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry_8    cacheline[  6][ 9] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FILTER_COND_11, Number of entries: 9
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    cacheline[  6][10] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry_1    cacheline[  6][11] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry_2    cacheline[  6][12] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  6][13] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_4    cacheline[  6][14] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry_5    cacheline[  6][15] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry_6    cacheline[  7][ 0] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  7][ 1] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry_8    cacheline[  7][ 2] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_12, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Number of entries 115
