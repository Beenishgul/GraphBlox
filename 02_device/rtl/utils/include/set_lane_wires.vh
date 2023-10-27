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

for (j=0; j< NUM_LANES; j++) begin
    if(LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j] != 0 && j != i && LANE_MERGE_WIDTH_LOCAL != 0) begin
        initial $display("MSG: Iteration number: %0d - %0d - %0d", i, j, LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]);
    end
end

