import subprocess
import re

# Define the graph suites with their corresponding graph names and file types
graph_suites = {
    "LAW": {
        "graphs": [
            "amazon-2008", "arabic-2005", "cnr-2000", "dblp-2010", "enron", "eu-2005",
            "hollywood-2009", "in-2004", "indochina-2004", "it-2004", "ljournal-2008",
            "sk-2005", "uk-2002", "uk-2005", "webbase-2001"
        ],
        "file_type": "graph.el"
    },
    "SNAP": {
        "graphs": [
            "cit-Patents", "com-Orkut", "soc-LiveJournal1", "soc-Pokec", "web-Google"
        ],
        "file_type": "graph.el"
    },
    "GAP": {
        "graphs": [
            "kron", "road", "twitter", "urand", "web"
        ],
        "file_type": "graph.wel"
    }
}

# Output file to store results
output_file = "graph_statistics.csv"
with open(output_file, 'w') as file:
    file.write("Graph Suite,Graph Name,File Type,Average Degree,Number of Vertices,Number of Edges\n")

    # Loop through each suite, their graphs, and file type
    for suite, details in graph_suites.items():
        graphs = details["graphs"]
        file_type = details["file_type"]
        for graph_name in graphs:
            print(f"Processing {graph_name} in suite {suite} with file type {file_type}...")
            # Run the command including the GRAPH_SUIT parameter
            result = subprocess.run(['make', 'run', f'GRAPH_SUIT={suite}', f'GRAPH_NAME={graph_name}', f'FILE_BIN_TYPE={file_type}'], capture_output=True, text=True)

            # Check for errors
            if result.stderr:
                print(f"Error processing {graph_name}: {result.stderr}")
                continue

            # Use regular expressions to find the needed values
            avg_degree = re.search(r"Average Degree \(D\)\s*\|\s*\n\|\s*(\d+)\s*\|", result.stdout)
            num_vertices = re.search(r"Number of Vertices \(V\)\s*\|\s*\n\|\s*(\d+)\s*\|", result.stdout)
            num_edges = re.search(r"Number of Edges \(E\)\s*\|\s*\n\|\s*(\d+)\s*\|", result.stdout)

            if avg_degree and num_vertices and num_edges:
                # Write the results to the output file
                file.write(f"{suite},{graph_name},{file_type},{avg_degree.group(1)},{num_vertices.group(1)},{num_edges.group(1)}\n")
            else:
                print(f"Failed to extract data for {graph_name}")

print(f"All graphs processed. Results saved in {output_file}.")
