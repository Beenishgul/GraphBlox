

create_project -force project_1 ./ -part xcvu9p-flga2104-2L-e

set verilog_files [glob *.v]
set sverilog_files [glob *.sv]



add_files $verilog_files
add_files $sverilog_files

#add_files -fileset clk_constrain -norecurse ./clk_constrain.xdc
#read_xdc -mode out_of_context ./clk_constrain.xdc

synth_design -mode out_of_context -flatten_hierarchy rebuilt -top Top_Module

#write_checkpoint synth.dcp

set_property HD.PARTITION 1 [current_design]

opt_design
place_design
phys_opt_design
route_design

read_xdc -mode out_of_context ./clk_constrain.xdc
report_timing_summary -file ./timing_summary.txt

report_utilization -hierarchical  -file ./utilization.txt

report_power -file ./power_summary.txt