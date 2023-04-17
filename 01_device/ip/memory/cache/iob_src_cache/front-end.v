`timescale 1ns / 1ps
`include "iob-cache.vh"

module front_end
  #(
    parameter CACHE_FRONTEND_ADDR_W   = 32,       //Address width - width that will used for the cache 
    parameter CACHE_FRONTEND_DATA_W   = 32,       //Data width - word size used for the cache

    //Do NOT change - memory cache's parameters - dependency
    parameter CACHE_FRONTEND_NBYTES  = CACHE_FRONTEND_DATA_W/8,       //Number of Bytes per Word
    parameter CACHE_FRONTEND_BYTE_W = $clog2(CACHE_FRONTEND_NBYTES), //Offset of the Number of Bytes per Word
    //Control's options
    parameter CACHE_CTRL_CACHE = 0,
    parameter CACHE_CTRL_CNT = 0
    )
   (
    //front-end port
    input                                       ap_clk,
    input                                       reset,
`ifdef WORD_ADDR   
    input [CACHE_CTRL_CACHE + CACHE_FRONTEND_ADDR_W -1:CACHE_FRONTEND_BYTE_W] addr, //MSB is used for Controller selection
`else
    input [CACHE_CTRL_CACHE + CACHE_FRONTEND_ADDR_W -1:0]         addr, //MSB is used for Controller selection
`endif
    input [CACHE_FRONTEND_DATA_W-1:0]                       wdata,
    input [CACHE_FRONTEND_NBYTES-1:0]                       wstrb,
    input                                       valid,
    output                                      ready,
    output [CACHE_FRONTEND_DATA_W-1:0]                      rdata,

    //internal input signals
    output                                      data_valid,
    output [CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W]              data_addr,
    //output [CACHE_FRONTEND_DATA_W-1:0]                      data_wdata,
    //output [CACHE_FRONTEND_NBYTES-1:0]                      data_wstrb,
    input [CACHE_FRONTEND_DATA_W-1:0]                       data_rdata,
    input                                       data_ready,
    //stored input signals
    output                                      data_valid_reg,
    output [CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W]              data_addr_reg,
    output [CACHE_FRONTEND_DATA_W-1:0]                      data_wdata_reg,
    output [CACHE_FRONTEND_NBYTES-1:0]                      data_wstrb_reg,
    //cache-control
    output                                      ctrl_valid,
    output [`CTRL_ADDR_W-1:0]                   ctrl_addr, 
    input [CACHE_CTRL_CACHE*(CACHE_FRONTEND_DATA_W-1):0]          ctrl_rdata,
    input                                       ctrl_ready
    );
   
   wire                                         valid_int;
   
   reg                                          valid_reg;
   reg [CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W]                  addr_reg;
   reg [CACHE_FRONTEND_DATA_W-1:0]                          wdata_reg;
   reg [CACHE_FRONTEND_NBYTES-1:0]                          wstrb_reg;

   assign data_valid_reg = valid_reg;
   assign data_addr_reg = addr_reg;
   assign data_wdata_reg = wdata_reg;
   assign data_wstrb_reg = wstrb_reg;

   
   //////////////////////////////////////////////////////////////////////////////////
     //    Cache-selection - cache-memory or cache-control 
   /////////////////////////////////////////////////////////////////////////////////
   generate
      if(CACHE_CTRL_CACHE) 
        begin

           //Front-end output signals
           assign ready = ctrl_ready | data_ready;
           assign rdata = (ctrl_ready)? ctrl_rdata  : data_rdata;     
           
           assign valid_int  = ~addr[CACHE_CTRL_CACHE + CACHE_FRONTEND_ADDR_W -1] & valid;
           
           assign ctrl_valid =  addr[CACHE_CTRL_CACHE + CACHE_FRONTEND_ADDR_W -1] & valid;       
           assign ctrl_addr  =  addr[CACHE_FRONTEND_BYTE_W +: `CTRL_ADDR_W];
           
        end // if (CACHE_CTRL_CACHE)
      else 
        begin
           //Front-end output signals
           assign ready = data_ready; 
           assign rdata = data_rdata;
           
           assign valid_int = valid;
           
           assign ctrl_valid = 1'bx;
           assign ctrl_addr = `CTRL_ADDR_W'dx;
           
        end // else: !if(CACHE_CTRL_CACHE)
   endgenerate

   //////////////////////////////////////////////////////////////////////////////////
   // Input Data stored signals
   /////////////////////////////////////////////////////////////////////////////////

   always @(posedge ap_clk, posedge reset)
     begin
        if(reset)
          begin
             valid_reg <= 0;
             addr_reg  <= 0;
             wdata_reg <= 0;
             wstrb_reg <= 0;
             
          end
        else
          begin
             valid_reg <= valid_int;
             addr_reg  <= addr[CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W];
             wdata_reg <= wdata;
             wstrb_reg <= wstrb;
          end
     end // always @ (posedge ap_clk, posedge reset)  

   
   //////////////////////////////////////////////////////////////////////////////////
   // Data-output ports
   /////////////////////////////////////////////////////////////////////////////////
   
   
   assign data_addr  = addr[CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W];
   assign data_valid = valid_int | valid_reg;
   
   assign data_addr_reg  = addr_reg[CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W];
   assign data_wdata_reg = wdata_reg;
   assign data_wstrb_reg = wstrb_reg;
   assign data_valid_reg = valid_reg;
   
endmodule
