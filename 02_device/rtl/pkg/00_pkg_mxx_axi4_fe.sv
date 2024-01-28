
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_MXX_AXI4_FE.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_timescale.vh"
`include "typedef.svh"
package PKG_MXX_AXI4_FE;

parameter S_AXI_FE_ADDR_WIDTH_BITS = 12;
parameter S_AXI_FE_DATA_WIDTH      = 32;

  

parameter M00_AXI4_FE_ADDR_W   = 32                 ;
parameter M00_AXI4_FE_DATA_W   = 32                 ;
parameter M00_AXI4_FE_STRB_W   = M00_AXI4_FE_DATA_W / 8;
parameter M00_AXI4_FE_BURST_W  = 2                   ;
parameter M00_AXI4_FE_CACHE_W  = 4                   ;
parameter M00_AXI4_FE_PROT_W   = 3                   ;
parameter M00_AXI4_FE_REGION_W = 4                   ;
parameter M00_AXI4_FE_USER_W   = 4                   ;
parameter M00_AXI4_FE_LOCK_W   = 1                   ;
parameter M00_AXI4_FE_QOS_W    = 4                   ;
parameter M00_AXI4_FE_LEN_W    = 8                   ;
parameter M00_AXI4_FE_SIZE_W   = 3                   ;
parameter M00_AXI4_FE_RESP_W   = 2                   ;
parameter M00_AXI4_FE_ID_W     = 1                   ;

typedef logic                          type_m00_axi4_fe_valid;
typedef logic                          type_m00_axi4_fe_ready;
typedef logic                          type_m00_axi4_fe_last;
typedef logic [M00_AXI4_FE_ADDR_W-1:0]   type_m00_axi4_fe_addr;
typedef logic [M00_AXI4_FE_DATA_W-1:0]   type_m00_axi4_fe_data;
typedef logic [M00_AXI4_FE_STRB_W-1:0]   type_m00_axi4_fe_strb;
typedef logic [M00_AXI4_FE_LEN_W-1:0]    type_m00_axi4_fe_len;
typedef logic [M00_AXI4_FE_LOCK_W-1:0]   type_m00_axi4_fe_lock;
typedef logic [M00_AXI4_FE_PROT_W-1:0]   type_m00_axi4_fe_prot;
typedef logic [M00_AXI4_FE_REGION_W-1:0] type_m00_axi4_fe_region;
typedef logic [M00_AXI4_FE_QOS_W-1:0]    type_m00_axi4_fe_qos;
typedef logic [M00_AXI4_FE_ID_W-1:0]     type_m00_axi4_fe_id;
typedef logic [M00_AXI4_FE_USER_W-1:0]   type_m00_axi4_fe_user;

parameter M00_AXI4_FE_BURST_FIXED = 2'b00;
parameter M00_AXI4_FE_BURST_INCR  = 2'b01;
parameter M00_AXI4_FE_BURST_WRAP  = 2'b10;
parameter M00_AXI4_FE_BURST_RSVD  = 2'b11;

typedef logic [M00_AXI4_FE_BURST_W-1:0] type_m00_axi4_fe_burst;

parameter M00_AXI4_FE_RESP_OKAY   = 2'b00;
parameter M00_AXI4_FE_RESP_EXOKAY = 2'b01;
parameter M00_AXI4_FE_RESP_SLVERR = 2'b10;
parameter M00_AXI4_FE_RESP_DECERR = 2'b11;

typedef logic [M00_AXI4_FE_RESP_W-1:0] type_m00_axi4_fe_resp;

parameter M00_AXI4_FE_SIZE_1B   = 3'b000;
parameter M00_AXI4_FE_SIZE_2B   = 3'b001;
parameter M00_AXI4_FE_SIZE_4B   = 3'b010;
parameter M00_AXI4_FE_SIZE_8B   = 3'b011;
parameter M00_AXI4_FE_SIZE_16B  = 3'b100;
parameter M00_AXI4_FE_SIZE_32B  = 3'b101;
parameter M00_AXI4_FE_SIZE_64B  = 3'b110;
parameter M00_AXI4_FE_SIZE_128B = 3'b111;

typedef logic [M00_AXI4_FE_SIZE_W-1:0] type_m00_axi4_fe_size;

parameter M00_AXI4_FE_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
parameter M00_AXI4_FE_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
parameter M00_AXI4_FE_CACHE_NO_ALLOCATE                            = 4'B0010;
parameter M00_AXI4_FE_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
parameter M00_AXI4_FE_CACHE_RESERVED_1                             = 4'B0100;
parameter M00_AXI4_FE_CACHE_RESERVED_2                             = 4'B0101;
parameter M00_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
parameter M00_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
parameter M00_AXI4_FE_CACHE_RESERVED_3                             = 4'B1000;
parameter M00_AXI4_FE_CACHE_RESERVED_4                             = 4'B1001;
parameter M00_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
parameter M00_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
parameter M00_AXI4_FE_CACHE_RESERVED_5                             = 4'B1100;
parameter M00_AXI4_FE_CACHE_RESERVED_6                             = 4'B1101;
parameter M00_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
parameter M00_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

typedef logic [M00_AXI4_FE_CACHE_W-1:0] type_m00_axi4_fe_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m00_axi4_fe_valid rvalid ; // Input Read channel valid
  type_m00_axi4_fe_last  arready; // Input Read Address read channel ready
  type_m00_axi4_fe_last  rlast  ; // Input Read channel last word
  type_m00_axi4_fe_data  rdata  ; // Input Read channel data
  type_m00_axi4_fe_id    rid    ; // Input Read channel ID
  type_m00_axi4_fe_resp  rresp  ; // Input Read channel response
} M00_AXI4_FE_MasterReadInterfaceInput;

typedef struct packed {
  type_m00_axi4_fe_valid  arvalid ; // Output Read Address read channel valid
  type_m00_axi4_fe_addr   araddr  ; // Output Read Address read channel address
  type_m00_axi4_fe_len    arlen   ; // Output Read Address channel burst length
  type_m00_axi4_fe_ready  rready  ; // Output Read Read channel ready
  type_m00_axi4_fe_id     arid    ; // Output Read Address read channel ID
  type_m00_axi4_fe_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m00_axi4_fe_burst  arburst ; // Output Read Address read channel burst type
  type_m00_axi4_fe_lock   arlock  ; // Output Read Address read channel lock type
  type_m00_axi4_fe_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m00_axi4_fe_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m00_axi4_fe_qos    arqos   ; // Output Read Address channel quality of service
  type_m00_axi4_fe_region arregion;
} M00_AXI4_FE_MasterReadInterfaceOutput;

typedef struct packed {
  M00_AXI4_FE_MasterReadInterfaceInput  in ;
  M00_AXI4_FE_MasterReadInterfaceOutput out;
} M00_AXI4_FE_MasterReadInterface;


typedef struct packed {
  type_m00_axi4_fe_ready awready; // Input Write Address write channel ready
  type_m00_axi4_fe_ready wready ; // Input Write channel ready
  type_m00_axi4_fe_id    bid    ; // Input Write response channel ID
  type_m00_axi4_fe_resp  bresp  ; // Input Write channel response
  type_m00_axi4_fe_valid bvalid ; // Input Write response channel valid
} M00_AXI4_FE_MasterWriteInterfaceInput;

typedef struct packed {
  type_m00_axi4_fe_valid  awvalid ; // Output Write Address write channel valid
  type_m00_axi4_fe_id     awid    ; // Output Write Address write channel ID
  type_m00_axi4_fe_addr   awaddr  ; // Output Write Address write channel address
  type_m00_axi4_fe_len    awlen   ; // Output Write Address write channel burst length
  type_m00_axi4_fe_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m00_axi4_fe_burst  awburst ; // Output Write Address write channel burst type
  type_m00_axi4_fe_lock   awlock  ; // Output Write Address write channel lock type
  type_m00_axi4_fe_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m00_axi4_fe_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m00_axi4_fe_qos    awqos   ; // Output Write Address write channel quality of service
  type_m00_axi4_fe_data   wdata   ; // Output Write channel data
  type_m00_axi4_fe_strb   wstrb   ; // Output Write channel write strobe
  type_m00_axi4_fe_last   wlast   ; // Output Write channel last word flag
  type_m00_axi4_fe_valid  wvalid  ; // Output Write channel valid
  type_m00_axi4_fe_ready  bready  ; // Output Write response channel ready
  type_m00_axi4_fe_region awregion;
} M00_AXI4_FE_MasterWriteInterfaceOutput;

typedef struct packed {
  M00_AXI4_FE_MasterWriteInterfaceInput  in ;
  M00_AXI4_FE_MasterWriteInterfaceOutput out;
} M00_AXI4_FE_MasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m00_axi4_fe_valid rvalid ; // Input Read channel valid
  type_m00_axi4_fe_last  arready; // Input Read Address read channel ready
  type_m00_axi4_fe_last  rlast  ; // Input Read channel last word
  type_m00_axi4_fe_data  rdata  ; // Input Read channel data
  type_m00_axi4_fe_id    rid    ; // Input Read channel ID
  type_m00_axi4_fe_resp  rresp  ; // Input Read channel response
} M00_AXI4_FE_SlaveReadInterfaceOutput;

typedef struct packed {
  type_m00_axi4_fe_valid  arvalid ; // Output Read Address read channel valid
  type_m00_axi4_fe_addr   araddr  ; // Output Read Address read channel address
  type_m00_axi4_fe_len    arlen   ; // Output Read Address channel burst length
  type_m00_axi4_fe_ready  rready  ; // Output Read Read channel ready
  type_m00_axi4_fe_id     arid    ; // Output Read Address read channel ID
  type_m00_axi4_fe_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m00_axi4_fe_burst  arburst ; // Output Read Address read channel burst type
  type_m00_axi4_fe_lock   arlock  ; // Output Read Address read channel lock type
  type_m00_axi4_fe_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m00_axi4_fe_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m00_axi4_fe_qos    arqos   ; // Output Read Address channel quality of service
  type_m00_axi4_fe_region arregion;
} M00_AXI4_FE_SlaveReadInterfaceInput;

typedef struct packed {
  M00_AXI4_FE_SlaveReadInterfaceInput  in ;
  M00_AXI4_FE_SlaveReadInterfaceOutput out;
} M00_AXI4_FE_SlaveReadInterface;


typedef struct packed {
  type_m00_axi4_fe_ready awready; // Input Write Address write channel ready
  type_m00_axi4_fe_ready wready ; // Input Write channel ready
  type_m00_axi4_fe_id    bid    ; // Input Write response channel ID
  type_m00_axi4_fe_resp  bresp  ; // Input Write channel response
  type_m00_axi4_fe_valid bvalid ; // Input Write response channel valid
} M00_AXI4_FE_SlaveWriteInterfaceOutput;

typedef struct packed {
  type_m00_axi4_fe_valid  awvalid ; // Output Write Address write channel valid
  type_m00_axi4_fe_id     awid    ; // Output Write Address write channel ID
  type_m00_axi4_fe_addr   awaddr  ; // Output Write Address write channel address
  type_m00_axi4_fe_len    awlen   ; // Output Write Address write channel burst length
  type_m00_axi4_fe_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m00_axi4_fe_burst  awburst ; // Output Write Address write channel burst type
  type_m00_axi4_fe_lock   awlock  ; // Output Write Address write channel lock type
  type_m00_axi4_fe_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m00_axi4_fe_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m00_axi4_fe_qos    awqos   ; // Output Write Address write channel quality of service
  type_m00_axi4_fe_data   wdata   ; // Output Write channel data
  type_m00_axi4_fe_strb   wstrb   ; // Output Write channel write strobe
  type_m00_axi4_fe_last   wlast   ; // Output Write channel last word flag
  type_m00_axi4_fe_valid  wvalid  ; // Output Write channel valid
  type_m00_axi4_fe_ready  bready  ; // Output Write response channel ready
  type_m00_axi4_fe_region awregion;
} M00_AXI4_FE_SlaveWriteInterfaceInput;

typedef struct packed {
  M00_AXI4_FE_SlaveWriteInterfaceInput  in ;
  M00_AXI4_FE_SlaveWriteInterfaceOutput out;
} M00_AXI4_FE_SlaveWriteInterface;


function logic [M00_AXI4_FE_DATA_W-1:0] swap_endianness_cacheline_m00_axi_fe (logic [M00_AXI4_FE_DATA_W-1:0] in, logic mode);

  logic [M00_AXI4_FE_DATA_W-1:0] out;

  integer i;

  if(mode == 1) begin
    for ( i = 0; i < M00_AXI4_FE_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M00_AXI4_FE_DATA_W-1)-(i*8)) -:8];
    end
  end else begin
    out = in;
  end

  return out;
endfunction : swap_endianness_cacheline_m00_axi_fe

  


// --------------------------------------------------------------------------------------
// AXI4 Lite 
// --------------------------------------------------------------------------------------

`AXI_TYPEDEF_ALL(m00_axi, type_m00_axi4_fe_addr, type_m00_axi4_fe_id, type_m00_axi4_fe_data, type_m00_axi4_fe_strb, type_m00_axi4_fe_user)
typedef m00_axi_req_t M00_AXI4_FE_REQ_T;
typedef m00_axi_resp_t M00_AXI4_FE_RESP_T;

