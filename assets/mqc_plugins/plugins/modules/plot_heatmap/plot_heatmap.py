#!/usr/bin/env python

"""MultiQC plugin module to plot a heatmap for rel-table-ASV_with-DADA2-tax"""

from __future__ import print_function
from doctest import script_from_examples
import logging
from multiqc import config
from multiqc.plots import heatmap
from multiqc.modules.base_module import BaseMultiqcModule
import pandas as pd
from collections import OrderedDict
import scipy.stats as stats

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(BaseMultiqcModule):

    def __init__(self):

        # Halt execution if we've disabled the plugin
        if config.kwargs.get('disable_plugin', False) is True:
            return None

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name = "Taxonomy Abundance Heatmap",
            target = "",
            anchor = "plot_heatmap"
        )

        # Initialize the data dict
        self.plot_heatmap_data = dict()
        # Find the data files
        for f in self.find_log_files("plot_heatmap", filehandles=True):
            self.add_data_source(f)
            # Parse the data file
            parsed_data = pd.read_csv(f["f"], sep="\t", index_col=0)
            if len(parsed_data):
                self.plot_heatmap_data[f["fn"]] = parsed_data
            else:
                log.debug("Could not parse heatmap data in {}".format(f["fn"]))
                raise UserWarning

        # Filter out samples matching ignored sample names
        self.plot_heatmap_data = self.ignore_samples(self.plot_heatmap_data)

        # Nothing found - raise a UserWarning to tell MultiQC
        if len(self.plot_heatmap_data) == 0:
            log.debug("Could not find any reports in {}".format(config.analysis_dir))
            raise UserWarning

        log.info("Found {} heatmap reports".format(len(self.plot_heatmap_data)))
        #add button in heatmap plot
        html = """<style> li:hover {cursor: pointer;}
                </style>"""
        button = ""

        html_new = ""
        click_id = ""
        taxanomy_level = ['Kingdom_taxo_heatmap.csv','Phylum_taxo_heatmap.csv','Class_taxo_heatmap.csv', 'Order_taxo_heatmap.csv', 'Family_taxo_heatmap.csv','Genus_taxo_heatmap.csv','Species_taxo_heatmap.csv']
        final_dict = OrderedDict()
        for name in taxanomy_level:
            try:
                final_dict[name] = self.plot_heatmap_data[name]
            except KeyError:
                continue
        for filename, data in final_dict.items():
            typedata = ["Absolute_abundance", "Z-score"]
            typedata_dropdown = {"Absolute_abundance":"Absolute_abundance",
                   "Z-score":"Z-score"
                             }
            taxa_button = filename.replace("_taxo_heatmap.csv","")
            taxa_button_interface = taxa_button.capitalize()            
            button_before = f"""
                        <div class="btn-group">
                            <a type="dropdown"  class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                {taxa_button_interface} ▼
                            </a>
                            <ul class="dropdown-menu dropdown-menu-right">
                        """
            button = ""

            for typedata in typedata_dropdown:
                if typedata == "Z-score":
                    data = data.apply(stats.zscore)
                else:
                    data = data
                taxa_button = filename.replace("_taxo_heatmap.csv","")
                taxa_button_interface = taxa_button.capitalize() 
                taxa_interface_typedata = typedata_dropdown[str(typedata)]
                taxa_button_id = taxa_button_interface + "_" + taxa_interface_typedata
                taxa_button_interface_id = taxa_button_id.lower().capitalize()
                self.write_data_file(data, 'taxo_heatmap')
    
                if typedata=="Absolute_abundance":
                    class_name_before = "content-plot active"
                else:
                    click_id = taxa_button_interface_id
                pconfig = {
                    "id": "Heatmap_plot_" + taxa_button_id,
                    "xTitle": "Samples",
                    "square": False,
                    "title": taxa_button,
                    'decimalPlaces': 3
                    }
                heatmap_plot_html = heatmap.plot(
                                    data.values.tolist(), data.columns.tolist(), data.index.tolist(), pconfig)
                heatmap_plot_html =  f"<div class='{class_name_before}' id='{taxa_button_id}'>" + heatmap_plot_html + "</div>"
                
                html_new += heatmap_plot_html 

                button += f"""
                          <li><a type="button" tham-lee="#{taxa_button_id}" id="{taxa_button_interface_id}" onclick=heatmapClick(event) >{taxa_interface_typedata} </a> </li>
                      """
            html = html +  button_before + button + "</ul> </div>"
        script_heatmap = """
            <script type="text/javascript">
                function funcx()
                    {{
                        document.getElementById('{a}').click();
                    }}
                setTimeout(funcx, 3000)
                function heatmap(){{
                    contentPlots = document.querySelectorAll('.content-plot')
                    contentPlots.forEach(contentPlot => {{
                        if(contentPlot.classList.contains('active')){{
                            contentPlot.style='display: block';
                        }}else{{
                            contentPlot.style='display: none';
                        }}
                    }});
                }}
                function heatmapClick(e) {{
                    var value = e.target.getAttribute('tham-lee');
                    var plot = document.querySelectorAll('.content-plot');
                    for (var i = 0; i < plot.length; i++) {{
                        if (plot[i].id === value.substring(1)) {{
                            plot[i].classList.add('active');
                        }} else {{
                            plot[i].classList.remove('active');
                        }}
                    }}
                    heatmap();
                }};
                heatmap();
            </script>
        """.format(a=click_id)
        html = html +  html_new + script_heatmap
        self.add_section(
            description= ("The taxonomy abundance heatmap with sample clustering is a quick way to help identify patterns of microbial distribution among samples.<br>"
            "The following heatmap shows the microbial composition of the samples at the species level with the most abundant species identified. Each row represents the abundance for each taxon, with the taxonomy ID shown on the right. Each column represents the each sample, with the sample ID shown at the bottom.<br>"
            "Hierarchical clustering is performed on samples based on Euclidean method. Hierarchical clustering was also performed on the taxa so that taxa with similar distributions are grouped together. The heatmap shows the top 20 taxa of each group. <br>"
            "Heatmaps at different taxonomic levels and with sample clustering can be found by clicking the button above the figure."
            ),
            plot = html
            )

