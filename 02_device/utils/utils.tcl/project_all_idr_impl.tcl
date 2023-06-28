set PARAMS_TCL_DIR                  [lindex $argv 0]

source ${PARAMS_TCL_DIR}


proc create_run_i_impl {run_name parent_run flow strategy} {
    create_run i_${run_name}_${strategy} -parent_run ${parent_run} -flow ${flow} -strategy ${strategy}
    # set_property REFERENCE_RUN ${run_name}_${strategy} [get_runs i_${run_name}_${strategy}] 
}

create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_Auto_1"
create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_Auto_2" 
create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_Auto_3"
create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_Explore"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_ExplorePostRoutePhysOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_ExploreWithRemap"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_WLBlockPlacement"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_WLBlockPlacementFanoutOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_EarlyBlockPlacement"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_NetDelay_high"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_NetDelay_low"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_Retiming"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_ExtraTimingOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_RefinePlacement"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_SpreadSLLs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_BalanceSLLs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_BalanceSLRs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Performance_HighUtilSLRs"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Congestion_SpreadLogic_high"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Congestion_SpreadLogic_medium"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Congestion_SpreadLogic_low"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Congestion_SSI_SpreadLogic_high"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Congestion_SSI_SpreadLogic_low"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Area_Explore"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Area_ExploreSequential"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Area_ExploreWithRemap"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Power_DefaultOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Power_ExploreArea"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Flow_RunPhysOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Flow_RunPostRoutePhysOpt"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Flow_RuntimeOptimized"
# create_run_i_impl "impl" "synth_1"  "Vivado IDR Flow ${VIVADO_VER}" "Flow_Quick"