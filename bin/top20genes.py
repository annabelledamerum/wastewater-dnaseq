#!/usr/bin/env python
import argparse
import pandas as pd
import re
import json
from collections import defaultdict
import seaborn as sns
import random

def top20genes(resistome_results):
    genelevel_resistome_mqc = {
        "id": "top20_genes_composition",
        "section_name": "Top 20 Genes Composition of Each Sample (AMRplusplus)",
        "description": ("This plot depicts the composition of genes identified by "
            "<a href='https://github.com/Microbial-Ecology-Group/AMRplusplus/tree/master'>AMRplusplus</a>. "
            "It includes counts of anti-microbial resistant genes detected in each shotgun sample. "
            "The top 20 mean percentage genes among all samples are demarcated by different colored bars. All other genes are labeled as 'Other' ."
            ),
        "plot_type": "bargraph",
        "anchor": "top20genes_amr_composition",
        "pconfig": {
            "id": "top20genes_composition_bargraph",
            "title": "AMR Top 20 Gene composition (AMRplusplus)",
            "cpswitch_c_active": True,
            "cpswitch_counts_label": "Read counts (Estimated)",
            "cpswitch_percent_label": "Relative percentage"
            }
    }

    AMRgene = pd.read_csv("C:/Users/NSharp/Downloads/genes_AMR_analytic_matrix.csv", index_col=0)
    AMRgene = AMRgene.reindex(sorted(AMRgene.columns), axis=1)
    AMRperc = pd.DataFrame()

    samplecount_columns = AMRgene.columns
    for column in samplecount_columns:
        AMRperc[column] = (AMRgene[column]/sum(AMRgene[column]))*100
                
    AMRperc["mean"] = AMRperc.mean(axis=1)
    AMRperc = AMRperc.sort_values(by=["mean"], ascending = False)
    AMRgene = AMRgene.reindex(AMRperc.index, axis=0)
    others = AMRgene.iloc[20:,:].sum(axis = 'rows')
    others.name = "Others"
    AMRgene = AMRgene.iloc[:20,:]
    AMRgene = AMRgene.append(others)

    AMRgene_json = AMRgene.to_json()
    geneorder = list(AMRgene.index)
    colors = ['#a1c9f4','#b9f2f0','#ffb482','#cfcfcf','#fbafe4','#8de5a1','#029e73','#fab0e4','#949494','#ca9161','#d55e00','#d0bbff','#debb9b','#56b4e9','#0173b2','#de8f05','#ece133','#cc78bc','#ff9f9b', '#fffea3', '#999999']
    geneorder_dict = defaultdict()
        for gene,color in zip(geneorder,colors):
            geneorder_dict[gene] = {"color":color}

    genelevel_resistome_mqc["categories"] = geneorder_dict
    genelevel_resistome_mqc["data"] = AMRgene_json
    with open('genelevel_resistomechart_mqc.json', 'w') as ofh:
        json.dump(genelevel_resistome_mqc, ofh, indent=4)

if __name__ == "__main__":
    parser=argparse.ArgumentParser(description="""Parse resistome results to be top 20 AMR genes expressed in each sample""")
    parser.add_argument("resistome_results", type=str, help="Resistome results on the gene level")
    args = parser.parse_args()
    top20genes(args.resistome_results)
