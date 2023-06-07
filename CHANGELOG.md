# nxf-zymobiomics_shotgun: Changelog

## v1.0.1 

- Metaphlan 3 changed to metaphlan 4
- Fixed use of uninitialized variable hostremoval_reference_index from nf-core/taxprofiler
- Added process QIIME_BIOMPREP that formats metaphlan output into BIOM format for qiime processing
- Added separate process QIIME_IMPORT for importing BIOM files into Qiime 2
- Added process QIIME_BARPLOT that performs qiime barplot on metaphlan output
- Added MultiQC module composition_barplots that graphs QIIME_BARPLOT results
- Added process QIIME_TAXMERGE to merge all identified species across QIIME2 data files; allows for later merging of qiime data files
- Added process QIIME_DATAMERGE to merge all qiime data files together
- QIIME_BARPLOT now accepts merged qza file containing data from multiple samples
- Process METAPHLAN_UNMAPPED added to track reads unmapped by Metaphlan
- MultiQC plot added to plot results of METAPHLAN_UNMAPPED
- Added process QIIME_DIVERSITYCORE to conduct diversity analysis between samples and sample groups
- Added script low_read_filter.py to QIIME_DIVERSITYCORE to remove samples with low read count from diversity analysis
- QIIME_BIOMPREP changed to output metaphlan absolute counts in addition to metaphlan relative counts for use in calculating alpha diversity
- QIIME_ALPHA process added that can calculate shannon alpha diversity for each sample
- CHECK_SAMPLESHEET can now handle group labels
- MultiQC plotting updated to plot 1) group-level comparison of alpha diversity and 2) shannon alpha diversity per sample
- MultiQC composition barplot changed to properly sort taxonomy by group size
- Filter added to QIIME_DIVERSITYCORE to remove samples from group comparison if they 1) have blank or NA groups or 2) are the only sample in a group
- Added process QIIME_BETA that runs group-level beta diversity calculations on QIIME_DIVERSITYCORE distance matrices
- MultiQC beta diversity by group plot added
- Added process QIIME_HEATMAP that plots relationships in top 20 taxa in each sample

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0 - Dodgy Dachshund [2023-03-13]

Initial release of nf-core/taxprofiler, created with the [nf-core](https://nf-co.re/) template.

- Add read quality control (sequencing QC, adapter removal and merging)
- Add read complexity filtering
- Add host-reads removal step
- Add run merging
- Add taxonomic classification
- Add taxon table standardisation
- Add post-classification visualisation

### `Added`

### `Fixed`

### `Dependencies`

### `Deprecated`
