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
package PKG_AXI4_BE;

parameter S_AXI_BE_ADDR_WIDTH_BITS = 12;
parameter S_AXI_BE_DATA_WIDTH      = 32;

parameter M_AXI4_BE_ADDR_W   = 64                  ;
parameter M_AXI4_BE_DATA_W   = 512                 ;
parameter M_AXI4_BE_STRB_W   = M_AXI4_BE_DATA_W / 8;
parameter M_AXI4_BE_BURST_W  = 2                   ;
parameter M_AXI4_BE_CACHE_W  = 4                   ;
parameter M_AXI4_BE_PROT_W   = 3                   ;
parameter M_AXI4_BE_REGION_W = 4                   ;
parameter M_AXI4_BE_USER_W   = 4                   ;
parameter M_AXI4_BE_LOCK_W   = 2                   ;
parameter M_AXI4_BE_QOS_W    = 4                   ;
parameter M_AXI4_BE_LEN_W    = 8                   ;
parameter M_AXI4_BE_SIZE_W   = 3                   ;
parameter M_AXI4_BE_RESP_W   = 2                   ;
parameter M_AXI4_BE_ID_W     = 1                   ;

typedef logic                          type_m_axi4_be_valid;
typedef logic                          type_m_axi4_be_ready;
typedef logic                          type_m_axi4_be_last;
typedef logic [M_AXI4_BE_ADDR_W-1:0]   type_m_axi4_be_addr;
typedef logic [M_AXI4_BE_DATA_W-1:0]   type_m_axi4_be_data;
typedef logic [M_AXI4_BE_STRB_W-1:0]   type_m_axi4_be_strb;
typedef logic [M_AXI4_BE_LEN_W-1:0]    type_m_axi4_be_len;
typedef logic [M_AXI4_BE_LOCK_W-1:0]   type_m_axi4_be_lock;
typedef logic [M_AXI4_BE_PROT_W-1:0]   type_m_axi4_be_prot;
typedef logic [M_AXI4_BE_REGION_W-1:0] type_m_axi4_be_region;
typedef logic [M_AXI4_BE_QOS_W-1:0]    type_m_axi4_be_qos;
typedef logic [M_AXI4_BE_ID_W-1:0]     type_m_axi4_be_id;

parameter M_AXI4_BE_BURST_FIXED = 2'b00;
parameter M_AXI4_BE_BURST_INCR  = 2'b01;
parameter M_AXI4_BE_BURST_WRAP  = 2'b10;
parameter M_AXI4_BE_BURST_RSVD  = 2'b11;

typedef logic [M_AXI4_BE_BURST_W-1:0] type_m_axi4_be_burst;

parameter M_AXI4_BE_RESP_OKAY   = 2'b00;
parameter M_AXI4_BE_RESP_EXOKAY = 2'b01;
parameter M_AXI4_BE_RESP_SLVERR = 2'b10;
parameter M_AXI4_BE_RESP_DECERR = 2'b11;

typedef logic [M_AXI4_BE_RESP_W-1:0] type_m_axi4_be_resp;

parameter M_AXI4_BE_SIZE_1B   = 3'b000;
parameter M_AXI4_BE_SIZE_2B   = 3'b001;
parameter M_AXI4_BE_SIZE_4B   = 3'b010;
parameter M_AXI4_BE_SIZE_8B   = 3'b011;
parameter M_AXI4_BE_SIZE_16B  = 3'b100;
parameter M_AXI4_BE_SIZE_32B  = 3'b101;
parameter M_AXI4_BE_SIZE_64B  = 3'b110;
parameter M_AXI4_BE_SIZE_128B = 3'b111;

typedef logic [M_AXI4_BE_SIZE_W-1:0] type_m_axi4_be_size;

