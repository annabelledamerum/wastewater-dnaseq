#!/usr/bin/env python
import re
import numpy as np
import pandas as pd
import argparse

def sourmash_readcountmerge( readcount )
#total read count for each sample must be formatted into a dataframe to be accepted by qiime_datamerge step
    allsamplereadcount = pd.DataFrame()

    readcount = readcount.split(" ")
    for sample in readcount:
        prefix = re.sub("_sketchfq_readcount.txt", "", sample)
        with open(sample, "r") as samplereadcount:
            readcount = int(samplereadcount.read())
            samplereadcount = pd.DataFrame([[readcount]], index = [prefix], columns = ["aligned"])
        allsamplereadcount = pd.concat([allsamplereadcount, samplereadcount], axis = 0)

    allsamplereadcount["aligned"].to_csv("allsamples_totalreads.csv")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Merge together all total read counts for each sample""")
    parser.add_argument("-r", "--readcount_totals", dest="readcount", type=str, help="list of sample readcounts")
    args = parser.parse_args()
    sourmash_readcountmerge( args.readcount )
