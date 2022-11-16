set moduleName glay_kernel
set isTopModule 1
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set pipeline_type none
set FunctionProtocol ap_ctrl_chain
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set C_modelName {glay_kernel}
set C_modelType { void 0 }
set C_modelArgList {
	{ m00_axi int 512 regular {axi_master 2}  }
	{ graph_csr_struct int 64 regular {axi_slave 0}  }
	{ vertex_out_degree int 64 unused {axi_slave 0}  }
	{ vertex_in_degree int 64 unused {axi_slave 0}  }
	{ vertex_edges_idx int 64 unused {axi_slave 0}  }
	{ edges_array_weight int 64 unused {axi_slave 0}  }
	{ edges_array_src int 64 unused {axi_slave 0}  }
	{ edges_array_dest int 64 unused {axi_slave 0}  }
	{ auxiliary_1 int 64 unused {axi_slave 0}  }
	{ auxiliary_2 int 64 unused {axi_slave 0}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "m00_axi", "interface" : "axi_master", "bitwidth" : 512, "direction" : "READWRITE", "bitSlice":[ {"cElement": [{"cName": "graph_csr_struct","offset": { "type": "dynamic","port_name": "graph_csr_struct","bundle": "control"},"direction": "READWRITE"},{"cName": "vertex_out_degree","offset": { "type": "dynamic","port_name": "vertex_out_degree","bundle": "control"},},{"cName": "vertex_in_degree","offset": { "type": "dynamic","port_name": "vertex_in_degree","bundle": "control"},},{"cName": "vertex_edges_idx","offset": { "type": "dynamic","port_name": "vertex_edges_idx","bundle": "control"},},{"cName": "edges_array_weight","offset": { "type": "dynamic","port_name": "edges_array_weight","bundle": "control"},},{"cName": "edges_array_src","offset": { "type": "dynamic","port_name": "edges_array_src","bundle": "control"},},{"cName": "edges_array_dest","offset": { "type": "dynamic","port_name": "edges_array_dest","bundle": "control"},},{"cName": "auxiliary_1","offset": { "type": "dynamic","port_name": "auxiliary_1","bundle": "control"},},{"cName": "auxiliary_2","offset": { "type": "dynamic","port_name": "auxiliary_2","bundle": "control"},}]}]} , 
 	{ "Name" : "graph_csr_struct", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":16}, "offset_end" : {"in":27}} , 
 	{ "Name" : "vertex_out_degree", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":28}, "offset_end" : {"in":39}} , 
 	{ "Name" : "vertex_in_degree", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":40}, "offset_end" : {"in":51}} , 
 	{ "Name" : "vertex_edges_idx", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":52}, "offset_end" : {"in":63}} , 
 	{ "Name" : "edges_array_weight", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":64}, "offset_end" : {"in":75}} , 
 	{ "Name" : "edges_array_src", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":76}, "offset_end" : {"in":87}} , 
 	{ "Name" : "edges_array_dest", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":88}, "offset_end" : {"in":99}} , 
 	{ "Name" : "auxiliary_1", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":100}, "offset_end" : {"in":111}} , 
 	{ "Name" : "auxiliary_2", "interface" : "axi_slave", "bundle":"control","type":"ap_none","bitwidth" : 64, "direction" : "READONLY", "offset" : {"in":112}, "offset_end" : {"in":123}} ]}
# RTL Port declarations: 
set portNum 65
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst_n sc_in sc_logic 1 reset -1 active_low_sync } 
	{ m_axi_m00_axi_AWVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_AWREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_AWADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_m00_axi_AWID sc_out sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_AWLEN sc_out sc_lv 8 signal 0 } 
	{ m_axi_m00_axi_AWSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_m00_axi_AWBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_m00_axi_AWLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_m00_axi_AWCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_m00_axi_AWPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_m00_axi_AWQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_m00_axi_AWREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_m00_axi_AWUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_WVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_WREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_WDATA sc_out sc_lv 512 signal 0 } 
	{ m_axi_m00_axi_WSTRB sc_out sc_lv 64 signal 0 } 
	{ m_axi_m00_axi_WLAST sc_out sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_WID sc_out sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_WUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_ARVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_ARREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_ARADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_m00_axi_ARID sc_out sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_ARLEN sc_out sc_lv 8 signal 0 } 
	{ m_axi_m00_axi_ARSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_m00_axi_ARBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_m00_axi_ARLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_m00_axi_ARCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_m00_axi_ARPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_m00_axi_ARQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_m00_axi_ARREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_m00_axi_ARUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_RVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_RREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_RDATA sc_in sc_lv 512 signal 0 } 
	{ m_axi_m00_axi_RLAST sc_in sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_RID sc_in sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_RUSER sc_in sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_RRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_m00_axi_BVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_BREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_m00_axi_BRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_m00_axi_BID sc_in sc_lv 1 signal 0 } 
	{ m_axi_m00_axi_BUSER sc_in sc_lv 1 signal 0 } 
	{ s_axi_control_AWVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_AWREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_AWADDR sc_in sc_lv 7 signal -1 } 
	{ s_axi_control_WVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_WREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_WDATA sc_in sc_lv 32 signal -1 } 
	{ s_axi_control_WSTRB sc_in sc_lv 4 signal -1 } 
	{ s_axi_control_ARVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_ARREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_ARADDR sc_in sc_lv 7 signal -1 } 
	{ s_axi_control_RVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_RREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_RDATA sc_out sc_lv 32 signal -1 } 
	{ s_axi_control_RRESP sc_out sc_lv 2 signal -1 } 
	{ s_axi_control_BVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_control_BREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_control_BRESP sc_out sc_lv 2 signal -1 } 
	{ interrupt sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "s_axi_control_AWADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":7, "type": "signal", "bundle":{"name": "control", "role": "AWADDR" },"address":[{"name":"glay_kernel","role":"start","value":"0","valid_bit":"0"},{"name":"glay_kernel","role":"continue","value":"0","valid_bit":"4"},{"name":"glay_kernel","role":"auto_start","value":"0","valid_bit":"7"},{"name":"graph_csr_struct","role":"data","value":"16"},{"name":"vertex_out_degree","role":"data","value":"28"},{"name":"vertex_in_degree","role":"data","value":"40"},{"name":"vertex_edges_idx","role":"data","value":"52"},{"name":"edges_array_weight","role":"data","value":"64"},{"name":"edges_array_src","role":"data","value":"76"},{"name":"edges_array_dest","role":"data","value":"88"},{"name":"auxiliary_1","role":"data","value":"100"},{"name":"auxiliary_2","role":"data","value":"112"}] },
	{ "name": "s_axi_control_AWVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "AWVALID" } },
	{ "name": "s_axi_control_AWREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "AWREADY" } },
	{ "name": "s_axi_control_WVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "WVALID" } },
	{ "name": "s_axi_control_WREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "WREADY" } },
	{ "name": "s_axi_control_WDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "control", "role": "WDATA" } },
	{ "name": "s_axi_control_WSTRB", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "control", "role": "WSTRB" } },
	{ "name": "s_axi_control_ARADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":7, "type": "signal", "bundle":{"name": "control", "role": "ARADDR" },"address":[{"name":"glay_kernel","role":"start","value":"0","valid_bit":"0"},{"name":"glay_kernel","role":"done","value":"0","valid_bit":"1"},{"name":"glay_kernel","role":"idle","value":"0","valid_bit":"2"},{"name":"glay_kernel","role":"ready","value":"0","valid_bit":"3"},{"name":"glay_kernel","role":"auto_start","value":"0","valid_bit":"7"}] },
	{ "name": "s_axi_control_ARVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "ARVALID" } },
	{ "name": "s_axi_control_ARREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "ARREADY" } },
	{ "name": "s_axi_control_RVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "RVALID" } },
	{ "name": "s_axi_control_RREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "RREADY" } },
	{ "name": "s_axi_control_RDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "control", "role": "RDATA" } },
	{ "name": "s_axi_control_RRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "control", "role": "RRESP" } },
	{ "name": "s_axi_control_BVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "BVALID" } },
	{ "name": "s_axi_control_BREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "BREADY" } },
	{ "name": "s_axi_control_BRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "control", "role": "BRESP" } },
	{ "name": "interrupt", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "control", "role": "interrupt" } }, 
 	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst_n", "role": "default" }} , 
 	{ "name": "m_axi_m00_axi_AWVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWVALID" }} , 
 	{ "name": "m_axi_m00_axi_AWREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWREADY" }} , 
 	{ "name": "m_axi_m00_axi_AWADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWADDR" }} , 
 	{ "name": "m_axi_m00_axi_AWID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWID" }} , 
 	{ "name": "m_axi_m00_axi_AWLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWLEN" }} , 
 	{ "name": "m_axi_m00_axi_AWSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWSIZE" }} , 
 	{ "name": "m_axi_m00_axi_AWBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWBURST" }} , 
 	{ "name": "m_axi_m00_axi_AWLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWLOCK" }} , 
 	{ "name": "m_axi_m00_axi_AWCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWCACHE" }} , 
 	{ "name": "m_axi_m00_axi_AWPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWPROT" }} , 
 	{ "name": "m_axi_m00_axi_AWQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWQOS" }} , 
 	{ "name": "m_axi_m00_axi_AWREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWREGION" }} , 
 	{ "name": "m_axi_m00_axi_AWUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "AWUSER" }} , 
 	{ "name": "m_axi_m00_axi_WVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "WVALID" }} , 
 	{ "name": "m_axi_m00_axi_WREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "WREADY" }} , 
 	{ "name": "m_axi_m00_axi_WDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":512, "type": "signal", "bundle":{"name": "m00_axi", "role": "WDATA" }} , 
 	{ "name": "m_axi_m00_axi_WSTRB", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "m00_axi", "role": "WSTRB" }} , 
 	{ "name": "m_axi_m00_axi_WLAST", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "WLAST" }} , 
 	{ "name": "m_axi_m00_axi_WID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "WID" }} , 
 	{ "name": "m_axi_m00_axi_WUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "WUSER" }} , 
 	{ "name": "m_axi_m00_axi_ARVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARVALID" }} , 
 	{ "name": "m_axi_m00_axi_ARREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARREADY" }} , 
 	{ "name": "m_axi_m00_axi_ARADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARADDR" }} , 
 	{ "name": "m_axi_m00_axi_ARID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARID" }} , 
 	{ "name": "m_axi_m00_axi_ARLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARLEN" }} , 
 	{ "name": "m_axi_m00_axi_ARSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARSIZE" }} , 
 	{ "name": "m_axi_m00_axi_ARBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARBURST" }} , 
 	{ "name": "m_axi_m00_axi_ARLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARLOCK" }} , 
 	{ "name": "m_axi_m00_axi_ARCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARCACHE" }} , 
 	{ "name": "m_axi_m00_axi_ARPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARPROT" }} , 
 	{ "name": "m_axi_m00_axi_ARQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARQOS" }} , 
 	{ "name": "m_axi_m00_axi_ARREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARREGION" }} , 
 	{ "name": "m_axi_m00_axi_ARUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "ARUSER" }} , 
 	{ "name": "m_axi_m00_axi_RVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "RVALID" }} , 
 	{ "name": "m_axi_m00_axi_RREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "RREADY" }} , 
 	{ "name": "m_axi_m00_axi_RDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":512, "type": "signal", "bundle":{"name": "m00_axi", "role": "RDATA" }} , 
 	{ "name": "m_axi_m00_axi_RLAST", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "RLAST" }} , 
 	{ "name": "m_axi_m00_axi_RID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "RID" }} , 
 	{ "name": "m_axi_m00_axi_RUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "RUSER" }} , 
 	{ "name": "m_axi_m00_axi_RRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "m00_axi", "role": "RRESP" }} , 
 	{ "name": "m_axi_m00_axi_BVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "BVALID" }} , 
 	{ "name": "m_axi_m00_axi_BREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "BREADY" }} , 
 	{ "name": "m_axi_m00_axi_BRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "m00_axi", "role": "BRESP" }} , 
 	{ "name": "m_axi_m00_axi_BID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "BID" }} , 
 	{ "name": "m_axi_m00_axi_BUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "m00_axi", "role": "BUSER" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "5", "7", "9", "10"],
		"CDFG" : "glay_kernel",
		"Protocol" : "ap_ctrl_chain",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "12440", "EstimateLatencyMax" : "12440",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "m00_axi", "Type" : "MAXI", "Direction" : "IO",
				"BlockSignal" : [
					{"Name" : "m00_axi_blk_n_AR", "Type" : "RtlSignal"},
					{"Name" : "m00_axi_blk_n_AW", "Type" : "RtlSignal"},
					{"Name" : "m00_axi_blk_n_B", "Type" : "RtlSignal"}],
				"SubConnect" : [
					{"ID" : "3", "SubInstance" : "grp_glay_kernel_Pipeline_1_fu_119", "Port" : "m00_axi", "Inst_start_state" : "72", "Inst_end_state" : "73"},
					{"ID" : "7", "SubInstance" : "grp_glay_kernel_Pipeline_3_fu_133", "Port" : "m00_axi", "Inst_start_state" : "76", "Inst_end_state" : "77"}]},
			{"Name" : "graph_csr_struct", "Type" : "None", "Direction" : "I"},
			{"Name" : "vertex_out_degree", "Type" : "None", "Direction" : "I"},
			{"Name" : "vertex_in_degree", "Type" : "None", "Direction" : "I"},
			{"Name" : "vertex_edges_idx", "Type" : "None", "Direction" : "I"},
			{"Name" : "edges_array_weight", "Type" : "None", "Direction" : "I"},
			{"Name" : "edges_array_src", "Type" : "None", "Direction" : "I"},
			{"Name" : "edges_array_dest", "Type" : "None", "Direction" : "I"},
			{"Name" : "auxiliary_1", "Type" : "None", "Direction" : "I"},
			{"Name" : "auxiliary_2", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.m00_axi_input_buffer_U", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.m00_axi_output_buffer_U", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_glay_kernel_Pipeline_1_fu_119", "Parent" : "0", "Child" : ["4"],
		"CDFG" : "glay_kernel_Pipeline_1",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "4099", "EstimateLatencyMax" : "4099",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "m00_axi", "Type" : "MAXI", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "m00_axi_blk_n_R", "Type" : "RtlSignal"}]},
			{"Name" : "sext_ln71", "Type" : "None", "Direction" : "I"},
			{"Name" : "m00_axi_input_buffer", "Type" : "Memory", "Direction" : "O"}],
		"Loop" : [
			{"Name" : "Loop 1", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter0", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter2", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter1", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "4", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_glay_kernel_Pipeline_1_fu_119.flow_control_loop_pipe_sequential_init_U", "Parent" : "3"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_glay_kernel_Pipeline_VITIS_LOOP_74_1_fu_127", "Parent" : "0", "Child" : ["6"],
		"CDFG" : "glay_kernel_Pipeline_VITIS_LOOP_74_1",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "4098", "EstimateLatencyMax" : "4098",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "m00_axi_input_buffer", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "m00_axi_output_buffer", "Type" : "Memory", "Direction" : "O"}],
		"Loop" : [
			{"Name" : "VITIS_LOOP_74_1", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter0", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter1", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter0", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "6", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_glay_kernel_Pipeline_VITIS_LOOP_74_1_fu_127.flow_control_loop_pipe_sequential_init_U", "Parent" : "5"},
	{"ID" : "7", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_glay_kernel_Pipeline_3_fu_133", "Parent" : "0", "Child" : ["8"],
		"CDFG" : "glay_kernel_Pipeline_3",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "4099", "EstimateLatencyMax" : "4099",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "m00_axi", "Type" : "MAXI", "Direction" : "O",
				"BlockSignal" : [
					{"Name" : "m00_axi_blk_n_W", "Type" : "RtlSignal"}]},
			{"Name" : "sext_ln71", "Type" : "None", "Direction" : "I"},
			{"Name" : "m00_axi_output_buffer", "Type" : "Memory", "Direction" : "I"}],
		"Loop" : [
			{"Name" : "Loop 1", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter0", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter2", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter1", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "8", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.grp_glay_kernel_Pipeline_3_fu_133.flow_control_loop_pipe_sequential_init_U", "Parent" : "7"},
	{"ID" : "9", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.control_s_axi_U", "Parent" : "0"},
	{"ID" : "10", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.m00_axi_m_axi_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	glay_kernel {
		m00_axi {Type IO LastRead 77 FirstWrite -1}
		graph_csr_struct {Type I LastRead 0 FirstWrite -1}
		vertex_out_degree {Type I LastRead -1 FirstWrite -1}
		vertex_in_degree {Type I LastRead -1 FirstWrite -1}
		vertex_edges_idx {Type I LastRead -1 FirstWrite -1}
		edges_array_weight {Type I LastRead -1 FirstWrite -1}
		edges_array_src {Type I LastRead -1 FirstWrite -1}
		edges_array_dest {Type I LastRead -1 FirstWrite -1}
		auxiliary_1 {Type I LastRead -1 FirstWrite -1}
		auxiliary_2 {Type I LastRead -1 FirstWrite -1}}
	glay_kernel_Pipeline_1 {
		m00_axi {Type I LastRead 1 FirstWrite -1}
		sext_ln71 {Type I LastRead 0 FirstWrite -1}
		m00_axi_input_buffer {Type O LastRead -1 FirstWrite 2}}
	glay_kernel_Pipeline_VITIS_LOOP_74_1 {
		m00_axi_input_buffer {Type I LastRead 0 FirstWrite -1}
		m00_axi_output_buffer {Type O LastRead -1 FirstWrite 1}}
	glay_kernel_Pipeline_3 {
		m00_axi {Type O LastRead -1 FirstWrite 2}
		sext_ln71 {Type I LastRead 0 FirstWrite -1}
		m00_axi_output_buffer {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "12440", "Max" : "12440"}
	, {"Name" : "Interval", "Min" : "12441", "Max" : "12441"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	m00_axi { m_axi {  { m_axi_m00_axi_AWVALID VALID 1 1 }  { m_axi_m00_axi_AWREADY READY 0 1 }  { m_axi_m00_axi_AWADDR ADDR 1 64 }  { m_axi_m00_axi_AWID ID 1 1 }  { m_axi_m00_axi_AWLEN SIZE 1 8 }  { m_axi_m00_axi_AWSIZE BURST 1 3 }  { m_axi_m00_axi_AWBURST LOCK 1 2 }  { m_axi_m00_axi_AWLOCK CACHE 1 2 }  { m_axi_m00_axi_AWCACHE PROT 1 4 }  { m_axi_m00_axi_AWPROT QOS 1 3 }  { m_axi_m00_axi_AWQOS REGION 1 4 }  { m_axi_m00_axi_AWREGION USER 1 4 }  { m_axi_m00_axi_AWUSER DATA 1 1 }  { m_axi_m00_axi_WVALID VALID 1 1 }  { m_axi_m00_axi_WREADY READY 0 1 }  { m_axi_m00_axi_WDATA FIFONUM 1 512 }  { m_axi_m00_axi_WSTRB STRB 1 64 }  { m_axi_m00_axi_WLAST LAST 1 1 }  { m_axi_m00_axi_WID ID 1 1 }  { m_axi_m00_axi_WUSER DATA 1 1 }  { m_axi_m00_axi_ARVALID VALID 1 1 }  { m_axi_m00_axi_ARREADY READY 0 1 }  { m_axi_m00_axi_ARADDR ADDR 1 64 }  { m_axi_m00_axi_ARID ID 1 1 }  { m_axi_m00_axi_ARLEN SIZE 1 8 }  { m_axi_m00_axi_ARSIZE BURST 1 3 }  { m_axi_m00_axi_ARBURST LOCK 1 2 }  { m_axi_m00_axi_ARLOCK CACHE 1 2 }  { m_axi_m00_axi_ARCACHE PROT 1 4 }  { m_axi_m00_axi_ARPROT QOS 1 3 }  { m_axi_m00_axi_ARQOS REGION 1 4 }  { m_axi_m00_axi_ARREGION USER 1 4 }  { m_axi_m00_axi_ARUSER DATA 1 1 }  { m_axi_m00_axi_RVALID VALID 0 1 }  { m_axi_m00_axi_RREADY READY 1 1 }  { m_axi_m00_axi_RDATA FIFONUM 0 512 }  { m_axi_m00_axi_RLAST LAST 0 1 }  { m_axi_m00_axi_RID ID 0 1 }  { m_axi_m00_axi_RUSER DATA 0 1 }  { m_axi_m00_axi_RRESP RESP 0 2 }  { m_axi_m00_axi_BVALID VALID 0 1 }  { m_axi_m00_axi_BREADY READY 1 1 }  { m_axi_m00_axi_BRESP RESP 0 2 }  { m_axi_m00_axi_BID ID 0 1 }  { m_axi_m00_axi_BUSER DATA 0 1 } } }
}

set maxi_interface_dict [dict create]
dict set maxi_interface_dict m00_axi {NUM_READ_OUTSTANDING 16 NUM_WRITE_OUTSTANDING 16 MAX_READ_BURST_LENGTH 16 MAX_WRITE_BURST_LENGTH 16 READ_WRITE_MODE READ_WRITE}

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
	{ m00_axi 64 }
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
	{ m00_axi 64 }
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}
