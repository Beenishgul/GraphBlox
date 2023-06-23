// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : xpm_fifo_sync_fwft_wrapper.sv
// Create : 2023-06-23 15:07:59
// Revise : 2023-06-23 15:08:10
// Editor : sublime text4, tab size (3)
// -----------------------------------------------------------------------------

module xpm_fifo_sync_fwft_wrapper(rst, 
                     rd_clk, rd_en, dout, empty,                 
                     wr_clk, wr_en, din, full);

   parameter width = 8;
   
   input                 rst;
   input                 rd_clk;
   input                 rd_en;
   input                 wr_clk;
   input                 wr_en;
   input [(width-1):0]   din;
   output                empty;
   output                full;
   output [(width-1):0]  dout;

   reg                   middle_valid, dout_valid;
   reg [(width-1):0]     dout, middle_dout;

   wire [(width-1):0]    fifo_dout;
   wire                  fifo_empty, fifo_rd_en;
   wire                  will_update_middle, will_update_dout;

   // orig_fifo is "standard" (non-FWFT) FIFO
   fifo orig_fifo
      (
       .rst(rst),       
       .rd_clk(rd_clk),
       .rd_en(fifo_rd_en),
       .dout(fifo_dout),
       .empty(fifo_empty),
       .wr_clk(wr_clk),
       .wr_en(wr_en),
       .din(din),
       .full(full)
       );

   assign will_update_middle = !fifo_empty && (middle_valid == will_update_dout);
   assign will_update_dout = (middle_valid || !fifo_empty) && (rd_en || !dout_valid);
   assign fifo_rd_en = !fifo_empty && !(middle_valid && dout_valid);
   assign empty = !dout_valid;

   always @(posedge rd_clk)
      if (rst)
         begin
            middle_valid <= 0;
            dout_valid <= 0;
            dout <= 0;
            middle_dout <= 0;
         end
      else
         begin
            if (will_update_middle)
               middle_dout <= fifo_dout;
            
            if (will_update_dout)
               dout <= middle_valid ? middle_dout : fifo_dout;
            
            if (fifo_rd_en)
               fifo_valid <= 1;
            else if (will_update_middle || will_update_dout)
               fifo_valid <= 0;
            
            if (will_update_middle)
               middle_valid <= 1;
            else if (will_update_dout)
               middle_valid <= 0;
            
            if (will_update_dout)
               dout_valid <= 1;
            else if (rd_en)
               dout_valid <= 0;
         end 
endmodule