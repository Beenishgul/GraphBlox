// --------------------------------------------------------------------------------------
// Engine: ENGINE_ALU_OPS_0, Number of entries: 6
// --------------------------------------------------------------------------------------
0x00000010 // entry_0    cacheline[  0][ 0] < 6b>: alu_operation[0:5]=ALU_ACC
0x00000001 // entry_1    cacheline[  0][ 1] <20b>: alu_mask[0:3]=0x1 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000000 // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00008421 // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x8421
0x00040201 // entry_5    cacheline[  0][ 5] <24b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x04
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_1, Number of entries: 8
// --------------------------------------------------------------------------------------
0x00000001 // entry_0    cacheline[  0][ 6] < 5b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  0][ 7] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  0][ 8] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  0][ 9] <32b>: stride[0:31]=0x00000001
0x00000000 // entry_4    cacheline[  0][10] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000001 // entry_5    cacheline[  0][11] <30b>: cmd[0:5]=CMD_MEM_INVALID || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x00
0x00030201 // entry_6    cacheline[  0][12] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x02 || id_lane[16:23]=0x03 || id_buffer[24:31]=0x00
0x00000000 // entry_7    cacheline[  0][13] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_3, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  0][14] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_1    cacheline[  0][15] <32b>: shift.amount[0:30]=0x0000002 || shift.direction[31:31]=0x1
0x00400042 // entry_2    cacheline[  1][ 0] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x01 || id_engine[14:21]=0x00 || id_channel[22:29]=0x01
0x04010401 // entry_3    cacheline[  1][ 1] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x04 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x04
0x00000000 // entry_4    cacheline[  1][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_5    cacheline[  1][ 3] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_6    cacheline[  1][ 4] <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_MERGE_DATA_4, Number of entries: 2
// --------------------------------------------------------------------------------------
0x00000003 // entry_0    cacheline[  1][ 5] < 4b>: merge_mask[0:3]=0x3
0x00000000 // entry_1    cacheline[  1][ 6] < 4b>: merge_type[0:3]=0x0
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_5, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  1][ 7] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_1    cacheline[  1][ 8] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400002 // entry_2    cacheline[  1][ 9] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x01
0x02000000 // entry_3    cacheline[  1][10] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x02
0x00000000 // entry_4    cacheline[  1][11] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_5    cacheline[  1][12] <32b>: const_value[0:31]=0x00000000
0x00008412 // entry_6    cacheline[  1][13] <16b>: ops_mask[0:15]=0x8412
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_6, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  1][14] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_1    cacheline[  1][15] <32b>: shift.amount[0:30]=0x0000002 || shift.direction[31:31]=1
0x00400004 // entry_2    cacheline[  2][ 0] <30b>: cmd[0:5]=CMD_MEM_WRITE || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x01
0x80000000 // entry_3    cacheline[  2][ 1] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x80
0x00000000 // entry_4    cacheline[  2][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_5    cacheline[  2][ 3] <32b>: const_value[0:31]=0x00000000
0x00002481 // entry_6    cacheline[  2][ 4] <16b>: ops_mask[0:15]=0x2481
// --------------------------------------------------------------------------------------
// Engine: ENGINE_CSR_INDEX_8, Number of entries: 8
// --------------------------------------------------------------------------------------
0x0000000D // entry_0    cacheline[  2][ 5] < 5b>: increment[0:0]=1 || decrement[1:1]=0 || mode_sequence[2:2]=1 || mode_buffer[3:3]=1 || mode_break[4:4]=0
0x00000000 // entry_1    cacheline[  2][ 6] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry_2    cacheline[  2][ 7] <32b>: index_end[0:31]=0x00000000
0x00000001 // entry_3    cacheline[  2][ 8] <32b>: stride[0:31]=0x00000001
0x80000002 // entry_4    cacheline[  2][ 9] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00800008 // entry_5    cacheline[  2][10] <30b>: cmd[0:5]=CMD_STREAM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=buffer_5
0x10010801 // entry_6    cacheline[  2][11] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x08 || id_lane[16:23]=0x01 || id_buffer[24:31]=buffer_5
0x00000000 // entry_7    cacheline[  2][12] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// Engine: ENGINE_READ_WRITE_10, Number of entries: 7
// --------------------------------------------------------------------------------------
0x00000000 // entry_0    cacheline[  2][13] <32b>: index_start[0:31]=0x00000000
0x80000002 // entry_1    cacheline[  2][14] <32b>: shift.amount[0:30]=2 || shift.direction[31:31]=1
0x00400002 // entry_2    cacheline[  2][15] <30b>: cmd[0:5]=CMD_MEM_READ || id_module[6:13]=0x00 || id_engine[14:21]=0x00 || id_channel[22:29]=0x01
0x40010101 // entry_3    cacheline[  3][ 0] <32b>: id_cu[0:7]=0x01 || id_bundle[8:15]=0x01 || id_lane[16:23]=0x01 || id_buffer[24:31]=0x40
0x00000000 // entry_4    cacheline[  3][ 1] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry_5    cacheline[  3][ 2] <32b>: const_value[0:31]=0x00000000
0x00004812 // entry_6    cacheline[  3][ 3] <16b>: ops_mask[0:15]=0x4812
// --------------------------------------------------------------------------------------
// Number of entries 52
