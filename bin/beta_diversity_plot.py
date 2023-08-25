#!/usr/bin/env python
import sys
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
from sklearn.decomposition import PCA
import plotly
import plotly.io as pio

pio.templates.default = "plotly_white"
usage = """beta_diversity_plot.py <condition> <metadata>"""

def addjitter(arr):
    stdev = .01*(max(arr)-min(arr))
    return arr + np.random.randn(len(arr))*stdev

#--- Check and read arguments ---#

condition = sys.argv[1]
metadata = sys.argv[2]
#Setting input file name for 4 matrices

bray            = "bray_curtis_pcoa_results.tsv"
jaccard         = "jaccard_pcoa_results.tsv"

#Set the output file name
out_file_name        = "beta_diversity_plot-groups.html"

#Set the input file
df_bray         = pd.read_csv(bray          , sep="\t", header = None)
df_jaccard      = pd.read_csv(jaccard       , sep="\t", header = None)

metadata        = pd.read_csv(metadata      , sep="\t")

input_dict = { 'Bray Curtis'       : df_bray,
            'Jaccard'           : df_jaccard,
             }

#Set the initial variables
traces = []
buttons =[]
n = 0

for name, df in input_dict.items():
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
    df=df.iloc[:,0:4]
    df.columns = ["sampleid", "PC1", "PC2", "PC3"]
    df = df.merge(metadata, on='sampleid', how="inner")
    df['ref'] = df['group'].str.contains(pat='Ref-')
    df.sort_values(by=['ref', 'group'],inplace=True)
    df.drop('ref', axis=1, inplace=True)
    category_name = "group"
    n_cols = len(df[category_name].unique())
    args = [False] * len(input_dict)*(n_cols)
    args[n*n_cols: (n+1)*n_cols] = [True]*n_cols
    button = dict(label = name,
            method = "update",
            args=[{"visible": list(args)}])
    buttons.append(button)

    #Adding jitter to PCs
    sampleinfo = df[["sampleid", "group"]]
    df = df[["PC1", "PC2", "PC3"]]
    #df must be rounded for accurate identification of duplicate rows
    df = round(df, ndigits=6)
    jitterarray = df.copy()
    for coords in ["PC1", "PC2", "PC3"]:
        jitterarray[coords] = addjitter(df[coords])

    isdup = df.duplicated(subset = ["PC1", "PC2", "PC3"], keep= False)
    for coords in ["PC1", "PC2", "PC3"]:
        for element, num in zip(isdup, isdup.index):
            if element:
                df[coords][num] = jitterarray[coords][num]
    df[["sampleid", "group"]] = sampleinfo
    arr = df.to_numpy()

    for i in range(n_cols):
        fig = px.scatter_3d(arr,
                    hover_name= df["sampleid"],
                    x=0, y=1, z=2,
                    color=df['group'],
                    color_discrete_sequence=default_colors)
        trace = fig.update_traces(marker=dict(size=7,
                                    line=dict(width=1,
                                        color='#ecf0f1')), visible=True if name=="Bray Curtis" else False).data[i]
        traces.append(trace)
    n+=1

#Setting dropdown menu
updatemenus=[
       dict(
           buttons = buttons,
           type = "dropdown",
           direction = "down",
       )
       ]

fig = go.Figure(data=traces,
layout=dict(updatemenus=updatemenus)
)
fig.update_layout(title='Beta diversity',scene = dict(
                    xaxis_title='PC1',
                    yaxis_title='PC2',
                    zaxis_title='PC3'),
                    margin=dict(r=20, b=20, l=20, t=40))
                    
#Edit output file name for mutliqc search pattern
plotly.io.write_html(fig, out_file_name, include_plotlyjs='cdn')
