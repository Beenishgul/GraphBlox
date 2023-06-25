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
// Revise : 2023-06-25 00:25:20
// Editor : sublime text4, tab size (3)
// -----------------------------------------------------------------------------

module xpm_fifo_sync_fwft_wrapper #(
   parameter FIFO_WRITE_DEPTH = 16,
   parameter WRITE_DATA_WIDTH = 32,
   parameter READ_DATA_WIDTH  = 32,
   parameter PROG_THRESH      = 6
) (
   input  logic                        clk        ,
   input  logic                        srst       ,
   input  logic [WRITE_DATA_WIDTH-1:0] din        ,
   input  logic                        wr_en      ,
   input  logic                        rd_en      ,
   output logic [ READ_DATA_WIDTH-1:0] dout       ,
   output logic                        full       ,
   output logic                        empty      ,
   output logic                        valid      ,
   output logic                        prog_full  ,
   output logic                        wr_rst_busy,
   output logic                        rd_rst_busy
);


   logic                         middle_valid, dout_valid, fifo_valid;
   logic [(READ_DATA_WIDTH-1):0] middle_dout ;

   logic [(WRITE_DATA_WIDTH-1):0] fifo_dout         ;
   logic                          fifo_empty, fifo_rd_en;
   logic                          will_update_middle, will_update_dout;

   assign will_update_middle = fifo_valid && (middle_valid == will_update_dout);
   assign will_update_dout   = (middle_valid || !fifo_empty) && (rd_en || !dout_valid);
   assign fifo_rd_en         = fifo_valid && !(middle_valid && dout_valid);
   assign empty              = !(fifo_valid || middle_valid);
   assign empty              = dout_valid;

   always @(posedge clk)
      if (srst)
         begin
            middle_valid <= 0;
            dout_valid   <= 0;
            dout         <= 0;
            middle_dout  <= 0;
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


// xpm_fifo_sync: Synchronous FIFO
// Xilinx Parameterized Macro
   xpm_fifo_sync #(
      .FIFO_MEMORY_TYPE   ("auto"                        ), //string; "auto", "block", "distributed", or "ultra";
      .ECC_MODE           ("no_ecc"                      ), //string; "no_ecc" or "en_ecc";
      .FIFO_WRITE_DEPTH   (FIFO_WRITE_DEPTH              ), //positive integer
      .WRITE_DATA_WIDTH   (WRITE_DATA_WIDTH              ), //positive integer
      .WR_DATA_COUNT_WIDTH($clog2(WRITE_DATA_WIDTH)      ), //positive integer
      .PROG_FULL_THRESH   (FIFO_WRITE_DEPTH - PROG_THRESH), //positive integer
      .FULL_RESET_VALUE   (0                             ), //positive integer; 0 or 1
      .USE_ADV_FEATURES   ("1002"                        ), //string; "0000" to "1F1F", "1A0A", "1002";
      .READ_MODE          ("std"                         ), //string; "std" or "fwft";
      .FIFO_READ_LATENCY  (1                             ), //positive integer;
      .READ_DATA_WIDTH    (READ_DATA_WIDTH               ), //positive integer
      .RD_DATA_COUNT_WIDTH($clog2(READ_DATA_WIDTH)       ), //positive integer
      .PROG_EMPTY_THRESH  (PROG_THRESH                   ), //positive integer
      .DOUT_RESET_VALUE   ("0"                           ), //string
      .WAKEUP_TIME        (0                             )  //positive integer; 0 or 2;
   ) xpm_fifo_sync_inst (
      .sleep        (1'b0       ),
      .rst          (srst       ),
      .wr_clk       (clk        ),
      .wr_en        (wr_en      ),
      .din          (din        ),
      .full         (full       ),
      .overflow     (           ),
      .prog_full    (prog_full  ),
      .wr_data_count(           ),
      .almost_full  (           ),
      .wr_ack       (           ),
      .wr_rst_busy  (wr_rst_busy),
      .rd_en        (fifo_rd_en ),
      .dout         (fifo_dout  ),
      .empty        (fifo_empty ),
      .prog_empty   (           ),
      .rd_data_count(           ),
      .almost_empty (           ),
      .data_valid   (           ),
      .underflow    (           ),
      .rd_rst_busy  (rd_rst_busy),
      .injectsbiterr(1'b0       ),
      .injectdbiterr(1'b0       ),
      .sbiterr      (           ),
      .dbiterr      (           )
   );
// End of xpm_fifo_sync instance declaration

endmodule : xpm_fifo_sync_fwft_wrapper
