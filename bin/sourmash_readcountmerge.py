#!/usr/bin/env python
import pandas as pd
import argparse
import json

def sourmash_readcountmerge( readcounts ):
    #total read count for each sample must be formatted into a dataframe to be accepted by qiime_datamerge step
    allsamplereadcount = dict()
    for filename in readcounts:
        with open(filename) as fh:
            data = json.load(fh)
            # Grab the data from the mqc json file generated in previous step
            for k,v in data["data"].items():
                allsamplereadcount[k] = v["Microbes"]

    # Output to csv
    data = pd.Series(allsamplereadcount, name="aligned")
    data.to_csv("allsamples_totalreads.csv")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Merge together all total assigned read counts for each sample""")
    parser.add_argument(dest="readcounts", nargs="+", type=str, help="list of sample readcounts, in mqc json format")
    args = parser.parse_args()
    sourmash_readcountmerge( args.readcounts )
