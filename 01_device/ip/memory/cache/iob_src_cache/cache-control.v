`timescale 1ns / 1ps
`include "iob-cache.vh"
/*------------------*/
/* Cache Control */
/*------------------*/
//Module responsible for performance measuring, information about the current cache state, and other cache functions

module cache_control #(
  parameter CACHE_FRONTEND_DATA_W = 32,
  parameter CACHE_CTRL_CNT  = 1
) (
  input                         ap_clk        ,
  input                         reset      ,
  input                         valid      ,
  input      [`CTRL_ADDR_W-1:0] addr       ,
  input                         wtbuf_full ,
  input                         wtbuf_empty,
  input                         write_hit  ,
  input                         write_miss ,
  input                         read_hit   ,
  input                         read_miss  ,
  output reg [   CACHE_FRONTEND_DATA_W-1:0] rdata      ,
  output reg                    ready      ,
  output reg                    invalidate
);

  generate
    if(CACHE_CTRL_CNT)
      begin

        reg  [CACHE_FRONTEND_DATA_W-1:0] read_hit_cnt, read_miss_cnt, write_hit_cnt, write_miss_cnt;
        wire [CACHE_FRONTEND_DATA_W-1:0] hit_cnt, miss_cnt;
        reg                  counter_reset;

        assign hit_cnt  = read_hit_cnt  + write_hit_cnt;
        assign miss_cnt = read_miss_cnt + write_miss_cnt;

        always @ (posedge ap_clk, posedge reset)
          begin
            if (reset)
              begin
                read_hit_cnt  <= {CACHE_FRONTEND_DATA_W{1'b0}};
                read_miss_cnt <= {CACHE_FRONTEND_DATA_W{1'b0}};
                write_hit_cnt  <= {CACHE_FRONTEND_DATA_W{1'b0}};
                write_miss_cnt <= {CACHE_FRONTEND_DATA_W{1'b0}};
              end
            else
              begin
                if (counter_reset)
                  begin
                    read_hit_cnt  <= {CACHE_FRONTEND_DATA_W{1'b0}};
                    read_miss_cnt <= {CACHE_FRONTEND_DATA_W{1'b0}};
                    write_hit_cnt  <= {CACHE_FRONTEND_DATA_W{1'b0}};
                    write_miss_cnt <= {CACHE_FRONTEND_DATA_W{1'b0}};
                  end
                else
                  if (read_hit)
                    begin
                      read_hit_cnt <= read_hit_cnt + 1;
                    end
                else if (write_hit)
                  begin
                    write_hit_cnt <= write_hit_cnt + 1;
                  end
                else if (read_miss)
                  begin
                    read_miss_cnt <= read_miss_cnt + 1;
                    read_hit_cnt <= read_hit_cnt - 1;
                  end
                else if (write_miss)
                  begin
                    write_miss_cnt <= write_miss_cnt + 1;
                  end
                else
                  begin
                    read_hit_cnt <= read_hit_cnt;
                    read_miss_cnt <= read_miss_cnt;
                    write_hit_cnt <= write_hit_cnt;
                    write_miss_cnt <= write_miss_cnt;
                  end
              end // else: !if(ctrl_arst)
          end // always @ (posedge ap_clk, posedge ctrl_arst)

          always @ (posedge ap_clk)
          begin
            rdata <= {CACHE_FRONTEND_DATA_W{1'b0}};
            invalidate <= 1'b0;
            counter_reset <= 1'b0;
            ready <= valid; // Sends acknowlege the next clock cycle after request (handshake)
            if(valid)
              if (addr == `ADDR_CACHE_HIT)
                rdata <= hit_cnt;
            else if (addr == `ADDR_CACHE_MISS)
              rdata <= miss_cnt;
            else if (addr == `ADDR_CACHE_READ_HIT)
              rdata <= read_hit_cnt;
            else if (addr == `ADDR_CACHE_READ_MISS)
              rdata <= read_miss_cnt;
            else if (addr == `ADDR_CACHE_WRITE_HIT)
              rdata <= write_hit_cnt;
            else if (addr == `ADDR_CACHE_WRITE_MISS)
              rdata <= write_miss_cnt;
            else if (addr == `ADDR_RESET_COUNTER)
              counter_reset <= 1'b1;
            else if (addr == `ADDR_CACHE_INVALIDATE)
              invalidate <= 1'b1;
            else if (addr == `ADDR_BUFFER_EMPTY)
              rdata <= wtbuf_empty;
            else if (addr == `ADDR_BUFFER_FULL)
              rdata <= wtbuf_full;
          end // always @ (posedge ap_clk)
        end // if (CACHE_CTRL_CNT)
      else
        begin

          always @ (posedge ap_clk)
          begin
            rdata <= {CACHE_FRONTEND_DATA_W{1'b0}};
            invalidate <= 1'b0;
            ready <= valid; // Sends acknowlege the next clock cycle after request (handshake)
            if(valid)
              if (addr == `ADDR_CACHE_INVALIDATE)
                invalidate <= 1'b1;
            else if (addr == `ADDR_BUFFER_EMPTY)
              rdata <= wtbuf_empty;
            else if (addr == `ADDR_BUFFER_FULL)
              rdata <= wtbuf_full;
          end // always @ (posedge ap_clk)
        end // else: !if(CACHE_CTRL_CNT)
    endgenerate

  endmodule // cache_controller
