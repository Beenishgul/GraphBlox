#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set VIVADO_BUILD_DIR         [lindex $argv 0]
set VIVADO_GUI_FLAG            [lindex $argv 1]
set XILINX_JOBS_STRATEGY       [lindex $argv 2]
# =========================================================

if {${VIVADO_GUI_FLAG} == "YES"} {
  start_gui
}

open_project ${VIVADO_BUILD_DIR} 

set runlist_synth [get_runs synth*]

reset_run synth_1
# set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.INCREMENTAL_MODE aggressive [get_runs synth_1]
launch_runs synth_1 -jobs ${XILINX_JOBS_STRATEGY}
wait_on_runs synth_1

# if {[regexp -- impl_1 $runlist]} {reset_run impl_1} else {create_run impl_2 -parent_run synth_1 -flow {Vivado Implementation 2022.2}}
# launch_runs impl_1
# wait_on_runs impl_1