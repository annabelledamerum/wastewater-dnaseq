#!/usr/bin/env python

import os
import sys
import argparse
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Collect command-line arguments
if len(sys.argv) < 3:
    print("Usage: python pathogen_metrics.py <metrics_directory> <metadata_file>")
    sys.exit(1)

# Function to load and process individual CSV files
def coverage_csv(file):
    file_name = os.path.splitext(os.path.basename(file))[0]  # Extract file name without extension
    data = pd.read_csv(file)  # Load the CSV file

    # Rename 'recalc_coverage' column to the file name
    if 'recalc_coverage' in data.columns:
        data = data.rename(columns={'recalc_coverage': file_name})

    # Select relevant columns to keep
    columns_to_drop = [
        'startpos', 'endpos', 'numreads', 'covbases', 'coverage', 
        'meandepth', 'meanbaseq', 'meanmapq', 'genus', 'species', 
        'display_name', 'fasta_id'
    ]
    data = data.drop(columns=[col for col in columns_to_drop if col in data.columns])
    data.set_index('assembly_accession', inplace=True)

    return data

# Function to merge coverage metrics into single dataframe and combine with genome assembly metadata
def combine_coverage(metrics_directory, input_metadata):
    # Load metadata and remove duplicates
    metadata = pd.read_csv(input_metadata, sep='\t').drop_duplicates(subset='assembly_accession')
    # Get list of CSV files from the specified directory
    file_paths = [os.path.join(metrics_directory, f) for f in os.listdir(metrics_directory) if f.endswith(".csv")]
    # Load and process all CSV files into a list of DataFrames
    data_list = [coverage_csv(file) for file in file_paths]
    # Merge all DataFrames on 'assembly_accession'
    coverage_data = pd.concat(data_list, axis=1, ignore_index=False)
    # Merge with metadata
    coverage_metadata = pd.merge(coverage_data, metadata, on='assembly_accession', how='inner')
    # Save the merged data to a CSV file
    coverage_metadata.to_csv("coverage.csv", index=False)
    return coverage_metadata

def plot_coverage_heatmap(data):
    # Prepare data for heatmap
    data = data.drop(columns=[
        'assembly_accession', 'accession', 'scaffold_size', 'genus', 
        'species', 'fasta_id', 'organism_name'
    ])
    # Set 'display_name' as the index for better plotting
    data = data.set_index('display_name')

    # Drop any non-numeric columns like 'Unnamed: 0' (used only as an index in the original file)
    data = data.drop(columns=['Unnamed: 0'], errors='ignore')

    # Create a custom colormap according to the defined rules
    def get_color(value):
        if value < 1:
            return "#bdbdbd"  # Gray
        elif 1 <= value <= 5:
            return "#e4a742"  # Gold
        else:
            return "#8b0000"  # Dark Red

    # Convert the dataframe to the appropriate format for heatmap plotting
    fig, ax = plt.subplots(figsize=(12, 10))

    # Use seaborn heatmap for layout, but we'll overlay values and control colors manually
    sns.heatmap(data, annot=True, fmt=".1f", cmap="coolwarm", cbar=False, ax=ax,
                annot_kws={"size": 10}, linewidths=0.5, linecolor='black')

    # Manually adjust the colors based on our criteria
    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            value = data.iloc[i, j]
            ax.add_patch(plt.Rectangle((j, i), 1, 1, fill=True, color=get_color(value)))

    # Adjust the plot to display x-axis labels at the top
    ax.xaxis.set_ticks_position('top')
    ax.xaxis.set_label_position('top')

    # Set labels and title
    ax.set_xlabel("Sample", fontsize=14)
    ax.set_ylabel("Organism", fontsize=14)
    ax.set_title("Coverage Heatmap", fontsize=18)

    # Create a custom legend for the three coverage ranges
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor="#bdbdbd", label="<1%"),
        Patch(facecolor="#e4a742", label="1-5%"),
        Patch(facecolor="#8b0000", label=">5%")
    ]
    ax.legend(handles=legend_elements, title="Coverage Range", loc='upper center', 
              bbox_to_anchor=(0.5, -0.1), ncol=3, frameon=True)

    # Adjust layout to avoid overlap
    plt.tight_layout(rect=[0, 0.05, 1, 1])

    # Save the plot as a PNG file
    plt.savefig("coverage_heatmap.png", dpi=300, bbox_inches='tight')

    # Close the plot to free memory
    plt.close()

def main():
    # Set up argparse to receive inputs from the command line
    parser = argparse.ArgumentParser(description="Merge coverage files and plot heatmap.")
    parser.add_argument("--coverage_directory", required=True, help="Directory containing .coverage files")
    parser.add_argument("--metadata_file", required=True, help="Path to the genome metadata file")

    args = parser.parse_args()

    # Merge coverage files and prepare for plotting
    coverage_data = combine_coverage(args.coverage_directory, args.metadata_file)
    # Plot the heatmap
    heatmap = plot_coverage_heatmap(coverage_data)

if __name__ == "__main__":
    main()