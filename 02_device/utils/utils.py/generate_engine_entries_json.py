import re
import json

# Sample text data (replace this with your actual data)
verilog_text = """
            (1 << 0) : begin
                configure_memory_reg.payload.param.increment     <= fifo_response_memory_in_dout_reg.payload.data.field[0][0];
                configure_memory_reg.payload.param.decrement     <= fifo_response_memory_in_dout_reg.payload.data.field[0][1];
                configure_memory_reg.payload.param.mode_sequence <= fifo_response_memory_in_dout_reg.payload.data.field[0][2];
                configure_memory_reg.payload.param.mode_buffer   <= fifo_response_memory_in_dout_reg.payload.data.field[0][3];
                configure_memory_reg.payload.param.mode_counter  <= fifo_response_memory_in_dout_reg.payload.data.field[0][4];
            end
            (1 << 1) : begin
                configure_memory_reg.payload.param.index_start <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 2) : begin
                configure_memory_reg.payload.param.index_end <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 3) : begin
                configure_memory_reg.payload.param.stride <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 4) : begin
                configure_memory_reg.payload.param.granularity            <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-2:0];
                configure_memory_reg.payload.param.direction              <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-1];
                configure_memory_reg.payload.meta.address.shift.amount    <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-2:0];
                configure_memory_reg.payload.meta.address.shift.direction <= fifo_response_memory_in_dout_reg.payload.data.field[0][M_AXI4_FE_DATA_W-1];
            end
            (1 << 5) : begin
                configure_memory_reg.payload.meta.subclass.cmd       <= type_memory_cmd'(fifo_response_memory_in_dout_reg.payload.data.field[0][TYPE_MEMORY_CMD_BITS-1:0]);
                configure_memory_reg.payload.meta.subclass.buffer    <= type_data_buffer'(fifo_response_memory_in_dout_reg.payload.data.field[0][(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS)-1:TYPE_MEMORY_CMD_BITS]);
                configure_memory_reg.payload.meta.route.to.id_module <= fifo_response_memory_in_dout_reg.payload.data.field[0][(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_WIDTH_BITS)-1:(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS)];
                configure_memory_reg.payload.meta.route.to.id_engine <= fifo_response_memory_in_dout_reg.payload.data.field[0][(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_WIDTH_BITS+CU_ENGINE_COUNT_WIDTH_BITS)-1:(TYPE_DATA_STRUCTURE_BITS+TYPE_MEMORY_CMD_BITS+CU_MODULE_COUNT_WIDTH_BITS)];
            end
            (1 << 6) : begin
                configure_memory_reg.payload.meta.route.to.id_cu     <= fifo_response_memory_in_dout_reg.payload.data.field[0][(CU_KERNEL_COUNT_WIDTH_BITS)-1:0];
                configure_memory_reg.payload.meta.route.to.id_bundle <= fifo_response_memory_in_dout_reg.payload.data.field[0][(CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)-1:CU_KERNEL_COUNT_WIDTH_BITS];
                configure_memory_reg.payload.meta.route.to.id_lane   <= fifo_response_memory_in_dout_reg.payload.data.field[0][(CU_LANE_COUNT_WIDTH_BITS+CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)-1:(CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)];
                configure_memory_reg.payload.meta.route.to.id_buffer <= fifo_response_memory_in_dout_reg.payload.data.field[0][(CU_BUFFER_COUNT_WIDTH_BITS+CU_LANE_COUNT_WIDTH_BITS+CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)-1:(CU_LANE_COUNT_WIDTH_BITS+CU_BUNDLE_COUNT_WIDTH_BITS+CU_KERNEL_COUNT_WIDTH_BITS)];
            end
            (1 << 7) : begin
                configure_memory_reg.payload.param.array_pointer[(M_AXI4_FE_DATA_W)-1:0] <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 8) : begin
                configure_memory_reg.payload.param.array_pointer[(M_AXI4_FE_ADDR_W)-1:M_AXI4_FE_DATA_W] <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 9) : begin
                configure_memory_reg.payload.param.array_size <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 10) : begin
                configure_memory_reg.payload.param.const_mask <= fifo_response_memory_in_dout_reg.payload.data.field[0][NUM_FIELDS_MEMORYPACKETDATA-1:0];
            end
            (1 << 11) : begin
                configure_memory_reg.payload.param.const_value <= fifo_response_memory_in_dout_reg.payload.data.field[0];
            end
            (1 << 12) : begin
                configure_memory_reg.payload.param.ops_mask <= fifo_response_memory_in_dout_reg.payload.data.field[0][(NUM_FIELDS_MEMORYPACKETDATA*NUM_FIELDS_MEMORYPACKETDATA)-1:0];
            end
"""

# Dictionary to hold the bit lengths of each parameter
bit_lengths = {
    "CU_KERNEL_COUNT_WIDTH_BITS": 8,  # Replace with actual values
    "CU_BUNDLE_COUNT_WIDTH_BITS": 8,
    "CU_LANE_COUNT_WIDTH_BITS"  : 8,
    "CU_BUFFER_COUNT_WIDTH_BITS": 8,
    "TYPE_MEMORY_CMD_BITS"      : 7,
    "TYPE_FILTER_OPERATION_BITS": 9,
    "TYPE_ALU_OPERATION_BITS"   : 6,
    "TYPE_DATA_STRUCTURE_BITS"  : 6,
    "TYPE_SEQUENCE_STATE_BITS"  : 4,
    "NUM_FIELDS_MEMORYPACKETDATA": 4,
    "M_AXI4_FE_ADDR_W"           : 64,

    # ... other bit length variables ...
}

# Regular expression to match each entry block
entry_pattern = r"\(1 << (\d+)\) : begin(.*?)end"
# Updated regular expression to capture parameter names and bit lengths
# Construct the JSON structure
config_json = {"entries": {}}
for entry_idx, entry_content in re.findall(entry_pattern, verilog_text, re.DOTALL):
    entry_name = f"entry_{entry_idx}"
    config_json["entries"][entry_name] = {}

    # Generic pattern to match parameter names
    param_pattern = r"configure_memory_reg\..+?\.(\w+)(?:\[\w*[-:]*\w*\])? <="

    for param in re.findall(param_pattern, entry_content):
        # Remove array indices and bit range if present
        param = re.sub(r'\[\w*[-:]*\w*\]', '', param)

        config_json["entries"][entry_name][param] = {"value": "0x00", "bits": "0"}  # Placeholder

# Print or save the JSON
json_output = json.dumps(config_json, indent=3)
print(json_output)