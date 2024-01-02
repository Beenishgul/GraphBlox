#!/usr/bin/env python3

import re
import sys
import os
import ast
import json

# Validate the number of arguments
if len(sys.argv) != 9:
    print("Usage: <script> <FULL_SRC_IP_DIR_OVERLAY> <FULL_SRC_IP_DIR_RTL> <FULL_SRC_FPGA_UTILS_CPP> <utils> <ARCHITECTURE> <CAPABILITY> <ALGORITHM_NAME> <INCLUDE_DIR>")
    sys.exit(1)

# Assuming the script name is the first argument, and the directories follow after.
_, FULL_SRC_IP_DIR_OVERLAY, FULL_SRC_IP_DIR_RTL, FULL_SRC_FPGA_UTILS_CPP, UTILS_DIR, ARCHITECTURE, CAPABILITY, ALGORITHM_NAME, INCLUDE_DIR = sys.argv

# Define the filename based on the CAPABILITY
config_filename = f"topology.json"
overlay_template_filename = f"{ALGORITHM_NAME}.ol"
json_template_filename = f"{ALGORITHM_NAME}.json"

json_program_path= f"{CAPABILITY}.json"
overlay_program_path= f"{CAPABILITY}.ol"  

cpp_template_filename = f"buffer_mapping.{ALGORITHM_NAME}.cpp"
verilog_template_filename = f"buffer_mapping.{ALGORITHM_NAME}.vh"

json_template_source= f"{ARCHITECTURE}/Engines/Templates.json"
overlay_template_source= f"{ARCHITECTURE}/Engines/Templates.ol"
config_architecture_path= f"{ARCHITECTURE}/{CAPABILITY}"


# Construct the full path for the file
output_file_path_ol = os.path.join(FULL_SRC_IP_DIR_OVERLAY, config_architecture_path, "Templates", overlay_template_filename)
# output_file_path_cpp = os.path.join(FULL_SRC_IP_DIR_CONFIG, config_architecture_path, cpp_template_filename)
output_file_path_json = os.path.join(FULL_SRC_IP_DIR_OVERLAY, config_architecture_path, "Templates", json_template_filename)
# output_file_path_cpp = os.path.join(FULL_SRC_IP_DIR_CONFIG, config_architecture_path, cpp_template_filename)
output_file_path_cpp = os.path.join(FULL_SRC_FPGA_UTILS_CPP, cpp_template_filename)
# output_file_path_vh = os.path.join(FULL_SRC_IP_DIR_OVERLAY, config_architecture_path, verilog_template_filename)
output_file_path_vh = os.path.join(FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "mapping", verilog_template_filename)

config_file_path = os.path.join(FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, config_filename)


source_program_path_json = os.path.join(FULL_SRC_IP_DIR_OVERLAY, config_architecture_path, json_program_path, json_template_filename)
output_program_path_ol = os.path.join(FULL_SRC_IP_DIR_OVERLAY, config_architecture_path, overlay_program_path, overlay_template_filename)


with open(config_file_path, "r") as file:
    config_data = json.load(file)

mapping = config_data["mapping"]
cycles  = config_data["cycles"]
buffers = config_data["buffers"]

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

entries = []
entry_index = 0
engine_index = 0

entries_cpp = []
entry_index_cpp = 0
engine_index_cpp = 0

entries_vh = []
entry_index_vh = 0
engine_index_vh = 0

combined_engine_template_json = {}
entry_index_json = 0
engine_index_json = 0


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
check_and_clean_file(output_file_path_json)
check_and_clean_file(output_file_path_cpp)
check_and_clean_file(output_file_path_vh)
check_and_clean_file(output_program_path_ol)

