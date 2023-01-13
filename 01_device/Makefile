.PHONY: help
help:
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make gen-vip"
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
	$(ECHO) "  $(GIT_VER)"

# =========================================================
# Directory/Project Configurations                           
# =========================================================

APP                 ?= glay
KERNEL_NAME         ?= glay_kernel
# APP_TEST            ?= test_match
# APP_TEST            ?= test_glay
# APP_TEST            ?= test_StalaGraph
APP_TEST            ?= test_glayGraph_$(XILINX_CTRL_MODE)
APP_LANG            ?= cpp
# APP_LANG            ?= c
INTEGRATION         ?= openmp
# INTEGRATION         ?= ggdl

MAKE_NUM_THREADS    ?= $(shell grep -c ^processor /proc/cpuinfo)
ROOT_DIR            ?= $(shell cd ../../ ; pwd)
GIT_VER             ?= $(shell cd .. && git log -1 --pretty=format:"%h")

APP_DIR             ?= 00_GLay
HOST_DIR            ?= 00_host
DEVICE_DIR          ?= 01_device

XILINX_DIR          ?= xilinx_project
SCRIPTS_DIR         ?= scripts
IP_DIR              ?= glay_ip
REPORTS_DIR         ?= reports

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
ALL_SYSTEM_VERILOG_SOURCES  := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.sv)
ALL_VERILOG_SOURCES 		:= $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.v)
ALL_VERILOG_HEADERS 		:= $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.vh)
ALL_SCRIPTS_SOURCES 		:= $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/,*)
ALL_DESIGN_SOURCES 		    := $(ALL_SYSTEM_VERILOG_SOURCES) $(ALL_VERILOG_SOURCES) $(ALL_VERILOG_HEADERS)

XILINX_DIR_ACTIVE  	?= $(XILINX_DIR)_$(KERNEL_NAME)_$(GIT_VER)
SCRIPTS_DIR_ACTIVE 	?= $(SCRIPTS_DIR)
IP_DIR_ACTIVE       ?= $(IP_DIR)
REPORTS_DIR_ACTIVE  ?= $(REPORTS_DIR)

ACTIVE_APP_DIR      := $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)

DEVICE_INDEX        ?= 0
XCLBIN_PATH         ?= $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin
GLAY_FPGA_ARGS      ?= -m $(DEVICE_INDEX) -q $(XCLBIN_PATH) -Q $(KERNEL_NAME)

ifeq ($(HOST_NAME), panther)
	PART ?=  xcu280-fsvh2892-2L-e
	PLATFORM ?= xilinx_u280_xdma_201920_3
else ifeq ($(HOST_NAME), jaguar)
	PART ?=  xcu250-figd2104-2L-e
	PLATFORM ?=  xilinx_u250_gen3x16_xdma_4_1_202210_1
else 
	PART ?=  xcu250-figd2104-2L-e
	PLATFORM ?=  xilinx_u250_gen3x16_xdma_4_1_202210_1

# 	PART ?=  xcu200-fsgd2104-2-e
# 	PLATFORM ?=  xilinx_u200_gen3x16_xdma_2_202110_1

# 	PART ?=  xcu50-fsvh2104-2-e
# 	PLATFORM ?=  xilinx_u50_gen3x16_xdma_5_202210_1

# 	PART ?=  xcu55c-fsvh2892-2L-e
# 	PLATFORM ?=  xilinx_u55c_gen3x16_xdma_3_202210_1

# 	PART ?=  xcu280-fsvh2892-2L-e
# 	PLATFORM ?=  xilinx_u280_gen3x16_xdma_1_202211_1
endif

# TARGET: set the build target, can be hw or hw_emu
TARGET   ?= hw_emu
# TARGET ?= hw

# Enabling Multiple Strategies For Closing Timing
XILINX_IMPL_STRATEGY ?= 0
XILINX_JOBS_STRATEGY ?= 2
XILINX_CTRL_MODE     ?= user_managed
# XILINX_CTRL_MODE     ?= ap_ctrl_hs
# XILINX_CTRL_MODE     ?= ap_ctrl_chain
# XILINX_CTRL_MODE     ?= ap_ctrl_none

# =========================================================
# CLI COMMANDS                           
# =========================================================

RM      :=@rm -f
RMDIR   :=@rm -rf
CP_RF   :=@cp -rf
MKDIR   :=@mkdir
MKDIR_P :=@mkdir -p
EXPORT  :=@export
CD      :=@cd
ECHO    :=@echo
BASH    :=@bash
TAIL_F  :=@tail -f 
UNSET   :=@unset
EMCONFIGUTIL := $(XILINX_VITIS)/bin/emconfigutil

