#!/usr/bin/env python3

import re
import sys
import os
import ast
import json

# Validate the number of arguments
if len(sys.argv) != 9:
    print(
        "Usage: <script> <FULL_SRC_IP_DIR_OVERLAY> <FULL_SRC_IP_DIR_RTL> <FULL_SRC_FPGA_UTILS_CPP> <utils> <ARCHITECTURE> <CAPABILITY> <ALGORITHM_NAME> <INCLUDE_DIR>"
    )
    sys.exit(1)

# Assuming the script name is the first argument, and the directories follow after.
(
    _,
    FULL_SRC_IP_DIR_OVERLAY,
    FULL_SRC_IP_DIR_RTL,
    FULL_SRC_FPGA_UTILS_CPP,
    UTILS_DIR,
    ARCHITECTURE,
    CAPABILITY,
    ALGORITHM_NAME,
    INCLUDE_DIR,
) = sys.argv

# Define the filename based on the CAPABILITY
config_filename = f"topology.json"
overlay_template_filename = f"{ALGORITHM_NAME}.ol"
json_template_filename = f"{ALGORITHM_NAME}.json"

json_program_path = f"{CAPABILITY}.json"
overlay_program_path = f"{CAPABILITY}.ol"

cpp_template_filename = f"buffer_mapping.{ALGORITHM_NAME}.cpp"
verilog_template_filename = f"buffer_mapping.{ALGORITHM_NAME}.vh"

json_template_source = f"{ARCHITECTURE}/Engines/Templates.json"
overlay_template_source = f"{ARCHITECTURE}/Engines/Templates.ol"
config_architecture_path = f"{ARCHITECTURE}/{CAPABILITY}"


output_folder_path_templates = os.path.join(
    FULL_SRC_IP_DIR_OVERLAY, config_architecture_path, "Templates"
)

output_folder_path_mapping = os.path.join(
    FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "mapping"
)

output_folder_path_capability = os.path.join(
    FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY
)

if not os.path.exists(output_folder_path_templates):
    os.makedirs(output_folder_path_templates)

if not os.path.exists(FULL_SRC_FPGA_UTILS_CPP):
    os.makedirs(FULL_SRC_FPGA_UTILS_CPP)

if not os.path.exists(output_folder_path_mapping):
    os.makedirs(output_folder_path_mapping)

if not os.path.exists(output_folder_path_capability):
    os.makedirs(output_folder_path_capability)

# Construct the full path for the file
output_file_path_ol = os.path.join(
    FULL_SRC_IP_DIR_OVERLAY,
    config_architecture_path,
    "Templates",
    overlay_template_filename,
)

output_file_path_json = os.path.join(
    FULL_SRC_IP_DIR_OVERLAY,
    config_architecture_path,
    "Templates",
    json_template_filename,
)

output_file_path_cpp = os.path.join(FULL_SRC_FPGA_UTILS_CPP, cpp_template_filename)

output_file_path_vh = os.path.join(
    FULL_SRC_IP_DIR_RTL, UTILS_DIR, INCLUDE_DIR, "mapping", verilog_template_filename
)

config_file_path = os.path.join(
    FULL_SRC_IP_DIR_OVERLAY, ARCHITECTURE, CAPABILITY, config_filename
)


source_program_path_json = os.path.join(
    FULL_SRC_IP_DIR_OVERLAY,
    config_architecture_path,
    json_program_path,
    json_template_filename,
)
output_program_path_ol = os.path.join(
    FULL_SRC_IP_DIR_OVERLAY,
    config_architecture_path,
    overlay_program_path,
    overlay_template_filename,
)


with open(config_file_path, "r") as file:
    config_data = json.load(file)

# mapping = config_data["mapping"]
# cycles  = config_data["cycles"]
buffers = config_data["buffers"]
channels = config_data["channels"]
engine_properties = config_data["engine_properties"]


