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

    #prepare dataframe shannon
    shannon = pd.read_csv(shannon, sep = '\t')
    shannon = shannon.drop([0])
    shannon=shannon.drop(columns=['id'])
    shannon=shannon.set_axis([*shannon.columns[:-1], 'Value'], axis=1)
    shannon ['Value'] = shannon['Value'].apply(pd.to_numeric)

    #prepare dataframe evenness
    evenness = pd.read_csv(evenness, sep = '\t')
    evenness = evenness.drop([0])
    evenness=evenness.drop(columns=['id'])
    evenness=evenness.set_axis([*evenness.columns[:-1], 'Value'], axis=1)
    evenness ['Value'] = evenness['Value'].apply(pd.to_numeric)

    #prepare dataframe observed_features
    observed_features = pd.read_csv(observed_features, sep = '\t')
    observed_features = observed_features.drop([0])
    observed_features=observed_features.drop(columns=['id'])
    observed_features=observed_features.set_axis([*observed_features.columns[:-1], 'Value'], axis=1)
    observed_features ['Value'] = observed_features['Value'].apply(pd.to_numeric)
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
    df_dict = {'Shannon': shannon,
               'Evenness' : evenness,
               'Observed features':observed_features,
               }
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
