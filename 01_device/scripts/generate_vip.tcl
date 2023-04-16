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
# Generate GLay IPs..... START!
# ----------------------------------------------------------------------------

puts "========================================================="
puts "\[[color 2 "Generate GLay IPs....."]\] [color 1 "START!"]"
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

set_property PART $part_id [current_project]
set_property target_language  Verilog [current_project] 
set_property target_simulator XSim    [current_project] 

set ip_repo_ert_firmware [file normalize $vivado_dir/data/emulation/hw_em/ip_repo_ert_firmware]
set cache_xilinx         [file normalize $vitis_dir/data/cache/xilinx]
set data_ip              [file normalize $vitis_dir/data/ip]
set hw_em_ip_repo        [file normalize $vivado_dir/data/emulation/hw_em/ip_repo] 

set ip_repo_list [concat $ip_repo_ert_firmware $cache_xilinx $hw_em_ip_repo $data_ip]

set_property IP_REPO_PATHS "$ip_repo_list" [current_project] 
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
             
set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

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

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_642x128_GlayCacheRequestInterfaceInput
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate FIFO GlayCacheRequest : fifo_642x128"]" 

set module_name fifo_642x128
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.INTERFACE_TYPE {Native}                                                    \
                    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM}                         \
                    CONFIG.Performance_Options {Standard_FIFO}                                        \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                        \
                    CONFIG.Reset_Pin {1}                                                              \
                    CONFIG.Reset_Type {Synchronous_Reset}                                             \
                    CONFIG.asymmetric_port_width {0}                                                  \
                    CONFIG.Input_Data_Width {642}                                                     \
                    CONFIG.Input_Depth {128}                                                          \
                    CONFIG.Output_Data_Width {642}                                                    \
                    CONFIG.Output_Depth {128}                                                         \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {96}                                           \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
                    CONFIG.Empty_Threshold_Assert_Value {32}                                          \
                    CONFIG.Valid_Flag {1}                                                             \
                    CONFIG.Almost_Empty_Flag {1}                                                      \
                    CONFIG.Almost_Full_Flag {1}                                                       \
                   ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_515x128_GlayCacheRequestInterfaceOutput
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate FIFO GlayCacheResponse: fifo_515x128"]" 

set module_name fifo_515x128
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.INTERFACE_TYPE {Native}                                                    \
                    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM}                         \
                    CONFIG.Performance_Options {Standard_FIFO}                                        \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                        \
                    CONFIG.Reset_Pin {1}                                                              \
                    CONFIG.Reset_Type {Synchronous_Reset}                                             \
                    CONFIG.asymmetric_port_width {0}                                                  \
                    CONFIG.Input_Data_Width {515}                                                     \
                    CONFIG.Input_Depth {128}                                                          \
                    CONFIG.Output_Data_Width {515}                                                    \
                    CONFIG.Output_Depth {128}                                                         \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {96}                                           \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
                    CONFIG.Empty_Threshold_Assert_Value {32}                                          \
                    CONFIG.Valid_Flag {1}                                                             \
                    CONFIG.Almost_Empty_Flag {1}                                                      \
                    CONFIG.Almost_Full_Flag {1}                                                       \
                   ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_642x128_GlayCacheRequest
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate FIFO GlayCacheRequest : fifo_642x32"]" 

set module_name fifo_642x32
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.INTERFACE_TYPE {Native}                                                    \
                    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM}                         \
                    CONFIG.Performance_Options {Standard_FIFO}                                        \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                        \
                    CONFIG.Reset_Pin {1}                                                              \
                    CONFIG.Reset_Type {Synchronous_Reset}                                             \
                    CONFIG.asymmetric_port_width {0}                                                  \
                    CONFIG.Input_Data_Width {642}                                                     \
                    CONFIG.Input_Depth {32}                                                           \
                    CONFIG.Output_Data_Width {642}                                                    \
                    CONFIG.Output_Depth {32}                                                          \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {24}                                           \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
                    CONFIG.Empty_Threshold_Assert_Value {8}                                           \
                    CONFIG.Valid_Flag {1}                                                             \
                    CONFIG.Almost_Empty_Flag {1}                                                      \
                    CONFIG.Almost_Full_Flag {1}                                                       \
                   ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_642x128_GlayCacheRequest
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate FIFO GlayCacheRequest : fifo_642x32_FWFT"]" 

set module_name fifo_642x32_FWFT
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.INTERFACE_TYPE {Native}                                                    \
                    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM}                         \
                    CONFIG.Performance_Options {First_Word_Fall_Through}                              \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                        \
                    CONFIG.Reset_Pin {1}                                                              \
                    CONFIG.Reset_Type {Synchronous_Reset}                                             \
                    CONFIG.asymmetric_port_width {0}                                                  \
                    CONFIG.Input_Data_Width {642}                                                     \
                    CONFIG.Input_Depth {32}                                                           \
                    CONFIG.Output_Data_Width {642}                                                    \
                    CONFIG.Output_Depth {32}                                                          \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {24}                                           \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
                    CONFIG.Empty_Threshold_Assert_Value {8}                                           \
                    CONFIG.Valid_Flag {1}                                                             \
                    CONFIG.Almost_Empty_Flag {1}                                                      \
                    CONFIG.Almost_Full_Flag {1}                                                       \
                   ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_515x32_GlayCacheResponse
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate FIFO GlayCacheResponse: fifo_515x32"]" 

