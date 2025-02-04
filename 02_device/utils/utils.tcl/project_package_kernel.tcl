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
set ACTIVE_PARAMS_TCL_DIR                  [lindex $argv 0]

source ${ACTIVE_PARAMS_TCL_DIR}

set package_full_dir ${APP_DIR_ACTIVE}/${VIVADO_PACKAGE_DIR}
set log_file         ${package_full_dir}/generate_${KERNEL_NAME}_package.log
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

proc add_filelist_if_exists {group filename log_file} {
   if { [file exists ${filename}] == 1} {               
       add_files -scan_for_includes -fileset $group [read [open ${filename}]] >> $log_file
       import_files -fileset $group [read [open ${filename}]] >> $log_file
   }
}

# =========================================================
puts "========================================================="
puts "\[[color 2 "Packaging ${KERNEL_NAME} IPs....."]\] [color 1 "START!"]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 4 "ARCHITECTURE      "]\] [color 2 ${ARCHITECTURE}]"
puts "\[[color 4 "CAPABILITY        "]\] [color 2 ${CAPABILITY}]"
puts "\[[color 4 "ALGORITHM_NAME    "]\] [color 2 ${ALGORITHM_NAME}]"
puts "========================================================="
puts "\[[color 4 "ALVEO ID          "]\] [color 2 ${ALVEO}]"
puts "\[[color 4 "PART ID           "]\] [color 2 ${PART}]"
puts "\[[color 4 "KERNEL_NAME       "]\] [color 2 ${KERNEL_NAME}]"
puts "\[[color 4 "XILINX_CTRL_MODE  "]\] [color 2 ${XILINX_CTRL_MODE}]"
puts "\[[color 4 "DESIGN_FREQ_HZ    "]\] [color 2 ${DESIGN_FREQ_HZ}]"
puts "\[[color 4 "VIVADO_PACKAGE_DIR"]\] [color 2 ${VIVADO_PACKAGE_DIR}]"
puts "\[[color 4 "KERNEL_NAME.XML   "]\] [color 2 ${KERNEL_NAME}.xml]"
puts "\[[color 4 "KERNEL_NAME.XO    "]\] [color 2 ${KERNEL_NAME}.xo]"
puts "\[[color 4 "Log File          "]\] [color 2 generate_${KERNEL_NAME}_package.log]"
puts "\[[color 4 "VIVADO_VER        "]\] [color 2 ${VIVADO_VER}]"
puts "\[[color 4 "GIT_VER           "]\] [color 2 ${GIT_VER}]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 2 "Packaging ${KERNEL_NAME} IPs....."]\] [color 1 "START!"]"
puts "========================================================="

# =========================================================
# Step 1: create vivado project and add design sources
# =========================================================
puts "[color 3 "                Step 1: Create vivado project and add design sources"]" 
puts "[color 4 "                        Create Project Kernel ${KERNEL_NAME}"]" 
create_project -force $KERNEL_NAME ${package_full_dir}/${KERNEL_NAME} -part $PART >> $log_file

# # set_part $PART
# set_property PART $PART [current_project]

# if {${ALVEO} == "U250"} {
#   set board_part_var "xilinx.com:au250:part0:1.4" 
#   puts "[color 4 "                        Set board part "][color 1 ${board_part_var}]" 
#   set_property board_part $board_part_var [current_project] >> $log_file
# } elseif {${ALVEO} == "U280"} {

#   set board_part_var "xilinx.com:au280:part0:1.3" 
#   puts "[color 4 "                        Set board part "][color 1 ${board_part_var}]"  
#   set_property board_part $board_part_var [current_project] >> $log_file
# } elseif {${ALVEO} == "U55"} {

#   set board_part_var "xilinx.com:au55c:part0:1.0"
#   puts "[color 4 "                        Set board part "][color 1 ${board_part_var}]"  
#   set_property board_part $board_part_var [current_project] >> $log_file
# } else {
#   set board_part_var "NONE" 
#   puts "[color 4 "                        NOT Set board part "][color 1 ${board_part_var}]"  
#   # set_property board_part $board_part_var [current_project]
# }

set_property default_lib xil_defaultlib [current_project] >> $log_file

