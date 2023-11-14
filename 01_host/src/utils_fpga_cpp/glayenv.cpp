// -----------------------------------------------------------------------------
//
//      "GLAY"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@ncsu.edu||atmughrabi@gmail.com
// File   : glayenv.c
// Create : 2019-10-09 19:20:39
// Revise : 2019-12-01 00:12:59
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

#include <iostream>
#include <fstream>
#include <string>
#include <unistd.h>
#include <iomanip>
#include <cstdlib>
#include <time.h>
#include <string.h>
#include <thread>
#include "glayenv.hpp"
#include "myMalloc.h"

// ********************************************************************************************
// ***************                  XRT General                                  **************
// ********************************************************************************************

struct xrtGLAYHandle *setupGLAYDevice(struct xrtGLAYHandle *glayHandle, int deviceIndex, char *xclbinPath, char *overlayPath, char *kernelName, int ctrlMode, bool endian, int entries)
{
    glayHandle = (struct xrtGLAYHandle *) my_malloc(sizeof(struct xrtGLAYHandle));
    glayHandle->deviceIndex = deviceIndex;
    glayHandle->xclbinPath  = xclbinPath;
    glayHandle->kernelName  = kernelName;
    glayHandle->ctrlMode    = ctrlMode;
    glayHandle->overlayPath = overlayPath;
    glayHandle->entries     = entries;
    glayHandle->endian      = endian;

    glayHandle->deviceHandle = xrt::device(glayHandle->deviceIndex);

    glayHandle->xclbinUUID = glayHandle->deviceHandle.load_xclbin(glayHandle->xclbinPath);

    glayHandle->xclbinHandle  = xrt::xclbin(glayHandle->xclbinPath);

    switch (glayHandle->ctrlMode)
    {
    case 0:
        glayHandle->ipHandle = xrt::ip(glayHandle->deviceHandle, glayHandle->xclbinUUID, glayHandle->kernelName);
        break;
    case 1:
    case 2:
        glayHandle->kernelHandle = xrt::kernel(glayHandle->deviceHandle, glayHandle->xclbinUUID, glayHandle->kernelName);
        break;
    default:
        glayHandle->ipHandle = xrt::ip(glayHandle->deviceHandle, glayHandle->xclbinUUID, glayHandle->kernelName);
    }

    for (auto &kernel : glayHandle->xclbinHandle.get_kernels())
    {
        if (kernel.get_name() == glayHandle->kernelName)
        {
            glayHandle->cuHandles = kernel.get_cus();
        }
    }

    if (glayHandle->cuHandles.empty()) throw std::runtime_error(std::string("IP ") + glayHandle->kernelName + std::string(" not found in the provided xclbin"));

    printGLAYDevice(glayHandle);

    return glayHandle;
}

void printGLAYDevice(struct xrtGLAYHandle *glayHandle)
{
    printf("\n-----------------------------------------------------\n");

    printf("DEVICE::NAME                    [%s] \n", glayHandle->deviceHandle.get_info<xrt::info::device::name>().c_str() );
    printf("DEVICE::BDF                     [%s] \n", glayHandle->deviceHandle.get_info<xrt::info::device::bdf>().c_str() );
    printf("DEVICE::MAX_CLOCK_FREQUENCY_MHZ [%ld] \n", glayHandle->deviceHandle.get_info<xrt::info::device::max_clock_frequency_mhz>() );
    printf("-----------------------------------------------------\n");
    printf(" \nKernel Arguments Offsets: HANDLE[%2u] \n", 0);

    uint32_t i = 0;
    for (auto it : glayHandle->cuHandles[0].get_args())
    {
        printf("ARG[%u]-[0x%03lX]\n", i, it.get_offset());
        i++;
    }
    printf("-----------------------------------------------------\n");
}

