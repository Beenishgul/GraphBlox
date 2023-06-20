set kernel_name         [lindex $argv 0]

create_run impl_default -parent_run synth_1 -flow {Vivado Implementation 2023}
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

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_default]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_default]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_default]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Auto_1]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Auto_1]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_Auto_1]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Auto_3]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Auto_3]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_Auto_3]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Auto_2]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Auto_2]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_Auto_2]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Explore]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Explore]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_Explore]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_ExploreWithRemap]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_ExploreWithRemap]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_ExploreWithRemap]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_WLBlockPlacementFanoutOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_WLBlockPlacementFanoutOpt]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_WLBlockPlacementFanoutOpt]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_BalanceSLRs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_BalanceSLRs]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_BalanceSLRs]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_NetDelay_low]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_NetDelay_low]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_NetDelay_low]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_ExtraTimingOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_ExtraTimingOpt]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_ExtraTimingOpt]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_SpreadSLLs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_SpreadSLLs]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_SpreadSLLs]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SpreadLogic_high]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SpreadLogic_high]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Congestion_SpreadLogic_high]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SpreadLogic_low]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SpreadLogic_low]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Congestion_SpreadLogic_low]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SSI_SpreadLogic_low]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SSI_SpreadLogic_low]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Congestion_SSI_SpreadLogic_low]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Area_ExploreSequential]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Area_ExploreSequential]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Area_ExploreSequential]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Power_DefaultOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Power_DefaultOpt]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Power_DefaultOpt]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Power_ExploreArea]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Power_ExploreArea]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Power_ExploreArea]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_RunPostRoutePhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_RunPostRoutePhysOpt]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Flow_RunPostRoutePhysOpt]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_Quick]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_Quick]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Flow_Quick]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_ExplorePostRoutePhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_ExplorePostRoutePhysOpt]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_ExplorePostRoutePhysOpt]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_WLBlockPlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_WLBlockPlacement]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_WLBlockPlacement]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_EarlyBlockPlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_EarlyBlockPlacement]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_EarlyBlockPlacement]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_BalanceSLLs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_BalanceSLLs]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_BalanceSLLs]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_NetDelay_high]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_NetDelay_high]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_NetDelay_high]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_Retiming]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_Retiming]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_Retiming]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_RefinePlacement]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_RefinePlacement]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_RefinePlacement]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Performance_HighUtilSLRs]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Performance_HighUtilSLRs]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Performance_HighUtilSLRs]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SpreadLogic_medium]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SpreadLogic_medium]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Congestion_SpreadLogic_medium]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Congestion_SSI_SpreadLogic_high]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Congestion_SSI_SpreadLogic_high]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Congestion_SSI_SpreadLogic_high]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Area_Explore]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Area_Explore]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Area_Explore]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Area_ExploreWithRemap]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Area_ExploreWithRemap]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Area_ExploreWithRemap]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_RunPhysOpt]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_RunPhysOpt]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Flow_RunPhysOpt]

set_property AUTO_INCREMENTAL_CHECKPOINT 1 [get_runs impl_Flow_RuntimeOptimized]
set_property AUTO_INCREMENTAL_CHECKPOINT.DIRECTORY ./${kernel_name} [get_runs impl_Flow_RuntimeOptimized]
set_property incremental_checkpoint.directive TimingClosure [get_runs impl_Flow_RuntimeOptimized]

create_run i_impl_default -parent_run synth_1 -flow {Vivado IDR Flow 2023}
create_run i_impl_Performance_Auto_1 -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_Auto_2 -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_Auto_3 -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_Explore -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_ExplorePostRoutePhysOpt -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_ExploreWithRemap -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_WLBlockPlacement -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_WLBlockPlacementFanoutOpt -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_EarlyBlockPlacement -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_NetDelay_high -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_NetDelay_low -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_Retiming -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_ExtraTimingOpt -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_RefinePlacement -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_SpreadSLLs -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_BalanceSLLs -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_BalanceSLRs -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Performance_HighUtilSLRs -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Congestion_SpreadLogic_high -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Congestion_SpreadLogic_medium -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Congestion_SpreadLogic_low -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Congestion_SSI_SpreadLogic_high -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Congestion_SSI_SpreadLogic_low -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Area_Explore -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Area_ExploreSequential -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Area_ExploreWithRemap -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Power_DefaultOpt -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Power_ExploreArea -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Flow_RunPhysOpt -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Flow_RunPostRoutePhysOpt -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Flow_RuntimeOptimized -parent_run synth_1 -flow {Vivado IDR Flow 2023} 
create_run i_impl_Flow_Quick -parent_run synth_1 -flow {Vivado IDR Flow 2023} 