set module_name fifo_515x32
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.INTERFACE_TYPE {Native}                                                    \
                    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM}                         \
                    CONFIG.Performance_Options {Standard_FIFO}                                        \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                        \
                    CONFIG.Reset_Pin {1}                                                              \
                    CONFIG.Reset_Type {Synchronous_Reset}                                             \
                    CONFIG.asymmetric_port_width {0}                                                  \
                    CONFIG.Input_Data_Width {515}                                                     \
                    CONFIG.Input_Depth {32}                                                           \
                    CONFIG.Output_Data_Width {515}                                                    \
                    CONFIG.Output_Depth {32}                                                          \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {24}                                           \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
                    CONFIG.Empty_Threshold_Assert_Value {8}                                           \
                    CONFIG.Valid_Flag {1}                                                             \
                    CONFIG.Almost_Empty_Flag {1}                                                      \
                    CONFIG.Almost_Full_Flag {1}                                                       \
                   ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_167x32_GLayMemoryRequestPacket
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate FIFO GLayMemoryRequestPacket: fifo_167x32"]" 

set module_name fifo_167x32
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.INTERFACE_TYPE {Native}                                                    \
                    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM}                         \
                    CONFIG.Performance_Options {Standard_FIFO}                                        \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                        \
                    CONFIG.Reset_Pin {1}                                                              \
                    CONFIG.Reset_Type {Synchronous_Reset}                                             \
                    CONFIG.asymmetric_port_width {0}                                                  \
                    CONFIG.Input_Data_Width {167}                                                     \
                    CONFIG.Input_Depth {32}                                                           \
                    CONFIG.Output_Data_Width {167}                                                    \
                    CONFIG.Output_Depth {32}                                                          \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {24}                                           \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
                    CONFIG.Empty_Threshold_Assert_Value {8}                                           \
                    CONFIG.Valid_Flag {1}                                                             \
                    CONFIG.Almost_Empty_Flag {1}                                                      \
                    CONFIG.Almost_Full_Flag {1}                                                       \
                   ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate fifo_654x32_MemoryResponsePacket
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate FIFO GLayMemoryResponsePacket: fifo_711x32"]" 

set module_name fifo_711x32
create_ip -name fifo_generator \
          -vendor xilinx.com \
          -library ip \
          -version 13.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                              \
                    CONFIG.INTERFACE_TYPE {Native}                                                    \
                    CONFIG.Fifo_Implementation {Common_Clock_Distributed_RAM}                         \
                    CONFIG.Performance_Options {Standard_FIFO}                                        \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                        \
                    CONFIG.Reset_Pin {1}                                                              \
                    CONFIG.Reset_Type {Synchronous_Reset}                                             \
                    CONFIG.asymmetric_port_width {0}                                                  \
                    CONFIG.Input_Data_Width {711}                                                     \
                    CONFIG.Input_Depth {32}                                                           \
                    CONFIG.Output_Data_Width {711}                                                    \
                    CONFIG.Output_Depth {32}                                                          \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}       \
                    CONFIG.Full_Threshold_Assert_Value {24}                                           \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}     \
                    CONFIG.Empty_Threshold_Assert_Value {8}                                           \
                    CONFIG.Valid_Flag {1}                                                             \
                    CONFIG.Almost_Empty_Flag {1}                                                      \
                    CONFIG.Almost_Full_Flag {1}                                                       \
                   ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file


# ----------------------------------------------------------------------------
# generate Asymmetric Simple_Dual_Port_RAM bram_asym_64wrtx512rd
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate BRAM Simple_Dual_Port_RAM Asymmetric: bram_64x256_asym_64wrt_512rd"]" 

set module_name bram_64x256_asym_64wrt_512rd
create_ip -name blk_mem_gen \
          -vendor xilinx.com \
          -library ip \
          -version 8.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                                \
                    CONFIG.Memory_Type {Simple_Dual_Port_RAM}                                           \
                    CONFIG.Assume_Synchronous_Clk {true}                                                \
                    CONFIG.Write_Width_A {64}                                                           \
                    CONFIG.Write_Depth_A {256}                                                          \
                    CONFIG.Read_Width_A {64}                                                            \
                    CONFIG.Operating_Mode_A {NO_CHANGE}                                                 \
                    CONFIG.Write_Width_B {512}                                                          \
                    CONFIG.Read_Width_B {512}                                                           \
                    CONFIG.Operating_Mode_B {READ_FIRST}                                                \
                    CONFIG.Enable_B {Use_ENB_Pin}                                                       \
                    CONFIG.Register_PortA_Output_of_Memory_Primitives {false}                           \
                    CONFIG.Register_PortB_Output_of_Memory_Primitives {true}                            \
                    CONFIG.Register_PortB_Output_of_Memory_Core {true}                                  \
                    CONFIG.Port_B_Clock {100}                                                           \
                    CONFIG.Port_B_Enable_Rate {100}                                                     \
                    ] [get_ips ${module_name}]


