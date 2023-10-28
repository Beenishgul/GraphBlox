localparam int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY_LOCAL [NUM_LANES_MAX] = LANES_CONFIG_LANE_CAST_WIDTH_ARRAY ;
localparam int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY_LOCAL[NUM_LANES_MAX] = LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY;
localparam int ENGINES_COUNT_ARRAY_LOCAL                  [NUM_LANES_MAX] = ENGINES_COUNT_ARRAY                ;
localparam int ID_BUNDLE_LOCAL                                            = ID_BUNDLE                          ;
localparam int ID_CU_LOCAL                                                = ID_CU                              ;
localparam int NUM_BUNDLES_LOCAL                                          = NUM_BUNDLES                        ;
localparam int NUM_LANES_LOCAL                                            = NUM_LANES                          ;

localparam int ID_LANE_LOCAL                                                           = i                                     ;
localparam int LANE_CAST_WIDTH_LOCAL                                                   = LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[i] ;
localparam int LANE_MERGE_WIDTH_LOCAL                                                  = LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[i];
localparam int ENGINES_CONFIG_ARRAY_LOCAL              [NUM_ENGINES_MAX]               = LANES_CONFIG_ARRAY[i]                 ;
localparam int ENGINES_CONFIG_CAST_WIDTH_ARRAY_LOCAL   [NUM_ENGINES_MAX]               = LANES_CONFIG_CAST_WIDTH_ARRAY[i]      ;
localparam int ENGINES_CONFIG_MERGE_CONNECT_ARRAY_LOCAL[NUM_ENGINES_MAX][NUM_CAST_MAX] = LANES_CONFIG_MERGE_CONNECT_ARRAY[i]   ;
localparam int ENGINES_CONFIG_MERGE_WIDTH_ARRAY_LOCAL  [NUM_ENGINES_MAX]               = LANES_CONFIG_MERGE_WIDTH_ARRAY[i]     ;
localparam int ENGINES_ENGINE_ID_ARRAY_LOCAL           [NUM_ENGINES_MAX]               = LANES_ENGINE_ID_ARRAY[i]              ;
localparam int NUM_ENGINES_LOCAL                                                       = ENGINES_COUNT_ARRAY[i]                ;

MemoryPacket           lanes_response_merge_engine_in               [(1+LANE_MERGE_WIDTH_LOCAL)-1:0];
FIFOStateSignalsInput  lanes_fifo_response_merge_lane_in_signals_in [(1+LANE_MERGE_WIDTH_LOCAL)-1:0];
FIFOStateSignalsOutput lanes_fifo_response_merge_lane_in_signals_out[(1+LANE_MERGE_WIDTH_LOCAL)-1:0];
MemoryPacket           lanes_request_cast_lane_out                  [ (1+LANE_CAST_WIDTH_LOCAL)-1:0];
FIFOStateSignalsInput  lanes_fifo_request_cast_lane_out_signals_in  [ (1+LANE_CAST_WIDTH_LOCAL)-1:0];
FIFOStateSignalsOutput lanes_fifo_request_cast_lane_out_signals_out [ (1+LANE_CAST_WIDTH_LOCAL)-1:0];

assign lanes_response_merge_engine_in[0]               = lanes_response_engine_in[i];
assign lanes_fifo_response_merge_lane_in_signals_in[0] = lanes_fifo_response_lane_in_signals_in[i];
assign lanes_fifo_response_lane_in_signals_out[i]      = lanes_fifo_response_merge_lane_in_signals_out[0];

assign lanes_request_lane_out[i]                      = lanes_request_cast_lane_out[0];
assign lanes_fifo_request_cast_lane_out_signals_in[0] = lanes_fifo_request_lane_out_signals_in[i];
assign lanes_fifo_request_lane_out_signals_out[i]     = lanes_fifo_request_cast_lane_out_signals_out [0];


// always_comb begin
//     if(LANE_MERGE_WIDTH_LOCAL != 0) begin
//         m = 0;
//         for (j = 0; j < NUM_LANES; j++) begin
//             if(LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j] != 0 && j != i) begin
//                 $display("MSG: - Lane number j: %0d - ENGINES_COUNT_ARRAY = %0d", j, ENGINES_COUNT_ARRAY[j]);
//                 for (k = 0; k < ENGINES_COUNT_ARRAY[j]; k++) begin
//                     $display("MSG: ++ Engine number k: %0d - LANES_CONFIG_CAST_WIDTH_ARRAY = %0d", k, LANES_CONFIG_CAST_WIDTH_ARRAY[j][k]);
//                     for (l = 0; l < LANES_CONFIG_CAST_WIDTH_ARRAY[j][k]; l++) begin
//                         $display("MSG: *** Cast number l: %0d - LANES_CONFIG_MERGE_CONNECT_ARRAY = %0d",l, LANES_CONFIG_MERGE_CONNECT_ARRAY[j][k][l]);
//                         if(LANES_CONFIG_MERGE_CONNECT_ARRAY[j][k][l] == i) begin
//                             m    = m + 1;
//                             c[j] = c[j] + 1;
//                             $display("MSG: >>> %0d -> %0d i:%0d j:%0d",j,i,m, c[j]);
//                             bundle_lanes.generate_lane_template[i].lanes_response_merge_engine_in[m]                                         = bundle_lanes.generate_lane_template[j].lanes_request_cast_lane_out[ c[j]];
//                             // lanes_fifo_response_merge_lane_in_signals_in[m]                           = generate_lane_template[j].lanes_fifo_request_cast_lane_out_signals_in[ c[j]] ;
//                             // generate_lane_template[j].lanes_fifo_request_cast_lane_out_signals_out[c[j]] = lanes_fifo_response_merge_lane_in_signals_out[m];
//                         end
//                     end
//                 end
//             end
//         end
//     end
// end
