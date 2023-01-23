#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_source_ip.sh ORIGINAL_IP_DIR ACTIVE_IP_DIR ctrl_mode"
  echo ""
  echo "  ORIGINAL_IP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/glay_ip"
  echo "  ACTIVE_IP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/glay_ip"
  echo "  ctrl_mode: USER_MANAGED"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ORIGINAL_IP_DIR=$1
ACTIVE_IP_DIR=$2
ctrl_mode=$3

glay_pkgs="pkg"
glay_engine="engine"
glay_kernel="kernel"
glay_top="top"
glay_cache="cache"
glay_kernel_testbench="testbench"
glay_control="control"
glay_utils="utils"

iob_include="iob_include"
portmaps="portmaps"


mkdir -p ${ACTIVE_IP_DIR}/${glay_pkgs}
mkdir -p ${ACTIVE_IP_DIR}/${glay_engine}
mkdir -p ${ACTIVE_IP_DIR}/${glay_kernel}
mkdir -p ${ACTIVE_IP_DIR}/${glay_top}
mkdir -p ${ACTIVE_IP_DIR}/${glay_cache}
mkdir -p ${ACTIVE_IP_DIR}/${glay_kernel_testbench}
mkdir -p ${ACTIVE_IP_DIR}/${glay_control}
mkdir -p ${ACTIVE_IP_DIR}/${glay_utils}


cp -r ${ORIGINAL_IP_DIR}/${glay_pkgs}/* ${ACTIVE_IP_DIR}/${glay_pkgs}
cp -r ${ORIGINAL_IP_DIR}/${glay_engine}/* ${ACTIVE_IP_DIR}/${glay_engine}
cp -r ${ORIGINAL_IP_DIR}/${glay_kernel}/* ${ACTIVE_IP_DIR}/${glay_kernel}
cp -r ${ORIGINAL_IP_DIR}/${glay_top}/* ${ACTIVE_IP_DIR}/${glay_top}
cp -r ${ORIGINAL_IP_DIR}/${glay_cache}/* ${ACTIVE_IP_DIR}/${glay_cache}
cp -r ${ORIGINAL_IP_DIR}/${glay_utils}/* ${ACTIVE_IP_DIR}/${glay_utils}
cp -r ${ORIGINAL_IP_DIR}/${glay_kernel_testbench}/* ${ACTIVE_IP_DIR}/${glay_kernel_testbench}


if [[ "$ctrl_mode" == "USER_MANAGED" ]]
then
   cp -r ${ORIGINAL_IP_DIR}/${glay_control}/glay_kernel_control_user_managed.sv ${ACTIVE_IP_DIR}/${glay_control}/glay_kernel_control.sv
elif [[ "$ctrl_mode" == "AP_CTRL_HS" ]]
then
   cp -r ${ORIGINAL_IP_DIR}/${glay_control}/glay_kernel_control_ap_ctrl_hs.sv ${ACTIVE_IP_DIR}/${glay_control}/glay_kernel_control.sv
elif [[ "$ctrl_mode" == "AP_CTRL_CHAIN" ]]
then
   cp -r ${ORIGINAL_IP_DIR}/${glay_control}/glay_kernel_control_ap_ctrl_chain.sv ${ACTIVE_IP_DIR}/${glay_control}/glay_kernel_control.sv
else
  echo "MSG: else |$ctrl_mode|"
   cp -r ${ORIGINAL_IP_DIR}/${glay_control}/glay_kernel_control_user_managed.sv ${ACTIVE_IP_DIR}/${glay_control}/glay_kernel_control.sv
fi