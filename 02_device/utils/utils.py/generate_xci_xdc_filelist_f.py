#!/usr/bin/env python3

import os
import glob
import json


def print_usage():
    usage_text = """
Usage: generate_package_filelist_f.py <params_sh_dir>
  <params_sh_dir>: Path to the parameters file.

Example:
  python generate_package_filelist_f.py /path/to/params.sh
"""
    print(usage_text)


def remove_empty_file_lists(filename):
    if os.path.exists(filename) and os.path.getsize(filename) == 0:
        os.remove(filename)


def generate_package_filelist(
    ip_directory, cfg_filelist_name, file_extension, additional_filter=None
):
    if not os.path.isdir(ip_directory):
        print(f"Directory does not exist: {ip_directory}")
        return

    pattern = f"**/*.{file_extension}"  # Pattern to match files of specific extension in all subdirectories
    with open(cfg_filelist_name, "a") as cfg_file:
        for filepath in sorted(
            glob.glob(os.path.join(ip_directory, pattern), recursive=True)
        ):
            if additional_filter and additional_filter not in filepath:
                continue
            cfg_file.write(filepath + "\n")


def load_params_from_bash(params_file_path):
    params = {}
    with open(params_file_path, "r") as file:
        for line in file:
            line = line.strip()
            # Ignore comments and empty lines
            if line.startswith("#") or not line:
                continue
            # Split on the first '=' to separate key and value
            key_value = line.split("=", 1)
            if len(key_value) == 2:
                key, value = key_value
                key = key.strip()
                value = value.strip()
                # Try to convert numerical values
                if value.isdigit():
                    value = int(value)
                elif value.replace(".", "", 1).isdigit():
                    value = float(value)
                # Handle strings, assuming they do not contain spaces
                else:
                    # Remove possible Bash export command
                    key = key.replace("export ", "")
                    # Assuming the values are not enclosed in quotes in the Bash script
                    # If they are, you might need to strip them: value = value.strip('\'"')
                params[key] = value
    return params


def main(params_sh_dir):
    if not os.path.isfile(params_sh_dir):
        print(f"Parameters file does not exist: {params_sh_dir}")
        return

    params = load_params_from_bash(params_sh_dir)

    app_dir_active = params.get("APP_DIR_ACTIVE")
    app_vip_active = params.get("VIVADO_VIP_DIR")
    utils_dir_active = params.get("UTILS_DIR_ACTIVE")
    kernel_name = params.get("KERNEL_NAME")
    alveo_part = params.get("ALVEO")
    utils_xdc = params.get("UTILS_XDC")

    print(f"app_dir_active: {app_dir_active}")
    print(f"utils_dir_active: {utils_dir_active}")
    print(f"kernel_name: {kernel_name}")
    print(f"alveo_part: {alveo_part}")
    print(f"utils_xdc: {utils_xdc}")

    cfg_file_name_xdc = os.path.join(
        app_dir_active, utils_dir_active, f"{kernel_name}_filelist_package.xdc.f"
    )
    cfg_file_name_xci = os.path.join(
        app_dir_active, utils_dir_active, f"{kernel_name}_filelist_package.xci.f"
    )

    # Clear or create cfg files
    open(cfg_file_name_xdc, "w").close()
    open(cfg_file_name_xci, "w").close()

    # Generate file lists
    generate_package_filelist(
        os.path.join(
            app_dir_active, app_vip_active, kernel_name, kernel_name + ".srcs/sources_1/ip/"
        ),
        cfg_file_name_xci,
        "xci",
    )
    generate_package_filelist(
        os.path.join(
            app_dir_active, app_vip_active, kernel_name, kernel_name + ".gen/sources_1/ip/"
        ),
        cfg_file_name_xdc,
        "xdc",
    )

    # generate_package_filelist(
    #     os.path.join(app_dir_active, utils_dir_active, utils_xdc, alveo_part),
    #     cfg_file_name_xdc,
    #     "xdc",
    #     alveo_part,
    # )

    # Remove empty file lists
    remove_empty_file_lists(cfg_file_name_xdc)
    remove_empty_file_lists(cfg_file_name_xci)


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 2:
        print_usage()
    else:
        main(sys.argv[1])
