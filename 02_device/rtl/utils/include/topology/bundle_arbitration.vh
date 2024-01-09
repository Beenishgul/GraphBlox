
generate
     if(ID_BUNDLE == 0)
          begin
               assign lane_arbiter_N_to_1_memory_request_in[0] = lanes_request_memory_out[0];
               assign lanes_fifo_request_memory_out_signals_in[0].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[0];
               assign lane_arbiter_N_to_1_memory_request_in[1] = lanes_request_memory_out[1];
               assign lanes_fifo_request_memory_out_signals_in[1].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[1];
               assign lane_arbiter_N_to_1_memory_request_in[2] = lanes_request_memory_out[2];
               assign lanes_fifo_request_memory_out_signals_in[2].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[2];
               assign lanes_fifo_request_memory_out_signals_in[3].rd_en  = 1'b0;
               assign lane_arbiter_N_to_1_memory_request_in[3] = 0;
               assign lane_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_BUNDLE == 1)
          begin
               assign lane_arbiter_N_to_1_memory_request_in[0] = lanes_request_memory_out[0];
               assign lanes_fifo_request_memory_out_signals_in[0].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[0];
               assign lane_arbiter_N_to_1_memory_request_in[1] = lanes_request_memory_out[1];
               assign lanes_fifo_request_memory_out_signals_in[1].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[1];
               assign lane_arbiter_N_to_1_memory_request_in[2] = lanes_request_memory_out[2];
               assign lanes_fifo_request_memory_out_signals_in[2].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[2];
               assign lanes_fifo_request_memory_out_signals_in[3].rd_en  = 1'b0;
               assign lane_arbiter_N_to_1_memory_request_in[3] = 0;
               assign lane_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_BUNDLE == 2)
          begin
               assign lane_arbiter_N_to_1_memory_request_in[0] = lanes_request_memory_out[0];
               assign lanes_fifo_request_memory_out_signals_in[0].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[0];
               assign lanes_fifo_request_memory_out_signals_in[1].rd_en  = 1'b0;
               assign lane_arbiter_N_to_1_memory_request_in[1] = 0;
               assign lane_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_BUNDLE == 3)
          begin
               assign lane_arbiter_N_to_1_memory_request_in[0] = lanes_request_memory_out[0];
               assign lanes_fifo_request_memory_out_signals_in[0].rd_en  = ~lane_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_memory_lane_arbiter_grant_out[0];
               assign lanes_fifo_request_memory_out_signals_in[1].rd_en  = 1'b0;
               assign lane_arbiter_N_to_1_memory_request_in[1] = 0;
               assign lane_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_BUNDLE == 1)
          begin
               assign lane_arbiter_N_to_1_control_request_in[0] = lanes_request_control_out[0];
               assign lanes_fifo_request_control_out_signals_in[0].rd_en  = ~lane_arbiter_N_to_1_control_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_control_lane_arbiter_grant_out[0];
               assign lanes_fifo_request_control_out_signals_in[1].rd_en  = 1'b0;
               assign lanes_fifo_request_control_out_signals_in[2].rd_en  = 1'b0;
               assign lanes_fifo_request_control_out_signals_in[3].rd_en  = 1'b0;
               assign lane_arbiter_N_to_1_control_request_in[1] = 0;
               assign lane_arbiter_N_to_1_control_request_in[2] = 0;
               assign lane_arbiter_N_to_1_control_request_in[3] = 0;
               assign lane_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_BUNDLE == 3)
          begin
               assign lane_arbiter_N_to_1_control_request_in[0] = lanes_request_control_out[0];
               assign lanes_fifo_request_control_out_signals_in[0].rd_en  = ~lane_arbiter_N_to_1_control_fifo_request_signals_out.prog_full & lane_arbiter_N_to_1_control_lane_arbiter_grant_out[0];
               assign lanes_fifo_request_control_out_signals_in[1].rd_en  = 1'b0;
               assign lane_arbiter_N_to_1_control_request_in[1] = 0;
               assign lane_arbiter_N_to_1_control_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_BUNDLE == 0)
          begin
               assign lanes_response_control_in[0] = 0;
               assign lanes_fifo_response_control_in_signals_in[0].rd_en = 1'b0;
               assign lanes_response_control_in[1] = 0;
               assign lanes_fifo_response_control_in_signals_in[1].rd_en = 1'b0;
               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[0].rd_en = ~lanes_fifo_response_control_in_signals_out[2].prog_full & fifo_response_control_in_signals_in_reg.rd_en;
               assign lanes_response_control_in[2] = lane_arbiter_1_to_N_control_response_out[0];
               assign lanes_fifo_response_control_in_signals_in[2].rd_en = 1'b1;
               assign lanes_response_control_in[3] = 0;
               assign lanes_fifo_response_control_in_signals_in[3].rd_en = 1'b0;
               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[1].rd_en = 1'b0;
               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[1].rd_en = 1'b0;
               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[1].rd_en = 1'b0;
               assign lane_arbiter_1_to_N_control_response_in = response_control_in_int;
          end
endgenerate



generate
     if(ID_BUNDLE == 2)
          begin
               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[0].rd_en = ~lanes_fifo_response_control_in_signals_out[0].prog_full & fifo_response_control_in_signals_in_reg.rd_en;
               assign lanes_response_control_in[0] = lane_arbiter_1_to_N_control_response_out[0];
               assign lanes_fifo_response_control_in_signals_in[0].rd_en = 1'b1;
               assign lanes_response_control_in[1] = 0;
               assign lanes_fifo_response_control_in_signals_in[1].rd_en = 1'b0;
               assign lane_arbiter_1_to_N_control_fifo_response_signals_in[1].rd_en = 1'b0;
               assign lane_arbiter_1_to_N_control_response_in = response_control_in_int;
          end
endgenerate