# =========================================================
# Generate Project VIPs
# =========================================================
puts "[color 4 "                        Add Project VIPs"]"
# set ip_repo_list [get_property IP_REPO_PATHS [current_project]] 
set vivado_dir $::env(XILINX_VIVADO)
set vitis_dir $::env(XILINX_VITIS)

# set ip_repo_ert_firmware [file normalize $vivado_dir/data/emulation/hw_em/ip_repo_ert_firmware]
# set cache_xilinx         [file normalize $vitis_dir/data/cache/xilinx]
# set data_ip              [file normalize $vitis_dir/data/ip]
# set hw_em_ip_repo        [file normalize $vivado_dir/data/emulation/hw_em/ip_repo]
# set vip_repo             [file normalize $APP_DIR_ACTIVE/$VIVADO_VIP_DIR] 

# set ip_repo_list [concat $vip_repo $ip_repo_ert_firmware $cache_xilinx $hw_em_ip_repo $data_ip]
# set ip_repo_list [concat $vip_repo $data_ip]

# set_property IP_REPO_PATHS "$ip_repo_list" [current_project] 
# update_ip_catalog >> $log_file

# =========================================================
# Add IP and design sources into project
# =========================================================
puts "[color 4 "                        Add VIP into project"]"
set argv [list ${ACTIVE_PARAMS_TCL_DIR} ${package_full_dir}]
set argc 2
source ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/project_generate_vip.tcl 

# Construct the path to the Python script
set XCI_XDC_PythonScriptPath "${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_PYTHON}/generate_xci_xdc_filelist_f.py"

# Use catch to handle any errors that occur during execution
if {[catch {exec python3 ${XCI_XDC_PythonScriptPath} ${ACTIVE_PARAMS_SH_DIR}} result]} {
    # If an error occurs, print the error message
    puts "An error occurred in the Python command: $result ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_PYTHON}/generate_xci_xdc_filelist_f.py"
} else {
    # If the command succeeds, you can use the result if needed
    puts "[color 4 "                        Add design XCI/XDC into project ${KERNEL_NAME}"]" 
}

puts "[color 4 "                        Add design sources into project ${KERNEL_NAME}"]" 
add_filelist_if_exists sources_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.vh.f $log_file
add_filelist_if_exists sources_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.src.f $log_file
add_filelist_if_exists sources_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.xci.f $log_file
# add_filelist_if_exists sources_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.xdc.f $log_file

puts "[color 4 "                        Add design sources into sim_1 ${KERNEL_NAME}"]" 
add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.v.f $log_file
add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.sv.f $log_file
add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.vhdl.f $log_file
add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.vh.f $log_file
# add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.xci.f $log_file
add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.v.f $log_file
add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.sv.f $log_file
add_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.vhdl.f $log_file

puts "[color 4 "                        Add design xdc into constrs_1"]" 
add_filelist_if_exists constrs_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.xdc.f $log_file

puts "[color 4 "                        Set Simulator ${KERNEL_NAME} settings"]"
set_property top ${KERNEL_NAME}_testbench [get_filesets sim_1]

# set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property simulator_language "Mixed" [current_project]
set_property target_language  "Verilog" [current_project]
set_property TARGET_SIMULATOR XSim [current_project]
set_property INCREMENTAL true [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.no_quit} -value {true} -objects [get_filesets sim_1]

puts "[color 4 "                        Update compile order: sources_1"]"
update_compile_order -fileset sources_1  >> $log_file

puts "[color 4 "                        Update compile order: constrs_1"]"
update_compile_order -fileset constrs_1  >> $log_file

puts "[color 4 "                        Update compile order: sim_1"]"
update_compile_order -fileset sim_1      >> $log_file

puts "[color 4 "                        Create OOC synthesis: synth_1"]"
# set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context -directive sdx_optimization_effort_high} -objects [get_runs synth_1]
# set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-directive sdx_optimization_effort_high} -objects [get_runs synth_1]

