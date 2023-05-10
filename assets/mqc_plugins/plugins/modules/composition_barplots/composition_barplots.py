#!/usr/bin/env python
""" MultiQC module to parse output from Composition """
from __future__ import print_function
from collections import OrderedDict
import logging
from multiqc import config
from multiqc.plots import bargraph, table
from multiqc.modules.base_module import BaseMultiqcModule
import seaborn as sns
import pandas as pd
import random
import numpy as np

# Initialise the logger
log = logging.getLogger(__name__)
import pandas as pd
class MultiqcModule(BaseMultiqcModule):
    def __init__(self):
        # Initialise the parent object
        super(MultiqcModule, self).__init__(
            name="Composition Barplots",
            anchor="composition_barplots"
        )
        self.comp_data = dict()
        self.comp_keys = list()
        taxonomy_level = {"level-7.csv":"Species","level-6.csv":"Genus","level-5.csv":"Family","level-4.csv":"Order","level-3.csv":"Class","level-2.csv":"Phylum", "level-1.csv":"Kingdom"}
        level_order = ["level-2.csv","level-3.csv","level-4.csv","level-5.csv","level-6.csv","level-7.csv","level-8.csv"]
        html = """<style> li:hover {cursor: pointer;}
                </style>"""
        button = ""
        data_dict = {}

        for f in self.find_log_files("composition_barplots", filehandles=True):
            df = pd.read_csv(f['f'], sep=",")
            # name = taxonomy_level[f['fn']]
            data_dict[f['fn']] = df
        final_dict = OrderedDict()

        for name in level_order:
            try:
                final_dict[name] = data_dict[name]
            except KeyError:
                continue

        order_list = ['d_', 'k_', 'p_', 'c_', 'o_', 'f_', 'g_', 's_']
        click_id_1 = ""
        click_id_2 = ""

        html_new = ""
        for s_name, df in final_dict.items():
            type=list(df.columns[0:len(df.columns)])
            df=df.sort_values(by=type, ascending=False, kind='stable', ignore_index=True)
            df=df.set_index('#OTU ID', drop = True )

            min_values = [0.1, 0.05, 0.001, 0]
            min_interface = {"0.1":"Grouping taxa < 10% into 'Others'",
                             "0.05": "Grouping taxa < 5% into 'Others'",
                             "0.001": "Grouping taxa < 0.1% into 'Others'",
                             "0": "No grouping"}
            sample_name = df.columns

            plotname = "_barplots"
            level_id = s_name.lower()
            level_id = taxonomy_level[level_id]
            level_interface = level_id.lower().capitalize()
            level_interface_id = level_id.lower().capitalize()

            button_before = f"""
                        <div class="btn-group">
                            <a type="dropdown"  class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                {level_interface} ▼
                            </a>
                            <ul class="dropdown-menu dropdown-menu-right">

                        """
            button = ""
            html_after = ""
            for min in min_values:
                for i in range(0,len(sample_name)):
                    df_new=df.drop(df.index[df[sample_name[i]] < min])
                    df_new.loc['Others'] = 100 - df_new.select_dtypes(np.number).sum()

                level_id = s_name.lower()
                level_id = taxonomy_level[level_id]
                level_interface_min = min_interface[str(min)]
                level_id = level_id.lower() + str(min).replace(".", "-")
                level_interface_id = level_id.lower().capitalize()

                color = ['#a1c9f4','#b9f2f0','#ffb482','#cfcfcf','#fbafe4','#8de5a1','#029e73','#fab0e4','#949494','#ca9161','#d55e00','#d0bbff','#debb9b','#56b4e9','#0173b2','#de8f05','#ece133','#cc78bc','#ff9f9b', '#fffea3']

                #Settings for colors
                if len(df_new.index) > 20:
                    color_21 = sns.color_palette("pastel", len(df_new.index)-20).as_hex()
                    random.shuffle(color_21)
                    color = color + color_21
                else:
                    color = color[0:len(df_new.index)]
                df_color = pd.DataFrame(index=df_new.index)
                df_color['color'] = color

                cats = df_color.to_dict('index')
                data = df_new.to_dict('series')
                self.write_data_file(data, 'composition_barplots')
                if len(data) > 0:
                    if s_name in self.comp_data:
                        log.debug("Duplicate sample name found! Overwriting: {}".   format(s_name))
                    self.add_data_source(f, s_name)
                    self.comp_data = data
                if min==0 and level_interface=="Species":
                    class_name_after = "content-table active"
                    click_id_2 = level_interface_id
                else:
                    class_name_after = "content-table active"
                    click_id_2 = level_interface_id


                config = {
                'id': 'Composition_barplots' + level_interface_id,
                'use_legend': True,
                'cpswitch': False,                       # Show the 'Counts /   Percentages' switch?
                'cpswitch_c_active': False,
                'xlab': 'Samples',                           # X axis label
                'ylab': 'Percentage',
                'ymax': 100,
                'labelSize': 8,
                'tt_decimals': 3,
                'tt_suffix': '',
                'tt_percentages': False,
                'height': 1024
                }

                barplot_html = bargraph.plot(self.comp_data, cats, pconfig=config)
                barplot_html = f"<div class='{class_name_after}' id='{level_id}'>" + barplot_html + "</div>"
                html_new += barplot_html

                button += f"""
                          <li><a type="button" thu-nga="#{level_id}" id="{level_interface_id}" onclick=handleClick(event) >{level_interface_min} </a> </li>
                      """

            html = html + button_before + button + "</ul> </div>" 
        script = """
            <script type="text/javascript">
                function funcx()
                    {{
                        document.getElementById('{a}').click();
                  
                    }}
                setTimeout(funcx, 3000)
                function follow(){{
                    contentTables = document.querySelectorAll('.content-table')
                    contentTables.forEach(contentTable => {{
                        if(contentTable.classList.contains('active')){{
                            contentTable.style='display: block';
                        }}else{{
                            contentTable.style='display: none';
                        }}
                    }});
                }}
                function handleClick(e) {{
                    var curr = e.target.getAttribute('thu-nga');
                    var elems = document.querySelectorAll('.content-table');
                    for (var i = 0; i < elems.length; i++) {{
                        // console.log(elems[i].id);
                        // console.log(elems[i].id);
                        // console.log(curr);
                        // console.log(elems[i].id.slice(-1) === curr.slice(-1)) 
                        if (elems[i].id === curr.substring(1)) {{
                            elems[i].classList.add('active');
                            // elems[i].style='display: block';
                        }} else {{
                            elems[i].classList.remove('active');
                            // elems[i].style='display: none';
                        }}
                    }}
                    follow();
                }};
                follow();
            </script>
        """.format(a=click_id_2)
        html = html + html_new + script
        script_2 = """
        """
        if len(self.comp_data) == 0:
            raise UserWarning

        self.add_section(
            name=" ",
            description="Taxa composition plots illustrate the microbial composition at different taxonomy levels from phylum to species. The interactive figure below shows the microbial composition at species level. Additional composition barplots for other taxonomy levels can be accessed by clicking on the below tabs.",
            plot=html)

    def plot_chart_html(self, cats):
        config = {
            'use_legend': True,
            'cpswitch': False,                       # Show the 'Counts / Percentages' switch?
            'cpswitch_c_active': False
        }
        return bargraph.plot(self.comp_data, cats, pconfig=config)
