// xpm_fifo_sync: Synchronous FIFO
// Xilinx Parameterized Macro, Version 2017.4
xpm_fifo_sync #(
    .FIFO_MEMORY_TYPE   ("auto"  ), //string; "auto", "block", "distributed", or "ultra";
    .ECC_MODE           ("no_ecc"), //string; "no_ecc" or "en_ecc";
    .FIFO_WRITE_DEPTH   (2048    ), //positive integer
    .WRITE_DATA_WIDTH   (32      ), //positive integer
    .WR_DATA_COUNT_WIDTH(12      ), //positive integer
    .PROG_FULL_THRESH   (10      ), //positive integer
    .FULL_RESET_VALUE   (0       ), //positive integer; 0 or 1
    .USE_ADV_FEATURES   ("0707"  ), //string; "0000" to "1F1F";
    .READ_MODE          ("std"   ), //string; "std" or "fwft";
    .FIFO_READ_LATENCY  (1       ), //positive integer;
    .READ_DATA_WIDTH    (32      ), //positive integer
    .RD_DATA_COUNT_WIDTH(12      ), //positive integer
    .PROG_EMPTY_THRESH  (10      ), //positive integer
    .DOUT_RESET_VALUE   ("0"     ), //string
    .WAKEUP_TIME        (0       )  //positive integer; 0 or 2;
) xpm_fifo_sync_inst (
    .sleep        (1'b0         ),
    .rst          (rst          ),
    .wr_clk       (wr_clk       ),
    .wr_en        (wr_en        ),
    .din          (din          ),
    .full         (full         ),
    .overflow     (overflow     ),
    .prog_full    (prog_full    ),
    .wr_data_count(wr_data_count),
    .almost_full  (             ),
    .wr_ack       (             ),
    .wr_rst_busy  (wr_rst_busy  ),
    .rd_en        (rd_en        ),
    .dout         (dout         ),
    .empty        (empty        ),
    .prog_empty   (prog_empty   ),
    .rd_data_count(rd_data_count),
    .almost_empty (             ),
    .data_valid   (             ),
    .underflow    (underflow    ),
    .rd_rst_busy  (rd_rst_busy  ),
    .injectsbiterr(1'b0         ),
    .injectdbiterr(1'b0         ),
    .sbiterr      (             ),
    .dbiterr      (             )
);
// End of xpm_fifo_sync instance declaration