// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_AXI4.sv
// Create : 2022-11-28 16:08:34
// Revise : 2022-11-28 16:08:34
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

#ifndef PKG_AXI4_HPP
#define PKG_AXI4_HPP

#include <cmath>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <cstdlib>
using namespace std;

#include “ap_int.h”

  #define S_AXI_ADDR_WIDTH_BITS  12
  #define S_AXI_DATA_WIDTH       32

  #define M_AXI4_ADDR_W    64               
  #define M_AXI4_DATA_W    512             
  #define M_AXI4_STRB_W    M_AXI4_DATA_W / 8
  #define M_AXI4_BURST_W   2                
  #define M_AXI4_CACHE_W   4                
  #define M_AXI4_PROT_W    3                
  #define M_AXI4_REGION_W  4                
  #define M_AXI4_USER_W    4                
  #define M_AXI4_LOCK_W    1                
  #define M_AXI4_QOS_W     4                
  #define M_AXI4_LEN_W     8                
  #define M_AXI4_SIZE_W    3               
  #define M_AXI4_RESP_W    2                
  #define M_AXI4_ID_W      1                
  #define M_AXI4_ID_1      1                

  typedef ap_uint<M_AXI4_ID_1>     type_m_axi4_valid;
  typedef ap_uint<M_AXI4_ID_1>     type_m_axi4_ready;
  typedef ap_uint<M_AXI4_ID_1>     type_m_axi4_last;
  typedef ap_uint<M_AXI4_ADDR_W>   type_m_axi4_addr;
  typedef ap_uint<M_AXI4_DATA_W>   type_m_axi4_data;
  typedef ap_uint<M_AXI4_STRB_W>   type_m_axi4_strb;
  typedef ap_uint<M_AXI4_LEN_W>    type_m_axi4_len;
  typedef ap_uint<M_AXI4_LOCK_W>   type_m_axi4_lock;
  typedef ap_uint<M_AXI4_PROT_W>   type_m_axi4_prot;
  typedef ap_uint<M_AXI4_REGION_W> type_m_axi4_region;
  typedef ap_uint<M_AXI4_QOS_W>    type_m_axi4_qos;
  typedef ap_uint<M_AXI4_ID_W>     type_m_axi4_id;
  typedef ap_uint<M_AXI4_BURST_W>  type_m_axi4_burst;
  typedef ap_uint<M_AXI4_RESP_W>   type_m_axi4_resp;
  typedef ap_uint<M_AXI4_SIZE_W>   type_m_axi4_size;
  typedef ap_uint<M_AXI4_CACHE_W>  type_m_axi4_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

  typedef struct {
    type_m_axi4_valid rvalid ; // Input Read channel valid
    type_m_axi4_last  arready; // Input Read Address read channel ready
    type_m_axi4_last  rlast  ; // Input Read channel last word
    type_m_axi4_data  rdata  ; // Input Read channel data
    type_m_axi4_id    rid    ; // Input Read channel ID
    type_m_axi4_resp  rresp  ; // Input Read channel response
  } AXI4MasterReadInterfaceInput;

  typedef struct {
    type_m_axi4_valid arvalid; // Output Read Address read channel valid
    type_m_axi4_addr  araddr ; // Output Read Address read channel address
    type_m_axi4_len   arlen  ; // Output Read Address channel burst length
    type_m_axi4_ready rready ; // Output Read Read channel ready
    type_m_axi4_id    arid   ; // Output Read Address read channel ID
    type_m_axi4_size  arsize ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
    type_m_axi4_burst arburst; // Output Read Address read channel burst type
    type_m_axi4_lock  arlock ; // Output Read Address read channel lock type
    type_m_axi4_cache arcache; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    type_m_axi4_prot  arprot ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    type_m_axi4_qos   arqos  ; // Output Read Address channel quality of service
  } AXI4MasterReadInterfaceOutput;

  typedef struct {
    AXI4MasterReadInterfaceInput  in ;
    AXI4MasterReadInterfaceOutput out;
  } AXI4MasterReadInterface;


  typedef struct {
    type_m_axi4_ready awready; // Input Write Address write channel ready
    type_m_axi4_ready wready ; // Input Write channel ready
    type_m_axi4_id    bid    ; // Input Write response channel ID
    type_m_axi4_resp  bresp  ; // Input Write channel response
    type_m_axi4_valid bvalid ; // Input Write response channel valid
  } AXI4MasterWriteInterfaceInput;

  typedef struct {
    type_m_axi4_valid awvalid; // Output Write Address write channel valid
    type_m_axi4_id    awid   ; // Output Write Address write channel ID
    type_m_axi4_addr  awaddr ; // Output Write Address write channel address
    type_m_axi4_len   awlen  ; // Output Write Address write channel burst length
    type_m_axi4_size  awsize ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
    type_m_axi4_burst awburst; // Output Write Address write channel burst type
    type_m_axi4_lock  awlock ; // Output Write Address write channel lock type
    type_m_axi4_cache awcache; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    type_m_axi4_prot  awprot ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    type_m_axi4_qos   awqos  ; // Output Write Address write channel quality of service
    type_m_axi4_data  wdata  ; // Output Write channel data
    type_m_axi4_strb  wstrb  ; // Output Write channel write strobe
    type_m_axi4_last  wlast  ; // Output Write channel last word flag
    type_m_axi4_valid wvalid ; // Output Write channel valid
    type_m_axi4_ready bready ; // Output Write response channel ready
  } AXI4MasterWriteInterfaceOutput;

  typedef struct {
    AXI4MasterWriteInterfaceInput  in ;
    AXI4MasterWriteInterfaceOutput out;
  } AXI4MasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

  typedef struct {
    type_m_axi4_valid rvalid ; // Input Read channel valid
    type_m_axi4_last  arready; // Input Read Address read channel ready
    type_m_axi4_last  rlast  ; // Input Read channel last word
    type_m_axi4_data  rdata  ; // Input Read channel data
    type_m_axi4_id    rid    ; // Input Read channel ID
    type_m_axi4_resp  rresp  ; // Input Read channel response
  } AXI4SlaveReadInterfaceOutput;

  typedef struct {
    type_m_axi4_valid arvalid; // Output Read Address read channel valid
    type_m_axi4_addr  araddr ; // Output Read Address read channel address
    type_m_axi4_len   arlen  ; // Output Read Address channel burst length
    type_m_axi4_ready rready ; // Output Read Read channel ready
    type_m_axi4_id    arid   ; // Output Read Address read channel ID
    type_m_axi4_size  arsize ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
    type_m_axi4_burst arburst; // Output Read Address read channel burst type
    type_m_axi4_lock  arlock ; // Output Read Address read channel lock type
    type_m_axi4_cache arcache; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    type_m_axi4_prot  arprot ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    type_m_axi4_qos   arqos  ; // Output Read Address channel quality of service
  } AXI4SlaveReadInterfaceInput;

  typedef struct {
    AXI4SlaveReadInterfaceInput  in ;
    AXI4SlaveReadInterfaceOutput out;
  } AXI4SlaveReadInterface;


  typedef struct {
    type_m_axi4_ready awready; // Input Write Address write channel ready
    type_m_axi4_ready wready ; // Input Write channel ready
    type_m_axi4_id    bid    ; // Input Write response channel ID
    type_m_axi4_resp  bresp  ; // Input Write channel response
    type_m_axi4_valid bvalid ; // Input Write response channel valid
  } AXI4SlaveWriteInterfaceOutput;

  typedef struct {
    type_m_axi4_valid awvalid; // Output Write Address write channel valid
    type_m_axi4_id    awid   ; // Output Write Address write channel ID
    type_m_axi4_addr  awaddr ; // Output Write Address write channel address
    type_m_axi4_len   awlen  ; // Output Write Address write channel burst length
    type_m_axi4_size  awsize ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
    type_m_axi4_burst awburst; // Output Write Address write channel burst type
    type_m_axi4_lock  awlock ; // Output Write Address write channel lock type
    type_m_axi4_cache awcache; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    type_m_axi4_prot  awprot ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    type_m_axi4_qos   awqos  ; // Output Write Address write channel quality of service
    type_m_axi4_data  wdata  ; // Output Write channel data
    type_m_axi4_strb  wstrb  ; // Output Write channel write strobe
    type_m_axi4_last  wlast  ; // Output Write channel last word flag
    type_m_axi4_valid wvalid ; // Output Write channel valid
    type_m_axi4_ready bready ; // Output Write response channel ready
  } AXI4SlaveWriteInterfaceInput;

  typedef struct {
    AXI4SlaveWriteInterfaceInput  in ;
    AXI4SlaveWriteInterfaceOutput out;
  } AXI4SlaveWriteInterface;


#endif