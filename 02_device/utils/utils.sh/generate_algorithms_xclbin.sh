#!/bin/bash

# Define an array of algorithm indices to be processed
# Add or remove indices as needed
algorithm_indices=(0 1 5 6 8)

# Loop through the specified algorithm indices
for ALGORITHM_INDEX in "${algorithm_indices[@]}"
do
    # Export ALGORITHMS variable
    export ALGORITHMS=$ALGORITHM_INDEX
    export ARCHITECTURE=GLay
    export CAPABILITY=Single
    export XILINX_NUM_KERNELS=8
    export TARGET=hw

    # Execute make and make build-hw in the background
    # nohup ensures the process is not killed if the terminal is closed
    # & puts the process in the background
    # Output is redirected to a log file for each algorithm
    nohup make && make build-hw > "algorithm_$ALGORITHM_INDEX.log" 2>&1 &
done

echo "Selected Single GLay algorithms are being processed in the background."

    # Export ALGORITHMS variable
    export ALGORITHMS=0
    export ARCHITECTURE=GLay
    export CAPABILITY=Lite
    export XILINX_NUM_KERNELS=4
    export TARGET=hw

    # Execute make and make build-hw in the background
    # nohup ensures the process is not killed if the terminal is closed
    # & puts the process in the background
    # Output is redirected to a log file for each algorithm
    nohup make && make build-hw > "algorithm_$ALGORITHM_INDEX.log" 2>&1 &

echo "Selected Lite GLay algorithms are being processed in the background."

    # Export ALGORITHMS variable
    export ALGORITHMS=0
    export ARCHITECTURE=GLay
    export CAPABILITY=Full
    export XILINX_NUM_KERNELS=2
    export TARGET=hw

    # Execute make and make build-hw in the background
    # nohup ensures the process is not killed if the terminal is closed
    # & puts the process in the background
    # Output is redirected to a log file for each algorithm
    nohup make && make build-hw > "algorithm_$ALGORITHM_INDEX.log" 2>&1 &

echo "Selected Full GLay algorithms are being processed in the background."