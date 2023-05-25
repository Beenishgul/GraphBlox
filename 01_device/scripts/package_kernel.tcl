#!/usr/bin/tclsh
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

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set part_id             [lindex $argv 0]
set kernel_name         [lindex $argv 1]
set app_directory       [lindex $argv 2]
set xilinx_directory    [lindex $argv 3]
set active_ip_directory [lindex $argv 4]
set ctrl_mode           [lindex $argv 5]
set scripts_directory   [lindex $argv 6]
set package_dir      ${app_directory}/${xilinx_directory}
set log_file         ${package_dir}/generate_${kernel_name}_package.log
# =========================================================


proc color {foreground text} {
    # tput is a little Unix utility that lets you use the termcap database
    # *much* more easily...
    return [exec tput setaf $foreground]$text[exec tput sgr0]
}

proc puts_reg_info {reg_text description_text address_offset_text size_text} {
    puts "[color 5 "                        -Reg"] [color 2 "definition     "] [color 2 "${reg_text}"]"
    puts "[color 4 "                             address offset "][color 2 "${address_offset_text}"]"
    puts "[color 4 "                             size           "][color 2 "${size_text}"]"
    puts "[color 4 "                             description    "][color 2 "${description_text}"]"
}


# =========================================================
puts "========================================================="
puts "\[[color 2 "Packaging ${kernel_name} IPs....."]\] [color 1 "START!"]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 4 "Part ID   "]\] [color 2 ${part_id}]"
puts "\[[color 4 "Kernel    "]\] [color 2 ${kernel_name}]"
puts "\[[color 4 "CTRL MODE "]\] [color 2 ${ctrl_mode}]"
puts "\[[color 4 "Project   "]\] [color 2 ${xilinx_directory}]"
puts "\[[color 4 "Kernel XML"]\] [color 2 ${kernel_name}.xml]"
puts "\[[color 4 "Kernel XO "]\] [color 2 ${kernel_name}.xo]"
puts "\[[color 4 "Log File  "]\] [color 2 generate_${kernel_name}_package.log]"
puts "========================================================="

# =========================================================
# Step 1: create vivado project and add design sources
# =========================================================
puts "[color 3 "                Step 1: Create vivado project and add design sources"]" 
puts "[color 4 "                        Create Project Kernel ${kernel_name}"]" 
create_project -force $kernel_name ./$kernel_name -part $part_id >> $log_file
# =========================================================

# =========================================================
# add design sources into project
# =========================================================
puts "[color 4 "                        Add design sources into project"]" 
add_files -fileset sources_1 [read [open ${app_directory}/${scripts_directory}/${kernel_name}_filelist_package.f]] >> $log_file
add_files -fileset sim_1 [read [open ${app_directory}/${scripts_directory}/${kernel_name}_filelist_xsim.v.f]] >> $log_file
add_files -fileset sim_1 [read [open ${app_directory}/${scripts_directory}/${kernel_name}_filelist_xsim.sv.f]] >> $log_file
# add_files -fileset sim_1 [read [open ${app_directory}/${scripts_directory}/${kernel_name}_filelist_xsim.vhdl.f]] >> $log_file

puts "[color 4 "                        Set Defines ${ctrl_mode}"]"
# set_property verilog_define ${ctrl_mode} [get_filesets sources_1]
# set_property verilog_define ${ctrl_mode} [get_filesets sim_1]

puts "[color 4 "                        Update compile order: sources_1"]"
update_compile_order -fileset sources_1  >> $log_file
puts "[color 4 "                        Update compile order: sim_1"]"
update_compile_order -fileset sim_1      >> $log_file

puts "[color 4 "                        Create IP packaging project"]" 
# create IP packaging project
ipx::package_project -root_dir ./${kernel_name}_ip -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current true >> $log_file
set core [ipx::current_core]
foreach user_parameter [list C_S_AXI_CONTROL_ADDR_WIDTH C_S_AXI_CONTROL_DATA_WIDTH C_M00_AXI_ADDR_WIDTH C_M00_AXI_DATA_WIDTH] {
    ::ipx::remove_user_parameter $user_parameter $core
  }
