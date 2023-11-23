#!make
# =========================================================
# STEP 1. Scripts/VIPs/Directories generation 
# =========================================================
.PHONY: gen-vip
gen-vip:
	-@$(MAKE) gen-vip $(MAKE_DEVICE)

.PHONY: gen-utils-dir
gen-utils-dir: 
	-@$(MAKE) gen-utils-dir $(MAKE_DEVICE)

.PHONY: gen-ip-dir
gen-ip-dir: 
	-@$(MAKE) gen-ip-dir $(MAKE_DEVICE)

.PHONY: clean-vip
clean-vip:
	-@$(MAKE) clean-vip $(MAKE_DEVICE)

.PHONY: clean-utils-dir
clean-utils-dir:
	-@$(MAKE) clean-utils-dir $(MAKE_DEVICE)

.PHONY: clean-ip-dir
clean-ip-dir: 
	-@$(MAKE) clean-ip-dir $(MAKE_DEVICE)

# =========================================================

# =========================================================
# STEP 1.a Run Hardware Simulation  
# =========================================================
.PHONY: run-sim
run-sim:
	-@$(MAKE) run-sim $(MAKE_DEVICE)

.PHONY: run-sim-gui
run-sim-gui:
	-@$(MAKE) run-sim-gui $(MAKE_DEVICE)

.PHONY: run-sim-noclean
run-sim-noclean:
	-@$(MAKE) run-sim-noclean $(MAKE_DEVICE)

.PHONY: run-sim-reset
run-sim-reset:
	-@$(MAKE) run-sim-reset $(MAKE_DEVICE)

.PHONY: run-sim-wave
run-sim-wave:
	-@$(MAKE) run-sim-wave $(MAKE_DEVICE)

.PHONY: run-sim-help
run-sim-help:
	-@$(MAKE) run-sim-help $(MAKE_DEVICE)

.PHONY: clean-sim
clean-sim:
	-@$(MAKE) clean-sim $(MAKE_DEVICE)

# =========================================================
# STEP 2.b Package Generation  
# =========================================================
.PHONY: package-kernel
package-kernel:
	-@$(MAKE) package-kernel $(MAKE_DEVICE)

.PHONY: clean-package-kernel
clean-package-kernel:
	-@$(MAKE) clean-package-kernel $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 2.b.1 VIVADO Project Mode
# =========================================================
.PHONY: run-sim-project
run-sim-project:
	-@$(MAKE) run-sim-project $(MAKE_DEVICE)

.PHONY: run-synth-project
run-synth-project:
	-@$(MAKE) run-synth-project $(MAKE_DEVICE)

.PHONY: run-impl-project
run-impl-project:
	-@$(MAKE) run-impl-project $(MAKE_DEVICE)

.PHONY: run-report-project
run-report-project:
	-@$(MAKE) run-report-project $(MAKE_DEVICE)

.PHONY: open-vivado-project
open-vivado-project:
	-@$(MAKE) open-vivado-project $(MAKE_DEVICE)

.PHONY: clean-vivado-project
clean-vivado-project:
	-@$(MAKE) clean-vivado-project $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 3.a XCLBIN File Generation
# =========================================================
.PHONY: build-hw
build-hw:
	-@$(MAKE) build-hw $(MAKE_DEVICE)

.PHONY: watch-build-hw
watch-build-hw:
	-@$(MAKE) watch-build-hw $(MAKE_DEVICE)

.PHONY: clean-build-hw
clean-build-hw:
	-@$(MAKE) clean-build-hw $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 3.b Application Executable File Generation
# =========================================================
.PHONY: gen-host-bin
gen-host-bin: 
	-@$(MAKE) gen-host-bin $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 3.c Export/Import vitis to vivado flow
# =========================================================
.PHONY: export-hw
export-hw:
	-@$(MAKE) export-hw $(MAKE_DEVICE)

.PHONY: clean-export-hw
clean-export-hw:
	-@$(MAKE) clean-export-hw $(MAKE_DEVICE)
