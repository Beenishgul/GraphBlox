#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set project_var         [lindex $argv 0]
set kernel_name         [lindex $argv 1]
set app_directory       [lindex $argv 2]
set xilinx_directory    [lindex $argv 3]
set scripts_directory   [lindex $argv 4]
set gui_flag            [lindex $argv 5]
# =========================================================

if {${gui_flag} == "YES"} {
  start_gui
}

open_project $project_var 

set runlist_synth [get_runs synth*]

set i 0
foreach j $x {
    puts "$j is item run $i in runlist_synth"
    incr i
}

reset_run synth_$i
launch_runs synth_$i
wait_on_runs synth_$i

# if {[regexp -- impl_1 $runlist]} {reset_run impl_1} else {create_run impl_2 -parent_run synth_1 -flow {Vivado Implementation 2022.2}}
# launch_runs impl_1
# wait_on_runs impl_1