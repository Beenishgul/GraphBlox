#!/usr/bin/env python3

import sys
import os
import json

def print_usage():
    print("""
MSG: Usage:
  generate_build_cfg.py APP_DIR_ACTIVE, UTILS_DIR_ACTIVE, KERNEL_NAME, XILINX_IMPL_STRATEGY, XILINX_JOBS_STRATEGY, PART, PLATFORM, TARGET, XILINX_NUM_KERNELS, XILINX_MAX_THREADS, DESIGN_FREQ_HZ

  APP_DIR_ACTIVE: /home/cmv6ru/Documents/00_github_repos/00_GLay/
  UTILS_DIR_ACTIVE: utils
  KERNEL_NAME: kernel
  XILINX_IMPL_STRATEGY: 0-2
  XILINX_JOBS_STRATEGY: 2
  PART: xcu280-fsvh2892-2L-e
  PLATFORM: xilinx_u250_gen3x16_xdma_4_1_202210_1
  TARGET: hw
  XILINX_NUM_KERNELS: 2
  XILINX_MAX_THREADS: 8
  DESIGN_FREQ_HZ: 300000000
""")

if len(sys.argv) < 15:
    print_usage()
    sys.exit(1)

APP_DIR_ACTIVE, UTILS_DIR_ACTIVE, KERNEL_NAME, XILINX_IMPL_STRATEGY, XILINX_JOBS_STRATEGY, PART, PLATFORM, TARGET, XILINX_NUM_KERNELS, XILINX_MAX_THREADS, DESIGN_FREQ_HZ, FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, OVERRIDE_TOPOLOGY_JSON = sys.argv[1:16]


# Construct the full path for the file
config_filename = f"topology.json"
config_file_path = os.path.join(FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, config_filename)

UTILS_TCL="utils.tcl"

output_file_project_generate_qor_pre_synth_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_read_qor_pre_synth.tcl")
output_file_project_generate_qor_post_synth_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_generate_qor_post_synth.tcl")

output_file_project_read_qor_pre_opt_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_read_qor_pre_opt.tcl")
output_file_project_generate_qor_post_opt_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_generate_qor_post_opt.tcl")

output_file_project_read_qor_pre_place_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_read_qor_pre_place.tcl")
output_file_project_generate_qor_post_place_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_generate_qor_post_place.tcl")

output_file_project_read_qor_pre_phys_opt_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_read_qor_pre_phys_opt.tcl")
output_file_project_generate_qor_post_phys_opt_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_generate_qor_post_phys_opt.tcl")

output_file_project_read_qor_pre_route_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_read_qor_pre_route.tcl")
output_file_project_generate_qor_post_route_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_generate_qor_post_route.tcl")

output_file_project_read_qor_pre_post_route_phys_opt_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_read_qor_pre_post_route_phys_opt.tcl")
output_file_project_generate_qor_post_post_route_phys_opt_tcl = os.path.join(APP_DIR_ACTIVE,UTILS_DIR_ACTIVE,UTILS_TCL,"project_generate_qor_post_post_route_phys_opt.tcl")

with open(config_file_path, "r") as file:
    config_data = json.load(file)

# Convert integer arguments to integers
OVERRIDE_TOPOLOGY_JSON

if not int(OVERRIDE_TOPOLOGY_JSON):
    XILINX_IMPL_STRATEGY = config_data["cu_properties"]["synth_strategy"]
    XILINX_NUM_KERNELS   = config_data["cu_properties"]["num_kernels"]
    DESIGN_FREQ_HZ       = config_data["cu_properties"]["frequency"]

XILINX_MAX_THREADS   = int(XILINX_MAX_THREADS)
XILINX_JOBS_STRATEGY = int(XILINX_JOBS_STRATEGY)
NUM_SLR = {"xcu55c-fsvh2892-2L-e": 3, "xcu280-fsvh2892-2L-e": 3, "xcu250-figd2104-2L-e": 4}.get(PART, 4)

