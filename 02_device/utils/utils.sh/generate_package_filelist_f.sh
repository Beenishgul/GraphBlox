# @Author: Abdullah
# @Date:   2023-04-06 18:46:46
# @Last Modified by:   Abdullah
# @Last Modified time: 2023-07-11 20:14:01
#!/bin/bash


print_usage () {
    echo "Usage: "
    echo "  generate_package_filelist_f.sh APP_DIR_ACTIVE UTILS_DIR_ACTIVE KERNEL_NAME IP_DIR_RTL_ACTIVE VIVADO_VIP_DIR"
    echo ""
    echo "  APP_DIR_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GLay/01_Device"
    echo "  UTILS_DIR_ACTIVE: utils"
    echo "  KERNEL_NAME: kernel"
    echo "  IP_DIR_RTL_ACTIVE: IP"
    echo "  VIVADO_VIP_DIR: vivado_generated_vip"
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

PARAMS_SH_DIR=$1

source ${PARAMS_SH_DIR}

pkgs="pkg"

engines="engines"
engine_template="engine_template"
engine_cu_setup="engine_cu_setup"
engine_alu_operations="engine_alu_operations"
engine_conditional="engine_conditional"
engine_read_write="engine_read_write"
engine_stride_index="engine_stride_index"
engine_csr_index="engine_csr_index"
engine_write="engine_write"
engine_pipeline="engine_pipeline"

kernel="kernel"
top="top"

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
utils_counter="counter"
utils_fifo="fifo"
utils_include="include"

iob_include="iob_include"
portmaps="portmaps"

CFG_FILE_NAME="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.src.f"
CFG_FILE_NAME_VH="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.vh.f"

rm_package_filelist_f () {

    local filename=$1

    if [[ -z $(grep '[^[:space:]]' $filename ) ]] ; then
        rm ${filename}
    fi
}

generate_package_filelist_f () {

    local ip_directory=$1
    local cfg_filelist_name=$2
    local verilog_type=$3

    for filepath in "$( find ${ip_directory} -type f -iname "*.${verilog_type}" | sort -n )" ; do
        newtext="${filepath}"
        echo "$newtext" >> ${cfg_filelist_name}
    done

}

newtext=""
echo "$newtext" > ${CFG_FILE_NAME}
echo "$newtext" > ${CFG_FILE_NAME_VH}

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${pkgs}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_cache}/${iob_include}/ ${CFG_FILE_NAME_VH} "vh"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_ram}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_cache}/ ${CFG_FILE_NAME} "v"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_generator}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_include}/ ${CFG_FILE_NAME_VH} "vh"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_arbiter}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_counter}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_fifo}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${bundle}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${cu}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${lane}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${control}/ ${CFG_FILE_NAME} "sv"

# generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/ ${CFG_FILE_NAME} "sv"
generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_cu_setup} ${CFG_FILE_NAME} "sv"
generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_template} ${CFG_FILE_NAME} "sv"
generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_pipeline} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_stride_index} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_csr_index} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_read_write} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_write} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_alu_operations} ${CFG_FILE_NAME} "sv"
# generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_conditional} ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${kernel}/ ${CFG_FILE_NAME} "sv"

generate_package_filelist_f ${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${top}/ ${CFG_FILE_NAME} "v"

newtext=""
echo $newtext >> ${CFG_FILE_NAME}
echo $newtext >> ${CFG_FILE_NAME_VH}

rm_package_filelist_f ${CFG_FILE_NAME}
rm_package_filelist_f ${CFG_FILE_NAME_VH}
