# =========================================================
# Directory/Project Configurations                           
# =========================================================

APP                 ?= glay

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
HOST_NAME           ?= $(shell /usr/bin/hostnamectl --transient 2>/dev/null)

GIT_VER             ?= $(shell cd .. ; git log -1 --pretty=format:"%h")

APP_DIR             ?= $(shell cd .. && pwd | xargs basename )
HOST_DIR            ?= 00_host
DEVICE_DIR          ?= 01_device
BENCH_DIR           ?= 02_test_graphs

GRAPH_DIR  ?= $(ROOT_DIR)/$(APP_DIR)/$(BENCH_DIR)
GRAPH_SUIT ?= TEST
GRAPH_NAME ?= v51_e1021

XILINX_DIR          ?= xilinx_project
SCRIPTS_DIR         ?= scripts
SCRIPTS_PERL        ?= scripts_pl
SCRIPTS_TCL         ?= scripts_tcl
SCRIPTS_SHELL       ?= scripts_sh
SCRIPTS_XDC         ?= scripts_xdc
IP_DIR              ?= ip
REPORTS_DIR         ?= reports

VIVADO_PACKAGE_DIR  = vivado_package_kernel
VIVADO_SIMULATE_DIR = vivado_simulate_kernel
VIVADO_RUN_DIR      = vivado_run_$(TARGET)
VIVADO_BUILD_DIR    = vivado_build_$(TARGET)
VIVADO_VIP_DIR      = vivado_generated_vip

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
ALL_SYSTEM_VERILOG_SOURCES  := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.sv)
ALL_VERILOG_SOURCES         := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.v)
ALL_VERILOG_HEADERS         := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR)/,*.vh)
ALL_SCRIPTS_SOURCES         := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/,*)
ALL_DESIGN_SOURCES          := $(ALL_SYSTEM_VERILOG_SOURCES) $(ALL_VERILOG_SOURCES) $(ALL_VERILOG_HEADERS)

XILINX_DIR_ACTIVE   ?= $(XILINX_DIR)_$(KERNEL_NAME)_$(GIT_VER)
SCRIPTS_DIR_ACTIVE  ?= vivado_$(SCRIPTS_DIR)
IP_DIR_ACTIVE       ?= vivado_$(IP_DIR)
REPORTS_DIR_ACTIVE  ?= vivado_$(REPORTS_DIR)

ACTIVE_APP_DIR      := $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)

KERNEL_NAME         ?= glay_kernel
DEVICE_INDEX        ?= 0
XCLBIN_PATH         ?= $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin
FPGA_ARGS           ?= -m $(DEVICE_INDEX) -q $(XCLBIN_PATH) -Q $(KERNEL_NAME)



ifeq ($(HOST_NAME), panther)
	ALVEO?=  U280
	PART ?=  xcu280-fsvh2892-2L-e
	PLATFORM ?= xilinx_u280_xdma_201920_3
else ifeq ($(HOST_NAME), jaguar)
	ALVEO?=  U250
	PART ?=  xcu250-figd2104-2L-e
	PLATFORM ?=  xilinx_u250_gen3x16_xdma_4_1_202210_1
else 
	ALVEO?=  U250
	PART ?=  xcu250-figd2104-2L-e
	PLATFORM ?=  xilinx_u250_gen3x16_xdma_4_1_202210_1

#   ALVEO?=  U200
#   PART ?=  xcu200-fsgd2104-2-e
#   PLATFORM ?=  xilinx_u200_gen3x16_xdma_2_202110_1

#   ALVEO?=  U50
#   PART ?=  xcu50-fsvh2104-2-e
#   PLATFORM ?=  xilinx_u50_gen3x16_xdma_5_202210_1

#   ALVEO?=  U55
#   PART ?=  xcu55c-fsvh2892-2L-e
#   PLATFORM ?=  xilinx_u55c_gen3x16_xdma_3_202210_1

#   ALVEO?=  U280
#   PART ?=  xcu280-fsvh2892-2L-e
#   PLATFORM ?=  xilinx_u280_gen3x16_xdma_1_202211_1
endif

