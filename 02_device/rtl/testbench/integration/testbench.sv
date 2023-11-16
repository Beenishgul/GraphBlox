// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ps / 1 ps
import axi_vip_pkg::*;
import slv_m00_axi_vip_pkg::*;
import control___KERNEL___vip_pkg::*;

import PKG_GLOBALS::*;
import PKG_AXI4::*;
import PKG_DESCRIPTOR::*;
import PKG_MEMORY::*;
import PKG_CACHE::*;

class GraphCSR;

    string  graph_name                    ;
    integer num_vertices                  ;
    integer num_edges                     ;
    integer num_auxiliary_1               ;
    integer num_auxiliary_2               ;
    integer mem512_num_vertices           ;
    integer mem512_auxiliary_1            ;
    integer mem512_auxiliary_2            ;
    integer mem512_num_edges              ;
    integer mem512_overlay_program_entries;
    integer debug_counter_1               ;
    integer debug_counter_2               ;

    integer file_error               ;
    integer file_ptr_overlay_program ;
    integer file_ptr_edges_idx       ;
    integer file_ptr_in_degree       ;
    integer file_ptr_out_degree      ;
    integer file_ptr_edges_array_src ;
    integer file_ptr_edges_array_dest;

    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] overlay_program[];

    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] auxiliary_1[];
    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] auxiliary_2[];
    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] in_degree[];
    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] out_degree[];
    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] edges_idx[];
    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] edges_array_src[];
    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] edges_array_dest[];
    bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] edges_array_weight[];

    function new ();
        this.file_error                = 0;
        this.file_ptr_overlay_program  = 0;
        this.file_ptr_edges_idx        = 0;
        this.file_ptr_in_degree        = 0;
        this.file_ptr_out_degree       = 0;
        this.file_ptr_edges_array_src  = 0;
        this.file_ptr_edges_array_dest = 0;
        this.num_vertices              = 0;
        this.num_edges                 = 0;
        this.mem512_num_vertices       = 0;
        this.mem512_num_edges          = 0;
        this.num_auxiliary_1           = 0;
        this.num_auxiliary_2           = 0;
        this.mem512_auxiliary_1        = 0;
        this.mem512_auxiliary_2        = 0;
        this.debug_counter_1           = 0;
        this.debug_counter_2           = 0;
        this.mem512_overlay_program_entries = 4;
    endfunction

    function void display ();
        $display("---------------------------------------------------------------------------");
        $display("MSG: GRAPH CSR : %s", this.graph_name);
        $display("MSG: VERTEX COUNT : %0d", this.num_vertices);
        $display("MSG: EDGE COUNT   : %0d", this.num_edges);
        $display("---------------------------------------------------------------------------");
        $display("MSG: debug_counter_1  : %0d", this.debug_counter_1);
        $display("MSG: debug_counter_2  : %0d", this.debug_counter_2);
        $display("---------------------------------------------------------------------------");
    endfunction

endclass

module __KERNEL___testbench ();
    parameter integer LP_MAX_LENGTH              = 8192     ;
    parameter integer LP_MAX_TRANSFER_LENGTH     = 16384 / 4;
    parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12       ;
    parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32       ;
    parameter integer C_M00_AXI_ADDR_WIDTH       = 64       ;
    parameter integer C_M00_AXI_DATA_WIDTH       = 512      ;
    parameter integer C_M00_AXI_ID_WIDTH         = 1        ;

// Control Register
    parameter KRNL_CTRL_REG_ADDR     = 32'h00000000;
    parameter CTRL_START_MASK        = 32'h00000001;
    parameter CTRL_DONE_MASK         = 32'h00000002;
    parameter CTRL_IDLE_MASK         = 32'h00000004;
    parameter CTRL_READY_MASK        = 32'h00000008;
    parameter CTRL_CONTINUE_MASK     = 32'h00000010; // Only AP_CTRL_CHAIN
    parameter CTRL_AUTO_RESTART_MASK = 32'h00000080; // Not used

// Global Interrupt Enable Register
    parameter KRNL_GIE_REG_ADDR = 32'h00000004;
    parameter GIE_GIE_MASK      = 32'h00000001;
// IP Interrupt Enable Register
    parameter KRNL_IER_REG_ADDR = 32'h00000008;
    parameter IER_DONE_MASK     = 32'h00000001;
    parameter IER_READY_MASK    = 32'h00000002;
// IP Interrupt Status Register
    parameter KRNL_ISR_REG_ADDR = 32'h0000000c;
    parameter ISR_DONE_MASK     = 32'h00000001;
    parameter ISR_READY_MASK    = 32'h00000002;

    parameter integer LP_CLK_PERIOD_PS = 4000; // 250 MHz

//System Signals
    logic ap_clk = 0;

    initial begin: AP_CLK
        forever begin
            ap_clk = #(LP_CLK_PERIOD_PS/2) ~ap_clk;
        end
    end

//System Signals
    logic ap_rst_n      = 0;
    logic initial_reset = 0;

    task automatic ap_rst_n_sequence(input integer unsigned width = 20);
        @(posedge ap_clk);
        #1ps;
        ap_rst_n = 0;
        repeat (width) @(posedge ap_clk);
        #1ps;
        ap_rst_n = 1;
    endtask

    initial begin: AP_RST
        ap_rst_n_sequence(50);
        initial_reset =1;
    end

