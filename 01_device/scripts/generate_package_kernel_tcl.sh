#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_package_kernel_tcl.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME IP_DIR"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  SCRIPTS_DIR: scripts"
  echo "  KERNEL_NAME: glay_kernel"
  echo "  IP_DIR: IP"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3
IP_DIR=$4
CTRL_MODE=$5

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_package_kernel.tcl"

echo -e '#!/usr/bin/tclsh' > ${CFG_FILE_NAME}
echo -e '#' >> ${CFG_FILE_NAME}
echo -e '# Copyright 2021 Xilinx, Inc.' >> ${CFG_FILE_NAME}
echo -e '#' >> ${CFG_FILE_NAME}
echo -e '# Licensed under the Apache License, Version 2.0 (the "License");' >> ${CFG_FILE_NAME}
echo -e '# you may not use this file except in compliance with the License.' >> ${CFG_FILE_NAME}
echo -e '# You may obtain a copy of the License at' >> ${CFG_FILE_NAME}
echo -e '#' >> ${CFG_FILE_NAME}
echo -e '#     http://www.apache.org/licenses/LICENSE-2.0' >> ${CFG_FILE_NAME}
echo -e '#' >> ${CFG_FILE_NAME}
echo -e '# Unless required by applicable law or agreed to in writing, software' >> ${CFG_FILE_NAME}
echo -e '# distributed under the License is distributed on an "AS IS" BASIS,' >> ${CFG_FILE_NAME}
echo -e '# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.' >> ${CFG_FILE_NAME}
echo -e '# See the License for the specific language governing permissions and' >> ${CFG_FILE_NAME}
echo -e '# limitations under the License.' >> ${CFG_FILE_NAME}
echo -e '#' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '##################################### Step 1: create vivado project and add design sources' >> ${CFG_FILE_NAME}
echo -e '# create ip project with part name in command line argvs' >> ${CFG_FILE_NAME}
echo -e 'set part_id          [lindex $argv 0]' >> ${CFG_FILE_NAME}
echo -e 'set kernel_name      [lindex $argv 1]' >> ${CFG_FILE_NAME}
echo -e 'set app_directory    [lindex $argv 2]' >> ${CFG_FILE_NAME}
echo -e 'set xilinx_directory [lindex $argv 3]' >> ${CFG_FILE_NAME}
echo -e 'set active_directory [lindex $argv 4]' >> ${CFG_FILE_NAME}
echo -e 'set ip_directory     [lindex $argv 5]' >> ${CFG_FILE_NAME}
echo -e 'set ctrl_mode        [lindex $argv 6]' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e 'puts $part_id' >> ${CFG_FILE_NAME}
echo -e 'puts $kernel_name' >> ${CFG_FILE_NAME}
echo -e 'puts $app_directory' >> ${CFG_FILE_NAME}
echo -e 'puts $xilinx_directory' >> ${CFG_FILE_NAME}
echo -e 'puts $active_directory' >> ${CFG_FILE_NAME}
echo -e 'puts $ip_directory' >> ${CFG_FILE_NAME}
echo -e 'puts $ctrl_mode' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e 'create_project -force $kernel_name ./$kernel_name -part $part_id' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# add design sources into project' >> ${CFG_FILE_NAME}
echo -e 'add_files -fileset sources_1 [read [open ${app_directory}/scripts/${kernel_name}_filelist_package.f]]' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# set_property source_mgmt_mode None [current_project]' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e 'update_compile_order -fileset sources_1 ' >> ${CFG_FILE_NAME}
echo -e '# create IP packaging project' >> ${CFG_FILE_NAME}
echo -e 'ipx::package_project -root_dir ./${kernel_name}_ip -vendor xilinx.com -library user -taxonomy /UserIP -import_files -set_current true' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e 'set core [ipx::current_core]' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e 'foreach user_parameter [list C_S_AXI_CONTROL_ADDR_WIDTH C_S_AXI_CONTROL_DATA_WIDTH C_M00_AXI_ADDR_WIDTH C_M00_AXI_DATA_WIDTH] {' >> ${CFG_FILE_NAME}
echo -e '    ::ipx::remove_user_parameter $user_parameter $core' >> ${CFG_FILE_NAME}
echo -e '  }' >> ${CFG_FILE_NAME}
echo -e '##################################### Step 2: Inference clock, reset, AXI interfaces and associate them with clock' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# inference clock and reset signals' >> ${CFG_FILE_NAME}
echo -e 'set bif      [::ipx::get_bus_interfaces -of $core  "m00_axi"] ' >> ${CFG_FILE_NAME}
echo -e 'set bifparam [::ipx::add_bus_parameter -quiet "MAX_BURST_LENGTH" $bif]' >> ${CFG_FILE_NAME}
echo -e 'set_property value        64           $bifparam' >> ${CFG_FILE_NAME}
echo -e 'set_property value_source constant     $bifparam' >> ${CFG_FILE_NAME}
echo -e 'set bifparam [::ipx::add_bus_parameter -quiet "NUM_READ_OUTSTANDING" $bif]' >> ${CFG_FILE_NAME}
echo -e 'set_property value        32           $bifparam' >> ${CFG_FILE_NAME}
echo -e 'set_property value_source constant     $bifparam' >> ${CFG_FILE_NAME}
echo -e 'set bifparam [::ipx::add_bus_parameter -quiet "NUM_WRITE_OUTSTANDING" $bif]' >> ${CFG_FILE_NAME}
echo -e 'set_property value        32           $bifparam' >> ${CFG_FILE_NAME}
echo -e 'set_property value_source constant     $bifparam' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '::ipx::associate_bus_interfaces -busif "m00_axi" -clock "ap_clk" $core' >> ${CFG_FILE_NAME}
echo -e '::ipx::associate_bus_interfaces -busif "s_axi_control" -clock "ap_clk" $core' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# Specify the freq_hz parameter ' >> ${CFG_FILE_NAME}
echo -e 'set clkbif      [::ipx::get_bus_interfaces -of $core "ap_clk"]' >> ${CFG_FILE_NAME}
echo -e 'set clkbifparam [::ipx::add_bus_parameter -quiet "FREQ_HZ" $clkbif]' >> ${CFG_FILE_NAME}
echo -e '# Set desired frequency                   ' >> ${CFG_FILE_NAME}
echo -e 'set_property value 300000000 $clkbifparam' >> ${CFG_FILE_NAME}
echo -e '# set value_resolve_type 'user' if the frequency can vary. ' >> ${CFG_FILE_NAME}
echo -e 'set_property value_resolve_type user $clkbifparam' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# associate AXI/AXIS interface with clock' >> ${CFG_FILE_NAME}
echo -e 'ipx::associate_bus_interfaces -busif "s_axi_control"  -clock "ap_clk" $core' >> ${CFG_FILE_NAME}
echo -e 'ipx::associate_bus_interfaces -busif "m00_axi"       -clock "ap_clk" $core' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# associate reset signal with clock' >> ${CFG_FILE_NAME}
echo -e 'ipx::associate_bus_interfaces -clock ap_clk -reset ap_rst_n $core' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '##################################### Step 3: Set the definition of AXI control slave registers, including CTRL and user kernel arguments' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# Add RTL kernel registers' >> ${CFG_FILE_NAME}
echo -e 'ipx::add_register CTRL [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects $core]]' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e 'set mem_map    [::ipx::add_memory_map -quiet "s_axi_control" $core]' >> ${CFG_FILE_NAME}
echo -e 'set addr_block [::ipx::add_address_block -quiet "reg0" $mem_map]' >> ${CFG_FILE_NAME}
echo -e 'set reg        [::ipx::add_register "CTRL" $addr_block]' >> ${CFG_FILE_NAME}
echo -e 'set field      [ipx::add_field AP_START $reg]' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# Set RTL kernel registers property' >> ${CFG_FILE_NAME}
echo -e 'set reg      [::ipx::add_register "CTRL" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property description    "Control signals"    $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x000 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           32    $reg' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e 'set field [ipx::add_field AP_START $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-write}  $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {0} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {1} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Control signal Register for 'ap_start'.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property MODIFIED_WRITE_VALUE {modify} $field' >> ${CFG_FILE_NAME}
echo -e '  set field [ipx::add_field AP_DONE $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-only} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {1} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {1} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Control signal Register for 'ap_done'.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property READ_ACTION {modify} $field' >> ${CFG_FILE_NAME}
echo -e '  set field [ipx::add_field AP_IDLE $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-only} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {2} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {1} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Control signal Register for 'ap_idle'.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property READ_ACTION {modify} $field' >> ${CFG_FILE_NAME}
echo -e '  set field [ipx::add_field AP_READY $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-only} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {3} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {1} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Control signal Register for 'ap_ready'.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property READ_ACTION {modify} $field' >> ${CFG_FILE_NAME}
echo -e '  set field [ipx::add_field AP_CONTINUE $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-only} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {4} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {1} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Control signal Register for 'ap_continue'.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property READ_ACTION {modify} $field' >> ${CFG_FILE_NAME}
echo -e '  set field [ipx::add_field RESERVED_1 $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-only} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {5} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {2} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Reserved.  0s on read.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property READ_ACTION {modify} $field' >> ${CFG_FILE_NAME}
echo -e '  set field [ipx::add_field AUTO_RESTART $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-write} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {7} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {1} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Control signal Register for 'auto_restart'.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property MODIFIED_WRITE_VALUE {modify} $field' >> ${CFG_FILE_NAME}
echo -e '  set field [ipx::add_field RESERVED_2 $reg]' >> ${CFG_FILE_NAME}
echo -e '    set_property ACCESS {read-only} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_OFFSET {8} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property BIT_WIDTH {24} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property DESCRIPTION {Reserved.  0s on read.} $field' >> ${CFG_FILE_NAME}
echo -e '    set_property READ_ACTION {modify} $field' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register "GIER" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property description    "Global Interrupt Enable Register"    $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x004 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           32    $reg' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register "IP_IER" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property description    "IP Interrupt Enable Register"    $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x008 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           32    $reg' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register "IP_ISR" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property description    "IP Interrupt Status Register"    $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x00C $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           32    $reg' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "graph_csr_struct" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x010 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "vertex_out_degree" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x01c $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "vertex_in_degree" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x028 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "vertex_edges_idx" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x034 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "edges_array_weight" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x040 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "edges_array_src" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x04c $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "edges_array_dest" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x058 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "auxiliary_1" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x064 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set reg      [::ipx::add_register -quiet "auxiliary_2" $addr_block]' >> ${CFG_FILE_NAME}
echo -e '  set_property address_offset 0x070 $reg' >> ${CFG_FILE_NAME}
echo -e '  set_property size           [expr {8*8}]   $reg' >> ${CFG_FILE_NAME}
echo -e '  set regparam [::ipx::add_register_parameter -quiet {ASSOCIATED_BUSIF} $reg] ' >> ${CFG_FILE_NAME}
echo -e '  set_property value m00_axi $regparam ' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set_property slave_memory_map_ref "s_axi_control" [::ipx::get_bus_interfaces -of $core "s_axi_control"]' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '  set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} $core' >> ${CFG_FILE_NAME}
echo -e '  set_property sdx_kernel true $core' >> ${CFG_FILE_NAME}
echo -e '  set_property sdx_kernel_type rtl $core' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '#### Step 5: Package Vivado IP and generate Vitis kernel file' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# Set required property for Vitis kernel' >> ${CFG_FILE_NAME}
echo -e 'set_property sdx_kernel true $core' >> ${CFG_FILE_NAME}
echo -e 'set_property sdx_kernel_type rtl $core' >> ${CFG_FILE_NAME}
echo -e 'set_property ipi_drc {ignore_freq_hz true} $core' >> ${CFG_FILE_NAME}
echo -e 'set_property vitis_drc {ctrl_protocol glay_ctrl_mode} $core' >> ${CFG_FILE_NAME}
echo -e '' >> ${CFG_FILE_NAME}
echo -e '# Packaging Vivado IP' >> ${CFG_FILE_NAME}
echo -e '::ipx::update_checksums $core' >> ${CFG_FILE_NAME}
echo -e '::ipx::check_integrity -kernel $core' >> ${CFG_FILE_NAME}
echo -e '::ipx::check_integrity -xrt $core' >> ${CFG_FILE_NAME}
echo -e '::ipx::save_core $core' >> ${CFG_FILE_NAME}
echo -e '::ipx::unload_core $core' >> ${CFG_FILE_NAME}
echo -e '# Generate Vitis Kernel from Vivado IP' >> ${CFG_FILE_NAME}
echo -e 'package_xo -force -xo_path ../${kernel_name}.xo -kernel_name ${kernel_name} -ctrl_protocol glay_ctrl_mode -ip_directory ./${kernel_name}_ip -output_kernel_xml ../${kernel_name}.xml' >> ${CFG_FILE_NAME}



newtext="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_package_kernel.tcl"
search="glay_ctrl_mode"
replace=${CTRL_MODE}
if [[ $search != "" && $replace != "" ]]; then
sed -i "s/$search/$replace/" $newtext
fi
# echo -e $newtext >> ${CFG_FILE_NAME}

