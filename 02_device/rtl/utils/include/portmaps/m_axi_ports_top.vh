
input  wire                                    m00_axi_awready      , // Address write channel ready
input  wire                                    m00_axi_wready       , // Write channel ready
output wire                                    m00_axi_awvalid      , // Address write channel valid
output wire                                    m00_axi_wlast        , // Write channel last word flag
output wire                                    m00_axi_wvalid       , // Write channel valid
output wire [                           8-1:0] m00_axi_awlen        , // Address write channel burst length
output wire [        C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr       , // Address write channel address
output wire [        C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata        , // Write channel data
output wire [      C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb        , // Write channel write strobe
input  wire                                    m00_axi_bvalid       , // Write response channel valid
output wire                                    m00_axi_bready       , // Write response channel ready
input  wire                                    m00_axi_arready      , // Address read channel ready
input  wire                                    m00_axi_rlast        , // Read channel last word
input  wire                                    m00_axi_rvalid       , // Read channel valid
input  wire [        C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata        , // Read channel data
output wire                                    m00_axi_arvalid      , // Address read channel valid
output wire                                    m00_axi_rready       , // Read channel ready
output wire [                           8-1:0] m00_axi_arlen        , // Address write channel burst length
output wire [        C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr       , // Address read channel address
// AXI4 master interface m00_axi missing ports
input  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_bid          , // Write response channel ID
input  wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_rid          , // Read channel ID
input  wire [                           2-1:0] m00_axi_rresp        , // Read channel response
input  wire [                           2-1:0] m00_axi_bresp        , // Write channel response
output wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_awid         , // Address write channel ID
output wire [                           3-1:0] m00_axi_awsize       , // Address write channel burst size
output wire [                           2-1:0] m00_axi_awburst      , // Address write channel burst type
output wire [                           1-1:0] m00_axi_awlock       , // Address write channel lock type
output wire [                           4-1:0] m00_axi_awcache      , // Address write channel memory type
output wire [                           3-1:0] m00_axi_awprot       , // Address write channel protection type
output wire [                           4-1:0] m00_axi_awqos        , // Address write channel quality of service
output wire [          C_M00_AXI_ID_WIDTH-1:0] m00_axi_arid         , // Address read channel ID
output wire [                           3-1:0] m00_axi_arsize       , // Address read channel burst size
output wire [                           2-1:0] m00_axi_arburst      , // Address read channel burst type
output wire [                           1-1:0] m00_axi_arlock       , // Address read channel lock type
output wire [                           4-1:0] m00_axi_arcache      , // Address read channel memory type
output wire [                           3-1:0] m00_axi_arprot       , // Address read channel protection type
output wire [                           4-1:0] m00_axi_arqos        , // Address read channel quality of service
    

input  wire                                    m01_axi_awready      , // Address write channel ready
input  wire                                    m01_axi_wready       , // Write channel ready
output wire                                    m01_axi_awvalid      , // Address write channel valid
output wire                                    m01_axi_wlast        , // Write channel last word flag
output wire                                    m01_axi_wvalid       , // Write channel valid
output wire [                           8-1:0] m01_axi_awlen        , // Address write channel burst length
output wire [        C_M01_AXI_ADDR_WIDTH-1:0] m01_axi_awaddr       , // Address write channel address
output wire [        C_M01_AXI_DATA_WIDTH-1:0] m01_axi_wdata        , // Write channel data
output wire [      C_M01_AXI_DATA_WIDTH/8-1:0] m01_axi_wstrb        , // Write channel write strobe
input  wire                                    m01_axi_bvalid       , // Write response channel valid
output wire                                    m01_axi_bready       , // Write response channel ready
input  wire                                    m01_axi_arready      , // Address read channel ready
input  wire                                    m01_axi_rlast        , // Read channel last word
input  wire                                    m01_axi_rvalid       , // Read channel valid
input  wire [        C_M01_AXI_DATA_WIDTH-1:0] m01_axi_rdata        , // Read channel data
output wire                                    m01_axi_arvalid      , // Address read channel valid
output wire                                    m01_axi_rready       , // Read channel ready
output wire [                           8-1:0] m01_axi_arlen        , // Address write channel burst length
output wire [        C_M01_AXI_ADDR_WIDTH-1:0] m01_axi_araddr       , // Address read channel address
// AXI4 master interface m01_axi missing ports
input  wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_bid          , // Write response channel ID
input  wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_rid          , // Read channel ID
input  wire [                           2-1:0] m01_axi_rresp        , // Read channel response
input  wire [                           2-1:0] m01_axi_bresp        , // Write channel response
output wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_awid         , // Address write channel ID
output wire [                           3-1:0] m01_axi_awsize       , // Address write channel burst size
output wire [                           2-1:0] m01_axi_awburst      , // Address write channel burst type
output wire [                           1-1:0] m01_axi_awlock       , // Address write channel lock type
output wire [                           4-1:0] m01_axi_awcache      , // Address write channel memory type
output wire [                           3-1:0] m01_axi_awprot       , // Address write channel protection type
output wire [                           4-1:0] m01_axi_awqos        , // Address write channel quality of service
output wire [          C_M01_AXI_ID_WIDTH-1:0] m01_axi_arid         , // Address read channel ID
output wire [                           3-1:0] m01_axi_arsize       , // Address read channel burst size
output wire [                           2-1:0] m01_axi_arburst      , // Address read channel burst type
output wire [                           1-1:0] m01_axi_arlock       , // Address read channel lock type
output wire [                           4-1:0] m01_axi_arcache      , // Address read channel memory type
output wire [                           3-1:0] m01_axi_arprot       , // Address read channel protection type
output wire [                           4-1:0] m01_axi_arqos        , // Address read channel quality of service
    