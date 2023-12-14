    parameter ID_CU                     = 0,
    parameter ID_BUNDLE                 = 0,
    parameter ID_LANE                   = 0,
    parameter ID_ENGINE                 = 0,
    parameter ID_RELATIVE               = 0,
    parameter ENGINES_CONFIG            = 0,
    parameter LANE_CAST_WIDTH           = 1,
    parameter LANE_MERGE_WIDTH          = 1,
    parameter ENGINE_CAST_WIDTH         = 1,
    parameter ENGINE_MERGE_WIDTH        = 1,
    parameter FIFO_WRITE_DEPTH_MEMORY   = 16,
    parameter FIFO_WRITE_DEPTH_ENGINE   = 16,
    parameter FIFO_WRITE_DEPTH_CONTROL  = 16,
    parameter ENGINE_SEQ_WIDTH          = 16,
    parameter ENGINE_SEQ_MIN            = ID_RELATIVE * ENGINE_SEQ_WIDTH,
// --------------------------------------------------------------------------------------
// CU SETTINGS
// --------------------------------------------------------------------------------------
`include "shared_parameters.vh"

