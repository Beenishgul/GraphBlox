#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_xrt_ini.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  SCRIPTS_DIR: scripts"
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

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_xrt.ini"

debug_mode="batch"
# debug_mode="gui"
user_pre_sim_script="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/cmd_xsim.tcl"
runtime_log="console"

profile="true"
timeline_trace="true"
device_trace="coarse"
exclusive_cu_context="true"

config="[Runtime]\n"
config+="exclusive_cu_context=${exclusive_cu_context}\n"

config+="\n[Emulation]\n"
config+="debug_mode=${debug_mode}\n"
config+="user_pre_sim_script=${user_pre_sim_script}\n"

config+="\n[Debug]\n"
config+="profile=${profile}\n"
config+="timeline_trace=${timeline_trace}\n"
config+="device_trace=${device_trace}\n"

echo -e "${config}" >> ${CFG_FILE_NAME}