RED     =\033[0;31m
NC      =\033[0m # No Color

# =========================================================
# COMPILER FLAGS                         
# =========================================================

CXX     := g++
VPP     := v++
GCC     := gcc
CC      := gcc

# =========================================================
#  Compile all steps
# =========================================================

.PHONY: all
all: gen-vip package-kernel build-hw

# =========================================================
#  Scripts/VIPs/Directories generation 
# =========================================================

.PHONY: $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE)
$(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE):
	$(RMDIR) $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE) ;\
	cp -r $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/* $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE)/

.PHONY: gen-ip-dir
gen-ip-dir: $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE)

.PHONY: $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)
$(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE):
	$(RMDIR) $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$$file $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$$file; done 
	
.PHONY: gen-scripts-dir
gen-scripts-dir: $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE)
	$(BASH) $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_xrt_ini.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_build_cfg.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(XILINX_IMPL_STRATEGY) $(XILINX_JOBS_STRATEGY);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_package_filelist_f.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(IP_DIR_ACTIVE) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_xsim_filelist_f.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(IP_DIR_ACTIVE) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_package_kernel_tcl.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE)

.PHONY: $(ACTIVE_APP_DIR)/vivado_generated_vip
$(ACTIVE_APP_DIR)/vivado_generated_vip:
	$(RMDIR) $(ACTIVE_APP_DIR)/vivado_generated_vip;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_generated_vip

.PHONY: gen-vip
gen-vip:  gen-scripts-dir $(ACTIVE_APP_DIR)/vivado_generated_vip
	$(CD) $(ACTIVE_APP_DIR)/vivado_generated_vip;\
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/generate_vip.tcl -notrace -tclargs $(PART) $(KERNEL_NAME) $(ACTIVE_APP_DIR) vivado_generated_vip

# =========================================================
#  Run Hardware Simulation  
# =========================================================

.PHONY: $(ACTIVE_APP_DIR)/vivado_simulate_kernel
$(ACTIVE_APP_DIR)/vivado_simulate_kernel:
	$(RMDIR) $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_simulate_kernel

.PHONY: run-sim
run-sim: $(ACTIVE_APP_DIR)/vivado_simulate_kernel
	$(CD) $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR)

.PHONY: run-sim-noclean
run-sim-noclean:
	$(CD) $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) -noclean_files

.PHONY: run-sim-reset
run-sim-reset:
	$(CD) $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) -reset_run 

.PHONY: run-sim-wave
run-sim-wave: $(ACTIVE_APP_DIR)/vivado_simulate_kernel/work.$(KERNEL_NAME)_testbench.wdb
	$(CD) $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) -wave_run 

.PHONY: run-sim-help
run-sim-help:
	$(CD) $(ACTIVE_APP_DIR)/vivado_simulate_kernel;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) -help 

# =========================================================
# XCLBIN V++ Flags
# =========================================================

XOCCFLAGS   = 	--platform $(PLATFORM) -t $(TARGET) -s -g
XOCCLFLAGS  = 	--link --optimize 3
VPPCONFLAGS = 	--config $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_build_hw.cfg \
				--temp_dir $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_temp \
				--log_dir $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_log \
				--report_dir $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_report

# You could uncomment following line and modify the options for hardware debug/profiling
# DEBUG_OPT   = --debug.chipscope $(KERNEL_NAME)_1 --debug.protocol all --profile_kernel data:all:all:all:all

# =========================================================
# Package Generation .XO
# =========================================================

.PHONY: $(ACTIVE_APP_DIR)/vivado_package_kernel
$(ACTIVE_APP_DIR)/vivado_package_kernel:
	$(RMDIR) $(ACTIVE_APP_DIR)/vivado_package_kernel;\
	rm -f $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xo ;\
	rm -f $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xml ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_package_kernel

$(ACTIVE_APP_DIR)/$(KERNEL_NAME).xo: gen-scripts-dir $(ACTIVE_APP_DIR)/vivado_package_kernel
	$(CD) $(ACTIVE_APP_DIR)/vivado_package_kernel;\
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_package_kernel.tcl -notrace -tclargs $(PART) $(KERNEL_NAME) $(ACTIVE_APP_DIR) vivado_package_kernel $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE)

.PHONY: package-kernel
package-kernel: $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xo
	
# =========================================================
# XCLBIN File Generation
# =========================================================

.PHONY: vivado_build_$(TARGET)
vivado_build_$(TARGET):
	$(RMDIR) $(ACTIVE_APP_DIR)/vivado_build_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)

.PHONY: $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin
$(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin: vivado_build_$(TARGET) 
	$(EXPORT) XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_build_$(TARGET) ;\
	touch $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/nohup.out ;\
	nohup $(VPP) $(XOCCLFLAGS) $(XOCCFLAGS) $(DEBUG_OPT) $(VPPCONFLAGS) -o $@ $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xo &

.PHONY: build-hw
build-hw: $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin 
	$(TAIL_F) $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/nohup.out
	
# =========================================================
# Run Hardware FPGA
# =========================================================

.PHONY: vivado_run_$(TARGET)
vivado_run_$(TARGET):
ifeq ($(TARGET),hw_emu)
	$(RMDIR) $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/xrt.ini ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/cmd_xsim.tcl $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/xsim.tcl
else
	$(RMDIR) $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)
endif

.PHONY: run-fpga-cmd
run-fpga-cmd: gen-host-bin vivado_run_$(TARGET)
ifeq ($(TARGET),hw)
	$(UNSET) XCL_EMULATION_MODE ;\
	rm -rf $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	mkdir -p $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	if [ $(DEBUG_CMD) -eq 1 ]; then \
		gdb -ex=r --args ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) ;\
	else \
		./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) ;\
	fi
else
	$(ECHO) "${RED}This build target <TARGET=hw> not valid when design target is <<TARGET=$(TARGET)>> ${NC}"
endif
	
.PHONY: run-fpga
run-fpga: DEBUG_CMD=0
run-fpga: run-fpga-cmd
	
.PHONY: run-fpga-debug
run-fpga-debug: DEBUG_CMD=1
run-fpga-debug: run-fpga-cmd
	
# =========================================================
# Run Hardware Emulation  
# =========================================================

.PHONY: run-emu-cmd
run-emu-cmd: gen-host-bin vivado_run_$(TARGET)
ifeq ($(TARGET),hw_emu)
	$(EXPORT) XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	echo "Generating emulation config file for platform $(PLATFORM).." ;\
	emconfigutil --platform $(PLATFORM)  ;\
	echo "Enter Hardware Emulation Mode" ;\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	if [ $(DEBUG_CMD) -eq 1 ]; then \
		gdb -ex=r --args $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) ;\
	else \
		$(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) ;\
	fi
else
	$(ECHO) "${RED}This build target <TARGET=hw_emu> not valid when design target is <<TARGET=$(TARGET)>> ${NC}"
endif

.PHONY: run-emu
run-emu: DEBUG_CMD=0
run-emu: run-emu-cmd
	
.PHONY: run-emu-debug
run-emu-debug: DEBUG_CMD=1
run-emu-debug: run-emu-cmd
	
.PHONY: run-emu-wave
run-emu-wave: $(ACTIVE_APP_DIR)/vivado_run_$(TARGET)/$(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb
	$(CD) $(ACTIVE_APP_DIR)/vivado_run_$(TARGET) ;\
	xsim --gui $(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb

# =========================================================
# Application Executable File Generation
# =========================================================

.PHONY: gen-host-bin
gen-host-bin:
	make $(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -w -C $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR) -j$(MAKE_NUM_THREADS)

# =========================================================
# Open Project in Vivado GUI
# =========================================================

.PHONY: open-vivado-project
open-vivado-project: $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_temp/link/vivado/vpl/prj/prj.xpr
	$(CD) $(ACTIVE_APP_DIR)/vivado_build_$(TARGET); \
	vivado $(KERNEL_NAME)_temp/link/vivado/vpl/prj/prj.xpr 

# =========================================================
#  Report Utilization Metrics
# =========================================================
# If the target is HW, this generates the power and resource
# utilization metrics.

report_metrics: $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) 
ifeq ($(TARGET),hw_emu)
	$(ECHO) "${RED}This build target <TARGET=hw> (report-metrics) not valid when design target is <<TARGET=$(TARGET)>> ${NC}"
else
	$(RMDIR) $(ACTIVE_APP_DIR)/$(REPORTS_DIR_ACTIVE)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(REPORTS_DIR_ACTIVE)
	$(CD) $(ACTIVE_APP_DIR)/$(REPORTS_DIR_ACTIVE); \
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/report_metrics.tcl -notrace $(ACTIVE_APP_DIR)/vivado_build_$(TARGET)/$(KERNEL_NAME)_temp/link/vivado/vpl/prj/prj.xpr
	$(ECHO) ""
	$(ECHO) "Vivado Utilization/Power Report Generation Complete..."
	$(ECHO) "####################################"
	$(ECHO) ""
endif

# =========================================================
# Clean Projects
# =========================================================

.PHONY: clean
clean:
	$(RMDIR) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR)*$(GIT_VER)
	$(RMDIR) *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x
	$(RMDIR) *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str
	$(CD) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR) ;\
	rm -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x ;\
	rm -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str
	$(CD) $(ROOT_DIR)/$(APP_DIR) ;\
	rm -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x ;\
	rm -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str


.PHONY: clean-all
clean-all:
	$(RMDIR) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR)_*
	$(RMDIR) *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x
	$(RMDIR) *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str
	$(CD) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR) ;\
	rm -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x ;\
	rm -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str
	$(CD) $(ROOT_DIR)/$(APP_DIR) ;\
	rm -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x ;\
	rm -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str