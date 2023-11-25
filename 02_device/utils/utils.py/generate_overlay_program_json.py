import json

# JSON data
data = """
{
    "ENGINE_ALU_OPS_0": {
        "type_ALU_operation": {
            "ALU_NOP": 1,
            "ALU_ADD": 2,
            "ALU_SUB": 4,
            "ALU_MUL": 8,
            "ALU_ACC": 16,
            "ALU_DIV": 32
        },
        "entries": {
            "entry_0": {
                "alu_operation": {
                    "bits": "6",
                    "value": "ALU_ACC"
                }
            },
            "entry_1": {
                "alu_mask": {
                    "bits": "4",
                    "value": "0x0"
                },
                "id_engine": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_module": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_2": {
                "const_mask": {
                    "bits": "4",
                    "value": "0x1"
                }
            },
            "entry_3": {
                "const_value": {
                    "bits": "32",
                    "value": "0x00000001"
                }
            },
            "entry_4": {
                "ops_mask": {
                    "bits": "16",
                    "value": "0x8421"
                }
            },
            "entry_5": {
                "id_cu": {
                    "bits": "8",
                    "value": "0x01"
                },
                "id_bundle": {
                    "bits": "8",
                    "value": "0x02"
                },
                "id_lane": {
                    "bits": "8",
                    "value": "0x04"
                },
                "id_buffer": {
                    "bits": "8",
                    "value": "0x00"
                }
            }
        }
    },
    "ENGINE_CSR_INDEX_1": {
        "type_memory_cmd": {
            "CMD_INVALID": 1,
            "CMD_MEM_READ": 2,
            "CMD_MEM_WRITE": 4,
            "CMD_MEM_RESPONSE": 8,
            "CMD_MEM_CONFIGURE": 16,
            "CMD_ENGINE": 32,
            "CMD_CONTROL": 64
        },
        "type_data_buffer": {
            "STRUCT_INVALID": 1,
            "STRUCT_CU_DATA": 2,
            "STRUCT_ENGINE_DATA": 4,
            "STRUCT_CU_SETUP": 8,
            "STRUCT_ENGINE_SETUP": 16,
            "STRUCT_CU_FLUSH": 32
        },
        "entries": {
            "entry_0": {
                "increment": {
                    "bits": "1",
                    "value": "1"
                },
                "decrement": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_sequence": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_buffer": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_break": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_1": {
                "index_start": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_2": {
                "index_end": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_3": {
                "stride": {
                    "bits": "32",
                    "value": "0x00000001"
                }
            },
            "entry_4": {
                "granularity": {
                    "bits": "4",
                    "value": "0"
                },
                "direction": {
                    "bits": "1",
                    "value": "0"
                },
                "shift.amount": {
                    "bits": "4",
                    "value": "0"
                },
                "shift.direction": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_5": {
                "cmd": {
                    "bits": "7",
                    "value": "CMD_MEM_READ"
                },
                "buffer": {
                    "bits": "6",
                    "value": "STRUCT_ENGINE_DATA"
                },
                "id_module": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_engine": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_6": {
                "id_cu": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_bundle": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_lane": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_buffer": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_7": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_8": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_9": {
                "array_size": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            }
        }
    },
    "ENGINE_FORWARD_DATA_2": {
        "entries": {
            "entry_0": {
                "hops": {
                    "bits": "4",
                    "value": "0x0"
                }
            }
        }
    },
    "ENGINE_READ_WRITE_3": {
        "type_memory_cmd": {
            "CMD_INVALID": 1,
            "CMD_MEM_READ": 2,
            "CMD_MEM_WRITE": 4,
            "CMD_MEM_RESPONSE": 8,
            "CMD_MEM_CONFIGURE": 16,
            "CMD_ENGINE": 32,
            "CMD_CONTROL": 64
        },
        "type_data_buffer": {
            "STRUCT_INVALID": 1,
            "STRUCT_CU_DATA": 2,
            "STRUCT_ENGINE_DATA": 4,
            "STRUCT_CU_SETUP": 8,
            "STRUCT_ENGINE_SETUP": 16,
            "STRUCT_CU_FLUSH": 32
        },
        "entries": {
            "entry_0": {
                "increment": {
                    "bits": "1",
                    "value": "0"
                },
                "decrement": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_sequence": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_buffer": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_break": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_1": {
                "index_start": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_2": {
                "index_end": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_3": {
                "stride": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_4": {
                "granularity": {
                    "bits": "4",
                    "value": "0"
                },
                "direction": {
                    "bits": "1",
                    "value": "0"
                },
                "shift.amount": {
                    "bits": "4",
                    "value": "0"
                },
                "shift.direction": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_5": {
                "cmd": {
                    "bits": "7",
                    "value": "CMD_INVALID"
                },
                "buffer": {
                    "bits": "6",
                    "value": "STRUCT_INVALID"
                },
                "id_module": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_engine": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_6": {
                "id_cu": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_bundle": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_lane": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_buffer": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_7": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_8": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_9": {
                "array_size": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_10": {
                "const_mask": {
                    "bits": "4",
                    "value": "0x0"
                }
            },
            "entry_11": {
                "const_value": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_12": {
                "ops_mask": {
                    "bits": "16",
                    "value": "0x00"
                }
            }
        }
    },
    "ENGINE_MERGE_DATA_4": {
        "entries": {
            "entry_0": {
                "merge_mask": {
                    "bits": "4",
                    "value": "0x0"
                }
            },
            "entry_1": {
                "merge_type": {
                    "bits": "4",
                    "value": "0x0"
                }
            }
        }
    },
    "ENGINE_READ_WRITE_5": {
        "type_memory_cmd": {
            "CMD_INVALID": 1,
            "CMD_MEM_READ": 2,
            "CMD_MEM_WRITE": 4,
            "CMD_MEM_RESPONSE": 8,
            "CMD_MEM_CONFIGURE": 16,
            "CMD_ENGINE": 32,
            "CMD_CONTROL": 64
        },
        "type_data_buffer": {
            "STRUCT_INVALID": 1,
            "STRUCT_CU_DATA": 2,
            "STRUCT_ENGINE_DATA": 4,
            "STRUCT_CU_SETUP": 8,
            "STRUCT_ENGINE_SETUP": 16,
            "STRUCT_CU_FLUSH": 32
        },
        "entries": {
            "entry_0": {
                "increment": {
                    "bits": "1",
                    "value": "0"
                },
                "decrement": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_sequence": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_buffer": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_break": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_1": {
                "index_start": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_2": {
                "index_end": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_3": {
                "stride": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_4": {
                "granularity": {
                    "bits": "4",
                    "value": "0"
                },
                "direction": {
                    "bits": "1",
                    "value": "0"
                },
                "shift.amount": {
                    "bits": "4",
                    "value": "0"
                },
                "shift.direction": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_5": {
                "cmd": {
                    "bits": "7",
                    "value": "CMD_INVALID"
                },
                "buffer": {
                    "bits": "6",
                    "value": "STRUCT_INVALID"
                },
                "id_module": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_engine": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_6": {
                "id_cu": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_bundle": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_lane": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_buffer": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_7": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_8": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_9": {
                "array_size": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_10": {
                "const_mask": {
                    "bits": "4",
                    "value": "0x0"
                }
            },
            "entry_11": {
                "const_value": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_12": {
                "ops_mask": {
                    "bits": "16",
                    "value": "0x00"
                }
            }
        }
    },
    "ENGINE_READ_WRITE_6": {
        "type_memory_cmd": {
            "CMD_INVALID": 1,
            "CMD_MEM_READ": 2,
            "CMD_MEM_WRITE": 4,
            "CMD_MEM_RESPONSE": 8,
            "CMD_MEM_CONFIGURE": 16,
            "CMD_ENGINE": 32,
            "CMD_CONTROL": 64
        },
        "type_data_buffer": {
            "STRUCT_INVALID": 1,
            "STRUCT_CU_DATA": 2,
            "STRUCT_ENGINE_DATA": 4,
            "STRUCT_CU_SETUP": 8,
            "STRUCT_ENGINE_SETUP": 16,
            "STRUCT_CU_FLUSH": 32
        },
        "entries": {
            "entry_0": {
                "increment": {
                    "bits": "1",
                    "value": "0"
                },
                "decrement": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_sequence": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_buffer": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_break": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_1": {
                "index_start": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_2": {
                "index_end": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_3": {
                "stride": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_4": {
                "granularity": {
                    "bits": "4",
                    "value": "0"
                },
                "direction": {
                    "bits": "1",
                    "value": "0"
                },
                "shift.amount": {
                    "bits": "4",
                    "value": "0"
                },
                "shift.direction": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_5": {
                "cmd": {
                    "bits": "7",
                    "value": "CMD_INVALID"
                },
                "buffer": {
                    "bits": "6",
                    "value": "STRUCT_INVALID"
                },
                "id_module": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_engine": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_6": {
                "id_cu": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_bundle": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_lane": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_buffer": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_7": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_8": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_9": {
                "array_size": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_10": {
                "const_mask": {
                    "bits": "4",
                    "value": "0x0"
                }
            },
            "entry_11": {
                "const_value": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_12": {
                "ops_mask": {
                    "bits": "16",
                    "value": "0x00"
                }
            }
        }
    },
    "ENGINE_FORWARD_DATA_7": {
        "entries": {
            "entry_0": {
                "hops": {
                    "bits": "4",
                    "value": "0x0"
                }
            }
        }
    },
    "ENGINE_CSR_INDEX_8": {
        "type_memory_cmd": {
            "CMD_INVALID": 1,
            "CMD_MEM_READ": 2,
            "CMD_MEM_WRITE": 4,
            "CMD_MEM_RESPONSE": 8,
            "CMD_MEM_CONFIGURE": 16,
            "CMD_ENGINE": 32,
            "CMD_CONTROL": 64
        },
        "type_data_buffer": {
            "STRUCT_INVALID": 1,
            "STRUCT_CU_DATA": 2,
            "STRUCT_ENGINE_DATA": 4,
            "STRUCT_CU_SETUP": 8,
            "STRUCT_ENGINE_SETUP": 16,
            "STRUCT_CU_FLUSH": 32
        },
        "entries": {
            "entry_0": {
                "increment": {
                    "bits": "1",
                    "value": "0"
                },
                "decrement": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_sequence": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_buffer": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_break": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_1": {
                "index_start": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_2": {
                "index_end": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_3": {
                "stride": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_4": {
                "granularity": {
                    "bits": "4",
                    "value": "0"
                },
                "direction": {
                    "bits": "1",
                    "value": "0"
                },
                "shift.amount": {
                    "bits": "4",
                    "value": "0"
                },
                "shift.direction": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_5": {
                "cmd": {
                    "bits": "7",
                    "value": "CMD_INVALID"
                },
                "buffer": {
                    "bits": "6",
                    "value": "STRUCT_INVALID"
                },
                "id_module": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_engine": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_6": {
                "id_cu": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_bundle": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_lane": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_buffer": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_7": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_8": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_9": {
                "array_size": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            }
        }
    },
    "ENGINE_FORWARD_DATA_9": {
        "entries": {
            "entry_0": {
                "hops": {
                    "bits": "4",
                    "value": "0x0"
                }
            }
        }
    },
    "ENGINE_READ_WRITE_10": {
        "type_memory_cmd": {
            "CMD_INVALID": 1,
            "CMD_MEM_READ": 2,
            "CMD_MEM_WRITE": 4,
            "CMD_MEM_RESPONSE": 8,
            "CMD_MEM_CONFIGURE": 16,
            "CMD_ENGINE": 32,
            "CMD_CONTROL": 64
        },
        "type_data_buffer": {
            "STRUCT_INVALID": 1,
            "STRUCT_CU_DATA": 2,
            "STRUCT_ENGINE_DATA": 4,
            "STRUCT_CU_SETUP": 8,
            "STRUCT_ENGINE_SETUP": 16,
            "STRUCT_CU_FLUSH": 32
        },
        "entries": {
            "entry_0": {
                "increment": {
                    "bits": "1",
                    "value": "0"
                },
                "decrement": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_sequence": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_buffer": {
                    "bits": "1",
                    "value": "0"
                },
                "mode_break": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_1": {
                "index_start": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_2": {
                "index_end": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_3": {
                "stride": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_4": {
                "granularity": {
                    "bits": "4",
                    "value": "0"
                },
                "direction": {
                    "bits": "1",
                    "value": "0"
                },
                "shift.amount": {
                    "bits": "4",
                    "value": "0"
                },
                "shift.direction": {
                    "bits": "1",
                    "value": "0"
                }
            },
            "entry_5": {
                "cmd": {
                    "bits": "7",
                    "value": "CMD_INVALID"
                },
                "buffer": {
                    "bits": "6",
                    "value": "STRUCT_INVALID"
                },
                "id_module": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_engine": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_6": {
                "id_cu": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_bundle": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_lane": {
                    "bits": "8",
                    "value": "0x00"
                },
                "id_buffer": {
                    "bits": "8",
                    "value": "0x00"
                }
            },
            "entry_7": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_8": {
                "array_pointer": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_9": {
                "array_size": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_10": {
                "const_mask": {
                    "bits": "4",
                    "value": "0x0"
                }
            },
            "entry_11": {
                "const_value": {
                    "bits": "32",
                    "value": "0x00000000"
                }
            },
            "entry_12": {
                "ops_mask": {
                    "bits": "16",
                    "value": "0x00"
                }
            }
        }
    },
    "ENGINE_FORWARD_DATA_11": {
        "entries": {
            "entry_0": {
                "hops": {
                    "bits": "4",
                    "value": "0x0"
                }
            }
        }
    }
}
    """


