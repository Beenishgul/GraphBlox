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
echo "  PLATFORM: xilinx_u250_gen3x16_xdma_4_1_202210_1"
echo "  TARGET: hw_emu"
echo "  NUM_KERNELS: 2"
echo "  MAX_THREADS: 8"
echo "  DESIGN_FREQ_HZ: 300000000"
echo "" 
}
if [ "$1" = "" ]
then
print_usage
fi


generate_connectivity_sp () {

local kernel_name=$1
local start_kernel_buffers=$2
local num_kernel_buffers=$3
local mem_type=$4
local start=$5
local end=$6
local i=$7

local config=""
local ip_directory=""
local prev_ip_directory=""

for j in $(seq ${start_kernel_buffers} ${num_kernel_buffers})
  do
    if [[ "$start" == "$end" ]]
      then
         config+="sp=${kernel_name}_$i.buffer_$j:$mem_type[$start]\n"
      else
         config+="sp=${kernel_name}_$i.buffer_$j:$mem_type[$start:$end]\n"
      fi
  done

echo $config
}



ACTIVE_APP_DIR=$1
SCRIPTS_DIR=$2
KERNEL_NAME=$3
IMPL_STRATEGY=$4
JOBS_STRATEGY=$5
PART=$6
PLATFORM=$7
TARGET=$8
DESIGN_FREQ_HZ=$9
MAX_THREADS=${10}
NUM_KERNELS=${11}
NUM_SLR=1

if [[ "$PART" == "xcu55c-fsvh2892-2L-e" ]]
then
 NUM_SLR=3
elif [[ "$PART" == "xcu280-fsvh2892-2L-e" ]]
then
 NUM_SLR=3
elif [[ "$PART" == "xcu250-figd2104-2L-e" ]]
then
 NUM_SLR=4
else
 NUM_SLR=4
fi

NUM_KERNELS_PER_SLR=4
NUM_KERNELS_BUFFERS=9 

CFG_FILE_NAME="${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/${KERNEL_NAME}_rtl_${TARGET}.cfg"

config=""

config+="platform=${PLATFORM}\n"
config+="messageDb=${KERNEL_NAME}.mdb\n"
config+="temp_dir=${KERNEL_NAME}.build\n"
config+="report_dir=${KERNEL_NAME}.build/reports\n"
config+="log_dir=${KERNEL_NAME}.build/logs\n"
config+="save-temps=1\n"
# config+="target=hw\n"
config+="debug=1\n"
config+="link =1\n"

config+="\n"
config+="[clock]\n"
config+="defaultFreqHz=${DESIGN_FREQ_HZ}\n"
config+="\n"

config+="[connectivity]\n"
config+="nk=${KERNEL_NAME}"
config+=":${NUM_KERNELS}:"

#kernel ID loop
for i in $(seq 1 ${NUM_KERNELS})
do
if [[ "$i" == "$NUM_KERNELS" ]]; then
   config+="${KERNEL_NAME}_$i"
else
   config+="${KERNEL_NAME}_$i,"
fi
done
config+="\n"

#SLR placement loop
for i in $(seq 1 ${NUM_KERNELS})
do
  config+="slr=${KERNEL_NAME}_$i:SLR0\n"
  if [[ "$PART" == "xcu55c-fsvh2892-2L-e" ]]
  then
    config+=$(generate_connectivity_sp ${KERNEL_NAME} "0" ${NUM_KERNELS_BUFFERS} "HBM" "0" "4" $i)
  elif [[ "$PART" == "xcu280-fsvh2892-2L-e" ]]
  then
    config+=$(generate_connectivity_sp ${KERNEL_NAME} "0" ${NUM_KERNELS_BUFFERS} "HBM" "0" "4" $i)
  elif [[ "$PART" == "xcu250-figd2104-2L-e" ]]
  then
    config+=$(generate_connectivity_sp ${KERNEL_NAME} "0" ${NUM_KERNELS_BUFFERS} "DDR" "0" "0" $i)
  else
    config+=$(generate_connectivity_sp ${KERNEL_NAME} "0" ${NUM_KERNELS_BUFFERS} "DDR" "0" "0" $i)
  fi
done
config+="\n"

