#!/usr/bin/env python

import glob
import plotly.express as px
import pandas as pd
import plotly.graph_objects as go
import plotly.io as pio
import sys
import argparse

pio.templates.default = "plotly_white"
usage = "alpha_diversity_plot.py <vector>"


vector = sys.argv[1]
def alpha_diversity_plot(shannon, evenness, observed_features, output_file):
    # shannon             = "shannon_vector.tsv"
    # faith_pd            = "faith_pd_vector.tsv"
    # evenness            = "evenness_vector.tsv"
    # observed_features   = "observed_features_vector.tsv"

    df_dict = {'Shannon': shannon, 
                  'Evenness': evenness,
                  'Observed features': observed_features
                 }

    for label, method in df_dict.items():
        #prepare dataframe for each alpha diversity method
        method = pd.read_csv(method, sep = '\t')
        method = method.drop([0])
        method = method.drop(columns=['id'])
        method = method.set_axis([*method.columns[:-1], 'Value'], axis=1)
        method['Value'] = method['Value'].apply(pd.to_numeric)
        df_dict[label] = method

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
    #prepare dataframe to input into plotly
    figs = []
    buttons = []
    i = 0
    for type, df in df_dict.items():
        col=df.columns[0]
        df[col] = df[col].apply(str)
        n=len(df.groupby(df[col]))
        df.sort_values(col,inplace=True)
        for t in range(n):
            fig=px.box(color = df[col],
                              y = df.Value.to_list(),
                              x =df[col],
                              color_discrete_sequence=default_colors 
                            ).update_traces(visible=True if type=="Shannon" else False).data[t]
            figs.append(fig)
        args = [False] * len(df_dict)*(n)
        args[i*n: (i+1)*n] = [True]*n
        button = dict(label = type,
                      method = "update",
                      args=[{"visible": args}])
        buttons.append(button)
        i+=1
    updatemenus=[
           dict(
               buttons = buttons,
               type = "dropdown",
               direction = "down",
                x = 0,
                y = 1.15
           )
           ]
    plot = go.Figure(data=figs,
    layout=dict(updatemenus=updatemenus)
    )
    plot.update_xaxes(showline=True, linewidth=0.05, linecolor='#ccc')
    plot.update_yaxes(showline=True, linewidth=0.05, linecolor='#ccc')
    plot.update_traces(marker=dict(size=3.5), line=dict(width=1))
    # plot.write_html("Alpha_Diversity_mqc.html",include_plotlyjs='cdn')
    return plot.write_html(f"{output_file}", include_plotlyjs='cdn')
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--shannon", "-s", type=str, help="Input  file")
    parser.add_argument("--evenness", "-e", type=str, help="Input  file")
    parser.add_argument("--observed_features", "-of", type=str, help="Input  file")
    parser.add_argument("--output_file", "-o", type=str, help="Folder to store output files")
    args = parser.parse_args()
    alpha_diversity_plot(args.shannon, args.evenness, args.observed_features, args.output_file)
