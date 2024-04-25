# @Author: Abdullah
# @Date:   2023-04-06 18:46:46
# @Last Modified by:   Abdullah
# @Last Modified time: 2024-04-25 00:45:16
#!/bin/bash


print_usage () {
    echo "Usage: "
    echo "  generate_xdc_filelist_f.sh APP_DIR_ACTIVE UTILS_DIR_ACTIVE KERNEL_NAME IP_DIR VIP_DIR"
    echo ""
    echo "  APP_DIR_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GraphBlox/01_Device"
    echo "  UTILS_DIR_ACTIVE: utils"
    echo "  KERNEL_NAME: kernel"
    echo "  ALVEO_PART: U250"
    echo "  UTILS_XDC:  utils.xdc"
    echo ""
}
if [ "$1" = "" ]
then
    print_usage
fi

# APP_DIR_ACTIVE=$1
# UTILS_DIR_ACTIVE=$2
# KERNEL_NAME=$3
# ALVEO_PART=$4
# UTILS_XDC=$5

PARAMS_SH_DIR=$1

source ${PARAMS_SH_DIR}

CFG_FILE_NAME="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.xdc.f"

rm_xdc_filelist_f () {

    local filename=$1

    if [[ -z $(grep '[^[:space:]]' $filename ) ]] ; then
        rm ${filename}
    fi
}

generate_xdc_filelist_f () {

    local script_directory=$1
    local cfg_filelist_name=$2
    local xdc_type=$3
    local alveo_part=$4
    local temp_filepath=${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_XDC}/${ALVEO_PART}/${alveo_part}.${xdc_type}

    for filepath in "$( find ${script_directory} -type f -iname "*${alveo_part}.${xdc_type}" | sort -n )" ; do
        newtext="${filepath}"
        if [[ "$newtext" == "$temp_filepath" ]]; then
            echo "$newtext" >> ${cfg_filelist_name}
        fi
    done

}

newtext=""
echo "$newtext" > ${CFG_FILE_NAME}

generate_xdc_filelist_f ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_XDC}/${ALVEO_PART} ${CFG_FILE_NAME} "xdc" ${ALVEO_PART}
generate_xdc_filelist_f ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${UTILS_XDC}/${ALVEO_PART} ${CFG_FILE_NAME} "xdc" "top"

newtext=""
echo $newtext >> ${CFG_FILE_NAME}
rm_xdc_filelist_f ${CFG_FILE_NAME}