set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate Asymmetric Simple_Dual_Port_RAM bram_512x32_asym_512wrt_64rd
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate BRAM Simple_Dual_Port_RAM Asymmetric: bram_512x32_asym_512wrt_64rd"]" 


set module_name bram_512x32_asym_512wrt_64rd
create_ip -name blk_mem_gen \
          -vendor xilinx.com \
          -library ip \
          -version 8.* \
          -module_name ${module_name}  \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                                \
                    CONFIG.Memory_Type {Simple_Dual_Port_RAM}                                           \
                    CONFIG.Assume_Synchronous_Clk {true}                                                \
                    CONFIG.Write_Width_A {512}                                                          \
                    CONFIG.Write_Depth_A {32}                                                           \
                    CONFIG.Read_Width_A {512}                                                           \
                    CONFIG.Operating_Mode_A {NO_CHANGE}                                                 \
                    CONFIG.Write_Width_B {64}                                                           \
                    CONFIG.Read_Width_B {64}                                                            \
                    CONFIG.Operating_Mode_B {READ_FIRST}                                                \
                    CONFIG.Enable_B {Use_ENB_Pin}                                                       \
                    CONFIG.Register_PortA_Output_of_Memory_Primitives {false}                           \
                    CONFIG.Register_PortB_Output_of_Memory_Primitives {true}                            \
                    CONFIG.Register_PortB_Output_of_Memory_Core {true}                                  \
                    CONFIG.Port_B_Clock {100}                                                           \
                    CONFIG.Port_B_Enable_Rate {100}                                                     \
                    ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# generate Asymmetric FIFO 512x32_512wrt_64_rd
# ----------------------------------------------------------------------------

create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_generator_0

puts "[color 2 "                        Generate FIFO Asymmetric: fifo_512x32_asym_512wrt_64_rd"]" 

set module_name fifo_512x32_asym_512wrt_64_rd
create_ip -name fifo_generator \
          -vendor xilinx.com            \
          -library ip                   \
          -version 13.*                 \
          -module_name ${module_name}   \
          -dir ${ip_dir} >> $log_file

set_property -dict [list                                                                            \
                    CONFIG.Fifo_Implementation {Common_Clock_Block_RAM}                             \
                    CONFIG.asymmetric_port_width {true}                                             \
                    CONFIG.Input_Data_Width {512}                                                   \
                    CONFIG.Input_Depth {32}                                                         \
                    CONFIG.Output_Data_Width {64}                                                   \
                    CONFIG.Output_Depth {256}                                                       \
                    CONFIG.Use_Embedded_Registers {true}                                            \
                    CONFIG.Almost_Full_Flag {true}                                                  \
                    CONFIG.Almost_Empty_Flag {true}                                                 \
                    CONFIG.Valid_Flag {true}                                                        \
                    CONFIG.Use_Extra_Logic {true}                                                   \
                    CONFIG.Data_Count_Width {5}                                                     \
                    CONFIG.Write_Data_Count_Width {6}                                               \
                    CONFIG.Read_Data_Count_Width {9}                                                \
                    CONFIG.Programmable_Full_Type {Single_Programmable_Full_Threshold_Constant}     \
                    CONFIG.Full_Threshold_Assert_Value {24}                                         \
                    CONFIG.Full_Threshold_Negate_Value {23}                                         \
                    CONFIG.Programmable_Empty_Type {Single_Programmable_Empty_Threshold_Constant}   \
                    CONFIG.Empty_Threshold_Assert_Value {8}                                         \
                    CONFIG.Empty_Threshold_Negate_Value {9}                                         \
                    CONFIG.Output_Register_Type {Embedded_Reg}                                      \
                    ] [get_ips ${module_name}]

set_property generate_synth_checkpoint false [get_files $ip_dir/${module_name}/${module_name}.xci]
generate_target {instantiation_template}     [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
generate_target all                          [get_files $ip_dir/${module_name}/${module_name}.xci] >> $log_file
export_ip_user_files -of_objects             [get_files $ip_dir/${module_name}/${module_name}.xci] -no_script -force >> $log_file
export_simulation -of_objects [get_files $ip_dir/${module_name}/${module_name}.xci] -directory $ip_dir/ip_user_files/sim_scripts -force >> $log_file

# ----------------------------------------------------------------------------
# Generate GLay IPs..... DONE! 
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
puts "\[[color 4 "Generate GLay IPs....."]\] [color 1 "DONE!"]"
puts "========================================================="
close_project >> $log_file