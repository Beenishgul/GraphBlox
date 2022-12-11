#########################################################
#                GENERAL DIRECTOIRES                    #
#########################################################
APP                 ?= glay
# APP_TEST            ?= test_match
# APP_TEST            ?= test_glay
# APP_TEST            ?= test_StalaGraph
APP_TEST            ?= test_glayGraph
INTEGRATION         ?= openmp

# Directories for host app
ROOT_DIR            ?= /home/cmv6ru/Documents/00_github_repos
APP_DIR             ?= 00_GLay
SUB_APP_DIR         := 00_host
ACTIVE_APP_DIR      := $(ROOT_DIR)/$(APP_DIR)/$(SUB_APP_DIR)
BENCH_DIR           ?= 03_test_graphs
#dir root/managed_folders

SRC_DIR             ?= src
OBJ_DIR             ?= obj
INC_DIR             ?= include
BIN_DIR             ?= bin
RES_DIR             ?= results

#if you want to compile from cmake you need this directory
#cd build
#cmake ..
BUILD_DIR           ?= build

# relative directories used for managing src/obj files
STRUCT_DIR          ?= structures
PREPRO_DIR          ?= preprocess
ALGO_DIR            ?= algorithms
ALGO_DIR_GLAY       ?= glay
ALGO_DIR_OPENMP     ?= openmp
UTIL_DIR            ?= utils_graph
UTIL_DIR_FPGA       ?= utils_fpga
CONFIG_DIR			?= config

#contains the tests use make run-test to compile what in this directory
TEST_DIR            ?= tests

#contains the main for the graph processing framework
MAIN_DIR            ?= main

#########################################################
#                GENERAL XILINX VARIABLES               #
#########################################################

PROJECT := glay
TARGET 	:= hw_emu
DEVICE 	:= xilinx_u280_xdma_201920_3 
XCLBIN 	:= ./xclbin
XO 		:= ./xo

EXECUTABLE := run-$(PROJECT)

DSA 		:= $(call device2sandsa, $(DEVICE))
BUILD_DIR 	:= ./_x.$(TARGET).$(DSA)
BUILD_DIR_PROJECT := $(BUILD_DIR)/$(PROJECT)

##############################################
#     CLI COMMANDS                           #
##############################################

RM 		:= @rm -f
RMDIR 	:= @rm -rf
ECHO 	:= @echo
CP 		:= @cp -rf
MKDIR   := @mkdir -p

