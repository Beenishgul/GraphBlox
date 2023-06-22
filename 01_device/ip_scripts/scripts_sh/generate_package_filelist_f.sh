# @Author: Abdullah
# @Date:   2023-04-06 18:46:46
# @Last Modified by:   Abdullah
# @Last Modified time: 2023-06-19 01:31:48
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

engines="engines"
engine_template="engine_template"
engine_cu_setup="engine_cu_setup"
engine_alu_operations="engine_alu_operations"
engine_conditional="engine_conditional"
engine_read_write="engine_read_write"
engine_stride_index="engine_stride_index"
engine_csr_index="engine_csr_index"
engine_write="engine_write"
engine_pipeline="engine_pipeline"

kernel="kernel"
top="top"

memory="memory"
memory_cache="cache"
memory_generator="generator"
memory_ram="ram"

control="control"
bundle="bundle"
cu="cu"
lane="lane"

utils="utils"
utils_arbiter="arbiter"
utils_counter="counter"
utils_fifo="fifo"
utils_include="include"

iob_include="iob_include"
portmaps="portmaps"

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_filelist_package.src.f"
# CFG_FILE_NAME_XCI="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_filelist_package.xci.f"
CFG_FILE_NAME_VH="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_filelist_package.vh.f"

rm_package_filelist_f () {

  local filename=$1
 
  if [[ -z $(grep '[^[:space:]]' $filename ) ]] ; then
      rm ${filename}
  fi
}

generate_package_filelist_f () {

  local ip_directory=$1
  local cfg_filelist_name=$2
  local verilog_type=$3

  for filepath in "$( find ${ip_directory} -type f -iname "*.${verilog_type}" | sort -n )" ; do  
    newtext="${filepath}"
    echo "$newtext" >> ${cfg_filelist_name}
  done 

}

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${pkgs}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${memory_cache}/${iob_include}/ ${CFG_FILE_NAME_VH} "vh"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${memory_ram}/ ${CFG_FILE_NAME} "sv"  

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${memory_cache}/ ${CFG_FILE_NAME} "v" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${memory}/${memory_generator}/ ${CFG_FILE_NAME} "sv"  

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_include}/ ${CFG_FILE_NAME_VH} "vh" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_arbiter}/ ${CFG_FILE_NAME} "sv" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_counter}/ ${CFG_FILE_NAME} "sv" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${utils}/${utils_fifo}/ ${CFG_FILE_NAME} "sv" 

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${bundle}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${cu}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${lane}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${control}/ ${CFG_FILE_NAME} "sv"

# generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/ ${CFG_FILE_NAME} "sv"
generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_cu_setup} ${CFG_FILE_NAME} "sv"
generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_template} ${CFG_FILE_NAME} "sv"
generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_pipeline} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_stride_index} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_csr_index} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_read_write} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_write} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_alu_operations} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${engines}/${engine_conditional} ${CFG_FILE_NAME} "sv"

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

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/slv_m00_axi_vip/slv_m00_axi_vip.xci"
# echo $newtext >> ${CFG_FILE_NAME_XCI}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/control_${KERNEL_NAME}_vip/control_${KERNEL_NAME}_vip.xci"
# echo $newtext >> ${CFG_FILE_NAME_XCI}

# newtext="${ACTIVE_APP_DIR}/${VIP_DIR}/system_cache_512x64/system_cache_512x64.xci"
# echo $newtext >> ${CFG_FILE_NAME_XCI}

# generate_package_filelist_f ${ACTIVE_APP_DIR}/${VIP_DIR}/ ${CFG_FILE_NAME_XCI} "xci"

newtext=""
echo $newtext >> ${CFG_FILE_NAME}
# echo $newtext >> ${CFG_FILE_NAME_XCI}
echo $newtext >> ${CFG_FILE_NAME_VH}

rm_package_filelist_f ${CFG_FILE_NAME}
# rm_package_filelist_f ${CFG_FILE_NAME_XCI}
rm_package_filelist_f ${CFG_FILE_NAME_VH}