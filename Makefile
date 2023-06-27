#!make
MAKE_DIR = 00_make

include ./$(MAKE_DIR)/app.env
include ./$(MAKE_DIR)/host.env
include ./$(MAKE_DIR)/device.env

PARAMS_TCL = params.tcl
PARAMS_SH  = params.sh

PARAMS_SH_DIR=$(ROOT_DIR)/$(APP_DIR)/$(MAKE_DIR)/$(PARAMS_SH)
PARAMS_TCL_DIR=$(ROOT_DIR)/$(APP_DIR)/$(MAKE_DIR)/$(PARAMS_TCL)

export

include ./$(MAKE_DIR)/params.mk
include ./$(MAKE_DIR)/host.mk
include ./$(MAKE_DIR)/device.mk

# =========================================================
# GLay HOST Argument list               
# =========================================================
export GLAY_FPGA_ARGS     = -m $(DEVICE_INDEX) -q $(XCLBIN_PATH) -Q $(KERNEL_NAME)
export ARGS = $(GLAY_FPGA_ARGS) -M $(MASK_MODE) -j $(INOUT_STATS) -g $(BIN_SIZE) -z $(FILE_FORMAT) -c $(CONVERT_FORMAT) -d $(DATA_STRUCTURES) -a $(ALGORITHMS) -r $(ROOT) -n $(NUM_THREADS_PRE) -N $(NUM_THREADS_ALGO) -K $(NUM_THREADS_KER) -i $(NUM_ITERATIONS) -o $(SORT_TYPE) -p $(PULL_PUSH) -t $(NUM_TRIALS) -e $(TOLERANCE) -F $(FILE_LABEL) -l $(REORDER_LAYER1) -L $(REORDER_LAYER2) -O $(REORDER_LAYER3) -b $(DELTA) -C $(CACHE_SIZE)
# =========================================================

