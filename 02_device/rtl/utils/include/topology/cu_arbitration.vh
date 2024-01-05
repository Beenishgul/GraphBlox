
generate
     if(ID_CU == 0)
          begin
               assign bundle_arbiter_memory_N_to_1_request_in[0] = bundle_request_memory_out[0];
               assign bundle_fifo_request_memory_out_signals_in[0].rd_en  = ~bundle_arbiter_memory_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_memory_N_to_1_arbiter_grant_out[0];
               assign bundle_arbiter_memory_N_to_1_request_in[1] = bundle_request_memory_out[1];
               assign bundle_fifo_request_memory_out_signals_in[1].rd_en  = ~bundle_arbiter_memory_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_memory_N_to_1_arbiter_grant_out[1];
               assign bundle_arbiter_memory_N_to_1_request_in[2] = bundle_request_memory_out[2];
               assign bundle_fifo_request_memory_out_signals_in[2].rd_en  = ~bundle_arbiter_memory_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_memory_N_to_1_arbiter_grant_out[2];
               assign bundle_arbiter_memory_N_to_1_request_in[3] = bundle_request_memory_out[3];
               assign bundle_fifo_request_memory_out_signals_in[3].rd_en  = ~bundle_arbiter_memory_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_memory_N_to_1_arbiter_grant_out[3];
               assign bundle_arbiter_memory_N_to_1_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_CU == 0)
          begin
               assign bundle_fifo_request_control_out_signals_in[0].rd_en  = 1'b0;
               assign bundle_arbiter_control_N_to_1_request_in[0] = bundle_request_control_out[1];
               assign bundle_fifo_request_control_out_signals_in[1].rd_en  = ~bundle_arbiter_control_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_control_N_to_1_arbiter_grant_out[0];
               assign bundle_fifo_request_control_out_signals_in[2].rd_en  = 1'b0;
               assign bundle_arbiter_control_N_to_1_request_in[1] = bundle_request_control_out[3];
               assign bundle_fifo_request_control_out_signals_in[3].rd_en  = ~bundle_arbiter_control_N_to_1_fifo_request_signals_out.prog_full & bundle_arbiter_control_N_to_1_arbiter_grant_out[1];
               assign bundle_arbiter_control_N_to_1_request_in[2]  = 0;
               assign bundle_arbiter_control_N_to_1_request_in[2]  = 0;
               assign bundle_arbiter_control_N_to_1_fifo_request_signals_in.rd_en = fifo_request_control_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if(ID_CU == 0)
          begin
               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[0].rd_en = ~bundle_fifo_response_control_in_signals_out[0].prog_full & fifo_response_control_in_signals_in_reg.rd_en;
               assign bundle_response_control_in[0] = bundle_arbiter_control_1_to_N_response_out[0];
               assign bundle_fifo_response_control_in_signals_in[0].rd_en = 1'b1;
               assign bundle_response_control_in[1] = 0;
               assign bundle_fifo_response_control_in_signals_in[1].rd_en = 1'b0;
               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[1].rd_en = ~bundle_fifo_response_control_in_signals_out[2].prog_full & fifo_response_control_in_signals_in_reg.rd_en;
               assign bundle_response_control_in[2] = bundle_arbiter_control_1_to_N_response_out[1];
               assign bundle_fifo_response_control_in_signals_in[2].rd_en = 1'b1;
               assign bundle_response_control_in[3] = 0;
               assign bundle_fifo_response_control_in_signals_in[3].rd_en = 1'b0;
               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[2].rd_en = 1'b0;
               assign bundle_arbiter_control_1_to_N_fifo_response_signals_in[3].rd_en = 1'b0;
               assign bundle_arbiter_control_1_to_N_response_in = response_control_in_int;
          end
endgenerate


