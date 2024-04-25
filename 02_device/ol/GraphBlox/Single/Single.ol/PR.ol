// --------------------------------------------------------------------------------------
// Engine: ENGINE_ALU_OPS_0, Number of entries: 6
// --------------------------------------------------------------------------------------
0x00000010 // entry_0    cacheline[  0][ 0] < 6b>: alu_operation[0:5]=ALU_ACC
0x00000001 // entry_1    cacheline[  0][ 1] <20b>: alu_mask[0:3]=0x1 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000000 // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00008421 // entry_4    cacheline[  0][ 4] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00020201 // entry_5    cacheline[  0][ 5] <24b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x02
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_1, Number of entries: 11
// --------------------------------------------------------------------------------------
0x00000021 // entry_0    cacheline[  0][ 6] < 6b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0 || mode_parallel[5:5]=1
0x00000000 // entry_1    cacheline[  0][ 7] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  0][ 8] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  0][ 9] <32b>: stride[0:31]=0x00000001
0x00000000 // entry_4    cacheline[  0][10] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_5    cacheline[  0][11] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00010201 // entry_6    cacheline[  0][12] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  0][13] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry_8    cacheline[  0][14] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0
0x00000000 // entry_9    cacheline[  0][15] <32b>: const_value[0:31]=0x00000000
0x00000421 // entry_10   cacheline[  1][ 0] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_2, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_PARALLEL_READ_WRITE_3, Number of entries: 29
// --------------------------------------------------------------------------------------
0x00003333 // entry_0    cacheline[  1][ 1] <16b>: lane_mask[0:3]=0x3 || cast_mask[4:7]=0x3 || merge_mask_1[8:11]=0x3 || merge_mask_2[12:15]=0x3
0x00000000 // entry_1    cacheline[  1][ 2] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_2    cacheline[  1][ 3] <32b>: shift.amount[0:30]=0x0000002 || shift.direction[31:31]=0x1
0x00400042 // entry_3    cacheline[  1][ 4] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x01 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_3
0x04010401 // entry_4    cacheline[  1][ 5] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x01 || id_buffer[24:31]=buffer_3
0x00020130 // entry_5    cacheline[  1][ 6] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x3 || op_bundle[8:15]=0x01 || op_lane[16:23]=0x02
0x00000000 // entry_6    cacheline[  1][ 7] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_7    cacheline[  1][ 8] <16b>: field_1[0:3]=0x2 || field_2[4:7]=0x1 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000000 // entry_8    cacheline[  1][ 9] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_9    cacheline[  1][10] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400042 // entry_10   cacheline[  1][11] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x01 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_2
0x02010401 // entry_11   cacheline[  1][12] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x01 || id_buffer[24:31]=buffer_2
0x00020130 // entry_12   cacheline[  1][13] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x3 || op_bundle[8:15]=0x01 || op_lane[16:23]=0x02
0x00000000 // entry_13   cacheline[  1][14] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_14   cacheline[  1][15] <16b>: field_1[0:3]=0x2 || field_2[4:7]=0x1 || field_3[8:11]=0x4 || field_4[12:15]=0x8
0x00000000 // entry_15   cacheline[  2][ 0] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_16   cacheline[  2][ 1] <32b>: shift.amount[0:30]=0x0000002 || shift.direction[31:31]=1
0x00000001 // entry_17   cacheline[  2][ 2] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_18   cacheline[  2][ 3] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00010100 // entry_19   cacheline[  2][ 4] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x01 || op_lane[16:23]=0x01
0x00000000 // entry_20   cacheline[  2][ 5] <32b>: const_value[0:31]=0x00000000
0x00002481 // entry_21   cacheline[  2][ 6] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x8 || field_3[8:11]=0x4 || field_4[12:15]=0x2
0x00000000 // entry_22   cacheline[  2][ 7] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_23   cacheline[  2][ 8] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_24   cacheline[  2][ 9] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00000000 // entry_25   cacheline[  2][10] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry_26   cacheline[  2][11] <24b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x0 || op_bundle[8:15]=0x00 || op_lane[16:23]=0x00
0x00000000 // entry_27   cacheline[  2][12] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry_28   cacheline[  2][13] <16b>: field_1[0:3]=0x0 || field_2[4:7]=0x0 || field_3[8:11]=0x0 || field_4[12:15]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_4, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  2][14] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_1    cacheline[  2][15] <32b>: shift.amount[0:30]=0x0000002 || shift.direction[31:31]=1
0x00400004 // entry_2    cacheline[  3][ 0] <30b>: cmd[0:5]=CMD_MEM_WRITE || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_8
0x80000000 // entry_3    cacheline[  3][ 1] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=buffer_8
0x000000F0 // entry_4    cacheline[  3][ 2] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0xF
0x00000000 // entry_5    cacheline[  3][ 3] <32b>: const_value[0:31]=0x00000000
0x00002481 // entry_6    cacheline[  3][ 4] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x8 || field_3[8:11]=0x4 || field_4[12:15]=0x2
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_5, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_6, Number of entries: 11
// --------------------------------------------------------------------------------------
0x0000000D // entry_0    cacheline[  3][ 5] < 6b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=1 || mode_buffer[3:3]=1 || mode_break[4:4]=0 || mode_parallel[5:5]=0
0x00000000 // entry_1    cacheline[  3][ 6] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  3][ 7] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  3][ 8] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  3][ 9] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400002 // entry_5    cacheline[  3][10] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_5
0x10010801 // entry_6    cacheline[  3][11] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x08 || id_lane[16:23]=0x01 || id_buffer[24:31]=buffer_5
0x00000000 // entry_7    cacheline[  3][12] <32b>: array_size[0:31]=0x00000000
0x00000030 // entry_8    cacheline[  3][13] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0x3
0x00000000 // entry_9    cacheline[  3][14] <32b>: const_value[0:31]=0x00000000
0x00000421 // entry_10   cacheline[  3][15] <16b>: field_1[0:3]=0x1 || field_2[4:7]=0x2 || field_3[8:11]=0x4 || field_4[12:15]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_7, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_8, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  4][ 0] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_1    cacheline[  4][ 1] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400002 // entry_2    cacheline[  4][ 2] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x01
0x40010101 // entry_3    cacheline[  4][ 3] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x01 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x40
0x000000F0 // entry_4    cacheline[  4][ 4] < 8b>: const_mask[0:3]=0x0 || mode_cache[4:7]=0xF
0x00000000 // entry_5    cacheline[  4][ 5] <32b>: const_value[0:31]=0x00000000
0x00004812 // entry_6    cacheline[  4][ 6] <16b>: field_1[0:3]=0x2 || field_2[4:7]=0x1 || field_3[8:11]=0x8 || field_4[12:15]=0x4
// --------------------------------------------------------------------------------------
// Engine: ENGINE_FORWARD_DATA_8, Number of entries: 0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Number of entries 71
// CU vector 255
