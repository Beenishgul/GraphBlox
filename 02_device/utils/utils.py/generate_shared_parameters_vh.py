
import re
import sys
import os
import ast
import json

# Assuming the script name is the first argument, and the directories follow after.
script_name, FULL_SRC_IP_DIR_CONFIG, FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR = sys.argv

# Construct the full path for the file
output_file_path = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "shared_parameters.vh")
config_file_path = os.path.join(FULL_SRC_IP_DIR_CONFIG, "architecture.json")

with open(config_file_path, "r") as file:
    config_data = json.load(file)

mapping = config_data["mapping"]

# Extract bundles and transform to the desired format
CU_BUNDLES_CONFIG_ARRAY = [config_data['bundle'][key] for key in sorted(config_data['bundle'].keys(), key=int)]

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

def get_width(engine_name):
    match = re.search(r'W:(\d+)', engine_name)
    if match:
        return int(match.group(1))
    return 0

def get_engine_id(engine_name):
    base_name = engine_name.split("(")[0]
    return mapping.get(base_name, 0)

def get_connect_array(engine_name):
    match = re.search(r'C:(\d+):(\d+)', engine_name)
    if match:
        start, end = int(match.group(1)), int(match.group(2))
        return list(range(start, end + 1))
    return []

def vhdl_format(array):
    if not isinstance(array, list):
        return str(array)
    return "'{" + ", ".join(vhdl_format(subarray) for subarray in array) + "}\n"

def extract_cast_width(token):
    """Extracts the cast width value from a token in the form (C:x:y)."""
    if "(C:" in token:
        start = token.find("(C:") + 3
        end = token.find(")")
        return int(token[start:end].split(":")[-1])
    return 0

def generate_config_cast_width_array():
    """Generates the CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY based on CU_BUNDLES_CONFIG_ARRAY."""
    cu_bundles_config_cast_width_array = []

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
        
        cu_bundles_config_cast_width_array.append(lane_list)

    return cu_bundles_config_cast_width_array

cu_bundles_config_cast_width_array = generate_config_cast_width_array()


# Step 1: Determine NUM_CAST_MAX
NUM_CAST_MAX = max(
    [max(engine) if engine else 0 for bundle in CU_BUNDLES_CONFIG_ARRAY for lane in bundle for engine in [get_connect_array(engine_name) for engine_name in lane]]
) + 1  # Added 1 because the values are 0-indexed

CU_BUNDLES_ENGINE_ID_ARRAY = []

# Calculate number of bundles per CU
CU_BUNDLES_COUNT_ARRAY = [len(bundle) for bundle in CU_BUNDLES_CONFIG_ARRAY]

# Calculate number of lanes per bundle for each CU
CU_BUNDLES_LANES_COUNT_ARRAY = [[len(lane) for lane in bundle] for bundle in CU_BUNDLES_CONFIG_ARRAY]

CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY = [[len(lane) for lane in bundle] for bundle in CU_BUNDLES_CONFIG_ARRAY]

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

# Create the CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY with the correct padding
CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY = [
    [
        pad_engines_cast(
            [pad_connect_array(get_connect_array(engine), NUM_CAST_MAX) for engine in lane], 
            NUM_ENGINES_MAX
        ) 
        for lane in bundle
    ]
    for bundle in CU_BUNDLES_CONFIG_ARRAY
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


# Write to VHDL file
with open(output_file_path, "w") as file:
    # file.write("parameter NUM_MEMORY_REQUESTOR = 2,\n")
    # file.write("parameter ID_CU                = 0,\n")

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// FIFO SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")

    file.write("parameter FIFO_WRITE_DEPTH = 32,\n")
    file.write("parameter PROG_THRESH      = 16,\n\n")

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
    file.write("parameter int LANES_COUNT_ARRAY[NUM_BUNDLES_MAX]                                       = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))
    file.write("parameter int ENGINES_COUNT_ARRAY[NUM_LANES_MAX]                                       = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[0]).replace("[", "'{").replace("]", "}") + ",\n")
    file.write("parameter int LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_CONFIG_ARRAY[NUM_ENGINES_MAX]                                    = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int ENGINES_ENGINE_ID_ARRAY[NUM_ENGINES_MAX]                                 = " + str(CU_BUNDLES_ENGINE_ID_ARRAY[0][0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_CONFIG_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                       = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int LANES_ENGINE_ID_ARRAY[NUM_LANES_MAX][NUM_ENGINES_MAX]                    = " + str(CU_BUNDLES_ENGINE_ID_ARRAY[0]).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]    = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX] = " + str(CU_BUNDLES_ENGINE_ID_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// TOPOLOGY CONFIGURATIONS SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")
    file.write(f"parameter CU_BUNDLES_COUNT_ARRAY                           = {NUM_BUNDLES_MAX},\n")
    file.write("parameter int CU_BUNDLES_LANES_COUNT_ARRAY[NUM_BUNDLES_MAX] = '{%s},\n" % (",".join(map(str, CU_BUNDLES_COUNT_ARRAY))))

    file.write("parameter int CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX]                                 = " + str(CU_BUNDLES_LANES_ENGINES_COUNT_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                             = " + str(CU_BUNDLES_ENGINE_CONFIG_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_ENGINE_ID_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                          = " + str(CU_BUNDLES_ENGINE_ID_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                 = " + str(CU_BUNDLES_CONFIG_MERGE_WIDTH_ARRAY).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX]                  = " + str(cu_bundles_config_cast_width_array).replace("[", "'{").replace("]", "}\n") + ",\n")
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_ARRAY) + "\n")
    