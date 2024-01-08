#!/usr/bin/env python3

import re
import sys
import os
import ast
import json


# Validate the number of arguments
if len(sys.argv) != 10:
    print("Usage: <script> <FULL_SRC_IP_DIR_OVERLAY> <FULL_SRC_IP_DIR_RTL> <FULL_SRC_IP_DIR_UTILS_TCL> <UTILS_DIR> <ARCHITECTURE> <CAPABILITY> <ALGORITHM_NAME> <NUM_CHANNELS> <INCLUDE_DIR>")
    sys.exit(1)

# Assuming the script name is the first argument, and the directories follow after.
_, FULL_SRC_IP_DIR_OVERLAY, FULL_SRC_IP_DIR_RTL, FULL_SRC_IP_DIR_UTILS_TCL, UTILS_DIR, ARCHITECTURE, CAPABILITY, ALGORITHM_NAME, NUM_CHANNELS, INCLUDE_DIR = sys.argv

# Construct the full path for the file
config_filename = f"topology.json"
config_file_path = os.path.join(FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, config_filename)

# output_folder_path_tcl  = os.path.join(FULL_SRC_IP_DIR_UTILS_TCL)
output_folder_path_testbench   = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "testbench")
output_folder_path_topology    = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "topology")
output_folder_path_global      = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "global")
output_folder_path_parameters  = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "parameters")
output_folder_path_portmaps    = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "portmaps")

if not os.path.exists(output_folder_path_topology):
    os.makedirs(output_folder_path_topology)

if not os.path.exists(output_folder_path_global):
    os.makedirs(output_folder_path_global)

if not os.path.exists(output_folder_path_parameters):
    os.makedirs(output_folder_path_parameters)

if not os.path.exists(output_folder_path_portmaps):
    os.makedirs(output_folder_path_portmaps)

if not os.path.exists(FULL_SRC_IP_DIR_UTILS_TCL):
    os.makedirs(FULL_SRC_IP_DIR_UTILS_TCL)

if not os.path.exists(output_folder_path_testbench):
    os.makedirs(output_folder_path_testbench)

output_file_afu_portmap = os.path.join(output_folder_path_portmaps,"m_axi_portmap_afu.vh")
output_file_afu_ports = os.path.join(output_folder_path_portmaps,"m_axi_ports_afu.vh")
output_file_afu_topology = os.path.join(output_folder_path_topology,"afu_topology.vh")
output_file_buffer_channels_tcl = os.path.join(FULL_SRC_IP_DIR_UTILS_TCL,"project_map_buffers_m_axi_ports.tcl")
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


def generate_topology_parameters(ch_properties):

    # Grouping values for each channel
    channel_config_l1 = []
    channel_config_l2 = []
    for channel, values in ch_properties.items():
        channel_config_l1.append(int(values[0]))
        channel_config_l2.append(int(values[1]))


    NUM_CHANNELS_MAX = len(channel_config_l1)


    return NUM_CHANNELS_MAX, channel_config_l1, channel_config_l2

CHANNEL_CONFIG_L1 = []
CHANNEL_CONFIG_L2 = []
NUM_CHANNELS_MAX  = 1

NUM_CHANNELS_MAX,CHANNEL_CONFIG_L1,CHANNEL_CONFIG_L2= generate_topology_parameters(ch_properties)

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
check_and_clean_file(output_file_slv_m_axi_vip_func)

