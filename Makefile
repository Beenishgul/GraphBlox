#########################################################
#                GENERAL DIRECTOIRES HOST               #
#########################################################
export APP                 = glay
# export APP_TEST            = test_match
# export APP_TEST            = test_glay
# export APP_TEST            = test_StalaGraph
export APP_TEST            = test_glayGraph
export INTEGRATION         = openmp

##################################################

export ROOT_DIR                = $(shell cd .. ; pwd)
export APP_DIR                 = 00_GLay
export HOST_DIR                = 00_host
export DEVICE_DIR              = 01_device

export BENCH_DIR               = 03_test_graphs

export MAKE_NUM_THREADS        = $(shell grep -c ^processor /proc/cpuinfo)
export MAKE_HOST               = -w -C $(ROOT_DIR)/$(APP_DIR)/$(HOST_DIR) -j$(MAKE_NUM_THREADS)
export MAKE_DEVICE             = -w -C $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR) -j$(MAKE_NUM_THREADS)
#########################################################

.PHONY: help
help: 
	$(MAKE) help $(MAKE_HOST)
	$(MAKE) help $(MAKE_DEVICE)

.PHONY: clean-all
clean-all:
	$(MAKE) clean-all $(MAKE_HOST)
	$(MAKE) clean $(MAKE_DEVICE)

.PHONY: clean
clean:
	$(MAKE) clean $(MAKE_HOST)

.PHONY: clean-results
clean-results:
	$(MAKE) clean-results $(MAKE_HOST)

##########################################################################
# RUN GLay HOST
##########################################################################

.PHONY: run
run:
	$(MAKE) run $(MAKE_HOST) 
	
.PHONY: debug-memory
debug-memory:
	$(MAKE) debug-memory $(MAKE_HOST) 

.PHONY: debug
debug:
	$(MAKE) debug $(MAKE_HOST) 

##########################################################################
# RUN Tests HOST
##########################################################################

.PHONY: run-test
run-test:
	$(MAKE) run-test $(MAKE_HOST) 

.PHONY: debug-test
debug-test:
	$(MAKE) debug-test $(MAKE_HOST) 

.PHONY: debug-test-memory
debug-test-memory:
	$(MAKE) debug-test-memory $(MAKE_HOST)

# test files
.PHONY: test
test:
	$(MAKE) test $(MAKE_HOST)

#########################################################
#                   GRAPH ARGUMENTS HOST                #
#########################################################

export GRAPH_DIR = $(ROOT_DIR)/$(APP_DIR)/$(BENCH_DIR)

# TEST # small test graphs
# export GRAPH_SUIT = TEST
# export GRAPH_NAME = test
# export GRAPH_NAME = v51_e1021
# export GRAPH_NAME = v300_e2730
# export GRAPH_NAME = graphbrew

export GRAPH_SUIT = LAW
export GRAPH_NAME = LAW-amazon-2008
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

# export FILE_BIN_TYPE = graph.txt
export FILE_BIN_TYPE = graph.bin
# export FILE_BIN_TYPE = graph.wbin

# export FILE_LABEL_TYPE = graph_Gorder.labels
# export FILE_LABEL_TYPE = graph_Rabbit.labels

#GRAPH file
export FILE_BIN = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_BIN_TYPE)
export FILE_LABEL = $(GRAPH_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_LABEL_TYPE)

#ALGORITHM
export PULL_PUSH        = 0
export ALGORITHMS       = 1

#GRAPH DATA_STRUCTURES
export SORT_TYPE        = 2
export DATA_STRUCTURES  = 0
export REORDER_LAYER1   = 0
export REORDER_LAYER2   = 0
export REORDER_LAYER3   = 0
# export CACHE_SIZE       = 32768 #(32KB)
# export CACHE_SIZE       = 262144 #(256KB)
export CACHE_SIZE       = 5068672 #(22MB)

#ALGORITHM SPECIFIC ARGS
export ROOT             = 0
export TOLERANCE        = 1e-8
export DELTA            = 800
export NUM_ITERATIONS   = 1

#PERFORMANCE
export NUM_THREADS_PRE  = 1
export NUM_THREADS_ALGO = 1
export NUM_THREADS_KER  = 1

#EXPERIMENTS
export NUM_TRIALS       = 1

#GRAPH FROMAT EDGELIST
export FILE_FORMAT      = 1
export CONVERT_FORMAT   = 1

#STATS COLLECTION VARIABLES
export BIN_SIZE         = 1000
export INOUT_STATS      = 0
export MASK_MODE        = 0

