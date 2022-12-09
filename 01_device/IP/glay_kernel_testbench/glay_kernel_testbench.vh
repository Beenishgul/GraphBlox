//
// Copyright 2021 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// Tasks for glay_kernel_testbench

class GraphCSR;

     bit [VERTEX_DATA_BITS-1:0] vertex_count = 0;
     bit [VERTEX_DATA_BITS-1:0] edge_count   = 0;

     function new ();
      this.vertex_count = 0;
      this.edge_count = 0;

     endfunction

endclass

/////////////////////////////////////////////////////////////////////////////////////////////////
// Initial VIPs
task automatic init_vips();
  axi_ready_gen     rgen;

  $display("Starting AXI Control Master: glay_ctrl_mst");

  glay_ctrl_mst = new("glay_ctrl_mst", glay_kernel_testbench.axi_vip_mst_glay.inst.IF);
  glay_ctrl_mst.start_master();

  $display("Starting Memory slave: glay_mem_slv");

  glay_mem_slv_buf = new("glay_mem_slv_buf", glay_kernel_testbench.axi_vip_slv_in_out_buf.inst.IF);
  glay_mem_slv_buf.start_slave();

// Applying slv_random_backpressure_wready
  rgen = new("axi_random_backpressure_wready");
  rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
  rgen.set_low_time_range(0,20);
  rgen.set_high_time_range(1,20);
  rgen.set_event_count_range(3,5);
  glay_mem_slv_buf.wr_driver.set_wready_gen(rgen);
// Applying slv_random_delay_rvalid
  glay_mem_slv_buf.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_RANDOM);
  glay_mem_slv_buf.mem_model.set_inter_beat_gap_range(0,20);

endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Control interface blocking write
// The task will return when the BRESP has been returned from the kernel.
task automatic blocking_write_register (input axi_vip_mst_mst_t ctrl, input bit [31:0] addr_in, input bit [31:0] data);
  axi_transaction   wr_xfer;
  axi_transaction   wr_rsp;
  wr_xfer = ctrl.wr_driver.create_transaction("wr_xfer");
  wr_xfer.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
  assert(wr_xfer.randomize() with {addr == addr_in;});
  wr_xfer.set_data_beat(0, data);
  ctrl.wr_driver.send(wr_xfer);
  ctrl.wr_driver.wait_rsp(wr_rsp);
endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Control interface blocking read
// The task will return when the BRESP has been returned from the kernel.
task automatic read_register (input axi_vip_mst_mst_t ctrl, input bit [31:0] addr, output bit [31:0] rddata);
  axi_transaction   rd_xfer;
  axi_transaction   rd_rsp;
  bit [31:0] rd_value;
  rd_xfer = ctrl.rd_driver.create_transaction("rd_xfer");
  rd_xfer.set_addr(addr);
  rd_xfer.set_driver_return_item_policy(XIL_AXI_PAYLOAD_RETURN);
  ctrl.rd_driver.send(rd_xfer);
  ctrl.rd_driver.wait_rsp(rd_rsp);
  rd_value = rd_rsp.get_data_beat(0);
  rddata = rd_value;
endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// CTRL register operation
// This will poll until the DONE flag in the status register is asserted.
task automatic poll_done_register (input axi_vip_mst_mst_t ctrl);
  bit [31:0] rd_value;
  do begin
    read_register(ctrl, KRNL_CTRL_REG_ADDR, rd_value);
  end while ((rd_value & CTRL_DONE_MASK) == 0);
endtask

// This will poll until the IDLE flag in the status register is asserted.
task automatic poll_idle_register (input axi_vip_mst_mst_t ctrl);
  bit [31:0] rd_value;
  do begin
    read_register(ctrl, KRNL_CTRL_REG_ADDR, rd_value);
  end while ((rd_value & CTRL_IDLE_MASK) == 0);
endtask

// This will poll until the READY flag in the status register is asserted.
task automatic poll_ready_register (input axi_vip_mst_mst_t ctrl);
  bit [31:0] rd_value;
  do begin
    read_register(ctrl, KRNL_CTRL_REG_ADDR, rd_value);
  end while ((rd_value & CTRL_READY_MASK) == 0);
endtask

// This will set START flag
task automatic set_start_register (input axi_vip_mst_mst_t ctrl);
  blocking_write_register(ctrl, KRNL_CTRL_REG_ADDR, CTRL_START_MASK);
endtask

// This will set CONTINUE flag
task automatic set_continue_register (input axi_vip_mst_mst_t ctrl);
  blocking_write_register(ctrl, KRNL_CTRL_REG_ADDR, CTRL_CONTINUE_MASK);
endtask

// This will poll the START flag in the status register is DE-asserted.
task automatic poll_start_register (input axi_vip_mst_mst_t ctrl);
  bit [31:0] rd_value;
  do begin
    read_register(ctrl, KRNL_CTRL_REG_ADDR, rd_value);
  end while ((rd_value & CTRL_START_MASK) != 0);
endtask


/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the input buffer AXI vip memory model with 128-bit words
function void in_buffer_fill_memory(
    input axi_vip_slv_slv_mem_t mem,      // vip memory model handle
    input bit [63:0] ptr,                 // start address of memory fill, should allign to 16-byte
    input bit [511:0] words_data[$],      // data source to fill memory
    input integer offset,                 // start index of data source
    input integer words                   // number of words to fill
  );
  int index;
  bit [511:0] temp;
  int i;
  for (index = 0; index < words; index++) begin
    for (i = 0; i < 16; i = i + 1) begin // endian conversion to emulate general memory little endian behavior
      temp[i*8+7-:8] = words_data[offset+index][(15-i)*8+7-:8];
    end
    mem.mem_model.backdoor_memory_write(ptr + index * 16, temp);
  end
endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor dump data from outputt buffer AXI vip memory model with 128-bit words
function void out_buffer_dump_memory(
    input axi_vip_slv_slv_mem_t mem,      // vip memory model handle
    input bit [63:0] ptr,                 // start address of memory fill, should allign to 16-byte
    inout bit [511:0] words_data[$],      // data source to fill memory
    input integer offset,                 // start index of data source
    input integer words                   // number of words to fill
  );
  int index;
  bit [511:0] temp;
  int i;
  for (index = 0; index < words; index++) begin
    temp = mem.mem_model.backdoor_memory_read(ptr + index * 16);
    for (i = 0; i < 16; i = i + 1) begin // endian conversion to emulate general memory little endian behavior
      words_data[offset+index][i*8+7-:8] = temp[(15-i)*8+7-:8];
    end
  end
endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// compare two 128-bit array of `WORD_NUM words
function int words_compare(
    input bit [511:0] exp_words[$],
    input bit [511:0] act_words[$],
    input integer words
  );
  int index;
  int success;
  success = 1;
  for (index = 0; index < words; index++) begin
    if (exp_words[index] != act_words[index]) begin
      $display("  -- MISMATCH at word %d: exp = %x, act = %x", index, exp_words[index], act_words[index]);
      success = 0;
    end
  end
  return(success);
endfunction