// ********************************************************************************************
// ***************                  GLAY General                                 **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank::GLAYGraphCSRxrtBufferHandlePerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary, int bankGroupIndex)
{
    overlay_program_entries  = glayHandle->entries;// (each engine can take 64bytes configuration 8 engines per 4 bundles) // 32 Cachelines
    endian = glayHandle->endian;
    xrt_buffer_size[0] = overlay_program_entries;
    xrt_buffer_size[1] = graph->num_vertices * sizeof(uint32_t);
    xrt_buffer_size[2] = graph->num_vertices * sizeof(uint32_t);
    xrt_buffer_size[3] = graph->num_vertices * sizeof(uint32_t);
    xrt_buffer_size[4] = graph->num_edges * sizeof(uint32_t);
    xrt_buffer_size[5] = graph->num_edges * sizeof(uint32_t);
    xrt_buffer_size[6] = graph->num_edges * sizeof(uint32_t);
    xrt_buffer_size[7] = graphAuxiliary->num_auxiliary_1 * sizeof(uint32_t);
    xrt_buffer_size[8] = graphAuxiliary->num_auxiliary_2 * sizeof(uint32_t);
    xrt_buffer_size[9] = 8;

    // ********************************************************************************************
    // ***************                  Allocate Device buffers                      **************
    // ********************************************************************************************
    xrt_buffer[0]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[0], xrt::bo::flags::normal, bankGroupIndex);// graph overlay_program program
    xrt_buffer[1]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[1], xrt::bo::flags::normal, bankGroupIndex);// V | vertex in degree
    xrt_buffer[2]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[2], xrt::bo::flags::normal, bankGroupIndex);// V | vertex out degree
    xrt_buffer[3]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[3], xrt::bo::flags::normal, bankGroupIndex);// V | vertex edges CSR index
    xrt_buffer[4]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[4], xrt::bo::flags::normal, bankGroupIndex);// E | edges array src
    xrt_buffer[5]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[5], xrt::bo::flags::normal, bankGroupIndex);// E | edges array dest
    xrt_buffer[6]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[6], xrt::bo::flags::normal, bankGroupIndex);// E | edges array weight
    xrt_buffer[7]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[7], xrt::bo::flags::normal, bankGroupIndex);// auxiliary 1
    xrt_buffer[8]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[8], xrt::bo::flags::normal, bankGroupIndex);// auxiliary 2
    xrt_buffer[9]   =  xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[9], xrt::bo::flags::normal, bankGroupIndex);// auxiliary 3

    // ********************************************************************************************
    // ***************                  Setup Device pointers                        **************
    // ********************************************************************************************
    xrt_buffer_device[0] = xrt_buffer[0].address();
    xrt_buffer_device[1] = xrt_buffer[1].address();
    xrt_buffer_device[2] = xrt_buffer[2].address();
    xrt_buffer_device[3] = xrt_buffer[3].address();
    xrt_buffer_device[4] = xrt_buffer[4].address();
    xrt_buffer_device[5] = xrt_buffer[5].address();
    xrt_buffer_device[6] = xrt_buffer[6].address();
    xrt_buffer_device[7] = xrt_buffer[7].address();
    xrt_buffer_device[8] = xrt_buffer[8].address(); // Each read is 4-Bytes granularity (256 cycles to configure) | / endian mode 0-big endian 1-little endian
    xrt_buffer_device[9] = (overlay_program_entries << 1) | endian; // Each read is 4-Bytes granularity (256 cycles to configure) | / endian mode 0-big endian 1-little endian

    // ********************************************************************************************
    // ***************                  Setup Host pointers                          **************
    // ********************************************************************************************
    initializeGLAYOverlayConfiguration(overlay_program_entries, 1, graph, glayHandle->overlayPath);
    xrt_buffer_host[0] = overlay_program;
    xrt_buffer_host[1] = graph->vertices->in_degree;
    xrt_buffer_host[2] = graph->vertices->out_degree;
    xrt_buffer_host[3] = graph->vertices->edges_idx;
    xrt_buffer_host[4] = graph->sorted_edges_array->edges_array_src;
    xrt_buffer_host[5] = graph->sorted_edges_array->edges_array_dest;
    xrt_buffer_host[6] = graph->sorted_edges_array->edges_array_weight;
    xrt_buffer_host[7] = graphAuxiliary->auxiliary_1; // endian mode 0-big endian 1-little endian
    xrt_buffer_host[8] = graphAuxiliary->auxiliary_2; // sizeof(uint32_t); // not passing an address but number of cachelines to read from graph_csr_struct
    xrt_buffer_host[9] = &xrt_buffer_device[9];

}

