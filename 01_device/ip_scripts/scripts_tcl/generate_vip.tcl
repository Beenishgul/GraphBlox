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
set app_directory    [lindex $argv 2]
set active_directory [lindex $argv 3]
set alveo_id         [lindex $argv 4]

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

create_project ${kernel_name}_ip_project -in_memory -force -part $part_id >> $log_file
 
set_property PART $part_id [current_project] >> $log_file

# if {${alveo_id} == "U250"} {

#   set board_part_var "xilinx.com:au250:part0:1.4" 
#   puts "[color 4 "                        Set board part "][color 1 ${board_part_var}]" 
#   set_property board_part $board_part_var [current_project] >> $log_file
# } elseif {${alveo_id} == "U280"} {

#   set board_part_var "xilinx.com:au280:part0:1.2" 
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

set_property target_language  Verilog [current_project]  >> $log_file
set_property target_simulator XSim    [current_project]  >> $log_file

set ip_repo_ert_firmware [file normalize $vivado_dir/data/emulation/hw_em/ip_repo_ert_firmware]
set cache_xilinx         [file normalize $vitis_dir/data/cache/xilinx]
set data_ip              [file normalize $vitis_dir/data/ip]
set hw_em_ip_repo        [file normalize $vivado_dir/data/emulation/hw_em/ip_repo] 

set ip_repo_list [concat $ip_repo_ert_firmware $cache_xilinx $hw_em_ip_repo $data_ip]

set_property IP_REPO_PATHS "$ip_repo_list" [current_project]  >> $log_file
update_ip_catalog >> $log_file

# ----------------------------------------------------------------------------
# generate axi master vip
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI VIP Master"]" 

set module_name control_${kernel_name}_vip
create_ip -name axi_vip                 \
          -vendor xilinx.com            \
          -library ip                   \
          -version 1.*                  \
          -module_name ${module_name}   \
          -dir ${ip_dir} >> $log_file
          
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
             
set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/.ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate axi slave vip
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI VIP Slave"]" 

set module_name slv_m00_axi_vip
create_ip -name axi_vip                 \
          -vendor xilinx.com            \
          -library ip                   \
          -version 1.*                  \
          -module_name ${module_name}   \
          -dir ${ip_dir} >> $log_file
          
