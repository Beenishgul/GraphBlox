// --------------------------------------------------------------------------------------
// FIFO SETTINGS
// --------------------------------------------------------------------------------------
parameter FIFO_WRITE_DEPTH = 32,
parameter PROG_THRESH      = 20,

// --------------------------------------------------------------------------------------
// CU CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter NUM_CUS_MAX     = 1,
parameter NUM_BUNDLES_MAX = 4,
parameter NUM_LANES_MAX   = 4,
parameter NUM_CAST_MAX    = 1,
parameter NUM_ENGINES_MAX = 2,

parameter NUM_CUS     = 1,
parameter NUM_BUNDLES = 4,
parameter NUM_LANES   = 4,
parameter NUM_ENGINES = 2,

parameter NUM_CUS_INDEX     = 1,
parameter NUM_BUNDLES_INDEX = 4,
parameter NUM_LANES_INDEX   = 4,
parameter NUM_ENGINES_INDEX = 2,

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS DEFAULTS
// --------------------------------------------------------------------------------------
parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{3,4,2,2},
parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = '{1, 1, 1, 0},
parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = '{'{1, 1, 1, 0}
, '{2, 1, 1, 1}
, '{1, 1, 0, 0}
, '{1, 1, 0, 0}
}
,
parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                          = '{5, 0}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_ENGINES_MAX]                           ='{6, 0}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_ENGINES_MAX]                             ='{0, 6}
,
parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                       = '{0, 0}
,
parameter int ENGINES_CONFIG_MERGE_WIDTH_ARRAY[NUM_ENGINES_MAX]                              = '{0, 0}
,
parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = '{0, 0, 0, 0}
,
parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = '{0, 0}
,
parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = '{0, 0, 0, 0}
,
parameter int ENGINES_CONFIG_MERGE_CONNECT_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]              = '{'{0}
, '{0}
}
,
parameter int ENGINES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]       = '{'{0}
, '{0}
}
,
parameter int ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY                                           = 0,
parameter int ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY                                            = 0,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  96 ,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  192 ,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  32 ,
parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  0 ,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = 16,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = 48,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE= 16,
parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST= 0,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY    = 0,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE    = 16,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE   = 0,
parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST   = 0,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_ENGINES_MAX]  = '{0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_ENGINES_MAX]  = '{16, 0}
,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_ENGINES_MAX] = '{0, 0}
,
parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_ENGINES_MAX] = '{0, 0}
,
parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                    = '{'{5, 0}
, '{2, 0}
, '{6, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_LANES_MAX][NUM_ENGINES_MAX]                   ='{'{6, 0}
, '{10, 0}
, '{1, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_LANES_MAX][NUM_ENGINES_MAX]                     ='{'{0, 6}
, '{6, 16}
, '{16, 17}
, '{17, 17}
}
,
parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = '{'{0, 0}
, '{1, 0}
, '{2, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY                                                = 0,
parameter int LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY                                               = 0,
parameter int LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                      = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_MERGE_CONNECT_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX]        = '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
,
parameter int LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  96 ,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  192 ,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  32 ,
parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  0 ,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = 16,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = 48,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE= 16,
parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST= 0,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_LANES_MAX] = '{0, 16, 0, 0}
,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_LANES_MAX] = '{16, 16, 16, 0}
,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_LANES_MAX]= '{0, 16, 0, 0}
,
parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_LANES_MAX]= '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{0, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_LANES_MAX][NUM_ENGINES_MAX]    = '{'{16, 0}
, '{16, 0}
, '{16, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{0, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
,
parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_LANES_MAX][NUM_ENGINES_MAX]   = '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
,
parameter BUNDLES_COUNT_ARRAY                                                                                  = 4,
parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{5, 0}
, '{2, 0}
, '{6, 0}
, '{0, 0}
}
, '{'{1, 4}
, '{1, 0}
, '{1, 0}
, '{6, 0}
}
, '{'{2, 0}
, '{6, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{1, 0}
, '{6, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{6, 0}
, '{10, 0}
, '{1, 0}
, '{0, 0}
}
, '{'{13, 2}
, '{13, 0}
, '{13, 0}
, '{1, 0}
}
, '{'{10, 0}
, '{1, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{13, 0}
, '{1, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 6}
, '{6, 16}
, '{16, 17}
, '{17, 17}
}
, '{'{17, 30}
, '{32, 45}
, '{45, 58}
, '{58, 59}
}
, '{'{59, 69}
, '{69, 70}
, '{70, 70}
, '{70, 70}
}
, '{'{70, 83}
, '{83, 84}
, '{84, 84}
, '{84, 84}
}
}
,
parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{3,4,2,2},
parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 1, 1, 0}
, '{2, 1, 1, 1}
, '{1, 1, 0, 0}
, '{1, 1, 0, 0}
}
,
parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0}
, '{1, 0}
, '{2, 0}
, '{0, 0}
}
, '{'{3, 4}
, '{5, 0}
, '{6, 0}
, '{7, 0}
}
, '{'{8, 0}
, '{9, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{10, 0}
, '{11, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{1, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{0, 1, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0, 0}
,
parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 1, 0, 0}
,
parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0}
, '{0, 1, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
}
,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  96 ,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  192 ,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  32 ,
parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  0 ,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX] = '{16, 48, 16, 16}
,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX] = '{48, 80, 32, 32}
,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= '{16, 0, 16, 0}
,
parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX]= '{0, 0, 0, 0}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{0, 16, 0, 0}
, '{16, 16, 16, 0}
, '{16, 0, 0, 0}
, '{16, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{16, 16, 16, 0}
, '{32, 16, 16, 16}
, '{16, 16, 0, 0}
, '{16, 16, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 16, 0, 0}
, '{0, 0, 0, 0}
, '{16, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{16, 0}
, '{16, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{16, 0}
, '{16, 0}
, '{16, 0}
, '{0, 0}
}
, '{'{16, 16}
, '{16, 0}
, '{16, 0}
, '{16, 0}
}
, '{'{16, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter CU_BUNDLES_COUNT_ARRAY                           = 4,
parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{3,4,2,2},
parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 1, 1, 0}
, '{2, 1, 1, 1}
, '{1, 1, 0, 0}
, '{1, 1, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{5, 0}
, '{2, 0}
, '{6, 0}
, '{0, 0}
}
, '{'{1, 4}
, '{1, 0}
, '{1, 0}
, '{6, 0}
}
, '{'{2, 0}
, '{6, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{1, 0}
, '{6, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{6, 0}
, '{10, 0}
, '{1, 0}
, '{0, 0}
}
, '{'{13, 2}
, '{13, 0}
, '{13, 0}
, '{1, 0}
}
, '{'{10, 0}
, '{1, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{13, 0}
, '{1, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 6}
, '{6, 16}
, '{16, 17}
, '{17, 17}
}
, '{'{17, 30}
, '{32, 45}
, '{45, 58}
, '{58, 59}
}
, '{'{59, 69}
, '{69, 70}
, '{70, 70}
, '{70, 70}
}
, '{'{70, 83}
, '{83, 84}
, '{84, 84}
, '{84, 84}
}
}
,
parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0}
, '{1, 0}
, '{2, 0}
, '{0, 0}
}
, '{'{3, 4}
, '{5, 0}
, '{6, 0}
, '{7, 0}
}
, '{'{8, 0}
, '{9, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{10, 0}
, '{11, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{1, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{0, 1, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0, 0}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 1, 0, 0}
,
parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{1, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0}
, '{0, 1, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
, '{'{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
, '{'{0}
, '{0}
}
}
}
,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  96 ,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  192 ,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  32 ,
parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  0 ,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX] = '{16, 48, 16, 16}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX] = '{48, 80, 32, 32}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= '{16, 0, 16, 0}
,
parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX]= '{0, 0, 0, 0}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{0, 16, 0, 0}
, '{16, 16, 16, 0}
, '{16, 0, 0, 0}
, '{16, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{16, 16, 16, 0}
, '{32, 16, 16, 16}
, '{16, 16, 0, 0}
, '{16, 16, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 16, 0, 0}
, '{0, 0, 0, 0}
, '{16, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= '{'{0, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{16, 0}
, '{16, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{16, 0}
, '{16, 0}
, '{16, 0}
, '{0, 0}
}
, '{'{16, 16}
, '{16, 0}
, '{16, 0}
, '{16, 0}
}
, '{'{16, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0}
, '{16, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{16, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}

parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}

// total_luts=26029

