#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set project_var         [lindex $argv 0]
set gui_flag            [lindex $argv 5]
# =========================================================

if {${gui_flag} == "YES"} {
  start_gui
}

open_project $project_var 

set runlist_impl  [get_runs impl*]
set runlist_synth [get_runs synth*]

reset_run synth_1
launch_runs synth_1
wait_on_runs synth_1

if {[regexp -- impl_1 $runlist_impl]} {reset_run impl_1} else {create_run impl_2 -parent_run synth_1 -flow {Vivado Implementation 2022.2}}
launch_runs impl_1
wait_on_runs impl_1