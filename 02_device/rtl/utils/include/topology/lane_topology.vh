
generate
     if((ID_BUNDLE == 0) && (ID_LANE == 0))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 0) && (ID_LANE == 1))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 0) && (ID_LANE == 2))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 0) && (ID_LANE == 3))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 1) && (ID_LANE == 0))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

               assign engines_response_merge_lane_in[1][0]        = engines_response_lane_in[1];
               assign engines_fifo_response_merge_lane_in_signals_in[1][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[1] = engines_fifo_response_merge_lane_in_signals_out[1][0];
               assign engines_request_lane_out[1]                  = engines_request_cast_lane_out[1][0];
               assign engines_fifo_request_cast_lane_out_signals_in[1][0].rd_en = engines_fifo_request_lane_out_signals_in[1].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[1] = engines_fifo_request_cast_lane_out_signals_out [1][0];

               assign engines_response_merge_lane_in[1][1]          = response_lane_in[1];
               assign engines_fifo_response_merge_lane_in_signals_in[1][1].rd_en = 1'b1;
               assign fifo_response_lane_in_signals_out[1] = engines_fifo_response_merge_lane_in_signals_out[1][1];

               assign engines_response_merge_lane_in[1][2]          = response_lane_in[2];
               assign engines_fifo_response_merge_lane_in_signals_in[1][2].rd_en = 1'b1;
               assign fifo_response_lane_in_signals_out[2] = engines_fifo_response_merge_lane_in_signals_out[1][2];

               assign engines_response_merge_lane_in[2][0]        = engines_response_lane_in[2];
               assign engines_fifo_response_merge_lane_in_signals_in[2][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[2] = engines_fifo_response_merge_lane_in_signals_out[2][0];
               assign engines_request_lane_out[2]                  = engines_request_cast_lane_out[2][0];
               assign engines_fifo_request_cast_lane_out_signals_in[2][0].rd_en = engines_fifo_request_lane_out_signals_in[2].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[2] = engines_fifo_request_cast_lane_out_signals_out [2][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 1) && (ID_LANE == 1))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

               assign request_lane_out[1]                  = engines_request_cast_lane_out[0][1];
               assign engines_fifo_request_cast_lane_out_signals_in[0][1].rd_en = fifo_request_lane_out_signals_in[1].rd_en;
               assign fifo_request_lane_out_signals_out[1] = engines_fifo_request_cast_lane_out_signals_out[0][1];

          end
endgenerate



generate
     if((ID_BUNDLE == 1) && (ID_LANE == 2))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

               assign request_lane_out[1]                  = engines_request_cast_lane_out[0][1];
               assign engines_fifo_request_cast_lane_out_signals_in[0][1].rd_en = fifo_request_lane_out_signals_in[1].rd_en;
               assign fifo_request_lane_out_signals_out[1] = engines_fifo_request_cast_lane_out_signals_out[0][1];

          end
endgenerate



generate
     if((ID_BUNDLE == 1) && (ID_LANE == 3))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 2) && (ID_LANE == 0))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 2) && (ID_LANE == 1))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

               assign engines_response_merge_lane_in[1][0]        = engines_response_lane_in[1];
               assign engines_fifo_response_merge_lane_in_signals_in[1][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[1] = engines_fifo_response_merge_lane_in_signals_out[1][0];
               assign engines_request_lane_out[1]                  = engines_request_cast_lane_out[1][0];
               assign engines_fifo_request_cast_lane_out_signals_in[1][0].rd_en = engines_fifo_request_lane_out_signals_in[1].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[1] = engines_fifo_request_cast_lane_out_signals_out [1][0];

               assign engines_response_merge_lane_in[2][0]        = engines_response_lane_in[2];
               assign engines_fifo_response_merge_lane_in_signals_in[2][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[2] = engines_fifo_response_merge_lane_in_signals_out[2][0];
               assign engines_request_lane_out[2]                  = engines_request_cast_lane_out[2][0];
               assign engines_fifo_request_cast_lane_out_signals_in[2][0].rd_en = engines_fifo_request_lane_out_signals_in[2].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[2] = engines_fifo_request_cast_lane_out_signals_out [2][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 2) && (ID_LANE == 2))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 3) && (ID_LANE == 0))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

               assign engines_response_merge_lane_in[1][0]        = engines_response_lane_in[1];
               assign engines_fifo_response_merge_lane_in_signals_in[1][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[1] = engines_fifo_response_merge_lane_in_signals_out[1][0];
               assign engines_request_lane_out[1]                  = engines_request_cast_lane_out[1][0];
               assign engines_fifo_request_cast_lane_out_signals_in[1][0].rd_en = engines_fifo_request_lane_out_signals_in[1].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[1] = engines_fifo_request_cast_lane_out_signals_out [1][0];

          end
endgenerate



generate
     if((ID_BUNDLE == 3) && (ID_LANE == 1))
          begin
               assign engines_response_merge_lane_in[0][0]        = engines_response_lane_in[0];
               assign engines_fifo_response_merge_lane_in_signals_in[0][0].rd_en = 1'b1;
               assign engines_fifo_response_lane_in_signals_out[0] = engines_fifo_response_merge_lane_in_signals_out[0][0];
               assign engines_request_lane_out[0]                  = engines_request_cast_lane_out[0][0];
               assign engines_fifo_request_cast_lane_out_signals_in[0][0].rd_en = engines_fifo_request_lane_out_signals_in[0].rd_en ;
               assign engines_fifo_request_lane_out_signals_out[0] = engines_fifo_request_cast_lane_out_signals_out [0][0];

          end
endgenerate


// total_luts=45805

