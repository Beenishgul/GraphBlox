#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set project_var         [lindex $argv 0]
set gui_flag            [lindex $argv 1]
# =========================================================

if {${gui_flag} == "YES"} {
  start_gui
}

open_project $project_var 

set runlist_impl  [get_runs impl*]
set runlist_synth [get_runs synth*]

# reset_run synth_1
# launch_runs synth_1
# wait_on_runs synth_1

set_property incremental_checkpoint.directive TimingClosure [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream
wait_on_runs impl_1