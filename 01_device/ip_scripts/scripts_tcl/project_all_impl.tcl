set kernel_name         [lindex $argv 0]
set vivado_version      [lindex $argv 1]

proc create_run_impl {run_name parent_run flow kernel_name strategy} {
    create_run ${run_name}_${strategy} -parent_run ${parent_run} -flow ${flow} -strategy ${strategy}
    set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs ${run_name}_${strategy}]
    set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs ${run_name}_${strategy}]
    set_property incremental_checkpoint.directive TimingClosure [get_runs ${run_name}_${strategy}]
}

# create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Defaults"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_Auto_1"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_Auto_2" 
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_Auto_3"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_Explore"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_ExplorePostRoutePhysOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_ExploreWithRemap"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_WLBlockPlacement"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_WLBlockPlacementFanoutOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_EarlyBlockPlacement"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_NetDelay_high"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_NetDelay_low"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_Retiming"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_ExtraTimingOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_RefinePlacement"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_SpreadSLLs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_BalanceSLLs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_BalanceSLRs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Performance_HighUtilSLRs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Congestion_SpreadLogic_high"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Congestion_SpreadLogic_medium"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Congestion_SpreadLogic_low"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Congestion_SSI_SpreadLogic_high"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Congestion_SSI_SpreadLogic_low"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Area_Explore"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Area_ExploreSequential"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Area_ExploreWithRemap"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Power_DefaultOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Power_ExploreArea"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Flow_RunPhysOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Flow_RunPostRoutePhysOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Flow_RuntimeOptimized"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${vivado_version}" ${kernel_name} "Flow_Quick"
