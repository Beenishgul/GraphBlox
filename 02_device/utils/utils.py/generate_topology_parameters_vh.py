#!/usr/bin/env python3

import re
import sys
import os
import ast
import json
from datetime import datetime

# Validate the number of arguments
if len(sys.argv) != 14:
    print("Usage: <script> <XILINX_VIVADO> <FULL_SRC_IP_DIR_GEN_VIP> <KERNEL_NAME> <FULL_SRC_IP_DIR_OVERLAY> <FULL_SRC_IP_DIR_RTL> <FULL_SRC_IP_DIR_UTILS> <FULL_SRC_IP_DIR_UTILS_TCL> <UTILS_DIR> <ARCHITECTURE> <CAPABILITY> <ALGORITHM_NAME> <PAUSE_FILE_GENERATION> <INCLUDE_DIR>")
    sys.exit(1)

# Assuming the script name is the first argument, and the directories follow after.
_, XILINX_VIVADO, FULL_SRC_IP_DIR_GEN_VIP, KERNEL_NAME, FULL_SRC_IP_DIR_OVERLAY, FULL_SRC_IP_DIR_RTL, FULL_SRC_IP_DIR_UTILS, FULL_SRC_IP_DIR_UTILS_TCL, UTILS_DIR, ARCHITECTURE, CAPABILITY, ALGORITHM_NAME, PAUSE_FILE_GENERATION, INCLUDE_DIR = sys.argv


# Getting the current date and time
current_datetime = datetime.now()

# Formatting the date and time in the specified format
formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M:%S")


# Construct the full path for the file
config_filename = f"topology.json"
config_file_path = os.path.join(FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, config_filename)

# output_folder_path_tcl  = os.path.join(FULL_SRC_IP_DIR_UTILS_TCL)
output_folder_path_testbench   = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "testbench")
output_folder_path_topology    = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "topology")
output_folder_path_global      = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "global")
output_folder_path_parameters  = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "parameters")
output_folder_path_portmaps    = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "portmaps")
output_folder_path_slice       = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, "slice")
output_folder_path_kernel      = os.path.join(FULL_SRC_IP_DIR_RTL, "kernel")
output_folder_path_cu          = os.path.join(FULL_SRC_IP_DIR_RTL, "cu")
output_folder_path_pkgs        = os.path.join(FULL_SRC_IP_DIR_RTL, "pkg")
output_folder_path_vip         = os.path.join(FULL_SRC_IP_DIR_GEN_VIP)

if not os.path.exists(output_folder_path_topology):
    os.makedirs(output_folder_path_topology)

if not os.path.exists(output_folder_path_global):
    os.makedirs(output_folder_path_global)

if not os.path.exists(output_folder_path_kernel):
    os.makedirs(output_folder_path_kernel)

if not os.path.exists(output_folder_path_cu):
    os.makedirs(output_folder_path_cu)

if not os.path.exists(output_folder_path_parameters):
    os.makedirs(output_folder_path_parameters)

if not os.path.exists(output_folder_path_portmaps):
    os.makedirs(output_folder_path_portmaps)

if not os.path.exists(output_folder_path_slice):
    os.makedirs(output_folder_path_slice)

if not os.path.exists(output_folder_path_pkgs):
    os.makedirs(output_folder_path_pkgs)

if not os.path.exists(FULL_SRC_IP_DIR_UTILS):
    os.makedirs(FULL_SRC_IP_DIR_UTILS)

if not os.path.exists(FULL_SRC_IP_DIR_UTILS_TCL):
    os.makedirs(FULL_SRC_IP_DIR_UTILS_TCL)

if not os.path.exists(output_folder_path_testbench):
    os.makedirs(output_folder_path_testbench)


output_file_kernel_cu_topology = os.path.join(output_folder_path_topology,"kernel_cu_topology.vh")
output_file_kernel_cu_portmap = os.path.join(output_folder_path_portmaps,"m_axi_portmap_kernel_cu.vh")
output_file_kernel_cu_ports = os.path.join(output_folder_path_portmaps,"m_axi_ports_kernel_cu.vh")

output_file_filelist_xsim_ip_vhdl_f = os.path.join(FULL_SRC_IP_DIR_UTILS,"glay_kernel_filelist_xsim.ip.vhdl.f")
output_file_filelist_xsim_ip_sv_f = os.path.join(FULL_SRC_IP_DIR_UTILS,"glay_kernel_filelist_xsim.ip.sv.f")
output_file_filelist_xsim_ip_v_f = os.path.join(FULL_SRC_IP_DIR_UTILS,"glay_kernel_filelist_xsim.ip.v.f")

output_file_pkg_mxx_axi4_fe  = os.path.join(output_folder_path_pkgs,"00_pkg_mxx_axi4_fe.sv")
output_file_pkg_mxx_axi4_mid = os.path.join(output_folder_path_pkgs,"00_pkg_mxx_axi4_mid.sv")
output_file_pkg_mxx_axi4_be  = os.path.join(output_folder_path_pkgs,"00_pkg_mxx_axi4_be.sv")

output_file_afu_portmap = os.path.join(output_folder_path_portmaps,"m_axi_portmap_afu.vh")
output_file_afu_ports = os.path.join(output_folder_path_portmaps,"m_axi_ports_afu.vh")
output_file_afu_topology = os.path.join(output_folder_path_topology,"afu_topology.vh")
output_file_buffer_channels_tcl = os.path.join(FULL_SRC_IP_DIR_UTILS_TCL,"project_map_buffers_m_axi_ports.tcl")
output_file_generate_m_axi_vip_tcl = os.path.join(FULL_SRC_IP_DIR_UTILS_TCL,"project_generate_m_axi_vip.tcl")
output_file_bundle_arbitration = os.path.join(output_folder_path_topology, "bundle_arbitration.vh")
output_file_bundle_topology = os.path.join(output_folder_path_topology , "bundle_topology.vh")
output_file_cu_arbitration = os.path.join(output_folder_path_topology, "cu_arbitration.vh")
output_file_generate_ports_tcl = os.path.join(FULL_SRC_IP_DIR_UTILS_TCL,"project_generate_m_axi_ports.tcl")
output_file_lane_arbitration = os.path.join(output_folder_path_topology,"lane_arbitration.vh")
output_file_lane_topology = os.path.join(output_folder_path_topology,"lane_topology.vh")
output_file_path_global = os.path.join(output_folder_path_global,"config_parameters.vh")
output_file_path_topology = os.path.join(output_folder_path_parameters,"topology_parameters.vh")
output_file_set_top_parameters = os.path.join(output_folder_path_parameters,"set_top_parameters.vh")
output_file_slv_m_axi_vip_func = os.path.join(output_folder_path_testbench,"module_slv_m_axi_vip_func.vh")
output_file_slv_m_axi_vip_inst = os.path.join(output_folder_path_testbench,"module_slv_m_axi_vip_inst.vh")
output_file_slv_m_axi_vip_import = os.path.join(output_folder_path_testbench,"module_slv_m_axi_vip_import.vh")
output_file_testbench_parameters = os.path.join(output_folder_path_parameters,"testbench_parameters.vh")
output_file_top_parameters = os.path.join(output_folder_path_parameters,"top_parameters.vh")
output_file_top_portmap = os.path.join(output_folder_path_portmaps,"m_axi_portmap_top.vh")
output_file_top_ports = os.path.join(output_folder_path_portmaps,"m_axi_ports_top.vh")
output_file_top_wires = os.path.join(output_folder_path_portmaps,"m_axi_wires_top.vh")

with open(config_file_path, "r") as file:
    config_data = json.load(file)

buffers = config_data["buffers"]
channels = config_data["channels"]
ch_properties = config_data["ch_properties"]
cu_properties = config_data["cu_properties"]
cache_properties = config_data["cache_properties"]
mapping = config_data["mapping"]
luts    = config_data["luts"]
fifo_control_response = config_data["fifo_control_response"]
fifo_control_request  = config_data["fifo_control_request"]
fifo_memory   = config_data["fifo_memory"]
fifo_engine   = config_data["fifo_engine"]


DISTINCT_CHANNELS = set(int(properties[0]) for properties in channels.values())
NUM_CHANNELS_TOP = len(DISTINCT_CHANNELS)

def get_config(config_data, algorithm):
    # Default to 'bundle' if the specified algorithm is not found
    selected_config = config_data.get(algorithm, config_data[CAPABILITY])

    # Sort the keys and create the configuration array
    return [selected_config[key] for key in sorted(selected_config.keys(), key=int)]

# Define the filename based on the CAPABILITY
if CAPABILITY == "Single":
    topology = f"{CAPABILITY}.{ALGORITHM_NAME}"
else:
    topology = f"{CAPABILITY}"

# Get the configuration for the selected algorithm
CU_BUNDLES_CONFIG_ARRAY = get_config(config_data, topology)

# Extract bundles and transform to the desired format
# CU_BUNDLES_CONFIG_ARRAY = [config_data['bundle'][key] for key in sorted(config_data['bundle'].keys(), key=int)]

# Compute values based on CU_BUNDLES_CONFIG_ARRAY
NUM_CUS_MAX = 1  # As there's only one CU
NUM_BUNDLES_MAX = len(CU_BUNDLES_CONFIG_ARRAY)
NUM_LANES_MAX = max(len(bundle) for bundle in CU_BUNDLES_CONFIG_ARRAY)
NUM_ENGINES_MAX = max(len(lane) for bundle in CU_BUNDLES_CONFIG_ARRAY for lane in bundle)

NUM_CUS = NUM_CUS_MAX
NUM_BUNDLES = NUM_BUNDLES_MAX
NUM_LANES = NUM_LANES_MAX
NUM_ENGINES = NUM_ENGINES_MAX

# Padding function for connect array
def pad_connect_array(connect_array, max_cast):
    padded_array = connect_array.copy()
    while len(padded_array) < max_cast:
        padded_array.append(0)
    return padded_array

def pad_engines(lane, max_engines):
    padded_lane = lane.copy()
    while len(padded_lane) < max_engines:
        padded_lane.append(0)
    return padded_lane

def pad_engines_cast(lane, max_engines):
    while len(lane) < max_engines:
        lane.append([0] * NUM_CAST_MAX)
    return lane

# Modified pad_data to accept a default pad value
def pad_data(data, max_length, default_val=0):
    padded_data = data.copy()
    while len(padded_data) < max_length:
        padded_data.append(default_val)
    return padded_data

def pad_lane(bundle):
    return pad_data(bundle, NUM_LANES_MAX, [0] * NUM_ENGINES_MAX)

def pad_bundle(bundle):
    while len(bundle) < NUM_LANES_MAX:
        bundle.append([[0]*NUM_CAST_MAX]*NUM_ENGINES_MAX)
    return bundle

def get_width(engine_name):
    match = re.search(r'W:(\d+)', engine_name)
    if match:
        return int(match.group(1))
    return 0

def get_engine_id(engine_name):
    base_name = engine_name.split("(")[0]
    return mapping.get(base_name, 0)

def get_memory_fifo(engine_name):
    base_name = engine_name.split("(")[0]
    return fifo_memory.get(base_name, 0)

def get_control_fifo_response(engine_name):
    base_name = engine_name.split("(")[0]
    return fifo_control_response.get(base_name, 0)

def get_control_fifo_request(engine_name):
    base_name = engine_name.split("(")[0]
    return fifo_control_request.get(base_name, 0)

def get_engine_fifo(engine_name):
    base_name = engine_name.split("(")[0]
    return fifo_engine.get(base_name, 0)

def get_memory_arbiter_num(engine_name):
    base_name = engine_name.split("(")[0]
    value = fifo_memory.get(base_name, 0)
    return 1 if value != 0 else 0

def get_control_arbiter_num_response(engine_name):
    base_name = engine_name.split("(")[0]
    value = fifo_control_response.get(base_name, 0)
    return 1 if value != 0 else 0

def get_control_arbiter_num_request(engine_name):
    base_name = engine_name.split("(")[0]
    value = fifo_control_request.get(base_name, 0)
    return 1 if value != 0 else 0

def get_engine_arbiter_num(engine_name):
    base_name = engine_name.split("(")[0]
    value = fifo_engine.get(base_name, 0)
    return 1 if value != 0 else 0

def get_connect_array(engine_name):
    match = re.search(r'C:(\d+):(\d+)', engine_name)
    if match:
        start, end = int(match.group(1)), int(match.group(2))
        return list(range(start, end + 1))
    
    match_explicit = re.search(r'C:([\d,]+)', engine_name)
    if match_explicit:
        values = [int(x) for x in match_explicit.group(1).split(',')]
        return values

    return []

def vhdl_format(array):
    if not isinstance(array, list):
        return str(array)
    inner_data = ", ".join(vhdl_format(subarray) for subarray in array)
    return "'{" + inner_data + "}\n"

def extract_cast_width(token):
    """Extracts the cast width value from a token in the form (C:x:y) or (C:x,y,z,...)."""
    if "(C:" in token:
        start = token.find("(C:") + 3
        end = token.find(")")
        values = token[start:end].split(":")
        if len(values) == 2:  # Format (C:x:y)
            return int(values[1]) - int(values[0]) + 1
        elif len(values) == 1:  # Format (C:x,y,z,...)
            return len(values[0].split(","))
    return 0

def generate_config_cast_width_array():
    """Generates the CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY based on CU_BUNDLES_CONFIG_ARRAY."""
    CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY = []

    for bundle in CU_BUNDLES_CONFIG_ARRAY:
        lane_list = []
        for lane in bundle:
            engine_list = [extract_cast_width(engine) for engine in lane]

            # Pad the engine list with zeros up to NUM_ENGINES_MAX
            while len(engine_list) < NUM_ENGINES_MAX:
                engine_list.append(0)
            
            lane_list.append(engine_list)

        # Pad the lane list with zeros up to NUM_LANES_MAX
        while len(lane_list) < NUM_LANES_MAX:
            lane_list.append([0] * NUM_ENGINES_MAX)
        
        CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY.append(lane_list)

    return CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY

def get_engine_name(engine_id, mapping):
    # Use regex to match the engine name ignoring any additional info like "(W:2)" or "(C:0)"
    match = re.match(r"ENGINE_[A-Z_]+", engine_id)
    if match:
        engine_base_name = match.group()
        return [name for name, id_ in mapping.items() if name == engine_base_name]
    return []

def generate_cu_bundles_config_array_engine_seq_width(cycles_dict, config_array, mapping):
    seq_width_array = [[[0 for _ in range(NUM_ENGINES_MAX)] for _ in range(NUM_LANES_MAX)] for _ in range(NUM_BUNDLES_MAX)]
    
    for bundle_index, lanes in enumerate(config_array):
        for lane_index, engines in enumerate(lanes):
            for engine_index, engine_id in enumerate(engines):
                engine_name = get_engine_name(engine_id, mapping)
                if engine_name:
                    seq_width_array[bundle_index][lane_index][engine_index] = cycles_dict.get(engine_name[0], 0)
                else:
                    # If engine_name is empty, it means no match was found
                    print(f"No match found for engine ID {engine_id}")
                    seq_width_array[bundle_index][lane_index][engine_index] = 0

    return seq_width_array

# The function to generate CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN
def generate_cu_bundles_config_array_engine_seq_min(seq_width_array):
    """
    Generate the prefix sum array based on the sequence width array.
    Accumulate sums within each lane for every bundle.
    """
    prefix_sum_array = [[[0 for _ in range(NUM_ENGINES_MAX)] for _ in range(NUM_LANES_MAX)] for _ in range(NUM_BUNDLES_MAX)]
    running_sum = 0
    for bundle_index in range(len(seq_width_array)):
        for lane_index in range(len(seq_width_array[bundle_index])):
            for engine_index in range(len(seq_width_array[bundle_index][lane_index])):
                # The current position in the prefix sum array gets the current running sum
                prefix_sum_array[bundle_index][lane_index][engine_index] = running_sum
                # The running sum is then carried over to the next engine (cumulative sum)
                # We add the current value to the running sum
                running_sum += seq_width_array[bundle_index][lane_index][engine_index]

    return prefix_sum_array

def calculate_total_luts(luts, configuration):
    total_luts = 0

    if not isinstance(configuration, list):
        raise ValueError("Configuration should be a list")

    for engines in configuration:
        if not isinstance(engines, list):
            raise ValueError("Each item in configuration should be a list of engines")
        for engine in engines:
            if not isinstance(engine, list):
                raise ValueError("Each engine should be a list")
            for engine_instance in engine:
                engine_name = engine_instance.split('(')[0]
                total_luts += luts.get(engine_name, 0)

    return total_luts

total_luts = calculate_total_luts(luts, CU_BUNDLES_CONFIG_ARRAY)

CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY = generate_config_cast_width_array()

# Generate CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH
CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH = generate_cu_bundles_config_array_engine_seq_width(
    config_data['cycles'], CU_BUNDLES_CONFIG_ARRAY, mapping
)

# Generate CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN
CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN = generate_cu_bundles_config_array_engine_seq_min(
    CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH
)

# Step 1: Determine NUM_CAST_MAX
NUM_CAST_MAX = max(
    [max(engine) if engine else 0 for bundle in CU_BUNDLES_CONFIG_ARRAY for lane in bundle for engine in [get_connect_array(engine_name) for engine_name in lane]]
) + 1  # Added 1 because the values are 0-indexed

CU_BUNDLES_ENGINE_ID_ARRAY = []

# Calculate number of bundles per CU
CU_BUNDLES_COUNT_ARRAY = [len(bundle) for bundle in CU_BUNDLES_CONFIG_ARRAY]

# Calculate number of lanes per bundle for each CU
CU_BUNDLES_LANES_COUNT_ARRAY = [[len(lane) for lane in bundle] for bundle in CU_BUNDLES_CONFIG_ARRAY]

CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY = [pad_data([len(lane) for lane in bundle],NUM_LANES_MAX) for bundle in CU_BUNDLES_CONFIG_ARRAY]

