#!/usr/bin/env python

import argparse
import pandas as pd

def filter_metadata_find_min(metadata, counts, output, ref_comp_output):
    # input_metadata file is a TSV file with two columns 
    # it can have duplicates because multiple sequencing runs for one sample
    input_metadata = pd.read_csv(metadata, sep="\t").drop_duplicates()
    # counts table has an extra comment line at the top
    # use first column as index
    data = pd.read_csv(counts, sep="\t", skiprows=1, index_col=0)
    # only keep samples that are in the counts file
    input_metadata = input_metadata.loc[input_metadata["sampleid"].isin(data.columns),]
    # When group labels are not provided, just use "user-samples" as group label for reference data comparisons
    if input_metadata["group"].isna().any():
        # require at least 2 samples
        if len(input_metadata) > 1:
            input_metadata["group"] = "user-samples"
            input_metadata.to_csv(ref_comp_output, sep="\t", index=False)
    else:
        # get the number of replicates per group
        replication = input_metadata.groupby("group")["sampleid"].nunique()
        replication.name = "replicates"
        input_metadata = input_metadata.merge(replication, on="group")
        if (input_metadata["replicates"]>1).any():
            # drop samples without replicates
            input_metadata = input_metadata.loc[input_metadata["replicates"]>1,]
            # Regardless of how many groups left, continue with reference dataset comparisons
            input_metadata = input_metadata.drop("replicates", axis=1)
            input_metadata.to_csv(ref_comp_output, sep="\t", index=False)
            # if there are at least two groups left, continue with group analysis
            if input_metadata["group"].nunique() > 1:
                input_metadata.to_csv(output, sep="\t", index=False)
        else:
            # If there are no replicates, just use "user-samples" as group label for reference data comparisons
            # require at least 2 samples
            if len(input_metadata) > 1:
                input_metadata["group"] = "user-samples"
                input_metadata = input_metadata.drop("replicates", axis=1)
                input_metadata.to_csv(ref_comp_output, sep="\t", index=False)

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
    parser.add_argument("-r", "--ref_comp_output", dest="ref_comp_output", default="ref_comp_metadata.tsv",
                        help="Output metadata file name for reference dataset comparison")
    args = parser.parse_args()
    filter_metadata_find_min(args.metadata, args.counts, args.output, args.ref_comp_output)