def get_engine_id(engine_name):
    global engine_index
    global output_file_path_ol
    global output_file_path_cpp
    global output_file_path_vh
    global buffers
    base_name    = engine_name.split("(")[0]
    buffer_name, buffer_start, buffer_end  = extract_buffer_details(engine_name) 
    buffer_key   = get_key_from_value(buffers, buffer_name)
    base_mapping = mapping.get(base_name, 0)
    base_cycles  = cycles.get(base_name, 0)
    engine_template_filename_ol = f"{base_name}.ol" 
    engine_template_filename_json = f"{base_name}.json" 
    template_file_path_ol   = os.path.join(FULL_SRC_IP_DIR_OVERLAY, overlay_template_source)
    template_file_path_json = os.path.join(FULL_SRC_IP_DIR_OVERLAY, json_template_source)
    
    buffer_start_ops = print_operations_cpp(buffer_start)
    buffer_end_ops = print_operations_cpp(buffer_end)
    append_to_file(output_file_path_ol, "// --------------------------------------------------------------------------------------")
    append_to_file(output_file_path_ol, f"// Name {base_name:<20}ID {engine_index:<4} mapping {base_mapping:<4} cycles {base_cycles:<4} {buffer_key}-{buffer_name} {buffer_start_ops}-{buffer_end_ops}")
    append_to_file(output_file_path_ol, "// --------------------------------------------------------------------------------------")
    process_file_ol(template_file_path_ol, engine_template_filename_ol)
    append_to_file(output_file_path_ol, "// --------------------------------------------------------------------------------------")
    
    append_to_file(output_file_path_vh, "// --------------------------------------------------------------------------------------")
    append_to_file(output_file_path_vh, f"// Name {base_name:<20}ID {engine_index:<4} mapping {base_mapping:<4} cycles {base_cycles:<4} {buffer_key}-{buffer_name} {buffer_start_ops}-{buffer_end_ops}")
    append_to_file(output_file_path_vh, "// --------------------------------------------------------------------------------------")
    process_file_vh(template_file_path_ol, engine_template_filename_ol, engine_name)
    append_to_file(output_file_path_vh, "// --------------------------------------------------------------------------------------")

    append_to_file(output_file_path_cpp, "// --------------------------------------------------------------------------------------")
    append_to_file(output_file_path_cpp, f"// Name {base_name:<20}ID {engine_index:<4} mapping {base_mapping:<4} cycles {base_cycles:<4} {buffer_key}-{buffer_name} {buffer_start_ops}-{buffer_end_ops}")
    append_to_file(output_file_path_cpp, "// --------------------------------------------------------------------------------------")
    process_file_cpp(template_file_path_ol, engine_template_filename_ol, engine_name)
    append_to_file(output_file_path_cpp, "// --------------------------------------------------------------------------------------")

    process_file_json(template_file_path_json, engine_template_filename_json, engine_name)


    return base_mapping

def get_key_from_value(buffers, value):
    """
    Returns the key for a given value in the buffers dictionary.
    If the value is not found, returns None.
    """
    for key, val in buffers.items():
        if val == value:
            return key
    return "None"

def get_index_from_value(buffers, value):
    """
    Returns the index of the key for a given value in the buffers dictionary.
    If the value is not found, returns None.
    """
    for index, (key, val) in enumerate(buffers.items()):
        if val == value:
            return index
    return "0"

def extract_buffer(token):
    """Extracts the text value from a token in the form (B:text)."""
    if "(B:" in token:
        start = token.find("(B:") + 3  # Finds the start index of the text after "(B:"
        end = token.find(")", start)   # Finds the end index, which is the closing ")"
        return token[start:end]        # Extracts and returns the substring
    return ""  # Returns an empty string if "(B:" is not found

def extract_buffer_details(token):
    """Extracts buffer details from a token. Handles (B:buffer_name,start,end) formats including mathematical operations."""
    if "(B:" in token:
        start = token.find("(B:") + 3
        end = token.find(")", start)
        details = token[start:end].split(',')

        buffer_name = details[0]  # Buffer name is always present
        start_value_ops = ['0']  # Default value
        end_value_ops = ['0']   # Default value

        # Improved pattern to match identifiers, numbers, and operators
        pattern = r'([a-zA-Z_][a-zA-Z0-9_]*|\d+|\+|\-|\*|\/|\%|\(|\))'

        # Update start and end values if present, including parsing for operations
        if len(details) > 1:
            start_value_ops = re.findall(pattern, details[1])
        if len(details) > 2:
            end_value_ops = re.findall(pattern, details[2])

        return buffer_name, start_value_ops, end_value_ops

    return "None", ['0'], ['0']

