



TARGET := hw_emu


##########################################################################
# The below commands generate a XO file from a pre-exsisitng RTL kernel.
###########################################################################
VIVADO := $(XILINX_VIVADO)/bin/vivado
$(XO)/vadd.xo: ./src/xml/kernel.xml ./scripts/package_kernel.tcl ./scripts/gen_xo.tcl ./src/IP/*.sv ./src/IP/*.v
	mkdir -p $(XO)
	$(VIVADO) -mode batch -source scripts/gen_xo.tcl -tclargs $(XO)/vadd.xo vadd $(TARGET) $(DEVICE)
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