#!/usr/bin python3

import shutil
import subprocess
import os

def ignore_subdirectories(directory, subdirectories):
    return [d for d in subdirectories if os.path.join(directory, d) in destination_directories]

def copy_directory(source, destination):
    try:
        shutil.copytree(source, destination, ignore=lambda src, names: ignore_subdirectories(src, names))
        print(f"Copied to: {destination}")
    except FileExistsError:
        print(f"Directory {destination} already exists.")

def run_make_in_parallel(directory, alg_index, arch, cap, num_kernels, target, cache, freq, strategy):
    # Construct the make commands
    make_commands = f"cd {directory} && make ALGORITHMS={alg_index} ARCHITECTURE={arch} CAPABILITY={cap} XILINX_NUM_KERNELS={num_kernels} TARGET={target} XILINX_IMPL_STRATEGY={strategy} SYSTEM_CACHE_SIZE_B={cache} DESIGN_FREQ_HZ={freq} && make build-hw ALGORITHMS={alg_index} ARCHITECTURE={arch} CAPABILITY={cap} XILINX_NUM_KERNELS={num_kernels} TARGET={target} XILINX_IMPL_STRATEGY={strategy} SYSTEM_CACHE_SIZE_B={cache} DESIGN_FREQ_HZ={freq}"
    
    # Define the log file path
    log_file = os.path.join(directory, f"make_{alg_index}_{arch}_{cap}_{num_kernels}_{target}_{cache}_{freq}Hz_{strategy}.log")
    
    # Run the make commands in its own shell and redirect output to the log file
    with open(log_file, "w") as file:
        subprocess.Popen(["nohup", "bash", "-c", make_commands], stdout=file, stderr=subprocess.STDOUT, preexec_fn=os.setpgrp)

base_directory = os.path.abspath('.')  # Current directory
source_directory = base_directory

# Parameters for different algorithm configurations
algorithms = [
    # Format: (Algorithm Index, Architecture, Capability, Number of Kernels, Target)
    (0, "GLay", "Single", 8, "hw", 131072, 240000000, 1),
    (1, "GLay", "Single", 8, "hw", 131072, 240000000, 1),
    (5, "GLay", "Single", 8, "hw", 131072, 240000000, 1),
    (6, "GLay", "Single", 8, "hw", 131072, 240000000, 1),
    (8, "GLay", "Single", 8, "hw", 131072, 240000000, 1),
    (0, "GLay", "Lite", 4, "hw", 131072, 240000000, 1),
    (0, "GLay", "Full", 2, "hw", 131072, 240000000, 1),
    (0, "GLay", "Lite", 4, "hw", 131072, 240000000, 2),
    (0, "GLay", "Full", 2, "hw", 131072, 240000000, 2),
    # Add more tuples here for other algorithm configurations as needed
]

# List of destination directories to be ignored during copy
destination_directories = [
    os.path.join(base_directory, f"alg_{alg_index}_{arch}_{cap}_{num_kernels}_{target}_{cache}_{freq}Hz_{strategy}")
    for alg_index, arch, cap, num_kernels, target, cache, freq, strategy in algorithms
]

# Create and copy to each destination directory
for destination in destination_directories:
    if not os.path.exists(destination):
        copy_directory(source_directory, destination)

# Run make in parallel for each algorithm configuration
for alg in algorithms:
    alg_index, arch, cap, num_kernels, target, cache, freq, strategy  = alg
    destination_directory = os.path.join(base_directory, f"alg_{alg_index}_{arch}_{cap}_{num_kernels}_{target}_{cache}_{freq}Hz_{strategy}")
    run_make_in_parallel(destination_directory, alg_index, arch, cap, num_kernels, target, cache, freq, strategy )
    print(f"Started processing in parallel with parameters: {alg}")
