
output logic                         m00_axi_awvalid,
input  logic                         m00_axi_awready,
output logic [ M00_AXI4_BE_ADDR_W-1:0] m00_axi_awaddr ,
output logic [  M00_AXI4_BE_LEN_W-1:0] m00_axi_awlen  ,
output logic                         m00_axi_wvalid ,
input  logic                         m00_axi_wready ,
output logic [ M00_AXI4_BE_DATA_W-1:0] m00_axi_wdata  ,
output logic [ M00_AXI4_BE_STRB_W-1:0] m00_axi_wstrb  ,
output logic                         m00_axi_wlast  ,
input  logic                         m00_axi_bvalid ,
output logic                         m00_axi_bready ,
output logic                         m00_axi_arvalid,
input  logic                         m00_axi_arready,
output logic [ M00_AXI4_BE_ADDR_W-1:0] m00_axi_araddr ,
output logic [  M00_AXI4_BE_LEN_W-1:0] m00_axi_arlen  ,
input  logic                         m00_axi_rvalid ,
output logic                         m00_axi_rready ,
input  logic [ M00_AXI4_BE_DATA_W-1:0] m00_axi_rdata  ,
input  logic                         m00_axi_rlast  ,
// Control Signals
// AXI4 master interface m00_axi missing ports
input  logic [   M00_AXI4_BE_ID_W-1:0] m00_axi_bid    ,
input  logic [   M00_AXI4_BE_ID_W-1:0] m00_axi_rid    ,
input  logic [ M00_AXI4_BE_RESP_W-1:0] m00_axi_rresp  ,
input  logic [ M00_AXI4_BE_RESP_W-1:0] m00_axi_bresp  ,
output logic [   M00_AXI4_BE_ID_W-1:0] m00_axi_awid   ,
output logic [ M00_AXI4_BE_SIZE_W-1:0] m00_axi_awsize ,
output logic [M00_AXI4_BE_BURST_W-1:0] m00_axi_awburst,
output logic [ M00_AXI4_BE_LOCK_W-1:0] m00_axi_awlock ,
output logic [M00_AXI4_BE_CACHE_W-1:0] m00_axi_awcache,
output logic [ M00_AXI4_BE_PROT_W-1:0] m00_axi_awprot ,
output logic [  M00_AXI4_BE_QOS_W-1:0] m00_axi_awqos  ,
output logic [   M00_AXI4_BE_ID_W-1:0] m00_axi_arid   ,
output logic [ M00_AXI4_BE_SIZE_W-1:0] m00_axi_arsize ,
output logic [M00_AXI4_BE_BURST_W-1:0] m00_axi_arburst,
output logic [ M00_AXI4_BE_LOCK_W-1:0] m00_axi_arlock ,
output logic [M00_AXI4_BE_CACHE_W-1:0] m00_axi_arcache,
output logic [ M00_AXI4_BE_PROT_W-1:0] m00_axi_arprot ,
output logic [  M00_AXI4_BE_QOS_W-1:0] m00_axi_arqos  ,
    

output logic                         m01_axi_awvalid,
input  logic                         m01_axi_awready,
output logic [ M01_AXI4_BE_ADDR_W-1:0] m01_axi_awaddr ,
output logic [  M01_AXI4_BE_LEN_W-1:0] m01_axi_awlen  ,
output logic                         m01_axi_wvalid ,
input  logic                         m01_axi_wready ,
output logic [ M01_AXI4_BE_DATA_W-1:0] m01_axi_wdata  ,
output logic [ M01_AXI4_BE_STRB_W-1:0] m01_axi_wstrb  ,
output logic                         m01_axi_wlast  ,
input  logic                         m01_axi_bvalid ,
output logic                         m01_axi_bready ,
output logic                         m01_axi_arvalid,
input  logic                         m01_axi_arready,
output logic [ M01_AXI4_BE_ADDR_W-1:0] m01_axi_araddr ,
output logic [  M01_AXI4_BE_LEN_W-1:0] m01_axi_arlen  ,
input  logic                         m01_axi_rvalid ,
output logic                         m01_axi_rready ,
input  logic [ M01_AXI4_BE_DATA_W-1:0] m01_axi_rdata  ,
input  logic                         m01_axi_rlast  ,
// Control Signals
// AXI4 master interface m01_axi missing ports
input  logic [   M01_AXI4_BE_ID_W-1:0] m01_axi_bid    ,
input  logic [   M01_AXI4_BE_ID_W-1:0] m01_axi_rid    ,
input  logic [ M01_AXI4_BE_RESP_W-1:0] m01_axi_rresp  ,
input  logic [ M01_AXI4_BE_RESP_W-1:0] m01_axi_bresp  ,
output logic [   M01_AXI4_BE_ID_W-1:0] m01_axi_awid   ,
output logic [ M01_AXI4_BE_SIZE_W-1:0] m01_axi_awsize ,
output logic [M01_AXI4_BE_BURST_W-1:0] m01_axi_awburst,
output logic [ M01_AXI4_BE_LOCK_W-1:0] m01_axi_awlock ,
output logic [M01_AXI4_BE_CACHE_W-1:0] m01_axi_awcache,
output logic [ M01_AXI4_BE_PROT_W-1:0] m01_axi_awprot ,
output logic [  M01_AXI4_BE_QOS_W-1:0] m01_axi_awqos  ,
output logic [   M01_AXI4_BE_ID_W-1:0] m01_axi_arid   ,
output logic [ M01_AXI4_BE_SIZE_W-1:0] m01_axi_arsize ,
output logic [M01_AXI4_BE_BURST_W-1:0] m01_axi_arburst,
output logic [ M01_AXI4_BE_LOCK_W-1:0] m01_axi_arlock ,
output logic [M01_AXI4_BE_CACHE_W-1:0] m01_axi_arcache,
output logic [ M01_AXI4_BE_PROT_W-1:0] m01_axi_arprot ,
output logic [  M01_AXI4_BE_QOS_W-1:0] m01_axi_arqos  ,
    