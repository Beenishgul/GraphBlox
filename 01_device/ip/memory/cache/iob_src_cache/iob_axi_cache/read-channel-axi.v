`timescale 1ns / 1ps
`include "iob-cache.vh"

module read_channel_axi #(
  parameter                      CACHE_FRONTEND_ADDR_W = 32                                                                 ,
  parameter                      CACHE_FRONTEND_DATA_W = 32                                                                 ,
  parameter                      CACHE_FRONTEND_NBYTES = CACHE_FRONTEND_DATA_W/8                                            ,
  parameter                      CACHE_WORD_OFF_W      = 3                                                                  ,
  //Higher hierarchy memory (slave) interface parameters
  parameter                      CACHE_BACKEND_ADDR_W  = CACHE_FRONTEND_ADDR_W                                              , //Address width of the higher hierarchy memory
  parameter                      CACHE_BACKEND_DATA_W  = CACHE_FRONTEND_DATA_W                                              , //Data width of the memory
  parameter                      CACHE_BACKEND_NBYTES  = CACHE_BACKEND_DATA_W/8                                             , //Number of bytes
  parameter                      CACHE_BACKEND_BYTE_W  = $clog2(CACHE_BACKEND_NBYTES)                                       , //Offset of the Number of Bytes
  // //AXI specific parameters
  parameter                      CACHE_AXI_ADDR_W      = CACHE_BACKEND_ADDR_W                                               ,
  parameter                      CACHE_AXI_DATA_W      = CACHE_BACKEND_DATA_W                                               ,
  parameter                      CACHE_AXI_LEN_W       = 8                                                                  , //AXI ID burst length (log2)
  parameter                      CACHE_AXI_ID_W        = 1                                                                  , //AXI ID (identification) width
  parameter [CACHE_AXI_ID_W-1:0] CACHE_AXI_ID          = 0                                                                  , //AXI ID value
  parameter                      CACHE_AXI_LOCK_W      = 1                                                                  ,
  parameter                      CACHE_AXI_CACHE_W     = 4                                                                  ,
  parameter                      CACHE_AXI_PROT_W      = 3                                                                  ,
  parameter                      CACHE_AXI_QOS_W       = 4                                                                  ,
  parameter                      CACHE_AXI_BURST_W     = 2                                                                  ,
  parameter                      CACHE_AXI_RESP_W      = 1                                                                  ,
  parameter                      CACHE_AXI_SIZE_W      = 3
) (
  //IOb slave frontend interface
  input                                                                      replace_valid,
  input      [CACHE_FRONTEND_ADDR_W-1:CACHE_BACKEND_BYTE_W] replace_addr ,
  output reg                                                                 replace      ,
  output                                                                     read_valid   ,
  output     [                                     CACHE_BACKEND_DATA_W-1:0] read_rdata   ,
  //AXI master backend interface
  `include "m_axi_m_read_port.vh"
  input                                                                      ap_clk          ,
  input                                                                      reset
);


reg m_axi_arvalid_int;
reg m_axi_rready_int ;

assign m_axi_arvalid = m_axi_arvalid_int;
assign m_axi_rready  = m_axi_rready_int;


//Constant AXI signals
assign m_axi_arid    = CACHE_AXI_ID;
assign m_axi_arlock  = 1'b0;
assign m_axi_arcache = 4'b1111;
assign m_axi_arprot  = 3'd0;
//Burst parameters
assign m_axi_arlen   = 8'd0; //will choose the burst lenght depending on the cache's and slave's data width
assign m_axi_arsize  = CACHE_BACKEND_BYTE_W; //each word will be the width of the memory for maximum bandwidth
assign m_axi_arburst = 2'b01; //incremental burst
assign m_axi_araddr  = {CACHE_BACKEND_ADDR_W{1'b0}} + {replace_addr, {(CACHE_BACKEND_BYTE_W){1'b0}}}; //base address for the burst, with width extension
assign m_axi_arqos   = 4'd0;

// Read Line values
assign read_rdata = m_axi_rdata;
assign read_valid = m_axi_rvalid;


localparam
  idle          = 2'd0,
  init_process  = 2'd1,
  load_process  = 2'd2,
  end_process   = 2'd3;


reg [1:0] state;


always @(posedge ap_clk, posedge reset)
  begin
    if(reset)

      state <= idle;

    else

      case (state)
        idle :
          begin
            if(replace_valid)
              state <= init_process;
            else
              state <= idle;
          end

        init_process :
          begin
            if(m_axi_arready)
              state <= load_process;
            else
              state <= init_process;
          end

        load_process :
          begin
            if(m_axi_rvalid)
              if(m_axi_rresp != 2'b00) //slave_error - received at the same time as valid
                state <= init_process;
            else
              state <= end_process;
            else
              state <= load_process;
          end

        end_process : //delay for the read_latency of the memories (if the rdata is the last word)
          state <= idle;


        default : ;
      endcase
  end


always @*
  begin
    m_axi_arvalid_int = 1'b0;
    m_axi_rready_int  = 1'b0;
    replace           = 1'b1;
    case(state)

      idle :
        begin
          replace = 1'b0;
        end

      init_process :
        begin
          m_axi_arvalid_int = 1'b1;
        end

      load_process :
        begin
          m_axi_rready_int = 1'b1;
        end

      default : ;

    endcase
  end // always @ *

endmodule // read_process_native
