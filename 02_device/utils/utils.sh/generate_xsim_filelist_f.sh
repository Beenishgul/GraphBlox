#!/bin/bash


print_usage () {
    echo "Usage: "
    echo "  generate_xsim_filelist_f.sh APP_DIR_ACTIVE UTILS_DIR_ACTIVE KERNEL_NAME IP_DIR_RTL_ACTIVE"
    echo ""
    echo "  APP_DIR_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
    echo "  UTILS_DIR_ACTIVE: utils"
    echo "  KERNEL_NAME: kernel"
    echo "  IP_DIR_RTL_ACTIVE : IP"
    echo "  VIVADO_VIP_DIR: vivado_generated_vip"
    echo "  TESTBENCH_MODULE : glay|unit"
    echo ""
}
if [ "$1" = "" ]
then
    print_usage
fi

# APP_DIR_ACTIVE=$1
# UTILS_DIR_ACTIVE=$2
# KERNEL_NAME=$3
# IP_DIR_RTL_ACTIVE=$4
# VIVADO_VIP_DIR=$5
# TESTBENCH_MODULE=$6

PARAMS_SH_DIR=$1

source ${PARAMS_SH_DIR}

pkgs="pkg"

engine_alu_ops="engine_alu_ops"
engine_csr_index="engine_csr_index"
engine_cu_setup="engine_cu_setup"
engine_filter_cond="engine_filter_cond"
engine_forward_data="engine_forward_data"
engine_m_axi="engine_m_axi"
engine_merge_data="engine_merge_data"
engine_pipeline="engine_pipeline"
engine_read_write="engine_read_write"
engine_template="engine_template"
engines="engines"

kernel="kernel"
top="top"
testbench="testbench"

memory="memory"
memory_cache="cache"
memory_generator="generator"
memory_ram="ram"

control="control"
bundle="bundle"
cu="cu"
lane="lane"

utils="utils"
utils_arbiter="arbiter"
utils_fifo="fifo"
utils_counter="counter"
utils_include="include"

iob_include="iob_include"
portmaps="portmaps"


CFG_FILE_NAME_SV="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.sv.f"
CFG_FILE_NAME_VHDL="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.vhdl.f"
CFG_FILE_NAME_V="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.v.f"

CFG_FILE_NAME_IP_SV="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.sv.f"
CFG_FILE_NAME_IP_VHDL="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.vhdl.f"
CFG_FILE_NAME_IP_V="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.v.f"

CFG_FILE_NAME_VH="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.vh.f"


rm_xsim_filelist_f () {

    local filename=$1

    if [[ -z $(grep '[^[:space:]]' $filename ) ]] ; then
        rm ${filename}
    fi
}

generate_xsim_filelist_f () {

    local ip_directory=$1
    local cfg_filelist_name=$2
    local verilog_type=$3

    for filepath in "$( find ${ip_directory} -type f -iname "*.${verilog_type}" | sort -n )" ; do
        newtext="${filepath}"
        echo "$newtext" >> ${cfg_filelist_name}
    done

}

generate_xsim_dirlist_f () {

    local ip_directory=$1
    local cfg_filelist_name=$2
    local verilog_type=$3
    local ip_directory=""
    for filepath in $( find ${ip_directory} -type f -iname "*.${verilog_type}" | sort -n ) ; do
        ip_directory="$(dirname  $(readlink -f "${filepath}"))"
        newtext="${ip_directory}"
        echo "$newtext" >> ${cfg_filelist_name}
    done

}

newtext=""
echo $newtext > ${CFG_FILE_NAME_SV}
echo $newtext > ${CFG_FILE_NAME_VHDL}
echo $newtext > ${CFG_FILE_NAME_VH}

echo $newtext > ${CFG_FILE_NAME_IP_SV}
echo $newtext > ${CFG_FILE_NAME_IP_VHDL}
echo $newtext > ${CFG_FILE_NAME_IP_V}

echo $newtext > ${CFG_FILE_NAME_V}

# Add include ip_directory
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_cache}/${iob_include}/ ${CFG_FILE_NAME_VH} "vh"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_include}/ ${CFG_FILE_NAME_VH} "vh"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${pkgs}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_arbiter}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_counter}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_fifo}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_ram}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_cache}/ ${CFG_FILE_NAME_V} "v"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_generator}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${bundle}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${cu}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${lane}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${control}/ ${CFG_FILE_NAME_SV} "sv"

# generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_alu_ops}      ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_csr_index}    ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_cu_setup}     ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_filter_cond}  ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_forward_data} ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_m_axi}        ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_merge_data}   ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_pipeline}     ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_read_write}   ${CFG_FILE_NAME_SV} "sv"
generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_template}     ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${kernel}/ ${CFG_FILE_NAME_SV} "sv"

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${top}/ ${CFG_FILE_NAME_V} "v"

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/control_${KERNEL_NAME}_vip/sim/control_${KERNEL_NAME}_vip_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME_IP_SV}

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/control_${KERNEL_NAME}_vip/sim/control_${KERNEL_NAME}_vip.sv"
echo $newtext >> ${CFG_FILE_NAME_IP_SV}

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/control_${KERNEL_NAME}_vip/hdl/axi_vip_v1_1_vl_rfs.sv"
echo $newtext >> ${CFG_FILE_NAME_IP_SV}

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/control_${KERNEL_NAME}_vip/hdl/axi_infrastructure_v1_1_vl_rfs.v"
echo $newtext >> ${CFG_FILE_NAME_IP_V}

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/slv_m00_axi_vip/sim/slv_m00_axi_vip_pkg.sv"
echo $newtext >> ${CFG_FILE_NAME_IP_SV}

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/slv_m00_axi_vip/sim/slv_m00_axi_vip.sv"
echo $newtext >> ${CFG_FILE_NAME_IP_SV}

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/system_cache_512x64/hdl/system_cache_v5_0_vh_rfs.vhd"
echo $newtext >> ${CFG_FILE_NAME_IP_VHDL}

newtext="${APP_DIR_ACTIVE}/${VIVADO_VIP_DIR}/${KERNEL_NAME}/${KERNEL_NAME}.gen/sources_1/ip/system_cache_512x64/sim/system_cache_512x64.vhd"
echo $newtext >> ${CFG_FILE_NAME_IP_VHDL}

generate_xsim_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${testbench}/${TESTBENCH_MODULE}/ ${CFG_FILE_NAME_SV} "sv"

newtext="${XILINX_VIVADO}/data/verilog/src/glbl.v"
echo $newtext >> ${CFG_FILE_NAME_IP_V}

newtext=""
echo $newtext >> ${CFG_FILE_NAME_SV}
echo $newtext >> ${CFG_FILE_NAME_VHDL}
echo $newtext >> ${CFG_FILE_NAME_V}

echo $newtext >> ${CFG_FILE_NAME_IP_SV}
echo $newtext >> ${CFG_FILE_NAME_IP_VHDL}
echo $newtext >> ${CFG_FILE_NAME_IP_V}

echo $newtext >> ${CFG_FILE_NAME_VH}

rm_xsim_filelist_f ${CFG_FILE_NAME_SV}
rm_xsim_filelist_f ${CFG_FILE_NAME_VHDL}
rm_xsim_filelist_f ${CFG_FILE_NAME_V}

rm_xsim_filelist_f ${CFG_FILE_NAME_IP_SV}
rm_xsim_filelist_f ${CFG_FILE_NAME_IP_VHDL}
rm_xsim_filelist_f ${CFG_FILE_NAME_IP_V}

rm_xsim_filelist_f ${CFG_FILE_NAME_VH}
