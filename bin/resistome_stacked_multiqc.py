#!/usr/bin/env python

import argparse
import pandas as pd
import re
import json

def parse_resistome(resistome_results):
    resistome_mqc = {
        "id": "resistome_class_composition",
        "section_name": "Resistome composition (AMRplusplus)",
        "description": ("This plot depicts the composition of classes identified (or not) by "
            "<a href='https://github.com/Microbial-Ecology-Group/AMRplusplus/tree/master'>AMRplusplus</a>. "
            "It includes counts of anti-microbial resistant classes detected in each shotgun sample. "
            "Class categories in AMR are comprised from collections of  read counts matching antimicrobial resistance genes "
            "For gene level data, please refer to downloadable table gene_AMR_analytic_matrix for detailed compositions of other microbes. "
            "Percentages in this stacked bargraph represent the share of antimicrobial genes for a certain class over the " 
            "total number of antimicrobial counts detected in the entire sample"),
        "plot_type": "bargraph",
        "anchor": "resistome_amr_composition",
        "pconfig": {
            "id": "resistome_composition_bargraph",
            "title": "AMR Class composition (AMRplusplus)",
            "cpswitch_c_active": True,
            "cpswitch_counts_label": "Read counts (Estimated)",
            "cpswitch_percent_label": "Relative percentage"
            }
    }

    resistome = pd.read_csv(resistome_results, index_col=0)
    resistome["mean"] = resistome.mean(axis=1)
    resistome = resistome.sort_values(by=["mean"], ascending = False)
    resistome = resistome.drop(columns = ['mean'])
    resistome_json = resistome.to_json()
    resistome_parsed = json.loads(resistome_json)

    resistome_mqc["data"] = resistome_parsed
    with open('class_resistomechart_mqc.json', 'w') as ofh:
        json.dump(resistome_mqc, ofh, indent=4)
    
if __name__ == "__main__":
    parser=argparse.ArgumentParser(description="""Parse sourmash gather results to be compatible with Qiime for taxonomy analysis""")
    parser.add_argument("resistome_results", type=str, help="Resistome results on the class level")
    args = parser.parse_args()
    parse_resistome(args.resistome_results)
