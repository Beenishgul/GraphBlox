# This script segment is generated automatically by AutoPilot

set axilite_register_dict [dict create]
set port_control {
graph_csr_struct { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 16
	offset_end 27
}
vertex_out_degree { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 28
	offset_end 39
}
vertex_in_degree { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 40
	offset_end 51
}
vertex_edges_idx { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 52
	offset_end 63
}
edges_array_weight { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 64
	offset_end 75
}
edges_array_src { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 76
	offset_end 87
}
edges_array_dest { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 88
	offset_end 99
}
auxiliary_1 { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 100
	offset_end 111
}
auxiliary_2 { 
	dir I
	width 64
	depth 1
	mode ap_none
	offset 112
	offset_end 123
}
ap_start { }
ap_done { }
ap_ready { }
ap_continue { }
ap_idle { }
interrupt {
}
}
dict set axilite_register_dict control $port_control


