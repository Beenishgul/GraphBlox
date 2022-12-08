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
set_part [lindex $argv 0]

# ----------------------------------------------------------------------------
# generate axi master vip
# ----------------------------------------------------------------------------
create_ip -name axi_vip \
          -vendor xilinx.com \
          -library ip \
          -version 1.1 \
          -module_name control_glay_kernel_vip \
          -dir ./xilinx/glay_kernel_ip_generation
          
set_property -dict [list CONFIG.INTERFACE_MODE {MASTER} \
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
                         CONFIG.HAS_WSTRB {1}] \
             [get_ips control_glay_kernel_vip]
             
generate_target all [get_files  ./xilinx/glay_kernel_ip_generation/control_glay_kernel_vip/control_glay_kernel_vip.xci]

# ----------------------------------------------------------------------------
# generate axi slave vip
# ----------------------------------------------------------------------------
create_ip -name axi_vip \
          -vendor xilinx.com \
          -library ip \
          -version 1.1 \
          -module_name slv_m00_axi_vip \
          -dir ./xilinx/glay_kernel_ip_generation
          
set_property -dict [list CONFIG.INTERFACE_MODE {SLAVE} \
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
                         CONFIG.ID_WIDTH   {1}] \
             [get_ips slv_m00_axi_vip]
             
generate_target all [get_files  ./xilinx/glay_kernel_ip_generation/slv_m00_axi_vip/slv_m00_axi_vip.xci]
