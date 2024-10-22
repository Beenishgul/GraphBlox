# =========================================================
#                GENERAL DIRECTOIRES HOST               
# =========================================================
APP                 ?= GraphBlox
# APP_TEST            ?= test_match
# APP_TEST            ?= test_graphblox
# APP_TEST            ?= test_StalaGraph
APP_TEST            ?= test_$(APP)_$(XILINX_CTRL_MODE)
APP_LANG            ?= cpp
# APP_LANG            ?= c
INTEGRATION         ?= openmp
# INTEGRATION         ?= ggdl

# Directories for host app
ROOT_DIR            ?= $(shell cd ../../ ; pwd)
HOST_NAME           ?= $(shell /usr/bin/hostnamectl --transient 2>/dev/null)
GIT_VER             ?= $(shell cd .. ; git log -1 --pretty=format:"%h")
APP_DIR             ?= $(shell cd .. && pwd | xargs basename )
HOST_DIR            ?= 01_host
DEVICE_DIR          ?= 02_device
ACTIVE_APP_DIR      := $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)
BENCH_DIR           ?= 03_data
#dir root/managed_folders

SRC_DIR             ?= src
OBJ_DIR             ?= obj
INC_DIR             ?= include
BIN_DIR             ?= bin
RES_DIR             ?= results

# relative directories used for managing src/obj files
STRUCT_DIR          ?= structures
PREPRO_DIR          ?= preprocess
ALGO_DIR            ?= algorithms
ALGO_DIR_GRAPHBLOX  ?= $(APP)
ALGO_DIR_OPENMP     ?= openmp
UTIL_DIR            ?= utils_graph
UTIL_DIR_FPGA_C     ?= utils_fpga_c
UTIL_DIR_FPGA_CPP   ?= utils_fpga_cpp
CONFIG_DIR          ?= config

#contains the tests use make run-test to compile what in this directory
TEST_DIR_C          ?= tests_c
TEST_DIR_CPP        ?= tests_cpp

#contains the main for the graph processing framework
MAIN_DIR            ?= main

FULL_SRC_FPGA_UTILS_CPP ?= $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR)/$(SRC_DIR)/$(UTIL_DIR_FPGA_CPP)
# =========================================================
#     CLI COMMANDS                           
# =========================================================

COMPILED_FILE = $(@F)
SUCCESS       = [${GREEN}success!${NC}]
FAIL          = [${RED}failure!${NC}]
SUCCESS_MSG   = echo  "$(SUCCESS) $(COMPILED_FILE)"
FAIL_MSG      = echo  "$(FAIL) $(COMPILED_FILE)"
EXIT_STATUS   = &&  $(SUCCESS_MSG) || { $(FAIL_MSG) ; exit 1; }

# =========================================================
# COMPILERS                         
# =========================================================

CXX     ?= g++
VPP     ?= v++
GCC     ?= gcc
CC      ?= gcc

# =========================================================
# COMPILER GRAPH FLAGS                         
# =========================================================

# flags
CXXFLAGS       = -Wall -m64 -fopenmp -g -O3
LDFLAGS        = -lm -lJudy

# =========================================================
# COMPILER XRT FLAGS                         
# =========================================================

HOST_CXXFLAGS += -std=c++17 -I./ -I$(XILINX_XRT)/include -I$(XILINX_VIVADO)/include
# The below are linking flags for C++ Compiler
XRT_LDFLAGS   += -L$(XILINX_XRT)/lib -lxrt_coreutil -pthread -luuid
CXXFLAGS      += $(HOST_CXXFLAGS)

# Host compiler global settings
CXXFLAGS      += -fmessage-length=0
LDFLAGS       += -lrt -lstdc++ $(XRT_LDFLAGS) 

# =========================================================
# GRAPHBLOX COMPILATION FOLDERS/FILES     
# =========================================================

