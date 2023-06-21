#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set project_var         [lindex $argv 0]
set gui_flag            [lindex $argv 1]
# =========================================================

# =========================================================
# Mode: - behavioral, 
#       - post-synthesis, post-implementation
#         * Type : functional, timing
# =========================================================
# Step 1: Open vivado project and add design sources
# =========================================================
if {${gui_flag} == "YES"} {
  start_gui
}

open_project $project_var 
# =========================================================

update_compile_order -fileset sources_1

launch_simulation -simset sim_1 -mode behavioral

log_wave -r *
run -all