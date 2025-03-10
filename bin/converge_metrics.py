#!/usr/bin/env python

import os
import pandas as pd
import argparse

def load_coverage_files(directory):
    """Load all .coverage files from the specified directory into a dictionary."""
    coverage_data = {}
    for filename in os.listdir(directory):
        if filename.endswith(".coverage.txt"):
            filepath = os.path.join(directory, filename)
            print(f"Loading {filename}")  # Debugging print statement
            coverage_data[filename] = pd.read_csv(filepath, sep='\t')
    if not coverage_data:
        raise ValueError("No .coverage files found in the directory.")
    return coverage_data

def clean_column_names(df):
    """Strip leading/trailing spaces from column names."""
    df.columns = df.columns.str.strip()
    return df

def merge_coverage_with_metadata(coverage_data, metadata_file):
    """Merge each coverage file with the metadata file by #rname and accession."""
    metadata = pd.read_csv(metadata_file, sep='\t')
    metadata = clean_column_names(metadata)  # Clean metadata columns
    print(f"Metadata columns: {metadata.columns}")

    merged_data = {}
    for filename, coverage_df in coverage_data.items():
        coverage_df = clean_column_names(coverage_df)  # Clean coverage columns
        print(f"Coverage columns for {filename}: {coverage_df.columns}")
        # Merge on appropriate columns
        merged_df = pd.merge(
            coverage_df, metadata,
            left_on='#rname', right_on='accession', 
            how='inner'
        )
        print(f"{filename} merged: {merged_df.shape[0]} rows")
        if not merged_df.empty:
            merged_data[filename] = merged_df

    if not merged_data:
        raise ValueError("No valid merged data from the .coverage and metadata files.")
    return merged_data

def summarize_by_assembly(merged_data):
    """Summarize data by summing and averaging necessary columns by assembly_accession."""
    summary_data = {}
    for filename, df in merged_data.items():
        summary = df.groupby('assembly_accession').agg({
            #'rname': 'first',
            'startpos': 'mean',
            'endpos': 'sum',
            'numreads': 'sum',
            'covbases': 'sum',
            'coverage': 'mean',
            'meandepth': 'mean',
            'meanbaseq': 'mean',
            'meanmapq': 'mean',
            'genus': 'first',
            'species': 'first',
            'display_name': 'first',
            'fasta_id': 'first',
            #'organism_name ': 'first'
        }).reset_index()
        summary_data[filename] = summary
    return summary_data

def add_recalc_coverage(summarized_data):
    """Add a recalc_coverage column by calculating (covbases / endpos) * 100."""
    for filename, df in summarized_data.items():
        df['recalc_coverage'] = (df['covbases'] / df['endpos']) * 100
        summarized_data[filename] = df
    return summarized_data

def save_dict_to_csv(data_dict, output_dir):
    """
    This function loops through a dictionary where each key corresponds to a filename
    and each value is the data to be converted into a DataFrame. It saves each DataFrame
    as a .csv file with the modified filename.
    
    Parameters:
    data_dict (dict): A dictionary where the key is the intended filename (with `.coverage.txt` suffix),
                      and the value is the data to be turned into a DataFrame (list of dicts or tuples).
    """
    for key, value in data_dict.items():
        # Create a DataFrame from the value
        df = pd.DataFrame(value)

        # Modify the filename by removing '.coverage.txt'
        filename = key.replace('.coverage.txt', '') + '.csv'

        # Construct the full path for the CSV file
        file_path = os.path.join(output_dir, filename)

        # Save the DataFrame as a CSV file
        df.to_csv(file_path, index=False)

        print(f"Saved {file_path}")

def main():
    # Set up argparse to receive inputs from the command line
    parser = argparse.ArgumentParser(description="Process coverage files and merge with metadata.")
    parser.add_argument("--coverage_directory", required=True, help="Directory containing .coverage files")
    parser.add_argument("--metadata_file", required=True, help="Path to the metadata file")
    parser.add_argument("--output_dir", required=True, help="Output directory file path")

    args = parser.parse_args()

    # Load coverage files
    coverage_data = load_coverage_files(args.coverage_directory)

    # Merge coverage with metadata
    merged_data = merge_coverage_with_metadata(coverage_data, args.metadata_file)

    # Group by assembly_accession - for references with >1 scaffold
    summarized_data = summarize_by_assembly(merged_data)

    # Recalculate coverage % after summing assembly scaffolds
    summarized_data_coverage = add_recalc_coverage(summarized_data)

    # Save as CSV dataframe - one per sample
    save_dict_to_csv(summarized_data_coverage, args.output_dir)

    print(f"Coverage data saved to {args.output_dir}")

if __name__ == "__main__":
    main()

