#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_xsim_filelist_f.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME IP_DIR"
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
glay_kernel_testbench="glay_kernel_testbench"

iob_cache="iob_cache"
iob_include="iob_include"
portmaps="portmaps"


CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_filelist_xsim.f"

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_pkgs}/glay_globals_pkg.sv"
echo $newtext > ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_pkgs}/glay_axi4_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_pkgs}/glay_descriptor_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_pkgs}/glay_control_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel}/glay_kernel_control.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel}/glay_kernel_cu.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel}/glay_kernel_afu.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_top}/glay_top_control_s_axi.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_top}/glay_top.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${KERNEL_NAME}_vip_generation/control_${KERNEL_NAME}_vip/sim/control_${KERNEL_NAME}_vip_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${KERNEL_NAME}_vip_generation/control_${KERNEL_NAME}_vip/sim/control_${KERNEL_NAME}_vip.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${KERNEL_NAME}_vip_generation/control_${KERNEL_NAME}_vip/hdl/axi_vip_v1_1_vl_rfs.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${KERNEL_NAME}_vip_generation/control_${KERNEL_NAME}_vip/hdl/axi_infrastructure_v1_1_vl_rfs.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${KERNEL_NAME}_vip_generation/slv_m00_axi_vip/sim/slv_m00_axi_vip_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${KERNEL_NAME}_vip_generation/slv_m00_axi_vip/sim/slv_m00_axi_vip.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel_testbench}/testbench.sv"
newtext_cp="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel_testbench}/${KERNEL_NAME}_testbench.sv"
cp ${newtext} ${newtext_cp}
cp ${newtext} ${newtext_cp}.bkp
search="glay_kernel"
replace=${KERNEL_NAME}
if [[ $search != "" && $replace != "" ]]; then
sed -i "s/$search/$replace/" $newtext_cp
fi
echo $newtext_cp >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${XILINX_VIVADO}/data/verilog/src/glbl.v"
echo $newtext >> ${CFG_FILE_NAME}
