// The monitor has a virtual interface handle with which it can monitor
// the events happening on the interface. It sees new transactions and then
// captures information into a packet and sends it to the scoreboard
// using another mailbox.
class monitor;
  virtual adder_if  m_adder_vif;
  virtual clk_if    m_clk_vif;
  
  mailbox scb_mbx;      // Mailbox connected to scoreboard
  
  task run();
    $display ("T=%0t [Monitor] starting ...", $time);
    
    // Check forever at every clock edge to see if there is a 
    // valid transaction and if yes, capture info into a class
    // object and send it to the scoreboard when the transaction 
    // is over.
    forever begin
      Packet m_pkt = new();
      @(posedge m_clk_vif.tb_clk);
      #1;
        m_pkt.a     = m_adder_vif.a;
        m_pkt.b     = m_adder_vif.b;
        m_pkt.rstn  = m_adder_vif.rstn;
        m_pkt.sum   = m_adder_vif.sum;
        m_pkt.carry = m_adder_vif.carry;
        m_pkt.print("Monitor");
      scb_mbx.put(m_pkt);
    end
  endtask
endclass
