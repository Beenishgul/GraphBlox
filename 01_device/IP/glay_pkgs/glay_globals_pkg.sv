// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_globals_pkg.sv
// Create : 2022-11-12 20:24:25
// Revise : 2022-11-12 20:24:25
// Editor : sublime text4, tab size (4)
// -----------------------------------------------------------------------------

package GLAY_GLOBALS_PKG;

////////////////////////////////////////////////////////////////////////////
//  GLay COMMON GLOBALS
////////////////////////////////////////////////////////////////////////////
    parameter PAGE_SIZE              = 65536                  ;// Pagesize default is 64KB
    parameter PAGE_SIZE_BITS         = (PAGE_SIZE * 8)        ;
    parameter CACHELINE_SIZE         = 64                     ; // cacheline is 128bytes
    parameter CACHELINE_SIZE_BITS    = (CACHELINE_SIZE * 8)   ;
    parameter CACHELINE_SIZE_HF      = (CACHELINE_SIZE >> 1)  ; // cacheline is 64bytes
    parameter CACHELINE_SIZE_BITS_HF = (CACHELINE_SIZE_HF * 8);

    parameter WORD                   = 4              ;
    parameter WORD_BITS              = WORD * 8       ;
    parameter WORD_DOUBLE            = WORD * 2       ;
    parameter WORD_DOUBLE_BITS       = WORD_DOUBLE * 8;

////////////////////////////////////////////////////////////////////////////
// AXI4 (SIZES/MODES)
////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////
// GLay ADDRESS Mappings on AFU and HOST
////////////////////////////////////////////////////////////////////////////

// ********************************************************************************************
// ***************                  MMIO/Scalar General                          **************
// ********************************************************************************************

    parameter AFU_STATUS         = 26'h 3FFFFF8 >> 2;
    parameter AFU_CONFIGURE      = 26'h 3FFFFF0 >> 2;
    parameter AFU_CONFIGURE_2    = 26'h 3FFFFE8 >> 2;

    parameter CU_STATUS          = 26'h 3FFFFE0 >> 2;
    parameter CU_CONFIGURE       = 26'h 3FFFFD8 >> 2;
    parameter CU_CONFIGURE_2     = 26'h 3FFFFD0 >> 2;
    parameter CU_CONFIGURE_3     = 26'h 3FFFFC8 >> 2;
    parameter CU_CONFIGURE_4     = 26'h 3FFFFC0 >> 2;

    parameter CU_RETURN          = 26'h 3FFFFB8 >> 2; // running counters that you can read continuosly
    parameter CU_RETURN_2        = 26'h 3FFFFB0 >> 2;
    parameter CU_RETURN_ACK      = 26'h 3FFFFA8 >> 2;

    parameter CU_RETURN_DONE     = 26'h 3FFFFA0 >> 2;
    parameter CU_RETURN_DONE_2   = 26'h 3FFFF98 >> 2;
    parameter CU_RETURN_DONE_ACK = 26'h 3FFFF90 >> 2;

    parameter ERROR_REG          = 26'h 3FFFF88 >> 2;
    parameter ERROR_REG_ACK      = 26'h 3FFFF80 >> 2;

// ********************************************************************************************
// ***************                  GLOBAL MEMORY(DDR4/HBM)                      **************
// ***************                  ALVEO 250 -> 4  banks (300MHz)               **************
// ***************                  ALVEO 250 -> 32 banks (300/500MHz)           **************
// ********************************************************************************************



endpackage