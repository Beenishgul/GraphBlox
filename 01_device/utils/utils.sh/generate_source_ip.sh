#!/bin/bash

print_usage () {
  echo "Usage: "
  echo "  generate_source_ip.sh SOURCE_IP_DIR ACTIVE_IP_DIR XILINX_CTRL_MODE"
  echo ""
  echo "  SOURCE_IP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/ip"
  echo "  ACTIVE_IP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/ip"
  echo "  XILINX_CTRL_MODE: USER_MANAGED"
  echo "  TESTBENCH_MODULE : glay|arbiter"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

SOURCE_IP_DIR=$1
ACTIVE_IP_DIR=$2
XILINX_CTRL_MODE=$3
TESTBENCH_MODULE=$4
GRAPH_DIR=$5
GRAPH_SUIT=$6
GRAPH_NAME=$7

pkgs="pkg"
engines="engines"
kernel="kernel"
top="top"

memory="memory"
cache="cache"
generator="generator"

testbench="testbench"
control="control"
bundle="bundle"
cu="cu"
lane="lane"

utils="utils"

iob_include="iob_include"
portmaps="portmaps"


mkdir -p ${ACTIVE_IP_DIR}/${pkgs}
mkdir -p ${ACTIVE_IP_DIR}/${engines}
mkdir -p ${ACTIVE_IP_DIR}/${kernel}
mkdir -p ${ACTIVE_IP_DIR}/${top}
mkdir -p ${ACTIVE_IP_DIR}/${memory}
mkdir -p ${ACTIVE_IP_DIR}/${testbench}/${TESTBENCH_MODULE}
mkdir -p ${ACTIVE_IP_DIR}/${control}
mkdir -p ${ACTIVE_IP_DIR}/${bundle}
mkdir -p ${ACTIVE_IP_DIR}/${cu}
mkdir -p ${ACTIVE_IP_DIR}/${lane}
mkdir -p ${ACTIVE_IP_DIR}/${utils}


cp -r -u ${SOURCE_IP_DIR}/${pkgs}/* ${ACTIVE_IP_DIR}/${pkgs}
cp -r -u ${SOURCE_IP_DIR}/${engines}/* ${ACTIVE_IP_DIR}/${engines}
cp -r -u ${SOURCE_IP_DIR}/${kernel}/* ${ACTIVE_IP_DIR}/${kernel}
cp -r -u ${SOURCE_IP_DIR}/${top}/* ${ACTIVE_IP_DIR}/${top}
cp -r -u ${SOURCE_IP_DIR}/${memory}/* ${ACTIVE_IP_DIR}/${memory}
cp -r -u ${SOURCE_IP_DIR}/${bundle}/* ${ACTIVE_IP_DIR}/${bundle}
cp -r -u ${SOURCE_IP_DIR}/${cu}/* ${ACTIVE_IP_DIR}/${cu}
cp -r -u ${SOURCE_IP_DIR}/${lane}/* ${ACTIVE_IP_DIR}/${lane}
cp -r -u ${SOURCE_IP_DIR}/${utils}/* ${ACTIVE_IP_DIR}/${utils}
cp -r -u ${SOURCE_IP_DIR}/${testbench}/${TESTBENCH_MODULE}/* ${ACTIVE_IP_DIR}/${testbench}/${TESTBENCH_MODULE}


if [[ "$XILINX_CTRL_MODE" == "USER_MANAGED" ]]
then
 cp -r -u ${SOURCE_IP_DIR}/${control}/kernel_control_user_managed.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
elif [[ "$XILINX_CTRL_MODE" == "AP_CTRL_HS" ]]
  then
   cp -r -u ${SOURCE_IP_DIR}/${control}/kernel_control_ap_ctrl_hs.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
 elif [[ "$XILINX_CTRL_MODE" == "AP_CTRL_CHAIN" ]]
  then
   cp -r -u ${SOURCE_IP_DIR}/${control}/kernel_control_ap_ctrl_chain.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
 else
  echo "MSG: else |$XILINX_CTRL_MODE|"
  cp -r -u ${SOURCE_IP_DIR}/${control}/kernel_control_user_managed.sv ${ACTIVE_IP_DIR}/${control}/kernel_control.sv
fi

# Copy testbench rename auto generated AXI modules (default kernel) to kenrel_name
if [[ "$TESTBENCH_MODULE" == "integration" ]]
then
  newtext="${ACTIVE_IP_DIR}/${testbench}/${TESTBENCH_MODULE}/testbench.sv"
  search="__KERNEL__"
  replace=${KERNEL_NAME}
  if [[ $search != "" && $replace != "" ]]; then
    sed -i "s/$search/$replace/" $newtext
  fi

  search="_GRAPH_DIR_"
  replace=${GRAPH_DIR}
  if [[ $search != "" && $replace != "" ]]; then
    sed -i "s@$search@$replace@" $newtext
  fi

  search="_GRAPH_SUIT_"
  replace=${GRAPH_SUIT}
  if [[ $search != "" && $replace != "" ]]; then
    sed -i "s/$search/$replace/" $newtext
  fi

  search="_GRAPH_NAME_"
  replace=${GRAPH_NAME}
  if [[ $search != "" && $replace != "" ]]; then
    sed -i "s/$search/$replace/" $newtext
  fi
fi