# =========================================================
# Step 2: Inference clock, reset, AXI interfaces and associate them with clock
# =========================================================
puts "[color 3 "                Step 2: Inference clock, reset, AXI interfaces and associate them with clock"]" 

# inference clock and reset signals
puts "[color 4 "                        Inference clock and reset signals"]" 
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

::ipx::associate_bus_interfaces -busif "m00_axi" -clock "ap_clk" $core >> $log_file
::ipx::associate_bus_interfaces -busif "s_axi_control" -clock "ap_clk" $core >> $log_file

# =========================================================
# Specify the freq_hz parameter
# =========================================================
puts "[color 4 "                        Specify the freq_hz parameter"]" 
set clkbif      [::ipx::get_bus_interfaces -of $core "ap_clk"]
set clkbifparam [::ipx::add_bus_parameter -quiet "FREQ_HZ" $clkbif]

# =========================================================
# Set desired frequency
# =========================================================                   
puts "[color 4 "                        Set desired frequency "][color 5 "300000000 Hz"]"
set_property value 300000000 $clkbifparam

# =========================================================
# set value_resolve_type user if the frequency can vary.
# =========================================================
puts "[color 4 "                        Set value_resolve_type user if the frequency can vary. Type: "][color 5 "user"]"
set_property value_resolve_type user $clkbifparam

# =========================================================
# associate AXI/AXIS interface with clock
# =========================================================
puts "[color 4 "                        Associate AXI/AXIS interface with clock"]" 
ipx::associate_bus_interfaces -busif "s_axi_control"  -clock "ap_clk" $core
ipx::associate_bus_interfaces -busif "m00_axi"       -clock "ap_clk" $core

# =========================================================
# associate reset signal with clock
# =========================================================
puts "[color 4 "                        Associate reset signal with clock"]" 
ipx::associate_bus_interfaces -clock ap_clk -reset ap_rst_n $core
# =========================================================

# =========================================================
# Step 3: Set the definition of AXI control slave registers, including CTRL and user kernel arguments
# =========================================================
puts "[color 3 "                Step 3: Set the definition of AXI control slave registers,"]" 
puts "[color 3 "                        including CTRL and user kernel arguments"]" 

# =========================================================
# Add RTL kernel registers
# =========================================================
puts "[color 4 "                        Add RTL kernel registers"]" 
ipx::add_register CTRL [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects $core]]

set mem_map    [::ipx::add_memory_map -quiet "s_axi_control" $core]
set addr_block [::ipx::add_address_block -quiet "reg0" $mem_map]
set reg        [::ipx::add_register "CTRL" $addr_block]
set field      [ipx::add_field AP_START $reg]

# =========================================================
# Set RTL kernel registers property
# =========================================================
puts "[color 4 "                        Set RTL kernel registers property"]" 

puts_reg_info "CTRL" "Control signals" "0x000" 32
set reg      [::ipx::add_register "CTRL" $addr_block]
  set_property description    "Control signals"    $reg
  set_property address_offset 0x000 $reg
  set_property size           32    $reg

puts_reg_info "AP_START" "Control signal Register for ap_start." "0x001" 1
  set field [ipx::add_field AP_START $reg]
    set_property ACCESS {read-write}  $field
    set_property BIT_OFFSET {0} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for ap_start.} $field
    set_property MODIFIED_WRITE_VALUE {modify} $field

puts_reg_info "AP_DONE" "Control signal Register for ap_done." "0x002" 1
  set field [ipx::add_field AP_DONE $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {1} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for ap_done.} $field
    set_property READ_ACTION {modify} $field

puts_reg_info "AP_IDLE" "Control signal Register for ap_idle." "0x004" 1
  set field [ipx::add_field AP_IDLE $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {2} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for ap_idle.} $field
    set_property READ_ACTION {modify} $field

puts_reg_info "AP_READY" "Control signal Register for ap_ready." "0x008" 1
  set field [ipx::add_field AP_READY $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {3} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for ap_ready.} $field
    set_property READ_ACTION {modify} $field

