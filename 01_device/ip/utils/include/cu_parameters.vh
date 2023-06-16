// --------------------------------------------------------------------------------------
// CU Configuration
// --------------------------------------------------------------------------------------
    parameter NUM_BUNDLES = 4,
	parameter NUM_LANES   = 6,
	parameter NUM_ENGINES = 3,
// --------------------------------------------------------------------------------------
// number of engines pipeline for each lane
// --------------------------------------------------------------------------------------
	parameter NUM_BUNDLES_MAX = 4,
	parameter NUM_LANES_MAX   = 6,
	parameter NUM_ENGINES_MAX = 3,
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
// TOPOLOGY CONFIGURATIONS GLAY
// --------------------------------------------------------------------------------------
	// parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]  = '{6,6,6,6},
	// parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX] = {3,3,3,3,2,2},
	// parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}},
	// parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX] = '{1,5,4},
	// parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},
	// parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}},'{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}}}


// --------------------------------------------------------------------------------------
// TOPOLOGY CONFIGURATIONS TEST
// --------------------------------------------------------------------------------------
	parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]  = '{6,6,6,6},
    parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX] = {3,3,3,3,2,2},
    parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = '{'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2},'{3,3,3,3,2,2}},
    parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX] = '{0,0,0},
    parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},
    parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = '{'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}},'{'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0},'{0,0,0}}}