# Modified pad_data to accept a default pad value
def pad_data(data, max_length, default_val=0):
    padded_data = data.copy()
    while len(padded_data) < max_length:
        padded_data.append(default_val)
    return padded_data

def pad_lane(bundle):
    return pad_data(bundle, NUM_LANES_MAX, [0] * NUM_ENGINES_MAX)

def calculate_cache_info(entry_index, entries_per_line):
    cache_line_index = entry_index // entries_per_line
    entry_offset = entry_index % entries_per_line
    return cache_line_index, entry_offset

def print_operations_vh(ops):
    if not ops:
        print(f"echo No operations {ops}")
        return

    processed_ops = []
    processed_ops.append(f"(")
    for op in ops:
        if op.isdigit():
            # If the operation is a number
            processed_ops.append(f"{op}")
        elif op in {'+', '-', '*', '/', '%'}:
            # If the operation is a mathematical operator
            processed_ops.append(f"{op}")
        else:
            # If the operation is text
            processed_ops.append(f"graph.{op}")
    processed_ops.append(f")")
    # Join and print the processed operations
    operation_str = ' '.join(processed_ops)
    return operation_str

def print_operations_cpp(ops):
    if not ops:
        print(f"echo No operations {ops}")
        return

    processed_ops = []
    processed_ops.append(f"(")
    for op in ops:
        if op.isdigit():
            # If the operation is a number
            processed_ops.append(f"{op}")
        elif op in {'+', '-', '*', '/', '%'}:
            # If the operation is a mathematical operator
            processed_ops.append(f"{op}")
        else:
            # If the operation is text
            processed_ops.append(f"graph->{op}")
    processed_ops.append(f")")
    # Join and print the processed operations
    operation_str = ' '.join(processed_ops)
    return operation_str

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

def process_file_vh(template_file_path, engine_template_filename, engine_name):
    # Define the size of a cache line in bytes and the size of each entry
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    global entries_vh
    global entry_index_vh
    global engine_index_vh
    global output_file_path_vh
    global buffers

    engine_type    = engine_name.split("(")[0]
    buffer_name, buffer_start, buffer_end  = extract_buffer_details(engine_name) 
    buffer_start_ops = print_operations_vh(buffer_start)
    buffer_end_ops = print_operations_vh(buffer_end)
    buffer_key   = get_key_from_value(buffers, buffer_name)
    local_count = 0
    filename = os.path.join(template_file_path, engine_template_filename)
    # print(filename)

    # Read the file and process entries and comments
    with open(filename, 'r') as file:

        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r'(0x[0-9A-Fa-f]+)(.*)', line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(2).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(entry_index_vh, entries_per_cache_line)
                # append_to_file(output_file_path_vh, f"{hex_value:<10} // entry {entry_index:<4} cacheline {cache_line:<4} offset {offset:<4} -- count {local_count:<4} -- {comment}")
                
                if engine_type in ["ENGINE_CSR_INDEX", "ENGINE_READ_WRITE"]:
                    if local_count == 1:
                        append_to_file(output_file_path_vh, f"   // --  1  - Index_Start")
                        append_to_file(output_file_path_vh, f"    graph.overlay_program[{cache_line}][(M_AXI4_FE_DATA_W*{offset})+:M_AXI4_FE_DATA_W]  = {buffer_start_ops};")
                    elif local_count == 2:
                        append_to_file(output_file_path_vh, f"   // --  2  - Index_End")
                        append_to_file(output_file_path_vh, f"    graph.overlay_program[{cache_line}][(M_AXI4_FE_DATA_W*{offset})+:M_AXI4_FE_DATA_W]  = {buffer_end_ops};")
                    elif local_count == 7:
                        append_to_file(output_file_path_vh, f"   // --  7  - Array_size")
                        append_to_file(output_file_path_vh, f"    graph.overlay_program[{cache_line}][(M_AXI4_FE_DATA_W*{offset})+:M_AXI4_FE_DATA_W]  = {buffer_end_ops}-{buffer_start_ops};")

                entry_index_vh += 1
                local_count += 1
            # elif line.startswith('//'):  # This is a comment line
            #     print(line)  # Print the comment line as is

    engine_index_vh += 1

