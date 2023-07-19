#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set PARAMS_TCL_DIR                  [lindex $argv 0]

source ${PARAMS_TCL_DIR}
# =========================================================

if {${VIVADO_GUI_FLAG} == "YES"} {
  start_gui
}

open_project ${KERNEL_PROJECT_PKG_XPR} 

set runlist_synth [get_runs synth*]

reset_run synth_1
# set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.INCREMENTAL_MODE aggressive [get_runs synth_1]
launch_runs synth_1 -jobs ${XILINX_JOBS_STRATEGY}
wait_on_runs synth_1

# if {[regexp -- impl_1 $runlist]} {reset_run impl_1} else {create_run impl_2 -parent_run synth_1 -flow {Vivado Implementation 2022.2}}
# launch_runs impl_1
# wait_on_runs impl_1