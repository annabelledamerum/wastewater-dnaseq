#!/usr/bin/env python

import argparse
import pandas as pd

def find_min(counts):
    # counts table has an extra comment line at the top
    # use first column as index
    data = pd.read_csv(counts, sep="\t", skiprows=1, index_col=0)
    # output the min total count to STDOUT
    print(data.sum().min().astype(int), end="")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="""Get a min total read count among samples""")
    parser.add_argument("-c", "--counts", dest="counts", type=str, required=True, 
                        help="Filtered absolute counts file from Qiime export")
    args = parser.parse_args()
    find_min( args.counts )