def recreate_data_structures_from_columns(engine_properties, categories_order):
    """
    Recreates the data structures for specified categories from the columnar 'engine_properties' data.

    Args:
    - engine_properties: A dictionary with engine properties as keys and lists as values,
      where each list's elements represent data for the categories in 'categories_order'.
    - categories_order: A list of category names in the order they appear in 'engine_properties' lists.

    Returns:
    - A dictionary of dictionaries, where each key is a category name from 'categories_order'
      and its value is a dictionary that mimics the structure of that category's original data.
    """
    # Initialize a dictionary to hold the recreated data for each category
    recreated_data = {category: {} for category in categories_order}

    # Iterate over each engine property and its columnar data
    for property_name, values in engine_properties.items():
        # For each category, extract the appropriate data and add it to the recreated data structure
        for i, category in enumerate(categories_order):
            if i < len(values):  # Ensure we do not go out of bounds
                recreated_data[category][property_name] = values[i]

    return recreated_data


# Define the order of categories as they appear in the engine_properties lists
categories_order = [
    "mapping",
    "cycles",
    "luts",
    "fifo_engine",
    "fifo_memory",
    "fifo_control_request",
    "fifo_control_response",
]
# Recreate the data structures for all categories
engine_properties_structures = recreate_data_structures_from_columns(
    engine_properties, categories_order
)

# Now, extract each category into its own variable
mapping = engine_properties_structures["mapping"]
cycles = engine_properties_structures["cycles"]
luts = engine_properties_structures["luts"]
fifo_control_response = engine_properties_structures["fifo_control_response"]
fifo_control_request = engine_properties_structures["fifo_control_request"]
fifo_memory = engine_properties_structures["fifo_memory"]
fifo_engine = engine_properties_structures["fifo_engine"]


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
NUM_ENGINES_MAX = max(
    len(lane) for bundle in CU_BUNDLES_CONFIG_ARRAY for lane in bundle
)

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
    base_name = engine_name.split("(")[0]
    detail_pattern = extract_buffer_details(engine_name)
    buffer_name, buffer_start, buffer_end = detail_pattern[0]
    buffer_key = get_key_from_value(buffers, buffer_name)
    base_mapping = mapping.get(base_name, 0)
    base_cycles = cycles.get(base_name, 0)
    engine_template_filename_ol = f"{base_name}.ol"
    engine_template_filename_json = f"{base_name}.json"
    template_file_path_ol = os.path.join(
        FULL_SRC_IP_DIR_OVERLAY, overlay_template_source
    )
    template_file_path_json = os.path.join(
        FULL_SRC_IP_DIR_OVERLAY, json_template_source
    )

    buffer_start_ops = print_operations_cpp(buffer_start)
    buffer_end_ops = print_operations_cpp(buffer_end)

    append_to_file(
        output_file_path_vh,
        "// --------------------------------------------------------------------------------------",
    )
    append_to_file(
        output_file_path_vh,
        f"// Name {base_name:<30}ID {engine_index:<4} mapping {base_mapping:<4} cycles {base_cycles:<4} {buffer_key}-{buffer_name} {buffer_start_ops}-{buffer_end_ops}",
    )
    append_to_file(
        output_file_path_vh,
        "// --------------------------------------------------------------------------------------",
    )
    # process_file_vh(template_file_path_ol, engine_template_filename_ol, engine_name)
    process_file_vh_v2(
        template_file_path_json,
        template_file_path_ol,
        engine_template_filename_json,
        engine_template_filename_ol,
        engine_name,
    )
    append_to_file(
        output_file_path_vh,
        "// --------------------------------------------------------------------------------------",
    )

    append_to_file(
        output_file_path_cpp,
        "// --------------------------------------------------------------------------------------",
    )
    append_to_file(
        output_file_path_cpp,
        f"// Name {base_name:<30}ID {engine_index:<4} mapping {base_mapping:<4} cycles {base_cycles:<4} {buffer_key}-{buffer_name} {buffer_start_ops}-{buffer_end_ops}",
    )
    append_to_file(
        output_file_path_cpp,
        "// --------------------------------------------------------------------------------------",
    )
    # process_file_cpp(template_file_path_ol, engine_template_filename_ol, engine_name)
    process_file_cpp_v2(
        template_file_path_json,
        template_file_path_ol,
        engine_template_filename_json,
        engine_template_filename_ol,
        engine_name,
    )
    append_to_file(
        output_file_path_cpp,
        "// --------------------------------------------------------------------------------------",
    )

    append_to_file(
        output_file_path_ol,
        "// --------------------------------------------------------------------------------------",
    )
    append_to_file(
        output_file_path_ol,
        f"// Name {base_name:<30}ID {engine_index:<4} mapping {base_mapping:<4} cycles {base_cycles:<4} {buffer_key}-{buffer_name} {buffer_start_ops}-{buffer_end_ops}",
    )
    append_to_file(
        output_file_path_ol,
        "// --------------------------------------------------------------------------------------",
    )
    process_file_ol(template_file_path_ol, engine_template_filename_ol)
    append_to_file(
        output_file_path_ol,
        "// --------------------------------------------------------------------------------------",
    )

    process_file_json(
        template_file_path_json, engine_template_filename_json, engine_name
    )

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
        end = token.find(")", start)  # Finds the end index, which is the closing ")"
        return token[start:end]  # Extracts and returns the substring
    return ""  # Returns an empty string if "(B:" is not found


