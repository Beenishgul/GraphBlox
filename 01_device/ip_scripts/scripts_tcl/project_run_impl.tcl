#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set project_var         [lindex $argv 0]
set gui_flag            [lindex $argv 1]
set strategy            [lindex $argv 2]
set num_jobs            [lindex $argv 3]
# =========================================================

if {${gui_flag} == "YES"} {
  start_gui
}

open_project $project_var 

# set runlist_impl  [get_runs impl*]
# set runlist_synth [get_runs synth*]

# reset_run synth_1
# launch_runs synth_1
# wait_on_runs synth_1

# reset_run impl_1
# launch_runs impl_1 -to_step write_bitstream
# wait_on_runs impl_1

foreach impl_strategy [list [lindex [get_runs impl*] $strategy]] { 
  reset_run $impl_strategy
  launch_runs $impl_strategy -to_step write_bitstream -jobs $num_jobs
  wait_on_runs $impl_strategy 
}