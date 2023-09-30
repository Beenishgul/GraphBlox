    parameter ID_CU              = 0,
    parameter ID_BUNDLE          = 0,
    parameter ID_LANE            = 0,
    parameter ID_ENGINE          = 0,
    parameter ID_RELATIVE        = 0,
    parameter ENGINES_CONFIG     = 0,
// --------------------------------------------------------------------------------------
// FIFO_SETTINGS
// --------------------------------------------------------------------------------------
    FIFO_WRITE_DEPTH         = 32,
    PROG_THRESH              = 16,
// --------------------------------------------------------------------------------------
// MAX NUMBER IN ALL CONFIGURATIONS FOR EACH VARIABLE
// --------------------------------------------------------------------------------------
    parameter NUM_CUS_MAX     = 2,
    parameter NUM_BUNDLES_MAX = 4,
    parameter NUM_LANES_MAX   = 6,
    parameter NUM_ENGINES_MAX = 3,
// --------------------------------------------------------------------------------------
// CU Configuration
// --------------------------------------------------------------------------------------
    parameter NUM_CUS     = 4,
    parameter NUM_BUNDLES = 4,
    parameter NUM_LANES   = 6,
    parameter NUM_ENGINES = 3,

    parameter NUM_CUS_INDEX     = NUM_CUS,
    parameter NUM_BUNDLES_INDEX = NUM_BUNDLES,
    parameter NUM_LANES_INDEX   = NUM_LANES,
    parameter NUM_ENGINES_INDEX = NUM_ENGINES,

    // parameter NUM_CUS_INDEX     = (NUM_CUS >  NUM_CUS_MAX) ? NUM_CUS_MAX : NUM_CUS,
    // parameter NUM_BUNDLES_INDEX = (NUM_BUNDLES >  NUM_BUNDLES_MAX) ? NUM_BUNDLES_MAX : NUM_BUNDLES,
    // parameter NUM_LANES_INDEX   = (NUM_LANES >  NUM_LANES_MAX) ? NUM_LANES_MAX : NUM_LANES,
    // parameter NUM_ENGINES_INDEX = (NUM_ENGINES >  NUM_ENGINES_MAX) ? NUM_ENGINES_MAX : NUM_ENGINES,
// --------------------------------------------------------------------------------------
// ENGINE CONFIG TYPES ORDERED in pipeline
// --------------------------------------------------------------------------------------
// (0) ENGINE EMPTY
// (1) ENGINE MEMORY R/W Generator
// (2) ENGINE CSR
// (3) ENGINE ALU
// (4) ENGINE FILTER
// (5) ENGINE MERGE
// (6) ENGINE FORWARD BUFFER
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS GLay
// --------------------------------------------------------------------------------------
    // parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]  = '{6,6,6,6},
    // parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX] = '{3,3,3,3,2,2},
    // parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}},
    // parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX] = '{1,5,4},
    // parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},
    // parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}}}

    // parameter int CU_BUNDLES_COUNT_ARRAY[NUM_CUS_MAX] = '{4,4},
    // parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_CUS_MAX][NUM_BUNDLES_MAX] = '{'{6,6,6,6},'{6,6,6,6}},
    // parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_CUS_MAX][NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}},'{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}}},
    // parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_CUS_MAX][NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}}},'{'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}}}},

// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS TEST
// --------------------------------------------------------------------------------------
    parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]  = '{6,6,6,6},
    parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX] = '{3,3,3,3,2,2},
    parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}},
    parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX] = '{0,0,0},
    parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX] = '{0,0,0},
    parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},
    parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},
    parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}}},
    parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}}},
    

    parameter int CU_BUNDLES_COUNT_ARRAY[NUM_CUS_MAX] = '{4,4},
    parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_CUS_MAX][NUM_BUNDLES_MAX] = '{'{6,6,6,6},'{6,6,6,6}},
    parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_CUS_MAX][NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}},'{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}}},
    parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_CUS_MAX][NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}}},'{'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}}}},
    parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_CUS_MAX][NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{'{0,0,0},'{1,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{2,0,0},'{3,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}}},'{'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}}}}
