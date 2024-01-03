// -----------------------------------------------------------------------------
//
//    "GLay: A Vertex Centric Re-Configurable Graph Processing Overlay"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2021-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi atmughrabi@gmail.com/atmughra@virginia.edu
// File   : xpm_fifo_sync_bram_wrapper.sv
// Create : 2023-01-11 23:47:45
// Revise : 2023-06-17 16:37:19
// Editor : sublime text4, tab size (2)
// -----------------------------------------------------------------------------

module xpm_fifo_sync_bram_wrapper #(
  parameter FIFO_WRITE_DEPTH = 16   ,
  parameter WRITE_DATA_WIDTH = 32   ,
  parameter READ_DATA_WIDTH  = 32   ,
  parameter PROG_THRESH      = 6    ,
  parameter READ_MODE        = "std"
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


  localparam REG_SIZE           = 72                        ;
  localparam LAST_REG_SIZE      = READ_DATA_WIDTH % REG_SIZE;
  localparam LAST_REG_SIZE_TEST = LAST_REG_SIZE ? 1 : 0     ;
  localparam NUM_FULL_REGISTERS = READ_DATA_WIDTH / REG_SIZE;

  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] wr_en_int      ;
  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] rd_en_int      ;
  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] full_int       ;
  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] empty_int      ;
  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] valid_int      ;
  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] prog_full_int  ;
  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] wr_rst_busy_int;
  logic [(NUM_FULL_REGISTERS+LAST_REG_SIZE_TEST)-1:0] rd_rst_busy_int;

  assign full        = |full_int;
  assign empty       = &empty_int;
  assign valid       = &valid_int;
  assign prog_full   = |prog_full_int;
  assign wr_rst_busy = |wr_rst_busy_int;
  assign rd_rst_busy = |rd_rst_busy_int;

  genvar i;
  generate
    begin
      // Splitting input_data into multiple registers
      for (i = 0; i < NUM_FULL_REGISTERS; i++) begin : gen_fifo_blocks

        // Internal registers for splitting
        logic [REG_SIZE-1:0] block_dout_bits_int[NUM_FULL_REGISTERS-1:0];
        logic [REG_SIZE-1:0] block_din_bits_int [NUM_FULL_REGISTERS-1:0];

        assign block_din_bits_int[i]      = din[i*REG_SIZE +: REG_SIZE];
        assign dout[i*REG_SIZE+:REG_SIZE] = block_dout_bits_int[i];
        assign wr_en_int[i]               = wr_en;
        assign rd_en_int[i]               = rd_en;

        // xpm_fifo_sync: Synchronous FIFO
        // Xilinx Parameterized Macro
        xpm_fifo_sync #(
          .FIFO_MEMORY_TYPE   ("block"          ), //string; "auto", "block", "distributed", or "ultra";
          .ECC_MODE           ("no_ecc"         ), //string; "no_ecc" or "en_ecc";
          .FIFO_WRITE_DEPTH   (512              ), //positive integer
          .WRITE_DATA_WIDTH   (REG_SIZE         ), //positive integer
          .WR_DATA_COUNT_WIDTH($clog2(REG_SIZE) ), //positive integer
          .PROG_FULL_THRESH   (512 - PROG_THRESH), //positive integer
          .FULL_RESET_VALUE   (0                ), //positive integer; 0 or 1
          .USE_ADV_FEATURES   ("1002"           ), //string; "0000" to "1F1F", "1A0A", "1002";
          .READ_MODE          (READ_MODE        ), //string; "std" or "fwft";
          .FIFO_READ_LATENCY  (1                ), //positive integer;
          .READ_DATA_WIDTH    (REG_SIZE         ), //positive integer
          .RD_DATA_COUNT_WIDTH($clog2(REG_SIZE) ), //positive integer
          .PROG_EMPTY_THRESH  (PROG_THRESH      ), //positive integer
          .DOUT_RESET_VALUE   ("0"              ), //string
          .WAKEUP_TIME        (0                )  //positive integer; 0 or 2;
        ) xpm_fifo_sync_inst (
          .sleep        (1'b0                  ),
          .rst          (srst                  ),
          .wr_clk       (clk                   ),
          .wr_en        (wr_en_int[i]          ),
          .din          (block_din_bits_int[i] ),
          .full         (full_int[i]           ),
          .overflow     (                      ),
          .prog_full    (prog_full_int[i]      ),
          .wr_data_count(                      ),
          .almost_full  (                      ),
          .wr_ack       (                      ),
          .wr_rst_busy  (wr_rst_busy_int[i]    ),
          .rd_en        (rd_en_int[i]          ),
          .dout         (block_dout_bits_int[i]),
          .empty        (empty_int[i]          ),
          .prog_empty   (                      ),
          .rd_data_count(                      ),
          .almost_empty (                      ),
          .data_valid   (valid_int[i]          ),
          .underflow    (                      ),
          .rd_rst_busy  (rd_rst_busy_int[i]    ),
          .injectsbiterr(1'b0                  ),
          .injectdbiterr(1'b0                  ),
          .sbiterr      (                      ),
          .dbiterr      (                      )
        );

      end
    end
  endgenerate

  generate
    begin
      if (LAST_REG_SIZE_TEST > 0) begin : gen_last_block

        logic [LAST_REG_SIZE-1:0] block_dout_bits_int_last;
        logic [LAST_REG_SIZE-1:0] block_din_bits_int_last ;

        assign block_din_bits_int_last                          = din[NUM_FULL_REGISTERS*REG_SIZE +: LAST_REG_SIZE];
        assign dout[NUM_FULL_REGISTERS*REG_SIZE+:LAST_REG_SIZE] = block_dout_bits_int_last;
        assign wr_en_int[NUM_FULL_REGISTERS]                    = wr_en;
        assign rd_en_int[NUM_FULL_REGISTERS]                    = rd_en;


        // xpm_fifo_sync: Synchronous FIFO
        // Xilinx Parameterized Macro
        xpm_fifo_sync #(
          .FIFO_MEMORY_TYPE   ("auto"               ), //string; "auto", "block", "distributed", or "ultra";
          .ECC_MODE           ("no_ecc"             ), //string; "no_ecc" or "en_ecc";
          .FIFO_WRITE_DEPTH   (512                  ), //positive integer
          .WRITE_DATA_WIDTH   (LAST_REG_SIZE        ), //positive integer
          .WR_DATA_COUNT_WIDTH($clog2(LAST_REG_SIZE)), //positive integer
          .PROG_FULL_THRESH   (512 - PROG_THRESH    ), //positive integer
          .FULL_RESET_VALUE   (0                    ), //positive integer; 0 or 1
          .USE_ADV_FEATURES   ("1002"               ), //string; "0000" to "1F1F", "1A0A", "1002";
          .READ_MODE          (READ_MODE            ), //string; "std" or "fwft";
          .FIFO_READ_LATENCY  (1                    ), //positive integer;
          .READ_DATA_WIDTH    (LAST_REG_SIZE        ), //positive integer
          .RD_DATA_COUNT_WIDTH($clog2(LAST_REG_SIZE)), //positive integer
          .PROG_EMPTY_THRESH  (PROG_THRESH          ), //positive integer
          .DOUT_RESET_VALUE   ("0"                  ), //string
          .WAKEUP_TIME        (0                    )  //positive integer; 0 or 2;
        ) xpm_fifo_sync_inst (
          .sleep        (1'b0                               ),
          .rst          (srst                               ),
          .wr_clk       (clk                                ),
          .wr_en        (wr_en_int[NUM_FULL_REGISTERS]      ),
          .din          (block_din_bits_int_last            ),
          .full         (full_int[NUM_FULL_REGISTERS]       ),
          .overflow     (                                   ),
          .prog_full    (prog_full_int[NUM_FULL_REGISTERS]  ),
          .wr_data_count(                                   ),
          .almost_full  (                                   ),
          .wr_ack       (                                   ),
          .wr_rst_busy  (wr_rst_busy_int[NUM_FULL_REGISTERS]),
          .rd_en        (rd_en_int[NUM_FULL_REGISTERS]      ),
          .dout         (block_dout_bits_int_last           ),
          .empty        (empty_int[NUM_FULL_REGISTERS]      ),
          .prog_empty   (                                   ),
          .rd_data_count(                                   ),
          .almost_empty (                                   ),
          .data_valid   (valid_int[NUM_FULL_REGISTERS]      ),
          .underflow    (                                   ),
          .rd_rst_busy  (rd_rst_busy_int[NUM_FULL_REGISTERS]),
          .injectsbiterr(1'b0                               ),
          .injectdbiterr(1'b0                               ),
          .sbiterr      (                                   ),
          .dbiterr      (                                   )
        );

      end
    end
  endgenerate

endmodule : xpm_fifo_sync_bram_wrapper

