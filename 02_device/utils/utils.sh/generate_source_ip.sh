#!/bin/bash

print_usage () {
    echo "Usage: "
    echo "  generate_source_ip.sh FULL_SRC_IP_DIR_RTL FULL_SRC_IP_DIR_RTL_ACTIVE XILINX_CTRL_MODE"
    echo ""
    echo "  FULL_SRC_IP_DIR_RTL: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/ip"
    echo "  FULL_SRC_IP_DIR_RTL_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device/ip"
    echo "  XILINX_CTRL_MODE: USER_MANAGED"
    echo "  TESTBENCH_MODULE : glay|arbiter"
    echo ""
}
if [ "$1" = "" ]
then
    print_usage
fi

# FULL_SRC_IP_DIR_RTL=$1
# FULL_SRC_IP_DIR_RTL_ACTIVE=$2
# XILINX_CTRL_MODE=$3
# TESTBENCH_MODULE=$4
# GRAPH_DIR=$5
# GRAPH_SUIT=$6
# GRAPH_NAME=$7

PARAMS_SH_DIR=$1

source ${PARAMS_SH_DIR}

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


mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${pkgs}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${engines}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${kernel}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${top}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${memory}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${testbench}/${TESTBENCH_MODULE}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${control}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${bundle}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${cu}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${lane}
mkdir -p ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${utils}


cp -r -u ${FULL_SRC_IP_DIR_RTL}/${pkgs}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${pkgs}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${engines}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${engines}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${kernel}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${kernel}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${top}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${top}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${memory}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${memory}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${bundle}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${bundle}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${cu}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${cu}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${lane}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${lane}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${utils}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${utils}
cp -r -u ${FULL_SRC_IP_DIR_RTL}/${testbench}/${TESTBENCH_MODULE}/* ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${testbench}/${TESTBENCH_MODULE}


if [[ "$XILINX_CTRL_MODE" == "USER_MANAGED" ]]
then
    cp -r -u ${FULL_SRC_IP_DIR_RTL}/${control}/kernel_control_user_managed.sv ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${control}/kernel_control.sv
elif [[ "$XILINX_CTRL_MODE" == "AP_CTRL_HS" ]]
then
    cp -r -u ${FULL_SRC_IP_DIR_RTL}/${control}/kernel_control_ap_ctrl_hs.sv ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${control}/kernel_control.sv
elif [[ "$XILINX_CTRL_MODE" == "AP_CTRL_CHAIN" ]]
then
    cp -r -u ${FULL_SRC_IP_DIR_RTL}/${control}/kernel_control_ap_ctrl_chain.sv ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${control}/kernel_control.sv
else
    echo "MSG: else |$XILINX_CTRL_MODE|"
    cp -r -u ${FULL_SRC_IP_DIR_RTL}/${control}/kernel_control_user_managed.sv ${FULL_SRC_IP_DIR_RTL_ACTIVE}/${control}/kernel_control.sv
fi

# Copy testbench rename auto generated AXI modules (default kernel) to kenrel_name
if [[ "$TESTBENCH_MODULE" == "integration" ]]
then
    newtext="${FULL_SRC_IP_DIR_RTL_ACTIVE}/${testbench}/${TESTBENCH_MODULE}/testbench.sv"
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
