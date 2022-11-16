// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1.2 (64-bit)
// Tool Version Limit: 2022.04
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XGLAY_KERNEL_H
#define XGLAY_KERNEL_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xglay_kernel_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
    u16 DeviceId;
    u64 Control_BaseAddress;
} XGlay_kernel_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XGlay_kernel;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XGlay_kernel_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XGlay_kernel_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XGlay_kernel_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XGlay_kernel_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
int XGlay_kernel_Initialize(XGlay_kernel *InstancePtr, u16 DeviceId);
XGlay_kernel_Config* XGlay_kernel_LookupConfig(u16 DeviceId);
int XGlay_kernel_CfgInitialize(XGlay_kernel *InstancePtr, XGlay_kernel_Config *ConfigPtr);
#else
int XGlay_kernel_Initialize(XGlay_kernel *InstancePtr, const char* InstanceName);
int XGlay_kernel_Release(XGlay_kernel *InstancePtr);
#endif

void XGlay_kernel_Start(XGlay_kernel *InstancePtr);
u32 XGlay_kernel_IsDone(XGlay_kernel *InstancePtr);
u32 XGlay_kernel_IsIdle(XGlay_kernel *InstancePtr);
u32 XGlay_kernel_IsReady(XGlay_kernel *InstancePtr);
void XGlay_kernel_Continue(XGlay_kernel *InstancePtr);
void XGlay_kernel_EnableAutoRestart(XGlay_kernel *InstancePtr);
void XGlay_kernel_DisableAutoRestart(XGlay_kernel *InstancePtr);

void XGlay_kernel_Set_graph_csr_struct(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_graph_csr_struct(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_vertex_out_degree(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_vertex_out_degree(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_vertex_in_degree(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_vertex_in_degree(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_vertex_edges_idx(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_vertex_edges_idx(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_edges_array_weight(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_edges_array_weight(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_edges_array_src(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_edges_array_src(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_edges_array_dest(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_edges_array_dest(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_auxiliary_1(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_auxiliary_1(XGlay_kernel *InstancePtr);
void XGlay_kernel_Set_auxiliary_2(XGlay_kernel *InstancePtr, u64 Data);
u64 XGlay_kernel_Get_auxiliary_2(XGlay_kernel *InstancePtr);

void XGlay_kernel_InterruptGlobalEnable(XGlay_kernel *InstancePtr);
void XGlay_kernel_InterruptGlobalDisable(XGlay_kernel *InstancePtr);
void XGlay_kernel_InterruptEnable(XGlay_kernel *InstancePtr, u32 Mask);
void XGlay_kernel_InterruptDisable(XGlay_kernel *InstancePtr, u32 Mask);
void XGlay_kernel_InterruptClear(XGlay_kernel *InstancePtr, u32 Mask);
u32 XGlay_kernel_InterruptGetEnabled(XGlay_kernel *InstancePtr);
u32 XGlay_kernel_InterruptGetStatus(XGlay_kernel *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
