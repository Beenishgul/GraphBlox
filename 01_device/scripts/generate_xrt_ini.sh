#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_xrt_ini.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/"
  echo "  SCRIPTS_DIR: 00_GLay"
  echo "  KERNEL_NAME: glay_kernel"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3

CFG_FILE_NAME="${KERNEL_NAME}_xrt.ini"

debug_mode="batch"
user_pre_sim_script="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_cmd_xsim.tcl"

profile="true"
timeline_trace="true"
device_trace="coarse"

newtext="[Emulation]"
echo $newtext > ${CFG_FILE_NAME}

newtext="debug_mode=${debug_mode}"
echo $newtext >> ${CFG_FILE_NAME}

newtext="user_pre_sim_script=${user_pre_sim_script}"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="[Debug]"
echo $newtext >> ${CFG_FILE_NAME}

newtext="profile=${profile}"
echo $newtext >> ${CFG_FILE_NAME}

newtext="timeline_trace=${timeline_trace}"
echo $newtext >> ${CFG_FILE_NAME}

newtext="device_trace=${device_trace}"
echo $newtext >> ${CFG_FILE_NAME}