puts_reg_info "AP_CONTINUE" "Control signal Register for ap_continue." "0x010" 1
  set field [ipx::add_field AP_CONTINUE $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {4} $field
    set_property BIT_WIDTH {1} $field
    set_property DESCRIPTION {Control signal Register for ap_continue.} $field
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
    set_property DESCRIPTION {Control signal Register for auto_restart.} $field
    set_property MODIFIED_WRITE_VALUE {modify} $field

  set field [ipx::add_field RESERVED_2 $reg]
    set_property ACCESS {read-only} $field
    set_property BIT_OFFSET {8} $field
    set_property BIT_WIDTH {24} $field
    set_property DESCRIPTION {Reserved.  0s on read.} $field
    set_property READ_ACTION {modify} $field

puts_reg_info "GIER" "Global Interrupt Enable Register" "0x004" 32
  set reg      [::ipx::add_register "GIER" $addr_block]
  set_property description    "Global Interrupt Enable Register"    $reg
  set_property address_offset 0x004 $reg
  set_property size           32    $reg

puts_reg_info "IP_IER" "IP Interrupt Enable Register" "0x008" 32
  set reg      [::ipx::add_register "IP_IER" $addr_block]
  set_property description    "IP Interrupt Enable Register"    $reg
  set_property address_offset 0x008 $reg
  set_property size           32    $reg

puts_reg_info "IP_ISR" "IP Interrupt Status Register" "0x00C" 32
  set reg      [::ipx::add_register "IP_ISR" $addr_block]
  set_property description    "IP Interrupt Status Register"    $reg
  set_property address_offset 0x00C $reg
  set_property size           32    $reg
# =========================================================

# =========================================================
# Step 4: Associate AXI master port to pointer argument and set data width
# =========================================================
puts "[color 3 "                Step 4: Associate AXI master port to pointer argument and set data width"]" 
puts "[color 3 "                        (Name, Offsets, Descriptions, and Size)"]" 
# =========================================================

puts "[color 4 "                        Set RTL kernel (${kernel_name}) registers property"]" 

puts_reg_info "graph_csr_struct" "description_text" "0x010" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "graph_csr_struct" $addr_block]
  set_property address_offset 0x010 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "vertex_out_degree" "description_text" "0x01c" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "vertex_out_degree" $addr_block]
  set_property address_offset 0x01c $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "vertex_in_degree" "description_text" "0x028" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "vertex_in_degree" $addr_block]
  set_property address_offset 0x028 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "vertex_edges_idx" "description_text" "0x034" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "vertex_edges_idx" $addr_block]
  set_property address_offset 0x034 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "edges_array_weight" "description_text" "0x040" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "edges_array_weight" $addr_block]
  set_property address_offset 0x040 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "edges_array_src" "description_text" "0x04c" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "edges_array_src" $addr_block]
  set_property address_offset 0x04c $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "edges_array_dest" "description_text" "0x058" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "edges_array_dest" $addr_block]
  set_property address_offset 0x058 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "auxiliary_1" "description_text" "0x064" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "auxiliary_1" $addr_block]
  set_property address_offset 0x064 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

puts_reg_info "auxiliary_2" "description_text" "0x070" [expr {8*8}]
  set reg      [::ipx::add_register -quiet "auxiliary_2" $addr_block]
  set_property address_offset 0x070 $reg
  set_property size           [expr {8*8}]   $reg
  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] 
  set_property value m00_axi $regparam 

  set_property slave_memory_map_ref "s_axi_control" [::ipx::get_bus_interfaces -of $core "s_axi_control"]

  set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} $core
  set_property sdx_kernel true $core
  set_property sdx_kernel_type rtl $core
# =========================================================

# =========================================================
# Step 5: Package Vivado IP and generate Vitis kernel file
# =========================================================
puts "[color 3 "                Step 5: Package Vivado IP and generate Vitis kernel file"]" 

