
generate
     if((ID_BUNDLE == 0) && (ID_LANE == 1))
          begin
               assign engine_arbiter_N_to_1_memory_request_in[0] = engines_request_memory_out[0];
               assign engines_fifo_request_memory_out_signals_in[0].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[0];
               assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if((ID_BUNDLE == 1) && (ID_LANE == 0))
          begin
               assign engine_arbiter_N_to_1_memory_request_in[0] = engines_request_memory_out[0];
               assign engines_fifo_request_memory_out_signals_in[0].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[0];
               assign engines_fifo_request_memory_out_signals_in[1].rd_en  = 1'b0;
               assign engine_arbiter_N_to_1_memory_request_in[1] = 0;
               assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if((ID_BUNDLE == 1) && (ID_LANE == 1))
          begin
               assign engine_arbiter_N_to_1_memory_request_in[0] = engines_request_memory_out[0];
               assign engines_fifo_request_memory_out_signals_in[0].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[0];
               assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if((ID_BUNDLE == 1) && (ID_LANE == 2))
          begin
               assign engine_arbiter_N_to_1_memory_request_in[0] = engines_request_memory_out[0];
               assign engines_fifo_request_memory_out_signals_in[0].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[0];
               assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if((ID_BUNDLE == 2) && (ID_LANE == 0))
          begin
               assign engine_arbiter_N_to_1_memory_request_in[0] = engines_request_memory_out[0];
               assign engines_fifo_request_memory_out_signals_in[0].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[0];
               assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if((ID_BUNDLE == 3) && (ID_LANE == 0))
          begin
               assign engine_arbiter_N_to_1_memory_request_in[0] = engines_request_memory_out[0];
               assign engines_fifo_request_memory_out_signals_in[0].rd_en  = ~engine_arbiter_N_to_1_memory_fifo_request_signals_out.prog_full & engine_arbiter_N_to_1_memory_engine_arbiter_grant_out[0];
               assign engine_arbiter_N_to_1_memory_fifo_request_signals_in.rd_en = fifo_request_memory_out_signals_in_reg.rd_en;
          end
endgenerate



generate
     if((ID_BUNDLE == 0) && (ID_LANE == 1))
          begin
               assign engine_arbiter_1_to_N_control_fifo_response_signals_in[0].rd_en = ~engines_fifo_response_control_in_signals_out[0].prog_full & fifo_response_control_in_signals_in_reg.rd_en;
               assign engines_response_control_in[0] = engine_arbiter_1_to_N_control_response_out[0];
               assign engines_fifo_response_control_in_signals_in[0].rd_en = 1'b1;
               assign engine_arbiter_1_to_N_control_response_in = response_control_in_int;
          end
endgenerate



generate
     if((ID_BUNDLE == 2) && (ID_LANE == 0))
          begin
               assign engine_arbiter_1_to_N_control_fifo_response_signals_in[0].rd_en = ~engines_fifo_response_control_in_signals_out[0].prog_full & fifo_response_control_in_signals_in_reg.rd_en;
               assign engines_response_control_in[0] = engine_arbiter_1_to_N_control_response_out[0];
               assign engines_fifo_response_control_in_signals_in[0].rd_en = 1'b1;
               assign engine_arbiter_1_to_N_control_response_in = response_control_in_int;
          end
endgenerate


