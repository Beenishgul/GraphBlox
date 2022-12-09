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

ECHO=@echo

.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make gen_ip"
	$(ECHO) "      Command to generate the IPs used in this design"
	$(ECHO) ""
	$(ECHO) "  make pack_kernel"
	$(ECHO) "      Command to pack the module glay_kernel to Vitis kernel"
	$(ECHO) ""
	$(ECHO) "  make runsim"
	$(ECHO) "      Command to run the simulation"
	$(ECHO) ""
	$(ECHO) "  make build_hw"
	$(ECHO) "      Command to build xclbin files for Alveo platform, including glay_kernel"
	$(ECHO) ""
	$(ECHO) "  make build_sw"
	$(ECHO) "      Command to build host software for xclbin test"
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove all the generated files."

APP_DIR := .
SCRIPTS_DIR := scripts
IP_DIR := IP
XML_DIR := xml
SCRIPTS_DIR := scripts
XILINX_DIR := xilinx

KERNEL := glay_kernel

# PART setting: uncomment the line matching your Alveo card
# PART := xcu200-fsgd2104-2-e
PART := xcu250-figd2104-2L-e
#PART := xcu50-fsvh2104-2-e
#PART := xcu55c-fsvh2892-2L-e
#PART := xcu280-fsvh2892-2L-e

# PLATFORM setting: uncomment the lin matching your Alveo card
# PLATFORM := xilinx_u200_gen3x16_xdma_2_202110_1
PLATFORM := xilinx_u250_gen3x16_xdma_4_1_202210_1
#PLATFORM := xilinx_u50_gen3x16_xdma_5_202210_1
#PLATFORM := xilinx_u55c_gen3x16_xdma_3_202210_1
#PLATFORM := xilinx_u280_gen3x16_xdma_1_202211_1

# TARGET: set the build target, can be hw or hw_emu
TARGET := hw_emu


.phony: clean traces

################## resource generation and simulation 
gen_ip:
	rm -rf $(XILINX_DIR)/$(KERNEL)_ip_generation; mkdir -p $(XILINX_DIR)/$(KERNEL)_ip_generation; vivado -mode batch -source ./$(SCRIPTS_DIR)/$(KERNEL)_gen_ip.tcl -tclargs $(PART)


pack_kernel:
	rm -rf $(XILINX_DIR)/$(KERNEL)_vivado_pack_krnl_project; mkdir -p $(XILINX_DIR)/$(KERNEL)_vivado_pack_krnl_project; cd $(XILINX_DIR)/$(KERNEL)_vivado_pack_krnl_project; vivado -mode batch -source ../../$(SCRIPTS_DIR)/$(KERNEL)_package.tcl -tclargs $(PART)

runsim:
	rm -rf $(XILINX_DIR)/$(KERNEL)_vivado_sim_krnl_project; mkdir -p $(XILINX_DIR)/$(KERNEL)_vivado_sim_krnl_project; cd $(XILINX_DIR)/$(KERNEL)_vivado_sim_krnl_project; sh ../../$(SCRIPTS_DIR)/$(KERNEL)_runsim_xsim.sh


################## hardware build 
XOCCFLAGS := --platform $(PLATFORM) -t $(TARGET)  -s -g
XOCCLFLAGS := --link --optimize 3
# You could uncomment following line and modify the options for hardware debug/profiling
#DEBUG_OPT := -debug.chipscope $(KERNEL)_1 --debug.protocol all --profile_kernel data:all:all:all:all

build_hw:
	v++ $(XOCCLFLAGS) $(XOCCFLAGS) $(DEBUG_OPT) --config ./$(SCRIPTS_DIR)/$(KERNEL)_test.cfg -o $(KERNEL)_test_$(TARGET).xclbin $(KERNEL).xo

all: gen_ip pack_kernel build_hw

################## clean up
clean:
	$(RM) -rf $(XILINX_DIR) .Xil
	$(RM) -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x
	$(RM) -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg