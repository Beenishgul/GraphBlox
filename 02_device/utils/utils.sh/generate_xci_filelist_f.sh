# @Author: Abdullah
# @Date:   2023-04-06 18:46:46
# @Last Modified by:   Abdullah
# @Last Modified time: 2023-06-26 22:55:13
#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_xdc_filelist_f.sh APP_DIR_ACTIVE UTILS_DIR_ACTIVE KERNEL_NAME IP_DIR VIVADO_VIP_DIR"
  echo ""
  echo "  APP_DIR_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  UTILS_DIR_ACTIVE: utils"
  echo "  KERNEL_NAME: kernel"
  echo "  VIVADO_VIP_DIR: U250"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

APP_DIR_ACTIVE=$1
UTILS_DIR_ACTIVE=$2
KERNEL_NAME=$3
VIVADO_VIP_DIR=$4

CFG_FILE_NAME_XCI="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.xci.f"

rm_xci_filelist_f () {

  local filename=$1
 
  if [[ -z $(grep '[^[:space:]]' $filename ) ]] ; then
      rm ${filename}
  fi
}

generate_xci_filelist_f () {

  local ip_directory=$1
  local cfg_filelist_name=$2
  local verilog_type=$3

  for filepath in "$( find ${ip_directory} -type f -iname "*.${verilog_type}" | sort -n )" ; do  
    newtext="${filepath}"
    echo "$newtext" >> ${cfg_filelist_name}
  done 

}

newtext=""
echo "$newtext" > ${CFG_FILE_NAME_XCI}

generate_xci_filelist_f ${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.srcs/sources_1/ip/ ${CFG_FILE_NAME_XCI} "xci"

newtext=""
echo $newtext >> ${CFG_FILE_NAME_XCI}
rm_xci_filelist_f ${CFG_FILE_NAME_XCI}