set_property -dict [list \
                    CONFIG.INTERFACE_MODE {SLAVE}               \
                    CONFIG.PROTOCOL {AXI4}                      \
                    CONFIG.ADDR_WIDTH {64}                      \
                    CONFIG.DATA_WIDTH {512}                     \
                    CONFIG.SUPPORTS_NARROW {0}                  \
                    CONFIG.HAS_LOCK {1}                         \
                    CONFIG.HAS_CACHE {1}                        \
                    CONFIG.HAS_REGION {0}                       \
                    CONFIG.HAS_BURST {1}                        \
                    CONFIG.HAS_QOS {1}                          \
                    CONFIG.HAS_PROT {1}                         \
                    CONFIG.HAS_WSTRB {1}                        \
                    CONFIG.HAS_SIZE {1}                         \
                    CONFIG.ID_WIDTH   {1}                       \
                    ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/.ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate fifo_942x32_CacheRequestInterfaceInput
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate FIFO CacheRequest : fifo_942x32"]" 

# set module_name fifo_942x32
# create_ip -name fifo_generator          \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 13.*                 \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                              \
#                     CONFIG.INTERFACE_TYPE {Native}                                                    \
#                     CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                               \
#                     CONFIG.Performance_Options {Standard_FIFO}                                        \
#                     CONFIG.Output_Register_Type {Embedded_Reg}                                        \
#                     CONFIG.Reset_Pin {1}                                                              \
#                     CONFIG.Reset_Type {Synchronous_Reset}                                             \
#                     CONFIG.asymmetric_port_width {0}                                                  \
#                     CONFIG.Input_Data_Width {942}                                                     \
#                     CONFIG.Input_Depth {32}                                                           \
#                     CONFIG.Output_Data_Width {942}                                                    \
#                     CONFIG.Output_Depth {32}                                                          \
#                     CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
#                     CONFIG.Full_Threshold_Assert_Value {24}                                           \
#                     CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
#                     CONFIG.Empty_Threshold_Assert_Value {8}                                           \
#                     CONFIG.Valid_Flag {1}                                                             \
#                     CONFIG.Almost_Empty_Flag {1}                                                      \
#                     CONFIG.Almost_Full_Flag {1}                                                       \
#                    ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate fifo_814x16_CacheRequestInterfaceOutput
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate FIFO CacheResponse: fifo_814x32"]" 

# set module_name fifo_814x32
# create_ip -name fifo_generator          \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 13.*                 \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                              \
#                     CONFIG.INTERFACE_TYPE {Native}                                                    \
#                     CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                               \
#                     CONFIG.Performance_Options {Standard_FIFO}                                        \
#                     CONFIG.Output_Register_Type {Embedded_Reg}                                        \
#                     CONFIG.Reset_Pin {1}                                                              \
#                     CONFIG.Reset_Type {Synchronous_Reset}                                             \
#                     CONFIG.asymmetric_port_width {0}                                                  \
#                     CONFIG.Input_Data_Width {814}                                                     \
#                     CONFIG.Input_Depth {32}                                                           \
#                     CONFIG.Output_Data_Width {814}                                                    \
#                     CONFIG.Output_Depth {32}                                                          \
#                     CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
#                     CONFIG.Full_Threshold_Assert_Value {24}                                           \
#                     CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
#                     CONFIG.Empty_Threshold_Assert_Value {8}                                           \
#                     CONFIG.Valid_Flag {1}                                                             \
#                     CONFIG.Almost_Empty_Flag {1}                                                      \
#                     CONFIG.Almost_Full_Flag {1}                                                       \
#                    ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate fifo_942x16_CacheRequest
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate FIFO CacheRequest : fifo_942x16"]" 

# set module_name fifo_942x16
# create_ip -name fifo_generator          \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 13.*                 \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                              \
#                     CONFIG.INTERFACE_TYPE {Native}                                                    \
#                     CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                               \
#                     CONFIG.Performance_Options {Standard_FIFO}                                        \
#                     CONFIG.Output_Register_Type {Embedded_Reg}                                        \
#                     CONFIG.Reset_Pin {1}                                                              \
#                     CONFIG.Reset_Type {Synchronous_Reset}                                             \
#                     CONFIG.asymmetric_port_width {0}                                                  \
#                     CONFIG.Input_Data_Width {942}                                                     \
#                     CONFIG.Input_Depth {16}                                                           \
#                     CONFIG.Output_Data_Width {942}                                                    \
#                     CONFIG.Output_Depth {16}                                                          \
#                     CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
#                     CONFIG.Full_Threshold_Assert_Value {12}                                           \
#                     CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
#                     CONFIG.Empty_Threshold_Assert_Value {4}                                           \
#                     CONFIG.Valid_Flag {1}                                                             \
#                     CONFIG.Almost_Empty_Flag {1}                                                      \
#                     CONFIG.Almost_Full_Flag {1}                                                       \
#                    ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate fifo_942x16_CacheRequest
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate FIFO CacheRequest : fifo_942x16_FWFT"]" 

# set module_name fifo_942x16_FWFT
# create_ip -name fifo_generator          \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 13.*                 \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                              \
#                     CONFIG.INTERFACE_TYPE {Native}                                                    \
#                     CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                               \
#                     CONFIG.Performance_Options {First_Word_Fall_Through}                              \
#                     CONFIG.Output_Register_Type {Embedded_Reg}                                        \
#                     CONFIG.Reset_Pin {1}                                                              \
#                     CONFIG.Reset_Type {Synchronous_Reset}                                             \
#                     CONFIG.asymmetric_port_width {0}                                                  \
#                     CONFIG.Input_Data_Width {942}                                                     \
#                     CONFIG.Input_Depth {16}                                                           \
#                     CONFIG.Output_Data_Width {942}                                                    \
#                     CONFIG.Output_Depth {16}                                                          \
#                     CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
#                     CONFIG.Full_Threshold_Assert_Value {12}                                           \
#                     CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
#                     CONFIG.Empty_Threshold_Assert_Value {4}                                           \
#                     CONFIG.Valid_Flag {1}                                                             \
#                     CONFIG.Almost_Empty_Flag {1}                                                      \
#                     CONFIG.Almost_Full_Flag {1}                                                       \
#                    ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate fifo_814x16_CacheResponse
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate FIFO CacheResponse: fifo_814x16"]" 

# set module_name fifo_814x16
# create_ip -name fifo_generator          \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 13.*                 \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                              \
#                     CONFIG.INTERFACE_TYPE {Native}                                                    \
#                     CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                               \
#                     CONFIG.Performance_Options {Standard_FIFO}                                        \
#                     CONFIG.Output_Register_Type {Embedded_Reg}                                        \
#                     CONFIG.Reset_Pin {1}                                                              \
#                     CONFIG.Reset_Type {Synchronous_Reset}                                             \
#                     CONFIG.asymmetric_port_width {0}                                                  \
#                     CONFIG.Input_Data_Width {814}                                                     \
#                     CONFIG.Input_Depth {16}                                                           \
#                     CONFIG.Output_Data_Width {814}                                                    \
#                     CONFIG.Output_Depth {16}                                                          \
#                     CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
#                     CONFIG.Full_Threshold_Assert_Value {12}                                           \
#                     CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
#                     CONFIG.Empty_Threshold_Assert_Value {4}                                           \
#                     CONFIG.Valid_Flag {1}                                                             \
#                     CONFIG.Almost_Empty_Flag {1}                                                      \
#                     CONFIG.Almost_Full_Flag {1}                                                       \
#                    ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate fifo_812x16_MemoryPacket
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate FIFO MemoryPacket: fifo_812x16"]" 

# set module_name fifo_812x16
# create_ip -name fifo_generator          \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 13.*                 \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                              \
#                     CONFIG.INTERFACE_TYPE {Native}                                                    \
#                     CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                               \
#                     CONFIG.Performance_Options {Standard_FIFO}                                        \
#                     CONFIG.Output_Register_Type {Embedded_Reg}                                        \
#                     CONFIG.Reset_Pin {1}                                                              \
#                     CONFIG.Reset_Type {Synchronous_Reset}                                             \
#                     CONFIG.asymmetric_port_width {0}                                                  \
#                     CONFIG.Input_Data_Width {812}                                                     \
#                     CONFIG.Input_Depth {16}                                                           \
#                     CONFIG.Output_Data_Width {812}                                                    \
#                     CONFIG.Output_Depth {16}                                                          \
#                     CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
#                     CONFIG.Full_Threshold_Assert_Value {12}                                           \
#                     CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
#                     CONFIG.Empty_Threshold_Assert_Value {4}                                           \
#                     CONFIG.Valid_Flag {1}                                                             \
#                     CONFIG.Almost_Empty_Flag {1}                                                      \
#                     CONFIG.Almost_Full_Flag {1}                                                       \
#                    ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate Asymmetric FIFO 512x32_512wrt_64_rd
# # ----------------------------------------------------------------------------

# create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_generator_0

# puts "[color 2 "                        Generate FIFO Asymmetric: fifo_512x32_asym_512wrt_64rd"]" 

# set module_name fifo_512x32_asym_512wrt_64rd
# create_ip -name fifo_generator          \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 13.*                 \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                            \
#                     CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                             \
#                     CONFIG.asymmetric_port_width {true}                                             \
#                     CONFIG.Input_Data_Width {512}                                                   \
#                     CONFIG.Input_Depth {32}                                                         \
#                     CONFIG.Output_Data_Width {64}                                                   \
#                     CONFIG.Output_Depth {256}                                                       \
#                     CONFIG.Use_Embedded_Registers {true}                                            \
#                     CONFIG.Almost_Full_Flag {true}                                                  \
#                     CONFIG.Almost_Empty_Flag {true}                                                 \
#                     CONFIG.Valid_Flag {true}                                                        \
#                     CONFIG.Use_Extra_Logic {true}                                                   \
#                     CONFIG.Data_Count_Width {5}                                                     \
#                     CONFIG.Write_Data_Count_Width {6}                                               \
#                     CONFIG.Read_Data_Count_Width {9}                                                \
#                     CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}     \
#                     CONFIG.Full_Threshold_Assert_Value {24}                                         \
#                     CONFIG.Full_Threshold_Negate_Value {23}                                         \
#                     CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}   \
#                     CONFIG.Empty_Threshold_Assert_Value {8}                                         \
#                     CONFIG.Empty_Threshold_Negate_Value {9}                                         \
#                     CONFIG.Output_Register_Type {Embedded_Reg}                                      \
#                     ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file


# # ----------------------------------------------------------------------------
# # generate Asymmetric Simple_Dual_Port_RAM bram_asym_64wrtx512rd
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate BRAM Simple_Dual_Port_RAM Asymmetric: bram_64x256_asym_64wrt_512rd"]" 

# set module_name bram_64x256_asym_64wrt_512rd
# create_ip -name blk_mem_gen             \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 8.*                  \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                                \
#                     CONFIG.Memory_Type {Simple_Dual_Port_RAM}                                           \
#                     CONFIG.Assume_Synchronous_Clk {true}                                                \
#                     CONFIG.Write_Width_A {64}                                                           \
#                     CONFIG.Write_Depth_A {256}                                                          \
#                     CONFIG.Read_Width_A {64}                                                            \
#                     CONFIG.Operating_Mode_A {NO_CHANGE}                                                 \
#                     CONFIG.Write_Width_B {512}                                                          \
#                     CONFIG.Read_Width_B {512}                                                           \
#                     CONFIG.Operating_Mode_B {READ_FIRST}                                                \
#                     CONFIG.Enable_B {Use_ENB_Pin}                                                       \
#                     CONFIG.Register_PortA_Output_of_Memory_Primitives {false}                           \
#                     CONFIG.Register_PortB_Output_of_Memory_Primitives {true}                            \
#                     CONFIG.Register_PortB_Output_of_Memory_Core {true}                                  \
#                     CONFIG.Port_B_Clock {100}                                                           \
#                     CONFIG.Port_B_Enable_Rate {100}                                                     \
#                     ] [get_ips ${module_name}]


# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# # ----------------------------------------------------------------------------
# # generate Asymmetric Simple_Dual_Port_RAM bram_512x32_asym_512wrt_64rd
# # ----------------------------------------------------------------------------
# puts "[color 2 "                        Generate BRAM Simple_Dual_Port_RAM Asymmetric: bram_512x32_asym_512wrt_64rd"]" 


# set module_name bram_512x32_asym_512wrt_64rd
# create_ip -name blk_mem_gen             \
#           -vendor xilinx.com            \
#           -library ip                   \
#           -version 8.*                  \
#           -module_name ${module_name}   \
#           -dir ${ip_dir} >> $log_file

# set_property -dict [list                                                                                \
#                     CONFIG.Memory_Type {Simple_Dual_Port_RAM}                                           \
#                     CONFIG.Assume_Synchronous_Clk {true}                                                \
#                     CONFIG.Write_Width_A {512}                                                          \
#                     CONFIG.Write_Depth_A {32}                                                           \
#                     CONFIG.Read_Width_A {512}                                                           \
#                     CONFIG.Operating_Mode_A {NO_CHANGE}                                                 \
#                     CONFIG.Write_Width_B {64}                                                           \
#                     CONFIG.Read_Width_B {64}                                                            \
#                     CONFIG.Operating_Mode_B {READ_FIRST}                                                \
#                     CONFIG.Enable_B {Use_ENB_Pin}                                                       \
#                     CONFIG.Register_PortA_Output_of_Memory_Primitives {false}                           \
#                     CONFIG.Register_PortB_Output_of_Memory_Primitives {true}                            \
#                     CONFIG.Register_PortB_Output_of_Memory_Core {true}                                  \
#                     CONFIG.Port_B_Clock {100}                                                           \
#                     CONFIG.Port_B_Enable_Rate {100}                                                     \
#                     ] [get_ips ${module_name}]

# set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
# generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
# export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
# export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate SYSTEM CACHE
# C_CACHE_SIZE    Cache size in bytes 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304
# ----------------------------------------------------------------------------
set SYSTEM_CACHE_SIZE_B   32768
set SYSTEM_CACHE_NUM_WAYS 4
set LINE_CACHE_DATA_WIDTH 512 
set FE_ADDR_WIDTH         64 
set FE_CACHE_DATA_WIDTH   512 
set BE_ADDR_WIDTH         63
set BE_CACHE_DATA_WIDTH   512

set SYSTEM_CACHE_SIZE_KB [expr {${SYSTEM_CACHE_SIZE_B} / 1024}]
puts "[color 2 "                        Generate Kernel Cache: Cache-line: ${LINE_CACHE_DATA_WIDTH}bits | Ways: ${SYSTEM_CACHE_NUM_WAYS} | Size: ${SYSTEM_CACHE_SIZE_KB}KB"]" 
puts "[color 2 "                                    Front-End: Data width: ${FE_CACHE_DATA_WIDTH}bits | Address width: ${FE_ADDR_WIDTH}bits"]" 
puts "[color 2 "                                     Back-End: Data width: ${BE_CACHE_DATA_WIDTH}bits | Address width: ${BE_ADDR_WIDTH}bits"]" 


set module_name system_cache_512x64
create_ip -name system_cache            \
          -vendor xilinx.com            \
          -library ip                   \
          -version 5.*                  \
          -module_name ${module_name}   \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                  \
                    CONFIG.C_CACHE_DATA_WIDTH ${LINE_CACHE_DATA_WIDTH}    \
                    CONFIG.C_CACHE_SIZE  ${SYSTEM_CACHE_SIZE_B}           \
                    CONFIG.C_M0_AXI_ADDR_WIDTH ${BE_ADDR_WIDTH}           \
                    CONFIG.C_M0_AXI_DATA_WIDTH ${BE_CACHE_DATA_WIDTH}     \
                    CONFIG.C_NUM_GENERIC_PORTS {1}                        \
                    CONFIG.C_NUM_OPTIMIZED_PORTS {0}                      \
                    CONFIG.C_ENABLE_NON_SECURE {1}                        \
                    CONFIG.C_ENABLE_ERROR_HANDLING {1}                    \
                    CONFIG.C_NUM_WAYS ${SYSTEM_CACHE_NUM_WAYS}            \
                    CONFIG.C_S0_AXI_GEN_DATA_WIDTH ${FE_CACHE_DATA_WIDTH} \
                    CONFIG.C_S0_AXI_GEN_ADDR_WIDTH ${FE_ADDR_WIDTH}       \
                    CONFIG.C_S0_AXI_GEN_FORCE_READ_ALLOCATE {1}           \
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_READ_ALLOCATE {0}        \
                    CONFIG.C_S0_AXI_GEN_FORCE_WRITE_ALLOCATE {1}          \
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_WRITE_ALLOCATE {0}       \
                    CONFIG.C_S0_AXI_GEN_FORCE_READ_BUFFER {1}             \
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_READ_BUFFER {0}          \
                    CONFIG.C_S0_AXI_GEN_FORCE_WRITE_BUFFER {1}            \
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_WRITE_BUFFER {0}         \
                    CONFIG.C_CACHE_TAG_MEMORY_TYPE {Automatic}            \
                    CONFIG.C_CACHE_DATA_MEMORY_TYPE {URAM}                \
                    CONFIG.C_CACHE_LRU_MEMORY_TYPE {Automatic}            \
                    ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/.ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# Generate ${kernel_name} IPs..... DONE! 
# ----------------------------------------------------------------------------

puts "========================================================="
puts "\[[color 4 "Check directory for VIP"]\]"
puts "\[[color 3 ${ip_dir}]\]"
puts "\[[color 4 "Part ID"]\] [color 2 ${part_id}]" 
puts "\[[color 4 "Kernel "]\] [color 2 ${kernel_name}]" 
puts "========================================================="

puts "========================================================="
puts "\[[color 2 [clock format [clock seconds] -format {%T %a %b %d %Y}]"]\] "
puts "========================================================="
puts "\[[color 4 "Generate ${kernel_name} IPs....."]\] [color 1 "DONE!"]"
puts "========================================================="
close_project >> $log_file