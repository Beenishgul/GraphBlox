#ifndef GLAYENV_H
#define GLAYENV_H

#include <bitset>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>

// XRT includes
#include "experimental/xrt_bo.h"
#include "experimental/xrt_device.h"
#include "experimental/xrt_kernel.h"
#include <experimental/xrt_ip.h>
#include <experimental/xrt_xclbin.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "graphCSR.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#ifdef __cplusplus
}
#endif

#define DEBUG_LOG 1

#ifdef DEBUG_LOG
#define DEBUG_PRINT(...) printf(__VA_ARGS__)
#else
#define DEBUG_PRINT(...) (void)0
#endif

// ********************************************************************************************
// ***************                      XRT Device Management **************
// ********************************************************************************************
struct __attribute__((__packed__)) GraphAuxiliary {
  uint32_t num_auxiliary_1;
  uint32_t num_auxiliary_2;
  //---------------------------------------------------
  void *auxiliary_1;
  void *auxiliary_2;
};

class xrtGLAYHandle {
public:
  bool endian_read;
  bool endian_write;
  bool flush_enable;
  int cacheSize;
  int ctrlMode;
  int numThreads;
  int overlay_algorithm;
  int overlay_program_entries;
  int cu_id;
  std::string kernelName;
  std::string kernelNameFull;
  std::string overlayPath;
  std::string xclbinPath;
  std::vector<uint32_t> overlay_program;
  std::vector<xrt::xclbin::ip> cuHandles;
  unsigned int deviceIndex;
  xrt::device deviceHandle;
  xrt::ip ipHandle;
  xrt::kernel kernelHandle;
  xrt::run runKernelHandle;
  xrt::uuid xclbinUUID;
  xrt::xclbin xclbinHandle;
  xrt::xclbin::mem mem_used;
  // xrt::ip::interrupt interruptHandle;

  // Constructor to initialize the device with arguments
  xrtGLAYHandle(struct Arguments *arguments);
  // Destructor to clean up resources if necessary
  ~xrtGLAYHandle() {
    // Implement any necessary cleanup
  }
  void setupGLAYDevice();
  void readGLAYDeviceEntriesFromFile();
  void printGLAYDevice() const;
  // Other methods as necessary for device interaction
};
// ********************************************************************************************
// ***************                      XRT Buffer Management **************
// ********************************************************************************************
class GLAYxrtBufferHandlePerKernel {
public:
  // User Managed Kernel MASK
  const uint32_t CONTROL_OFFSET = 0x00;
  const uint32_t CONTROL_START = 0x01;
  const uint32_t CONTROL_DONE = 0x02;
  const uint32_t CONTROL_IDLE = 0x04;
  const uint32_t CONTROL_READY = 0x08;
  const uint32_t CONTROL_CONTINUE = 0x10;
  static const int MAX_XRT_BUFFERS =
      32; // Adjust this to your maximum expected number of buffers
  static const int MAX_CUS =
      32; // Adjust this to your maximum expected number of buffers
          // Now we convert the parameters to C++ constants
  uint32_t system_cache_num_ways;
  uint32_t system_cache_data_width;
  uint32_t system_cache_size;

  uint32_t system_cache_line_size_log;
  uint32_t system_cache_num_sets;
  uint32_t system_cache_count;

  // Each Memory bank contains a Graph CSR segment
  bool endian;
  int overlay_program_entries;
  int xrt_buffers_num = 10;
  size_t xrt_buffer_size[10];
  std::bitset<MAX_XRT_BUFFERS> xrt_buffer_sync;
  std::bitset<MAX_CUS> cu_vector;
  uint32_t *overlay_program;
  uint64_t xrt_buffer_device[10];
  void *xrt_buffer_host[10];
  void *xrt_buffer_map[10];
  xrt::bo xrt_buffer_object[10];
  xrtGLAYHandle *glayHandle;

  GLAYxrtBufferHandlePerKernel() : overlay_program(nullptr) {}
  ~GLAYxrtBufferHandlePerKernel() {
    if (overlay_program) {
      free(overlay_program); // Use free for memory allocated with aligned_alloc
    }
    delete glayHandle;
    glayHandle = nullptr; // Good practice to avoid dangling pointer
  }

  GLAYxrtBufferHandlePerKernel(struct Arguments *arguments,
                               struct GraphCSR *graph,
                               struct GraphAuxiliary *graphAuxiliary);
  int writeGLAYHostToDeviceBuffersPerKernel();
  int mapGLAYHostToDeviceBuffersPerKernel();
  int readGLAYDeviceToHostBuffersPerKernel();
  int writeRegistersAddressGLAYHostToDeviceBuffersPerKernel();
  int setArgsKernelAddressGLAYHostToDeviceBuffersPerKernel();
  void initializeGLAYOverlayConfiguration(struct GraphCSR *graph);
  void printGLAYxrtBufferHandlePerKernel();
  void assignGraphtoXRTBufferHost(struct GraphCSR *graph,
                                  struct GraphAuxiliary *graphAuxiliary);
  void assignGraphtoXRTBufferSize(struct GraphCSR *graph,
                                  struct GraphAuxiliary *graphAuxiliary);
  void prinGraphtoXRTBufferSize() const;
  void SetSyncBuffersBasedOnString(const std::string &syncPattern);

  void mapGLAYOverlayProgramBuffersBFS(struct GraphCSR *graph);
  void mapGLAYOverlayProgramBuffersPR(struct GraphCSR *graph);
  void mapGLAYOverlayProgramBuffersTC(struct GraphCSR *graph);
  void mapGLAYOverlayProgramBuffersSPMV(struct GraphCSR *graph);
  void mapGLAYOverlayProgramBuffersCC(struct GraphCSR *graph);

  // ********************************************************************************************
  // ***************                  GLAY Control **************
  // ********************************************************************************************
  void setupGLAY();
  void startGLAY();
  void waitGLAY();
  void releaseGLAY();

  // ********************************************************************************************
  // ***************                  GLAY Control USER_MANAGED **************
  // ********************************************************************************************
  void setupGLAYUserManaged();
  void startGLAYUserManaged();
  void waitGLAYUserManaged();
  void releaseGLAYUserManaged();

  // ********************************************************************************************
  // ***************                  GLAY Control AP_CTRL_HS **************
  // ********************************************************************************************
  void setupGLAYCtrlHs();
  void startGLAYCtrlHs();
  void waitGLAYCtrlHs();
  void releaseGLAYCtrlHs();

  // ********************************************************************************************
  // ***************                  GLAY Control AP_CTRL_CHAIN **************
  // ********************************************************************************************
  void setupGLAYCtrlChain();
  void startGLAYCtrlChain();
  void waitGLAYCtrlChain();
  void releaseGLAYCtrlChain();
};

#endif
