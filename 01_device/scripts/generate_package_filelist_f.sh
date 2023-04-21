# @Author: Abdullah
# @Date:   2023-04-06 18:46:46
# @Last Modified by:   Abdullah
# @Last Modified time: 2023-04-19 18:03:37
#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_package_filelist_f.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME IP_DIR VIP_DIR"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  SCRIPTS_DIR: scripts"
  echo "  KERNEL_NAME: kernel"
  echo "  IP_DIR: IP"
  echo "  VIP_DIR: vivado_generated_vip"
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

pkgs="pkg"
engine="engine"
kernel="kernel"
top="top"

memory="memory"
cache="cache"
generator="generator"
control="control"
vertex="vertex"

utils="utils"
utils_arbiter="arbiter"
utils_counter="counter"
utils_fifo="fifo"
utils_include="include"

iob_include="iob_include"
portmaps="portmaps"

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_filelist_package.f"

generate_package_filelist_f () {

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

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${pkgs}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${cache}/${iob_include}/ ${CFG_FILE_NAME} "vh"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${cache}/ ${CFG_FILE_NAME} "v" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${generator}/ ${CFG_FILE_NAME} "sv"  

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_include}/ ${CFG_FILE_NAME} "vh" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_arbiter}/ ${CFG_FILE_NAME} "sv" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_counter}/ ${CFG_FILE_NAME} "sv" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_fifo}/ ${CFG_FILE_NAME} "sv" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${vertex}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${control}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engine}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${kernel}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${top}/ ${CFG_FILE_NAME} "v"

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_942x32/fifo_942x32.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_814x32/fifo_814x32.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_942x16/fifo_942x16.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_942x16_FWFT/fifo_942x16_FWFT.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_814x16/fifo_814x16.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_812x16/fifo_812x16.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/fifo_512x32_asym_512wrt_64rd/fifo_512x32_asym_512wrt_64rd.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/bram_64x256_asym_64wrt_512rd/bram_64x256_asym_64wrt_512rd.xci"
# echo $newtext >> ${CFG_FILE_NAME}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/bram_512x32_asym_512wrt_64rd/bram_512x32_asym_512wrt_64rd.xci"
# echo $newtext >> ${CFG_FILE_NAME}