def get_channel_range_from_properties_corrected(kernel_idx, slr_idx, cu_properties):
    """
    Correctly calculates and returns the start and end channels for a given kernel based on cu_properties,
    considering the SLR index and the selected channel layout strategy, ensuring integer channel ranges.
    
    Parameters:
    - kernel_idx: Index of the kernel (1-based).
    - slr_idx: Index of the SLR (0-based) the kernel is in.
    - cu_properties: Dictionary containing configuration properties.
    
    Returns:
    - Tuple of (channel_start, channel_end) indicating the integer range of channels allocated to the kernel.
    """
    total_memory_channels = int(cu_properties["num_channels"])
    num_kernels = int(cu_properties["num_kernels"])
    slr_percent = cu_properties.get("slr_percent", [100])
    # Determine channel distribution strategy
    channel_layout = cu_properties.get("channel_layout", "0")

    # Initialize channel range
    channel_start = 0
    channel_end = 0

    if channel_layout == "0":
        # Calculate total channels for this SLR based on percentage
        channels_for_slr = round(total_memory_channels * (slr_percent[slr_idx] / 100))
        
        # Calculate start channel index based on SLR
        previous_channels = sum(round(total_memory_channels * (p / 100)) for p in slr_percent[:slr_idx])
        
        # Find kernels in this SLR
        kernels_in_slr = cu_properties["slr_mapping"].count(slr_idx)
        if kernels_in_slr > 0:
            channels_per_kernel = channels_for_slr // kernels_in_slr

            # Calculate start and end for this kernel within SLR
            kernel_order = cu_properties["slr_mapping"][:kernel_idx].count(slr_idx)
            channel_start = previous_channels + (kernel_order - 1) * channels_per_kernel
            channel_end = channel_start + channels_per_kernel - 1

    elif channel_layout == "1":
        # Direct channel mapping logic here
        if kernel_idx <= len(cu_properties["channel_mapping"]):
            channel_range = cu_properties["channel_mapping"][kernel_idx - 1].split(':')
            channel_start, channel_end = map(int, channel_range)

    # Adjust channel_end to not exceed total channels and ensure it's integer
    channel_end = min(channel_end, total_memory_channels - 1)

    return channel_start, channel_end


def generate_kernel_and_memory_config(kernel_name, config_data, part, num_kernels, num_buffers_per_kernel=10):
    # Define part information including SLR count and memory type
    # Extract SLR and memory configuration based on part information
    part_info = {
        "xcu55c-fsvh2892-2L-e": ("hbm", 3),
        "xcu280-fsvh2892-2L-e": ("hbm", 3),
        "xcu250-figd2104-2L-e": ("ddr", 4),
    }
    memory_type, num_slrs = part_info.get(part, ("ddr", 4))
    cu_properties = config_data["cu_properties"]
    slr_layout    = config_data["cu_properties"]["slr_layout"]
    slr_mapping   = config_data["cu_properties"]["slr_mapping"] if slr_layout == "2" else []
    slr_percent   = config_data["cu_properties"]["slr_percent"]
    total_memory_channels = int(config_data["cu_properties"].get("num_channels", 32 if memory_type == "hbm" else 4))

    # Calculate kernels per SLR based on percentages for interleaved distribution
    kernels_per_slr = [round(num_kernels * (percent / 100.0)) for percent in slr_percent[:num_slrs]]
    if slr_layout == "1":  # Adjust for interleaving if total does not match num_kernels
        while sum(kernels_per_slr) < num_kernels:
            for i in range(num_slrs):
                if sum(kernels_per_slr) < num_kernels:
                    kernels_per_slr[i] += 1
                else:
                    break

    connectivity_configs = ["[connectivity]"]
    nk_line = f"nk={kernel_name}:{num_kernels}:" + ",".join([f"{kernel_name}_{i+1}" for i in range(num_kernels)])
    connectivity_configs.append(nk_line)

    kernel_assignments = []
    if slr_layout == "1":
        # Interleave kernels according to the percentages
        current_counts = [0] * num_slrs
        for i in range(num_kernels):
            slr_idx = i % num_slrs
            if current_counts[slr_idx] < kernels_per_slr[slr_idx]:
                kernel_assignments.append(slr_idx)
                current_counts[slr_idx] += 1
            else:
                for j in range(num_slrs):
                    if current_counts[j] < kernels_per_slr[j]:
                        kernel_assignments.append(j)
                        current_counts[j] += 1
                        break
    else:
        # sequnce kernels according to the percentages
        current_counts = [0] * num_slrs
        for i in range(num_kernels):
            slr_idx = 0
            if current_counts[slr_idx] < kernels_per_slr[slr_idx]:
                kernel_assignments.append(slr_idx)
                current_counts[slr_idx] += 1
            else:
                slr_idx = slr_idx + 1
                for j in range(num_slrs):
                    if current_counts[j] < kernels_per_slr[j]:
                        kernel_assignments.append(j)
                        current_counts[j] += 1
                        break

    for kernel_idx in range(1, num_kernels + 1):
        if slr_layout == "1":
            slr_idx = kernel_assignments[kernel_idx - 1]
        elif slr_layout == "2":
            slr_idx = slr_mapping[(kernel_idx - 1) % len(slr_mapping)]
        else:
            slr_idx = kernel_assignments[kernel_idx - 1]

        # channel_start = (kernel_idx - 1) * (total_memory_channels // num_kernels) if memory_type == "hbm" else slr_idx
        # channel_end = kernel_idx * (total_memory_channels // num_kernels) - 1 if memory_type == "hbm" else channel_start

        channel_start, channel_end =  get_channel_range_from_properties_corrected(kernel_idx, slr_idx, cu_properties)

        connectivity_configs.append(f"slr={kernel_name}_{kernel_idx}:SLR{slr_idx}")
        for buffer_idx in range(num_buffers_per_kernel):
            connectivity_configs.append(f"sp={kernel_name}_{kernel_idx}.buffer_{buffer_idx}:{memory_type.upper()}[{channel_start}:{channel_end}]")

    return "\n".join(connectivity_configs)