# TEST PASS OR FAIL
PASS = \033[92mPASS\033[0m
FAIL = \033[91mFAIL\033[0m

##############################################
#     COMPILER FLAGS                         #
##############################################

CXX 	:= g++
VPP 	:= v++
GCC 	:= gcc
CC      := gcc

# flags
CFLAGS   	   = -Wall -m64 -fopenmp -g -Wall -O0 
LFLAGS         = -lm -lJudy
HOST_CXXFLAGS += -std=c++17 -I./ -I$(XILINX_XRT)/include -I$(XILINX_VIVADO)/include
# The below are linking flags for C++ Compiler
XRT_LDFLAGS   += -L$(XILINX_XRT)/lib -lxrt_coreutil -pthread
CXXFLAGS      += $(HOST_CXXFLAGS)
CFLAGS        += $(HOST_CXXFLAGS)

# Host compiler global settings
CXXFLAGS      += -fmessage-length=0
LDFLAGS       += -lrt -lstdc++ $(XRT_LDFLAGS) 

##############################################
#     GLAY COMPILATION FOLDERS/FILES         #
##############################################

#each implementation is contained in a separate folder. when you compile for openmp for example the files in openmp folder gets included
SRC_FILES_ALGO      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/*.c)
SRC_FILES_UTIL      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/*.c)
SRC_FILES_UTIL_FPGA =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR_FPGA)/*.c)
SRC_FILES_PREPRO    =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/*.c)
SRC_FILES_STRUCT    =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/*.c)
SRC_FILES_MAIN      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/*.c)
SRC_FILES_TEST      =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR)/*.c)
SRC_FILES_CONFIG    =   $(wildcard $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(CONFIG_DIR)/*.c)


INC_FILES_ALGO      =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/*.h)
INC_FILES_UTIL      =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR)/*.h)
INC_FILES_UTIL_FPGA =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR_FPGA)/*.h)
INC_FILES_PREPRO    =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(PREPRO_DIR)/*.h)
INC_FILES_STRUCT    =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(STRUCT_DIR)/*.h)
INC_FILES_CONFIG    =   $(wildcard $(ACTIVE_APP_DIR)/$(INC_DIR)/$(CONFIG_DIR)/*.h)


ALL_HEADER_FILES    =   $(INC_FILES_ALGO) $(INC_FILES_UTIL) $(INC_FILES_PREPRO) $(INC_FILES_STRUCT) $(INC_FILES_CONFIG)

#create object file rules for the final binary target
OBJ_FILES_ALGO      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(ALGO_DIR)/$(INTEGRATION)/%.o,$(SRC_FILES_ALGO))

OBJ_FILES_UTIL      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR)/%.o,$(SRC_FILES_UTIL))
OBJ_FILES_UTIL_FPGA = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR_FPGA)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR_FPGA)/%.o,$(SRC_FILES_UTIL_FPGA))
OBJ_FILES_PREPRO    = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(PREPRO_DIR)/%.o,$(SRC_FILES_PREPRO))
OBJ_FILES_STRUCT    = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(STRUCT_DIR)/%.o,$(SRC_FILES_STRUCT))
OBJ_FILES_MAIN      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)/%.o,$(SRC_FILES_MAIN))
OBJ_FILES_TEST      = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR)/%.o,$(SRC_FILES_TEST))
OBJ_FILES_CONFIG    = $(patsubst $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(CONFIG_DIR)/%.c,$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(CONFIG_DIR)/%.o,$(SRC_FILES_CONFIG))

OPENMP_INC =    -I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(STRUCT_DIR)               \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(ALGO_DIR)/$(INTEGRATION)  \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(PREPRO_DIR)               \
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR)   				\
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(UTIL_DIR_FPGA)   			\
				-I$(ACTIVE_APP_DIR)/$(INC_DIR)/$(CONFIG_DIR)              

#########################################################
#                GLAY GENERATION                        #
#########################################################

.PHONY: help
help: $(APP)-$(INTEGRATION)
	./$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION) --help

.PHONY: $(APP)-$(INTEGRATION)
$(APP)-$(INTEGRATION) : $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION)
	-$(ECHO) "\n ******************************************************************************  "
	-$(ECHO) " * DONE!! NOTHING ELSE TO COMPILE ---> $(APP)-$(INTEGRATION): $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION)"
	-$(ECHO) " ******************************************************************************  \n"

.PHONY: $(APP_TEST)-$(INTEGRATION)
$(APP_TEST)-$(INTEGRATION) : $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)
	-$(ECHO) "\n ******************************************************************************  "
	-$(ECHO) " * DONE!! NOTHING ELSE TO COMPILE ---> $(APP_TEST): $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION)"
	-$(ECHO) " ****************************************************************************** \n"

.PHONY: directories-obj
directories-obj :
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR_FPGA)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(PREPRO_DIR)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(STRUCT_DIR)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(CONFIG_DIR)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(ALGO_DIR)/$(INTEGRATION)
	-$(MKDIR) $(ACTIVE_APP_DIR)/$(RES_DIR)/$(INTEGRATION)/$(INTEGRATION)

.PHONY: clean-all
clean-all:
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(BIN_DIR)
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(RES_DIR)

.PHONY: clean
clean:
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(BIN_DIR)
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(OBJ_DIR)

.PHONY: clean-results
clean-results:
	-$(RMDIR) $(ACTIVE_APP_DIR)/$(RES_DIR)


#########################################################
#                GLAY COMPILATION                       #
#########################################################

$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP)-$(INTEGRATION) : $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)/$(APP).o $(OBJ_FILES_UTIL) $(OBJ_FILES_UTIL_FPGA) $(OBJ_FILES_ALGO) $(OBJ_FILES_PREPRO) $(OBJ_FILES_STRUCT) $(OBJ_FILES_CONFIG)
	@$(CXX) $(CFLAGS) -o $@ $^  $(LFLAGS) $(LDFLAGS)

$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION) : $(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR)/$(APP_TEST).o $(OBJ_FILES_UTIL) $(OBJ_FILES_UTIL_FPGA) $(OBJ_FILES_ALGO) $(OBJ_FILES_PREPRO) $(OBJ_FILES_STRUCT) $(OBJ_FILES_CONFIG)
	@$(CXX) $(CFLAGS) -o $@ $^  $(LFLAGS) $(LDFLAGS)

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(MAIN_DIR)/$(APP).o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/$(APP).c $(ALL_HEADER_FILES) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(TEST_DIR)/$(APP_TEST).o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(TEST_DIR)/$(APP_TEST).c $(ALL_HEADER_FILES) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/%.c $(INC_FILES_UTIL) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(UTIL_DIR_FPGA)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(UTIL_DIR_FPGA)/%.c $(INC_FILES_UTIL) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(ALGO_DIR)/$(INTEGRATION)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/$(INTEGRATION)/%.c $(ALL_HEADER_FILES) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(PREPRO_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/%.c $(INC_FILES_PREPRO) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(STRUCT_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/%.c $(INC_FILES_STRUCT) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

$(ACTIVE_APP_DIR)/$(OBJ_DIR)/$(INTEGRATION)/$(CONFIG_DIR)/%.o : $(ACTIVE_APP_DIR)/$(SRC_DIR)/$(CONFIG_DIR)/%.c $(INC_FILES_CONFIG) directories-obj
	$(CXX) $(CFLAGS) $(OPENMP_INC) $(MODE) -c -o $@ $<

##########################################################################
# RUN GLay
##########################################################################

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

##########################################################################
# RUN Tests
##########################################################################



.PHONY: run-test
run-test: $(APP_TEST)
	$(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION) -f $(FILE_BIN) $(ARGS)

.PHONY: $(APP_TEST)
$(APP_TEST): $(APP_TEST)-$(INTEGRATION)

.PHONY: debug-test
debug-test: $(APP_TEST)
	gdb -ex=r --args $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION) -f $(FILE_BIN) $(ARGS)

.PHONY: debug-test-memory
debug-test-memory: $(APP_TEST)
	valgrind --leak-check=full --show-leak-kinds=all -v $(ACTIVE_APP_DIR)/$(BIN_DIR)/$(INTEGRATION)/$(APP_TEST)-$(INTEGRATION) -f $(FILE_BIN) $(ARGS)

# test files
.PHONY: test
test:
	@if $(MAKE) run-test -C $(ACTIVE_APP_DIR) | grep FAIL > /dev/null; \
		then exit 1; \
	fi
	
#########################################################
#       		    GRAPH ARGUMENTS         			#
#########################################################

export GRAPH_DIR ?= $(ROOT_DIR)/$(APP_DIR)/$(BENCH_DIR)

# TEST # small test graphs
# export GRAPH_SUIT ?= TEST
# export GRAPH_NAME ?= test
# export GRAPH_NAME ?= v51_e1021
# export GRAPH_NAME ?= v300_e2730
# export GRAPH_NAME ?= graphbrew

export GRAPH_SUIT ?= LAW
export GRAPH_NAME ?= LAW-amazon-2008
# export GRAPH_NAME ?= LAW-cnr-2000
# export GRAPH_NAME ?= LAW-dblp-2010
# export GRAPH_NAME ?= LAW-enron

# export GRAPH_SUIT ?= KRON
# export GRAPH_NAME ?= RMAT

# export FILE_BIN_TYPE ?= g.20.16.text
# export FILE_LABEL_TYPE ?= a.20.16.1000000.text

# export FILE_BIN_TYPE   ?= g.20.16.text.dbin
# export FILE_LABEL_TYPE ?= a.20.16.1000000.text.dbin

# export FILE_BIN_TYPE   ?=  g.5.16.text.dbin
# export FILE_LABEL_TYPE ?= a.5.16.100.text.dbin

# export FILE_BIN_TYPE ?= g.24.16.text.dbin
# export FILE_LABEL_TYPE ?= a.24.16.10000000.text.dbin

# export FILE_BIN_TYPE ?= g.24.16.text
# export FILE_LABEL_TYPE ?= a.24.16.10000000.text

# export FILE_BIN_TYPE ?= graph.txt
export FILE_BIN_TYPE ?= graph.bin
# export FILE_BIN_TYPE ?= graph.wbin

# export FILE_LABEL_TYPE ?= graph_Gorder.labels
# export FILE_LABEL_TYPE ?= graph_Rabbit.labels

#GRAPH file
export FILE_BIN = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_BIN_TYPE)
export FILE_LABEL = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_LABEL_TYPE)

#ALGORITHM
export PULL_PUSH 		?= 0
export ALGORITHMS 		?= 1

#GRAPH DATA_STRUCTURES
export SORT_TYPE		?= 2
export DATA_STRUCTURES  ?= 1
export REORDER_LAYER1 	?= 0
export REORDER_LAYER2   ?= 0
export REORDER_LAYER3   ?= 0
# export CACHE_SIZE       ?= 32768 #(32KB)
# export CACHE_SIZE       ?= 262144 #(256KB)
export CACHE_SIZE       ?= 5068672 #(22MB)

#ALGORITHM SPECIFIC ARGS
export ROOT 			?= 0
export TOLERANCE 		?= 1e-8
export DELTA			?= 800
export NUM_ITERATIONS	?= 1

#PERFORMANCE
export NUM_THREADS_PRE  ?= 1
export NUM_THREADS_ALGO ?= 1
export NUM_THREADS_KER  ?= 1

#EXPERIMENTS
export NUM_TRIALS 		?= 1

#GRAPH FROMAT EDGELIST
export FILE_FORMAT		?= 1
export CONVERT_FORMAT 	?= 1

#STATS COLLECTION VARIABLES
export BIN_SIZE 		?= 1000
export INOUT_STATS 		?= 0
export MASK_MODE 		?= 0

#########################################################
#                GENERAL XILINX ARGS                    #
#########################################################

DEVICE_INDEX ?= 0
XCLBIN_PATH ?= ./file.xclbin
export GLAY_FPGA_ARGS ?= -m $(DEVICE_INDEX) -q $(XCLBIN_PATH)

##################################################

export ARGS ?= $(GLAY_FPGA_ARGS) -k -M $(MASK_MODE) -j $(INOUT_STATS) -g $(BIN_SIZE) -z $(FILE_FORMAT) -d $(DATA_STRUCTURES) -a $(ALGORITHMS) -r $(ROOT) -n $(NUM_THREADS_PRE) -N $(NUM_THREADS_ALGO) -K $(NUM_THREADS_KER) -i $(NUM_ITERATIONS) -o $(SORT_TYPE) -p $(PULL_PUSH) -t $(NUM_TRIALS) -e $(TOLERANCE) -F $(FILE_LABEL) -l $(REORDER_LAYER1) -L $(REORDER_LAYER2) -O $(REORDER_LAYER3) -b $(DELTA) -C $(CACHE_SIZE)

##############################################
