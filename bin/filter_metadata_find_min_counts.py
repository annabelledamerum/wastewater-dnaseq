#!/usr/bin/env python

import argparse
import pandas as pd

def filter_metadata(metadata, counts, output):
    # input_metadata file is a TSV file with two columns 
    # it can have duplicates because multiple sequencing runs for one sample
    input_metadata = pd.read_csv(metadata, sep="\t").drop_duplicates()
    # counts table has an extra comment line at the top
    # use first column as index
    data = pd.read_csv(counts, sep="\t", skiprows=1, index_col=0)
    # only keep samples that are in the counts file
    input_metadata = input_metadata.loc[input_metadata["sampleid"].isin(data.columns),]
    # if there is at least one group with replicates and two groups in total,
    # and more than 3 samples, continue with group analysis
    if ( (input_metadata.groupby("group")["sampleid"].nunique()>1).any() and 
         input_metadata["group"].nunique() > 1 and 
         len(input_metadata) > 3 ):
        input_metadata.to_csv(output, sep="\t", index=False)

def get_min_total_counts(counts):
    # counts table has an extra comment line at the top
    # use first column as index
    data = pd.read_csv(counts, sep="\t", skiprows=1, index_col=0)
    # output to STDOUT
    print(data.sum().min(), end="")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="""Filter metadata(group) file and get a min total read count among samples""")
    parser.add_argument("-m", "--metadata", dest="metadata", type=str, required=True, help="Input metadata TSV file")
    parser.add_argument("-c", "--counts", dest="counts", type=str, required=True, 
                        help="Filtered absolute counts file from Qiime export")
    parser.add_argument("-o", "--output", dest="output", default="filtered_metadata.tsv",
                        help="Output metadata file name")
    args = parser.parse_args()
    filter_metadata(args.metadata, args.counts, args.output)
    get_min_total_counts(args.counts)
