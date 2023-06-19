#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set project_var         [lindex $argv 0]
set kernel_name         [lindex $argv 1]
set app_directory       [lindex $argv 2]
set xilinx_directory    [lindex $argv 3]
set scripts_directory   [lindex $argv 4]
set sim_dir          ${app_directory}/${xilinx_directory}
set log_file         ${sim_dir}/generate_${kernel_name}_sim.log
# =========================================================

# =========================================================
# Mode: - behavioral, 
#       - post-synthesis, post-implementation
#         * Type : functional, timing
# =========================================================
# Step 1: Open vivado project and add design sources
# =========================================================
open_project $project_var 
# =========================================================

update_compile_order -fileset sources_1

launch_simulation -simset sim_1 -mode behavioral

run -all

start_gui