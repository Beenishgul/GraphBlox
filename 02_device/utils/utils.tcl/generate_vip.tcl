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
set ACTIVE_PARAMS_TCL_DIR                  [lindex $argv 0]

source ${ACTIVE_PARAMS_TCL_DIR}

set package_full_dir ${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}
set log_file         ${package_full_dir}/generate_${KERNEL_NAME}_vip.log

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

create_project -force ${KERNEL_NAME} ${package_full_dir}/${KERNEL_NAME} -part $PART >> $log_file
 
set_property PART $PART [current_project] >> $log_file

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
set_property simulator_language "Mixed" [current_project]  >> $log_file
set_property target_language  Verilog   [current_project]  >> $log_file
set_property target_simulator XSim      [current_project]  >> $log_file

puts "[color 4 "                        Add VIP into project"]"
set argv [list ${ACTIVE_PARAMS_TCL_DIR} ${package_full_dir}]
set argc 2
source ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/project_generate_vip.tcl 

# ----------------------------------------------------------------------------
# Generate ${KERNEL_NAME} IPs..... DONE! 
# ----------------------------------------------------------------------------

close_project >> $log_file