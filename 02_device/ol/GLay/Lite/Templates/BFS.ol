// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 0    mapping 2    cycles 10   None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 0    cacheline 0    offset 0    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 1    cacheline 0    offset 1    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 2    cacheline 0    offset 2    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 3    cacheline 0    offset 3    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 4    cacheline 0    offset 4    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 5    cacheline 0    offset 5    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 6    cacheline 0    offset 6    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 7    cacheline 0    offset 7    -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 8    cacheline 0    offset 8    -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 9    cacheline 0    offset 9    -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 1    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 10   cacheline 0    offset 10   -- // entry_0    cacheline[  0][ 0] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry 11   cacheline 0    offset 11   -- // entry_1    cacheline[  0][ 1] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry 12   cacheline 0    offset 12   -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 13   cacheline 0    offset 13   -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 14   cacheline 0    offset 14   -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 15   cacheline 0    offset 15   -- // entry_5    cacheline[  0][ 5] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry 16   cacheline 1    offset 0    -- // entry_6    cacheline[  0][ 6] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry 17   cacheline 1    offset 1    -- // entry_7    cacheline[  0][ 7] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry 18   cacheline 1    offset 2    -- // entry_8    cacheline[  0][ 8] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 2    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 19   cacheline 1    offset 3    -- // entry_0    cacheline[  0][ 0] < 6b>: alu_operation[0:5]=ALU_NOP
0x00000000 // entry 20   cacheline 1    offset 4    -- // entry_1    cacheline[  0][ 1] <20b>: alu_mask[0:3]=0x0 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000000 // entry 21   cacheline 1    offset 5    -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 22   cacheline 1    offset 6    -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 23   cacheline 1    offset 7    -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 24   cacheline 1    offset 8    -- // entry_5    cacheline[  0][ 5] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 3    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 25   cacheline 1    offset 9    -- // entry_0    cacheline[  0][ 0] < 6b>: alu_operation[0:5]=ALU_NOP
0x00000000 // entry 26   cacheline 1    offset 10   -- // entry_1    cacheline[  0][ 1] <20b>: alu_mask[0:3]=0x0 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000000 // entry 27   cacheline 1    offset 11   -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 28   cacheline 1    offset 12   -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 29   cacheline 1    offset 13   -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 30   cacheline 1    offset 14   -- // entry_5    cacheline[  0][ 5] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 4    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 31   cacheline 1    offset 15   -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 5    mapping 1    cycles 13   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 32   cacheline 2    offset 0    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 33   cacheline 2    offset 1    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 34   cacheline 2    offset 2    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 35   cacheline 2    offset 3    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 36   cacheline 2    offset 4    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 37   cacheline 2    offset 5    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 38   cacheline 2    offset 6    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 39   cacheline 2    offset 7    -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 40   cacheline 2    offset 8    -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 41   cacheline 2    offset 9    -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 42   cacheline 2    offset 10   -- // entry_10   cacheline[  0][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 43   cacheline 2    offset 11   -- // entry_11   cacheline[  0][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 44   cacheline 2    offset 12   -- // entry_12   cacheline[  0][12] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 6    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 45   cacheline 2    offset 13   -- // entry_0    cacheline[  0][ 0] < 4b>: merge_mask[0:3]=0x0
0x00000000 // entry 46   cacheline 2    offset 14   -- // entry_1    cacheline[  0][ 1] < 4b>: merge_type[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 7    mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 47   cacheline 2    offset 15   -- // entry_0    cacheline[  0][ 0] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry 48   cacheline 3    offset 0    -- // entry_1    cacheline[  0][ 1] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry 49   cacheline 3    offset 1    -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 50   cacheline 3    offset 2    -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 51   cacheline 3    offset 3    -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 52   cacheline 3    offset 4    -- // entry_5    cacheline[  0][ 5] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry 53   cacheline 3    offset 5    -- // entry_6    cacheline[  0][ 6] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry 54   cacheline 3    offset 6    -- // entry_7    cacheline[  0][ 7] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry 55   cacheline 3    offset 7    -- // entry_8    cacheline[  0][ 8] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 8    mapping 1    cycles 13   buffer_1-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 56   cacheline 3    offset 8    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 57   cacheline 3    offset 9    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 58   cacheline 3    offset 10   -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 59   cacheline 3    offset 11   -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 60   cacheline 3    offset 12   -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 61   cacheline 3    offset 13   -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 62   cacheline 3    offset 14   -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 63   cacheline 3    offset 15   -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 64   cacheline 4    offset 0    -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 65   cacheline 4    offset 1    -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 66   cacheline 4    offset 2    -- // entry_10   cacheline[  0][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 67   cacheline 4    offset 3    -- // entry_11   cacheline[  0][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 68   cacheline 4    offset 4    -- // entry_12   cacheline[  0][12] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 9    mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 69   cacheline 4    offset 5    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 70   cacheline 4    offset 6    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 71   cacheline 4    offset 7    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 72   cacheline 4    offset 8    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 73   cacheline 4    offset 9    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 74   cacheline 4    offset 10   -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 75   cacheline 4    offset 11   -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 76   cacheline 4    offset 12   -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 77   cacheline 4    offset 13   -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 78   cacheline 4    offset 14   -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 79   cacheline 4    offset 15   -- // entry_10   cacheline[  0][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 80   cacheline 5    offset 0    -- // entry_11   cacheline[  0][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 81   cacheline 5    offset 1    -- // entry_12   cacheline[  0][12] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 10   mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 82   cacheline 5    offset 2    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 83   cacheline 5    offset 3    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 84   cacheline 5    offset 4    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 85   cacheline 5    offset 5    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 86   cacheline 5    offset 6    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 87   cacheline 5    offset 7    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 88   cacheline 5    offset 8    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 89   cacheline 5    offset 9    -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 90   cacheline 5    offset 10   -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 91   cacheline 5    offset 11   -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 92   cacheline 5    offset 12   -- // entry_10   cacheline[  0][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 93   cacheline 5    offset 13   -- // entry_11   cacheline[  0][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 94   cacheline 5    offset 14   -- // entry_12   cacheline[  0][12] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 11   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 95   cacheline 5    offset 15   -- // entry_0    cacheline[  0][ 0] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry 96   cacheline 6    offset 0    -- // entry_1    cacheline[  0][ 1] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry 97   cacheline 6    offset 1    -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 98   cacheline 6    offset 2    -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 99   cacheline 6    offset 3    -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 100  cacheline 6    offset 4    -- // entry_5    cacheline[  0][ 5] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry 101  cacheline 6    offset 5    -- // entry_6    cacheline[  0][ 6] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry 102  cacheline 6    offset 6    -- // entry_7    cacheline[  0][ 7] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry 103  cacheline 6    offset 7    -- // entry_8    cacheline[  0][ 8] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 12   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 104  cacheline 6    offset 8    -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 13   mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 105  cacheline 6    offset 9    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 106  cacheline 6    offset 10   -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 107  cacheline 6    offset 11   -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 108  cacheline 6    offset 12   -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 109  cacheline 6    offset 13   -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 110  cacheline 6    offset 14   -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 111  cacheline 6    offset 15   -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 112  cacheline 7    offset 0    -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 113  cacheline 7    offset 1    -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 114  cacheline 7    offset 2    -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 115  cacheline 7    offset 3    -- // entry_10   cacheline[  0][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 116  cacheline 7    offset 4    -- // entry_11   cacheline[  0][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 117  cacheline 7    offset 5    -- // entry_12   cacheline[  0][12] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 14   mapping 1    cycles 13   buffer_8-auxiliary_2 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 118  cacheline 7    offset 6    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 119  cacheline 7    offset 7    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 120  cacheline 7    offset 8    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 121  cacheline 7    offset 9    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 122  cacheline 7    offset 10   -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 123  cacheline 7    offset 11   -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 124  cacheline 7    offset 12   -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 125  cacheline 7    offset 13   -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 126  cacheline 7    offset 14   -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 127  cacheline 7    offset 15   -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 128  cacheline 8    offset 0    -- // entry_10   cacheline[  0][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 129  cacheline 8    offset 1    -- // entry_11   cacheline[  0][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 130  cacheline 8    offset 2    -- // entry_12   cacheline[  0][12] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 15   mapping 2    cycles 10   buffer_4-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
0x00000000 // entry 131  cacheline 8    offset 3    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 132  cacheline 8    offset 4    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 133  cacheline 8    offset 5    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 134  cacheline 8    offset 6    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 135  cacheline 8    offset 7    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 136  cacheline 8    offset 8    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 137  cacheline 8    offset 9    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 138  cacheline 8    offset 10   -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 139  cacheline 8    offset 11   -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 140  cacheline 8    offset 12   -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 16   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 141  cacheline 8    offset 13   -- // entry_0    cacheline[  0][ 0] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry 142  cacheline 8    offset 14   -- // entry_1    cacheline[  0][ 1] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry 143  cacheline 8    offset 15   -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 144  cacheline 9    offset 0    -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 145  cacheline 9    offset 1    -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 146  cacheline 9    offset 2    -- // entry_5    cacheline[  0][ 5] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry 147  cacheline 9    offset 3    -- // entry_6    cacheline[  0][ 6] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry 148  cacheline 9    offset 4    -- // entry_7    cacheline[  0][ 7] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry 149  cacheline 9    offset 5    -- // entry_8    cacheline[  0][ 8] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 17   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 150  cacheline 9    offset 6    -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 18   mapping 1    cycles 13   buffer_7-auxiliary_1 ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 151  cacheline 9    offset 7    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 152  cacheline 9    offset 8    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 153  cacheline 9    offset 9    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 154  cacheline 9    offset 10   -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 155  cacheline 9    offset 11   -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 156  cacheline 9    offset 12   -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 157  cacheline 9    offset 13   -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 158  cacheline 9    offset 14   -- // entry_7    cacheline[  0][ 7] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 159  cacheline 9    offset 15   -- // entry_8    cacheline[  0][ 8] <32b>: array_pointer[0:31]=0x00000000
0x00000000 // entry 160  cacheline 10   offset 0    -- // entry_9    cacheline[  0][ 9] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 161  cacheline 10   offset 1    -- // entry_10   cacheline[  0][10] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 162  cacheline 10   offset 2    -- // entry_11   cacheline[  0][11] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 163  cacheline 10   offset 3    -- // entry_12   cacheline[  0][12] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FILTER_COND  ID 19   mapping 3    cycles 9    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 164  cacheline 10   offset 4    -- // entry_0    cacheline[  0][ 0] < 9b>: filter_operation[0:8]=FILTER_NOP
0x00000000 // entry 165  cacheline 10   offset 5    -- // entry_1    cacheline[  0][ 1] < 4b>: filter_mask[0:3]=0x0
0x00000000 // entry 166  cacheline 10   offset 6    -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 167  cacheline 10   offset 7    -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 168  cacheline 10   offset 8    -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 169  cacheline 10   offset 9    -- // entry_5    cacheline[  0][ 5] < 7b>: break_flag[0:0]=0 || break_pass[1:1]=0 || filter_post[2:2]=0 || filter_pass[3:3]=0 || continue_flag[4:4]=0 || ternary_flag[5:5]=0 || conditional_flag[6:6]=0
0x00000000 // entry 170  cacheline 10   offset 10   -- // entry_6    cacheline[  0][ 6] <32b>: if_id_cu[0:7]=0x00 || if_id_bundle[8:15]=0x00 || if_id_lane[16:23]=0x00 || if_id_buffer[24:31]=0x00
0x00000000 // entry 171  cacheline 10   offset 11   -- // entry_7    cacheline[  0][ 7] <32b>: else_id_cu[0:7]=0x00 || else_id_bundle[8:15]=0x00 || else_id_lane[16:23]=0x00 || else_id_buffer[24:31]=0x00
0x00000000 // entry 172  cacheline 10   offset 12   -- // entry_8    cacheline[  0][ 8] <32b>: if_id_module[0:7]=0x00 || if_id_engine[8:15]=0x00 || else_id_module[16:23]=0x00 || else_id_engine[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 20   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 173  cacheline 10   offset 13   -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Template.Lite  <-- 
// Number of entries 174