# Write to VHDL file
with open(output_file_top_parameters, "w") as file:
    output_lines = []

    ports_template = """
parameter integer C_M{0:02d}_AXI_ADDR_WIDTH       = 64 ,
parameter integer C_M{0:02d}_AXI_DATA_WIDTH       = 512,
parameter integer C_M{0:02d}_AXI_ID_WIDTH         = 1,
"""
    for channel in DISTINCT_CHANNELS:
        output_lines.append(ports_template.format(channel))
    
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
    
    file.write(f"parameter NUM_CHANNELS_WIDTH_BITS = {NUM_CHANNELS_TOP};\n")
    file.write(f"parameter NUM_CUS_WIDTH_BITS      = {NUM_CUS};\n")
    file.write(f"parameter NUM_BUNDLES_WIDTH_BITS  = {NUM_BUNDLES};\n")
    file.write(f"parameter NUM_LANES_WIDTH_BITS    = {NUM_LANES};\n")
    file.write(f"parameter NUM_ENGINES_WIDTH_BITS  = {NUM_ENGINES};\n")
    file.write(f"parameter NUM_MODULES_WIDTH_BITS  = 3;\n")
    file.write(f"parameter CU_PACKET_SEQUENCE_ID_WIDTH_BITS = $clog2(({CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE}*NUM_BUNDLES)+(8*NUM_BUNDLES));\n")
    
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

    # ... [The previous writing for the arrays here] ...

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// TOPOLOGY CONFIGURATIONS CHANNEL\n")
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write(f"parameter NUM_CHANNELS_MAX = {NUM_CHANNELS_MAX},\n")
    file.write("parameter int CHANNEL_CONFIG_L1_CACHE[NUM_CHANNELS_MAX]            =" + vhdl_format(CHANNEL_CONFIG_L1) + ",\n")
    file.write("parameter int CHANNEL_CONFIG_L2_CACHE[NUM_CHANNELS_MAX]            =" + vhdl_format(CHANNEL_CONFIG_L2) + ",\n")
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

                file.write(f"               assign engine_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;\n")
                file.write(f"          end\n") 
                file.write(f"endgenerate\n")
                file.write(f"\n\n") 

    for ID_BUNDLE in range(NUM_BUNDLES):

        NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE]
        ENGINES_COUNT_ARRAY                  = CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[ID_BUNDLE]     


        LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE = CU_BUNDLES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[ID_BUNDLE]
        LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[ID_BUNDLE]

        for ID_LANE in range(NUM_LANES):

            NUM_ENGINES = ENGINES_COUNT_ARRAY[ID_LANE]
            ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE = LANES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[ID_LANE]
            ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE = LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[ID_LANE]

            if ENGINES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE:

                file.write("\n")
                file.write(f"generate\n")
                file.write(f"     if((ID_BUNDLE == {ID_BUNDLE}) && (ID_LANE == {ID_LANE}))\n")
                file.write(f"          begin\n")  

                REAL_ID_ENGINE = 0;
                for ID_ENGINE in range(NUM_ENGINES):
                    MAP_ENGINE = ENGINES_CONFIG_ENGINE_ARBITER_NUM_CONTROL_RESPONSE[ID_ENGINE]

                    if MAP_ENGINE:
                        file.write(f"               assign engine_arbiter_1_to_N_control_fifo_response_signals_in[{REAL_ID_ENGINE}].rd_en = ~engines_fifo_response_control_in_signals_out[{ID_ENGINE}].prog_full & fifo_response_control_in_signals_in_reg.rd_en;\n")
                        file.write(f"               assign engines_response_control_in[{ID_ENGINE}] = engine_arbiter_1_to_N_control_response_out[{REAL_ID_ENGINE}];\n")
                        file.write(f"               assign engines_fifo_response_control_in_signals_in[{ID_ENGINE}].rd_en = 1'b1;\n")
                        REAL_ID_ENGINE += 1
                    else:
                        file.write(f"               assign engines_response_control_in[{ID_ENGINE}] = 0;\n")
                        file.write(f"               assign engines_fifo_response_control_in_signals_in[{ID_ENGINE}].rd_en = 1'b0;\n")

                for ID_ENGINE in range(REAL_ID_ENGINE,NUM_ENGINES):
                    file.write(f"               assign engine_arbiter_1_to_N_control_fifo_response_signals_in[{REAL_ID_ENGINE}].rd_en = 1'b0;\n")

                file.write(f"               assign engine_arbiter_1_to_N_control_response_in = response_control_in_int;\n")
                file.write(f"          end\n") 
                file.write(f"endgenerate\n")
                file.write(f"\n\n") 


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

            file.write(f"               assign lane_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;\n")
            file.write(f"          end\n") 
            file.write(f"endgenerate\n")
            file.write(f"\n\n") 

    for ID_BUNDLE in range(NUM_BUNDLES):

        NUM_LANES = CU_BUNDLES_COUNT_ARRAY[ID_BUNDLE] 
        LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE  = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE [ID_BUNDLE]
        LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE  = CU_BUNDLES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE [ID_BUNDLE]

        if LANES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE :

            file.write("\n")
            file.write(f"generate\n")
            file.write(f"     if(ID_BUNDLE == {ID_BUNDLE})\n")
            file.write(f"          begin\n")  

            REAL_ID_LANE = 0;
            for ID_LANE in range(NUM_LANES):
                MAP_LANE = LANES_CONFIG_LANE_ARBITER_NUM_CONTROL_RESPONSE[ID_LANE]

                if MAP_LANE:
                    file.write(f"               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[{REAL_ID_LANE}].rd_en = ~lanes_fifo_response_control_in_signals_out[{ID_LANE}].prog_full & fifo_response_control_in_signals_in_reg.rd_en;\n")
                    file.write(f"               assign lanes_response_control_in[{ID_LANE}] = lane_arbiter_1_to_N_control_response_out[{REAL_ID_LANE}];\n")
                    file.write(f"               assign lanes_fifo_response_control_in_signals_in[{ID_LANE}].rd_en = 1'b1;\n")
                    REAL_ID_LANE += 1
                else:
                    file.write(f"               assign lanes_response_control_in[{ID_LANE}] = 0;\n")
                    file.write(f"               assign lanes_fifo_response_control_in_signals_in[{ID_LANE}].rd_en = 1'b0;\n")

            for ID_LANE in range(REAL_ID_LANE,NUM_LANES):
                file.write(f"               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[{REAL_ID_LANE}].rd_en = 1'b0;\n")
                   

            file.write(f"               assign lane_arbiter_1_to_N_control_response_in = response_control_in_int;\n")
            file.write(f"          end\n") 
            file.write(f"endgenerate\n")
            file.write(f"\n\n") 


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
            file.write(f"               assign bundle_arbiter_control_N_to_1_request_in[{REAL_ID_BUNDLE}]  = 0;\n")

        file.write(f"               assign bundle_arbiter_control_N_to_1_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;\n")
        file.write(f"          end\n") 
        file.write(f"endgenerate\n")
        file.write(f"\n\n") 

    if CU_BUNDLES_CONFIG_CU_ARBITER_NUM_CONTROL_RESPONSE:

        file.write("\n")
        file.write(f"generate\n")
        file.write(f"     if(ID_CU == 0)\n")
        file.write(f"          begin\n")  

        REAL_ID_BUNDLE = 0;
        for ID_BUNDLE in range(NUM_BUNDLES):
            MAP_BUNDLE  = CU_BUNDLES_CONFIG_BUNDLE_ARBITER_NUM_CONTROL_RESPONSE_TEMP[ID_BUNDLE]

            if MAP_BUNDLE:
                file.write(f"               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[{REAL_ID_BUNDLE}].rd_en = ~bundle_fifo_response_control_in_signals_out[{ID_BUNDLE}].prog_full & fifo_response_control_in_signals_in_reg.rd_en;\n")
                file.write(f"               assign bundle_response_control_in[{ID_BUNDLE}] = bundle_arbiter_control_1_to_N_response_out[{REAL_ID_BUNDLE}];\n")
                file.write(f"               assign bundle_fifo_response_control_in_signals_in[{ID_BUNDLE}].rd_en = 1'b1;\n")
                REAL_ID_BUNDLE += 1
            else:
                file.write(f"               assign bundle_response_control_in[{ID_BUNDLE}] = 0;\n")
                file.write(f"               assign bundle_fifo_response_control_in_signals_in[{ID_BUNDLE}].rd_en = 1'b0;\n")

        for ID_BUNDLE in range(REAL_ID_BUNDLE,NUM_BUNDLES):
            file.write(f"               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[{ID_BUNDLE}].rd_en = 1'b0;\n")


        file.write(f"               assign bundle_arbiter_control_1_to_N_response_in = response_control_in_int;\n")
        file.write(f"          end\n") 
        file.write(f"endgenerate\n")
        file.write(f"\n\n") 


