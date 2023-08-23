#!/usr/bin/env python
import re
import numpy as np
import pandas as pd
import sys
import argparse

condition = sys.argv[1]
pcoa      = sys.argv[2]

def alpha_diversity_plot(pcoa, condition, metadata):
    metadata = pd.read_csv(metadata, sep="\t")
    samplenames = metadata[["sampleid"]].iloc[:,0]
    clean_pcoa = ""
    with open(pcoa, "r") as pcoafile:
        for line in pcoafile:
            for searchterm in samplenames:
                if(re.search(searchterm,line)):
                    clean_pcoa=clean_pcoa+line
    with open(condition+".tsv", "w+") as fn:
        fn.write(clean_pcoa)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--pcoa", "-p", type=str, help="Input PCOA file")
    parser.add_argument("--condition", "-c", type=str, help="jaccard or bray curtis beta diversity pcoa")
    parser.add_argument("--metadata", "-m", type=str, help="Metadata")
    args = parser.parse_args()
    alpha_diversity_plot(args.pcoa, args.condition, args.metadata)

