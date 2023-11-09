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

ifeq ($(shell cd .. ; git log -1 --pretty=format:"%h" 2>/dev/null),)
	GIT_VER ?= 1
else
	GIT_VER ?= $(shell cd .. ; git log -1 --pretty=format:"%h" 2>/dev/null)
endif

APP_DIR             ?= $(shell cd .. && pwd | xargs basename )
HOST_DIR            ?= 01_host
DEVICE_DIR          ?= 02_device
BENCH_DIR           ?= 03_data

GRAPH_DIR  ?= $(ROOT_DIR)/$(APP_DIR)/$(BENCH_DIR)
GRAPH_SUIT ?= TEST
GRAPH_NAME ?= v51_e1021

XILINX_DIR         ?= xilinx_project
UTILS_DIR          ?= utils
UTILS_PERL         ?= utils.pl
UTILS_TCL          ?= utils.tcl
UTILS_SHELL        ?= utils.sh
UTILS_XDC          ?= utils.xdc
IP_DIR_RTL         ?= rtl
IP_DIR_HLS         ?= hls
REPORTS_DIR        ?= rpt

VIVADO_PACKAGE_DIR  ?= vivado_$(KERNEL_NAME).pkg
VIVADO_SIMULATE_DIR ?= vivado_$(KERNEL_NAME).sim
VIVADO_RUN_DIR      ?= $(KERNEL_NAME).run
VIVADO_BUILD_DIR    ?= vivado_$(KERNEL_NAME).$(TARGET)
VIVADO_VMA_DIR      ?= vivado_$(KERNEL_NAME).vma
VIVADO_EXPORT_DIR   ?= $(KERNEL_NAME).export
VIVADO_IMPORT_DIR   ?= $(KERNEL_NAME).import
VIVADO_VIP_DIR      ?= vivado_$(KERNEL_NAME).vip
VITIS_BUILD_DIR     ?= vitis_$(KERNEL_NAME).pkg

rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
ALL_SYSTEM_VERILOG_SOURCES  := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR_RTL)/,*.sv)
ALL_VERILOG_SOURCES         := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR_RTL)/,*.v)
ALL_VERILOG_HEADERS         := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(IP_DIR_RTL)/,*.vh)
ALL_UTILS_SOURCES           := $(call rwildcard,$(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/,*)
ALL_DESIGN_SOURCES          := $(ALL_SYSTEM_VERILOG_SOURCES) $(ALL_VERILOG_SOURCES) $(ALL_VERILOG_HEADERS)

XILINX_DIR_ACTIVE   ?= $(XILINX_DIR)_$(KERNEL_NAME)_$(CAPABILITY)_$(GIT_VER)
UTILS_DIR_ACTIVE    ?= vivado_$(UTILS_DIR)
IP_DIR_RTL_ACTIVE   ?= vivado_$(IP_DIR_RTL)
IP_DIR_HLS_ACTIVE   ?= vivado_$(IP_DIR_HLS)
REPORTS_DIR_ACTIVE  ?= vivado_$(REPORTS_DIR)

APP_DIR_ACTIVE      ?= $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)

KERNEL_NAME         ?= glay_kernel
DEVICE_INDEX        ?= 0
XCLBIN_PATH         ?= $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin
FPGA_ARGS           ?= -m $(DEVICE_INDEX) -q $(XCLBIN_PATH) -Q $(KERNEL_NAME)



ifeq ($(HOST_NAME), default)
	ALVEO?=  U250
	PART ?=  xcu250-figd2104-2L-e
	PLATFORM   ?=  xilinx_u250_gen3x16_xdma_4_1_202210_1
	
	VIVADO_VER ?= 2022
	DESIGN_FREQ_HZ ?= 300000000  
	XILINX_JOBS_STRATEGY ?= 1
    XILINX_MAX_THREADS   ?= 1
else ifeq ($(HOST_NAME), panther)
	ALVEO?=  U280
	PART ?=  xcu280-fsvh2892-2L-e
	PLATFORM   ?= xilinx_u280_gen3x16_xdma_1_202211_1
	
	VIVADO_VER ?= 2022
	DESIGN_FREQ_HZ ?= 300000000  
	XILINX_JOBS_STRATEGY ?= 4
    XILINX_MAX_THREADS   ?= 8
