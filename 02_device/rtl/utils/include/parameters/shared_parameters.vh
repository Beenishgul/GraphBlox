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
parameter NUM_LANES_MAX   = 5,
parameter NUM_CAST_MAX    = 1,
parameter NUM_ENGINES_MAX = 3,

parameter NUM_CUS     = 1,
parameter NUM_BUNDLES = 4,
parameter NUM_LANES   = 5,
parameter NUM_ENGINES = 3,

parameter NUM_CUS_INDEX     = 1,
parameter NUM_BUNDLES_INDEX = 4,
parameter NUM_LANES_INDEX   = 5,
parameter NUM_ENGINES_INDEX = 3,

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS DEFAULTS
// --------------------------------------------------------------------------------------
parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{3,5,4,2},
parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = '{1, 3, 1, 0, 0},
parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = '{'{1, 3, 1, 0, 0}
, '{3, 1, 1, 2, 1}
, '{1, 1, 2, 1, 0}
, '{2, 1, 0, 0, 0}
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
parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = '{0, 0, 0, 0, 0}
,
parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = '{0, 0, 0, 0, 0}
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
, '{3, 5, 5}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_LANES_MAX][NUM_ENGINES_MAX]                   ='{'{10, 0, 0}
, '{9, 6, 6}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_LANES_MAX][NUM_ENGINES_MAX]                     ='{'{0, 10, 10}
, '{10, 19, 25}
, '{31, 32, 32}
, '{32, 32, 32}
, '{32, 32, 32}
}
,
parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = '{'{0, 0, 0}
, '{1, 2, 3}
, '{4, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = '{0, 0, 0, 0, 0}
,
parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 0, 0, 0, 0}
,
parameter int LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY                                                = 0,
parameter int LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY                                               = 0,
parameter int LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 0, 0, 0, 0}
,
parameter int LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                      = '{0, 0, 0, 0, 0}
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
, '{'{0}
, '{0}
, '{0}
}
}
,
parameter BUNDLES_COUNT_ARRAY                                                                                  = 4,
parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{2, 0, 0}
, '{3, 5, 5}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 4, 3}
, '{1, 0, 0}
, '{1, 0, 0}
, '{1, 3, 0}
, '{6, 0, 0}
}
, '{'{1, 0, 0}
, '{1, 0, 0}
, '{2, 3, 0}
, '{6, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 3, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{10, 0, 0}
, '{9, 6, 6}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{13, 2, 9}
, '{13, 0, 0}
, '{13, 0, 0}
, '{13, 9, 0}
, '{1, 0, 0}
}
, '{'{13, 0, 0}
, '{13, 0, 0}
, '{10, 9, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{13, 9, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 10, 10}
, '{10, 19, 25}
, '{31, 32, 32}
, '{32, 32, 32}
, '{32, 32, 32}
}
, '{'{32, 45, 47}
, '{56, 69, 69}
, '{69, 82, 82}
, '{82, 95, 104}
, '{104, 105, 105}
}
, '{'{105, 118, 118}
, '{118, 131, 131}
, '{131, 141, 150}
, '{150, 151, 151}
, '{151, 151, 151}
}
, '{'{151, 164, 173}
, '{173, 174, 174}
, '{174, 174, 174}
, '{174, 174, 174}
, '{174, 174, 174}
}
}
,
parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{3,5,4,2},
parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 3, 1, 0, 0}
, '{3, 1, 1, 2, 1}
, '{1, 1, 2, 1, 0}
, '{2, 1, 0, 0, 0}
}
,
parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0, 0}
, '{1, 2, 3}
, '{4, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{5, 6, 7}
, '{8, 0, 0}
, '{9, 0, 0}
, '{10, 11, 0}
, '{12, 0, 0}
}
, '{'{13, 0, 0}
, '{14, 0, 0}
, '{15, 16, 0}
, '{17, 0, 0}
, '{0, 0, 0}
}
, '{'{18, 19, 0}
, '{20, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 2, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0, 0}
, '{2, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0, 0}
, '{0, 1, 1, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0, 0}
,
parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 2, 0, 0}
,
parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0, 0}
, '{2, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0, 0}
, '{0, 1, 1, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
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
parameter CU_BUNDLES_COUNT_ARRAY                           = 4,
parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{3,5,4,2},
parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{1, 3, 1, 0, 0}
, '{3, 1, 1, 2, 1}
, '{1, 1, 2, 1, 0}
, '{2, 1, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{2, 0, 0}
, '{3, 5, 5}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 4, 3}
, '{1, 0, 0}
, '{1, 0, 0}
, '{1, 3, 0}
, '{6, 0, 0}
}
, '{'{1, 0, 0}
, '{1, 0, 0}
, '{2, 3, 0}
, '{6, 0, 0}
, '{0, 0, 0}
}
, '{'{1, 3, 0}
, '{6, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{10, 0, 0}
, '{9, 6, 6}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{13, 2, 9}
, '{13, 0, 0}
, '{13, 0, 0}
, '{13, 9, 0}
, '{1, 0, 0}
}
, '{'{13, 0, 0}
, '{13, 0, 0}
, '{10, 9, 0}
, '{1, 0, 0}
, '{0, 0, 0}
}
, '{'{13, 9, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 10, 10}
, '{10, 19, 25}
, '{31, 32, 32}
, '{32, 32, 32}
, '{32, 32, 32}
}
, '{'{32, 45, 47}
, '{56, 69, 69}
, '{69, 82, 82}
, '{82, 95, 104}
, '{104, 105, 105}
}
, '{'{105, 118, 118}
, '{118, 131, 131}
, '{131, 141, 150}
, '{150, 151, 151}
, '{151, 151, 151}
}
, '{'{151, 164, 173}
, '{173, 174, 174}
, '{174, 174, 174}
, '{174, 174, 174}
, '{174, 174, 174}
}
}
,
parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 0, 0}
, '{1, 2, 3}
, '{4, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{5, 6, 7}
, '{8, 0, 0}
, '{9, 0, 0}
, '{10, 11, 0}
, '{12, 0, 0}
}
, '{'{13, 0, 0}
, '{14, 0, 0}
, '{15, 16, 0}
, '{17, 0, 0}
, '{0, 0, 0}
}
, '{'{18, 19, 0}
, '{20, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 2, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{0, 0, 0, 0, 0}
, '{2, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{1, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0, 0}
, '{0, 1, 1, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{0, 1, 0, 0}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{0, 2, 0, 0}
,
parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 0, 0, 0, 0}
, '{2, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 0, 0, 0, 0}
, '{0, 1, 1, 0, 0}
, '{0, 0, 0, 0, 0}
, '{0, 0, 0, 0, 0}
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
, '{'{0}
, '{0}
, '{0}
}
}
}

// total_luts=56184

