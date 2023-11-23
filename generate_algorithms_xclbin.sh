#!/bin/bash

# Define an array of algorithm indices to be processed
algorithm_indices=(0 1 5 6 8)

# Function to build with parameters
build_with_params() {
    local alg_index=$1
    local arch=$2
    local cap=$3
    local num_kernels=$4
    local target=$5

    # Constructing the parameter list
    local params="ALGORITHMS=$alg_index ARCHITECTURE=$arch CAPABILITY=$cap XILINX_NUM_KERNELS=$num_kernels TARGET=$target"

    # Execute make with parameters, then make build-hw in the background
    echo "nohup make $params && make build-hw $params > "algorithm_${alg_index}_${cap}.log" 2>&1 &"
}

# Loop through the specified algorithm indices
for ALGORITHM_INDEX in "${algorithm_indices[@]}"
do
    build_with_params $ALGORITHM_INDEX GLay Single 8 hw
done

# echo "xlcbin Single GLay algorithms are being processed in the background."

# Single run with Lite capability
build_with_params 0 GLay Lite 4 hw
# echo "xlcbin Lite GLay algorithm is being processed in the background."

# Single run with Full capability
build_with_params 0 GLay Full 2 hw
# echo "xlcbin Full GLay algorithm is being processed in the background."
