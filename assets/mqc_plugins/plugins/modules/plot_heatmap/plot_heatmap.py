#!/usr/bin/env python

"""MultiQC plugin module to plot a heatmap for top taxa"""

from __future__ import print_function
import logging
from multiqc import config
from multiqc.plots import heatmap
from multiqc.modules.base_module import BaseMultiqcModule
import pandas as pd
import numpy as np
from collections import OrderedDict
import os

# Initialise the main MultiQC logger
log = logging.getLogger("multiqc")

class MultiqcModule(BaseMultiqcModule):
    def __init__(self):
        # Halt execution if we've disabled the plugin
        if config.kwargs.get("disable_plugin", False) is True:
            return None

        # Initialise the parent module Class object
        super(MultiqcModule, self).__init__(
            name="Taxonomy Abundance Heatmap", target="", anchor="plot_heatmap"
        )
        self.css = {
            "assets/style.css": os.path.join(os.path.dirname(__file__), "..", "style.css")
        }

        # Get the top_taxa param from conifg
        top_taxa = getattr(config, "top_taxa", 20)
        
        # Initialize the data dict
        taxonomy_level = OrderedDict({
            "Kingdom_taxo_heatmap.csv": "Kingdom",
            "Phylum_taxo_heatmap.csv": "Phylum",
            "Class_taxo_heatmap.csv": "Class",
            "Order_taxo_heatmap.csv": "Order",
            "Family_taxo_heatmap.csv": "Family",
            "Genus_taxo_heatmap.csv": "Genus",
            "Species_taxo_heatmap.csv": "Species"
        })
        data_dict = OrderedDict([(k, None) for k in taxonomy_level.keys()])

        # Find the data files
        for f in self.find_log_files("plot_heatmap", filehandles=True):
            if f["fn"] in data_dict:
                self.add_data_source(f)
                # Parse the data file
                parsed_data = pd.read_csv(f["f"], sep="\t", index_col=0)
                if len(parsed_data):
                    data_dict[f["fn"]] = parsed_data
                else:
                    log.debug("Could not parse heatmap data in {}".format(f["fn"]))
                    raise UserWarning
            else:
                log.warning("{} not recogized by heatmap barplot module".format(f['fn']))

        # Nothing found - raise a UserWarning to tell MultiQC
        if len(data_dict) == 0:
            log.debug("Could not find any reports in {}".format(config.analysis_dir))
            raise UserWarning
        
        log.info("Found {} heatmap reports".format(len(data_dict)))

        # add button in heatmap plot
        button = ""
        html = ""
        html_new = ""
        click_id = ""
        for filename, data in data_dict.items():
            if data is None:
                continue
            typedata_dropdown = {
                "Log_normalized": "Log-transformed and normalized",
                "Relative_abundance": "Relative abundance",
            }
            taxa_button = taxonomy_level[filename]
            button_before = f"""
                        <div class="btn-group">
                            <a type="dropdown"  class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                {taxa_button} ▼
                            </a>
                            <ul class="dropdown-menu dropdown-menu-right">
                        """
            button = ""

            for typedata, label in typedata_dropdown.items():
                taxa_button_id = (taxa_button + "_" + typedata).lower().capitalize()
                click_id = taxa_button_id
                pconfig = {
                        "id": "Heatmap_plot_" + taxa_button_id,
                        "xTitle": "Samples",
                        "square": False,
                        "title": taxa_button,
                        "decimalPlaces": 3,
                    }
                plot_data = data
                if typedata == "Log_normalized":
                    if (plot_data>0).all().all():
                        pseudocount = 0
                    else:
                        pseudocount = plot_data.apply(lambda x:x[x>0].min()).min() / 2
                    plot_data = np.log10(plot_data+pseudocount)
                    plot_data = plot_data - plot_data.mean(axis=0)
                    # Center the color scale and set min/max
                    min_max = min(max(abs(plot_data.min().min()), plot_data.max().max()), 3)
                    pconfig["min"] = -min_max
                    pconfig["max"] = min_max
                else:
                    pconfig["colstops"] = [
                        [0, "#fdefef"],
                        [0.1, "#fcdfdf"],
                        [0.2, "#fbcfcf"],
                        [0.3, "#f9bfbf"],
                        [0.4, "#f8b0b0"],
                        [0.5, "#f7a0a0"],
                        [0.6, "#f59090"],
                        [0.7, "#f48080"],
                        [0.8, "#f37070"],
                        [0.9, "#f26161"],
                        [1, "#d73027"],
                    ]
                self.write_data_file(plot_data, "taxo_heatmap")

                heatmap_plot_html = heatmap.plot(
                    plot_data.values.tolist(),
                    plot_data.columns.tolist(),
                    plot_data.index.tolist(),
                    pconfig,
                )
                heatmap_plot_html = (
                    f"<div class='content-plot active' id='{taxa_button_id}'>"
                    + heatmap_plot_html
                    + "</div>"
                )
                html_new += heatmap_plot_html
                button += f"""
                          <li class="dropdown-items"><a class="dropdown-items content" type="button"  href="#{taxa_button_id}" id="{taxa_button_id}" onclick=heatmapClick(event)>{label} </a> </li>
                      """
                
            html += button_before + button + "</ul> </div>"
        script_heatmap = """
            <script type="text/javascript">
                function funcx() {{
                    document.getElementById('{a}').click();
                }}
                function heatmap() {{
                    console.log("start setting display...")
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
                    var value = e.target.getAttribute('href');
                    var plot = document.querySelectorAll('.content-plot');
                    for (var i = 0; i < plot.length; i++) {{
                        if (plot[i].id === value.substring(1)) {{
                            plot[i].classList.add('active');
                        }} else {{
                            plot[i].classList.remove('active');
                        }}
                    }}
                    heatmap();
                }}
                function handleLable() {{
                    console.log("start function handle label...");
                    var label = document.querySelectorAll(".hc-plot.hc-heatmap g.highcharts-axis-labels.highcharts-xaxis-labels>text>tspan") 
                    console.log("labels: ", label);
                    var found = Array.from(label).find((node) => node.innerHTML.includes("…"));
                    console.log("Found: ", found);
                    if (found) {{
                        for (var i = 0; i < label.length; i++) {{
                            label[i].parentElement.style.fontSize = "9px"
                            label[i].parentElement.style.translate = "1.5%"
                            if (label[i].innerHTML.includes("…")) {{
                                console.log("found ... items: ", label[i]);
                                label[i].innerHTML = label[i].parentElement.lastChild.innerHTML;
                            }}
                        }}
                    }}
                }}
                setTimeout(() => {{
                    funcx();
                    handleLable();
                }}, 3000);
                heatmap();
                window.addEventListener("resize", (event) => {{
                    console.log("resize");
                    setTimeout(handleLable, 1000);
                }}
                ); 
            </script>
        """.format(
            a=click_id
        )
        html = html + html_new + script_heatmap
        self.add_section(
            description=(
                "The taxonomy abundance heatmap is a plot of the relative abundance of taxa (ranging from 0-1) for each sample and is a quick way to identify patterns of microbial distribution amongst samples. "
                "Each row represents the relative abundance of each taxon, with the taxonomy ID shown on the right. "
                "Each column represents a sample, with the sample ID shown at the bottom. "
                "Each box, or tile, on the heatmap represents relative abundance, colored according to the key scale on the far right of the plot. <br>"
                "Hierarchical clustering is performed on samples and taxa based on the Euclidean distance of log-transformed relative abundance. "
                "More similar samples and taxa are closer to each other. "
                "The heatmaps are made using the top {} most abundant taxa of each sample group. Heatmaps are only made when there are >= 5 taxa at a taxonomic rank.<br>"
                "Please note that long taxa names (right of plot) may be partially obscured, however full details can be observed by hovering the mouse cursor over each tile. <br>"
                "Heatmaps at different taxonomic ranks can be accessed by clicking the buttons above the plot. "
                "By default, the plot shows relative abundance values, however results can be displayed as log-transformed and normalized. "
                "Relative abundances are log10 transformed and centered on each row. "
                "This view can be activated by selecting 'Log_normalized' from the drop down-list that appears when clicking the taxonomic rank buttons at the top of the plot."
            ).format(top_taxa),
            plot=html,
        )