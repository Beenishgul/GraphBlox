.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform>"
	$(ECHO) "      Command to generate the design for specified Target and Device."
	$(ECHO) ""
	$(ECHO) "  make clean "
	$(ECHO) "      Command to remove the generated non-hardware files."
	$(ECHO) ""
	$(ECHO) "  make cleanall"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
	$(ECHO) "  make check TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) ""
	$(ECHO) "  make run_nimbix DEVICE=<FPGA platform>"
	$(ECHO) "      Command to run application on Nimbix Cloud."
	$(ECHO) ""
	$(ECHO) "  make aws_build DEVICE=<FPGA platform>"
	$(ECHO) "      Command to build AWS xclbin application on AWS Cloud."
	$(ECHO) ""


#########################################################
#                GENERAL DIRECTOIRES                    #
#########################################################
# global binary /bin/glay name doesn't need to match main/glay.c
APP                 ?= glay

# test name needs to match the file name tests/test_glay.c
APP_TEST            ?= test_glay

# dirs Root app
APP_DIR             ?= .
BENCHMARKS_DIR      ?= ../01_test_graphs

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
UTIL_DIR            ?= utils
CONFIG_DIR			?= config

#contains the tests use make run-test to compile what in this directory
TEST_DIR            ?= tests

#contains the main for the graph processing framework
MAIN_DIR            ?= main

#########################################################
#                GENERAL VARIABLES                      #
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

CXX 	:= g++
VPP 	:= v++
GCC 	:= gcc

RM 		:= rm -f
RMDIR 	:= rm -rf
ECHO 	:= @echo
CP 		:= cp -rf

##############################################
#     GLAY COMPILATION FOLDERS/FILES         #
##############################################


