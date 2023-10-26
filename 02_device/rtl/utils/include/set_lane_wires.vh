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