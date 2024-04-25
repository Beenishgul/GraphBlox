import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import gmean

# Algorithms to compare
algorithms = ['CC', 'PR', 'TC-B', 'BFS-B']
labels = ['SOC', 'OR', 'KR21', 'KR20', 'UK', 'R26']

# Dummy data for Table 1 and Table 2 for demonstration purposes
table_1_data = {
    'SOC': [0.13431, 0.26483, 0.51135, 0.01604],
    'OR': [0.00745, 0.325, 1.1404, 0.1182],
    'KR21': [0.08086, 0.27158, 2.28551, 0.11327],
    'KR20': [0.00423, 0.06932, 0.8411, 0.00238],
    'UK': [0.07629, 0.62953, 2.34965, 0.08619],
    'R26': [1.02241, 4.67799, 1.7731, 0.30173]
}

table_2_data = {
    'SOC': [0.03258, 0.4574325, 1.1086275, 0.0266625],
    'OR': [0.00816, 0.303486, 1.855212, 0.012582],
    'KR21': [0.0102051, 0.1379601, 2.9076681, 0.0056814],
    'KR20': [0.0051584, 0.0662896, 1.189604, 0.0028756],
    'UK': [0.14792, 1.39689, 5.24477, 0.15608],
    'R26': [1.524035, 3.612525, 2.284035, 0.321365]
}

# Calculate speedup/slowdown for each algorithm and dataset
speedup_data_corrected = {alg: [] for alg in algorithms}
for alg_index, alg in enumerate(algorithms):
    for dataset in labels:
        gap_time = table_1_data[dataset][alg_index]
        graphBlox_time = table_2_data[dataset][alg_index]
        speedup_factor = gap_time / graphBlox_time if graphBlox_time != 0 else np.inf
        speedup_data_corrected[alg].append(speedup_factor)

# Calculate the geometric mean for each algorithm's speedup data
gm_speedup_corrected = {alg: gmean(speedup_data_corrected[alg]) for alg in algorithms}

# Create the bar charts with corrected speedup data
fig, axes = plt.subplots(nrows=1, ncols=len(algorithms), figsize=(20, 5), sharey=True)

for i, alg in enumerate(algorithms):
    factors = speedup_data_corrected[alg]
    bar_positions = np.arange(len(labels))
    gm_bar_position = len(labels)  # Position for the geometric mean bar

    # Plot the speedup/slowdown bars
    for j, factor in enumerate(factors):
        color = 'green' if factor > 1 else 'red'
        axes[i].bar(j, factor, color=color, edgecolor='black', linewidth=1)

    # Plot the GM bar, separated by a vertical line
    axes[i].axvline(x=gm_bar_position - 0.5, color='black', linewidth=1, linestyle='--')
    axes[i].bar(gm_bar_position, gm_speedup_corrected[alg], color='orange', edgecolor='black', linewidth=1.5, label='GM')

    # Set plot titles and labels
    axes[i].set_title(f'{alg} Speedup/Slowdown', fontweight='bold')
    axes[i].set_xticks(list(bar_positions) + [gm_bar_position])
    axes[i].set_xticklabels(labels + ['GM'], rotation=45, ha="right")
    axes[i].set_xlabel('Datasets', fontweight='bold')
    axes[i].axhline(y=1, color='black', linewidth=0.5, linestyle='--')

    if i == 0:
        axes[i].set_ylabel('Factor', fontweight='bold')
        axes[i].legend()

# Adjust layout to prevent overlap
plt.tight_layout()

# Save the figure in SVG format
corrected_speedup_svg_filename = './corrected_speedup_slowdown_comparison.svg'
plt.savefig(corrected_speedup_svg_filename,
