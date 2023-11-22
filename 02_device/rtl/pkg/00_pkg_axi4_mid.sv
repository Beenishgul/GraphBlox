// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_AXI4_BE.sv
// Create : 2022-11-28 16:08:34
// Revise : 2022-11-28 16:08:34
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_timescale.vh"
package PKG_AXI4_MID;

parameter S_AXI_MID_ADDR_WIDTH_BITS = 12;
parameter S_AXI_MID_DATA_WIDTH      = 32;

parameter M_AXI4_MID_ADDR_W   = 64                   ;
parameter M_AXI4_MID_DATA_W   = 32                   ;
parameter M_AXI4_MID_STRB_W   = M_AXI4_MID_DATA_W / 8;
parameter M_AXI4_MID_BURST_W  = 2                    ;
parameter M_AXI4_MID_CACHE_W  = 4                    ;
parameter M_AXI4_MID_PROT_W   = 3                    ;
parameter M_AXI4_MID_REGION_W = 4                    ;
parameter M_AXI4_MID_USER_W   = 4                    ;
parameter M_AXI4_MID_LOCK_W   = 1                    ;
parameter M_AXI4_MID_QOS_W    = 4                    ;
parameter M_AXI4_MID_LEN_W    = 8                    ;
parameter M_AXI4_MID_SIZE_W   = 3                    ;
parameter M_AXI4_MID_RESP_W   = 2                    ;
parameter M_AXI4_MID_ID_W     = 1                    ;

typedef logic                           type_m_axi4_mid_valid;
typedef logic                           type_m_axi4_mid_ready;
typedef logic                           type_m_axi4_mid_last;
typedef logic [M_AXI4_MID_ADDR_W-1:0]   type_m_axi4_mid_addr;
typedef logic [M_AXI4_MID_DATA_W-1:0]   type_m_axi4_mid_data;
typedef logic [M_AXI4_MID_STRB_W-1:0]   type_m_axi4_mid_strb;
typedef logic [M_AXI4_MID_LEN_W-1:0]    type_m_axi4_mid_len;
typedef logic [M_AXI4_MID_LOCK_W-1:0]   type_m_axi4_mid_lock;
typedef logic [M_AXI4_MID_PROT_W-1:0]   type_m_axi4_mid_prot;
typedef logic [M_AXI4_MID_REGION_W-1:0] type_m_axi4_mid_region;
typedef logic [M_AXI4_MID_QOS_W-1:0]    type_m_axi4_mid_qos;
typedef logic [M_AXI4_MID_ID_W-1:0]     type_m_axi4_mid_id;

parameter M_AXI4_MID_BURST_FIXED = 2'b00;
parameter M_AXI4_MID_BURST_INCR  = 2'b01;
parameter M_AXI4_MID_BURST_WRAP  = 2'b10;
parameter M_AXI4_MID_BURST_RSVD  = 2'b11;

typedef logic [M_AXI4_MID_BURST_W-1:0] type_m_axi4_mid_burst;

parameter M_AXI4_MID_RESP_OKAY   = 2'b00;
parameter M_AXI4_MID_RESP_EXOKAY = 2'b01;
parameter M_AXI4_MID_RESP_SLVERR = 2'b10;
parameter M_AXI4_MID_RESP_DECERR = 2'b11;

typedef logic [M_AXI4_MID_RESP_W-1:0] type_m_axi4_mid_resp;

parameter M_AXI4_MID_SIZE_1B   = 3'b000;
parameter M_AXI4_MID_SIZE_2B   = 3'b001;
parameter M_AXI4_MID_SIZE_4B   = 3'b010;
parameter M_AXI4_MID_SIZE_8B   = 3'b011;
parameter M_AXI4_MID_SIZE_16B  = 3'b100;
parameter M_AXI4_MID_SIZE_32B  = 3'b101;
parameter M_AXI4_MID_SIZE_64B  = 3'b110;
parameter M_AXI4_MID_SIZE_128B = 3'b111;

typedef logic [M_AXI4_MID_SIZE_W-1:0] type_m_axi4_mid_size;

