#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_build_cfg.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/"
  echo "  SCRIPTS_DIR: 00_GLay"
  echo "  KERNEL_NAME: glay_kernel"
  echo "" 
}
if [ "$1" = "" ]
then
  print_usage
fi

ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_build_hw.cfg"

param1="compiler.skipTimingCheckAndFrequencyScaling=0"
param2="compiler.multiStrategiesWaitOnAllRuns=1"
slr="${KERNEL_NAME}_1:SLR1"

newtext="[advanced]"
echo $newtext > ${CFG_FILE_NAME}

newtext="param=${param1}"
echo $newtext >> ${CFG_FILE_NAME}
newtext="param=${param2}"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="[connectivity]"
echo $newtext >> ${CFG_FILE_NAME}

newtext="slr=${slr}"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="[vivado]"
echo $newtext >> ${CFG_FILE_NAME}

newtext="impl.strategies=Performance_Explore,Area_Explore"
echo $newtext >> ${CFG_FILE_NAME}

newtext="impl.jobs=2"
echo $newtext >> ${CFG_FILE_NAME}

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