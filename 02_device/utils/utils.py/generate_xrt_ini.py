#!/usr/bin/env python3

import sys
import os
import glob
import json

def print_usage():
    usage_text = """
Usage: generate_rtl_synth_cfg.py <params_sh_dir>
  <params_sh_dir>: Path to the parameters file.

Example:
  python generate_rtl_synth_cfg.py /path/to/params.sh
"""
    print(usage_text)

def load_params_from_bash(params_file_path):
    params = {}
    with open(params_file_path, 'r') as file:
        for line in file:
            line = line.strip()
            # Ignore comments and empty lines
            if line.startswith('#') or not line:
                continue
            # Split on the first '=' to separate key and value
            key_value = line.split('=', 1)
            if len(key_value) == 2:
                key, value = key_value
                key = key.strip()
                value = value.strip()
                # Try to convert numerical values
                if value.isdigit():
                    value = int(value)
                elif value.replace('.', '', 1).isdigit():
                    value = float(value)
                # Handle strings, assuming they do not contain spaces
                else:
                    # Remove possible Bash export command
                    key = key.replace('export ', '')
                    # Assuming the values are not enclosed in quotes in the Bash script
                    # If they are, you might need to strip them: value = value.strip('\'"')
                params[key] = value
    return params

def generate_xrt_ini(params):

    # Extract parameters from the loaded params
    VIVADO_GUI_FLAG = params['VIVADO_GUI_FLAG']
    APP_DIR_ACTIVE = params['APP_DIR_ACTIVE']
    UTILS_DIR_ACTIVE = params['UTILS_DIR_ACTIVE']
    KERNEL_NAME = params['KERNEL_NAME']
    UTILS_TCL = params['UTILS_TCL']
    XILINX_CTRL_MODE = params.get('XILINX_CTRL_MODE', 'USER_MANAGED')  # Default to USER_MANAGED if not set

    CFG_FILE_NAME = f"{APP_DIR_ACTIVE}/{UTILS_DIR_ACTIVE}/{KERNEL_NAME}_xrt.ini"

    if VIVADO_GUI_FLAG == "NO":
        debug_mode = "batch"
    else:
        debug_mode="gui"

    user_pre_sim_script = f"{APP_DIR_ACTIVE}/{UTILS_DIR_ACTIVE}/{UTILS_TCL}/cmd_xsim.tcl"
    runtime_log = "console"

    profile = "true"
    timeline_trace = "true"
    device_trace = "coarse"

    config = "[Emulation]\n"
    config += f"debug_mode={debug_mode}\n"
    config += f"user_pre_sim_script={user_pre_sim_script}\n"

    config += "\n[Debug]\n"
    config += f"profile={profile}\n"
    config += f"timeline_trace={timeline_trace}\n"
    config += f"device_trace={device_trace}\n"

    if XILINX_CTRL_MODE == "USER_MANAGED":
        config += "\n[Runtime]\n"
        config += "exclusive_cu_context=true\n"

    with open(CFG_FILE_NAME, 'w') as cfg_file:
        cfg_file.write(config)

# Script usage and parameters loading logic
if len(sys.argv) < 2:
    print_usage()
    sys.exit(1)

params_sh_dir = sys.argv[1]
params = load_params_from_bash(params_sh_dir)

# Call the generate_xrt_ini function with the loaded parameters
generate_xrt_ini(params)