.PHONY: help
help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make gen-ip"
	$(ECHO) "      Command to generate the IPs used in this design"
	$(ECHO) ""
	$(ECHO) "  make package-kernel"
	$(ECHO) "      Command to pack the module glay_kernel to Vitis kernel"
	$(ECHO) ""
	$(ECHO) "  make run-sim"
	$(ECHO) "      Command to run the simulation"
	$(ECHO) ""
	$(ECHO) "  make build-hw"
	$(ECHO) "      Command to build xclbin files for Alveo platform, including glay_kernel"
	$(ECHO) ""
	$(ECHO) "  make clean"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
	$(ECHO) "  github commit version:"
	$(ECHO) "     $(GIT_VER)"

APP                 ?= glay
KERNEL_NAME         ?= glay_kernel
# APP_TEST            ?= test_match
# APP_TEST            ?= test_glay
# APP_TEST            ?= test_StalaGraph
APP_TEST            ?= test_glayGraph
APP_LANG            ?= cpp
INTEGRATION         ?= openmp

MAKE_NUM_THREADS    ?= $(shell grep -c ^processor /proc/cpuinfo)
ROOT_DIR            ?= $(shell cd ../../ ; pwd)
GIT_VER             ?= $(shell cd .. && git log -1 --pretty=format:"%h")

APP_DIR             ?= 00_GLay
HOST_DIR            ?= 00_host
DEVICE_DIR          ?= 01_device

XILINX_DIR          ?= xilinx_project
SCRIPTS_DIR         ?= scripts
IP_DIR              ?= glay_ip

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
ALL_SYSTEM_VERILOG_SOURCES  := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.sv)
ALL_VERILOG_SOURCES 		:= $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.v)
ALL_VERILOG_HEADERS 		:= $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.vh)
ALL_SCRIPTS_SOURCES 		:= $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/,*)

XILINX_DIR_ACTIVE  	?= $(XILINX_DIR)_$(KERNEL_NAME)_$(GIT_VER)
SCRIPTS_DIR_ACTIVE 	?= $(SCRIPTS_DIR)
IP_DIR_ACTIVE       ?= $(IP_DIR)

ACTIVE_APP_DIR      := $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)

DEVICE_INDEX        ?= 0
XCLBIN_PATH         ?= $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin
GLAY_FPGA_ARGS      ?= -m $(DEVICE_INDEX) -q $(XCLBIN_PATH)

# PART setting: uncomment the line matching your Alveo card
# PART ?= xcu200-fsgd2104-2-e
PART ?= xcu250-figd2104-2L-e
# PART ?= xcu50-fsvh2104-2-e
# PART ?= xcu55c-fsvh2892-2L-e
# PART ?=xcu280-fsvh2892-2L-e

# PLATFORM setting: uncomment the lin matching your Alveo card
# PLATFORM ?= xilinx_u200_gen3x16_xdma_2_202110_1
PLATFORM ?= xilinx_u250_gen3x16_xdma_4_1_202210_1
# PLATFORM ?= xilinx_u50_gen3x16_xdma_5_202210_1
# PLATFORM ?= xilinx_u55c_gen3x16_xdma_3_202210_1
# PLATFORM ?= xilinx_u280_gen3x16_xdma_1_202211_1

# TARGET: set the build target, can be hw or hw_emu
TARGET   ?= hw_emu
# TARGET ?= hw
EMU_MODE ?= off

##############################################
#     CLI COMMANDS                           #
##############################################

RM      :=rm -f
RMDIR   :=rm -rf
CP      :=@cp -rf
MKDIR   :=mkdir -p
EXPORTE :=@export
CD      :=@cd
ECHO    :=@echo
EMCONFIGUTIL := $(XILINX_VITIS)/bin/emconfigutil

##############################################
#     COMPILER FLAGS                         #
##############################################

CXX     := g++
VPP     := v++
GCC     := gcc
CC      := gcc

