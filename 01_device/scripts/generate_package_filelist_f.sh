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

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/iob-cache.vh"
echo $newtext > ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/iob_lib.vh"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/${portmaps}/m_axi_m_read_port.vh"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/${portmaps}/m_axi_m_write_port.vh"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/${portmaps}/m_axi_portmap.vh"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/${portmaps}/m_axi_read_portmap.vh"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${iob_cache}/${iob_include}/${portmaps}/m_axi_write_portmap.vh"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_pkgs}/glay_globals_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME}

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

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel}/glay_kernel_afu.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_kernel}/glay_kernel_cu.sv"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_top}/glay_top_control_s_axi.v"
echo $newtext >> ${CFG_FILE_NAME}

newtext="${ACTIVE_APP_DIR}/${IP_DIR}/${glay_top}/glay_top.v"
echo $newtext >> ${CFG_FILE_NAME}