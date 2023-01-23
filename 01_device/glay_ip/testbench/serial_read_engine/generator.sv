// Sometimes we simply need to generate N random transactions to random
// locations so a generator would be useful to do just that. In this case
// loop determines how many transactions need to be sent
class generator;
  int   loop = 10;
  event drv_done;
  mailbox drv_mbx;
  
  task run();
    for (int i = 0; i < loop; i++) begin
      Packet item = new;
      item.randomize();
      $display ("T=%0t [Generator] Loop:%0d/%0d create next item", $time, i+1, loop);
      drv_mbx.put(item);
      $display ("T=%0t [Generator] Wait for driver to be done", $time);
      @(drv_done);
    end
  endtask
endclass