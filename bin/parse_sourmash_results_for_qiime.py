#!/usr/bin/env python

import argparse
import pandas as pd
import re
import json

def parse_sourmash(sourmash_results, sketch_log, name, filter_fp, host_lineage):
    # Get sample name if not specified
    if not name:
        name = sourmash_results.replace('.with-lineages.csv','')

    # Initialize dict for multiqc output
    mqc_data = {
        "id": "kmer_composition",
        "section_name": "Kmer composition (sourmash)",
        "description": ("This plots depict the the composition of kmers identified (or not) by "
                        "<a href='https://github.com/sourmash-bio/sourmash'>sourmash</a>. "
                        "It includes percentages of kmers that were identified as common host organisms, "
                        "common eukaryotic pathogens/parasites, and other microbes. Unidentified kmers "
                        "are those do not have match with the database or those with a match but fail to reach "
                        "the base-pair threshold set during the sourmash step of the pipeline. Please refer to "
                        "plots in sections below for detailed compositions of other microbes."),
        "plot_type": "bargraph",
        "anchor": "sourmash_kmer_composition",
        "pconfig": {
            "id": "kmer_composition_bargraph",
            "title": "Kmer composition (sourmash)",
            "ylab": "Percent of all Kmers",
            "cpswitch": False
        },
        "yCeiling": 100,
        "data": { name : dict() }
    }

    # Read the sketch log to get number of sequences
    pattern = r"calculated \d+ signature for (\d+) sequences taken from \d+ files"
    with open(sketch_log) as fh:
        t = fh.read()
        m = re.search(pattern, t)
        if m:
            readcount = int(m.group(1)) 
        else:
            raise Exception("Failed to parse sourmash sketch log to get number of reads!")
    
    # Read gather results
    profile = pd.read_csv(sourmash_results)

    # Filter false positives if requested
    if filter_fp:
        profile = profile[(profile["match_containment_ani"] >= 0.935) | (profile["unique_intersect_bp"] > 1000000)]

    # Calculate total percentages of microbes and unidenfied kmers
    mqc_data["data"][name]["Microbes"] = profile["f_unique_weighted"].sum()*100
    mqc_data["data"][name]["Unidentified"] = 100 - mqc_data["data"]["Microbes"]

    # Read host lineage file to get a list of host genome accessions and species names
    if host_lineage:
        host_info = pd.read_csv(host_lineage)
        host_info = host_info[["ident","species"]]
        # Extract accession number from subject names in the gather results
        profile["accession"] = profile["name"].map(lambda x:x.split()[0])
        # Separate host and other matches
        host = profile.loc[profile["accession"].isin(host_info["ident"])]
        profile = profile.loc[~profile["accession"].isin(host_info["ident"])]
        mqc_data["data"][name]["Microbes"] = profile["f_unique_weighted"].sum()*100
        # Add the species name to the host profile
        host = host[["accession","f_unique_weighted"]]
        host = pd.merge(host, host_info, left_on="accession", right_on="ident", how="left")
        # Record the percentages of each host organism
        mqc_data["data"][name].update(host.set_index("species")["f_unique_weighted"].mul(100).to_dict())

    profile = profile[["lineage","f_unique_weighted"]]
    profile = profile.rename(columns={'f_unique_weighted':name})
    # Collapsing rows together in case of duplicate clade name
    profile = profile.groupby('lineage').sum()
    profile.to_csv(name+'_relabun_parsed_mpaprofile.txt', sep="\t")
    
    # Calculate absolute abundance (approximate)
    profile = profile.mul(readcount)
    profile.to_csv(name+'_absabun_parsed_mpaprofile.txt', sep="\t")

    # Create a taxonomy file
    profile['Taxon'] = profile.index.str.replace(";", "|", regex=False)
    profile = profile.drop(name, axis=1)
    profile.index.name = 'Feature ID'
    profile.to_csv(name+"_profile_taxonomy.txt", sep="\t")

    # Output mqc results
    with open(name+"_sourmash_stats_mqc.json", "w") as fh:
        json.dump(mqc_data, fh, indent=4)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Parse sourmash gather results to be compatible with Qiime for taxonomy analysis""")
    parser.add_argument("sourmash_results", type=str, help="Sourmash results after gather & tax annotate")
    parser.add_argument("-l", "--sketch_log", dest="sketch_log", type=str, required=True, help="Sourmash sketch log")
    parser.add_argument("-n", "--name", dest="name", type=str, help="Sample name")
    parser.add_argument("-f", "--filter_false_positive", dest="filter_fp", action="store_true", help="Whether to filter potentially false positive results, empirically")
    parser.add_argument("--host_lineage", dest="host_lineage", type=str, help="Host/pathogen lineage file")
    args = parser.parse_args()
    parse_sourmash(args.sourmash_results, args.sketch_log, args.name, args.filter_fp, args.host_lineage)