# =========================================================
.PHONY: import-hw
import-hw:
	-@$(MAKE) import-hw $(MAKE_DEVICE)

.PHONY: clean-import-hw
clean-import-hw:
	-@$(MAKE) clean-import-hw $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 4.a Run Hardware Emulation  
# =========================================================
.PHONY: run-emu
run-emu:
	-@$(MAKE) run-emu $(MAKE_DEVICE)

.PHONY: run-emu-debug
run-emu-debug:
	-@$(MAKE) run-emu-debug $(MAKE_DEVICE)

.PHONY: run-emu-wave
run-emu-wave:
	-@$(MAKE) run-emu-wave $(MAKE_DEVICE)

.PHONY: clean-run-emu
clean-run-emu:
	-@$(MAKE) clean-run-emu $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 4.b Run Hardware FPGA
# =========================================================
.PHONY: run-fpga
run-fpga:
	-@$(MAKE) run-fpga $(MAKE_DEVICE)

.PHONY: run-fpga-debug
run-fpga-debug:
	-@$(MAKE) run-fpga-debug $(MAKE_DEVICE)

.PHONY: clean-run-fpga
clean-run-fpga:
	-@$(MAKE) clean-run-fpga $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 5.a Open Project in Vivado GUI
# =========================================================
.PHONY: run-vpp-sim-project
run-vpp-sim-project:
	@$(MAKE) run-vpp-sim-project $(MAKE_DEVICE)

.PHONY: run-vpp-synth-project
run-vpp-synth-project:
	@$(MAKE) run-vpp-synth-project $(MAKE_DEVICE)

.PHONY: run-vpp-impl-project
run-vpp-impl-project:
	@$(MAKE) run-vpp-impl-project $(MAKE_DEVICE)

.PHONY: run-vpp-report-project
run-vpp-report-project:
	@$(MAKE) run-vpp-report-project $(MAKE_DEVICE)

.PHONY: open-vpp-vivado-project
open-vpp-vivado-project:
	@$(MAKE) open-vpp-vivado-project $(MAKE_DEVICE)

.PHONY: clean-vpp-vivado-project
clean-vpp-vivado-project:
	@$(MAKE) clean-vpp-vivado-project $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 5.b VITIS Flow: Open Project
# =========================================================
.PHONY: open-vitis-project
open-vitis-project:
	@$(MAKE) open-vitis-project $(MAKE_DEVICE)

.PHONY: clean-vitis-project
clean-vitis-project:
	@$(MAKE) clean-vitis-project $(MAKE_DEVICE)
# =========================================================

# =========================================================
# STEP 5.b Report Utilization Metrics
# =========================================================
# If the target is HW, this generates the power and resource
# utilization metrics.
# =========================================================
.PHONY: report-metrics
report-metrics: 
	-@$(MAKE) report-metrics $(MAKE_DEVICE)

.PHONY: clean-report-metrics
clean-report-metrics: 
	-@$(MAKE) clean-report-metrics $(MAKE_DEVICE)

# =========================================================
# =========================================================
# SWEEP GENERATION of XCLBIN Images based on architecture paramters
# =========================================================
# # Parameters for different algorithm configurations
# algorithms = [
#     # Format: (Algorithm Index, Architecture, Capability, Number of Kernels, Target)
#     (0, "GLay", "Single", 8, "hw"),
#     (1, "GLay", "Single", 8, "hw"),
#     (5, "GLay", "Single", 8, "hw"),
#     (6, "GLay", "Single", 8, "hw"),
#     (8, "GLay", "Single", 8, "hw"),
#     (0, "GLay", "Lite", 4, "hw"),
#     (0, "GLay", "Full", 2, "hw"),
#     # Add more tuples here for other algorithm configurations as needed
# ]
# =========================================================
.PHONY: run-sweep-xclbin
run-sweep-xclbin:
	-@$(MAKE) run-sweep-xclbin $(MAKE_DEVICE)