def process_file_cpp(template_file_path, engine_template_filename, engine_name):
    # Define the size of a cache line in bytes and the size of each entry
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    global entries_cpp
    global entry_index_cpp
    global engine_index_cpp
    global output_file_path_cpp
    global buffers

    engine_type    = engine_name.split("(")[0]
    buffer_name, buffer_start, buffer_end  = extract_buffer_details(engine_name) 
    buffer_start_ops = print_operations_cpp(buffer_start)
    buffer_end_ops = print_operations_cpp(buffer_end)
    buffer_key   = get_key_from_value(buffers, buffer_name)
    buffer_index   = get_index_from_value(buffers, buffer_name)
    local_count = 0
    filename = os.path.join(template_file_path, engine_template_filename)
    # print(filename)

    # Read the file and process entries and comments
    with open(filename, 'r') as file:
        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r'(0x[0-9A-Fa-f]+)(.*)', line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(2).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(entry_index_vh, entries_per_cache_line)
                # append_to_file(output_file_path_vh, f"{hex_value:<10} // entry {entry_index:<4} cacheline {cache_line:<4} offset {offset:<4} -- count {local_count:<4} -- {comment}")
                
                if engine_type in ["ENGINE_CSR_INDEX", "ENGINE_READ_WRITE"]:
                    if local_count == 1:
                        append_to_file(output_file_path_cpp, f"   // --  1  - Index_Start")
                        append_to_file(output_file_path_cpp, f"    overlay_program[{entry_index_cpp}] = {buffer_start_ops};")
                    elif local_count == 2:
                        append_to_file(output_file_path_cpp, f"   // --  2  - Index_End")
                        append_to_file(output_file_path_cpp, f"    overlay_program[{entry_index_cpp}] = {buffer_end_ops};")
                    elif local_count == 7:
                        append_to_file(output_file_path_cpp, f"   // --  7  - Array_size")
                        append_to_file(output_file_path_cpp, f"    overlay_program[{entry_index_cpp}] = {buffer_end_ops}-{buffer_start_ops};")

                entry_index_cpp += 1
                local_count += 1
            # elif line.startswith('//'):  # This is a comment line
            #     print(line)  # Print the comment line as is

    engine_index_cpp += 1

def process_file_json(template_file_path, engine_template_filename, engine_name):
    # Define the size of a cache line in bytes and the size of each entry
    global combined_engine_template_json
    global entry_index__json
    global engine_index_json
    global output_file_path_json

    engine_type = engine_name.split("(")[0]
    filename = os.path.join(template_file_path, engine_template_filename)
    engine_id = f"{engine_type}_{engine_index_json}"
    # print(filename)

    # Read the file and process entries and comments
    with open(filename, 'r') as file:
        # Load the JSON data from the file
        json_engine_template = json.load(file)
        # Combine the data
        combined_engine_template_json[engine_id]=json_engine_template # Use extend for lists, update for dicts

    engine_index_json += 1