# Get engine IDs and pad accordingly
CU_BUNDLES_ENGINE_CONFIG_ARRAY = [
    pad_lane([pad_data([get_engine_id(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

# Get engine widths and pad accordingly
CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY = [
    pad_lane([pad_data([get_width(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

# Initialize CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY with zeros
CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[bundle_index][lane_index] = sum(lane)

# Initialize CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY with zeros
CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[bundle_index][lane_index] = sum(lane)

# Create the CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY with the correct padding
CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY = [
    pad_bundle([
        pad_engines_cast(
            [pad_connect_array(get_connect_array(engine), NUM_CAST_MAX) for engine in lane], 
            NUM_ENGINES_MAX
        ) 
        for lane in bundle
    ])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY = [
    max(lane) for lane in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
]

CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY = [
    max(lane) for lane in CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY
]

# Compute the max values across the engine dimension
CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY = [
    [max(lane) for lane in bundle]
    for bundle in CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY
]

CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY = [
    [max(lane) for lane in bundle]
    for bundle in CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY
]

counter = 0
for cu in CU_BUNDLES_CONFIG_ARRAY:
    cu_list = []
    for lane_index in range(NUM_LANES_MAX):
        lane_list = []
        for engine_index in range(NUM_ENGINES_MAX):
            # Check if current lane and engine is present in the config
            if lane_index < len(cu) and engine_index < len(cu[lane_index]):
                lane_list.append(counter)
                counter += 1
            else:
                lane_list.append(0)
        cu_list.append(lane_list)
    CU_BUNDLES_ENGINE_ID_ARRAY.append(cu_list)

CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY = []

for bundle in CU_BUNDLES_CONFIG_ARRAY:
    new_bundle = []
    for lane in bundle:
        new_lane = []
        prefix_sum = 0
        for engine in lane:
            connect_array = get_connect_array(engine)
            new_engine = [prefix_sum + idx for idx in connect_array]
            new_lane.append(pad_connect_array(new_engine, NUM_CAST_MAX))
            prefix_sum += len(connect_array)
        new_lane = pad_engines_cast(new_lane, NUM_ENGINES_MAX)
        new_bundle.append(new_lane)
    new_bundle = pad_bundle(new_bundle)
    CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY.append(new_bundle)

def check_and_clean_file(file_path):
    # Check if the file exists
    if os.path.exists(file_path):
        # Delete the file if it exists
        os.remove(file_path)
        # print(f"MSG: Existing file '{file_path}' found and removed.")


def generate_channels_properties_parameters(ch_properties):

    # Grouping values for each channel
    channel_config_l1 = []
    channel_config_l2 = []
    channel_config_data_width_be = []
    channel_config_address_width_be = []
    channel_config_data_width_mid = []
    channel_config_address_width_mid = []
    channel_config_data_width_fe = []
    channel_config_address_width_fe = []
    for channel, values in ch_properties.items():
        channel_config_address_width_be.append(int(values[2]))
        channel_config_address_width_fe.append(int(values[6]))
        channel_config_address_width_mid.append(int(values[4]))
        channel_config_data_width_be.append(int(values[3]))
        channel_config_data_width_fe.append(int(values[7]))
        channel_config_data_width_mid.append(int(values[5]))
        channel_config_l1.append(int(values[1]))
        channel_config_l2.append(int(values[0]))


    NUM_CHANNELS_MAX = len(channel_config_l1)


    return NUM_CHANNELS_MAX, channel_config_l1, channel_config_l2, channel_config_address_width_be, channel_config_data_width_be, channel_config_address_width_mid, channel_config_data_width_mid, channel_config_address_width_fe, channel_config_data_width_fe

def generate_caches_properties_parameters(cache_properties):

    # Grouping values for each cache
    cache_config_l1_num_ways = []
    cache_config_l1_size = []
    cache_config_l1_prefetch = []
    cache_config_l2_num_ways = []
    cache_config_l2_size = []
    cache_config_l2_ram = []
    cache_config_l2_ctrl = []
    for cache, values in cache_properties.items():
        cache_config_l1_prefetch.append(int(values[4]))
        cache_config_l1_num_ways.append(int(values[3]))
        cache_config_l1_size.append(int(values[2]))
        cache_config_l2_num_ways.append(int(values[1]))
        cache_config_l2_size.append(int(values[0]))
        cache_config_l2_ram.append(values[5])
        cache_config_l2_ctrl.append(values[6])


    return cache_config_l2_size, cache_config_l2_num_ways, cache_config_l1_size, cache_config_l1_num_ways, cache_config_l1_prefetch, cache_config_l2_ram, cache_config_l2_ctrl


CHANNEL_CONFIG_L1 = []
CHANNEL_CONFIG_L2 = []
CHANNEL_CONFIG_ADDRESS_WIDTH_BE=[]
CHANNEL_CONFIG_DATA_WIDTH_BE=[]
CHANNEL_CONFIG_ADDRESS_WIDTH_MID=[]
CHANNEL_CONFIG_DATA_WIDTH_MID=[]
CHANNEL_CONFIG_ADDRESS_WIDTH_FE=[]
CHANNEL_CONFIG_DATA_WIDTH_FE=[]
NUM_CHANNELS_MAX  = 1

NUM_CHANNELS_MAX,CHANNEL_CONFIG_L1,CHANNEL_CONFIG_L2, CHANNEL_CONFIG_ADDRESS_WIDTH_BE, CHANNEL_CONFIG_DATA_WIDTH_BE, CHANNEL_CONFIG_ADDRESS_WIDTH_MID, CHANNEL_CONFIG_DATA_WIDTH_MID, CHANNEL_CONFIG_ADDRESS_WIDTH_FE, CHANNEL_CONFIG_DATA_WIDTH_FE= generate_channels_properties_parameters(ch_properties)

CACHE_CONFIG_L1_PREFETCH = []
CACHE_CONFIG_L1_NUM_WAYS = []
CACHE_CONFIG_L1_SIZE = []
CACHE_CONFIG_L2_NUM_WAYS = []
CACHE_CONFIG_L2_SIZE = []
CACHE_CONFIG_L2_RAM = []
CACHE_CONFIG_L2_CTRL = []

CACHE_CONFIG_L2_SIZE, CACHE_CONFIG_L2_NUM_WAYS, CACHE_CONFIG_L1_SIZE, CACHE_CONFIG_L1_NUM_WAYS, CACHE_CONFIG_L1_PREFETCH, CACHE_CONFIG_L2_RAM, CACHE_CONFIG_L2_CTRL = generate_caches_properties_parameters(cache_properties)


def find_max_value(list1, list2, list1_c, list2_c, max_size):
    # Combine both lists while filtering out empty lists
    list1_temp = []
    list2_temp = []

    for index in range(max_size):
        if(list1_c[index] != 0):
            list1_temp.append(list1[index])
        if(list2_c[index] != 0):
            list2_temp.append(list2[index])

    combined_list = [x for x in list1_temp + list2_temp if x is not None]

    # Check if the combined list is empty
    if not combined_list:
        return 0  # or return None, or raise an error, depending on your requirements

    # Return the maximum value
    return max(combined_list)

CACHE_CONFIG_MAX_NUM_WAYS = find_max_value(CACHE_CONFIG_L1_NUM_WAYS, CACHE_CONFIG_L2_NUM_WAYS, CHANNEL_CONFIG_L1, CHANNEL_CONFIG_L2, NUM_CHANNELS_TOP)
CACHE_CONFIG_MAX_SIZE = find_max_value(CACHE_CONFIG_L1_SIZE, CACHE_CONFIG_L2_SIZE, CHANNEL_CONFIG_L1, CHANNEL_CONFIG_L2, NUM_CHANNELS_TOP)

# Get engine IDs and pad accordingly
CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY = [
    pad_lane([pad_data([get_memory_fifo(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE = [
    pad_lane([pad_data([get_engine_fifo(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_RESPONSE = [
    pad_lane([pad_data([get_control_fifo_response(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_REQUEST = [
    pad_lane([pad_data([get_control_fifo_request(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]


# Initialize CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY with zeros
CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[bundle_index][lane_index] = sum(lane)

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[bundle_index][lane_index] = sum(lane)

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_RESPONSE):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[bundle_index][lane_index] = sum(lane)

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_REQUEST):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[bundle_index][lane_index] = sum(lane)

CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY
]
CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE
]
CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE
]
CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST
]

CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY  = sum(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY)
CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE  = sum(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE)
CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE = sum(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)
CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST = sum(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST)

# Get engine IDs and pad accordingly
CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY = [
    pad_lane([pad_data([get_memory_arbiter_num(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE = [
    pad_lane([pad_data([get_engine_arbiter_num(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE = [
    pad_lane([pad_data([get_control_arbiter_num_response(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST = [
    pad_lane([pad_data([get_control_arbiter_num_request(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

# Initialize CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY with zeros
CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

# Initialize CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY with zeros
CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY_TEMP = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE_TEMP = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE_TEMP = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST_TEMP = [
    [0 for _ in range(NUM_LANES_MAX)]
    for _ in range(NUM_BUNDLES_MAX)
]

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[bundle_index][lane_index] = sum(lane)
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY_TEMP[bundle_index][lane_index] = 1 if any(lane) else 0 

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE[bundle_index][lane_index] = sum(lane)
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE_TEMP[bundle_index][lane_index] = 1 if any(lane) else 0 

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[bundle_index][lane_index] = sum(lane)
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE_TEMP[bundle_index][lane_index] = 1 if any(lane) else 0 

# Sum each lane and place the result in CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[bundle_index][lane_index] = sum(lane)
        CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST_TEMP[bundle_index][lane_index] = 1 if any(lane) else 0 



CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY_TEMP = [
    1 if any(lane) else 0  for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY
]
CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE_TEMP = [
    1 if any(lane) else 0  for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE
]
CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE_TEMP = [
    1 if any(lane) else 0  for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE
]
CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST_TEMP = [
   1 if any(lane) else 0  for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST
]


CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY_TEMP
]
CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE_TEMP
]
CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE_TEMP
]
CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST_TEMP
]

CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY  = sum(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY_TEMP)
CU_BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE  = sum(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE_TEMP)
CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE = sum(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE_TEMP)
CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST = sum(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST_TEMP)

check_and_clean_file(output_file_generate_ports_tcl)
check_and_clean_file(output_file_buffer_channels_tcl)
check_and_clean_file(output_file_generate_m_axi_vip_tcl)
check_and_clean_file(output_file_path_global)
check_and_clean_file(output_file_top_parameters)
check_and_clean_file(output_file_set_top_parameters)
check_and_clean_file(output_file_testbench_parameters)
check_and_clean_file(output_file_path_topology)
check_and_clean_file(output_file_bundle_topology)
check_and_clean_file(output_file_lane_topology)
check_and_clean_file(output_file_afu_topology)
check_and_clean_file(output_file_afu_ports)
check_and_clean_file(output_file_top_ports)
check_and_clean_file(output_file_top_wires)
check_and_clean_file(output_file_afu_portmap)
check_and_clean_file(output_file_top_portmap)
check_and_clean_file(output_file_cu_arbitration)
check_and_clean_file(output_file_bundle_arbitration)
check_and_clean_file(output_file_lane_arbitration)
check_and_clean_file(output_file_slv_m_axi_vip_inst)
check_and_clean_file(output_file_slv_m_axi_vip_import)
check_and_clean_file(output_file_slv_m_axi_vip_func)
check_and_clean_file(output_file_filelist_xsim_ip_vhdl_f)
check_and_clean_file(output_file_filelist_xsim_ip_sv_f)
check_and_clean_file(output_file_filelist_xsim_ip_v_f)
check_and_clean_file(output_file_pkg_mxx_axi4_fe)
check_and_clean_file(output_file_pkg_mxx_axi4_mid)
check_and_clean_file(output_file_pkg_mxx_axi4_be)
check_and_clean_file(output_file_kernel_cu_topology)
check_and_clean_file(output_file_kernel_cu_portmap)
check_and_clean_file(output_file_kernel_cu_ports)

# Write to VHDL file
with open(output_file_top_parameters, "w") as file:
    output_lines = []

    ports_template = """
parameter integer C_M{0:02d}_AXI_ADDR_WIDTH       = {2} ,
parameter integer C_M{0:02d}_AXI_DATA_WIDTH       = {1} ,
parameter integer C_M{0:02d}_AXI_ID_WIDTH         = 1   ,
"""
    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(ports_template.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index]))
    
    output_lines.append(f"parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12 ,")
    output_lines.append(f"parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32")

    file.write('\n'.join(output_lines))

# Write to VHDL file
with open(output_file_path_global, "w") as file:

    file.write(f"parameter NUM_CUS     = {NUM_CUS};\n")
    file.write(f"parameter NUM_BUNDLES = {NUM_BUNDLES};\n")
    file.write(f"parameter NUM_LANES   = {NUM_LANES};\n")
    file.write(f"parameter NUM_ENGINES = {NUM_ENGINES};\n")
    file.write(f"parameter NUM_MODULES = 3;\n")
    file.write(f"parameter NUM_CHANNELS           = {NUM_CHANNELS_TOP};\n")
    
    file.write(f"parameter CACHE_CONFIG_MAX_NUM_WAYS   = {CACHE_CONFIG_MAX_NUM_WAYS};\n")
    file.write(f"parameter CACHE_CONFIG_MAX_SIZE = {CACHE_CONFIG_MAX_SIZE};\n\n")

    file.write(f"parameter NUM_CHANNELS_WIDTH_BITS = {NUM_CHANNELS_TOP};\n")
    file.write(f"parameter NUM_CUS_WIDTH_BITS      = {NUM_CUS};\n")
    file.write(f"parameter NUM_BUNDLES_WIDTH_BITS  = {NUM_BUNDLES};\n")
    file.write(f"parameter NUM_LANES_WIDTH_BITS    = {NUM_LANES};\n")
    file.write(f"parameter NUM_ENGINES_WIDTH_BITS  = {NUM_ENGINES};\n")
    file.write(f"parameter NUM_MODULES_WIDTH_BITS  = 3;\n")
    file.write(f"parameter CU_PACKET_SEQUENCE_ID_WIDTH_BITS = $clog2(({CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE}*NUM_BUNDLES)+(8*NUM_BUNDLES));\n")

    for buffer_name, properties in channels.items():
        uppercase_buffer_name = buffer_name.upper()
        file.write(f"parameter {uppercase_buffer_name}_WIDTH_BITS = {properties[1]};\n")
    
# Write to VHDL file
with open(output_file_path_topology, "w") as file:

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// FIFO SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")

    file.write("parameter FIFO_WRITE_DEPTH = 32,\n")
    file.write("parameter PROG_THRESH      = 24,\n\n")

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// CU CONFIGURATIONS SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")

    file.write(f"parameter NUM_CHANNELS    = {NUM_CHANNELS_TOP},\n")

    file.write(f"parameter NUM_CUS_MAX     = {NUM_CUS_MAX},\n")
    file.write(f"parameter NUM_BUNDLES_MAX = {NUM_BUNDLES_MAX},\n")
    file.write(f"parameter NUM_LANES_MAX   = {NUM_LANES_MAX},\n")
    file.write(f"parameter NUM_CAST_MAX    = {NUM_CAST_MAX},\n")
    file.write(f"parameter NUM_ENGINES_MAX = {NUM_ENGINES_MAX},\n\n")

    file.write(f"parameter NUM_CUS     = {NUM_CUS},\n")
    file.write(f"parameter NUM_BUNDLES = {NUM_BUNDLES},\n")
    file.write(f"parameter NUM_LANES   = {NUM_LANES},\n")
    file.write(f"parameter NUM_BACKTRACK_LANES   = {NUM_LANES},\n")
    file.write(f"parameter NUM_ENGINES = {NUM_ENGINES},\n\n")

    file.write(f"parameter NUM_CUS_INDEX     = {NUM_CUS},\n")
    file.write(f"parameter NUM_BUNDLES_INDEX = {NUM_BUNDLES},\n")
    file.write(f"parameter NUM_LANES_INDEX   = {NUM_LANES},\n")
    file.write(f"parameter NUM_ENGINES_INDEX = {NUM_ENGINES},\n\n")

    file.write(f"parameter CACHE_CONFIG_MAX_NUM_WAYS   = {CACHE_CONFIG_MAX_NUM_WAYS},\n")
    file.write(f"parameter CACHE_CONFIG_MAX_SIZE = {CACHE_CONFIG_MAX_SIZE},\n\n")

    # ... [The previous writing for the arrays here] ...
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// TOPOLOGY CONFIGURATIONS CHANNEL\n")
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write(f"parameter NUM_CHANNELS_MAX = {NUM_CHANNELS_MAX},\n")
    file.write("parameter int CHANNEL_CONFIG_L1_CACHE[NUM_CHANNELS_MAX]               =" + vhdl_format(CHANNEL_CONFIG_L1) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_L2_CACHE[NUM_CHANNELS_MAX]               =" + vhdl_format(CHANNEL_CONFIG_L2) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_DATA_WIDTH_BE[NUM_CHANNELS_MAX]          =" + vhdl_format(CHANNEL_CONFIG_DATA_WIDTH_BE) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_ADDRESS_WIDTH_BE[NUM_CHANNELS_MAX]       =" + vhdl_format(CHANNEL_CONFIG_ADDRESS_WIDTH_BE) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_DATA_WIDTH_MID[NUM_CHANNELS_MAX]         =" + vhdl_format(CHANNEL_CONFIG_DATA_WIDTH_MID) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_ADDRESS_WIDTH_MID[NUM_CHANNELS_MAX]      =" + vhdl_format(CHANNEL_CONFIG_ADDRESS_WIDTH_MID) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_DATA_WIDTH_FE[NUM_CHANNELS_MAX]          =" + vhdl_format(CHANNEL_CONFIG_DATA_WIDTH_FE) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_ADDRESS_WIDTH_FE[NUM_CHANNELS_MAX]       =" + vhdl_format(CHANNEL_CONFIG_ADDRESS_WIDTH_FE) + ",\n")

    file.write("parameter int CACHE_CONFIG_L2_SIZE[NUM_CHANNELS_MAX]         =" + vhdl_format(CACHE_CONFIG_L2_SIZE) + ",\n")
    file.write("parameter int CACHE_CONFIG_L2_NUM_WAYS[NUM_CHANNELS_MAX]      =" + vhdl_format(CACHE_CONFIG_L2_NUM_WAYS) + ",\n")
    file.write("parameter int CACHE_CONFIG_L1_SIZE[NUM_CHANNELS_MAX]          =" + vhdl_format(CACHE_CONFIG_L1_SIZE) + ",\n")
    file.write("parameter int CACHE_CONFIG_L1_NUM_WAYS[NUM_CHANNELS_MAX]       =" + vhdl_format(CACHE_CONFIG_L1_NUM_WAYS) + ",\n")
    file.write("parameter int CACHE_CONFIG_L1_PREFETCH[NUM_CHANNELS_MAX]       =" + vhdl_format(CACHE_CONFIG_L1_PREFETCH) + ",\n")

    
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// TOPOLOGY CONFIGURATIONS DEFAULTS\n")
    file.write("// --------------------------------------------------------------------------------------\n")

    file.write(f"parameter CU_BUNDLES_COUNT_ARRAY                           = {NUM_BUNDLES_MAX},\n")
    file.write("parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE) + ",\n")  
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE) + ",\n")  
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_REQUEST).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_RESPONSE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE) + ",\n")  
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE) + ",\n")  
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = " + str(CU_BUNDLES_ENGINE_ID_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))
    file.write("parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST} ,\n")   
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE} ,\n")  
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY} ,\n")   
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST} ,\n")   
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE} ,\n")  
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY} ,\n")   
    
    file.write(f"parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST} ,\n") 
    file.write(f"parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE} ,\n")  
    file.write(f"parameter int BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY} ,\n")   
    file.write(f"parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST} ,\n") 
    file.write(f"parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE} ,\n")  
    file.write(f"parameter int BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY} ,\n")   
    file.write(f"parameter BUNDLES_COUNT_ARRAY                                                                                  = {NUM_BUNDLES_MAX},\n")
    file.write("parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE) + ",\n")  
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE) + ",\n")  
    file.write("parameter int BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_REQUEST).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_RESPONSE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE) + ",\n")  
    file.write("parameter int BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE)+ ",\n")    
    file.write("parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE) + ",\n")  
    file.write("parameter int BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = " + str(CU_BUNDLES_ENGINE_ID_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))
    file.write("parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
   
    file.write("parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                    = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_LANES_MAX][NUM_ENGINES_MAX]                     =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_LANES_MAX][NUM_ENGINES_MAX]                   =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST[0])+ ",\n")   
    file.write("parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE[0])+ ",\n")    
    file.write("parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE[0]) + ",\n")  
    file.write("parameter int LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[0])+ ",\n")   
    file.write("parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[0])+ ",\n")    
    file.write("parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[0]) + ",\n")  
    file.write("parameter int LANES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_LANES_MAX][NUM_ENGINES_MAX]   = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_LANES_MAX][NUM_ENGINES_MAX]   = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_LANES_MAX][NUM_ENGINES_MAX]    = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_LANES_MAX][NUM_ENGINES_MAX]   = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_LANES_MAX][NUM_ENGINES_MAX]   = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_REQUEST[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_LANES_MAX][NUM_ENGINES_MAX]   = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_LANES_MAX][NUM_ENGINES_MAX]    = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_LANES_MAX][NUM_ENGINES_MAX]   = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[0])+ ",\n")    
    file.write("parameter int LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[0])+ ",\n")    
    file.write("parameter int LANES_CONFIG_LANE_ARBITER_NUM_ENGINE[NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE[0]) + ",\n")  
    file.write("parameter int LANES_CONFIG_LANE_ARBITER_NUM_MEMORY[NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                     = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[0])+ ",\n")    
    file.write("parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[0])+ ",\n")    
    file.write("parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[0]) + ",\n")  
    file.write("parameter int LANES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY                                                = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY                                               = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                      = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                     = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MERGE_CONNECT_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX]        = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))
    file.write("parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = " + str(CU_BUNDLES_ENGINE_ID_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write(f"parameter int LANES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST} ,\n")  
    file.write(f"parameter int LANES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int LANES_CONFIG_CU_ARBITER_NUM_ENGINE =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE} ,\n")  
    file.write(f"parameter int LANES_CONFIG_CU_ARBITER_NUM_MEMORY =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY} ,\n")   
    file.write(f"parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST} ,\n")  
    file.write(f"parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE} ,\n")  
    file.write(f"parameter int LANES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY} ,\n")   

    file.write("parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                          = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_ENGINES_MAX]                             =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_ENGINES_MAX]                           =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST[0])+ ",\n")   
    file.write("parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE[0])+ ",\n")  
    file.write("parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_ENGINE[0]) + ",\n")  
    file.write("parameter int ENGINES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY[0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[0])+ ",\n")   
    file.write("parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[0])+ ",\n")  
    file.write("parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[0]) + ",\n")  
    file.write("parameter int ENGINES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[NUM_ENGINES_MAX]  = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_ENGINE[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[NUM_ENGINES_MAX]  = " + str(CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_REQUEST[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_ENGINES_MAX]  = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_ENGINES_MAX]  = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST   = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[0][0])+ ",\n")  
    file.write("parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE   = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[0][0])+ ",\n")    
    file.write("parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_ENGINE    = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_ENGINE[0][0]) + ",\n")  
    file.write("parameter int ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY    = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST   = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_REQUEST[0][0])+ ",\n")  
    file.write("parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE   = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL_RESPONSE[0][0])+ ",\n")    
    file.write("parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE    = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[0][0]) + ",\n")  
    file.write("parameter int ENGINES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY    = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY                                            = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY                                           = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MERGE_CONNECT_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]              = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]       = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MERGE_WIDTH_ARRAY[NUM_ENGINES_MAX]                              = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[0]).replace("[", "'{").replace("]", "}") + ",\n")
    file.write("parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                       = " + str(CU_BUNDLES_ENGINE_ID_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write(f"parameter int ENGINES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST} ,\n") 
    file.write(f"parameter int ENGINES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int ENGINES_CONFIG_CU_ARBITER_NUM_ENGINE =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_ENGINE} ,\n")  
    file.write(f"parameter int ENGINES_CONFIG_CU_ARBITER_NUM_MEMORY =  {CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY} ,\n")   
    file.write(f"parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_REQUEST} ,\n") 
    file.write(f"parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL_RESPONSE} ,\n")   
    file.write(f"parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE} ,\n")  
    file.write(f"parameter int ENGINES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY}\n")   

    file.write(f"// total_luts={total_luts}\n\n")  
   


# Write to VHDL file
with open(output_file_bundle_topology, "w") as file:
    cast_count = [0] * NUM_LANES

    for j in range(NUM_BUNDLES):
        LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY      = CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[j]      
        LANES_CONFIG_MAX_CAST_WIDTH_ARRAY       = CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[j]       
        LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY  = CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[j]  
        LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY = CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[j] 
        LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY = CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[j] 
        LANES_CONFIG_ARRAY                      = CU_BUNDLES_CONFIG_ARRAY[j]                      
        LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN       = CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[j]                    
        LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH     = CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[j]      
        LANES_CONFIG_CAST_WIDTH_ARRAY           = CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[j]           
        LANES_CONFIG_LANE_CAST_WIDTH_ARRAY      = CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]      
        LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY     = CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]     
        LANES_CONFIG_MERGE_CONNECT_ARRAY        = CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[j]        
        LANES_CONFIG_MERGE_WIDTH_ARRAY          = CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[j]          
        LANES_ENGINE_ID_ARRAY                   = CU_BUNDLES_ENGINE_ID_ARRAY[j]                   
        ENGINES_COUNT_ARRAY                     = CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[j]                 
        ID_BUNDLE                               = j                                            
        NUM_LANES                               = CU_BUNDLES_COUNT_ARRAY[j]   
        file.write("\n")
        file.write(f"generate\n")
        file.write(f"     if(ID_BUNDLE == {j})\n")
        file.write(f"                    begin\n")         
        for lane_merge in range(NUM_LANES):
            lane_merge_l = lane_merge
            LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY_L = LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[lane_merge_l]
            

            file.write(f"                      assign lanes_fifo_request_cast_lane_out_signals_in[{lane_merge_l}][0]  = lanes_fifo_request_lane_out_signals_in[{lane_merge_l}];\n")
            file.write(f"                      assign lanes_fifo_request_lane_out_signals_out[{lane_merge_l}]         = lanes_fifo_request_cast_lane_out_signals_out [{lane_merge_l}][0];\n")
            file.write(f"                      assign lanes_fifo_response_lane_in_signals_out[{lane_merge_l}]         = lanes_fifo_response_merge_lane_in_signals_out[{lane_merge_l}][0];\n")
            file.write(f"                      assign lanes_fifo_response_merge_lane_in_signals_in[{lane_merge_l}][0] = lanes_fifo_response_lane_in_signals_in[{lane_merge_l}];\n")
            file.write(f"                      assign lanes_request_lane_out[{lane_merge_l}]                          = lanes_request_cast_lane_out[{lane_merge_l}][0];\n")
            file.write(f"                      assign lanes_response_merge_engine_in[{lane_merge_l}][0]               = lanes_response_engine_in[{lane_merge_l}];\n\n")


            if LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY_L != 0:
                merge_count = 0
                for lane_cast in range(NUM_LANES):
                    lane_cast_l = lane_cast
                    LANES_CONFIG_LANE_CAST_WIDTH_ARRAY_L = LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[lane_cast_l]
                    ENGINES_COUNT_ARRAY_L = ENGINES_COUNT_ARRAY[lane_cast_l]

                    if LANES_CONFIG_LANE_CAST_WIDTH_ARRAY_L != 0 and lane_cast_l != lane_merge_l:
                        for engine_idx in range(ENGINES_COUNT_ARRAY_L):
                            engine_idx_l = engine_idx
                            LANES_CONFIG_CAST_WIDTH_ARRAY_L = LANES_CONFIG_CAST_WIDTH_ARRAY[lane_cast_l][engine_idx_l]

                            for cast_idx in range(LANES_CONFIG_CAST_WIDTH_ARRAY_L):
                                cast_idx_l = cast_idx
                                LANES_CONFIG_MERGE_CONNECT_ARRAY_L = LANES_CONFIG_MERGE_CONNECT_ARRAY[lane_cast_l][engine_idx_l][cast_idx_l]

                                if LANES_CONFIG_MERGE_CONNECT_ARRAY_L == lane_merge_l:
                                    merge_count += 1
                                    cast_count[lane_cast_l] += 1
                                    file.write(f"                      assign lanes_fifo_request_cast_lane_out_signals_in[{lane_cast_l}][{cast_count[lane_cast_l]}].rd_en             = ~lanes_fifo_response_merge_lane_in_signals_out[{lane_merge_l}][{merge_count}].prog_full;\n")
                                    file.write(f"                      assign lanes_fifo_response_merge_lane_in_signals_in[{lane_merge_l}][{merge_count}].rd_en             = 1'b1;\n")
                                    file.write(f"                      assign lanes_response_merge_engine_in[{lane_merge_l}][{merge_count}]                                 = lanes_request_cast_lane_out[{lane_cast_l}][{cast_count[lane_cast_l]}];\n\n")
                               

        file.write(f"                    end\n") 
        file.write(f"endgenerate\n")
    
    file.write(f"// total_luts={total_luts}\n\n")   


# Write to VHDL file
with open(output_file_lane_topology, "w") as file:
    cast_count = [0] * NUM_LANES

    for j in range(NUM_BUNDLES):
        LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY      = CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[j]      
        LANES_CONFIG_MAX_CAST_WIDTH_ARRAY       = CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[j]       
        LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY  = CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[j]  
        LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY = CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[j] 
        LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY = CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[j] 
        LANES_CONFIG_ARRAY                      = CU_BUNDLES_CONFIG_ARRAY[j]                      
        LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN       = CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[j]                    
        LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH     = CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[j]      
        LANES_CONFIG_CAST_WIDTH_ARRAY           = CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[j]           
        LANES_CONFIG_LANE_CAST_WIDTH_ARRAY      = CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[j]      
        LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY     = CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[j]     
        LANES_CONFIG_MERGE_CONNECT_ARRAY        = CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[j]        
        LANES_CONFIG_MERGE_WIDTH_ARRAY          = CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[j]          
        LANES_ENGINE_ID_ARRAY                   = CU_BUNDLES_ENGINE_ID_ARRAY[j]                   
        ENGINES_COUNT_ARRAY                     = CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[j]                 
        ID_BUNDLE                               = j                                            
        NUM_LANES                               = CU_BUNDLES_COUNT_ARRAY[j]   
        
        for l in range(NUM_LANES):

            ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY   =LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[l]          
            ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY    =LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[l]           
            ENGINES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY  =LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[l] 
            ENGINES_CONFIG_ARRAY                   =LANES_CONFIG_ARRAY[l]                          
            ENGINES_CONFIG_ARRAY_ENGINE_SEQ_MIN    =LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[l]                                 
            ENGINES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH  =LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[l]          
            ENGINES_CONFIG_CAST_WIDTH_ARRAY        =LANES_CONFIG_CAST_WIDTH_ARRAY[l]               
            ENGINES_CONFIG_MERGE_CONNECT_ARRAY     =LANES_CONFIG_MERGE_CONNECT_ARRAY[l]            
            ENGINES_CONFIG_MERGE_WIDTH_ARRAY       =LANES_CONFIG_MERGE_WIDTH_ARRAY[l]              
            ENGINES_ENGINE_ID_ARRAY                =LANES_ENGINE_ID_ARRAY[l]                       
            ID_LANE                                =l                                              
            LANE_CAST_WIDTH                        =LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[l]          
            LANE_MERGE_WIDTH                       =LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[l]         
            NUM_ENGINES                            =ENGINES_COUNT_ARRAY[l]                         


            file.write("\n")
            file.write(f"generate\n")
            file.write(f"     if((ID_BUNDLE == {j}) && (ID_LANE == {l}))\n")
            file.write(f"          begin\n")       

            # Initialize counters
            cast_count = 0
            merge_count = 0

            # Ensure NUM_ENGINES is an integer or use NUM_ENGINES[0] if it's a list containing the integer value
            for engine_idx in range(NUM_ENGINES):
                engine_idx_l = engine_idx
                ENGINES_CONFIG_MERGE_WIDTH_ARRAY_L = ENGINES_CONFIG_MERGE_WIDTH_ARRAY[engine_idx_l]
                ENGINES_CONFIG_CAST_WIDTH_ARRAY_L = ENGINES_CONFIG_CAST_WIDTH_ARRAY[engine_idx_l]

                file.write(f"               assign engines_response_merge_lane_in[{engine_idx_l}][0]        = engines_response_lane_in[{engine_idx_l}];\n")
                file.write(f"               assign engines_fifo_response_merge_lane_in_signals_in[{engine_idx_l}][0].rd_en = 1'b1;\n")
                file.write(f"               assign engines_fifo_response_lane_in_signals_out[{engine_idx_l}] = engines_fifo_response_merge_lane_in_signals_out[{engine_idx_l}][0];\n")

                file.write(f"               assign engines_request_lane_out[{engine_idx_l}]                  = engines_request_cast_lane_out[{engine_idx_l}][0];\n")
                file.write(f"               assign engines_fifo_request_cast_lane_out_signals_in[{engine_idx_l}][0].rd_en = engines_fifo_request_lane_out_signals_in[{engine_idx_l}].rd_en ;\n")
                file.write(f"               assign engines_fifo_request_lane_out_signals_out[{engine_idx_l}] = engines_fifo_request_cast_lane_out_signals_out [{engine_idx_l}][0];\n\n")
    
                for engine_merge in range(ENGINES_CONFIG_MERGE_WIDTH_ARRAY_L):
                    engine_merge_l = engine_merge
                    merge_count += 1
                   
                    file.write(f"               assign engines_response_merge_lane_in[{engine_idx_l}][{engine_merge_l+1}]          = response_lane_in[{merge_count}];\n")
                    file.write(f"               assign engines_fifo_response_merge_lane_in_signals_in[{engine_idx_l}][{engine_merge_l+1}].rd_en = 1'b1;\n")
                    file.write(f"               assign fifo_response_lane_in_signals_out[{merge_count}] = engines_fifo_response_merge_lane_in_signals_out[{engine_idx_l}][{engine_merge_l+1}];\n\n")

                for engine_cast in range(ENGINES_CONFIG_CAST_WIDTH_ARRAY_L):
                    engine_cast_l = engine_cast
                    cast_count += 1

                    file.write(f"               assign request_lane_out[{cast_count}]                  = engines_request_cast_lane_out[{engine_idx_l}][{engine_cast_l+1}];\n")
                    file.write(f"               assign engines_fifo_request_cast_lane_out_signals_in[{engine_idx_l}][{engine_cast_l+1}].rd_en = fifo_request_lane_out_signals_in[{cast_count}].rd_en;\n")
                    file.write(f"               assign fifo_request_lane_out_signals_out[{cast_count}] = engines_fifo_request_cast_lane_out_signals_out[{engine_idx_l}][{engine_cast_l+1}];\n\n")

            file.write(f"          end\n") 
            file.write(f"endgenerate\n")
            file.write(f"\n\n") 

    file.write(f"// total_luts={total_luts}\n\n")   
                   

with open(output_file_lane_arbitration, "w") as file:
    for ID_BUNDLE in range(NUM_BUNDLES):

        NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE]
        ENGINES_COUNT_ARRAY                  = CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[ID_BUNDLE]     


        LANES_CONFIG_ENGINE_ARBITER_NUM_MEMORY = CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[ID_BUNDLE]
        LANES_CONFIG_LANE_ARBITER_NUM_MEMORY = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[ID_BUNDLE]

        for ID_LANE in range(NUM_LANES):

            NUM_ENGINES = ENGINES_COUNT_ARRAY[ID_LANE]
            ENGINES_CONFIG_ENGINE_ARBITER_NUM_MEMORY = LANES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[ID_LANE]
            ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY = LANES_CONFIG_LANE_ARBITER_NUM_MEMORY[ID_LANE]

            if ENGINES_CONFIG_LANE_ARBITER_NUM_MEMORY:

                file.write("\n")
                file.write(f"generate\n")
                file.write(f"     if((ID_BUNDLE == {ID_BUNDLE}) && (ID_LANE == {ID_LANE}))\n")
                file.write(f"          begin\n")  

                REAL_ID_ENGINE = 0;
                for ID_ENGINE in range(NUM_ENGINES):
                    MAP_ENGINE = ENGINES_CONFIG_ENGINE_ARBITER_NUM_MEMORY[ID_ENGINE]
  
                    if MAP_ENGINE:
                        file.write(f"               assign engine_arbiter_N_to_1_memory_request_in[{REAL_ID_ENGINE}] = engines_request_memory_out[{ID_ENGINE}];\n")
                        file.write(f"               assign engines_fifo_request_memory_out_signals_in[{ID_ENGINE}].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[{ID_ENGINE}];\n")
                        REAL_ID_ENGINE += 1
                    else:
                        file.write(f"               assign engines_fifo_request_memory_out_signals_in[{ID_ENGINE}].rd_en  = 1'b0;\n")

                for ID_ENGINE in range(REAL_ID_ENGINE,NUM_ENGINES):
                    file.write(f"               assign engine_arbiter_N_to_1_memory_request_in[{ID_ENGINE}] = 0;\n")
                    file.write(f"               assign engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[{ID_ENGINE}] = 1'b0;\n")

                file.write(f"               assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;\n")
                file.write(f"          end\n") 
                file.write(f"endgenerate\n")
                file.write(f"\n\n") 

    for ID_BUNDLE in range(NUM_BUNDLES):

        NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE]
        ENGINES_COUNT_ARRAY                  = CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[ID_BUNDLE]     


        LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST = CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[ID_BUNDLE]
        LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[ID_BUNDLE]

        for ID_LANE in range(NUM_LANES):

            NUM_ENGINES = ENGINES_COUNT_ARRAY[ID_LANE]
            ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST = LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[ID_LANE]
            ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST = LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[ID_LANE]

            if ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST:

                file.write("\n")
                file.write(f"generate\n")
                file.write(f"     if((ID_BUNDLE == {ID_BUNDLE}) && (ID_LANE == {ID_LANE}))\n")
                file.write(f"          begin\n")  

                REAL_ID_ENGINE = 0;
                for ID_ENGINE in range(NUM_ENGINES):
                    MAP_ENGINE = ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_REQUEST[ID_ENGINE]

                    if MAP_ENGINE:
                        file.write(f"               assign engine_arbiter_N_to_1_control_request_in[{REAL_ID_ENGINE}] = engines_request_control_out[{ID_ENGINE}];\n")
                        file.write(f"               assign engines_fifo_request_control_out_signals_in[{ID_ENGINE}].rd_en  = ~engine_arbiter_N_to_1_control_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_control_engine_arbiter_grant_out[{REAL_ID_ENGINE}];\n")
                        REAL_ID_ENGINE += 1
                    else:
                        file.write(f"               assign engines_fifo_request_control_out_signals_in[{ID_ENGINE}].rd_en  = 1'b0;\n")
                
                for ID_ENGINE in range(REAL_ID_ENGINE,NUM_ENGINES):
                    file.write(f"               assign engine_arbiter_N_to_1_control_request_in[{ID_ENGINE}] = 0;\n")
                    file.write(f"               assign engine_arbiter_N_to_1_control_engine_arbiter_grant_out[{ID_ENGINE}] = 1'b0;\n")

                file.write(f"               assign engine_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;\n")
                file.write(f"          end\n") 
                file.write(f"endgenerate\n")
                file.write(f"\n\n") 

    # for ID_BUNDLE in range(NUM_BUNDLES):

    #     NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE]
    #     ENGINES_COUNT_ARRAY                  = CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[ID_BUNDLE]     


    #     LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE = CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[ID_BUNDLE]
    #     LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[ID_BUNDLE]

    #     for ID_LANE in range(NUM_LANES):

    #         NUM_ENGINES = ENGINES_COUNT_ARRAY[ID_LANE]
    #         ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE = LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[ID_LANE]
    #         ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE = LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[ID_LANE]

    #         if ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE:

    #             file.write("\n")
    #             file.write(f"generate\n")
    #             file.write(f"     if((ID_BUNDLE == {ID_BUNDLE}) && (ID_LANE == {ID_LANE}))\n")
    #             file.write(f"          begin\n")  

    #             REAL_ID_ENGINE = 0;
    #             for ID_ENGINE in range(NUM_ENGINES):
    #                 MAP_ENGINE = ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[ID_ENGINE]

    #                 if MAP_ENGINE:
    #                     file.write(f"               assign engine_arbiter_1_to_N_control_fifo_response_signals_in[{REAL_ID_ENGINE}].rd_en = ~engines_fifo_response_control_in_signals_out[{ID_ENGINE}].prog_full & fifo_response_control_in_signals_in_reg.rd_en;\n")
    #                     file.write(f"               assign engines_response_control_in[{ID_ENGINE}] = engine_arbiter_1_to_N_control_response_out[{REAL_ID_ENGINE}];\n")
    #                     file.write(f"               assign engines_fifo_response_control_in_signals_in[{ID_ENGINE}].rd_en = 1'b1;\n")
    #                     REAL_ID_ENGINE += 1
    #                 else:
    #                     file.write(f"               assign engines_response_control_in[{ID_ENGINE}] = 0;\n")
    #                     file.write(f"               assign engines_fifo_response_control_in_signals_in[{ID_ENGINE}].rd_en = 1'b0;\n")

    #             for ID_ENGINE in range(REAL_ID_ENGINE,NUM_ENGINES):
    #                 file.write(f"               assign engine_arbiter_1_to_N_control_fifo_response_signals_in[{ID_ENGINE}].rd_en = 1'b0;\n")

    #             file.write(f"               assign engine_arbiter_1_to_N_control_response_in = response_control_in_int;\n")
    #             file.write(f"          end\n") 
    #             file.write(f"endgenerate\n")
    #             file.write(f"\n\n") 


with open(output_file_bundle_arbitration, "w") as file:
    for ID_BUNDLE in range(NUM_BUNDLES):

        NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE] 
        LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY[ID_BUNDLE]
        LANES_CONFIG_LANE_ARBITER_NUM_MEMORY = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_MEMORY[ID_BUNDLE]

        if LANES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY:

            file.write("\n")
            file.write(f"generate\n")
            file.write(f"     if(ID_BUNDLE == {ID_BUNDLE})\n")
            file.write(f"          begin\n")  

            REAL_ID_LANE = 0;
            for ID_LANE in range(NUM_LANES):
                MAP_LANE = LANES_CONFIG_LANE_ARBITER_NUM_MEMORY[ID_LANE]

                if MAP_LANE:
                    file.write(f"               assign lane_arbiter_N_to_1_memory_request_in[{REAL_ID_LANE}] = lanes_request_memory_out[{ID_LANE}];\n")
                    file.write(f"               assign lanes_fifo_request_memory_out_signals_in[{ID_LANE}].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[{REAL_ID_LANE}];\n")
                    REAL_ID_LANE += 1
                else:
                    file.write(f"               assign lanes_fifo_request_memory_out_signals_in[{ID_LANE}].rd_en  = 1'b0;\n")

            for ID_LANE in range(REAL_ID_LANE,NUM_LANES):
                file.write(f"               assign lane_arbiter_N_to_1_memory_request_in[{ID_LANE}] = 0;\n")
                file.write(f"               assign lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[{ID_LANE}] = 1'b0;\n")

            file.write(f"               assign lane_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;\n")
            file.write(f"          end\n") 
            file.write(f"endgenerate\n")
            file.write(f"\n\n") 

    for ID_BUNDLE in range(NUM_BUNDLES):

        NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE] 
        LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST[ID_BUNDLE]
        LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[ID_BUNDLE]

        if LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST:

            file.write("\n")
            file.write(f"generate\n")
            file.write(f"     if(ID_BUNDLE == {ID_BUNDLE})\n")
            file.write(f"          begin\n")  

            REAL_ID_LANE = 0;
            for ID_LANE in range(NUM_LANES):
                MAP_LANE = LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_REQUEST[ID_LANE]

                if MAP_LANE:
                    file.write(f"               assign lane_arbiter_N_to_1_control_request_in[{REAL_ID_LANE}] = lanes_request_control_out[{ID_LANE}];\n")
                    file.write(f"               assign lanes_fifo_request_control_out_signals_in[{ID_LANE}].rd_en  = ~lane_arbiter_N_to_1_control_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_control_lane_arbiter_grant_out[{REAL_ID_LANE}];\n")
                    REAL_ID_LANE += 1
                else:
                    file.write(f"               assign lanes_fifo_request_control_out_signals_in[{ID_LANE}].rd_en  = 1'b0;\n")

            for ID_LANE in range(REAL_ID_LANE,NUM_LANES):
                file.write(f"               assign lane_arbiter_N_to_1_control_request_in[{ID_LANE}] = 0;\n")
                file.write(f"               assign lane_arbiter_N_to_1_control_lane_arbiter_grant_out[{ID_LANE}] = 1'b0;\n")

            file.write(f"               assign lane_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;\n")
            file.write(f"          end\n") 
            file.write(f"endgenerate\n")
            file.write(f"\n\n") 

    # for ID_BUNDLE in range(NUM_BUNDLES):

    #     NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE] 
    #     LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE  = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE [ID_BUNDLE]
    #     LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE  = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE [ID_BUNDLE]

    #     if LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE :

    #         file.write("\n")
    #         file.write(f"generate\n")
    #         file.write(f"     if(ID_BUNDLE == {ID_BUNDLE})\n")
    #         file.write(f"          begin\n")  

    #         REAL_ID_LANE = 0;
    #         for ID_LANE in range(NUM_LANES):
    #             MAP_LANE = LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[ID_LANE]

    #             if MAP_LANE:
    #                 file.write(f"               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[{REAL_ID_LANE}].rd_en = ~lanes_fifo_response_control_in_signals_out[{ID_LANE}].prog_full & fifo_response_control_in_signals_in_reg.rd_en;\n")
    #                 file.write(f"               assign lanes_response_control_in[{ID_LANE}] = lane_arbiter_1_to_N_control_response_out[{REAL_ID_LANE}];\n")
    #                 file.write(f"               assign lanes_fifo_response_control_in_signals_in[{ID_LANE}].rd_en = 1'b1;\n")
    #                 REAL_ID_LANE += 1
    #             else:
    #                 file.write(f"               assign lanes_response_control_in[{ID_LANE}] = 0;\n")
    #                 file.write(f"               assign lanes_fifo_response_control_in_signals_in[{ID_LANE}].rd_en = 1'b0;\n")

    #         for ID_LANE in range(REAL_ID_LANE,NUM_LANES):
    #             file.write(f"               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[{ID_LANE}].rd_en = 1'b0;\n")
                   

    #         file.write(f"               assign lane_arbiter_1_to_N_control_response_in = response_control_in_int;\n")
    #         file.write(f"          end\n") 
    #         file.write(f"endgenerate\n")
    #         file.write(f"\n\n") 


with open(output_file_cu_arbitration, "w") as file:

    if CU_BUNDLES_CONFIG_CU_ARBITER_NUM_MEMORY:

        file.write("\n")
        file.write(f"generate\n")
        file.write(f"     if(ID_CU == 0)\n")
        file.write(f"          begin\n")  

        REAL_ID_BUNDLE = 0;
        for ID_BUNDLE in range(NUM_BUNDLES):
            MAP_BUNDLE  = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_MEMORY_TEMP[ID_BUNDLE]

            if MAP_BUNDLE:
                file.write(f"               assign bundle_arbiter_memory_N_to_1_request_in[{REAL_ID_BUNDLE}] = bundle_request_memory_out[{ID_BUNDLE}];\n")
                file.write(f"               assign bundle_fifo_request_memory_out_signals_in[{ID_BUNDLE}].rd_en  = ~bundle_arbiter_memory_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_memory_N_to_1_arbiter_grant_out[{REAL_ID_BUNDLE}];\n")
                REAL_ID_BUNDLE += 1
            else:
                file.write(f"               assign bundle_fifo_request_memory_out_signals_in[{ID_BUNDLE}].rd_en  = 1'b0;\n")

        for ID_BUNDLE in range(REAL_ID_BUNDLE,NUM_BUNDLES):
            file.write(f"               assign bundle_arbiter_memory_N_to_1_request_in[{ID_BUNDLE}] = 0;\n")
            file.write(f"               assign bundle_arbiter_memory_N_to_1_arbiter_grant_out[{ID_BUNDLE}] = 1'b0;\n")
               
        file.write(f"               assign bundle_arbiter_memory_N_to_1_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;\n")
        file.write(f"          end\n") 
        file.write(f"endgenerate\n")
        file.write(f"\n\n") 

    if CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_REQUEST:

        file.write("\n")
        file.write(f"generate\n")
        file.write(f"     if(ID_CU == 0)\n")
        file.write(f"          begin\n")  

        REAL_ID_BUNDLE = 0;
        for ID_BUNDLE in range(NUM_BUNDLES):
            MAP_BUNDLE  = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_REQUEST_TEMP[ID_BUNDLE]

            if MAP_BUNDLE:
                file.write(f"               assign bundle_arbiter_control_N_to_1_request_in[{REAL_ID_BUNDLE}] = bundle_request_control_out[{ID_BUNDLE}];\n")
                file.write(f"               assign bundle_fifo_request_control_out_signals_in[{ID_BUNDLE}].rd_en  = ~bundle_arbiter_control_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_control_N_to_1_arbiter_grant_out[{REAL_ID_BUNDLE}];\n")
                REAL_ID_BUNDLE += 1
            else:
                file.write(f"               assign bundle_fifo_request_control_out_signals_in[{ID_BUNDLE}].rd_en  = 1'b0;\n")

        for ID_BUNDLE in range(REAL_ID_BUNDLE,NUM_BUNDLES):
            file.write(f"               assign bundle_arbiter_control_N_to_1_request_in[{ID_BUNDLE}]  = 0;\n")
            file.write(f"               assign bundle_arbiter_control_N_to_1_arbiter_grant_out[{ID_BUNDLE}]  = 1'b0;\n")

        file.write(f"               assign bundle_arbiter_control_N_to_1_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;\n")
        file.write(f"          end\n") 
        file.write(f"endgenerate\n")
        file.write(f"\n\n") 

    # if CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE:

    #     file.write("\n")
    #     file.write(f"generate\n")
    #     file.write(f"     if(ID_CU == 0)\n")
    #     file.write(f"          begin\n")  

    #     REAL_ID_BUNDLE = 0;
    #     for ID_BUNDLE in range(NUM_BUNDLES):
    #         MAP_BUNDLE  = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE_TEMP[ID_BUNDLE]

    #         if MAP_BUNDLE:
    #             file.write(f"               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[{REAL_ID_BUNDLE}].rd_en = ~bundle_fifo_response_control_in_signals_out[{ID_BUNDLE}].prog_full & fifo_response_control_in_signals_in_reg.rd_en;\n")
    #             file.write(f"               assign bundle_response_control_in[{ID_BUNDLE}] = bundle_arbiter_control_1_to_N_response_out[{REAL_ID_BUNDLE}];\n")
    #             file.write(f"               assign bundle_fifo_response_control_in_signals_in[{ID_BUNDLE}].rd_en = 1'b1;\n")
    #             REAL_ID_BUNDLE += 1
    #         else:
    #             file.write(f"               assign bundle_response_control_in[{ID_BUNDLE}] = 0;\n")
    #             file.write(f"               assign bundle_fifo_response_control_in_signals_in[{ID_BUNDLE}].rd_en = 1'b0;\n")

    #     for ID_BUNDLE in range(REAL_ID_BUNDLE,NUM_BUNDLES):
    #         file.write(f"               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[{ID_BUNDLE}].rd_en = 1'b0;\n")


    #     file.write(f"               assign bundle_arbiter_control_1_to_N_response_in = response_control_in_int;\n")
    #     file.write(f"          end\n") 
    #     file.write(f"endgenerate\n")
    #     file.write(f"\n\n") 


with open(output_file_afu_topology, 'w') as file:
    output_lines = []

    parameters_template = """
M{0:02d}_AXI4_BE_MasterReadInterface  m{0:02d}_axi4_read ;
M{0:02d}_AXI4_BE_MasterWriteInterface m{0:02d}_axi4_write;

M{0:02d}_AXI4_MID_SlaveReadInterfaceOutput  kernel_s{0:02d}_axi_read_out ;
M{0:02d}_AXI4_MID_SlaveReadInterfaceInput   kernel_s{0:02d}_axi_read_in  ;
M{0:02d}_AXI4_MID_SlaveWriteInterfaceOutput kernel_s{0:02d}_axi_write_out;
M{0:02d}_AXI4_MID_SlaveWriteInterfaceInput  kernel_s{0:02d}_axi_write_in ;

M{0:02d}_AXI4_BE_MasterReadInterfaceInput   kernel_m{0:02d}_axi4_read_in  ;
M{0:02d}_AXI4_BE_MasterReadInterfaceOutput  kernel_m{0:02d}_axi4_read_out ;
M{0:02d}_AXI4_BE_MasterWriteInterfaceInput  kernel_m{0:02d}_axi4_write_in ;
M{0:02d}_AXI4_BE_MasterWriteInterfaceOutput kernel_m{0:02d}_axi4_write_out;

M{0:02d}_AXI4_LITE_MID_RESP_T               kernel_m{0:02d}_axi_lite_in ;
M{0:02d}_AXI4_LITE_MID_REQ_T                kernel_m{0:02d}_axi_lite_out;

"""

    assign_template = """
// --------------------------------------------------------------------------------------
// Channel {1} READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m{0:02d}_axi4_read.in.rvalid  = m{0:02d}_axi_rvalid ; // Read channel valid
assign m{0:02d}_axi4_read.in.arready = m{0:02d}_axi_arready; // Address read channel ready
assign m{0:02d}_axi4_read.in.rlast   = m{0:02d}_axi_rlast  ; // Read channel last word
assign m{0:02d}_axi4_read.in.rdata   = swap_endianness_cacheline_m{0:02d}_axi_be(m{0:02d}_axi_rdata, endian_read_reg)  ; // Read channel data
assign m{0:02d}_axi4_read.in.rid     = m{0:02d}_axi_rid    ; // Read channel ID
assign m{0:02d}_axi4_read.in.rresp   = m{0:02d}_axi_rresp  ; // Read channel response

// --------------------------------------------------------------------------------------
// Channel {1} READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m{0:02d}_axi_arvalid = m{0:02d}_axi4_read.out.arvalid; // Address read channel valid
assign m{0:02d}_axi_araddr  = m{0:02d}_axi4_read.out.araddr ; // Address read channel address
assign m{0:02d}_axi_arlen   = m{0:02d}_axi4_read.out.arlen  ; // Address write channel burst length
assign m{0:02d}_axi_rready  = m{0:02d}_axi4_read.out.rready ; // Read channel ready
assign m{0:02d}_axi_arid    = m{0:02d}_axi4_read.out.arid   ; // Address read channel ID
assign m{0:02d}_axi_arsize  = m{0:02d}_axi4_read.out.arsize ; // Address read channel burst size
assign m{0:02d}_axi_arburst = m{0:02d}_axi4_read.out.arburst; // Address read channel burst type
assign m{0:02d}_axi_arlock  = m{0:02d}_axi4_read.out.arlock ; // Address read channel lock type
assign m{0:02d}_axi_arcache = m{0:02d}_axi4_read.out.arcache; // Address read channel memory type
assign m{0:02d}_axi_arprot  = m{0:02d}_axi4_read.out.arprot ; // Address write channel protection type
assign m{0:02d}_axi_arqos   = m{0:02d}_axi4_read.out.arqos  ; // Address write channel quality of service

// --------------------------------------------------------------------------------------
// Channel {1} WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m{0:02d}_axi4_write.in.awready = m{0:02d}_axi_awready; // Address write channel ready
assign m{0:02d}_axi4_write.in.wready  = m{0:02d}_axi_wready ; // Write channel ready
assign m{0:02d}_axi4_write.in.bid     = m{0:02d}_axi_bid    ; // Write response channel ID
assign m{0:02d}_axi4_write.in.bresp   = m{0:02d}_axi_bresp  ; // Write channel response
assign m{0:02d}_axi4_write.in.bvalid  = m{0:02d}_axi_bvalid ; // Write response channel valid

// --------------------------------------------------------------------------------------
// Channel {1} WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m{0:02d}_axi_awvalid = m{0:02d}_axi4_write.out.awvalid; // Address write channel valid
assign m{0:02d}_axi_awid    = m{0:02d}_axi4_write.out.awid   ; // Address write channel ID
assign m{0:02d}_axi_awaddr  = m{0:02d}_axi4_write.out.awaddr ; // Address write channel address
assign m{0:02d}_axi_awlen   = m{0:02d}_axi4_write.out.awlen  ; // Address write channel burst length
assign m{0:02d}_axi_awsize  = m{0:02d}_axi4_write.out.awsize ; // Address write channel burst size
assign m{0:02d}_axi_awburst = m{0:02d}_axi4_write.out.awburst; // Address write channel burst type
assign m{0:02d}_axi_awlock  = m{0:02d}_axi4_write.out.awlock ; // Address write channel lock type
assign m{0:02d}_axi_awcache = m{0:02d}_axi4_write.out.awcache; // Address write channel memory type
assign m{0:02d}_axi_awprot  = m{0:02d}_axi4_write.out.awprot ; // Address write channel protection type
assign m{0:02d}_axi_awqos   = m{0:02d}_axi4_write.out.awqos  ; // Address write channel quality of service
assign m{0:02d}_axi_wdata   = swap_endianness_cacheline_m{0:02d}_axi_be(m{0:02d}_axi4_write.out.wdata, endian_write_reg); // Write channel data
assign m{0:02d}_axi_wstrb   = m{0:02d}_axi4_write.out.wstrb  ; // Write channel write strobe
assign m{0:02d}_axi_wlast   = m{0:02d}_axi4_write.out.wlast  ; // Write channel last word flag
assign m{0:02d}_axi_wvalid  = m{0:02d}_axi4_write.out.wvalid ; // Write channel valid
assign m{0:02d}_axi_bready  = m{0:02d}_axi4_write.out.bready ; // Write response channel ready
    """

    module_template = """
// --------------------------------------------------------------------------------------
// System Cache CH {5}-> AXI
// --------------------------------------------------------------------------------------
generate
// --------------------------------------------------------------------------------------
    if(CHANNEL_CONFIG_L2_CACHE[{5}] == 1) begin
// --------------------------------------------------------------------------------------
      kernel_m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}_wrapper inst_kernel_m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}_wrapper_cache_l2 (
        .ap_clk            (ap_clk                          ),
        .areset            (areset_cache[{5}]               ),
        .s_axi_read_out    (kernel_s{0:02d}_axi_read_out    ),
        .s_axi_read_in     (kernel_s{0:02d}_axi_read_in     ),
        .s_axi_write_out   (kernel_s{0:02d}_axi_write_out   ),
        .s_axi_write_in    (kernel_s{0:02d}_axi_write_in    ),
        .m_axi_read_in     (kernel_m{0:02d}_axi4_read_in    ),
        .m_axi_read_out    (kernel_m{0:02d}_axi4_read_out   ),
        .m_axi_write_in    (kernel_m{0:02d}_axi4_write_in   ),
        .m_axi_write_out   (kernel_m{0:02d}_axi4_write_out  ),
        .s_axi_lite_in     (kernel_m{0:02d}_axi_lite_out    ),
        .s_axi_lite_out    (kernel_m{0:02d}_axi_lite_in     ),
        .cache_setup_signal(kernel_cache_setup_signal[{5}])
      );
// Kernel CACHE (M->S) Register Slice
// --------------------------------------------------------------------------------------
      m{0:02d}_axi_register_slice_be_{1}x{2}_wrapper inst_m{0:02d}_axi_register_slice_be_{1}x{2}_wrapper (
        .ap_clk         (ap_clk                        ),
        .areset         (areset_axi_slice[{5}]         ),
        .s_axi_read_out (kernel_m{0:02d}_axi4_read_in  ),
        .s_axi_read_in  (kernel_m{0:02d}_axi4_read_out ),
        .s_axi_write_out(kernel_m{0:02d}_axi4_write_in ),
        .s_axi_write_in (kernel_m{0:02d}_axi4_write_out),
        .m_axi_read_in  (m{0:02d}_axi4_read.in         ),
        .m_axi_read_out (m{0:02d}_axi4_read.out        ),
        .m_axi_write_in (m{0:02d}_axi4_write.in        ),
        .m_axi_write_out(m{0:02d}_axi4_write.out       )
      );

    end else begin
        assign kernel_cache_setup_signal[{5}] = 0;
        assign kernel_m{0:02d}_axi4_read_in   = 0;
        assign kernel_m{0:02d}_axi4_read_out  = 0;
        assign kernel_m{0:02d}_axi4_write_in  = 0;
        assign kernel_m{0:02d}_axi4_write_out = 0;
        assign kernel_s{0:02d}_axi_read_out     = m{0:02d}_axi4_read.in       ;
        assign m{0:02d}_axi4_read.out           = kernel_s{0:02d}_axi_read_in ;
        assign kernel_s{0:02d}_axi_write_out    = m{0:02d}_axi4_write.in      ;
        assign m{0:02d}_axi4_write.out          = kernel_s{0:02d}_axi_write_in;
        assign kernel_m{0:02d}_axi_lite_in      = 0;
    end
// --------------------------------------------------------------------------------------
endgenerate
    """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"// Channel {index}")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(parameters_template.format(channel))
        output_lines.append(assign_template.format(channel,index))
        output_lines.append(module_template.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],index))


    # Writing to the VHDL file


    file.write('\n'.join(output_lines))


with open(output_file_afu_ports, 'w') as file:
    output_lines = []

    ports_template = """
output logic                         m{0:02d}_axi_awvalid,
input  logic                         m{0:02d}_axi_awready,
output logic [ M{0:02d}_AXI4_BE_ADDR_W-1:0] m{0:02d}_axi_awaddr ,
output logic [  M{0:02d}_AXI4_BE_LEN_W-1:0] m{0:02d}_axi_awlen  ,
output logic                         m{0:02d}_axi_wvalid ,
input  logic                         m{0:02d}_axi_wready ,
output logic [ M{0:02d}_AXI4_BE_DATA_W-1:0] m{0:02d}_axi_wdata  ,
output logic [ M{0:02d}_AXI4_BE_STRB_W-1:0] m{0:02d}_axi_wstrb  ,
output logic                         m{0:02d}_axi_wlast  ,
input  logic                         m{0:02d}_axi_bvalid ,
output logic                         m{0:02d}_axi_bready ,
output logic                         m{0:02d}_axi_arvalid,
input  logic                         m{0:02d}_axi_arready,
output logic [ M{0:02d}_AXI4_BE_ADDR_W-1:0] m{0:02d}_axi_araddr ,
output logic [  M{0:02d}_AXI4_BE_LEN_W-1:0] m{0:02d}_axi_arlen  ,
input  logic                         m{0:02d}_axi_rvalid ,
output logic                         m{0:02d}_axi_rready ,
input  logic [ M{0:02d}_AXI4_BE_DATA_W-1:0] m{0:02d}_axi_rdata  ,
input  logic                         m{0:02d}_axi_rlast  ,
// Control Signals
// AXI4 master interface m{0:02d}_axi missing ports
input  logic [   M{0:02d}_AXI4_BE_ID_W-1:0] m{0:02d}_axi_bid    ,
input  logic [   M{0:02d}_AXI4_BE_ID_W-1:0] m{0:02d}_axi_rid    ,
input  logic [ M{0:02d}_AXI4_BE_RESP_W-1:0] m{0:02d}_axi_rresp  ,
input  logic [ M{0:02d}_AXI4_BE_RESP_W-1:0] m{0:02d}_axi_bresp  ,
output logic [   M{0:02d}_AXI4_BE_ID_W-1:0] m{0:02d}_axi_awid   ,
output logic [ M{0:02d}_AXI4_BE_SIZE_W-1:0] m{0:02d}_axi_awsize ,
output logic [M{0:02d}_AXI4_BE_BURST_W-1:0] m{0:02d}_axi_awburst,
output logic [ M{0:02d}_AXI4_BE_LOCK_W-1:0] m{0:02d}_axi_awlock ,
output logic [M{0:02d}_AXI4_BE_CACHE_W-1:0] m{0:02d}_axi_awcache,
output logic [ M{0:02d}_AXI4_BE_PROT_W-1:0] m{0:02d}_axi_awprot ,
output logic [  M{0:02d}_AXI4_BE_QOS_W-1:0] m{0:02d}_axi_awqos  ,
output logic [   M{0:02d}_AXI4_BE_ID_W-1:0] m{0:02d}_axi_arid   ,
output logic [ M{0:02d}_AXI4_BE_SIZE_W-1:0] m{0:02d}_axi_arsize ,
output logic [M{0:02d}_AXI4_BE_BURST_W-1:0] m{0:02d}_axi_arburst,
output logic [ M{0:02d}_AXI4_BE_LOCK_W-1:0] m{0:02d}_axi_arlock ,
output logic [M{0:02d}_AXI4_BE_CACHE_W-1:0] m{0:02d}_axi_arcache,
output logic [ M{0:02d}_AXI4_BE_PROT_W-1:0] m{0:02d}_axi_arprot ,
output logic [  M{0:02d}_AXI4_BE_QOS_W-1:0] m{0:02d}_axi_arqos  ,
    """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(ports_template.format(channel))

    file.write('\n'.join(output_lines))

with open(output_file_top_wires, 'w') as file:
    output_lines = []

    wires_template = """
  wire                                    m{0:02d}_axi_awready      ; // Address write channel ready
  wire                                    m{0:02d}_axi_wready       ; // Write channel ready
  wire                                    m{0:02d}_axi_awvalid      ; // Address write channel valid
  wire                                    m{0:02d}_axi_wlast        ; // Write channel last word flag
  wire                                    m{0:02d}_axi_wvalid       ; // Write channel valid
  wire [                           8-1:0] m{0:02d}_axi_awlen        ; // Address write channel burst length
  wire [        C_M{0:02d}_AXI_ADDR_WIDTH-1:0] m{0:02d}_axi_awaddr  ; // Address write channel address
  wire [        C_M{0:02d}_AXI_DATA_WIDTH-1:0] m{0:02d}_axi_wdata   ; // Write channel data
  wire [      C_M{0:02d}_AXI_DATA_WIDTH/8-1:0] m{0:02d}_axi_wstrb   ; // Write channel write strobe
  wire                                    m{0:02d}_axi_bvalid       ; // Write response channel valid
  wire                                    m{0:02d}_axi_bready       ; // Write response channel ready
  wire                                    m{0:02d}_axi_arready      ; // Address read channel ready
  wire                                    m{0:02d}_axi_rlast        ; // Read channel last word
  wire                                    m{0:02d}_axi_rvalid       ; // Read channel valid
  wire [        C_M{0:02d}_AXI_DATA_WIDTH-1:0] m{0:02d}_axi_rdata   ; // Read channel data
  wire                                    m{0:02d}_axi_arvalid      ; // Address read channel valid
  wire                                    m{0:02d}_axi_rready       ; // Read channel ready
  wire [                           8-1:0] m{0:02d}_axi_arlen        ; // Address write channel burst length
  wire [        C_M{0:02d}_AXI_ADDR_WIDTH-1:0] m{0:02d}_axi_araddr  ; // Address read channel address
// AXI4 master interface m{0:02d}_axi missing ports
  wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_bid     ; // Write response channel ID
  wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_rid     ; // Read channel ID
  wire [                           2-1:0] m{0:02d}_axi_rresp        ; // Read channel response
  wire [                           2-1:0] m{0:02d}_axi_bresp        ; // Write channel response
  wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_awid    ; // Address write channel ID
  wire [                           3-1:0] m{0:02d}_axi_awsize       ; // Address write channel burst size
  wire [                           2-1:0] m{0:02d}_axi_awburst      ; // Address write channel burst type
  wire [                           1-1:0] m{0:02d}_axi_awlock       ; // Address write channel lock type
  wire [                           4-1:0] m{0:02d}_axi_awcache      ; // Address write channel memory type
  wire [                           3-1:0] m{0:02d}_axi_awprot       ; // Address write channel protection type
  wire [                           4-1:0] m{0:02d}_axi_awqos        ; // Address write channel quality of service
  wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_arid    ; // Address read channel ID
  wire [                           3-1:0] m{0:02d}_axi_arsize       ; // Address read channel burst size
  wire [                           2-1:0] m{0:02d}_axi_arburst      ; // Address read channel burst type
  wire [                           1-1:0] m{0:02d}_axi_arlock       ; // Address read channel lock type
  wire [                           4-1:0] m{0:02d}_axi_arcache      ; // Address read channel memory type
  wire [                           3-1:0] m{0:02d}_axi_arprot       ; // Address read channel protection type
  wire [                           4-1:0] m{0:02d}_axi_arqos        ; // Address read channel quality of service
    """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(wires_template.format(channel))

    file.write('\n'.join(output_lines))

with open(output_file_top_ports, 'w') as file:
    output_lines = []

    ports_template = """
input  wire                                    m{0:02d}_axi_awready      , // Address write channel ready
input  wire                                    m{0:02d}_axi_wready       , // Write channel ready
output wire                                    m{0:02d}_axi_awvalid      , // Address write channel valid
output wire                                    m{0:02d}_axi_wlast        , // Write channel last word flag
output wire                                    m{0:02d}_axi_wvalid       , // Write channel valid
output wire [                           8-1:0] m{0:02d}_axi_awlen        , // Address write channel burst length
output wire [        C_M{0:02d}_AXI_ADDR_WIDTH-1:0] m{0:02d}_axi_awaddr       , // Address write channel address
output wire [        C_M{0:02d}_AXI_DATA_WIDTH-1:0] m{0:02d}_axi_wdata        , // Write channel data
output wire [      C_M{0:02d}_AXI_DATA_WIDTH/8-1:0] m{0:02d}_axi_wstrb        , // Write channel write strobe
input  wire                                    m{0:02d}_axi_bvalid       , // Write response channel valid
output wire                                    m{0:02d}_axi_bready       , // Write response channel ready
input  wire                                    m{0:02d}_axi_arready      , // Address read channel ready
input  wire                                    m{0:02d}_axi_rlast        , // Read channel last word
input  wire                                    m{0:02d}_axi_rvalid       , // Read channel valid
input  wire [        C_M{0:02d}_AXI_DATA_WIDTH-1:0] m{0:02d}_axi_rdata        , // Read channel data
output wire                                    m{0:02d}_axi_arvalid      , // Address read channel valid
output wire                                    m{0:02d}_axi_rready       , // Read channel ready
output wire [                           8-1:0] m{0:02d}_axi_arlen        , // Address write channel burst length
output wire [        C_M{0:02d}_AXI_ADDR_WIDTH-1:0] m{0:02d}_axi_araddr       , // Address read channel address
// AXI4 master interface m{0:02d}_axi missing ports
input  wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_bid          , // Write response channel ID
input  wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_rid          , // Read channel ID
input  wire [                           2-1:0] m{0:02d}_axi_rresp        , // Read channel response
input  wire [                           2-1:0] m{0:02d}_axi_bresp        , // Write channel response
output wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_awid         , // Address write channel ID
output wire [                           3-1:0] m{0:02d}_axi_awsize       , // Address write channel burst size
output wire [                           2-1:0] m{0:02d}_axi_awburst      , // Address write channel burst type
output wire [                           1-1:0] m{0:02d}_axi_awlock       , // Address write channel lock type
output wire [                           4-1:0] m{0:02d}_axi_awcache      , // Address write channel memory type
output wire [                           3-1:0] m{0:02d}_axi_awprot       , // Address write channel protection type
output wire [                           4-1:0] m{0:02d}_axi_awqos        , // Address write channel quality of service
output wire [          C_M{0:02d}_AXI_ID_WIDTH-1:0] m{0:02d}_axi_arid         , // Address read channel ID
output wire [                           3-1:0] m{0:02d}_axi_arsize       , // Address read channel burst size
output wire [                           2-1:0] m{0:02d}_axi_arburst      , // Address read channel burst type
output wire [                           1-1:0] m{0:02d}_axi_arlock       , // Address read channel lock type
output wire [                           4-1:0] m{0:02d}_axi_arcache      , // Address read channel memory type
output wire [                           3-1:0] m{0:02d}_axi_arprot       , // Address read channel protection type
output wire [                           4-1:0] m{0:02d}_axi_arqos        , // Address read channel quality of service
    """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(ports_template.format(channel))

    file.write('\n'.join(output_lines))


with open(output_file_top_portmap, 'w') as file:
    output_lines = []

    connection_template = """
.m{0:02d}_axi_awvalid(m{0:02d}_axi_awvalid),
.m{0:02d}_axi_awready(m{0:02d}_axi_awready),
.m{0:02d}_axi_awaddr (m{0:02d}_axi_awaddr ),
.m{0:02d}_axi_awlen  (m{0:02d}_axi_awlen  ),
.m{0:02d}_axi_wvalid (m{0:02d}_axi_wvalid ),
.m{0:02d}_axi_wready (m{0:02d}_axi_wready ),
.m{0:02d}_axi_wdata  (m{0:02d}_axi_wdata  ),
.m{0:02d}_axi_wstrb  (m{0:02d}_axi_wstrb  ),
.m{0:02d}_axi_wlast  (m{0:02d}_axi_wlast  ),
.m{0:02d}_axi_bvalid (m{0:02d}_axi_bvalid ),
.m{0:02d}_axi_bready (m{0:02d}_axi_bready ),
.m{0:02d}_axi_arvalid(m{0:02d}_axi_arvalid),
.m{0:02d}_axi_arready(m{0:02d}_axi_arready),
.m{0:02d}_axi_araddr (m{0:02d}_axi_araddr ),
.m{0:02d}_axi_arlen  (m{0:02d}_axi_arlen  ),
.m{0:02d}_axi_rvalid (m{0:02d}_axi_rvalid ),
.m{0:02d}_axi_rready (m{0:02d}_axi_rready ),
.m{0:02d}_axi_rdata  (m{0:02d}_axi_rdata  ),
.m{0:02d}_axi_rlast  (m{0:02d}_axi_rlast  ),
.m{0:02d}_axi_bid    (m{0:02d}_axi_bid    ),
.m{0:02d}_axi_rid    (m{0:02d}_axi_rid    ),
.m{0:02d}_axi_rresp  (m{0:02d}_axi_rresp  ),
.m{0:02d}_axi_bresp  (m{0:02d}_axi_bresp  ),
.m{0:02d}_axi_awid   (m{0:02d}_axi_awid   ),
.m{0:02d}_axi_awsize (m{0:02d}_axi_awsize ),
.m{0:02d}_axi_awburst(m{0:02d}_axi_awburst),
.m{0:02d}_axi_awlock (m{0:02d}_axi_awlock ),
.m{0:02d}_axi_awcache(m{0:02d}_axi_awcache),
.m{0:02d}_axi_awprot (m{0:02d}_axi_awprot ),
.m{0:02d}_axi_awqos  (m{0:02d}_axi_awqos  ),
.m{0:02d}_axi_arid   (m{0:02d}_axi_arid   ),
.m{0:02d}_axi_arsize (m{0:02d}_axi_arsize ),
.m{0:02d}_axi_arburst(m{0:02d}_axi_arburst),
.m{0:02d}_axi_arlock (m{0:02d}_axi_arlock ),
.m{0:02d}_axi_arcache(m{0:02d}_axi_arcache),
.m{0:02d}_axi_arprot (m{0:02d}_axi_arprot ),
.m{0:02d}_axi_arqos  (m{0:02d}_axi_arqos  ),
    """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(connection_template.format(channel))

    file.write('\n'.join(output_lines))

with open(output_file_afu_portmap, 'w') as file:
    output_lines = []

    connection_template = """
.m{0:02d}_axi_awvalid(m{0:02d}_axi_awvalid),
.m{0:02d}_axi_awready(m{0:02d}_axi_awready),
.m{0:02d}_axi_awaddr (m{0:02d}_axi_awaddr ),
.m{0:02d}_axi_awlen  (m{0:02d}_axi_awlen  ),
.m{0:02d}_axi_wvalid (m{0:02d}_axi_wvalid ),
.m{0:02d}_axi_wready (m{0:02d}_axi_wready ),
.m{0:02d}_axi_wdata  (m{0:02d}_axi_wdata  ),
.m{0:02d}_axi_wstrb  (m{0:02d}_axi_wstrb  ),
.m{0:02d}_axi_wlast  (m{0:02d}_axi_wlast  ),
.m{0:02d}_axi_bvalid (m{0:02d}_axi_bvalid ),
.m{0:02d}_axi_bready (m{0:02d}_axi_bready ),
.m{0:02d}_axi_arvalid(m{0:02d}_axi_arvalid),
.m{0:02d}_axi_arready(m{0:02d}_axi_arready),
.m{0:02d}_axi_araddr (m{0:02d}_axi_araddr ),
.m{0:02d}_axi_arlen  (m{0:02d}_axi_arlen  ),
.m{0:02d}_axi_rvalid (m{0:02d}_axi_rvalid ),
.m{0:02d}_axi_rready (m{0:02d}_axi_rready ),
.m{0:02d}_axi_rdata  (m{0:02d}_axi_rdata  ),
.m{0:02d}_axi_rlast  (m{0:02d}_axi_rlast  ),
.m{0:02d}_axi_bid    (m{0:02d}_axi_bid    ),
.m{0:02d}_axi_rid    (m{0:02d}_axi_rid    ),
.m{0:02d}_axi_rresp  (m{0:02d}_axi_rresp  ),
.m{0:02d}_axi_bresp  (m{0:02d}_axi_bresp  ),
.m{0:02d}_axi_awid   (m{0:02d}_axi_awid   ),
.m{0:02d}_axi_awsize (m{0:02d}_axi_awsize ),
.m{0:02d}_axi_awburst(m{0:02d}_axi_awburst),
.m{0:02d}_axi_awlock (m{0:02d}_axi_awlock ),
.m{0:02d}_axi_awcache(m{0:02d}_axi_awcache),
.m{0:02d}_axi_awprot (m{0:02d}_axi_awprot ),
.m{0:02d}_axi_awqos  (m{0:02d}_axi_awqos  ),
.m{0:02d}_axi_arid   (m{0:02d}_axi_arid   ),
.m{0:02d}_axi_arsize (m{0:02d}_axi_arsize ),
.m{0:02d}_axi_arburst(m{0:02d}_axi_arburst),
.m{0:02d}_axi_arlock (m{0:02d}_axi_arlock ),
.m{0:02d}_axi_arcache(m{0:02d}_axi_arcache),
.m{0:02d}_axi_arprot (m{0:02d}_axi_arprot ),
.m{0:02d}_axi_arqos  (m{0:02d}_axi_arqos  ),
    """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(connection_template.format(channel))

    file.write('\n'.join(output_lines))

with open(output_file_slv_m_axi_vip_inst, 'w') as file:
    output_lines = []

    module_template = """
    // Slave MM VIP instantiation
    slv_m{0:02d}_axi_vip inst_slv_m{0:02d}_axi_vip (
        .aclk         (ap_clk         ),
        .aresetn      (ap_rst_n       ),
        .s_axi_awvalid(m{0:02d}_axi_awvalid),
        .s_axi_awready(m{0:02d}_axi_awready),
        .s_axi_awaddr (m{0:02d}_axi_awaddr ),
        .s_axi_awlen  (m{0:02d}_axi_awlen  ),
        .s_axi_wvalid (m{0:02d}_axi_wvalid ),
        .s_axi_wready (m{0:02d}_axi_wready ),
        .s_axi_wdata  (m{0:02d}_axi_wdata  ),
        .s_axi_wstrb  (m{0:02d}_axi_wstrb  ),
        .s_axi_wlast  (m{0:02d}_axi_wlast  ),
        .s_axi_bvalid (m{0:02d}_axi_bvalid ),
        .s_axi_bready (m{0:02d}_axi_bready ),
        .s_axi_arvalid(m{0:02d}_axi_arvalid),
        .s_axi_arready(m{0:02d}_axi_arready),
        .s_axi_araddr (m{0:02d}_axi_araddr ),
        .s_axi_arlen  (m{0:02d}_axi_arlen  ),
        .s_axi_rvalid (m{0:02d}_axi_rvalid ),
        .s_axi_rready (m{0:02d}_axi_rready ),
        .s_axi_rdata  (m{0:02d}_axi_rdata  ),
        .s_axi_rlast  (m{0:02d}_axi_rlast  ),
        
        .s_axi_bid    (m{0:02d}_axi_bid    ),
        .s_axi_rid    (m{0:02d}_axi_rid    ),
        .s_axi_rresp  (m{0:02d}_axi_rresp  ),
        .s_axi_bresp  (m{0:02d}_axi_bresp  ),
        .s_axi_awid   (m{0:02d}_axi_awid   ),
        .s_axi_awsize (m{0:02d}_axi_awsize ),
        .s_axi_awburst(m{0:02d}_axi_awburst),
        .s_axi_awlock (m{0:02d}_axi_awlock ),
        .s_axi_awcache(m{0:02d}_axi_awcache),
        .s_axi_awprot (m{0:02d}_axi_awprot ),
        .s_axi_awqos  (m{0:02d}_axi_awqos  ),
        .s_axi_arid   (m{0:02d}_axi_arid   ),
        .s_axi_arsize (m{0:02d}_axi_arsize ),
        .s_axi_arburst(m{0:02d}_axi_arburst),
        .s_axi_arlock (m{0:02d}_axi_arlock ),
        .s_axi_arcache(m{0:02d}_axi_arcache),
        .s_axi_arprot (m{0:02d}_axi_arprot ),
        .s_axi_arqos  (m{0:02d}_axi_arqos  )
    );

        slv_m{0:02d}_axi_vip_slv_mem_t m{0:02d}_axi    ;
        slv_m{0:02d}_axi_vip_slv_t     m{0:02d}_axi_slv;
        """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(module_template.format(channel))

    file.write('\n'.join(output_lines))

with open(output_file_slv_m_axi_vip_import, 'w') as file:
    output_lines = []

    module_template = """
    // Slave MM VIP instantiation
    import slv_m{0:02d}_axi_vip_pkg::*;
        """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(module_template.format(channel))

    file.write('\n'.join(output_lines))


def generate_output_file_buffer_channels_tcl(output_file_name):
  
    # Open output file for writing
    with open(output_file_name, "w") as file:
        current_address = 0x010  # Starting base address

        for buffer_name, properties in channels.items():
            axi_interface = f"m0{properties[0]}_axi"
            size = int(properties[1])  # Size as specified in JSON
            size_in_hex = (size // 8) + 4 # Convert size to equivalent hex value

            # Writing the TCL commands
            file.write(f'''puts_reg_info "{buffer_name}" "Channel {properties[0]}" "0x{current_address:03X}" [expr {{{size}}}]
  set reg      [ipx::add_register -quiet "{buffer_name}" $addr_block]
  set_property address_offset 0x{current_address:03X} $reg
  set_property size           [expr {{{size}}}]   $reg
  set regparam [ipx::add_register_parameter -quiet {{ASSOCIATED_BUSIF}} $reg] 
  set_property value {axi_interface} $regparam \n\n''')

            current_address += size_in_hex  # Increment the address based on the size

generate_output_file_buffer_channels_tcl(output_file_buffer_channels_tcl)

def generate_ipx_associate_commands_tcl(output_file_name):

    # Open output file for appending
    with open(output_file_name, "a") as file:
        for index, channel_num in enumerate(DISTINCT_CHANNELS):
            file.write(f'ipx::associate_bus_interfaces -busif "m{channel_num:02d}_axi" -clock "ap_clk" $core >> $log_file\n')
            file.write(f'set bifparam [ipx::add_bus_parameter DATA_WIDTH [ipx::get_bus_interfaces m{channel_num:02d}_axi -of_objects $core]]\n')
            file.write(f'set_property value {CHANNEL_CONFIG_DATA_WIDTH_BE[index]} $bifparam\n')
            file.write(f'set bifparam [ipx::add_bus_parameter ADDR_WIDTH [ipx::get_bus_interfaces m{channel_num:02d}_axi -of_objects $core]]\n')
            file.write(f'set_property value {CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index]} $bifparam\n')
          

# Generate the ipx::associate_bus_interfaces commands
generate_ipx_associate_commands_tcl(output_file_generate_ports_tcl)


# ----------------------------------------------------------------------------
# generate axi vip
# ----------------------------------------------------------------------------

with open(output_file_generate_m_axi_vip_tcl, "w") as file:
    output_lines = []

    fill_m_axi_vip_tcl_template="""
# ----------------------------------------------------------------------------
set BE_ADDR_WIDTH_M{0:02d}         {2}
set BE_CACHE_DATA_WIDTH_M{0:02d}   {1}
set LINE_CACHE_DATA_WIDTH_M{0:02d} {1} 
set MID_ADDR_WIDTH_M{0:02d}        {4} 
set MID_CACHE_DATA_WIDTH_M{0:02d}  {3} 
set SYSTEM_CACHE_NUM_WAYS_M{0:02d} {6} 
set SYSTEM_CACHE_SIZE_B_M{0:02d}   {5} 
# ----------------------------------------------------------------------------
# generate axi slave vip
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI_M{0:02d} VIP Slave"]" 

set module_name slv_m{0:02d}_axi_vip
create_ip -name axi_vip                 \\
          -vendor xilinx.com            \\
          -library ip                   \\
          -version 1.*                  \\
          -module_name ${{module_name}}   >> $log_file
          
set_property -dict [list \\
                    CONFIG.INTERFACE_MODE {{SLAVE}}                     \\
                    CONFIG.PROTOCOL {{AXI4}}                            \\
                    CONFIG.ADDR_WIDTH ${{BE_ADDR_WIDTH_M{0:02d}}}       \\
                    CONFIG.DATA_WIDTH ${{BE_CACHE_DATA_WIDTH_M{0:02d}}} \\
                    CONFIG.SUPPORTS_NARROW {{0}}                        \\
                    CONFIG.HAS_LOCK {{1}}                               \\
                    CONFIG.HAS_CACHE {{1}}                              \\
                    CONFIG.HAS_REGION {{0}}                             \\
                    CONFIG.HAS_BURST {{1}}                              \\
                    CONFIG.HAS_QOS {{1}}                                \\
                    CONFIG.HAS_PROT {{1}}                               \\
                    CONFIG.HAS_WSTRB {{1}}                              \\
                    CONFIG.HAS_SIZE {{1}}                               \\
                    CONFIG.ID_WIDTH   {{1}}                             \\
                    ] [get_ips ${{module_name}}]

set files_sources_xci ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.srcs/sources_1/ip/${{module_name}}/${{module_name}}.xci
set files_ip_user_files_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.ip_user_files
set files_cache_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.cache
set_property generate_synth_checkpoint false [get_files ${{files_sources_xci}}]
generate_target {{instantiation_template}}     [get_files ${{files_sources_xci}}] >> $log_file
# catch {{ config_ip_cache -export [get_ips -all ${{module_name}}] }}
generate_target all                          [get_files ${{files_sources_xci}}] >> $log_file
export_ip_user_files -of_objects             [get_files ${{files_sources_xci}}] -no_script -force >> $log_file
export_simulation -of_objects [get_files ${{files_sources_xci}}] -directory ${{files_ip_user_files_dir}}/sim_scripts -ip_user_files_dir ${{files_ip_user_files_dir}} -ipstatic_source_dir ${{files_ip_user_files_dir}}/ipstatic -lib_map_path [list {{modelsim=${{files_cache_dir}}/compile_simlib/modelsim}} {{questa=${{files_cache_dir}}/compile_simlib/questa}} {{xcelium=${{files_cache_dir}}/compile_simlib/xcelium}} {{vcs=${{files_cache_dir}}/compile_simlib/vcs}} {{riviera=${{files_cache_dir}}/compile_simlib/riviera}}] -use_ip_compiled_libs -force >> $log_file
    """

    fill_m_axi_vip_tcl_template_cache_pre="""
# ----------------------------------------------------------------------------
# generate SYSTEM CACHE AXI_M{0:02d}
# C_CACHE_SIZE    Cache size in bytes 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304

set SYSTEM_CACHE_SIZE_KB_M{0:02d} [expr {{${{SYSTEM_CACHE_SIZE_B_M{0:02d}}} / 1024}}]
puts "[color 2 "                        Generate AXI_M{0:02d} Kernel Cache \\[{7}\\]: Cache-line: ${{LINE_CACHE_DATA_WIDTH_M{0:02d}}}bits | Ways: ${{SYSTEM_CACHE_NUM_WAYS_M{0:02d}}} | Size: ${{SYSTEM_CACHE_SIZE_KB_M{0:02d}}}KB"]" 
puts "[color 2 "                                      Mid-End: Data width: ${{MID_CACHE_DATA_WIDTH_M{0:02d}}}bits | Address width: ${{MID_ADDR_WIDTH_M{0:02d}}}bits"]" 
puts "[color 2 "                                     Back-End: Data width: ${{BE_CACHE_DATA_WIDTH_M{0:02d}}}bits | Address width: ${{BE_ADDR_WIDTH_M{0:02d}}}bits"]" 


set module_name m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}
create_ip -name system_cache            \\
          -vendor xilinx.com            \\
          -library ip                   \\
          -version 5.*                  \\
          -module_name ${{module_name}}   >> $log_file

set_property -dict [list                                                  \\
                    CONFIG.C_CACHE_DATA_WIDTH ${{LINE_CACHE_DATA_WIDTH_M{0:02d}}}    \\
                    CONFIG.C_CACHE_SIZE  ${{SYSTEM_CACHE_SIZE_B_M{0:02d}}}           \\
                    CONFIG.C_M0_AXI_ADDR_WIDTH ${{BE_ADDR_WIDTH_M{0:02d}}}           \\
                    CONFIG.C_M0_AXI_DATA_WIDTH ${{BE_CACHE_DATA_WIDTH_M{0:02d}}}     \\
                    CONFIG.C_NUM_GENERIC_PORTS {{1}}                        \\
                    CONFIG.C_NUM_OPTIMIZED_PORTS {{0}}                      \\
                    CONFIG.C_ENABLE_NON_SECURE {{1}}                        \\
                    CONFIG.C_ENABLE_ERROR_HANDLING {{1}}                    \\"""

    fill_m_axi_vip_tcl_template_cache_mid="""                    CONFIG.C_ENABLE_CTRL {{{8}}}                            \\
                    CONFIG.C_ENABLE_STATISTICS {{2}}                        \\
                    CONFIG.C_S_AXI_CTRL_DATA_WIDTH {{64}}                   \\
                    CONFIG.C_ENABLE_VERSION_REGISTER {{0}}                  \\"""

    fill_m_axi_vip_tcl_template_cache_post="""                    CONFIG.C_NUM_WAYS ${{SYSTEM_CACHE_NUM_WAYS_M{0:02d}}}            \\
                    CONFIG.C_S0_AXI_GEN_DATA_WIDTH ${{MID_CACHE_DATA_WIDTH_M{0:02d}}}\\
                    CONFIG.C_S0_AXI_GEN_ADDR_WIDTH ${{MID_ADDR_WIDTH_M{0:02d}}}      \\
                    CONFIG.C_S0_AXI_GEN_FORCE_READ_ALLOCATE {{1}}           \\
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_READ_ALLOCATE {{0}}        \\
                    CONFIG.C_S0_AXI_GEN_FORCE_WRITE_ALLOCATE {{1}}          \\
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_WRITE_ALLOCATE {{0}}       \\
                    CONFIG.C_S0_AXI_GEN_FORCE_READ_BUFFER {{1}}             \\
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_READ_BUFFER {{0}}          \\
                    CONFIG.C_S0_AXI_GEN_FORCE_WRITE_BUFFER {{1}}            \\
                    CONFIG.C_S0_AXI_GEN_PROHIBIT_WRITE_BUFFER {{0}}         \\
                    CONFIG.C_CACHE_TAG_MEMORY_TYPE {{Automatic}}            \\
                    CONFIG.C_CACHE_DATA_MEMORY_TYPE {{{7}}}                 \\
                    CONFIG.C_CACHE_LRU_MEMORY_TYPE {{Automatic}}            \\
                    ] [get_ips ${{module_name}}] >> $log_file

set files_sources_xci ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.srcs/sources_1/ip/${{module_name}}/${{module_name}}.xci
set files_ip_user_files_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.ip_user_files
set files_cache_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.cache
set_property generate_synth_checkpoint false [get_files ${{files_sources_xci}}]
generate_target {{instantiation_template}}     [get_files ${{files_sources_xci}}] >> $log_file
# catch {{ config_ip_cache -export [get_ips -all ${{module_name}}] }}
generate_target all                          [get_files ${{files_sources_xci}}] >> $log_file
export_ip_user_files -of_objects             [get_files ${{files_sources_xci}}] -no_script -force >> $log_file
export_simulation -of_objects [get_files ${{files_sources_xci}}] -directory ${{files_ip_user_files_dir}}/sim_scripts -ip_user_files_dir ${{files_ip_user_files_dir}} -ipstatic_source_dir ${{files_ip_user_files_dir}}/ipstatic -lib_map_path [list {{modelsim=${{files_cache_dir}}/compile_simlib/modelsim}} {{questa=${{files_cache_dir}}/compile_simlib/questa}} {{xcelium=${{files_cache_dir}}/compile_simlib/xcelium}} {{vcs=${{files_cache_dir}}/compile_simlib/vcs}} {{riviera=${{files_cache_dir}}/compile_simlib/riviera}}] -use_ip_compiled_libs -force >> $log_file
    """

    fill_m_axi_vip_tcl_template_slice_post="""
# ----------------------------------------------------------------------------
# Generate AXI_M{0:02d} Register Slice
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI_M{0:02d} Register Slice Mid-end {3}x{4}"]" 

set module_name m{0:02d}_axi_register_slice_mid_{3}x{4}
create_ip -name axi_register_slice      \\
          -vendor xilinx.com            \\
          -library ip                   \\
          -version 2.*                  \\
          -module_name ${{module_name}}   >> $log_file
          
set_property -dict [list                                                      \\
                      CONFIG.ADDR_WIDTH ${{MID_ADDR_WIDTH_M{0:02d}}}           \\
                      CONFIG.DATA_WIDTH ${{MID_CACHE_DATA_WIDTH_M{0:02d}}}     \\
                      CONFIG.ID_WIDTH {{1}}                   \\
                      CONFIG.READ_WRITE_MODE {{READ_WRITE}}   \\
                      CONFIG.MAX_BURST_LENGTH {{32}}            \\
                      CONFIG.NUM_READ_OUTSTANDING {{32}}        \\
                      CONFIG.NUM_WRITE_OUTSTANDING {{32}}       \\
                      CONFIG.REG_AR {{15}}                    \\
                      CONFIG.REG_AW {{15}}                    \\
                      CONFIG.REG_B {{15}}                     \\
                      CONFIG.REG_R {{15}}                     \\
                      CONFIG.REG_W {{15}}                     \\
                      CONFIG.USE_AUTOPIPELINING {{1}}         \\
                    ] [get_ips ${{module_name}}]

set files_sources_xci ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.srcs/sources_1/ip/${{module_name}}/${{module_name}}.xci
set files_ip_user_files_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.ip_user_files
set files_cache_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.cache
set_property generate_synth_checkpoint false [get_files ${{files_sources_xci}}]
generate_target {{instantiation_template}}     [get_files ${{files_sources_xci}}] >> $log_file
generate_target all                          [get_files ${{files_sources_xci}}] >> $log_file
export_ip_user_files -of_objects             [get_files ${{files_sources_xci}}] -no_script -force >> $log_file
export_simulation -of_objects [get_files ${{files_sources_xci}}] -directory ${{files_ip_user_files_dir}}/sim_scripts -ip_user_files_dir ${{files_ip_user_files_dir}} -ipstatic_source_dir ${{files_ip_user_files_dir}}/ipstatic -lib_map_path [list {{modelsim=${{files_cache_dir}}/compile_simlib/modelsim}} {{questa=${{files_cache_dir}}/compile_simlib/questa}} {{xcelium=${{files_cache_dir}}/compile_simlib/xcelium}} {{vcs=${{files_cache_dir}}/compile_simlib/vcs}} {{riviera=${{files_cache_dir}}/compile_simlib/riviera}}] -use_ip_compiled_libs -force >> $log_file

# ----------------------------------------------------------------------------
# Generate AXI_M{0:02d} Register Slice
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI_M{0:02d} Register Slice Back-end {1}x{2}"]" 

set module_name m{0:02d}_axi_register_slice_be_{1}x{2}
create_ip -name axi_register_slice      \\
          -vendor xilinx.com            \\
          -library ip                   \\
          -version 2.*                  \\
          -module_name ${{module_name}}   >> $log_file
          
set_property -dict [list                                                          \\
                      CONFIG.ADDR_WIDTH ${{BE_ADDR_WIDTH_M{0:02d}}}               \\
                      CONFIG.DATA_WIDTH ${{BE_CACHE_DATA_WIDTH_M{0:02d}}}         \\
                      CONFIG.ID_WIDTH {{1}}                                       \\
                      CONFIG.READ_WRITE_MODE {{READ_WRITE}}                       \\
                      CONFIG.MAX_BURST_LENGTH {{32}}            \\
                      CONFIG.NUM_READ_OUTSTANDING {{32}}        \\
                      CONFIG.NUM_WRITE_OUTSTANDING {{32}}       \\
                      CONFIG.REG_AR {{15}}                    \\
                      CONFIG.REG_AW {{15}}                    \\
                      CONFIG.REG_B {{15}}                     \\
                      CONFIG.REG_R {{15}}                     \\
                      CONFIG.REG_W {{15}}                     \\
                      CONFIG.USE_AUTOPIPELINING {{1}}         \\
                    ] [get_ips ${{module_name}}]

set files_sources_xci ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.srcs/sources_1/ip/${{module_name}}/${{module_name}}.xci
set files_ip_user_files_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.ip_user_files
set files_cache_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.cache
set_property generate_synth_checkpoint false [get_files ${{files_sources_xci}}]
generate_target {{instantiation_template}}     [get_files ${{files_sources_xci}}] >> $log_file
generate_target all                          [get_files ${{files_sources_xci}}] >> $log_file
export_ip_user_files -of_objects             [get_files ${{files_sources_xci}}] -no_script -force >> $log_file
export_simulation -of_objects [get_files ${{files_sources_xci}}] -directory ${{files_ip_user_files_dir}}/sim_scripts -ip_user_files_dir ${{files_ip_user_files_dir}} -ipstatic_source_dir ${{files_ip_user_files_dir}}/ipstatic -lib_map_path [list {{modelsim=${{files_cache_dir}}/compile_simlib/modelsim}} {{questa=${{files_cache_dir}}/compile_simlib/questa}} {{xcelium=${{files_cache_dir}}/compile_simlib/xcelium}} {{vcs=${{files_cache_dir}}/compile_simlib/vcs}} {{riviera=${{files_cache_dir}}/compile_simlib/riviera}}] -use_ip_compiled_libs -force >> $log_file
    """

    fill_m_axi_vip_tcl_template_ctrl_post="""
# ----------------------------------------------------------------------------
# Generate AXI_LITE{0:02d} Register Slice
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI_LITE_M{0:02d} Register Slice Back-end 64x17"]" 

set module_name m{0:02d}_axi_lite_register_slice_mid_64x17
create_ip -name axi_register_slice      \\
          -vendor xilinx.com            \\
          -library ip                   \\
          -version 2.*                  \\
          -module_name ${{module_name}}   >> $log_file
          
set_property -dict [list                                                          \\
                      CONFIG.ADDR_WIDTH {{17}}                                    \\
                      CONFIG.DATA_WIDTH {{64}}                                    \\
                      CONFIG.PROTOCOL  {{AXI4LITE}}                               \\
                      CONFIG.READ_WRITE_MODE {{READ_WRITE}}                       \\
                      CONFIG.REG_AR {{7}}                     \\
                      CONFIG.REG_AW {{7}}                     \\
                      CONFIG.REG_B {{7}}                      \\
                      CONFIG.REG_R {{7}}                      \\
                      CONFIG.REG_W {{7}}                      \\
                    ] [get_ips ${{module_name}}]

set files_sources_xci ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.srcs/sources_1/ip/${{module_name}}/${{module_name}}.xci
set files_ip_user_files_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.ip_user_files
set files_cache_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.cache
set_property generate_synth_checkpoint false [get_files ${{files_sources_xci}}]
generate_target {{instantiation_template}}     [get_files ${{files_sources_xci}}] >> $log_file
generate_target all                          [get_files ${{files_sources_xci}}] >> $log_file
export_ip_user_files -of_objects             [get_files ${{files_sources_xci}}] -no_script -force >> $log_file
export_simulation -of_objects [get_files ${{files_sources_xci}}] -directory ${{files_ip_user_files_dir}}/sim_scripts -ip_user_files_dir ${{files_ip_user_files_dir}} -ipstatic_source_dir ${{files_ip_user_files_dir}}/ipstatic -lib_map_path [list {{modelsim=${{files_cache_dir}}/compile_simlib/modelsim}} {{questa=${{files_cache_dir}}/compile_simlib/questa}} {{xcelium=${{files_cache_dir}}/compile_simlib/xcelium}} {{vcs=${{files_cache_dir}}/compile_simlib/vcs}} {{riviera=${{files_cache_dir}}/compile_simlib/riviera}}] -use_ip_compiled_libs -force >> $log_file
  
 """

    fill_m_axi_vip_tcl_template_axi_lite_to_axi4_post="""
# ----------------------------------------------------------------------------
# Generate AXI_LITE{0:02d} Register Slice
# ----------------------------------------------------------------------------
puts "[color 2 "                        Generate AXI_LITE_M{0:02d} To AXI4 32x64"]" 

set module_name m{0:02d}_axi_lite_to_axi4_32x64
create_ip -name axi_protocol_converter      \\
          -vendor xilinx.com            \\
          -library ip                   \\
          -version 2.*                  \\
          -module_name ${{module_name}}   >> $log_file
          
set_property -dict [list                                                          \\
                        CONFIG.ADDR_WIDTH {{64}} \\
                        CONFIG.DATA_WIDTH {{32}} \\
                        CONFIG.MI_PROTOCOL {{AXI4}} \\
                        CONFIG.SI_PROTOCOL {{AXI4LITE}} \\
                        CONFIG.TRANSLATION_MODE {{2}} \\
                    ] [get_ips ${{module_name}}]

set files_sources_xci ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.srcs/sources_1/ip/${{module_name}}/${{module_name}}.xci
set files_ip_user_files_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.ip_user_files
set files_cache_dir     ${{package_full_dir}}/${{KERNEL_NAME}}/${{KERNEL_NAME}}.cache
set_property generate_synth_checkpoint false [get_files ${{files_sources_xci}}]
generate_target {{instantiation_template}}     [get_files ${{files_sources_xci}}] >> $log_file
generate_target all                          [get_files ${{files_sources_xci}}] >> $log_file
export_ip_user_files -of_objects             [get_files ${{files_sources_xci}}] -no_script -force >> $log_file
export_simulation -of_objects [get_files ${{files_sources_xci}}] -directory ${{files_ip_user_files_dir}}/sim_scripts -ip_user_files_dir ${{files_ip_user_files_dir}} -ipstatic_source_dir ${{files_ip_user_files_dir}}/ipstatic -lib_map_path [list {{modelsim=${{files_cache_dir}}/compile_simlib/modelsim}} {{questa=${{files_cache_dir}}/compile_simlib/questa}} {{xcelium=${{files_cache_dir}}/compile_simlib/xcelium}} {{vcs=${{files_cache_dir}}/compile_simlib/vcs}} {{riviera=${{files_cache_dir}}/compile_simlib/riviera}}] -use_ip_compiled_libs -force >> $log_file
  
 """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(fill_m_axi_vip_tcl_template.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CACHE_CONFIG_L2_SIZE[index], CACHE_CONFIG_L2_NUM_WAYS[index], CACHE_CONFIG_L2_RAM[index], CACHE_CONFIG_L2_CTRL[index]))
        output_lines.append(fill_m_axi_vip_tcl_template_cache_pre.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CACHE_CONFIG_L2_SIZE[index], CACHE_CONFIG_L2_NUM_WAYS[index], CACHE_CONFIG_L2_RAM[index], CACHE_CONFIG_L2_CTRL[index]))
        if(int(CACHE_CONFIG_L2_CTRL[index])):
            output_lines.append(fill_m_axi_vip_tcl_template_cache_mid.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CACHE_CONFIG_L2_SIZE[index], CACHE_CONFIG_L2_NUM_WAYS[index], CACHE_CONFIG_L2_RAM[index], CACHE_CONFIG_L2_CTRL[index]))
        output_lines.append(fill_m_axi_vip_tcl_template_cache_post.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CACHE_CONFIG_L2_SIZE[index], CACHE_CONFIG_L2_NUM_WAYS[index], CACHE_CONFIG_L2_RAM[index], CACHE_CONFIG_L2_CTRL[index]))
        output_lines.append(fill_m_axi_vip_tcl_template_slice_post.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CACHE_CONFIG_L2_SIZE[index], CACHE_CONFIG_L2_NUM_WAYS[index], CACHE_CONFIG_L2_RAM[index], CACHE_CONFIG_L2_CTRL[index]))
        if(int(CACHE_CONFIG_L2_CTRL[index])):
            output_lines.append(fill_m_axi_vip_tcl_template_ctrl_post.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CACHE_CONFIG_L2_SIZE[index], CACHE_CONFIG_L2_NUM_WAYS[index], CACHE_CONFIG_L2_RAM[index], CACHE_CONFIG_L2_CTRL[index]))
        # output_lines.append(fill_m_axi_vip_tcl_template_axi_lite_to_axi4_post.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CACHE_CONFIG_L2_SIZE[index], CACHE_CONFIG_L2_NUM_WAYS[index], CACHE_CONFIG_L2_RAM[index], CACHE_CONFIG_L2_CTRL[index]))
      
    file.write('\n'.join(output_lines))

# ----------------------------------------------------------------------------
# generate axi vip project files
# ----------------------------------------------------------------------------
with open(output_file_filelist_xsim_ip_vhdl_f, "w") as file:
    output_lines = []

    fill_filelist_xsim_ip_vhdl_template_once="""
{5}/m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}/hdl/system_cache_v5_0_vh_rfs.vhd
  """
    fill_filelist_xsim_ip_vhdl_template="""
{5}/m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}/sim/m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}.vhd
  """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        if(index==0):
            output_lines.append(fill_filelist_xsim_ip_vhdl_template_once.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],output_folder_path_vip ,KERNEL_NAME))
        output_lines.append(fill_filelist_xsim_ip_vhdl_template.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],output_folder_path_vip ,KERNEL_NAME))

    file.write('\n'.join(output_lines))


with open(output_file_filelist_xsim_ip_sv_f, "w") as file:
    output_lines = []

    output_lines.append(f"{output_folder_path_vip}/control_{KERNEL_NAME}_vip/sim/control_{KERNEL_NAME}_vip_pkg.sv")
    output_lines.append(f"{output_folder_path_vip}/control_{KERNEL_NAME}_vip/sim/control_{KERNEL_NAME}_vip.sv")
    output_lines.append(f"{output_folder_path_vip}/control_{KERNEL_NAME}_vip/hdl/axi_vip_v1_1_vl_rfs.sv")

    fill_file_filelist_xsim_ip_sv_template="""
{5}/slv_m{0:02d}_axi_vip/sim/slv_m{0:02d}_axi_vip_pkg.sv
{5}/slv_m{0:02d}_axi_vip/sim/slv_m{0:02d}_axi_vip.sv
  """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(fill_file_filelist_xsim_ip_sv_template.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],output_folder_path_vip ,KERNEL_NAME))

    file.write('\n'.join(output_lines))


with open(output_file_filelist_xsim_ip_v_f, "w") as file:
    output_lines = []

    output_lines.append(f"{output_folder_path_vip}/control_{KERNEL_NAME}_vip/hdl/axi_infrastructure_v1_1_vl_rfs.v")

    fill_file_filelist_xsim_ip_v_template_once="""
{5}/m{0:02d}_axi_register_slice_be_{1}x{2}/hdl/axi_register_slice_v2_1_vl_rfs.v
   """

    fill_file_filelist_xsim_ip_v_template="""
{5}/m{0:02d}_axi_register_slice_be_{1}x{2}/sim/m{0:02d}_axi_register_slice_be_{1}x{2}.v
{5}/m{0:02d}_axi_register_slice_mid_{3}x{4}/sim/m{0:02d}_axi_register_slice_mid_{3}x{4}.v
   """

    fill_file_filelist_xsim_ip_v_template_axi_lite="""
{5}/m{0:02d}_axi_lite_register_slice_mid_64x17/sim/m{0:02d}_axi_lite_register_slice_mid_64x17.v
   """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        if(index==0):
            output_lines.append(fill_file_filelist_xsim_ip_v_template_once.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],output_folder_path_vip ,KERNEL_NAME))
        if(int(CACHE_CONFIG_L2_CTRL[index])):
            output_lines.append(fill_file_filelist_xsim_ip_v_template_axi_lite.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],output_folder_path_vip ,KERNEL_NAME))
        output_lines.append(fill_file_filelist_xsim_ip_v_template.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],output_folder_path_vip ,KERNEL_NAME))

    output_lines.append(f"{XILINX_VIVADO}/data/verilog/src/glbl.v")
    
    file.write('\n'.join(output_lines))


# ----------------------------------------------------------------------------
# generate axi slave vip functions
# ----------------------------------------------------------------------------
# Write to VHDL file
with open(output_file_slv_m_axi_vip_func, "w") as file:
    output_lines = []

    fill_memory_template = """
/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the input buffer AXI vip memory model with  M{0:02d}_AXI4_BE_DATA_W-bit words
    function void m{0:02d}_axi_buffer_fill_memory(
            input slv_m{0:02d}_axi_vip_slv_mem_t mem,      // vip memory model handle
            input bit [63:0] ptr,                 // start address of memory fill, should allign to 16-byte
            input bit [M{0:02d}_AXI4_FE_DATA_W/8-1:0][8-1:0]words_data[$],      // data source to fill memory
            input integer offset,                 // start index of data source
            input integer words                   // number of words to fill
        );
        int i;
        int index;
        int words_be;
        int word_count_fe;
        int word_count_be;
        int global_index;
        bit [M{0:02d}_AXI4_BE_DATA_W/M{0:02d}_AXI4_FE_DATA_W-1:0][M{0:02d}_AXI4_FE_DATA_W/8-1:0][8-1:0]temp;
        bit [M{0:02d}_AXI4_FE_DATA_W/8-1:0][8-1:0]temp_fe;

        word_count_be = M{0:02d}_AXI4_BE_DATA_W/M{0:02d}_AXI4_FE_DATA_W;
        word_count_fe = M{0:02d}_AXI4_FE_DATA_W/8;
        words_be = (words*M{0:02d}_AXI4_FE_DATA_W + M{0:02d}_AXI4_BE_DATA_W - 1) / M{0:02d}_AXI4_BE_DATA_W;

        global_index = 0;

        for (index = 0; index < words_be && global_index < words; index++) begin
            temp = 0;
            for (i = 0; i < word_count_be; i = i + 1) begin
                temp_fe = 0;
                for (int j = 0; j < word_count_fe; j = j + 1) begin
                    temp_fe[word_count_fe-1-j] = words_data[global_index][j];
                end
                temp[word_count_be-1-i] = temp_fe;
                // $display("MSG: %0d 32'h%0h | %0d Hex number: 32'h%0h",global_index,words_data[global_index],(word_count_be-1-i), temp_fe);
                global_index++;
            end
            // $display("MSG: %0d 512'h%0h",(index * word_count_be),temp);
            mem.mem_model.backdoor_memory_write(ptr + (index * M{0:02d}_AXI4_BE_DATA_W/8), temp);
        end
    endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the input buffer AXI vip memory model with  M{0:02d}_AXI4_BE_DATA_W-bit words
    function void m{0:02d}_axi_buffer_dump_memory(
            input slv_m{0:02d}_axi_vip_slv_mem_t mem,      // vip memory model handle
            input bit [63:0] ptr,                 // start address of memory fill, should allign to 16-byte
            inout bit [M{0:02d}_AXI4_FE_DATA_W/8-1:0][8-1:0] words_data[$],      // data source to fill memory
            input integer offset,                 // start index of data source
            input integer words                   // number of words to fill
        );
        int i;
        int index;
        int words_be;
        int word_count_fe;
        int word_count_be;
        int global_index;
        bit [M{0:02d}_AXI4_BE_DATA_W/M{0:02d}_AXI4_FE_DATA_W-1:0][M{0:02d}_AXI4_FE_DATA_W/8-1:0][8-1:0]temp;
        bit [M{0:02d}_AXI4_FE_DATA_W/8-1:0][8-1:0]temp_fe;

        word_count_be = M{0:02d}_AXI4_BE_DATA_W/M{0:02d}_AXI4_FE_DATA_W;
        word_count_fe = M{0:02d}_AXI4_FE_DATA_W/8;
        words_be = (words*M{0:02d}_AXI4_FE_DATA_W + M{0:02d}_AXI4_BE_DATA_W - 1) / M{0:02d}_AXI4_BE_DATA_W;

        global_index = 0;

        for (index = 0; index < words_be && global_index < words; index++) begin
            temp = 0;
            temp = mem.mem_model.backdoor_memory_read(ptr + (index * M{0:02d}_AXI4_BE_DATA_W/8));
            // $display("MSG: %0d 512'h%0h",(index * word_count_be),temp);

            for (i = 0; i < word_count_be; i = i + 1) begin
                temp_fe = 0;
                for (int j = 0; j < word_count_fe; j = j + 1) begin
                    temp_fe[word_count_fe-1-j] = temp[word_count_be-1-i][j];
                end
                words_data[global_index] = temp_fe;
                // $display("MSG: %0d 32'h%0h | %0d Hex number: 32'h%0h",global_index,words_data[global_index],(word_count_be-1-i), temp[word_count_be-1-i]);
                global_index++;
            end
        end
    endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the m{0:02d}_axi memory.
        function void m{0:02d}_axi_fill_memory(
                input bit [63:0] ptr,
                input integer    length
            );
            for (longint unsigned slot = 0; slot < length; slot++) begin
                m{0:02d}_axi.mem_model.backdoor_memory_write_4byte(ptr + (slot * 4), slot);
            end
        endfunction
        """

    start_vips_pre = """
/////////////////////////////////////////////////////////////////////////////////////////////////
// Start the control VIP, SLAVE memory models and AXI4-Stream.
        task automatic start_vips();

            $display("///////////////////////////////////////////////////////////////////////////");
            $display("MSG: Control Master: ctrl");
            ctrl = new("ctrl", __KERNEL___testbench.inst_control___KERNEL___vip.inst.IF);
            ctrl.start_master();
            """

    start_vips_mid = """
            $display("///////////////////////////////////////////////////////////////////////////");
            $display("Starting Memory slave: m{0:02d}_axi");
            m{0:02d}_axi = new("m{0:02d}_axi", __KERNEL___testbench.inst_slv_m{0:02d}_axi_vip.inst.IF);
            m{0:02d}_axi.start_slave();
            """

    start_vips_end = """
        endtask
            """

    slv_no_backpressure_wready_pre = """
/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, set the Slave to not de-assert WREADY at any time.
// This will show the fastest outbound bandwidth from the WRITE channel.
        task automatic slv_no_backpressure_wready();
            axi_ready_gen     rgen;
            $display("%t - Applying slv_no_backpressure_wready", $time);
            """

    slv_no_backpressure_wready_mid = """
            rgen = new("m{0:02d}_axi_no_backpressure_wready");
            rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
            m{0:02d}_axi.wr_driver.set_wready_gen(rgen);
            """

    slv_no_backpressure_wready_end = """
        endtask
            """

    slv_random_backpressure_wready_pre = """
/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, apply a WREADY policy to introduce backpressure.
// Based on the simulation seed the order/shape of the WREADY per-channel will be different.
        task automatic slv_random_backpressure_wready();
            axi_ready_gen     rgen;
            $display("%t - Applying slv_random_backpressure_wready", $time);
            """

    slv_random_backpressure_wready_mid = """
            rgen = new("m{0:02d}_axi_random_backpressure_wready");
            rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
            rgen.set_low_time_range(0,12);
            rgen.set_high_time_range(1,12);
            rgen.set_event_count_range(3,5);
            m{0:02d}_axi.wr_driver.set_wready_gen(rgen);
            """

    slv_random_backpressure_wready_end = """
        endtask
            """

    slv_no_delay_rvalid_pre = """
/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, force the memory model to not insert any inter-beat
// gaps on the READ channel.
        task automatic slv_no_delay_rvalid();
            $display("%t - Applying slv_no_delay_rvalid", $time);
            """

    slv_no_delay_rvalid_mid = """
            m{0:02d}_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_FIXED);
            m{0:02d}_axi.mem_model.set_inter_beat_gap(0);
            """

    slv_no_delay_rvalid_end = """
        endtask
            """

    slv_random_delay_rvalid_pre = """
/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, Allow the memory model to insert any inter-beat
// gaps on the READ channel.
        task automatic slv_random_delay_rvalid();
            $display("%t - Applying slv_random_delay_rvalid", $time);
            """

    slv_random_delay_rvalid_mid = """
            m{0:02d}_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_RANDOM);
            m{0:02d}_axi.mem_model.set_inter_beat_gap_range(0,10);
            """

    slv_random_delay_rvalid_end = """
        endtask
            """


    backdoor_fill_memories_pre = """
        task automatic backdoor_fill_memories();
            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Backdoor fill the memory with the content.
            """

    backdoor_fill_memories_mid = """
            m{0:02d}_axi_fill_memory({1}_ptr, LP_MAX_LENGTH);
            """

    backdoor_fill_memories_end = """
        endtask
            """

    backdoor_buffer_fill_memories_pre = """
        task automatic backdoor_buffer_fill_memories(ref GraphCSR graph);
            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Backdoor fill the memory with the content.
            """

    backdoor_buffer_fill_memories_mid = """
            m{0:02d}_axi_buffer_fill_memory(m{0:02d}_axi, {1}_ptr, graph.{2}, 0, graph.mem_{2});
            """

    backdoor_buffer_fill_memories_end = """
        endtask
            """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(fill_memory_template.format(channel))

    output_lines.append(start_vips_pre)
    for channel in DISTINCT_CHANNELS:
        output_lines.append(start_vips_mid.format(channel))
    output_lines.append(start_vips_end)

    output_lines.append(slv_no_backpressure_wready_pre)
    for channel in DISTINCT_CHANNELS:
        output_lines.append(slv_no_backpressure_wready_mid.format(channel))
    output_lines.append(slv_no_backpressure_wready_end)

    output_lines.append(slv_random_backpressure_wready_pre)
    for channel in DISTINCT_CHANNELS:
        output_lines.append(slv_random_backpressure_wready_mid.format(channel))
    output_lines.append(slv_random_backpressure_wready_end)

    output_lines.append(slv_no_delay_rvalid_pre)
    for channel in DISTINCT_CHANNELS:
        output_lines.append(slv_no_delay_rvalid_mid.format(channel))
    output_lines.append(slv_no_delay_rvalid_end)

    output_lines.append(slv_random_delay_rvalid_pre)
    for channel in DISTINCT_CHANNELS:
        output_lines.append(slv_random_delay_rvalid_mid.format(channel))
    output_lines.append(slv_random_delay_rvalid_end)

    output_lines.append(backdoor_fill_memories_pre)
    for index, (buffer_name, properties) in enumerate(channels.items()):
        output_lines.append(backdoor_fill_memories_mid.format(int(properties[0]), buffer_name, index))
    output_lines.append(backdoor_fill_memories_end)

    output_lines.append(backdoor_buffer_fill_memories_pre)
    for index, ((buffer_name, properties), (buffer_name2, properties2)) in enumerate(zip(channels.items(), buffers.items())):
        if index == 9:
            continue  # Skip the iteration if the index is 9
        output_lines.append(backdoor_buffer_fill_memories_mid.format(int(properties[0]), buffer_name2, properties2))
    output_lines.append(backdoor_buffer_fill_memories_end)
    
    file.write('\n'.join(output_lines))


# Write to VHDL file
with open(output_file_set_top_parameters, "w") as file:
    output_lines = []

    ports_template = """
        .C_M{0:02d}_AXI_ADDR_WIDTH      (C_M{0:02d}_AXI_ADDR_WIDTH      ),
        .C_M{0:02d}_AXI_DATA_WIDTH      (C_M{0:02d}_AXI_DATA_WIDTH      ),
        """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(ports_template.format(channel))

    file.write('\n'.join(output_lines))


# Write to VHDL file
with open(output_file_testbench_parameters, "w") as file:
    output_lines = []

    ports_template = """
        parameter integer C_M{0:02d}_AXI_ADDR_WIDTH       = {2}           ;
        parameter integer C_M{0:02d}_AXI_DATA_WIDTH       = {1}        ;
        parameter integer C_M{0:02d}_AXI_ID_WIDTH         = M{0:02d}_AXI4_BE_ID_W          ;
        """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(ports_template.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index]))

    file.write('\n'.join(output_lines))





check_and_clean_file(output_file_pkg_mxx_axi4_fe)
check_and_clean_file(output_file_pkg_mxx_axi4_mid)
check_and_clean_file(output_file_pkg_mxx_axi4_be)

# ----------------------------------------------------------------------------
# generate axi pkg axi project files
# ----------------------------------------------------------------------------
with open(output_file_pkg_mxx_axi4_be, "w") as file:
    output_lines = []

    fill_file_pkg_mxx_axi4_be_pre="""
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_MXX_AXI4_BE.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_timescale.vh"
`include "typedef.svh"
package PKG_MXX_AXI4_BE;

parameter S_AXI_BE_ADDR_WIDTH_BITS = 12;
parameter S_AXI_BE_DATA_WIDTH      = 32;

  """

    fill_file_pkg_mxx_axi4_be_mid="""
parameter M{0:02d}_AXI4_BE_ADDR_W   = {2}                 ;
parameter M{0:02d}_AXI4_BE_DATA_W   = {1}                 ;
parameter M{0:02d}_AXI4_BE_STRB_W   = M{0:02d}_AXI4_BE_DATA_W / 8;
parameter M{0:02d}_AXI4_BE_BURST_W  = 2                   ;
parameter M{0:02d}_AXI4_BE_CACHE_W  = 4                   ;
parameter M{0:02d}_AXI4_BE_PROT_W   = 3                   ;
parameter M{0:02d}_AXI4_BE_REGION_W = 4                   ;
parameter M{0:02d}_AXI4_BE_USER_W   = 4                   ;
parameter M{0:02d}_AXI4_BE_LOCK_W   = 1                   ;
parameter M{0:02d}_AXI4_BE_QOS_W    = 4                   ;
parameter M{0:02d}_AXI4_BE_LEN_W    = 8                   ;
parameter M{0:02d}_AXI4_BE_SIZE_W   = 3                   ;
parameter M{0:02d}_AXI4_BE_RESP_W   = 2                   ;
parameter M{0:02d}_AXI4_BE_ID_W     = 1                   ;

typedef logic                          type_m{0:02d}_axi4_be_valid;
typedef logic                          type_m{0:02d}_axi4_be_ready;
typedef logic                          type_m{0:02d}_axi4_be_last;
typedef logic [M{0:02d}_AXI4_BE_ADDR_W-1:0]   type_m{0:02d}_axi4_be_addr;
typedef logic [M{0:02d}_AXI4_BE_DATA_W-1:0]   type_m{0:02d}_axi4_be_data;
typedef logic [M{0:02d}_AXI4_BE_STRB_W-1:0]   type_m{0:02d}_axi4_be_strb;
typedef logic [M{0:02d}_AXI4_BE_LEN_W-1:0]    type_m{0:02d}_axi4_be_len;
typedef logic [M{0:02d}_AXI4_BE_LOCK_W-1:0]   type_m{0:02d}_axi4_be_lock;
typedef logic [M{0:02d}_AXI4_BE_PROT_W-1:0]   type_m{0:02d}_axi4_be_prot;
typedef logic [M{0:02d}_AXI4_BE_REGION_W-1:0] type_m{0:02d}_axi4_be_region;
typedef logic [M{0:02d}_AXI4_BE_QOS_W-1:0]    type_m{0:02d}_axi4_be_qos;
typedef logic [M{0:02d}_AXI4_BE_ID_W-1:0]     type_m{0:02d}_axi4_be_id;
typedef logic [M{0:02d}_AXI4_BE_USER_W-1:0]   type_m{0:02d}_axi4_be_user;

parameter M{0:02d}_AXI4_BE_BURST_FIXED = 2'b00;
parameter M{0:02d}_AXI4_BE_BURST_INCR  = 2'b01;
parameter M{0:02d}_AXI4_BE_BURST_WRAP  = 2'b10;
parameter M{0:02d}_AXI4_BE_BURST_RSVD  = 2'b11;

typedef logic [M{0:02d}_AXI4_BE_BURST_W-1:0] type_m{0:02d}_axi4_be_burst;

parameter M{0:02d}_AXI4_BE_RESP_OKAY   = 2'b00;
parameter M{0:02d}_AXI4_BE_RESP_EXOKAY = 2'b01;
parameter M{0:02d}_AXI4_BE_RESP_SLVERR = 2'b10;
parameter M{0:02d}_AXI4_BE_RESP_DECERR = 2'b11;

typedef logic [M{0:02d}_AXI4_BE_RESP_W-1:0] type_m{0:02d}_axi4_be_resp;

parameter M{0:02d}_AXI4_BE_SIZE_1B   = 3'b000;
parameter M{0:02d}_AXI4_BE_SIZE_2B   = 3'b001;
parameter M{0:02d}_AXI4_BE_SIZE_4B   = 3'b010;
parameter M{0:02d}_AXI4_BE_SIZE_8B   = 3'b011;
parameter M{0:02d}_AXI4_BE_SIZE_16B  = 3'b100;
parameter M{0:02d}_AXI4_BE_SIZE_32B  = 3'b101;
parameter M{0:02d}_AXI4_BE_SIZE_64B  = 3'b110;
parameter M{0:02d}_AXI4_BE_SIZE_128B = 3'b111;

typedef logic [M{0:02d}_AXI4_BE_SIZE_W-1:0] type_m{0:02d}_axi4_be_size;

parameter M{0:02d}_AXI4_BE_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
parameter M{0:02d}_AXI4_BE_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
parameter M{0:02d}_AXI4_BE_CACHE_NO_ALLOCATE                            = 4'B0010;
parameter M{0:02d}_AXI4_BE_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
parameter M{0:02d}_AXI4_BE_CACHE_RESERVED_1                             = 4'B0100;
parameter M{0:02d}_AXI4_BE_CACHE_RESERVED_2                             = 4'B0101;
parameter M{0:02d}_AXI4_BE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
parameter M{0:02d}_AXI4_BE_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
parameter M{0:02d}_AXI4_BE_CACHE_RESERVED_3                             = 4'B1000;
parameter M{0:02d}_AXI4_BE_CACHE_RESERVED_4                             = 4'B1001;
parameter M{0:02d}_AXI4_BE_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
parameter M{0:02d}_AXI4_BE_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
parameter M{0:02d}_AXI4_BE_CACHE_RESERVED_5                             = 4'B1100;
parameter M{0:02d}_AXI4_BE_CACHE_RESERVED_6                             = 4'B1101;
parameter M{0:02d}_AXI4_BE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
parameter M{0:02d}_AXI4_BE_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

typedef logic [M{0:02d}_AXI4_BE_CACHE_W-1:0] type_m{0:02d}_axi4_be_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

typedef struct packed {{
  type_m{0:02d}_axi4_be_valid rvalid ; // Input Read channel valid
  type_m{0:02d}_axi4_be_last  arready; // Input Read Address read channel ready
  type_m{0:02d}_axi4_be_last  rlast  ; // Input Read channel last word
  type_m{0:02d}_axi4_be_data  rdata  ; // Input Read channel data
  type_m{0:02d}_axi4_be_id    rid    ; // Input Read channel ID
  type_m{0:02d}_axi4_be_resp  rresp  ; // Input Read channel response
}} M{0:02d}_AXI4_BE_MasterReadInterfaceInput;

typedef struct packed {{
  type_m{0:02d}_axi4_be_valid  arvalid ; // Output Read Address read channel valid
  type_m{0:02d}_axi4_be_addr   araddr  ; // Output Read Address read channel address
  type_m{0:02d}_axi4_be_len    arlen   ; // Output Read Address channel burst length
  type_m{0:02d}_axi4_be_ready  rready  ; // Output Read Read channel ready
  type_m{0:02d}_axi4_be_id     arid    ; // Output Read Address read channel ID
  type_m{0:02d}_axi4_be_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_be_burst  arburst ; // Output Read Address read channel burst type
  type_m{0:02d}_axi4_be_lock   arlock  ; // Output Read Address read channel lock type
  type_m{0:02d}_axi4_be_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_be_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_be_qos    arqos   ; // Output Read Address channel quality of service
  type_m{0:02d}_axi4_be_region arregion;
}} M{0:02d}_AXI4_BE_MasterReadInterfaceOutput;

typedef struct packed {{
  M{0:02d}_AXI4_BE_MasterReadInterfaceInput  in ;
  M{0:02d}_AXI4_BE_MasterReadInterfaceOutput out;
}} M{0:02d}_AXI4_BE_MasterReadInterface;


typedef struct packed {{
  type_m{0:02d}_axi4_be_ready awready; // Input Write Address write channel ready
  type_m{0:02d}_axi4_be_ready wready ; // Input Write channel ready
  type_m{0:02d}_axi4_be_id    bid    ; // Input Write response channel ID
  type_m{0:02d}_axi4_be_resp  bresp  ; // Input Write channel response
  type_m{0:02d}_axi4_be_valid bvalid ; // Input Write response channel valid
}} M{0:02d}_AXI4_BE_MasterWriteInterfaceInput;

typedef struct packed {{
  type_m{0:02d}_axi4_be_valid  awvalid ; // Output Write Address write channel valid
  type_m{0:02d}_axi4_be_id     awid    ; // Output Write Address write channel ID
  type_m{0:02d}_axi4_be_addr   awaddr  ; // Output Write Address write channel address
  type_m{0:02d}_axi4_be_len    awlen   ; // Output Write Address write channel burst length
  type_m{0:02d}_axi4_be_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_be_burst  awburst ; // Output Write Address write channel burst type
  type_m{0:02d}_axi4_be_lock   awlock  ; // Output Write Address write channel lock type
  type_m{0:02d}_axi4_be_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_be_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_be_qos    awqos   ; // Output Write Address write channel quality of service
  type_m{0:02d}_axi4_be_data   wdata   ; // Output Write channel data
  type_m{0:02d}_axi4_be_strb   wstrb   ; // Output Write channel write strobe
  type_m{0:02d}_axi4_be_last   wlast   ; // Output Write channel last word flag
  type_m{0:02d}_axi4_be_valid  wvalid  ; // Output Write channel valid
  type_m{0:02d}_axi4_be_ready  bready  ; // Output Write response channel ready
  type_m{0:02d}_axi4_be_region awregion;
}} M{0:02d}_AXI4_BE_MasterWriteInterfaceOutput;

typedef struct packed {{
  M{0:02d}_AXI4_BE_MasterWriteInterfaceInput  in ;
  M{0:02d}_AXI4_BE_MasterWriteInterfaceOutput out;
}} M{0:02d}_AXI4_BE_MasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

typedef struct packed {{
  type_m{0:02d}_axi4_be_valid rvalid ; // Input Read channel valid
  type_m{0:02d}_axi4_be_last  arready; // Input Read Address read channel ready
  type_m{0:02d}_axi4_be_last  rlast  ; // Input Read channel last word
  type_m{0:02d}_axi4_be_data  rdata  ; // Input Read channel data
  type_m{0:02d}_axi4_be_id    rid    ; // Input Read channel ID
  type_m{0:02d}_axi4_be_resp  rresp  ; // Input Read channel response
}} M{0:02d}_AXI4_BE_SlaveReadInterfaceOutput;

typedef struct packed {{
  type_m{0:02d}_axi4_be_valid  arvalid ; // Output Read Address read channel valid
  type_m{0:02d}_axi4_be_addr   araddr  ; // Output Read Address read channel address
  type_m{0:02d}_axi4_be_len    arlen   ; // Output Read Address channel burst length
  type_m{0:02d}_axi4_be_ready  rready  ; // Output Read Read channel ready
  type_m{0:02d}_axi4_be_id     arid    ; // Output Read Address read channel ID
  type_m{0:02d}_axi4_be_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_be_burst  arburst ; // Output Read Address read channel burst type
  type_m{0:02d}_axi4_be_lock   arlock  ; // Output Read Address read channel lock type
  type_m{0:02d}_axi4_be_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_be_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_be_qos    arqos   ; // Output Read Address channel quality of service
  type_m{0:02d}_axi4_be_region arregion;
}} M{0:02d}_AXI4_BE_SlaveReadInterfaceInput;

typedef struct packed {{
  M{0:02d}_AXI4_BE_SlaveReadInterfaceInput  in ;
  M{0:02d}_AXI4_BE_SlaveReadInterfaceOutput out;
}} M{0:02d}_AXI4_BE_SlaveReadInterface;


typedef struct packed {{
  type_m{0:02d}_axi4_be_ready awready; // Input Write Address write channel ready
  type_m{0:02d}_axi4_be_ready wready ; // Input Write channel ready
  type_m{0:02d}_axi4_be_id    bid    ; // Input Write response channel ID
  type_m{0:02d}_axi4_be_resp  bresp  ; // Input Write channel response
  type_m{0:02d}_axi4_be_valid bvalid ; // Input Write response channel valid
}} M{0:02d}_AXI4_BE_SlaveWriteInterfaceOutput;

typedef struct packed {{
  type_m{0:02d}_axi4_be_valid  awvalid ; // Output Write Address write channel valid
  type_m{0:02d}_axi4_be_id     awid    ; // Output Write Address write channel ID
  type_m{0:02d}_axi4_be_addr   awaddr  ; // Output Write Address write channel address
  type_m{0:02d}_axi4_be_len    awlen   ; // Output Write Address write channel burst length
  type_m{0:02d}_axi4_be_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_be_burst  awburst ; // Output Write Address write channel burst type
  type_m{0:02d}_axi4_be_lock   awlock  ; // Output Write Address write channel lock type
  type_m{0:02d}_axi4_be_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_be_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_be_qos    awqos   ; // Output Write Address write channel quality of service
  type_m{0:02d}_axi4_be_data   wdata   ; // Output Write channel data
  type_m{0:02d}_axi4_be_strb   wstrb   ; // Output Write channel write strobe
  type_m{0:02d}_axi4_be_last   wlast   ; // Output Write channel last word flag
  type_m{0:02d}_axi4_be_valid  wvalid  ; // Output Write channel valid
  type_m{0:02d}_axi4_be_ready  bready  ; // Output Write response channel ready
  type_m{0:02d}_axi4_be_region awregion;
}} M{0:02d}_AXI4_BE_SlaveWriteInterfaceInput;

typedef struct packed {{
  M{0:02d}_AXI4_BE_SlaveWriteInterfaceInput  in ;
  M{0:02d}_AXI4_BE_SlaveWriteInterfaceOutput out;
}} M{0:02d}_AXI4_BE_SlaveWriteInterface;


function logic [M{0:02d}_AXI4_BE_DATA_W-1:0] swap_endianness_cacheline_m{0:02d}_axi_be (logic [M{0:02d}_AXI4_BE_DATA_W-1:0] in, logic mode);

  logic [M{0:02d}_AXI4_BE_DATA_W-1:0] out;

  integer i;

  if(mode == 1) begin
    for ( i = 0; i < M{0:02d}_AXI4_BE_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M{0:02d}_AXI4_BE_DATA_W-1)-(i*8)) -:8];
    end
  end else begin
    out = in;
  end

  return out;
endfunction : swap_endianness_cacheline_m{0:02d}_axi_be

  """

    fill_file_pkg_mxx_axi4_lite_be_mid="""

// --------------------------------------------------------------------------------------
// AXI4 Lite 
// --------------------------------------------------------------------------------------

`AXI_TYPEDEF_ALL(m{0:02d}_axi, type_m{0:02d}_axi4_be_addr, type_m{0:02d}_axi4_be_id, type_m{0:02d}_axi4_be_data, type_m{0:02d}_axi4_be_strb, type_m{0:02d}_axi4_be_user)
typedef m{0:02d}_axi_req_t M{0:02d}_AXI4_BE_REQ_T;
typedef m{0:02d}_axi_resp_t M{0:02d}_AXI4_BE_RESP_T;

parameter M{0:02d}_AXI4_LITE_BE_ADDR_W   = 17                 ;
parameter M{0:02d}_AXI4_LITE_BE_DATA_W   = 64                 ;
parameter M{0:02d}_AXI4_LITE_BE_STRB_W   = M{0:02d}_AXI4_LITE_BE_DATA_W / 8;
parameter M{0:02d}_AXI4_LITE_BE_ID_W     = 1                   ;
typedef logic [M{0:02d}_AXI4_LITE_BE_ADDR_W-1:0]   type_m{0:02d}_axi4_lite_be_addr;
typedef logic [M{0:02d}_AXI4_LITE_BE_DATA_W-1:0]   type_m{0:02d}_axi4_lite_be_data;
typedef logic [M{0:02d}_AXI4_LITE_BE_STRB_W-1:0]   type_m{0:02d}_axi4_lite_be_strb;

`AXI_LITE_TYPEDEF_ALL(m{0:02d}_axi_lite, type_m{0:02d}_axi4_lite_be_addr, type_m{0:02d}_axi4_lite_be_data, type_m{0:02d}_axi4_lite_be_strb)
typedef m{0:02d}_axi_lite_req_t  M{0:02d}_AXI4_LITE_BE_REQ_T;
typedef m{0:02d}_axi_lite_resp_t M{0:02d}_AXI4_LITE_BE_RESP_T;
typedef m{0:02d}_axi_lite_req_t  S{0:02d}_AXI4_LITE_BE_REQ_T;
typedef m{0:02d}_axi_lite_resp_t S{0:02d}_AXI4_LITE_BE_RESP_T;

  """

    fill_file_pkg_mxx_axi4_be_end="""
endpackage
  """

    output_lines.append(fill_file_pkg_mxx_axi4_be_pre)
    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(fill_file_pkg_mxx_axi4_be_mid.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index]))
        output_lines.append(fill_file_pkg_mxx_axi4_lite_be_mid.format(channel,CHANNEL_CONFIG_DATA_WIDTH_BE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index]))
    output_lines.append(fill_file_pkg_mxx_axi4_be_end)

    file.write('\n'.join(output_lines))


with open(output_file_pkg_mxx_axi4_mid, "w") as file:
    output_lines = []

    fill_file_pkg_mxx_axi4_mid_pre="""
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_MXX_AXI4_MID.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_timescale.vh"
`include "typedef.svh"
package PKG_MXX_AXI4_MID;

parameter S_AXI_MID_ADDR_WIDTH_BITS = 12;
parameter S_AXI_MID_DATA_WIDTH      = 32;

  """

    fill_file_pkg_mxx_axi4_mid_mid="""
parameter M{0:02d}_AXI4_MID_ADDR_W   = {2}                 ;
parameter M{0:02d}_AXI4_MID_DATA_W   = {1}                 ;
parameter M{0:02d}_AXI4_MID_STRB_W   = M{0:02d}_AXI4_MID_DATA_W / 8;
parameter M{0:02d}_AXI4_MID_BURST_W  = 2                   ;
parameter M{0:02d}_AXI4_MID_CACHE_W  = 4                   ;
parameter M{0:02d}_AXI4_MID_PROT_W   = 3                   ;
parameter M{0:02d}_AXI4_MID_REGION_W = 4                   ;
parameter M{0:02d}_AXI4_MID_USER_W   = 4                   ;
parameter M{0:02d}_AXI4_MID_LOCK_W   = 1                   ;
parameter M{0:02d}_AXI4_MID_QOS_W    = 4                   ;
parameter M{0:02d}_AXI4_MID_LEN_W    = 8                   ;
parameter M{0:02d}_AXI4_MID_SIZE_W   = 3                   ;
parameter M{0:02d}_AXI4_MID_RESP_W   = 2                   ;
parameter M{0:02d}_AXI4_MID_ID_W     = 1                   ;

typedef logic                          type_m{0:02d}_axi4_mid_valid;
typedef logic                          type_m{0:02d}_axi4_mid_ready;
typedef logic                          type_m{0:02d}_axi4_mid_last;
typedef logic [M{0:02d}_AXI4_MID_ADDR_W-1:0]   type_m{0:02d}_axi4_mid_addr;
typedef logic [M{0:02d}_AXI4_MID_DATA_W-1:0]   type_m{0:02d}_axi4_mid_data;
typedef logic [M{0:02d}_AXI4_MID_STRB_W-1:0]   type_m{0:02d}_axi4_mid_strb;
typedef logic [M{0:02d}_AXI4_MID_LEN_W-1:0]    type_m{0:02d}_axi4_mid_len;
typedef logic [M{0:02d}_AXI4_MID_LOCK_W-1:0]   type_m{0:02d}_axi4_mid_lock;
typedef logic [M{0:02d}_AXI4_MID_PROT_W-1:0]   type_m{0:02d}_axi4_mid_prot;
typedef logic [M{0:02d}_AXI4_MID_REGION_W-1:0] type_m{0:02d}_axi4_mid_region;
typedef logic [M{0:02d}_AXI4_MID_QOS_W-1:0]    type_m{0:02d}_axi4_mid_qos;
typedef logic [M{0:02d}_AXI4_MID_ID_W-1:0]     type_m{0:02d}_axi4_mid_id;
typedef logic [M{0:02d}_AXI4_MID_USER_W-1:0]   type_m{0:02d}_axi4_mid_user;

parameter M{0:02d}_AXI4_MID_BURST_FIXED = 2'b00;
parameter M{0:02d}_AXI4_MID_BURST_INCR  = 2'b01;
parameter M{0:02d}_AXI4_MID_BURST_WRAP  = 2'b10;
parameter M{0:02d}_AXI4_MID_BURST_RSVD  = 2'b11;

typedef logic [M{0:02d}_AXI4_MID_BURST_W-1:0] type_m{0:02d}_axi4_mid_burst;

parameter M{0:02d}_AXI4_MID_RESP_OKAY   = 2'b00;
parameter M{0:02d}_AXI4_MID_RESP_EXOKAY = 2'b01;
parameter M{0:02d}_AXI4_MID_RESP_SLVERR = 2'b10;
parameter M{0:02d}_AXI4_MID_RESP_DECERR = 2'b11;

typedef logic [M{0:02d}_AXI4_MID_RESP_W-1:0] type_m{0:02d}_axi4_mid_resp;

parameter M{0:02d}_AXI4_MID_SIZE_1B   = 3'b000;
parameter M{0:02d}_AXI4_MID_SIZE_2B   = 3'b001;
parameter M{0:02d}_AXI4_MID_SIZE_4B   = 3'b010;
parameter M{0:02d}_AXI4_MID_SIZE_8B   = 3'b011;
parameter M{0:02d}_AXI4_MID_SIZE_16B  = 3'b100;
parameter M{0:02d}_AXI4_MID_SIZE_32B  = 3'b101;
parameter M{0:02d}_AXI4_MID_SIZE_64B  = 3'b110;
parameter M{0:02d}_AXI4_MID_SIZE_128B = 3'b111;

typedef logic [M{0:02d}_AXI4_MID_SIZE_W-1:0] type_m{0:02d}_axi4_mid_size;

parameter M{0:02d}_AXI4_MID_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
parameter M{0:02d}_AXI4_MID_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
parameter M{0:02d}_AXI4_MID_CACHE_NO_ALLOCATE                            = 4'B0010;
parameter M{0:02d}_AXI4_MID_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
parameter M{0:02d}_AXI4_MID_CACHE_RESERVED_1                             = 4'B0100;
parameter M{0:02d}_AXI4_MID_CACHE_RESERVED_2                             = 4'B0101;
parameter M{0:02d}_AXI4_MID_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
parameter M{0:02d}_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
parameter M{0:02d}_AXI4_MID_CACHE_RESERVED_3                             = 4'B1000;
parameter M{0:02d}_AXI4_MID_CACHE_RESERVED_4                             = 4'B1001;
parameter M{0:02d}_AXI4_MID_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
parameter M{0:02d}_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
parameter M{0:02d}_AXI4_MID_CACHE_RESERVED_5                             = 4'B1100;
parameter M{0:02d}_AXI4_MID_CACHE_RESERVED_6                             = 4'B1101;
parameter M{0:02d}_AXI4_MID_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
parameter M{0:02d}_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

typedef logic [M{0:02d}_AXI4_MID_CACHE_W-1:0] type_m{0:02d}_axi4_mid_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

typedef struct packed {{
  type_m{0:02d}_axi4_mid_valid rvalid ; // Input Read channel valid
  type_m{0:02d}_axi4_mid_last  arready; // Input Read Address read channel ready
  type_m{0:02d}_axi4_mid_last  rlast  ; // Input Read channel last word
  type_m{0:02d}_axi4_mid_data  rdata  ; // Input Read channel data
  type_m{0:02d}_axi4_mid_id    rid    ; // Input Read channel ID
  type_m{0:02d}_axi4_mid_resp  rresp  ; // Input Read channel response
}} M{0:02d}_AXI4_MID_MasterReadInterfaceInput;

typedef struct packed {{
  type_m{0:02d}_axi4_mid_valid  arvalid ; // Output Read Address read channel valid
  type_m{0:02d}_axi4_mid_addr   araddr  ; // Output Read Address read channel address
  type_m{0:02d}_axi4_mid_len    arlen   ; // Output Read Address channel burst length
  type_m{0:02d}_axi4_mid_ready  rready  ; // Output Read Read channel ready
  type_m{0:02d}_axi4_mid_id     arid    ; // Output Read Address read channel ID
  type_m{0:02d}_axi4_mid_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_mid_burst  arburst ; // Output Read Address read channel burst type
  type_m{0:02d}_axi4_mid_lock   arlock  ; // Output Read Address read channel lock type
  type_m{0:02d}_axi4_mid_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_mid_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_mid_qos    arqos   ; // Output Read Address channel quality of service
  type_m{0:02d}_axi4_mid_region arregion;
}} M{0:02d}_AXI4_MID_MasterReadInterfaceOutput;

typedef struct packed {{
  M{0:02d}_AXI4_MID_MasterReadInterfaceInput  in ;
  M{0:02d}_AXI4_MID_MasterReadInterfaceOutput out;
}} M{0:02d}_AXI4_MID_MasterReadInterface;


typedef struct packed {{
  type_m{0:02d}_axi4_mid_ready awready; // Input Write Address write channel ready
  type_m{0:02d}_axi4_mid_ready wready ; // Input Write channel ready
  type_m{0:02d}_axi4_mid_id    bid    ; // Input Write response channel ID
  type_m{0:02d}_axi4_mid_resp  bresp  ; // Input Write channel response
  type_m{0:02d}_axi4_mid_valid bvalid ; // Input Write response channel valid
}} M{0:02d}_AXI4_MID_MasterWriteInterfaceInput;

typedef struct packed {{
  type_m{0:02d}_axi4_mid_valid  awvalid ; // Output Write Address write channel valid
  type_m{0:02d}_axi4_mid_id     awid    ; // Output Write Address write channel ID
  type_m{0:02d}_axi4_mid_addr   awaddr  ; // Output Write Address write channel address
  type_m{0:02d}_axi4_mid_len    awlen   ; // Output Write Address write channel burst length
  type_m{0:02d}_axi4_mid_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_mid_burst  awburst ; // Output Write Address write channel burst type
  type_m{0:02d}_axi4_mid_lock   awlock  ; // Output Write Address write channel lock type
  type_m{0:02d}_axi4_mid_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_mid_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_mid_qos    awqos   ; // Output Write Address write channel quality of service
  type_m{0:02d}_axi4_mid_data   wdata   ; // Output Write channel data
  type_m{0:02d}_axi4_mid_strb   wstrb   ; // Output Write channel write strobe
  type_m{0:02d}_axi4_mid_last   wlast   ; // Output Write channel last word flag
  type_m{0:02d}_axi4_mid_valid  wvalid  ; // Output Write channel valid
  type_m{0:02d}_axi4_mid_ready  bready  ; // Output Write response channel ready
  type_m{0:02d}_axi4_mid_region awregion;
}} M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput;

typedef struct packed {{
  M{0:02d}_AXI4_MID_MasterWriteInterfaceInput  in ;
  M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput out;
}} M{0:02d}_AXI4_MID_MasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

typedef struct packed {{
  type_m{0:02d}_axi4_mid_valid rvalid ; // Input Read channel valid
  type_m{0:02d}_axi4_mid_last  arready; // Input Read Address read channel ready
  type_m{0:02d}_axi4_mid_last  rlast  ; // Input Read channel last word
  type_m{0:02d}_axi4_mid_data  rdata  ; // Input Read channel data
  type_m{0:02d}_axi4_mid_id    rid    ; // Input Read channel ID
  type_m{0:02d}_axi4_mid_resp  rresp  ; // Input Read channel response
}} M{0:02d}_AXI4_MID_SlaveReadInterfaceOutput;

typedef struct packed {{
  type_m{0:02d}_axi4_mid_valid  arvalid ; // Output Read Address read channel valid
  type_m{0:02d}_axi4_mid_addr   araddr  ; // Output Read Address read channel address
  type_m{0:02d}_axi4_mid_len    arlen   ; // Output Read Address channel burst length
  type_m{0:02d}_axi4_mid_ready  rready  ; // Output Read Read channel ready
  type_m{0:02d}_axi4_mid_id     arid    ; // Output Read Address read channel ID
  type_m{0:02d}_axi4_mid_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_mid_burst  arburst ; // Output Read Address read channel burst type
  type_m{0:02d}_axi4_mid_lock   arlock  ; // Output Read Address read channel lock type
  type_m{0:02d}_axi4_mid_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_mid_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_mid_qos    arqos   ; // Output Read Address channel quality of service
  type_m{0:02d}_axi4_mid_region arregion;
}} M{0:02d}_AXI4_MID_SlaveReadInterfaceInput;

typedef struct packed {{
  M{0:02d}_AXI4_MID_SlaveReadInterfaceInput  in ;
  M{0:02d}_AXI4_MID_SlaveReadInterfaceOutput out;
}} M{0:02d}_AXI4_MID_SlaveReadInterface;


typedef struct packed {{
  type_m{0:02d}_axi4_mid_ready awready; // Input Write Address write channel ready
  type_m{0:02d}_axi4_mid_ready wready ; // Input Write channel ready
  type_m{0:02d}_axi4_mid_id    bid    ; // Input Write response channel ID
  type_m{0:02d}_axi4_mid_resp  bresp  ; // Input Write channel response
  type_m{0:02d}_axi4_mid_valid bvalid ; // Input Write response channel valid
}} M{0:02d}_AXI4_MID_SlaveWriteInterfaceOutput;

typedef struct packed {{
  type_m{0:02d}_axi4_mid_valid  awvalid ; // Output Write Address write channel valid
  type_m{0:02d}_axi4_mid_id     awid    ; // Output Write Address write channel ID
  type_m{0:02d}_axi4_mid_addr   awaddr  ; // Output Write Address write channel address
  type_m{0:02d}_axi4_mid_len    awlen   ; // Output Write Address write channel burst length
  type_m{0:02d}_axi4_mid_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_mid_burst  awburst ; // Output Write Address write channel burst type
  type_m{0:02d}_axi4_mid_lock   awlock  ; // Output Write Address write channel lock type
  type_m{0:02d}_axi4_mid_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_mid_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_mid_qos    awqos   ; // Output Write Address write channel quality of service
  type_m{0:02d}_axi4_mid_data   wdata   ; // Output Write channel data
  type_m{0:02d}_axi4_mid_strb   wstrb   ; // Output Write channel write strobe
  type_m{0:02d}_axi4_mid_last   wlast   ; // Output Write channel last word flag
  type_m{0:02d}_axi4_mid_valid  wvalid  ; // Output Write channel valid
  type_m{0:02d}_axi4_mid_ready  bready  ; // Output Write response channel ready
  type_m{0:02d}_axi4_mid_region awregion;
}} M{0:02d}_AXI4_MID_SlaveWriteInterfaceInput;

typedef struct packed {{
  M{0:02d}_AXI4_MID_SlaveWriteInterfaceInput  in ;
  M{0:02d}_AXI4_MID_SlaveWriteInterfaceOutput out;
}} M{0:02d}_AXI4_MID_SlaveWriteInterface;


function logic [M{0:02d}_AXI4_MID_DATA_W-1:0] swap_endianness_cacheline_m{0:02d}_axi_mid (logic [M{0:02d}_AXI4_MID_DATA_W-1:0] in, logic mode);

  logic [M{0:02d}_AXI4_MID_DATA_W-1:0] out;

  integer i;

  if(mode == 1) begin
    for ( i = 0; i < M{0:02d}_AXI4_MID_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M{0:02d}_AXI4_MID_DATA_W-1)-(i*8)) -:8];
    end
  end else begin
    out = in;
  end

  return out;
endfunction : swap_endianness_cacheline_m{0:02d}_axi_mid

  """

    fill_file_pkg_mxx_axi4_lite_mid_mid="""

// --------------------------------------------------------------------------------------
// AXI4 Lite 
// --------------------------------------------------------------------------------------

`AXI_TYPEDEF_ALL(m{0:02d}_axi, type_m{0:02d}_axi4_mid_addr, type_m{0:02d}_axi4_mid_id, type_m{0:02d}_axi4_mid_data, type_m{0:02d}_axi4_mid_strb, type_m{0:02d}_axi4_mid_user)
typedef m{0:02d}_axi_req_t M{0:02d}_AXI4_MID_REQ_T;
typedef m{0:02d}_axi_resp_t M{0:02d}_AXI4_MID_RESP_T;

parameter M{0:02d}_AXI4_LITE_MID_ADDR_W   = 17                 ;
parameter M{0:02d}_AXI4_LITE_MID_DATA_W   = 64                 ;
parameter M{0:02d}_AXI4_LITE_MID_STRB_W   = M{0:02d}_AXI4_LITE_MID_DATA_W / 8;
parameter M{0:02d}_AXI4_LITE_MID_ID_W     = 1                   ;
typedef logic [M{0:02d}_AXI4_LITE_MID_ADDR_W-1:0]   type_m{0:02d}_axi4_lite_mid_addr;
typedef logic [M{0:02d}_AXI4_LITE_MID_DATA_W-1:0]   type_m{0:02d}_axi4_lite_mid_data;
typedef logic [M{0:02d}_AXI4_LITE_MID_STRB_W-1:0]   type_m{0:02d}_axi4_lite_mid_strb;

`AXI_LITE_TYPEDEF_ALL(m{0:02d}_axi_lite, type_m{0:02d}_axi4_lite_mid_addr, type_m{0:02d}_axi4_lite_mid_data, type_m{0:02d}_axi4_lite_mid_strb)
typedef m{0:02d}_axi_lite_req_t  M{0:02d}_AXI4_LITE_MID_REQ_T;
typedef m{0:02d}_axi_lite_resp_t M{0:02d}_AXI4_LITE_MID_RESP_T;
typedef m{0:02d}_axi_lite_req_t  S{0:02d}_AXI4_LITE_MID_REQ_T;
typedef m{0:02d}_axi_lite_resp_t S{0:02d}_AXI4_LITE_MID_RESP_T;

  """

    fill_file_pkg_mxx_axi4_mid_end="""
endpackage
  """

    output_lines.append(fill_file_pkg_mxx_axi4_mid_pre)
    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(fill_file_pkg_mxx_axi4_mid_mid.format(channel,CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index]))
        output_lines.append(fill_file_pkg_mxx_axi4_lite_mid_mid.format(channel,CHANNEL_CONFIG_DATA_WIDTH_MID[index],CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index]))
    output_lines.append(fill_file_pkg_mxx_axi4_mid_end)

    file.write('\n'.join(output_lines))


with open(output_file_pkg_mxx_axi4_fe, "w") as file:
    output_lines = []

    fill_file_pkg_mxx_axi4_fe_pre="""
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : PKG_MXX_AXI4_FE.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_timescale.vh"
`include "typedef.svh"
package PKG_MXX_AXI4_FE;

parameter S_AXI_FE_ADDR_WIDTH_BITS = 12;
parameter S_AXI_FE_DATA_WIDTH      = 32;

  """

    fill_file_pkg_mxx_axi4_fe_mid="""
parameter M{0:02d}_AXI4_FE_ADDR_W   = {2}                 ;
parameter M{0:02d}_AXI4_FE_DATA_W   = {1}                 ;
parameter M{0:02d}_AXI4_FE_STRB_W   = M{0:02d}_AXI4_FE_DATA_W / 8;
parameter M{0:02d}_AXI4_FE_BURST_W  = 2                   ;
parameter M{0:02d}_AXI4_FE_CACHE_W  = 4                   ;
parameter M{0:02d}_AXI4_FE_PROT_W   = 3                   ;
parameter M{0:02d}_AXI4_FE_REGION_W = 4                   ;
parameter M{0:02d}_AXI4_FE_USER_W   = 4                   ;
parameter M{0:02d}_AXI4_FE_LOCK_W   = 1                   ;
parameter M{0:02d}_AXI4_FE_QOS_W    = 4                   ;
parameter M{0:02d}_AXI4_FE_LEN_W    = 8                   ;
parameter M{0:02d}_AXI4_FE_SIZE_W   = 3                   ;
parameter M{0:02d}_AXI4_FE_RESP_W   = 2                   ;
parameter M{0:02d}_AXI4_FE_ID_W     = 1                   ;

typedef logic                          type_m{0:02d}_axi4_fe_valid;
typedef logic                          type_m{0:02d}_axi4_fe_ready;
typedef logic                          type_m{0:02d}_axi4_fe_last;
typedef logic [M{0:02d}_AXI4_FE_ADDR_W-1:0]   type_m{0:02d}_axi4_fe_addr;
typedef logic [M{0:02d}_AXI4_FE_DATA_W-1:0]   type_m{0:02d}_axi4_fe_data;
typedef logic [M{0:02d}_AXI4_FE_STRB_W-1:0]   type_m{0:02d}_axi4_fe_strb;
typedef logic [M{0:02d}_AXI4_FE_LEN_W-1:0]    type_m{0:02d}_axi4_fe_len;
typedef logic [M{0:02d}_AXI4_FE_LOCK_W-1:0]   type_m{0:02d}_axi4_fe_lock;
typedef logic [M{0:02d}_AXI4_FE_PROT_W-1:0]   type_m{0:02d}_axi4_fe_prot;
typedef logic [M{0:02d}_AXI4_FE_REGION_W-1:0] type_m{0:02d}_axi4_fe_region;
typedef logic [M{0:02d}_AXI4_FE_QOS_W-1:0]    type_m{0:02d}_axi4_fe_qos;
typedef logic [M{0:02d}_AXI4_FE_ID_W-1:0]     type_m{0:02d}_axi4_fe_id;
typedef logic [M{0:02d}_AXI4_FE_USER_W-1:0]   type_m{0:02d}_axi4_fe_user;

parameter M{0:02d}_AXI4_FE_BURST_FIXED = 2'b00;
parameter M{0:02d}_AXI4_FE_BURST_INCR  = 2'b01;
parameter M{0:02d}_AXI4_FE_BURST_WRAP  = 2'b10;
parameter M{0:02d}_AXI4_FE_BURST_RSVD  = 2'b11;

typedef logic [M{0:02d}_AXI4_FE_BURST_W-1:0] type_m{0:02d}_axi4_fe_burst;

parameter M{0:02d}_AXI4_FE_RESP_OKAY   = 2'b00;
parameter M{0:02d}_AXI4_FE_RESP_EXOKAY = 2'b01;
parameter M{0:02d}_AXI4_FE_RESP_SLVERR = 2'b10;
parameter M{0:02d}_AXI4_FE_RESP_DECERR = 2'b11;

typedef logic [M{0:02d}_AXI4_FE_RESP_W-1:0] type_m{0:02d}_axi4_fe_resp;

parameter M{0:02d}_AXI4_FE_SIZE_1B   = 3'b000;
parameter M{0:02d}_AXI4_FE_SIZE_2B   = 3'b001;
parameter M{0:02d}_AXI4_FE_SIZE_4B   = 3'b010;
parameter M{0:02d}_AXI4_FE_SIZE_8B   = 3'b011;
parameter M{0:02d}_AXI4_FE_SIZE_16B  = 3'b100;
parameter M{0:02d}_AXI4_FE_SIZE_32B  = 3'b101;
parameter M{0:02d}_AXI4_FE_SIZE_64B  = 3'b110;
parameter M{0:02d}_AXI4_FE_SIZE_128B = 3'b111;

typedef logic [M{0:02d}_AXI4_FE_SIZE_W-1:0] type_m{0:02d}_axi4_fe_size;

parameter M{0:02d}_AXI4_FE_CACHE_NONCACHEABLE_NONBUFFERABLE             = 4'B0000;
parameter M{0:02d}_AXI4_FE_CACHE_BUFFERABLE_ONLY                        = 4'B0001;
parameter M{0:02d}_AXI4_FE_CACHE_NO_ALLOCATE                            = 4'B0010;
parameter M{0:02d}_AXI4_FE_CACHE_BUFFERABLE_NO_ALLOCATE                 = 4'B0011;
parameter M{0:02d}_AXI4_FE_CACHE_RESERVED_1                             = 4'B0100;
parameter M{0:02d}_AXI4_FE_CACHE_RESERVED_2                             = 4'B0101;
parameter M{0:02d}_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS        = 4'B0110;
parameter M{0:02d}_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_ON_READS           = 4'B0111;
parameter M{0:02d}_AXI4_FE_CACHE_RESERVED_3                             = 4'B1000;
parameter M{0:02d}_AXI4_FE_CACHE_RESERVED_4                             = 4'B1001;
parameter M{0:02d}_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_WRITES       = 4'B1010;
parameter M{0:02d}_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_ON_WRITES          = 4'B1011;
parameter M{0:02d}_AXI4_FE_CACHE_RESERVED_5                             = 4'B1100;
parameter M{0:02d}_AXI4_FE_CACHE_RESERVED_6                             = 4'B1101;
parameter M{0:02d}_AXI4_FE_CACHE_WRITE_THROUGH_ALLOCATE_ON_READS_WRITES = 4'B1110;
parameter M{0:02d}_AXI4_FE_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES       = 4'B1111;

typedef logic [M{0:02d}_AXI4_FE_CACHE_W-1:0] type_m{0:02d}_axi4_fe_cache;

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------

typedef struct packed {{
  type_m{0:02d}_axi4_fe_valid rvalid ; // Input Read channel valid
  type_m{0:02d}_axi4_fe_last  arready; // Input Read Address read channel ready
  type_m{0:02d}_axi4_fe_last  rlast  ; // Input Read channel last word
  type_m{0:02d}_axi4_fe_data  rdata  ; // Input Read channel data
  type_m{0:02d}_axi4_fe_id    rid    ; // Input Read channel ID
  type_m{0:02d}_axi4_fe_resp  rresp  ; // Input Read channel response
}} M{0:02d}_AXI4_FE_MasterReadInterfaceInput;

typedef struct packed {{
  type_m{0:02d}_axi4_fe_valid  arvalid ; // Output Read Address read channel valid
  type_m{0:02d}_axi4_fe_addr   araddr  ; // Output Read Address read channel address
  type_m{0:02d}_axi4_fe_len    arlen   ; // Output Read Address channel burst length
  type_m{0:02d}_axi4_fe_ready  rready  ; // Output Read Read channel ready
  type_m{0:02d}_axi4_fe_id     arid    ; // Output Read Address read channel ID
  type_m{0:02d}_axi4_fe_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_fe_burst  arburst ; // Output Read Address read channel burst type
  type_m{0:02d}_axi4_fe_lock   arlock  ; // Output Read Address read channel lock type
  type_m{0:02d}_axi4_fe_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_fe_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_fe_qos    arqos   ; // Output Read Address channel quality of service
  type_m{0:02d}_axi4_fe_region arregion;
}} M{0:02d}_AXI4_FE_MasterReadInterfaceOutput;

typedef struct packed {{
  M{0:02d}_AXI4_FE_MasterReadInterfaceInput  in ;
  M{0:02d}_AXI4_FE_MasterReadInterfaceOutput out;
}} M{0:02d}_AXI4_FE_MasterReadInterface;


typedef struct packed {{
  type_m{0:02d}_axi4_fe_ready awready; // Input Write Address write channel ready
  type_m{0:02d}_axi4_fe_ready wready ; // Input Write channel ready
  type_m{0:02d}_axi4_fe_id    bid    ; // Input Write response channel ID
  type_m{0:02d}_axi4_fe_resp  bresp  ; // Input Write channel response
  type_m{0:02d}_axi4_fe_valid bvalid ; // Input Write response channel valid
}} M{0:02d}_AXI4_FE_MasterWriteInterfaceInput;

typedef struct packed {{
  type_m{0:02d}_axi4_fe_valid  awvalid ; // Output Write Address write channel valid
  type_m{0:02d}_axi4_fe_id     awid    ; // Output Write Address write channel ID
  type_m{0:02d}_axi4_fe_addr   awaddr  ; // Output Write Address write channel address
  type_m{0:02d}_axi4_fe_len    awlen   ; // Output Write Address write channel burst length
  type_m{0:02d}_axi4_fe_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_fe_burst  awburst ; // Output Write Address write channel burst type
  type_m{0:02d}_axi4_fe_lock   awlock  ; // Output Write Address write channel lock type
  type_m{0:02d}_axi4_fe_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_fe_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_fe_qos    awqos   ; // Output Write Address write channel quality of service
  type_m{0:02d}_axi4_fe_data   wdata   ; // Output Write channel data
  type_m{0:02d}_axi4_fe_strb   wstrb   ; // Output Write channel write strobe
  type_m{0:02d}_axi4_fe_last   wlast   ; // Output Write channel last word flag
  type_m{0:02d}_axi4_fe_valid  wvalid  ; // Output Write channel valid
  type_m{0:02d}_axi4_fe_ready  bready  ; // Output Write response channel ready
  type_m{0:02d}_axi4_fe_region awregion;
}} M{0:02d}_AXI4_FE_MasterWriteInterfaceOutput;

typedef struct packed {{
  M{0:02d}_AXI4_FE_MasterWriteInterfaceInput  in ;
  M{0:02d}_AXI4_FE_MasterWriteInterfaceOutput out;
}} M{0:02d}_AXI4_FE_MasterWriteInterface;

// --------------------------------------------------------------------------------------
// AXI4 Slave
// --------------------------------------------------------------------------------------

typedef struct packed {{
  type_m{0:02d}_axi4_fe_valid rvalid ; // Input Read channel valid
  type_m{0:02d}_axi4_fe_last  arready; // Input Read Address read channel ready
  type_m{0:02d}_axi4_fe_last  rlast  ; // Input Read channel last word
  type_m{0:02d}_axi4_fe_data  rdata  ; // Input Read channel data
  type_m{0:02d}_axi4_fe_id    rid    ; // Input Read channel ID
  type_m{0:02d}_axi4_fe_resp  rresp  ; // Input Read channel response
}} M{0:02d}_AXI4_FE_SlaveReadInterfaceOutput;

typedef struct packed {{
  type_m{0:02d}_axi4_fe_valid  arvalid ; // Output Read Address read channel valid
  type_m{0:02d}_axi4_fe_addr   araddr  ; // Output Read Address read channel address
  type_m{0:02d}_axi4_fe_len    arlen   ; // Output Read Address channel burst length
  type_m{0:02d}_axi4_fe_ready  rready  ; // Output Read Read channel ready
  type_m{0:02d}_axi4_fe_id     arid    ; // Output Read Address read channel ID
  type_m{0:02d}_axi4_fe_size   arsize  ; // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_fe_burst  arburst ; // Output Read Address read channel burst type
  type_m{0:02d}_axi4_fe_lock   arlock  ; // Output Read Address read channel lock type
  type_m{0:02d}_axi4_fe_cache  arcache ; // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_fe_prot   arprot  ; // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_fe_qos    arqos   ; // Output Read Address channel quality of service
  type_m{0:02d}_axi4_fe_region arregion;
}} M{0:02d}_AXI4_FE_SlaveReadInterfaceInput;

typedef struct packed {{
  M{0:02d}_AXI4_FE_SlaveReadInterfaceInput  in ;
  M{0:02d}_AXI4_FE_SlaveReadInterfaceOutput out;
}} M{0:02d}_AXI4_FE_SlaveReadInterface;


typedef struct packed {{
  type_m{0:02d}_axi4_fe_ready awready; // Input Write Address write channel ready
  type_m{0:02d}_axi4_fe_ready wready ; // Input Write channel ready
  type_m{0:02d}_axi4_fe_id    bid    ; // Input Write response channel ID
  type_m{0:02d}_axi4_fe_resp  bresp  ; // Input Write channel response
  type_m{0:02d}_axi4_fe_valid bvalid ; // Input Write response channel valid
}} M{0:02d}_AXI4_FE_SlaveWriteInterfaceOutput;

typedef struct packed {{
  type_m{0:02d}_axi4_fe_valid  awvalid ; // Output Write Address write channel valid
  type_m{0:02d}_axi4_fe_id     awid    ; // Output Write Address write channel ID
  type_m{0:02d}_axi4_fe_addr   awaddr  ; // Output Write Address write channel address
  type_m{0:02d}_axi4_fe_len    awlen   ; // Output Write Address write channel burst length
  type_m{0:02d}_axi4_fe_size   awsize  ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  type_m{0:02d}_axi4_fe_burst  awburst ; // Output Write Address write channel burst type
  type_m{0:02d}_axi4_fe_lock   awlock  ; // Output Write Address write channel lock type
  type_m{0:02d}_axi4_fe_cache  awcache ; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  type_m{0:02d}_axi4_fe_prot   awprot  ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  type_m{0:02d}_axi4_fe_qos    awqos   ; // Output Write Address write channel quality of service
  type_m{0:02d}_axi4_fe_data   wdata   ; // Output Write channel data
  type_m{0:02d}_axi4_fe_strb   wstrb   ; // Output Write channel write strobe
  type_m{0:02d}_axi4_fe_last   wlast   ; // Output Write channel last word flag
  type_m{0:02d}_axi4_fe_valid  wvalid  ; // Output Write channel valid
  type_m{0:02d}_axi4_fe_ready  bready  ; // Output Write response channel ready
  type_m{0:02d}_axi4_fe_region awregion;
}} M{0:02d}_AXI4_FE_SlaveWriteInterfaceInput;

typedef struct packed {{
  M{0:02d}_AXI4_FE_SlaveWriteInterfaceInput  in ;
  M{0:02d}_AXI4_FE_SlaveWriteInterfaceOutput out;
}} M{0:02d}_AXI4_FE_SlaveWriteInterface;


function logic [M{0:02d}_AXI4_FE_DATA_W-1:0] swap_endianness_cacheline_m{0:02d}_axi_fe (logic [M{0:02d}_AXI4_FE_DATA_W-1:0] in, logic mode);

  logic [M{0:02d}_AXI4_FE_DATA_W-1:0] out;

  integer i;

  if(mode == 1) begin
    for ( i = 0; i < M{0:02d}_AXI4_FE_STRB_W; i++) begin
      out[i*8 +: 8] = in[((M{0:02d}_AXI4_FE_DATA_W-1)-(i*8)) -:8];
    end
  end else begin
    out = in;
  end

  return out;
endfunction : swap_endianness_cacheline_m{0:02d}_axi_fe

  """

    fill_file_pkg_mxx_axi4_lite_fe_mid="""

// --------------------------------------------------------------------------------------
// AXI4 Lite 
// --------------------------------------------------------------------------------------

`AXI_TYPEDEF_ALL(m{0:02d}_axi, type_m{0:02d}_axi4_fe_addr, type_m{0:02d}_axi4_fe_id, type_m{0:02d}_axi4_fe_data, type_m{0:02d}_axi4_fe_strb, type_m{0:02d}_axi4_fe_user)
typedef m{0:02d}_axi_req_t M{0:02d}_AXI4_FE_REQ_T;
typedef m{0:02d}_axi_resp_t M{0:02d}_AXI4_FE_RESP_T;

parameter M{0:02d}_AXI4_LITE_FE_ADDR_W   = 17                 ;
parameter M{0:02d}_AXI4_LITE_FE_DATA_W   = 64                 ;
parameter M{0:02d}_AXI4_LITE_FE_STRB_W   = M{0:02d}_AXI4_LITE_FE_DATA_W / 8;
parameter M{0:02d}_AXI4_LITE_FE_ID_W     = 1                   ;
typedef logic [M{0:02d}_AXI4_LITE_FE_ADDR_W-1:0]   type_m{0:02d}_axi4_lite_fe_addr;
typedef logic [M{0:02d}_AXI4_LITE_FE_DATA_W-1:0]   type_m{0:02d}_axi4_lite_fe_data;
typedef logic [M{0:02d}_AXI4_LITE_FE_STRB_W-1:0]   type_m{0:02d}_axi4_lite_fe_strb;

`AXI_LITE_TYPEDEF_ALL(m{0:02d}_axi_lite, type_m{0:02d}_axi4_lite_fe_addr, type_m{0:02d}_axi4_lite_fe_data, type_m{0:02d}_axi4_lite_fe_strb)
typedef m{0:02d}_axi_lite_req_t  M{0:02d}_AXI4_LITE_FE_REQ_T;
typedef m{0:02d}_axi_lite_resp_t M{0:02d}_AXI4_LITE_FE_RESP_T;
typedef m{0:02d}_axi_lite_req_t  S{0:02d}_AXI4_LITE_FE_REQ_T;
typedef m{0:02d}_axi_lite_resp_t S{0:02d}_AXI4_LITE_FE_RESP_T;

  """

    fill_file_pkg_mxx_axi4_fe_end="""
endpackage
  """

    output_lines.append(fill_file_pkg_mxx_axi4_fe_pre)
    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(fill_file_pkg_mxx_axi4_fe_mid.format(channel,CHANNEL_CONFIG_DATA_WIDTH_FE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index], formatted_datetime))
        output_lines.append(fill_file_pkg_mxx_axi4_lite_fe_mid.format(channel,CHANNEL_CONFIG_DATA_WIDTH_FE[index],CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index], formatted_datetime))
    output_lines.append(fill_file_pkg_mxx_axi4_fe_end)

    file.write('\n'.join(output_lines))


fill_mxx_axi_register_slice_be_wrapper_module = []

fill_mxx_axi_register_slice_be_wrapper_pre="""
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : mxx_axi_register_slice_be_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
"""

fill_mxx_axi_register_slice_be_wrapper="""

module m{0:02d}_axi_register_slice_be_{1}x{2}_wrapper (
  // System Signals
  input  logic                                  ap_clk         ,
  input  logic                                  areset         ,
  output M{0:02d}_AXI4_BE_SlaveReadInterfaceOutput   s_axi_read_out ,
  input  M{0:02d}_AXI4_BE_SlaveReadInterfaceInput    s_axi_read_in  ,
  output M{0:02d}_AXI4_BE_SlaveWriteInterfaceOutput  s_axi_write_out,
  input  M{0:02d}_AXI4_BE_SlaveWriteInterfaceInput   s_axi_write_in ,
  input  M{0:02d}_AXI4_BE_MasterReadInterfaceInput   m_axi_read_in  ,
  output M{0:02d}_AXI4_BE_MasterReadInterfaceOutput  m_axi_read_out ,
  input  M{0:02d}_AXI4_BE_MasterWriteInterfaceInput  m_axi_write_in ,
  output M{0:02d}_AXI4_BE_MasterWriteInterfaceOutput m_axi_write_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_register_slice;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
M{0:02d}_AXI4_BE_MasterReadInterface  m_axi_read ;
M{0:02d}_AXI4_BE_MasterWriteInterface m_axi_write;
M{0:02d}_AXI4_BE_SlaveReadInterface   s_axi_read ;
M{0:02d}_AXI4_BE_SlaveWriteInterface  s_axi_write;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_register_slice <= ~areset;
end

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_write.in = m_axi_write_in;
assign m_axi_read.in  = m_axi_read_in;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out  = m_axi_read.out;
assign m_axi_write_out = m_axi_write.out;

// --------------------------------------------------------------------------------------
// AXI4 SLAVE
// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign s_axi_write_out = s_axi_write.out;
assign s_axi_read_out  = s_axi_read.out;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign s_axi_read.in  = s_axi_read_in;
assign s_axi_write.in = s_axi_write_in;

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
m{0:02d}_axi_register_slice_be_512x64 inst_m{0:02d}_axi_register_slice_be_{1}x{2} (
  .aclk          (ap_clk                  ),
  .aresetn       (areset_register_slice   ),
  .s_axi_araddr  (s_axi_read.in.araddr    ), // input read address read channel address
  .s_axi_arburst (s_axi_read.in.arburst   ), // input read address read channel burst type
  .s_axi_arcache (s_axi_read.in.arcache   ), // input read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .s_axi_arid    (s_axi_read.in.arid      ), // input read address read channel id
  .s_axi_arlen   (s_axi_read.in.arlen     ), // input read address channel burst length
  .s_axi_arlock  (s_axi_read.in.arlock    ), // input read address read channel lock type
  .s_axi_arprot  (s_axi_read.in.arprot    ), // input read address channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .s_axi_arqos   (s_axi_read.in.arqos     ), // input read address channel quality of service
  .s_axi_arready (s_axi_read.out.arready  ), // output read address read channel ready
  .s_axi_arregion(s_axi_read.in.arregion  ),
  .s_axi_arsize  (s_axi_read.in.arsize    ), // input read address read channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_arvalid (s_axi_read.in.arvalid   ), // input read address read channel valid
  .s_axi_awaddr  (s_axi_write.in.awaddr   ), // input write address write channel address
  .s_axi_awburst (s_axi_write.in.awburst  ), // input write address write channel burst type
  .s_axi_awcache (s_axi_write.in.awcache  ), // input write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .s_axi_awid    (s_axi_write.in.awid     ), // input write address write channel id
  .s_axi_awlen   (s_axi_write.in.awlen    ), // input write address write channel burst length
  .s_axi_awlock  (s_axi_write.in.awlock   ), // input write address write channel lock type
  .s_axi_awprot  (s_axi_write.in.awprot   ), // input write address write channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .s_axi_awqos   (s_axi_write.in.awqos    ), // input write address write channel quality of service
  .s_axi_awready (s_axi_write.out.awready ), // output write address write channel ready
  .s_axi_awregion(s_axi_write.in.awregion ),
  .s_axi_awsize  (s_axi_write.in.awsize   ), // input write address write channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_awvalid (s_axi_write.in.awvalid  ), // input write address write channel valid
  .s_axi_bid     (s_axi_write.out.bid     ), // output write response channel id
  .s_axi_bready  (s_axi_write.in.bready   ), // input write response channel ready
  .s_axi_bresp   (s_axi_write.out.bresp   ), // output write channel response
  .s_axi_bvalid  (s_axi_write.out.bvalid  ), // output write response channel valid
  .s_axi_rdata   (s_axi_read.out.rdata    ), // output read channel data
  .s_axi_rid     (s_axi_read.out.rid      ), // output read channel id
  .s_axi_rlast   (s_axi_read.out.rlast    ), // output read channel last word
  .s_axi_rready  (s_axi_read.in.rready    ), // input read read channel ready
  .s_axi_rresp   (s_axi_read.out.rresp    ), // output read channel response
  .s_axi_rvalid  (s_axi_read.out.rvalid   ), // output read channel valid
  .s_axi_wdata   (s_axi_write.in.wdata    ), // input write channel data
  .s_axi_wlast   (s_axi_write.in.wlast    ), // input write channel last word flag
  .s_axi_wready  (s_axi_write.out.wready  ), // output write channel ready
  .s_axi_wstrb   (s_axi_write.in.wstrb    ), // input write channel write strobe
  .s_axi_wvalid  (s_axi_write.in.wvalid   ), // input write channel valid
  
  .m_axi_araddr  (m_axi_read.out.araddr   ), // output read address read channel address
  .m_axi_arburst (m_axi_read.out.arburst  ), // output read address read channel burst type
  .m_axi_arcache (m_axi_read.out.arcache  ), // output read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .m_axi_arid    (m_axi_read.out.arid     ), // output read address read channel id
  .m_axi_arlen   (m_axi_read.out.arlen    ), // output read address channel burst length
  .m_axi_arlock  (m_axi_read.out.arlock   ), // output read address read channel lock type
  .m_axi_arprot  (m_axi_read.out.arprot   ), // output read address channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .m_axi_arqos   (m_axi_read.out.arqos    ), // output read address channel quality of service
  .m_axi_arready (m_axi_read.in.arready   ), // input read address read channel ready
  .m_axi_arregion(m_axi_read.out.arregion ),
  .m_axi_arsize  (m_axi_read.out.arsize   ), // output read address read channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_arvalid (m_axi_read.out.arvalid  ), // output read address read channel valid
  .m_axi_awaddr  (m_axi_write.out.awaddr  ), // output write address write channel address
  .m_axi_awburst (m_axi_write.out.awburst ), // output write address write channel burst type
  .m_axi_awcache (m_axi_write.out.awcache ), // output write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .m_axi_awid    (m_axi_write.out.awid    ), // output write address write channel id
  .m_axi_awlen   (m_axi_write.out.awlen   ), // output write address write channel burst length
  .m_axi_awlock  (m_axi_write.out.awlock  ), // output write address write channel lock type
  .m_axi_awprot  (m_axi_write.out.awprot  ), // output write address write channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .m_axi_awqos   (m_axi_write.out.awqos   ), // output write address write channel quality of service
  .m_axi_awready (m_axi_write.in.awready  ), // input write address write channel ready
  .m_axi_awregion(m_axi_write.out.awregion),
  .m_axi_awsize  (m_axi_write.out.awsize  ), // output write address write channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_awvalid (m_axi_write.out.awvalid ), // output write address write channel valid
  .m_axi_bid     (m_axi_write.in.bid      ), // input write response channel id
  .m_axi_bready  (m_axi_write.out.bready  ), // output write response channel ready
  .m_axi_bresp   (m_axi_write.in.bresp    ), // input write channel response
  .m_axi_bvalid  (m_axi_write.in.bvalid   ), // input write response channel valid
  .m_axi_rdata   (m_axi_read.in.rdata     ), // input read channel data
  .m_axi_rid     (m_axi_read.in.rid       ), // input read channel id
  .m_axi_rlast   (m_axi_read.in.rlast     ), // input read channel last word
  .m_axi_rready  (m_axi_read.out.rready   ), // output read read channel ready
  .m_axi_rresp   (m_axi_read.in.rresp     ), // input read channel response
  .m_axi_rvalid  (m_axi_read.in.rvalid    ), // input read channel valid
  .m_axi_wdata   (m_axi_write.out.wdata   ), // output write channel data
  .m_axi_wlast   (m_axi_write.out.wlast   ), // output write channel last word flag
  .m_axi_wready  (m_axi_write.in.wready   ), // input write channel ready
  .m_axi_wstrb   (m_axi_write.out.wstrb   ), // output write channel write strobe
  .m_axi_wvalid  (m_axi_write.out.wvalid  )  // output write channel valid
);

endmodule : m{0:02d}_axi_register_slice_be_{1}x{2}_wrapper

  """


output_file_mxx_axi_register_slice_be_wrapper = os.path.join(output_folder_path_slice,f"mxx_axi_register_slice_be_wrapper.sv")
check_and_clean_file(output_file_mxx_axi_register_slice_be_wrapper)

with open(output_file_mxx_axi_register_slice_be_wrapper, "w") as file:
    fill_mxx_axi_register_slice_be_wrapper_module.append(fill_mxx_axi_register_slice_be_wrapper_pre.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index], formatted_datetime))
    for index, channel in enumerate(DISTINCT_CHANNELS):
        fill_mxx_axi_register_slice_be_wrapper_module.append(fill_mxx_axi_register_slice_be_wrapper.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index], formatted_datetime))
    
    file.write('\n'.join(fill_mxx_axi_register_slice_be_wrapper_module))


fill_mxx_axi_register_slice_mid_wrapper_module=[]

fill_mxx_axi_register_slice_mid_wrapper_pre="""
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : mxx_axi_register_slice_mid_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
  """

fill_mxx_axi_register_slice_mid_wrapper="""

module m{0:02d}_axi_register_slice_mid_{1}x{2}_wrapper (
  // System Signals
  input  logic                                  ap_clk         ,
  input  logic                                  areset         ,
  output M{0:02d}_AXI4_MID_SlaveReadInterfaceOutput   s_axi_read_out ,
  input  M{0:02d}_AXI4_MID_SlaveReadInterfaceInput    s_axi_read_in  ,
  output M{0:02d}_AXI4_MID_SlaveWriteInterfaceOutput  s_axi_write_out,
  input  M{0:02d}_AXI4_MID_SlaveWriteInterfaceInput   s_axi_write_in ,
  input  M{0:02d}_AXI4_MID_MasterReadInterfaceInput   m_axi_read_in  ,
  output M{0:02d}_AXI4_MID_MasterReadInterfaceOutput  m_axi_read_out ,
  input  M{0:02d}_AXI4_MID_MasterWriteInterfaceInput  m_axi_write_in ,
  output M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput m_axi_write_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_register_slice;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
M{0:02d}_AXI4_MID_MasterReadInterface  m_axi_read ;
M{0:02d}_AXI4_MID_MasterWriteInterface m_axi_write;
M{0:02d}_AXI4_MID_SlaveReadInterface   s_axi_read ;
M{0:02d}_AXI4_MID_SlaveWriteInterface  s_axi_write;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_register_slice <= ~areset;
end

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_write.in = m_axi_write_in;
assign m_axi_read.in  = m_axi_read_in;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out  = m_axi_read.out;
assign m_axi_write_out = m_axi_write.out;

// --------------------------------------------------------------------------------------
// AXI4 SLAVE
// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign s_axi_write_out = s_axi_write.out;
assign s_axi_read_out  = s_axi_read.out;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign s_axi_read.in  = s_axi_read_in;
assign s_axi_write.in = s_axi_write_in;

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
m{0:02d}_axi_register_slice_mid_{1}x{2} inst_m{0:02d}_axi_register_slice_mid_{1}x{2} (
  .aclk          (ap_clk                  ),
  .aresetn       (areset_register_slice   ),
  .s_axi_araddr  (s_axi_read.in.araddr    ), // input read address read channel address
  .s_axi_arburst (s_axi_read.in.arburst   ), // input read address read channel burst type
  .s_axi_arcache (s_axi_read.in.arcache   ), // input read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .s_axi_arid    (s_axi_read.in.arid      ), // input read address read channel id
  .s_axi_arlen   (s_axi_read.in.arlen     ), // input read address channel burst length
  .s_axi_arlock  (s_axi_read.in.arlock    ), // input read address read channel lock type
  .s_axi_arprot  (s_axi_read.in.arprot    ), // input read address channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .s_axi_arqos   (s_axi_read.in.arqos     ), // input read address channel quality of service
  .s_axi_arready (s_axi_read.out.arready  ), // output read address read channel ready
  .s_axi_arregion(s_axi_read.in.arregion  ),
  .s_axi_arsize  (s_axi_read.in.arsize    ), // input read address read channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_arvalid (s_axi_read.in.arvalid   ), // input read address read channel valid
  .s_axi_awaddr  (s_axi_write.in.awaddr   ), // input write address write channel address
  .s_axi_awburst (s_axi_write.in.awburst  ), // input write address write channel burst type
  .s_axi_awcache (s_axi_write.in.awcache  ), // input write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .s_axi_awid    (s_axi_write.in.awid     ), // input write address write channel id
  .s_axi_awlen   (s_axi_write.in.awlen    ), // input write address write channel burst length
  .s_axi_awlock  (s_axi_write.in.awlock   ), // input write address write channel lock type
  .s_axi_awprot  (s_axi_write.in.awprot   ), // input write address write channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .s_axi_awqos   (s_axi_write.in.awqos    ), // input write address write channel quality of service
  .s_axi_awready (s_axi_write.out.awready ), // output write address write channel ready
  .s_axi_awregion(s_axi_write.in.awregion ),
  .s_axi_awsize  (s_axi_write.in.awsize   ), // input write address write channel burst size. this signal indicates the size of each transfer out the burst
  .s_axi_awvalid (s_axi_write.in.awvalid  ), // input write address write channel valid
  .s_axi_bid     (s_axi_write.out.bid     ), // output write response channel id
  .s_axi_bready  (s_axi_write.in.bready   ), // input write response channel ready
  .s_axi_bresp   (s_axi_write.out.bresp   ), // output write channel response
  .s_axi_bvalid  (s_axi_write.out.bvalid  ), // output write response channel valid
  .s_axi_rdata   (s_axi_read.out.rdata    ), // output read channel data
  .s_axi_rid     (s_axi_read.out.rid      ), // output read channel id
  .s_axi_rlast   (s_axi_read.out.rlast    ), // output read channel last word
  .s_axi_rready  (s_axi_read.in.rready    ), // input read read channel ready
  .s_axi_rresp   (s_axi_read.out.rresp    ), // output read channel response
  .s_axi_rvalid  (s_axi_read.out.rvalid   ), // output read channel valid
  .s_axi_wdata   (s_axi_write.in.wdata    ), // input write channel data
  .s_axi_wlast   (s_axi_write.in.wlast    ), // input write channel last word flag
  .s_axi_wready  (s_axi_write.out.wready  ), // output write channel ready
  .s_axi_wstrb   (s_axi_write.in.wstrb    ), // input write channel write strobe
  .s_axi_wvalid  (s_axi_write.in.wvalid   ), // input write channel valid
  
  .m_axi_araddr  (m_axi_read.out.araddr   ), // output read address read channel address
  .m_axi_arburst (m_axi_read.out.arburst  ), // output read address read channel burst type
  .m_axi_arcache (m_axi_read.out.arcache  ), // output read address read channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .m_axi_arid    (m_axi_read.out.arid     ), // output read address read channel id
  .m_axi_arlen   (m_axi_read.out.arlen    ), // output read address channel burst length
  .m_axi_arlock  (m_axi_read.out.arlock   ), // output read address read channel lock type
  .m_axi_arprot  (m_axi_read.out.arprot   ), // output read address channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .m_axi_arqos   (m_axi_read.out.arqos    ), // output read address channel quality of service
  .m_axi_arready (m_axi_read.in.arready   ), // input read address read channel ready
  .m_axi_arregion(m_axi_read.out.arregion ),
  .m_axi_arsize  (m_axi_read.out.arsize   ), // output read address read channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_arvalid (m_axi_read.out.arvalid  ), // output read address read channel valid
  .m_axi_awaddr  (m_axi_write.out.awaddr  ), // output write address write channel address
  .m_axi_awburst (m_axi_write.out.awburst ), // output write address write channel burst type
  .m_axi_awcache (m_axi_write.out.awcache ), // output write address write channel memory type. transactions set with normal non-cacheable modifiable and bufferable ({0:02d}11).
  .m_axi_awid    (m_axi_write.out.awid    ), // output write address write channel id
  .m_axi_awlen   (m_axi_write.out.awlen   ), // output write address write channel burst length
  .m_axi_awlock  (m_axi_write.out.awlock  ), // output write address write channel lock type
  .m_axi_awprot  (m_axi_write.out.awprot  ), // output write address write channel protection type. transactions set with normal, secure, and data attributes ({0:02d}0).
  .m_axi_awqos   (m_axi_write.out.awqos   ), // output write address write channel quality of service
  .m_axi_awready (m_axi_write.in.awready  ), // input write address write channel ready
  .m_axi_awregion(m_axi_write.out.awregion),
  .m_axi_awsize  (m_axi_write.out.awsize  ), // output write address write channel burst size. this signal indicates the size of each transfer in the burst
  .m_axi_awvalid (m_axi_write.out.awvalid ), // output write address write channel valid
  .m_axi_bid     (m_axi_write.in.bid      ), // input write response channel id
  .m_axi_bready  (m_axi_write.out.bready  ), // output write response channel ready
  .m_axi_bresp   (m_axi_write.in.bresp    ), // input write channel response
  .m_axi_bvalid  (m_axi_write.in.bvalid   ), // input write response channel valid
  .m_axi_rdata   (m_axi_read.in.rdata     ), // input read channel data
  .m_axi_rid     (m_axi_read.in.rid       ), // input read channel id
  .m_axi_rlast   (m_axi_read.in.rlast     ), // input read channel last word
  .m_axi_rready  (m_axi_read.out.rready   ), // output read read channel ready
  .m_axi_rresp   (m_axi_read.in.rresp     ), // input read channel response
  .m_axi_rvalid  (m_axi_read.in.rvalid    ), // input read channel valid
  .m_axi_wdata   (m_axi_write.out.wdata   ), // output write channel data
  .m_axi_wlast   (m_axi_write.out.wlast   ), // output write channel last word flag
  .m_axi_wready  (m_axi_write.in.wready   ), // input write channel ready
  .m_axi_wstrb   (m_axi_write.out.wstrb   ), // output write channel write strobe
  .m_axi_wvalid  (m_axi_write.out.wvalid  )  // output write channel valid
);

endmodule : m{0:02d}_axi_register_slice_mid_{1}x{2}_wrapper

  """

output_file_mxx_axi_register_slice_mid_wrapper = os.path.join(output_folder_path_slice,f"mxx_axi_register_slice_mid_wrapper.sv")
check_and_clean_file(output_file_mxx_axi_register_slice_mid_wrapper)

with open(output_file_mxx_axi_register_slice_mid_wrapper, "w") as file:
    fill_mxx_axi_register_slice_mid_wrapper_module.append(fill_mxx_axi_register_slice_mid_wrapper_pre.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index], formatted_datetime))
    for index, channel in enumerate(DISTINCT_CHANNELS):
        fill_mxx_axi_register_slice_mid_wrapper_module.append(fill_mxx_axi_register_slice_mid_wrapper.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index], formatted_datetime))
    
    file.write('\n'.join(fill_mxx_axi_register_slice_mid_wrapper_module))

fill_mxx_axi_lite_register_slice_mid_wrapper_module = []

fill_mxx_axi_lite_register_slice_mid_wrapper_pre="""
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m{0:02d}_axi_lite_register_slice_mid_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
"""

fill_mxx_axi_lite_register_slice_mid_wrapper="""

module m{0:02d}_axi_lite_register_slice_mid_{1}x{2}_wrapper (
  // System Signals
  input  logic                   ap_clk,
  input  logic                   areset,
  input  M{0:02d}_AXI4_LITE_MID_RESP_T m_axi_lite_in,
  output M{0:02d}_AXI4_LITE_MID_REQ_T  m_axi_lite_out,
  input  S{0:02d}_AXI4_LITE_MID_REQ_T  s_axi_lite_in,
  output S{0:02d}_AXI4_LITE_MID_RESP_T s_axi_lite_out
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_register_slice;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_register_slice <= ~areset;
end

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
m{0:02d}_axi_lite_register_slice_mid_{1}x{2} inst_m{0:02d}_axi_lite_register_slice_mid_{1}x{2} (
  .aclk         (ap_clk                 ),
  .aresetn      (areset_register_slice  ),
  .s_axi_araddr (s_axi_lite_in.ar.addr  ), // : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  .s_axi_arprot (s_axi_lite_in.ar.prot  ), // : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  .s_axi_arready(s_axi_lite_out.ar_ready), // : OUT STD_LOGIC;
  .s_axi_arvalid(s_axi_lite_in.ar_valid ), // : IN STD_LOGIC;
  .s_axi_awaddr (s_axi_lite_in.aw.addr  ), // : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  .s_axi_awprot (s_axi_lite_in.aw.prot  ), // : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  .s_axi_awready(s_axi_lite_out.aw_ready),
  .s_axi_awvalid(s_axi_lite_in.aw_valid ), // : IN STD_LOGIC;
  .s_axi_bready (s_axi_lite_in.b_ready  ), // : IN STD_LOGIC;
  .s_axi_bresp  (s_axi_lite_out.b.resp  ), // : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  .s_axi_bvalid (s_axi_lite_out.b_valid ), // : OUT STD_LOGIC;
  .s_axi_rdata  (s_axi_lite_out.r.data  ), // : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  .s_axi_rready (s_axi_lite_in.r_ready  ), // : IN STD_LOGIC;
  .s_axi_rresp  (s_axi_lite_out.r.resp  ), // : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  .s_axi_rvalid (s_axi_lite_out.r_valid ), // : OUT STD_LOGIC;
  .s_axi_wdata  (s_axi_lite_in.w.data   ), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  .s_axi_wready (s_axi_lite_out.w_ready ),
  .s_axi_wstrb  (s_axi_lite_in.w.strb   ),
  .s_axi_wvalid (s_axi_lite_in.w_valid  ), // : IN STD_LOGIC;
  
  .m_axi_araddr (m_axi_lite_out.ar.addr ), // : out STD_LOGIC_VECTOR(16 DOWNTO 0);
  .m_axi_arprot (m_axi_lite_out.ar.prot ), // : out STD_LOGIC_VECTOR(2 DOWNTO 0);
  .m_axi_arready(m_axi_lite_in.ar_ready ), // : in STD_LOGIC;
  .m_axi_arvalid(m_axi_lite_out.ar_valid), // : out STD_LOGIC;
  .m_axi_awaddr (m_axi_lite_out.aw.addr ), // : out STD_LOGIC_VECTOR(16 DOWNTO 0);
  .m_axi_awprot (m_axi_lite_out.aw.prot ), // : out STD_LOGIC_VECTOR(2 DOWNTO 0);
  .m_axi_awready(m_axi_lite_in.aw_ready ),
  .m_axi_awvalid(m_axi_lite_out.aw_valid), // : out STD_LOGIC;
  .m_axi_bready (m_axi_lite_out.b_ready ), // : out STD_LOGIC;
  .m_axi_bresp  (m_axi_lite_in.b.resp   ), // : in STD_LOGIC_VECTOR(1 DOWNTO 0);
  .m_axi_bvalid (m_axi_lite_in.b_valid  ), // : in STD_LOGIC;
  .m_axi_rdata  (m_axi_lite_in.r.data   ), // : in STD_LOGIC_VECTOR(63 DOWNTO 0);
  .m_axi_rready (m_axi_lite_out.r_ready ), // : out STD_LOGIC;
  .m_axi_rresp  (m_axi_lite_in.r.resp   ), // : in STD_LOGIC_VECTOR(1 DOWNTO 0);
  .m_axi_rvalid (m_axi_lite_in.r_valid  ), // : in STD_LOGIC;
  .m_axi_wdata  (m_axi_lite_out.w.data  ), // : out STD_LOGIC_VECTOR(63 DOWNTO 0);
  .m_axi_wready (m_axi_lite_in.w_ready  ),
  .m_axi_wstrb  (m_axi_lite_out.w.strb  ),
  .m_axi_wvalid (m_axi_lite_out.w_valid )  // : out STD_LOGIC;
);

endmodule : m{0:02d}_axi_lite_register_slice_mid_{1}x{2}_wrapper

  """


output_file_mxx_axi_lite_register_slice_mid_wrapper = os.path.join(output_folder_path_slice,f"mxx_axi_lite_register_slice_mid_wrapper.sv")
check_and_clean_file(output_file_mxx_axi_lite_register_slice_mid_wrapper)

with open(output_file_mxx_axi_lite_register_slice_mid_wrapper, "w") as file:
    fill_mxx_axi_lite_register_slice_mid_wrapper_module.append(fill_mxx_axi_lite_register_slice_mid_wrapper_pre.format(channel, 64, 17, formatted_datetime))
    for index, channel in enumerate(DISTINCT_CHANNELS):
        if(int(CACHE_CONFIG_L2_CTRL[index])):
            fill_mxx_axi_lite_register_slice_mid_wrapper_module.append(fill_mxx_axi_lite_register_slice_mid_wrapper.format(channel, 64, 17, formatted_datetime))
    
    file.write('\n'.join(fill_mxx_axi_lite_register_slice_mid_wrapper_module))


fill_kernel_mxx_axi_system_cache_wrapper_module = []

fill_kernel_mxx_axi_system_cache_wrapper_pre="""
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : kernel_mxx_axi_system_cache_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
"""

fill_kernel_mxx_axi_system_cache_wrapper="""

module kernel_m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}_wrapper (
  // System Signals
  input  logic                                  ap_clk            ,
  input  logic                                  areset            ,
  output M{0:02d}_AXI4_MID_SlaveReadInterfaceOutput  s_axi_read_out    ,
  input  M{0:02d}_AXI4_MID_SlaveReadInterfaceInput   s_axi_read_in     ,
  output M{0:02d}_AXI4_MID_SlaveWriteInterfaceOutput s_axi_write_out   ,
  input  M{0:02d}_AXI4_MID_SlaveWriteInterfaceInput  s_axi_write_in    ,
  input  M{0:02d}_AXI4_BE_MasterReadInterfaceInput   m_axi_read_in     ,
  output M{0:02d}_AXI4_BE_MasterReadInterfaceOutput  m_axi_read_out    ,
  input  M{0:02d}_AXI4_BE_MasterWriteInterfaceInput  m_axi_write_in    ,
  output M{0:02d}_AXI4_BE_MasterWriteInterfaceOutput m_axi_write_out   ,
  input  S{0:02d}_AXI4_LITE_MID_REQ_T                s_axi_lite_in     ,
  output S{0:02d}_AXI4_LITE_MID_RESP_T               s_axi_lite_out    ,
  output logic                                  cache_setup_signal
);

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic areset_system_cache;
logic areset_control     ;

logic cache_setup_signal_int;

logic m_axi_read_out_araddr_63 ;
logic m_axi_write_out_awaddr_63;
// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
M{0:02d}_AXI4_BE_MasterReadInterface  m_axi_read ;
M{0:02d}_AXI4_BE_MasterWriteInterface m_axi_write;
M{0:02d}_AXI4_MID_SlaveReadInterface  s_axi_read ;
M{0:02d}_AXI4_MID_SlaveWriteInterface s_axi_write;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_control      <= areset;
  areset_system_cache <= ~areset;
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    cache_setup_signal <= 1'b1;
  end
  else begin
    cache_setup_signal <= cache_setup_signal_int;
  end
end

// --------------------------------------------------------------------------------------
// AXI4 MASTER
// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_write.in = m_axi_write_in;
assign m_axi_read.in  = m_axi_read_in;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 MASTER SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out  = m_axi_read.out;
assign m_axi_write_out = m_axi_write.out;

// --------------------------------------------------------------------------------------
// AXI4 SLAVE
// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign s_axi_write_out = s_axi_write.out;
assign s_axi_read_out  = s_axi_read.out;

// --------------------------------------------------------------------------------------
// DRIVE AXI4 SLAVE SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign s_axi_read.in  = s_axi_read_in;
assign s_axi_write.in = s_axi_write_in;

// --------------------------------------------------------------------------------------
// System cache
// --------------------------------------------------------------------------------------
assign m_axi_read.out.araddr[63]  = 1'b0;
assign m_axi_write.out.awaddr[63] = 1'b0;
assign m_axi_write.out.awregion   = 0;
assign m_axi_read.out.arregion    = 0;

m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4} inst_m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4} (

  .S0_AXI_GEN_ARUSER (0                           ),
  .S0_AXI_GEN_AWUSER (0                           ),
  .S0_AXI_GEN_RVALID (s_axi_read.out.rvalid       ), // Output Read channel valid
  .S0_AXI_GEN_ARREADY(s_axi_read.out.arready      ), // Output Read Address read channel ready
  .S0_AXI_GEN_RLAST  (s_axi_read.out.rlast        ), // Output Read channel last word
  .S0_AXI_GEN_RDATA  (s_axi_read.out.rdata        ), // Output Read channel data
  .S0_AXI_GEN_RID    (s_axi_read.out.rid          ), // Output Read channel ID
  .S0_AXI_GEN_RRESP  (s_axi_read.out.rresp        ), // Output Read channel response
  .S0_AXI_GEN_ARVALID(s_axi_read.in.arvalid       ), // Input Read Address read channel valid
  .S0_AXI_GEN_ARADDR (s_axi_read.in.araddr        ), // Input Read Address read channel address
  .S0_AXI_GEN_ARLEN  (s_axi_read.in.arlen         ), // Input Read Address channel burst length
  .S0_AXI_GEN_RREADY (s_axi_read.in.rready        ), // Input Read Read channel ready
  .S0_AXI_GEN_ARID   (s_axi_read.in.arid          ), // Input Read Address read channel ID
  .S0_AXI_GEN_ARSIZE (s_axi_read.in.arsize        ), // Input Read Address read channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_ARBURST(s_axi_read.in.arburst       ), // Input Read Address read channel burst type
  .S0_AXI_GEN_ARLOCK (s_axi_read.in.arlock        ), // Input Read Address read channel lock type
  .S0_AXI_GEN_ARCACHE(s_axi_read.in.arcache       ), // Input Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_ARPROT (s_axi_read.in.arprot        ), // Input Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_ARQOS  (s_axi_read.in.arqos         ), // Input Read Address channel quality of service
  .S0_AXI_GEN_AWREADY(s_axi_write.out.awready     ), // Output Write Address write channel ready
  .S0_AXI_GEN_WREADY (s_axi_write.out.wready      ), // Output Write channel ready
  .S0_AXI_GEN_BID    (s_axi_write.out.bid         ), // Output Write response channel ID
  .S0_AXI_GEN_BRESP  (s_axi_write.out.bresp       ), // Output Write channel response
  .S0_AXI_GEN_BVALID (s_axi_write.out.bvalid      ), // Output Write response channel valid
  .S0_AXI_GEN_AWVALID(s_axi_write.in.awvalid      ), // Input Write Address write channel valid
  .S0_AXI_GEN_AWID   (s_axi_write.in.awid         ), // Input Write Address write channel ID
  .S0_AXI_GEN_AWADDR (s_axi_write.in.awaddr       ), // Input Write Address write channel address
  .S0_AXI_GEN_AWLEN  (s_axi_write.in.awlen        ), // Input Write Address write channel burst length
  .S0_AXI_GEN_AWSIZE (s_axi_write.in.awsize       ), // Input Write Address write channel burst size. This signal indicates the size of each transfer out the burst
  .S0_AXI_GEN_AWBURST(s_axi_write.in.awburst      ), // Input Write Address write channel burst type
  .S0_AXI_GEN_AWLOCK (s_axi_write.in.awlock       ), // Input Write Address write channel lock type
  .S0_AXI_GEN_AWCACHE(s_axi_write.in.awcache      ), // Input Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .S0_AXI_GEN_AWPROT (s_axi_write.in.awprot       ), // Input Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .S0_AXI_GEN_AWQOS  (s_axi_write.in.awqos        ), // Input Write Address write channel quality of service
  .S0_AXI_GEN_WDATA  (s_axi_write.in.wdata        ), // Input Write channel data
  .S0_AXI_GEN_WSTRB  (s_axi_write.in.wstrb        ), // Input Write channel write strobe
  .S0_AXI_GEN_WLAST  (s_axi_write.in.wlast        ), // Input Write channel last word flag
  .S0_AXI_GEN_WVALID (s_axi_write.in.wvalid       ), // Input Write channel valid
  .S0_AXI_GEN_BREADY (s_axi_write.in.bready       ), // Input Write response channel ready

  .M0_AXI_RVALID     (m_axi_read.in.rvalid        ), // Input Read channel valid
  .M0_AXI_ARREADY    (m_axi_read.in.arready       ), // Input Read Address read channel ready
  .M0_AXI_RLAST      (m_axi_read.in.rlast         ), // Input Read channel last word
  .M0_AXI_RDATA      (m_axi_read.in.rdata         ), // Input Read channel data
  .M0_AXI_RID        (m_axi_read.in.rid           ), // Input Read channel ID
  .M0_AXI_RRESP      (m_axi_read.in.rresp         ), // Input Read channel response
  .M0_AXI_ARVALID    (m_axi_read.out.arvalid      ), // Output Read Address read channel valid
  .M0_AXI_ARADDR     ({{m_axi_read_out_araddr_63, m_axi_read.out.araddr[62:0]}} ), // Output Read Address read channel address
  .M0_AXI_ARLEN      (m_axi_read.out.arlen        ), // Output Read Address channel burst length
  .M0_AXI_RREADY     (m_axi_read.out.rready       ), // Output Read Read channel ready
  .M0_AXI_ARID       (m_axi_read.out.arid         ), // Output Read Address read channel ID
  .M0_AXI_ARSIZE     (m_axi_read.out.arsize       ), // Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_ARBURST    (m_axi_read.out.arburst      ), // Output Read Address read channel burst type
  .M0_AXI_ARLOCK     (m_axi_read.out.arlock       ), // Output Read Address read channel lock type
  .M0_AXI_ARCACHE    (m_axi_read.out.arcache      ), // Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_ARPROT     (m_axi_read.out.arprot       ), // Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_ARQOS      (m_axi_read.out.arqos        ), // Output Read Address channel quality of service
  .M0_AXI_AWREADY    (m_axi_write.in.awready      ), // Input Write Address write channel ready
  .M0_AXI_WREADY     (m_axi_write.in.wready       ), // Input Write channel ready
  .M0_AXI_BID        (m_axi_write.in.bid          ), // Input Write response channel ID
  .M0_AXI_BRESP      (m_axi_write.in.bresp        ), // Input Write channel response
  .M0_AXI_BVALID     (m_axi_write.in.bvalid       ), // Input Write response channel valid
  .M0_AXI_AWVALID    (m_axi_write.out.awvalid     ), // Output Write Address write channel valid
  .M0_AXI_AWID       (m_axi_write.out.awid        ), // Output Write Address write channel ID
  .M0_AXI_AWADDR     ({{m_axi_write_out_awaddr_63, m_axi_write.out.awaddr[62:0]}}), // Output Write Address write channel address
  .M0_AXI_AWLEN      (m_axi_write.out.awlen       ), // Output Write Address write channel burst length
  .M0_AXI_AWSIZE     (m_axi_write.out.awsize      ), // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
  .M0_AXI_AWBURST    (m_axi_write.out.awburst     ), // Output Write Address write channel burst type
  .M0_AXI_AWLOCK     (m_axi_write.out.awlock      ), // Output Write Address write channel lock type
  .M0_AXI_AWCACHE    (m_axi_write.out.awcache     ), // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .M0_AXI_AWPROT     (m_axi_write.out.awprot      ), // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .M0_AXI_AWQOS      (m_axi_write.out.awqos       ), // Output Write Address write channel quality of service
  .M0_AXI_WDATA      (m_axi_write.out.wdata       ), // Output Write channel data
  .M0_AXI_WSTRB      (m_axi_write.out.wstrb       ), // Output Write channel write strobe
  .M0_AXI_WLAST      (m_axi_write.out.wlast       ), // Output Write channel last word flag
  .M0_AXI_WVALID     (m_axi_write.out.wvalid      ), // Output Write channel valid
  .M0_AXI_BREADY     (m_axi_write.out.bready      ),  // Output Write response channel ready
    """

fill_kernel_mxx_axi_system_cache_wrapper_ctrl="""
  .S_AXI_CTRL_AWADDR (s_axi_lite_in.aw.addr       ), // : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  .S_AXI_CTRL_AWPROT (s_axi_lite_in.aw.prot       ), // : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  .S_AXI_CTRL_AWVALID(s_axi_lite_in.aw_valid      ), // : IN STD_LOGIC;
  .S_AXI_CTRL_AWREADY(s_axi_lite_out.aw_ready     ),
  .S_AXI_CTRL_WDATA  (s_axi_lite_in.w.data        ), // : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  .S_AXI_CTRL_WVALID (s_axi_lite_in.w_valid       ), // : IN STD_LOGIC;
  .S_AXI_CTRL_WREADY (s_axi_lite_out.w_ready      ),
  .S_AXI_CTRL_BRESP  (s_axi_lite_out.b.resp       ), // : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  .S_AXI_CTRL_BVALID (s_axi_lite_out.b_valid      ), // : OUT STD_LOGIC;
  .S_AXI_CTRL_BREADY (s_axi_lite_in.b_ready       ), // : IN STD_LOGIC;
  .S_AXI_CTRL_ARADDR (s_axi_lite_in.ar.addr       ), // : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  .S_AXI_CTRL_ARPROT (s_axi_lite_in.ar.prot       ), // : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  .S_AXI_CTRL_ARVALID(s_axi_lite_in.ar_valid      ), // : IN STD_LOGIC;
  .S_AXI_CTRL_ARREADY(s_axi_lite_out.ar_ready     ), // : OUT STD_LOGIC;
  .S_AXI_CTRL_RDATA  (s_axi_lite_out.r.data       ), // : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  .S_AXI_CTRL_RRESP  (s_axi_lite_out.r.resp       ), // : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  .S_AXI_CTRL_RVALID (s_axi_lite_out.r_valid      ), // : OUT STD_LOGIC;
  .S_AXI_CTRL_RREADY (s_axi_lite_in.r_ready       ), // : IN STD_LOGIC;
    """

fill_kernel_mxx_axi_system_cache_wrapper_post_if="""
  .ACLK              (ap_clk                      ),
  .ARESETN           (areset_system_cache         ),
  .Initializing      (cache_setup_signal_int      )
);

endmodule : kernel_m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}_wrapper

"""

fill_kernel_mxx_axi_system_cache_wrapper_post_else="""
  .ACLK              (ap_clk                      ),
  .ARESETN           (areset_system_cache         ),
  .Initializing      (cache_setup_signal_int      )    
);

assign s_axi_lite_out = 0;

endmodule : kernel_m{0:02d}_axi_system_cache_be{1}x{2}_mid{3}x{4}_wrapper

"""

output_file_kernel_mxx_axi_system_cache_wrapper = os.path.join(output_folder_path_kernel,f"kernel_mxx_axi_system_cache_wrapper.sv")
check_and_clean_file(output_file_kernel_mxx_axi_system_cache_wrapper)

with open(output_file_kernel_mxx_axi_system_cache_wrapper, "w") as file:
    fill_kernel_mxx_axi_system_cache_wrapper_module.append(fill_kernel_mxx_axi_system_cache_wrapper_pre.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],formatted_datetime))
    for index, channel in enumerate(DISTINCT_CHANNELS):
        fill_kernel_mxx_axi_system_cache_wrapper_module.append(fill_kernel_mxx_axi_system_cache_wrapper.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],formatted_datetime))
        if(int(CACHE_CONFIG_L2_CTRL[index])):
            fill_kernel_mxx_axi_system_cache_wrapper_module.append(fill_kernel_mxx_axi_system_cache_wrapper_ctrl.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],formatted_datetime))
            fill_kernel_mxx_axi_system_cache_wrapper_module.append(fill_kernel_mxx_axi_system_cache_wrapper_post_if.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],formatted_datetime))
        else:
            fill_kernel_mxx_axi_system_cache_wrapper_module.append(fill_kernel_mxx_axi_system_cache_wrapper_post_else.format(channel, CHANNEL_CONFIG_DATA_WIDTH_BE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_BE[index],CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],formatted_datetime))
     
    file.write('\n'.join(fill_kernel_mxx_axi_system_cache_wrapper_module))



with open(output_file_kernel_cu_topology, 'w') as file:
    output_lines = []

    output_file_kernel_cu_topology_template = """
// --------------------------------------------------------------------------------------
// CU Cache -> AXI-CH {1}
// --------------------------------------------------------------------------------------


M{0:02d}_AXI4_MID_MasterReadInterfaceInput   cu_m{0:02d}_axi_read_in  ;
M{0:02d}_AXI4_MID_MasterReadInterfaceOutput  cu_m{0:02d}_axi_read_out ;
M{0:02d}_AXI4_MID_MasterWriteInterfaceInput  cu_m{0:02d}_axi_write_in ;
M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput cu_m{0:02d}_axi_write_out;

M{0:02d}_AXI4_LITE_MID_RESP_T cu_m{0:02d}_axi_lite_in;
M{0:02d}_AXI4_LITE_MID_REQ_T  cu_m{0:02d}_axi_lite_out;

generate
// --------------------------------------------------------------------------------------
    if(CHANNEL_CONFIG_L1_CACHE[{1}] == 1) begin
// --------------------------------------------------------------------------------------
// CU Cache -> AXI Kernel Cache
      m{0:02d}_axi_cu_cache_mid{2}x{3}_fe{4}x{5}_wrapper inst_cu_cache_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[{1}]                   ),
        .descriptor_in            (cu_channel_descriptor[{1}]               ),
        .request_in               (cu_channel_request_in[{1}]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[{1}] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[{1}]  ),
        .response_out             (cu_channel_response_out[{1}]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[{1}]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[{1}] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[{1}]        ),
        .m_axi_read_in            (cu_m{0:02d}_axi_read_in                  ),
        .m_axi_read_out           (cu_m{0:02d}_axi_read_out                 ),
        .m_axi_write_in           (cu_m{0:02d}_axi_write_in                 ),
        .m_axi_write_out          (cu_m{0:02d}_axi_write_out                ),
        .m_axi_lite_in            (cu_m{0:02d}_axi_lite_in                  ),
        .m_axi_lite_out           (cu_m{0:02d}_axi_lite_out                 ),
        .done_out                 (cu_channel_done_out[{1}]                 )
      );
    end else if(CHANNEL_CONFIG_L1_CACHE[{1}] == 2) begin
// CU SRAN -> AXI Kernel Cache
      m{0:02d}_axi_cu_sram_mid{2}x{3}_fe{4}x{5}_wrapper inst_cu_sram_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[{1}]                   ),
        .descriptor_in            (cu_channel_descriptor[{1}]               ),
        .request_in               (cu_channel_request_in[{1}]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[{1}] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[{1}]  ),
        .response_out             (cu_channel_response_out[{1}]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[{1}]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[{1}] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[{1}]        ),
        .m_axi_read_in            (cu_m{0:02d}_axi_read_in                  ),
        .m_axi_read_out           (cu_m{0:02d}_axi_read_out                 ),
        .m_axi_write_in           (cu_m{0:02d}_axi_write_in                 ),
        .m_axi_write_out          (cu_m{0:02d}_axi_write_out                ),
        .m_axi_lite_in            (cu_m{0:02d}_axi_lite_in                  ),
        .m_axi_lite_out           (cu_m{0:02d}_axi_lite_out                 ),
        .done_out                 (cu_channel_done_out[{1}]                 )
      );
    end else begin
// CU BUFFER -> AXI Kernel Cache
      m{0:02d}_axi_cu_stream_mid{2}x{3}_fe{4}x{5}_wrapper inst_cu_stream_l1 (
        .ap_clk                   (ap_clk                                 ),
        .areset                   (areset_cu_channel[{1}]                   ),
        .descriptor_in            (cu_channel_descriptor[{1}]               ),
        .request_in               (cu_channel_request_in[{1}]               ),
        .fifo_request_signals_out (cu_channel_fifo_request_signals_out[{1}] ),
        .fifo_request_signals_in  (cu_channel_fifo_request_signals_in[{1}]  ),
        .response_out             (cu_channel_response_out[{1}]             ),
        .fifo_response_signals_out(cu_channel_fifo_response_signals_out[{1}]),
        .fifo_response_signals_in (cu_channel_fifo_response_signals_in[{1}] ),
        .fifo_setup_signal        (cu_channel_fifo_setup_signal[{1}]        ),
        .m_axi_read_in            (cu_m{0:02d}_axi_read_in                  ),
        .m_axi_read_out           (cu_m{0:02d}_axi_read_out                 ),
        .m_axi_write_in           (cu_m{0:02d}_axi_write_in                 ),
        .m_axi_write_out          (cu_m{0:02d}_axi_write_out                ),
        .m_axi_lite_in            (cu_m{0:02d}_axi_lite_in                  ),
        .m_axi_lite_out           (cu_m{0:02d}_axi_lite_out                 ),
        .done_out                 (cu_channel_done_out[{1}]                 )
      );
    end
endgenerate
// --------------------------------------------------------------------------------------
// Generate CU CACHE CH {1} (M->S) Register Slice
// --------------------------------------------------------------------------------------
    m{0:02d}_axi_register_slice_mid_{2}x{3}_wrapper inst_m{0:02d}_axi_register_slice_mid_{2}x{3}_wrapper_ch (
      .ap_clk         (ap_clk                 ),
      .areset         (areset_axi_slice[{1}]    ),
      .s_axi_read_out (cu_m{0:02d}_axi_read_in  ),
      .s_axi_read_in  (cu_m{0:02d}_axi_read_out ),
      .s_axi_write_out(cu_m{0:02d}_axi_write_in ),
      .s_axi_write_in (cu_m{0:02d}_axi_write_out),
      .m_axi_read_in  (m{0:02d}_axi_read_in     ),
      .m_axi_read_out (m{0:02d}_axi_read_out    ),
      .m_axi_write_in (m{0:02d}_axi_write_in    ),
      .m_axi_write_out(m{0:02d}_axi_write_out   )
    );
    """

    output_file_axi_lite_ctrl_template_if = """
// --------------------------------------------------------------------------------------
// Generate CU CACHE CH {1} Lite (M->S) Register Slice
// --------------------------------------------------------------------------------------
    m{0:02d}_axi_lite_register_slice_mid_64x17_wrapper inst_m{0:02d}_axi_lite_register_slice_mid_64x17_wrapper
        (
            .ap_clk         (ap_clk),
            .areset         (areset_axi_lite_slice[{1}]),
            .m_axi_lite_in  (m{0:02d}_axi_lite_in) ,
            .m_axi_lite_out (m{0:02d}_axi_lite_out),
            .s_axi_lite_in  (cu_m{0:02d}_axi_lite_out),
            .s_axi_lite_out (cu_m{0:02d}_axi_lite_in )
        );
    """

    output_file_axi_lite_ctrl_template_else = """
// --------------------------------------------------------------------------------------
// Generate CU CACHE CH {1} Lite (M->S) Register Slice
// --------------------------------------------------------------------------------------
    assign cu_m{0:02d}_axi_lite_in = 0;
    assign m{0:02d}_axi_lite_out = 0;
    """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(output_file_kernel_cu_topology_template.format(channel, index,CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index]))
        if(int(CACHE_CONFIG_L2_CTRL[index])):
            output_lines.append(output_file_axi_lite_ctrl_template_if.format(channel, index,CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index]))
        else:
            output_lines.append(output_file_axi_lite_ctrl_template_else.format(channel, index,CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index]))
          
    file.write('\n'.join(output_lines))


with open(output_file_kernel_cu_ports, 'w') as file:
    output_lines = []

    output_file_kernel_cu_ports_template = """
  input  M{0:02d}_AXI4_MID_MasterReadInterfaceInput   m{0:02d}_axi_read_in  ,
  output M{0:02d}_AXI4_MID_MasterReadInterfaceOutput  m{0:02d}_axi_read_out ,
  input  M{0:02d}_AXI4_MID_MasterWriteInterfaceInput  m{0:02d}_axi_write_in ,
  output M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput m{0:02d}_axi_write_out,
  input  M{0:02d}_AXI4_LITE_MID_RESP_T                m{0:02d}_axi_lite_in  ,
  output M{0:02d}_AXI4_LITE_MID_REQ_T                 m{0:02d}_axi_lite_out ,
    """

    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(output_file_kernel_cu_ports_template.format(channel, index,CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index]))

    file.write('\n'.join(output_lines))


with open(output_file_kernel_cu_portmap, 'w') as file:
    output_lines = []

    output_file_kernel_cu_portmap_template = """
.m{0:02d}_axi_read_in  (kernel_s{0:02d}_axi_read_out ),
.m{0:02d}_axi_read_out (kernel_s{0:02d}_axi_read_in  ),
.m{0:02d}_axi_write_in (kernel_s{0:02d}_axi_write_out),
.m{0:02d}_axi_write_out(kernel_s{0:02d}_axi_write_in ),

.m{0:02d}_axi_lite_in (kernel_m{0:02d}_axi_lite_in),
.m{0:02d}_axi_lite_out(kernel_m{0:02d}_axi_lite_out),
    """
    for index, channel in enumerate(DISTINCT_CHANNELS):
        output_lines.append(output_file_kernel_cu_portmap_template.format(channel, index,CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index]))

    file.write('\n'.join(output_lines))

if int(PAUSE_FILE_GENERATION):
    print("MSG: Pause CU cache/buffer module generation.")
    sys.exit()  # Exits the script


fill_cu_mxx_axi_cu_cache_wrapper_module = []

fill_cu_mxx_axi_cu_cache_wrapper_pre="""
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m{0:02d}_axi_cu_cache_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
"""

fill_cu_mxx_axi_cu_cache_wrapper="""

module m{0:02d}_axi_cu_cache_mid{1}x{2}_fe{3}x{4}_wrapper #(
  parameter FIFO_WRITE_DEPTH = 64,
  parameter PROG_THRESH      = 32
) (
  // System Signals
  input  logic                                   ap_clk                   ,
  input  logic                                   areset                   ,
  input  KernelDescriptor                        descriptor_in            ,
  input  MemoryPacketRequest                     request_in               ,
  output FIFOStateSignalsOutput                  fifo_request_signals_out ,
  input  FIFOStateSignalsInput                   fifo_request_signals_in  ,
  output MemoryPacketResponse                    response_out             ,
  output FIFOStateSignalsOutput                  fifo_response_signals_out,
  input  FIFOStateSignalsInput                   fifo_response_signals_in ,
  output logic                                   fifo_setup_signal        ,
  input  M{0:02d}_AXI4_MID_MasterReadInterfaceInput   m_axi_read_in            ,
  output M{0:02d}_AXI4_MID_MasterReadInterfaceOutput  m_axi_read_out           ,
  input  M{0:02d}_AXI4_MID_MasterWriteInterfaceInput  m_axi_write_in           ,
  output M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput m_axi_write_out          ,
  input  M{0:02d}_AXI4_LITE_MID_RESP_T                m_axi_lite_in            ,
  output M{0:02d}_AXI4_LITE_MID_REQ_T                 m_axi_lite_out           ,
  output logic                                   done_out
);

assign m_axi_lite_out = 0;
// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic            areset_fifo      ;
logic            areset_cache     ;
logic            areset_control   ;
KernelDescriptor descriptor_in_reg;

MemoryPacketRequest request_in_reg      ;
CacheRequest        cache_request_in_reg;
CacheResponse       response_in_int     ;

logic fifo_empty_int;
logic fifo_empty_reg;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
M{0:02d}_AXI4_MID_MasterReadInterface  m_axi_read ;
M{0:02d}_AXI4_MID_MasterWriteInterface m_axi_write;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
CacheRequestPayload   cache_request_mem    ;
CacheRequestPayload   cache_request_mem_reg;
CacheResponsePayload  cache_response_mem   ;
CacheControlIOBOutput cache_ctrl_in        ;
CacheControlIOBOutput cache_ctrl_out       ;

// --------------------------------------------------------------------------------------
// Cache request FIFO
// --------------------------------------------------------------------------------------
CacheRequestPayload           fifo_request_din                  ;
CacheRequestPayload           fifo_request_dout                 ;
FIFOStateSignalsOutInternal   fifo_request_signals_out_int      ;
FIFOStateSignalsInput         fifo_request_signals_in_reg       ;
FIFOStateSignalsInputInternal fifo_request_signals_in_int       ;
logic                         fifo_request_setup_signal_int     ;
logic                         fifo_request_signals_out_valid_int;

// --------------------------------------------------------------------------------------
// Memory response FIFO
// --------------------------------------------------------------------------------------
MemoryPacketResponsePayload   fifo_response_din             ;
MemoryPacketResponsePayload   fifo_response_dout            ;
FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
logic                           areset_counter                  ;
logic                           counter_load                    ;
logic                           write_command_counter_is_zero   ;
logic [CACHE_WTBUF_DEPTH_W-1:0] write_command_counter_          ;
logic [CACHE_WTBUF_DEPTH_W-1:0] write_command_counter_load_value;

assign write_command_counter_load_value = ((CACHE_WTBUF_DEPTH_W**2)-1);

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_fifo    <= areset;
  areset_control <= areset;
  areset_cache   <= areset;
  areset_counter <= areset;
end

// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    descriptor_in_reg.valid <= 0;
  end
  else begin
    if(descriptor_in.valid)begin
      descriptor_in_reg.valid   <= descriptor_in.valid;
      descriptor_in_reg.payload <= descriptor_in.payload;
    end
  end
end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    request_in_reg.valid         <= 1'b0;
    cache_request_in_reg.valid   <= 1'b0;
    fifo_response_signals_in_reg <= 0;
    fifo_request_signals_in_reg  <= 0;
  end
  else begin
    request_in_reg.valid         <= request_in.valid;
    cache_request_in_reg.valid   <= request_in_reg.valid;
    fifo_response_signals_in_reg <= fifo_response_signals_in;
    fifo_request_signals_in_reg  <= fifo_request_signals_in;
  end
end

always_ff @(posedge ap_clk) begin
  request_in_reg.payload       <= request_in.payload;
  cache_request_in_reg.payload <= map_MemoryRequestPacket_to_CacheRequest(request_in_reg.payload, descriptor_in_reg.payload, request_in_reg.valid);
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal  <= 1'b1;
    response_out.valid <= 1'b0;
    done_out           <= 1'b0;
    fifo_empty_reg     <= 1'b1;
  end
  else begin
    fifo_setup_signal  <= fifo_request_setup_signal_int | fifo_response_setup_signal_int;
    response_out.valid <= response_in_int.valid;
    done_out           <= fifo_empty_reg;
    fifo_empty_reg     <= fifo_empty_int;
  end
end

assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty & cache_ctrl_out.wtb_empty & cache_response_mem.iob.ready;

always_ff @(posedge ap_clk) begin
  fifo_request_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
  fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
  response_out.payload      <= response_in_int.payload;
end

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_write.in = m_axi_write_in;

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign m_axi_read.in = m_axi_read_in;

// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_write_out = m_axi_write.out;

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out = m_axi_read.out;

// --------------------------------------------------------------------------------------
// AXI port cache
// --------------------------------------------------------------------------------------
assign cache_ctrl_in.force_inv = 1'b0;
assign cache_ctrl_in.wtb_empty = 1'b1;

iob_cache_axi #(
  .FE_ADDR_W           (M{0:02d}_AXI4_FE_ADDR_W                                 ),
  .FE_DATA_W           (M{0:02d}_AXI4_FE_DATA_W                                 ),
  .BE_ADDR_W           (M{0:02d}_AXI4_MID_ADDR_W                                ),
  .BE_DATA_W           (M{0:02d}_AXI4_MID_DATA_W                                ),
  .NWAYS_W             ({6}                                                     ),
  .NLINES_W            ($clog2({5})                                             ),
  .WORD_OFFSET_W       ($clog2(M{0:02d}_AXI4_MID_DATA_W*{7}/M{0:02d}_AXI4_FE_DATA_W)),
  .WTBUF_DEPTH_W       (CACHE_WTBUF_DEPTH_W                                ),
  .REP_POLICY          (CACHE_REP_POLICY                                   ),
  .WRITE_POL           (CACHE_WRITE_POL                                    ),
  .USE_CTRL            (CACHE_CTRL_CACHE                                   ),
  .USE_CTRL_CNT        (CACHE_CTRL_CACHE                                   ),
  .AXI_ID_W            (M00_AXI4_MID_ID_W                                  ),
  .AXI_ID              (0                                                  ),
  .AXI_LEN_W           (M00_AXI4_MID_LEN_W                                 ),
  .AXI_ADDR_W          (M{0:02d}_AXI4_MID_ADDR_W                           ),
  .AXI_DATA_W          (M{0:02d}_AXI4_MID_DATA_W                           ),
  .CACHE_AXI_CACHE_MODE(M{0:02d}_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES)
) inst_iob_cache_axi (
  .iob_avalid_i(cache_request_mem.iob.valid                                                           ),
  .iob_addr_i  (cache_request_mem.iob.addr [CACHE_CTRL_CNT+M{0:02d}_AXI4_FE_ADDR_W-1:$clog2(M{0:02d}_AXI4_FE_DATA_W/8)]),
  .iob_wdata_i (cache_request_mem.iob.wdata                                                           ),
  .iob_wstrb_i (cache_request_mem.iob.wstrb                                                           ),
  .iob_rdata_o (cache_response_mem.iob.rdata                                                          ),
  .iob_rvalid_o(cache_response_mem.iob.valid                                                          ),
  .iob_ready_o (cache_response_mem.iob.ready                                                          ),
  .invalidate_i(cache_ctrl_in.force_inv                                                               ),
  .invalidate_o(cache_ctrl_out.force_inv                                                              ),
  .wtb_empty_i (cache_ctrl_in.wtb_empty                                                               ),
  .wtb_empty_o (cache_ctrl_out.wtb_empty                                                              ),
  `include "m_axi_portmap_cache.vh"
  .clk_i       (ap_clk                                                                                ),
  .cke_i       (1'b1                                                                                  ),
  .arst_i      (areset_cache                                                                          )
);

// --------------------------------------------------------------------------------------
// Cache request FIFO FWFT
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_signals_in_int.wr_en = cache_request_in_reg.valid;
assign fifo_request_din.iob              = cache_request_in_reg.payload.iob;
assign fifo_request_din.meta             = cache_request_in_reg.payload.meta;
assign fifo_request_din.data             = cache_request_in_reg.payload.data;

// Pop
// assign fifo_request_signals_in_int.rd_en = cache_request_pop_int;
assign cache_request_mem.iob.valid = cache_request_mem_reg.iob.valid;
assign cache_request_mem.iob.addr  = cache_request_mem_reg.iob.addr;
assign cache_request_mem.iob.wdata = cache_request_mem_reg.iob.wdata;
assign cache_request_mem.iob.wstrb = cache_request_mem_reg.iob.wstrb;
assign cache_request_mem.meta      = cache_request_mem_reg.meta;
assign cache_request_mem.data      = cache_request_mem_reg.data;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
  .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
  .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
  .PROG_THRESH     (PROG_THRESH               ),
  .READ_MODE       ("fwft"                    )  //string; "std" or "fwft";
) inst_fifo_CacheRequest (
  .clk        (ap_clk                                  ),
  .srst       (areset_fifo                             ),
  .din        (fifo_request_din                        ),
  .wr_en      (fifo_request_signals_in_int.wr_en       ),
  .rd_en      (fifo_request_signals_in_int.rd_en       ),
  .dout       (fifo_request_dout                       ),
  .full       (fifo_request_signals_out_int.full       ),
  .empty      (fifo_request_signals_out_int.empty      ),
  .valid      (fifo_request_signals_out_int.valid      ),
  .prog_full  (fifo_request_signals_out_int.prog_full  ),
  .wr_rst_busy(fifo_request_signals_out_int.wr_rst_busy),
  .rd_rst_busy(fifo_request_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy | fifo_response_signals_out_int.rd_rst_busy;

// Push
always_comb fifo_response_din = map_CacheResponse_to_MemoryResponsePacket(cache_request_mem, cache_response_mem);

// Pop
assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en;
assign response_in_int.valid              = fifo_response_signals_out_int.valid;
assign response_in_int.payload            = fifo_response_dout;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH                  ),
  .WRITE_DATA_WIDTH($bits(MemoryPacketResponsePayload)),
  .READ_DATA_WIDTH ($bits(MemoryPacketResponsePayload)),
  .PROG_THRESH     (PROG_THRESH                       )
) inst_fifo_CacheResponse (
  .clk        (ap_clk                                   ),
  .srst       (areset_fifo                              ),
  .din        (fifo_response_din                        ),
  .wr_en      (fifo_response_signals_in_int.wr_en       ),
  .rd_en      (fifo_response_signals_in_int.rd_en       ),
  .dout       (fifo_response_dout                       ),
  .full       (fifo_response_signals_out_int.full       ),
  .empty      (fifo_response_signals_out_int.empty      ),
  .valid      (fifo_response_signals_out_int.valid      ),
  .prog_full  (fifo_response_signals_out_int.prog_full  ),
  .wr_rst_busy(fifo_response_signals_out_int.wr_rst_busy),
  .rd_rst_busy(fifo_response_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// Cache Commands State Machine
// --------------------------------------------------------------------------------------
logic cmd_read_condition ;
logic cmd_write_condition;

cu_cache_command_generator_state current_state;
cu_cache_command_generator_state next_state   ;
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if(areset_control)
    current_state <= CU_CACHE_CMD_RESET;
  else begin
    current_state <= next_state;
  end
end// always_ff @(posedge ap_clk)
// --------------------------------------------------------------------------------------
assign fifo_request_signals_out_valid_int = fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & descriptor_in_reg.valid;
assign cmd_read_condition                 = cache_response_mem.iob.ready & fifo_request_signals_out_valid_int & ((fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH));
assign cmd_write_condition                = cache_response_mem.iob.ready & fifo_request_signals_out_valid_int & ((fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE)| (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_WRITE)) & ~(write_command_counter_is_zero & ~cache_ctrl_out.wtb_empty);
// --------------------------------------------------------------------------------------
always_comb begin
  next_state = current_state;
  case (current_state)
    CU_CACHE_CMD_RESET : begin
      next_state = CU_CACHE_CMD_READY;
    end
    CU_CACHE_CMD_READY : begin
        next_state = CU_CACHE_CMD_READY;
    end
  endcase
end// always_comb
// State Transition Logic

always_comb begin
  counter_load                       = 1'b0;
  fifo_request_signals_in_int.rd_en  = 1'b0;
  fifo_response_signals_in_int.wr_en = 1'b0;
  cache_request_mem_reg.iob.valid    = 1'b0;
  case (current_state)
    CU_CACHE_CMD_RESET : begin
      counter_load                       = 1'b1;
      fifo_request_signals_in_int.rd_en  = 1'b0;
      fifo_response_signals_in_int.wr_en = 1'b0;
      cache_request_mem_reg.iob.valid    = 1'b0;
    end
    CU_CACHE_CMD_READY : begin
      counter_load                       = 1'b0;
      fifo_request_signals_in_int.rd_en  = 1'b0;
      fifo_response_signals_in_int.wr_en = 1'b0;
      cache_request_mem_reg.iob.valid    = 1'b0;
      if(cmd_read_condition) begin
        if(~cache_response_mem.iob.valid) begin
        cache_request_mem_reg.iob.valid    = 1'b1;
        fifo_request_signals_in_int.rd_en  = 1'b0;
        fifo_response_signals_in_int.wr_en = 1'b0;
      end else begin
        fifo_request_signals_in_int.rd_en  = 1'b1;
        fifo_response_signals_in_int.wr_en = 1'b1;
        cache_request_mem_reg.iob.valid    = 1'b0;
      end
      end else if(cmd_write_condition) begin
        cache_request_mem_reg.iob.valid    = 1'b1;
        fifo_request_signals_in_int.rd_en  = 1'b1;
        fifo_response_signals_in_int.wr_en = 1'b1;
      end
    end
  endcase
end// always_comb

always_comb begin
  cache_request_mem_reg.iob.wstrb = fifo_request_dout.iob.wstrb & {{32{{(cmd_write_condition)}}}};
  cache_request_mem_reg.iob.addr  = fifo_request_dout.iob.addr;
  cache_request_mem_reg.iob.wdata = fifo_request_dout.iob.wdata;
  cache_request_mem_reg.meta      = fifo_request_dout.meta;
  cache_request_mem_reg.data      = fifo_request_dout.data;
end

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
counter #(.C_WIDTH(CACHE_WTBUF_DEPTH_W)) inst_write_command_counter (
  .ap_clk      (ap_clk                                                                                       ),
  .ap_clken    (1'b1                                                                                         ),
  .areset      (areset_counter                                                                               ),
  .load        (counter_load                                                                                 ),
  .incr        (fifo_response_signals_in_int.wr_en  & (cache_request_mem.meta.subclass.cmd == CMD_MEM_WRITE) ),
  .decr        (cache_request_mem_reg.iob.valid  & (cache_request_mem_reg.meta.subclass.cmd == CMD_MEM_WRITE)),
  .load_value  (write_command_counter_load_value                                                             ),
  .stride_value({{{{(CACHE_WTBUF_DEPTH_W-1){{1'b0}}}},{{1'b1}}}}                                                     ),
  .count       (write_command_counter_                                                                       ),
  .is_zero     (write_command_counter_is_zero                                                                )
);

endmodule : m{0:02d}_axi_cu_cache_mid{1}x{2}_fe{3}x{4}_wrapper
  """


output_file_cu_mxx_axi_cu_cache_wrapper = os.path.join(output_folder_path_cu,f"cu_mxx_axi_cu_cache_wrapper.sv")
check_and_clean_file(output_file_cu_mxx_axi_cu_cache_wrapper)

with open(output_file_cu_mxx_axi_cu_cache_wrapper, "w") as file:
    fill_cu_mxx_axi_cu_cache_wrapper_module.append(fill_cu_mxx_axi_cu_cache_wrapper_pre.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index],CACHE_CONFIG_L1_SIZE[index], CACHE_CONFIG_L1_NUM_WAYS[index], CACHE_CONFIG_L1_PREFETCH[index],formatted_datetime))
    for index, channel in enumerate(DISTINCT_CHANNELS):
        fill_cu_mxx_axi_cu_cache_wrapper_module.append(fill_cu_mxx_axi_cu_cache_wrapper.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index],CACHE_CONFIG_L1_SIZE[index], CACHE_CONFIG_L1_NUM_WAYS[index], CACHE_CONFIG_L1_PREFETCH[index],formatted_datetime))
    
    file.write('\n'.join(fill_cu_mxx_axi_cu_cache_wrapper_module))



fill_cu_mxx_axi_cu_stream_wrapper_module=[]

fill_cu_mxx_axi_cu_stream_wrapper_pre="""
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m{0:02d}_axi_cu_stream_mid_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
"""

fill_cu_mxx_axi_cu_stream_wrapper="""

module m{0:02d}_axi_cu_stream_mid{1}x{2}_fe{3}x{4}_wrapper #(
  parameter NUM_CHANNELS_READ = 1 ,
  parameter FIFO_WRITE_DEPTH  = 64,
  parameter PROG_THRESH       = 32
) (
  // System Signals
  input  logic                                   ap_clk                   ,
  input  logic                                   areset                   ,
  input  KernelDescriptor                        descriptor_in            ,
  input  MemoryPacketRequest                     request_in               ,
  output FIFOStateSignalsOutput                  fifo_request_signals_out ,
  input  FIFOStateSignalsInput                   fifo_request_signals_in  ,
  output MemoryPacketResponse                    response_out             ,
  output FIFOStateSignalsOutput                  fifo_response_signals_out,
  input  FIFOStateSignalsInput                   fifo_response_signals_in ,
  output logic                                   fifo_setup_signal        ,
  input  M{0:02d}_AXI4_MID_MasterReadInterfaceInput   m_axi_read_in            ,
  output M{0:02d}_AXI4_MID_MasterReadInterfaceOutput  m_axi_read_out           ,
  input  M{0:02d}_AXI4_MID_MasterWriteInterfaceInput  m_axi_write_in           ,
  output M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput m_axi_write_out          ,
  input  M{0:02d}_AXI4_LITE_MID_RESP_T                m_axi_lite_in            ,
  output M{0:02d}_AXI4_LITE_MID_REQ_T                 m_axi_lite_out           ,
  output logic                                   done_out
);

    assign m_axi_lite_out = 0;
    assign m_axi_write_out = 0;
// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
    logic areset_m_axi       ;
    logic areset_fifo        ;
    logic areset_engine_m_axi;
    logic areset_control     ;

    KernelDescriptor descriptor_in_reg;

    MemoryPacketRequest  request_in_reg      ;
    CacheRequest         cache_request_in_reg;
    MemoryPacketResponse response_in_int     ;

    logic fifo_empty_int;
    logic fifo_empty_reg;

    logic cmd_read_condition ;
    logic cmd_halt_condition ;

// --------------------------------------------------------------------------------------
//   Cache AXI signals
// --------------------------------------------------------------------------------------
    M{0:02d}_AXI4_MID_MasterReadInterface  m_axi_read ;
    M{0:02d}_AXI4_MID_MasterWriteInterface m_axi_write;

// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
    CacheRequestPayload  stream_request_mem     ;
    CacheRequestPayload  stream_request_mem_int ;
    CacheResponsePayload stream_response_mem    ;
    // CacheResponsePayload stream_response_mem_reg;

// --------------------------------------------------------------------------------------
// Cache request FIFO
// --------------------------------------------------------------------------------------
    CacheRequestPayload           fifo_request_din                  ;
    CacheRequestPayload           fifo_request_dout                 ;
    FIFOStateSignalsOutInternal   fifo_request_signals_out_int      ;
    FIFOStateSignalsInput         fifo_request_signals_in_reg       ;
    FIFOStateSignalsInputInternal fifo_request_signals_in_int       ;
    logic                         fifo_request_setup_signal_int     ;
    logic                         fifo_request_signals_out_valid_int;

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
    CacheRequestPayload           fifo_response_din             ;
    CacheRequestPayload           fifo_response_dout            ;
    FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
    FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
    FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
    logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
// READ/WRITE ENGINE
// --------------------------------------------------------------------------------------
    logic                                                    read_transaction_done_out     ;
    logic                                                    read_transaction_start_in     ;
    logic [  NUM_CHANNELS_READ-1:0]                          read_transaction_prog_full    ;
    logic [  NUM_CHANNELS_READ-1:0]                          read_transaction_tready_in    ;
    logic [  NUM_CHANNELS_READ-1:0]                          read_transaction_tvalid_out   ;
    logic [  NUM_CHANNELS_READ-1:0][M{0:02d}_AXI4_MID_ADDR_W-1:0] read_transaction_offset_in    ;
    logic [  NUM_CHANNELS_READ-1:0][M{0:02d}_AXI4_MID_DATA_W-1:0] read_transaction_tdata_out    ;
    logic [  NUM_CHANNELS_READ-1:0][M{0:02d}_AXI4_MID_DATA_W-1:0] read_transaction_tdata_out_reg;
    logic [M{0:02d}_AXI4_MID_DATA_W-1:0]                          read_transaction_length_in    ;

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
    logic                           areset_counter         ;
    logic                           counter_load           ;
    logic                           command_counter_is_zero;
     type_m01_axi4_fe_len   command_counter_       ;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      areset_m_axi        <= areset;
      areset_fifo         <= areset;
      areset_control      <= areset;
      areset_engine_m_axi <= areset;
      areset_counter      <= areset;
    end

// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      if (areset_control) begin
        descriptor_in_reg.valid <= 0;
      end
      else begin
        if(descriptor_in.valid)begin
          descriptor_in_reg.valid   <= descriptor_in.valid;
          descriptor_in_reg.payload <= descriptor_in.payload;
        end
      end
    end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      if (areset_control) begin
        request_in_reg.valid         <= 1'b0;
        cache_request_in_reg.valid   <= 1'b0;
        fifo_response_signals_in_reg <= 0;
        fifo_request_signals_in_reg  <= 0;
      end
      else begin
        request_in_reg.valid         <= request_in.valid;
        cache_request_in_reg.valid   <= request_in_reg.valid;
        fifo_response_signals_in_reg <= fifo_response_signals_in;
        fifo_request_signals_in_reg  <= fifo_request_signals_in;
      end
    end

    always_ff @(posedge ap_clk) begin
      request_in_reg.payload       <= request_in.payload;
      cache_request_in_reg.payload <= map_MemoryRequestPacket_to_CacheRequest(request_in_reg.payload, descriptor_in_reg.payload, request_in_reg.valid);
    end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      if (areset_control) begin
        fifo_setup_signal  <= 1'b1;
        response_out.valid <= 1'b0;
        done_out           <= 1'b0;
        fifo_empty_reg     <= 1'b1;
      end
      else begin
        fifo_setup_signal  <= fifo_request_setup_signal_int | fifo_response_setup_signal_int;
        response_out.valid <= response_in_int.valid;
        done_out           <= fifo_empty_reg;
        fifo_empty_reg     <= fifo_empty_int;
      end
    end

    assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty;

    always_ff @(posedge ap_clk) begin
      fifo_request_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
      fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
      response_out.payload      <= response_in_int.payload;
    end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      if (areset_m_axi) begin
        m_axi_read.in <= 0;
      end
      else begin
        m_axi_read.in <= m_axi_read_in;
      end
    end

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      if (areset_m_axi) begin
        m_axi_read_out <= 0;
      end
      else begin
        m_axi_read_out <= m_axi_read.out;
      end
    end

// --------------------------------------------------------------------------------------
// AXI port engine_m_axi
// --------------------------------------------------------------------------------------
// Request FIFO FWFT
// --------------------------------------------------------------------------------------
// FIFO is resetting
    assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
    assign fifo_request_signals_in_int.wr_en = cache_request_in_reg.valid;
    assign fifo_request_din.iob              = cache_request_in_reg.payload.iob;
    assign fifo_request_din.meta             = cache_request_in_reg.payload.meta;
    assign fifo_request_din.data             = cache_request_in_reg.payload.data;

// Pop
// assign fifo_request_signals_in_int.rd_en = stream_request_pop_int;
    assign stream_request_mem.iob.valid = stream_request_mem_int.iob.valid;
    assign stream_request_mem.iob.addr  = stream_request_mem_int.iob.addr;
    assign stream_request_mem.iob.wdata = stream_request_mem_int.iob.wdata;
    assign stream_request_mem.iob.wstrb = stream_request_mem_int.iob.wstrb;
    assign stream_request_mem.meta      = stream_request_mem_int.meta;
    assign stream_request_mem.data      = stream_request_mem_int.data;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
    .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
    .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
    .PROG_THRESH     (PROG_THRESH               ),
    .READ_MODE       ("fwft"                    )  //string; "std" or "fwft";
  ) inst_fifo_CacheRequest (
    .clk        (ap_clk                                  ),
    .srst       (areset_fifo                             ),
    .din        (fifo_request_din                        ),
    .wr_en      (fifo_request_signals_in_int.wr_en       ),
    .rd_en      (fifo_request_signals_in_int.rd_en       ),
    .dout       (fifo_request_dout                       ),
    .full       (fifo_request_signals_out_int.full       ),
    .empty      (fifo_request_signals_out_int.empty      ),
    .valid      (fifo_request_signals_out_int.valid      ),
    .prog_full  (fifo_request_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_request_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_request_signals_out_int.rd_rst_busy)
  );

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
// FIFO is resetting
    assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy | fifo_response_signals_out_int.rd_rst_busy;

// Push
    assign fifo_response_signals_in_int.wr_en   = stream_response_mem.iob.valid & cmd_halt_condition;
    always_comb fifo_response_din               = map_CacheResponse_to_MemoryResponsePacket(fifo_request_dout, stream_response_mem);

// Pop
    assign fifo_response_signals_in_int.rd_en = ~fifo_response_signals_out_int.empty & fifo_response_signals_in_reg.rd_en ;
    assign response_in_int.valid              = fifo_response_signals_out_int.valid;
    always_comb response_in_int.payload       = fifo_response_dout;

  xpm_fifo_sync_wrapper #(
    .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH           ),
    .WRITE_DATA_WIDTH($bits(CacheRequestPayload )),
    .READ_DATA_WIDTH ($bits(CacheRequestPayload )),
    .PROG_THRESH     (PROG_THRESH                )
  ) inst_fifo_CacheResponse (
    .clk        (ap_clk                                   ),
    .srst       (areset_fifo                              ),
    .din        (fifo_response_din                        ),
    .wr_en      (fifo_response_signals_in_int.wr_en       ),
    .rd_en      (fifo_response_signals_in_int.rd_en       ),
    .dout       (fifo_response_dout                       ),
    .full       (fifo_response_signals_out_int.full       ),
    .empty      (fifo_response_signals_out_int.empty      ),
    .valid      (fifo_response_signals_out_int.valid      ),
    .prog_full  (fifo_response_signals_out_int.prog_full  ),
    .wr_rst_busy(fifo_response_signals_out_int.wr_rst_busy),
    .rd_rst_busy(fifo_response_signals_out_int.rd_rst_busy)
  );

    // always_ff @(posedge ap_clk) begin
    //   stream_response_mem_reg <= stream_response_mem;
    // end

// --------------------------------------------------------------------------------------
// Cache Commands Read State Machine
// --------------------------------------------------------------------------------------
    cu_stream_command_generator_state current_state;
    cu_stream_command_generator_state next_state   ;

    logic cmd_read_pending ;
// --------------------------------------------------------------------------------------
//   State Machine AP_USER_MANAGED sync
// --------------------------------------------------------------------------------------
    always_ff @(posedge ap_clk) begin
      if(areset_control)
        current_state <= CU_STREAM_CMD_RESET;
      else begin
        current_state <= next_state;
      end
    end// always_ff @(posedge ap_clk)
// --------------------------------------------------------------------------------------
    assign fifo_request_signals_out_valid_int = ~command_counter_is_zero & fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & fifo_response_signals_in_reg.rd_en & descriptor_in_reg.valid;
    assign cmd_read_condition                 = ((fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH))  & fifo_request_signals_out_valid_int;
    assign cmd_halt_condition                 = ~command_counter_is_zero & ~fifo_response_signals_out_int.prog_full & descriptor_in_reg.valid;
// --------------------------------------------------------------------------------------

    always_comb begin
      next_state = current_state;
      case (current_state)
        CU_STREAM_CMD_RESET : begin
          next_state = CU_STREAM_CMD_READY;
        end
        CU_STREAM_CMD_READY : begin
          if(cmd_read_condition)
            next_state = CU_STREAM_CMD_READ_TRANS;
          else
            next_state = CU_STREAM_CMD_READY;
        end
        CU_STREAM_CMD_READ_TRANS : begin
          next_state = CU_STREAM_CMD_PENDING;
        end
        CU_STREAM_CMD_PENDING : begin
          if(command_counter_is_zero)
            next_state = CU_STREAM_CMD_DONE;
          else
            next_state = CU_STREAM_CMD_PENDING;
        end
        CU_STREAM_CMD_DONE : begin
          next_state = CU_STREAM_CMD_READY;
        end
        default : begin
          next_state = CU_STREAM_CMD_RESET;
        end
      endcase
    end// always_comb
// State Transition Logic

    always_ff @(posedge ap_clk) begin
      case (current_state)
        CU_STREAM_CMD_RESET : begin
          cmd_read_pending                   <= 1'b0;
          counter_load                       <= 1'b0;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
        end
        CU_STREAM_CMD_READY : begin
          cmd_read_pending                   <= 1'b0;
          counter_load                       <= 1'b1;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
        end
        CU_STREAM_CMD_READ_TRANS : begin
          cmd_read_pending                   <= 1'b1;
          counter_load                       <= 1'b0;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b1;
        end
        CU_STREAM_CMD_PENDING : begin
          counter_load                       <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
          if(command_counter_is_zero)
            fifo_request_signals_in_int.rd_en  <= 1'b1;
          else
            fifo_request_signals_in_int.rd_en  <= 1'b0;
        end
        CU_STREAM_CMD_DONE : begin
          cmd_read_pending                   <= 1'b0;
          counter_load                       <= 1'b0;
          fifo_request_signals_in_int.rd_en  <= 1'b0;
          stream_request_mem_int.iob.valid   <= 1'b0;
        end
      endcase
    end// always_ff @(posedge ap_clk)

// --------------------------------------------------------------------------------------
    always_comb begin
      stream_request_mem_int.iob.wstrb = 0;
      stream_request_mem_int.iob.addr  = fifo_request_dout.iob.addr;
      stream_request_mem_int.iob.wdata = fifo_request_dout.iob.wdata;
      stream_request_mem_int.meta      = fifo_request_dout.meta;
      stream_request_mem_int.data      = fifo_request_dout.data;
    end

// --------------------------------------------------------------------------------------
// READ Stream
// --------------------------------------------------------------------------------------
    assign read_transaction_length_in = fifo_request_dout.meta.address.burst_length;
    assign read_transaction_start_in  = stream_request_mem_int.iob.valid & ((fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ)|(fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH));
    assign read_transaction_offset_in = stream_request_mem_int.iob.addr;
    assign read_transaction_tready_in = cmd_read_pending & cmd_halt_condition;
// --------------------------------------------------------------------------------------
// output Stream
// --------------------------------------------------------------------------------------
    assign stream_response_mem.iob.ready = ~read_transaction_prog_full;
    assign stream_response_mem.iob.valid = read_transaction_tvalid_out;
    assign stream_response_mem.iob.rdata = read_transaction_tdata_out;

  engine_m_axi #(
    .C_NUM_CHANNELS     (NUM_CHANNELS_READ                        ),
    .M_AXI4_MID_ADDR_W  (M{0:02d}_AXI4_MID_ADDR_W                      ),
    .M_AXI4_MID_BURST_W (M{0:02d}_AXI4_MID_BURST_W                     ),
    .M_AXI4_MID_CACHE_W (M{0:02d}_AXI4_MID_CACHE_W                     ),
    .M_AXI4_MID_DATA_W  (M{0:02d}_AXI4_MID_DATA_W                      ),
    .M_AXI4_MID_ID_W    (M{0:02d}_AXI4_MID_ID_W                        ),
    .M_AXI4_MID_LEN_W   (M{0:02d}_AXI4_MID_LEN_W                       ),
    .M_AXI4_MID_LOCK_W  (M{0:02d}_AXI4_MID_LOCK_W                      ),
    .M_AXI4_MID_PROT_W  (M{0:02d}_AXI4_MID_PROT_W                      ),
    .M_AXI4_MID_QOS_W   (M{0:02d}_AXI4_MID_QOS_W                       ),
    .M_AXI4_MID_REGION_W(M{0:02d}_AXI4_MID_REGION_W                    ),
    .M_AXI4_MID_RESP_W  (M{0:02d}_AXI4_MID_RESP_W                      ),
    .M_AXI4_MID_SIZE_W  (M{0:02d}_AXI4_MID_SIZE_W                      ),
    .C_AXI_RW_CACHE     (M{0:02d}_AXI4_MID_CACHE_BUFFERABLE_NO_ALLOCATE)
  ) inst_engine_m_axi (
    .read_transaction_done_out   (read_transaction_done_out   ),
    .read_transaction_length_in  (read_transaction_length_in  ),
    .read_transaction_offset_in  (read_transaction_offset_in  ),
    .read_transaction_start_in   (read_transaction_start_in   ),
    .read_transaction_tdata_out  (read_transaction_tdata_out  ),
    .read_transaction_tready_in  (read_transaction_tready_in  ),
    .read_transaction_tvalid_out (read_transaction_tvalid_out ),
    .read_transaction_prog_full  (read_transaction_prog_full  ),
    `include "m_axi_portmap_buffer.vh"
    .ap_clk                      (ap_clk                      ),
    .areset                      (areset_engine_m_axi         )
  );

// --------------------------------------------------------------------------------------
// Cache/Memory response counter
// --------------------------------------------------------------------------------------
  counter #(.C_WIDTH($bits(type_m01_axi4_fe_len))) inst_write_command_counter (
    .ap_clk      (ap_clk                                          ),
    .ap_clken    (1'b1                                            ),
    .areset      (areset_counter                                  ),
    .load        (counter_load                                    ),
    .incr        (1'b0                                            ),
    .decr        (stream_response_mem.iob.valid                   ),
    .load_value  (fifo_request_dout.meta.address.burst_length     ),
    .stride_value({{{{($bits(type_m01_axi4_fe_len)-1){{1'b0}}}},{{1'b1}}}}),
    .count       (command_counter_                                ),
    .is_zero     (command_counter_is_zero                         )
  );


  endmodule : m{0:02d}_axi_cu_stream_mid{1}x{2}_fe{3}x{4}_wrapper
  """

output_file_cu_mxx_axi_cu_stream_wrapper = os.path.join(output_folder_path_cu,f"cu_mxx_axi_cu_stream_wrapper.sv")
check_and_clean_file(output_file_cu_mxx_axi_cu_stream_wrapper)

with open(output_file_cu_mxx_axi_cu_stream_wrapper, "w") as file:
    fill_cu_mxx_axi_cu_stream_wrapper_module.append(fill_cu_mxx_axi_cu_stream_wrapper_pre.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index],formatted_datetime))
    for index, channel in enumerate(DISTINCT_CHANNELS):
        fill_cu_mxx_axi_cu_stream_wrapper_module.append(fill_cu_mxx_axi_cu_stream_wrapper.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index],formatted_datetime))
    
    file.write('\n'.join(fill_cu_mxx_axi_cu_stream_wrapper_module))


fill_cu_mxx_axi_cu_sram_wrapper_module = []

fill_cu_mxx_axi_cu_sram_wrapper_pre="""
// -----------------------------------------------------------------------------
//
//      "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : m{0:02d}_axi_cu_sram_wrapper.sv
// Create : 2024-01-12 14:41:10
// Revise : 2024-01-12 14:41:10
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

`include "global_package.vh"
"""

fill_cu_mxx_axi_cu_sram_wrapper="""

module m{0:02d}_axi_cu_sram_mid{1}x{2}_fe{3}x{4}_wrapper #(
  parameter FIFO_WRITE_DEPTH = 64,
  parameter PROG_THRESH      = 32
) (
  // System Signals
  input  logic                                   ap_clk                   ,
  input  logic                                   areset                   ,
  input  KernelDescriptor                        descriptor_in            ,
  input  MemoryPacketRequest                     request_in               ,
  output FIFOStateSignalsOutput                  fifo_request_signals_out ,
  input  FIFOStateSignalsInput                   fifo_request_signals_in  ,
  output MemoryPacketResponse                    response_out             ,
  output FIFOStateSignalsOutput                  fifo_response_signals_out,
  input  FIFOStateSignalsInput                   fifo_response_signals_in ,
  output logic                                   fifo_setup_signal        ,
  input  M{0:02d}_AXI4_MID_MasterReadInterfaceInput   m_axi_read_in            ,
  output M{0:02d}_AXI4_MID_MasterReadInterfaceOutput  m_axi_read_out           ,
  input  M{0:02d}_AXI4_MID_MasterWriteInterfaceInput  m_axi_write_in           ,
  output M{0:02d}_AXI4_MID_MasterWriteInterfaceOutput m_axi_write_out          ,
  input  M{0:02d}_AXI4_LITE_MID_RESP_T                m_axi_lite_in            ,
  output M{0:02d}_AXI4_LITE_MID_REQ_T                 m_axi_lite_out           ,
  output logic                                   done_out
);


assign m_axi_lite_out = 0;
// --------------------------------------------------------------------------------------
// Define SRAM axi data types
// --------------------------------------------------------------------------------------
M{0:02d}_AXI4_FE_REQ_T  axi_req_o;
M{0:02d}_AXI4_FE_RESP_T axi_rsp_i;

// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign axi_rsp_i.ar_ready = m_axi_read_in.arready ;// Input Read Address read channel ready
assign axi_rsp_i.r.data   = m_axi_read_in.rdata   ;// Input Read channel data
assign axi_rsp_i.r.id     = m_axi_read_in.rid     ;// Input Read channel ID
assign axi_rsp_i.r.last   = m_axi_read_in.rlast   ;// Input Read channel last word
assign axi_rsp_i.r.resp   = m_axi_read_in.rresp   ;// Input Read channel response
assign axi_rsp_i.r_valid  = m_axi_read_in.rvalid  ;// Input Read channel valid
assign axi_rsp_i.r.user   = 0 ;// Input Read channel user
// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS INPUT
// --------------------------------------------------------------------------------------
assign axi_rsp_i.aw_ready = m_axi_write_in.awready ;// Input Write Address write channel ready
assign axi_rsp_i.w_ready  = m_axi_write_in.wready  ;// Input Write channel ready
assign axi_rsp_i.b.id     = m_axi_write_in.bid     ;// Input Write response channel ID
assign axi_rsp_i.b.resp   = m_axi_write_in.bresp   ;// Input Write channel response
assign axi_rsp_i.b_valid  = m_axi_write_in.bvalid  ;// Input Write response channel valid
assign axi_rsp_i.b.user   = 0 ;// Input Write channel user
// --------------------------------------------------------------------------------------
// READ AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_read_out.arvalid  = axi_req_o.ar_valid;// Output Read Address read channel valid
assign m_axi_read_out.araddr   = axi_req_o.ar.addr ;// Output Read Address read channel address
assign m_axi_read_out.arlen    = axi_req_o.ar.len  ;// Output Read Address channel burst length
assign m_axi_read_out.rready   = axi_req_o.r_ready ;// Output Read Read channel ready
assign m_axi_read_out.arid     = axi_req_o.ar.id   ;// Output Read Address read channel ID
assign m_axi_read_out.arsize   = axi_req_o.ar.size ;// Output Read Address read channel burst size. This signal indicates the size of each transfer in the burst
assign m_axi_read_out.arburst  = axi_req_o.ar.burst;// Output Read Address read channel burst type
assign m_axi_read_out.arlock   = axi_req_o.ar.lock ;// Output Read Address read channel lock type
assign m_axi_read_out.arcache  = axi_req_o.ar.cache;// Output Read Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
assign m_axi_read_out.arprot   = axi_req_o.ar.prot ;// Output Read Address channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
assign m_axi_read_out.arqos    = axi_req_o.ar.qos  ;// Output Read Address channel quality of service
assign m_axi_read_out.arregion = axi_req_o.ar.region;// Output Read Address channel arregion
//assign m_axi_read_out.user     = axi_req_o.ar.user;
// --------------------------------------------------------------------------------------
// WRITE AXI4 SIGNALS OUTPUT
// --------------------------------------------------------------------------------------
assign m_axi_write_out.awvalid  = axi_req_o.aw_valid; // Output Write Address write channel valid
assign m_axi_write_out.awid     = axi_req_o.aw.id   ; // Output Write Address write channel ID
assign m_axi_write_out.awaddr   = axi_req_o.aw.addr ; // Output Write Address write channel address
assign m_axi_write_out.awlen    = axi_req_o.aw.len  ; // Output Write Address write channel burst length
assign m_axi_write_out.awsize   = axi_req_o.aw.size ; // Output Write Address write channel burst size. This signal indicates the size of each transfer in the burst
assign m_axi_write_out.awburst  = axi_req_o.aw.burst; // Output Write Address write channel burst type
assign m_axi_write_out.awlock   = axi_req_o.aw.lock ; // Output Write Address write channel lock type
assign m_axi_write_out.awcache  = axi_req_o.aw.cache; // Output Write Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
assign m_axi_write_out.awprot   = axi_req_o.aw.prot ; // Output Write Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
assign m_axi_write_out.awqos    = axi_req_o.aw.qos  ; // Output Write Address write channel quality of service
assign m_axi_write_out.wdata    = axi_req_o.w.data  ; // Output Write channel data
assign m_axi_write_out.wstrb    = axi_req_o.w.strb  ; // Output Write channel write strobe
assign m_axi_write_out.wlast    = axi_req_o.w.last  ; // Output Write channel last word flag
assign m_axi_write_out.wvalid   = axi_req_o.w_valid ; // Output Write channel valid
assign m_axi_write_out.bready   = axi_req_o.b_ready ; // Output Write response channel ready
assign m_axi_write_out.awregion = axi_req_o.aw.region;
// assign m_axi_write_out.awatop = axi_req_o.aw.atop;
// assign m_axi_write_out.awuser = axi_req_o.aw.user;
// assign m_axi_write_out.wuser  = axi_req_o.w.user;

// --------------------------------------------------------------------------------------
// Module Wires and Variables
// --------------------------------------------------------------------------------------
logic            areset_fifo      ;
logic            areset_sram      ;
logic            areset_control   ;
KernelDescriptor descriptor_in_reg;

MemoryPacketRequest  request_in_reg     ;
CacheRequest         sram_request_in_reg;
MemoryPacketResponse response_in_int    ;

logic fifo_empty_int;
logic fifo_empty_reg;

logic cmd_read_condition ;
logic cmd_write_condition;
logic mem_rsp_error_o    ;
// --------------------------------------------------------------------------------------
//   Cache signals
// --------------------------------------------------------------------------------------
CacheRequestPayload  sram_request_mem        ;
CacheRequestPayload  sram_request_mem_int    ;
CacheResponsePayload sram_response_mem       ;
CacheResponsePayload sram_response_mem_reg   ;
CacheResponsePayload sram_response_mem_reg_S2;

// --------------------------------------------------------------------------------------
// Cache request FIFO
// --------------------------------------------------------------------------------------
CacheRequestPayload           fifo_request_din                  ;
CacheRequestPayload           fifo_request_dout                 ;
FIFOStateSignalsOutInternal   fifo_request_signals_out_int      ;
FIFOStateSignalsInput         fifo_request_signals_in_reg       ;
FIFOStateSignalsInputInternal fifo_request_signals_in_int       ;
logic                         fifo_request_setup_signal_int     ;
logic                         fifo_request_signals_out_valid_int;

// --------------------------------------------------------------------------------------
// Memory response FIFO
// --------------------------------------------------------------------------------------
CacheRequestPayload           fifo_response_din             ;
CacheRequestPayload           fifo_response_dout            ;
FIFOStateSignalsOutInternal   fifo_response_signals_out_int ;
FIFOStateSignalsInput         fifo_response_signals_in_reg  ;
FIFOStateSignalsInputInternal fifo_response_signals_in_int  ;
logic                         fifo_response_setup_signal_int;

// --------------------------------------------------------------------------------------
//   Register reset signal
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  areset_fifo    <= areset;
  areset_control <= areset;
  areset_sram    <= ~areset;
end

// --------------------------------------------------------------------------------------
// READ Descriptor Control and Drive signals to other modules
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    descriptor_in_reg.valid <= 0;
  end
  else begin
    if(descriptor_in.valid)begin
      descriptor_in_reg.valid   <= descriptor_in.valid;
      descriptor_in_reg.payload <= descriptor_in.payload;
    end
  end
end

// --------------------------------------------------------------------------------------
// Drive input
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    request_in_reg.valid         <= 1'b0;
    sram_request_in_reg.valid    <= 1'b0;
    fifo_response_signals_in_reg <= 0;
    fifo_request_signals_in_reg  <= 0;
  end
  else begin
    request_in_reg.valid         <= request_in.valid;
    sram_request_in_reg.valid    <= request_in_reg.valid;
    fifo_response_signals_in_reg <= fifo_response_signals_in;
    fifo_request_signals_in_reg  <= fifo_request_signals_in;
  end
end

always_ff @(posedge ap_clk) begin
  request_in_reg.payload      <= request_in.payload;
  sram_request_in_reg.payload <= map_MemoryRequestPacket_to_CacheRequest(request_in_reg.payload, descriptor_in_reg.payload, request_in_reg.valid);
end

// --------------------------------------------------------------------------------------
// Drive output
// --------------------------------------------------------------------------------------
always_ff @(posedge ap_clk) begin
  if (areset_control) begin
    fifo_setup_signal  <= 1'b1;
    response_out.valid <= 1'b0;
    done_out           <= 1'b0;
    fifo_empty_reg     <= 1'b1;
  end
  else begin
    fifo_setup_signal  <= fifo_request_setup_signal_int | fifo_response_setup_signal_int;
    response_out.valid <= response_in_int.valid;
    done_out           <= fifo_empty_reg;
    fifo_empty_reg     <= fifo_empty_int;
  end
end

assign fifo_empty_int = fifo_request_signals_out_int.empty & fifo_response_signals_out_int.empty;

always_ff @(posedge ap_clk) begin
  fifo_request_signals_out  <= map_internal_fifo_signals_to_output(fifo_request_signals_out_int);
  fifo_response_signals_out <= map_internal_fifo_signals_to_output(fifo_response_signals_out_int);
  response_out.payload      <= response_in_int.payload;
end

// --------------------------------------------------------------------------------------
// AXI port sram
// --------------------------------------------------------------------------------------
axi_from_mem #(
  .MemAddrWidth(M{0:02d}_AXI4_FE_ADDR_W    ),
  .AxiAddrWidth(M{0:02d}_AXI4_FE_ADDR_W    ),
  .DataWidth   (M{0:02d}_AXI4_FE_DATA_W    ),
  .MaxRequests (2**{7}                 ),
  .axi_req_t   (M{0:02d}_AXI4_FE_REQ_T     ),
  .axi_rsp_t   (M{0:02d}_AXI4_FE_RESP_T    )
) inst_axi_from_mem (
  .clk_i          (ap_clk                                   ),
  .rst_ni         (areset_sram                              ),
  .mem_req_i      (sram_request_mem.iob.valid               ),
  .mem_addr_i     (sram_request_mem.iob.addr                ),
  .mem_we_i       (cmd_write_condition                      ),
  .mem_wdata_i    (sram_request_mem.iob.wdata               ),
  .mem_be_i       (sram_request_mem.iob.wstrb               ),
  .mem_gnt_o      (sram_response_mem.iob.ready              ),
  .mem_rsp_valid_o(sram_response_mem.iob.valid              ),
  .mem_rsp_rdata_o(sram_response_mem.iob.rdata              ),
  .mem_rsp_error_o(mem_rsp_error_o                          ),
  .slv_aw_cache_i (M{0:02d}_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES),
  .slv_ar_cache_i (M{0:02d}_AXI4_MID_CACHE_WRITE_BACK_ALLOCATE_READS_WRITES),
  .axi_req_o      (axi_req_o                                ),
  .axi_rsp_i      (axi_rsp_i                                )
);

// --------------------------------------------------------------------------------------
// Cache request FIFO FWFT
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_request_setup_signal_int = fifo_request_signals_out_int.wr_rst_busy | fifo_request_signals_out_int.rd_rst_busy;

// Push
assign fifo_request_signals_in_int.wr_en = sram_request_in_reg.valid;
assign fifo_request_din.iob              = sram_request_in_reg.payload.iob;
assign fifo_request_din.meta             = sram_request_in_reg.payload.meta;
assign fifo_request_din.data             = sram_request_in_reg.payload.data;

// Pop
// assign fifo_request_signals_in_int.rd_en = sram_request_pop_int;
assign sram_request_mem.iob.valid = sram_request_mem_int.iob.valid;
assign sram_request_mem.iob.addr  = sram_request_mem_int.iob.addr;
assign sram_request_mem.iob.wdata = sram_request_mem_int.iob.wdata;
assign sram_request_mem.iob.wstrb = sram_request_mem_int.iob.wstrb;
assign sram_request_mem.meta      = sram_request_mem_int.meta;
assign sram_request_mem.data      = sram_request_mem_int.data;

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
  .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
  .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
  .PROG_THRESH     (PROG_THRESH               ),
  .READ_MODE       ("fwft"                    )  //string; "std" or "fwft";
) inst_fifo_CacheRequest (
  .clk        (ap_clk                                  ),
  .srst       (areset_fifo                             ),
  .din        (fifo_request_din                        ),
  .wr_en      (fifo_request_signals_in_int.wr_en       ),
  .rd_en      (fifo_request_signals_in_int.rd_en       ),
  .dout       (fifo_request_dout                       ),
  .full       (fifo_request_signals_out_int.full       ),
  .empty      (fifo_request_signals_out_int.empty      ),
  .valid      (fifo_request_signals_out_int.valid      ),
  .prog_full  (fifo_request_signals_out_int.prog_full  ),
  .wr_rst_busy(fifo_request_signals_out_int.wr_rst_busy),
  .rd_rst_busy(fifo_request_signals_out_int.rd_rst_busy)
);

// --------------------------------------------------------------------------------------
// Cache response FIFO
// --------------------------------------------------------------------------------------
// FIFO is resetting
assign fifo_response_setup_signal_int = fifo_response_signals_out_int.wr_rst_busy | fifo_response_signals_out_int.rd_rst_busy;

// Push
assign fifo_response_din = sram_request_mem;

// Pop
assign fifo_response_signals_in_int.rd_en = sram_response_mem_reg.iob.valid ;
assign response_in_int.valid              = fifo_response_signals_out_int.valid;
always_comb response_in_int.payload       = map_CacheResponse_to_MemoryResponsePacket(fifo_response_dout, sram_response_mem_reg_S2);

xpm_fifo_sync_wrapper #(
  .FIFO_WRITE_DEPTH(FIFO_WRITE_DEPTH          ),
  .WRITE_DATA_WIDTH($bits(CacheRequestPayload)),
  .READ_DATA_WIDTH ($bits(CacheRequestPayload)),
  .PROG_THRESH     (PROG_THRESH               )
) inst_fifo_CacheResponse (
  .clk        (ap_clk                                   ),
  .srst       (areset_fifo                              ),
  .din        (fifo_response_din                        ),
  .wr_en      (fifo_response_signals_in_int.wr_en       ),
  .rd_en      (fifo_response_signals_in_int.rd_en       ),
  .dout       (fifo_response_dout                       ),
  .full       (fifo_response_signals_out_int.full       ),
  .empty      (fifo_response_signals_out_int.empty      ),
  .valid      (fifo_response_signals_out_int.valid      ),
  .prog_full  (fifo_response_signals_out_int.prog_full  ),
  .wr_rst_busy(fifo_response_signals_out_int.wr_rst_busy),
  .rd_rst_busy(fifo_response_signals_out_int.rd_rst_busy)
);

always_ff @(posedge ap_clk) begin
  sram_response_mem_reg    <= sram_response_mem;
  sram_response_mem_reg_S2 <= sram_response_mem_reg;
end

// --------------------------------------------------------------------------------------
// SRAM Commands State Machine
// --------------------------------------------------------------------------------------
assign fifo_request_signals_out_valid_int = fifo_request_signals_out_int.valid & ~fifo_request_signals_out_int.empty & ~fifo_response_signals_out_int.prog_full & fifo_response_signals_in_reg.rd_en & descriptor_in_reg.valid;
assign sram_request_mem_int.iob.valid     = fifo_request_signals_out_valid_int;
assign fifo_request_signals_in_int.rd_en  = sram_response_mem.iob.ready;
assign fifo_response_signals_in_int.wr_en = sram_response_mem.iob.ready;
assign cmd_read_condition                 = (fifo_request_dout.meta.subclass.cmd == CMD_MEM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_READ) | (fifo_request_dout.meta.subclass.cmd == CMD_CACHE_FLUSH);
assign cmd_write_condition                = (fifo_request_dout.meta.subclass.cmd == CMD_MEM_WRITE)| (fifo_request_dout.meta.subclass.cmd == CMD_STREAM_WRITE);

always_comb begin
  sram_request_mem_int.iob.wstrb = fifo_request_dout.iob.wstrb & {{32{{(cmd_write_condition)}}}};
  sram_request_mem_int.iob.addr  = fifo_request_dout.iob.addr;
  sram_request_mem_int.iob.wdata = fifo_request_dout.iob.wdata;
  sram_request_mem_int.meta      = fifo_request_dout.meta;
  sram_request_mem_int.data      = fifo_request_dout.data;
end

endmodule : m{0:02d}_axi_cu_sram_mid{1}x{2}_fe{3}x{4}_wrapper
  """


output_file_cu_mxx_axi_cu_sram_wrapper = os.path.join(output_folder_path_cu,f"cu_mxx_axi_cu_sram_wrapper.sv")
check_and_clean_file(output_file_cu_mxx_axi_cu_sram_wrapper)

with open(output_file_cu_mxx_axi_cu_sram_wrapper, "w") as file:
    fill_cu_mxx_axi_cu_sram_wrapper_module.append(fill_cu_mxx_axi_cu_sram_wrapper_pre.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index],CACHE_CONFIG_L1_SIZE[index], CACHE_CONFIG_L1_NUM_WAYS[index], CACHE_CONFIG_L1_PREFETCH[index],formatted_datetime))
    for index, channel in enumerate(DISTINCT_CHANNELS):
        fill_cu_mxx_axi_cu_sram_wrapper_module.append(fill_cu_mxx_axi_cu_sram_wrapper.format(channel, CHANNEL_CONFIG_DATA_WIDTH_MID[index], CHANNEL_CONFIG_ADDRESS_WIDTH_MID[index],CHANNEL_CONFIG_DATA_WIDTH_FE[index], CHANNEL_CONFIG_ADDRESS_WIDTH_FE[index],CACHE_CONFIG_L1_SIZE[index], CACHE_CONFIG_L1_NUM_WAYS[index], CACHE_CONFIG_L1_PREFETCH[index],formatted_datetime))
    
    file.write('\n'.join(fill_cu_mxx_axi_cu_sram_wrapper_module))