################## resource generation 
.PHONY: gen-ip-dir
gen-ip-dir:
	rm -rf $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE) ;\
	cp -r $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/* $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE)/

.PHONY: gen-scripts-dir
gen-scripts-dir:
	rm -rf $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)) ; do cp -v -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$$file $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$$file; done ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_xrt_ini.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_build_cfg.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_package_filelist_f.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(IP_DIR_ACTIVE) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_xsim_filelist_f.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(IP_DIR_ACTIVE)

.PHONY: gen-vip
gen-vip: gen-scripts-dir gen-ip-dir
	rm -rf $(ACTIVE_APP_DIR)/vivado_generated_vip;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_generated_vip;\
	cd $(ACTIVE_APP_DIR)/vivado_generated_vip;\
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_vip.tcl -tclargs $(PART) $(KERNEL_NAME) $(ACTIVE_APP_DIR) vivado_generated_vip

################## simulation 
.PHONY: run-sim
run-sim:
	mkdir -p $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	cd $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR)

.PHONY: run-sim-clean
run-sim-clean:
	rm -rf $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	cd $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR)

.PHONY: run-sim-reset
run-sim-reset:
	mkdir -p $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	cd $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) -reset_run 

.PHONY: run-sim-wave
run-sim-wave: $(ACTIVE_APP_DIR)/vivado_simulate_kernel/work.$(KERNEL_NAME)_testbench.wdb
	cd $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) -wave_run 

.PHONY: run-sim-help
run-sim-help:
	mkdir -p $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	cd $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) -help 


################## hardware build
XOCCFLAGS := --platform $(PLATFORM) -t $(TARGET) -s -g
XOCCLFLAGS := --link --optimize 3
# You could uncomment following line and modify the options for hardware debug/profiling
# DEBUG_OPT := --debug.chipscope $(KERNEL_NAME)_1 --debug.protocol all --profile_kernel data:all:all:all:all

.PHONY: package-kernel
package-kernel: gen-scripts-dir gen-ip-dir
	rm -rf $(ACTIVE_APP_DIR)/vivado_package_kernel;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_package_kernel;\
	cd $(ACTIVE_APP_DIR)/vivado_package_kernel;\
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/package_kernel.tcl -tclargs $(PART) $(KERNEL_NAME) $(ACTIVE_APP_DIR) vivado_package_kernel $(IP_DIR_ACTIVE)

.PHONY: build-hw
build-hw: $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xo
	export XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	rm -rf $(ACTIVE_APP_DIR)/$(KERNEL_NAME)_vivado_build_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_build_$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_build_$(TARGET) ;\
	nohup $(VPP) $(XOCCLFLAGS) $(XOCCFLAGS) $(DEBUG_OPT) --config $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_build_hw.cfg \
	--temp_dir $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_temp \
	--log_dir $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_log \
	--report_dir $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_report \
	-o $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xo &
	tail -f $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/nohup.out


################## hardware run
.PHONY: run-fpga
run-fpga: gen-host-bin
	unset XCL_EMULATION_MODE ;\
	rm -rf $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS)

.PHONY: run-fpga-debug
run-fpga-debug: gen-host-bin
	unset XCL_EMULATION_MODE ;\
	rm -rf $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	gdb -ex=r --args ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS)

.PHONY: run-emu
run-emu: gen-host-bin
	export XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	rm -rf $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ./xrt.ini ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_cmd_xsim.tcl ./xsim.tcl ;\
	echo "Generating emulation config file for platform $(PLATFORM).." ;\
	emconfigutil --platform $(PLATFORM)  ;\
	echo "Enter Hardware Emulation Mode" ;\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS)

.PHONY: run-emu-debug
run-emu-debug: gen-host-bin
	export XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	rm -rf $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ./xrt.ini ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_cmd_xsim.tcl ./xsim.tcl ;\
	echo "Generating emulation config file for platform $(PLATFORM).." ;\
	emconfigutil --platform $(PLATFORM)  ;\
	echo "Enter Hardware Emulation Mode" ;\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	gdb -ex=r --args $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS)

.PHONY: run-emu-wave
run-emu-wave: $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/$(PLATFORM)-0-$(KERNEL_NAME)_$(TARGET).wdb
	export XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	xsim --gui $(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb

.PHONY: gen-host-bin
gen-host-bin:
	make $(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -w -C $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR) -j$(MAKE_NUM_THREADS)


.PHONY: all
all: gen-vip package-kernel build-hw

################## clean up
.PHONY: clean
clean:
	rm -rf $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR)_*
	rm -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x
	rm -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg
