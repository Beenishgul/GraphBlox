#!/usr/bin/env python3

import shutil
import subprocess
import os
import fnmatch
import json
import shutil
import glob


def read_gitignore_patterns(gitignore_path):
    patterns = []
    with open(gitignore_path, "r") as file:
        for line in file:
            line = line.strip()
            if line and not line.startswith("#"):
                patterns.append(line)
    return patterns


def ignore_subdirectories(directory, subdirectories, patterns):
    ignored = []
    for subdir in subdirectories:
        # Check against only the basename of the directory
        if any(fnmatch.fnmatch(subdir, pattern) for pattern in patterns):
            # print(f"Ignoring {subdir}")  # Debugging output
            ignored.append(subdir)
    return ignored


def generate_topology_file(file_path, params, ch_property):
    # Step 1: Read the JSON file
    with open(file_path, "r") as file:
        tolopogy = json.load(file)

    (
        algorithm,
        architecture,
        capability,
        num_kernels,
        num_kernel_cu,
        target,
        cache_properties,
        synth_strategy,
        frequency,
    ) = params

    tolopogy["cache_properties"]["channel_0"] = cache_properties
    tolopogy["ch_properties"]["channel_0"] = ch_property[0]
    tolopogy["ch_properties"]["channel_1"] = ch_property[1]
    tolopogy["cu_properties"]["synth_strategy"] = str(synth_strategy)
    tolopogy["cu_properties"]["num_kernels"] = str(num_kernels)
    tolopogy["cu_properties"]["num_kernel_cu"] = str(num_kernel_cu)
    tolopogy["cu_properties"]["frequency"] = str(frequency)

    # Any other modifications you need to make can be done in a similar manner

    # Step 3: Write the updated JSON tolopogy back to the file
    with open(file_path, "w") as file:
        json.dump(tolopogy, file, indent=4)  # Using indent for pretty printing


# def ignore_subdirectories(directory, subdirectories):
#     return [d for d in subdirectories if os.path.join(directory, d) in destination_directories]


def copy_directory(source, destination, ignore_patterns):
    try:
        shutil.copytree(
            source,
            destination,
            ignore=lambda src, names: ignore_subdirectories(
                src, names, ignore_patterns
            ),
        )
        print(f"Copied to: {destination}")
    except FileExistsError:
        print(f"Directory {destination} already exists.")


def construct_make_arguments(params):
    (
        algorithm,
        architecture,
        capability,
        num_kernels,
        num_kernel_cu,
        target,
        cache_properties,
        synth_strategy,
        frequency,
    ) = params
    # Construct the common part of the make command with parameters
    common_args = f"ALGORITHMS={algorithm} ARCHITECTURE={architecture} CAPABILITY={capability} XILINX_NUM_KERNELS={num_kernels} TARGET={target} XILINX_IMPL_STRATEGY={synth_strategy} SYSTEM_CACHE_SIZE_B={cache_properties[0]} DESIGN_FREQ_HZ={frequency}"
    return common_args


def run_make_in_parallel(destination_directory, params):
    # Construct the make commands
    (
        algorithm,
        architecture,
        capability,
        num_kernels,
        num_kernel_cu,
        target,
        cache_properties,
        synth_strategy,
        frequency,
    ) = params

    common_args = construct_make_arguments(params)

    make_commands = f"cd {destination_directory} && make {common_args} && make build-hw {common_args} && make gen-xclbin-zip {common_args}"

    # Define the log file path
    log_file = os.path.join(
        destination_directory,
        f"make_{algorithm}_{architecture}_{capability}_{num_kernels}_{num_kernel_cu}_{target}_{cache_properties[0]}_{synth_strategy}_{frequency}Hz.log",
    )

    # Run the make commands in its own shell and redirect output to the log file
    with open(log_file, "w") as file:
        subprocess.Popen(
            ["nohup", "bash", "-c", make_commands],
            stdout=file,
            stderr=subprocess.STDOUT,
            preexec_fn=os.setpgrp,
        )


