// -----------------------------------------------------------------------------
//
//      "GRAPHBLOX"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2019 All rights reserved
// -----------------------------------------------------------------------------
// Author : Abdullah Mughrabi
// Email  : atmughra@ncsu.edu||atmughrabi@gmail.com
// File   : graphbloxenv.c
// Create : 2019-10-09 19:20:39
// Revise : 2019-12-01 00:12:59
// Editor : Abdullah Mughrabi
// -----------------------------------------------------------------------------

#include "graphbloxenv.hpp"
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
// ***************                  GRAPHBLOX Handle **************
// ********************************************************************************************

xrtGRAPHBLOXHandle::xrtGRAPHBLOXHandle(struct Arguments *arguments) {
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
  overlay_program_entries = 0; // Will be set in readGRAPHBLOXDeviceEntriesFromFile
  kernelNameFull =
      kernelName + ":{" + kernelName + "_" + std::to_string(cu_id + 1) + "}";

  setupGRAPHBLOXDevice();
}

void xrtGRAPHBLOXHandle::setupGRAPHBLOXDevice() {
  // Perform the setup as in the original setupGRAPHBLOXDevice function
  // This includes reading entries from file, initializing xrt devices, etc.
  readGRAPHBLOXDeviceEntriesFromFile(); // Reads entries into overlay_program and
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
    kernelHandle = xrt::kernel(deviceHandle, xclbinUUID, kernelNameFull.c_str(),
                               xrt::kernel::cu_access_mode::exclusive);
    break;
  default:
    ipHandle = xrt::ip(deviceHandle, xclbinUUID, kernelNameFull.c_str());
    break;
  }
}

