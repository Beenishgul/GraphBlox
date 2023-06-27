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
set part_id              [lindex $argv 0]
set kernel_name          [lindex $argv 1]
set app_directory        [lindex $argv 2]
set active_app_directory [lindex $argv 3]
set scripts_directory    [lindex $argv 4]
set alveo_id             [lindex $argv 5]

set ip_dir           ${app_directory}/${active_app_directory}
set log_file         ${ip_dir}/generate_${kernel_name}_vip.log

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
# Generate ${kernel_name} IPs..... START!
# ----------------------------------------------------------------------------

puts "========================================================="
puts "\[[color 2 "Generate ${kernel_name} IPs....."]\] [color 1 "START!"]"
puts "========================================================="
puts "\[[color 2 " [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 4 "Part ID"]\] [color 2 ${part_id}]" 
puts "\[[color 4 "Kernel "]\] [color 2 ${kernel_name}]" 
puts "========================================================="
puts "\[[color 4 "XILINX_VIVADO"]\] [color 2 ${vivado_dir}]" 
puts "\[[color 4 "XILINX_VITIS "]\] [color 2 ${vitis_dir}]" 
puts "========================================================="

# set_part ${part_id} >> $log_file

create_project -force ${kernel_name} ${ip_dir}/${kernel_name} -part $part_id >> $log_file
 
set_property PART $part_id [current_project] >> $log_file

# if {${alveo_id} == "U250"} {
#   set board_part_var "xilinx.com:au250:part0:1.4" 
#   puts "[color 4 "                        Set board part "][color 1 ${board_part_var}]" 
#   set_property board_part $board_part_var [current_project] >> $log_file
# } elseif {${alveo_id} == "U280"} {

#   set board_part_var "xilinx.com:au280:part0:1.3" 
#   puts "[color 4 "                        Set board part "][color 1 ${board_part_var}]"  
#   set_property board_part $board_part_var [current_project] >> $log_file
# } elseif {${alveo_id} == "U55"} {
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
set argv [list ${part_id} ${kernel_name} ${app_directory} ${active_app_directory}]
set argc 4
source ${app_directory}/${scripts_directory}/scripts_tcl/project_generate_vip.tcl 

# ----------------------------------------------------------------------------
# Generate ${kernel_name} IPs..... DONE! 
# ----------------------------------------------------------------------------

close_project >> $log_file