def extract_buffer_details(token):
    """Extracts details of multiple buffers from a token, handling formats including mathematical operations.
    Ensures at least four tuples are returned."""
    buffer_pattern = r"\(B:([^\)]+)\)"
    detail_pattern = r"([a-zA-Z_][a-zA-Z0-9_]*|\d+|\+|\-|\*|\/|\%|\(|\))"
    matches = re.findall(buffer_pattern, token)

    buffer_details_list = []

    for match in matches:
        details = match.split(",")
        buffer_name = details[0]
        start_value_ops = ["0"]
        end_value_ops = ["0"]

        if len(details) > 1:
            start_value_ops = re.findall(detail_pattern, details[1])
        if len(details) > 2:
            end_value_ops = re.findall(detail_pattern, details[2])

        buffer_details_list.append((buffer_name, start_value_ops, end_value_ops))

    # Ensure there are at least four tuples in the list
    while len(buffer_details_list) < 4:
        buffer_details_list.append(("None", ["0"], ["0"]))

    return buffer_details_list


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
        elif op in {"+", "-", "*", "/", "%"}:
            # If the operation is a mathematical operator
            processed_ops.append(f"{op}")
        else:
            # If the operation is text
            processed_ops.append(f"graph.{op}")
    processed_ops.append(f")")
    # Join and print the processed operations
    operation_str = " ".join(processed_ops)
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
        elif op in {"+", "-", "*", "/", "%"}:
            # If the operation is a mathematical operator
            processed_ops.append(f"{op}")
        else:
            # If the operation is text
            processed_ops.append(f"graph->{op}")
    processed_ops.append(f")")
    # Join and print the processed operations
    operation_str = " ".join(processed_ops)
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
    with open(filename, "r") as file:
        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r"(0x[0-9A-Fa-f]+)(.*)", line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(
                    2
                ).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(
                    entry_index, entries_per_cache_line
                )
                append_to_file(
                    output_file_path_ol,
                    f"{hex_value:<10} // entry {entry_index:<4} cacheline {cache_line:<4} offset {offset:<4} -- {comment}",
                )
                entry_index += 1
            # elif line.startswith('//'):  # This is a comment line
            #     print(line)  # Print the comment line as is

    engine_index += 1

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
    with open(filename, "r") as file:
        # Load the JSON data from the file
        json_engine_template = json.load(file)
        # Combine the data
        # combined_engine_template_json[engine_id]=json_engine_template # Use extend for lists, update for dicts

    # This replaces the entire top-level key with the new engine_id
    new_engine_template = {
        engine_id: json_engine_template[next(iter(json_engine_template))]
    }

    # Update the combined JSON structure
    combined_engine_template_json.update(new_engine_template)

    engine_index_json += 1


