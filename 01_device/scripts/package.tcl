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
set part_id          [lindex $argv 0]
set kernel_name      [lindex $argv 1]
set app_directory    [lindex $argv 2]
set xilinx_directory [lindex $argv 3]
set active_directory [lindex $argv 4]
set ip_directory     [lindex $argv 5]
set ctrl_mode     "user_managed"

puts $part_id
puts $kernel_name
puts $app_directory
puts $xilinx_directory
puts $active_directory
puts $ip_directory
puts $ctrl_mode

create_project -force $kernel_name ./$kernel_name -part $part_id

# add design sources into project
add_files -fileset sources_1 [read [open ${app_directory}/${kernel_name}_scripts/${kernel_name}_filelist_package.f]]

update_compile_order -fileset sources_1 
# create IP packaging project
ipx::package_project -root_dir ./${kernel_name}_ip -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current true

set core       [ipx::current_core]

foreach user_parameter [list C_S_AXI_CONTROL_ADDR_WIDTH C_S_AXI_CONTROL_DATA_WIDTH C_M00_AXI_ADDR_WIDTH C_M00_AXI_DATA_WIDTH] {
    ::ipx::remove_user_parameter $user_parameter $core
  }
##################################### Step 2: Inference clock, reset, AXI interfaces and associate them with clock

# inference clock and reset signals
set bif      [::ipx::get_bus_interfaces -of $core  "m00_axi"] 
set bifparam [::ipx::add_bus_parameter -quiet "MAX_BURST_LENGTH" $bif]
set_property value        64           $bifparam
set_property value_source constant     $bifparam
set bifparam [::ipx::add_bus_parameter -quiet "NUM_READ_OUTSTANDING" $bif]
set_property value        32           $bifparam
set_property value_source constant     $bifparam
set bifparam [::ipx::add_bus_parameter -quiet "NUM_WRITE_OUTSTANDING" $bif]
set_property value        32           $bifparam
set_property value_source constant     $bifparam

::ipx::associate_bus_interfaces -busif "m00_axi" -clock "ap_clk" $core
::ipx::associate_bus_interfaces -busif "s_axi_control" -clock "ap_clk" $core

# Specify the freq_hz parameter 
set clkbif      [::ipx::get_bus_interfaces -of [ipx::current_core] "ap_clk"]
set clkbifparam [::ipx::add_bus_parameter -quiet "FREQ_HZ" $clkbif]
# Set desired frequency                   
set_property value 300000000 $clkbifparam
# set value_resolve_type 'user' if the frequency can vary. 
set_property value_resolve_type user $clkbifparam

# associate AXI/AXIS interface with clock
ipx::associate_bus_interfaces -busif "s_axi_control"  -clock "ap_clk" [ipx::current_core]
ipx::associate_bus_interfaces -busif "m00_axi"       -clock "ap_clk" [ipx::current_core]

# associate reset signal with clock
ipx::associate_bus_interfaces -clock ap_clk -reset ap_rst_n [ipx::current_core]


##################################### Step 3: Set the definition of AXI control slave registers, including CTRL and user kernel arguments

# Add RTL kernel registers
ipx::add_register CTRL                    [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]


set mem_map    [::ipx::add_memory_map -quiet "s_axi_control" $core]
set addr_block [::ipx::add_address_block -quiet "reg0" $mem_map]
set reg        [::ipx::add_register "CTRL" $addr_block]
set field      [ipx::add_field AP_START $reg]

# Set RTL kernel registers property
set reg      [::ipx::add_register "CTRL" $addr_block]
  set_property description    "Control signals"    $reg
  set_property address_offset 0x000 $reg
  set_property size           32    $reg

set field [ipx::add_field AP_START $reg]
    set_property ACCESS {read-write}  $field
    set_property BIT_OFFSET {0} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for 'ap_start'.} $field
    set_property MODIFIED_WRITE_VALUE {modify} $field
  set field [ipx::add_field AP_DONE $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {1} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for 'ap_done'.} $field
    set_property READ_ACTION {modify} $field
  set field [ipx::add_field AP_IDLE $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {2} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for 'ap_idle'.} $field
    set_property READ_ACTION {modify} $field
  set field [ipx::add_field AP_READY $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {3} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for 'ap_ready'.} $field
    set_property READ_ACTION {modify} $field
  set field [ipx::add_field AP_CONTINUE $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {4} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for 'ap_continue'.} $field
    set_property READ_ACTION {modify} $field
  set field [ipx::add_field RESERVED_1 $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {5} $field
    set_property BIT_WIDTH {2} $field
    set_property DESCRIPTION {Reserved.  0s on read.} $field
    set_property READ_ACTION {modify} $field
  set field [ipx::add_field AUTO_RESTART $reg]
    set_property ACCESS {read-write} $field
    set_property BIT_OFFSET {7} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for 'auto_restart'.} $field
    set_property MODIFIED_WRITE_VALUE {modify} $field
  set field [ipx::add_field RESERVED_2 $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {8} $field
    set_property BIT_WIDTH {24} $field
    set_property DESCRIPTION {Reserved.  0s on read.} $field
    set_property READ_ACTION {modify} $field

  set reg      [::ipx::add_register "GIER" $addr_block]
  set_property description    "Global Interrupt Enable Register"    $reg
  set_property address_offset 0x004 $reg
  set_property size           32    $reg

  set reg      [::ipx::add_register "IP_IER" $addr_block]
  set_property description    "IP Interrupt Enable Register"    $reg
  set_property address_offset 0x008 $reg
  set_property size           32    $reg

  set reg      [::ipx::add_register "IP_ISR" $addr_block]
  set_property description    "IP Interrupt Status Register"    $reg
  set_property address_offset 0x00C $reg
  set_property size           32    $reg

  set reg      [::ipx::add_register -quiet "graph_csr_struct" $addr_block]
  set_property address_offset 0x010 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "vertex_out_degree" $addr_block]
  set_property address_offset 0x01c $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "vertex_in_degree" $addr_block]
  set_property address_offset 0x028 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "vertex_edges_idx" $addr_block]
  set_property address_offset 0x034 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "edges_array_weight" $addr_block]
  set_property address_offset 0x040 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "edges_array_src" $addr_block]
  set_property address_offset 0x04c $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "edges_array_dest" $addr_block]
  set_property address_offset 0x058 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "auxiliary_1" $addr_block]
  set_property address_offset 0x064 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set reg      [::ipx::add_register -quiet "auxiliary_2" $addr_block]
  set_property address_offset 0x070 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set_property slave_memory_map_ref "s_axi_control" [::ipx::get_bus_interfaces -of $core "s_axi_control"]

  set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} $core
  set_property sdx_kernel true $core
  set_property sdx_kernel_type rtl $core

#### Step 5: Package Vivado IP and generate Vitis kernel file

# Set required property for Vitis kernel
set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
set_property vitis_drc {ctrl_protocol user_managed} [ipx::current_core]

# Packaging Vivado IP
::ipx::update_checksums $core
::ipx::check_integrity -kernel $core
::ipx::check_integrity -xrt $core
::ipx::save_core $core
::ipx::unload_core $core
# Generate Vitis Kernel from Vivado IP
package_xo -force -xo_path ../${kernel_name}.xo -kernel_name ${kernel_name} -ctrl_protocol user_managed -ip_directory ./${kernel_name}_ip -output_kernel_xml ../${kernel_name}.xml