with open(output_file_afu_topology, 'w') as file:
    output_lines = []

    for channel, channel_dist in zip(range(int(NUM_CHANNELS_TOP)), DISTINCT_CHANNELS):
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"// Channel {channel}")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"// Channel {channel} READ AXI4 SIGNALS INPUT")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"assign m_axi4_read[{channel}].in.rvalid  = m{channel_dist:02d}_axi_rvalid ; // Read channel valid")
        output_lines.append(f"assign m_axi4_read[{channel}].in.arready = m{channel_dist:02d}_axi_arready; // Address read channel ready")
        output_lines.append(f"assign m_axi4_read[{channel}].in.rlast   = m{channel_dist:02d}_axi_rlast  ; // Read channel last word")
        output_lines.append(f"assign m_axi4_read[{channel}].in.rdata   = swap_endianness_cacheline_axi_be(m{channel_dist:02d}_axi_rdata, endian_read_reg)  ; // Read channel data")
        output_lines.append(f"assign m_axi4_read[{channel}].in.rid     = m{channel_dist:02d}_axi_rid    ; // Read channel ID")
        output_lines.append(f"assign m_axi4_read[{channel}].in.rresp   = m{channel_dist:02d}_axi_rresp  ; // Read channel response")
        output_lines.append("")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"// Channel {channel} READ AXI4 SIGNALS OUTPUT")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arvalid = m_axi4_read[{channel}].out.arvalid; // Address read channel valid")
        output_lines.append(f"assign m{channel_dist:02d}_axi_araddr  = m_axi4_read[{channel}].out.araddr ; // Address read channel address")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arlen   = m_axi4_read[{channel}].out.arlen  ; // Address write channel burst length")
        output_lines.append(f"assign m{channel_dist:02d}_axi_rready  = m_axi4_read[{channel}].out.rready ; // Read channel ready")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arid    = m_axi4_read[{channel}].out.arid   ; // Address read channel ID")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arsize  = m_axi4_read[{channel}].out.arsize ; // Address read channel burst size")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arburst = m_axi4_read[{channel}].out.arburst; // Address read channel burst type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arlock  = m_axi4_read[{channel}].out.arlock ; // Address read channel lock type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arcache = m_axi4_read[{channel}].out.arcache; // Address read channel memory type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arprot  = m_axi4_read[{channel}].out.arprot ; // Address write channel protection type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_arqos   = m_axi4_read[{channel}].out.arqos  ; // Address write channel quality of service")
        output_lines.append("")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"// Channel {channel} WRITE AXI4 SIGNALS INPUT")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"assign m_axi4_write[{channel}].in.awready = m{channel_dist:02d}_axi_awready; // Address write channel ready")
        output_lines.append(f"assign m_axi4_write[{channel}].in.wready  = m{channel_dist:02d}_axi_wready ; // Write channel ready")
        output_lines.append(f"assign m_axi4_write[{channel}].in.bid     = m{channel_dist:02d}_axi_bid    ; // Write response channel ID")
        output_lines.append(f"assign m_axi4_write[{channel}].in.bresp   = m{channel_dist:02d}_axi_bresp  ; // Write channel response")
        output_lines.append(f"assign m_axi4_write[{channel}].in.bvalid  = m{channel_dist:02d}_axi_bvalid ; // Write response channel valid")
        output_lines.append("")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"// Channel {channel} WRITE AXI4 SIGNALS OUTPUT")
        output_lines.append(f"// --------------------------------------------------------------------------------------")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awvalid = m_axi4_write[{channel}].out.awvalid; // Address write channel valid")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awid    = m_axi4_write[{channel}].out.awid   ; // Address write channel ID")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awaddr  = m_axi4_write[{channel}].out.awaddr ; // Address write channel address")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awlen   = m_axi4_write[{channel}].out.awlen  ; // Address write channel burst length")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awsize  = m_axi4_write[{channel}].out.awsize ; // Address write channel burst size")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awburst = m_axi4_write[{channel}].out.awburst; // Address write channel burst type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awlock  = m_axi4_write[{channel}].out.awlock ; // Address write channel lock type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awcache = m_axi4_write[{channel}].out.awcache; // Address write channel memory type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awprot  = m_axi4_write[{channel}].out.awprot ; // Address write channel protection type")
        output_lines.append(f"assign m{channel_dist:02d}_axi_awqos   = m_axi4_write[{channel}].out.awqos  ; // Address write channel quality of service")
        output_lines.append(f"assign m{channel_dist:02d}_axi_wdata   = swap_endianness_cacheline_axi_be(m_axi4_write[{channel}].out.wdata, endian_write_reg); // Write channel data")
        output_lines.append(f"assign m{channel_dist:02d}_axi_wstrb   = m_axi4_write[{channel}].out.wstrb  ; // Write channel write strobe")
        output_lines.append(f"assign m{channel_dist:02d}_axi_wlast   = m_axi4_write[{channel}].out.wlast  ; // Write channel last word flag")
        output_lines.append(f"assign m{channel_dist:02d}_axi_wvalid  = m_axi4_write[{channel}].out.wvalid ; // Write channel valid")
        output_lines.append(f"assign m{channel_dist:02d}_axi_bready  = m_axi4_write[{channel}].out.bready ; // Write response channel ready")
        output_lines.append("")

    # Writing to the VHDL file

    file.write('\n'.join(output_lines))