void xrtGRAPHBLOXHandle::readGRAPHBLOXDeviceEntriesFromFile() {
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

void xrtGRAPHBLOXHandle::printGRAPHBLOXDevice() const {
  DEBUG_PRINT("\n-----------------------------------------------------\n");
  DEBUG_PRINT("DEVICE::BDF                     [%s]\n",
              deviceHandle.get_info<xrt::info::device::bdf>().c_str());
  DEBUG_PRINT("DEVICE::INDEX                   [%u]\n", deviceIndex);
  DEBUG_PRINT(
      "DEVICE::MAX_CLOCK_FREQUENCY_MHZ [%ld]\n",
      deviceHandle.get_info<xrt::info::device::max_clock_frequency_mhz>());
  DEBUG_PRINT("DEVICE::NAME                    [%s]\n",
              deviceHandle.get_info<xrt::info::device::name>().c_str());
  DEBUG_PRINT("\n-----------------------------------------------------\n");

  switch (ctrlMode) {
  case 0: // UserManaged
    DEBUG_PRINT("KERNEL::CONTROL::MODE           [USER_MANAGED]\n");
    break;
  case 1: // CtrlHS
    DEBUG_PRINT("KERNEL::CONTROL::MODE           [AP_CTRL_HS]\n");
    break;
  case 2: // CtrlChain
    DEBUG_PRINT("KERNEL::CONTROL::MODE           [AP_CTRL_CHAIN]\n");
    break;
  default:
    DEBUG_PRINT("KERNEL::CONTROL::MODE           [USER_MANAGED]\n");
    break;
  }

  DEBUG_PRINT("KERNEL::CACHE::SIZE             [%d]\n", cacheSize);
  DEBUG_PRINT("KERNEL::NAME                    [%s]\n", kernelName.c_str());
  DEBUG_PRINT("KERNEL::NAME::FULL              [%s]\n", kernelNameFull.c_str());
  DEBUG_PRINT("KERNEL::THREADS::NUM            [%d]\n", numThreads);
  DEBUG_PRINT("KERNEL::XCLBIN::PATH            [%s]\n", xclbinPath.c_str());
  DEBUG_PRINT("KERNEL::ENDIAN::READ            [%d]\n", endian_read);
  DEBUG_PRINT("KERNEL::ENDIAN::WRITE           [%d]\n", endian_write);
  DEBUG_PRINT("KERNEL::FLUSH::ENABLE           [%d]\n", flush_enable);
  DEBUG_PRINT("-----------------------------------------------------\n");
  DEBUG_PRINT("OVERLAY::ALGORITHM              [%d]\n", overlay_algorithm);
  DEBUG_PRINT("OVERLAY::PROGRAM_ENTRIES        [%d]\n",
              overlay_program_entries);
  DEBUG_PRINT("OVERLAY::PATH                   [%s]\n", overlayPath.c_str());
  DEBUG_PRINT("-----------------------------------------------------\n");
  DEBUG_PRINT("KERNEL::ARGUMENTS::OFFSETS:     [%ld]\n",
              cuHandles[cu_id].get_args().size());
  DEBUG_PRINT("-----------------------------------------------------\n");
  uint32_t i = 0;
  for (auto it : cuHandles[cu_id].get_args()) {
    DEBUG_PRINT("ARG[%u]-[0x%03lX]\n", i, it.get_offset());
    i++;
  }
  DEBUG_PRINT("-----------------------------------------------------\n");
}

// ********************************************************************************************
// ***************                  GRAPHBLOX General **************
// ********************************************************************************************

GRAPHBLOXxrtBufferHandlePerKernel::GRAPHBLOXxrtBufferHandlePerKernel(
    struct Arguments *arguments, struct GraphCSR *graph,
    struct GraphAuxiliary *graphAuxiliary) {

  // ********************************************************************************************
  // ***************                  Create Device Handle **************
  // ********************************************************************************************
  graphBloxHandle = new xrtGRAPHBLOXHandle(arguments);

  if (graphBloxHandle == NULL) {
    DEBUG_PRINT("183::ERROR::GRAPHBLOXxrtBufferHandlePerKernel::graphBloxHandle = new "
                "xrtGRAPHBLOXHandle(arguments);\n");
  } else {
    graphBloxHandle->printGRAPHBLOXDevice();
  }

  // ********************************************************************************************
  // ***************                  Allocate Device buffers **************
  // ********************************************************************************************
  assignGraphtoXRTBufferSize(graph, graphAuxiliary);

  switch (graphBloxHandle->ctrlMode) {
  case 0: {
    for (int i = 0; i < xrt_buffers_num; i++) {
      xrt_buffer_object[i] =
          xrt::bo(graphBloxHandle->deviceHandle, xrt_buffer_size[i],
                  graphBloxHandle->mem_used.get_index());
      DEBUG_PRINT(
          "IP::Buffer::Allocate::xrt::bo xrt_buffer_object[%d] BankGroup[%d]\n",
          i, graphBloxHandle->mem_used.get_index());
    }
  } break;
  case 1:
  case 2: {
    for (int i = 0; i < xrt_buffers_num; i++) {
      xrt_buffer_object[i] =
          xrt::bo(graphBloxHandle->deviceHandle, xrt_buffer_size[i],
                  graphBloxHandle->kernelHandle.group_id(i));
      DEBUG_PRINT("KERNEL::Buffer allocate(xrt::bo) xrt_buffer_object[%d] "
                  "BankGroup[%d]\n",
                  i, graphBloxHandle->kernelHandle.group_id(i));
    }

  } break;
  default: {
    for (int i = 0; i < xrt_buffers_num; i++) {
      xrt_buffer_object[i] =
          xrt::bo(graphBloxHandle->deviceHandle, xrt_buffer_size[i],
                  arguments->bankGroupIndex);
      DEBUG_PRINT("DEFAULT::IP::Buffer allocate(xrt::bo) xrt_buffer_object[%d] "
                  "BankGroup[%d]\n",
                  i, graphBloxHandle->mem_used.get_index());
    }

  } break;
  }

  // ********************************************************************************************
  // ***************                  Setup Device CUs **************
  for (int i = 0; i < arguments->ker_numThreads; ++i) {
    cu_vector.set(i); // Set the first 'activeCUs' bits to 1
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

  system_cache_num_ways = 4;
  system_cache_data_width = 512 / 8;
  system_cache_size = graphBloxHandle->cacheSize;
  system_cache_line_size_log = (uint32_t)log2(system_cache_data_width);
  system_cache_num_sets =
      (system_cache_size >>
       (system_cache_line_size_log + (uint32_t)log2(system_cache_num_ways)));
  system_cache_count = system_cache_num_sets * system_cache_num_ways;

 DEBUG_PRINT("system_cache_count %u \n\n", system_cache_count);
  // ********************************************************************************************
  // Each read is 4-Bytes granularity (256 cycles to configure) | / endian mode
  // 0-big endian 1-little endian
  // ********************************************************************************************
  xrt_buffer_device[xrt_buffers_num - 1] =
      (uint64_t)((uint64_t)(system_cache_count) << 32) |
      (uint64_t)(cu_vector.to_ullong() << 16) |
      (uint64_t)(overlay_program_entries << 3) |
      (uint64_t)(graphBloxHandle->flush_enable << 2) |
      ((uint64_t)graphBloxHandle->endian_write << 1) |
      (uint64_t)graphBloxHandle->endian_read;
  DEBUG_PRINT("-----------------------------------------------------\n");
  for (int i = 0; i < xrt_buffers_num - 1; i++) {
    xrt_buffer_device[i] = xrt_buffer_object[i].address();
    DEBUG_PRINT(
        "SETUP::XRT-BUFFER-ID %-4u : DEVICE[0x%016lX] SIZE-BYTES[%-10lu], "
        "SYNC[%-1d]\n",
        i, xrt_buffer_device[i], xrt_buffer_size[i], xrt_buffer_sync.test(i));
  }
  DEBUG_PRINT(
      "SETUP::XRT-BUFFER-ID %-4u : DEVICE[0x%016lX] SIZE-BYTES[%-10lu], "
      "SYNC[%-1d]\n",
      xrt_buffers_num - 1, xrt_buffer_device[xrt_buffers_num - 1],
      xrt_buffer_size[xrt_buffers_num - 1],
      xrt_buffer_sync.test(xrt_buffers_num - 1));
  DEBUG_PRINT("-----------------------------------------------------\n");
  // ********************************************************************************************
  // ***************                  Setup Host pointers **************
  // ********************************************************************************************
  initializeGRAPHBLOXOverlayConfiguration(graph);
  assignGraphtoXRTBufferHost(graph, graphAuxiliary);
  DEBUG_PRINT("SETUP::GRAPHBLOXxrtBufferHandlePerKernel::"
              "initializeGRAPHBLOXOverlayConfiguration\n");
  DEBUG_PRINT("SETUP::GRAPHBLOXxrtBufferHandlePerKernel::"
              "assignGraphtoXRTBufferHost\n");
  DEBUG_PRINT("-----------------------------------------------------\n");
  // ********************************************************************************************
}

void GRAPHBLOXxrtBufferHandlePerKernel::SetSyncBuffersBasedOnString(
    const std::string &syncPattern) {
  // Reset all bits initially.
  xrt_buffer_sync.reset();

  for (size_t i = 0; i < syncPattern.length() && i < MAX_XRT_BUFFERS; ++i) {
    if (syncPattern[i] == '1') {
      xrt_buffer_sync.set(i, true); // auxiliary 1 read back to host
    }
  }
}

void GRAPHBLOXxrtBufferHandlePerKernel::assignGraphtoXRTBufferSize(
    struct GraphCSR *graph, struct GraphAuxiliary *graphAuxiliary) {

  DEBUG_PRINT("IP::START::GRAPHBLOXxrtBufferHandlePerKernel::"
              "assignGraphtoXRTBufferSize\n");
  if (xrt_buffers_num <= 10) // Adjust based on actual size
  {
    overlay_program_entries = graphBloxHandle->overlay_program_entries;
    xrt_buffer_size[0] =
        ((graphBloxHandle->overlay_program_entries + system_cache_count) *
         sizeof(uint32_t));
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
  DEBUG_PRINT("IP::DONE::GRAPHBLOXxrtBufferHandlePerKernel::"
              "assignGraphtoXRTBufferSize\n");
}

void GRAPHBLOXxrtBufferHandlePerKernel::prinGraphtoXRTBufferSize() const {
  std::cout << "XRT Buffer Sizes:" << std::endl;
  for (int i = 0; i < xrt_buffers_num; ++i) {
    std::cout << "Buffer " << i << ": " << xrt_buffer_size[i] << " bytes"
              << std::endl;
  }
}

void GRAPHBLOXxrtBufferHandlePerKernel::assignGraphtoXRTBufferHost(
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

int GRAPHBLOXxrtBufferHandlePerKernel::writeGRAPHBLOXHostToDeviceBuffersPerKernel() {
  DEBUG_PRINT("IP::START::GRAPHBLOXxrtBufferHandlePerKernel::"
              "writeGRAPHBLOXHostToDeviceBuffersPerKernel\n");
  for (int i = 0; i < xrt_buffers_num; i++) {
    xrt_buffer_object[i].write(xrt_buffer_host[i], xrt_buffer_size[i], 0);
    DEBUG_PRINT("WRITE::XCL_BO_SYNC_BO_TO_DEVICE xrt_buffer_object[%d] "
                "xrt_buffer_size[%ld]\n",
                i, xrt_buffer_size[i]);
  }
  for (int i = 0; i < xrt_buffers_num; i++) {

    DEBUG_PRINT("SYNC::XCL_BO_SYNC_BO_TO_DEVICE xrt_buffer_object[%d] "
                "xrt_buffer_size[%ld]\n",
                i, xrt_buffer_size[i]);
  }
  DEBUG_PRINT("IP::DONE::GRAPHBLOXxrtBufferHandlePerKernel::"
              "writeGRAPHBLOXHostToDeviceBuffersPerKernel\n");
  return 0;
}

int GRAPHBLOXxrtBufferHandlePerKernel::mapGRAPHBLOXHostToDeviceBuffersPerKernel() {
  for (int i = 0; i < xrt_buffers_num; i++) {
    // xrt_buffer_map[i] = xrt_buffer_device[i].map<uint32_t *>();
  }
  return 0;
}

int GRAPHBLOXxrtBufferHandlePerKernel::updateGRAPHBLOXDeviceToHostBuffersPerKernel() {
  for (int i = 0; i < xrt_buffers_num; i++) {
    if (xrt_buffer_sync.test(i)) // Check if sync is enabled
    {
      xrt_buffer_object[i].write(xrt_buffer_host[i], xrt_buffer_size[i], 0);
      xrt_buffer_object[i].sync(XCL_BO_SYNC_BO_TO_DEVICE, xrt_buffer_size[i], 0);
    }
  }
  return 0;
}


int GRAPHBLOXxrtBufferHandlePerKernel::readGRAPHBLOXDeviceToHostBuffersPerKernel() {
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

int GRAPHBLOXxrtBufferHandlePerKernel::
    writeRegistersAddressGRAPHBLOXHostToDeviceBuffersPerKernel() {
  auto args = graphBloxHandle->cuHandles[graphBloxHandle->cu_id].get_args();
  DEBUG_PRINT("IP::START::GRAPHBLOXxrtBufferHandlePerKernel::"
              "writeRegistersAddressGRAPHBLOXHostToDeviceBuffersPerKernel\n");
  for (int i = 0; i < xrt_buffers_num; i++) {
    graphBloxHandle->ipHandle.write_register(args[i].get_offset(),
                                        xrt_buffer_device[i]);
    graphBloxHandle->ipHandle.write_register((args[i].get_offset() + 4),
                                        xrt_buffer_device[i] >> 32);
    DEBUG_PRINT("IP::WRITE::REGISTER::ARGS[%d] RHS-OFFSET[0x%08lX][0x%08lX] "
                "LHS-OFFSET[0x%08lX][0x%08lX]\n",
                i, (args[i].get_offset() + 4), (xrt_buffer_device[i] >> 32),
                args[i].get_offset(), xrt_buffer_device[i]);
  }
  DEBUG_PRINT("IP::DONE::GRAPHBLOXxrtBufferHandlePerKernel::"
              "writeRegistersAddressGRAPHBLOXHostToDeviceBuffersPerKernel\n");
  return 0;
}

int GRAPHBLOXxrtBufferHandlePerKernel::
    setArgsKernelAddressGRAPHBLOXHostToDeviceBuffersPerKernel() {
  graphBloxHandle->runKernelHandle = xrt::run(graphBloxHandle->kernelHandle);
  for (int i = 0; i < xrt_buffers_num; i++) {
    graphBloxHandle->runKernelHandle.set_arg(i, xrt_buffer_object[i]);
  }
  return 0;
}

void GRAPHBLOXxrtBufferHandlePerKernel::initializeGRAPHBLOXOverlayConfiguration(
    struct GraphCSR *graph) {

  overlay_program = (uint32_t *)aligned_alloc(
      4096, xrt_buffer_size[0]); // Assuming 4096-byte alignment

  for (uint32_t i = 0; i < (xrt_buffer_size[0] / sizeof(uint32_t)); i++) {
    overlay_program[i] = 0;
  }

  if (!overlay_program) {
    std::cerr << "ERROR::GRAPHBLOXxrtBufferHandlePerKernel::"
                 "setArgsKernelAddressGRAPHBLOXHostToDeviceBuffersPerKernel "
                 "Memory alignment error."
              << std::endl;
    return;
  }

  for (int i = 0; i < overlay_program_entries; i++) {
    overlay_program[i] = graphBloxHandle->overlay_program[i];
  }

  switch (graphBloxHandle->overlay_algorithm) {
  case 0: // bfs
  {
    mapGRAPHBLOXOverlayProgramBuffersBFS(graph);
  } break;
  case 1: // pagerank
  {
    mapGRAPHBLOXOverlayProgramBuffersPR(graph);
  } break;
  case 5: // SPMV
  {
    mapGRAPHBLOXOverlayProgramBuffersSPMV(graph);
  } break;
  case 6: // Connected Components
  {
    mapGRAPHBLOXOverlayProgramBuffersCC(graph);
  } break;
  case 8: // Triangle Counting
  {
    mapGRAPHBLOXOverlayProgramBuffersTC(graph);
  } break;
  default: // BFS
  {
    mapGRAPHBLOXOverlayProgramBuffersBFS(graph);
  } break;
  }
}

void GRAPHBLOXxrtBufferHandlePerKernel::printGRAPHBLOXxrtBufferHandlePerKernel() {
  for (uint32_t i = 0; i < 10; ++i) {
    DEBUG_PRINT(
        "XRT-BUFFER-ID %-4u : HOST[%16p] DEVICE[0x%016lX] SIZE-BYTES[%lu], "
        "SYNC[%d]\n",
        i, xrt_buffer_host[i], xrt_buffer_device[i], xrt_buffer_size[i],
        xrt_buffer_sync.test(i));
  }

  DEBUG_PRINT("\nCURRENT OVERLAY CONFIGURATION ... \n");

  for (int j = 0; j < overlay_program_entries; j++) {
    DEBUG_PRINT("[0x%08X] - current...entry[%u]\n", overlay_program[j], j);
  }
}

// ********************************************************************************************
// ***************                  GRAPHBLOX Control **************
// ********************************************************************************************
void GRAPHBLOXxrtBufferHandlePerKernel::setupGRAPHBLOX() {
  switch (graphBloxHandle->ctrlMode) {
  case 0: // UserManaged
    setupGRAPHBLOXUserManaged();
    break;
  case 1: // CtrlHS
    setupGRAPHBLOXCtrlHs();
    break;
  case 2: // CtrlChain
    setupGRAPHBLOXCtrlChain();
    break;
  default:
    setupGRAPHBLOXUserManaged();
    break;
  }
}

void GRAPHBLOXxrtBufferHandlePerKernel::startGRAPHBLOX() {
  switch (graphBloxHandle->ctrlMode) {
  case 0: // UserManaged
    startGRAPHBLOXUserManaged();
    break;
  case 1: // CtrlHS
    startGRAPHBLOXCtrlHs();
    break;
  case 2: // CtrlChain
    startGRAPHBLOXCtrlChain();
    break;
  default:
    startGRAPHBLOXUserManaged();
    break;
  }
}

void GRAPHBLOXxrtBufferHandlePerKernel::waitGRAPHBLOX() {
  switch (graphBloxHandle->ctrlMode) {
  case 0: // UserManaged
    waitGRAPHBLOXUserManaged();
    break;
  case 1: // CtrlHS
    waitGRAPHBLOXCtrlHs();
    break;
  case 2: // CtrlChain
    waitGRAPHBLOXCtrlChain();
    break;
  default:
    releaseGRAPHBLOXUserManaged();
    break;
  }
}

void GRAPHBLOXxrtBufferHandlePerKernel::releaseGRAPHBLOX() {
  switch (graphBloxHandle->ctrlMode) {
  case 0: // UserManaged
    releaseGRAPHBLOXUserManaged();
    break;
  case 1: // CtrlHS
    releaseGRAPHBLOXCtrlHs();
    break;
  case 2: // CtrlChain
    releaseGRAPHBLOXCtrlChain();
    break;
  default:
    releaseGRAPHBLOXUserManaged();
    break;
  }
}

// ********************************************************************************************
// ***************                  GRAPHBLOX Control USER_MANAGED **************
// ********************************************************************************************

void GRAPHBLOXxrtBufferHandlePerKernel::setupGRAPHBLOXUserManaged() {
  writeGRAPHBLOXHostToDeviceBuffersPerKernel();
  writeRegistersAddressGRAPHBLOXHostToDeviceBuffersPerKernel();
}

void GRAPHBLOXxrtBufferHandlePerKernel::startGRAPHBLOXUserManaged() {
  uint32_t graphBlox_control_write = 0;
  uint32_t graphBlox_control_read = 0;
  graphBlox_control_write = CONTROL_START;

  graphBloxHandle->ipHandle.write_register(CONTROL_OFFSET, graphBlox_control_write);

  do {
    graphBlox_control_read = graphBloxHandle->ipHandle.read_register(CONTROL_OFFSET);
    DEBUG_PRINT("MSG::UserManaged::START-[0x%08X] \n", graphBlox_control_read);
  } while (!(graphBlox_control_read & CONTROL_READY));

  DEBUG_PRINT("MSG::UserManaged::WAIT-[0x%08X] \n", graphBlox_control_read);
}

void GRAPHBLOXxrtBufferHandlePerKernel::waitGRAPHBLOXUserManaged() {
  uint32_t graphBlox_control_read = 0;

  do {
    graphBlox_control_read = graphBloxHandle->ipHandle.read_register(CONTROL_OFFSET);
    // DEBUG_PRINT("MSG: WAIT-[0x%08X] \n", graphBlox_control_read);
  } while (!(graphBlox_control_read & CONTROL_IDLE));

  DEBUG_PRINT("MSG::UserManaged::WAIT-[0x%08X] \n", graphBlox_control_read);
}

void GRAPHBLOXxrtBufferHandlePerKernel::releaseGRAPHBLOXUserManaged() {
  // Close an opened device
  //  xrtKernelClose(graphBloxHandle->kernelHandle);
  //  xrtDeviceClose(graphBloxHandle->deviceHandle);
}

// ********************************************************************************************
// ***************                  GRAPHBLOX Control AP_CTRL_HS **************
// ********************************************************************************************

void GRAPHBLOXxrtBufferHandlePerKernel::setupGRAPHBLOXCtrlHs() {
  writeGRAPHBLOXHostToDeviceBuffersPerKernel();
  setArgsKernelAddressGRAPHBLOXHostToDeviceBuffersPerKernel();
}

void GRAPHBLOXxrtBufferHandlePerKernel::startGRAPHBLOXCtrlHs() {
  graphBloxHandle->runKernelHandle.start();
}

void GRAPHBLOXxrtBufferHandlePerKernel::waitGRAPHBLOXCtrlHs() {
  graphBloxHandle->runKernelHandle.wait();
}

void GRAPHBLOXxrtBufferHandlePerKernel::releaseGRAPHBLOXCtrlHs() {
  // Close an opened device
  //  xrtKernelClose(graphBloxHandle->kernelHandle);
  //  xrtDeviceClose(graphBloxHandle->deviceHandle);
}

// ********************************************************************************************
// ***************                  GRAPHBLOX Control AP_CTRL_CHAIN **************
// ********************************************************************************************

void GRAPHBLOXxrtBufferHandlePerKernel::setupGRAPHBLOXCtrlChain() {
  writeGRAPHBLOXHostToDeviceBuffersPerKernel();
  setArgsKernelAddressGRAPHBLOXHostToDeviceBuffersPerKernel();
}

void GRAPHBLOXxrtBufferHandlePerKernel::startGRAPHBLOXCtrlChain() {
  graphBloxHandle->runKernelHandle.start();
}

void GRAPHBLOXxrtBufferHandlePerKernel::waitGRAPHBLOXCtrlChain() {
  graphBloxHandle->runKernelHandle.wait();
}

void GRAPHBLOXxrtBufferHandlePerKernel::releaseGRAPHBLOXCtrlChain() {
  // Close an opened device
  //  xrtKernelClose(graphBloxHandle->kernelHandle);
  //  xrtDeviceClose(graphBloxHandle->deviceHandle);
}

// ********************************************************************************************
// ***************                  GRAPHBLOX Control multithreaded **************
// ********************************************************************************************

// // kernel running thread
// void executeGraphBloxThread(xrt::run runGraphBloxKernel,
// GRAPHBLOXxrtBufferHandlePerKernel *graphBloxGraphCSRxrtBufferHandlePerKernel)
// {
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_0_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[0]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_1_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[1]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_2_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[2]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_3_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[3]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_4_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[4]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_5_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[5]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_6_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[6]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_7_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[7]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_8_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[8]);
//     runGraphBloxKernel.set_arg(ADDR_BUFFER_9_ID,
//     graphBloxGraphCSRxrtBufferHandlePerKernel->xrt_buffer_object[9]);
//     runGraphBloxKernel.start();
//     runGraphBloxKernel.wait();
// }

// void executeGraphBloxMultiThreaded(xrtGRAPHBLOXHandle *graphBloxHandle,
// GRAPHBLOXxrtBufferHandlePerKernel *graphBloxGraphCSRxrtBufferHandlePerKernel)
// {
//     std::vector<xrt::run> runGraphBloxKernels;
//     std::vector<std::thread> t(thread_num);

//     for (int i = 0; i < thread_num; i++)
//     {
//         runGraphBloxKernels.push_back(xrt::run(graphBloxHandle->kernelHandle));
//     }

//     int residue = groups_num % thread_num;
//     int i, k;
//     for (k = 0; k < groups_num / thread_num; k++)
//     {
//         for (i = 0; i < thread_num; i++)
//         {
//             t[i] = std::thread(executeGraphBloxThread, runGraphBloxKernels[i],
//             graphBloxGraphCSRxrtBufferHandlePerKernel);
//         }
//         for (i = 0; i < thread_num; i++)
//         {
//             t[i].join();
//         }
//     }
//     for (i = 0; i < residue; i++)
//     {
//         //runGraphBloxKernels[i].set_arg(krnl_cbc_arg_SRC_ADDR, input_sub_buffer[k
//         * thread_num + i]);   // use sub-buffer for source pointer argument
//         //runGraphBloxKernels[i].set_arg(krnl_cbc_arg_DEST_ADDR,
//         output_sub_buffer[k * thread_num + i]); // use sub-buffer for source
//         pointer argument t[i] = std::thread(executeGraphBloxThread,
//         runGraphBloxKernels[i], graphBloxGraphCSRxrtBufferHandlePerKernel);
//     }
//     for (i = 0; i < residue; i++)
//     {
//         t[i].join();
//     }

// }59a5b4f4da507000 61040f3ff1241000