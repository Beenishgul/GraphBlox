#
# Copyright 2021 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


##################################### Step 1: create vivado project and add design sources

# create ip project with part name in command line argvs



create_project -force glay_kernel ./glay_kernel -part [lindex $argv 0]

# add design sources into project
add_files \
        {                                           \
              ../../IP/iob_cache/iob_include        \
              ../../IP/glay_pkgs                    \
              ../../IP/glay_kernel                  \
              ../../IP/glay_top                     \
       }

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# create IP packaging project
ipx::package_project -root_dir ./glay_kernel_ip -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current true


##################################### Step 2: Inference clock, reset, AXI interfaces and associate them with clock

# inference clock and reset signals
ipx::infer_bus_interface ap_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface ap_rst_n xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

# associate AXI/AXIS interface with clock
ipx::associate_bus_interfaces -busif s_axi_control  -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif m00_axi       -clock ap_clk [ipx::current_core]

# associate reset signal with clock
ipx::associate_bus_interfaces -clock ap_clk -reset ap_rst_n [ipx::current_core]


##################################### Step 3: Set the definition of AXI control slave registers, including CTRL and user kernel arguments

# Add RTL kernel registers
ipx::add_register CTRL                    [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register GRAPH_CSR_STRUCT        [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register VERTEX_OUT_DEGREE       [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register VERTEX_IN_DEGREE        [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register VERTEX_EDGES_IDX        [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register EDGES_ARRAY_WEIGHT      [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register EDGES_ARRAY_SRC         [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register EDGES_ARRAY_DEST        [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register AUXILIARY_1             [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
ipx::add_register AUXILIARY_2             [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]


# Set RTL kernel registers property
set_property description    {Control Signals}           [ipx::get_registers CTRL    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x000}                     [ipx::get_registers CTRL    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {32}                        [ipx::get_registers CTRL    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {Graph CSR struct}          [ipx::get_registers GRAPH_CSR_STRUCT    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x010}                     [ipx::get_registers GRAPH_CSR_STRUCT    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers GRAPH_CSR_STRUCT    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {vertex_out_degree}         [ipx::get_registers VERTEX_OUT_DEGREE    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x01c}                     [ipx::get_registers VERTEX_OUT_DEGREE    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers VERTEX_OUT_DEGREE    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {vertex_in_degree}          [ipx::get_registers VERTEX_IN_DEGREE    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x028}                     [ipx::get_registers VERTEX_IN_DEGREE    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers VERTEX_IN_DEGREE    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {vertex_edges_idx}          [ipx::get_registers VERTEX_EDGES_IDX    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x034}                     [ipx::get_registers VERTEX_EDGES_IDX    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers VERTEX_EDGES_IDX    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {edges_array_weight}        [ipx::get_registers EDGES_ARRAY_WEIGHT    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x040}                     [ipx::get_registers EDGES_ARRAY_WEIGHT    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers EDGES_ARRAY_WEIGHT    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {edges_array_src}           [ipx::get_registers EDGES_ARRAY_SRC    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x04c}                     [ipx::get_registers EDGES_ARRAY_SRC    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers EDGES_ARRAY_SRC    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {edges_array_dest}          [ipx::get_registers EDGES_ARRAY_DEST    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x058}                     [ipx::get_registers EDGES_ARRAY_DEST    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers EDGES_ARRAY_DEST    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {auxiliary_1}               [ipx::get_registers AUXILIARY_1    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x064}                     [ipx::get_registers AUXILIARY_1    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers AUXILIARY_1    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set_property description    {auxiliary_2}               [ipx::get_registers AUXILIARY_2    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property address_offset {0x070}                     [ipx::get_registers AUXILIARY_2    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           {64}                        [ipx::get_registers AUXILIARY_2    -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]



##################################### Step 4: associate AXI master port to pointer argument and set data width

# define association between pointer arguments  and axi masters (m00_axi)
ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers GRAPH_CSR_STRUCT -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers GRAPH_CSR_STRUCT              \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]

ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers VERTEX_OUT_DEGREE -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers VERTEX_OUT_DEGREE             \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]


ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers VERTEX_IN_DEGREE -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers VERTEX_IN_DEGREE              \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]

ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers VERTEX_EDGES_IDX -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers VERTEX_EDGES_IDX              \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]

ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers EDGES_ARRAY_WEIGHT -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers EDGES_ARRAY_WEIGHT            \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]

ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers EDGES_ARRAY_SRC -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers EDGES_ARRAY_SRC               \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]

ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers EDGES_ARRAY_DEST -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers EDGES_ARRAY_DEST              \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]

ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers AUXILIARY_1 -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers AUXILIARY_1                   \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]

ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers AUXILIARY_2 -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property value          {m00_axi}          [ipx::get_register_parameters ASSOCIATED_BUSIF     \
                                    -of_objects [ipx::get_registers AUXILIARY_2                   \
                                    -of_objects [ipx::get_address_blocks reg0                     \
                                    -of_objects [ipx::get_memory_maps s_axi_control               \
                                    -of_objects [ipx::current_core]]]]]


ipx::add_bus_parameter DATA_WIDTH [ipx::get_bus_interfaces m00_axi -of_objects [ipx::current_core]]
set_property value          {512} [ipx::get_bus_parameters DATA_WIDTH -of_objects [ipx::get_bus_interfaces m00_axi -of_objects [ipx::current_core]]]

ipx::add_bus_parameter ADDR_WIDTH [ipx::get_bus_interfaces m00_axi -of_objects [ipx::current_core]]
set_property value          {64}  [ipx::get_bus_parameters ADDR_WIDTH -of_objects [ipx::get_bus_interfaces m00_axi -of_objects [ipx::current_core]]]

ipx::add_bus_parameter ID_WIDTH   [ipx::get_bus_interfaces m00_axi -of_objects [ipx::current_core]]
set_property value          {1} [ipx::get_bus_parameters ID_WIDTH -of_objects [ipx::get_bus_interfaces m00_axi -of_objects [ipx::current_core]]]

ipx::add_bus_parameter ADDR_WIDTH   [ipx::get_bus_interfaces s_axi_control -of_objects [ipx::current_core]]
set_property value          {12} [ipx::get_bus_parameters ADDR_WIDTH -of_objects [ipx::get_bus_interfaces s_axi_control -of_objects [ipx::current_core]]]

ipx::add_bus_parameter DATA_WIDTH   [ipx::get_bus_interfaces s_axi_control -of_objects [ipx::current_core]]
set_property value          {32} [ipx::get_bus_parameters DATA_WIDTH -of_objects [ipx::get_bus_interfaces s_axi_control -of_objects [ipx::current_core]]]



#### Step 5: Package Vivado IP and generate Vitis kernel file

# Set required property for Vitis kernel
set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_chain} [ipx::current_core]

# Packaging Vivado IP
ipx::update_source_project_archive -component [ipx::current_core]
ipx::save_core [ipx::current_core]

# Generate Vitis Kernel from Vivado IP
package_xo -force -xo_path ../glay_kernel.xo -kernel_name glay_kernel -ctrl_protocol ap_ctrl_chain -ip_directory ./glay_kernel_ip -output_kernel_xml ../glay_kernel.xml