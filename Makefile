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

export APP_DIR                 = .
export MAKE_DIR_HOST           = 00_host
export MAKE_DIR_DEVICE         = 01_device

export MAKE_NUM_THREADS        = $(shell grep -c ^processor /proc/cpuinfo)
export MAKE_ARGS_HOST          = -w -C $(APP_DIR)/$(MAKE_DIR_HOST) -j$(MAKE_NUM_THREADS)

#########################################################

.PHONY: help
help: 
	$(MAKE) help $(MAKE_ARGS_HOST)

.PHONY: clean-all
clean-all:
	$(MAKE) clean-all $(MAKE_ARGS_HOST)

.PHONY: clean
clean:
	$(MAKE) clean $(MAKE_ARGS_HOST)

.PHONY: clean-results
clean-results:
	$(MAKE) clean-results $(MAKE_ARGS_HOST)

##########################################################################
# RUN GLay HOST
##########################################################################

.PHONY: run
run:
	$(MAKE) run $(MAKE_ARGS_HOST) 
	
.PHONY: debug-memory
debug-memory:
	$(MAKE) debug-memory $(MAKE_ARGS_HOST) 

.PHONY: debug
debug:
	$(MAKE) debug $(MAKE_ARGS_HOST) 

##########################################################################
# RUN Tests HOST
##########################################################################

.PHONY: run-test
run-test:
	$(MAKE) run-test $(MAKE_ARGS_HOST) 

.PHONY: debug-test
debug-test:
	$(MAKE) debug-test $(MAKE_ARGS_HOST) 

.PHONY: debug-test-memory
debug-test-memory:
	$(MAKE) debug-test-memory $(MAKE_ARGS_HOST)

# test files
.PHONY: test
test:
	$(MAKE) test $(MAKE_ARGS_HOST)

#########################################################
#       		    GRAPH ARGUMENTS HOST       			#
#########################################################

export BENCHMARKS_DIR = ../03_test_graphs

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
export FILE_BIN = $(BENCHMARKS_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_BIN_TYPE)
export FILE_LABEL = $(BENCHMARKS_DIR)/$(GRAPH_SUIT)/$(GRAPH_NAME)/$(FILE_LABEL_TYPE)

#ALGORITHM
export PULL_PUSH 		= 0
export ALGORITHMS 		= 1

#GRAPH DATA_STRUCTURES
export SORT_TYPE		= 2
export DATA_STRUCTURES  = 0
export REORDER_LAYER1 	= 0
export REORDER_LAYER2   = 0
export REORDER_LAYER3   = 0
# export CACHE_SIZE       = 32768 #(32KB)
# export CACHE_SIZE       = 262144 #(256KB)
export CACHE_SIZE       = 5068672 #(22MB)

#ALGORITHM SPECIFIC ARGS
export ROOT 			= 0
export TOLERANCE 		= 1e-8
export DELTA			= 800
export NUM_ITERATIONS	= 1

#PERFORMANCE
export NUM_THREADS_PRE  = 1
export NUM_THREADS_ALGO = 1
export NUM_THREADS_KER  = 1

#EXPERIMENTS
export NUM_TRIALS 		= 1

#GRAPH FROMAT EDGELIST
export FILE_FORMAT		= 1
export CONVERT_FORMAT 	= 1

#STATS COLLECTION VARIABLES
export BIN_SIZE 		= 1000
export INOUT_STATS 		= 0
export MASK_MODE 		= 0

##################################################

export ARGS = $(GLAY_FPGA_ARGS) -k -M $(MASK_MODE) -j $(INOUT_STATS) -g $(BIN_SIZE) -z $(FILE_FORMAT) -d $(DATA_STRUCTURES) -a $(ALGORITHMS) -r $(ROOT) -n $(NUM_THREADS_PRE) -N $(NUM_THREADS_ALGO) -K $(NUM_THREADS_KER) -i $(NUM_ITERATIONS) -o $(SORT_TYPE) -p $(PULL_PUSH) -t $(NUM_TRIALS) -e $(TOLERANCE) -F $(FILE_LABEL) -l $(REORDER_LAYER1) -L $(REORDER_LAYER2) -O $(REORDER_LAYER3) -b $(DELTA) -C $(CACHE_SIZE)

##############################################

#########################################################
#                        XILINX ARGS                    #
#########################################################

export DEVICE_INDEX   = 0
export XCLBIN_PATH    = ./$(APP).xclbin
export GLAY_FPGA_ARGS = -m $(DEVICE_INDEX) -q $(XCLBIN_PATH)


