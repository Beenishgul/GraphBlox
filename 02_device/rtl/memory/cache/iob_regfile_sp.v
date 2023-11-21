`include "global_timescale.vh"

module iob_regfile_sp #(
   parameter ADDR_W = 2,
   parameter DATA_W = 21
) (
   input [1-1:0] clk_i,
   input [1-1:0] cke_i,
   input [1-1:0] arst_i,
   input         rst_i,

   input               we_i,
   input  [ADDR_W-1:0] addr_i,
   input  [DATA_W-1:0] d_i,
   output [DATA_W-1:0] d_o
);

   wire [DATA_W*(2**ADDR_W)-1:0] data_in = d_i << (addr_i * DATA_W);
   wire [DATA_W*(2**ADDR_W)-1:0]                                     data_out;
   assign d_o = data_out >> (addr_i * DATA_W);

   genvar i;
   generate
      for (i = 0; i < 2 ** ADDR_W; i = i + 1) begin : g_regfile
         wire reg_en_i = we_i & (addr_i == i);
         iob_reg_re #(
            .DATA_W(DATA_W)
         ) regfile_sp_inst (
            .clk_i (clk_i),                             //clock signal
            .cke_i (cke_i),                             //clock enable
            .arst_i(arst_i),                            //asynchronous reset
            .rst_i (rst_i),
            .en_i  (reg_en_i),
            .data_i(data_in[DATA_W*(i+1)-1:DATA_W*i]),
            .data_o(data_out[DATA_W*(i+1)-1:DATA_W*i])
         );
      end
   endgenerate

endmodule
