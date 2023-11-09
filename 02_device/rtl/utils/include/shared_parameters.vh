// --------------------------------------------------------------------------------------
// FIFO SETTINGS
// --------------------------------------------------------------------------------------
parameter FIFO_WRITE_DEPTH = 32,
parameter PROG_THRESH      = 16,

// --------------------------------------------------------------------------------------
// CU CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter NUM_CUS_MAX     = 1,
parameter NUM_BUNDLES_MAX = 4,
parameter NUM_LANES_MAX   = 6,
parameter NUM_CAST_MAX    = 3,
parameter NUM_ENGINES_MAX = 3,

parameter NUM_CUS     = 1,
parameter NUM_BUNDLES = 4,
parameter NUM_LANES   = 6,
parameter NUM_ENGINES = 3,

parameter NUM_CUS_INDEX     = 1,
parameter NUM_BUNDLES_INDEX = 4,
parameter NUM_LANES_INDEX   = 6,
parameter NUM_ENGINES_INDEX = 3,

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS DEFAULTS
// --------------------------------------------------------------------------------------
parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{6,6,6,6},
parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = '{3, 3, 3, 2, 2, 2},
parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = '{'{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
}
,
parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                          = '{1, 4, 3}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_ENGINES_MAX]                           ='{13, 2, 8}
,
parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_ENGINES_MAX]                             ='{0, 13, 15}
,
parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                       = '{0, 1, 2}
,
parameter int ENGINES_CONFIG_MERGE_WIDTH_ARRAY[NUM_ENGINES_MAX]                              = '{0, 3, 0}
,
parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = '{3, 2, 1, 0, 0, 0}
,
parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = '{0, 0, 0}
,
parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = '{0, 1, 2, 3, 0, 0}
,
parameter int ENGINES_CONFIG_MERGE_CONNECT_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]              = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int ENGINES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]       = '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY                                           = 3,
parameter int ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY                                            = 0,
parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                    = '{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_LANES_MAX][NUM_ENGINES_MAX]                   ='{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
,
parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_LANES_MAX][NUM_ENGINES_MAX]                     ='{'{0, 13, 15}
, '{23, 36, 38}
, '{46, 59, 61}
, '{69, 79, 87}
, '{87, 93, 101}
, '{101, 102, 110}
}
,
parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = '{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 8}
, '{9, 10, 0}
, '{11, 12, 0}
, '{13, 14, 0}
}
,
parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = '{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = '{3, 2, 1, 0, 0, 0}
,
parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
,
parameter int LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{0, 1, 2, 3, 0, 0}
,
parameter int LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY                                                = 3,
parameter int LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY                                               = 3,
parameter int LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                     = '{3, 2, 1, 0, 0, 0}
,
parameter int LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                      = '{0, 1, 2, 3, 0, 0}
,
parameter int LANES_CONFIG_MERGE_CONNECT_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX]        = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter BUNDLES_COUNT_ARRAY                                                                                  = 4,
parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
, '{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
, '{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
, '{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
, '{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
, '{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
, '{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
}
,
parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 13, 15}
, '{23, 36, 38}
, '{46, 59, 61}
, '{69, 79, 87}
, '{87, 93, 101}
, '{101, 102, 110}
}
, '{'{110, 123, 125}
, '{133, 146, 148}
, '{156, 169, 171}
, '{179, 189, 197}
, '{197, 203, 211}
, '{211, 212, 220}
}
, '{'{220, 233, 235}
, '{243, 256, 258}
, '{266, 279, 281}
, '{289, 299, 307}
, '{307, 313, 321}
, '{321, 322, 330}
}
, '{'{330, 343, 345}
, '{353, 366, 368}
, '{376, 389, 391}
, '{399, 409, 417}
, '{417, 423, 431}
, '{431, 432, 440}
}
}
,
parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{6,6,6,6},
parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
}
,
parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 8}
, '{9, 10, 0}
, '{11, 12, 0}
, '{13, 14, 0}
}
, '{'{15, 16, 17}
, '{18, 19, 20}
, '{21, 22, 23}
, '{24, 25, 0}
, '{26, 27, 0}
, '{28, 29, 0}
}
, '{'{30, 31, 32}
, '{33, 34, 35}
, '{36, 37, 38}
, '{39, 40, 0}
, '{41, 42, 0}
, '{43, 44, 0}
}
, '{'{45, 46, 47}
, '{48, 49, 50}
, '{51, 52, 53}
, '{54, 55, 0}
, '{56, 57, 0}
, '{58, 59, 0}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
}
,
parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{3, 3, 3, 3}
,
parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{3, 3, 3, 3}
,
parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
}
,
parameter int BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
}
,
// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter CU_BUNDLES_COUNT_ARRAY                           = 4,
parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{6,6,6,6},
parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = '{'{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = '{'{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
, '{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
, '{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
, '{'{1, 4, 3}
, '{1, 4, 3}
, '{1, 4, 3}
, '{2, 3, 0}
, '{5, 3, 0}
, '{6, 3, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            ='{'{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
, '{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
, '{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
, '{'{13, 2, 8}
, '{13, 2, 8}
, '{13, 2, 8}
, '{10, 8, 0}
, '{6, 8, 0}
, '{1, 8, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              ='{'{'{0, 13, 15}
, '{23, 36, 38}
, '{46, 59, 61}
, '{69, 79, 87}
, '{87, 93, 101}
, '{101, 102, 110}
}
, '{'{110, 123, 125}
, '{133, 146, 148}
, '{156, 169, 171}
, '{179, 189, 197}
, '{197, 203, 211}
, '{211, 212, 220}
}
, '{'{220, 233, 235}
, '{243, 256, 258}
, '{266, 279, 281}
, '{289, 299, 307}
, '{307, 313, 321}
, '{321, 322, 330}
}
, '{'{330, 343, 345}
, '{353, 366, 368}
, '{376, 389, 391}
, '{399, 409, 417}
, '{417, 423, 431}
, '{431, 432, 440}
}
}
,
parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = '{'{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 8}
, '{9, 10, 0}
, '{11, 12, 0}
, '{13, 14, 0}
}
, '{'{15, 16, 17}
, '{18, 19, 20}
, '{21, 22, 23}
, '{24, 25, 0}
, '{26, 27, 0}
, '{28, 29, 0}
}
, '{'{30, 31, 32}
, '{33, 34, 35}
, '{36, 37, 38}
, '{39, 40, 0}
, '{41, 42, 0}
, '{43, 44, 0}
}
, '{'{45, 46, 47}
, '{48, 49, 50}
, '{51, 52, 53}
, '{54, 55, 0}
, '{56, 57, 0}
, '{58, 59, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = '{'{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 3, 0}
, '{0, 2, 0}
, '{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = '{'{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = '{'{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{1, 0, 0}
, '{2, 0, 0}
, '{3, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = '{3, 3, 3, 3}
,
parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = '{3, 3, 3, 3}
,
parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = '{'{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
, '{3, 2, 1, 0, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = '{'{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
, '{0, 1, 2, 3, 0, 0}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = '{'{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
, '{'{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 1, 2}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
, '{'{0, 0, 0}
, '{0, 0, 0}
, '{0, 0, 0}
}
}
}

