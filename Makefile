# =========================================================
#                GENERAL DIRECTOIRES HOST               
# =========================================================
export ROOT_DIR                = $(shell cd .. ; pwd)
export HOST_NAME               = $(shell /usr/bin/hostnamectl --transient 2>/dev/null)
export GIT_VER                 = $(shell cd . ; git log -1 --pretty=format:"%h")
export APP_DIR                 = $(shell basename "$(PWD)")
export HOST_DIR                = 00_host
export DEVICE_DIR              = 01_device
export BENCH_DIR               = 02_test_graphs
# =========================================================


# =========================================================
# CLI Commands                           
# =========================================================
ECHO    := @echo
# =========================================================
# Color coded messages                      
# =========================================================
export YELLOW  =\033[0;33m
export GREEN   =\033[0;32m
export BLUE    =\033[0;34m
export RED     =\033[0;31m
export NC      =\033[0m
# =========================================================

# =========================================================
#                APP HOST PROPERTIES    
# =========================================================

# =========================================================
# Application name 00_GLay/src/main folder (glay.c) 
# =========================================================
export APP  = glay
# =========================================================

# =========================================================
# Application name 00_GLay/src/test folder (test.c/cpp) 
# =========================================================
# export APP_TEST  = test_match
# export APP_TEST = test_glay
# export APP_TEST = test_StalaGraph
export APP_TEST = test_glayGraph_$(XILINX_CTRL_MODE)
# export APP_TEST = test_glayGraph_emu

# =========================================================
# Application extention ./src/test folder (test.c/cpp) 
# =========================================================
export APP_LANG = cpp
# export APP_LANG = c
# =========================================================

# =========================================================
# Application name src/algorithms folder openmp/cuda/fpga
# =========================================================
export INTEGRATION         = openmp
# export INTEGRATION         = ggdl
# =========================================================

# =========================================================
# Nested make calls args for host/device makefiles
# =========================================================
export MAKE_NUM_THREADS        = $(shell grep -c ^processor /proc/cpuinfo)
export MAKE_HOST               = --no-print-directory -C $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR) -j$(MAKE_NUM_THREADS)
export MAKE_DEVICE             = --no-print-directory -C $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)
# =========================================================

# =========================================================
# Starting point of GLay generate IPs and compile Host
# =========================================================
.PHONY: start
start:
	$(ECHO) "========================================================="
	$(ECHO) "${RED}Initial compile will only take a minute!${NC}"
	$(ECHO) "========================================================="
	-@$(MAKE) start $(MAKE_DEVICE)
	-@$(MAKE) start $(MAKE_HOST)
	$(ECHO) "========================================================="
	$(ECHO) "${YELLOW}Usage : make help -- to view options!${NC}"
	$(ECHO) "========================================================="
# =========================================================

.PHONY: host
host:
	$(ECHO) "========================================================="
	$(ECHO) "${RED}[HOST] Initial compile will only take a minute!${NC}"
	$(ECHO) "========================================================="
	-@$(MAKE) start $(MAKE_HOST)
	$(ECHO) "========================================================="
	$(ECHO) "${YELLOW}Usage : make help -- to view options!${NC}"
	$(ECHO) "========================================================="
# =========================================================

# =========================================================
# Compile all steps
# =========================================================
.PHONY: all
all:
	-@$(MAKE) all $(MAKE_DEVICE)
	-@$(MAKE) all $(MAKE_HOST)
	
.PHONY: clean-all
clean-all:
	-@$(MAKE) clean-all $(MAKE_DEVICE)
	-@$(MAKE) clean-all $(MAKE_HOST)
	
.PHONY: clean
clean:
	-@$(MAKE) clean $(MAKE_DEVICE)
	-@$(MAKE) clean $(MAKE_HOST)
	
.PHONY: clean-results
clean-results:
	-@$(MAKE) clean-results $(MAKE_HOST)

.PHONY: help
help:
	-@$(MAKE) help $(MAKE_DEVICE)
	-@$(MAKE) help $(MAKE_HOST)
# =========================================================

# =========================================================
# Run GLay HOST
# =========================================================
.PHONY: run
run:
	-@$(MAKE) run $(MAKE_HOST) 
	
.PHONY: debug-memory
debug-memory:
	-@$(MAKE) debug-memory $(MAKE_HOST) 

.PHONY: debug
debug:
	-@$(MAKE) debug $(MAKE_HOST) 
# =========================================================

# =========================================================
# Run Tests HOST
# =========================================================
.PHONY: run-test
run-test:
	-@$(MAKE) run-test $(MAKE_HOST) 

.PHONY: debug-test
debug-test:
	-@$(MAKE) debug-test $(MAKE_HOST) 

.PHONY: debug-test-memory
debug-test-memory:
	-@$(MAKE) debug-test-memory $(MAKE_HOST)

.PHONY: test
test:
	-@$(MAKE) test $(MAKE_HOST)
# =========================================================

# =========================================================
#                   GRAPH ARGUMENTS HOST                
# =========================================================

# =========================================================
# TEST # all test graphs directory location
# =========================================================
export GRAPH_DIR = $(ROOT_DIR)/$(APP_DIR)/$(BENCH_DIR)
# =========================================================

# =========================================================
# TEST # small test graphs
# =========================================================
export GRAPH_SUIT = TEST
# export GRAPH_NAME = test
export GRAPH_NAME = v51_e1021
# export GRAPH_NAME = v300_e2730
# export GRAPH_NAME = graphbrew

# export GRAPH_SUIT = LAW
# export GRAPH_NAME = LAW-amazon-2008
# export GRAPH_NAME = LAW-cnr-2000
# export GRAPH_NAME = LAW-dblp-2010
# export GRAPH_NAME = LAW-enron

# export GRAPH_SUIT = KRON
# export GRAPH_NAME = RMAT

# export FILE_BIN_TYPE = g.20.16.text
# export FILE_LABEL_TYPE = a.20.16.1000000.text

# export FILE_BIN_TYPE   = g.20.16.text.dbin
# export FILE_LABEL_TYPE = a.20.16.1000000.text.dbin

# export FILE_BIN_TYPE   =  g.5.16.text.dbin
# export FILE_LABEL_TYPE = a.5.16.100.text.dbin

# export FILE_BIN_TYPE = g.24.16.text.dbin
# export FILE_LABEL_TYPE = a.24.16.10000000.text.dbin

# export FILE_BIN_TYPE = g.24.16.text
# export FILE_LABEL_TYPE = a.24.16.10000000.text

# export FILE_BIN_TYPE = graph.txt.bin
export FILE_BIN_TYPE = graph.bin
# export FILE_BIN_TYPE = graph.wbin

# export FILE_LABEL_TYPE = graph_Gorder.labels
# export FILE_LABEL_TYPE = graph_Rabbit.labels
# =========================================================

# =========================================================
# GRAPH file location with and if any relabel files exist
# =========================================================
export FILE_BIN = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_BIN_TYPE)
export FILE_LABEL = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_LABEL_TYPE)
# =========================================================

# =========================================================
# ALGORITHM Flow
# =========================================================
export PULL_PUSH        = 0
export ALGORITHMS       = 0
# =========================================================

# =========================================================
# GRAPH DATA_STRUCTURES Pre-Processing
# =========================================================
export SORT_TYPE        = 1
export DATA_STRUCTURES  = 0
export REORDER_LAYER1   = 0
export REORDER_LAYER2   = 0
export REORDER_LAYER3   = 0
# export CACHE_SIZE       = 32768 #(32KB)
# export CACHE_SIZE       = 262144 #(256KB)
export CACHE_SIZE       = 5068672 #(22MB)
# =========================================================

# =========================================================
# ALGORITHM SPECIFIC ARGS
# =========================================================
export ROOT             = 0
export TOLERANCE        = 1e-8
export DELTA            = 800
export NUM_ITERATIONS   = 1
# =========================================================

# =========================================================
# Parallel Pre-Processing/Algorithm/Kernel (dominant loop)
# =========================================================
export NUM_THREADS_PRE  = 1
export NUM_THREADS_ALGO = 1
export NUM_THREADS_KER  = 1
# =========================================================

# =========================================================
# Number of runs for each algorithm
# =========================================================
export NUM_TRIALS       = 1
# =========================================================

# =========================================================
# GRAPH FROMAT EDGELIST
# =========================================================
export FILE_FORMAT      = 1
export CONVERT_FORMAT   = 1
# =========================================================

# =========================================================
# STATS COLLECTION VARIABLES
# =========================================================
export BIN_SIZE         = 1000
export INOUT_STATS      = 0
export MASK_MODE        = 0
# =========================================================

# =========================================================
#                        XILINX ARGS                    
# =========================================================
export XILINX_DIR         = xilinx_project
export SCRIPTS_DIR        = ip_scripts
export SCRIPTS_PERL       = scripts_pl
export SCRIPTS_TCL        = scripts_tcl
export SCRIPTS_SHELL      = scripts_sh
export SCRIPTS_XDC        = scripts_xdc
export IP_DIR_RTL         = ip_rtl
export IP_DIR_HLS         = ip_hls
export REPORTS_DIR        = reports
export VIVADO_GUI_FLAG    = NO

export XILINX_DIR_ACTIVE  = $(XILINX_DIR)_$(KERNEL_NAME)_$(GIT_VER)
export SCRIPTS_DIR_ACTIVE = vivado_$(SCRIPTS_DIR)
export IP_DIR_RTL_ACTIVE  = vivado_$(IP_DIR_RTL)
export IP_DIR_HLS_ACTIVE  = vivado_$(IP_DIR_HLS)
export REPORTS_DIR_ACTIVE = vivado_$(REPORTS_DIR)
# =========================================================

# =========================================================
# APP Device properties    
# =========================================================
export KERNEL_NAME        = glay_kernel
export DEVICE_INDEX       = 0
export XCLBIN_PATH        = $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin
# =========================================================

# =========================================================
# PART and PLATFORM settings
# =========================================================
# PART: remove comment the line matching Alveo card
# PLATFORM: remove comment the line matching  Alveo card
# =========================================================
# How many parallel jobs works for [0-7] 
# For number of jobs is XILINX_JOBS_STRATEGY=2
# Synth -> 2 parallel synths 
# Impl  -> 2 parallel implementations  
# =========================================================
ifeq ($(HOST_NAME), panther)
	export ALVEO =  U280
	export PART  =  xcu280-fsvh2892-2L-e
	export PLATFORM   = xilinx_u280_gen3x16_xdma_1_202211_1
	export VIVADO_VER = 2022

# 	export ALVEO =  U55
# 	export PART  = xcu55c-fsvh2892-2L-e
# 	export PLATFORM = xilinx_u55c_gen3x16_xdma_3_202210_1
	
	export XILINX_JOBS_STRATEGY = 4
	export XILINX_MAX_THREADS   = 8
else ifeq ($(HOST_NAME), jaguar)
	export ALVEO =  U250
	export PART  =  xcu250-figd2104-2L-e
	export PLATFORM = xilinx_u250_gen3x16_xdma_4_1_202210_1
	export VIVADO_VER = 2023

# 	export ALVEO =  U55
# 	export PART  = xcu55c-fsvh2892-2L-e
# 	export PLATFORM = xilinx_u55c_gen3x16_xdma_3_202210_1

	export XILINX_JOBS_STRATEGY = 8
	export XILINX_MAX_THREADS   = 32
else
	export ALVEO =  U250
	export PART  =  xcu250-figd2104-2L-e
	export PLATFORM   = xilinx_u250_gen3x16_xdma_4_1_202210_1
	export VIVADO_VER = 2023

# 	export ALVEO =  U200
# 	export PART  =  xcu200-fsgd2104-2-e
# 	export PLATFORM =  xilinx_u200_gen3x16_xdma_2_202110_1

# 	export ALVEO =  U50
# 	export PART  =  xcu50-fsvh2104-2-e
# 	export PLATFORM =  xilinx_u50_gen3x16_xdma_5_202210_1

# 	export ALVEO =  U55
# 	export PART  =  xcu55c-fsvh2892-2L-e
# 	export PLATFORM =  xilinx_u55c_gen3x16_xdma_3_202210_1

# 	export ALVEO =  U280
# 	export PART  =  xcu280-fsvh2892-2L-e
# 	export PLATFORM =  xilinx_u280_gen3x16_xdma_1_202211_1

	export XILINX_JOBS_STRATEGY = 4
	export XILINX_MAX_THREADS   = 8
endif
# =========================================================

# =========================================================
# TARGET: set the build target, can be hw or hw_emu
# =========================================================
export TARGET = hw_emu
# export TARGET = hw
# =========================================================

# =========================================================
# Enabling Multiple Strategies For Closing Timing TARGET=hw
# =========================================================
# [0-7]-strategies
# Example: 
# XILINX_IMPL_STRATEGY =0 #(fast ~2hrs) 
# XILINX_IMPL_STRATEGY =2 #(slow upto 33 strategies ~13hrs)
# Check 01_device/scripts/generate_build_cfg
# pick a suitable strategy or add yours
# =========================================================
export XILINX_IMPL_STRATEGY = 1
# =========================================================

# =========================================================
# Control mode options
# =========================================================
# Control mode XRT/OCL/HLS (AP_CTRL_HS, AP_CTRL_CHAIN) 
# Control mode USER (USER_MANAGED)
# =========================================================
export XILINX_CTRL_MODE     = USER_MANAGED
# export XILINX_CTRL_MODE     = AP_CTRL_HS
# export XILINX_CTRL_MODE     = AP_CTRL_CHAIN
# export XILINX_CTRL_MODE     = ap_ctrl_none
# =========================================================



# =========================================================
# Select Testbench for simulation testbench_glay/arbiter
# =========================================================
export TESTBENCH_MODULE     = glay
# export TESTBENCH_MODULE     = arbiter
# export TESTBENCH_MODULE     = kernel_setup
# export TESTBENCH_MODULE     = alu_operations
# export TESTBENCH_MODULE     = conditional_break
# export TESTBENCH_MODULE     = conditional_continue
# export TESTBENCH_MODULE     = conditional_filter
# export TESTBENCH_MODULE     = random_read_engine
# export TESTBENCH_MODULE     = random_write_engine
# export TESTBENCH_MODULE     = serial_read_engine
# export TESTBENCH_MODULE     = serial_write_engine
# export TESTBENCH_MODULE     = stride_index_generator
# =========================================================

# =========================================================
# Each project is tagged with a GIT commit id
# If you want to commit code and reuse same project metadata
# remove comment for this variable and choose any number
# =========================================================
#if you make a push and use a previous compile 
# export GIT_VER              = 03c8d73
# =========================================================

# =========================================================
# STEP 1. Scripts/VIPs/Directories generation 
# =========================================================
.PHONY: gen-vip
gen-vip:
	-@$(MAKE) gen-vip $(MAKE_DEVICE)

.PHONY: gen-scripts-dir
gen-scripts-dir: 
	-@$(MAKE) gen-scripts-dir $(MAKE_DEVICE)

.PHONY: gen-ip-dir
gen-ip-dir: 
	-@$(MAKE) gen-ip-dir $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 2.a Run Hardware Simulation  
# =========================================================
.PHONY: run-sim
run-sim:
	-@$(MAKE) run-sim $(MAKE_DEVICE)

.PHONY: run-sim-gui
run-sim-gui:
	-@$(MAKE) run-sim-gui $(MAKE_DEVICE)

.PHONY: run-sim-noclean
run-sim-noclean:
	-@$(MAKE) run-sim-noclean $(MAKE_DEVICE)

.PHONY: run-sim-reset
run-sim-reset:
	-@$(MAKE) run-sim-reset $(MAKE_DEVICE)

.PHONY: run-sim-wave
run-sim-wave:
	-@$(MAKE) run-sim-wave $(MAKE_DEVICE)

.PHONY: run-sim-help
run-sim-help:
	-@$(MAKE) run-sim-help $(MAKE_DEVICE)

# =========================================================
# VIVADO Project Mode
# =========================================================
.PHONY: run-sim-project
run-sim-project:
	-@$(MAKE) run-sim-project $(MAKE_DEVICE)

.PHONY: run-synth-project
run-synth-project:
	-@$(MAKE) run-synth-project $(MAKE_DEVICE)

.PHONY: run-impl-project
run-impl-project:
	-@$(MAKE) run-impl-project $(MAKE_DEVICE)

.PHONY: run-report-project
run-report-project:
	-@$(MAKE) run-report-project $(MAKE_DEVICE)

.PHONY: open-vivado-project
open-vivado-project:
	-@$(MAKE) open-vivado-project $(MAKE_DEVICE)

# =========================================================

# =========================================================
# STEP 2.b Package Generation  
# =========================================================
.PHONY: package-kernel
package-kernel:
	-@$(MAKE) package-kernel $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 3.a XCLBIN File Generation
# =========================================================
.PHONY: build-hw
build-hw:
	-@$(MAKE) build-hw $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 3.b Application Executable File Generation
# =========================================================
.PHONY: gen-host-bin
gen-host-bin: 
	-@$(MAKE) gen-host-bin $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 3.c Export/Import vitis to vivado flow
# =========================================================
.PHONY: export-hw
export-hw:
	-@$(MAKE) export-hw $(MAKE_DEVICE)

.PHONY: import-hw
import-hw:
	-@$(MAKE) import-hw $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 4.a Run Hardware Emulation  
# =========================================================
.PHONY: run-emu
run-emu:
	-@$(MAKE) run-emu $(MAKE_DEVICE)

.PHONY: run-emu-debug
run-emu-debug:
	-@$(MAKE) run-emu-debug $(MAKE_DEVICE)

.PHONY: run-emu-wave
run-emu-wave:
	-@$(MAKE) run-emu-wave $(MAKE_DEVICE)
# ================================= ========================

# =========================================================
# STEP 4.b Run Hardware FPGA
# =========================================================
.PHONY: run-fpga
run-fpga:
	-@$(MAKE) run-fpga $(MAKE_DEVICE)

.PHONY: run-fpga-debug
run-fpga-debug:
	-@$(MAKE) run-fpga-debug $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 5.a Open Project in Vivado GUI
# =========================================================
.PHONY: run-vpp-sim-project
run-vpp-sim-project:
	@$(MAKE) run-vpp-sim-project $(MAKE_DEVICE)

.PHONY: run-vpp-synth-project
run-vpp-synth-project:
	@$(MAKE) run-vpp-synth-project $(MAKE_DEVICE)

.PHONY: run-vpp-impl-project
run-vpp-impl-project:
	@$(MAKE) run-vpp-impl-project $(MAKE_DEVICE)

.PHONY: run-vpp-report-project
run-vpp-report-project:
	@$(MAKE) run-vpp-report-project $(MAKE_DEVICE)

.PHONY: open-vpp-vivado-project
open-vpp-vivado-project:
	@$(MAKE) open-vpp-vivado-project $(MAKE_DEVICE)

# =========================================================
# STEP 5.b VITIS Flow: Open Project
# =========================================================
.PHONY: open-vitis-project
open-vitis-project:
	@$(MAKE) open-vitis-project $(MAKE_DEVICE)

# =========================================================

# =========================================================
# STEP 5.b Report Utilization Metrics
# =========================================================
# If the target is HW, this generates the power and resource
# utilization metrics.
# =========================================================
.PHONY: report_metrics
report_metrics: 
	-@$(MAKE) report_metrics $(MAKE_DEVICE)
# =========================================================

# =========================================================
# GLay HOST Argument list               
# =========================================================
export GLAY_FPGA_ARGS     = -m $(DEVICE_INDEX) -q $(XCLBIN_PATH) -Q $(KERNEL_NAME)
export ARGS = $(GLAY_FPGA_ARGS) -M $(MASK_MODE) -j $(INOUT_STATS) -g $(BIN_SIZE) -z $(FILE_FORMAT) -c $(CONVERT_FORMAT) -d $(DATA_STRUCTURES) -a $(ALGORITHMS) -r $(ROOT) -n $(NUM_THREADS_PRE) -N $(NUM_THREADS_ALGO) -K $(NUM_THREADS_KER) -i $(NUM_ITERATIONS) -o $(SORT_TYPE) -p $(PULL_PUSH) -t $(NUM_TRIALS) -e $(TOLERANCE) -F $(FILE_LABEL) -l $(REORDER_LAYER1) -L $(REORDER_LAYER2) -O $(REORDER_LAYER3) -b $(DELTA) -C $(CACHE_SIZE)
# =========================================================

