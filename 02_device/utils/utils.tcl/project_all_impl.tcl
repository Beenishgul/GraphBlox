set KERNEL_NAME         [lindex $argv 0]
set VIVADO_VER      [lindex $argv 1]

proc create_run_impl {run_name parent_run flow KERNEL_NAME strategy} {
    create_run ${run_name}_${strategy} -parent_run ${parent_run} -flow ${flow} -strategy ${strategy}
    set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs ${run_name}_${strategy}]
    set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${KERNEL_NAME} [get_runs ${run_name}_${strategy}]
    set_property incremental_checkpoint.directive TimingClosure [get_runs ${run_name}_${strategy}]
}

# create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Defaults"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_Auto_1"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_Auto_2" 
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_Auto_3"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_Explore"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_ExplorePostRoutePhysOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_ExploreWithRemap"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_WLBlockPlacement"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_WLBlockPlacementFanoutOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_EarlyBlockPlacement"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_NetDelay_high"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_NetDelay_low"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_Retiming"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_ExtraTimingOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_RefinePlacement"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_SpreadSLLs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_BalanceSLLs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_BalanceSLRs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Performance_HighUtilSLRs"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Congestion_SpreadLogic_high"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Congestion_SpreadLogic_medium"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Congestion_SpreadLogic_low"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Congestion_SSI_SpreadLogic_high"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Congestion_SSI_SpreadLogic_low"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Area_Explore"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Area_ExploreSequential"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Area_ExploreWithRemap"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Power_DefaultOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Power_ExploreArea"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Flow_RunPhysOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Flow_RunPostRoutePhysOpt"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Flow_RuntimeOptimized"
create_run_impl "impl" "synth_1"  "Vivado Implementation ${VIVADO_VER}" ${KERNEL_NAME} "Flow_Quick"