parameter M_AXI4_BE_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
parameter M_AXI4_BE_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
parameter M_AXI4_BE_CACHE_NO_ALLOCATE                            = 4'B0010;
parameter M_AXI4_BE_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
parameter M_AXI4_BE_CACHE_RESERVED_1                             = 4'B0100;
parameter M_AXI4_BE_CACHE_RESERVED_2                             = 4'B0101;
parameter M_AXI4_BE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
parameter M_AXI4_BE_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
parameter M_AXI4_BE_CACHE_RESERVED_3                             = 4'B1000;
parameter M_AXI4_BE_CACHE_RESERVED_4                             = 4'B1001;
parameter M_AXI4_BE_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
parameter M_AXI4_BE_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
parameter M_AXI4_BE_CACHE_RESERVED_5                             = 4'B1100;
parameter M_AXI4_BE_CACHE_RESERVED_6                             = 4'B1101;
parameter M_AXI4_BE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
parameter M_AXI4_BE_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

typedef logic [M_AXI4_BE_CACHE_W-1:0] type_m_axi4_be_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m_axi4_be_valid rvalid ; // Input Read channel valid
  type_m_axi4_be_last  arready; // Input Read Address read channel ready
  type_m_axi4_be_last  rlast  ; // Input Read channel last word
  type_m_axi4_be_data  rdata  ; // Input Read channel data
  type_m_axi4_be_id    rid    ; // Input Read channel ID
  type_m_axi4_be_resp  rresp  ; // Input Read channel response
} AXI4BEMasterReadInterfaceInput;

typedef struct packed {
  type_m_axi4_be_valid  arvalid ; // Output Read Address read channel valid
  type_m_axi4_be_addr   araddr  ; // Output Read Address read channel address
  type_m_axi4_be_len    arlen   ; // Output Read Address channel burst length
  type_m_axi4_be_ready  rready  ; // Output Read Read channel ready
  type_m_axi4_be_id     arid    ; // Output Read Address read channel ID
  type_m_axi4_be_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_be_burst  arburst ; // Output Read Address read channel burst type
  type_m_axi4_be_lock   arlock  ; // Output Read Address read channel lock type
  type_m_axi4_be_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_be_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_be_qos    arqos   ; // Output Read Address channel quality of service
  type_m_axi4_be_region arregion;
} AXI4BEMasterReadInterfaceOutput;

typedef struct packed {
  AXI4BEMasterReadInterfaceInput  in ;
  AXI4BEMasterReadInterfaceOutput out;
} AXI4BEMasterReadInterface;


typedef struct packed {
  type_m_axi4_be_ready awready; // Input Write Address write channel ready
  type_m_axi4_be_ready wready ; // Input Write channel ready
  type_m_axi4_be_id    bid    ; // Input Write response channel ID
  type_m_axi4_be_resp  bresp  ; // Input Write channel response
  type_m_axi4_be_valid bvalid ; // Input Write response channel valid
} AXI4BEMasterWriteInterfaceInput;

typedef struct packed {
  type_m_axi4_be_valid  awvalid ; // Output Write Address write channel valid
  type_m_axi4_be_id     awid    ; // Output Write Address write channel ID
  type_m_axi4_be_addr   awaddr  ; // Output Write Address write channel address
  type_m_axi4_be_len    awlen   ; // Output Write Address write channel burst length
  type_m_axi4_be_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_be_burst  awburst ; // Output Write Address write channel burst type
  type_m_axi4_be_lock   awlock  ; // Output Write Address write channel lock type
  type_m_axi4_be_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_be_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_be_qos    awqos   ; // Output Write Address write channel quality of service
  type_m_axi4_be_data   wdata   ; // Output Write channel data
  type_m_axi4_be_strb   wstrb   ; // Output Write channel write strobe
  type_m_axi4_be_last   wlast   ; // Output Write channel last word flag
  type_m_axi4_be_valid  wvalid  ; // Output Write channel valid
  type_m_axi4_be_ready  bready  ; // Output Write response channel ready
  type_m_axi4_be_region awregion;
} AXI4BEMasterWriteInterfaceOutput;

