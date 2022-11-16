// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// kernel: glay_kernel
//
// Purpose: This is a C-model of the RTL kernel intended to be used for cpu
//          emulation.  It is designed to only be functionally equivalent to
//          the RTL Kernel.
//-----------------------------------------------------------------------------
#define WORD_SIZE 32
#define SHORT_WORD_SIZE 16
#define CHAR_WORD_SIZE 8
// Transfer size and buffer size are in words.
#define TRANSFER_SIZE_BITS WORD_SIZE*4096*8
#define BUFFER_WORD_SIZE 8192
#include <string.h>
#include <stdbool.h>
#include "hls_half.h"
#include "ap_axi_sdata.h"
#include "hls_stream.h"



// Function declaration/Interface pragmas to match RTL Kernel
extern "C" void glay_kernel (
    int* graph_csr_struct,
    int* vertex_out_degree,
    int* vertex_in_degree,
    int* vertex_edges_idx,
    int* edges_array_weight,
    int* edges_array_src,
    int* edges_array_dest,
    int* auxiliary_1,
    int* auxiliary_2
) {

    #pragma HLS INTERFACE m_axi port=graph_csr_struct offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=vertex_out_degree offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=vertex_in_degree offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=vertex_edges_idx offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=edges_array_weight offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=edges_array_src offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=edges_array_dest offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=auxiliary_1 offset=slave bundle=m00_axi
    #pragma HLS INTERFACE m_axi port=auxiliary_2 offset=slave bundle=m00_axi
    #pragma HLS INTERFACE s_axilite port=graph_csr_struct bundle=control
    #pragma HLS INTERFACE s_axilite port=vertex_out_degree bundle=control
    #pragma HLS INTERFACE s_axilite port=vertex_in_degree bundle=control
    #pragma HLS INTERFACE s_axilite port=vertex_edges_idx bundle=control
    #pragma HLS INTERFACE s_axilite port=edges_array_weight bundle=control
    #pragma HLS INTERFACE s_axilite port=edges_array_src bundle=control
    #pragma HLS INTERFACE s_axilite port=edges_array_dest bundle=control
    #pragma HLS INTERFACE s_axilite port=auxiliary_1 bundle=control
    #pragma HLS INTERFACE s_axilite port=auxiliary_2 bundle=control
    #pragma HLS INTERFACE s_axilite port=return bundle=control
    #pragma HLS INTERFACE ap_ctrl_chain port=return

// Modify contents below to match the function of the RTL Kernel

    // Create input and output buffers for interface m00_axi
    int m00_axi_input_buffer[BUFFER_WORD_SIZE];
    int m00_axi_output_buffer[BUFFER_WORD_SIZE];


    // length is specified in number of words.
    unsigned int m00_axi_length = 4096;


    // Assign input to a buffer
    memcpy(m00_axi_input_buffer, (int*) graph_csr_struct, m00_axi_length*sizeof(int));

    // Add 1 to input buffer and assign to output buffer.
    for (unsigned int i = 0; i < m00_axi_length; i++) {
      m00_axi_output_buffer[i] = m00_axi_input_buffer[i]  + 1;
    }

    // assign output buffer out to memory
    memcpy((int*) graph_csr_struct, m00_axi_output_buffer, m00_axi_length*sizeof(int));


}

