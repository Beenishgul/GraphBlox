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
# set the device part from command line argvs
set PARAMS_TCL_DIR                  [lindex $argv 0]
set package_full_dir                [lindex $argv 1]

source ${PARAMS_TCL_DIR}

# set package_full_dir ${APP_DIR_ACTIVE}/${VIVADO_PACKAGE_DIR}
set log_file         ${package_full_dir}/generate_${KERNEL_NAME}_ip.log

# ----------------------------------------------------------------------------
# Color function
# ----------------------------------------------------------------------------
# set ip_repo_list [get_property IP_REPO_PATHS [current_project]] 
set vivado_dir $::env(XILINX_VIVADO)
set vitis_dir $::env(XILINX_VITIS)

proc color {foreground text} {
    # tput is a little Unix utility that lets you use the termcap database
    # *much* more easily...
    return [exec tput setaf $foreground]$text[exec tput sgr0]
}

# ----------------------------------------------------------------------------
# Generate ${KERNEL_NAME} IPs..... START!
# ----------------------------------------------------------------------------

puts "========================================================="
puts "\[[color 2 "Generate ${KERNEL_NAME} IPs....."]\] [color 1 "START!"]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 4 "Part ID"]\] [color 2 ${PART}]" 
puts "\[[color 4 "Kernel "]\] [color 2 ${KERNEL_NAME}]" 
puts "========================================================="
puts "\[[color 4 "XILINX_VIVADO"]\] [color 2 ${vivado_dir}]" 
puts "\[[color 4 "XILINX_VITIS "]\] [color 2 ${vitis_dir}]" 
puts "========================================================="

# set_part ${PART} >> $log_file

# create_project ${KERNEL_NAME}_ip_project -in_memory -force -part $PART >> $log_file
# current_project

set_property PART $PART [current_project]
set_property target_language  Verilog [current_project] 
set_property target_simulator XSim    [current_project] 

# set ip_repo_ert_firmware [file normalize $vivado_dir/data/emulation/hw_em/ip_repo_ert_firmware]
# set cache_xilinx         [file normalize $vitis_dir/data/cache/xilinx]
# set data_ip              [file normalize $vitis_dir/data/ip]
# set hw_em_ip_repo        [file normalize $vivado_dir/data/emulation/hw_em/ip_repo] 

# set ip_repo_list [concat $ip_repo_ert_firmware $cache_xilinx $hw_em_ip_repo $data_ip]

# set_property IP_REPO_PATHS "$ip_repo_list" [current_project] 
# update_ip_catalog >> $log_file

# ----------------------------------------------------------------------------
# generate axi master vip
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI VIP Master"]" 

set module_name control_${KERNEL_NAME}_vip
create_ip -name axi_vip                 \
          -vendor xilinx.com            \
          -library ip                   \
          -version 1.*                  \
          -module_name ${module_name}   >> $log_file
          
set_property -dict [list \
                    CONFIG.INTERFACE_MODE {MASTER}              \
                    CONFIG.PROTOCOL {AXI4LITE}                  \
                    CONFIG.ADDR_WIDTH {12}                      \
                    CONFIG.DATA_WIDTH {32}                      \
                    CONFIG.SUPPORTS_NARROW {0}                  \
                    CONFIG.HAS_BURST {0}                        \
                    CONFIG.HAS_LOCK {0}                         \
                    CONFIG.HAS_CACHE {0}                        \
                    CONFIG.HAS_REGION {0}                       \
                    CONFIG.HAS_QOS {0}                          \
                    CONFIG.HAS_PROT {0}                         \
                    CONFIG.HAS_WSTRB {1}                        \
                    ] [get_ips ${module_name}]

set files_sources_xci ${package_full_dir}/${KERNEL_NAME}/${KERNEL_NAME}.srcs/sources_1/ip/${module_name}/${module_name}.xci
set files_ip_user_files_dir     ${package_full_dir}/${KERNEL_NAME}/${KERNEL_NAME}.ip_user_files
set files_cache_dir     ${package_full_dir}/${KERNEL_NAME}/${KERNEL_NAME}.cache
set_property generate_synth_checkpoint false [get_files ${files_sources_xci}]
generate_target {instantiation_template}     [get_files ${files_sources_xci}] >> $log_file
# catch { config_ip_cache -export [get_ips -all ${module_name}] }
generate_target all                          [get_files ${files_sources_xci}] >> $log_file
export_ip_user_files -of_objects             [get_files ${files_sources_xci}] -no_script -force >> $log_file
export_simulation -of_objects [get_files ${files_sources_xci}] -directory ${files_ip_user_files_dir}/sim_scripts -ip_user_files_dir ${files_ip_user_files_dir} -ipstatic_source_dir ${files_ip_user_files_dir}/ipstatic -lib_map_path [list {modelsim=${files_cache_dir}/compile_simlib/modelsim} {questa=${files_cache_dir}/compile_simlib/questa} {xcelium=${files_cache_dir}/compile_simlib/xcelium} {vcs=${files_cache_dir}/compile_simlib/vcs} {riviera=${files_cache_dir}/compile_simlib/riviera}] -use_ip_compiled_libs -force >> $log_file

puts "[color 4 "                        Add VIP into project"]"
set argv [list ${PARAMS_TCL_DIR} ${package_full_dir} ${log_file} ${vivado_dir} ${vitis_dir}]
set argc 5
source ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/project_generate_m_axi_vip.tcl 

puts "========================================================="
puts "\[[color 4 "Check directory for VIP"]\]"
puts "\[[color 3 ${package_full_dir}]\]"
puts "\[[color 4 "Part ID"]\] [color 2 ${PART}]" 
puts "\[[color 4 "Kernel "]\] [color 2 ${KERNEL_NAME}]" 
puts "========================================================="

puts "========================================================="
puts "\[[color 2 [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 4 "Generate ${KERNEL_NAME} IPs....."]\] [color 1 "DONE!"]"
puts "========================================================="
