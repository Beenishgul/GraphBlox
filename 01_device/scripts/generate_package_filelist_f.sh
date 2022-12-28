#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_package_filelist_f.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME IP_DIR"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  SCRIPTS_DIR: scripts"
  echo "  KERNEL_NAME: glay_kernel"
  echo "  IP_DIR: IP"
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

glay_pkgs="glay_pkgs"
glay_kernel="glay_kernel"
glay_top="glay_top"

iob_cache="iob_cache"
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

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/ ${CFG_FILE_NAME} "vh"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_pkgs}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/ ${CFG_FILE_NAME} "v"  

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${ACTIVE_APP_DIR}/${IP_DIR}/${glay_top}/ ${CFG_FILE_NAME} "v"
