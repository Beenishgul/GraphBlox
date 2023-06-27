.PHONY: config-env
config-env: 
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


# =========================================================
#                GENERAL DIRECTOIRES HOST               
# =========================================================
ROOT_DIR                = $(shell cd .. ; pwd)
APP_DIR                 = $(shell basename "$(PWD)")
HOST_DIR                = 01_host
DEVICE_DIR              = 02_device
BENCH_DIR               = 03_data
GIT_VER = $(shell cd . ; git log -1 --pretty=format:"%h" 2>/dev/null)
HOST_NAME  = $(shell /usr/bin/hostnamectl --transient 2>/dev/null)
APP  = glay
APP_TEST = test_glayGraph_$(XILINX_CTRL_MODE)
APP_LANG = cpp
INTEGRATION         = openmp
MAKE_NUM_THREADS = $(shell grep -c ^processor /proc/cpuinfo)
MAKE_HOST               = --no-print-directory -C $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR) -j$(MAKE_NUM_THREADS)
MAKE_DEVICE             = --no-print-directory -C $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)
GRAPH_DIR = $(ROOT_DIR)/$(APP_DIR)/$(BENCH_DIR)
GRAPH_SUIT = TEST
GRAPH_NAME = v51_e1021
FILE_BIN_TYPE = graph.bin
FILE_BIN = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_BIN_TYPE)
FILE_LABEL = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_LABEL_TYPE)
PULL_PUSH        = 0
ALGORITHMS       = 0
SORT_TYPE        = 1
DATA_STRUCTURES  = 0
REORDER_LAYER1   = 0
REORDER_LAYER2   = 0
REORDER_LAYER3   = 0
CACHE_SIZE       = 5068672 #(22MB)
ROOT             = 0
TOLERANCE        = 1e-8
DELTA            = 800
NUM_ITERATIONS   = 1
NUM_THREADS_PRE  = 1
NUM_THREADS_ALGO = 1
NUM_THREADS_KER  = 1
NUM_TRIALS       = 1
FILE_FORMAT      = 1
CONVERT_FORMAT   = 1
BIN_SIZE         = 1000
INOUT_STATS      = 0
MASK_MODE        = 0
VIVADO_GUI_FLAG   = NO
XILINX_DIR       = xilinx_project
UTILS_DIR        = utils
UTILS_PERL       = utils.pl
UTILS_TCL        = utils.tcl
UTILS_SHELL      = utils.sh
UTILS_XDC        = utils.xdc
IP_DIR_RTL       = rtl
IP_DIR_HLS       = hls
REPORTS_DIR      = rpt
VIVADO_PACKAGE_DIR  = vivado_$(KERNEL_NAME).pkg
VIVADO_SIMULATE_DIR = vivado_$(KERNEL_NAME).sim
VIVADO_RUN_DIR      = $(KERNEL_NAME).run
VIVADO_BUILD_DIR    = vivado_$(KERNEL_NAME).$(TARGET)
VIVADO_VMA_DIR      = vivado_$(KERNEL_NAME).vma
VIVADO_EXPORT_DIR   = $(KERNEL_NAME).export
VIVADO_IMPORT_DIR   = $(KERNEL_NAME).import
VIVADO_VIP_DIR      = vivado_$(KERNEL_NAME).vip
VITIS_BUILD_DIR     = vitis_$(KERNEL_NAME).pkg
XILINX_DIR_ACTIVE  = $(XILINX_DIR)_$(KERNEL_NAME)_$(GIT_VER)
UTILS_DIR_ACTIVE   = vivado_$(KERNEL_NAME).$(UTILS_DIR)
IP_DIR_RTL_ACTIVE  = vivado_$(KERNEL_NAME).$(IP_DIR_RTL)
IP_DIR_HLS_ACTIVE  = vivado_$(KERNEL_NAME).$(IP_DIR_HLS)
REPORTS_DIR_ACTIVE = vivado_$(KERNEL_NAME).$(REPORTS_DIR)
KERNEL_NAME        = glay_kernel
DEVICE_INDEX       = 0
XCLBIN_PATH        = $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)/vivado_$(KERNEL_NAME).$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin
ALVEO =  U250
PART  =  xcu250-figd2104-2L-e
PLATFORM = xilinx_u250_gen3x16_xdma_4_1_202210_1
VIVADO_VER     = 2023
DESIGN_FREQ_HZ = 300000000  
XILINX_JOBS_STRATEGY = 4
XILINX_MAX_THREADS   = 8
TARGET = hw_emu
XILINX_IMPL_STRATEGY = 1
XILINX_NUM_KERNELS = 1
XILINX_CTRL_MODE     = USER_MANAGED
TESTBENCH_MODULE     = integration
# =========================================================


