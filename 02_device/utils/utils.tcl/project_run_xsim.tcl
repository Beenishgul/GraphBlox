#!/usr/bin/tclsh

# =========================================================
# create ip project with part name in command line argvs
# =========================================================
set ACTIVE_PARAMS_TCL_DIR                  [lindex $argv 0]

source ${ACTIVE_PARAMS_TCL_DIR}

set package_full_dir ${APP_DIR_ACTIVE}/${VIVADO_PACKAGE_DIR}
set log_file         ${package_full_dir}/generate_${KERNEL_NAME}_xsim.log
# =========================================================

proc update_filelist_if_exists {group filename log_file} {
   if { [file exists ${filename}] == 1} {       
       add_files -force -scan_for_includes -fileset $group [read [open ${filename}]] >> $log_file
       import_files -force -fileset $group [read [open ${filename}]] >> $log_file
   }
}

proc color {foreground text} {
    # tput is a little Unix utility that lets you use the termcap database
    # *much* more easily...
    return [exec tput setaf $foreground]$text[exec tput sgr0]
}

# =========================================================
# Mode: - behavioral, 
#       - post-synthesis, post-implementation
#         * Type : functional, timing
# =========================================================
# Step 1: Open vivado project and add design sources
# =========================================================
if {${VIVADO_GUI_FLAG} == "YES"} {
  start_gui
}

open_project ${KERNEL_PROJECT_PKG_XPR} 
# =========================================================

# remove_files -fileset sim_1      [get_files] >> $log_file   

# puts "[color 4 "                        INFO: Add design sources into sim_1 ${KERNEL_NAME}"]" 
# set_property SOURCE_SET sources_1 [get_filesets sim_1]
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.v.f $log_file
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.sv.f $log_file
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.vhdl.f $log_file
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.vh.f $log_file
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_package.xci.f $log_file
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.v.f $log_file
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.sv.f $log_file
# update_filelist_if_exists sim_1 ${APP_DIR_ACTIVE}/${UTILS_DIR_ACTIVE}/${KERNEL_NAME}_filelist_xsim.ip.vhdl.f $log_file

# puts "[color 4 "                        INFO: Update compile order: sim_1"]"
# update_compile_order -fileset sim_1 >> $log_file

if {${SIMULATION_MODE} == 0} {
  launch_simulation -simset sim_1 -mode behavioral
} elseif {${SIMULATION_MODE} == 1} {
  launch_simulation -simset sim_1 -mode post-synthesis -type functional
} elseif {${SIMULATION_MODE} == 2} {
  launch_simulation -simset sim_1 -mode post-implementation -type functional
} else {
  launch_simulation -simset sim_1 -mode behavioral
}

log_wave -r *
run -all