puts "[color 4 "                        Create all implementation strategies: impl_strategy"]"
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED 1 [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED 1 [get_runs impl_1]
set_property -name {STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS} -value {-retiming} -objects [get_runs impl_1]
set_property AUTO_RQS 1 [get_runs impl_1]
set_property AUTO_RQS.SUGGESTION_RUN impl_1 [get_runs synth_1]

set argv [list ${ACTIVE_PARAMS_TCL_DIR}]
set argc 1
source ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/project_all_impl.tcl >> $log_file

puts "[color 4 "                        Create IDR implementation strategies: i_impl_strategies"]"
set argv [list ${ACTIVE_PARAMS_TCL_DIR}]
set argc 1
source ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/project_all_idr_impl.tcl >> $log_file

puts "[color 4 "                        Create IP packaging project ${KERNEL_NAME}_ip"]" 
# create IP packaging project
ipx::package_project -root_dir ${package_full_dir}/${KERNEL_NAME} -vendor virginia.edu -library ${KERNEL_NAME} -taxonomy /KernelIP -import_files -set_current true >> $log_file

set core [ipx::current_core]
scan ${GIT_VER} "%c" num_git_version
set_property vendor cs.virginia.edu $core
set_property library mezzanine $core
set_property name ${KERNEL_NAME} $core
set_property core_revision ${num_git_version} $core

foreach user_parameter [ipx::get_user_parameters] {
    ipx::remove_user_parameter $user_parameter $core
  }
# =========================================================
# Step 2: Inference clock, reset, AXI interfaces and associate them with clock
# =========================================================
puts "[color 3 "                Step 2: Inference clock, reset, AXI interfaces and associate them with clock"]" 

# inference clock and reset signals
# puts "[color 4 "                        Inference clock and reset signals"]" 
# set bif      [ipx::get_bus_interfaces -of $core  "m00_axi"] 
# set bifparam [ipx::add_bus_parameter -quiet "MAX_BURST_LENGTH" $bif]
# set_property value        32           $bifparam
# set_property value_source constant     $bifparam
# set bifparam [ipx::add_bus_parameter -quiet "NUM_READ_OUTSTANDING" $bif]
# set_property value        32           $bifparam
# set_property value_source constant     $bifparam
# set bifparam [ipx::add_bus_parameter -quiet "NUM_WRITE_OUTSTANDING" $bif]
# set_property value        32           $bifparam
# set_property value_source constant     $bifparam

# ipx::associate_bus_interfaces -busif "m00_axi" -clock "ap_clk" $core >> $log_file
# ipx::associate_bus_interfaces -busif "s_axi_control" -clock "ap_clk" $core >> $log_file

# =========================================================
# Specify the freq_hz parameter
# =========================================================
puts "[color 4 "                        Specify the freq_hz parameter"]" 
set clkbif      [ipx::get_bus_interfaces -of $core "ap_clk"]
set clkbifparam [ipx::add_bus_parameter -quiet "FREQ_HZ" $clkbif]

# =========================================================
# Set desired frequency
# ========================================================= 

             
puts "[color 4 "                        Set desired frequency "][color 5 "${DESIGN_FREQ_HZ} Hz"]"
set_property value ${DESIGN_FREQ_HZ} $clkbifparam

# =========================================================
# set value_resolve_type user if the frequency can vary.
# =========================================================
puts "[color 4 "                        Set value_resolve_type user if the frequency can vary. Type: "][color 5 "user"]"
set_property value_resolve_type user $clkbifparam

# =========================================================
# associate AXI/AXIS interface with clock
# =========================================================
puts "[color 4 "                        Associate AXIS interface with clock"]" 
ipx::associate_bus_interfaces -busif "s_axi_control"  -clock "ap_clk" $core >> $log_file

puts "[color 4 "                        Associate AXI interface with clock"]" 
set argv [list ${ACTIVE_PARAMS_TCL_DIR} $core]
set argc 2
source ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/project_generate_m_axi_ports.tcl 

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
puts "[color 4 "                        Add RTL kernel registers s_axi_control"]" 
ipx::add_register CTRL [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects $core]]

set mem_map    [ipx::add_memory_map -quiet "s_axi_control" $core]
set addr_block [ipx::add_address_block -quiet "reg0" $mem_map]
set reg        [ipx::add_register "CTRL" $addr_block]
set field      [ipx::add_field AP_START $reg]

