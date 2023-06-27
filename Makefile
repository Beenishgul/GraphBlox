#!make
ENV_HOST   := $(PWD)/host.env
ENV_DEVICE := $(PWD)/device.env

MAKE_HOST   := $(PWD)/host.mk
MAKE_DEVICE := $(PWD)/device.mk

include ./host.env
include ./device.env
export

# print_file_vars:
#     $($(foreach v, $(.VARIABLES), $(if $(filter file,$(origin $(v))), $(info  set $(v) "$($(v))"))) | tee ./env.tcl) ;\
#     $($(foreach v, $(.VARIABLES), $(if $(filter file,$(origin $(v))), $(info  $(v)=$($(v))))) | tee ./env.sh)

include ./host.mk
include ./device.mk

# =========================================================
# GLay HOST Argument list               
# =========================================================
export GLAY_FPGA_ARGS     = -m $(DEVICE_INDEX) -q $(XCLBIN_PATH) -Q $(KERNEL_NAME)
export ARGS = $(GLAY_FPGA_ARGS) -M $(MASK_MODE) -j $(INOUT_STATS) -g $(BIN_SIZE) -z $(FILE_FORMAT) -c $(CONVERT_FORMAT) -d $(DATA_STRUCTURES) -a $(ALGORITHMS) -r $(ROOT) -n $(NUM_THREADS_PRE) -N $(NUM_THREADS_ALGO) -K $(NUM_THREADS_KER) -i $(NUM_ITERATIONS) -o $(SORT_TYPE) -p $(PULL_PUSH) -t $(NUM_TRIALS) -e $(TOLERANCE) -F $(FILE_LABEL) -l $(REORDER_LAYER1) -L $(REORDER_LAYER2) -O $(REORDER_LAYER3) -b $(DELTA) -C $(CACHE_SIZE)
# =========================================================

