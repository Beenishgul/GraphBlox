// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ps / 1 ps
import axi_vip_pkg::*;
`include "module_slv_m_axi_vip_import.vh"
import control___KERNEL___vip_pkg::*;

`include "global_package.vh"

class GraphCSR;

string  graph_name     ;
integer num_vertices   ;
integer num_edges      ;
integer num_auxiliary_1;
integer num_auxiliary_2;
integer debug_counter_1;
integer debug_counter_2;
integer bfs_source     ;

integer mem_num_vertices      ;
integer mem_auxiliary_1       ;
integer mem_auxiliary_2       ;
integer mem_num_edges         ;
integer mem_overlay_program   ;
integer mem_edges_idx         ;
integer mem_in_degree         ;
integer mem_out_degree        ;
integer mem_edges_array_src   ;
integer mem_edges_array_dest  ;
integer mem_edges_array_weight;

integer file_error               ;
integer file_ptr_overlay_program ;
integer file_ptr_edges_idx       ;
integer file_ptr_in_degree       ;
integer file_ptr_out_degree      ;
integer file_ptr_edges_array_src ;
integer file_ptr_edges_array_dest;

bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] overlay_program[];

bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] auxiliary_1[];
bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] auxiliary_2[];
bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] in_degree[];
bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] out_degree[];
bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] edges_idx[];
bit [M01_AXI4_FE_DATA_W/8-1:0][8-1:0] edges_array_src[];
bit [M01_AXI4_FE_DATA_W/8-1:0][8-1:0] edges_array_dest[];
bit [M01_AXI4_FE_DATA_W/8-1:0][8-1:0] edges_array_weight[];

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
    this.mem_num_vertices       = 0;
    this.mem_num_edges          = 0;
    this.num_auxiliary_1           = 0;
    this.num_auxiliary_2           = 0;
    this.mem_auxiliary_1        = 0;
    this.mem_auxiliary_2        = 0;
    this.debug_counter_1           = 0;
    this.debug_counter_2           = 0;
    this.mem_overlay_program    = 4;
    this.mem_edges_idx          = 0;
    this.mem_in_degree          = 0;
    this.mem_out_degree         = 0;
    this.mem_edges_array_src    = 0;
    this.mem_edges_array_dest   = 0;
    this.mem_edges_array_weight = 0;
endfunction

function void display ();
    $display("---------------------------------------------------------------------------");
    $display("MSG: GRAPH CSR : %s", this.graph_name);
    $display("MSG: VERTEX COUNT : %0d", this.num_vertices);
    $display("MSG: EDGE COUNT   : %0d", this.num_edges);
    $display("---------------------------------------------------------------------------");
    $display("MSG: debug_counter_1  : %0d", this.debug_counter_1);
    $display("MSG: debug_counter_2  : %0d", this.debug_counter_2);
    $display("MSG: bfs_source       : %0d", this.bfs_source);
    $display("---------------------------------------------------------------------------");
endfunction

endclass

    // Function to print sizes of data types
    function void printDataTypeSizes();
        $display("Size (bits) ALUOpsConfigurationPayload: %0d ", $bits(ALUOpsConfigurationPayload));
        $display("Size (bits) CacheRequestPayload: %0d ", $bits(CacheRequestPayload));
        $display("Size (bits) ControlPacketPayload: %0d ", $bits(ControlPacketPayload));
        $display("Size (bits) CSRIndexConfigurationPayload: %0d ", $bits(CSRIndexConfigurationPayload));
        $display("Size (bits) EnginePacketFullPayload: %0d ", $bits(EnginePacketFullPayload));
        $display("Size (bits) EnginePacketPayload: %0d ", $bits(EnginePacketPayload));
        $display("Size (bits) FilterCondConfigurationPayload: %0d ", $bits(FilterCondConfigurationPayload));
        $display("Size (bits) MemoryPacketRequestPayload: %0d ", $bits(MemoryPacketRequestPayload));
        $display("Size (bits) MemoryPacketResponsePayload: %0d ", $bits(MemoryPacketResponsePayload));
        $display("Size (bits) MergeDataConfigurationPayload: %0d ", $bits(MergeDataConfigurationPayload));
        $display("Size (bits) ParallelReadWriteConfigurationPayload: %0d ", $bits(ParallelReadWriteConfigurationPayload));
        $display("Size (bits) ReadWriteConfigurationPayload: %0d ", $bits(ReadWriteConfigurationPayload));
        $display("Size (bits) SetOpsConfigurationPayload: %0d ", $bits(SetOpsConfigurationPayload));
    endfunction

    class __KERNEL__xrtBufferHandlePerKernel;

        integer num_buffers;

        string xrt_buffer_name[];
        bit [63:0] xrt_buffer_ptr[];
        bit [63:0] xrt_buffer_host[];
        bit [63:0] xrt_buffer_device[];
        bit [63:0] xrt_buffer_size[];
        bit [63:0] xrt_debug_counter[];

        function new ();
            this.num_buffers = 9;
        endfunction

        function void display_buffer (input integer index);
            $display("---------------------------------------------------------------------------");
            $display("MSG: XRT BUFFER NAME : %s" , this.xrt_buffer_name[index]);
            $display("MSG:             PTR : %0d", this.xrt_buffer_ptr[index]);
            $display("MSG:            HOST : %0d", this.xrt_buffer_host[index]);
            $display("MSG:          DEVICE : %0d", this.xrt_buffer_device[index]);
            $display("MSG:            SIZE : %0d", this.xrt_buffer_size[index]);
            $display("MSG:   DEBUG COUNTER : %0d", this.xrt_debug_counter[index]);
            $display("---------------------------------------------------------------------------");
        endfunction

        function void display ();
            for (int i = 0; i < this.num_buffers; i++) begin
                display_buffer(i);
            end
        endfunction

    endclass

