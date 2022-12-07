
xvlog -f ./glay_kernel_filelist.f         \
      -L xilinx_vip                       \
      --sv # -d DUMP_WAVEFORM
      
xelab glay_kernel_tb glbl                 \
      -debug typical        \
      -L unisims_ver        \
      -L xpm                \
      -L xilinx_vip

xsim -t xsim.tcl --wdb work.glay_kernel_tb.wdb work.glay_kernel_tb#work.glbl