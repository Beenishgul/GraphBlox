#!/bin/bash

# Function to build with parameters
build_with_params() {
    local alg_index=$1
    local arch=$2
    local cap=$3
    local num_kernels=$4
    local target=$5

    # Constructing the parameter list
    local params="ALGORITHMS=$alg_index ARCHITECTURE=$arch CAPABILITY=$cap XILINX_NUM_KERNELS=$num_kernels TARGET=$target"

    # Define the log file name
    local log_file="algorithm_${alg_index}_${cap}.log"

    # Run make commands with nohup and output redirection
    nohup bash -c "make $params && make build-hw $params" > "$log_file" 2>&1 &
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <Algorithm Index> <Architecture> <Capability> <Number of Kernels> <Target>"
    exit 1
fi

# Call the build function with command line arguments
build_with_params "$1" "$2" "$3" "$4" "$5"

echo "xlcbin $3 $2 algorithm is being processed in the background."