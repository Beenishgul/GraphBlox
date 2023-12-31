// --------------------------------------------------------------------------------------
// Name ENGINE_ALU_OPS      ID 0    mapping 5    cycles 6    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000001 // entry 0    cacheline 0    offset 0    -- // entry_0    cacheline[  0][ 0] < 6b>: alu_operation[0:5]=ALU_NOP
0x00000000 // entry 1    cacheline 0    offset 1    -- // entry_1    cacheline[  0][ 1] <20b>: alu_mask[0:3]=0x0 || id_engine[4:11]=0x00 || id_module[12:19]=0x00
0x00000000 // entry 2    cacheline 0    offset 2    -- // entry_2    cacheline[  0][ 2] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 3    cacheline 0    offset 3    -- // entry_3    cacheline[  0][ 3] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 4    cacheline 0    offset 4    -- // entry_4    cacheline[  0][ 4] <16b>: ops_mask[0:15]=0x0000
0x00000000 // entry 5    cacheline 0    offset 5    -- // entry_5    cacheline[  0][ 5] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 1    mapping 2    cycles 8    None-NONE ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 6    cacheline 0    offset 6    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 7    cacheline 0    offset 7    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 8    cacheline 0    offset 8    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 9    cacheline 0    offset 9    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 10   cacheline 0    offset 10   -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 11   cacheline 0    offset 11   -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 12   cacheline 0    offset 12   -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 13   cacheline 0    offset 13   -- // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 2    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 14   cacheline 0    offset 14   -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 3    mapping 1    cycles 11   buffer_3-edges_idx ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 15   cacheline 0    offset 15   -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 16   cacheline 1    offset 0    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 17   cacheline 1    offset 1    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 18   cacheline 1    offset 2    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 19   cacheline 1    offset 3    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 20   cacheline 1    offset 4    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 21   cacheline 1    offset 5    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 22   cacheline 1    offset 6    -- // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 23   cacheline 1    offset 7    -- // entry_8    cacheline[  0][ 8] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 24   cacheline 1    offset 8    -- // entry_9    cacheline[  0][ 9] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 25   cacheline 1    offset 9    -- // entry_10   cacheline[  0][10] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_MERGE_DATA   ID 4    mapping 4    cycles 2    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 26   cacheline 1    offset 10   -- // entry_0    cacheline[  0][ 0] < 4b>: merge_mask[0:3]=0x0
0x00000000 // entry 27   cacheline 1    offset 11   -- // entry_1    cacheline[  0][ 1] < 4b>: merge_type[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 5    mapping 1    cycles 11   buffer_2-out_degree ( 0 )-( graph->num_vertices )
// --------------------------------------------------------------------------------------
0x00000000 // entry 28   cacheline 1    offset 12   -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 29   cacheline 1    offset 13   -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 30   cacheline 1    offset 14   -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 31   cacheline 1    offset 15   -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 32   cacheline 2    offset 0    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 33   cacheline 2    offset 1    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 34   cacheline 2    offset 2    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 35   cacheline 2    offset 3    -- // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 36   cacheline 2    offset 4    -- // entry_8    cacheline[  0][ 8] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 37   cacheline 2    offset 5    -- // entry_9    cacheline[  0][ 9] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 38   cacheline 2    offset 6    -- // entry_10   cacheline[  0][10] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 6    mapping 1    cycles 11   buffer_8-auxiliary_2 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 39   cacheline 2    offset 7    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 40   cacheline 2    offset 8    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 41   cacheline 2    offset 9    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 42   cacheline 2    offset 10   -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 43   cacheline 2    offset 11   -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 44   cacheline 2    offset 12   -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 45   cacheline 2    offset 13   -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 46   cacheline 2    offset 14   -- // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 47   cacheline 2    offset 15   -- // entry_8    cacheline[  0][ 8] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 48   cacheline 3    offset 0    -- // entry_9    cacheline[  0][ 9] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 49   cacheline 3    offset 1    -- // entry_10   cacheline[  0][10] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 7    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 50   cacheline 3    offset 2    -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_CSR_INDEX    ID 8    mapping 2    cycles 8    buffer_5-edges_array_dest ( 0 )-( graph->num_edges )
// --------------------------------------------------------------------------------------
0x00000000 // entry 51   cacheline 3    offset 3    -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 52   cacheline 3    offset 4    -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 53   cacheline 3    offset 5    -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 54   cacheline 3    offset 6    -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 55   cacheline 3    offset 7    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 56   cacheline 3    offset 8    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 57   cacheline 3    offset 9    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 58   cacheline 3    offset 10   -- // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 9    mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 59   cacheline 3    offset 11   -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_READ_WRITE   ID 10   mapping 1    cycles 11   buffer_7-auxiliary_1 ( graph->num_vertices )-( graph->num_vertices * 2 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 60   cacheline 3    offset 12   -- // entry_0    cacheline[  0][ 0] < 5b>: increment[0:0]=0 || decrement[1:1]=0 || mode_sequence[2:2]=0 || mode_buffer[3:3]=0 || mode_break[4:4]=0
0x00000000 // entry 61   cacheline 3    offset 13   -- // entry_1    cacheline[  0][ 1] <32b>: index_start[0:31]=0x00000000
0x00000000 // entry 62   cacheline 3    offset 14   -- // entry_2    cacheline[  0][ 2] <32b>: index_end[0:31]=0x00000000
0x00000000 // entry 63   cacheline 3    offset 15   -- // entry_3    cacheline[  0][ 3] <32b>: stride[0:31]=0x00000000
0x00000000 // entry 64   cacheline 4    offset 0    -- // entry_4    cacheline[  0][ 4] <32b>: shift.amount[0:30]=0 || shift.direction[31:31]=0
0x00000081 // entry 65   cacheline 4    offset 1    -- // entry_5    cacheline[  0][ 5] <29b>: cmd[0:6]=CMD_INVALID || buffer[7:12]=STRUCT_INVALID || id_module[13:20]=0x00 || id_engine[21:28]=0x00
0x00000000 // entry 66   cacheline 4    offset 2    -- // entry_6    cacheline[  0][ 6] <32b>: id_cu[0:7]=0x00 || id_bundle[8:15]=0x00 || id_lane[16:23]=0x00 || id_buffer[24:31]=0x00
0x00000000 // entry 67   cacheline 4    offset 3    -- // entry_7    cacheline[  0][ 7] <32b>: array_size[0:31]=0x00000000
0x00000000 // entry 68   cacheline 4    offset 4    -- // entry_8    cacheline[  0][ 8] < 4b>: const_mask[0:3]=0x0
0x00000000 // entry 69   cacheline 4    offset 5    -- // entry_9    cacheline[  0][ 9] <32b>: const_value[0:31]=0x00000000
0x00000000 // entry 70   cacheline 4    offset 6    -- // entry_10   cacheline[  0][10] <16b>: ops_mask[0:15]=0x00
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Name ENGINE_FORWARD_DATA ID 11   mapping 6    cycles 1    None-None ( 0 )-( 0 )
// --------------------------------------------------------------------------------------
0x00000000 // entry 71   cacheline 4    offset 7    -- // entry_0    cacheline[  0][ 0] < 4b>: hops[0:3]=0x0
// --------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// -->  Template.Single.PR  <-- 
// Number of entries 72