if [[ ${IMPL_STRATEGY} -eq 0 ]]
then
config+="\n[advanced]\n"
config+="param=compiler.skipTimingCheckAndFrequencyScaling=1\n"
elif [[ ${IMPL_STRATEGY} -eq 1 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"

 config+="\n[vivado]\n"
 config+="prop=run.synth_1.STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS={-directive sdx_optimization_effort_high}\n"
 config+="prop=run.impl_1.STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED=true\n"
 config+="prop=run.impl_1.STEPS.POST_PLACE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED=true\n"
 config+="prop=run.impl_1.STEPS.POST_PLACE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE={AlternateFlowWithRetiming}\n"
 
 config+="impl.jobs=${JOBS_STRATEGY}\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"

elif [[ ${IMPL_STRATEGY} -eq 2 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"

 config+="\n[vivado]\n"
 config+="impl.strategies=ALL\n"
 config+="impl.jobs=${JOBS_STRATEGY}\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"
 # config+="prop=run.impl_1.STEPS.OPT_DESIGN.TCL.PRE={${ACTIVE_APP_DIR}/${SCRIPTS_DIR}/opt_pre.tcl}"

elif [[ ${IMPL_STRATEGY} -eq 3 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"

 config+="\n[vivado]\n"
 config+="impl.strategies=ALL\n"
 config+="impl.jobs=${JOBS_STRATEGY})\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"

 config+="param=project.writeIntermediateCheckpoints=1\n"
 config+="prop=run.impl_1.STEPS.OPT_DESIGN.ARGS.DIRECTIVE=Explore\n"
 config+="prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.IS_ENABLED=true\n"
 config+="prop=run.impl_1.STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE=AggressiveExplore\n"
 config+="prop=run.impl_1.STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE=Explore\n"
 config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.MORE OPTIONS}={-tns_cleanup}\n"

 config+="prop=run.impl_1.STEPS.PLACE_DESIGN.ARGS.DIRECTIVE=Explore\n"
 config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.MORE OPTIONS}={-no_bufg_opt}\n"
 config+="param=hd.enableClockTrackSelectionEnancement=1\n"

elif [[ ${IMPL_STRATEGY} -eq 4 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"

 config+="\n[vivado]\n"
 config+="impl.strategies=ALL\n"
 config+="impl.jobs=${JOBS_STRATEGY})\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"

 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"
 config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={AltSpreadLogic_high}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
 config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
 config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"

elif [[ ${IMPL_STRATEGY} -eq 5 ]]
then

 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"

 config+="\n[vivado]\n"
 config+="impl.strategies=ALL\n"
 config+="impl.jobs=${JOBS_STRATEGY})\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"

 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={ExploreWithRemap}\n"
 config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={EarlyBlockPlacement}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Default}\n"
 config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={Default}\n"
 config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={false}\n" 

elif [[ ${IMPL_STRATEGY} -eq 6 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"

 config+="\n[vivado]\n"
 config+="impl.strategies=ALL\n"
 config+="impl.jobs=${JOBS_STRATEGY})\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"

 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"
 config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={AltSpreadLogic_high}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
 config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={AggressiveExplore}\n"
 config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n" 

elif [[ ${IMPL_STRATEGY} -eq 7 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"

 config+="\n[vivado]\n"
 config+="impl.strategies=ALL\n"
 config+="impl.jobs=${JOBS_STRATEGY})\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"

 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.OPT_DESIGN.ARGS.DIRECTIVE}={Explore}\n"
 config+="prop=run.impl_1.{STEPS.PLACE_DESIGN.ARGS.DIRECTIVE}={EarlyBlockPlacement}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={true}\n"
 config+="prop=run.impl_1.{STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE}={ExploreWithHoldFix}\n"
 config+="prop=run.impl_1.{STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE}={Default}\n"
 config+="prop=run.impl_1.{STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.IS_ENABLED}={false}\n" 

elif [[ ${IMPL_STRATEGY} -eq 8 ]]
then
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=0\n"
 config+="param=compiler.multiStrategiesWaitOnAllRuns=1\n"
 config+="\n[vivado]\n"
 config+="impl.strategies=Congestion_SpreadLogic_high\n"
 config+="impl.jobs=${JOBS_STRATEGY}\n"
 config+="synth.jobs=${JOBS_STRATEGY}\n"
 config+="param=general.maxThreads=${MAX_THREADS}\n"

else
 config+="\n[advanced]\n"
 config+="param=compiler.skipTimingCheckAndFrequencyScaling=1\n"
fi

echo -e  "${config}" > ${CFG_FILE_NAME}