else ifeq ($(HOST_NAME), jaguar)
	ALVEO?=  U250
	PART ?=  xcu250-figd2104-2L-e
	PLATFORM   ?=  xilinx_u250_gen3x16_xdma_4_1_202210_1
	
	VIVADO_VER ?= 2023
	DESIGN_FREQ_HZ ?= 250000000  
	XILINX_JOBS_STRATEGY ?= 4
    XILINX_MAX_THREADS   ?= 8
else 
	ALVEO?=  U250
	PART ?=  xcu250-figd2104-2L-e
	PLATFORM ?= xilinx_u250_gen3x16_xdma_4_1_202210_1

#   ALVEO?=  U200
#   PART ?=  xcu200-fsgd2104-2-e
#   PLATFORM ?=  xilinx_u200_gen3x16_xdma_2_202110_1

#   ALVEO?=  U50
#   PART ?=  xcu50-fsvh2104-2-e
#   PLATFORM ?=  xilinx_u50_gen3x16_xdma_5_202210_1

#   ALVEO?=  U55
#   PART ?=  xcu55c-fsvh2892-2L-e
#   PLATFORM ?=  xilinx_u55c_gen3x16_xdma_3_202210_1

# 	ALVEO?=  U280
# 	PART ?=  xcu280-fsvh2892-2L-e
# 	PLATFORM   ?=  xilinx_u280_gen3x16_xdma_1_202211_1
	
	VIVADO_VER ?=2023
	DESIGN_FREQ_HZ ?= 250000000  
	XILINX_JOBS_STRATEGY ?= 4
    XILINX_MAX_THREADS   ?= 8
endif

# TARGET: set the build target, can be hw or hw_emu
TARGET   ?= hw_emu
# TARGET ?= hw

# Enabling Multiple Strategies For Closing Timing
XILINX_IMPL_STRATEGY ?= 1

# Enabling Multiple Kernels For CU
XILINX_NUM_KERNELS   ?= 1

XILINX_CTRL_MODE     ?= USER_MANAGED
# XILINX_CTRL_MODE     ?= AP_CTRL_HS
# XILINX_CTRL_MODE     ?= AP_CTRL_CHAIN
# XILINX_CTRL_MODE     ?= ap_ctrl_none


TESTBENCH_MODULE     ?= integration
# TESTBENCH_MODULE     ?= unit/arbiter

# =========================================================
# Each project has topology Architecture
# ARCHITECTURE.CAPABILITY/architecture.ALGORITHM_NAME.json
# Project GLay
# Capability Full, lite, Single, Test
# Algorithm BFS, PR, CC, SSSP, TC
# =========================================================
#if you make a push and use a previous compile 
ARCHITECTURE              ?= GLay
# CAPABILITY                = Test
# CAPABILITY                = Single
# CAPABILITY                = Lite
CAPABILITY                ?= Full
# =========================================================

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
start: package-kernel
# =========================================================

# =========================================================
#  Build info output to terminal
# =========================================================
.PHONY: session-info
session-info: 
	$(ECHO) "========================================================="
	$(ECHO) "${BLUE}Build $(APP_DIR)${NC} -> ${RED}$(MAKECMDGOALS)${NC}"
	$(ECHO) "========================================================="
	$(ECHO) "${BLUE}HOST_NAME      ${NC}| ${GREEN}$(HOST_NAME)${NC}"
	$(ECHO) "${BLUE}KERNEL_NAME    ${NC}| ${GREEN}$(KERNEL_NAME)${NC}"
	$(ECHO) "${BLUE}ALVEO          ${NC}| ${GREEN}$(ALVEO)${NC}"
	$(ECHO) "${BLUE}PART           ${NC}| ${GREEN}$(PART)${NC}"
	$(ECHO) "${BLUE}PLATFORM       ${NC}| ${GREEN}$(PLATFORM)${NC}"
	$(ECHO) "${BLUE}TARGET         ${NC}| ${GREEN}$(TARGET)${NC}"
	$(ECHO) "${BLUE}CTRL_MODE      ${NC}| ${GREEN}$(XILINX_CTRL_MODE)${NC}"
	$(ECHO) "${BLUE}DESIGN_FREQ_HZ ${NC}| ${GREEN}$(DESIGN_FREQ_HZ)${NC}"
	$(ECHO) "========================================================="
	$(ECHO) "${BLUE}GIT_VER     | ${YELLOW}$(GIT_VER)${NC}"
	$(ECHO) "========================================================="