def get_buffer_index(buffers, input_value):
    # Iterate through the dictionary with an index counter
    for index, (key, value) in enumerate(buffers.items()):
        if key == input_value or value == input_value:
            return index  # This is an integer

    # Return None if no match is found
    return None


def get_channels_index(channels, input_value):
    # Iterate through the dictionary with an index counter
    for index, (key, value) in enumerate(channels.items()):
        if key == input_value or value[0] == input_value:
            return int(value[0])  # This is an integer

    # Return None if no match is found
    return None


def process_file_vh_v2(
    template_file_path_json,
    template_file_path_ol,
    engine_template_filename_json,
    engine_template_filename_ol,
    engine_name,
):
    # Define the size of a cache line in bytes and the size of each entry
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    global entries_vh
    global entry_index_vh
    global engine_index_vh
    global output_file_path_vh
    global buffers
    global channels

    engine_type = engine_name.split("(")[0]
    detail_pattern = extract_buffer_details(engine_name)
    buffer_name, buffer_start, buffer_end = detail_pattern[0]
    buffer_start_ops = print_operations_vh(buffer_start)
    buffer_end_ops = print_operations_vh(buffer_end)
    buffer_key = get_key_from_value(buffers, buffer_name)
    local_count = 0
    filename_ol = os.path.join(template_file_path_ol, engine_template_filename_ol)
    filename_json = os.path.join(template_file_path_json, engine_template_filename_json)

    # print(f"echo {filename_ol}")
    # print(f"echo {engine_name}")

    check_and_clean_file(filename_ol)

    process_entries_json_v2(filename_ol, filename_json, channels, buffers)

    # Read the file and process entries and comments
    with open(filename_ol, "r") as file:

        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r"(0x[0-9A-Fa-f]+)(.*)", line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(
                    2
                ).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(
                    entry_index_vh, entries_per_cache_line
                )
                # append_to_file(output_file_path_vh, f"{hex_value:<10} // entry {entry_index:<4} cacheline {cache_line:<4} offset {offset:<4} -- count {local_count:<4} -- {comment}")

                if engine_type in ["ENGINE_CSR_INDEX"]:
                    if local_count == 1:
                        append_to_file(
                            output_file_path_vh, f"   // --  1  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}]  = {buffer_start_ops};",
                        )
                    elif local_count == 2:
                        append_to_file(output_file_path_vh, f"   // --  2  - Index_End")
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}]  = {buffer_end_ops};",
                        )
                    elif local_count == 7:
                        append_to_file(
                            output_file_path_vh, f"   // --  7  - Array_size"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}]  = {buffer_end_ops}-{buffer_start_ops};",
                        )
                elif engine_type in ["ENGINE_READ_WRITE"]:
                    if local_count == 0:
                        append_to_file(
                            output_file_path_vh, f"   // --  0  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}]  = {buffer_start_ops};",
                        )
                elif engine_type in ["ENGINE_PARALLEL_READ_WRITE"]:
                    if local_count == 1:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[0]
                        )
                        local_buffer_start_ops = print_operations_vh(local_buffer_start)
                        append_to_file(
                            output_file_path_vh, f"   // --  1  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 8:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[1]
                        )
                        local_buffer_start_ops = print_operations_vh(local_buffer_start)
                        append_to_file(
                            output_file_path_vh, f"   // --  2  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 15:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[2]
                        )
                        local_buffer_start_ops = print_operations_vh(local_buffer_start)
                        append_to_file(
                            output_file_path_vh, f"   // --  3  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 22:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[3]
                        )
                        local_buffer_start_ops = print_operations_vh(local_buffer_start)
                        append_to_file(
                            output_file_path_vh, f"   // --  4  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 29:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[4]
                        )
                        local_buffer_start_ops = print_operations_vh(local_buffer_start)
                        append_to_file(
                            output_file_path_vh, f"   // --  5  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_vh,
                            f"    graph.overlay_program[{entry_index_vh}] = {local_buffer_start_ops};",
                        )

                entry_index_vh += 1
                local_count += 1
            # elif line.startswith('//'):  # This is a comment line
            #     print(line)  # Print the comment line as is

    engine_index_vh += 1