int GLAYGraphCSRxrtBufferHandlePerBank::writeGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{
    xrt_buffer[0].write(xrt_buffer_host[0], xrt_buffer_size[0], 0);
    xrt_buffer[1].write(xrt_buffer_host[1], xrt_buffer_size[1], 0);
    xrt_buffer[2].write(xrt_buffer_host[2], xrt_buffer_size[2], 0);
    xrt_buffer[3].write(xrt_buffer_host[3], xrt_buffer_size[3], 0);
    xrt_buffer[4].write(xrt_buffer_host[4], xrt_buffer_size[4], 0);
    xrt_buffer[5].write(xrt_buffer_host[5], xrt_buffer_size[5], 0);
    xrt_buffer[6].write(xrt_buffer_host[6], xrt_buffer_size[6], 0);
    xrt_buffer[7].write(xrt_buffer_host[7], xrt_buffer_size[7], 0);
    xrt_buffer[8].write(xrt_buffer_host[8], xrt_buffer_size[8], 0);
    xrt_buffer[9].write(xrt_buffer_host[9], xrt_buffer_size[9], 0);

    xrt_buffer[0].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[0], 0);
    xrt_buffer[1].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[1], 0);
    xrt_buffer[2].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[2], 0);
    xrt_buffer[3].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[3], 0);
    xrt_buffer[4].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[4], 0);
    xrt_buffer[5].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[5], 0);
    xrt_buffer[6].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[6], 0);
    xrt_buffer[7].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[7], 0);
    xrt_buffer[8].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[8], 0);
    xrt_buffer[9].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[9], 0);

    return 0;
}

int GLAYGraphCSRxrtBufferHandlePerBank::writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->ipHandle.write_register(ADDR_BUFFER_0_DATA_0, xrt_buffer_device[0]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_0_DATA_0 + 4), xrt_buffer_device[0] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_1_DATA_0, xrt_buffer_device[1]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_1_DATA_0 + 4), xrt_buffer_device[1] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_2_DATA_0, xrt_buffer_device[2]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_2_DATA_0 + 4), xrt_buffer_device[2] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_3_DATA_0, xrt_buffer_device[3]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_3_DATA_0 + 4), xrt_buffer_device[3] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_4_DATA_0, xrt_buffer_device[4]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_4_DATA_0 + 4), xrt_buffer_device[4] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_5_DATA_0, xrt_buffer_device[5]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_5_DATA_0 + 4), xrt_buffer_device[5] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_6_DATA_0, xrt_buffer_device[6]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_6_DATA_0 + 4), xrt_buffer_device[6] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_7_DATA_0, xrt_buffer_device[7]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_7_DATA_0 + 4), xrt_buffer_device[7] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_8_DATA_0, xrt_buffer_device[8]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_8_DATA_0 + 4), xrt_buffer_device[8] >> 32);

    glayHandle->ipHandle.write_register(ADDR_BUFFER_9_DATA_0, xrt_buffer_device[9]);
    glayHandle->ipHandle.write_register((ADDR_BUFFER_9_DATA_0 + 4), xrt_buffer_device[9] >> 32);

    return 0;
}

int GLAYGraphCSRxrtBufferHandlePerBank::setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(struct xrtGLAYHandle *glayHandle, GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
{
    glayHandle->runKernelHandle = xrt::run(glayHandle->kernelHandle);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_0_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[0]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_1_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[1]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_2_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[2]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_3_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[3]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_4_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[4]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_5_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[5]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_6_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[6]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_7_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[7]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_8_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[8]);
    glayHandle->runKernelHandle.set_arg(ADDR_BUFFER_9_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[9]);

    return 0;
}

void GLAYGraphCSRxrtBufferHandlePerBank::initializeGLAYOverlayConfiguration(size_t overlay_program_entries, int algorithm, struct GraphCSR *graph, char *overlayPath)
{
    std::ifstream file(overlayPath);
    if (!file.is_open())
    {
        std::cerr << "Failed to open file." << std::endl;
        return;
    }

    std::string line;
    std::vector<uint32_t> values;

    while (std::getline(file, line))
    {
        size_t comment_pos = line.find("\\");
        if (comment_pos != std::string::npos)
        {
            line = line.substr(0, comment_pos);
        }

        uint32_t value;
        if (sscanf(line.c_str(), "0x%8x", &value) == 1)
        {
            values.push_back(value);
        }
    }

    overlay_program_entries = values.size() * sizeof(uint32_t);
    overlay_program = (uint32_t *)aligned_alloc(4096, overlay_program_entries); // Assuming 4096-byte alignment

    if (!overlay_program)
    {
        std::cerr << "Memory alignment error." << std::endl;
        return;
    }

    for (size_t i = 0; i < values.size(); i++)
    {
        overlay_program[i] = values[i];
    }

    // overlay_program[2]  = graph->num_vertices       ;//  2  - Index_end
    // overlay_program[8]  = xrt_buffer_device[2]      ;//  8  - BUFFER Array Pointer LHS
    // overlay_program[9]  = xrt_buffer_device[2] >> 32;//  9  - BUFFER Array Pointer RHS
    // overlay_program[10] = graph->num_vertices       ;//  10 - BUFFER size
    switch (algorithm)
    {
    case 0: // bfs
    {
        mapGLAYOverlayProgramBuffersBFS(overlay_program_entries, algorithm, graph, overlayPath);
    }
    break;
    case 1: // pagerank
    {
        mapGLAYOverlayProgramBuffersPR(overlay_program_entries, algorithm, graph, overlayPath);
    }
    break;
    case 2: // SSSP-Delta
    {

    }
    break;
    case 3: // SSSP-Bellmanford
    {

    }
    break;
    case 4: // DFS
    {

    }
    break;
    case 5: //SPMV
    {

    }
    break;
    case 6: // Connected Components
    {

    }
    break;
    case 7: // Betweenness Centrality
    {

    }
    break;
    case 8: // Triangle Counting
    {
        mapGLAYOverlayProgramBuffersTC(overlay_program_entries, algorithm, graph, overlayPath);
    }
    break;
    case 9: // clustering
    {

    }
    break;
    default:// BFS
    {
        mapGLAYOverlayProgramBuffersBFS(overlay_program_entries, algorithm, graph, overlayPath);
    }
    break;
    }

}