.PHONY: sub-session-info
sub-session-info: 
	$(ECHO) "========================================================="
	$(ECHO) "${BLUE}Build $(APP_DIR)${NC} -> ${RED}$(MAKECMDGOALS)${NC}"
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

.PHONY: $(APP_DIR_ACTIVE)/$(IP_DIR_RTL_ACTIVE)
$(APP_DIR_ACTIVE)/$(IP_DIR_RTL_ACTIVE): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(IP_DIR_RTL_ACTIVE) ;\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_source_ip.sh $(PARAMS_SH_DIR)

.PHONY: gen-ip-dir
gen-ip-dir: sub-session-info | $(APP_DIR_ACTIVE)/$(IP_DIR_RTL_ACTIVE)

.PHONY: $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)
$(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE) ;\
	mkdir -p $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_PYTHON)  ;\
	mkdir -p $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_PERL)    ;\
	mkdir -p $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)     ;\
	mkdir -p $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)   ;\
	mkdir -p $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_XDC)/$(ALVEO)   ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_PYTHON)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_PYTHON)/$$file $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_PYTHON)/$$file; done    ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_PERL)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_PERL)/$$file $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_PERL)/$$file; done    ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_TCL)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_TCL)/$$file $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/$$file; done       ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_SHELL)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_SHELL)/$$file $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/$$file; done ;\
	for file in $$(ls $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_XDC)/$(ALVEO)) ; do cp -- $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(UTILS_DIR)/$(UTILS_XDC)/$(ALVEO)/$$file $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_XDC)/$(ALVEO)/$$file; done ;\

.PHONY: gen-utils-dir
gen-utils-dir: sub-session-info $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE) $(APP_DIR_ACTIVE)/$(IP_DIR_RTL_ACTIVE) gen-filelists $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt_ini $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_rtl_$(TARGET).cfg

.PHONY: $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt_ini
$(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt_ini: sub-session-info
	$(BASH) $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_xrt_ini.sh $(PARAMS_SH_DIR)

.PHONY: $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_rtl_$(TARGET).cfg
$(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_rtl_$(TARGET).cfg: sub-session-info
	$(BASH) $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_rtl_${TARGET}_cfg.sh $(PARAMS_SH_DIR)

.PHONY: gen-filelists
gen-filelists: sub-session-info
	$(BASH) $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_package_filelist_f.sh $(PARAMS_SH_DIR) ;\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_xdc_filelist_f.sh $(PARAMS_SH_DIR) ;\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_xsim_filelist_f.sh $(PARAMS_SH_DIR)

.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR)
$(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR)

.PHONY: gen-vip
gen-vip: session-info gen-utils-dir | $(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR)
ifeq ($(shell test -s $(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR)/$(KERNEL_NAME)/$(KERNEL_NAME).xpr && echo -n yes),yes)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR)
else
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/generate_vip.tcl -notrace -tclargs $(PARAMS_TCL_DIR) ;\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_xci_filelist_f.sh $(PARAMS_SH_DIR)
endif

.PHONY: clean-vip
clean-vip: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_VIP_DIR)

.PHONY: clean-utils-dir
clean-utils-dir: session-info 
	$(RMDIR) $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)

.PHONY: clean-ip-dir
clean-ip-dir: session-info 
	$(RMDIR) $(APP_DIR_ACTIVE)/$(IP_DIR_RTL_ACTIVE)

# =========================================================
# VPP Flow: Run Hardware Simulation  
# =========================================================
.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR)
$(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR)

.PHONY: run-sim 
run-sim: session-info gen-utils-dir | $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR) gen-vip 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR);\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/testbench_xsim.sh $(PARAMS_SH_DIR) | perl $(COLOR_TAIL_SIM_PL)

.PHONY: run-sim-gui
run-sim-gui: session-info gen-utils-dir | $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR) gen-vip 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR);\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/testbench_xsim.sh $(PARAMS_SH_DIR) -sim_gui | perl $(COLOR_TAIL_SIM_PL)

.PHONY: run-sim-noclean
run-sim-noclean: session-info gen-utils-dir | $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR) gen-vip 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR);\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/testbench_xsim.sh $(PARAMS_SH_DIR) -noclean_files | perl $(COLOR_TAIL_SIM_PL)

.PHONY: run-sim-reset
run-sim-reset: session-info gen-utils-dir | $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR) gen-vip 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR);\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/testbench_xsim.sh $(PARAMS_SH_DIR) -reset_run | perl $(COLOR_TAIL_SIM_PL)

