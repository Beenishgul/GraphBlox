set kernel_name         [lindex $argv 0]

create_run impl_Performance_Auto_1 -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_Auto_1  
create_run impl_Performance_Auto_2 -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_Auto_2 
create_run impl_Performance_Auto_3 -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_Auto_3 
create_run impl_Performance_Explore -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_Explore 
create_run impl_Performance_ExplorePostRoutePhysOpt -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_ExplorePostRoutePhysOpt 
create_run impl_Performance_ExploreWithRemap -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_ExploreWithRemap
create_run impl_Performance_WLBlockPlacement -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_WLBlockPlacement
create_run impl_Performance_WLBlockPlacementFanoutOpt -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_WLBlockPlacementFanoutOpt
create_run impl_Performance_EarlyBlockPlacement -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_EarlyBlockPlacement
create_run impl_Performance_NetDelay_high -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_NetDelay_high
create_run impl_Performance_NetDelay_low -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_NetDelay_low
create_run impl_Performance_Retiming -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_Retiming
create_run impl_Performance_ExtraTimingOpt -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_ExtraTimingOpt
create_run impl_Performance_RefinePlacement -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_RefinePlacement
create_run impl_Performance_SpreadSLLs -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_SpreadSLLs
create_run impl_Performance_BalanceSLLs -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_BalanceSLLs
create_run impl_Performance_BalanceSLRs -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_BalanceSLRs
create_run impl_Performance_HighUtilSLRs -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Performance_HighUtilSLRs
create_run impl_Congestion_SpreadLogic_high -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Congestion_SpreadLogic_high
create_run impl_Congestion_SpreadLogic_medium -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Congestion_SpreadLogic_medium
create_run impl_Congestion_SpreadLogic_low -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Congestion_SpreadLogic_low
create_run impl_Congestion_SSI_SpreadLogic_high -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Congestion_SSI_SpreadLogic_high
create_run impl_Congestion_SSI_SpreadLogic_low -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Congestion_SSI_SpreadLogic_low
create_run impl_Area_Explore -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Area_Explore
create_run impl_Area_ExploreSequential -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Area_ExploreSequential
create_run impl_Area_ExploreWithRemap -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Area_ExploreWithRemap
create_run impl_Power_DefaultOpt -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Power_DefaultOpt
create_run impl_Power_ExploreArea -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Power_ExploreArea
create_run impl_Flow_RunPhysOpt -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Flow_RunPhysOpt
create_run impl_Flow_RunPostRoutePhysOpt -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Flow_RunPostRoutePhysOpt
create_run impl_Flow_RuntimeOptimized -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Flow_RuntimeOptimized
create_run impl_Flow_Quick -parent_run synth_1 -flow {Vivado Implementation 2023} -strategy Flow_Quick

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Auto_1]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name}/${kernel_name}.srcs/utils_1/imports/impl_Performance_Auto_1 [get_runs impl_Performance_Auto_1]
set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs impl_Performance_Auto_1]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Auto_2]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Auto_2]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Explore]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Explore]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_ExploreWithRemap]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_ExploreWithRemap]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_WLBlockPlacementFanoutOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_WLBlockPlacementFanoutOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_BalanceSLRs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_BalanceSLRs]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_NetDelay_low]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_NetDelay_low]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_ExtraTimingOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_ExtraTimingOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_SpreadSLLs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_SpreadSLLs]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SpreadLogic_high]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SpreadLogic_high]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SpreadLogic_low]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SpreadLogic_low]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SSI_SpreadLogic_low]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SSI_SpreadLogic_low]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Area_ExploreSequential]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Area_ExploreSequential]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Power_DefaultOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Power_DefaultOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Power_ExploreArea]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Power_ExploreArea]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_RunPostRoutePhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_RunPostRoutePhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_Quick]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_Quick]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_1]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_1]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Auto_1]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Auto_1]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Auto_3]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Auto_3]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_ExplorePostRoutePhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_ExplorePostRoutePhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_WLBlockPlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_WLBlockPlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_EarlyBlockPlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_EarlyBlockPlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_BalanceSLLs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_BalanceSLLs]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_NetDelay_high]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_NetDelay_high]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Retiming]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Retiming]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_RefinePlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_RefinePlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_HighUtilSLRs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_HighUtilSLRs]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SpreadLogic_medium]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SpreadLogic_medium]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SSI_SpreadLogic_high]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SSI_SpreadLogic_high]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Area_Explore]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Area_Explore]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Area_ExploreWithRemap]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Area_ExploreWithRemap]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_RunPhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_RunPhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_RuntimeOptimized]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_RuntimeOptimized]