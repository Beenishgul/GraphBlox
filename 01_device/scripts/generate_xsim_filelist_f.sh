#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_xsim_filelist_f.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME IP_DIR"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  SCRIPTS_DIR: scripts"
  echo "  KERNEL_NAME: glay_kernel"
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

glay_pkgs="pkg"
glay_engine="engine"
glay_kernel="kernel"
glay_top="top"
glay_testbench="testbench"

glay_memory="memory"
glay_cache="cache"
glay_generator="generator"

glay_control="control"
glay_utils="utils"
glay_utils_arbiter="arbiter"
glay_utils_counter="counter"
glay_utils_include="include"

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

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_pkgs}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_utils}/${glay_utils_arbiter}/ ${CFG_FILE_NAME} "sv"  

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_utils}/${glay_utils_counter}/ ${CFG_FILE_NAME} "sv"  

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_memory}/${glay_cache}/ ${CFG_FILE_NAME} "v" 

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_memory}/${glay_generator}/ ${CFG_FILE_NAME} "sv"  

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_control}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_engine}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel}/ ${CFG_FILE_NAME} "sv"

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_top}/ ${CFG_FILE_NAME} "v"

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

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_638x128/simulation/fifo_generator_vlog_beh.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_638x128/hdl/fifo_generator_v13_2_rfs.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_638x128/sim/fifo_638x128.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_516x128/sim/fifo_516x128.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_638x32/sim/fifo_638x32.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_516x32/sim/fifo_516x32.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_167x32/sim/fifo_167x32.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_711x32/sim/fifo_711x32.v"
echo $newtext >> ${CFG_FILE_NAME}

ewtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/asym_bram_64wrtx512rdx32/simulation/blk_mem_gen_v8_4.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/asym_bram_64wrtx512rdx32/sim/asym_bram_64wrtx512rdx32.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/asym_bram_512wrtx64rdx32/sim/asym_bram_512wrtx64rdx32.v"
echo $newtext >> ${CFG_FILE_NAME}

generate_xsim_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_testbench}/${MODULE}/ ${CFG_FILE_NAME} "sv"

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${XILINX_VIVADO}/data/verilog/src/glbl.v"
echo $newtext >> ${CFG_FILE_NAME}
