set kernel_name         [lindex $argv 0]
set vivado_version      [lindex $argv 1]

proc create_run_i_impl {run_name parent_run flow strategy} {
    create_run i_${run_name}_${strategy} -parent_run ${parent_run} -flow ${flow} -strategy ${strategy}
    # set_property REFERENCE_RUN ${run_name}_${strategy} [get_runs i_${run_name}_${strategy}] 
}

create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_Auto_1"
create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_Auto_2" 
create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_Auto_3"
create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_Explore"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_ExplorePostRoutePhysOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_ExploreWithRemap"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_WLBlockPlacement"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_WLBlockPlacementFanoutOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_EarlyBlockPlacement"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_NetDelay_high"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_NetDelay_low"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_Retiming"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_ExtraTimingOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_RefinePlacement"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_SpreadSLLs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_BalanceSLLs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_BalanceSLRs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Performance_HighUtilSLRs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Congestion_SpreadLogic_high"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Congestion_SpreadLogic_medium"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Congestion_SpreadLogic_low"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Congestion_SSI_SpreadLogic_high"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Congestion_SSI_SpreadLogic_low"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Area_Explore"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Area_ExploreSequential"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Area_ExploreWithRemap"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Power_DefaultOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Power_ExploreArea"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Flow_RunPhysOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Flow_RunPostRoutePhysOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Flow_RuntimeOptimized"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${vivado_version}" "Flow_Quick"