# Function to parse and construct the entries with compact comments
def parse_entries(data):
    parsed_data = json.loads(data)

    for engine_name, engine_data in parsed_data.items():
        entries = engine_data["entries"]
        # Print engine name and number of entries
        print(f"// --------------------------------------------------------------------------------------")
        print(f"// Engine: {engine_name}, Number of entries: {len(entries)}")
        print(f"// --------------------------------------------------------------------------------------")
        lookup_tables = {**engine_data.get('type_memory_cmd', {}), **engine_data.get('type_data_buffer', {}), **engine_data.get('type_ALU_operation', {})}

        for key in entries:
            entry = entries[key]
            entry_value = 0

            bits_prev = 0
            comment_details = []  # List to store details for the comment

            # Start from LSB to MSB
            for param in entry:
                bits = int(entry[param]["bits"])
                value = entry[param]["value"]
                original_value = value
                original_flag = 0

                # Replace symbolic values with their corresponding numeric values
                if isinstance(value, str):
                    original_flag = 1
                    value = lookup_tables.get(value, value)
                
                # Convert to integer
                if isinstance(value, str) and value.startswith("0x"):
                    value = int(value, 16)
                else:
                    value = int(value)

                # Shift and OR the value
                value <<= bits_prev
                entry_value |= value

                # Calculate the bit range and format the value for the current parameter
                bit_range = f"{bits_prev}:{bits_prev + bits - 1}"
                if original_flag :
                    formatted_value = original_value
                else :
                    formatted_value = f"0x{value >> bits_prev}"  # Short hex value

                if bits == 1 and isinstance(formatted_value, int):
                    formatted_value = "True" if formatted_value == 1 else "False"

                comment_details.append(f"{param}[{bit_range}]={formatted_value}")
                bits_prev += bits

            # Convert to hexadecimal format
            entry_hex = f"0x{entry_value:08X}"
            # Create the compact comment
            comment = f" // {key:10} <{bits_prev:2}b>: " + " || ".join(comment_details)
            print(f"{entry_hex}{comment}")
    print(f"// --------------------------------------------------------------------------------------")

# Call the function with the JSON data
parse_entries(data)