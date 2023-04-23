`timescale 1ns / 1ps
`include "iob-cache.vh"

module back_end_native
  #(
    //memory cache's parameters
    parameter CACHE_FRONTEND_ADDR_W   = 32,       //Address width - width of the Master's entire access address (including the LSBs that are discarded, but discarding the Controller's)
    parameter CACHE_FRONTEND_DATA_W   = 32,       //Data width - word size used for the cache
    parameter CACHE_WORD_OFF_W = 3,      //Word-Offset Width - 2**OFFSET_W total CACHE_FRONTEND_DATA_W words per line - WARNING about CACHE_LINE2MEM_W (can cause word_counter [-1:0]
    parameter CACHE_BACKEND_ADDR_W = CACHE_FRONTEND_ADDR_W, //Address width of the higher hierarchy memory
    parameter CACHE_BACKEND_DATA_W = CACHE_FRONTEND_DATA_W, //Data width of the memory

    parameter CACHE_FRONTEND_NBYTES  = CACHE_FRONTEND_DATA_W/8,        //Number of Bytes per Word
    parameter CACHE_FRONTEND_BYTE_W  = $clog2(CACHE_FRONTEND_NBYTES), //Byte Offset
    /*---------------------------------------------------*/
    //Higher hierarchy memory (slave) interface parameters 

    parameter CACHE_BACKEND_NBYTES = CACHE_BACKEND_DATA_W/8, //Number of bytes
    parameter CACHE_BACKEND_BYTE_W = $clog2(CACHE_BACKEND_NBYTES), //Offset of Number of Bytes
    //Cache-Memory base Offset
    parameter CACHE_LINE2MEM_W = CACHE_WORD_OFF_W-$clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W),
    // Write-Policy
    parameter CACHE_WRITE_POL = `WRITE_THROUGH //write policy: write-through (0), write-back (1)
  
    ) 
   (
    input                                                                    clk,
    input                                                                    reset,
    //write-through-buffer
    input                                                                    write_valid,
    input [CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W + CACHE_WRITE_POL*CACHE_WORD_OFF_W]                     write_addr,
    input [CACHE_FRONTEND_DATA_W + CACHE_WRITE_POL*(CACHE_FRONTEND_DATA_W*(2**CACHE_WORD_OFF_W)-CACHE_FRONTEND_DATA_W)-1 :0] write_wdata,
    input [CACHE_FRONTEND_NBYTES-1:0]                                                    write_wstrb,
    output                                                                   write_ready,
    //cache-line replacement
    input                                                                    replace_valid,
    input [CACHE_FRONTEND_ADDR_W -1: CACHE_FRONTEND_BYTE_W + CACHE_WORD_OFF_W]                             replace_addr,
    output                                                                   replace,
    output                                                                   read_valid,
    output [CACHE_LINE2MEM_W -1:0]                                                 read_addr,
    output [CACHE_BACKEND_DATA_W -1:0]                                                  read_rdata,
    //back-end memory interface
    output                                                                   mem_valid,
    output [CACHE_BACKEND_ADDR_W -1:0]                                                  mem_addr,
    output [CACHE_BACKEND_DATA_W-1:0]                                                   mem_wdata,
    output [CACHE_BACKEND_NBYTES-1:0]                                                   mem_wstrb,
    input [CACHE_BACKEND_DATA_W-1:0]                                                    mem_rdata,
    input                                                                    mem_ready
    );

   wire [CACHE_BACKEND_ADDR_W-1:0]                                                      mem_addr_read,  mem_addr_write;
   wire                                                                      mem_valid_read, mem_valid_write;

   assign mem_addr =  (mem_valid_read)? mem_addr_read : mem_addr_write;
   assign mem_valid = mem_valid_read | mem_valid_write;                   
   
   
   read_channel_native
     #(
       .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
       .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),  
       .CACHE_WORD_OFF_W(CACHE_WORD_OFF_W),
       .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W),
       .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W)
       )
   read_fsm
     (
      .clk(clk),
      .reset(reset),
      .replace_valid (replace_valid),
      .replace_addr (replace_addr),
      .replace (replace),
      .read_valid (read_valid),
      .read_addr (read_addr),
      .read_rdata (read_rdata),
      .mem_addr(mem_addr_read),
      .mem_valid(mem_valid_read),
      .mem_ready(mem_ready),
      .mem_rdata(mem_rdata)  
      );

   write_channel_native
     #(
       .CACHE_FRONTEND_ADDR_W (CACHE_FRONTEND_ADDR_W),
       .CACHE_FRONTEND_DATA_W (CACHE_FRONTEND_DATA_W),
       .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W),
       .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W),
       .CACHE_WRITE_POL (CACHE_WRITE_POL),
       .CACHE_WORD_OFF_W(CACHE_WORD_OFF_W)
       )
   write_fsm
     (
      .clk(clk),
      .reset(reset),
      .valid (write_valid),
      .addr (write_addr),
      .wstrb (write_wstrb),
      .wdata (write_wdata),
      .ready (write_ready),
      .mem_addr(mem_addr_write),
      .mem_valid(mem_valid_write),
      .mem_ready(mem_ready),
      .mem_wdata(mem_wdata),
      .mem_wstrb(mem_wstrb)
      );
   
endmodule // back_end_native
