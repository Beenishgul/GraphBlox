`timescale 1 ns / 1 ps

`include "iob_lib.vh"
`include "iob-cache.vh"

package GLAY_REQ_PKG;

import GLAY_GLOBALS_PKG::*;
import GLAY_AXI4_PKG::*;


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

typedef struct packed {
  logic                                 valid  ;
  GlayCacheRequestInterfaceInputPayload payload;
} GlayCacheRequestInterfaceInput;


typedef struct packed {
  logic [CACHE_FRONTEND_DATA_W-1:0] rdata;
  logic                             ready;
  `ifdef CTRL_IO
    //control-status io
    logic force_inv_out;
    logic wtb_empty_out;
  `endif
} GlayCacheRequestInterfaceOutputPayload;

typedef struct packed {
  logic                                  valid  ;
  GlayCacheRequestInterfaceOutputPayload payload;
} GlayCacheRequestInterfaceOutput;

endpackage
