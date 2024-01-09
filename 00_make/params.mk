#!make
# =========================================================
#                        SHELL ARGS                    
# =========================================================
#                        HOST ARGS                    
# =========================================================
$(shell echo '#!/usr/bin/env bash' > $(PARAMS_SH_DIR))
$(shell echo 'ALGORITHM_NAME=$(ALGORITHM_NAME)' >> $(PARAMS_SH_DIR))
$(shell echo 'ALGORITHMS=$(ALGORITHMS)' >> $(PARAMS_SH_DIR))
$(shell echo 'APP=$(APP)' >> $(PARAMS_SH_DIR))
$(shell echo 'APP_DIR=$(APP_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'APP_LANG=$(APP_LANG)' >> $(PARAMS_SH_DIR))
$(shell echo 'APP_TEST=$(APP_TEST)' >> $(PARAMS_SH_DIR))
$(shell echo 'BENCH_DIR=$(BENCH_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'BIN_SIZE=$(BIN_SIZE)' >> $(PARAMS_SH_DIR))
$(shell echo 'CACHE_SIZE=$(CACHE_SIZE)' >> $(PARAMS_SH_DIR))
$(shell echo 'CONVERT_FORMAT=$(CONVERT_FORMAT)' >> $(PARAMS_SH_DIR))
$(shell echo 'DATA_STRUCTURES=$(DATA_STRUCTURES)' >> $(PARAMS_SH_DIR))
$(shell echo 'DELTA=$(DELTA)' >> $(PARAMS_SH_DIR))
$(shell echo 'DEVICE_DIR=$(DEVICE_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'FILE_BIN=$(FILE_BIN)' >> $(PARAMS_SH_DIR))
$(shell echo 'FILE_BIN_TYPE=$(FILE_BIN_TYPE)' >> $(PARAMS_SH_DIR))
$(shell echo 'FILE_FORMAT=$(FILE_FORMAT)' >> $(PARAMS_SH_DIR))
$(shell echo 'FILE_LABEL=$(FILE_LABEL)' >> $(PARAMS_SH_DIR))
$(shell echo 'FULL_SRC_FPGA_UTILS_CPP=$(FULL_SRC_FPGA_UTILS_CPP)' >> $(PARAMS_SH_DIR))
$(shell echo 'GIT_VER=$(GIT_VER)' >> $(PARAMS_SH_DIR))
$(shell echo 'GRAPH_DIR=$(GRAPH_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'GRAPH_NAME=$(GRAPH_NAME)' >> $(PARAMS_SH_DIR))
$(shell echo 'GRAPH_SUIT=$(GRAPH_SUIT)' >> $(PARAMS_SH_DIR))
$(shell echo 'HOST_DIR=$(HOST_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'HOST_NAME=$(HOST_NAME)' >> $(PARAMS_SH_DIR))
$(shell echo 'INOUT_STATS=$(INOUT_STATS)' >> $(PARAMS_SH_DIR))
$(shell echo 'INTEGRATION=$(INTEGRATION)' >> $(PARAMS_SH_DIR))
$(shell echo 'MAKE_DIR=$(MAKE_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'MAKE_NUM_THREADS=$(MAKE_NUM_THREADS)' >> $(PARAMS_SH_DIR))
$(shell echo 'MASK_MODE=$(MASK_MODE)' >> $(PARAMS_SH_DIR))
$(shell echo 'NUM_ITERATIONS=$(NUM_ITERATIONS)' >> $(PARAMS_SH_DIR))
$(shell echo 'NUM_THREADS_ALGO=$(NUM_THREADS_ALGO)' >> $(PARAMS_SH_DIR))
$(shell echo 'NUM_THREADS_KER=$(NUM_THREADS_KER)' >> $(PARAMS_SH_DIR))
$(shell echo 'NUM_THREADS_PRE=$(NUM_THREADS_PRE)' >> $(PARAMS_SH_DIR))
$(shell echo 'NUM_TRIALS=$(NUM_TRIALS)' >> $(PARAMS_SH_DIR))
$(shell echo 'PARAMS_SH=$(PARAMS_SH)' >> $(PARAMS_SH_DIR))
$(shell echo 'PARAMS_SH_DIR=$(PARAMS_SH_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'PARAMS_TCL=$(PARAMS_TCL)' >> $(PARAMS_SH_DIR))
$(shell echo 'PARAMS_TCL_DIR=$(PARAMS_TCL_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'PULL_PUSH=$(PULL_PUSH)' >> $(PARAMS_SH_DIR))
$(shell echo 'REORDER_LAYER1=$(REORDER_LAYER1)' >> $(PARAMS_SH_DIR))
$(shell echo 'REORDER_LAYER2=$(REORDER_LAYER2)' >> $(PARAMS_SH_DIR))
$(shell echo 'REORDER_LAYER3=$(REORDER_LAYER3)' >> $(PARAMS_SH_DIR))
$(shell echo 'ROOT=$(ROOT)' >> $(PARAMS_SH_DIR))
$(shell echo 'ROOT_DIR=$(ROOT_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'SORT_TYPE=$(SORT_TYPE)' >> $(PARAMS_SH_DIR))
$(shell echo 'TOLERANCE=$(TOLERANCE)' >> $(PARAMS_SH_DIR))

# =========================================================
#                        DEVICE ARGS                    
# =========================================================
$(shell echo 'ALVEO=$(ALVEO)' >> $(PARAMS_SH_DIR))
$(shell echo 'APP_DIR_ACTIVE=$(APP_DIR_ACTIVE)' >> $(PARAMS_SH_DIR))
$(shell echo 'ARCHITECTURE=$(ARCHITECTURE)' >> $(PARAMS_SH_DIR))
$(shell echo 'PAUSE_FILE_GENERATION=$(PAUSE_FILE_GENERATION)' >> $(PARAMS_SH_DIR))
$(shell echo 'CAPABILITY=$(CAPABILITY)' >> $(PARAMS_SH_DIR))
$(shell echo 'COLOR_TAIL_EMU_PL=$(COLOR_TAIL_EMU_PL)' >> $(PARAMS_SH_DIR))
$(shell echo 'COLOR_TAIL_EMU_SUB_PL=$(COLOR_TAIL_EMU_SUB_PL)' >> $(PARAMS_SH_DIR))
$(shell echo 'COLOR_TAIL_IMPL_PL=$(COLOR_TAIL_IMPL_PL)' >> $(PARAMS_SH_DIR))
$(shell echo 'COLOR_TAIL_PACK_PL=$(COLOR_TAIL_PACK_PL)' >> $(PARAMS_SH_DIR))
$(shell echo 'COLOR_TAIL_REPORT_PL=$(COLOR_TAIL_REPORT_PL)' >> $(PARAMS_SH_DIR))
$(shell echo 'COLOR_TAIL_SIM_PL=$(COLOR_TAIL_SIM_PL)' >> $(PARAMS_SH_DIR))
$(shell echo 'DESIGN_FREQ_HZ=$(DESIGN_FREQ_HZ)' >> $(PARAMS_SH_DIR))
$(shell echo 'DEVICE_INDEX=$(DEVICE_INDEX)' >> $(PARAMS_SH_DIR))
$(shell echo 'FULL_SRC_IP_DIR_CONFIG=$(FULL_SRC_IP_DIR_CONFIG)' >> $(PARAMS_SH_DIR))
$(shell echo 'FULL_SRC_IP_DIR_OVERLAY=$(FULL_SRC_IP_DIR_OVERLAY)' >> $(PARAMS_SH_DIR))
$(shell echo 'FULL_SRC_IP_DIR_RTL=$(FULL_SRC_IP_DIR_RTL)' >> $(PARAMS_SH_DIR))
$(shell echo 'FULL_SRC_IP_DIR_RTL_ACTIVE=$(FULL_SRC_IP_DIR_RTL_ACTIVE)' >> $(PARAMS_SH_DIR))
$(shell echo 'IP_DIR_CONFIG=$(IP_DIR_CONFIG)' >> $(PARAMS_SH_DIR))
$(shell echo 'IP_DIR_HLS=$(IP_DIR_HLS)' >> $(PARAMS_SH_DIR))
$(shell echo 'IP_DIR_HLS_ACTIVE=$(IP_DIR_HLS_ACTIVE)' >> $(PARAMS_SH_DIR))
$(shell echo 'IP_DIR_RTL=$(IP_DIR_RTL)' >> $(PARAMS_SH_DIR))
$(shell echo 'IP_DIR_RTL_ACTIVE=$(IP_DIR_RTL_ACTIVE)' >> $(PARAMS_SH_DIR))
$(shell echo 'KERNEL_NAME=$(KERNEL_NAME)' >> $(PARAMS_SH_DIR))
$(shell echo 'KERNEL_PROJECT_PKG_XPR=$(KERNEL_PROJECT_PKG_XPR)' >> $(PARAMS_SH_DIR))
$(shell echo 'KERNEL_PROJECT_VPP_XPR=$(KERNEL_PROJECT_VPP_XPR)' >> $(PARAMS_SH_DIR))
$(shell echo 'PART=$(PART)' >> $(PARAMS_SH_DIR))
$(shell echo 'PLATFORM=$(PLATFORM)' >> $(PARAMS_SH_DIR))
$(shell echo 'REPORTS_DIR=$(REPORTS_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'REPORTS_DIR_ACTIVE=$(REPORTS_DIR_ACTIVE)' >> $(PARAMS_SH_DIR))
$(shell echo 'SYSTEM_CACHE_SIZE_B=$(SYSTEM_CACHE_SIZE_B)' >> $(PARAMS_SH_DIR))
$(shell echo 'TARGET=$(TARGET)' >> $(PARAMS_SH_DIR))
$(shell echo 'TESTBENCH_MODULE=$(TESTBENCH_MODULE)' >> $(PARAMS_SH_DIR))
$(shell echo 'UTILS_DIR=$(UTILS_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'UTILS_DIR_ACTIVE=$(UTILS_DIR_ACTIVE)' >> $(PARAMS_SH_DIR))
$(shell echo 'UTILS_PERL=$(UTILS_PERL)' >> $(PARAMS_SH_DIR))
$(shell echo 'UTILS_PYTHON=$(UTILS_PYTHON)' >> $(PARAMS_SH_DIR))
$(shell echo 'UTILS_SHELL=$(UTILS_SHELL)' >> $(PARAMS_SH_DIR))
$(shell echo 'UTILS_TCL=$(UTILS_TCL)' >> $(PARAMS_SH_DIR))
$(shell echo 'UTILS_XDC=$(UTILS_XDC)' >> $(PARAMS_SH_DIR))
$(shell echo 'VITIS_BUILD_DIR=$(VITIS_BUILD_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_BUILD_DIR=$(VIVADO_BUILD_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_EXPORT_DIR=$(VIVADO_EXPORT_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_GUI_FLAG=$(VIVADO_GUI_FLAG)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_IMPORT_DIR=$(VIVADO_IMPORT_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_PACKAGE_DIR=$(VIVADO_PACKAGE_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_RUN_DIR=$(VIVADO_RUN_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_SIMULATE_DIR=$(VIVADO_SIMULATE_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_VER=$(VIVADO_VER)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_VIP_DIR=$(VIVADO_VIP_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'VIVADO_VMA_DIR=$(VIVADO_VMA_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'XCLBIN_PATH=$(XCLBIN_PATH)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_CTRL_MODE=$(XILINX_CTRL_MODE)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_DIR=$(XILINX_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_DIR_ACTIVE=$(XILINX_DIR_ACTIVE)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_IMPL_STRATEGY=$(XILINX_IMPL_STRATEGY)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_JOBS_STRATEGY=$(XILINX_JOBS_STRATEGY)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_MAX_THREADS=$(XILINX_MAX_THREADS)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_NUM_KERNELS=$(XILINX_NUM_KERNELS)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_VITIS_DIR=$(XILINX_VITIS_DIR)' >> $(PARAMS_SH_DIR))
$(shell echo 'XILINX_VIVADO_DIR=$(XILINX_VIVADO_DIR)' >> $(PARAMS_SH_DIR))

# =========================================================
#                        TCL ARGS                    
# =========================================================
#                        HOST ARGS                    
# =========================================================
$(shell echo '#!/usr/bin/tclsh' > $(PARAMS_TCL_DIR))
$(shell echo 'set ALGORITHM_NAME $(ALGORITHM_NAME)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set ALGORITHMS $(ALGORITHMS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set APP $(APP)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set APP_DIR $(APP_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set APP_LANG $(APP_LANG)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set APP_TEST $(APP_TEST)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set BENCH_DIR $(BENCH_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set BIN_SIZE $(BIN_SIZE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set CACHE_SIZE $(CACHE_SIZE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set CONVERT_FORMAT $(CONVERT_FORMAT)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set DATA_STRUCTURES $(DATA_STRUCTURES)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set DELTA $(DELTA)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set DEVICE_DIR $(DEVICE_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FILE_BIN $(FILE_BIN)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FILE_BIN_TYPE $(FILE_BIN_TYPE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FILE_FORMAT $(FILE_FORMAT)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FILE_LABEL $(FILE_LABEL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FULL_SRC_FPGA_UTILS_CPP $(FULL_SRC_FPGA_UTILS_CPP)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set GIT_VER $(GIT_VER)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set GRAPH_DIR $(GRAPH_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set GRAPH_NAME $(GRAPH_NAME)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set GRAPH_SUIT $(GRAPH_SUIT)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set HOST_DIR $(HOST_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set HOST_NAME $(HOST_NAME)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set INOUT_STATS $(INOUT_STATS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set INTEGRATION $(INTEGRATION)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set MAKE_DIR $(MAKE_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set MAKE_NUM_THREADS $(MAKE_NUM_THREADS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set MASK_MODE $(MASK_MODE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set NUM_ITERATIONS $(NUM_ITERATIONS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set NUM_THREADS_ALGO $(NUM_THREADS_ALGO)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set NUM_THREADS_KER $(NUM_THREADS_KER)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set NUM_THREADS_PRE $(NUM_THREADS_PRE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set NUM_TRIALS $(NUM_TRIALS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PARAMS_SH $(PARAMS_SH)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PARAMS_SH_DIR $(PARAMS_SH_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PARAMS_TCL $(PARAMS_TCL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PARAMS_TCL_DIR $(PARAMS_TCL_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PULL_PUSH $(PULL_PUSH)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set REORDER_LAYER1 $(REORDER_LAYER1)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set REORDER_LAYER2 $(REORDER_LAYER2)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set REORDER_LAYER3 $(REORDER_LAYER3)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set ROOT $(ROOT)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set ROOT_DIR $(ROOT_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set SORT_TYPE $(SORT_TYPE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set TOLERANCE $(TOLERANCE)' >> $(PARAMS_TCL_DIR))

# =========================================================
#                        DEVICE ARGS                    
# =========================================================
$(shell echo 'set ALVEO $(ALVEO)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set APP_DIR_ACTIVE $(APP_DIR_ACTIVE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set ARCHITECTURE $(ARCHITECTURE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PAUSE_FILE_GENERATION $(PAUSE_FILE_GENERATION)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set CAPABILITY $(CAPABILITY)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set COLOR_TAIL_EMU_PL $(COLOR_TAIL_EMU_PL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set COLOR_TAIL_EMU_SUB_PL $(COLOR_TAIL_EMU_SUB_PL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set COLOR_TAIL_IMPL_PL $(COLOR_TAIL_IMPL_PL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set COLOR_TAIL_PACK_PL $(COLOR_TAIL_PACK_PL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set COLOR_TAIL_REPORT_PL $(COLOR_TAIL_REPORT_PL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set COLOR_TAIL_SIM_PL $(COLOR_TAIL_SIM_PL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set DESIGN_FREQ_HZ $(DESIGN_FREQ_HZ)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set DEVICE_INDEX $(DEVICE_INDEX)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FULL_SRC_IP_DIR_CONFIG $(FULL_SRC_IP_DIR_CONFIG)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FULL_SRC_IP_DIR_OVERLAY $(FULL_SRC_IP_DIR_OVERLAY)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FULL_SRC_IP_DIR_RTL $(FULL_SRC_IP_DIR_RTL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set FULL_SRC_IP_DIR_RTL_ACTIVE $(FULL_SRC_IP_DIR_RTL_ACTIVE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set IP_DIR_CONFIG $(IP_DIR_CONFIG)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set IP_DIR_HLS $(IP_DIR_HLS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set IP_DIR_HLS_ACTIVE $(IP_DIR_HLS_ACTIVE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set IP_DIR_RTL $(IP_DIR_RTL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set IP_DIR_RTL_ACTIVE $(IP_DIR_RTL_ACTIVE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set KERNEL_NAME $(KERNEL_NAME)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set KERNEL_PROJECT_PKG_XPR $(KERNEL_PROJECT_PKG_XPR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set KERNEL_PROJECT_VPP_XPR $(KERNEL_PROJECT_VPP_XPR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PART $(PART)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set PLATFORM $(PLATFORM)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set REPORTS_DIR $(REPORTS_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set REPORTS_DIR_ACTIVE $(REPORTS_DIR_ACTIVE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set SYSTEM_CACHE_SIZE_B $(SYSTEM_CACHE_SIZE_B)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set TARGET $(TARGET)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set TESTBENCH_MODULE $(TESTBENCH_MODULE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set UTILS_DIR $(UTILS_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set UTILS_DIR_ACTIVE $(UTILS_DIR_ACTIVE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set UTILS_PERL $(UTILS_PERL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set UTILS_PYTHON $(UTILS_PYTHON)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set UTILS_SHELL $(UTILS_SHELL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set UTILS_TCL $(UTILS_TCL)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set UTILS_XDC $(UTILS_XDC)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VITIS_BUILD_DIR $(VITIS_BUILD_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_BUILD_DIR $(VIVADO_BUILD_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_EXPORT_DIR $(VIVADO_EXPORT_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_GUI_FLAG $(VIVADO_GUI_FLAG)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_IMPORT_DIR $(VIVADO_IMPORT_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_PACKAGE_DIR $(VIVADO_PACKAGE_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_RUN_DIR $(VIVADO_RUN_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_SIMULATE_DIR $(VIVADO_SIMULATE_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_VER $(VIVADO_VER)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_VIP_DIR $(VIVADO_VIP_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set VIVADO_VMA_DIR $(VIVADO_VMA_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XCLBIN_PATH $(XCLBIN_PATH)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_CTRL_MODE $(XILINX_CTRL_MODE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_DIR $(XILINX_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_DIR_ACTIVE $(XILINX_DIR_ACTIVE)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_IMPL_STRATEGY $(XILINX_IMPL_STRATEGY)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_JOBS_STRATEGY $(XILINX_JOBS_STRATEGY)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_MAX_THREADS $(XILINX_MAX_THREADS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_NUM_KERNELS $(XILINX_NUM_KERNELS)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_VITIS_DIR $(XILINX_VITIS_DIR)' >> $(PARAMS_TCL_DIR))
$(shell echo 'set XILINX_VIVADO_DIR $(XILINX_VIVADO_DIR)' >> $(PARAMS_TCL_DIR))