parameter M00_AXI4_LITE_FE_ADDR_W   = 17                 ;
parameter M00_AXI4_LITE_FE_DATA_W   = 64                 ;
parameter M00_AXI4_LITE_FE_STRB_W   = M00_AXI4_LITE_FE_DATA_W / 8;
parameter M00_AXI4_LITE_FE_ID_W     = 1                   ;
typedef logic [M00_AXI4_LITE_FE_ADDR_W-1:0]   type_m00_axi4_lite_fe_addr;
typedef logic [M00_AXI4_LITE_FE_DATA_W-1:0]   type_m00_axi4_lite_fe_data;
typedef logic [M00_AXI4_LITE_FE_STRB_W-1:0]   type_m00_axi4_lite_fe_strb;

`AXI_LITE_TYPEDEF_ALL(m00_axi_lite, type_m00_axi4_lite_fe_addr, type_m00_axi4_lite_fe_data, type_m00_axi4_lite_fe_strb)
typedef m00_axi_lite_req_t  M00_AXI4_LITE_FE_REQ_T;
typedef m00_axi_lite_resp_t M00_AXI4_LITE_FE_RESP_T;
typedef m00_axi_lite_req_t  S00_AXI4_LITE_FE_REQ_T;
typedef m00_axi_lite_resp_t S00_AXI4_LITE_FE_RESP_T;

  

parameter M01_AXI4_FE_ADDR_W   = 32                 ;
parameter M01_AXI4_FE_DATA_W   = 32                 ;
parameter M01_AXI4_FE_STRB_W   = M01_AXI4_FE_DATA_W / 8;
parameter M01_AXI4_FE_BURST_W  = 2                   ;
parameter M01_AXI4_FE_CACHE_W  = 4                   ;
parameter M01_AXI4_FE_PROT_W   = 3                   ;
parameter M01_AXI4_FE_REGION_W = 4                   ;
parameter M01_AXI4_FE_USER_W   = 4                   ;
parameter M01_AXI4_FE_LOCK_W   = 1                   ;
parameter M01_AXI4_FE_QOS_W    = 4                   ;
parameter M01_AXI4_FE_LEN_W    = 8                   ;
parameter M01_AXI4_FE_SIZE_W   = 3                   ;
parameter M01_AXI4_FE_RESP_W   = 2                   ;
parameter M01_AXI4_FE_ID_W     = 1                   ;

typedef logic                          type_m01_axi4_fe_valid;
typedef logic                          type_m01_axi4_fe_ready;
typedef logic                          type_m01_axi4_fe_last;
typedef logic [M01_AXI4_FE_ADDR_W-1:0]   type_m01_axi4_fe_addr;
typedef logic [M01_AXI4_FE_DATA_W-1:0]   type_m01_axi4_fe_data;
typedef logic [M01_AXI4_FE_STRB_W-1:0]   type_m01_axi4_fe_strb;
typedef logic [M01_AXI4_FE_LEN_W-1:0]    type_m01_axi4_fe_len;
typedef logic [M01_AXI4_FE_LOCK_W-1:0]   type_m01_axi4_fe_lock;
typedef logic [M01_AXI4_FE_PROT_W-1:0]   type_m01_axi4_fe_prot;
typedef logic [M01_AXI4_FE_REGION_W-1:0] type_m01_axi4_fe_region;
typedef logic [M01_AXI4_FE_QOS_W-1:0]    type_m01_axi4_fe_qos;
typedef logic [M01_AXI4_FE_ID_W-1:0]     type_m01_axi4_fe_id;
typedef logic [M01_AXI4_FE_USER_W-1:0]   type_m01_axi4_fe_user;

parameter M01_AXI4_FE_BURST_FIXED = 2'b00;
parameter M01_AXI4_FE_BURST_INCR  = 2'b01;
parameter M01_AXI4_FE_BURST_WRAP  = 2'b10;
parameter M01_AXI4_FE_BURST_RSVD  = 2'b11;

typedef logic [M01_AXI4_FE_BURST_W-1:0] type_m01_axi4_fe_burst;

parameter M01_AXI4_FE_RESP_OKAY   = 2'b00;
parameter M01_AXI4_FE_RESP_EXOKAY = 2'b01;
parameter M01_AXI4_FE_RESP_SLVERR = 2'b10;
parameter M01_AXI4_FE_RESP_DECERR = 2'b11;

typedef logic [M01_AXI4_FE_RESP_W-1:0] type_m01_axi4_fe_resp;

parameter M01_AXI4_FE_SIZE_1B   = 3'b000;
parameter M01_AXI4_FE_SIZE_2B   = 3'b001;
parameter M01_AXI4_FE_SIZE_4B   = 3'b010;
parameter M01_AXI4_FE_SIZE_8B   = 3'b011;
parameter M01_AXI4_FE_SIZE_16B  = 3'b100;
parameter M01_AXI4_FE_SIZE_32B  = 3'b101;
parameter M01_AXI4_FE_SIZE_64B  = 3'b110;
parameter M01_AXI4_FE_SIZE_128B = 3'b111;

typedef logic [M01_AXI4_FE_SIZE_W-1:0] type_m01_axi4_fe_size;

parameter M01_AXI4_FE_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
parameter M01_AXI4_FE_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
parameter M01_AXI4_FE_CACHE_NO_ALLOCATE                            = 4'B0010;
parameter M01_AXI4_FE_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
parameter M01_AXI4_FE_CACHE_RESERVED_1                             = 4'B0100;
parameter M01_AXI4_FE_CACHE_RESERVED_2                             = 4'B0101;
parameter M01_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
parameter M01_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
parameter M01_AXI4_FE_CACHE_RESERVED_3                             = 4'B1000;
parameter M01_AXI4_FE_CACHE_RESERVED_4                             = 4'B1001;
parameter M01_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
parameter M01_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
parameter M01_AXI4_FE_CACHE_RESERVED_5                             = 4'B1100;
parameter M01_AXI4_FE_CACHE_RESERVED_6                             = 4'B1101;
parameter M01_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
parameter M01_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

typedef logic [M01_AXI4_FE_CACHE_W-1:0] type_m01_axi4_fe_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m01_axi4_fe_valid rvalid ; // Input Read channel valid
  type_m01_axi4_fe_last  arready; // Input Read Address read channel ready
  type_m01_axi4_fe_last  rlast  ; // Input Read channel last word
  type_m01_axi4_fe_data  rdata  ; // Input Read channel data
  type_m01_axi4_fe_id    rid    ; // Input Read channel ID
  type_m01_axi4_fe_resp  rresp  ; // Input Read channel response
} M01_AXI4_FE_MasterReadInterfaceInput;

typedef struct packed {
  type_m01_axi4_fe_valid  arvalid ; // Output Read Address read channel valid
  type_m01_axi4_fe_addr   araddr  ; // Output Read Address read channel address
  type_m01_axi4_fe_len    arlen   ; // Output Read Address channel burst length
  type_m01_axi4_fe_ready  rready  ; // Output Read Read channel ready
  type_m01_axi4_fe_id     arid    ; // Output Read Address read channel ID
  type_m01_axi4_fe_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m01_axi4_fe_burst  arburst ; // Output Read Address read channel burst type
  type_m01_axi4_fe_lock   arlock  ; // Output Read Address read channel lock type
  type_m01_axi4_fe_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m01_axi4_fe_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m01_axi4_fe_qos    arqos   ; // Output Read Address channel quality of service
  type_m01_axi4_fe_region arregion;
} M01_AXI4_FE_MasterReadInterfaceOutput;

typedef struct packed {
  M01_AXI4_FE_MasterReadInterfaceInput  in ;
  M01_AXI4_FE_MasterReadInterfaceOutput out;
} M01_AXI4_FE_MasterReadInterface;


typedef struct packed {
  type_m01_axi4_fe_ready awready; // Input Write Address write channel ready
  type_m01_axi4_fe_ready wready ; // Input Write channel ready
  type_m01_axi4_fe_id    bid    ; // Input Write response channel ID
  type_m01_axi4_fe_resp  bresp  ; // Input Write channel response
  type_m01_axi4_fe_valid bvalid ; // Input Write response channel valid
} M01_AXI4_FE_MasterWriteInterfaceInput;

typedef struct packed {
  type_m01_axi4_fe_valid  awvalid ; // Output Write Address write channel valid
  type_m01_axi4_fe_id     awid    ; // Output Write Address write channel ID
  type_m01_axi4_fe_addr   awaddr  ; // Output Write Address write channel address
  type_m01_axi4_fe_len    awlen   ; // Output Write Address write channel burst length
  type_m01_axi4_fe_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m01_axi4_fe_burst  awburst ; // Output Write Address write channel burst type
  type_m01_axi4_fe_lock   awlock  ; // Output Write Address write channel lock type
  type_m01_axi4_fe_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m01_axi4_fe_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m01_axi4_fe_qos    awqos   ; // Output Write Address write channel quality of service
  type_m01_axi4_fe_data   wdata   ; // Output Write channel data
  type_m01_axi4_fe_strb   wstrb   ; // Output Write channel write strobe
  type_m01_axi4_fe_last   wlast   ; // Output Write channel last word flag
  type_m01_axi4_fe_valid  wvalid  ; // Output Write channel valid
  type_m01_axi4_fe_ready  bready  ; // Output Write response channel ready
  type_m01_axi4_fe_region awregion;
} M01_AXI4_FE_MasterWriteInterfaceOutput;

typedef struct packed {
  M01_AXI4_FE_MasterWriteInterfaceInput  in ;
  M01_AXI4_FE_MasterWriteInterfaceOutput out;
} M01_AXI4_FE_MasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m01_axi4_fe_valid rvalid ; // Input Read channel valid
  type_m01_axi4_fe_last  arready; // Input Read Address read channel ready
  type_m01_axi4_fe_last  rlast  ; // Input Read channel last word
  type_m01_axi4_fe_data  rdata  ; // Input Read channel data
  type_m01_axi4_fe_id    rid    ; // Input Read channel ID
  type_m01_axi4_fe_resp  rresp  ; // Input Read channel response
} M01_AXI4_FE_SlaveReadInterfaceOutput;

typedef struct packed {
  type_m01_axi4_fe_valid  arvalid ; // Output Read Address read channel valid
  type_m01_axi4_fe_addr   araddr  ; // Output Read Address read channel address
  type_m01_axi4_fe_len    arlen   ; // Output Read Address channel burst length
  type_m01_axi4_fe_ready  rready  ; // Output Read Read channel ready
  type_m01_axi4_fe_id     arid    ; // Output Read Address read channel ID
  type_m01_axi4_fe_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m01_axi4_fe_burst  arburst ; // Output Read Address read channel burst type
  type_m01_axi4_fe_lock   arlock  ; // Output Read Address read channel lock type
  type_m01_axi4_fe_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m01_axi4_fe_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m01_axi4_fe_qos    arqos   ; // Output Read Address channel quality of service
  type_m01_axi4_fe_region arregion;
} M01_AXI4_FE_SlaveReadInterfaceInput;

typedef struct packed {
  M01_AXI4_FE_SlaveReadInterfaceInput  in ;
  M01_AXI4_FE_SlaveReadInterfaceOutput out;
} M01_AXI4_FE_SlaveReadInterface;


typedef struct packed {
  type_m01_axi4_fe_ready awready; // Input Write Address write channel ready
  type_m01_axi4_fe_ready wready ; // Input Write channel ready
  type_m01_axi4_fe_id    bid    ; // Input Write response channel ID
  type_m01_axi4_fe_resp  bresp  ; // Input Write channel response
  type_m01_axi4_fe_valid bvalid ; // Input Write response channel valid
} M01_AXI4_FE_SlaveWriteInterfaceOutput;

typedef struct packed {
  type_m01_axi4_fe_valid  awvalid ; // Output Write Address write channel valid
  type_m01_axi4_fe_id     awid    ; // Output Write Address write channel ID
  type_m01_axi4_fe_addr   awaddr  ; // Output Write Address write channel address
  type_m01_axi4_fe_len    awlen   ; // Output Write Address write channel burst length
  type_m01_axi4_fe_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m01_axi4_fe_burst  awburst ; // Output Write Address write channel burst type
  type_m01_axi4_fe_lock   awlock  ; // Output Write Address write channel lock type
  type_m01_axi4_fe_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m01_axi4_fe_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m01_axi4_fe_qos    awqos   ; // Output Write Address write channel quality of service
  type_m01_axi4_fe_data   wdata   ; // Output Write channel data
  type_m01_axi4_fe_strb   wstrb   ; // Output Write channel write strobe
  type_m01_axi4_fe_last   wlast   ; // Output Write channel last word flag
  type_m01_axi4_fe_valid  wvalid  ; // Output Write channel valid
  type_m01_axi4_fe_ready  bready  ; // Output Write response channel ready
  type_m01_axi4_fe_region awregion;
} M01_AXI4_FE_SlaveWriteInterfaceInput;

typedef struct packed {
  M01_AXI4_FE_SlaveWriteInterfaceInput  in ;
  M01_AXI4_FE_SlaveWriteInterfaceOutput out;
} M01_AXI4_FE_SlaveWriteInterface;


function logic [M01_AXI4_FE_DATA_W-1:0] swap_endianness_cacheline_m01_axi_fe (logic [M01_AXI4_FE_DATA_W-1:0] in, logic mode);

  logic [M01_AXI4_FE_DATA_W-1:0] out;

  integer i;

  if(mode == 1) begin
    for ( i = 0; i < M01_AXI4_FE_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M01_AXI4_FE_DATA_W-1)-(i*8)) -:8];
    end
  end else begin
    out = in;
  end

  return out;
endfunction : swap_endianness_cacheline_m01_axi_fe

  


// --------------------------------------------------------------------------------------
// AXI4 Lite 
// --------------------------------------------------------------------------------------

`AXI_TYPEDEF_ALL(m01_axi, type_m01_axi4_fe_addr, type_m01_axi4_fe_id, type_m01_axi4_fe_data, type_m01_axi4_fe_strb, type_m01_axi4_fe_user)
typedef m01_axi_req_t M01_AXI4_FE_REQ_T;
typedef m01_axi_resp_t M01_AXI4_FE_RESP_T;

