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

#include "glayenv.hpp"
#include "myMalloc.h"
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <string>
#include <thread>
#include <time.h>
#include <unistd.h>

// ********************************************************************************************
// ***************                  GLAY Handle **************
// ********************************************************************************************

xrtGLAYHandle::xrtGLAYHandle(struct Arguments *arguments) {
  deviceIndex = arguments->device_index;
  xclbinPath = arguments->xclbin_path;
  kernelName = arguments->kernel_name;
  ctrlMode = arguments->ctrl_mode;
  overlayPath = arguments->overlay_path;
  endian_read = arguments->endian_read;
  endian_write = arguments->endian_write;
  flush_enable = arguments->flush_cache;
  cacheSize = arguments->cache_size;
  numThreads = arguments->ker_numThreads;
  overlay_algorithm = arguments->algorithm;
  cu_id = arguments->cu_id;
  overlay_program_entries = 0; // Will be set in readGLAYDeviceEntriesFromFile
  kernelNameFull =
      kernelName + ":{" + kernelName + "_" + std::to_string(cu_id + 1) + "}";

  setupGLAYDevice();
}

void xrtGLAYHandle::setupGLAYDevice() {
  // Perform the setup as in the original setupGLAYDevice function
  // This includes reading entries from file, initializing xrt devices, etc.
  readGLAYDeviceEntriesFromFile(); // Reads entries into overlay_program and
  // sets overlay_program_entries

  // Initialize xrt::device, load xclbin, etc.
  // Example:
  deviceHandle = xrt::device(deviceIndex);
  xclbinUUID = deviceHandle.load_xclbin(xclbinPath);
  xclbinHandle = xrt::xclbin(xclbinPath);

  for (auto &kernel : xclbinHandle.get_kernels()) {
    if (kernel.get_name() == kernelName) {
      cuHandles = kernel.get_cus();
    }
  }

  if (cuHandles.empty())
    throw std::runtime_error(std::string("IP ") + kernelName +
                             std::string(" not found in the provided xclbin"));

  for (auto &mem : xclbinHandle.get_mems()) {
    if (mem.get_used()) {
      mem_used = mem;
      break;
    }
  }

  switch (ctrlMode) {
  case 0:
    ipHandle = xrt::ip(deviceHandle, xclbinUUID, kernelNameFull.c_str());
    break;
  case 1:
  case 2:
    kernelHandle =
        xrt::kernel(deviceHandle, xclbinUUID, kernelNameFull.c_str(), xrt::kernel::cu_access_mode::shared);
    break;
  default:
    ipHandle = xrt::ip(deviceHandle, xclbinUUID, kernelNameFull.c_str());
    break;
  }
}

void xrtGLAYHandle::readGLAYDeviceEntriesFromFile() {
  std::ifstream file(overlayPath);
  if (!file.is_open()) {
    throw std::runtime_error("Failed to open overlay file.");
  }

  std::string line;
  while (std::getline(file, line)) {
    size_t comment_pos = line.find("//"); // Assuming comments start with //
    if (comment_pos != std::string::npos) {
      line = line.substr(0, comment_pos);
    }

    uint32_t value;
    if (sscanf(line.c_str(), "0x%8x", &value) == 1) {
      overlay_program.push_back(value);
    }
  }

  overlay_program_entries = overlay_program.size();
}

