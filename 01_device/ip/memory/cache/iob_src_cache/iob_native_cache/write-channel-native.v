`timescale 1ns / 1ps
`include "iob-cache.vh"

module write_channel_native
  #(
    parameter CACHE_FRONTEND_ADDR_W = 32,
    parameter CACHE_FRONTEND_DATA_W = 32,
    parameter CACHE_FRONTEND_NBYTES = CACHE_FRONTEND_DATA_W/8,
    parameter CACHE_FRONTEND_BYTE_W = $clog2(CACHE_FRONTEND_NBYTES),
    parameter CACHE_BACKEND_ADDR_W = CACHE_FRONTEND_ADDR_W,
    parameter CACHE_BACKEND_DATA_W = CACHE_FRONTEND_DATA_W,
    parameter CACHE_BACKEND_NBYTES = CACHE_BACKEND_DATA_W/8,
    parameter CACHE_BACKEND_BYTE_W = $clog2(CACHE_BACKEND_NBYTES),
    // Write-Policy
    parameter CACHE_WRITE_POL  = `WRITE_THROUGH, //write policy: write-through (0), write-back (1)
    parameter CACHE_WORD_OFF_W = 3, //required for write-back
    parameter CACHE_LINE2MEM_W = CACHE_WORD_OFF_W-$clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W) //burst offset based on the cache and memory word size
    )
   (
    input                                                                   clk,
    input                                                                   reset,

    input                                                                   valid,
    input [CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W + CACHE_WRITE_POL*CACHE_WORD_OFF_W]                    addr,
    input [CACHE_FRONTEND_NBYTES-1:0]                                                   wstrb,
    input [CACHE_FRONTEND_DATA_W + CACHE_WRITE_POL*(CACHE_FRONTEND_DATA_W*(2**CACHE_WORD_OFF_W)-CACHE_FRONTEND_DATA_W)-1:0] wdata, //try [CACHE_FRONTEND_DATA_W*((2**CACHE_WORD_OFF_W)**CACHE_WRITE_POL)-1:0] (f(x)=a*b^x)
    output reg                                                              ready,
    //Native Memory interface
    output [CACHE_BACKEND_ADDR_W -1:0]                                                 mem_addr,
    output reg                                                              mem_valid,
    input                                                                   mem_ready,
    output [CACHE_BACKEND_DATA_W-1:0]                                                  mem_wdata,
    output reg [CACHE_BACKEND_NBYTES-1:0]                                              mem_wstrb

    );

    genvar                                                                   i;

    generate
      if(CACHE_WRITE_POL == `WRITE_THROUGH) begin

        assign mem_addr = {CACHE_BACKEND_ADDR_W{1'b0}} + {addr[CACHE_FRONTEND_ADDR_W-1:CACHE_BACKEND_BYTE_W], {CACHE_BACKEND_BYTE_W{1'b0}}};

        localparam
          idle  = 1'd0,
          write = 1'd1;

          reg [0:0] state;
          if(CACHE_BACKEND_DATA_W == CACHE_FRONTEND_DATA_W) begin
            assign mem_wdata = wdata;
            always @* begin
              mem_wstrb = 0;
              case(state)
                write: mem_wstrb = wstrb;
                default:;
              endcase // case (state)
            end // always @ *
          end
          else begin
            wire [CACHE_BACKEND_BYTE_W-CACHE_FRONTEND_BYTE_W -1 :0] word_align = addr[CACHE_FRONTEND_BYTE_W +: (CACHE_BACKEND_BYTE_W - CACHE_FRONTEND_BYTE_W)];

            for (i = 0; i < CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W; i = i +1) begin : wdata_block
              assign mem_wdata[(i+1)*CACHE_FRONTEND_DATA_W-1:i*CACHE_FRONTEND_DATA_W] = wdata;
            end

            always @* begin
              mem_wstrb = 0;
              case(state)
                write: mem_wstrb = wstrb << word_align * CACHE_FRONTEND_NBYTES;
                default:;
              endcase // case (state)
            end // always @ *
          end

          always @(posedge clk, posedge reset) begin
            if(reset)
              state <= idle;
            else
              case(state)
                idle: begin
                  if(valid)
                    state <= write;
                  else
                    state <= idle;
                end
                //write: begin
                default: begin
                  if(mem_ready & ~valid)
                    state <= idle;
                  else
                    if(mem_ready & valid) //still has data to write
                      state <= write;
                    else
                      state <= write;
                end
              endcase // case (state)
          end // always @ (posedge clk, posedge reset)

         always @*
           begin
              ready = 1'b0;
              mem_valid = 1'b0;
              case(state)
                idle:
                  ready = 1'b1;
                //write:
                default:
                  begin
                     mem_valid = ~mem_ready;
                     ready = mem_ready;
                  end
              endcase // case (state)
           end
      end // if (CACHE_WRITE_POL == WRITE_THROUGH)
      //////////////////////////////////////////////////////////////////////////////////////////////
      else begin // if (CACHE_WRITE_POL == WRITE_BACK)

         if (CACHE_LINE2MEM_W > 0) begin

            reg [CACHE_LINE2MEM_W-1:0] word_counter, word_counter_reg;
            always @(posedge clk) word_counter_reg <= word_counter;

            // memory address
            assign mem_addr  = {CACHE_BACKEND_ADDR_W{1'b0}} + {addr[CACHE_FRONTEND_ADDR_W-1: CACHE_BACKEND_BYTE_W + CACHE_LINE2MEM_W], word_counter, {CACHE_BACKEND_BYTE_W{1'b0}}};
            // memory write-data
            assign mem_wdata = wdata>>(CACHE_BACKEND_DATA_W*word_counter);

            localparam
              idle  = 1'd0,
              write = 1'd1;

            reg [0:0]            state;

            always @(posedge clk, posedge reset)
              begin
                 if(reset)
                   state <= idle;
                 else
                   case(state)

                     idle:
                       begin
                          if(valid)
                            state <= write;
                          else
                            state <= idle;
                       end

                     //write:
                     default:
                       begin
                          if(mem_ready & (&word_counter_reg))
                            state <= idle;
                          else
                            state <= write;
                       end
                   endcase // case (state)
              end // always @ (posedge clk, posedge reset)

            always @*
              begin
                 ready        = 1'b0;
                 mem_valid    = 1'b0;
                 mem_wstrb    = 0;
                 word_counter = 0;

                 case(state)
                   idle:
                     begin
                        ready = ~valid;
                        if(valid) mem_wstrb = {CACHE_BACKEND_NBYTES{1'b1}};
                        else mem_wstrb =0;
                     end

                   //write:
                   default:
                     begin
                        ready = mem_ready & (&word_counter); //last word transfered
                        mem_valid = ~(mem_ready & (&word_counter));
                        mem_wstrb = {CACHE_BACKEND_NBYTES{1'b1}};
                        word_counter = word_counter_reg + mem_ready;
                     end
                 endcase // case (state)
              end

         end // if (CACHE_LINE2MEM_W > 0)
         else begin // if (CACHE_LINE2MEM_W == 0)

            // memory address
            assign mem_addr  = {CACHE_BACKEND_ADDR_W{1'b0}} + {addr[CACHE_FRONTEND_ADDR_W-1: CACHE_BACKEND_BYTE_W], {CACHE_BACKEND_BYTE_W{1'b0}}};
            // memory write-data
            assign mem_wdata = wdata;

            localparam
              idle  = 1'd0,
              write = 1'd1;

            reg [0:0]            state;

            always @(posedge clk, posedge reset)
              begin
                 if(reset)
                   state <= idle;
                 else
                   case(state)

                     idle:
                       begin
                          if(valid)
                            state <= write;
                          else
                            state <= idle;
                       end

                     //write:
                     default:
                       begin
                          if(mem_ready)
                            state <= idle;
                          else
                            state <= write;
                       end
                   endcase // case (state)
              end // always @ (posedge clk, posedge reset)

            always @*
              begin
                 ready        = 1'b0;
                 mem_valid    = 1'b0;
                 mem_wstrb    = 0;

                 case(state)
                   idle:
                     begin
                        ready = ~valid;
                        if(valid) mem_wstrb = {CACHE_BACKEND_NBYTES{1'b1}};
                        else mem_wstrb = 0;
                     end

                   //write:
                   default:
                     begin
                        ready = mem_ready;
                        mem_valid = ~mem_ready;
                        mem_wstrb = {CACHE_BACKEND_NBYTES{1'b1}};
                     end
                 endcase // case (state)
              end // always @ *

         end // else: !if(CACHE_LINE2MEM_W > 0)
      end // else: !if(CACHE_WRITE_POL == WRITE_THROUGH)
   endgenerate

endmodule
