// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1.2 (64-bit)
// Tool Version Limit: 2022.04
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xglay_kernel.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XGlay_kernel_CfgInitialize(XGlay_kernel *InstancePtr, XGlay_kernel_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XGlay_kernel_Start(XGlay_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XGlay_kernel_IsDone(XGlay_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XGlay_kernel_IsIdle(XGlay_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XGlay_kernel_IsReady(XGlay_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XGlay_kernel_Continue(XGlay_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL, Data | 0x10);
}

void XGlay_kernel_EnableAutoRestart(XGlay_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XGlay_kernel_DisableAutoRestart(XGlay_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AP_CTRL, 0);
}

void XGlay_kernel_Set_graph_csr_struct(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_GRAPH_CSR_STRUCT_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_GRAPH_CSR_STRUCT_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_graph_csr_struct(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_GRAPH_CSR_STRUCT_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_GRAPH_CSR_STRUCT_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_vertex_out_degree(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_OUT_DEGREE_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_OUT_DEGREE_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_vertex_out_degree(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_OUT_DEGREE_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_OUT_DEGREE_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_vertex_in_degree(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_IN_DEGREE_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_IN_DEGREE_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_vertex_in_degree(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_IN_DEGREE_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_IN_DEGREE_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_vertex_edges_idx(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_EDGES_IDX_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_EDGES_IDX_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_vertex_edges_idx(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_EDGES_IDX_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_VERTEX_EDGES_IDX_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_edges_array_weight(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_WEIGHT_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_WEIGHT_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_edges_array_weight(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_WEIGHT_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_WEIGHT_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_edges_array_src(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_SRC_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_SRC_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_edges_array_src(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_SRC_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_SRC_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_edges_array_dest(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_DEST_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_DEST_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_edges_array_dest(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_DEST_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_EDGES_ARRAY_DEST_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_auxiliary_1(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_1_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_1_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_auxiliary_1(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_1_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_1_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_Set_auxiliary_2(XGlay_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_2_DATA, (u32)(Data));
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_2_DATA + 4, (u32)(Data >> 32));
}

u64 XGlay_kernel_Get_auxiliary_2(XGlay_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_2_DATA);
    Data += (u64)XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_AUXILIARY_2_DATA + 4) << 32;
    return Data;
}

void XGlay_kernel_InterruptGlobalEnable(XGlay_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_GIE, 1);
}

void XGlay_kernel_InterruptGlobalDisable(XGlay_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_GIE, 0);
}

void XGlay_kernel_InterruptEnable(XGlay_kernel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_IER);
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_IER, Register | Mask);
}

void XGlay_kernel_InterruptDisable(XGlay_kernel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_IER);
    XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_IER, Register & (~Mask));
}

void XGlay_kernel_InterruptClear(XGlay_kernel *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    //XGlay_kernel_WriteReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_ISR, Mask);
}

u32 XGlay_kernel_InterruptGetEnabled(XGlay_kernel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_IER);
}

u32 XGlay_kernel_InterruptGetStatus(XGlay_kernel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    // Current Interrupt Clear Behavior is Clear on Read(COR).
    return XGlay_kernel_ReadReg(InstancePtr->Control_BaseAddress, XGLAY_KERNEL_CONTROL_ADDR_ISR);
}