void xrtGLAYHandle::printGLAYDevice() const {
  printf("\n-----------------------------------------------------\n");
  printf("DEVICE::BDF                     [%s]\n",
         deviceHandle.get_info<xrt::info::device::bdf>().c_str());
  printf("DEVICE::INDEX                   [%u]\n", deviceIndex);
  printf("DEVICE::MAX_CLOCK_FREQUENCY_MHZ [%ld]\n",
         deviceHandle.get_info<xrt::info::device::max_clock_frequency_mhz>());
  printf("DEVICE::NAME                    [%s]\n",
         deviceHandle.get_info<xrt::info::device::name>().c_str());
  printf("\n-----------------------------------------------------\n");

  switch (ctrlMode) {
  case 0: // UserManaged
    printf("KERNEL::CONTROL::MODE           [USER_MANAGED]\n");
    break;
  case 1: // CtrlHS
    printf("KERNEL::CONTROL::MODE           [AP_CTRL_HS]\n");
    break;
  case 2: // CtrlChain
    printf("KERNEL::CONTROL::MODE           [AP_CTRL_CHAIN]\n");
    break;
  default:
    printf("KERNEL::CONTROL::MODE           [USER_MANAGED]\n");
    break;
  }

  printf("KERNEL::CACHE::SIZE             [%d]\n", cacheSize);
  printf("KERNEL::NAME                    [%s]\n", kernelName.c_str());
  printf("KERNEL::NAME::FULL              [%s]\n", kernelNameFull.c_str());
  printf("KERNEL::THREADS::NUM            [%d]\n", numThreads);
  printf("KERNEL::XCLBIN::PATH            [%s]\n", xclbinPath.c_str());
  printf("KERNEL::ENDIAN::READ            [%d]\n", endian_read);
  printf("KERNEL::ENDIAN::WRITE           [%d]\n", endian_write);
  printf("KERNEL::FLUSH::ENABLE           [%d]\n", flush_enable);
  printf("-----------------------------------------------------\n");
  printf("OVERLAY::ALGORITHM              [%d]\n", overlay_algorithm);
  printf("OVERLAY::PROGRAM_ENTRIES        [%d]\n", overlay_program_entries);
  printf("OVERLAY::PATH                   [%s]\n", overlayPath.c_str());
  printf("-----------------------------------------------------\n");
  printf("KERNEL::ARGUMENTS::OFFSETS:     [%ld]\n",
         cuHandles[cu_id].get_args().size());
  printf("-----------------------------------------------------\n");
  uint32_t i = 0;
  for (auto it : cuHandles[cu_id].get_args()) {
    printf("ARG[%u]-[0x%03lX]\n", i, it.get_offset());
    i++;
  }
  printf("-----------------------------------------------------\n");
}

// ********************************************************************************************
// ***************                  GLAY General **************
// ********************************************************************************************

