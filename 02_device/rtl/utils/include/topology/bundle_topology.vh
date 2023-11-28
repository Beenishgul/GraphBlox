
generate
     if(ID_BUNDLE == 0)
                    begin
                      assign lanes_fifo_request_cast_lane_out_signals_in[0][0]  = lanes_fifo_request_lane_out_signals_in[0];
                      assign lanes_fifo_request_lane_out_signals_out[0]         = lanes_fifo_request_cast_lane_out_signals_out [0][0];
                      assign lanes_fifo_response_lane_in_signals_out[0]         = lanes_fifo_response_merge_lane_in_signals_out[0][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[0][0] = lanes_fifo_response_lane_in_signals_in[0];
                      assign lanes_request_lane_out[0]                          = lanes_request_cast_lane_out[0][0];
                      assign lanes_response_merge_engine_in[0][0]               = lanes_response_engine_in[0];

                      assign lanes_fifo_request_cast_lane_out_signals_in[1][0]  = lanes_fifo_request_lane_out_signals_in[1];
                      assign lanes_fifo_request_lane_out_signals_out[1]         = lanes_fifo_request_cast_lane_out_signals_out [1][0];
                      assign lanes_fifo_response_lane_in_signals_out[1]         = lanes_fifo_response_merge_lane_in_signals_out[1][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[1][0] = lanes_fifo_response_lane_in_signals_in[1];
                      assign lanes_request_lane_out[1]                          = lanes_request_cast_lane_out[1][0];
                      assign lanes_response_merge_engine_in[1][0]               = lanes_response_engine_in[1];

                      assign lanes_fifo_request_cast_lane_out_signals_in[2][0]  = lanes_fifo_request_lane_out_signals_in[2];
                      assign lanes_fifo_request_lane_out_signals_out[2]         = lanes_fifo_request_cast_lane_out_signals_out [2][0];
                      assign lanes_fifo_response_lane_in_signals_out[2]         = lanes_fifo_response_merge_lane_in_signals_out[2][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[2][0] = lanes_fifo_response_lane_in_signals_in[2];
                      assign lanes_request_lane_out[2]                          = lanes_request_cast_lane_out[2][0];
                      assign lanes_response_merge_engine_in[2][0]               = lanes_response_engine_in[2];

                    end
endgenerate

generate
     if(ID_BUNDLE == 1)
                    begin
                      assign lanes_fifo_request_cast_lane_out_signals_in[0][0]  = lanes_fifo_request_lane_out_signals_in[0];
                      assign lanes_fifo_request_lane_out_signals_out[0]         = lanes_fifo_request_cast_lane_out_signals_out [0][0];
                      assign lanes_fifo_response_lane_in_signals_out[0]         = lanes_fifo_response_merge_lane_in_signals_out[0][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[0][0] = lanes_fifo_response_lane_in_signals_in[0];
                      assign lanes_request_lane_out[0]                          = lanes_request_cast_lane_out[0][0];
                      assign lanes_response_merge_engine_in[0][0]               = lanes_response_engine_in[0];

                      assign lanes_fifo_request_cast_lane_out_signals_in[1][1].rd_en             = ~lanes_fifo_response_merge_lane_in_signals_out[0][1].prog_full;
                      assign lanes_fifo_response_merge_lane_in_signals_in[0][1].rd_en             = 1'b1;
                      assign lanes_response_merge_engine_in[0][1]                                 = lanes_request_cast_lane_out[1][1];

                      assign lanes_fifo_request_cast_lane_out_signals_in[2][1].rd_en             = ~lanes_fifo_response_merge_lane_in_signals_out[0][2].prog_full;
                      assign lanes_fifo_response_merge_lane_in_signals_in[0][2].rd_en             = 1'b1;
                      assign lanes_response_merge_engine_in[0][2]                                 = lanes_request_cast_lane_out[2][1];

                      assign lanes_fifo_request_cast_lane_out_signals_in[1][0]  = lanes_fifo_request_lane_out_signals_in[1];
                      assign lanes_fifo_request_lane_out_signals_out[1]         = lanes_fifo_request_cast_lane_out_signals_out [1][0];
                      assign lanes_fifo_response_lane_in_signals_out[1]         = lanes_fifo_response_merge_lane_in_signals_out[1][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[1][0] = lanes_fifo_response_lane_in_signals_in[1];
                      assign lanes_request_lane_out[1]                          = lanes_request_cast_lane_out[1][0];
                      assign lanes_response_merge_engine_in[1][0]               = lanes_response_engine_in[1];

                      assign lanes_fifo_request_cast_lane_out_signals_in[2][0]  = lanes_fifo_request_lane_out_signals_in[2];
                      assign lanes_fifo_request_lane_out_signals_out[2]         = lanes_fifo_request_cast_lane_out_signals_out [2][0];
                      assign lanes_fifo_response_lane_in_signals_out[2]         = lanes_fifo_response_merge_lane_in_signals_out[2][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[2][0] = lanes_fifo_response_lane_in_signals_in[2];
                      assign lanes_request_lane_out[2]                          = lanes_request_cast_lane_out[2][0];
                      assign lanes_response_merge_engine_in[2][0]               = lanes_response_engine_in[2];

                      assign lanes_fifo_request_cast_lane_out_signals_in[3][0]  = lanes_fifo_request_lane_out_signals_in[3];
                      assign lanes_fifo_request_lane_out_signals_out[3]         = lanes_fifo_request_cast_lane_out_signals_out [3][0];
                      assign lanes_fifo_response_lane_in_signals_out[3]         = lanes_fifo_response_merge_lane_in_signals_out[3][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[3][0] = lanes_fifo_response_lane_in_signals_in[3];
                      assign lanes_request_lane_out[3]                          = lanes_request_cast_lane_out[3][0];
                      assign lanes_response_merge_engine_in[3][0]               = lanes_response_engine_in[3];

                      assign lanes_fifo_request_cast_lane_out_signals_in[4][0]  = lanes_fifo_request_lane_out_signals_in[4];
                      assign lanes_fifo_request_lane_out_signals_out[4]         = lanes_fifo_request_cast_lane_out_signals_out [4][0];
                      assign lanes_fifo_response_lane_in_signals_out[4]         = lanes_fifo_response_merge_lane_in_signals_out[4][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[4][0] = lanes_fifo_response_lane_in_signals_in[4];
                      assign lanes_request_lane_out[4]                          = lanes_request_cast_lane_out[4][0];
                      assign lanes_response_merge_engine_in[4][0]               = lanes_response_engine_in[4];

                    end
endgenerate

generate
     if(ID_BUNDLE == 2)
                    begin
                      assign lanes_fifo_request_cast_lane_out_signals_in[0][0]  = lanes_fifo_request_lane_out_signals_in[0];
                      assign lanes_fifo_request_lane_out_signals_out[0]         = lanes_fifo_request_cast_lane_out_signals_out [0][0];
                      assign lanes_fifo_response_lane_in_signals_out[0]         = lanes_fifo_response_merge_lane_in_signals_out[0][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[0][0] = lanes_fifo_response_lane_in_signals_in[0];
                      assign lanes_request_lane_out[0]                          = lanes_request_cast_lane_out[0][0];
                      assign lanes_response_merge_engine_in[0][0]               = lanes_response_engine_in[0];

                      assign lanes_fifo_request_cast_lane_out_signals_in[1][0]  = lanes_fifo_request_lane_out_signals_in[1];
                      assign lanes_fifo_request_lane_out_signals_out[1]         = lanes_fifo_request_cast_lane_out_signals_out [1][0];
                      assign lanes_fifo_response_lane_in_signals_out[1]         = lanes_fifo_response_merge_lane_in_signals_out[1][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[1][0] = lanes_fifo_response_lane_in_signals_in[1];
                      assign lanes_request_lane_out[1]                          = lanes_request_cast_lane_out[1][0];
                      assign lanes_response_merge_engine_in[1][0]               = lanes_response_engine_in[1];

                      assign lanes_fifo_request_cast_lane_out_signals_in[2][0]  = lanes_fifo_request_lane_out_signals_in[2];
                      assign lanes_fifo_request_lane_out_signals_out[2]         = lanes_fifo_request_cast_lane_out_signals_out [2][0];
                      assign lanes_fifo_response_lane_in_signals_out[2]         = lanes_fifo_response_merge_lane_in_signals_out[2][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[2][0] = lanes_fifo_response_lane_in_signals_in[2];
                      assign lanes_request_lane_out[2]                          = lanes_request_cast_lane_out[2][0];
                      assign lanes_response_merge_engine_in[2][0]               = lanes_response_engine_in[2];

                      assign lanes_fifo_request_cast_lane_out_signals_in[3][0]  = lanes_fifo_request_lane_out_signals_in[3];
                      assign lanes_fifo_request_lane_out_signals_out[3]         = lanes_fifo_request_cast_lane_out_signals_out [3][0];
                      assign lanes_fifo_response_lane_in_signals_out[3]         = lanes_fifo_response_merge_lane_in_signals_out[3][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[3][0] = lanes_fifo_response_lane_in_signals_in[3];
                      assign lanes_request_lane_out[3]                          = lanes_request_cast_lane_out[3][0];
                      assign lanes_response_merge_engine_in[3][0]               = lanes_response_engine_in[3];

                    end
endgenerate

generate
     if(ID_BUNDLE == 3)
                    begin
                      assign lanes_fifo_request_cast_lane_out_signals_in[0][0]  = lanes_fifo_request_lane_out_signals_in[0];
                      assign lanes_fifo_request_lane_out_signals_out[0]         = lanes_fifo_request_cast_lane_out_signals_out [0][0];
                      assign lanes_fifo_response_lane_in_signals_out[0]         = lanes_fifo_response_merge_lane_in_signals_out[0][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[0][0] = lanes_fifo_response_lane_in_signals_in[0];
                      assign lanes_request_lane_out[0]                          = lanes_request_cast_lane_out[0][0];
                      assign lanes_response_merge_engine_in[0][0]               = lanes_response_engine_in[0];

                      assign lanes_fifo_request_cast_lane_out_signals_in[1][0]  = lanes_fifo_request_lane_out_signals_in[1];
                      assign lanes_fifo_request_lane_out_signals_out[1]         = lanes_fifo_request_cast_lane_out_signals_out [1][0];
                      assign lanes_fifo_response_lane_in_signals_out[1]         = lanes_fifo_response_merge_lane_in_signals_out[1][0];
                      assign lanes_fifo_response_merge_lane_in_signals_in[1][0] = lanes_fifo_response_lane_in_signals_in[1];
                      assign lanes_request_lane_out[1]                          = lanes_request_cast_lane_out[1][0];
                      assign lanes_response_merge_engine_in[1][0]               = lanes_response_engine_in[1];

                    end
endgenerate
// total_luts=48610

