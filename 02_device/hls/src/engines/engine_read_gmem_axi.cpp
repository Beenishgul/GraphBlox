/*
* @Author: Abdullah
* @Date:   2023-06-22 21:58:56
* @Last Modified by:   Abdullah
* @Last Modified time: 2023-06-22 21:58:56
*/
#include <hls_stream.h>
#include <ap_axi_sdata.h>
#define BUFFER_SIZE 1024
typedef ap_axiu<32,1,1,1> stream_type;

void readFromGlobalMemory(int* input, hls::stream<stream_type>& fifo, int size) {
    stream_type data;
    for(int i = 0; i < size; i++) {
        #pragma HLS PIPELINE II=1
        data.data = input[i];
        data.dest = 0;
        data.id = 0;
        data.keep = 1;
        data.last = (i == (size - 1)) ? 1 : 0;
        data.strb = 0;
        data.user = 0;
        fifo.write(data);
    }
}

void writeToGlobalMemory(hls::stream<stream_type>& fifo, int* output, int size) {
    for(int i = 0; i < size; i++) {
        #pragma HLS PIPELINE II=1
        stream_type data = fifo.read();
        output[i] = data.data;
    }
}

extern "C" {
    void memcopy(int* input, int* output, int size) {
        #pragma HLS INTERFACE m_axi port=input depth=BUFFER_SIZE offset=slave bundle=gmem0
        #pragma HLS INTERFACE m_axi port=output depth=BUFFER_SIZE offset=slave bundle=gmem1
        #pragma HLS INTERFACE s_axilite port=size
        #pragma HLS INTERFACE s_axilite port=return

        hls::stream<stream_type> fifo;
        #pragma HLS STREAM variable=fifo depth=BUFFER_SIZE

        readFromGlobalMemory(input, fifo, size);
        writeToGlobalMemory(fifo, output, size);
    }
}
