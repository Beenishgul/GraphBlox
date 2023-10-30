import PKG_AXI4::*;
import PKG_GLOBALS::*;
import PKG_DESCRIPTOR::*;
import PKG_CONTROL::*;
import PKG_MEMORY::*;
import PKG_ENGINE::*;
import PKG_SETUP::*;
import PKG_CACHE::*;

module bundle_lanes_topology #(
    parameter NUM_STAGES = 1,
    `include "bundle_parameters.vh"
) (
    // Clock and Reset
    input  logic                  ap_clk                                                                                                       ,
    input  logic                  areset                                                                                                       ,
    // Output Ports
    output MemoryPacket           lanes_response_merge_engine_in               [NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:1],
    output FIFOStateSignalsInput  lanes_fifo_response_merge_lane_in_signals_in [NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:1],
    input  FIFOStateSignalsOutput lanes_fifo_response_merge_lane_in_signals_out[NUM_LANES-1:0][(1+LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:1],
    // Input Ports
    input  MemoryPacket           lanes_request_cast_lane_out                  [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:1],
    output FIFOStateSignalsInput  lanes_fifo_request_cast_lane_out_signals_in  [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:1],
    input  FIFOStateSignalsOutput lanes_fifo_request_cast_lane_out_signals_out [NUM_LANES-1:0][ (1+LANES_CONFIG_LANE_MAX_CAST_WIDTH_ARRAY)-1:1]
);

    // Logic for stage 0
    int lane_merge, lane_cast, engine_idx, cast_idx, merge_count = 0;
    integer cast_count[NUM_LANES] = '{default: 0};

    // Logic pipeline stages
    typedef struct {
        MemoryPacket          response    ;
        FIFOStateSignalsInput fifo_in     ;
        FIFOStateSignalsInput fifo_in_cast;
    } PipelineStage;

    PipelineStage stage[NUM_LANES-1:0][(LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY)-1:0][NUM_STAGES];

    always_ff @(posedge ap_clk) begin
        if (areset) begin
            // Reset logic
            for (int i = 0; i < NUM_LANES; i++) begin
                for (int j = 0; j < LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY; j++) begin
                    for (int s = 0; s < NUM_STAGES; s++) begin
                        stage[i][j][s].response     <= 0;
                        stage[i][j][s].fifo_in      <= 0;
                        stage[i][j][s].fifo_in_cast <= 0;
                    end
                end
            end
        end else begin
            // Pipelined logic
            for (int i = 0; i < NUM_LANES; i++) begin
                for (int j = 0; j < LANES_CONFIG_LANE_MAX_MERGE_WIDTH_ARRAY; j++) begin
                    for (int s = NUM_STAGES - 1; s > 0; s = s - 1) begin
                        stage[i][j][s] <= stage[i][j][s - 1];
                    end
                    lanes_response_merge_engine_in[i][j]               <= stage[i][j][NUM_STAGES-1].response;
                    lanes_fifo_response_merge_lane_in_signals_in[i][j] <= stage[i][j][NUM_STAGES-1].fifo_in;
                    lanes_fifo_request_cast_lane_out_signals_in[i][j]  <= stage[i][j][NUM_STAGES-1].fifo_in_cast;
                end
            end

            for (lane_merge=0; lane_merge< NUM_LANES; lane_merge++) begin
                if (LANES_CONFIG_LANE_MERGE_WIDTH_ARRAY[lane_merge] != 0) begin
                    merge_count = 0;
                    for (lane_cast = 0; lane_cast < NUM_LANES; lane_cast++) begin
                        if (LANES_CONFIG_LANE_CAST_WIDTH_ARRAY[lane_cast] != 0 && lane_cast != lane_merge) begin
                            for (engine_idx = 0; engine_idx < ENGINES_COUNT_ARRAY[lane_cast]; engine_idx++) begin
                                for (cast_idx = 0; cast_idx < LANES_CONFIG_CAST_WIDTH_ARRAY[lane_cast][engine_idx]; cast_idx++) begin
                                    if (LANES_CONFIG_MERGE_CONNECT_ARRAY[lane_cast][engine_idx][cast_idx] == lane_merge) begin
                                        merge_count           = merge_count + 1;
                                        cast_count[lane_cast] = cast_count[lane_cast] + 1;
                                        stage[lane_merge][merge_count][0].response           <= lanes_request_cast_lane_out[lane_cast][cast_count[lane_cast]];
                                        stage[lane_merge][merge_count][0].fifo_in.rd_en      <= ~lanes_fifo_request_cast_lane_out_signals_out[lane_cast][cast_count[lane_cast]].empty;
                                        stage[lane_merge][merge_count][0].fifo_in_cast.rd_en <= ~lanes_fifo_response_merge_lane_in_signals_out[lane_merge][merge_count].prog_full;
                                    end else begin
                                        stage[lane_merge][merge_count][0].response           <= 0;
                                        stage[lane_merge][merge_count][0].fifo_in.rd_en      <= 0;
                                        stage[lane_merge][merge_count][0].fifo_in_cast.rd_en <= 0;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

endmodule : bundle_lanes_topology