GLAYxrtBufferHandlePerKernel::GLAYxrtBufferHandlePerKernel(
    struct Arguments *arguments, struct GraphCSR *graph,
    struct GraphAuxiliary *graphAuxiliary) {

  // ********************************************************************************************
  // ***************                  Create Device Handle **************
  // ********************************************************************************************
  glayHandle = new xrtGLAYHandle(arguments);

  if (glayHandle == NULL) {
    printf("193::ERROR::GLAYxrtBufferHandlePerKernel::glayHandle = new "
           "xrtGLAYHandle(arguments);\n");
  } else {
    glayHandle->printGLAYDevice();
  }

  // ********************************************************************************************
  // ***************                  Allocate Device buffers **************
  // ********************************************************************************************
  assignGraphtoXRTBufferSize(graph, graphAuxiliary);

  switch (glayHandle->ctrlMode) {
  case 0: {
    for (int i = 0; i < xrt_buffers_num; i++) {
      xrt_buffer_object[i] =
          xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[i],
                  glayHandle->mem_used.get_index());
      printf(
          "IP::Buffer::Allocate::xrt::bo xrt_buffer_object[%d] BankGroup[%d]\n",
          i, glayHandle->mem_used.get_index());
    }
  } break;
  case 1:
  case 2: {
    for (int i = 0; i < xrt_buffers_num; i++) {
      xrt_buffer_object[i] =
          xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[i],
                  glayHandle->kernelHandle.group_id(i));
      printf("KERNEL::Buffer allocate(xrt::bo) xrt_buffer_object[%d] "
             "BankGroup[%d]\n",
             i, glayHandle->kernelHandle.group_id(i));
    }

  } break;
  default: {
    for (int i = 0; i < xrt_buffers_num; i++) {
      xrt_buffer_object[i] =
          xrt::bo(glayHandle->deviceHandle, xrt_buffer_size[i],
                  arguments->bankGroupIndex);
      printf("DEFAULT::IP::Buffer allocate(xrt::bo) xrt_buffer_object[%d] "
             "BankGroup[%d]\n",
             i, glayHandle->mem_used.get_index());
    }

  } break;
  }

  // ********************************************************************************************
  // ***************                  Setup Device pointers **************
  // ********************************************************************************************
  // ***************                  Setup Device to Host Sync **************
  // ********************************************************************************************
  // xrt_buffer_sync.set(7, true); // auxiliary 1 read back to host
  // xrt_buffer_sync.set(8, true); // auxiliary 2 read back to host
  std::string syncPattern = "0000000110";
  SetSyncBuffersBasedOnString(syncPattern);
  // ********************************************************************************************
  // Each read is 4-Bytes granularity (256 cycles to configure) | / endian mode
  // 0-big endian 1-little endian
  // ********************************************************************************************
  xrt_buffer_device[xrt_buffers_num - 1] =
      (uint64_t)((uint64_t)(glayHandle->cacheSize) << 32) |
      (uint64_t)(overlay_program_entries << 3) |
      (uint64_t)(glayHandle->flush_enable << 2) |
      ((uint64_t)glayHandle->endian_write << 1) |
      (uint64_t)glayHandle->endian_read;
  printf("-----------------------------------------------------\n");
  for (int i = 0; i < xrt_buffers_num - 1; i++) {
    xrt_buffer_device[i] = xrt_buffer_object[i].address();
    printf("SETUP::XRT-BUFFER-ID %-4u : DEVICE[0x%016lX] SIZE-BYTES[%-10lu], "
           "SYNC[%-1d]\n",
           i, xrt_buffer_device[i], xrt_buffer_size[i],
           xrt_buffer_sync.test(i));
  }
  printf("SETUP::XRT-BUFFER-ID %-4u : DEVICE[0x%016lX] SIZE-BYTES[%-10lu], "
         "SYNC[%-1d]\n",
         xrt_buffers_num - 1, xrt_buffer_device[xrt_buffers_num - 1],
         xrt_buffer_size[xrt_buffers_num - 1],
         xrt_buffer_sync.test(xrt_buffers_num - 1));
  printf("-----------------------------------------------------\n");
  // ********************************************************************************************
  // ***************                  Setup Host pointers **************
  // ********************************************************************************************
  initializeGLAYOverlayConfiguration(graph);
  assignGraphtoXRTBufferHost(graph, graphAuxiliary);
  printf("SETUP::GLAYxrtBufferHandlePerKernel::"
         "initializeGLAYOverlayConfiguration\n");
  printf("SETUP::GLAYxrtBufferHandlePerKernel::"
         "assignGraphtoXRTBufferHost\n");
  printf("-----------------------------------------------------\n");
  // ********************************************************************************************
}

void GLAYxrtBufferHandlePerKernel::SetSyncBuffersBasedOnString(
    const std::string &syncPattern) {
  // Reset all bits initially.
  xrt_buffer_sync.reset();

  for (size_t i = 0; i < syncPattern.length() && i < MAX_XRT_BUFFERS; ++i) {
    if (syncPattern[i] == '1') {
      xrt_buffer_sync.set(i, true); // auxiliary 1 read back to host
    }
  }
}

