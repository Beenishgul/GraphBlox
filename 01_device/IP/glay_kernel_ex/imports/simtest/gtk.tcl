# clear all
set nfacs [ gtkwave::getNumFacs ]
set signals [list]
for {set i 0} {$i < $nfacs } {incr i} {
    set facname [ gtkwave::getFacName $i ]
    lappend signals "$facname"
}
gtkwave::deleteSignalsFromList $signals

# add instance port
set ports [list tb_glay_kernel_example_counter.clk tb_glay_kernel_example_counter.clken tb_glay_kernel_example_counter.rst tb_glay_kernel_example_counter.load tb_glay_kernel_example_counter.incr tb_glay_kernel_example_counter.decr tb_glay_kernel_example_counter.load_value tb_glay_kernel_example_counter.count tb_glay_kernel_example_counter.is_zero]
gtkwave::addSignalsFromList $ports
