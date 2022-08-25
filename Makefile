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



PROJECT := vadd
TARGET 	:= hw_emu
DEVICE 	:= xilinx_u280_xdma_201920_3 
XCLBIN 	:= ./xclbin
XO 		:= ./xo

EXECUTABLE := run-$(PROJECT)

DSA := $(call device2sandsa, $(DEVICE))
BUILD_DIR := ./_x.$(TARGET).$(DSA)
BUILD_DIR_PROJECT := $(BUILD_DIR)/$(PROJECT)

CXX := g++
VPP := v++
GCC := gcc

RM := rm -f
RMDIR := rm -rf
ECHO:= @echo
CP := cp -rf


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

$(EXECUTABLE): $(HOST_SRCS)
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
	-$(RMDIR) *.log emconfig.json vadd.xclbin vivado.jou
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