def process_file_cpp_v2(
    template_file_path_json,
    template_file_path_ol,
    engine_template_filename_json,
    engine_template_filename_ol,
    engine_name,
):
    # Define the size of a cache line in bytes and the size of each entry
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    global entries_cpp
    global entry_index_cpp
    global engine_index_cpp
    global output_file_path_cpp
    global buffers
    global channels

    engine_type = engine_name.split("(")[0]
    detail_pattern = extract_buffer_details(engine_name)
    buffer_name, buffer_start, buffer_end = detail_pattern[0]
    buffer_start_ops = print_operations_cpp(buffer_start)
    buffer_end_ops = print_operations_cpp(buffer_end)
    buffer_key = get_key_from_value(buffers, buffer_name)
    buffer_index = get_index_from_value(buffers, buffer_name)
    local_count = 0
    filename_ol = os.path.join(template_file_path_ol, engine_template_filename_ol)
    filename_json = os.path.join(template_file_path_json, engine_template_filename_json)

    # print(f"echo {filename_ol}")
    # print(f"echo {filename_json}")

    check_and_clean_file(filename_ol)

    process_entries_json_v2(filename_ol, filename_json, channels, buffers)

    # Read the file and process entries and comments
    with open(filename_ol, "r") as file:
        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r"(0x[0-9A-Fa-f]+)(.*)", line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(
                    2
                ).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(
                    entry_index_vh, entries_per_cache_line
                )
                # append_to_file(output_file_path_vh, f"{hex_value:<10} // entry {entry_index:<4} cacheline {cache_line:<4} offset {offset:<4} -- count {local_count:<4} -- {comment}")

                if engine_type in ["ENGINE_CSR_INDEX"]:
                    if local_count == 1:
                        append_to_file(
                            output_file_path_cpp, f"   // --  1  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {buffer_start_ops};",
                        )
                    elif local_count == 2:
                        append_to_file(
                            output_file_path_cpp, f"   // --  2  - Index_End"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {buffer_end_ops};",
                        )
                    elif local_count == 7:
                        append_to_file(
                            output_file_path_cpp, f"   // --  7  - Array_size"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {buffer_end_ops}-{buffer_start_ops};",
                        )
                elif engine_type in ["ENGINE_READ_WRITE"]:
                    if local_count == 0:
                        append_to_file(
                            output_file_path_cpp, f"   // --  0  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {buffer_start_ops};",
                        )
                elif engine_type in ["ENGINE_PARALLEL_READ_WRITE"]:
                    if local_count == 1:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[0]
                        )
                        local_buffer_start_ops = print_operations_cpp(
                            local_buffer_start
                        )
                        append_to_file(
                            output_file_path_cpp, f"   // --  1  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 8:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[1]
                        )
                        local_buffer_start_ops = print_operations_cpp(
                            local_buffer_start
                        )
                        append_to_file(
                            output_file_path_cpp, f"   // --  2  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 15:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[2]
                        )
                        local_buffer_start_ops = print_operations_cpp(
                            local_buffer_start
                        )
                        append_to_file(
                            output_file_path_cpp, f"   // --  3  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 22:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[3]
                        )
                        local_buffer_start_ops = print_operations_cpp(
                            local_buffer_start
                        )
                        append_to_file(
                            output_file_path_cpp, f"   // --  4  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {local_buffer_start_ops};",
                        )
                    elif local_count == 29:
                        local_buffer_name, local_buffer_start, local_buffer_end = (
                            detail_pattern[4]
                        )
                        local_buffer_start_ops = print_operations_cpp(
                            local_buffer_start
                        )
                        append_to_file(
                            output_file_path_cpp, f"   // --  5  - Index_Start"
                        )
                        append_to_file(
                            output_file_path_cpp,
                            f"    overlay_program[{entry_index_cpp}] = {local_buffer_start_ops};",
                        )

                entry_index_cpp += 1
                local_count += 1
            # elif line.startswith('//'):  # This is a comment line
            #     print(line)  # Print the comment line as is

    engine_index_cpp += 1


