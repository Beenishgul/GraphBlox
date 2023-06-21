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
set part_id          [lindex $argv 0]
set kernel_name      [lindex $argv 1]
set device_directory [lindex $argv 2]
set active_directory [lindex $argv 3]
set vma_directory    [lindex $argv 4]
set project_var      [lindex $argv 5]
set gui_flag         [lindex $argv 6]


set ip_dir           ${device_directory}/${active_directory}
set log_file         ${ip_dir}/generate_${kernel_name}_ip.log

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

proc import_archive_if_exists {filename} {
   if { [file exists ${filename}] == 1} {               
       vitis::import_archive ${filename}
   } else {
      puts "ERROR: \[NOT-FOUND\] ${filename}"
   }
}

# ----------------------------------------------------------------------------
# Generate ${kernel_name} IPs..... START!
# ----------------------------------------------------------------------------

# set_part ${part_id} >> $log_file

if {${gui_flag} == "YES"} {
  start_gui
}

# create_project ${kernel_name}_vma_project -part $part_id >> $log_file

open_project $project_var 

import_archive_if_exists ${device_directory}/${vma_directory}/${kernel_name}_export.vma 
