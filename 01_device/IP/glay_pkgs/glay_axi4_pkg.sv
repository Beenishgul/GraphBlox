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

`timescale 1 ns / 1 ps
package GLAY_AXI4_PKG;

  import GLAY_GLOBALS_PKG::*;

  parameter M_AXI4_ADDR_W   = M_AXI_MEMORY_ADDR_WIDTH     ;
  parameter M_AXI4_DATA_W   = M_AXI_MEMORY_DATA_WIDTH_BITS;
  parameter M_AXI4_STRB_W   = M_AXI4_DATA_W / 8           ;
  parameter M_AXI4_BURST_W  = 2                           ;
  parameter M_AXI4_CACHE_W  = 4                           ;
  parameter M_AXI4_PROT_W   = 3                           ;
  parameter M_AXI4_REGION_W = 4                           ;
  parameter M_AXI4_USER_W   = 4                           ;
  parameter M_AXI4_LOCK_W   = 1                           ;
  parameter M_AXI4_QOS_W    = 4                           ;
  parameter M_AXI4_LEN_W    = 8                           ;
  parameter M_AXI4_SIZE_W   = 3                           ;
  parameter M_AXI4_RESP_W   = 2                           ;
  parameter M_AXI4_ID_W     = CACHE_AXI_ID_W              ;

  typedef logic                       m_axi4_valid_t;
  typedef logic                       m_axi4_ready_t;
  typedef logic                       m_axi4_last_t;
  typedef logic [M_AXI4_ADDR_W-1:0]   m_axi4_addr_t;
  typedef logic [M_AXI4_DATA_W-1:0]   m_axi4_data_t;
  typedef logic [M_AXI4_STRB_W-1:0]   m_axi4_strb_t;
  typedef logic [M_AXI4_LEN_W-1:0]    m_axi4_len_t;
  typedef logic [M_AXI4_LOCK_W-1:0]    m_axi4_lock_t;
  typedef logic [M_AXI4_CACHE_W-1:0]  m_axi4_cache_t;
  typedef logic [M_AXI4_PROT_W-1:0]   m_axi4_prot_t;
  typedef logic [M_AXI4_REGION_W-1:0] m_axi4_region_t;
  typedef logic [M_AXI4_QOS_W-1:0]    m_axi4_qos_t;
  typedef logic [M_AXI4_ID_W-1:0]     m_axi4_id_t;

  typedef enum logic [M_AXI4_BURST_W-1:0] {
    M_AXI4_BURST_FIXED = 2'b00,
    M_AXI4_BURST_INCR  = 2'b01,
    M_AXI4_BURST_WRAP  = 2'b10,
    M_AXI4_BURST_RSVD  = 2'b11
  } m_axi4_burst_t;

  typedef enum logic [M_AXI4_RESP_W-1:0] {
    M_AXI4_RESP_OKAY   = 2'b00,
    M_AXI4_RESP_EXOKAY = 2'b01,
    M_AXI4_RESP_SLVERR = 2'b10,
    M_AXI4_RESP_DECERR = 2'b11
  } m_axi4_resp_t;

  typedef enum logic [M_AXI4_SIZE_W-1:0] {
    M_AXI4_SIZE_1B   = 3'b000,
    M_AXI4_SIZE_2B   = 3'b001,
    M_AXI4_SIZE_4B   = 3'b010,
    M_AXI4_SIZE_8B   = 3'b011,
    M_AXI4_SIZE_16B  = 3'b100,
    M_AXI4_SIZE_32B  = 3'b101,
    M_AXI4_SIZE_64B  = 3'b110,
    M_AXI4_SIZE_128B = 3'b111
  } m_axi4_size_t;

  typedef struct packed {
    m_axi4_valid_t rvalid ; // Read channel valid
    m_axi4_last_t  arready; // Address read channel ready
    m_axi4_last_t  rlast  ; // Read channel last word
    m_axi4_data_t  rdata  ; // Read channel data
    m_axi4_id_t    rid    ; // Read channel ID
    m_axi4_resp_t  rresp  ; // Read channel response
  } AXI4MasterReadInterfaceInput;

  typedef struct packed {
    m_axi4_valid_t arvalid; // Address read channel valid
    m_axi4_addr_t  araddr ; // Address read channel address
    m_axi4_len_t   arlen  ; // Address write channel burst length
    m_axi4_ready_t rready ; // Read channel ready
    m_axi4_id_t    arid   ; // Address read channel ID
    m_axi4_size_t  arsize ; // Address read channel burst size. This signal indicates the size of each transfer in the burst
    m_axi4_burst_t arburst; // Address read channel burst type
    m_axi4_lock_t  arlock ; // Address read channel lock type
    m_axi4_cache_t arcache; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    m_axi4_prot_t  arprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    m_axi4_qos_t   arqos  ; // Address write channel quality of service
  } AXI4MasterReadInterfaceOutput;

  typedef struct packed {
    AXI4MasterReadInterfaceInput  in ;
    AXI4MasterReadInterfaceOutput out;
  } AXI4MasterReadInterface;


  typedef struct packed {
    m_axi4_ready_t awready; // Address write channel ready
    m_axi4_ready_t wready ; // Write channel ready
    m_axi4_id_t    bid    ; // Write response channel ID
    m_axi4_resp_t  bresp  ; // Write channel response
    m_axi4_valid_t bvalid ; // Write response channel valid
  } AXI4MasterWriteInterfaceInput;

  typedef struct packed {
    m_axi4_valid_t awvalid; // Address write channel valid
    m_axi4_id_t    awid   ; // Address write channel ID
    m_axi4_addr_t  awaddr ; // Address write channel address
    m_axi4_len_t   awlen  ; // Address write channel burst length
    m_axi4_size_t  awsize ; // Address write channel burst size. This signal indicates the size of each transfer in the burst
    m_axi4_burst_t awburst; // Address write channel burst type
    m_axi4_lock_t  awlock ; // Address write channel lock type
    m_axi4_cache_t awcache; // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    m_axi4_prot_t  awprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    m_axi4_qos_t   awqos  ; // Address write channel quality of service
    m_axi4_data_t  wdata  ; // Write channel data
    m_axi4_strb_t  wstrb  ; // Write channel write strobe
    m_axi4_last_t  wlast  ; // Write channel last word flag
    m_axi4_valid_t wvalid ; // Write channel valid
    m_axi4_ready_t bready ; // Write response channel ready
  } AXI4MasterWriteInterfaceOutput;

  typedef struct packed {
    AXI4MasterWriteInterfaceInput  in ;
    AXI4MasterWriteInterfaceOutput out;
  } AXI4MasterWriteInterface;

endpackage
