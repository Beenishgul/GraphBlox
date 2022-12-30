`timescale 1ns / 1ps
`include "iob-cache.vh"

module read_channel_native
  #(
    parameter CACHE_FRONTEND_ADDR_W   = 32,
    parameter CACHE_FRONTEND_DATA_W   = 32,
    parameter CACHE_FRONTEND_NBYTES  = CACHE_FRONTEND_DATA_W/8,
    parameter CACHE_WORD_OFF_W = 3,
    //Higher hierarchy memory (slave) interface parameters 
    parameter CACHE_BACKEND_ADDR_W = CACHE_FRONTEND_ADDR_W, //Address width of the higher hierarchy memory
    parameter CACHE_BACKEND_DATA_W = CACHE_FRONTEND_DATA_W, //Data width of the memory 
    parameter CACHE_BACKEND_NBYTES = CACHE_BACKEND_DATA_W/8, //Number of bytes
    parameter CACHE_BACKEND_BYTE_W = $clog2(CACHE_BACKEND_NBYTES), //Offset of the Number of Bytes
    //Cache-Memory base Offset
    parameter CACHE_LINE2MEM_W = CACHE_WORD_OFF_W-$clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W) //burst offset based on the cache word's and memory word size
    )
   (
    input                                        ap_clk,
    input                                        reset,
    input                                        replace_valid,
    input [CACHE_FRONTEND_ADDR_W -1: CACHE_BACKEND_BYTE_W + CACHE_LINE2MEM_W] replace_addr,
    output reg                                   replace,
    output reg                                   read_valid,
    output reg [CACHE_LINE2MEM_W-1:0]                  read_addr,
    output [CACHE_BACKEND_DATA_W-1:0]                       read_rdata,
    //Native memory interface
    output [CACHE_BACKEND_ADDR_W -1:0]                      mem_addr,
    output reg                                   mem_valid,
    input                                        mem_ready,
    input [CACHE_BACKEND_DATA_W-1:0]                        mem_rdata
    );

   generate
      if (CACHE_LINE2MEM_W > 0)
        begin

           reg [CACHE_LINE2MEM_W-1:0] word_counter;
           
           assign mem_addr  = {CACHE_BACKEND_ADDR_W{1'b0}} + {replace_addr[CACHE_FRONTEND_ADDR_W -1: CACHE_BACKEND_BYTE_W + CACHE_LINE2MEM_W], word_counter, {CACHE_BACKEND_BYTE_W{1'b0}}};
           

           // assign read_valid = mem_ready;
           assign read_rdata = mem_rdata;

           localparam
             idle             = 2'd0,
             handshake        = 2'd1, //the process was divided in 2 handshake steps to cause a delay in the
             end_handshake    = 2'd2; //(always 1 or a delayed valid signal), otherwise it will fail

           always @ (posedge ap_clk)
             read_addr <= word_counter;
           
           reg [1:0]            state;

           always @(posedge ap_clk, posedge reset)
             begin
                if(reset)
                  begin
                     state <= idle;
                     
                  end
                else
                  begin
                     case(state)

                       idle:
                         begin
                            if(replace_valid) //main_process flag
                              state <= handshake;                                        
                            else
                              state <= idle;                      
                         end
                       
                       handshake:
                         begin
                            if(mem_ready)
                              if(read_addr == {CACHE_LINE2MEM_W{1'b1}})
                                state <= end_handshake;
                              else
                                begin
                                   state <= handshake;
                                end
                            else
                              begin
                                 state <= handshake;
                              end
                         end
                       
                       end_handshake: //read-latency delay (last line word)
                         begin
                            state <= idle;
                         end
                       
                       default:;
                       
                     endcase                                                     
                  end         
             end
           
           
           always @*
             begin 
                mem_valid     = 1'b0;
                replace = 1'b1;
                word_counter  = 0;
                read_valid    = 1'b0;
                
                case(state)
                  
                  idle:
                    begin
                       replace = 1'b0;
                    end

                  handshake:
                    begin
                       mem_valid = ~mem_ready | ~(&read_addr);
                       word_counter = read_addr + mem_ready;
                       read_valid = mem_ready;
                    end
                  
                  default:;
                  
                  
                endcase
             end
        end // if (CACHE_LINE2MEM_W > 0)
      else
        begin
           assign mem_addr  = {CACHE_BACKEND_ADDR_W{1'b0}} + {replace_addr, {CACHE_BACKEND_BYTE_W{1'b0}}};
           
           // assign read_valid = mem_valid; //doesn require line_load since when mem_valid is HIGH, so is line_load.
           assign read_rdata = mem_rdata;

           localparam
             idle             = 2'd0,
             handshake        = 2'd1, //the process was divided in 2 handshake steps to cause a delay in the
             end_handshake    = 2'd2; //(always 1 or a delayed valid signal), otherwise it will fail
           
           
           reg [1:0]                                  state;

           always @(posedge ap_clk, posedge reset)
             begin
                if(reset)
                  state <= idle;
                else
                  begin
                     case(state)

                       idle:
                         begin
                            
                            if(replace_valid)
                              state <= handshake;                                        
                            else
                              state <= idle;                      
                         end
                       
                       handshake:
                         begin
                            if(mem_ready)
                              state <= end_handshake;
                            else
                              state <= handshake;
                         end
                       
                       end_handshake: //read-latency delay (last line word)
                         begin
                            state <= idle;
                         end
                       
                       default:;
                       
                     endcase                                                     
                  end         
             end
           
           
           always @*
             begin 
                mem_valid     = 1'b0;
                replace = 1'b1;
                read_valid    = 1'b0;
                
                case(state)
                  
                  idle:
                    begin
                       replace = 1'b0;
                    end

                  handshake:
                    begin
                       mem_valid = ~mem_ready;
                       read_valid = mem_ready;
                    end
                  
                  default:;
                  
                endcase
             end
           
        end // else: !if(MEM_OFF_W > 0)
   endgenerate
   
endmodule // read_process_native




