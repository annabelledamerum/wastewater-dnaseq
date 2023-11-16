#!/usr/bin/env python
import re
import numpy as np
import pandas as pd
import argparse
from io import StringIO
import plotly.express as px
import plotly.graph_objects as go
import plotly.io as pio

def extract_pcoa(fn, samples):
    coordinates = ''
    correct_section = False
    with open(fn) as fh:
        # Control which section of the file to search
        # Between these two lines
        for line in fh:
            if re.match(r"Site\t\d+\t\d+", line):
                correct_section = True
            elif re.match(r"Biplot\t\d+\t\d+", line):
                correct_section = False
            if correct_section:
                if line.startswith(samples):
                    coordinates += line
    data = pd.read_csv(StringIO(coordinates), sep="\t", header=None)
    data = data.iloc[:, 0:4]
    data.columns = ["sampleid", "PC1", "PC2", "PC3"]
    return data

def addjitter(arr):
        stdev = .01*(max(arr)-min(arr))
        return arr + np.random.randn(len(arr))*stdev


def pcoa_plot(ordinations, metadata, output):

    #Set the initial variables
    traces = []
    buttons = []
    pio.templates.default = "plotly_white"
    
    # Default colors
    default_colors = [
        "#7cb5ec",
        "#434348",
        "#90ed7d",
        "#f7a35c",
        "#8085e9",
        "#f15c80",
        "#e4d354",
        "#2b908f",
        "#f45b5b",
        "#91e8e1",
    ]

    # File name to metric translation
    index_name = {
        'bray_curtis_pcoa_ordination.txt': 'Bray-Curtis',
        'jaccard_pcoa_ordination.txt': 'Jaccard'
        }
    
    # Get all sample IDs to help parse the ordination txt file
    meta = pd.read_csv(metadata, sep="\t")
    samples = tuple(meta["sampleid"].tolist())

    for i, fn in enumerate(ordinations):
        # Get the coordinates from oridination txt file
        data = extract_pcoa(fn, samples)
        # Add metadata to it
        data = data.merge(meta, on="sampleid", how="inner")
        # Put Aladdin reference data to front
        data['ref'] = data['group'].str.contains(pat='Ref-')
        data = data.sort_values(by=['ref', 'group'])
        data = data.drop('ref', axis=1)

        # Construct the plot
        name = index_name[fn]
        n_cols = data['group'].nunique()
        args = [False] * len(ordinations) * n_cols
        args[i*n_cols: (i+1)*n_cols] = [True] * n_cols
        button = dict(
            label = name,
            method = "update",
            args = [{"visible": list(args)}]
            )
        buttons.append(button)

        sampleinfo = data[["sampleid", "group"]]
        data = data[["PC1", "PC2", "PC3"]]
        #df must be rounded for accurate identification of duplicate rows
        data = round(data, ndigits=6)
        jitterarray = data.copy()
        for coords in ["PC1", "PC2", "PC3"]:
            jitterarray[coords] = addjitter(data[coords])

        isdup = data.duplicated(subset = ["PC1", "PC2", "PC3"], keep= False)
        for coords in ["PC1", "PC2", "PC3"]:
            for element, num in zip(isdup, isdup.index):
                if element:
                    data[coords][num] = jitterarray[coords][num]
        data[["sampleid", "group"]] = sampleinfo

        arr = data[["PC1", "PC2", "PC3"]].to_numpy()
        for j in range(n_cols):
            fig = px.scatter_3d(
                arr,
                hover_name=data['sampleid'],
                x=0, y=1, z=2,
                color=data['group'],
                color_discrete_sequence=default_colors
                )
            trace = fig.update_traces(
                marker=dict(
                    size=7,
                    line=dict(width=1,color='#ecf0f1')
                    ), 
                visible=True if name=="Bray-Curtis" else False
                ).data[j]
            traces.append(trace)

    #Setting dropdown menu
    updatemenus=[dict(
        buttons = buttons,
        type = "dropdown",
        direction = "down",
        )]
    
    fig = go.Figure(
        data=traces,
        layout=dict(updatemenus=updatemenus)
        )
    
    fig.update_layout(
        title = 'Beta diversity',
        scene = dict(
            xaxis_title='PC1',
            yaxis_title='PC2',
            zaxis_title='PC3'
            ),
        margin=dict(r=20, b=20, l=20, t=40)
        )
                        
    #Edit output file name for mutliqc search pattern
    pio.write_html(fig, output, include_plotlyjs='cdn')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Make a plotly plot of PCoA results from Qiime2")
    parser.add_argument(dest="ordinations", type=str, nargs="+", help="PCoA ordination files from Qiime export")
    parser.add_argument("-m", "--metadata", dest="metadata", type=str, required=True, help="Metadata file")
    parser.add_argument("-o", "--output", dest="output", default="beta_diversity_mqc.html", help="Output file name")
    args = parser.parse_args()
    pcoa_plot(args.ordinations, args.metadata, args.output)