void GLAYxrtBufferHandlePerKernel::assignGraphtoXRTBufferSize(
    struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary) {

  printf("IP::START::GLAYxrtBufferHandlePerKernel::"
         "assignGraphtoXRTBufferSize\n");
  if (xrt_buffers_num <= 10) // Adjust based on actual size
  {
    overlay_program_entries = glayHandle->overlay_program_entries;
    xrt_buffer_size[0] =
        (glayHandle->overlay_program_entries * sizeof(uint32_t)) +
        glayHandle->cacheSize;
    xrt_buffer_size[1] = graph->num_vertices * sizeof(uint32_t);
    xrt_buffer_size[2] = graph->num_vertices * sizeof(uint32_t);
    xrt_buffer_size[3] = graph->num_vertices * sizeof(uint32_t);
    xrt_buffer_size[4] = graph->num_edges * sizeof(uint32_t);
    xrt_buffer_size[5] = graph->num_edges * sizeof(uint32_t);
    xrt_buffer_size[6] = graph->num_edges * sizeof(uint32_t);
    xrt_buffer_size[7] = graphAuxiliary->num_auxiliary_1 * sizeof(uint32_t);
    xrt_buffer_size[8] = graphAuxiliary->num_auxiliary_2 * sizeof(uint32_t);
    xrt_buffer_size[xrt_buffers_num - 1] = 8;
  } else {
    // Handle error or invalid `xrt_buffers_num` value
  }
  printf("IP::DONE::GLAYxrtBufferHandlePerKernel::"
         "assignGraphtoXRTBufferSize\n");
}

void GLAYxrtBufferHandlePerKernel::prinGraphtoXRTBufferSize() const {
  std::cout << "XRT Buffer Sizes:" << std::endl;
  for (int i = 0; i < xrt_buffers_num; ++i) {
    std::cout << "Buffer " << i << ": " << xrt_buffer_size[i] << " bytes"
              << std::endl;
  }
}

void GLAYxrtBufferHandlePerKernel::assignGraphtoXRTBufferHost(
    struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary) {
  struct Vertex *vertices = NULL;
  struct EdgeList *sorted_edges_array = NULL;

#if DIRECTED
  vertices = graph->inverse_vertices;
  sorted_edges_array = graph->inverse_sorted_edges_array;
#else
  vertices = graph->vertices;
  sorted_edges_array = graph->sorted_edges_array;
#endif

  if (xrt_buffers_num <= 10) // Adjust based on actual size
  {
    xrt_buffer_host[0] = overlay_program;
    xrt_buffer_host[1] = vertices->in_degree;
    xrt_buffer_host[2] = vertices->out_degree;
    xrt_buffer_host[3] = vertices->edges_idx;
    xrt_buffer_host[4] = sorted_edges_array->edges_array_src;
    xrt_buffer_host[5] = sorted_edges_array->edges_array_dest;
    xrt_buffer_host[6] = sorted_edges_array->edges_array_weight;
    xrt_buffer_host[7] = graphAuxiliary->auxiliary_1; // endian mode
    xrt_buffer_host[8] = graphAuxiliary->auxiliary_2; // cachelines
    xrt_buffer_host[xrt_buffers_num - 1] =
        &xrt_buffer_device[xrt_buffers_num - 1];
  } else {
    // Handle error or invalid `xrt_buffers_num` value
  }
}

int GLAYxrtBufferHandlePerKernel::writeGLAYHostToDeviceBuffersPerKernel() {
  printf("IP::START::GLAYxrtBufferHandlePerKernel::"
         "writeGLAYHostToDeviceBuffersPerKernel\n");
  for (int i = 0; i < xrt_buffers_num; i++) {
    xrt_buffer_object[i].write(xrt_buffer_host[i], xrt_buffer_size[i], 0);
    xrt_buffer_object[i].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[i], 0);
    printf("WRITE::SYNC::XCL_BO_SYNC_BO_TO_DEVICE xrt_buffer_object[%d] "
           "xrt_buffer_size[%ld]\n",
           i, xrt_buffer_size[i]);
  }
  printf("IP::DONE::GLAYxrtBufferHandlePerKernel::"
         "writeGLAYHostToDeviceBuffersPerKernel\n");
  return 0;
}

int GLAYxrtBufferHandlePerKernel::mapGLAYHostToDeviceBuffersPerKernel() {
  for (int i = 0; i < xrt_buffers_num; i++) {
    // xrt_buffer_map[i] = xrt_buffer_device[i].map<uint32_t *>();
  }
  return 0;
}

