`timescale 1 ns / 1 ps

`include "iob_lib.vh"
`include "iob-cache.vh"

package GLAY_REQ_PKG;

import GLAY_GLOBALS_PKG::*;

// --------------------------------------------------------------------------------------
// FIFO Signals
// --------------------------------------------------------------------------------------

typedef struct packed {
  logic full        ;
  logic almost_full ;
  logic empty       ;
  logic almost_empty;
  logic valid       ;
  logic prog_full   ;
  logic prog_empty  ;
  logic wr_rst_busy ;
  logic rd_rst_busy ;
} FIFOStateSignalsOutput;

typedef struct packed {
  logic rd_en;
  logic wr_en;
} FIFOStateSignalsInput;

// --------------------------------------------------------------------------------------
// Cache requests in GlayCacheRequestInterfaceOutput
// --------------------------------------------------------------------------------------

// SIZE = 516 bits
typedef struct packed {
  logic valid;
  `ifdef WORD_ADDR
    logic [CACHE_CTRL_CNT+CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W] addr;
  `else
    logic [CACHE_CTRL_CNT+CACHE_FRONTEND_ADDR_W-1:0] addr;
  `endif

  logic [CACHE_FRONTEND_DATA_W-1:0] wdata;
  logic [CACHE_FRONTEND_NBYTES-1:0] wstrb;
  `ifdef CTRL_IO
    //control-status io
    logic force_inv_in; //force 1'b0 if unused
    logic wtb_empty_in; //force 1'b1 if unused
  `endif
} GlayCacheRequestInterfaceInputPayload;


// SIZE = 644 - 6(CACHE_FRONTEND_BYTE_W) = 638 bits
typedef struct packed {
  logic                                 valid  ;
  GlayCacheRequestInterfaceInputPayload payload;
} GlayCacheRequestInterfaceInput;

// --------------------------------------------------------------------------------------
// Cache requests out GlayCacheRequestInterfaceOutput
// --------------------------------------------------------------------------------------

typedef struct packed {
  logic [CACHE_FRONTEND_DATA_W-1:0] rdata;
  logic                             ready;
  `ifdef CTRL_IO
    //control-status io
    logic force_inv_out;
    logic wtb_empty_out;
  `endif
} GlayCacheRequestInterfaceOutputPayload;


// SIZE = 516 bits
typedef struct packed {
  logic                                  valid  ;
  GlayCacheRequestInterfaceOutputPayload payload;
} GlayCacheRequestInterfaceOutput;


// --------------------------------------------------------------------------------------
//   State Machine Setup Requests
// --------------------------------------------------------------------------------------

    typedef enum int unsigned {
        SETUP_RESET,
        SETUP_IDLE,
        SETUP_REQ_START,
        SETUP_REQ_BUSY,
        SETUP_REQ_DONE
    } kernel_setup_state;

endpackage