# Function to parse and construct the entries with compact comments
def process_entries_json_v2(
    output_program_path_ol, source_program_path_json, channels, buffers
):

    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    total_number_entries = 0

    # print(f"echo {source_program_path_json}")

    with open(source_program_path_json, "r") as file:
        # Load the JSON data from the file
        parsed_data = json.load(file)

    for engine_name, engine_data in parsed_data.items():

        entries = engine_data["entries"]
        # Print engine name and number of entries
        if "entries" in engine_data:
            entries = engine_data["entries"]
        else:
            print(f"echo Warning: 'entries' key not found in engine_data. Skipping.")
            continue  # Skip t

        append_to_file(
            output_program_path_ol,
            f"// --------------------------------------------------------------------------------------",
        )
        append_to_file(
            output_program_path_ol,
            f"// Engine: {engine_name}, Number of entries: {len(entries)}",
        )
        append_to_file(
            output_program_path_ol,
            f"// --------------------------------------------------------------------------------------",
        )
        lookup_tables = {
            **engine_data.get("type_memory_cmd", {}),
            **engine_data.get("type_ALU_operation", {}),
            **engine_data.get("type_filter_operation", {}),
        }

        for key in entries:
            cache_line, offset = calculate_cache_info(
                total_number_entries, entries_per_cache_line
            )
            total_number_entries += 1
            entry = entries[key]
            entry_value = 0

            bits_prev = 0
            comment_details = []  # List to store details for the comment

            # Start from LSB to MSB
            for param in entry:
                if "bits" not in entry[param] and "value" not in entry[param]:
                    continue  # Skip this iteration if the key should be ignored or if "bits"/"value" are missing
    
                bits = int(entry[param]["bits"])
                value = entry[param]["value"]
                original_value = value
                original_flag = 0

                # Replace symbolic values with their corresponding numeric values
                if isinstance(value, str) and not value.startswith("0x"):
                    original_flag = 1
                    if param in ["id_buffer", "if_id_buffer", "else_id_buffer"] :
                        buffer_index = get_buffer_index(buffers, value)
                        if buffer_index is not None:
                            if buffer_index == 0:
                                value = 0
                            else:
                                value = 1 << (buffer_index - 1)
                            # print(f"echo id_buffer {0} {1}", value, bits_prev)
                        else:
                            value = 0
                    elif param == "id_channel" and value in channels:
                        channel_index = get_channels_index(channels, value)
                        if channel_index is not None:
                            value = 1 << channel_index
                    else:
                        value = lookup_tables.get(value, value)

                # Convert to hex integer
                if isinstance(value, str) and value.startswith("0x"):
                    value = int(value, 16)
                else:
                    value = int(value)

                # Shift and OR the value
                value <<= bits_prev
                entry_value |= value

                # Calculate the bit range and format the value for the current parameter
                bit_range = f"{bits_prev}:{bits_prev + bits - 1}"
                if original_flag:
                    formatted_value = original_value
                else:
                    formatted_value = (
                        f"0x{value >> bits_prev:0{bits//4}X}"  # Short hex value
                    )

                if bits == 1 and isinstance(formatted_value, int):
                    formatted_value = "True" if formatted_value == 1 else "False"

                comment_details.append(f"{param}[{bit_range}]={formatted_value}")
                bits_prev += bits

            # Convert to hexadecimal format
            entry_hex = f"0x{entry_value:08X}"
            # Create the compact comment
            comment = (
                f" // {key:10} cacheline[{cache_line:3}][{offset:2}] <{bits_prev:2}b>: "
                + " || ".join(comment_details)
            )
            append_to_file(output_program_path_ol, f"{entry_hex}{comment}")
    append_to_file(
        output_program_path_ol,
        f"// --------------------------------------------------------------------------------------",
    )
    append_to_file(
        output_program_path_ol, f"// Number of entries {total_number_entries}"
    )