##################################################

export ARGS = $(GLAY_FPGA_ARGS) -k -M $(MASK_MODE) -j $(INOUT_STATS) -g $(BIN_SIZE) -z $(FILE_FORMAT) -d $(DATA_STRUCTURES) -a $(ALGORITHMS) -r $(ROOT) -n $(NUM_THREADS_PRE) -N $(NUM_THREADS_ALGO) -K $(NUM_THREADS_KER) -i $(NUM_ITERATIONS) -o $(SORT_TYPE) -p $(PULL_PUSH) -t $(NUM_TRIALS) -e $(TOLERANCE) -F $(FILE_LABEL) -l $(REORDER_LAYER1) -L $(REORDER_LAYER2) -O $(REORDER_LAYER3) -b $(DELTA) -C $(CACHE_SIZE)

##############################################

#########################################################
#                        XILINX ARGS                    #
#########################################################
export XILINX_DIR         = xilinx
export SCRIPTS_DIR        = scripts
export KERNEL_NAME        = glay_kernel_C
export IP_DIR             = IP
export SCRIPTS_DIR_ACTIVE = $(KERNEL_NAME)_$(SCRIPTS_DIR)
export XILINX_DIR_ACTIVE  = $(KERNEL_NAME)_$(XILINX_DIR)
export IP_DIR_ACTIVE      = $(KERNEL_NAME)_$(IP_DIR)

export DEVICE_INDEX       = 0
export XCLBIN_PATH        = $(ROOT_DIR)/$(APP_DIR)/$(DEVICE_DIR)/$(XILINX_DIR_ACTIVE)/$(KERNEL_NAME)_vivado_$(TARGET)_krnl_project/$(KERNEL_NAME)_test_$(TARGET).xclbin
export GLAY_FPGA_ARGS     = -m $(DEVICE_INDEX) -q $(XCLBIN_PATH)



# PART setting: uncomment the line matching your Alveo card
# export PART =  xcu200-fsgd2104-2-e
export PART = xcu250-figd2104-2L-e
# export PART =  xcu50-fsvh2104-2-e
# export PART =  xcu55c-fsvh2892-2L-e
# export PART =  xcu280-fsvh2892-2L-e

# PLATFORM setting: uncomment the lin matching your Alveo card
# export PLATFORM =  xilinx_u200_gen3x16_xdma_2_202110_1
export PLATFORM = xilinx_u250_gen3x16_xdma_4_1_202210_1
# export PLATFORM =  xilinx_u50_gen3x16_xdma_5_202210_1
# export PLATFORM =  xilinx_u55c_gen3x16_xdma_3_202210_1
# export PLATFORM =  xilinx_u280_gen3x16_xdma_1_202211_1

# TARGET: set the build target, can be hw or hw_emu
export TARGET = hw_emu
# export TARGET = hw

export EMU_MODE = off
##################################################

################## resource generation and simulation
.PHONY: gen-vip
gen-vip:
	$(MAKE) gen-vip $(MAKE_DEVICE)

.PHONY: pack-kernel
pack-kernel:
	$(MAKE) pack-kernel $(MAKE_DEVICE)

################## simulation

.PHONY: run-sim
run-sim:
	$(MAKE) run-sim $(MAKE_DEVICE)

.PHONY: run-sim-clean
run-sim-clean:
	$(MAKE) run-sim-clean $(MAKE_DEVICE)

.PHONY: run-sim-reset
run-sim-reset:
	$(MAKE) run-sim-reset $(MAKE_DEVICE)

.PHONY: run-sim-wave
run-sim-wave:
	$(MAKE) run-sim-wave $(MAKE_DEVICE)

.PHONY: run-sim-help
run-sim-help:
	$(MAKE) run-sim-help $(MAKE_DEVICE)

################## build HW
.PHONY: build-hw
build-hw:
	$(MAKE) build-hw $(MAKE_DEVICE)

.PHONY: run-emu
run-emu:
	$(MAKE) run-emu $(MAKE_DEVICE)

.PHONY: run-emu-wave
run-emu-wave:
	$(MAKE) run-emu-wave $(MAKE_DEVICE)

.PHONY: gen-host-bin
gen-host-bin: 
	$(MAKE) gen-host-bin $(MAKE_DEVICE)


.PHONY: gen-host-bin
gen-host-bin: 
	$(MAKE) gen-host-bin $(MAKE_DEVICE)

.PHONY: gen-scripts-dir
gen-scripts-dir: 
	$(MAKE) gen-scripts-dir $(MAKE_DEVICE)