# TARGET: set the build target, can be hw or hw_emu
TARGET   ?= hw_emu
# TARGET ?= hw

# Enabling Multiple Strategies For Closing Timing
XILINX_IMPL_STRATEGY ?= 0
XILINX_JOBS_STRATEGY ?= 2
XILINX_MAX_THREADS   ?= $(shell grep -c ^processor /proc/cpuinfo)

XILINX_CTRL_MODE     ?= USER_MANAGED
# XILINX_CTRL_MODE     ?= AP_CTRL_HS
# XILINX_CTRL_MODE     ?= AP_CTRL_CHAIN
# XILINX_CTRL_MODE     ?= ap_ctrl_none


TESTBENCH_MODULE     ?= glay
# TESTBENCH_MODULE     ?= arbiter

# =========================================================
# CLI COMMANDS                           
# =========================================================
RM      :=-@rm -f
RMDIR   :=-@rm -rf
CP_RF   :=-@cp -rf
MKDIR   :=-@mkdir
MKDIR_P :=-@mkdir -p
EXPORT  :=-@export
CD      :=-@cd
ECHO    :=-@echo
BASH    :=-@bash
TAIL_F  :=-@tail -f 
UNSET   :=-@unset
EMCONFIGUTIL := $(XILINX_VITIS)/bin/emconfigutil

# =========================================================
# Color coded messages                      
# =========================================================
YELLOW  ?=\033[0;33m
GREEN   ?=\033[0;32m
BLUE    ?=\033[0;34m
RED     ?=\033[0;31m
NC      ?=\033[0m

# =========================================================
# COMPILER FLAGS                         
# =========================================================
CXX     := g++
VPP     := v++
GCC     := gcc
CC      := gcc

# =========================================================
# Starting point of GLay generate IPs and compile Host
# =========================================================
.PHONY: start
start: gen-vip package-kernel
# =========================================================

# =========================================================
#  Build info output to terminal
# =========================================================
.PHONY: session-info
session-info: 
	$(ECHO) "========================================================="
	$(ECHO) "${BLUE}Build $(APP_DIR)${NC} -> ${RED}$(MAKECMDGOALS)${NC}"
	$(ECHO) "========================================================="
	$(ECHO) "${BLUE}HOST_NAME   ${NC}| ${GREEN}$(HOST_NAME)${NC}"
	$(ECHO) "${BLUE}KERNEL_NAME ${NC}| ${GREEN}$(KERNEL_NAME)${NC}"
	$(ECHO) "${BLUE}ALVEO       ${NC}| ${GREEN}$(ALVEO)${NC}"
	$(ECHO) "${BLUE}PART        ${NC}| ${GREEN}$(PART)${NC}"
	$(ECHO) "${BLUE}PLATFORM    ${NC}| ${GREEN}$(PLATFORM)${NC}"
	$(ECHO) "${BLUE}TARGET      ${NC}| ${GREEN}$(TARGET)${NC}"
	$(ECHO) "${BLUE}CTRL_MODE   ${NC}| ${GREEN}$(XILINX_CTRL_MODE)${NC}"
	$(ECHO) "========================================================="
	$(ECHO) "${BLUE}GIT_VER     | ${YELLOW}$(GIT_VER)${NC}"
	$(ECHO) "========================================================="
# =========================================================

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
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/generate_source_ip.sh $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR) $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(TESTBENCH_MODULE) $(GRAPH_DIR) $(GRAPH_SUIT) $(GRAPH_NAME)

.PHONY: gen-ip-dir
gen-ip-dir: $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE)

.PHONY: $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)
$(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE):
	$(RMDIR) $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)  ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_TCL)   ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_XDC)   ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_PERL)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_PERL)/$$file $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/$$file; done    ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_TCL)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_TCL)/$$file $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_TCL)/$$file; done       ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_SHELL)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_SHELL)/$$file $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/$$file; done ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_XDC)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(SCRIPTS_DIR)/$(SCRIPTS_XDC)/$$file $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_XDC)/$$file; done ;\