int GLAYxrtBufferHandlePerKernel::readGLAYDeviceToHostBuffersPerKernel() {
  for (int i = 0; i < xrt_buffers_num; i++) {
    if (xrt_buffer_sync.test(i)) // Check if sync is enabled
    {
      xrt_buffer_object[i].sync(XCL_BO_SYNC_BO_FROM_DEVICE, xrt_buffer_size[i],
                                0);
      xrt_buffer_object[i].read(xrt_buffer_host[i], xrt_buffer_size[i], 0);
    }
  }
  return 0;
}

int GLAYxrtBufferHandlePerKernel::
    writeRegistersAddressGLAYHostToDeviceBuffersPerKernel() {
  auto args = glayHandle->cuHandles[glayHandle->cu_id].get_args();
  printf("IP::START::GLAYxrtBufferHandlePerKernel::"
         "writeRegistersAddressGLAYHostToDeviceBuffersPerKernel");
  for (int i = 0; i < xrt_buffers_num; i++) {
    glayHandle->ipHandle.write_register(args[i].get_offset(),
                                        xrt_buffer_device[i]);
    glayHandle->ipHandle.write_register((args[i].get_offset() + 4),
                                        xrt_buffer_device[i] >> 32);
    printf("IP::WRITE::REGISTER::ARGS[%d] RHS-OFFSET[0x%08lX][0x%08lX] "
           "LHS-OFFSET[0x%08lX][0x%08lX]",
           i, (args[i].get_offset() + 4), (xrt_buffer_device[i] >> 32),
           args[i].get_offset(), xrt_buffer_device[i]);
  }
  printf("IP::DONE::GLAYxrtBufferHandlePerKernel::"
         "writeRegistersAddressGLAYHostToDeviceBuffersPerKernel\n");
  return 0;
}

int GLAYxrtBufferHandlePerKernel::
    setArgsKernelAddressGLAYHostToDeviceBuffersPerKernel() {
  glayHandle->runKernelHandle = xrt::run(glayHandle->kernelHandle);
  for (int i = 0; i < xrt_buffers_num; i++) {
    glayHandle->runKernelHandle.set_arg(i, xrt_buffer_object[i]);
  }
  return 0;
}

void GLAYxrtBufferHandlePerKernel::initializeGLAYOverlayConfiguration(
    struct GraphCSR *graph) {

  overlay_program = (uint32_t *)aligned_alloc(
      4096, xrt_buffer_size[0]); // Assuming 4096-byte alignment

  for (uint32_t i = 0; i < (xrt_buffer_size[0] / sizeof(uint32_t)); i++) {
    overlay_program[i] = 0;
  }

  if (!overlay_program) {
    std::cerr << "ERROR::GLAYxrtBufferHandlePerKernel::"
                 "setArgsKernelAddressGLAYHostToDeviceBuffersPerKernel "
                 "Memory alignment error."
              << std::endl;
    return;
  }

  for (int i = 0; i < overlay_program_entries; i++) {
    overlay_program[i] = glayHandle->overlay_program[i];
  }

  switch (glayHandle->overlay_algorithm) {
  case 0: // bfs
  {
    mapGLAYOverlayProgramBuffersBFS(graph);
  } break;
  case 1: // pagerank
  {
    mapGLAYOverlayProgramBuffersPR(graph);
  } break;
  case 5: // SPMV
  {
    mapGLAYOverlayProgramBuffersSPMV(graph);
  } break;
  case 6: // Connected Components
  {
    mapGLAYOverlayProgramBuffersCC(graph);
  } break;
  case 8: // Triangle Counting
  {
    mapGLAYOverlayProgramBuffersTC(graph);
  } break;
  default: // BFS
  {
    mapGLAYOverlayProgramBuffersBFS(graph);
  } break;
  }
}

void GLAYxrtBufferHandlePerKernel::printGLAYxrtBufferHandlePerKernel() {
  for (uint32_t i = 0; i < 10; ++i) {
    printf("XRT-BUFFER-ID %-4u : HOST[%16p] DEVICE[0x%016lX] SIZE-BYTES[%lu], "
           "SYNC[%d]\n",
           i, xrt_buffer_host[i], xrt_buffer_device[i], xrt_buffer_size[i],
           xrt_buffer_sync.test(i));
  }

  printf("\nCURRENT OVERLAY CONFIGURATION ... \n");

  for (int j = 0; j < overlay_program_entries; j++) {
    printf("[0x%08X] - current...entry[%u]\n", overlay_program[j], j);
  }
}

