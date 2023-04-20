#!/bin/bash


print_usage () {
  echo "Usage: "
  echo "  generate_build_cfg.sh ACTIVE_APP_DIR SCRIPTS_DIR KERNEL_NAME"
  echo ""
  echo "  ACTIVE_APP_DIR: /home/cmv6ru/Documents/00_github_repos/00_GLay/"
  echo "  SCRIPTS_DIR: 00_GLay"
  echo "  KERNEL_NAME: kernel"
  echo "  IMPL_STRATEGY: 0"
  echo "  JOBS_STRATEGY: 2"
  echo "  PART: xcu280-fsvh2892-2L-e"
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
PART=$6

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_build_hw.cfg"
 
config=""
 
config+="[connectivity]\n"
if [[ "$PART" == "xcu280-fsvh2892-2L-e" ]]
then
   config+="slr=${KERNEL_NAME}_1:SLR0\n"
   config+="sp=${KERNEL_NAME}_1.graph_csr_struct:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.vertex_out_degree:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.vertex_in_degree:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.vertex_edges_idx:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.edges_array_weight:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.edges_array_src:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.edges_array_dest:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.auxiliary_1:HBM[1]\n"
   config+="sp=${KERNEL_NAME}_1.auxiliary_2:HBM[1]\n"
elif [[ "$PART" == "xcu250-figd2104-2L-e" ]]
then
   config+="slr=${KERNEL_NAME}_1:SLR0\n"
   config+="sp=${KERNEL_NAME}_1.graph_csr_struct:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.vertex_out_degree:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.vertex_in_degree:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.vertex_edges_idx:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.edges_array_weight:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.edges_array_src:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.edges_array_dest:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.auxiliary_1:DDR[0]\n"
   config+="sp=${KERNEL_NAME}_1.auxiliary_2:DDR[0]\n"
else
  config+="slr=${KERNEL_NAME}_1:SLR0\n"
  config+="sp=${KERNEL_NAME}_1.graph_csr_struct:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.vertex_out_degree:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.vertex_in_degree:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.vertex_edges_idx:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.edges_array_weight:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.edges_array_src:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.edges_array_dest:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.auxiliary_1:DDR[0]\n"
  config+="sp=${KERNEL_NAME}_1.auxiliary_2:DDR[0]\n"
fi


if [[ ${IMPL_STRATEGY} -eq 0 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=1\n"
 echo -e "${config}" >> ${CFG_FILE_NAME}
elif [[ ${IMPL_STRATEGY} -eq 1 ]]
  then
   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
   config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"


   config+="\n[vivado]\n"
   config+="impl.strategies=Performance_Explore,Area_Explore\n"
   config+="impl.jobs=${JOBS_STRATEGY}\n"

   echo -e "${config}" >> ${CFG_FILE_NAME}
 elif [[ ${IMPL_STRATEGY} -eq 2 ]]
  then
   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
   config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"


   JOBS_STRATEGY=$(grep -c ^processor /proc/cpuinfo)

   config+="\n[vivado]\n"
   config+="impl.strategies=ALL\n"
   config+="impl.jobs=$((${JOBS_STRATEGY} / 4))\n"
   config+="synth.jobs=${JOBS_STRATEGY}\n"
   # config+="prop=run.impl_1.STEPS.OPT_DESIGN.TCL.PRE={${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/opt_pre.tcl}"

   echo -e "${config}" >> ${CFG_FILE_NAME}
 elif [[ ${IMPL_STRATEGY} -eq 3 ]]
  then
   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
   config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"


   JOBS_STRATEGY=$(grep -c ^processor /proc/cpuinfo)

   config+="\n[vivado]\n"
   config+="impl.strategies=ALL\n"
   config+="impl.jobs=$((${JOBS_STRATEGY} / 4))\n"
   config+="synth.jobs=${JOBS_STRATEGY}\n"

   config+="param=project.writeIntermediateCheckpoints=1\n"
   config+="prop=run.impl_1.STEPS.OPT_DESIGN.ARGS.DIRECTIVE=Explore\n"
   config+="prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true\n"
   config+="prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE=AggressiveExplore\n"
   config+="prop=run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore\n"
   config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS}={-tns_cleanup}\n"
   config+="prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED=true\n"
   config+="prop=run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=Explore\n"
   config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS}={-no_bufg_opt}\n"
   config+="param=hd.enableClockTrackSelectionEnancement=1\n"

   echo -e "${config}" >> ${CFG_FILE_NAME}
 elif [[ ${IMPL_STRATEGY} -eq 4 ]]
  then
   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
   config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"


   JOBS_STRATEGY=$(grep -c ^processor /proc/cpuinfo)

   config+="\n[vivado]\n"
   config+="impl.strategies=ALL\n"
   config+="impl.jobs=$((${JOBS_STRATEGY} / 4))\n"
   config+="synth.jobs=${JOBS_STRATEGY}\n"

   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"
   config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={AltSpreadLogic_high}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
   config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
   config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"

   echo -e "${config}" >> ${CFG_FILE_NAME}
 elif [[ ${IMPL_STRATEGY} -eq 5 ]]
  then

   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
   config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"


   JOBS_STRATEGY=$(grep -c ^processor /proc/cpuinfo)

   config+="\n[vivado]\n"
   config+="impl.strategies=ALL\n"
   config+="impl.jobs=$((${JOBS_STRATEGY} / 4))\n"
   config+="synth.jobs=${JOBS_STRATEGY}\n"

   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={ExploreWithRemap}\n"
   config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={EarlyBlockPlacement}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Default}\n"
   config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={Default}\n"
   config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={false}\n" 

   echo -e "${config}" >> ${CFG_FILE_NAME}
 elif [[ ${IMPL_STRATEGY} -eq 6 ]]
  then
   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
   config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"


   JOBS_STRATEGY=$(grep -c ^processor /proc/cpuinfo)

   config+="\n[vivado]\n"
   config+="impl.strategies=ALL\n"
   config+="impl.jobs=$((${JOBS_STRATEGY} / 4))\n"
   config+="synth.jobs=${JOBS_STRATEGY}\n"

   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"
   config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={AltSpreadLogic_high}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
   config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
   config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n" 

   echo -e "${config}" >> ${CFG_FILE_NAME}
 elif [[ ${IMPL_STRATEGY} -eq 7 ]]
  then
   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
   config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"


   JOBS_STRATEGY=$(grep -c ^processor /proc/cpuinfo)

   config+="\n[vivado]\n"
   config+="impl.strategies=ALL\n"
   config+="impl.jobs=$((${JOBS_STRATEGY} / 4))\n"
   config+="synth.jobs=${JOBS_STRATEGY}\n"

   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"
   config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={EarlyBlockPlacement}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
   config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={ExploreWithHoldFix}\n"
   config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={Default}\n"
   config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={false}\n" 

   echo -e "${config}" >> ${CFG_FILE_NAME}
 else
   config+="\n[advanced]\n"
   config+="param=compiler.skipTimingCheckAndFrequencyScaling=1\n"
   echo -e  "${config}" >> ${CFG_FILE_NAME}
 fi

