`timescale 1ns / 1ps
`include "iob_lib.vh"
`include "iob-cache.vh"

module back_end_axi #(
  //memory cache's parameters
  parameter                      CACHE_FRONTEND_ADDR_W = 32                                                                 , //Address width - width of the Master's entire access address (including the LSBs that are discarded, but discarding the Controller's)
  parameter                      CACHE_FRONTEND_DATA_W = 32                                                                 , //Data width - word size used for the cache
  parameter                      CACHE_WORD_OFF_W      = 3                                                                  , //Word-Offset Width - 2**OFFSET_W total CACHE_FRONTEND_DATA_W words per line - WARNING about CACHE_LINE2MEM_W (can cause word_counter [-1:0]
  parameter                      CACHE_BACKEND_ADDR_W  = CACHE_FRONTEND_ADDR_W                                              , //Address width of the higher hierarchy memory
  parameter                      CACHE_BACKEND_DATA_W  = CACHE_FRONTEND_DATA_W                                              , //Data width of the memory
  parameter                      CACHE_FRONTEND_NBYTES = CACHE_FRONTEND_DATA_W/8                                            , //Number of Bytes per Word
  parameter                      CACHE_FRONTEND_BYTE_W = $clog2(CACHE_FRONTEND_NBYTES)                                      , //Byte Offset
  /*---------------------------------------------------*/
  //Higher hierarchy memory (slave) interface parameters
  parameter                      CACHE_BACKEND_NBYTES  = CACHE_BACKEND_DATA_W/8                                             , //Number of bytes
  parameter                      CACHE_BACKEND_BYTE_W  = $clog2(CACHE_BACKEND_NBYTES)                                       , //Offset of Number of Bytes
  //Cache-Memory base Offset
  parameter                      CACHE_LINE2MEM_W      = CACHE_WORD_OFF_W-$clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W),
  // Write-Policy
  parameter                      CACHE_WRITE_POL       = `WRITE_THROUGH                                                     , //write policy: write-through (0), write-back (1)
  //AXI specific parameters
  parameter                      CACHE_AXI_ADDR_W      = CACHE_BACKEND_ADDR_W                                               ,
  parameter                      CACHE_AXI_DATA_W      = CACHE_BACKEND_DATA_W                                               ,
  parameter                      CACHE_AXI_ID_W        = 1                                                                  , //AXI ID (identification) width
  parameter                      CACHE_AXI_LEN_W       = 8                                                                  , //AXI ID burst length (log2)
  parameter [CACHE_AXI_ID_W-1:0] CACHE_AXI_ID          = 0                                                                  , //AXI ID value
  parameter                      CACHE_AXI_LOCK_W      = 1                                                                  ,
  parameter                      CACHE_AXI_CACHE_W     = 4                                                                  ,
  parameter                      CACHE_AXI_PROT_W      = 3                                                                  ,
  parameter                      CACHE_AXI_QOS_W       = 4                                                                  ,
  parameter                      CACHE_AXI_BURST_W     = 2                                                                  ,
  parameter                      CACHE_AXI_RESP_W      = 1                                                                  ,
  parameter                      CACHE_AXI_SIZE_W      = 3
) (
  //write-through-buffer
  input                                                                                                                  write_valid  ,
  input  [                               CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W+CACHE_WRITE_POL*CACHE_WORD_OFF_W] write_addr   ,
  input  [CACHE_FRONTEND_DATA_W+CACHE_WRITE_POL*(CACHE_FRONTEND_DATA_W*(2**CACHE_WORD_OFF_W)-CACHE_FRONTEND_DATA_W)-1:0] write_wdata  ,
  input  [                                                                                    CACHE_FRONTEND_NBYTES-1:0] write_wstrb  ,
  output                                                                                                                 write_ready  ,
  //cache-line replacement
  input                                                                                                                  replace_valid,
  input  [                                               CACHE_FRONTEND_ADDR_W-1:CACHE_FRONTEND_BYTE_W+CACHE_WORD_OFF_W] replace_addr ,
  output                                                                                                                 replace      ,
  output                                                                                                                 read_valid   ,
  output [                                                                                         CACHE_LINE2MEM_W-1:0] read_addr    ,
  output [                                                                                     CACHE_BACKEND_DATA_W-1:0] read_rdata   ,
  //AXI master backend interface
  `include "m_axi_m_port.vh"
  input                                                                                                                  ap_clk          ,
  input                                                                                                                  reset
);



read_channel_axi #(
  .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
  .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),
  .CACHE_WORD_OFF_W     (CACHE_WORD_OFF_W     ),
  .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W ),
  .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W ),
  .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W     ),
  .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W     ),
  .CACHE_AXI_ID_W       (CACHE_AXI_ID_W       ),
  .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W      ),
  .CACHE_AXI_ID         (CACHE_AXI_ID         ),
  .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W     ),
  .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W    ),
  .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W     ),
  .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W      ),
  .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W    ),
  .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W     ),
  .CACHE_AXI_SIZE_W     (CACHE_AXI_SIZE_W     )
) read_fsm (
  .replace_valid(replace_valid),
  .replace_addr (replace_addr ),
  .replace      (replace      ),
  .read_valid   (read_valid   ),
  .read_addr    (read_addr    ),
  .read_rdata   (read_rdata   ),
  `include "m_axi_read_portmap.vh"
  .ap_clk          (ap_clk          ),
  .reset        (reset        )
);


write_channel_axi #(
  .CACHE_FRONTEND_ADDR_W(CACHE_FRONTEND_ADDR_W),
  .CACHE_FRONTEND_DATA_W(CACHE_FRONTEND_DATA_W),
  .CACHE_BACKEND_ADDR_W (CACHE_BACKEND_ADDR_W ),
  .CACHE_BACKEND_DATA_W (CACHE_BACKEND_DATA_W ),
  .CACHE_WRITE_POL      (CACHE_WRITE_POL      ),
  .CACHE_WORD_OFF_W     (CACHE_WORD_OFF_W     ),
  .CACHE_AXI_ADDR_W     (CACHE_AXI_ADDR_W     ),
  .CACHE_AXI_DATA_W     (CACHE_AXI_DATA_W     ),
  .CACHE_AXI_LEN_W      (CACHE_AXI_LEN_W      ),
  .CACHE_AXI_ID_W       (CACHE_AXI_ID_W       ),
  .CACHE_AXI_ID         (CACHE_AXI_ID         ),
  .CACHE_AXI_LOCK_W     (CACHE_AXI_LOCK_W     ),
  .CACHE_AXI_CACHE_W    (CACHE_AXI_CACHE_W    ),
  .CACHE_AXI_PROT_W     (CACHE_AXI_PROT_W     ),
  .CACHE_AXI_QOS_W      (CACHE_AXI_QOS_W      ),
  .CACHE_AXI_BURST_W    (CACHE_AXI_BURST_W    ),
  .CACHE_AXI_RESP_W     (CACHE_AXI_RESP_W     ),
  .CACHE_AXI_SIZE_W     (CACHE_AXI_SIZE_W     )
) write_fsm (
  .valid(write_valid),
  .addr (write_addr ),
  .wstrb(write_wstrb),
  .wdata(write_wdata),
  .ready(write_ready),
  `include "m_axi_write_portmap.vh"
  .ap_clk  (ap_clk        ),
  .reset(reset      )
);

endmodule // back_end_native
