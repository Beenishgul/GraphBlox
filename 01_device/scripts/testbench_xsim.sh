#!/bin/bash -f
#*********************************************************************************************************
# Vivado (TM) v2022.1.2 (64-bit)
#
# Filename    : control_${kernel_name}_vip.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Simulation script for compiling, elaborating and verifying the project source files.
#               The script will automatically create the design libraries sub-directories in the run
#               directory, add the library logical mappings in the simulator setup file, create default
#               'do/prj' file, execute compilation, elaboration and simulation steps.
#
# Generated by Vivado on Mon Nov 14 23:17:13 EST 2022
# SW Build 3605665 on Fri Aug  5 22:52:02 MDT 2022
#
# Tool Version Limit: 2022.04 
#
# usage: ${kernel_name}_testbench_xsim.sh [-help]
# usage: ${kernel_name}_testbench_xsim.sh [-lib_map_path]
# usage: ${kernel_name}_testbench_xsim.sh [-noclean_files]
# usage: ${kernel_name}_testbench_xsim.sh [-reset_run]
#
#*********************************************************************************************************


kernel_name=$1
app_directory=$2

# Set xvlog options
xvlog_opts="--incr --relax -L uvm -f ${app_directory}/${kernel_name}_scripts/${kernel_name}_filelist_xsim.f  -i ${app_directory}/${kernel_name}_IP/iob_cache/iob_include -L xilinx_vip --sv -d DUMP_WAVEFORM"
xelab_opts="-debug typical -L unisims_ver  -L xpm --incr --debug typical --relax --mt auto -L xilinx_vip -L xpm -L axi_infrastructure_v1_1_0 -L xil_defaultlib -L axi_vip_v1_1_12 -L uvm"
xsim_opts="-tclbatch ${app_directory}/${kernel_name}_scripts/${kernel_name}_cmd_xsim.tcl --wdb work.${kernel_name}_testbench.wdb work.${kernel_name}_testbench#work.glbl"
# Script info
echo -e "${kernel_name}_testbench_xsim.sh - (Vivado v2022.1.2 (64-bit)-id)\n"

# Main steps
run()
{
  check_args $# $3
  setup $3 $4
}

# RUN_STEP: <compile>
compile()
{
  xvlog $xvlog_opts 2>&1 | tee compile.log
}

# RUN_STEP: <elaborate>
elaborate()
{
  xelab ${kernel_name}_testbench glbl $xelab_opts -log elaborate.log

}

# RUN_STEP: <simulate>
simulate()
{
  xsim  $xsim_opts -log simulate.log
}

# RUN_STEP: <GUI wave>
wave_run()
{
  xsim --gui work.${kernel_name}_testbench#work.glbl
}

# STEP: setup
setup()
{
  case $3 in
    "-lib_map_path" )
      if [[ ($4 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./${kernel_name}_testbench_xsim.sh -help\" for more information)\n"
        exit 1
      fi
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      compile
      elaborate
      simulate
      exit 0
      # do not remove previous data
    ;;
    "-wave_run" )
      wave_run
      exit 0
      # do not remove previous data
    ;;
    *)
      compile
      elaborate
      simulate
      exit 0
    ;;
  esac

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(xelab.pb xsim.jou xvhdl.log xvlog.log compile.log elaborate.log simulate.log xelab.log xsim.log run.log xvhdl.pb xvlog.pb ${kernel_name}_testbench.wdb xsim.dir)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done
}

# Check command line arguments
check_args()
{
  if [[ ($3 == 3 ) && ($4 != "-lib_map_path" && $4 != "-noclean_files" && $4 != "-reset_run" && $4 != "-wave_run" && $4 != "-help" && $4 != "-h") ]]; then
    echo -e "ERROR: Unknown option specified '$4' (type \"./${kernel_name}_testbench_xsim.sh -help\" for more information)\n"
    exit 1
  fi

  if [[ ($4 == "-help" || $4 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
msg="Usage: ${kernel_name}_testbench_xsim.sh [-help]\n\
Usage: ${kernel_name}_testbench_xsim.sh [-lib_map_path]\n\
Usage: ${kernel_name}_testbench_xsim.sh [-reset_run]\n\
Usage: ${kernel_name}_testbench_xsim.sh [-wave_run]\n\
Usage: ${kernel_name}_testbench_xsim.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $3 $4
