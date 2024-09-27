#!/usr/bin/env python

import pandas as pd
import numpy as np
import argparse
import re
import json

def display_unmapped_mpareads(infofiles):

    # Initialize dict for general stats table
    mqc_gs_data = {
        "id": "metaphlan4_gs",
        "plot_type": "generalstats",
        "pconfig": {
            "identified_reads": {
                "title": "% Reads w/ Taxonomy",
                "namespace": "metaphlan4",
                "description": "% Reads with assigned taxonomy by metaphlan4",
                "max": 100,
                "min": 0,
                "scale": "RdYlGn",
                "format": "{:.2f}%"
            }
        },
        "data": { }
    }

    mpa_readstats = pd.DataFrame()

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
        mqc_gs_data["data"][samplename] = { "identified_reads": float(reads_aligned)/int(reads_processed)*100 }

    mpa_readstats_json = mpa_readstats.to_json(orient="index")
    mpa_readstats_parsed = json.loads(mpa_readstats_json)

    description = "The following bargraph provides the number of reads in each sample that Metaphlan4 was able to align to the Metaphlan microbiomics reference database mpa_vOct22_CHOCOPhlAnSGB_202212. Unmapped reads are those that did not match with the database. Please refer to plots in sections below for detailed compositions of other microbes."
    mpa_readstats_multiqc = {
        'id' : 'mpa_readstats',
        'section_name' : 'Number of Metaphlan Aligned Reads',
        'description' : description,
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
    with open('mpa_readstats_gs_mqc.json', 'w') as ofh:
        json.dump(mqc_gs_data, ofh, indent=4)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""display unaligned/aligned read statistics""")
    parser.add_argument("-i", "--infotext", dest="infofiles", nargs='+', type=str, help="file containing all paths for mpa read statistics")
    args = parser.parse_args()
    display_unmapped_mpareads(args.infofiles)