// ********************************************************************************************
// ***************                  GLAY Control **************
// ********************************************************************************************
void GLAYxrtBufferHandlePerKernel::setupGLAY() {
  switch (glayHandle->ctrlMode) {
  case 0: // UserManaged
    setupGLAYUserManaged();
    break;
  case 1: // CtrlHS
    setupGLAYCtrlHs();
    break;
  case 2: // CtrlChain
    setupGLAYCtrlChain();
    break;
  default:
    setupGLAYUserManaged();
    break;
  }
}

void GLAYxrtBufferHandlePerKernel::startGLAY() {
  switch (glayHandle->ctrlMode) {
  case 0: // UserManaged
    startGLAYUserManaged();
    break;
  case 1: // CtrlHS
    startGLAYCtrlHs();
    break;
  case 2: // CtrlChain
    startGLAYCtrlChain();
    break;
  default:
    startGLAYUserManaged();
    break;
  }
}

void GLAYxrtBufferHandlePerKernel::waitGLAY() {
  switch (glayHandle->ctrlMode) {
  case 0: // UserManaged
    waitGLAYUserManaged();
    break;
  case 1: // CtrlHS
    waitGLAYCtrlHs();
    break;
  case 2: // CtrlChain
    waitGLAYCtrlChain();
    break;
  default:
    releaseGLAYUserManaged();
    break;
  }
}

void GLAYxrtBufferHandlePerKernel::releaseGLAY() {
  switch (glayHandle->ctrlMode) {
  case 0: // UserManaged
    releaseGLAYUserManaged();
    break;
  case 1: // CtrlHS
    releaseGLAYCtrlHs();
    break;
  case 2: // CtrlChain
    releaseGLAYCtrlChain();
    break;
  default:
    releaseGLAYUserManaged();
    break;
  }
}

// ********************************************************************************************
// ***************                  GLAY Control USER_MANAGED **************
// ********************************************************************************************

void GLAYxrtBufferHandlePerKernel::setupGLAYUserManaged() {
  writeGLAYHostToDeviceBuffersPerKernel();
  writeRegistersAddressGLAYHostToDeviceBuffersPerKernel();
}

void GLAYxrtBufferHandlePerKernel::startGLAYUserManaged() {
  uint32_t glay_control_write = 0;
  uint32_t glay_control_read = 0;
  glay_control_write = CONTROL_START;

  glayHandle->ipHandle.write_register(CONTROL_OFFSET, glay_control_write);

  do {
    glay_control_read = glayHandle->ipHandle.read_register(CONTROL_OFFSET);
    printf("MSG::UserManaged::START-[0x%08X] \n", glay_control_read);
  } while (!(glay_control_read & CONTROL_READY));

  printf("MSG::UserManaged::WAIT-[0x%08X] \n", glay_control_read);
}

void GLAYxrtBufferHandlePerKernel::waitGLAYUserManaged() {
  uint32_t glay_control_read = 0;

  do {
    glay_control_read = glayHandle->ipHandle.read_register(CONTROL_OFFSET);
    // printf("MSG: WAIT-[0x%08X] \n", glay_control_read);
  } while (!(glay_control_read & CONTROL_IDLE));

  printf("MSG::UserManaged::WAIT-[0x%08X] \n", glay_control_read);
}

void GLAYxrtBufferHandlePerKernel::releaseGLAYUserManaged() {
  // Close an opened device
  //  xrtKernelClose(glayHandle->kernelHandle);
  //  xrtDeviceClose(glayHandle->deviceHandle);
}

// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_HS **************
// ********************************************************************************************

