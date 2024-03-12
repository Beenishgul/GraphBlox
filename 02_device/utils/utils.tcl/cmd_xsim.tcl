#!/usr/bin/tclsh
#
# Copyright 2021 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
add_wave {{//pfm_top_wrapper/pfm_top_i/pfm_dynamic_inst/glay_kernel_1/inst/inst_kernel_afu/inst_kernel_cu}}
# add_wave {{/pfm_top_wrapper/pfm_top_i/pfm_dynamic_inst/glay_kernel_1}} 
log_wave -r *
run all
exit