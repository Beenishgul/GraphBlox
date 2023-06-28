#!/bin/bash

print_usage () {
  echo "Usage: "
  echo "  generate_xrt_ini.sh APP_DIR_ACTIVE UTILS_DIR_ACTIVE KERNEL_NAME XILINX_CTRL_MODE"
  echo ""
  echo "  APP_DIR_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
  echo "  UTILS_DIR_ACTIVE: scripts"
  echo "  KERNEL_NAME: kernel"
  echo "  XILINX_CTRL_MODE  : USER_MANAGED"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

# APP_DIR_ACTIVE=$1
# UTILS_DIR_ACTIVE=$2
# KERNEL_NAME=$3
# XILINX_CTRL_MODE=$4
# UTILS_TCL=$5

PARAMS_SH_DIR=$1

source ${PARAMS_SH_DIR}

CFG_FILE_NAME="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_xrt.ini"

debug_mode="batch"
# debug_mode="gui"
user_pre_sim_script="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_TCL}/cmd_xsim.tcl"
runtime_log="console"

profile="true"
timeline_trace="true"
device_trace="coarse"


config="[Emulation]\n"
config+="debug_mode=${debug_mode}\n"
config+="user_pre_sim_script=${user_pre_sim_script}\n"

config+="\n[Debug]\n"
config+="profile=${profile}\n"
config+="timeline_trace=${timeline_trace}\n"
config+="device_trace=${device_trace}\n"

if [[ "$XILINX_CTRL_MODE" == "USER_MANAGED" ]]
then
   config+="\n[Runtime]\n"
   config+="exclusive_cu_context=true\n"
fi


echo -e "${config}" > ${CFG_FILE_NAME}