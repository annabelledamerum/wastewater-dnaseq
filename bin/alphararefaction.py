#!/usr/bin/env python

import argparse
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
import plotly.io as pio

def plot_alpha_rarefaction(categories, output_file):

    pio.templates.default = "plotly_white"

    n_groups = 0
    for category, record in categories.items():
        # Read the input file
        data = pd.read_csv(record['input'])
        # Melt the data into one data point per row
        melted_data = pd.melt(data, id_vars = ['group','sample-id'],
                              value_vars = data.columns[1:-1], var_name='depth_iter', value_name = 'metric')
        # Drop all the NA rows
        melted_data = melted_data.dropna()
        # Extract depth and iter from the depth-iteration ID, always in the form of 'depth-<n>_iter-<k>'
        melted_data['depth'] = melted_data['depth_iter'].map(lambda x:int(x.split('_')[0].replace('depth-','')))
        melted_data['iter'] = melted_data['depth_iter'].map(lambda x:int(x.split('_')[1].replace('iter-','')))
        # Take median among samples at the same depth and iteration
        plot_data = melted_data.groupby(['depth','group','iter']).agg({'metric':'median'})
        # Sort rows, round to 2 decimals
        plot_data = plot_data.reset_index()
        plot_data['ref'] = plot_data['group'].str.contains(pat='Ref-')
        plot_data = plot_data.sort_values(['ref','group','depth'])
        plot_data['metric'] = plot_data['metric'].round(2)
        # Record how many groups are in the data
        if n_groups:
            assert n_groups == plot_data['group'].nunique(), "Number of groups not consistent between groups"
        else:
            n_groups = plot_data['group'].nunique()
        categories[category]['plot_data'] = plot_data

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

    figs = []
    buttons = []
    i = 0
    for category, record in categories.items():
        fig= px.box(
            data_frame = record['plot_data'],
            x='depth',
            y='metric',
            color='group',
            color_discrete_sequence=default_colors
        ).update_traces(visible=True if category=="Shannon" else False)
        figs += fig.data
        args = [False] * len(categories) * n_groups
        args[i*n_groups : (i+1)*n_groups] = [True] * n_groups
        i += 1
        button = dict(label = category,
                      method = "update",
                      args = [{"visible": args}])
        buttons.append(button)

    updatemenus=[
        dict(
            buttons = buttons,
            type = "dropdown",
            direction = "down",
            x = 0,
            y = 1.15
        )
    ]

    plot = go.Figure(data=figs, layout=dict(updatemenus=updatemenus))
    plot.update_xaxes(showline=True, linewidth=0.05, linecolor='#ccc', title_text="Depth sequencing", title_standoff = 0)
    plot.update_yaxes(showline=True, linewidth=0.05, linecolor='#ccc', title_text="Metric")
    plot.update_layout(legend=dict(groupclick="togglegroup",traceorder="reversed+grouped"))
    plot.update_traces(marker=dict(size=3.5), line=dict(width=1))
    plot.write_html(output_file, include_plotlyjs='cdn')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="""Make a plot for alpha rarefaction curve using plotly""")
    parser.add_argument("-o", "--observed_features", dest="observed_features",  required=True,
                        help="Observed features CSV file")
    parser.add_argument("-s", "--shannon", dest="shannon", required=True,
                        help="Shannon CSV file")
    parser.add_argument("-w", "--output_file", dest="output_file", required=True,
                        help="Output HTML file name")
    args = parser.parse_args()
    categories = {
        'Shannon' : { 'input' : args.shannon },
        'Observed features' : { 'input' : args.observed_features }
    }
    plot_alpha_rarefaction(categories, args.output_file)