parameter M_AXI4_MID_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
parameter M_AXI4_MID_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
parameter M_AXI4_MID_CACHE_NO_ALLOCATE                            = 4'B0010;
parameter M_AXI4_MID_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
parameter M_AXI4_MID_CACHE_RESERVED_1                             = 4'B0100;
parameter M_AXI4_MID_CACHE_RESERVED_2                             = 4'B0101;
parameter M_AXI4_MID_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
parameter M_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
parameter M_AXI4_MID_CACHE_RESERVED_3                             = 4'B1000;
parameter M_AXI4_MID_CACHE_RESERVED_4                             = 4'B1001;
parameter M_AXI4_MID_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
parameter M_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
parameter M_AXI4_MID_CACHE_RESERVED_5                             = 4'B1100;
parameter M_AXI4_MID_CACHE_RESERVED_6                             = 4'B1101;
parameter M_AXI4_MID_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
parameter M_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

typedef logic [M_AXI4_MID_CACHE_W-1:0] type_m_axi4_mid_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m_axi4_mid_valid rvalid ; // Input Read channel valid
  type_m_axi4_mid_last  arready; // Input Read Address read channel ready
  type_m_axi4_mid_last  rlast  ; // Input Read channel last word
  type_m_axi4_mid_data  rdata  ; // Input Read channel data
  type_m_axi4_mid_id    rid    ; // Input Read channel ID
  type_m_axi4_mid_resp  rresp  ; // Input Read channel response
} AXI4MIDMasterReadInterfaceInput;

typedef struct packed {
  type_m_axi4_mid_valid  arvalid ; // Output Read Address read channel valid
  type_m_axi4_mid_addr   araddr  ; // Output Read Address read channel address
  type_m_axi4_mid_len    arlen   ; // Output Read Address channel burst length
  type_m_axi4_mid_ready  rready  ; // Output Read Read channel ready
  type_m_axi4_mid_id     arid    ; // Output Read Address read channel ID
  type_m_axi4_mid_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_mid_burst  arburst ; // Output Read Address read channel burst type
  type_m_axi4_mid_lock   arlock  ; // Output Read Address read channel lock type
  type_m_axi4_mid_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_mid_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_mid_qos    arqos   ; // Output Read Address channel quality of service
  type_m_axi4_mid_region arregion;
} AXI4MIDMasterReadInterfaceOutput;

typedef struct packed {
  AXI4MIDMasterReadInterfaceInput  in ;
  AXI4MIDMasterReadInterfaceOutput out;
} AXI4MIDMasterReadInterface;


typedef struct packed {
  type_m_axi4_mid_ready awready; // Input Write Address write channel ready
  type_m_axi4_mid_ready wready ; // Input Write channel ready
  type_m_axi4_mid_id    bid    ; // Input Write response channel ID
  type_m_axi4_mid_resp  bresp  ; // Input Write channel response
  type_m_axi4_mid_valid bvalid ; // Input Write response channel valid
} AXI4MIDMasterWriteInterfaceInput;

typedef struct packed {
  type_m_axi4_mid_valid  awvalid ; // Output Write Address write channel valid
  type_m_axi4_mid_id     awid    ; // Output Write Address write channel ID
  type_m_axi4_mid_addr   awaddr  ; // Output Write Address write channel address
  type_m_axi4_mid_len    awlen   ; // Output Write Address write channel burst length
  type_m_axi4_mid_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_mid_burst  awburst ; // Output Write Address write channel burst type
  type_m_axi4_mid_lock   awlock  ; // Output Write Address write channel lock type
  type_m_axi4_mid_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_mid_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_mid_qos    awqos   ; // Output Write Address write channel quality of service
  type_m_axi4_mid_data   wdata   ; // Output Write channel data
  type_m_axi4_mid_strb   wstrb   ; // Output Write channel write strobe
  type_m_axi4_mid_last   wlast   ; // Output Write channel last word flag
  type_m_axi4_mid_valid  wvalid  ; // Output Write channel valid
  type_m_axi4_mid_ready  bready  ; // Output Write response channel ready
  type_m_axi4_mid_region awregion;
} AXI4MIDMasterWriteInterfaceOutput;