.PHONY: gen-scripts-dir
gen-scripts-dir: $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) $(ACTIVE_APP_DIR)/$(IP_DIR_ACTIVE)
	$(BASH) $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/generate_xrt_ini.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(XILINX_CTRL_MODE) $(SCRIPTS_TCL) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/generate_build_cfg.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(XILINX_IMPL_STRATEGY) $(XILINX_JOBS_STRATEGY) $(PART) $(XILINX_MAX_THREADS);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/generate_package_filelist_f.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(IP_DIR_ACTIVE) $(VIVADO_VIP_DIR) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/generate_xdc_filelist_f.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(ALVEO) ;\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/generate_xsim_filelist_f.sh $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(KERNEL_NAME) $(IP_DIR_ACTIVE) $(VIVADO_VIP_DIR) $(TESTBENCH_MODULE)
	
.PHONY: $(ACTIVE_APP_DIR)/$(VIVADO_VIP_DIR)
$(ACTIVE_APP_DIR)/$(VIVADO_VIP_DIR):
	$(RMDIR) $(ACTIVE_APP_DIR)/$(VIVADO_VIP_DIR);\
	mkdir -p $(ACTIVE_APP_DIR)/$(VIVADO_VIP_DIR)

.PHONY: gen-vip
gen-vip: session-info  gen-scripts-dir $(ACTIVE_APP_DIR)/$(VIVADO_VIP_DIR)
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_VIP_DIR);\
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_TCL)/generate_vip.tcl -notrace -tclargs $(PART) $(KERNEL_NAME) $(ACTIVE_APP_DIR) $(VIVADO_VIP_DIR)

# =========================================================
#  Run Hardware Simulation  
# =========================================================
.PHONY: $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR)
$(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR):
	$(RMDIR) $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR);\
	mkdir -p $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR)

.PHONY: run-sim 
run-sim: session-info $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR)
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(SCRIPTS_TCL) | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_sim.pl

.PHONY: run-sim-gui
run-sim-gui: session-info $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR)
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(SCRIPTS_TCL) -sim_gui | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_sim.pl

.PHONY: run-sim-noclean
run-sim-noclean: session-info 
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(SCRIPTS_TCL) -noclean_files | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_sim.pl

.PHONY: run-sim-reset
run-sim-reset: session-info 
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(SCRIPTS_TCL) -reset_run | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_sim.pl

.PHONY: run-sim-wave
run-sim-wave: session-info  $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR)/work.$(KERNEL_NAME)_testbench.wdb
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR) $(SCRIPTS_DIR_ACTIVE) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(SCRIPTS_TCL) -wave_run | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_sim.pl

.PHONY: run-sim-help
run-sim-help: session-info 
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_SIMULATE_DIR);\
	bash $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_SHELL)/testbench_xsim.sh $(KERNEL_NAME) $(ACTIVE_APP_DIR)  $(SCRIPTS_DIR_ACTIVE) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(SCRIPTS_TCL) -help  | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_sim.pl

# =========================================================
# XCLBIN V++ Flags
# =========================================================
XOCCFLAGS   =   --platform $(PLATFORM) -t $(TARGET) -s -g
XOCCLFLAGS  =   --link --optimize 3
VPPCONFLAGS =   --config $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_build_hw.cfg \
				--temp_dir $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_temp \
				--log_dir $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_log \
				--report_dir $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_report
		


# You could uncomment following line and modify the options for hardware debug/profiling
# DEBUG_OPT   = --debug.chipscope $(KERNEL_NAME)_1 --debug.protocol all --profile_kernel data:all:all:all:all

# =========================================================
# Package Generation .XO
# =========================================================
.PHONY: $(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR)
$(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR):
	$(RMDIR) $(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR);\
	rm -f $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xo ;\
	rm -f $(ACTIVE_APP_DIR)/$(KERNEL_NAME).xml ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR)

$(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo: gen-scripts-dir $(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR)
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR);\
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_TCL)/package_kernel.tcl -notrace -tclargs $(PART) $(KERNEL_NAME) $(ACTIVE_APP_DIR) $(VIVADO_PACKAGE_DIR) $(IP_DIR_ACTIVE) $(XILINX_CTRL_MODE) $(SCRIPTS_DIR_ACTIVE)

