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

set ip_dir           ${device_directory}/${active_directory}
set log_file         ${ip_dir}/generate_${kernel_name}_ip.log

# ----------------------------------------------------------------------------
# Generate GLay IPs..... START!
# ----------------------------------------------------------------------------
puts "\[Generate GLay IPs.....\] START! [clock format [clock seconds] -format {%T %a %b %d %Y}]"
puts "\[Part ID: ${part_id}\]" 
puts "\[Kernel: ${kernel_name}\]" 

set_part ${part_id} >> $log_file
set_property target_language  Verilog [current_project] 
set_property target_simulator XSim    [current_project] 

# ----------------------------------------------------------------------------
# generate axi master vip
# ----------------------------------------------------------------------------
puts "                        generate axi master vip"

set module_name control_${kernel_name}_vip
create_ip -name axi_vip \
          -vendor xilinx.com \
          -library ip \
          -version 1.* \
          -module_name ${module_name} \
          -dir ${ip_dir} >> $log_file
          
set_property -dict [list \
                    CONFIG.INTERFACE_MODE {MASTER} \
                    CONFIG.PROTOCOL {AXI4LITE} \
                    CONFIG.ADDR_WIDTH {12} \
                    CONFIG.DATA_WIDTH {32} \
                    CONFIG.SUPPORTS_NARROW {0} \
                    CONFIG.HAS_BURST {0} \
                    CONFIG.HAS_LOCK {0} \
                    CONFIG.HAS_CACHE {0} \
                    CONFIG.HAS_REGION {0} \
                    CONFIG.HAS_QOS {0} \
                    CONFIG.HAS_PROT {0} \
                    CONFIG.HAS_WSTRB {1} \
                    ] [get_ips ${module_name}]
             
generate_target all [get_files  ${ip_dir}/${module_name}/${module_name}.xci] >> $log_file

# ----------------------------------------------------------------------------
# generate axi slave vip
# ----------------------------------------------------------------------------
puts "                        generate axi slave vip"

set module_name slv_m00_axi_vip
create_ip -name axi_vip \
          -vendor xilinx.com \
          -library ip \
          -version 1.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file
          
set_property -dict [list \
                    CONFIG.INTERFACE_MODE {SLAVE} \
                    CONFIG.PROTOCOL {AXI4} \
                    CONFIG.ADDR_WIDTH {64} \
                    CONFIG.DATA_WIDTH {512} \
                    CONFIG.SUPPORTS_NARROW {0} \
                    CONFIG.HAS_LOCK {1} \
                    CONFIG.HAS_CACHE {1} \
                    CONFIG.HAS_REGION {0} \
                    CONFIG.HAS_BURST {1} \
                    CONFIG.HAS_QOS {1} \
                    CONFIG.HAS_PROT {1} \
                    CONFIG.HAS_WSTRB {1} \
                    CONFIG.HAS_SIZE {1} \
                    CONFIG.ID_WIDTH   {1}\
                    ] [get_ips ${module_name}]

generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file             
generate_target all [get_files  ${ip_dir}/${module_name}/${module_name}.xci] >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_638x128_GlayCacheRequestInterfaceInput
# ----------------------------------------------------------------------------
puts "                        generate create fifo_638x128_GlayCacheRequestInterfaceInput"

set module_name fifo_638x128_GlayCacheRequestInterfaceInput
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.Performance_Options {First_Word_Fall_Through}                              \
                    CONFIG.Input_Data_Width {513}                                                     \
                    CONFIG.Input_Depth {512}                                                          \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {490}                                          \
                    CONFIG.Output_Data_Width {513}                                                    \
                    CONFIG.Output_Depth {512}                                                         \
                    CONFIG.Data_Count_Width {9}                                                       \
                    CONFIG.Write_Data_Count_Width {9}                                                 \
                    CONFIG.Read_Data_Count_Width {9}                                                  \
                    CONFIG.Full_Threshold_Negate_Value {489}                                          \
                    CONFIG.Empty_Threshold_Assert_Value {4}                                           \
                    CONFIG.Empty_Threshold_Negate_Value {5}                                           \
                   ] [get_ips ${module_name}]
set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_516x128_GlayCacheRequestInterfaceOutput
# ----------------------------------------------------------------------------
puts "                        generate fifo_516x128_GlayCacheRequestInterfaceOutput"



# ----------------------------------------------------------------------------
# Generate GLay IPs..... DONE! 
# ----------------------------------------------------------------------------
puts "\[Check directory:\]"
puts "\[${ip_dir}\]"
puts "\[Generate GLay IPs.....\] DONE!  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
close_project >> $log_file