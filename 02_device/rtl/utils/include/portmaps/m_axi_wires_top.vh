
  wire                                    m00_axi_awready      ; // Address write channel ready
  wire                                    m00_axi_wready       ; // Write channel ready
  wire                                    m00_axi_awvalid      ; // Address write channel valid
  wire                                    m00_axi_wlast        ; // Write channel last word flag
  wire                                    m00_axi_wvalid       ; // Write channel valid
  wire [                           8-1:0] m00_axi_awlen        ; // Address write channel burst length
  wire [        C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr  ; // Address write channel address
  wire [        C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata   ; // Write channel data
  wire [      C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb   ; // Write channel write strobe
  wire                                    m00_axi_bvalid       ; // Write response channel valid
  wire                                    m00_axi_bready       ; // Write response channel ready
  wire                                    m00_axi_arready      ; // Address read channel ready
  wire                                    m00_axi_rlast        ; // Read channel last word
  wire                                    m00_axi_rvalid       ; // Read channel valid
  wire [        C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata   ; // Read channel data
  wire                                    m00_axi_arvalid      ; // Address read channel valid
  wire                                    m00_axi_rready       ; // Read channel ready
  wire [                           8-1:0] m00_axi_arlen        ; // Address write channel burst length
  wire [        C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr  ; // Address read channel address
// AXI4 master interface m00_axi missing ports
  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_bid     ; // Write response channel ID
  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_rid     ; // Read channel ID
  wire [                           2-1:0] m00_axi_rresp        ; // Read channel response
  wire [                           2-1:0] m00_axi_bresp        ; // Write channel response
  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_awid    ; // Address write channel ID
  wire [                           3-1:0] m00_axi_awsize       ; // Address write channel burst size
  wire [                           2-1:0] m00_axi_awburst      ; // Address write channel burst type
  wire [                           1-1:0] m00_axi_awlock       ; // Address write channel lock type
  wire [                           4-1:0] m00_axi_awcache      ; // Address write channel memory type
  wire [                           3-1:0] m00_axi_awprot       ; // Address write channel protection type
  wire [                           4-1:0] m00_axi_awqos        ; // Address write channel quality of service
  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_arid    ; // Address read channel ID
  wire [                           3-1:0] m00_axi_arsize       ; // Address read channel burst size
  wire [                           2-1:0] m00_axi_arburst      ; // Address read channel burst type
  wire [                           1-1:0] m00_axi_arlock       ; // Address read channel lock type
  wire [                           4-1:0] m00_axi_arcache      ; // Address read channel memory type
  wire [                           3-1:0] m00_axi_arprot       ; // Address read channel protection type
  wire [                           4-1:0] m00_axi_arqos        ; // Address read channel quality of service
    

  wire                                    m01_axi_awready      ; // Address write channel ready
  wire                                    m01_axi_wready       ; // Write channel ready
  wire                                    m01_axi_awvalid      ; // Address write channel valid
  wire                                    m01_axi_wlast        ; // Write channel last word flag
  wire                                    m01_axi_wvalid       ; // Write channel valid
  wire [                           8-1:0] m01_axi_awlen        ; // Address write channel burst length
  wire [        C_M01_AXI_ADDR_WIDTH-1:0] m01_axi_awaddr  ; // Address write channel address
  wire [        C_M01_AXI_DATA_WIDTH-1:0] m01_axi_wdata   ; // Write channel data
  wire [      C_M01_AXI_DATA_WIDTH/8-1:0] m01_axi_wstrb   ; // Write channel write strobe
  wire                                    m01_axi_bvalid       ; // Write response channel valid
  wire                                    m01_axi_bready       ; // Write response channel ready
  wire                                    m01_axi_arready      ; // Address read channel ready
  wire                                    m01_axi_rlast        ; // Read channel last word
  wire                                    m01_axi_rvalid       ; // Read channel valid
  wire [        C_M01_AXI_DATA_WIDTH-1:0] m01_axi_rdata   ; // Read channel data
  wire                                    m01_axi_arvalid      ; // Address read channel valid
  wire                                    m01_axi_rready       ; // Read channel ready
  wire [                           8-1:0] m01_axi_arlen        ; // Address write channel burst length
  wire [        C_M01_AXI_ADDR_WIDTH-1:0] m01_axi_araddr  ; // Address read channel address
// AXI4 master interface m01_axi missing ports
  wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_bid     ; // Write response channel ID
  wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_rid     ; // Read channel ID
  wire [                           2-1:0] m01_axi_rresp        ; // Read channel response
  wire [                           2-1:0] m01_axi_bresp        ; // Write channel response
  wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_awid    ; // Address write channel ID
  wire [                           3-1:0] m01_axi_awsize       ; // Address write channel burst size
  wire [                           2-1:0] m01_axi_awburst      ; // Address write channel burst type
  wire [                           1-1:0] m01_axi_awlock       ; // Address write channel lock type
  wire [                           4-1:0] m01_axi_awcache      ; // Address write channel memory type
  wire [                           3-1:0] m01_axi_awprot       ; // Address write channel protection type
  wire [                           4-1:0] m01_axi_awqos        ; // Address write channel quality of service
  wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_arid    ; // Address read channel ID
  wire [                           3-1:0] m01_axi_arsize       ; // Address read channel burst size
  wire [                           2-1:0] m01_axi_arburst      ; // Address read channel burst type
  wire [                           1-1:0] m01_axi_arlock       ; // Address read channel lock type
  wire [                           4-1:0] m01_axi_arcache      ; // Address read channel memory type
  wire [                           3-1:0] m01_axi_arprot       ; // Address read channel protection type
  wire [                           4-1:0] m01_axi_arqos        ; // Address read channel quality of service
    