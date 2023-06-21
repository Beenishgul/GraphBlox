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
  echo "  ALVEO_PART: vivado_generated_vip"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3
ALVEO_PART=$4

XDC_DIR="scripts_xdc"

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_filelist_package.xdc.f"

rm_xdc_filelist_f () {

  local filename=$1
 
  if [[ -z $(grep '[^[:space:]]' $filename ) ]] ; then
      rm ${filename}
  fi
}

generate_xdc_filelist_f () {

  local script_directory=$1
  local cfg_filelist_name=$2
  local xdc_type=$3
  local alveo_part=$4
  local temp_filepath=${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${XDC_DIR}/${ALVEO_PART}/${alveo_part}.${xdc_type}

  for filepath in "$( find ${script_directory} -type f -iname "*${alveo_part}.${xdc_type}" | sort -n )" ; do  
    newtext="${filepath}"
    if [[ "$newtext" == "$temp_filepath" ]]; then
      echo "$newtext" >> ${cfg_filelist_name}
    fi
  done 

}

generate_xdc_filelist_f ${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${XDC_DIR}/${ALVEO_PART} ${CFG_FILE_NAME} "xdc" ${ALVEO_PART}
generate_xdc_filelist_f ${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${XDC_DIR}/${ALVEO_PART} ${CFG_FILE_NAME} "xdc" "top"

newtext=""
echo $newtext >> ${CFG_FILE_NAME}
rm_xdc_filelist_f ${CFG_FILE_NAME}