.PHONY: package-kernel
package-kernel: session-info $(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo
	
# =========================================================
# XCLBIN File Generation
# =========================================================
.PHONY: $(VIVADO_BUILD_DIR)
$(VIVADO_BUILD_DIR): session-info
	$(RMDIR) $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR) ;\
	touch $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).log ;\
	touch $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).err 

.PHONY: $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin
$(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin: $(VIVADO_BUILD_DIR) 
	$(EXPORT) XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR) ;\
	nohup $(VPP) $(XOCCLFLAGS) $(XOCCFLAGS) $(DEBUG_OPT) $(VPPCONFLAGS) -o $@ $(ACTIVE_APP_DIR)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo > $(KERNEL_NAME)_$(TARGET).log 2> $(KERNEL_NAME)_$(TARGET).err &

.PHONY: build-hw
build-hw: $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin 
	$(TAIL_F) $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).log | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_impl.pl
	
# =========================================================
# Run Hardware FPGA
# =========================================================
.PHONY: $(VIVADO_RUN_DIR)
$(VIVADO_RUN_DIR):
ifeq ($(TARGET),hw_emu)
	$(RMDIR) $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR)/xrt.ini ;\
	cp $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_TCL)/cmd_xsim.tcl $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR)/xsim.tcl
else
	$(RMDIR) $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR)
endif

.PHONY: run-fpga-cmd
run-fpga-cmd: gen-host-bin $(VIVADO_RUN_DIR)
ifeq ($(TARGET),hw)
	$(UNSET) XCL_EMULATION_MODE ;\
	rm -rf $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
	mkdir -p $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
	cd $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
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
run-fpga: session-info run-fpga-cmd
	
.PHONY: run-fpga-debug
run-fpga-debug: DEBUG_CMD=1
run-fpga-debug: session-info run-fpga-cmd
	
# =========================================================
# Run Hardware Emulation  
# =========================================================
.PHONY: run-emu-cmd
run-emu-cmd: gen-host-bin $(VIVADO_RUN_DIR)
ifeq ($(TARGET),hw_emu)
	$(EXPORT) XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	cd $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
	echo "INFO: Generating emulation config file for platform $(PLATFORM)" | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_emu.pl ;\
	emconfigutil --platform $(PLATFORM)  | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_emu_sub.pl;\
	echo "INFO: Enter Hardware Emulation Mode" | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_emu_sub.pl;\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	if [ $(DEBUG_CMD) -eq 1 ]; then \
		gdb -ex=r --args $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) ;\
	else \
		$(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_emu_sub.pl;\
	fi
else
	$(ECHO) "${RED}ERROR: This build target <TARGET=hw_emu> not valid when design target is <<TARGET=$(TARGET)>> ${NC}" | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_emu.pl
endif

.PHONY: run-emu
run-emu: DEBUG_CMD=0
run-emu: session-info run-emu-cmd
	
.PHONY: run-emu-debug
run-emu-debug: DEBUG_CMD=1
run-emu-debug: run-emu-cmd
	
.PHONY: run-emu-wave
run-emu-wave: session-info $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR)/$(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_RUN_DIR) ;\
	xsim --gui $(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_sim.pl

# =========================================================
# Application Executable File Generation
# =========================================================
.PHONY: gen-host-bin
gen-host-bin:
	-@$(MAKE) $(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -w -C $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR) -j$(MAKE_NUM_THREADS)

# =========================================================
# Open Project in Vivado GUI
# =========================================================
.PHONY: open-vivado-project
open-vivado-project: session-info $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_temp/link/vivado/vpl/prj/prj.xpr
	$(CD) $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR); \
	vivado $(KERNEL_NAME)_temp/link/vivado/vpl/prj/prj.xpr 

