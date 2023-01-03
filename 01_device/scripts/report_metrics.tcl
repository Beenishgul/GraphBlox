#!/usr/bin/tclsh

open_run impl_1
#Utilisation
report_utilization -file utilization_hierarchical.txt -hierarchical
report_utilization -file utilization_report.txt

#Power
report_power -file power_hierarchical.txt
report_power -file {power.txt} -xpe {power.xpe} -rpx {power.rpx}

#Timing summary
check_timing -verbose -name timing_violations_report -file timing_violations_report.txt
report_timing -delay_type min_max -max_paths 20 -sort_by group -input_pins -routable_nets -name timing_report -file timing_report.txt
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 20 -input_pins -routable_nets -name timing_summary_report -file timing_summary_report.txt 