CFG_FILE_NAME = f"{APP_DIR_ACTIVE}/{UTILS_DIR_ACTIVE}/{KERNEL_NAME}_rtl_{TARGET}.cfg"

# Define configuration variables for each XILINX_IMPL_STRATEGY
XILINX_IMPL_STRATEGY_0 = f"""
[advanced]
param=compiler.skipTimingCheckAndFrequencyScaling=1
"""

XILINX_IMPL_STRATEGY_1 = f"""
[advanced]
param=compiler.skipTimingCheckAndFrequencyScaling=0
param=compiler.multiStrategiesWaitOnAllRuns=1

[vivado]
prop=run.my_rm_synth_1.{{STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS}}={{-directive sdx_optimization_effort_high}}
prop=run.impl_1.{{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED}}={{true}}
prop=run.impl_1.{{STEPS.PHYS_OPT_DESIGN.IS_ENABLED}}={{true}}
prop=run.impl_1.{{STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS}}={{-retiming}}
prop=run.impl_1.STEPS.OPT_DESIGN.IS_ENABLED=true
prop=run.impl_1.STEPS.OPT_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=ExtraTimingOpt
prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true
prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true
prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=AggressiveExplore
impl.jobs={XILINX_JOBS_STRATEGY}
synth.jobs={XILINX_JOBS_STRATEGY}
param=general.maxThreads={XILINX_MAX_THREADS}
"""

XILINX_IMPL_STRATEGY_2 = f"""
[advanced]
param=compiler.skipTimingCheckAndFrequencyScaling=0
param=compiler.multiStrategiesWaitOnAllRuns=1

[vivado]
impl.strategies=ALL
impl.jobs={XILINX_JOBS_STRATEGY}
synth.jobs={XILINX_JOBS_STRATEGY}
param=general.maxThreads={XILINX_MAX_THREADS}
"""

XILINX_IMPL_STRATEGY_3 = f"""
[advanced]
param=compiler.skipTimingCheckAndFrequencyScaling=0
param=compiler.multiStrategiesWaitOnAllRuns=1

[vivado]
prop=run.my_rm_synth_1.{{STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS}}={{-directive sdx_optimization_effort_high}}
prop=run.impl_1.{{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED}}={{true}}
prop=run.impl_1.{{STEPS.PHYS_OPT_DESIGN.IS_ENABLED}}={{true}}
prop=run.impl_1.{{STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS}}={{-retiming}}
prop=run.impl_1.STEPS.OPT_DESIGN.IS_ENABLED=true
prop=run.impl_1.STEPS.OPT_DESIGN.ARGS.DIRECTIVE=ExploreWithRemap
prop=run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=SSI_SpreadSLLs
prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true
prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=AlternateCLBRouting
prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true
prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=AggressiveExplore
impl.jobs={XILINX_JOBS_STRATEGY}
synth.jobs={XILINX_JOBS_STRATEGY}
param=general.maxThreads={XILINX_MAX_THREADS}
"""