typedef struct packed {
  AXI4MIDMasterWriteInterfaceInput  in ;
  AXI4MIDMasterWriteInterfaceOutput out;
} AXI4MIDMasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

typedef struct packed {
  type_m_axi4_mid_valid rvalid ; // Input Read channel valid
  type_m_axi4_mid_last  arready; // Input Read Address read channel ready
  type_m_axi4_mid_last  rlast  ; // Input Read channel last word
  type_m_axi4_mid_data  rdata  ; // Input Read channel data
  type_m_axi4_mid_id    rid    ; // Input Read channel ID
  type_m_axi4_mid_resp  rresp  ; // Input Read channel response
} AXI4MIDSlaveReadInterfaceOutput;

typedef struct packed {
  type_m_axi4_mid_valid  arvalid ; // Output Read Address read channel valid
  type_m_axi4_mid_addr   araddr  ; // Output Read Address read channel address
  type_m_axi4_mid_len    arlen   ; // Output Read Address channel burst length
  type_m_axi4_mid_ready  rready  ; // Output Read Read channel ready
  type_m_axi4_mid_id     arid    ; // Output Read Address read channel ID
  type_m_axi4_mid_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_mid_burst  arburst ; // Output Read Address read channel burst type
  type_m_axi4_mid_lock   arlock  ; // Output Read Address read channel lock type
  type_m_axi4_mid_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_mid_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_mid_qos    arqos   ; // Output Read Address channel quality of service
  type_m_axi4_mid_region arregion;
} AXI4MIDSlaveReadInterfaceInput;

typedef struct packed {
  AXI4MIDSlaveReadInterfaceInput  in ;
  AXI4MIDSlaveReadInterfaceOutput out;
} AXI4MIDSlaveReadInterface;


typedef struct packed {
  type_m_axi4_mid_ready awready; // Input Write Address write channel ready
  type_m_axi4_mid_ready wready ; // Input Write channel ready
  type_m_axi4_mid_id    bid    ; // Input Write response channel ID
  type_m_axi4_mid_resp  bresp  ; // Input Write channel response
  type_m_axi4_mid_valid bvalid ; // Input Write response channel valid
} AXI4MIDSlaveWriteInterfaceOutput;

typedef struct packed {
  type_m_axi4_mid_valid  awvalid ; // Output Write Address write channel valid
  type_m_axi4_mid_id     awid    ; // Output Write Address write channel ID
  type_m_axi4_mid_addr   awaddr  ; // Output Write Address write channel address
  type_m_axi4_mid_len    awlen   ; // Output Write Address write channel burst length
  type_m_axi4_mid_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m_axi4_mid_burst  awburst ; // Output Write Address write channel burst type
  type_m_axi4_mid_lock   awlock  ; // Output Write Address write channel lock type
  type_m_axi4_mid_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m_axi4_mid_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m_axi4_mid_qos    awqos   ; // Output Write Address write channel quality of service
  type_m_axi4_mid_data   wdata   ; // Output Write channel data
  type_m_axi4_mid_strb   wstrb   ; // Output Write channel write strobe
  type_m_axi4_mid_last   wlast   ; // Output Write channel last word flag
  type_m_axi4_mid_valid  wvalid  ; // Output Write channel valid
  type_m_axi4_mid_ready  bready  ; // Output Write response channel ready
  type_m_axi4_mid_region awregion;
} AXI4MIDSlaveWriteInterfaceInput;

typedef struct packed {
  AXI4MIDSlaveWriteInterfaceInput  in ;
  AXI4MIDSlaveWriteInterfaceOutput out;
} AXI4MIDSlaveWriteInterface;


function logic [M_AXI4_MID_DATA_W-1:0] swap_endianness_cacheline_axi_mid (logic [M_AXI4_MID_DATA_W-1:0] in, logic mode);

  logic [M_AXI4_MID_DATA_W-1:0] out;

  integer i;

  if(mode == 1) begin
    for ( i = 0; i < M_AXI4_MID_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M_AXI4_MID_DATA_W-1)-(i*8)) -:8];
    end
  end else begin
    out = in;
  end

  return out;
endfunction : swap_endianness_cacheline_axi_mid

endpackage