set_property REFERENCE_RUN impl_default [get_runs i_impl_default] 
set_property REFERENCE_RUN impl_Performance_Auto_1 [get_runs i_impl_Performance_Auto_1] 
set_property REFERENCE_RUN impl_Performance_Auto_2 [get_runs i_impl_Performance_Auto_2] 
set_property REFERENCE_RUN impl_Performance_Auto_3 [get_runs i_impl_Performance_Auto_3] 
set_property REFERENCE_RUN impl_Performance_Explore [get_runs i_impl_Performance_Explore] 
set_property REFERENCE_RUN impl_Performance_ExplorePostRoutePhysOpt [get_runs i_impl_Performance_ExplorePostRoutePhysOpt] 
set_property REFERENCE_RUN impl_Performance_ExploreWithRemap [get_runs i_impl_Performance_ExploreWithRemap] 
set_property REFERENCE_RUN impl_Performance_WLBlockPlacement [get_runs i_impl_Performance_WLBlockPlacement] 
set_property REFERENCE_RUN impl_Performance_WLBlockPlacementFanoutOpt [get_runs i_impl_Performance_WLBlockPlacementFanoutOpt] 
set_property REFERENCE_RUN impl_Performance_EarlyBlockPlacement [get_runs i_impl_Performance_EarlyBlockPlacement] 
set_property REFERENCE_RUN impl_Performance_NetDelay_high [get_runs i_impl_Performance_NetDelay_high] 
set_property REFERENCE_RUN impl_Performance_NetDelay_low [get_runs i_impl_Performance_NetDelay_low] 
set_property REFERENCE_RUN impl_Performance_Retiming [get_runs i_impl_Performance_Retiming] 
set_property REFERENCE_RUN impl_Performance_ExtraTimingOpt [get_runs i_impl_Performance_ExtraTimingOpt] 
set_property REFERENCE_RUN impl_Performance_RefinePlacement [get_runs i_impl_Performance_RefinePlacement] 
set_property REFERENCE_RUN impl_Performance_SpreadSLLs [get_runs i_impl_Performance_SpreadSLLs] 
set_property REFERENCE_RUN impl_Performance_BalanceSLLs [get_runs i_impl_Performance_BalanceSLLs] 
set_property REFERENCE_RUN impl_Performance_BalanceSLRs [get_runs i_impl_Performance_BalanceSLRs] 
set_property REFERENCE_RUN impl_Performance_HighUtilSLRs [get_runs i_impl_Performance_HighUtilSLRs] 
set_property REFERENCE_RUN impl_Congestion_SpreadLogic_high [get_runs i_impl_Congestion_SpreadLogic_high] 
set_property REFERENCE_RUN impl_Congestion_SpreadLogic_medium [get_runs i_impl_Congestion_SpreadLogic_medium] 
set_property REFERENCE_RUN impl_Congestion_SpreadLogic_low [get_runs i_impl_Congestion_SpreadLogic_low] 
set_property REFERENCE_RUN impl_Congestion_SSI_SpreadLogic_high [get_runs i_impl_Congestion_SSI_SpreadLogic_high] 
set_property REFERENCE_RUN impl_Congestion_SSI_SpreadLogic_low [get_runs i_impl_Congestion_SSI_SpreadLogic_low] 
set_property REFERENCE_RUN impl_Area_Explore [get_runs i_impl_Area_Explore] 
set_property REFERENCE_RUN impl_Area_ExploreSequential [get_runs i_impl_Area_ExploreSequential] 
set_property REFERENCE_RUN impl_Area_ExploreWithRemap [get_runs i_impl_Area_ExploreWithRemap] 
set_property REFERENCE_RUN impl_Power_DefaultOpt [get_runs i_impl_Power_DefaultOpt] 
set_property REFERENCE_RUN impl_Power_ExploreArea [get_runs i_impl_Power_ExploreArea] 
set_property REFERENCE_RUN impl_Flow_RunPhysOpt [get_runs i_impl_Flow_RunPhysOpt] 
set_property REFERENCE_RUN impl_Flow_RunPostRoutePhysOpt [get_runs i_impl_Flow_RunPostRoutePhysOpt] 
set_property REFERENCE_RUN impl_Flow_RuntimeOptimized [get_runs i_impl_Flow_RuntimeOptimized] 
set_property REFERENCE_RUN impl_Flow_Quick [get_runs i_impl_Flow_Quick] 