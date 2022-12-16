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

param="compiler.skipTimingCheckAndFrequencyScaling=1"
slr="${KERNEL_NAME}_1:SLR0"

newtext="[advanced]"
echo $newtext > ${CFG_FILE_NAME}

newtext="param=${param}"
echo $newtext >> ${CFG_FILE_NAME}

newtext=""
echo $newtext >> ${CFG_FILE_NAME}

newtext="[connectivity]"
echo $newtext >> ${CFG_FILE_NAME}

newtext="slr=${slr}"
echo $newtext >> ${CFG_FILE_NAME}

