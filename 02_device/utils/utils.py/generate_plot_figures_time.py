#!/usr/bin/env python3
# Assuming you want to add a new table of data and display each figure side by side for each algorithm
# We will add a third table with dummy data and then plot the figures side by side.

# New dummy data for Table 3
table_3_data = {
    "SOC": [0.05, 0.45, 1.0, 0.02],
    "OR": [0.01, 0.35, 1.8, 0.11],
    "KR21": [0.09, 0.25, 2.3, 0.10],
    "KR20": [0.005, 0.07, 0.85, 0.002],
    "UK": [0.08, 0.65, 2.4, 0.09],
    "R26": [1.0, 4.5, 1.7, 0.3],
}

# Redefine the plot to accommodate the new table
fig, axes = plt.subplots(nrows=1, ncols=len(algorithms), figsize=(20, 5), sharey=True)

# Adjust bar positions to accommodate the new bars
bar_positions_1 = np.arange(len(labels)) * 3.0  # Table 1
bar_positions_2 = [x + bar_width for x in bar_positions_1]  # Table 2
bar_positions_3 = [x + bar_width for x in bar_positions_2]  # Table 3

# Loop through each algorithm to create its bar chart
for i, algorithm in enumerate(algorithms):
    # Extract times for this algorithm from all tables for each dataset
    table_1_algo_times = [table_1_data[dataset][i] for dataset in labels]
    table_2_algo_times = [table_2_data[dataset][i] for dataset in labels]
    table_3_algo_times = [table_3_data[dataset][i] for dataset in labels]

    # Plot bars for each table
    axes[i].bar(
        bar_positions_1,
        table_1_algo_times,
        bar_width,
        alpha=opacity,
        color=colors[0],
        edgecolor="black",
        linewidth=1.5,
        label="Table 1",
    )
    axes[i].bar(
        bar_positions_2,
        table_2_algo_times,
        bar_width,
        alpha=opacity,
        color=colors[1],
        edgecolor="black",
        linewidth=1.5,
        label="Table 2",
    )
    axes[i].bar(
        bar_positions_3,
        table_3_algo_times,
        bar_width,
        alpha=opacity,
        color=colors[2],
        edgecolor="black",
        linewidth=1.5,
        label="Table 3",
    )

    # Set plot titles and labels
    axes[i].set_title(algorithm, fontweight="bold")
    axes[i].set_xticks([r + bar_width for r in range(0, len(labels) * 3, 3)])
    axes[i].set_xticklabels(labels, rotation=45, ha="right")
    axes[i].set_xlabel("Datasets", fontweight="bold")

    # Only add y-axis label to the first subplot for a cleaner look
    if i == 0:
        axes[i].set_ylabel("Time (S)", fontweight="bold")
        axes[i].legend()

# Adjust layout to prevent overlap
plt.tight_layout()

# Save the figure in SVG format
expanded_svg_filename = "/mnt/data/expanded_color_blind_multi_bar_comparison.svg"
plt.savefig(expanded_svg_filename, format="svg")

plt.show()
