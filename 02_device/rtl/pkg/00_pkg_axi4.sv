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

`include "global_timescale.vh"
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
  parameter M_AXI4_LOCK_W   = 2                ;
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

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

  typedef struct packed {
    type_m_axi4_valid rvalid ; // Input Read channel valid
    type_m_axi4_last  arready; // Input Read Address read channel ready
    type_m_axi4_last  rlast  ; // Input Read channel last word
    type_m_axi4_data  rdata  ; // Input Read channel data
    type_m_axi4_id    rid    ; // Input Read channel ID
    type_m_axi4_resp  rresp  ; // Input Read channel response
  } AXI4MasterReadInterfaceInput;

  typedef struct packed {
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

  typedef struct packed {
    AXI4MasterReadInterfaceInput  in ;
    AXI4MasterReadInterfaceOutput out;
  } AXI4MasterReadInterface;


  typedef struct packed {
    type_m_axi4_ready awready; // Input Write Address write channel ready
    type_m_axi4_ready wready ; // Input Write channel ready
    type_m_axi4_id    bid    ; // Input Write response channel ID
    type_m_axi4_resp  bresp  ; // Input Write channel response
    type_m_axi4_valid bvalid ; // Input Write response channel valid
  } AXI4MasterWriteInterfaceInput;

  typedef struct packed {
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

  typedef struct packed {
    AXI4MasterWriteInterfaceInput  in ;
    AXI4MasterWriteInterfaceOutput out;
  } AXI4MasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

  typedef struct packed {
    type_m_axi4_valid rvalid ; // Input Read channel valid
    type_m_axi4_last  arready; // Input Read Address read channel ready
    type_m_axi4_last  rlast  ; // Input Read channel last word
    type_m_axi4_data  rdata  ; // Input Read channel data
    type_m_axi4_id    rid    ; // Input Read channel ID
    type_m_axi4_resp  rresp  ; // Input Read channel response
  } AXI4SlaveReadInterfaceOutput;

  typedef struct packed {
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

  typedef struct packed {
    AXI4SlaveReadInterfaceInput  in ;
    AXI4SlaveReadInterfaceOutput out;
  } AXI4SlaveReadInterface;


  typedef struct packed {
    type_m_axi4_ready awready; // Input Write Address write channel ready
    type_m_axi4_ready wready ; // Input Write channel ready
    type_m_axi4_id    bid    ; // Input Write response channel ID
    type_m_axi4_resp  bresp  ; // Input Write channel response
    type_m_axi4_valid bvalid ; // Input Write response channel valid
  } AXI4SlaveWriteInterfaceOutput;

  typedef struct packed {
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

  typedef struct packed {
    AXI4SlaveWriteInterfaceInput  in ;
    AXI4SlaveWriteInterfaceOutput out;
  } AXI4SlaveWriteInterface;


  function logic [M_AXI4_DATA_W-1:0] swap_endianness_cacheline_axi (logic [M_AXI4_DATA_W-1:0] in, logic mode);

    logic [M_AXI4_DATA_W-1:0] out;

    integer i;

    if(mode == 1) begin
      for ( i = 0; i < M_AXI4_STRB_W; i++) begin
        out[i*8 +: 8] = in[((M_AXI4_DATA_W-1)-(i*8)) -:8];
      end
    end else begin
      out = in;
    end

    return out;
  endfunction : swap_endianness_cacheline_axi

endpackage