# =========================================================
# Set RTL kernel registers property
# =========================================================
puts "[color 4 "                        Set RTL kernel registers property"]" 

puts_reg_info "CTRL" "Control signals" "0x000" 32
set reg      [ipx::add_register "CTRL" $addr_block]
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
  set reg      [ipx::add_register "GIER" $addr_block]
  set_property description    "Global Interrupt Enable Register"    $reg
  set_property address_offset 0x004 $reg
  set_property size           32    $reg

puts_reg_info "IP_IER" "IP Interrupt Enable Register" "0x008" 32
  set reg      [ipx::add_register "IP_IER" $addr_block]
  set_property description    "IP Interrupt Enable Register"    $reg
  set_property address_offset 0x008 $reg
  set_property size           32    $reg

puts_reg_info "IP_ISR" "IP Interrupt Status Register" "0x00C" 32
  set reg      [ipx::add_register "IP_ISR" $addr_block]
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

puts "[color 4 "                        Set RTL kernel (${KERNEL_NAME}) registers property"]" 

set argv [list ${ACTIVE_PARAMS_TCL_DIR} $addr_block]
set argc 2
source ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/project_map_buffers_m_axi_ports.tcl 

  set_property slave_memory_map_ref "s_axi_control" [ipx::get_bus_interfaces -of $core "s_axi_control"]

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

if {${XILINX_CTRL_MODE} == "USER_MANAGED"} {
  puts "[color 4 "                        Set ctrl mode "][color 1 "USER_MANAGED"]" 
  set_property vitis_drc {ctrl_protocol user_managed} $core
} elseif {${XILINX_CTRL_MODE} == "AP_CTRL_HS"} {
  puts "[color 4 "                        Set ctrl mode "][color 1 "AP_CTRL_HS"]"  
  set_property vitis_drc {ctrl_protocol ap_ctrl_hs} $core
} elseif {${XILINX_CTRL_MODE} == "AP_CTRL_CHAIN"} {
  puts "[color 4 "                        Set ctrl mode "][color 1 "AP_CTRL_CHAIN"]"  
  set_property vitis_drc {ctrl_protocol ap_ctrl_chain} $core
} else {
  puts "[color 4 "                        Set ctrl mode "][color 1 "USER_MANAGED"]"  
  set_property vitis_drc {ctrl_protocol user_managed} $core
}

puts "[color 4 "                        Merge project changes"]" 
update_compile_order -fileset [current_fileset] >> $log_file

ipx::add_bus_parameter FREQ_TOLERANCE_HZ [ipx::get_bus_interfaces ap_clk -of_objects [ipx::current_core]]
set_property value -1 [ipx::get_bus_parameters FREQ_TOLERANCE_HZ -of_objects [ipx::get_bus_interfaces ap_clk -of_objects [ipx::current_core]]]

ipx::merge_project_changes files [ipx::current_core] >> $log_file
ipx::merge_project_changes hdl_parameters [ipx::current_core] >> $log_file


puts "[color 4 "                        Upgrade Vivado IPs"]" 
update_ip_catalog     >> $log_file
upgrade_ip [get_ips]  >> $log_file
# =========================================================
# Packaging Vivado IP
# =========================================================
puts "[color 4 "                        Packaging Vivado IP"]" 
ipx::update_checksums $core
ipx::check_integrity -kernel $core >> $log_file
ipx::check_integrity -xrt $core >> $log_file
ipx::save_core $core
ipx::check_integrity -quiet -kernel $core
# ipx::create_xgui_files $core
ipx::archive_core ${package_full_dir}/${KERNEL_NAME}/${KERNEL_NAME}.zip $core
ipx::unload_core $core
# =========================================================
# Generate Vitis Kernel from Vivado IP
# =========================================================
puts "[color 4 "                        Generate Vitis Kernel from Vivado IP"]" 
# package_xo -force -xo_path .${package_full_dir}/${KERNEL_NAME}.xo -kernel_name ${KERNEL_NAME} -ctrl_protocol USER_MANAGED -ip_directory ${package_full_dir}/${KERNEL_NAME}_ip -output_kernel_xml .${package_full_dir}/${KERNEL_NAME}.xml >> $log_file