void GLAYGraphCSRxrtBufferHandlePerBank::printGLAYGraphCSRxrtBufferHandlePerBank()
{
    uint32_t engine_id = 0;
    uint32_t bundle_id = 0;

    for (uint32_t i = 0; i < 10; ++i)
    {
        printf("XRT-BUFFER-ID %-4u : HOST[%16p] DEVICE[0x%016lX] SIZE-BYTES[%lu]\n", i, xrt_buffer_host[i], xrt_buffer_device[i], xrt_buffer_size[i]);
    }

    printf("\nOVERLAY CONFIGURATION ... \n ");

    for (uint32_t j = 0; j < 4; j++)
    {
        bundle_id = j;
        printf(" \nBUNDLE-ID [%-2u] \n", bundle_id);
        for (uint32_t i = 0; i < 8; i++)
        {
            engine_id = i;
            printf("ENGINE-ID [%-2u] \n", engine_id);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (0)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (1)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (2)]);
            printf("[0x%08X]\n", overlay_program[(j * (16 * 8)) + (i * 16) + (3)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (4)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (5)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (6)]);
            printf("[0x%08X]\n", overlay_program[(j * (16 * 8)) + (i * 16) + (7)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (8)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (9)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (10)]);
            printf("[0x%08X]\n", overlay_program[(j * (16 * 8)) + (i * 16) + (11)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (12)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (13)]);
            printf("[0x%08X]  ", overlay_program[(j * (16 * 8)) + (i * 16) + (14)]);
            printf("[0x%08X]\n", overlay_program[(j * (16 * 8)) + (i * 16) + (15)]);
        }
    }
}

// ********************************************************************************************
// ***************                  GLAY Control                                 **************
// ********************************************************************************************

void freeGlayHandle ( struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    if(glayHandle)
        free(glayHandle);
}

void releaseGLAY(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}


// ********************************************************************************************
// ***************                  GLAY Control USER_MANAGED                    **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRUserManaged(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary, int bankGroupIndex)
{
    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = new GLAYGraphCSRxrtBufferHandlePerBank(glayHandle, graph, graphAuxiliary, bankGroupIndex);
    glayGraphCSRxrtBufferHandlePerBank->writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraphCSRxrtBufferHandlePerBank);
    glayGraphCSRxrtBufferHandlePerBank->writeRegistersAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle);

    return glayGraphCSRxrtBufferHandlePerBank;
}

void startGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    uint32_t glay_control_write = 0;
    uint32_t glay_control_read  = 0;
    glay_control_write = CONTROL_START;

    glayHandle->ipHandle.write_register(CONTROL_OFFSET, glay_control_write);

    do
    {
        glay_control_read = glayHandle->ipHandle.read_register(CONTROL_OFFSET);
        printf("MSG: START-[0x%08X] \n", glay_control_read);
    }
    while(!(glay_control_read & CONTROL_READY));

    printf("MSG: WAIT-[0x%08X] \n", glay_control_read);
}

void waitGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    uint32_t glay_control_read = 0;

    do
    {
        glay_control_read = glayHandle->ipHandle.read_register(CONTROL_OFFSET);
        // printf("MSG: WAIT-[0x%08X] \n", glay_control_read);
    }
    while(!(glay_control_read & CONTROL_IDLE));

    printf("MSG: WAIT-[0x%08X] \n", glay_control_read);
}

void releaseGLAYUserManaged(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}


// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_HS                      **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRCtrlHs(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary, int bankGroupIndex)
{
    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = new GLAYGraphCSRxrtBufferHandlePerBank(glayHandle, graph, graphAuxiliary, bankGroupIndex);
    glayGraphCSRxrtBufferHandlePerBank->writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraphCSRxrtBufferHandlePerBank);
    glayGraphCSRxrtBufferHandlePerBank->setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, glayGraphCSRxrtBufferHandlePerBank);

    return glayGraphCSRxrtBufferHandlePerBank;
}

void startGLAYCtrlHs(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->runKernelHandle.start();
}

void waitGLAYCtrlHs(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->runKernelHandle.wait();
}

void releaseGLAYCtrlHs(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}


// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_CHAIN                   **************
// ********************************************************************************************

GLAYGraphCSRxrtBufferHandlePerBank *setupGLAYGraphCSRCtrlChain(struct xrtGLAYHandle *glayHandle, struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary, int bankGroupIndex)
{
    GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank = new GLAYGraphCSRxrtBufferHandlePerBank(glayHandle, graph, graphAuxiliary, bankGroupIndex);
    glayGraphCSRxrtBufferHandlePerBank->writeGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, graph, glayGraphCSRxrtBufferHandlePerBank);
    glayGraphCSRxrtBufferHandlePerBank->setArgsKernelAddressGLAYGraphCSRHostToDeviceBuffersPerBank(glayHandle, glayGraphCSRxrtBufferHandlePerBank);

    return glayGraphCSRxrtBufferHandlePerBank;
}

void startGLAYCtrlChain(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->runKernelHandle.start();
}

void waitGLAYCtrlChain(struct xrtGLAYHandle *glayHandle)
{
    glayHandle->runKernelHandle.wait();
}

void releaseGLAYCtrlChain(struct xrtGLAYHandle *glayHandle)
{
    //Close an opened device
    // xrtKernelClose(glayHandle->kernelHandle);
    // xrtDeviceClose(glayHandle->deviceHandle);
    freeGlayHandle(glayHandle);
}


// ********************************************************************************************
// ***************                  GLAY Control multithreaded                   **************
// ********************************************************************************************

// // kernel running thread
// void executeGLayThread(xrt::run runGLayKernel, GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
// {
//     runGLayKernel.set_arg(ADDR_BUFFER_0_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[0]);
//     runGLayKernel.set_arg(ADDR_BUFFER_1_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[1]);
//     runGLayKernel.set_arg(ADDR_BUFFER_2_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[2]);
//     runGLayKernel.set_arg(ADDR_BUFFER_3_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[3]);
//     runGLayKernel.set_arg(ADDR_BUFFER_4_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[4]);
//     runGLayKernel.set_arg(ADDR_BUFFER_5_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[5]);
//     runGLayKernel.set_arg(ADDR_BUFFER_6_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[6]);
//     runGLayKernel.set_arg(ADDR_BUFFER_7_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[7]);
//     runGLayKernel.set_arg(ADDR_BUFFER_8_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[8]);
//     runGLayKernel.set_arg(ADDR_BUFFER_9_ID, glayGraphCSRxrtBufferHandlePerBank->xrt_buffer[9]);
//     runGLayKernel.start();
//     runGLayKernel.wait();
// }


// void executeGLayMultiThreaded(struct xrtGLAYHandle *glayHandle, GLAYGraphCSRxrtBufferHandlePerBank *glayGraphCSRxrtBufferHandlePerBank)
// {
//     std::vector<xrt::run> runGLayKernels;
//     std::vector<std::thread> t(thread_num);

//     for (int i = 0; i < thread_num; i++)
//     {
//         runGLayKernels.push_back(xrt::run(glayHandle->kernelHandle));
//     }

//     int residue = groups_num % thread_num;
//     int i, k;
//     for (k = 0; k < groups_num / thread_num; k++)
//     {
//         for (i = 0; i < thread_num; i++)
//         {
//             t[i] = std::thread(executeGLayThread, runGLayKernels[i], glayGraphCSRxrtBufferHandlePerBank);
//         }
//         for (i = 0; i < thread_num; i++)
//         {
//             t[i].join();
//         }
//     }
//     for (i = 0; i < residue; i++)
//     {
//         //runGLayKernels[i].set_arg(krnl_cbc_arg_SRC_ADDR, input_sub_buffer[k * thread_num + i]);   // use sub-buffer for source pointer argument
//         //runGLayKernels[i].set_arg(krnl_cbc_arg_DEST_ADDR, output_sub_buffer[k * thread_num + i]); // use sub-buffer for source pointer argument
//         t[i] = std::thread(executeGLayThread, runGLayKernels[i], glayGraphCSRxrtBufferHandlePerBank);
//     }
//     for (i = 0; i < residue; i++)
//     {
//         t[i].join();
//     }

// }