#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_xsim_filelist_f.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME IP_DIR"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  SCRIPTS_DIR: scripts"
  echo "  KERNEL_NAME: kernel"
  echo "  IP_DIR : IP"
  echo "  VIP_DIR: vivado_generated_vip"
  echo "  MODULE : glay|arbiter"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3
IP_DIR=$4
VIP_DIR=$5
MODULE=$6

pkgs="pkg"
engine="engine"
kernel="kernel"
top="top"
testbench="testbench"

memory="memory"
cache="cache"
generator="generator"

control="control"
utils="utils"
utils_arbiter="arbiter"
utils_counter="counter"
utils_include="include"

iob_include="iob_include"
portmaps="portmaps"


CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_filelist_xsim.f"

generate_xsim_filelist_f () {

  local ip_directory=$1
  local cfg_filelist_name=$2
  local verilog_type=$3

  for filepath in "$( find ${ip_directory} -type f -iname "*.${verilog_type}" | sort -n )" ; do  
    newtext="${filepath}"
    echo "$newtext" >> ${cfg_filelist_name}
  done 

  newtext=""
  echo $newtext >> ${CFG_FILE_NAME}
}

newtext=""
echo $newtext > ${CFG_FILE_NAME}

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${pkgs}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_arbiter}/ ${CFG_FILE_NAME} "sv"  

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_counter}/ ${CFG_FILE_NAME} "sv"  

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${cache}/ ${CFG_FILE_NAME} "v" 

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${generator}/ ${CFG_FILE_NAME} "sv"  

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${control}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engine}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${kernel}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${top}/ ${CFG_FILE_NAME} "v"

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/control_${KERNEL_NAME}_vip/sim/control_${KERNEL_NAME}_vip_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/control_${KERNEL_NAME}_vip/sim/control_${KERNEL_NAME}_vip.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/control_${KERNEL_NAME}_vip/hdl/axi_vip_v1_1_vl_rfs.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/control_${KERNEL_NAME}_vip/hdl/axi_infrastructure_v1_1_vl_rfs.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/slv_m00_axi_vip/sim/slv_m00_axi_vip_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/slv_m00_axi_vip/sim/slv_m00_axi_vip.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_937x16/simulation/fifo_generator_vlog_beh.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_937x16/hdl/fifo_generator_v13_2_rfs.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_937x32/sim/fifo_937x32.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_814x16/sim/fifo_814x16.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_937x16/sim/fifo_937x16.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_937x16_FWFT/sim/fifo_937x16_FWFT.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_814x16/sim/fifo_814x16.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_812x16/sim/fifo_812x16.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_512x32_asym_512wrt_64rd/sim/fifo_512x32_asym_512wrt_64rd.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/bram_64x256_asym_64wrt_512rd/simulation/blk_mem_gen_v8_4.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/bram_64x256_asym_64wrt_512rd/sim/bram_64x256_asym_64wrt_512rd.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/bram_512x32_asym_512wrt_64rd/sim/bram_512x32_asym_512wrt_64rd.v"
echo $newtext >> ${CFG_FILE_NAME}

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${testbench}/${MODULE}/ ${CFG_FILE_NAME} "sv"

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${XILINX_VIVADO}/data/verilog/src/glbl.v"
echo $newtext >> ${CFG_FILE_NAME}
