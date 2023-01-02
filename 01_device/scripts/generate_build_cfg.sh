#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_build_cfg.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/"
  echo "  SCRIPTS_DIR: 00_GLay"
  echo "  KERNEL_NAME: glay_kernel"
  echo "  IMPL_STRATEGY: 0"
  echo "  JOBS_STRATEGY: 2"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3
IMPL_STRATEGY=$4
JOBS_STRATEGY=$5

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_build_hw.cfg"

# param1="compiler.skipTimingCheckAndFrequencyScaling=1"
# param2="compiler.multiStrategiesWaitOnAllRuns=1"
# slr="${KERNEL_NAME}_1:SLR1"

# config="[advanced]"
# echo $config > ${CFG_FILE_NAME}

# config="param=${param1}"
# echo $config >> ${CFG_FILE_NAME}
# config="param=${param2}"
# echo $config >> ${CFG_FILE_NAME}

# config=""
# echo $config >> ${CFG_FILE_NAME}

# config="[connectivity]"
# echo $config >> ${CFG_FILE_NAME}

# config="slr=${slr}"
# echo $config >> ${CFG_FILE_NAME}

# config=""
# echo $config >> ${CFG_FILE_NAME}

# config="[vivado]"
# echo $config >> ${CFG_FILE_NAME}

# config="impl.strategies=Performance_Explore,Area_Explore"
# echo $config >> ${CFG_FILE_NAME}

# config="impl.jobs=2"
# echo $config >> ${CFG_FILE_NAME}

if [[ ${IMPL_STRATEGY} -eq 0 ]]
then
     config="\n[advanced]\n"
     config+="param=compiler.skipTimingCheckAndFrequencyScaling=1\n"
     config+="\n[connectivity]\n"
     config+="slr=${KERNEL_NAME}_1:SLR1\n"
     echo $config >> ${CFG_FILE_NAME}
elif [[ ${IMPL_STRATEGY} -eq 1 ]]
then
     config="\n[advanced]\n"
     config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
     config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"
     config+="\n[connectivity]\n"
     config+="slr=${KERNEL_NAME}_1:SLR1\n"
     config+="\n[vivado]\n"
     config+="impl.strategies=Performance_Explore,Area_Explore\n"
     config+="impl.jobs=${JOBS_STRATEGY}\n"
     echo $config >> ${CFG_FILE_NAME}
elif [[ ${IMPL_STRATEGY} -eq 2 ]]
then
     # CODE-TO-EXECUTE-2
elif [[ ${IMPL_STRATEGY} -eq 3 ]]
then
     # CODE-TO-EXECUTE-2
else
else
     # CODE-TO-EXECUTE-2
fi

# [vivado]
# #impl.strategies=Performance_Explore,Area_Explore
# #impl.strategies=all
# param=project.writeIntermediateCheckpoints=1
# prop=run.impl_1.STEPS.OPT_DESIGN.ARGS.DIRECTIVE=Explore
# prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true
# prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE=AggressiveExplore
# prop=run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore
# prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS}={-tns_cleanup}
# prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true
# [vivado]
# prop=run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=Explore
# prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS}={-no_bufg_opt}
# param=hd.enableClockTrackSelectionEnancement=1

# ifeq ($(N_FIR_FILTERS),10)
#    ifeq ($(N_FIR_TAPS),15)
#      VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={AltSpreadLogic_high}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Explore}
       
#    else ifeq ($(N_FIR_TAPS),64)
#       VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={ExploreWithRemap}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={EarlyBlockPlacement}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Default}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={Default}
#     #VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={disabled} 
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={false} 
   
#   else ifeq ($(N_FIR_TAPS),129)
#       VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={AltSpreadLogic_high}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Explore} 
   
#   else ifeq ($(N_FIR_TAPS),240)
#       VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={EarlyBlockPlacement}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={ExploreWithHoldFix}
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={Default}
#     #VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={disabled} 
#     VPP_LINK_FLAGS += --vivado.prop run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={false} 
#    endif
# endif

## Enabling Multiple Strategies For Closing Timing...
#VPP_LINK_FLAGS += --vivado.impl.strategies "ALL"
##VPP_LINK_FLAGS += --vivado.impl.lsf '{bsub -R "select[type=X86_64] rusage[mem=65536]" -N -q medium}'
#VPP_LINK_FLAGS += --advanced.param "compiler.enableMultiStrategies=1"
#VPP_LINK_FLAGS += --advanced.param "compiler.multiStrategiesWaitOnAllRuns=1"
#VPP_LINK_FLAGS += --vivado.synth.jobs 32
#VPP_LINK_FLAGS += --vivado.impl.jobs 8