# =========================================================
# Set required property for Vitis kernel
# =========================================================
puts "[color 4 "                        Set required property for Vitis kernel"]" 
set_property sdx_kernel true $core
set_property sdx_kernel_type rtl $core
set_property ipi_drc {ignore_freq_hz true} $core
# set_property vitis_drc {ctrl_protocol USER_MANAGED} $core

if {${ctrl_mode} == "USER_MANAGED"} {
  puts "[color 4 "                        Set ctrl mode "][color 1 "USER_MANAGED"]" 
  set_property vitis_drc {ctrl_protocol user_managed} $core
} elseif {${ctrl_mode} == "AP_CTRL_HS"} {
  puts "[color 4 "                        Set ctrl mode "][color 1 "AP_CTRL_HS"]"  
  set_property vitis_drc {ctrl_protocol ap_ctrl_hs} $core
} elseif {${ctrl_mode} == "AP_CTRL_CHAIN"} {
  puts "[color 4 "                        Set ctrl mode "][color 1 "AP_CTRL_CHAIN"]"  
  set_property vitis_drc {ctrl_protocol ap_ctrl_chain} $core
} else {
  puts "[color 4 "                        Set ctrl mode "][color 1 "USER_MANAGED"]"  
  set_property vitis_drc {ctrl_protocol user_managed} $core
}

# =========================================================
# Packaging Vivado IP
# =========================================================
puts "[color 4 "                        Packaging Vivado IP"]" 
::ipx::update_checksums $core
::ipx::check_integrity -kernel $core >> $log_file
::ipx::check_integrity -xrt $core >> $log_file
::ipx::save_core $core
::ipx::unload_core $core

# =========================================================
# Generate Vitis Kernel from Vivado IP
# =========================================================
puts "[color 4 "                        Generate Vitis Kernel from Vivado IP"]" 
# package_xo -force -xo_path ../${kernel_name}.xo -kernel_name ${kernel_name} -ctrl_protocol USER_MANAGED -ip_directory ./${kernel_name}_ip -output_kernel_xml ../${kernel_name}.xml >> $log_file

if {${ctrl_mode} == "USER_MANAGED"} {
  package_xo -force -xo_path ./${kernel_name}.xo -kernel_name ${kernel_name} -ctrl_protocol user_managed -ip_directory ./${kernel_name}_ip -output_kernel_xml ./${kernel_name}.xml >> $log_file
} elseif {${ctrl_mode} == "AP_CTRL_HS"} {
  package_xo -force -xo_path ./${kernel_name}.xo -kernel_name ${kernel_name} -ctrl_protocol ap_ctrl_hs -ip_directory ./${kernel_name}_ip -output_kernel_xml ./${kernel_name}.xml >> $log_file
} elseif {${ctrl_mode} == "AP_CTRL_CHAIN"} { 
  package_xo -force -xo_path ./${kernel_name}.xo -kernel_name ${kernel_name} -ctrl_protocol ap_ctrl_chain -ip_directory ./${kernel_name}_ip -output_kernel_xml ./${kernel_name}.xml >> $log_file
} else {
  package_xo -force -xo_path ./${kernel_name}.xo -kernel_name ${kernel_name} -ctrl_protocol user_managed -ip_directory ./${kernel_name}_ip -output_kernel_xml ./${kernel_name}.xml >> $log_file
}
# =========================================================

puts "========================================================="
puts "\[[color 4 "Part ID   "]\] [color 2 ${part_id}]"
puts "\[[color 4 "Kernel    "]\] [color 2 ${kernel_name}]"
puts "\[[color 4 "CTRL MODE "]\] [color 2 ${ctrl_mode}]"
puts "\[[color 4 "Project   "]\] [color 2 ${xilinx_directory}]"
puts "\[[color 4 "Kernel XML"]\] [color 2 ${kernel_name}.xml]"
puts "\[[color 4 "Kernel XO "]\] [color 2 ${kernel_name}.xo]"
puts "\[[color 4 "Log File  "]\] [color 2 generate_${kernel_name}_package.log]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 2 "Packaging ${kernel_name} IPs....."]\] [color 1 "DONE!"]"
puts "========================================================="