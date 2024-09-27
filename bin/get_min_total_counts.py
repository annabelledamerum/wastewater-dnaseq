#!/usr/bin/env python

import argparse
import pandas as pd

def find_min(counts, output):
    # counts table has an extra comment line at the top
    # use first column as index
    data = pd.read_csv(counts, sep="\t", skiprows=1, index_col=0)
    # output the min total count to file
    with open(output, "w") as fh:
        print(data.sum().min().astype(int), file=fh)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="""Get a min total read count among samples""")
    parser.add_argument("-c", "--counts", dest="counts", type=str, required=True, 
                        help="Filtered absolute counts file from Qiime export")
    parser.add_argument("-o", "--output", dest="output", type=str, default="min_total.txt", 
                        help="Output file name")
    args = parser.parse_args()
    find_min( args.counts, args.output )