.PHONY: run-sim-wave
run-sim-wave: session-info | $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR)/work.$(KERNEL_NAME)_testbench.wdb 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR);\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/testbench_xsim.sh $(PARAMS_SH_DIR) -wave_run | perl $(COLOR_TAIL_SIM_PL)

.PHONY: run-sim-help
run-sim-help: session-info 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR);\
	bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/testbench_xsim.sh $(PARAMS_SH_DIR) -help  | perl $(COLOR_TAIL_SIM_PL)

.PHONY: clean-sim
clean-sim: session-info 
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_SIMULATE_DIR)

# =========================================================
# VIVADO Project Mode
# =========================================================
.PHONY: run-sim-project
run-sim-project: session-info | $(KERNEL_PROJECT_PKG_XPR) 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_xsim.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_SIM_PL)

.PHONY: run-synth-project
run-synth-project: session-info | $(KERNEL_PROJECT_PKG_XPR) 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_synth.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_IMPL_PL)

.PHONY: run-impl-project
run-impl-project: session-info | $(KERNEL_PROJECT_PKG_XPR) 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_impl.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_IMPL_PL)

.PHONY: run-report-project
run-report-project: session-info | $(KERNEL_PROJECT_PKG_XPR) 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_impl.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_REPORT_PL)

.PHONY: open-vivado-project
open-vivado-project: session-info | $(KERNEL_PROJECT_PKG_XPR) 
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR); \
	vivado $(KERNEL_NAME)/$(KERNEL_NAME).xpr

# =========================================================
# VPP Flow: XCLBIN V++ Flags
# =========================================================
# XOCCFLAGS   =   
XOCCLFLAGS  =   --optimize 3 
VPPCONFLAGS =   --config $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_rtl_$(TARGET).cfg
		
# You could uncomment following line and modify the options for hardware debug/profiling
# DEBUG_OPT   = --debug.chipscope $(KERNEL_NAME)_1 --debug.protocol all --profile_kernel data:all:all:all:all

# =========================================================
# Package Generation .XO
# =========================================================
.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)
$(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)

.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo
$(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo: sub-session-info | gen-utils-dir $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)
ifeq ($(shell test -s $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo && echo -n yes),yes)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)
else
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR) ;\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_package_kernel.tcl -notrace -tclargs $(PARAMS_TCL_DIR)
endif

.PHONY: $(KERNEL_PROJECT_PKG_XPR) 
$(KERNEL_PROJECT_PKG_XPR): sub-session-info | gen-utils-dir $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)
ifeq ($(shell test -s $(KERNEL_PROJECT_PKG_XPR) && echo -n yes),yes)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)
else
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR) ;\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_package_kernel.tcl -notrace -tclargs $(PARAMS_TCL_DIR)
endif

.PHONY: package-kernel
package-kernel: session-info | $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo

.PHONY: clean-package-kernel
clean-package-kernel: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)

# =========================================================
# VPP Flow: Export to vivado flow
# =========================================================
.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)
$(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR) ;\
	touch $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)/$(KERNEL_NAME)_export.log ;\
	touch $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)/$(KERNEL_NAME)_export.err 

.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)/$(KERNEL_NAME)_export.vma
$(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)/$(KERNEL_NAME)_export.vma: sub-session-info | $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)
ifeq ($(shell test -s $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)/$(KERNEL_NAME)_export.vma && echo -n yes),yes)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)
else
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR) ;\
	nohup $(VPP) $(XOCCLFLAGS) $(XOCCFLAGS) $(DEBUG_OPT) $(VPPCONFLAGS) --export_archive -o $@ $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo > $(KERNEL_NAME)_export.log 2> $(KERNEL_NAME)_export.err &
endif

PHONY: export-hw
export-hw: TARGET=hw
export-hw: session-info | $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)/$(KERNEL_NAME)_export.vma $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_rtl_hw.cfg
	$(TAIL_F) $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)/$(KERNEL_NAME)_export.log | perl $(COLOR_TAIL_IMPL_PL)

PHONY: clean-export-hw
clean-export-hw: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_EXPORT_DIR)

# =========================================================
# Vivado Flow: Import VITIS vma
# =========================================================
.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_IMPORT_DIR)
$(APP_DIR_ACTIVE)/$(VIVADO_IMPORT_DIR): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_IMPORT_DIR)

# bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_vma_xci_filelist_f.sh $(APP_DIR_ACTIVE) $(UTILS_DIR_ACTIVE) $(KERNEL_NAME) $(VIVADO_EXPORT_DIR)/$(KERNEL_NAME).build/link/vivado/vpl/.local/hw_platform/bd/202210_1_dev.srcs/sources_1/bd/ulp/ip
# bash $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_SHELL)/generate_vma_xci_filelist_f.sh $(APP_DIR_ACTIVE) $(UTILS_DIR_ACTIVE) $(KERNEL_NAME) $(VIVADO_EXPORT_DIR)/$(KERNEL_NAME).build/link/vivado/vpl/.local/hw_platform/bd/202210_1_dev.srcs/sources_1/bd/ulp/ip 
.PHONY: import-hw
import-hw: session-info | $(APP_DIR_ACTIVE)/$(VIVADO_IMPORT_DIR) $(KERNEL_PROJECT_PKG_XPR)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_IMPORT_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_import_vma.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_IMPL_PL)

PHONY: clean-import-hw
clean-import-hw: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_IMPORT_DIR)

# =========================================================
# VPP Flow: XCLBIN File Generation
# =========================================================
# 	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)
.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)
$(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR): sub-session-info
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR) ;\
	touch $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).log ;\
	touch $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).err 

.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin
$(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin: sub-session-info | $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR) 
ifeq ($(shell test -s $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin && echo -n yes),yes)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)
else
	$(EXPORT) XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(UTILS_DIR_ACTIVE)/xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	cd $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR) ;\
	nohup $(VPP) $(XOCCLFLAGS) $(XOCCFLAGS) $(DEBUG_OPT) $(VPPCONFLAGS) -t $(TARGET) -o $@ $(APP_DIR_ACTIVE)/$(VIVADO_PACKAGE_DIR)/$(KERNEL_NAME).xo > $(KERNEL_NAME)_$(TARGET).log 2> $(KERNEL_NAME)_$(TARGET).err &
endif

.PHONY: build-hw
build-hw: session-info | $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).xclbin $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_rtl_$(TARGET).cfg
	$(TAIL_F) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(KERNEL_NAME)_$(TARGET).log | perl $(COLOR_TAIL_IMPL_PL)

PHONY: clean-build-hw
clean-build-hw: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)

# =========================================================
# VPP Flow: Run Hardware FPGA
# =========================================================
.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)
$(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR): sub-session-info
ifeq ($(TARGET),hw_emu)
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR) ;\
	cp $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)/xrt.ini ;\
	cp $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/cmd_xsim.tcl $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)/xsim.tcl
else
	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)
endif

.PHONY: run-fpga-cmd
run-fpga-cmd: sub-session-info | gen-host-bin $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)
ifeq ($(TARGET),hw)
	$(UNSET) XCL_EMULATION_MODE ;\
	cd $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR) ;\
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

PHONY: clean-run-fpga
clean-run-fpga: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)
	
# =========================================================
# VPP Flow: Run Hardware Emulation  
# =========================================================
.PHONY: $(APP_DIR_ACTIVE)/$(VIVADO_RUN_DIR)/$(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb
$(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)/$(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb : sub-session-info | gen-host-bin $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)
ifeq ($(TARGET),hw_emu)
	$(EXPORT) XRT_INI_PATH=$(ROOT_DIR)/$(APP_DIR)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_xrt.ini ;\
	export XCL_EMULATION_MODE=$(TARGET) ;\
	cd $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR) ;\
	echo "INFO: Generating emulation config file for platform $(PLATFORM)" | perl $(COLOR_TAIL_EMU_PL) ;\
	emconfigutil --platform $(PLATFORM) --od $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR) | perl $(COLOR_TAIL_EMU_SUB_PL);\
	echo "INFO: Enter Hardware Emulation Mode" | perl $(COLOR_TAIL_EMU_SUB_PL);\
	cp $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/bin/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) ;\
	if [ $(DEBUG_CMD) -eq 1 ]; then \
		gdb -ex=r --args ./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) ;\
	else \
		./$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS) ;\
	fi
else
	$(ECHO) "${RED}ERROR: This build target <TARGET=hw_emu> not valid when design target is <<TARGET=$(TARGET)>> ${NC}" | perl $(COLOR_TAIL_EMU_PL)
endif

