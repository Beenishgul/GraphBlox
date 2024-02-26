#!/usr/bin/env python3

import shutil
import subprocess
import os
import fnmatch
import json

def read_gitignore_patterns(gitignore_path):
    patterns = []
    with open(gitignore_path, 'r') as file:
        for line in file:
            line = line.strip()
            if line and not line.startswith('#'):
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

def generate_topology_file(file_path, params):
    # Step 1: Read the JSON file
    with open(file_path, 'r') as file:
        tolopogy = json.load(file)

    (algorithm, architecture, capability, num_kernels, target, cache_properties, synth_strategy) = params

    tolopogy['cache_properties']['channel_0'] = cache_properties   
    tolopogy['cu_properties']['synth_strategy']  = str(synth_strategy) 
    tolopogy['cu_properties']['num_kernels']  = str(num_kernels)    

    # Any other modifications you need to make can be done in a similar manner

    # Step 3: Write the updated JSON tolopogy back to the file
    with open(file_path, 'w') as file:
        json.dump(tolopogy, file, indent=4)  # Using indent for pretty printing

# def ignore_subdirectories(directory, subdirectories):
#     return [d for d in subdirectories if os.path.join(directory, d) in destination_directories]

def copy_directory(source, destination, ignore_patterns):
    try:
        shutil.copytree(source, destination, ignore=lambda src, names: ignore_subdirectories(src, names, ignore_patterns))
        print(f"Copied to: {destination}")
    except FileExistsError:
        print(f"Directory {destination} already exists.")

def run_make_in_parallel(destination_directory, params):
    # Construct the make commands
    (algorithm, architecture, capability, num_kernels, target, cache_properties, synth_strategy) = params

    make_commands = f"cd {destination_directory} && make ALGORITHMS={algorithm} ARCHITECTURE={architecture} CAPABILITY={capability} XILINX_NUM_KERNELS={num_kernels} TARGET={target} XILINX_IMPL_STRATEGY={synth_strategy} SYSTEM_CACHE_SIZE_B={cache_properties[0]} && make build-hw ALGORITHMS={algorithm} ARCHITECTURE={architecture} CAPABILITY={capability} XILINX_NUM_KERNELS={num_kernels} TARGET={target} XILINX_IMPL_STRATEGY={synth_strategy} SYSTEM_CACHE_SIZE_B={cache_properties[0]} && make gen-xclbin-zip"
    
    # Define the log file path
    log_file = os.path.join(destination_directory, f"make_{algorithm}_{architecture}_{capability}_{num_kernels}_{target}_{cache_properties[0]}_{synth_strategy}.log")
    
    # Run the make commands in its own shell and redirect output to the log file
    with open(log_file, "w") as file:
        subprocess.Popen(["nohup", "bash", "-c", make_commands], stdout=file, stderr=subprocess.STDOUT, preexec_fn=os.setpgrp)

def run_make_in_serial(destination_directory, params):

    (algorithm, architecture, capability, num_kernels, target, cache_properties, synth_strategy) = params
    # Construct the make commands
    make_commands = f"cd {destination_directory} && make ALGORITHMS={algorithm} ARCHITECTURE={architecture} CAPABILITY={capability} XILINX_NUM_KERNELS={num_kernels} TARGET={target} XILINX_IMPL_STRATEGY={synth_strategy} SYSTEM_CACHE_SIZE_B={cache_properties[0]} && make build-hw ALGORITHMS={algorithm} ARCHITECTURE={architecture} CAPABILITY={capability} XILINX_NUM_KERNELS={num_kernels} TARGET={target} XILINX_IMPL_STRATEGY={synth_strategy} SYSTEM_CACHE_SIZE_B={cache_properties[0]} && make gen-xclbin-zip"
    
    # Define the log file path
    log_file = os.path.join(destination_directory, f"make_{algorithm}_{architecture}_{capability}_{num_kernels}_{target}_{cache_properties[0]}_{synth_strategy}.log")
    
    # Run the make commands in its own shell and redirect output to the log file
    with open(log_file, "w") as file:
        process = subprocess.Popen(["bash", "-c", make_commands], stdout=file, stderr=subprocess.STDOUT, preexec_fn=os.setpgrp)
        process.wait()  # Wait for the command to complete

# Example Usage
base_directory   = os.path.abspath('.')  # Current directory
source_directory = base_directory
gitignore_path   = os.path.join(source_directory, '.gitignore')
ignore_patterns  = read_gitignore_patterns(gitignore_path)

# Parameters for different algorithm configurations
algorithms = [
    # Format: (algorithm, architecture, capability, Number of Kernels, synth_strategy, cache_properties)
    (1, "GLay", "Single", 1, "hw", ["32768",     "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
    (1, "GLay", "Single", 1, "hw", ["65536",     "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
    (1, "GLay", "Single", 1, "hw", ["131072",    "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
    (1, "GLay", "Single", 1, "hw", ["262144",    "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
    (1, "GLay", "Single", 1, "hw", ["524288",    "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
    (1, "GLay", "Single", 1, "hw", ["1048576",   "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
    (1, "GLay", "Single", 1, "hw", ["2097152",   "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
    (1, "GLay", "Single", 1, "hw", ["4194304",   "4", "URAM",      "0", "512",  "1", "8", "BRAM"], 1),
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
    os.path.join(base_directory, f"alg_{algorithm}_{architecture}_{capability}_{num_kernels}_{target}_{cache_properties[0]}_{synth_strategy}")
    for algorithm, architecture, capability, num_kernels, target, cache_properties, synth_strategy in algorithms
]

# Create and copy to each destination directory
for destination_directory in destination_directories:
    if not os.path.exists(destination_directory):
        copy_directory(source_directory, destination_directory, ignore_patterns)

# Run make in parallel for each algorithm configuration
for params in algorithms:
    (algorithm, architecture, capability, num_kernels, target, cache_properties, synth_strategy) = params
    destination_directory = os.path.join(base_directory, f"alg_{algorithm}_{architecture}_{capability}_{num_kernels}_{target}_{cache_properties[0]}_{synth_strategy}")
    topology_directory = os.path.join(destination_directory, "02_device", "ol", architecture, capability,"topology.json")
    generate_topology_file(topology_directory, params)
    run_make_in_serial(destination_directory, params)
    print(f"Started processing in parallel with parameters: {alg}")