void GLAYxrtBufferHandlePerKernel::setupGLAYCtrlHs() {
  writeGLAYHostToDeviceBuffersPerKernel();
  setArgsKernelAddressGLAYHostToDeviceBuffersPerKernel();
}

void GLAYxrtBufferHandlePerKernel::startGLAYCtrlHs() {
  glayHandle->runKernelHandle.start();
}

void GLAYxrtBufferHandlePerKernel::waitGLAYCtrlHs() {
  glayHandle->runKernelHandle.wait();
}

void GLAYxrtBufferHandlePerKernel::releaseGLAYCtrlHs() {
  // Close an opened device
  //  xrtKernelClose(glayHandle->kernelHandle);
  //  xrtDeviceClose(glayHandle->deviceHandle);
}

// ********************************************************************************************
// ***************                  GLAY Control AP_CTRL_CHAIN **************
// ********************************************************************************************

void GLAYxrtBufferHandlePerKernel::setupGLAYCtrlChain() {
  writeGLAYHostToDeviceBuffersPerKernel();
  setArgsKernelAddressGLAYHostToDeviceBuffersPerKernel();
}

void GLAYxrtBufferHandlePerKernel::startGLAYCtrlChain() {
  glayHandle->runKernelHandle.start();
}

void GLAYxrtBufferHandlePerKernel::waitGLAYCtrlChain() {
  glayHandle->runKernelHandle.wait();
}

void GLAYxrtBufferHandlePerKernel::releaseGLAYCtrlChain() {
  // Close an opened device
  //  xrtKernelClose(glayHandle->kernelHandle);
  //  xrtDeviceClose(glayHandle->deviceHandle);
}

// ********************************************************************************************
// ***************                  GLAY Control multithreaded **************
// ********************************************************************************************

// // kernel running thread
// void executeGLayThread(xrt::run runGLayKernel,
// GLAYxrtBufferHandlePerKernel *glayGraphCSRxrtBufferHandlePerKernel)
// {
//     runGLayKernel.set_arg(ADDR_BUFFER_0_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[0]);
//     runGLayKernel.set_arg(ADDR_BUFFER_1_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[1]);
//     runGLayKernel.set_arg(ADDR_BUFFER_2_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[2]);
//     runGLayKernel.set_arg(ADDR_BUFFER_3_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[3]);
//     runGLayKernel.set_arg(ADDR_BUFFER_4_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[4]);
//     runGLayKernel.set_arg(ADDR_BUFFER_5_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[5]);
//     runGLayKernel.set_arg(ADDR_BUFFER_6_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[6]);
//     runGLayKernel.set_arg(ADDR_BUFFER_7_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[7]);
//     runGLayKernel.set_arg(ADDR_BUFFER_8_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[8]);
//     runGLayKernel.set_arg(ADDR_BUFFER_9_ID,
//     glayGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[9]);
//     runGLayKernel.start();
//     runGLayKernel.wait();
// }

// void executeGLayMultiThreaded(xrtGLAYHandle *glayHandle,
// GLAYxrtBufferHandlePerKernel *glayGraphCSRxrtBufferHandlePerKernel)
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
//             t[i] = std::thread(executeGLayThread, runGLayKernels[i],
//             glayGraphCSRxrtBufferHandlePerKernel);
//         }
//         for (i = 0; i < thread_num; i++)
//         {
//             t[i].join();
//         }
//     }
//     for (i = 0; i < residue; i++)
//     {
//         //runGLayKernels[i].set_arg(krnl_cbc_arg_SRC_ADDR, input_sub_buffer[k
//         * thread_num + i]);   // use sub-buffer for source pointer argument
//         //runGLayKernels[i].set_arg(krnl_cbc_arg_DEST_ADDR,
//         output_sub_buffer[k * thread_num + i]); // use sub-buffer for source
//         pointer argument t[i] = std::thread(executeGLayThread,
//         runGLayKernels[i], glayGraphCSRxrtBufferHandlePerKernel);
//     }
//     for (i = 0; i < residue; i++)
//     {
//         t[i].join();
//     }

// }59a5b4f4da507000 61040f3ff1241000