// The test can instantiate any environment. In this test, we are using
// an environment without the generator and hence the stimulus should be 
// written in the test. 
class test;
  env e0;
  mailbox drv_mbx;
  
  function new();
    drv_mbx = new();
    e0 = new();
  endfunction
  
  virtual task run();
    e0.d0.drv_mbx = drv_mbx;
    e0.run();
  endtask
endclass