#!/usr/bin/env python

import argparse
import pandas as pd
import numpy as np
import re

def metaphlan_profileparse( mpa_profiletable, label ):
    
    #Retrieve number of unknown reads
    #Process Metaphlan4 input table
    #For relative abundance: remove all entries that are not on species level
    profile = pd.read_csv(mpa_profiletable, sep="\t")
    relprofile = profile[["clade_name", "relative_abundance"]]
    absprofile = profile[["clade_name", "estimated_number_of_reads_from_the_clade"]]

    profiles = { '_relabun_parsed_mpaprofile.txt' : relprofile,
                 '_absabun_parsed_mpaprofile.txt' : absprofile }

    #For relative counts and absolute counts, clean all entries that are not on the sample level
    for fileaddress, profile in profiles.items():
        profile.columns = ["clade_name",label]
        profile = profile[profile["clade_name"].str.contains("s__") == True]
        profile = profile[profile["clade_name"].str.contains("t__") == False]
        profile.to_csv((label+fileaddress), sep="\t", index=False)

    #Formatting supplemental taxonomy table needed by qiime2
    #Column names MUST be "Feature ID", "Taxon"
    taxonomy = pd.DataFrame(profile["clade_name"].str.replace("|", ";", regex=False))
    taxonomy = pd.concat((profile["clade_name"], taxonomy), axis=1)
    taxonomy.columns = ["Feature ID", "Taxon"]
    taxonomy.to_csv(label+"_profile_taxonomy.txt", sep="\t", index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""Parse metaphlan table""")
    parser.add_argument("-t", "--mpa_table", dest="mpa_profiletable", type=str, help="metaphlan assigned reads")
    parser.add_argument("-l", "--label", dest="label", type=str, help="sample label")
    args = parser.parse_args()
    metaphlan_profileparse(args.mpa_profiletable, args.label)