//AXI4 master interface m00_axi
    wire [                     1-1:0] m00_axi_awvalid;
    wire [                     1-1:0] m00_axi_awready;
    wire [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_awaddr ;
    wire [                     8-1:0] m00_axi_awlen  ;
    wire [                     1-1:0] m00_axi_wvalid ;
    wire [                     1-1:0] m00_axi_wready ;
    wire [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_wdata  ;
    wire [C_M00_AXI_DATA_WIDTH/8-1:0] m00_axi_wstrb  ;
    wire [                     1-1:0] m00_axi_wlast  ;
    wire [                     1-1:0] m00_axi_bvalid ;
    wire [                     1-1:0] m00_axi_bready ;
    wire [                     1-1:0] m00_axi_arvalid;
    wire [                     1-1:0] m00_axi_arready;
    wire [  C_M00_AXI_ADDR_WIDTH-1:0] m00_axi_araddr ;
    wire [                     8-1:0] m00_axi_arlen  ;
    wire [                     1-1:0] m00_axi_rvalid ;
    wire [                     1-1:0] m00_axi_rready ;
    wire [  C_M00_AXI_DATA_WIDTH-1:0] m00_axi_rdata  ;
    wire [                     1-1:0] m00_axi_rlast  ;

    // AXI4 master interface m00_axi missing ports
    wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_bid    ;
    wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_rid    ;
    wire [                 2-1:0] m00_axi_rresp  ;
    wire [                 2-1:0] m00_axi_bresp  ;
    wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_awid   ;
    wire [                 3-1:0] m00_axi_awsize ;
    wire [                 2-1:0] m00_axi_awburst;
    wire [                 1-1:0] m00_axi_awlock ;
    wire [                 4-1:0] m00_axi_awcache;
    wire [                 3-1:0] m00_axi_awprot ;
    wire [                 4-1:0] m00_axi_awqos  ;
    wire [C_M00_AXI_ID_WIDTH-1:0] m00_axi_arid   ;
    wire [                 3-1:0] m00_axi_arsize ;
    wire [                 2-1:0] m00_axi_arburst;
    wire [                 1-1:0] m00_axi_arlock ;
    wire [                 4-1:0] m00_axi_arcache;
    wire [                 3-1:0] m00_axi_arprot ;
    wire [                 4-1:0] m00_axi_arqos  ;

//AXI4LITE control signals
    wire [                           1-1:0] s_axi_control_awvalid;
    wire [                           1-1:0] s_axi_control_awready;
    wire [  C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_awaddr ;
    wire [                           1-1:0] s_axi_control_wvalid ;
    wire [                           1-1:0] s_axi_control_wready ;
    wire [  C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_wdata  ;
    wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb  ;
    wire [                           1-1:0] s_axi_control_arvalid;
    wire [                           1-1:0] s_axi_control_arready;
    wire [  C_S_AXI_CONTROL_ADDR_WIDTH-1:0] s_axi_control_araddr ;
    wire [                           1-1:0] s_axi_control_rvalid ;
    wire [                           1-1:0] s_axi_control_rready ;
    wire [  C_S_AXI_CONTROL_DATA_WIDTH-1:0] s_axi_control_rdata  ;
    wire [                           2-1:0] s_axi_control_rresp  ;
    wire [                           1-1:0] s_axi_control_bvalid ;
    wire [                           1-1:0] s_axi_control_bready ;
    wire [                           2-1:0] s_axi_control_bresp  ;
    wire                                    interrupt            ;

// DUT instantiation
    top #(
        .C_S_AXI_CONTROL_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH),
        .C_S_AXI_CONTROL_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH),
        .C_M00_AXI_ADDR_WIDTH      (C_M00_AXI_ADDR_WIDTH      ),
        .C_M00_AXI_DATA_WIDTH      (C_M00_AXI_DATA_WIDTH      )
    ) inst_dut (
        .ap_clk               (ap_clk               ),
        .ap_rst_n             (ap_rst_n             ),
        .m00_axi_awvalid      (m00_axi_awvalid      ),
        .m00_axi_awready      (m00_axi_awready      ),
        .m00_axi_awaddr       (m00_axi_awaddr       ),
        .m00_axi_awlen        (m00_axi_awlen        ),
        .m00_axi_wvalid       (m00_axi_wvalid       ),
        .m00_axi_wready       (m00_axi_wready       ),
        .m00_axi_wdata        (m00_axi_wdata        ),
        .m00_axi_wstrb        (m00_axi_wstrb        ),
        .m00_axi_wlast        (m00_axi_wlast        ),
        .m00_axi_bvalid       (m00_axi_bvalid       ),
        .m00_axi_bready       (m00_axi_bready       ),
        .m00_axi_arvalid      (m00_axi_arvalid      ),
        .m00_axi_arready      (m00_axi_arready      ),
        .m00_axi_araddr       (m00_axi_araddr       ),
        .m00_axi_arlen        (m00_axi_arlen        ),
        .m00_axi_rvalid       (m00_axi_rvalid       ),
        .m00_axi_rready       (m00_axi_rready       ),
        .m00_axi_rdata        (m00_axi_rdata        ),
        .m00_axi_rlast        (m00_axi_rlast        ),
        
        .m00_axi_bid          (m00_axi_bid          ),
        .m00_axi_rid          (m00_axi_rid          ),
        .m00_axi_rresp        (m00_axi_rresp        ),
        .m00_axi_bresp        (m00_axi_bresp        ),
        .m00_axi_awid         (m00_axi_awid         ),
        .m00_axi_awsize       (m00_axi_awsize       ),
        .m00_axi_awburst      (m00_axi_awburst      ),
        .m00_axi_awlock       (m00_axi_awlock       ),
        .m00_axi_awcache      (m00_axi_awcache      ),
        .m00_axi_awprot       (m00_axi_awprot       ),
        .m00_axi_awqos        (m00_axi_awqos        ),
        .m00_axi_arid         (m00_axi_arid         ),
        .m00_axi_arsize       (m00_axi_arsize       ),
        .m00_axi_arburst      (m00_axi_arburst      ),
        .m00_axi_arlock       (m00_axi_arlock       ),
        .m00_axi_arcache      (m00_axi_arcache      ),
        .m00_axi_arprot       (m00_axi_arprot       ),
        .m00_axi_arqos        (m00_axi_arqos        ),
        
        .s_axi_control_awvalid(s_axi_control_awvalid),
        .s_axi_control_awready(s_axi_control_awready),
        .s_axi_control_awaddr (s_axi_control_awaddr ),
        .s_axi_control_wvalid (s_axi_control_wvalid ),
        .s_axi_control_wready (s_axi_control_wready ),
        .s_axi_control_wdata  (s_axi_control_wdata  ),
        .s_axi_control_wstrb  (s_axi_control_wstrb  ),
        .s_axi_control_arvalid(s_axi_control_arvalid),
        .s_axi_control_arready(s_axi_control_arready),
        .s_axi_control_araddr (s_axi_control_araddr ),
        .s_axi_control_rvalid (s_axi_control_rvalid ),
        .s_axi_control_rready (s_axi_control_rready ),
        .s_axi_control_rdata  (s_axi_control_rdata  ),
        .s_axi_control_rresp  (s_axi_control_rresp  ),
        .s_axi_control_bvalid (s_axi_control_bvalid ),
        .s_axi_control_bready (s_axi_control_bready ),
        .s_axi_control_bresp  (s_axi_control_bresp  ),
        .interrupt            (interrupt            )
    );

// Master Control instantiation
    control___KERNEL___vip inst_control___KERNEL___vip (
        .aclk         (ap_clk               ),
        .aresetn      (ap_rst_n             ),
        .m_axi_awvalid(s_axi_control_awvalid),
        .m_axi_awready(s_axi_control_awready),
        .m_axi_awaddr (s_axi_control_awaddr ),
        .m_axi_wvalid (s_axi_control_wvalid ),
        .m_axi_wready (s_axi_control_wready ),
        .m_axi_wdata  (s_axi_control_wdata  ),
        .m_axi_wstrb  (s_axi_control_wstrb  ),
        .m_axi_arvalid(s_axi_control_arvalid),
        .m_axi_arready(s_axi_control_arready),
        .m_axi_araddr (s_axi_control_araddr ),
        .m_axi_rvalid (s_axi_control_rvalid ),
        .m_axi_rready (s_axi_control_rready ),
        .m_axi_rdata  (s_axi_control_rdata  ),
        .m_axi_rresp  (s_axi_control_rresp  ),
        .m_axi_bvalid (s_axi_control_bvalid ),
        .m_axi_bready (s_axi_control_bready ),
        .m_axi_bresp  (s_axi_control_bresp  )
    );

    control___KERNEL___vip_mst_t ctrl;

// Slave MM VIP instantiation
    slv_m00_axi_vip inst_slv_m00_axi_vip (
        .aclk         (ap_clk         ),
        .aresetn      (ap_rst_n       ),
        .s_axi_awvalid(m00_axi_awvalid),
        .s_axi_awready(m00_axi_awready),
        .s_axi_awaddr (m00_axi_awaddr ),
        .s_axi_awlen  (m00_axi_awlen  ),
        .s_axi_wvalid (m00_axi_wvalid ),
        .s_axi_wready (m00_axi_wready ),
        .s_axi_wdata  (m00_axi_wdata  ),
        .s_axi_wstrb  (m00_axi_wstrb  ),
        .s_axi_wlast  (m00_axi_wlast  ),
        .s_axi_bvalid (m00_axi_bvalid ),
        .s_axi_bready (m00_axi_bready ),
        .s_axi_arvalid(m00_axi_arvalid),
        .s_axi_arready(m00_axi_arready),
        .s_axi_araddr (m00_axi_araddr ),
        .s_axi_arlen  (m00_axi_arlen  ),
        .s_axi_rvalid (m00_axi_rvalid ),
        .s_axi_rready (m00_axi_rready ),
        .s_axi_rdata  (m00_axi_rdata  ),
        .s_axi_rlast  (m00_axi_rlast  ),
        
        .s_axi_bid    (m00_axi_bid    ),
        .s_axi_rid    (m00_axi_rid    ),
        .s_axi_rresp  (m00_axi_rresp  ),
        .s_axi_bresp  (m00_axi_bresp  ),
        .s_axi_awid   (m00_axi_awid   ),
        .s_axi_awsize (m00_axi_awsize ),
        .s_axi_awburst(m00_axi_awburst),
        .s_axi_awlock (m00_axi_awlock ),
        .s_axi_awcache(m00_axi_awcache),
        .s_axi_awprot (m00_axi_awprot ),
        .s_axi_awqos  (m00_axi_awqos  ),
        .s_axi_arid   (m00_axi_arid   ),
        .s_axi_arsize (m00_axi_arsize ),
        .s_axi_arburst(m00_axi_arburst),
        .s_axi_arlock (m00_axi_arlock ),
        .s_axi_arcache(m00_axi_arcache),
        .s_axi_arprot (m00_axi_arprot ),
        .s_axi_arqos  (m00_axi_arqos  )
    );

    slv_m00_axi_vip_slv_mem_t m00_axi    ;
    slv_m00_axi_vip_slv_t     m00_axi_slv;

    parameter NUM_AXIS_MST   = 0;
    parameter NUM_AXIS_SLV   = 0;
    parameter NUM_AXIS_PAIRS = 0;
    bit       error_found    = 0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_0_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_1_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_2_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_3_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_4_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_5_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_6_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_7_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_8_ptr = 64'h0;

///////////////////////////////////////////////////////////////////////////
// Pointer for interface : m00_axi
    bit [63:0] buffer_9_ptr = 64'h0;

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the input buffer AXI vip memory model with 32-bit words
    function void  m00_axi_buffer_fill_memory(
            input slv_m00_axi_vip_slv_mem_t mem,      // vip memory model handle
            input bit [63:0] ptr,                     // start address of memory fill, should allign to 16-byte
            input bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] words_data[$],      // data source to fill memory
            input integer offset,                 // start index of data source
            input integer words                   // number of words to fill
        );
        int index;
        // bit [(32/8)-1:0] wr_strb = 4'hf;
        bit [M_AXI_MEMORY_DATA_WIDTH_BITS-1:0] temp;
        int i;
        for (index = 0; index < words; index++) begin
            // $display("Before: %0d ->%0d ->%0h",index, i, words_data[offset+index]);
            for (i = 0; i < (M_AXI_MEMORY_DATA_WIDTH_BITS/8); i = i + 1) begin // endian conversion to emulate general memory little endian behavior
                temp[i*8+7-:8] = words_data[offset+index][((M_AXI_MEMORY_DATA_WIDTH_BITS/8)-1-i)*8+7-:8];
                // $display("%0d ->%0d ->%0h",index, i, temp[i*8+7-:8] );
            end
            // $display("After: %0d ->%0d ->%0h",index, i, temp);
            mem.mem_model.backdoor_memory_write(ptr + index * (M_AXI_MEMORY_DATA_WIDTH_BITS/8), temp);
        end
    endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the m00_axi memory.
    function void m00_axi_fill_memory(
            input bit [63:0] ptr,
            input integer    length
        );
        for (longint unsigned slot = 0; slot < length; slot++) begin
            m00_axi.mem_model.backdoor_memory_write_4byte(ptr + (slot * 4), slot);
        end
    endfunction

    task automatic system_reset_sequence(input integer unsigned width = 20);
        $display("%t : Starting System Reset Sequence", $time);
        fork
            ap_rst_n_sequence(25);
        join

    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Generate a random 32bit number
    function bit [31:0] get_random_4bytes();
        bit [31:0] rptr;
        ptr_random_failed : assert(std::randomize(rptr));
        return(rptr);
    endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Generate a random 64bit 4k aligned address pointer.
    function bit [63:0] get_random_ptr();
        bit [63:0] rptr;
        ptr_random_failed : assert(std::randomize(rptr));
        rptr[31:0] &= ~(32'h00000fff);
        return(rptr);
    endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Generate a random bit number
    function bit get_random_bit();
        bit rptr;
        ptr_random_failed : assert(std::randomize(rptr));
        return(rptr);
    endfunction


/////////////////////////////////////////////////////////////////////////////////////////////////
// Control interface non-blocking write
// The task will return when the transaction has been accepted by the driver. It will be some
// amount of time before it will appear on the interface.
    task automatic write_register (input bit [31:0] addr_in, input bit [31:0] data);
        axi_transaction   wr_xfer;
        wr_xfer = ctrl.wr_driver.create_transaction("wr_xfer");
        assert(wr_xfer.randomize() with {addr == addr_in;});
        wr_xfer.set_data_beat(0, data);
        ctrl.wr_driver.send(wr_xfer);
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Control interface blocking write
// The task will return when the BRESP has been returned from the __KERNEL__.
    task automatic blocking_write_register (input bit [31:0] addr_in, input bit [31:0] data);
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
// The task will return when the BRESP has been returned from the __KERNEL__.
    task automatic read_register (input bit [31:0] addr, output bit [31:0] rddata);
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
// Poll the Control interface status register.
// This will poll until the DONE flag in the status register is asserted.
    task automatic poll_done_register ();
        bit [31:0] rd_value;
        do begin
            read_register(KRNL_CTRL_REG_ADDR, rd_value);
        end while ((rd_value & CTRL_DONE_MASK) == 0);
    endtask

// This will poll until the IDLE flag in the status register is asserted.
    task automatic poll_idle_register ();
        bit [31:0] rd_value;
        do begin
            read_register(KRNL_CTRL_REG_ADDR, rd_value);
        end while ((rd_value & CTRL_IDLE_MASK) == 0);
    endtask

// This will poll until the IDLE flag in the status register is asserted.
    task automatic poll_ready_register ();
        bit [31:0] rd_value;
        do begin
            read_register(KRNL_CTRL_REG_ADDR, rd_value);
        end while ((rd_value & CTRL_READY_MASK) == 0);
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Write to the control registers to enable the triggering of interrupts for the __KERNEL__
    task automatic enable_interrupts();
        $display("Starting: Enabling Interrupts....");
        write_register(KRNL_GIE_REG_ADDR, GIE_GIE_MASK);
        write_register(KRNL_IER_REG_ADDR, IER_DONE_MASK);
        $display("Finished: Interrupts enabled.");
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Disabled the interrupts.
    task automatic disable_interrupts();
        $display("Starting: Disable Interrupts....");
        write_register(KRNL_GIE_REG_ADDR, 32'h0);
        write_register(KRNL_IER_REG_ADDR, 32'h0);
        $display("Finished: Interrupts disabled.");
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
//When the interrupt is asserted, read the correct registers and clear the asserted interrupt.
    task automatic service_interrupts();
        bit [31:0] rd_value;
        $display("Starting Servicing interrupts....");
        read_register(KRNL_CTRL_REG_ADDR, rd_value);
        $display("MSG: Control Register: 0x%0x", rd_value);

        blocking_write_register(KRNL_CTRL_REG_ADDR, CTRL_CONTINUE_MASK);

        if ((rd_value & CTRL_DONE_MASK) == 0) begin
            $error("%t : DONE bit not asserted. Register value: (0x%0x)", $time, rd_value);
        end
        read_register(KRNL_ISR_REG_ADDR, rd_value);
        $display("MSG: Interrupt Status Register: 0x%0x", rd_value);
        blocking_write_register(KRNL_ISR_REG_ADDR, rd_value);
        $display("Finished Servicing interrupts");
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Start the control VIP, SLAVE memory models and AXI4-Stream.
    task automatic start_vips();

        $display("///////////////////////////////////////////////////////////////////////////");
        $display("MSG: Control Master: ctrl");
        ctrl = new("ctrl", __KERNEL___testbench.inst_control___KERNEL___vip.inst.IF);
        ctrl.start_master();

        $display("///////////////////////////////////////////////////////////////////////////");
        $display("Starting Memory slave: m00_axi");
        m00_axi = new("m00_axi", __KERNEL___testbench.inst_slv_m00_axi_vip.inst.IF);
        m00_axi.start_slave();

    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, set the Slave to not de-assert WREADY at any time.
// This will show the fastest outbound bandwidth from the WRITE channel.
    task automatic slv_no_backpressure_wready();
        axi_ready_gen     rgen;
        $display("%t - Applying slv_no_backpressure_wready", $time);

        rgen = new("m00_axi_no_backpressure_wready");
        rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
        m00_axi.wr_driver.set_wready_gen(rgen);

    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, apply a WREADY policy to introduce backpressure.
// Based on the simulation seed the order/shape of the WREADY per-channel will be different.
    task automatic slv_random_backpressure_wready();
        axi_ready_gen     rgen;
        $display("%t - Applying slv_random_backpressure_wready", $time);

        rgen = new("m00_axi_random_backpressure_wready");
        rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
        rgen.set_low_time_range(0,12);
        rgen.set_high_time_range(1,12);
        rgen.set_event_count_range(3,5);
        m00_axi.wr_driver.set_wready_gen(rgen);

    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, force the memory model to not insert any inter-beat
// gaps on the READ channel.
    task automatic slv_no_delay_rvalid();
        $display("%t - Applying slv_no_delay_rvalid", $time);

        m00_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_FIXED);
        m00_axi.mem_model.set_inter_beat_gap(0);

    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, Allow the memory model to insert any inter-beat
// gaps on the READ channel.
    task automatic slv_random_delay_rvalid();
        $display("%t - Applying slv_random_delay_rvalid", $time);

        m00_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_RANDOM);
        m00_axi.mem_model.set_inter_beat_gap_range(0,10);

    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Check to ensure, following reset the value of the register is 0.
// Check that only the width of the register bits can be written.
    task automatic check_register_value(input bit [31:0] addr_in, input integer unsigned register_width, output bit error_found);
        bit [31:0] rddata;
        bit [31:0] mask_data;
        error_found = 0;
        if (register_width < 32) begin
            mask_data = (1 << register_width) - 1;
        end else begin
            mask_data = 32'hffffffff;
        end
        read_register(addr_in, rddata);
        if (rddata != 32'h0) begin
            $error("MSG: Initial value mismatch: A:0x%0x : Expected 0x%x -> Got 0x%x", addr_in, 0, rddata);
            error_found = 1;
        end
        blocking_write_register(addr_in, 32'hffffffff);
        read_register(addr_in, rddata);
        if (rddata != mask_data) begin
            $error("MSG: Initial value mismatch: A:0x%0x : Expected 0x%x -> Got 0x%x", addr_in, mask_data, rddata);
            error_found = 1;
        end
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the scalar registers, check:
// * reset value
// * correct number bits set on a write
    task automatic check_scalar_registers(output bit error_found);
        bit tmp_error_found = 0;
        error_found = 0;
        $display("%t : Checking post reset values of scalar registers", $time);

    endtask

    task automatic set_scalar_registers();
        $display("%t : Setting Scalar Registers registers", $time);

    endtask

    task automatic check_pointer_registers(output bit error_found);
        bit tmp_error_found = 0;
        ///////////////////////////////////////////////////////////////////////////
        //Check the reset states of the pointer registers.
        $display("%t : Checking post reset values of pointer registers", $time);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 0: buffer_0 (0x010)
        check_register_value(32'h010, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 0: buffer_0 (0x014)
        check_register_value(32'h014, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 1: buffer_1 (0x01c)
        check_register_value(32'h01c, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 1: buffer_1 (0x020)
        check_register_value(32'h020, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 2: buffer_2 (0x028)
        check_register_value(32'h028, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 2: buffer_2 (0x02c)
        check_register_value(32'h02c, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 3: buffer_3 (0x034)
        check_register_value(32'h034, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 3: buffer_3 (0x038)
        check_register_value(32'h038, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 4: buffer_4 (0x040)
        check_register_value(32'h040, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 4: buffer_4 (0x044)
        check_register_value(32'h044, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 5: buffer_5 (0x04c)
        check_register_value(32'h04c, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 5: buffer_5 (0x050)
        check_register_value(32'h050, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 6: buffer_6 (0x058)
        check_register_value(32'h058, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 6: buffer_6 (0x05c)
        check_register_value(32'h05c, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 7: buffer_7 (0x064)
        check_register_value(32'h064, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 7: buffer_7 (0x068)
        check_register_value(32'h068, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 8: buffer_8 (0x070)
        check_register_value(32'h070, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 8: buffer_8 (0x074)
        check_register_value(32'h074, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 9: buffer_9 (0x07c)
        check_register_value(32'h07c, 32, tmp_error_found);
        error_found |= tmp_error_found;

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 9: buffer_9 (0x080)
        check_register_value(32'h080, 32, tmp_error_found);
        error_found |= tmp_error_found;

    endtask

    task automatic set_memory_pointers();
        ///////////////////////////////////////////////////////////////////////////
        //Randomly generate memory pointers.
        buffer_0_ptr[62:0] = get_random_ptr();
        buffer_1_ptr[62:0] = get_random_ptr();
        buffer_2_ptr[62:0] = get_random_ptr();
        buffer_3_ptr[62:0] = get_random_ptr();
        buffer_4_ptr[62:0] = get_random_ptr();
        buffer_5_ptr[62:0] = get_random_ptr();
        buffer_6_ptr[62:0] = get_random_ptr();
        buffer_7_ptr[62:0] = get_random_ptr();
        buffer_8_ptr[62:0] = get_random_ptr();
        buffer_9_ptr = {(SYSTEM_CACHE_SIZE_ITERAIONS +_NUM_ENTRIES_),31'd_NUM_ENTRIES_, 1'b1};

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 0: buffer_0 (0x010) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h010, buffer_0_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 0: buffer_0 (0x014) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h014, buffer_0_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 1: buffer_1 (0x01c) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h01c, buffer_1_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 1: buffer_1 (0x020) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h020, buffer_1_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 2: buffer_2 (0x028) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h028, buffer_2_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 2: buffer_2 (0x02c) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h02c, buffer_2_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 3: buffer_3 (0x034) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h034, buffer_3_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 3: buffer_3 (0x038) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h038, buffer_3_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 4: edges_array_weight (0x040) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h040, buffer_4_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 4: edges_array_weight (0x044) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h044, buffer_4_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 5: edges_array_src (0x04c) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h04c, buffer_5_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 5: edges_array_src (0x050) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h050, buffer_5_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 6: edges_array_dest (0x058) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h058, buffer_6_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 6: edges_array_dest (0x05c) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h05c, buffer_6_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 7: buffer_7 (0x064) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h064, buffer_7_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 7: buffer_7 (0x068) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h068, buffer_7_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 8: buffer_8 (0x070) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h070, buffer_8_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 8: buffer_8 (0x074) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h074, buffer_8_ptr[63:32]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 9: buffer_9 (0x07c) -> Randomized 4k aligned address (Global memory, lower 32 bits)
        write_register(32'h07c, buffer_9_ptr[31:0]);

        ///////////////////////////////////////////////////////////////////////////
        //Write ID 9: buffer_9 (0x080) -> Randomized 4k aligned address (Global memory, upper 32 bits)
        write_register(32'h080, buffer_9_ptr[63:32]);

    endtask

    task automatic backdoor_fill_memories();

        /////////////////////////////////////////////////////////////////////////////////////////////////
        // Backdoor fill the memory with the content.
        m00_axi_fill_memory(buffer_0_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_1_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_2_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_3_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_4_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_5_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_6_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_7_ptr, LP_MAX_LENGTH);
        m00_axi_fill_memory(buffer_8_ptr, LP_MAX_LENGTH);

    endtask

    task automatic backdoor_buffer_fill_memories(ref GraphCSR graph);
        /////////////////////////////////////////////////////////////////////////////////////////////////
        // Backdoor fill the memory with the content.
        m00_axi_buffer_fill_memory(m00_axi, buffer_0_ptr, graph.overlay_program, 0, graph.mem512_overlay_program_entries);
        m00_axi_buffer_fill_memory(m00_axi, buffer_1_ptr, graph.out_degree, 0, graph.mem512_num_vertices);
        m00_axi_buffer_fill_memory(m00_axi, buffer_2_ptr, graph.in_degree , 0, graph.mem512_num_vertices);
        m00_axi_buffer_fill_memory(m00_axi, buffer_3_ptr, graph.edges_idx , 0, graph.mem512_num_vertices);
        m00_axi_buffer_fill_memory(m00_axi, buffer_4_ptr, graph.edges_array_dest, 0, graph.mem512_num_edges);
        m00_axi_buffer_fill_memory(m00_axi, buffer_5_ptr, graph.edges_array_src, 0, graph.mem512_num_edges);
        m00_axi_buffer_fill_memory(m00_axi, buffer_6_ptr, graph.edges_array_weight, 0, graph.mem512_num_edges);
        m00_axi_buffer_fill_memory(m00_axi, buffer_7_ptr, graph.auxiliary_1 , 0, graph.mem512_auxiliary_1);
        m00_axi_buffer_fill_memory(m00_axi, buffer_8_ptr, graph.auxiliary_2 , 0, graph.mem512_auxiliary_2);

    endtask

    function automatic bit check___KERNEL___result();
        bit [31:0]        ret_rd_value = 32'h0;
        bit error_found = 0;
        integer error_counter;
        error_counter = 0;

        /////////////////////////////////////////////////////////////////////////////////////////////////
        // Checking memory connected to m00_axi
        for (longint unsigned slot = 0; slot < LP_MAX_LENGTH; slot++) begin
            ret_rd_value = m00_axi.mem_model.backdoor_memory_read_4byte(buffer_7_ptr + (slot * 4));
            if (slot < LP_MAX_TRANSFER_LENGTH) begin
                if (ret_rd_value != (slot + 1)) begin
                    $error("ERROR: Memory Mismatch: m00_axi : @0x%x : Expected 0x%x -> Got 0x%x ", buffer_7_ptr + (slot * 4), slot + 1, ret_rd_value);
                    error_found |= 1;
                    error_counter++;
                end
            end else begin
                if (ret_rd_value != slot) begin
                    $error("ERROR: Memory Mismatch: m00_axi : @0x%x : Expected 0x%x -> Got 0x%x ", buffer_7_ptr + (slot * 4), slot, ret_rd_value);
                    error_found |= 1;
                    error_counter++;
                end
            end
            if (error_counter > 5) begin
                $display("WARNING: Too many errors found. Exiting check of m00_axi.");
                slot = LP_MAX_LENGTH;
            end
        end
        error_counter = 0;

        return(error_found);
    endfunction

    bit         choose_pressure_type      = 0;
    bit         axis_choose_pressure_type = 0;
    bit [0-1:0] axis_tlast_received          ;

    GraphCSR graph;

    // Helper function to find the index of a substring within a string
    function int find_str(string str, string substr);
        automatic int i;
        automatic int str_len = str.len();
        automatic int substr_len = substr.len();
        find_str = -1; // Initialize as -1 (not found)
        for(i = 0; i <= str_len - substr_len; i++) begin
            if (str.substr(i, i + substr_len - 1) == substr) begin
                find_str = i; // Found
                break;
            end
        end
    endfunction


    function automatic void read_files_graphCSR(ref GraphCSR graph);

        // graph.overlay_program[0] = 0;
        // graph.overlay_program[1] = 0;
        // graph.overlay_program[2] = 0;
        // graph.overlay_program[3] = 0;

        // graph.overlay_program[0][0+:CACHE_FRONTEND_DATA_W] = graph.num_edges;
        // graph.overlay_program[0][CACHE_FRONTEND_DATA_W+:CACHE_FRONTEND_DATA_W] = graph.num_vertices;
        // graph.overlay_program[0][(64)+:64] = buffer_1_ptr;
        // graph.overlay_program[0][(64*2)+:64] = buffer_2_ptr;
        // graph.overlay_program[0][(64*3)+:64] = buffer_3_ptr;
        // graph.overlay_program[0][(64*4)+:64] = buffer_5_ptr;
        // graph.overlay_program[0][(64*5)+:64] = buffer_6_ptr;
        // graph.overlay_program[0][(64*6)+:64] = buffer_4_ptr;
        // graph.overlay_program[0][(64*7)+:64] = buffer_7_ptr;
        // graph.overlay_program[1][0+:64] = buffer_8_ptr;
        // graph.overlay_program[1][(64)+:64] = 1;

        int          realcount                 = 0;
        int          vertexcount               = 0;
        int o,l;
        bit [CACHE_FRONTEND_DATA_W-1:0] temp_overlay_program         ;
        bit [CACHE_FRONTEND_DATA_W-1:0] temp_out_degree              ;
        bit [CACHE_FRONTEND_DATA_W-1:0] temp_in_degree               ;
        bit [CACHE_FRONTEND_DATA_W-1:0] temp_edges_idx               ;

        bit [CACHE_FRONTEND_DATA_W-1:0] temp_edges_array_src ;
        bit [CACHE_FRONTEND_DATA_W-1:0] temp_edges_array_dest;
        bit [CACHE_FRONTEND_DATA_W-1:0] setup_temp;

        realcount = 0;
        setup_temp = 0;

        for (int i = 0; i < graph.mem512_overlay_program_entries; i++) begin
            for (int j = 0; j < (M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W); j++) begin
                graph.overlay_program[i][(CACHE_FRONTEND_DATA_W*j)+:CACHE_FRONTEND_DATA_W] = realcount;
                realcount++;
            end
        end

        // $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_overlay_program);

        o=0;
        l=0;
        while (!$feof(graph.file_ptr_overlay_program)) begin
            string line;
            string hex_str;
            int comment_index;
            int num_read;

            // read a line from the file
            if (!$fgets(line, graph.file_ptr_overlay_program))
                break;

            // find the comment start position using $strstr
            comment_index = find_str(line, "//");
            if (comment_index != -1)
                line = line.substr(0, comment_index - 1); // discarding the comment

            // remove leading and trailing spaces using a loop
            while (line.len() > 0 && {line[0]} == " ")
                line = line.substr(1, line.len() - 1);

            while (line.len() > 0 && {line[line.len() - 1]} == " ")
                line = line.substr(0, line.len() - 2);
            // parse hex number from the line
            if (line.len() > 0) begin
                num_read = $sscanf(line, "0x%h", temp_overlay_program); // Notice the format specifier used here
                if(num_read == 1) begin
                    // $display("MSG: %d %d Hex number: 32'h%0h",l,o, temp_overlay_program);
                    setup_temp = temp_overlay_program;
                    graph.overlay_program[l][(CACHE_FRONTEND_DATA_W*o)+:CACHE_FRONTEND_DATA_W] = setup_temp;
                    // $display("MSG: %d %d Hex number: 32'h%0h",l,o, graph.overlay_program[l][(CACHE_FRONTEND_DATA_W*o)+:CACHE_FRONTEND_DATA_W]);
                    o++;
                    if (o%(M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W) == 0) begin
                        l++;
                        o=0;
                    end
                end
            end
        end

        `include"buffer_mapping._ALGORITHM_NAME_.vh"

        // $display("MSG: Starting graph.mem512_num_vertices: %0d\n", graph.mem512_num_vertices);
        // $display("MSG: Starting graph.mem512_num_edges: %0d\n", graph.mem512_num_edges);

        for (int i = 0; i < graph.mem512_num_vertices; i++) begin
            for (int j = 0; j < (M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W); j++) begin
                graph.file_error =  $fscanf(graph.file_ptr_out_degree, "%0d\n",temp_out_degree);
                setup_temp = temp_out_degree;
                graph.out_degree[i][(CACHE_FRONTEND_DATA_W*j)+:CACHE_FRONTEND_DATA_W] = setup_temp;
                // $display("MSG: Starting temp_out_degree: %0d\n", graph.out_degree[i][j+:CACHE_FRONTEND_DATA_W]);

                graph.file_error =  $fscanf(graph.file_ptr_in_degree, "%0d\n",temp_in_degree);
                setup_temp = temp_in_degree;
                graph.in_degree[i][(CACHE_FRONTEND_DATA_W*j)+:CACHE_FRONTEND_DATA_W] = setup_temp;

                // $display("MSG: Starting temp_in_degree: %0d\n", temp_in_degree);
                graph.file_error =  $fscanf(graph.file_ptr_edges_idx, "%0d\n",temp_edges_idx);
                setup_temp = temp_edges_idx;
                graph.edges_idx[i][(CACHE_FRONTEND_DATA_W*j)+:CACHE_FRONTEND_DATA_W] = setup_temp;
                // $display("MSG: Starting temp_edges_idx: %0d\n", temp_edges_idx);
            end
        end

        o=0;
        l=0;

        for (int i = 0; i < graph.num_auxiliary_1; i++) begin
            graph.auxiliary_1[l][(CACHE_FRONTEND_DATA_W*o)+:CACHE_FRONTEND_DATA_W] = {CACHE_FRONTEND_DATA_W{1'b1}};
            o++;
            if (o%(M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W) == 0) begin
                l++;
                o=0;
            end
        end

        for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
            graph.auxiliary_1[l][(CACHE_FRONTEND_DATA_W*o)+:CACHE_FRONTEND_DATA_W] = 0;
            o++;
            if (o%(M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W) == 0) begin
                l++;
                o=0;
            end
        end

        o=0;
        l=0;

        for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
            setup_temp = {31'b0,get_random_bit()};
            if(setup_temp)
                graph.auxiliary_2[l][(CACHE_FRONTEND_DATA_W*o)+:CACHE_FRONTEND_DATA_W] ={CACHE_FRONTEND_DATA_W{1'b1}};
            else
                graph.auxiliary_2[l][(CACHE_FRONTEND_DATA_W*o)+:CACHE_FRONTEND_DATA_W] =5;
            o++;
            if (o%(M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W) == 0) begin
                l++;
                o=0;
            end
        end

        for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
            setup_temp = {31'b0,get_random_bit()};
            graph.debug_counter_2 += setup_temp;
            graph.auxiliary_2[l][(CACHE_FRONTEND_DATA_W*o)+:CACHE_FRONTEND_DATA_W] = setup_temp;
            o++;
            if (o%(M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W) == 0) begin
                l++;
                o=0;
            end
        end

        for (int i = 0; i < graph.mem512_num_edges; i++) begin
            for (int j = 0;j < (M_AXI_MEMORY_DATA_WIDTH_BITS/CACHE_FRONTEND_DATA_W); j++) begin
                graph.file_error =  $fscanf(graph.file_ptr_edges_array_src, "%0d\n",temp_edges_array_src);
                setup_temp = temp_edges_array_src;
                graph.edges_array_src[i][(CACHE_FRONTEND_DATA_W*j)+:CACHE_FRONTEND_DATA_W] = setup_temp;

                graph.file_error =  $fscanf(graph.file_ptr_edges_array_dest, "%0d\n",temp_edges_array_dest);
                setup_temp = temp_edges_array_dest;
                graph.edges_array_dest[i][(CACHE_FRONTEND_DATA_W*j)+:CACHE_FRONTEND_DATA_W] = setup_temp;
            end
        end

    endfunction : read_files_graphCSR

    task automatic initalize_graph (ref GraphCSR graph);
        graph.graph_name = "_GRAPH_NAME_";

        graph.file_ptr_overlay_program = $fopen("_FULL_SRC_IP_DIR_OVERLAY_/_ARCHITECTURE_._CAPABILITY_/_ALGORITHM_NAME_.ol", "r");
        if(graph.file_ptr_overlay_program) $display("File was opened successfully : %0d",graph.file_ptr_overlay_program);
        else                   $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_overlay_program);

        graph.file_ptr_in_degree = $fopen("_GRAPH_DIR_/_GRAPH_SUIT_/_GRAPH_NAME_/_FILE_BIN_TYPE_.in_degree", "r");
        if(graph.file_ptr_in_degree) $display("File was opened successfully : %0d",graph.file_ptr_in_degree);
        else                   $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_in_degree);

        graph.file_ptr_out_degree = $fopen("_GRAPH_DIR_/_GRAPH_SUIT_/_GRAPH_NAME_/_FILE_BIN_TYPE_.out_degree", "r");
        if(graph.file_ptr_out_degree) $display("File was opened successfully : %0d",graph.file_ptr_out_degree);
        else                    $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_out_degree);

        graph.file_ptr_edges_idx = $fopen("_GRAPH_DIR_/_GRAPH_SUIT_/_GRAPH_NAME_/_FILE_BIN_TYPE_.edges_idx", "r");
        if(graph.file_ptr_edges_idx) $display("File was opened successfully : %0d",graph.file_ptr_edges_idx);
        else                   $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_edges_idx);

        graph.file_ptr_edges_array_src = $fopen("_GRAPH_DIR_/_GRAPH_SUIT_/_GRAPH_NAME_/_FILE_BIN_TYPE_.edges_array_src", "r");
        if(graph.file_ptr_edges_array_src) $display("File was opened successfully : %0d",graph.file_ptr_edges_array_src);
        else                         $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_edges_array_src);

        graph.file_ptr_edges_array_dest= $fopen("_GRAPH_DIR_/_GRAPH_SUIT_/_GRAPH_NAME_/_FILE_BIN_TYPE_.edges_array_dest", "r");
        if(graph.file_ptr_edges_array_dest) $display("File was opened successfully : %0d",graph.file_ptr_edges_array_dest);
        else                          $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_edges_array_dest);

        graph.file_error =      $fscanf(graph.file_ptr_out_degree, "%d\n",graph.num_vertices);
        graph.file_error =      $fscanf(graph.file_ptr_edges_array_src, "%d\n",graph.num_edges);

        graph.num_auxiliary_1 = graph.num_vertices;
        graph.num_auxiliary_2 = graph.num_vertices;

        graph.mem512_overlay_program_entries = int'(buffer_9_ptr[CACHE_FRONTEND_DATA_W-1:1] + SYSTEM_CACHE_SIZE_ITERAIONS); // cachelines

        graph.mem512_num_vertices = ((graph.num_vertices*CACHE_FRONTEND_DATA_W) + (M_AXI_MEMORY_DATA_WIDTH_BITS-1) )/ (M_AXI_MEMORY_DATA_WIDTH_BITS);
        graph.mem512_num_edges = ((graph.num_edges*CACHE_FRONTEND_DATA_W) + (M_AXI_MEMORY_DATA_WIDTH_BITS-1) )/ (M_AXI_MEMORY_DATA_WIDTH_BITS);

        graph.mem512_auxiliary_1 = ((graph.num_auxiliary_1*CACHE_FRONTEND_DATA_W*2) + (M_AXI_MEMORY_DATA_WIDTH_BITS-1) )/ (M_AXI_MEMORY_DATA_WIDTH_BITS);
        graph.mem512_auxiliary_2 = ((graph.num_auxiliary_2*CACHE_FRONTEND_DATA_W*2) + (M_AXI_MEMORY_DATA_WIDTH_BITS-1) )/ (M_AXI_MEMORY_DATA_WIDTH_BITS);

        graph.out_degree   = new [graph.mem512_num_vertices];
        graph.in_degree    = new [graph.mem512_num_vertices];
        graph.edges_idx    = new [graph.mem512_num_vertices];
        graph.auxiliary_1  = new [graph.mem512_auxiliary_1];
        graph.auxiliary_2  = new [graph.mem512_auxiliary_2];
        graph.edges_array_src = new [graph.mem512_num_edges];
        graph.edges_array_dest= new [graph.mem512_num_edges];
        graph.overlay_program = new [graph.mem512_overlay_program_entries];

        read_files_graphCSR(graph);

        $fclose(graph.file_ptr_overlay_program);
        $fclose(graph.file_ptr_in_degree);
        $fclose(graph.file_ptr_out_degree);
        $fclose(graph.file_ptr_edges_idx);
        $fclose(graph.file_ptr_edges_array_src);
        $fclose(graph.file_ptr_edges_array_dest);

        graph.display();
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Set up the __KERNEL__ for operation and set the __KERNEL__ START bit.
// The task will poll the DONE bit and check the results when complete.
    task automatic multiple_iteration(input integer unsigned num_iterations, output bit error_found, ref GraphCSR graph);
        error_found = 0;

        $display("Starting: multiple_iteration");
        for (integer unsigned iter = 0; iter < num_iterations; iter++) begin

            $display("Starting iteration: %d / %d", iter+1, num_iterations);
            RAND_WREADY_PRESSURE_FAILED : assert(std::randomize(choose_pressure_type));
            case(choose_pressure_type)
                0 : slv_no_backpressure_wready();
                1 : slv_random_backpressure_wready();
            endcase
            RAND_RVALID_PRESSURE_FAILED : assert(std::randomize(choose_pressure_type));
            case(choose_pressure_type)
                0 : slv_no_delay_rvalid();
                1 : slv_random_delay_rvalid();
            endcase

            set_scalar_registers();
            set_memory_pointers();
            initalize_graph (graph);
            // backdoor_fill_memories();
            backdoor_buffer_fill_memories(graph);
            // Check that __KERNEL__ is IDLE before starting.
            poll_idle_register();
            ///////////////////////////////////////////////////////////////////////////
            //Start transfers
            blocking_write_register(KRNL_CTRL_REG_ADDR, CTRL_START_MASK);

            ctrl.wait_drivers_idle();

            poll_ready_register();

            poll_done_register();
            ///////////////////////////////////////////////////////////////////////////
            //Wait for interrupt being asserted or poll done register
            // @(posedge interrupt);
            // poll_done_register();
            ///////////////////////////////////////////////////////////////////////////
            // Service the interrupt
            // service_interrupts();
            // wait(interrupt == 0);

            ///////////////////////////////////////////////////////////////////////////
            // error_found |= check___KERNEL___result()   ;

            $display("Finished iteration: %d / %d", iter+1, num_iterations);
        end
    endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
//Instantiate AXI4 LITE VIP
    initial begin : STIMULUS

        graph = new();

        #200000;
        start_vips();
        check_scalar_registers(error_found);
        if (error_found == 1) begin
            $display( "ERROR: Test Failed!");
            $finish();
        end

        #1000
            check_pointer_registers(error_found);
        if (error_found == 1) begin
            $display( "ERROR: Test Failed!");
            $finish();
        end

        // enable_interrupts();
        disable_interrupts();

        #1000
            multiple_iteration(1, error_found, graph);
        if (error_found == 1) begin
            $display( "ERROR: Test Failed!");
            $finish();
        end

        #1000
            multiple_iteration(5, error_found, graph);

        if (error_found == 1) begin
            $display( "ERROR: Test Failed!");
            $finish();
        end else begin
            $display( "Test completed successfully");
        end

        #1000  $finish;

    end

// Waveform dump
    `ifdef DUMP_WAVEFORM
        initial begin
            $dumpfile("__KERNEL___testbench.vcd");
            $dumpvars(0,__KERNEL___testbench);
        end
    `endif

endmodule
`default_nettype wire

