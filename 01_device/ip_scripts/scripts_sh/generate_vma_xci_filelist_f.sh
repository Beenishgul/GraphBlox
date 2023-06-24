# @Author: Abdullah
# @Date:   2023-04-06 18:46:46
# @Last Modified by:   Abdullah
# @Last Modified time: 2023-06-19 01:31:48
#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_xdc_filelist_f.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME IP_DIR VIP_DIR"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  SCRIPTS_DIR: scripts"
  echo "  KERNEL_NAME: kernel"
  echo "  VIP_DIR: U250"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3
VIP_DIR=$4

CFG_FILE_NAME_XCI="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_vma_filelist_package.xci.f"

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

generate_xci_filelist_f ${ACTIVE_APP_DIR}/${VIP_DIR}/ ${CFG_FILE_NAME_XCI} "xci"

newtext=""
echo $newtext >> ${CFG_FILE_NAME_XCI}
rm_xci_filelist_f ${CFG_FILE_NAME_XCI}