#each implementation is contained in a separate folder. when you compile for openmp for example the files in openmp folder gets included
SRC_FILES_ALGO      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/*.c)
SRC_FILES_UTIL      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/*.c)
SRC_FILES_PREPRO    =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/*.c)
SRC_FILES_STRUCT    =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/*.c)
SRC_FILES_MAIN      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/*.c)
SRC_FILES_TEST      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR_C)/*.c)
SRC_FILES_CONFIG    =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(CONFIG_DIR)/*.c)

INC_FILES_ALGO      =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/*.h)
INC_FILES_UTIL      =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR)/*.h)
INC_FILES_PREPRO    =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(PREPRO_DIR)/*.h)
INC_FILES_STRUCT    =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(STRUCT_DIR)/*.h)
INC_FILES_CONFIG    =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(CONFIG_DIR)/*.h)

#create object file rules for the final binary target
OBJ_FILES_ALGO      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(ALGO_DIR)/$(INTEGRATION)/%.o,$(SRC_FILES_ALGO))
OBJ_FILES_UTIL      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR)/%.o,$(SRC_FILES_UTIL))
OBJ_FILES_PREPRO    = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(PREPRO_DIR)/%.o,$(SRC_FILES_PREPRO))
OBJ_FILES_STRUCT    = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(STRUCT_DIR)/%.o,$(SRC_FILES_STRUCT))
OBJ_FILES_MAIN      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)/%.o,$(SRC_FILES_MAIN))
OBJ_FILES_TEST      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR_C)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_C)/%.o,$(SRC_FILES_TEST))
OBJ_FILES_CONFIG    = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(CONFIG_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(CONFIG_DIR)/%.o,$(SRC_FILES_CONFIG))

SRC_FILES_TEST_CPP      = $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR_CPP)/*.cpp)
OBJ_FILES_TEST_CPP      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR_CPP)/%.cpp,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_CPP)/%.o,$(SRC_FILES_TEST_CPP))
SRC_FILES_UTIL_FPGA_CPP = $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR_FPGA_CPP)/*.cpp)
INC_FILES_UTIL_FPGA_HPP = $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR_FPGA_CPP)/*.hpp)
OBJ_FILES_UTIL_FPGA_CPP = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR_FPGA_CPP)/%.cpp,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR_FPGA_CPP)/%.o,$(SRC_FILES_UTIL_FPGA_CPP))

ALL_HEADER_FILES    =   $(INC_FILES_ALGO) \
						$(INC_FILES_UTIL) \
						$(INC_FILES_UTIL_FPGA) \
						$(INC_FILES_PREPRO) \
						$(INC_FILES_STRUCT) \
						$(INC_FILES_CONFIG) \
						$(INC_FILES_UTIL_FPGA_HPP)

OPENMP_INC =    -I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(STRUCT_DIR)               \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(ALGO_DIR)/$(INTEGRATION)  \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(PREPRO_DIR)               \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR)                 \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR_FPGA_CPP)        \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(CONFIG_DIR)

# =========================================================
# Starting point of GraphBlox generate IPs and compile Host
# =========================================================
.PHONY: start
start: $(APP)-$(INTEGRATION)
	
# =========================================================
# =========================================================
# GRAPHBLOX GENERATION                        
# =========================================================

.PHONY: help
help: $(APP)-$(INTEGRATION)
	$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION) --help

.PHONY: all
all: $(APP)-$(INTEGRATION)

.PHONY: $(APP)-$(INTEGRATION)
$(APP)-$(INTEGRATION) : $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION)
	$(ECHO) "\n========================================================="
	$(ECHO) "${GREEN}DONE!! NOTHING ELSE TO COMPILE${NC}"
	$(ECHO) "${BLUE}$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$@${NC}"
	$(ECHO) "=========================================================\n"

.PHONY: $(APP_TEST)-$(INTEGRATION)-$(APP_LANG)
$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) : $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) 
	$(ECHO) "\n========================================================="
	$(ECHO) "${GREEN}DONE!! NOTHING ELSE TO COMPILE${NC}"
	$(ECHO) "${BLUE}$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$@${NC}"
	$(ECHO) "=========================================================\n"
.PHONY: directories-obj
directories-obj :
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR_FPGA_CPP)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(PREPRO_DIR)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(STRUCT_DIR)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_C)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_CPP)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(CONFIG_DIR)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(ALGO_DIR)/$(INTEGRATION)
	$(MKDIR_P) $(ACTIVE_APP_DIR)/$(RES_DIR)/$(INTEGRATION)/$(INTEGRATION)

.PHONY: clean-all
clean-all:
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(BIN_DIR)
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(RES_DIR)
	-$(RMDIR) $(ROOT_DIR)/$(APP_DIR)/alg_*

.PHONY: clean
clean:
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(BIN_DIR)
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)

.PHONY: clean-results
clean-results:
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(RES_DIR)

# =========================================================
# GRAPHBLOX COMPILATION                       
# =========================================================

$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION) : $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)/$(APP).o $(OBJ_FILES_UTIL) $(OBJ_FILES_ALGO) $(OBJ_FILES_PREPRO) $(OBJ_FILES_STRUCT) $(OBJ_FILES_CONFIG)
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-c : $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_C)/$(APP_TEST).o $(OBJ_FILES_UTIL) $(OBJ_FILES_ALGO) $(OBJ_FILES_PREPRO) $(OBJ_FILES_STRUCT) $(OBJ_FILES_CONFIG)
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-cpp : $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_CPP)/$(APP_TEST).o $(OBJ_FILES_UTIL) $(OBJ_FILES_UTIL_FPGA_CPP) $(OBJ_FILES_ALGO) $(OBJ_FILES_PREPRO) $(OBJ_FILES_STRUCT) $(OBJ_FILES_CONFIG)
	@$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS) $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)/$(APP).o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/$(APP).c $(ALL_HEADER_FILES) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_C)/$(APP_TEST).o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR_C)/$(APP_TEST).c $(ALL_HEADER_FILES) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR_CPP)/$(APP_TEST).o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR_CPP)/$(APP_TEST).cpp $(ALL_HEADER_FILES) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/%.c $(INC_FILES_UTIL) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR_FPGA_CPP)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR_FPGA_CPP)/%.cpp $(INC_FILES_UTIL) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(ALGO_DIR)/$(INTEGRATION)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/%.c $(ALL_HEADER_FILES) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(PREPRO_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/%.c $(INC_FILES_PREPRO) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(STRUCT_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/%.c $(INC_FILES_STRUCT) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(CONFIG_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(CONFIG_DIR)/%.c $(INC_FILES_CONFIG) | directories-obj
	@$(CXX) $(CXXFLAGS) $(OPENMP_INC) -c -o $@ $< $(EXIT_STATUS)

# =========================================================
# RUN GraphBlox
# =========================================================

.PHONY: run
run: $(APP)
	$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION) -f $(FILE_BIN) $(ARGS) 

.PHONY: $(APP)
$(APP): $(APP)-$(INTEGRATION)
	
.PHONY: debug-memory
debug-memory: $(APP)
	valgrind --leak-check=full --show-leak-kinds=all -v $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION) -f $(FILE_BIN) $(ARGS)

.PHONY: debug
debug: $(APP)
	gdb -ex=r --args $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION) -f $(FILE_BIN) $(ARGS)

# =========================================================
# RUN Tests
# =========================================================

.PHONY: run-test
run-test: $(APP_TEST)
	$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS)

.PHONY: $(APP_TEST)
$(APP_TEST): $(APP_TEST)-$(INTEGRATION)-$(APP_LANG)

.PHONY: debug-test
debug-test: $(APP_TEST)
	gdb -ex=r --args $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS)

.PHONY: debug-test-memory
debug-test-memory: $(APP_TEST)
	valgrind --leak-check=full --show-leak-kinds=all -v $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)-$(APP_LANG) -f $(FILE_BIN) $(ARGS)

# test files
.PHONY: test
test:
	@if $(MAKE) run-test -C $(ACTIVE_APP_DIR) | grep FAIL > /dev/null; \
		then exit 1; \
	fi
	
# =========================================================
# GRAPH ARGUMENTS                     
# =========================================================

GRAPH_DIR ?= $(ROOT_DIR)/$(APP_DIR)/$(BENCH_DIR)

# TEST # small test graphs
# GRAPH_SUIT ?= TEST
# GRAPH_NAME ?= test
# GRAPH_NAME ?= v51_e1021
# GRAPH_NAME ?= v300_e2730
# GRAPH_NAME ?= graphbrew

GRAPH_SUIT ?= LAW
GRAPH_NAME ?= LAW-amazon-2008
# GRAPH_NAME ?= LAW-cnr-2000
# GRAPH_NAME ?= LAW-dblp-2010
# GRAPH_NAME ?= LAW-enron

# GRAPH_SUIT ?= KRON
# GRAPH_NAME ?= RMAT

# FILE_BIN_TYPE ?= g.20.16.text
# FILE_LABEL_TYPE ?= a.20.16.1000000.text

# FILE_BIN_TYPE   ?= g.20.16.text.dbin
# FILE_LABEL_TYPE ?= a.20.16.1000000.text.dbin

# FILE_BIN_TYPE   ?=  g.5.16.text.dbin
# FILE_LABEL_TYPE ?= a.5.16.100.text.dbin

# FILE_BIN_TYPE ?= g.24.16.text.dbin
# FILE_LABEL_TYPE ?= a.24.16.10000000.text.dbin

# FILE_BIN_TYPE ?= g.24.16.text
# FILE_LABEL_TYPE ?= a.24.16.10000000.text

# FILE_BIN_TYPE ?= graph.txt
FILE_BIN_TYPE ?= graph.bin
# FILE_BIN_TYPE ?= graph.wbin

# FILE_LABEL_TYPE ?= graph_Gorder.labels
# FILE_LABEL_TYPE ?= graph_Rabbit.labels

#GRAPH file
FILE_BIN ?= $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_BIN_TYPE)
FILE_LABEL ?= $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_LABEL_TYPE)

#ALGORITHM
PULL_PUSH       ?= 0
ALGORITHMS      ?= 1

#GRAPH DATA_STRUCTURES
SORT_TYPE        ?= 2
DATA_STRUCTURES  ?= 1
REORDER_LAYER1   ?= 0
REORDER_LAYER2   ?= 0
REORDER_LAYER3   ?= 0
# CACHE_SIZE       ?= 32768 #(32KB)
# CACHE_SIZE       ?= 262144 #(256KB)
CACHE_SIZE       ?= 5068672 #(22MB)

#ALGORITHM SPECIFIC ARGS
ROOT            ?= 0
TOLERANCE       ?= 1e-8
DELTA           ?= 800
NUM_ITERATIONS  ?= 1

#PERFORMANCE
NUM_THREADS_PRE  ?= 1
NUM_THREADS_ALGO ?= 1
NUM_THREADS_KER  ?= 1

#EXPERIMENTS
NUM_TRIALS      ?= 1

#GRAPH FROMAT EDGELIST
FILE_FORMAT     ?= 1
CONVERT_FORMAT  ?= 1

#STATS COLLECTION VARIABLES
BIN_SIZE        ?= 1000
INOUT_STATS     ?= 0
MASK_MODE       ?= 0

# =========================================================
# GENERAL XILINX ARGS                    
# =========================================================

KERNEL_NAME ?= $(APP)_kernel
XILINX_DIR  ?= xilinx_project
XILINX_DIR_ACTIVE  	?= $(XILINX_DIR)_$(KERNEL_NAME)_$(GIT_VER)

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

# 	ALVEO?=  U200
# 	PART ?=  xcu200-fsgd2104-2-e
# 	PLATFORM ?=  xilinx_u200_gen3x16_xdma_2_202110_1

# 	ALVEO?=  U50
# 	PART ?=  xcu50-fsvh2104-2-e
# 	PLATFORM ?=  xilinx_u50_gen3x16_xdma_5_202210_1

# 	ALVEO?=  U55
# 	PART ?=  xcu55c-fsvh2892-2L-e
# 	PLATFORM ?=  xilinx_u55c_gen3x16_xdma_3_202210_1

# 	ALVEO?=  U280
# 	PART ?=  xcu280-fsvh2892-2L-e
# 	PLATFORM ?=  xilinx_u280_gen3x16_xdma_1_202211_1
endif

# TARGET: set the build target, can be hw or hw_emu
TARGET ?= hw_emu
# TARGET ?= hw

XILINX_CTRL_MODE     ?= USER_MANAGED
# XILINX_CTRL_MODE     ?= AP_CTRL_HS
# XILINX_CTRL_MODE     ?= AP_CTRL_CHAIN
# XILINX_CTRL_MODE     ?= ap_ctrl_none

DEVICE_INDEX        ?= 0
XCLBIN_PATH         ?= $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)/vivado_build_$(TARGET)/$(KERNEL_NAME)_$(TARGET).xclbin
GRAPHBLOX_FPGA_ARGS      ?= -m $(DEVICE_INDEX) -q $(XCLBIN_PATH) -Q $(KERNEL_NAME)

# =========================================================
# GraphBlox HOST Argument list               
# =========================================================

ARGS ?= $(GRAPHBLOX_FPGA_ARGS) -k -M $(MASK_MODE) -j $(INOUT_STATS) -g $(BIN_SIZE) -z $(FILE_FORMAT) -d $(DATA_STRUCTURES) -a $(ALGORITHMS) -r $(ROOT) -n $(NUM_THREADS_PRE) -N $(NUM_THREADS_ALGO) -K $(NUM_THREADS_KER) -i $(NUM_ITERATIONS) -o $(SORT_TYPE) -p $(PULL_PUSH) -t $(NUM_TRIALS) -e $(TOLERANCE) -F $(FILE_LABEL) -l $(REORDER_LAYER1) -L $(REORDER_LAYER2) -O $(REORDER_LAYER3) -b $(DELTA) -C $(CACHE_SIZE)
# =========================================================