# Function to parse and construct the entries with compact comments
def process_entries_json(output_program_path_ol, source_program_path_json):

    global topology
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    total_number_entries = 0

    with open(source_program_path_json, 'r') as file:
        # Load the JSON data from the file
        parsed_data = json.load(file)

    for engine_name, engine_data in parsed_data.items():

        entries = engine_data["entries"]
        # Print engine name and number of entries
        
        append_to_file(output_program_path_ol, f"// --------------------------------------------------------------------------------------")
        append_to_file(output_program_path_ol, f"// Engine: {engine_name}, Number of entries: {len(entries)}")
        append_to_file(output_program_path_ol, f"// --------------------------------------------------------------------------------------")
        lookup_tables = {**engine_data.get('type_memory_cmd', {}), **engine_data.get('type_ALU_operation', {}), **engine_data.get('type_filter_operation', {})}

        for key in entries:
            cache_line, offset = calculate_cache_info(total_number_entries, entries_per_cache_line)
            total_number_entries += 1
            entry = entries[key]
            entry_value = 0

            bits_prev = 0
            comment_details = []  # List to store details for the comment

            # Start from LSB to MSB
            for param in entry:
                bits = int(entry[param]["bits"])
                value = entry[param]["value"]
                original_value = value
                original_flag = 0

                # Replace symbolic values with their corresponding numeric values
                if isinstance(value, str):
                    original_flag = 1
                    value = lookup_tables.get(value, value)
                
                # Convert to integer
                if isinstance(value, str) and value.startswith("0x"):
                    value = int(value, 16)
                else:
                    value = int(value)

                # Shift and OR the value
                value <<= bits_prev
                entry_value |= value

                # Calculate the bit range and format the value for the current parameter
                bit_range = f"{bits_prev}:{bits_prev + bits - 1}"
                if original_flag :
                    formatted_value = original_value
                else :
                    formatted_value = f"0x{value >> bits_prev}"  # Short hex value

                if bits == 1 and isinstance(formatted_value, int):
                    formatted_value = "True" if formatted_value == 1 else "False"

                comment_details.append(f"{param}[{bit_range}]={formatted_value}")
                bits_prev += bits

            # Convert to hexadecimal format
            entry_hex = f"0x{entry_value:08X}"
            # Create the compact comment
            comment = f" // {key:10} cacheline[{cache_line:3}][{offset:2}] <{bits_prev:2}b>: " + " || ".join(comment_details)
            append_to_file(output_program_path_ol, f"{entry_hex}{comment}")
    append_to_file(output_program_path_ol, f"// --------------------------------------------------------------------------------------")
    append_to_file(output_program_path_ol, f"// -->  Load.{topology}  <-- ")
    append_to_file(output_program_path_ol, f"// Number of entries {total_number_entries}")


append_to_file(output_file_path_cpp, "#include \"glayenv.hpp\"")
append_to_file(output_file_path_cpp, f"void GLAYGraphCSRxrtBufferHandlePerKernel::mapGLAYOverlayProgramBuffers{ALGORITHM_NAME}(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)")
append_to_file(output_file_path_cpp, "{")

# Get engine IDs and pad accordingly
CU_BUNDLES_ENGINE_CONFIG_ARRAY = [
    pad_lane([pad_data([get_engine_id(engine) for engine in lane], NUM_ENGINES_MAX) for lane in bundle])
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

append_to_file(output_file_path_cpp, "}")
append_to_file(output_file_path_cpp, "// --------------------------------------------------------------------------------------")
append_to_file(output_file_path_cpp, f"// -->  CPP.{topology}  <-- ")
append_to_file(output_file_path_cpp, f"// Number of entries {entry_index_cpp}")

append_to_file(output_file_path_ol, "// --------------------------------------------------------------------------------------")
append_to_file(output_file_path_ol, f"// -->  Template.{topology}  <-- ")
append_to_file(output_file_path_ol, f"// Number of entries {entry_index}")

append_to_file(output_file_path_vh, "// --------------------------------------------------------------------------------------")
append_to_file(output_file_path_vh, f"// -->  Benchmark.{topology}  <-- ")
append_to_file(output_file_path_vh, f"// Number of entries {entry_index_vh}")

# Write the combined data to a new file
with open(output_file_path_json, 'w') as f:
    json.dump(combined_engine_template_json, f, indent=4)

process_entries_json(output_program_path_ol, source_program_path_json)

print(f"export NUM_ENTRIES={entry_index_vh}")