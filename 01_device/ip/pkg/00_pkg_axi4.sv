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

`timescale 1 ns / 1 ps
package PKG_AXI4;

  parameter S_AXI_ADDR_WIDTH_BITS = 12;
  parameter S_AXI_DATA_WIDTH      = 32;

  parameter M_AXI4_ADDR_W   = 64               ;
  parameter M_AXI4_DATA_W   = 512              ;
  parameter M_AXI4_STRB_W   = M_AXI4_DATA_W / 8;
  parameter M_AXI4_BURST_W  = 2                ;
  parameter M_AXI4_CACHE_W  = 4                ;
  parameter M_AXI4_PROT_W   = 3                ;
  parameter M_AXI4_REGION_W = 4                ;
  parameter M_AXI4_USER_W   = 4                ;
  parameter M_AXI4_LOCK_W   = 1                ;
  parameter M_AXI4_QOS_W    = 4                ;
  parameter M_AXI4_LEN_W    = 8                ;
  parameter M_AXI4_SIZE_W   = 3                ;
  parameter M_AXI4_RESP_W   = 2                ;
  parameter M_AXI4_ID_W     = 1                ;

  typedef logic                       type_m_axi4_valid;
  typedef logic                       type_m_axi4_ready;
  typedef logic                       type_m_axi4_last;
  typedef logic [M_AXI4_ADDR_W-1:0]   type_m_axi4_addr;
  typedef logic [M_AXI4_DATA_W-1:0]   type_m_axi4_data;
  typedef logic [M_AXI4_STRB_W-1:0]   type_m_axi4_strb;
  typedef logic [M_AXI4_LEN_W-1:0]    type_m_axi4_len;
  typedef logic [M_AXI4_LOCK_W-1:0]   type_m_axi4_lock;
  typedef logic [M_AXI4_PROT_W-1:0]   type_m_axi4_prot;
  typedef logic [M_AXI4_REGION_W-1:0] type_m_axi4_region;
  typedef logic [M_AXI4_QOS_W-1:0]    type_m_axi4_qos;
  typedef logic [M_AXI4_ID_W-1:0]     type_m_axi4_id;

  parameter M_AXI4_BURST_FIXED = 2'b00;
  parameter M_AXI4_BURST_INCR  = 2'b01;
  parameter M_AXI4_BURST_WRAP  = 2'b10;
  parameter M_AXI4_BURST_RSVD  = 2'b11;

  typedef logic [M_AXI4_BURST_W-1:0] type_m_axi4_burst;

  parameter M_AXI4_RESP_OKAY   = 2'b00;
  parameter M_AXI4_RESP_EXOKAY = 2'b01;
  parameter M_AXI4_RESP_SLVERR = 2'b10;
  parameter M_AXI4_RESP_DECERR = 2'b11;

  typedef logic [M_AXI4_RESP_W-1:0] type_m_axi4_resp;

  parameter M_AXI4_SIZE_1B   = 3'b000;
  parameter M_AXI4_SIZE_2B   = 3'b001;
  parameter M_AXI4_SIZE_4B   = 3'b010;
  parameter M_AXI4_SIZE_8B   = 3'b011;
  parameter M_AXI4_SIZE_16B  = 3'b100;
  parameter M_AXI4_SIZE_32B  = 3'b101;
  parameter M_AXI4_SIZE_64B  = 3'b110;
  parameter M_AXI4_SIZE_128B = 3'b111;

  typedef logic [M_AXI4_SIZE_W-1:0] type_m_axi4_size;

  parameter M_AXI4_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
  parameter M_AXI4_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
  parameter M_AXI4_CACHE_NO_ALLOCATE                            = 4'B0010;
  parameter M_AXI4_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
  parameter M_AXI4_CACHE_RESERVED_1                             = 4'B0100;
  parameter M_AXI4_CACHE_RESERVED_2                             = 4'B0101;
  parameter M_AXI4_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
  parameter M_AXI4_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
  parameter M_AXI4_CACHE_RESERVED_3                             = 4'B1000;
  parameter M_AXI4_CACHE_RESERVED_4                             = 4'B1001;
  parameter M_AXI4_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
  parameter M_AXI4_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
  parameter M_AXI4_CACHE_RESERVED_5                             = 4'B1100;
  parameter M_AXI4_CACHE_RESERVED_6                             = 4'B1101;
  parameter M_AXI4_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
  parameter M_AXI4_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

  typedef logic [M_AXI4_CACHE_W-1:0] type_m_axi4_cache;

  typedef struct packed {
    type_m_axi4_valid rvalid ; // Read channel valid
    type_m_axi4_last  arready; // Address read channel ready
    type_m_axi4_last  rlast  ; // Read channel last word
    type_m_axi4_data  rdata  ; // Read channel data
    type_m_axi4_id    rid    ; // Read channel ID
    type_m_axi4_resp  rresp  ; // Read channel response
  } AXI4MasterReadInterfaceInput;

  typedef struct packed {
    type_m_axi4_valid arvalid; // Address read channel valid
    type_m_axi4_addr  araddr ; // Address read channel address
    type_m_axi4_len   arlen  ; // Address write channel burst length
    type_m_axi4_ready rready ; // Read channel ready
    type_m_axi4_id    arid   ; // Address read channel ID
    type_m_axi4_size  arsize ; // Address read channel burst size. This signal indicates the size of each transfer in the burst
    type_m_axi4_burst arburst; // Address read channel burst type
    type_m_axi4_lock  arlock ; // Address read channel lock type
    type_m_axi4_cache arcache; // Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    type_m_axi4_prot  arprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    type_m_axi4_qos   arqos  ; // Address write channel quality of service
  } AXI4MasterReadInterfaceOutput;

  typedef struct packed {
    AXI4MasterReadInterfaceInput  in ;
    AXI4MasterReadInterfaceOutput out;
  } AXI4MasterReadInterface;


  typedef struct packed {
    type_m_axi4_ready awready; // Address write channel ready
    type_m_axi4_ready wready ; // Write channel ready
    type_m_axi4_id    bid    ; // Write response channel ID
    type_m_axi4_resp  bresp  ; // Write channel response
    type_m_axi4_valid bvalid ; // Write response channel valid
  } AXI4MasterWriteInterfaceInput;

  typedef struct packed {
    type_m_axi4_valid awvalid; // Address write channel valid
    type_m_axi4_id    awid   ; // Address write channel ID
    type_m_axi4_addr  awaddr ; // Address write channel address
    type_m_axi4_len   awlen  ; // Address write channel burst length
    type_m_axi4_size  awsize ; // Address write channel burst size. This signal indicates the size of each transfer in the burst
    type_m_axi4_burst awburst; // Address write channel burst type
    type_m_axi4_lock  awlock ; // Address write channel lock type
    type_m_axi4_cache awcache; // Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
    type_m_axi4_prot  awprot ; // Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    type_m_axi4_qos   awqos  ; // Address write channel quality of service
    type_m_axi4_data  wdata  ; // Write channel data
    type_m_axi4_strb  wstrb  ; // Write channel write strobe
    type_m_axi4_last  wlast  ; // Write channel last word flag
    type_m_axi4_valid wvalid ; // Write channel valid
    type_m_axi4_ready bready ; // Write response channel ready
  } AXI4MasterWriteInterfaceOutput;

  typedef struct packed {
    AXI4MasterWriteInterfaceInput  in ;
    AXI4MasterWriteInterfaceOutput out;
  } AXI4MasterWriteInterface;


  function logic [M_AXI4_DATA_W-1:0] swap_endianness_cacheline_axi (logic [M_AXI4_DATA_W-1:0] in);

    logic [M_AXI4_DATA_W-1:0] out;

    integer i;
    for ( i = 0; i < M_AXI4_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M_AXI4_DATA_W-1)-(i*8)) -:8];
    end

    return out;
  endfunction : swap_endianness_cacheline_axi

endpackage
