
/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the input buffer AXI vip memory model with 32-bit words
        function void  m00_axi_buffer_fill_memory(
                input slv_m00_axi_vip_slv_mem_t mem,      // vip memory model handle
                input bit [63:0] ptr,                     // start address of memory fill, should allign to 16-byte
                input bit [M00_AXI4_BE_DATA_W-1:0] words_data[$],      // data source to fill memory
                input integer offset,                 // start index of data source
                input integer words                   // number of words to fill
            );
            int index;
            // bit [(32/8)-1:0] wr_strb = 4'hf;
            bit [M00_AXI4_BE_DATA_W-1:0] temp;
            int i;
            for (index = 0; index < words; index++) begin
                // $display("Before: %0d ->%0d ->%0h",index, i, words_data[offset+index]);
                for (i = 0; i < (M00_AXI4_BE_DATA_W/8); i = i + 1) begin // endian conversion to emulate general memory little endian behavior
                    temp[i*8+7-:8] = words_data[offset+index][((M00_AXI4_BE_DATA_W/8)-1-i)*8+7-:8];
                    // $display("%0d ->%0d ->%0h",index, i, temp[i*8+7-:8] );
                end
                // $display("After: %0d ->%0d ->%0h",index, i, temp);
                mem.mem_model.backdoor_memory_write(ptr + index * (M00_AXI4_BE_DATA_W/8), temp);
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
        

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the input buffer AXI vip memory model with 32-bit words
        function void  m01_axi_buffer_fill_memory(
                input slv_m01_axi_vip_slv_mem_t mem,      // vip memory model handle
                input bit [63:0] ptr,                     // start address of memory fill, should allign to 16-byte
                input bit [M01_AXI4_BE_DATA_W-1:0] words_data[$],      // data source to fill memory
                input integer offset,                 // start index of data source
                input integer words                   // number of words to fill
            );
            int index;
            // bit [(32/8)-1:0] wr_strb = 4'hf;
            bit [M01_AXI4_BE_DATA_W-1:0] temp;
            int i;
            for (index = 0; index < words; index++) begin
                // $display("Before: %0d ->%0d ->%0h",index, i, words_data[offset+index]);
                for (i = 0; i < (M01_AXI4_BE_DATA_W/8); i = i + 1) begin // endian conversion to emulate general memory little endian behavior
                    temp[i*8+7-:8] = words_data[offset+index][((M01_AXI4_BE_DATA_W/8)-1-i)*8+7-:8];
                    // $display("%0d ->%0d ->%0h",index, i, temp[i*8+7-:8] );
                end
                // $display("After: %0d ->%0d ->%0h",index, i, temp);
                mem.mem_model.backdoor_memory_write(ptr + index * (M01_AXI4_BE_DATA_W/8), temp);
            end
        endfunction

/////////////////////////////////////////////////////////////////////////////////////////////////
// Backdoor fill the m01_axi memory.
        function void m01_axi_fill_memory(
                input bit [63:0] ptr,
                input integer    length
            );
            for (longint unsigned slot = 0; slot < length; slot++) begin
                m01_axi.mem_model.backdoor_memory_write_4byte(ptr + (slot * 4), slot);
            end
        endfunction
        

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
            

            $display("///////////////////////////////////////////////////////////////////////////");
            $display("Starting Memory slave: m01_axi");
            m01_axi = new("m01_axi", __KERNEL___testbench.inst_slv_m01_axi_vip.inst.IF);
            m01_axi.start_slave();
            

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
            

            rgen = new("m01_axi_no_backpressure_wready");
            rgen.set_ready_policy(XIL_AXI_READY_GEN_NO_BACKPRESSURE);
            m01_axi.wr_driver.set_wready_gen(rgen);
            

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
            

            rgen = new("m01_axi_random_backpressure_wready");
            rgen.set_ready_policy(XIL_AXI_READY_GEN_RANDOM);
            rgen.set_low_time_range(0,12);
            rgen.set_high_time_range(1,12);
            rgen.set_event_count_range(3,5);
            m01_axi.wr_driver.set_wready_gen(rgen);
            

        endtask
            

