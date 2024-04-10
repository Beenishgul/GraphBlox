#!/bin/bash

# Function to print usage
print_usage() {
    cat <<EOF
Usage: generate_package_filelist_f.sh <params_sh_dir>
  <params_sh_dir>: Path to the parameters file.

Example:
  ./generate_package_filelist_f.sh /path/to/params.sh
EOF
}

# Exit if no arguments
if [[ $# -eq 0 ]]; then
    print_usage
    exit 1
fi

PARAMS_SH_DIR=$1

# Source the parameters file
if [ -f "${PARAMS_SH_DIR}" ]; then
    source "${PARAMS_SH_DIR}"
else
    echo "Parameters file does not exist: ${PARAMS_SH_DIR}"
    exit 1
fi

pkgs="pkg"
engines="engines"
kernel="kernel"
top="top"

memory="memory"
memory_cache="cache"
memory_sram="sram_axi"
memory_sram_include="include"

control="control"
bundle="bundle"
cu="cu"
lane="lane"

utils="utils"
utils_arbiter="arbiter"
utils_counter="counter"
utils_fifo="fifo"
utils_include="include"
utils_slice="slice"

iob_include="iob_include"
portmaps="portmaps"

# Initialize file names
CFG_FILE_NAME="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.src.f"
CFG_FILE_NAME_VH="${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.vh.f"

# Function to remove empty file lists
rm_package_filelist_f() {
    local filename=$1
    if [[ ! -s $filename ]]; then
        rm -f -- "${filename}"
    fi
}

# Function to generate file lists based on extension
generate_package_filelist_f() {
    local ip_directory=$1 cfg_filelist_name=$2 verilog_type=$3

    if [[ ! -d $ip_directory ]]; then
        echo "Directory does not exist: $ip_directory"
        return
    fi

    find "$ip_directory" -type f -iname "*.${verilog_type}" -print0 | sort -z | while IFS= read -r -d $'\0' filepath; do
        echo "$filepath" >> "$cfg_filelist_name"
    done
}

# Clear file lists
: > "$CFG_FILE_NAME"
: > "$CFG_FILE_NAME_VH"

# Configuration for directories and extensions
declare -A config=(
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${pkgs}/"]="sv"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_cache}/${iob_include}/"]="vh"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_cache}/"]="v"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_sram}/${memory_sram_include}/"]="svh"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${memory}/${memory_sram}/"]="sv"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${utils}/${utils_include}/"]="vh"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${bundle}/"]="sv"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${cu}/"]="sv"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${lane}/"]="sv"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${control}/"]="sv"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${kernel}/"]="sv"
    ["${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${top}/"]="v"
)

# Generate file lists based on configuration
for path in "${!config[@]}"; do
    extension="${config[$path]}"
    cfg_file="${CFG_FILE_NAME}"
    [[ "$extension" == "vh" || "$extension" == "svh" ]] && cfg_file="${CFG_FILE_NAME_VH}"
    generate_package_filelist_f "$path" "$cfg_file" "$extension"
done

# Engine directories to process
declare -a engine_dirs=(
    "engine_alu_ops"
    "engine_csr_index"
    "engine_cu_setup"
    "engine_filter_cond"
    "engine_forward_data"
    "engine_merge_data"
    "engine_set_ops"
    "engine_pipeline"
    "engine_read_write"
    "engine_m_axi"
    "engine_template"
    "engine_automata_nfa"
)

# Process each engine directory
for engine_dir in "${engine_dirs[@]}"; do
    path="${APP_DIR_ACTIVE}/${IP_DIR_RTL_ACTIVE}/${engines}/${engine_dir}"
    generate_package_filelist_f "$path" "$CFG_FILE_NAME" "sv"
    generate_package_filelist_f "$path" "$CFG_FILE_NAME" "vh"
    generate_package_filelist_f "$path" "$CFG_FILE_NAME" "v"
done

# Remove package file list if empty
rm_package_filelist_f "$CFG_FILE_NAME"
rm_package_filelist_f "$CFG_FILE_NAME_VH"
