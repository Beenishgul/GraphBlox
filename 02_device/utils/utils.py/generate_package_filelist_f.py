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


def generate_package_filelist(ip_directory, cfg_filelist_name, verilog_type):
    if not os.path.isdir(ip_directory):
        print(f"Directory does not exist: {ip_directory}")
        return

    pattern = f"**/*.{verilog_type}"  # Pattern to match files of verilog_type in all subdirectories
    with open(cfg_filelist_name, "a") as cfg_file:
        # The recursive=True allows searching subdirectories
        for filepath in sorted(
            glob.glob(os.path.join(ip_directory, pattern), recursive=True)
        ):
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

    # Assuming params_sh_dir is a Python file with variables defined
    params = load_params_from_bash(params_sh_dir)

    # print(params)

    app_dir_active = params["APP_DIR_ACTIVE"]
    utils_dir_active = params["UTILS_DIR_ACTIVE"]
    kernel_name = params["KERNEL_NAME"]
    ip_dir_rtl_active = params["IP_DIR_RTL_ACTIVE"]
    target = params["TARGET"]

    bundle = "bundle"
    control = "control"
    cu = "cu"
    engines = "engines"
    iob_include = "iob_include"
    kernel = "kernel"
    lane = "lane"
    memory = "memory"
    memory_cache = "cache"
    memory_sram = "sram_axi"
    memory_sram_include = "include"
    pkgs = "pkg"
    portmaps = "portmaps"
    top = "top"
    utils = "utils"
    utils_arbiter = "arbiter"
    utils_counter = "counter"
    utils_fifo = "fifo"
    utils_include = "include"
    utils_slice = "slice"

    cfg_file_name = os.path.join(
        app_dir_active, utils_dir_active, f"{kernel_name}_filelist_package.src.f"
    )
    cfg_file_name_vh = os.path.join(
        app_dir_active, utils_dir_active, f"{kernel_name}_filelist_package.vh.f"
    )

    # Clear file lists
    open(cfg_file_name, "w").close()
    open(cfg_file_name_vh, "w").close()

    configs = {
        os.path.join(app_dir_active, ip_dir_rtl_active, pkgs) + "/": ["sv"],
        os.path.join(
            app_dir_active, ip_dir_rtl_active, memory, memory_cache, iob_include
        )
        + "/": ["vh"],
        os.path.join(
            app_dir_active, ip_dir_rtl_active, memory, memory_sram, memory_sram_include
        )
        + "/": ["svh"],
        os.path.join(app_dir_active, ip_dir_rtl_active, utils, utils_include)
        + "/": ["vh"],
        os.path.join(app_dir_active, ip_dir_rtl_active, utils, utils_arbiter)
        + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, utils, utils_slice)
        + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, utils, utils_counter)
        + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, utils, utils_fifo)
        + "/": ["v", "sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, memory, memory_cache)
        + "/": ["v"],
        os.path.join(app_dir_active, ip_dir_rtl_active, memory, memory_sram)
        + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, bundle) + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, cu) + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, lane) + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, control) + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, kernel) + "/": ["sv"],
        os.path.join(app_dir_active, ip_dir_rtl_active, top) + "/": ["v"],
    }

    for path, extensions in configs.items():
        for extension in extensions:
            # Decide the configuration file based on the extension
            cfg_file = cfg_file_name if extension in ["sv", "v"] else cfg_file_name_vh
            generate_package_filelist(path, cfg_file, extension)

    # Engine directories processing (example)
    # engine_dirs = [
    #     "engine_alu_ops",
    #     "engine_csr_index",
    #     "engine_cu_setup",
    #     "engine_filter_cond",
    #     "engine_forward_data",
    #     "engine_merge_data",
    #     "engine_set_ops",
    #     "engine_pipeline",
    #     "engine_read_write",
    #     "engine_m_axi",
    #     "engine_template",
    #     "engine_automata_nfa"
    # ]

    # Assuming 'topology.json' is your JSON file's name $(APP_DIR_ACTIVE)/$(UTILS_DIR_ACTIVE)/$(KERNEL_NAME)_$(TARGET).topology.json ;\
    topology_file_name = f"{kernel_name}_{target}.topology.json"
    topology_file_path = os.path.join(
        app_dir_active, utils_dir_active, topology_file_name
    )

    with open(topology_file_path, "r") as file:
        topology = json.load(file)

    engine_properties = topology["engine_properties"]
    engine_dirs = [key.lower() for key in engine_properties.keys()]

    # Default engines to always include
    default_engines = [
        "engine_template",
        "engine_m_axi",
        "engine_cu_setup",
        "engine_pipeline",
    ]

    # Add default engines without redundancy
    for engine in default_engines:
        if engine not in engine_dirs:
            engine_dirs.append(engine)

    for engine_dir in engine_dirs:
        path = os.path.join(app_dir_active, ip_dir_rtl_active, engines, engine_dir)
        generate_package_filelist(path, cfg_file_name, "sv")
        generate_package_filelist(path, cfg_file_name, "v")
        generate_package_filelist(path, cfg_file_name_vh, "vh")

    # Remove package file list if empty
    remove_empty_file_lists(cfg_file_name)
    remove_empty_file_lists(cfg_file_name_vh)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print_usage()
        sys.exit(1)
    main(sys.argv[1])
