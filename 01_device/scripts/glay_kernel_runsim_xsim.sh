
pwd

xvlog -f ../../scripts/glay_kernel_filelist.f   -i ../../IP/iob_cache/iob_include \
      -L xilinx_vip                       \
      --sv # -d DUMP_WAVEFORM
      
xelab glay_kernel_testbench glbl                 \
      -debug typical        \
      -L unisims_ver        \
      -L xpm                \
      -L xilinx_vip

xsim -t ../../scripts/glay_kernel_xsim.tcl --wdb work.glay_kernel_testbench.wdb work.glay_kernel_testbench#work.glbl