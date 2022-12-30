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
  //Cache-Memory base Offset
  parameter                      CACHE_LINE2MEM_W      = CACHE_WORD_OFF_W-$clog2(CACHE_BACKEND_DATA_W/CACHE_FRONTEND_DATA_W), //burst offset based on the cache word's and memory word size
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
  input      [CACHE_FRONTEND_ADDR_W-1:CACHE_BACKEND_BYTE_W+CACHE_LINE2MEM_W] replace_addr ,
  output reg                                                                 replace      ,
  output                                                                     read_valid   ,
  output reg [                                         CACHE_LINE2MEM_W-1:0] read_addr    ,
  output     [                                     CACHE_BACKEND_DATA_W-1:0] read_rdata   ,
  //AXI master backend interface
  `include "m_axi_m_read_port.vh"
  input                                                                      ap_clk          ,
  input                                                                      reset
);


   reg                                           m_axi_arvalid_int;
   reg                                           m_axi_rready_int;

   assign m_axi_arvalid = m_axi_arvalid_int;
   assign m_axi_rready = m_axi_rready_int;
           
   generate
      if(CACHE_LINE2MEM_W > 0)
        begin
           
           //Constant AXI signals
           assign m_axi_arid    = CACHE_AXI_ID;
           assign m_axi_arlock  = 1'b0;
           assign m_axi_arcache = 4'b0011;
           assign m_axi_arprot  = 3'd0;
           //Burst parameters
           assign m_axi_arlen   = 2**CACHE_LINE2MEM_W -1; //will choose the burst lenght depending on the cache's and slave's data width
           assign m_axi_arsize  = CACHE_BACKEND_BYTE_W; //each word will be the width of the memory for maximum bandwidth
           assign m_axi_arburst = 2'b01; //incremental burst
           assign m_axi_araddr  = {CACHE_BACKEND_ADDR_W{1'b0}} + {replace_addr, {(CACHE_LINE2MEM_W+CACHE_BACKEND_BYTE_W){1'b0}}}; //base address for the burst, with width extension 

           
           // Read Line values
           assign read_rdata = m_axi_rdata;
           assign read_valid = m_axi_rvalid;
           
           
           localparam
             idle          = 2'd0,
             init_process  = 2'd1,
             load_process  = 2'd2,
             end_process   = 2'd3;
           
           
           reg [1:0]                           state;
           reg                                 slave_error;//axi slave_error during reply (m_axi_rresp[1] == 1) - burst can't be interrupted, so a flag needs to be active
           
           
           always @(posedge ap_clk, posedge reset)
             begin
                if(reset)
                  begin
                     state <= idle;
                     read_addr <= 0;
                     slave_error <= 0;
                  end
                else
                  begin
                     slave_error <= slave_error;
                     case (state)   
                       idle:
                         begin
                            slave_error <= 0;
                            read_addr <= 0;  
                            if(replace_valid)
                              state <= init_process;
                            else
                              state <= idle;
                         end

                       init_process:
                         begin
                            slave_error <= 0;
                            read_addr <= 0;  
                            if(m_axi_arready)
                              state <= load_process;
                            else
                              state <= init_process;
                         end

                       load_process:
                         begin
                            if(m_axi_rvalid)
                              if(m_axi_rlast)
                                begin
                                   state <= end_process;
                                   read_addr <= read_addr; //to avoid writting last data in first line word
                                   if(m_axi_rresp != 2'b00) //slave_error - received at the same time as the valid - needs to wait until the end to start all over - going directly to init_process would cause a stall to this burst
                                     slave_error <= 1;
                                end
                              else
                                begin
                                   read_addr <= read_addr +1;
                                   state <= load_process;
                                   if(m_axi_rresp != 2'b00) //slave_error - received at the same time as the valid - needs to wait until the end to start all over - going directly to init_process would cause a stall to this burst
                                     slave_error <= 1;
                                end
                            else
                              begin
                                 read_addr <= read_addr;
                                 state <= load_process;
                              end
                         end

                       //end_process://delay for the read_latency of the memories (if the rdata is the last word)
                                     default:
                                       if (slave_error)
                                         state <= init_process;
                                       else
                                         state <= idle;
                       
                     endcase
                  end
             end

           always @*
             begin
                m_axi_arvalid_int   = 1'b0;
                m_axi_rready_int    = 1'b0;
                replace = 1'b1;
                case(state)

                  idle:
                    replace = 1'b0;
                  
                  init_process:
                    m_axi_arvalid_int = 1'b1;

                  //load_process:
                  default:
                    m_axi_rready_int  = 1'b1;
                  
                endcase
             end // always @ *
        end // if (CACHE_LINE2MEM_W > 0)

      
      else
         
        begin
           //Constant AXI signals
           assign m_axi_arid    = CACHE_AXI_ID;
           assign m_axi_arlock  = 1'b0;
           assign m_axi_arcache = 4'b0011;
           assign m_axi_arprot  = 3'd0;
           //Burst parameters - single 
           assign m_axi_arlen   = 8'd0; //A single burst of Memory data width word
           assign m_axi_arsize  = CACHE_BACKEND_BYTE_W; //each word will be the width of the memory for maximum bandwidth
           assign m_axi_arburst = 2'b00; 
           assign m_axi_araddr  = {CACHE_BACKEND_ADDR_W{1'b0}} + {replace_addr, {CACHE_BACKEND_BYTE_W{1'b0}}}; //base address for the burst, with width extension 

           // Read Line values
           assign read_valid = m_axi_rvalid;
           assign read_rdata  = m_axi_rdata;
           
           
           localparam
             idle          = 2'd0,
             init_process  = 2'd1,
             load_process  = 2'd2,
             end_process   = 2'd3;
           
           
           reg [1:0]                           state;

           
           always @(posedge ap_clk, posedge reset)
             begin
                if(reset)
                   
                  state <= idle;
                
                else
                   
                  case (state)   
                    idle:
                      begin
                         if(replace_valid)
                           state <= init_process;
                         else
                           state <= idle;
                      end

                    init_process:
                      begin                      
                         if(m_axi_arready)
                           state <= load_process;
                         else
                           state <= init_process;
                      end

                    load_process:
                      begin
                         if(m_axi_rvalid)
                           if(m_axi_rresp != 2'b00) //slave_error - received at the same time as valid
                             state <= init_process;
                           else
                             state <= end_process;
                         else
                           state <= load_process;
                      end

                    end_process://delay for the read_latency of the memories (if the rdata is the last word)
                      state <= idle;
                    
                    
                    default:;
                  endcase
             end
           
           
           always @*
             begin
                m_axi_arvalid_int   = 1'b0;
                m_axi_rready_int    = 1'b0;
                replace = 1'b1;
                case(state)

                  idle:
                    begin
                       replace = 1'b0;
                    end
                  
                  init_process:
                    begin
                       m_axi_arvalid_int = 1'b1;
                    end

                  load_process:
                    begin
                       m_axi_rready_int  = 1'b1;             
                    end
                  
                  default:;
                  
                endcase
             end // always @ *
           
        end     
   endgenerate 
   
endmodule // read_process_native
