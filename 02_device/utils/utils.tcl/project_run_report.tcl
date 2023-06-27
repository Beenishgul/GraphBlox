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

open_project $VIVADO_BUILD_DIR 
set runlist [get_runs impl*]

open_run impl_1
# open_run impl_Performance_EarlyBlockPlacement
#Utilization
report_utilization -file utilization_hierarchical.txt -hierarchical
report_utilization -file utilization_report.txt

#Design Analysis
report_design_analysis -file logic_level_distribution_report.txt -logic_level_distribution 

#Power
report_power -file power_hierarchical.txt
report_power -file {power.txt} -xpe {power.xpe} -rpx {power.rpx}

#Timing Summary
check_timing -verbose -name timing_violations_report -file timing_violations_report.txt
report_timing -delay_type min_max -max_paths 20 -sort_by group -input_pins -routable_nets -name timing_report -file timing_report.txt
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 20 -input_pins -routable_nets -name timing_summary_report -file timing_summary_report.txt 

#DRC Summary
report_drc -file drc_routed_report.txt

# display timing report summary
# "user_design_clk" is defined in "constraints_timing.xdc"
# set user_design_clk_period_ns [get_property PERIOD [get_clocks user_design_clk]]
# puts "User design clock: [show_period_freq $user_design_clk_period_ns]"
# set wns [get_property SLACK [get_timing_paths]]
# set timing_met [expr {$wns >= 0}]
# if {$timing_met} {
#     puts "Timing constraints: met (worst negative slack = $wns)"
# } else {
#     puts "Timing constraints: violated (worst negative slack = $wns)"
# }

# set impl_finish_time [clock clicks -milliseconds]
# set impl_time [expr ($impl_finish_time - $impl_start_time) / 1000]
# puts "Implementation time = [expr $impl_time / 60]:[format %02d [expr $impl_time % 60]]"
