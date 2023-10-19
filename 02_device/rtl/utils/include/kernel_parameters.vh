parameter NUM_MEMORY_REQUESTOR = 2,
parameter ID_CU = 0,
// --------------------------------------------------------------------------------------
// FIFO SETTINGS
// --------------------------------------------------------------------------------------
parameter FIFO_WRITE_DEPTH = 32,
parameter PROG_THRESH = 16,

// --------------------------------------------------------------------------------------
// CU CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter NUM_CUS_MAX = 1,
parameter NUM_BUNDLES_MAX = 2,
parameter NUM_LANES_MAX = 6,
parameter NUM_ENGINES_MAX = 3,

parameter NUM_CUS = 1,
parameter NUM_BUNDLES = 2,
parameter NUM_LANES = 6,
parameter NUM_ENGINES = 3,

parameter NUM_CUS_INDEX = 1,
parameter NUM_BUNDLES_INDEX = 2,
parameter NUM_LANES_INDEX = 6,
parameter NUM_ENGINES_INDEX = 3,

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS DEFAULTS
// --------------------------------------------------------------------------------------
parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{6,6},
parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX] = '{3, 3, 3, 2, 2, 2},
parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
}
,
parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX] = '{1, 5, 4}
,
parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX] = '{0, 1, 2}
,
parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]  = '{'{1, 5, 4}
, '{1, 5, 4}
, '{1, 5, 4}
, '{2, 4}
, '{6, 4}
, '{7, 4}
}
,
parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 8}
, '{9, 10}
, '{11, 12}
, '{13, 14}
}
,
parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1, 5, 4}
, '{1, 5, 4}
, '{1, 5, 4}
, '{2, 4}
, '{6, 4}
, '{7, 4}
}
, '{'{1, 5, 4}
, '{1, 5, 4}
, '{1, 5, 4}
, '{2, 4}
, '{6, 4}
, '{7, 4}
}
}
,
parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX ]= '{'{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 8}
, '{9, 10}
, '{11, 12}
, '{13, 14}
}
, '{'{15, 16, 17}
, '{18, 19, 20}
, '{21, 22, 23}
, '{24, 25}
, '{26, 27}
, '{28, 29}
}
}
,
// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS SETTINGS
// --------------------------------------------------------------------------------------
parameter CU_BUNDLES_COUNT_ARRAY = 2,
parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{6,6},
parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{3, 3, 3, 2, 2, 2}
, '{3, 3, 3, 2, 2, 2}
}
,
parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1, 5, 4}
, '{1, 5, 4}
, '{1, 5, 4}
, '{2, 4}
, '{6, 4}
, '{7, 4}
}
, '{'{1, 5, 4}
, '{1, 5, 4}
, '{1, 5, 4}
, '{2, 4}
, '{6, 4}
, '{7, 4}
}
}
,
parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 1, 2}
, '{3, 4, 5}
, '{6, 7, 8}
, '{9, 10}
, '{11, 12}
, '{13, 14}
}
, '{'{15, 16, 17}
, '{18, 19, 20}
, '{21, 22, 23}
, '{24, 25}
, '{26, 27}
, '{28, 29}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0, 4, 0}
, '{0, 3, 0}
, '{0, 2, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
, '{'{0, 4, 0}
, '{0, 3, 0}
, '{0, 2, 0}
, '{0, 0}
, '{0, 0}
, '{0, 0}
}
}
,
parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{'{}
, '{}
, '{}
}
, '{'{0}
, '{}
, '{}
}
, '{'{0, 1}
, '{}
, '{}
}
, '{'{0, 1, 2}
, '{}
}
, '{'{}
, '{}
}
, '{'{}
, '{}
}
}
, '{'{'{}
, '{}
, '{}
}
, '{'{0}
, '{}
, '{}
}
, '{'{0, 1}
, '{}
, '{}
}
, '{'{0, 1, 2}
, '{}
}
, '{'{}
, '{}
}
, '{'{}
, '{}
}
}
}