def run_make_in_serial(destination_directory, params):

    (
        algorithm,
        architecture,
        capability,
        num_kernels,
        num_kernel_cu,
        target,
        cache_properties,
        synth_strategy,
        frequency,
    ) = params

    common_args = construct_make_arguments(params)

    make_commands = f"cd {destination_directory} && make {common_args} && make build-hw {common_args} && make gen-xclbin-zip {common_args}"

    # Define the log file path
    log_file = os.path.join(
        destination_directory,
        f"make_{algorithm}_{architecture}_{capability}_{num_kernels}_{num_kernel_cu}_{target}_{cache_properties[0]}_{synth_strategy}_{frequency}Hz.log",
    )

    try:
        process = subprocess.Popen(["bash", "-c", make_commands], preexec_fn=os.setpgrp)
        process.wait()  # Wait for the command to complete
        if process.returncode != 0:
            raise Exception(
                f"ERROR: Command failed with return code {process.returncode}"
            )
        print(f"MSG: Successfully completed: {make_commands}")
    except Exception as e:
        print(e)
        # Here you can handle the failure, e.g., by logging it, but the script will continue to the next command.


# Example Usage
base_directory = os.path.abspath(".")  # Current directory
source_directory = base_directory
gitignore_path = os.path.join(source_directory, ".gitignore")
ignore_patterns = read_gitignore_patterns(gitignore_path)

# Parameters for different algorithm configurations
algorithms = [
    # Format: (algorithm, architecture, capability, Number of Kernels, cache_properties[l2_size, l2_num_ways, l2_ram, l2_ctrl, l1_size, l1_num_ways, l1_buffer, l1_ram], synth_strategy, frequency)
    # (
    #     1,
    #     "GLay",
    #     "Single",
    #     1,
    #     4,
    #     "hw",
    #     ["1048576", "4", "URAM", "0", "512", "1", "8", "BRAM"],
    #     1,
    #     300000000,
    # ),
    (
        1,
        "GLay",
        "Single",
        1,
        1,
        "hw",
        ["1048576", "4", "URAM", "0", "512", "1", "8", "BRAM"],
        1,
        300000000,
    ),
    (
        1,
        "GLay",
        "Single",
        1,
        2,
        "hw",
        ["1048576", "4", "URAM", "0", "512", "1", "8", "BRAM"],
        1,
        300000000,
    ),
    (
        1,
        "GLay",
        "Single",
        1,
        4,
        "hw",
        ["1048576", "4", "URAM", "0", "512", "1", "8", "BRAM"],
        1,
        300000000,
    ),
    (
        1,
        "GLay",
        "Single",
        1,
        8,
        "hw",
        ["1048576", "4", "URAM", "0", "512", "1", "8", "BRAM"],
        1,
        300000000,
    ),
    (
        1,
        "GLay",
        "Single",
        1,
        16,
        "hw",
        ["1048576", "4", "URAM", "0", "512", "1", "8", "BRAM"],
        1,
        300000000,
    ),
    (
        1,
        "GLay",
        "Single",
        1,
        20,
        "hw",
        ["1048576", "4", "URAM", "0", "512", "1", "8", "BRAM"],
        1,
        300000000,
    ),
    (
        1,
        "GLay",
        "Single",
        1,
        32,
        "hw",
        ["2097152", "4", "URAM", "0", "512", "1", "8", "BRAM"],
        1,
        300000000,
    ),
    # (
    #     1,
    #     "GLay",
    #     "Single",
    #     1,
    #     "hw",
    #     ["4194304", "4", "URAM", "0", "512", "1", "8", "BRAM"],
    #     1,
    #     300000000,
    # ),
    # (5, "GLay", "Single", 8, "hw", 65536, 1),
    # (6, "GLay", "Single", 8, "hw", 65536, 1),
    # (8, "GLay", "Single", 8, "hw", 65536, 1),
    # (0, "GLay", "Lite", 4, "hw", 131072, 1),
    # (0, "GLay", "Full", 2, "hw", 262144, 1),
    # (0, "GLay", "Lite", 4, "hw", 131072, 2),
    # (0, "GLay", "Full", 2, "hw", 131072, 2),
    # Add more tuples here for other algorithm configurations as needed
]

