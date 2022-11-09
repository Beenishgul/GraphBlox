#!/bin/sh


# this script should be run where the makefile resides 

############################################################
# Hardware emulation run 
############################################################
make all TARGET=hw_emu DEVICE=xilinx_u280_xdma_201920_3 


#############################################################
# Hardware run 
##############################################################

#make all TARGET=hw DEVICE=xilinx_u200_gen3x16_xdma_1_202110_1 


