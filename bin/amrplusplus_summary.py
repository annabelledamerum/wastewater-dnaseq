#!/usr/bin/env python

import pandas as pd
import numpy as np
import argparse
import re
import json
import matplotlib.pyplot as plt
import seaborn as sns

def normalize_amr(rawcounts, flagstats):
    totalcountstable = pd.DataFrame()
    for sample in flagstats:
        samplename = re.sub("_flagstat.txt", "", sample)
        with open(sample, "r") as sampleinfo:
            infotext = sampleinfo.read()
            flagstat_total = re.search(r"(\d+) \+ \d+ in total", infotext)
            flagstat_secondary = re.search(r"(\d+) \+ \d+ secondary", infotext)
            flagstat_supplementary = re.search(r"(\d+) \+ \d+ supplementary", infotext)
            total_num = int(flagstat_total.group(1))
            secondary_num = int(flagstat_secondary.group(1))
            supplementary_num = int(flagstat_supplementary.group(1))
            total_reads = (total_num - secondary_num - supplementary_num)
            totalcountstable.insert(len(totalcountstable.columns), samplename, [total_reads])

    totalcountstable = totalcountstable.reindex(sorted(totalcountstable.columns), axis=1)

    for cat_type in rawcounts:
        cat_name = re.sub("_SNPconfirmed_analytic_matrix.csv", "", cat_type)
        count_df = pd.read_csv(cat_type, index_col="gene_accession")
        count_df = count_df.reindex(sorted(count_df.columns), axis=1)
        for sample in count_df.columns:
            count_df[sample] = (count_df[sample] / totalcountstable.loc[0, sample]) * 1_000_000
        count_df.to_csv(cat_name + "_SNPconfirmed_normalized_AMR_analytic_matrix.csv")
    return count_df

def summarize_amr(amr_metadata, amr_counts):
    merged_df = pd.merge(amr_counts, amr_metadata, on="gene_accession", how="left")
    merged_df.to_csv("./genes_SNPconfirmed_normalized_AMR_analytic_matrix_wMetadata.csv", index=False)

    if 'Multi-compound' in merged_df['type'].unique():
        filtered_df = merged_df[
            (merged_df['type'] == 'Drugs') |
            ((merged_df['type'] == 'Multi-compound') & 
             (merged_df['class'].str.contains('Drug', case=False, na=False)))
        ]
    else:
        filtered_df = merged_df[merged_df['type'] == 'Drugs']
    # Identify sample columns (assuming they start from the second column of the original AMR matrix)
    sample_columns = amr_metadata.columns[1:]
    # Filter out rows where all sample columns have zero counts
    filtered_df = filtered_df[(filtered_df[sample_columns] != 0).any(axis=1)]

    pivot_table = filtered_df.pivot_table(
        index=['class', 'enhanced_subclass'],
        values=amr_counts.columns[1:], 
        aggfunc='sum',
        fill_value=0
    )
    pivot_table.to_csv("./AMR_matrix_pivot.csv")

    num_rows = pivot_table.shape[0]
    plt.figure(figsize=(20, min(10 + num_rows * 0.2, 100)))
    sns.heatmap(pivot_table, cmap="YlGnBu", linewidths=0.5, linecolor='black', annot=True, fmt='.1f', cbar=True)
    plt.title('AMR Heatmap')
    plt.xlabel('Samples')
    plt.gca().xaxis.set_label_position('top')
    plt.gca().xaxis.tick_top()
    plt.ylabel('Antibiotic Class')
    plt.savefig("./amr_heatmap.png", bbox_inches='tight')
    plt.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Display unaligned/aligned read statistics")
    parser.add_argument("-c", "--amr_counts", dest="amr_counts", nargs='+', type=str, help="AMR Count statistics files")
    parser.add_argument("-f", "--flagstats", dest="flagstats", nargs='+', type=str, help="Samtools flagstat files")
    parser.add_argument("-m", "--amr_metadata", dest="amr_metadata", type=str, help="AMR gene database metadata file")

    args = parser.parse_args()
    amr_counts_df = normalize_amr(args.amr_counts, args.flagstats)
    amr_metadata_df = pd.read_csv(args.amr_metadata)
    summarize_amr(amr_metadata_df, amr_counts_df)