XILINX_IMPL_STRATEGY_4 = f"""
[advanced]
param=compiler.skipTimingCheckAndFrequencyScaling=0
param=compiler.multiStrategiesWaitOnAllRuns=1

[vivado]
prop=run.my_rm_synth_1.{{STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS}}={{-directive sdx_optimization_effort_high}}
prop=run.my_rm_synth_1.{{STEPS.SYNTH_DESIGN.TCL.PRE}}={{{output_file_project_generate_qor_pre_synth_tcl}}}
prop=run.my_rm_synth_1.{{STEPS.SYNTH_DESIGN.TCL.POST}}={{{output_file_project_generate_qor_post_synth_tcl}}}

prop=run.impl_1.{{STEPS.OPT_DESIGN.IS_ENABLED}}={{true}}
prop=run.impl_1.STEPS.OPT_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.{{STEPS.OPT_DESIGN.TCL.PRE}}={{{output_file_project_read_qor_pre_opt_tcl}}}
prop=run.impl_1.{{STEPS.OPT_DESIGN.TCL.POST}}={{{output_file_project_generate_qor_post_opt_tcl}}}

prop=run.impl_1.{{STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS}}={{-retiming}}
prop=run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.{{STEPS.PLACE_DESIGN.TCL.PRE}}={{{output_file_project_read_qor_pre_place_tcl}}}
prop=run.impl_1.{{STEPS.PLACE_DESIGN.TCL.POST}}={{{output_file_project_generate_qor_post_place_tcl}}}

prop=run.impl_1.{{STEPS.PHYS_OPT_DESIGN.IS_ENABLED}}={{true}}
prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.{{STEPS.PHYS_OPT_DESIGN.TCL.PRE}}={{{output_file_project_read_qor_pre_phys_opt_tcl}}}
prop=run.impl_1.{{STEPS.PHYS_OPT_DESIGN.TCL.POST}}={{{output_file_project_generate_qor_post_phys_opt_tcl}}}

prop=run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.{{STEPS.ROUTE_DESIGN.TCL.PRE}}={{{output_file_project_read_qor_pre_route_tcl}}}
prop=run.impl_1.{{STEPS.ROUTE_DESIGN.TCL.POST}}={{{output_file_project_generate_qor_post_route_tcl}}}

prop=run.impl_1.{{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED}}={{true}}
prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE=Explore
prop=run.impl_1.{{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.TCL.PRE}}={{{output_file_project_read_qor_pre_post_route_phys_opt_tcl}}}
prop=run.impl_1.{{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.TCL.POST}}={{{output_file_project_generate_qor_post_post_route_phys_opt_tcl}}}

impl.jobs={XILINX_JOBS_STRATEGY}
synth.jobs={XILINX_JOBS_STRATEGY}
param=general.maxThreads={XILINX_MAX_THREADS}
"""


# Build the final configuration string
config = f"\nplatform={PLATFORM}\n"
config += f"messageDb={KERNEL_NAME}.mdb\n"
config += f"temp_dir={KERNEL_NAME}.build\n"
config += f"report_dir={KERNEL_NAME}.build/reports\n"
config += f"log_dir={KERNEL_NAME}.build/logs\n"
config += "save-temps=1\n"
# config += "debug=1\n"
config += "link=1\n\n"

config+="[clock]\n"
config+=f"defaultFreqHz={DESIGN_FREQ_HZ}\n\n"

config +=  generate_kernel_and_memory_config(KERNEL_NAME, config_data, PART, int(XILINX_NUM_KERNELS))

config+="\n"
# Select the appropriate configuration based on XILINX_IMPL_STRATEGY
if XILINX_IMPL_STRATEGY == '0':
    config += XILINX_IMPL_STRATEGY_0
elif XILINX_IMPL_STRATEGY == '1':
    config += XILINX_IMPL_STRATEGY_1
elif XILINX_IMPL_STRATEGY == '2':
    config += XILINX_IMPL_STRATEGY_2
elif XILINX_IMPL_STRATEGY == '3':
    config += XILINX_IMPL_STRATEGY_3
elif XILINX_IMPL_STRATEGY == '4':
    config += XILINX_IMPL_STRATEGY_4

else:
    print("ERROR: Invalid XILINX_IMPL_STRATEGY")
    sys.exit(1)

def check_and_clean_file(file_path):
    # Check if the file exists
    if os.path.exists(file_path):
        # Delete the file if it exists
        os.remove(file_path)
        # print(f"MSG: Existing file '{file_path}' found and removed.")

output_folder_path_cfg = os.path.join(APP_DIR_ACTIVE, UTILS_DIR_ACTIVE)

if not os.path.exists(output_folder_path_cfg):
    os.makedirs(output_folder_path_cfg)

check_and_clean_file(CFG_FILE_NAME)

with open(CFG_FILE_NAME, 'w') as cfg_file:
    cfg_file.write(config)
