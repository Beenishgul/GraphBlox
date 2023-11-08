import re
import sys

def process_file(filename):
    # Define the size of a cache line in bytes and the size of each entry
    CACHE_LINE_SIZE = 64
    ENTRY_SIZE = 4  # Assuming 4 bytes per entry
    entries_per_cache_line = CACHE_LINE_SIZE // ENTRY_SIZE

    def calculate_cache_info(entry_index, entries_per_line):
        cache_line_index = entry_index // entries_per_line
        entry_offset = entry_index % entries_per_line
        return cache_line_index, entry_offset

    # Read the file and process entries and comments
    with open(filename, 'r') as file:
        entries = []
        entry_index = 0
        for line in file:
            line = line.strip()  # Strip the leading and trailing whitespaces

            # Check if the line is a hex entry with optional comment
            hex_match = re.search(r'(0x[0-9A-Fa-f]+)(.*)', line)
            if hex_match:
                hex_value = hex_match.group(1)
                comment = hex_match.group(2).strip()  # Remove leading/trailing whitespace from comment
                cache_line, offset = calculate_cache_info(entry_index, entries_per_cache_line)
                print(f"Entry {hex_value} (Index {entry_index}): Cache Line Index = {cache_line}, Entry Offset = {offset}, Comment: {comment}")
                entry_index += 1
            elif line.startswith('//'):  # This is a comment line
                print(line)  # Print the comment line as is

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)

    filename = sys.argv[1]
    process_file(filename)