parameter M01_AXI4_LITE_FE_ADDR_W   = 17                 ;
parameter M01_AXI4_LITE_FE_DATA_W   = 64                 ;
parameter M01_AXI4_LITE_FE_STRB_W   = M01_AXI4_LITE_FE_DATA_W / 8;
parameter M01_AXI4_LITE_FE_ID_W     = 1                   ;
typedef logic [M01_AXI4_LITE_FE_ADDR_W-1:0]   type_m01_axi4_lite_fe_addr;
typedef logic [M01_AXI4_LITE_FE_DATA_W-1:0]   type_m01_axi4_lite_fe_data;
typedef logic [M01_AXI4_LITE_FE_STRB_W-1:0]   type_m01_axi4_lite_fe_strb;

`AXI_LITE_TYPEDEF_ALL(m01_axi_lite, type_m01_axi4_lite_fe_addr, type_m01_axi4_lite_fe_data, type_m01_axi4_lite_fe_strb)
typedef m01_axi_lite_req_t  M01_AXI4_LITE_FE_REQ_T;
typedef m01_axi_lite_resp_t M01_AXI4_LITE_FE_RESP_T;
typedef m01_axi_lite_req_t  S01_AXI4_LITE_FE_REQ_T;
typedef m01_axi_lite_resp_t S01_AXI4_LITE_FE_RESP_T;

  

endpackage
  