.PHONY: run-emu
run-emu: DEBUG_CMD=0
run-emu: session-info | $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)/$(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb
	
.PHONY: run-emu-debug
run-emu-debug: DEBUG_CMD=1
run-emu-debug: run-emu-cmd
	
.PHONY: run-emu-wave
run-emu-wave: DEBUG_CMD=0
run-emu-wave: session-info | $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)/$(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR) ;\
	xsim --gui $(PLATFORM)-$(DEVICE_INDEX)-$(KERNEL_NAME)_$(TARGET).wdb | perl $(COLOR_TAIL_SIM_PL)

PHONY: clean-run-emu
clean-run-emu: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/$(VIVADO_RUN_DIR)

# =========================================================
# VPP Flow: Application Executable File Generation
# =========================================================
.PHONY: gen-host-bin
gen-host-bin: session-info
	-@$(MAKE) $(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -w -C $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR) -j$(MAKE_NUM_THREADS)

# =========================================================
# VPP Flow: Open Project
# =========================================================
.PHONY: run-vpp-sim-project
run-vpp-sim-project: session-info | $(KERNEL_PROJECT_VPP_XPR)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_xsim.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_SIM_PL)

.PHONY: run-vpp-synth-project
run-vpp-synth-project: session-info | $(KERNEL_PROJECT_VPP_XPR)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_synth.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_IMPL_PL)

.PHONY: run-vpp-impl-project
run-vpp-impl-project: session-info | $(KERNEL_PROJECT_VPP_XPR)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_impl.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_IMPL_PL)

.PHONY: run-vpp-report-project
run-vpp-report-project: session-info | $(KERNEL_PROJECT_VPP_XPR)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR);\
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/project_run_impl.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_REPORT_PL)

.PHONY: open-vpp-vivado-project
open-vpp-vivado-project: session-info | $(KERNEL_PROJECT_VPP_XPR)
	$(CD) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR); \
	vivado $(KERNEL_PROJECT_VPP_XPR)

PHONY: clean-vpp-vivado-project
clean-vpp-vivado-project: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VIVADO_BUILD_DIR)/${KERNEL_NAME}.build

# =========================================================
# VITIS Flow: Open Project
# =========================================================
.PHONY: $(APP_DIR_ACTIVE)/$(VITIS_BUILD_DIR)
$(APP_DIR_ACTIVE)/$(VITIS_BUILD_DIR): sub-session-info 
		$(MKDIR_P) $(APP_DIR_ACTIVE)/$(VITIS_BUILD_DIR)

.PHONY: open-vitis-project
open-vitis-project: session-info | $(APP_DIR_ACTIVE)/$(VITIS_BUILD_DIR)
	$(CD) $(APP_DIR_ACTIVE)/$(VITIS_BUILD_DIR); \
	vitis -workspace $(APP_DIR_ACTIVE)/$(VITIS_BUILD_DIR)

PHONY: clean-vitis-project
clean-vitis-projectt: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(VITIS_BUILD_DIR)/

# =========================================================
# VPP Flow: Report Utilization Metrics
# =========================================================
# If the target is HW, this generates the power and resource
# utilization metrics.
# =========================================================
.PHONY: report-metrics
report-metrics: KERNEL_PROJECT_XPR=$(KERNEL_PROJECT_VPP_XPR)
report-metrics: session-info | $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE) 
ifeq ($(TARGET),hw_emu)
	$(ECHO) "${RED}ERROR: This build target <TARGET=hw> (report-metrics) not valid when design target is <<TARGET=$(TARGET)>> ${NC}"
else

	$(MKDIR_P) $(APP_DIR_ACTIVE)/$(REPORTS_DIR_ACTIVE)
	$(CD) $(APP_DIR_ACTIVE)/$(REPORTS_DIR_ACTIVE); \
	vivado -mode batch -source $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(UTILS_TCL)/vpp_report_metrics.tcl -notrace -tclargs $(PARAMS_TCL_DIR) | perl $(COLOR_TAIL_REPORT_PL)
	$(ECHO) ""
	$(ECHO) "INFO: Vivado Utilization/Power Report Generation Complete..."
	$(ECHO) "####################################"
	$(ECHO) ""
endif

.PHONY: clean-report-metrics
clean-report-metrics: session-info
	$(RMDIR) $(APP_DIR_ACTIVE)/$(REPORTS_DIR_ACTIVE)

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