typedef struct packed {
  AXI4BEMasterWriteInterfaceInput  in ;
  AXI4BEMasterWriteInterfaceOutput out;
} AXI4BEMasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m_axi4_be_valid rvalid ; // Input Read channel valid
  type_m_axi4_be_last  arready; // Input Read Address read channel ready
  type_m_axi4_be_last  rlast  ; // Input Read channel last word
  type_m_axi4_be_data  rdata  ; // Input Read channel data
  type_m_axi4_be_id    rid    ; // Input Read channel ID
  type_m_axi4_be_resp  rresp  ; // Input Read channel response
} AXI4BESlaveReadInterfaceOutput;

typedef struct packed {
  type_m_axi4_be_valid  arvalid ; // Output Read Address read channel valid
  type_m_axi4_be_addr   araddr  ; // Output Read Address read channel address
  type_m_axi4_be_len    arlen   ; // Output Read Address channel burst length
  type_m_axi4_be_ready  rready  ; // Output Read Read channel ready
  type_m_axi4_be_id     arid    ; // Output Read Address read channel ID
  type_m_axi4_be_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_be_burst  arburst ; // Output Read Address read channel burst type
  type_m_axi4_be_lock   arlock  ; // Output Read Address read channel lock type
  type_m_axi4_be_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_be_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_be_qos    arqos   ; // Output Read Address channel quality of service
  type_m_axi4_be_region arregion;
} AXI4BESlaveReadInterfaceInput;

typedef struct packed {
  AXI4BESlaveReadInterfaceInput  in ;
  AXI4BESlaveReadInterfaceOutput out;
} AXI4BESlaveReadInterface;


typedef struct packed {
  type_m_axi4_be_ready awready; // Input Write Address write channel ready
  type_m_axi4_be_ready wready ; // Input Write channel ready
  type_m_axi4_be_id    bid    ; // Input Write response channel ID
  type_m_axi4_be_resp  bresp  ; // Input Write channel response
  type_m_axi4_be_valid bvalid ; // Input Write response channel valid
} AXI4BESlaveWriteInterfaceOutput;

typedef struct packed {
  type_m_axi4_be_valid  awvalid ; // Output Write Address write channel valid
  type_m_axi4_be_id     awid    ; // Output Write Address write channel ID
  type_m_axi4_be_addr   awaddr  ; // Output Write Address write channel address
  type_m_axi4_be_len    awlen   ; // Output Write Address write channel burst length
  type_m_axi4_be_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_be_burst  awburst ; // Output Write Address write channel burst type
  type_m_axi4_be_lock   awlock  ; // Output Write Address write channel lock type
  type_m_axi4_be_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_be_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_be_qos    awqos   ; // Output Write Address write channel quality of service
  type_m_axi4_be_data   wdata   ; // Output Write channel data
  type_m_axi4_be_strb   wstrb   ; // Output Write channel write strobe
  type_m_axi4_be_last   wlast   ; // Output Write channel last word flag
  type_m_axi4_be_valid  wvalid  ; // Output Write channel valid
  type_m_axi4_be_ready  bready  ; // Output Write response channel ready
  type_m_axi4_be_region awregion;
} AXI4BESlaveWriteInterfaceInput;

typedef struct packed {
  AXI4BESlaveWriteInterfaceInput  in ;
  AXI4BESlaveWriteInterfaceOutput out;
} AXI4BESlaveWriteInterface;


function logic [M_AXI4_BE_DATA_W-1:0] swap_endianness_cacheline_axi_be (logic [M_AXI4_BE_DATA_W-1:0] in, logic mode);

  logic [M_AXI4_BE_DATA_W-1:0] out;

  integer i;

  if(mode == 1) begin
    for ( i = 0; i < M_AXI4_BE_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M_AXI4_BE_DATA_W-1)-(i*8)) -:8];
    end
  end else begin
    out = in;
  end

  return out;
endfunction : swap_endianness_cacheline_axi_be

endpackage