ch_properties = [
    # Format: (address_width_be, data_width_be, axi_port_full_be, l2_type, address_width_mid, data_width_mid, l1_type, address_width_fe, data_width_fe)
    # (
    #     ["33", "32", "0", "0", "33", "32", "2", "33", "32"],
    #     ["33", "32", "0", "0", "33", "32", "3", "33", "32"],
    # ),
    (
        ["33", "512", "0", "1", "33", "32", "2", "33", "32"],
        ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    ),
    (
        ["33", "512", "0", "1", "33", "32", "2", "33", "32"],
        ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    ),
    (
        ["33", "512", "0", "1", "33", "32", "2", "33", "32"],
        ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    ),
    (
        ["33", "512", "0", "1", "33", "32", "2", "33", "32"],
        ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    ),
    (
        ["33", "512", "0", "1", "33", "32", "2", "33", "32"],
        ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    ),
    (
        ["33", "512", "0", "1", "33", "32", "2", "33", "32"],
        ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    ),
    (
        ["33", "512", "0", "1", "33", "32", "2", "33", "32"],
        ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    ),
    # (
    #     ["33", "512", "0", "1", "33", "32", "4", "33", "32"],
    #     ["33", "512", "0", "2", "33", "32", "3", "33", "32"],
    # ),
    # (5, "GLay", "Single", 8, "hw", 65536, 1),
    # (6, "GLay", "Single", 8, "hw", 65536, 1),
    # (8, "GLay", "Single", 8, "hw", 65536, 1),
    # (0, "GLay", "Lite", 4, "hw", 131072, 1),
    # (0, "GLay", "Full", 2, "hw", 262144, 1),
    # (0, "GLay", "Lite", 4, "hw", 131072, 2),
    # (0, "GLay", "Full", 2, "hw", 131072, 2),
    # Add more tuples here for other algorithm configurations as needed
]


# List of destination directories to be ignored during copy
destination_directories = [
    os.path.join(
        base_directory,
        f"alg_{algorithm}_{architecture}_{capability}_{num_kernels}_{num_kernel_cu}_{target}_{cache_properties[0]}_{synth_strategy}_{frequency}Hz",
    )
    for algorithm, architecture, capability, num_kernels, num_kernel_cu,target, cache_properties, synth_strategy, frequency in algorithms
]

# Create and copy to each destination directory
for destination_directory in destination_directories:
    if not os.path.exists(destination_directory):
        copy_directory(source_directory, destination_directory, ignore_patterns)

# Run make in parallel for each algorithm configuration
for params, ch_property in zip(algorithms, ch_properties):
    (
        algorithm,
        architecture,
        capability,
        num_kernels,
        num_kernel_cu,
        target,
        cache_properties,
        synth_strategy,
        frequency,
    ) = params
    destination_directory = os.path.join(
        base_directory,
        f"alg_{algorithm}_{architecture}_{capability}_{num_kernels}_{num_kernel_cu}_{target}_{cache_properties[0]}_{synth_strategy}_{frequency}Hz",
    )
    topology_directory = os.path.join(
        destination_directory,
        "02_device",
        "ol",
        architecture,
        capability,
        "topology.json",
    )
    xclbin_directory = os.path.join(
        destination_directory, "02_device", "utils", "utils.xclbin", "file.zip"
    )
    print(f"Start synthesis with parameters: {params}")
    generate_topology_file(topology_directory, params, ch_property)
    run_make_in_serial(destination_directory, params)

for params, ch_property in zip(algorithms, ch_properties):
    (
        algorithm,
        architecture,
        capability,
        num_kernels,
        num_kernel_cu,
        target,
        cache_properties,
        synth_strategy,
        frequency,
    ) = params
    destination_directory = os.path.join(
        base_directory,
        f"alg_{algorithm}_{architecture}_{capability}_{num_kernels}_{num_kernel_cu}_{target}_{cache_properties[0]}_{synth_strategy}_{frequency}Hz",
    )
    xclbin_from_directory = os.path.join(
        destination_directory, "02_device", "utils", "utils.xclbin"
    )
    xclbin_to_directory = os.path.join(
        base_directory, "02_device", "utils", "utils.xclbin"
    )

    # Ensure the target directory exists
    os.makedirs(os.path.dirname(xclbin_to_directory), exist_ok=True)

    # Find all zip files in the source directory
    zip_files = glob.glob(os.path.join(xclbin_from_directory, "*.zip"))

    # Copy each found zip file with appended details
    for zip_file in zip_files:
        filename = os.path.basename(zip_file)
        new_filename = f"{os.path.splitext(filename)[0]}_{algorithm}_{architecture}_{capability}_{num_kernels}_{num_kernel_cu}_{target}_{cache_properties[0]}_{synth_strategy}_{frequency}Hz.zip"
        new_filepath = os.path.join(xclbin_to_directory, new_filename)
        try:
            shutil.copy(zip_file, new_filepath)
            print(f"Successfully copied and renamed {zip_file} to {new_filepath}")
        except Exception as e:
            print(f"Failed to copy and rename {zip_file} to {new_filepath}. Error: {e}")
