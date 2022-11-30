// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : glay_axi4_pkg.sv
// Create : 2022-11-28 16:08:34
// Revise : 2022-11-28 16:08:34
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------


package GLAY_AXI4_PKG;

  import GLOBALS_AFU_PKG::*;

  typedef struct packed {
    AXI4MasterReadInterfaceInput  in ;
    AXI4MasterReadInterfaceOutput out;
  } AXI4MasterReadInterface;

  typedef struct packed {
    logic                            rvalid ; // Read channel valid
    logic                            arready; // Address read channel ready
    logic                            rlast  ; // Read channel last word
    logic [C_M00_AXI_DATA_WIDTH-1:0] rdata  ; // Read channel data
    logic [      CACHE_AXI_ID_W-1:0] rid    ; // Read channel ID
    logic [                   2-1:0] rresp  ; // Read channel response
  } AXI4MasterReadInterfaceInput;

  typedef struct packed {
    logic                          arvalid; // Address read channel valid
    logic [C_M_AXI_ADDR_WIDTH-1:0] araddr ; // Address read channel address
    logic [                 8-1:0] arlen  ; // Address write channel burst length
    logic                          rready ; // Read channel ready
    logic [    CACHE_AXI_ID_W-1:0] arid   ; // Address read channel ID
    logic [                 3-1:0] arsize ; // Address read channel burst size. This signal indicates the size of each transfer in the burst
    logic [                 2-1:0] arburst; // Address read channel burst type
    logic [                 2-1:0] arlock ; // Address read channel lock type
    logic [                 4-1:0] arcache; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    logic [                 3-1:0] arprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    logic [                 4-1:0] arqos  ; // Address write channel quality of service
  } AXI4MasterReadInterfaceOutput;

  typedef struct packed {
    AXI4MasterWriteInterfaceInput  in ;
    AXI4MasterWriteInterfaceOutput out;
  } AXI4MasterWriteInterface;

  typedef struct packed {
    logic                      awready; // Address write channel ready
    logic                      wready ; // Write channel ready
    logic [CACHE_AXI_ID_W-1:0] bid    ; // Write response channel ID
    logic [             2-1:0] bresp  ; // Write channel response
    logic                      bvalid ; // Write response channel valid
  } AXI4MasterWriteInterfaceInput;

  typedef struct packed {
    logic                            awvalid; // Address write channel valid
    logic [      CACHE_AXI_ID_W-1:0] awid   ; // Address write channel ID
    logic [C_M00_AXI_ADDR_WIDTH-1:0] awaddr ; // Address write channel address
    logic [                   8-1:0] awlen  ; // Address write channel burst length
    logic [                   3-1:0] awsize ; // Address write channel burst size. This signal indicates the size of each transfer in the burst
    logic [                   2-1:0] awburst; // Address write channel burst type
    logic [                   2-1:0] awlock ; // Address write channel lock type
    logic [                   4-1:0] awcache; // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    logic [                   3-1:0] awprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    logic [                   4-1:0] awqos  ; // Address write channel quality of service
    logic [C_M00_AXI_DATA_WIDTH-1:0] wdata  ; // Write channel data
    logic                            wstrb  ; // Write channel write strobe
    logic                            wlast  ; // Write channel last word flag
    logic                            wvalid ; // Write channel valid
    logic                            bready ; // Write response channel ready

  } AXI4MasterWriteInterfaceOutput;

endpackage
