#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set ACTIVE_PARAMS_TCL_DIR                  [lindex $argv 0]

source ${ACTIVE_PARAMS_TCL_DIR}
# =========================================================

if {${VIVADO_GUI_FLAG} == "YES"} {
  start_gui
}

open_project ${KERNEL_PROJECT_PKG_XPR} 

# set runlist_impl  [get_runs impl*]
# set runlist_synth [get_runs synth*]

# reset_run synth_1
# launch_runs synth_1
# wait_on_runs synth_1

reset_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_runs impl_1

# Optionally, you can also close the project after completion
close_project
# foreach impl_strategy [list [lindex [get_runs impl*] ${XILINX_IMPL_STRATEGY}]] { 
#   reset_run $impl_strategy
#   launch_runs $impl_strategy -to_step write_bitstream -jobs $XILINX_JOBS_STRATEGY
#   wait_on_runs $impl_strategy 
# }