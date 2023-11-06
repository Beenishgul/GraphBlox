// --------------------------------------------------------------------------------------
// FIFO SETTINGS
// --------------------------------------------------------------------------------------
parameter FIFO_WRITE_DEPTH = 32,
parameter PROG_THRESH      = 16,

// --------------------------------------------------------------------------------------
// CU CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter NUM_CUS_MAX     = 1,
parameter NUM_BUNDLES_MAX = 2,
parameter NUM_LANES_MAX   = 5,
parameter NUM_CAST_MAX    = 2,
parameter NUM_ENGINES_MAX = 3,

parameter NUM_CUS     = 1,
parameter NUM_BUNDLES = 2,
parameter NUM_LANES   = 5,
parameter NUM_ENGINES = 3,

parameter NUM_CUS_INDEX     = 1,
parameter NUM_BUNDLES_INDEX = 2,
parameter NUM_LANES_INDEX   = 5,
parameter NUM_ENGINES_INDEX = 3,

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS DEFAULTS
// --------------------------------------------------------------------------------------
parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{5,5},
parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = '{3, 3, 2, 2, 2},
parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = '{'{3, 3, 2, 2, 2}
, '{3, 3, 2, 2, 2}
}
,
parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                          = '{2, 5, 4}
,
parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                       = '{0, 1, 2}
,
parameter int ENGINES_CONFIG_MERGE_WIDTH_ARRAY[NUM_ENGINES_MAX]                              = '{0, 2, 0}
,
parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = '{2, 1, 0, 0, 0}
,
parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = '{0, 1, 2, 0, 0}
,
parameter int ENGINES_CONFIG_MERGE_CONNECT_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]              = '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
,
parameter int ENGINES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]       = '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
,
parameter int ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY                                           = 2,
parameter int ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY                                            = 0,
parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                    = '{'{2, 5, 4}
, '{2, 5, 4}
, '{2, 4, 0}
, '{6, 4, 0}
, '{7, 4, 0}
}
,
parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = '{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 0}
, '{8, 9, 0}
, '{10, 11, 0}
}
,
parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = '{'{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = '{2, 1, 0, 0, 0}
,
parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 1, 2, 0, 0}
,
parameter int LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY                                                = 2,
parameter int LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY                                               = 2,
parameter int LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{2, 1, 0, 0, 0}
,
parameter int LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                      = '{0, 1, 2, 0, 0}
,
parameter int LANES_CONFIG_MERGE_CONNECT_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX]        = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter BUNDLES_COUNT_ARRAY                                                                                  = 2,
parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{2, 5, 4}
, '{2, 5, 4}
, '{2, 4, 0}
, '{6, 4, 0}
, '{7, 4, 0}
}
, '{'{2, 5, 4}
, '{2, 5, 4}
, '{2, 4, 0}
, '{6, 4, 0}
, '{7, 4, 0}
}
}
,
parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{5,5},
parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{3, 3, 2, 2, 2}
, '{3, 3, 2, 2, 2}
}
,
parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 0}
, '{8, 9, 0}
, '{10, 11, 0}
}
, '{'{12, 13, 14}
, '{15, 16, 17}
, '{18, 19, 0}
, '{20, 21, 0}
, '{22, 23, 0}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{2, 1, 0, 0, 0}
, '{2, 1, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 1, 2, 0, 0}
, '{0, 1, 2, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{2, 2}
,
parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{2, 2}
,
parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{2, 1, 0, 0, 0}
, '{2, 1, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 1, 2, 0, 0}
, '{0, 1, 2, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
, '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
, '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
}
,
// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter CU_BUNDLES_COUNT_ARRAY                           = 2,
parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{5,5},
parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{3, 3, 2, 2, 2}
, '{3, 3, 2, 2, 2}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{2, 5, 4}
, '{2, 5, 4}
, '{2, 4, 0}
, '{6, 4, 0}
, '{7, 4, 0}
}
, '{'{2, 5, 4}
, '{2, 5, 4}
, '{2, 4, 0}
, '{6, 4, 0}
, '{7, 4, 0}
}
}
,
parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 0}
, '{8, 9, 0}
, '{10, 11, 0}
}
, '{'{12, 13, 14}
, '{15, 16, 17}
, '{18, 19, 0}
, '{20, 21, 0}
, '{22, 23, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{2, 1, 0, 0, 0}
, '{2, 1, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 1, 2, 0, 0}
, '{0, 1, 2, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{2, 2}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{2, 2}
,
parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{2, 1, 0, 0, 0}
, '{2, 1, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 1, 2, 0, 0}
, '{0, 1, 2, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
, '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
, '{'{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 1}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 0}
, '{0, 0}
, '{0, 0}
}
}
}

