#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set VIVADO_BUILD_DIR         [lindex $argv 0]
set VIVADO_GUI_FLAG          [lindex $argv 1]
set XILINX_IMPL_STRATEGY     [lindex $argv 2]
set XILINX_JOBS_STRATEGY     [lindex $argv 3]
# =========================================================

if {${VIVADO_GUI_FLAG} == "YES"} {
  start_gui
}

open_project ${VIVADO_BUILD_DIR} 

# set runlist_impl  [get_runs impl*]
# set runlist_synth [get_runs synth*]

# reset_run synth_1
# launch_runs synth_1
# wait_on_runs synth_1

# reset_run impl_1
# launch_runs impl_1 -to_step write_bitstream
# wait_on_runs impl_1

foreach impl_strategy [list [lindex [get_runs impl*] ${XILINX_IMPL_STRATEGY}]] { 
  reset_run $impl_strategy
  launch_runs $impl_strategy -to_step write_bitstream -jobs $XILINX_JOBS_STRATEGY
  wait_on_runs $impl_strategy 
}