# Function to parse and construct the entries with compact comments
def process_entries_json(output_program_path_ol, source_program_path_json):

    global topology
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE
    total_number_entries = 0

    with open(source_program_path_json, "r") as file:
        # Load the JSON data from the file
        parsed_data = json.load(file)

    for engine_name, engine_data in parsed_data.items():

        entries = engine_data["entries"]
        # Print engine name and number of entries

        append_to_file(
            output_program_path_ol,
            f"// --------------------------------------------------------------------------------------",
        )
        append_to_file(
            output_program_path_ol,
            f"// Engine: {engine_name}, Number of entries: {len(entries)}",
        )
        append_to_file(
            output_program_path_ol,
            f"// --------------------------------------------------------------------------------------",
        )
        lookup_tables = {
            **engine_data.get("type_memory_cmd", {}),
            **engine_data.get("type_ALU_operation", {}),
            **engine_data.get("type_filter_operation", {}),
        }

        for key in entries:
            cache_line, offset = calculate_cache_info(
                total_number_entries, entries_per_cache_line
            )
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
                if original_flag:
                    formatted_value = original_value
                else:
                    formatted_value = f"0x{value >> bits_prev}"  # Short hex value

                if bits == 1 and isinstance(formatted_value, int):
                    formatted_value = "True" if formatted_value == 1 else "False"

                comment_details.append(f"{param}[{bit_range}]={formatted_value}")
                bits_prev += bits

            # Convert to hexadecimal format
            entry_hex = f"0x{entry_value:08X}"
            # Create the compact comment
            comment = (
                f" // {key:10} cacheline[{cache_line:3}][{offset:2}] <{bits_prev:2}b>: "
                + " || ".join(comment_details)
            )
            append_to_file(output_program_path_ol, f"{entry_hex}{comment}")
    append_to_file(
        output_program_path_ol,
        f"// --------------------------------------------------------------------------------------",
    )
    append_to_file(output_program_path_ol, f"// -->  Load.{topology}  <-- ")
    append_to_file(
        output_program_path_ol, f"// Number of entries {total_number_entries}"
    )


append_to_file(output_file_path_cpp, '#include "glayenv.hpp"')
append_to_file(
    output_file_path_cpp,
    f"void GLAYxrtBufferHandlePerKernel::mapGLAYOverlayProgramBuffers{ALGORITHM_NAME}(struct GraphCSR *graph)",
)
append_to_file(output_file_path_cpp, "{")

# Get engine IDs and pad accordingly
CU_BUNDLES_ENGINE_CONFIG_ARRAY = [
    pad_lane(
        [
            pad_data([get_engine_id(engine) for engine in lane], NUM_ENGINES_MAX)
            for lane in bundle
        ]
    )
    for bundle in CU_BUNDLES_CONFIG_ARRAY
]

append_to_file(output_file_path_cpp, "}")
append_to_file(
    output_file_path_cpp,
    "// --------------------------------------------------------------------------------------",
)
append_to_file(output_file_path_cpp, f"// -->  CPP.{topology}  <-- ")
append_to_file(output_file_path_cpp, f"// Number of entries {entry_index_cpp}")

append_to_file(
    output_file_path_ol,
    "// --------------------------------------------------------------------------------------",
)
append_to_file(output_file_path_ol, f"// -->  Template.{topology}  <-- ")
append_to_file(output_file_path_ol, f"// Number of entries {entry_index}")

append_to_file(
    output_file_path_vh,
    "// --------------------------------------------------------------------------------------",
)
append_to_file(output_file_path_vh, f"// -->  Benchmark.{topology}  <-- ")
append_to_file(output_file_path_vh, f"// Number of entries {entry_index_vh}")

# Write the combined data to a new file
with open(output_file_path_json, "w") as f:
    json.dump(combined_engine_template_json, f, indent=4)

# process_entries_json(output_program_path_ol, source_program_path_json)
process_entries_json_v2(
    output_program_path_ol, source_program_path_json, channels, buffers
)

print(f"export NUM_ENTRIES={entry_index_vh}")
