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
set part_id           [lindex $argv 0]
set kernel_name       [lindex $argv 1]
set app_directory     [lindex $argv 2]
set active_directory  [lindex $argv 3]
set vma_directory     [lindex $argv 4]
set project_var       [lindex $argv 5]
set gui_flag          [lindex $argv 6]
set scripts_directory [lindex $argv 7]

set ip_dir           ${app_directory}/${active_directory}
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

proc add_filelist_if_exists {group filename log_file} {
   if { [file exists ${filename}] == 1} {               
       add_files -fileset $group [read [open ${filename}]] >> $log_file
       import_files -fileset $group [read [open ${filename}]] >> $log_file
   }
}


# ----------------------------------------------------------------------------
# Generate ${kernel_name} IPs..... START!
# ----------------------------------------------------------------------------

# set_part ${part_id} >> $log_file

if {${gui_flag} == "YES"} {
  start_gui
}

create_project -force ${kernel_name}_vma -part $part_id >> $log_file

# set board_part_var "xilinx.com:au250:part0:1.4" 
# set_property board_part $board_part_var [current_project] >> $log_file

set vpl_ip_dir     ${app_directory}/${vma_directory}/${kernel_name}.build/link/vivado/vpl/.local/hw_platform/bd/202210_1_dev.srcs/sources_1/bd/ulp/ip
set vpl_iprepo_dir ${app_directory}/${vma_directory}/${kernel_name}.build/link/vivado/vpl/.local/hw_platform/iprepo/ip_repo

# open_project $project_var >> $log_file

# set ip_repo_ert_firmware [file normalize $vivado_dir/data/emulation/hw_em/ip_repo_ert_firmware]
# set cache_xilinx         [file normalize $vitis_dir/data/cache/xilinx]
# set data_ip              [file normalize $vitis_dir/data/ip]
# set hw_em_ip_repo        [file normalize $vivado_dir/data/emulation/hw_em/ip_repo]
# set vip_repo             [file normalize $app_directory/$vip_directory]
# set vma_iprepo           [file normalize $vpl_ip_dir] 
# set vma_ip               [file normalize $vpl_iprepo_dir] 

# set ip_repo_list [concat $vma_iprepo $vma_ip]

# set_property IP_REPO_PATHS "$ip_repo_list" [current_project] 
# update_ip_catalog >> $log_file

# add_filelist_if_exists sources_1 ${app_directory}/${scripts_directory}/${kernel_name}_vma_filelist_package.xci.f $log_file

# update_compile_order -fileset sources_1 >> $log_file

import_archive_if_exists ${app_directory}/${vma_directory}/${kernel_name}_export.vma 