/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, force the memory model to not insert any inter-beat
// gaps on the READ channel.
        task automatic slv_no_delay_rvalid();
            $display("%t - Applying slv_no_delay_rvalid", $time);
            

            m00_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_FIXED);
            m00_axi.mem_model.set_inter_beat_gap(0);
            

            m01_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_FIXED);
            m01_axi.mem_model.set_inter_beat_gap(0);
            

        endtask
            

/////////////////////////////////////////////////////////////////////////////////////////////////
// For each of the connected slave interfaces, Allow the memory model to insert any inter-beat
// gaps on the READ channel.
        task automatic slv_random_delay_rvalid();
            $display("%t - Applying slv_random_delay_rvalid", $time);
            

            m00_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_RANDOM);
            m00_axi.mem_model.set_inter_beat_gap_range(0,10);
            

            m01_axi.mem_model.set_inter_beat_gap_delay_policy(XIL_AXI_MEMORY_DELAY_RANDOM);
            m01_axi.mem_model.set_inter_beat_gap_range(0,10);
            

        endtask
            

        task automatic backdoor_fill_memories();
            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Backdoor fill the memory with the content.
            

            m00_axi_fill_memory(buffer_0_ptr, LP_MAX_LENGTH);
            

            m00_axi_fill_memory(buffer_1_ptr, LP_MAX_LENGTH);
            

            m00_axi_fill_memory(buffer_2_ptr, LP_MAX_LENGTH);
            

            m00_axi_fill_memory(buffer_3_ptr, LP_MAX_LENGTH);
            

            m01_axi_fill_memory(buffer_4_ptr, LP_MAX_LENGTH);
            

            m01_axi_fill_memory(buffer_5_ptr, LP_MAX_LENGTH);
            

            m01_axi_fill_memory(buffer_6_ptr, LP_MAX_LENGTH);
            

            m00_axi_fill_memory(buffer_7_ptr, LP_MAX_LENGTH);
            

            m00_axi_fill_memory(buffer_8_ptr, LP_MAX_LENGTH);
            

            m00_axi_fill_memory(buffer_9_ptr, LP_MAX_LENGTH);
            

        endtask
            

        task automatic backdoor_buffer_fill_memories(ref GraphCSR graph);
            /////////////////////////////////////////////////////////////////////////////////////////////////
            // Backdoor fill the memory with the content.
            

            m00_axi_buffer_fill_memory(m00_axi, buffer_0_ptr, graph.overlay_program, 0, graph.mem512_overlay_program);
            

            m00_axi_buffer_fill_memory(m00_axi, buffer_1_ptr, graph.in_degree, 0, graph.mem512_in_degree);
            

            m00_axi_buffer_fill_memory(m00_axi, buffer_2_ptr, graph.out_degree, 0, graph.mem512_out_degree);
            

            m00_axi_buffer_fill_memory(m00_axi, buffer_3_ptr, graph.edges_idx, 0, graph.mem512_edges_idx);
            

            m01_axi_buffer_fill_memory(m01_axi, buffer_4_ptr, graph.edges_array_src, 0, graph.mem512_edges_array_src);
            

            m01_axi_buffer_fill_memory(m01_axi, buffer_5_ptr, graph.edges_array_dest, 0, graph.mem512_edges_array_dest);
            

            m01_axi_buffer_fill_memory(m01_axi, buffer_6_ptr, graph.edges_array_weight, 0, graph.mem512_edges_array_weight);
            

            m00_axi_buffer_fill_memory(m00_axi, buffer_7_ptr, graph.auxiliary_1, 0, graph.mem512_auxiliary_1);
            

            m00_axi_buffer_fill_memory(m00_axi, buffer_8_ptr, graph.auxiliary_2, 0, graph.mem512_auxiliary_2);
            

        endtask
            