with open(output_file_afu_ports, 'w') as file:
    output_lines = []

    ports_template = """
output logic                         m{0:02d}_axi_awvalid,
input  logic                         m{0:02d}_axi_awready,
output logic [ M_AXI4_BE_ADDR_W-1:0] m{0:02d}_axi_awaddr ,
output logic [  M_AXI4_BE_LEN_W-1:0] m{0:02d}_axi_awlen  ,
output logic                         m{0:02d}_axi_wvalid ,
input  logic                         m{0:02d}_axi_wready ,
output logic [ M_AXI4_BE_DATA_W-1:0] m{0:02d}_axi_wdata  ,
output logic [ M_AXI4_BE_STRB_W-1:0] m{0:02d}_axi_wstrb  ,
output logic                         m{0:02d}_axi_wlast  ,
input  logic                         m{0:02d}_axi_bvalid ,
output logic                         m{0:02d}_axi_bready ,
output logic                         m{0:02d}_axi_arvalid,
input  logic                         m{0:02d}_axi_arready,
output logic [ M_AXI4_BE_ADDR_W-1:0] m{0:02d}_axi_araddr ,
output logic [  M_AXI4_BE_LEN_W-1:0] m{0:02d}_axi_arlen  ,
input  logic                         m{0:02d}_axi_rvalid ,
output logic                         m{0:02d}_axi_rready ,
input  logic [ M_AXI4_BE_DATA_W-1:0] m{0:02d}_axi_rdata  ,
input  logic                         m{0:02d}_axi_rlast  ,
// Control Signals
// AXI4 master interface m{0:02d}_axi missing ports
input  logic [   M_AXI4_BE_ID_W-1:0] m{0:02d}_axi_bid    ,
input  logic [   M_AXI4_BE_ID_W-1:0] m{0:02d}_axi_rid    ,
input  logic [ M_AXI4_BE_RESP_W-1:0] m{0:02d}_axi_rresp  ,
input  logic [ M_AXI4_BE_RESP_W-1:0] m{0:02d}_axi_bresp  ,
output logic [   M_AXI4_BE_ID_W-1:0] m{0:02d}_axi_awid   ,
output logic [ M_AXI4_BE_SIZE_W-1:0] m{0:02d}_axi_awsize ,
output logic [M_AXI4_BE_BURST_W-1:0] m{0:02d}_axi_awburst,
output logic [ M_AXI4_BE_LOCK_W-1:0] m{0:02d}_axi_awlock ,
output logic [M_AXI4_BE_CACHE_W-1:0] m{0:02d}_axi_awcache,
output logic [ M_AXI4_BE_PROT_W-1:0] m{0:02d}_axi_awprot ,
output logic [  M_AXI4_BE_QOS_W-1:0] m{0:02d}_axi_awqos  ,
output logic [   M_AXI4_BE_ID_W-1:0] m{0:02d}_axi_arid   ,
output logic [ M_AXI4_BE_SIZE_W-1:0] m{0:02d}_axi_arsize ,
output logic [M_AXI4_BE_BURST_W-1:0] m{0:02d}_axi_arburst,
output logic [ M_AXI4_BE_LOCK_W-1:0] m{0:02d}_axi_arlock ,
output logic [M_AXI4_BE_CACHE_W-1:0] m{0:02d}_axi_arcache,
output logic [ M_AXI4_BE_PROT_W-1:0] m{0:02d}_axi_arprot ,
output logic [  M_AXI4_BE_QOS_W-1:0] m{0:02d}_axi_arqos  ,
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
    slv_m00_axi_vip inst_slv_m{0:02d}_axi_vip (
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

        slv_m00_axi_vip_slv_mem_t m{0:02d}_axi    ;
        slv_m00_axi_vip_slv_t     m{0:02d}_axi_slv;
        """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(module_template.format(channel))

    file.write('\n'.join(output_lines))