# =========================================================
#  Report Utilization Metrics
# =========================================================
# If the target is HW, this generates the power and resource
# utilization metrics.
# =========================================================
.PHONY: report_metrics
report_metrics: session-info $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE) 
ifeq ($(TARGET),hw_emu)
	$(ECHO) "${RED}ERROR: This build target <TARGET=hw> (report-metrics) not valid when design target is <<TARGET=$(TARGET)>> ${NC}"
else
	$(RMDIR) $(ACTIVE_APP_DIR)/$(REPORTS_DIR_ACTIVE)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(REPORTS_DIR_ACTIVE)
	$(CD) $(ACTIVE_APP_DIR)/$(REPORTS_DIR_ACTIVE); \
	vivado -mode batch -source $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_TCL)/report_metrics.tcl -notrace $(ACTIVE_APP_DIR)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_temp/link/vivado/vpl/prj/prj.xpr | perl $(ACTIVE_APP_DIR)/$(SCRIPTS_DIR_ACTIVE)/$(SCRIPTS_PERL)/color_tail_report.pl
	$(ECHO) ""
	$(ECHO) "INFO: Vivado Utilization/Power Report Generation Complete..."
	$(ECHO) "####################################"
	$(ECHO) ""
endif

# =========================================================
#  Help menu
# =========================================================
.PHONY: help
help: session-info 
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  STEP 1. Scripts/VIPs/Directories generation "
	$(ECHO) "   make gen-vip"
	$(ECHO) "      Command to generate the IPs used in this design"
	$(ECHO) ""
	$(ECHO) "  STEP 2.a Run Hardware Simulation "
	$(ECHO) "   make run-sim"
	$(ECHO) "      Command to run the simulation"
	$(ECHO) ""
	$(ECHO) "  STEP 2.b Package Generation "
	$(ECHO) "   make package-kernel"
	$(ECHO) "      Command to pack the module $(KERNEL_NAME) to Vitis kernel"
	$(ECHO) ""
	$(ECHO) "  STEP 3.a XCLBIN File Generation"
	$(ECHO) "   make build-hw"
	$(ECHO) "      Command to build xclbin files for Alveo platform, including $(KERNEL_NAME)"
	$(ECHO) ""
	$(ECHO) "  STEP 3.b Application Executable File Generation"
	$(ECHO) "   make gen-host-bin"
	$(ECHO) "      compiles host binary to call $(KERNEL_NAME), auto-generated with other make rules"
	$(ECHO) ""
	$(ECHO) "  STEP 4.a Run Hardware Emulation"
	$(ECHO) "   make run-emu"
	$(ECHO) "      compiles host binary and emulates $(KERNEL_NAME)"
	$(ECHO) ""
	$(ECHO) "  STEP 4.b Run Hardware FPGA"
	$(ECHO) "   make run-fpga"
	$(ECHO) "      compiles host binary and run $(KERNEL_NAME) on Alveo FPGA board"
	$(ECHO) ""
	$(ECHO) "  STEP 5.a Open Project in Vivado GUI"
	$(ECHO) "   make open-vivado-project"
	$(ECHO) "      opens hw/hw_emu project in GUI mode"
	$(ECHO) ""
	$(ECHO) "  STEP 5.b Report Utilization Metrics"
	$(ECHO) "   make report_metrics"
	$(ECHO) "      generates reports folder after synthesis complete"
	$(ECHO) ""
	$(ECHO) "   make clean"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
	$(ECHO) "   Github commit version:"
	$(ECHO) "      $(GIT_VER)"

# =========================================================
# Clean Projects
# =========================================================
.PHONY: clean
clean: session-info 
	$(RMDIR) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/.Xil
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
clean-all: session-info 
	$(RMDIR) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/.Xil
	$(RMDIR) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR)_*
	$(RMDIR) *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x
	$(RMDIR) *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str
	$(CD) $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR) ;\
	rm -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x ;\
	rm -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str
	$(CD) $(ROOT_DIR)/$(APP_DIR) ;\
	rm -rf *.xo *.xclbin *.xclbin.info *.xclbin.link_summary *.jou *.log *.xo.compile_summary _x ;\
	rm -rf *.dat *.pb xsim.dir *.xml *.ltx *.csv *.json *.protoinst *.wdb *.wcfg *.str