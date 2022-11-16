// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1.2 (64-bit)
// Tool Version Limit: 2022.04
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xglay_kernel.h"

extern XGlay_kernel_Config XGlay_kernel_ConfigTable[];

XGlay_kernel_Config *XGlay_kernel_LookupConfig(u16 DeviceId) {
	XGlay_kernel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XGLAY_KERNEL_NUM_INSTANCES; Index++) {
		if (XGlay_kernel_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XGlay_kernel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XGlay_kernel_Initialize(XGlay_kernel *InstancePtr, u16 DeviceId) {
	XGlay_kernel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XGlay_kernel_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XGlay_kernel_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

