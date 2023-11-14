// --------------------------------------------------------------------------------------
// FIFO SETTINGS
// --------------------------------------------------------------------------------------
parameter FIFO_WRITE_DEPTH = 32,
parameter PROG_THRESH      = 16,

// --------------------------------------------------------------------------------------
// CU CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter NUM_CUS_MAX     = 1,
parameter NUM_BUNDLES_MAX = 3,
parameter NUM_LANES_MAX   = 4,
parameter NUM_CAST_MAX    = 1,
parameter NUM_ENGINES_MAX = 3,

parameter NUM_CUS     = 1,
parameter NUM_BUNDLES = 3,
parameter NUM_LANES   = 4,
parameter NUM_ENGINES = 3,

parameter NUM_CUS_INDEX     = 1,
parameter NUM_BUNDLES_INDEX = 3,
parameter NUM_LANES_INDEX   = 4,
parameter NUM_ENGINES_INDEX = 3,

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS DEFAULTS
// --------------------------------------------------------------------------------------
parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{2,4,2},
parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = '{1, 1, 0, 0},
parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = '{'{1, 1, 0, 0}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
}
,
parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                          = '{2, 0, 0}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_ENGINES_MAX]                           ='{10, 0, 0}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_ENGINES_MAX]                             ='{0, 10, 10}
,
parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                       = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_MERGE_WIDTH_ARRAY[NUM_ENGINES_MAX]                              = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = '{0, 0, 0, 0}
,
parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = '{0, 0, 0, 0}
,
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
parameter int ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY                                           = 0,
parameter int ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY                                            = 0,
parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                    = '{'{2, 0, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_LANES_MAX][NUM_ENGINES_MAX]                   ='{'{10, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_LANES_MAX][NUM_ENGINES_MAX]                     ='{'{0, 10, 10}
, '{10, 11, 11}
, '{11, 11, 11}
, '{11, 11, 11}
}
,
parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = '{'{0, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = '{0, 0, 0, 0}
,
parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
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
parameter BUNDLES_COUNT_ARRAY                                                                                  = 3,
parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{2, 0, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
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
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{10, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{13, 2, 9}
, '{13, 0, 0}
, '{13, 0, 0}
, '{1, 0, 0}
}
, '{'{10, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 10, 10}
, '{10, 11, 11}
, '{11, 11, 11}
, '{11, 11, 11}
}
, '{'{11, 24, 26}
, '{35, 48, 48}
, '{48, 61, 61}
, '{61, 62, 62}
}
, '{'{62, 72, 72}
, '{72, 73, 73}
, '{73, 73, 73}
, '{73, 73, 73}
}
}
,
parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{2,4,2},
parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 1, 0, 0}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
}
,
parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{2, 3, 4}
, '{5, 0, 0}
, '{6, 0, 0}
, '{7, 0, 0}
}
, '{'{8, 0, 0}
, '{9, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
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
}
,
parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
}
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
}
,
parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0}
,
parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 2, 0}
,
parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
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
}
,
// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter CU_BUNDLES_COUNT_ARRAY                           = 3,
parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{2,4,2},
parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 1, 0, 0}
, '{3, 1, 1, 1}
, '{1, 1, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{2, 0, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
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
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{10, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{13, 2, 9}
, '{13, 0, 0}
, '{13, 0, 0}
, '{1, 0, 0}
}
, '{'{10, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 10, 10}
, '{10, 11, 11}
, '{11, 11, 11}
, '{11, 11, 11}
}
, '{'{11, 24, 26}
, '{35, 48, 48}
, '{48, 61, 61}
, '{61, 62, 62}
}
, '{'{62, 72, 72}
, '{72, 73, 73}
, '{73, 73, 73}
, '{73, 73, 73}
}
}
,
parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{2, 3, 4}
, '{5, 0, 0}
, '{6, 0, 0}
, '{7, 0, 0}
}
, '{'{8, 0, 0}
, '{9, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
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
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
}
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
}
,
parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 2, 0}
,
parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0}
, '{2, 0, 0, 0}
, '{0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0}
, '{0, 1, 1, 0}
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
}

