// --------------------------------------------------------------------------------------
// FIFO SETTINGS
// --------------------------------------------------------------------------------------
parameter FIFO_WRITE_DEPTH = 32,
parameter PROG_THRESH      = 20,

// --------------------------------------------------------------------------------------
// CU CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter NUM_CHANNELS    = 2,
parameter NUM_CUS_MAX     = 1,
parameter NUM_BUNDLES_MAX = 4,
parameter NUM_LANES_MAX   = 4,
parameter NUM_CAST_MAX    = 1,
parameter NUM_ENGINES_MAX = 3,

parameter NUM_CUS     = 1,
parameter NUM_BUNDLES = 4,
parameter NUM_LANES   = 4,
parameter NUM_BACKTRACK_LANES   = 4,
parameter NUM_ENGINES = 3,

parameter NUM_CUS_INDEX     = 1,
parameter NUM_BUNDLES_INDEX = 4,
parameter NUM_LANES_INDEX   = 4,
parameter NUM_ENGINES_INDEX = 3,

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS DEFAULTS
// --------------------------------------------------------------------------------------
parameter CU_BUNDLES_COUNT_ARRAY                           = 4,
parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{1, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{6, 0, 0}
}
, '{'{1, 4, 3}
, '{1, 0, 0}
, '{1, 0, 0}
, '{6, 0, 0}
}
, '{'{2, 0, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 3, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 11, 11}
, '{11, 22, 22}
, '{22, 30, 30}
, '{30, 30, 30}
}
, '{'{30, 41, 43}
, '{52, 63, 63}
, '{63, 74, 74}
, '{74, 74, 74}
}
, '{'{74, 82, 82}
, '{82, 82, 82}
, '{82, 82, 82}
, '{82, 82, 82}
}
, '{'{82, 93, 102}
, '{102, 102, 102}
, '{102, 102, 102}
, '{102, 102, 102}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{11, 0, 0}
, '{11, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{11, 2, 9}
, '{11, 0, 0}
, '{11, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{11, 9, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX]= '{0, 1, 0, 1}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= '{1, 0, 1, 0}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX] = '{4, 4, 2, 2}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX] = '{3, 3, 1, 1}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX]= '{0, 8, 0, 8}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= '{8, 0, 8, 0}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX] = '{32, 48, 16, 24}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX] = '{24, 24, 8, 8}
,
parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 1}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
}
, '{'{1, 1, 1}
, '{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
}
, '{'{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 1, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 8}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 8, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
}
, '{'{8, 8, 8}
, '{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
}
, '{'{8, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 8, 0}
, '{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
, '{1, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 1, 0}
, '{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{1, 1, 1, 1}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
, '{2, 1, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{1, 1, 1, 0}
, '{1, 1, 1, 0}
, '{1, 0, 0, 0}
, '{1, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 0, 0}
, '{8, 0, 0, 0}
, '{0, 0, 0, 0}
, '{8, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 8, 0}
, '{0, 0, 0, 0}
, '{8, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{8, 8, 8, 8}
, '{24, 8, 8, 8}
, '{8, 8, 0, 0}
, '{16, 8, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{8, 8, 8, 0}
, '{8, 8, 8, 0}
, '{8, 0, 0, 0}
, '{8, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0, 0}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 2, 0, 0}
,
parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 2, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
}
, '{'{4, 5, 6}
, '{7, 0, 0}
, '{8, 0, 0}
, '{9, 0, 0}
}
, '{'{10, 0, 0}
, '{11, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{12, 13, 0}
, '{14, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{4,4,2,2},
parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 1, 1, 1}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
, '{2, 1, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  2 ,
parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  2 ,
parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE =  4 ,
parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY =  4 ,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  16 ,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  16 ,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  120 ,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  64 ,
parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  2 ,
parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  2 ,
parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE =  4 ,
parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY =  4 ,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  16 ,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  16 ,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  120 ,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  64 ,
parameter BUNDLES_COUNT_ARRAY                                                                                  = 4,
parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{1, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{6, 0, 0}
}
, '{'{1, 4, 3}
, '{1, 0, 0}
, '{1, 0, 0}
, '{6, 0, 0}
}
, '{'{2, 0, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 3, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 11, 11}
, '{11, 22, 22}
, '{22, 30, 30}
, '{30, 30, 30}
}
, '{'{30, 41, 43}
, '{52, 63, 63}
, '{63, 74, 74}
, '{74, 74, 74}
}
, '{'{74, 82, 82}
, '{82, 82, 82}
, '{82, 82, 82}
, '{82, 82, 82}
}
, '{'{82, 93, 102}
, '{102, 102, 102}
, '{102, 102, 102}
, '{102, 102, 102}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{11, 0, 0}
, '{11, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{11, 2, 9}
, '{11, 0, 0}
, '{11, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{11, 9, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX]= '{0, 1, 0, 1}
,
parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= '{1, 0, 1, 0}
,
parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX] = '{4, 4, 2, 2}
,
parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX] = '{3, 3, 1, 1}
,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX]= '{0, 8, 0, 8}
,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= '{8, 0, 8, 0}
,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX] = '{32, 48, 16, 24}
,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX] = '{24, 24, 8, 8}
,
parameter int BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 1}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
}
, '{'{1, 1, 1}
, '{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
}
, '{'{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 1, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 8}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 8, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
}
, '{'{8, 8, 8}
, '{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
}
, '{'{8, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 8, 0}
, '{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{8, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
, '{1, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 1, 0}
, '{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{1, 1, 1, 1}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
, '{2, 1, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{1, 1, 1, 0}
, '{1, 1, 1, 0}
, '{1, 0, 0, 0}
, '{1, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 0, 0}
, '{8, 0, 0, 0}
, '{0, 0, 0, 0}
, '{8, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 8, 0}
, '{0, 0, 0, 0}
, '{8, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{8, 8, 8, 8}
, '{24, 8, 8, 8}
, '{8, 8, 0, 0}
, '{16, 8, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{8, 8, 8, 0}
, '{8, 8, 8, 0}
, '{8, 0, 0, 0}
, '{8, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0, 0}
,
parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 2, 0, 0}
,
parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 2, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
}
, '{'{4, 5, 6}
, '{7, 0, 0}
, '{8, 0, 0}
, '{9, 0, 0}
}
, '{'{10, 0, 0}
, '{11, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{12, 13, 0}
, '{14, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{4,4,2,2},
parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 1, 1, 1}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
, '{2, 1, 0, 0}
}
,
parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                    = '{'{1, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{6, 0, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_LANES_MAX][NUM_ENGINES_MAX]                     ='{'{0, 11, 11}
, '{11, 22, 22}
, '{22, 30, 30}
, '{30, 30, 30}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_LANES_MAX][NUM_ENGINES_MAX]                   ='{'{11, 0, 0}
, '{11, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST= 0,
parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE= 1,
parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE = 4,
parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY = 3,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST= 0,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE= 8,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = 32,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = 24,
parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{0, 0, 0}
, '{0, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_LANES_MAX][NUM_ENGINES_MAX]    = '{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{1, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{0, 0, 0}
, '{0, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_LANES_MAX][NUM_ENGINES_MAX]    = '{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{8, 0, 0}
, '{8, 0, 0}
, '{8, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[NUM_LANES_MAX]= '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[NUM_LANES_MAX]= '{0, 0, 1, 0}
,
parameter int LANES_CONFIG_LANE_ARBITER_NUM_ENGINE[NUM_LANES_MAX] = '{1, 1, 1, 1}
,
parameter int LANES_CONFIG_LANE_ARBITER_NUM_MEMORY[NUM_LANES_MAX] = '{1, 1, 1, 0}
,
parameter int LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_LANES_MAX]= '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_LANES_MAX]= '{0, 0, 8, 0}
,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_LANES_MAX] = '{8, 8, 8, 8}
,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_LANES_MAX] = '{8, 8, 8, 0}
,
parameter int LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY                                                = 0,
parameter int LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY                                               = 0,
parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                      = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_MERGE_CONNECT_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX]        = '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
,
parameter int LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
, '{'{0}
, '{0}
, '{0}
}
}
,
parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{4,4,2,2},
parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
}
,
parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = '{'{1, 1, 1, 1}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
, '{2, 1, 0, 0}
}
,
parameter int LANES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  2 ,
parameter int LANES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  2 ,
parameter int LANES_CONFIG_CU_ARBITER_NUM_ENGINE =  4 ,
parameter int LANES_CONFIG_CU_ARBITER_NUM_MEMORY =  4 ,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  16 ,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  16 ,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  120 ,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  64 ,
parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                          = '{1, 0, 0}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_ENGINES_MAX]                             ='{0, 11, 11}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_ENGINES_MAX]                           ='{11, 0, 0}
,
parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST= 0,
parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE= 1,
parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE = 4,
parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY = 3,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST= 0,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE= 8,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = 32,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = 24,
parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_ENGINES_MAX] = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_ENGINES_MAX] = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_ENGINES_MAX]  = '{1, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_ENGINES_MAX]  = '{1, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_ENGINES_MAX] = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_ENGINES_MAX] = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_ENGINES_MAX]  = '{8, 0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_ENGINES_MAX]  = '{8, 0, 0}
,
parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST   = 0,
parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE   = 0,
parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_ENGINE    = 1,
parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY    = 1,
parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = '{0, 0, 0, 0}
,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST   = 0,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE   = 0,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE    = 8,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY    = 8,
parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = '{0, 0, 0, 0}
,
parameter int ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY                                            = 0,
parameter int ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY                                           = 0,
parameter int ENGINES_CONFIG_MERGE_CONNECT_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]              = '{'{0}
, '{0}
, '{0}
}
,
parameter int ENGINES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]       = '{'{0}
, '{0}
, '{0}
}
,
parameter int ENGINES_CONFIG_MERGE_WIDTH_ARRAY[NUM_ENGINES_MAX]                              = '{0, 0, 0}
,
parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = '{1, 1, 1, 1},
parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                       = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  2 ,
parameter int ENGINES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  2 ,
parameter int ENGINES_CONFIG_CU_ARBITER_NUM_ENGINE =  4 ,
parameter int ENGINES_CONFIG_CU_ARBITER_NUM_MEMORY =  4 ,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  16 ,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  16 ,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  120 ,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  64
// total_luts=36408

