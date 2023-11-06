
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

CU_BUNDLES_CONFIG_CAST_WIDTH_ARRAY = generate_config_cast_width_array()


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


# Write to VHDL file
with open(output_file_path, "w") as file:
    # file.write("parameter NUM_MEMORY_REQUESTOR = 2,\n")
    # file.write("parameter ID_CU                = 0,\n")

    file.write("// --------------------------------------------------------------------------------------\n")
    file.write("// FIFO SETTINGS\n")
    file.write("// --------------------------------------------------------------------------------------\n")

    file.write("parameter FIFO_WRITE_DEPTH = 16,\n")
    file.write("parameter PROG_THRESH      = 8,\n\n")

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
    file.write("parameter int CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY[NUM_BUNDLES_MAX][NUM_LANES_MAX][NUM_ENGINES_MAX][NUM_CAST_MAX] = " + vhdl_format(CU_BUNDLES_CONFIG_MERGE_CONNECT_PREFIX_ARRAY) + "\n")
   

   
