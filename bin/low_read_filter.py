#!/usr/bin/env python
import re
import numpy as np
import pandas as pd
import argparse

def qiime_taxmerge(qza, readcount, lowread_filter):
    totalreads = pd.read_csv(readcount, index_col=0)
    exclude = totalreads[totalreads["aligned"] < lowread_filter].index
    for i in exclude:
        qza = re.sub(i+"_qiime_absfreq_table.qza", "", qza)
    subset_num = totalreads[totalreads["aligned"] >= lowread_filter]["aligned"].min()
    with open('qza_lowqualityfiltered.txt', 'w+') as fn:
        fn.write(qza)
    with open('readcount_maxsubset.txt', 'w+') as fn:
        fn.write(str(subset_num))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Merge together all taxonomy file output""")
    parser.add_argument("-q", "--qza_files", dest="qza", type=str, help="list of qza files")
    parser.add_argument("-r", "--readcount_totals", dest="readcount", type=str, help="list of sample readcounts")
    parser.add_argument("-f", "--filter", dest="lowread_filter", type=int, help="samples lower than this user provided read count will be cut")
    args = parser.parse_args()
    qiime_taxmerge(args.qza, args.readcount, args.lowread_filter)
