`timescale 1ns / 1ps

module temp_wrap #(
  parameter CHWIDTH = 10,
  parameter COLWIDTH = 7,  //11, // 9, for 2048 X 64 mem
  parameter DEVICE_WIDTH = 16,
  parameter log_DEVICE_WIDTH = 4,
  //column finder
  parameter SEG_SIZE =  256,
  parameter log_SEG_SIZE = 8,
  parameter PG_NUM = ((2**COLWIDTH)*DEVICE_WIDTH)/((SEG_SIZE*2)+64), // 64 is size of query batch
  parameter SEG_NUM  = PG_NUM*2
) (
    input logic [COLWIDTH+log_DEVICE_WIDTH-1:0] query_col,
    input logic [CHWIDTH-1:0] row_address,
    input logic clk,
    input logic rsn,
    output logic [DEVICE_WIDTH-1:0] dina,
    //making match_col an outport
    output logic [COLWIDTH+log_DEVICE_WIDTH-1:0] match_col,   // matched column index
    output logic ETM,  //ETM = 1 to terminate, ETM = 0 (CONTINUE)
    input logic [DEVICE_WIDTH-1:0] douta,
    input logic [2**COLWIDTH*DEVICE_WIDTH-1:0] doutb
    );

// reg [DEVICE_WIDTH*2**COLWIDTH-1:0] match_row;
// match_row = 512*3 = 1536
reg [(SEG_SIZE*SEG_NUM)-1:0] match_row;
 //column finder
 reg [SEG_NUM-1:0] SR;  //array of segment registers for all the segments (needed for ETM)
 reg [SEG_NUM-1:0] BSR; //array of backup segment registers for all the segments ( needed for CF) 
 reg [SEG_SIZE-1:0] RS; //reserved segment
 reg [COLWIDTH+log_DEVICE_WIDTH-1:0] RS_idx; // reserved segment index to compute final column number
 
genvar k, m;
generate

           for(k=0; k<PG_NUM; k=k+1)
           begin
                for(m=0; m<=255; m=m+1)
                begin 
                matcher_1bit M0 (.rsn(rsn),
                                 .reference(doutb[(DEVICE_WIDTH*2**COLWIDTH-1)-256*(2*k)-(64*k)-m]),
                                 .query(doutb[(DEVICE_WIDTH*2**COLWIDTH-1)-256*((2*k)+1)-(64*k)-query_col]),
                                 .match(match_row[((SEG_SIZE*SEG_NUM-1)-2*k*SEG_SIZE)-m]),
                                 .match_en(1'b1)
                                 );
                matcher_1bit M1 (.rsn(rsn),
                                 .reference(doutb[(DEVICE_WIDTH*2**COLWIDTH-1)-256*((2*k)+1)-64*(k+1)-m]),
                                 .query(doutb[(DEVICE_WIDTH*2**COLWIDTH-1)-256*((2*k)+1)-(64*k)-query_col]),
                                 .match(match_row[((SEG_SIZE*SEG_NUM-1)-(2*k+1)*SEG_SIZE)-m]),
                                 .match_en(1'b1)
                                 );                 
                                 
                end
                                 
           end
    assign BSR = SR;       
endgenerate  

genvar i;
generate
    for(i =0; i<SEG_NUM; i=i+1)
    begin
        segment Si (.latch(match_row[(i+1)*SEG_SIZE-1:i*SEG_SIZE]),
                    .latch_OR(SR[i]),
                    .clk(clk),
                    .rsn(rsn)
                    );
    end                    
endgenerate    


always@(posedge clk) begin
    if(rsn == 1'b0) 
            begin
            RS <= {SEG_SIZE{1'b0}};
            RS_idx <= {(COLWIDTH+log_DEVICE_WIDTH){1'b0}};  //to be able to shift for the max column 
            match_col <= {(COLWIDTH+log_DEVICE_WIDTH){1'b1}};
            ETM <= 1'b0;
            end
    else begin
            if((|SR) == 0) begin
            ETM <= 1'b1;
            end
            //if(ETM == 1)  begin  //Temporary till I design Sieve_reset
            //match_row <= {(SEG_SIZE*SEG_NUM){1'b1}};
            //end
        for(int i=0; i< SEG_NUM; i=i+1) begin
           //if(row_address == (2**CHWIDTH -1)) begin  // started with 64 -> 0
           if(row_address == 0 && ETM == 0) begin  // can be ORed with ETM --KK
               if( BSR[i] == 1'b1) begin  //corresponds to the mux in fig 8  //changed SR to BSR
               RS <= match_row[((i+1)*SEG_SIZE)-1 -: (SEG_SIZE)]; // for decreasing order of indexing
               RS_idx <= i;
               end
           end
        end
        for(int j=0; j<SEG_SIZE; j++) begin     // tried to make it combinational to keep in the same pipeline stage (think of better way if possible) KK       
            if(RS[0] == 1'b1)
                match_col = (RS_idx << log_SEG_SIZE ) + j; 
            RS = RS >> 1;    
        end
    end
end

//always @* begin
//    for(int j=0; j<SEG_SIZE; j++) begin     // tried to make it combinational to keep in the same pipeline stage (think of better way if possible) KK       
//       if(RS[0] == 1'b1)
//            match_col = (RS_idx << log_SEG_SIZE ) + j; 
//       RS = RS >> 1;    
//   end
//end



//writing the match_col to memory (match_col = 11'h7FF, no match) 
assign dina =  16'ha5a5; //match_col;
//assign addra = 

endmodule
