#!/bin/bash


print_usage () {
    echo "Usage: "
    echo "  generate_build_cfg.sh APP_DIR_ACTIVE UTILS_DIR_ACTIVE KERNEL_NAME"
    echo ""
    echo "  APP_DIR_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GraphBlox/"
    echo "  UTILS_DIR_ACTIVE: utils"
    echo "  KERNEL_NAME: kernel"
    echo "  XILINX_IMPL_STRATEGY: 0"
    echo "  XILINX_JOBS_STRATEGY: 2"
    echo "  PART: xcu280-fsvh2892-2L-e"
    echo "  PLATFORM: xilinx_u250_gen3x16_xdma_4_1_202210_1"
    echo "  TARGET: hw"
    echo "  XILINX_NUM_KERNELS: 2"
    echo "  XILINX_MAX_THREADS: 8"
    echo "  DESIGN_FREQ_HZ: 300000000"
    echo ""
}
if [ "$1" = "" ]
then
    print_usage
fi

# APP_DIR_ACTIVE=$1
# UTILS_DIR_ACTIVE=$2
# KERNEL_NAME=$3
# XILINX_IMPL_STRATEGY=$4
# XILINX_JOBS_STRATEGY=$5
# PART=$6
# PLATFORM=$7
# TARGET=$8
# DESIGN_FREQ_HZ=$9
# XILINX_MAX_THREADS=${10}
# XILINX_NUM_KERNELS=${11}

PARAMS_SH_DIR=$1

source ${PARAMS_SH_DIR}

CFG_FILE_NAME="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_rtl_${TARGET}.cfg"

python3 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_PYTHON}/generate_rtl_synth_cfg.py ${APP_DIR_ACTIVE} ${UTILS_DIR_ACTIVE} ${KERNEL_NAME} ${XILINX_IMPL_STRATEGY} ${XILINX_JOBS_STRATEGY} ${PART} ${PLATFORM} ${TARGET} ${XILINX_NUM_KERNELS} ${XILINX_MAX_THREADS} ${DESIGN_FREQ_HZ} ${FULL_SRC_IP_DIR_OVERLAY} ${ARCHITECTURE} ${CAPABILITY} ${OVERRIDE_TOPOLOGY_JSON}

