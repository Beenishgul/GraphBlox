#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_source_ip.sh ORIGINAL_IP_DIR ACTIVE_IP_DIR CTRL_MODE"
  echo ""
  echo "  ORIGINAL_IP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/ip"
  echo "  ACTIVE_IP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/ip"
  echo "  CTRL_MODE: USER_MANAGED"
  echo "  MODULE : glay|arbiter"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ORIGINAL_IP_DIR=$1
ACTIVE_IP_DIR=$2
CTRL_MODE=$3
MODULE=$4


pkgs="pkg"
engine="engine"
kernel="kernel"
top="top"

memory="memory"
cache="cache"
generator="generator"

testbench="testbench"
control="control"
vertex="vertex"
utils="utils"

iob_include="iob_include"
portmaps="portmaps"


mkdir -p ${ACTIVE_IP_DIR}/${pkgs}
mkdir -p ${ACTIVE_IP_DIR}/${engine}
mkdir -p ${ACTIVE_IP_DIR}/${kernel}
mkdir -p ${ACTIVE_IP_DIR}/${top}
mkdir -p ${ACTIVE_IP_DIR}/${memory}
mkdir -p ${ACTIVE_IP_DIR}/${testbench}/${MODULE}
mkdir -p ${ACTIVE_IP_DIR}/${control}
mkdir -p ${ACTIVE_IP_DIR}/${vertex}
mkdir -p ${ACTIVE_IP_DIR}/${utils}


cp -r ${ORIGINAL_IP_DIR}/${pkgs}/* ${ACTIVE_IP_DIR}/${pkgs}
cp -r ${ORIGINAL_IP_DIR}/${engine}/* ${ACTIVE_IP_DIR}/${engine}
cp -r ${ORIGINAL_IP_DIR}/${kernel}/* ${ACTIVE_IP_DIR}/${kernel}
cp -r ${ORIGINAL_IP_DIR}/${top}/* ${ACTIVE_IP_DIR}/${top}
cp -r ${ORIGINAL_IP_DIR}/${memory}/* ${ACTIVE_IP_DIR}/${memory}
cp -r ${ORIGINAL_IP_DIR}/${vertex}/* ${ACTIVE_IP_DIR}/${vertex}
cp -r ${ORIGINAL_IP_DIR}/${utils}/* ${ACTIVE_IP_DIR}/${utils}
cp -r ${ORIGINAL_IP_DIR}/${testbench}/${MODULE}/* ${ACTIVE_IP_DIR}/${testbench}/${MODULE}


if [[ "$CTRL_MODE" == "USER_MANAGED" ]]
then
 cp -r ${ORIGINAL_IP_DIR}/${control}/kernel_control_user_managed.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
elif [[ "$CTRL_MODE" == "AP_CTRL_HS" ]]
  then
   cp -r ${ORIGINAL_IP_DIR}/${control}/kernel_control_ap_ctrl_hs.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
 elif [[ "$CTRL_MODE" == "AP_CTRL_CHAIN" ]]
  then
   cp -r ${ORIGINAL_IP_DIR}/${control}/kernel_control_ap_ctrl_chain.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
 else
  echo "MSG: else |$CTRL_MODE|"
  cp -r ${ORIGINAL_IP_DIR}/${control}/kernel_control_user_managed.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
fi

# Copy testbench rename auto generated AXI modules (default kernel) to kenrel_name
if [[ "$MODULE" == "glay" ]]
then
  newtext="${ACTIVE_IP_DIR}/${testbench}/${MODULE}/testbench.sv"
  search="kernel"
  replace=${KERNEL_NAME}
  if [[ $search != "" && $replace != "" ]]; then
    sed -i "s/$search/$replace/" $newtext
  fi
fi