#each implementation is contained in a separate folder. when you compile for openmp for example the files in openmp folder gets included
SRC_FILES_ALGO_OPENMP       =   $(wildcard $(APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/openmp/*.c)
SRC_FILES_UTIL      =   $(wildcard $(APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/*.c)
SRC_FILES_PREPRO    =   $(wildcard $(APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/*.c)
SRC_FILES_STRUCT    =   $(wildcard $(APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/*.c)
SRC_FILES_MAIN      =   $(wildcard $(APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/*.c)
SRC_FILES_TEST      =   $(wildcard $(APP_DIR)/$(SRC_DIR)/$(TEST_DIR)/*.c)


INC_FILES_ALGO_OPENMP       =   $(wildcard $(APP_DIR)/$(INC_DIR)/$(ALGO_DIR)/openmp/*.h)
INC_FILES_UTIL      =   $(wildcard $(APP_DIR)/$(INC_DIR)/$(UTIL_DIR)/*.h)
INC_FILES_PREPRO    =   $(wildcard $(APP_DIR)/$(INC_DIR)/$(PREPRO_DIR)/*.h)
INC_FILES_STRUCT    =   $(wildcard $(APP_DIR)/$(INC_DIR)/$(STRUCT_DIR)/*.h)
INC_FILES_CONFIG    =   $(wildcard $(APP_DIR)/$(INC_DIR)/$(CONFIG_DIR)/*.h)


ALL_HEADER_FILES    =   $(INC_FILES_ALGO_OPENMP) $(INC_FILES_UTIL) $(INC_FILES_PREPRO) $(INC_FILES_STRUCT) $(INC_FILES_CONFIG)

#create object file rules for the final binary target
OBJ_FILES_ALGO_OPENMP = $(patsubst $(APP_DIR)/$(SRC_DIR)/$(ALGO_DIR)/openmp/%.c,$(APP_DIR)/$(OBJ_DIR)/$(ALGO_DIR)/openmp/%.o,$(SRC_FILES_ALGO_OPENMP))

OBJ_FILES_UTIL      = $(patsubst $(APP_DIR)/$(SRC_DIR)/$(UTIL_DIR)/%.c,$(APP_DIR)/$(OBJ_DIR)/$(UTIL_DIR)/%.o,$(SRC_FILES_UTIL))
OBJ_FILES_PREPRO    = $(patsubst $(APP_DIR)/$(SRC_DIR)/$(PREPRO_DIR)/%.c,$(APP_DIR)/$(OBJ_DIR)/$(PREPRO_DIR)/%.o,$(SRC_FILES_PREPRO))
OBJ_FILES_STRUCT    = $(patsubst $(APP_DIR)/$(SRC_DIR)/$(STRUCT_DIR)/%.c,$(APP_DIR)/$(OBJ_DIR)/$(STRUCT_DIR)/%.o,$(SRC_FILES_STRUCT))
OBJ_FILES_MAIN      = $(patsubst $(APP_DIR)/$(SRC_DIR)/$(MAIN_DIR)/%.c,$(APP_DIR)/$(OBJ_DIR)/$(MAIN_DIR)/%.o,$(SRC_FILES_MAIN))
OBJ_FILES_TEST      = $(patsubst $(APP_DIR)/$(SRC_DIR)/$(TEST_DIR)/%.c,$(APP_DIR)/$(OBJ_DIR)/$(TEST_DIR)/%.o,$(SRC_FILES_TEST))

CC                = gcc

OPENMP_INC =    -I$(APP_DIR)/$(INC_DIR)/$(STRUCT_DIR)               \
				-I$(APP_DIR)/$(INC_DIR)/$(ALGO_DIR)/$(INTEGRATION)  \
				-I$(APP_DIR)/$(INC_DIR)/$(PREPRO_DIR)               \
				-I$(APP_DIR)/$(INC_DIR)/$(UTIL_DIR)   				\
				-I$(APP_DIR)/$(INC_DIR)/$(CONFIG_DIR)              


# flags
CFLAGS   =  -O3 -Wall -m64 -fopenmp -g
LFLAGS = -lm -lJudy


# TEST PASS OR FAIL
PASS = \033[92mPASS\033[0m
FAIL = \033[91mFAIL\033[0m

##################################################
##################################################

######################################################################
# Executable Arguments
######################################################################

DEVICE_INDEX := 0
XCLBIN_PATH := ./file.xclbin
CMD_ARGS := $(DEVICE_INDEX) $(XCLBIN_PATH)

######################################################################
# G++ COMPILER FLAGS
######################################################################
host_CXXFLAGS += -g -g -std=c++17 -I./ -I$(XILINX_XRT)/include -I$(XILINX_VIVADO)/include -Wall -O0 
# The below are linking flags for C++ Compiler
xrt_LDFLAGS += -L$(XILINX_XRT)/lib -lxrt_coreutil -pthread
CXXFLAGS += $(host_CXXFLAGS)
CFLAGS += $(host_CXXFLAGS)


HOST_SRCS += ./src/host/user-host.c

# Host compiler global settings
CXXFLAGS += -fmessage-length=0
LDFLAGS += -lrt -lstdc++ $(xrt_LDFLAGS) 


##########################################################################
# Compile Executable
##########################################################################

$(EXECUTABLE): $(HOST_SRCS)s
	$(CXX) $(CXXFLAGS) $(HOST_SRCS) -o '$@' $(LDFLAGS)

##########################################################################
# RUN Executable
##########################################################################

run: $(EXECUTABLE)
	./$(EXECUTABLE) $(CMD_ARGS)

##########################################################################
# Cleaning stuff
##########################################################################
clean:
	#-$(RMDIR) $(EXECUTABLE) $(XCLBIN)/{*sw_emu*,*hw_emu*}
	-$(RMDIR) $(EXECUTABLE) $(XCLBIN)
	-$(RMDIR) *.log emconfig.json glay.xclbin vivado.jou
	#-$(RMDIR) TempConfig system_estimate.xtxt *.rpt
	#-$(RMDIR) src/*.ll _v++_* .Xil emconfig.json dltmp* xmltmp* *.log *.jou

cleanall: clean
	-$(RMDIR) $(XCLBIN) $(XO)
	-$(RMDIR) _x
	-$(RMDIR) ./tmp_kernel_pack* ./packaged_kernel*
###########################################################################
#END OF Cleaning stuff
##########################################################################


##########################################################################
# The below commands generate a XO file from a pre-exsisitng RTL kernel.
###########################################################################
VIVADO := $(XILINX_VIVADO)/bin/vivado
$(XO)/$(PROJECT).xo: ./src/xml/kernel.xml ./scripts/package_kernel.tcl ./scripts/gen_xo.tcl ./src/IP/*.sv ./src/IP/*.v
	mkdir -p $(XO)
	$(VIVADO) -mode batch -source scripts/gen_xo.tcl -tclargs $(XO)/$(PROJECT).xo $(PROJECT) $(TARGET) $(DEVICE)
###########################################################################
#END OF GENERATION OF XO
##########################################################################



#######################################################################
# RTL Kernel only supports Hardware and Hardware Emulation.
# THis line is to check that
#########################################################################
ifneq ($(TARGET),$(findstring $(TARGET), hw hw_emu))
$(warning WARNING:Application supports only hw hw_emu TARGET. Please use the target for running the application)
endif

###################################################################
#check the devices avaiable
########################################################################

check-devices:
ifndef DEVICE
	$(error DEVICE not set. Please set the DEVICE properly and rerun. Run "make help" for more details.)
endif

############################################################################
# check the VITIS environment
#############################################################################

ifndef XILINX_VITIS
$(error XILINX_VITIS variable is not set, please set correctly and rerun)
endif

