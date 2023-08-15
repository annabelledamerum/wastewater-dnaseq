#!/usr/bin/env python

import argparse
import pandas as pd

def filter_metadata_find_min(metadata, counts, output):
    # input_metadata file is a TSV file with two columns 
    # it can have duplicates because multiple sequencing runs for one sample
    input_metadata = pd.read_csv(metadata, sep="\t").drop_duplicates()
    # counts table has an extra comment line at the top
    # use first column as index
    data = pd.read_csv(counts, sep="\t", skiprows=1, index_col=0)
    # only keep samples that are in the counts file
    input_metadata = input_metadata.loc[input_metadata["sampleid"].isin(data.columns),]
    # get the number of replicates per group
    replication = input_metadata.groupby("group")["sampleid"].nunique()
    replication.name = "replicates"
    input_metadata = input_metadata.merge(replication, on="group")
    # drop samples without replicates
    input_metadata = input_metadata.loc[input_metadata["replicates"]>1,]
    # if there are at least two groups left, continue with group analysis
    if input_metadata["group"].nunique() > 1:
        input_metadata = input_metadata.drop("replicates", axis=1)
        input_metadata.to_csv(output, sep="\t", index=False)

    # filter singleton samples from counts table as well
    data = data.loc[:, data.columns.isin(input_metadata["sampleid"])]
    # output the min total count to STDOUT
    print(data.sum().min().astype(int), end="")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="""Filter metadata(group) file and get a min total read count among samples""")
    parser.add_argument("-m", "--metadata", dest="metadata", type=str, required=True, help="Input metadata TSV file")
    parser.add_argument("-c", "--counts", dest="counts", type=str, required=True, 
                        help="Filtered absolute counts file from Qiime export")
    parser.add_argument("-o", "--output", dest="output", default="filtered_metadata.tsv",
                        help="Output metadata file name")
    args = parser.parse_args()
    filter_metadata_find_min(args.metadata, args.counts, args.output)
