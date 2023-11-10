import re
import sys
import os
import ast
import json

# Validate the number of arguments
if len(sys.argv) != 7:
    print("Usage: <script> <FULL_SRC_IP_DIR_CONFIG> <FULL_SRC_IP_DIR_OVERLAY> <ARCHITECTURE> <CAPABILITY> <ALGORITHM_NAME> <INCLUDE_DIR>")
    sys.exit(1)

# Assuming the script name is the first argument, and the directories follow after.
_, FULL_SRC_IP_DIR_CONFIG, FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, ALGORITHM_NAME, INCLUDE_DIR = sys.argv

# Define the filename based on the CAPABILITY
if CAPABILITY == "Single":
    config_filename = f"architecture.{ALGORITHM_NAME}.json"
    overlay_template_filename = f"template.{ALGORITHM_NAME}.ol"
    cpp_template_filename = f"template.{ALGORITHM_NAME}.cpp"
    verilog_template_filename = f"template.{ALGORITHM_NAME}.vh"
else:
    config_filename = "architecture.json"
    overlay_template_filename = "template.ol"
    cpp_template_filename = f"template.cpp"
    verilog_template_filename = f"template.vh"

overlay_template_source= "Engines.Templates"
overlay_template_path= f"{ARCHITECTURE}.{CAPABILITY}"
config_architecture_path= f"{ARCHITECTURE}.{CAPABILITY}"

# Construct the full path for the file
output_file_path_ol = os.path.join(FULL_SRC_IP_DIR_CONFIG, config_architecture_path, overlay_template_filename)
output_file_path_cpp = os.path.join(FULL_SRC_IP_DIR_CONFIG, config_architecture_path, cpp_template_filename)
output_file_path_vh = os.path.join(FULL_SRC_IP_DIR_CONFIG, config_architecture_path, verilog_template_filename)
config_file_path = os.path.join(FULL_SRC_IP_DIR_CONFIG, config_architecture_path, config_filename)

with open(config_file_path, "r") as file:
    config_data = json.load(file)

mapping = config_data["mapping"]
cycles = config_data["cycles"]

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

entries = []
entry_index = 0
engine_index = 0


def check_and_clean_file(file_path):
    # Check if the file exists
    if os.path.exists(file_path):
        # Delete the file if it exists
        os.remove(file_path)
        # print(f"MSG: Existing file '{file_path}' found and removed.")

def append_to_file(file_path, line_to_append):
    # Open the file in append mode ('a')
    with open(file_path, "a") as file:
        # Append the line with a newline character at the end
        file.write(line_to_append + "\n")

# Before writing to the file, clean up any existing version of the file
check_and_clean_file(output_file_path_ol)
check_and_clean_file(output_file_path_cpp)
check_and_clean_file(output_file_path_vh)

def get_engine_id(engine_name):
    global engine_index
    global output_file_path_ol
    base_name    = engine_name.split("(")[0]
    base_mapping = mapping.get(base_name, 0)
    base_cycles  = cycles.get(base_name, 0)
    engine_template_filename_ol = f"{base_name}.ol" 
    template_file_path = os.path.join(FULL_SRC_IP_DIR_OVERLAY, overlay_template_source)
    
    append_to_file(output_file_path_ol, "// --------------------------------------------------------------------------------------")
    append_to_file(output_file_path_ol, f"// Name {base_name:<20}ID {engine_index:<4} mapping {base_mapping:<4} cycles {base_cycles:<4}")
    append_to_file(output_file_path_ol, "// --------------------------------------------------------------------------------------")
    process_file_ol(template_file_path, engine_template_filename)
    append_to_file(output_file_path_ol, "// --------------------------------------------------------------------------------------")
    
    return base_mapping

# Modified pad_data to accept a default pad value
def pad_data(data, max_length, default_val=0):
    padded_data = data.copy()
    while len(padded_data) < max_length:
        padded_data.append(default_val)
    return padded_data

def pad_lane(bundle):
    return pad_data(bundle, NUM_LANES_MAX, [0] * NUM_ENGINES_MAX)

def process_file_ol(template_file_path, engine_template_filename):
    # Define the size of a cache line in bytes and the size of each entry
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    global entries
    global entry_index
    global engine_index
    global output_file_path_ol
    filename = os.path.join(template_file_path, engine_template_filename)
    # print(filename)

    def calculate_cache_info(entry_index, entries_per_line):
        cache_line_index = entry_index // entries_per_line
        entry_offset = entry_index % entries_per_line
        return cache_line_index, entry_offset

    # Read the file and process entries and comments
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r'(0x[0-9A-Fa-f]+)(.*)', line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(2).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(entry_index, entries_per_cache_line)
                append_to_file(output_file_path_ol, f"{hex_value:<10} // entry {entry_index:<4} cacheline {cache_line:<4} offset {offset:<4} -- {comment}")
                entry_index += 1
            # elif line.startswith('//'):  # This is a comment line
            #     print(line)  # Print the comment line as is

    engine_index += 1

def process_file_cpp(template_file_path, engine_template_filename):
    # Define the size of a cache line in bytes and the size of each entry
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    global entries
    global entry_index
    global engine_index
    global output_file_path_ol
    filename = os.path.join(template_file_path, engine_template_filename)
    # print(filename)

    def calculate_cache_info(entry_index, entries_per_line):
        cache_line_index = entry_index // entries_per_line
        entry_offset = entry_index % entries_per_line
        return cache_line_index, entry_offset

    # Read the file and process entries and comments
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r'(0x[0-9A-Fa-f]+)(.*)', line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(2).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(entry_index, entries_per_cache_line)
                append_to_file(output_file_path_ol, f"{hex_value:<10} // entry {entry_index:<4} cacheline {cache_line:<4} offset {offset:<4} -- {comment}")
                entry_index += 1
            # elif line.startswith('//'):  # This is a comment line
            #     print(line)  # Print the comment line as is

    engine_index += 1

# Get engine IDs and pad accordingly
CU_BUNDLES_ENGINE_CONFIG_ARRAY = [
    pad_lane([pad_data([get_engine_id(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]