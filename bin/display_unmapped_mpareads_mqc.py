#!/usr/bin/env python

import pandas as pd
import numpy as np
import argparse
import re
import json

def display_unmapped_mpareads(info):
    mpa_readstats = pd.DataFrame()

    with open(info, "r") as infofiles:
        for sample in infofiles:
            sample = re.sub("\n", "", sample)
            samplename = sample
            samplename = re.sub("_infotext.txt", "", sample)
            with open(sample, "r") as sampleinfo:
                infotext = sampleinfo.read()
                reads_processed_search = re.search("#(\d+) reads processed", infotext)
                reads_processed = reads_processed_search.group(1)
                reads_mapped_search = re.search("estimated_reads_mapped_to_known_clades:(\d+)", infotext)
                reads_aligned = reads_mapped_search.group(1)
                reads_unaligned = int(reads_processed) - int(reads_aligned)
            aligned_unaligned = pd.DataFrame([[reads_aligned, reads_unaligned]], index=[samplename], columns=["aligned", "unaligned"])
            mpa_readstats = pd.concat([mpa_readstats, aligned_unaligned], axis = 0)
            mpa_readstats["aligned"].to_csv("allsamples_alignedreads.csv")

        mpa_readstats_json = mpa_readstats.to_json(orient="index")
        mpa_readstats_parsed = json.loads(mpa_readstats_json)

        description = "The following bargraph provides the number of reads in each sample that Metaphlan was able to align to the user-selected microbiomics reference database."
        mpa_readstats_multiqc = {
            'id' : 'mpa_readstats',
            'section_name' : 'Number of Metaphlan Aligned Reads',
            'description' : description,
            'doi' : 'https://www.nature.com/articles/s41587-023-01688-w'
            'plot_type' : 'bargraph',
            'pconfig' : {
                'id' : 'estimated_unaligned_mpareads_plot',
                'title' : 'Reads Unaligned Plot',
                'ylab' : 'Counts'
                },
            'categories' : {
                'aligned' : {
                    'name': 'aligned',
                    'color' : '#3A4BA2'
                    },
                'unaligned' : {
                    'name' : 'unaligned',
                    'color' : '#999999'
                    }
                }
            }

        mpa_readstats_multiqc['data'] = mpa_readstats_parsed
        with open('mpa_readstats_mqc.json', 'w') as ofh:
            json.dump(mpa_readstats_multiqc, ofh, indent=4)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""display unaligned/aligned read statistics""")
    parser.add_argument("-i", "--infotext", dest="info", type=str, help="file containing all paths for mpa read statistics")
    args = parser.parse_args()
    display_unmapped_mpareads(args.info)
