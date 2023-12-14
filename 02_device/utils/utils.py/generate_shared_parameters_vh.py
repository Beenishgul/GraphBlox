#!/usr/bin/env python3

import re
import sys
import os
import ast
import json


# Validate the number of arguments
if len(sys.argv) != 8:
    print("Usage: <script> <FULL_SRC_IP_DIR_OVERLAY> <FULL_SRC_IP_DIR_RTL> <UTILS_DIR> <ARCHITECTURE> <CAPABILITY> <ALGORITHM_NAME> <INCLUDE_DIR>")
    sys.exit(1)

# Assuming the script name is the first argument, and the directories follow after.
_, FULL_SRC_IP_DIR_OVERLAY, FULL_SRC_IP_DIR_RTL, UTILS_DIR, ARCHITECTURE, CAPABILITY, ALGORITHM_NAME, INCLUDE_DIR = sys.argv

# Construct the full path for the file
config_filename = f"topology.json"
config_file_path = os.path.join(FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, config_filename)

output_file_path = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "parameters" ,"shared_parameters.vh")
output_file_bundle_top = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "topology" , "bundle_topology.vh")
output_file_lane_top = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "topology" ,"lane_topology.vh")

with open(config_file_path, "r") as file:
    config_data = json.load(file)

mapping = config_data["mapping"]
luts    = config_data["luts"]
fifo_control  = config_data["fifo_control"]
fifo_memory   = config_data["fifo_memory"]
fifo_engine   = config_data["fifo_engine"]


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

def get_control_fifo(engine_name):
    base_name = engine_name.split("(")[0]
    return fifo_control.get(base_name, 0)

def get_engine_fifo(engine_name):
    base_name = engine_name.split("(")[0]
    return fifo_engine.get(base_name, 0)

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