def generate_tcl_script_from_json(output_file_name):
  
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

def generate_ipx_associate_commands(output_file_name):

    # Open output file for appending
    with open(output_file_name, "a") as file:
        for channel_num in DISTINCT_CHANNELS:
            file.write(f'ipx::associate_bus_interfaces -busif "m0{channel_num}_axi" -clock "ap_clk" $core >> $log_file\n')

# Generate the ipx::associate_bus_interfaces commands
generate_ipx_associate_commands(output_file_generate_ports_tcl)
generate_tcl_script_from_json(output_file_buffer_channels_tcl)



# Write to VHDL file
with open(output_file_slv_m_axi_vip_func, "w") as file:
    output_lines = []

    fill_memory_template = """
/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the input buffer AXI vip memory model with 32-bit words
        function void  m{0:02d}_axi_buffer_fill_memory(
                input slv_m00_axi_vip_slv_mem_t mem,      // vip memory model handle
                input bit [63:0] ptr,                     // start address of memory fill, should allign to 16-byte
                input bit [M_AXI4_BE_DATA_W-1:0] words_data[$],      // data source to fill memory
                input integer offset,                 // start index of data source
                input integer words                   // number of words to fill
            );
            int index;
            // bit [(32/8)-1:0] wr_strb = 4'hf;
            bit [M_AXI4_BE_DATA_W-1:0] temp;
            int i;
            for (index = 0; index < words; index++) begin
                // $display("Before: %0d ->%0d ->%0h",index, i, words_data[offset+index]);
                for (i = 0; i < (M_AXI4_BE_DATA_W/8); i = i + 1) begin // endian conversion to emulate general memory little endian behavior
                    temp[i*8+7-:8] = words_data[offset+index][((M_AXI4_BE_DATA_W/8)-1-i)*8+7-:8];
                    // $display("%0d ->%0d ->%0h",index, i, temp[i*8+7-:8] );
                end
                // $display("After: %0d ->%0d ->%0h",index, i, temp);
                mem.mem_model.backdoor_memory_write(ptr + index * (M_AXI4_BE_DATA_W/8), temp);
            end
        endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the m00_axi memory.
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
            m{0:02d}_axi_buffer_fill_memory(m{0:02d}_axi, {1}_ptr, graph.{2}, 0, graph.mem512_{2});
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
        parameter integer C_M{0:02d}_AXI_ADDR_WIDTH       = M_AXI4_BE_ADDR_W        ;
        parameter integer C_M{0:02d}_AXI_DATA_WIDTH       = M_AXI4_BE_DATA_W        ;
        parameter integer C_M{0:02d}_AXI_ID_WIDTH         = M_AXI4_BE_ID_W          ;
        """

    for channel in DISTINCT_CHANNELS:
        output_lines.append(ports_template.format(channel))

    file.write('\n'.join(output_lines))