if {${XILINX_CTRL_MODE} == "USER_MANAGED"} {
  package_xo -force -xo_path ${package_full_dir}/${KERNEL_NAME}.xo -kernel_name ${KERNEL_NAME} -ctrl_protocol user_managed -ip_directory ${package_full_dir}/${KERNEL_NAME} -output_kernel_xml ${package_full_dir}/${KERNEL_NAME}.xml >> $log_file
} elseif {${XILINX_CTRL_MODE} == "AP_CTRL_HS"} {
  package_xo -force -xo_path ${package_full_dir}/${KERNEL_NAME}.xo -kernel_name ${KERNEL_NAME} -ctrl_protocol ap_ctrl_hs -ip_directory ${package_full_dir}/${KERNEL_NAME} -output_kernel_xml ${package_full_dir}/${KERNEL_NAME}.xml >> $log_file
} elseif {${XILINX_CTRL_MODE} == "AP_CTRL_CHAIN"} { 
  package_xo -force -xo_path ${package_full_dir}/${KERNEL_NAME}.xo -kernel_name ${KERNEL_NAME} -ctrl_protocol ap_ctrl_chain -ip_directory ${package_full_dir}/${KERNEL_NAME} -output_kernel_xml ${package_full_dir}/${KERNEL_NAME}.xml >> $log_file
} else {
  package_xo -force -xo_path ${package_full_dir}/${KERNEL_NAME}.xo -kernel_name ${KERNEL_NAME} -ctrl_protocol user_managed -ip_directory ${package_full_dir}/${KERNEL_NAME} -output_kernel_xml ${package_full_dir}/${KERNEL_NAME}.xml >> $log_file
}

# set ip_repo_list [concat $vip_repo $ip_repo_ert_firmware $cache_xilinx $hw_em_ip_repo $data_ip ${package_full_dir}]
# set ip_repo_list [concat $vip_repo $data_ip]
# set_property IP_REPO_PATHS "$ip_repo_list" [current_project] 
update_ip_catalog >> $log_file

puts "[color 4 "                        Synth design RTL test"]" 
# synth_design -rtl >> $log_file
# =========================================================
close_project

puts "========================================================="
puts "\[[color 2 "Packaging ${KERNEL_NAME} IPs....."]\] [color 1 "DONE!"]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 4 "ARCHITECTURE      "]\] [color 2 ${ARCHITECTURE}]"
puts "\[[color 4 "CAPABILITY        "]\] [color 2 ${CAPABILITY}]"
puts "\[[color 4 "ALGORITHM_NAME    "]\] [color 2 ${ALGORITHM_NAME}]"
puts "========================================================="
puts "\[[color 4 "ALVEO ID          "]\] [color 2 ${ALVEO}]"
puts "\[[color 4 "PART ID           "]\] [color 2 ${PART}]"
puts "\[[color 4 "KERNEL_NAME       "]\] [color 2 ${KERNEL_NAME}]"
puts "\[[color 4 "XILINX_CTRL_MODE  "]\] [color 2 ${XILINX_CTRL_MODE}]"
puts "\[[color 4 "DESIGN_FREQ_HZ    "]\] [color 2 ${DESIGN_FREQ_HZ}]"
puts "\[[color 4 "VIVADO_PACKAGE_DIR"]\] [color 2 ${VIVADO_PACKAGE_DIR}]"
puts "\[[color 4 "KERNEL_NAME.XML   "]\] [color 2 ${KERNEL_NAME}.xml]"
puts "\[[color 4 "KERNEL_NAME.XO    "]\] [color 2 ${KERNEL_NAME}.xo]"
puts "\[[color 4 "Log File          "]\] [color 2 generate_${KERNEL_NAME}_package.log]"
puts "\[[color 4 "VIVADO_VER        "]\] [color 2 ${VIVADO_VER}]"
puts "\[[color 4 "GIT_VER           "]\] [color 2 ${GIT_VER}]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 2 "Packaging ${KERNEL_NAME} IPs....."]\] [color 1 "DONE!"]"
puts "========================================================="