module __KERNEL___testbench ();
        parameter integer LP_MAX_LENGTH              = 8192                    ;
        parameter integer LP_MAX_TRANSFER_LENGTH     = 16384 / 4               ;
        parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = S_AXI_BE_ADDR_WIDTH_BITS;
        parameter integer C_S_AXI_CONTROL_DATA_WIDTH = S_AXI_BE_DATA_WIDTH     ;
        `include "testbench_parameters.vh"

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
        `include "m_axi_wires_top.vh"

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
        `include "set_top_parameters.vh"
        .C_S_AXI_CONTROL_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH),
        .C_S_AXI_CONTROL_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH)
    ) inst_dut (
        .ap_clk               (ap_clk               ),
        .ap_rst_n             (ap_rst_n             ),
        // AXI4 master interface m00_axi
        `include "m_axi_portmap_top.vh"
        // Control Signals
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

        `include "module_slv_m_axi_vip_inst.vh"

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

        task automatic system_reset_sequence(input integer unsigned width = 20);
            $display("%t : Starting System Reset Sequence", $time);
            fork
                ap_rst_n_sequence(25);
            join

        endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
// Generate a random 32bit number
        function bit [$bits(size)-1:0] get_random_nbytes(int size);
            bit [$bits(size)-1:0] rptr;
            bit [$bits(size)-1:0] page_mask ;

            assert(std::randomize(rptr));
            // Create a mask to set lower 12 bits to zero for page alignment
            page_mask = ~((1 << 12) - 1);
            rptr &= page_mask;

            return rptr;
        endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////
// Generate a random 32bit number
        function bit [31:0] get_random_4bytes();
            bit [31:0] rptr;
            ptr_random_failed : assert(std::randomize(rptr));
            rptr[31:0] &= ~(32'h00000fff);
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
            buffer_0_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_1_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_2_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_3_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_4_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_5_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_6_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_7_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_8_ptr[63:0] = get_random_nbytes(M00_AXI4_BE_ADDR_W);
            buffer_9_ptr = {(SYSTEM_CACHE_SIZE_ITERAIONS +_NUM_ENTRIES_),16'd_CU_VECTOR_,13'd_NUM_ENTRIES_, 1'b1, 1'b1, 1'b1}; //flush_cache , endian_write_reg , endian_read_reg

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

        `include "module_slv_m_axi_vip_func.vh"

        task automatic update_BFS_auxiliary_struct(ref GraphCSR graph);
        /////////////////////////////////////////////////////////////////////////////////////////////////

        `include "module_slv_m_axi_vip_dump.vh"

        for (int i = 0; i < graph.num_auxiliary_1; i++) begin
            graph.auxiliary_1[i] = auxiliary_1[i];
        end
        for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
            graph.auxiliary_1[i] = auxiliary_2[i];
        end

        for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
            graph.auxiliary_2[i] = auxiliary_1[i];
        end
        for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
            graph.auxiliary_2[i] = 0;
        end
        endtask

            function automatic void update_CC_compressNodes(integer num_vertices, ref bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] components[]);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                integer n;  // Use integer for loop index
                for (n = 0; n < num_vertices; n++) begin
                    while (components[n] != components[components[n]]) begin
                        components[n] = components[components[n]];
                    end
                end
            endfunction

            task automatic update_CC_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                integer auxiliary_count[];
                integer n;

                `include "module_slv_m_axi_vip_dump.vh"

                auxiliary_count  = new [graph.num_auxiliary_1];
                graph.debug_counter_2 = 0;

                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = auxiliary_1[i];
                    auxiliary_count[i] = 0;
                end

                update_CC_compressNodes(graph.num_auxiliary_1, graph.auxiliary_1);

                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = auxiliary_1[i];
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end

                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    n = graph.auxiliary_1[i];
                    auxiliary_count[n] += 1;
                end

                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    if(auxiliary_count[i] > 0)
                        graph.debug_counter_2 += 1;
                end

            endtask

            function automatic void initialize_BFS_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor fill the memory with the content.
                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = {M00_AXI4_FE_DATA_W{1'b1}};
                    if(i == graph.bfs_source)begin
                        graph.auxiliary_1[i] = graph.bfs_source;
                    end
                end
                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = 0;
                    if(i == graph.num_auxiliary_1 + graph.bfs_source)begin
                        graph.auxiliary_1[i] = 1;
                    end
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = {M00_AXI4_FE_DATA_W{1'b1}};
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
            endfunction

            function automatic void initialize_SPMV_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor fill the memory with the content.
                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = 1;
                end
                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = 0;
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
            endfunction

            function automatic void initialize_TC_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor fill the memory with the content.
                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = 0;
                end
                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = 0;
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
            endfunction

            function automatic void initialize_MEMCPY_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor fill the memory with the content.
                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = 0;
                end
                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = 0;
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
            endfunction

            function automatic void initialize_AUTOMATA_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor fill the memory with the content.
                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = 0;
                end
                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = 0;
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
            endfunction

            function automatic void initialize_CC_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor fill the memory with the content.
                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = i;
                end
                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = 0;
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
            endfunction

            function automatic void initialize_PR_auxiliary_struct(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor fill the memory with the content.
                for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                    graph.auxiliary_1[i] = 0;
                end
                for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                    graph.auxiliary_1[i] = 1;
                end

                for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    graph.auxiliary_2[i] = 0;
                end
            endfunction

            function automatic bit check_BFS_result(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor read the memory with the content.
                bit error_found;
                integer error_counter;
                integer frontier_counter;

                `include "module_slv_m_axi_vip_dump.vh"

                error_found = 0;
                error_counter = 0;
                frontier_counter = 0;
                $display("MSG: // ------------------------------------------------- \n");
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    if(auxiliary_2[i])
                        $display("MSG: %0d \n", i-graph.num_auxiliary_2);
                    frontier_counter += auxiliary_2[i];
                end
                $display("MSG: Frontier_counter: %0d \n", frontier_counter);
                $display("MSG: // ------------------------------------------------- \n");

                graph.debug_counter_1 = frontier_counter;
                error_counter = 0;
                return(error_found);
            endfunction

            function automatic bit check_PR_result(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor read the memory with the content.
                // bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0]        set_value    = {(M00_AXI4_FE_DATA_W-1){1'b0},1'b1};
                bit error_found;
                integer error_counter;
                integer mismatch_counter;

                `include "module_slv_m_axi_vip_dump.vh"

                error_found = 0;
                error_counter = 0;
                mismatch_counter = 0;

                $display("MSG: // ------------------------------------------------- \n");
                for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                    if(auxiliary_2[i] != graph.out_degree[i-graph.num_auxiliary_2]) begin
                        $display("MSG: Starting num_auxiliary_2[%0d]: %0d==%0d\n",i-graph.num_auxiliary_2, auxiliary_2[i], graph.out_degree[i-graph.num_auxiliary_2]);
                        mismatch_counter += 1;
                    end
                end
                $display("MSG: // ------------------------------------------------- \n");
                $display("MSG: mismatch_counter: %0d \n", mismatch_counter);
                $display("MSG: // ------------------------------------------------- \n");

                error_counter = 0;

                return(error_found);
            endfunction

            function automatic bit check_CC_result(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor read the memory with the content.
                bit error_found;
                integer error_counter;
                integer CC_change;

                `include "module_slv_m_axi_vip_dump.vh"

                error_found = 0;
                error_counter = 0;
                CC_change = auxiliary_2[1];
                $display("MSG: // ------------------------------------------------- \n");
                $display("MSG: CC_change: %0d \n", CC_change);
                $display("MSG: // ------------------------------------------------- \n");

                graph.debug_counter_1 = CC_change;
                error_counter = 0;
                return(error_found);
            endfunction

            function automatic bit check_TC_result(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor read the memory with the content.
                bit error_found;
                integer error_counter;
                integer triangle_count;

                `include "module_slv_m_axi_vip_dump.vh"

                error_found = 0;
                error_counter = 0;
                triangle_count = auxiliary_2[0];
                $display("MSG: // ------------------------------------------------- \n");
                $display("MSG: Triangle_count: %0d \n", triangle_count);
                $display("MSG: // ------------------------------------------------- \n");

                error_counter = 0;
                return(error_found);
            endfunction

            function automatic bit check_MEMCPY_result(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor read the memory with the content.
                bit error_found;
                integer error_counter;
                integer mismatch_counter;

                `include "module_slv_m_axi_vip_dump.vh"

                error_found = 0;
                error_counter = 0;
                mismatch_counter = 0;

                $display("MSG: // ------------------------------------------------- \n");
                for (int i = 0; i < graph.mem_edges_array_src; i++) begin
                    if(edges_array_src[i] != graph.edges_array_dest[i]) begin
                        $display("MSG: Starting edges_array_dest[%0d]: %0d==%0d\n",i, edges_array_src[i], graph.edges_array_dest[i]);
                        mismatch_counter += 1;
                    end
                end
                $display("MSG: // ------------------------------------------------- \n");
                $display("MSG: mismatch_counter: %0d \n", mismatch_counter);
                $display("MSG: // ------------------------------------------------- \n");

                error_counter = 0;

                return(error_found);
            endfunction

            function automatic bit check_AUTOMATA_result(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor read the memory with the content.
                bit error_found;
                integer error_counter;
                integer mismatch_counter;

                `include "module_slv_m_axi_vip_dump.vh"

                error_found = 0;
                error_counter = 0;
                mismatch_counter = 0;

                $display("MSG: // ------------------------------------------------- \n");
                for (int i = 0; i < graph.mem_edges_array_src; i++) begin
                    if(edges_array_src[i] != graph.edges_array_dest[i]) begin
                        $display("MSG: Starting edges_array_dest[%0d]: %0d==%0d\n",i, edges_array_src[i], graph.edges_array_dest[i]);
                        mismatch_counter += 1;
                    end
                end
                $display("MSG: // ------------------------------------------------- \n");
                $display("MSG: mismatch_counter: %0d \n", mismatch_counter);
                $display("MSG: // ------------------------------------------------- \n");

                error_counter = 0;

                return(error_found);
            endfunction

            function automatic bit check___KERNEL___result(ref GraphCSR graph);
                /////////////////////////////////////////////////////////////////////////////////////////////////
                // Backdoor read the memory with the content.
                bit error_found = 0;

                error_found |= check__ALGORITHM_NAME__result(graph)   ;

                return(error_found);
            endfunction

            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Global read the files then send to backdoor memory with the content.
            /////////////////////////////////////////////////////////////////////////////////////////////////

            bit choose_pressure_type = 0;
        bit         axis_choose_pressure_type = 0;
        bit [0-1:0] axis_tlast_received          ;

        GraphCSR graph;

        /////////////////////////////////////////////////////////////////////////////////////////////////
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
            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Backdoor read the files then send to backdoor memory with the content.
            int          realcount                 = 0;
            int          vertexcount               = 0;
            int l;
            bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] temp_overlay_program         ;
            bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] temp_out_degree              ;
            bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] temp_in_degree               ;
            bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] temp_edges_idx               ;

            bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] temp_edges_array_src ;
            bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] temp_edges_array_dest;
            bit [M00_AXI4_FE_DATA_W/8-1:0][8-1:0] setup_temp;

            realcount = 0;
            setup_temp = 0;

            for (int i = 0; i < graph.mem_overlay_program; i++) begin
                graph.overlay_program[i] = realcount;
                realcount++;
            end

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
                        graph.overlay_program[l] = setup_temp;
                        // $display("MSG: %d Hex number: 32'h%0h",l, graph.overlay_program[l]);
                        l++;
                    end
                end
            end

            `include"buffer_mapping._ALGORITHM_NAME_.vh"

            for (int i = 0; i < graph.mem_num_vertices; i++) begin
                graph.file_error =  $fscanf(graph.file_ptr_out_degree, "%0d\n",temp_out_degree);
                setup_temp = temp_out_degree;
                graph.out_degree[i] = setup_temp;
                // $display("MSG: Starting temp_out_degree: %0d\n", graph.out_degree[i][j+:M00_AXI4_FE_DATA_W]);

                graph.file_error =  $fscanf(graph.file_ptr_in_degree, "%0d\n",temp_in_degree);
                setup_temp = temp_in_degree;
                graph.in_degree[i] = setup_temp;

                // $display("MSG: Starting temp_in_degree: %0d\n", temp_in_degree);
                graph.file_error =  $fscanf(graph.file_ptr_edges_idx, "%0d\n",temp_edges_idx);
                setup_temp = temp_edges_idx;
                graph.edges_idx[i] = setup_temp;
                // $display("MSG: Starting temp_edges_idx: %0d\n", temp_edges_idx);
            end

            // `include"initialize_testbench._ALGORITHM_NAME_.vh"

            for (int i = 0; i < graph.mem_edges_array_src; i++) begin
                // for (int j = 0;j < (M00_AXI4_BE_DATA_W/M00_AXI4_FE_DATA_W); j++) begin
                graph.file_error =  $fscanf(graph.file_ptr_edges_array_src, "%0d\n",temp_edges_array_src);
                setup_temp = temp_edges_array_src;
                graph.edges_array_src[i]= setup_temp;
                // end
            end

            for (int i = 0; i < graph.mem_num_edges; i++) begin
                graph.file_error =  $fscanf(graph.file_ptr_edges_array_dest, "%0d\n",temp_edges_array_dest);
                setup_temp = temp_edges_array_dest;
                graph.edges_array_dest[i] = setup_temp;
                // $display("MSG: Starting temp_edges_array_dest: %0d\n", temp_edges_array_dest);
            end

            initialize__ALGORITHM_NAME__auxiliary_struct(graph);
        endfunction : read_files_graphCSR

        typedef struct {
            string graph_suit   ;
            string graph_name   ;
            string file_bin_type;
        } GraphInitTuple;

        // localparam int NUM_GRAPHS = 5; // Adjust based on actual needs
        // GraphInitTuple graphInitParams_TEST[NUM_GRAPHS] = '{
        //     {"TEST", "v500_e500"   , "graph.bin"},
        //     {"TEST", "v529_e3500"  , "graph.bin"},
        //     {"TEST", "v1000_e10000", "graph.bin"},
        //     {"TEST", "v1024_e4096" , "graph.bin"},
        //     {"TEST", "v8192_e32768", "graph.bin"}
        // };

        localparam int NUM_GRAPHS = 1; // Adjust based on actual needs
        GraphInitTuple graphInitParams_TEST[NUM_GRAPHS] = '{
            {"TEST", "v500_e500"   , "graph.bin"}
        };

        function automatic void initialize_GraphCSR_Tuple (ref GraphCSR graph, GraphInitTuple graphInitParams, input integer unsigned source = _ROOT_);
            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Backdoor read the files then send to backdoor memory with the content.

            string in_degree_path = $sformatf("_GRAPH_DIR_/%0s/%1s/%2s.in_degree", graphInitParams.graph_suit, graphInitParams.graph_name, graphInitParams.file_bin_type);
            string out_degree_path = $sformatf("_GRAPH_DIR_/%0s/%1s/%2s.out_degree", graphInitParams.graph_suit, graphInitParams.graph_name, graphInitParams.file_bin_type);
            string edges_idx_path = $sformatf("_GRAPH_DIR_/%0s/%1s/%2s.edges_idx", graphInitParams.graph_suit, graphInitParams.graph_name, graphInitParams.file_bin_type);
            string edges_array_src_path = $sformatf("_GRAPH_DIR_/%0s/%1s/%2s.edges_array_src", graphInitParams.graph_suit, graphInitParams.graph_name, graphInitParams.file_bin_type);
            string edges_array_dest_path = $sformatf("_GRAPH_DIR_/%0s/%1s/%2s.edges_array_dest", graphInitParams.graph_suit, graphInitParams.graph_name, graphInitParams.file_bin_type);

            graph.graph_name = graphInitParams.graph_name;

            graph.file_ptr_overlay_program = $fopen("_FULL_SRC_IP_DIR_OVERLAY_/_ARCHITECTURE_/_CAPABILITY_/_CAPABILITY_.ol/_ALGORITHM_NAME_.ol", "r");
            if(graph.file_ptr_overlay_program) $display("File was opened successfully : %0d",graph.file_ptr_overlay_program);
            else                   $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_overlay_program);

            graph.file_ptr_in_degree = $fopen(in_degree_path, "r");
            if(graph.file_ptr_in_degree) $display("File was opened successfully : %0d",graph.file_ptr_in_degree);
            else                   $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_in_degree);

            graph.file_ptr_out_degree = $fopen(out_degree_path, "r");
            if(graph.file_ptr_out_degree) $display("File was opened successfully : %0d",graph.file_ptr_out_degree);
            else                    $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_out_degree);

            graph.file_ptr_edges_idx = $fopen(edges_idx_path, "r");
            if(graph.file_ptr_edges_idx) $display("File was opened successfully : %0d",graph.file_ptr_edges_idx);
            else                   $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_edges_idx);

            graph.file_ptr_edges_array_src = $fopen(edges_array_src_path, "r");
            if(graph.file_ptr_edges_array_src) $display("File was opened successfully : %0d",graph.file_ptr_edges_array_src);
            else                         $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_edges_array_src);

            graph.file_ptr_edges_array_dest= $fopen(edges_array_dest_path, "r");
            if(graph.file_ptr_edges_array_dest) $display("File was opened successfully : %0d",graph.file_ptr_edges_array_dest);
            else                          $display("MSG: File was NOT opened successfully : %0d",graph.file_ptr_edges_array_dest);

            graph.file_error =      $fscanf(graph.file_ptr_out_degree, "%d\n",graph.num_vertices);
            graph.file_error =      $fscanf(graph.file_ptr_edges_array_src, "%d\n",graph.num_edges);

            graph.bfs_source = source;

            graph.num_auxiliary_1 = graph.num_vertices;
            graph.num_auxiliary_2 = graph.num_vertices;

            graph.mem_overlay_program = int'(buffer_9_ptr[M00_AXI4_FE_DATA_W-1:1] + SYSTEM_CACHE_SIZE_ITERAIONS); // cachelines

            graph.mem_num_vertices = ((graph.num_vertices*M00_AXI4_FE_DATA_W) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);
            graph.mem_num_edges = ((graph.num_edges*M00_AXI4_FE_DATA_W) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);

            graph.mem_edges_idx       = graph.mem_num_vertices ;
            graph.mem_in_degree       = graph.mem_num_vertices ;
            graph.mem_out_degree      = graph.mem_num_vertices ;

            graph.mem_edges_array_src   = ((graph.num_edges*M01_AXI4_FE_DATA_W) + (M01_AXI4_FE_DATA_W-1) )/ (M01_AXI4_FE_DATA_W);
            graph.mem_edges_array_dest  = ((graph.num_edges*M01_AXI4_FE_DATA_W) + (M01_AXI4_FE_DATA_W-1) )/ (M01_AXI4_FE_DATA_W);
            graph.mem_edges_array_weight= ((graph.num_edges*M01_AXI4_FE_DATA_W) + (M01_AXI4_FE_DATA_W-1) )/ (M01_AXI4_FE_DATA_W);

            graph.mem_auxiliary_1 = ((graph.num_auxiliary_1*M00_AXI4_FE_DATA_W*2) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);
            graph.mem_auxiliary_2 = ((graph.num_auxiliary_2*M00_AXI4_FE_DATA_W*2) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);

            graph.out_degree   = new [graph.mem_num_vertices];
            graph.in_degree    = new [graph.mem_num_vertices];
            graph.edges_idx    = new [graph.mem_num_vertices];
            graph.auxiliary_1  = new [graph.mem_auxiliary_1];
            graph.auxiliary_2  = new [graph.mem_auxiliary_2];
            graph.edges_array_src = new [graph.mem_edges_array_src];
            graph.edges_array_dest= new [graph.mem_edges_array_dest];
            graph.overlay_program = new [graph.mem_overlay_program];

            read_files_graphCSR(graph);

            $fclose(graph.file_ptr_overlay_program);
            $fclose(graph.file_ptr_in_degree);
            $fclose(graph.file_ptr_out_degree);
            $fclose(graph.file_ptr_edges_idx);
            $fclose(graph.file_ptr_edges_array_src);
            $fclose(graph.file_ptr_edges_array_dest);

            graph.display();
        endfunction

        function automatic void initalize_GraphCSR (ref GraphCSR graph, input integer unsigned source = _ROOT_);
            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Backdoor read the files then send to backdoor memory with the content.
            graph.graph_name = "_GRAPH_NAME_";

            graph.file_ptr_overlay_program = $fopen("_FULL_SRC_IP_DIR_OVERLAY_/_ARCHITECTURE_/_CAPABILITY_/_CAPABILITY_.ol/_ALGORITHM_NAME_.ol", "r");
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

            graph.bfs_source = source;

            graph.num_auxiliary_1 = graph.num_vertices;
            graph.num_auxiliary_2 = graph.num_vertices;

            graph.mem_overlay_program = int'(buffer_9_ptr[M00_AXI4_FE_DATA_W-1:1] + SYSTEM_CACHE_SIZE_ITERAIONS); // cachelines

            graph.mem_num_vertices = ((graph.num_vertices*M00_AXI4_FE_DATA_W) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);
            graph.mem_num_edges = ((graph.num_edges*M00_AXI4_FE_DATA_W) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);

            graph.mem_edges_idx       = graph.mem_num_vertices ;
            graph.mem_in_degree       = graph.mem_num_vertices ;
            graph.mem_out_degree      = graph.mem_num_vertices ;

            graph.mem_edges_array_src   = ((graph.num_edges*M01_AXI4_FE_DATA_W) + (M01_AXI4_FE_DATA_W-1) )/ (M01_AXI4_FE_DATA_W);
            graph.mem_edges_array_dest  = ((graph.num_edges*M01_AXI4_FE_DATA_W) + (M01_AXI4_FE_DATA_W-1) )/ (M01_AXI4_FE_DATA_W);
            graph.mem_edges_array_weight= ((graph.num_edges*M01_AXI4_FE_DATA_W) + (M01_AXI4_FE_DATA_W-1) )/ (M01_AXI4_FE_DATA_W);

            graph.mem_auxiliary_1 = ((graph.num_auxiliary_1*M00_AXI4_FE_DATA_W*2) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);
            graph.mem_auxiliary_2 = ((graph.num_auxiliary_2*M00_AXI4_FE_DATA_W*2) + (M00_AXI4_FE_DATA_W-1) )/ (M00_AXI4_FE_DATA_W);

            graph.out_degree   = new [graph.mem_num_vertices];
            graph.in_degree    = new [graph.mem_num_vertices];
            graph.edges_idx    = new [graph.mem_num_vertices];
            graph.auxiliary_1  = new [graph.mem_auxiliary_1];
            graph.auxiliary_2  = new [graph.mem_auxiliary_2];
            graph.edges_array_src = new [graph.mem_edges_array_src];
            graph.edges_array_dest= new [graph.mem_edges_array_dest];
            graph.overlay_program = new [graph.mem_overlay_program];

            read_files_graphCSR(graph);

            $fclose(graph.file_ptr_overlay_program);
            $fclose(graph.file_ptr_in_degree);
            $fclose(graph.file_ptr_out_degree);
            $fclose(graph.file_ptr_edges_idx);
            $fclose(graph.file_ptr_edges_array_src);
            $fclose(graph.file_ptr_edges_array_dest);

            graph.display();
        endfunction

        /////////////////////////////////////////////////////////////////////////////////////////////////
        // Set up the __KERNEL__ for operation and set the __KERNEL__ START bit.
        // The task will poll the DONE bit and check the results when complete.
        task automatic multiple_iteration(input integer unsigned num_trials, output bit error_found);
            GraphCSR graph;
            error_found = 0;
            graph = new();
            $display("Starting: multiple_iteration");
            for (integer unsigned trial = 0; trial < num_trials; trial++) begin

                $display("Starting iteration: %d / %d", trial+1, num_trials);
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
                initalize_GraphCSR (graph);
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
                error_found |= check___KERNEL___result(graph)   ;

                $display("Finished iteration: %d / %d", trial+1, num_trials);
            end
        endtask

        task automatic multiple_iteration_MEMCPY(input integer unsigned num_trials, output bit error_found);
            GraphCSR graph;
            error_found = 0;
            graph = new();
            $display("Starting: multiple_iteration MEMCPY");
            for (integer unsigned trial = 0; trial < num_trials; trial++) begin

                $display("Starting iteration: %d / %d", trial+1, num_trials);
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
                initalize_GraphCSR (graph);
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
                error_found |= check___KERNEL___result(graph)   ;

                $display("Finished iteration: %d / %d", trial+1, num_trials);
            end
        endtask

        task automatic multiple_iteration_AUTOMATA(input integer unsigned num_trials, output bit error_found);
            GraphCSR graph;
            error_found = 0;
            graph = new();
            $display("Starting: multiple_iteration AUTOMATA");
            for (integer unsigned trial = 0; trial < num_trials; trial++) begin

                $display("Starting iteration: %d / %d", trial+1, num_trials);
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
                initalize_GraphCSR (graph);
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
                error_found |= check___KERNEL___result(graph)   ;

                $display("Finished iteration: %d / %d", trial+1, num_trials);
            end
        endtask

        task automatic multiple_iteration_PR(input integer unsigned num_trials, output bit error_found);
            GraphCSR graph;
            error_found = 0;
            graph = new();
            for (integer unsigned trial = 0; trial < num_trials; trial++) begin

                $display("Starting - PR Trial: %0d / %0d", trial+1, num_trials);
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
                // slv_random_backpressure_wready();
                // slv_random_delay_rvalid();

                set_scalar_registers();
                set_memory_pointers();
                initalize_GraphCSR (graph);
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
                error_found |= check___KERNEL___result(graph)   ;

                $display("Finished iteration: %d / %d", trial+1, num_trials);
            end
        endtask

        task automatic multiple_iteration_CC(input integer unsigned num_trials, output bit error_found);
            GraphCSR graph;
            integer unsigned trial = 0;
            integer unsigned iter  = 0;
            error_found = 0;
            graph = new();
            for (int trial = 0; trial < num_trials; trial++) begin
                graph.bfs_source = trial;
                graph.debug_counter_1 = 0;
                graph.debug_counter_2 = 0;

                // RAND_WREADY_PRESSURE_FAILED : assert(std::randomize(choose_pressure_type));
                // case(choose_pressure_type)
                //     0 : slv_no_backpressure_wready();
                //     1 : slv_random_backpressure_wready();
                // endcase
                // RAND_RVALID_PRESSURE_FAILED : assert(std::randomize(choose_pressure_type));
                // case(choose_pressure_type)
                //     0 : slv_no_delay_rvalid();
                //     1 : slv_random_delay_rvalid();
                // endcase
                slv_random_backpressure_wready();
                slv_random_delay_rvalid();
                if(trial == 0)
                    initalize_GraphCSR (graph);
                else
                    initalize_GraphCSR (graph);

                $display("Starting - CC Trial: %0d / %0d", trial, num_trials);
                $display("Starting - Iteration: %0d - Components: %0d", iter, graph.debug_counter_2);
                set_scalar_registers();
                set_memory_pointers();
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
                error_found |= check___KERNEL___result(graph)   ;

                $display("Starting - Multiple Iterations:");
                while (graph.debug_counter_1) begin
                    RAND_WREADY_PRESSURE_FAILED_ITER : assert(std::randomize(choose_pressure_type));
                    case(choose_pressure_type)
                        0 : slv_no_backpressure_wready();
                        1 : slv_random_backpressure_wready();
                    endcase
                    RAND_RVALID_PRESSURE_FAILED_ITER : assert(std::randomize(choose_pressure_type));
                    case(choose_pressure_type)
                        0 : slv_no_delay_rvalid();
                        1 : slv_random_delay_rvalid();
                    endcase
                    update_CC_auxiliary_struct(graph);
                    $display("Starting - Iteration: %0d - Components: %0d", iter+1, graph.debug_counter_2);
                    set_scalar_registers();
                    set_memory_pointers();
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
                    error_found |= check___KERNEL___result(graph)   ;
                    if(graph.debug_counter_1 == 0)
                        break;
                    iter++;
                end
                update_BFS_auxiliary_struct(graph);
                $display("Finished - Iteration: %0d - Components: %0d", iter+1, graph.debug_counter_1);
            end
        endtask


        task automatic multiple_iteration_TC(input integer unsigned num_trials, output bit error_found);
            GraphCSR graph;
            error_found = 0;
            graph = new();
            $display("Starting: multiple_iteration TC");
            for (integer unsigned trial = 0; trial < num_trials; trial++) begin

                $display("Starting iteration: %d / %d", trial+1, num_trials);
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
                initalize_GraphCSR (graph);
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
                error_found |= check___KERNEL___result(graph)   ;

                $display("Finished iteration: %d / %d", trial+1, num_trials);
            end
        endtask

        localparam int     NUM_SOURCES              = 4              ; // Example, adjust based on actual needs
        integer            sources    [NUM_SOURCES] = '{1, 3, 543, 2}; // Initialize the array with your specific source values

        task automatic multiple_iteration_BFS(input integer unsigned num_trials, output bit error_found);
            GraphCSR graph;
            integer unsigned trial;
            integer unsigned iter;

            error_found = 0;
            graph = new();
            foreach (graphInitParams_TEST[i]) begin
                iter  = 0;
                trial = 0;
                for (int trial = 0; trial < num_trials; trial++) begin
                    graph.bfs_source = trial;
                    graph.debug_counter_1 = 1;

                    // RAND_WREADY_PRESSURE_FAILED : assert(std::randomize(choose_pressure_type));
                    // case(choose_pressure_type)
                    //     0 : slv_no_backpressure_wready();
                    //     1 : slv_random_backpressure_wready();
                    // endcase
                    // RAND_RVALID_PRESSURE_FAILED : assert(std::randomize(choose_pressure_type));
                    // case(choose_pressure_type)
                    //     0 : slv_no_delay_rvalid();
                    //     1 : slv_random_delay_rvalid();
                    // endcase
                    slv_random_backpressure_wready();
                    slv_random_delay_rvalid();
                    if(trial == 0)
                        initialize_GraphCSR_Tuple (graph, graphInitParams_TEST[i]);
                    else
                        initialize_GraphCSR_Tuple (graph, graphInitParams_TEST[i], trial);

                    $display("Starting - BFS Trial: %0d / %0d - Source: %0d", trial, num_trials, graph.bfs_source);
                    $display("Starting - Iteration: %0d - Frontier: %0d", iter, graph.debug_counter_1);
                    set_scalar_registers();
                    set_memory_pointers();
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
                    error_found |= check___KERNEL___result(graph)   ;

                    $display("Starting - Multiple Iterations:");
                    while (graph.debug_counter_1) begin
                        RAND_WREADY_PRESSURE_FAILED_ITER : assert(std::randomize(choose_pressure_type));
                        case(choose_pressure_type)
                            0 : slv_no_backpressure_wready();
                            1 : slv_random_backpressure_wready();
                        endcase
                        RAND_RVALID_PRESSURE_FAILED_ITER : assert(std::randomize(choose_pressure_type));
                        case(choose_pressure_type)
                            0 : slv_no_delay_rvalid();
                            1 : slv_random_delay_rvalid();
                        endcase
                        // slv_random_backpressure_wready();
                        // slv_random_delay_rvalid();
                        update_BFS_auxiliary_struct(graph);
                        $display("Starting - Iteration: %0d - Frontier: %0d", iter+1, graph.debug_counter_1);
                        set_scalar_registers();
                        set_memory_pointers();
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
                        error_found |= check___KERNEL___result(graph)   ;
                        if(graph.debug_counter_1 == 0)
                            break;
                        iter++;
                    end
                    update_BFS_auxiliary_struct(graph);
                    $display("Finished - Iteration: %0d - Frontier: %0d", iter+1, graph.debug_counter_1);
                end
            end
        endtask

/////////////////////////////////////////////////////////////////////////////////////////////////
//Instantiate AXI4 LITE VIP
        initial begin : STIMULUS
            printDataTypeSizes();

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
                multiple_iteration__ALGORITHM_NAME_(_NUM_TRIALS_, error_found);

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


