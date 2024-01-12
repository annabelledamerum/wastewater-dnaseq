#!/usr/bin/env python

import pandas as pd
import numpy as np
import argparse
import re
import json

def normalize_amr(rawcounts, flagstats):
    #totalcountstable is intended to hold the # of properly paired reads per sample
    totalcountstable = pd.DataFrame()
    for sample in flagstats:
         samplename = re.sub("_flagstat.txt", "", sample)
         with open(sample, "r") as sampleinfo:
             infotext = sampleinfo.read()
             #extract # of properly paired reads from FASTQ samtools flagstat file
             flagstat_total = re.search("(\d+) \+ \d+ in total", infotext)
             flagstat_secondary = re.search("(\d+) \+ \d+ secondary", infotext)
             flagstat_supplementary = re.search("(\d+) \+ \d+ supplementary", infotext)
             total_num = int(flagstat_total.group(1))
             secondary_num = int(flagstat_secondary.group(1))
             supplementary_num = int(flagstat_supplementary.group(1))
             total_reads = (total_num - secondary_num - supplementary_num)
             totalcountstable.insert(len(totalcountstable.columns), samplename, [total_reads])

    totalcountstable = totalcountstable.reindex(sorted(totalcountstable.columns), axis=1)
    for cat_type in rawcounts:
        #get category name [class, mechanism, gene]
        cat_name = re.sub("_rawcounts_AMR_analytic_matrix.csv", "", cat_type)
        count_df = pd.read_csv(cat_type, index_col = "gene_accession")
        count_df = count_df.reindex(sorted(count_df.columns), axis=1)
        #for each sample in count_df, scale to 1 million reads
        for sample in count_df.columns:
            count_df[sample] = (count_df[sample]/totalcountstable.loc[0,sample])*1000000
        count_df.to_csv(cat_name+"_normalized_AMR_analytic_matrix.csv")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""display unaligned/aligned read statistics""")
    parser.add_argument("-r", "--rawcounts", dest="rawcounts", nargs='+', type=str, help="string containing file titles for AMR Count statistics")
    parser.add_argument("-f", "--flagstats", dest="flagstats", nargs='+', type=str, help="samtools flagstat on BAM files to get properly paired # of total reads")
    args = parser.parse_args()
    normalize_amr(args.rawcounts, args.flagstats)