# Get engine IDs and pad accordingly
CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY = [
    pad_lane([pad_data([get_memory_fifo(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE = [
    pad_lane([pad_data([get_engine_fifo(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL = [
    pad_lane([pad_data([get_control_fifo(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
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

CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL = [
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
for bundle_index, bundle in enumerate(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL):
    for lane_index, lane in enumerate(bundle):
        CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL[bundle_index][lane_index] = sum(lane)

CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY
]
CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE
]
CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL = [
    sum(lane) for lane in CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL
]


CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY  = sum(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY)
CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE  = sum(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE)
CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL = sum(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL)

check_and_clean_file(output_file_path)
check_and_clean_file(output_file_bundle_top)
check_and_clean_file(output_file_lane_top)

# Write to VHDL file
with open(output_file_path, "w") as file:
    # file.write("parameter NUM_MEMORY_REQUESTOR = 2,\n")
    # file.write("parameter ID_CU                = 0,\n")

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// FIFO SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")

    file.write("parameter FIFO_WRITE_DEPTH = 32,\n")
    file.write("parameter PROG_THRESH      = 20,\n\n")

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// CU CONFIGURATIONS SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")

    file.write(f"parameter NUM_CUS_MAX     = {NUM_CUS_MAX},\n")
    file.write(f"parameter NUM_BUNDLES_MAX = {NUM_BUNDLES_MAX},\n")
    file.write(f"parameter NUM_LANES_MAX   = {NUM_LANES_MAX},\n")
    file.write(f"parameter NUM_CAST_MAX    = {NUM_CAST_MAX},\n")
    file.write(f"parameter NUM_ENGINES_MAX = {NUM_ENGINES_MAX},\n\n")

    file.write(f"parameter NUM_CUS     = {NUM_CUS},\n")
    file.write(f"parameter NUM_BUNDLES = {NUM_BUNDLES},\n")
    file.write(f"parameter NUM_LANES   = {NUM_LANES},\n")
    file.write(f"parameter NUM_ENGINES = {NUM_ENGINES},\n\n")

    file.write(f"parameter NUM_CUS_INDEX     = {NUM_CUS},\n")
    file.write(f"parameter NUM_BUNDLES_INDEX = {NUM_BUNDLES},\n")
    file.write(f"parameter NUM_LANES_INDEX   = {NUM_LANES},\n")
    file.write(f"parameter NUM_ENGINES_INDEX = {NUM_ENGINES},\n\n")
    # ... [The previous writing for the arrays here] ...

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// TOPOLOGY CONFIGURATIONS DEFAULTS\n")
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                             = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))
    file.write("parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                             = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[0]).replace("[", "'{").replace("]", "}") + ",\n")
    file.write("parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                      = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                          = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_ENGINES_MAX]                           =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_ENGINES_MAX]                             =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[0][0]) + ",\n")
  
    file.write("parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                       = " + str(CU_BUNDLES_ENGINE_ID_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
   
    file.write("parameter int ENGINES_CONFIG_MERGE_WIDTH_ARRAY[NUM_ENGINES_MAX]                              = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                           = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_CAST_WIDTH_ARRAY[NUM_ENGINES_MAX]                               = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                            = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MERGE_CONNECT_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]              = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_ENGINES_MAX][NUM_CAST_MAX]       = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MAX_MERGE_WIDTH_ARRAY                                           = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[0][0]) + ",\n")
    file.write("parameter int ENGINES_CONFIG_MAX_CAST_WIDTH_ARRAY                                            = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[0][0]) + ",\n")
   

    file.write("parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                    = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_LANES_MAX][NUM_ENGINES_MAX]                   =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_LANES_MAX][NUM_ENGINES_MAX]                     =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[0]) + ",\n")
    file.write("parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                                 = " + str(CU_BUNDLES_ENGINE_ID_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_CONFIG_MERGE_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                        = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                    = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_CAST_WIDTH_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                         = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                     = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY                                                = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY                                               = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_LANES_MAX]                                     = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_LANES_MAX]                                      = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MERGE_CONNECT_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX]        = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[0]) + ",\n")
    file.write("parameter int LANES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[0]) + ",\n")
    
    file.write(f"parameter BUNDLES_COUNT_ARRAY                                                                                  = {NUM_BUNDLES_MAX},\n")
    file.write("parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN) + ",\n")
    file.write("parameter int BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                                        = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))
    file.write("parameter int BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = " + str(CU_BUNDLES_ENGINE_ID_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY) + ",\n")
    file.write("parameter int BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY) + ",\n")
    
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// TOPOLOGY CONFIGURATIONS SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write(f"parameter CU_BUNDLES_COUNT_ARRAY                           = {NUM_BUNDLES_MAX},\n")
    file.write("parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))

    file.write("parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]            =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_WIDTH) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]              =" + vhdl_format(CU_BUNDLES_CONFIG_ARRAY_ENGINE_SEQ_MIN) + ",\n")
    file.write("parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = " + str(CU_BUNDLES_ENGINE_ID_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                             = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = " + str(CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                         = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX]                                        = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                              = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_MERGE_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                               = " + vhdl_format(CU_BUNDLES_CONFIG_MAX_CAST_WIDTH_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY) + ",\n")
    
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_MEMORY} ,\n")   
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE =  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_ENGINE} ,\n")  
    file.write(f"parameter int CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL=  {CU_BUNDLES_CONFIG_CU_FIFO_ARBITER_SIZE_CONTROL} ,\n")   

    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_MEMORY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_ENGINE) + ",\n")  
    file.write("parameter int CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL[NUM_BUNDLES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_BUNDLE_FIFO_ARBITER_SIZE_CONTROL)+ ",\n")    

    file.write("parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_MEMORY) + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_ENGINE) + ",\n")  
    file.write("parameter int CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL[NUM_BUNDLES_MAX][NUM_LANES_MAX]= " + vhdl_format(CU_BUNDLES_CONFIG_LANE_FIFO_ARBITER_SIZE_CONTROL)+ ",\n")    

    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_MEMORY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_MEMORY).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_ENGINE[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_ENGINE).replace("[", "'{").replace("]", "}\n") + ",\n")    
    file.write("parameter int CU_BUNDLES_CONFIG_ENGINE_FIFO_ARBITER_SIZE_CONTROL[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_CONFIG_FIFO_ARBITER_SIZE_CONTROL).replace("[", "'{").replace("]", "}\n") + ",\n")    


    file.write(f"// total_luts={total_luts}\n\n")  
   


# Write to VHDL file
with open(output_file_bundle_top, "w") as file:
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
with open(output_file_lane_top, "w") as file:
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
                   

  
