#!/usr/bin/env python

from setuptools import setup, find_packages


_version = '0.0.1'

setup(
    name='multiqc_custom_plugins',
    version=_version,
    description="Custom MultiQC plugins for zymobiomics pipeline",
    packages=find_packages(),
    include_package_data=True,
    install_requires=['multiqc==1.14'],
    entry_points={
        'multiqc.templates.v1': [
            'default = multiqc.templates.default'
        ],
        'multiqc.modules.v1': [
            # 'fastqc = plugins.modules.fastqc_ext:MultiqcModule',
            #'cutaidapt = plugins.modules.cutadapt_ext:MultiqcModule',
            'plot_heatmap = plugins.modules.plot_heatmap:MultiqcModule',
            #'ancombc_heatmap = plugins.modules.ancombc_heatmap:MultiqcModule',
            #'ancombc_lfc = plugins.modules.ancombc_lfc:MultiqcModule',
            'composition_barplots = plugins.modules.composition_barplots:MultiqcModule'
            # 'download = plugins.modules.download:MultiqcModule'
        ],
        'multiqc.hooks.v1': [
            #'before_config = plugins.utils.hooks:before_config',
            'execution_start = plugins.utils.hooks:execution_start'
            #'after_modules = plugins.utils.hooks:after_modules'
            # 'before_config = plugins.custom_code:plugin_before_config',
            # 'execution_start = plugins.custom_code:plugin_execution_start'
        ],
    }
)
