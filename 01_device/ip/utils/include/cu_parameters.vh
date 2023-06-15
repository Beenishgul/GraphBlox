// --------------------------------------------------------------------------------------
// CU Configuration
// --------------------------------------------------------------------------------------
parameter NUM_BUNDLES = 4,
parameter NUM_LANES   = 6,
parameter NUM_ENGINES = 3,

// --------------------------------------------------------------------------------------
// number of engines pipeline for each lane
// --------------------------------------------------------------------------------------
parameter LANES_CONFIG[NUM_LANES] = '{3,3,3,2,2,2},

// --------------------------------------------------------------------------------------
// ENGINE TYPES ORDERED in pipeline
// (0) ENGINE EMPTY
// (1) ENGINE MEMORY R/W Generator
// (2) ENGINE CSR
// (3) ENGINE ALU
// (4) ENGINE FILTER
// (5) ENGINE MERGE
// (6) ENGINE FORWARD BUFFER
// --------------------------------------------------------------------------------------
parameter ENGINES_CONFIG[NUM_LANES][NUM_ENGINES] = '{'{1,5,4},'{1,5,4},'{1,5,4},'{2,5,0},'{3,4,0},'{6,4,0}}
