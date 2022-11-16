# clear all
set nfacs [ gtkwave::getNumFacs ]
set signals [list]
for {set i 0} {$i < $nfacs } {incr i} {
    set facname [ gtkwave::getFacName $i ]
    lappend signals "$facname"
}
gtkwave::deleteSignalsFromList $signals

# add instance port
set ports [list tb_iob_cache_axi.valid tb_iob_cache_axi.addr tb_iob_cache_axi.addr tb_iob_cache_axi.wdata tb_iob_cache_axi.wstrb tb_iob_cache_axi.rdata tb_iob_cache_axi.ready tb_iob_cache_axi.force_inv_in tb_iob_cache_axi.force_inv_out tb_iob_cache_axi.wtb_empty_in tb_iob_cache_axi.wtb_empty_out tb_iob_cache_axi.clk tb_iob_cache_axi.reset]
gtkwave::addSignalsFromList $ports
