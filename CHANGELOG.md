# nf-core/taxprofiler: Changelog

## v1.0.1 

- metaphlan 3 changed to metaphlan 4
- fixed use of uninitialized variable hostremoval_reference_index
- qiime process added to pipeline
- qiime changed to qiime2
- qiime2 composition barplot added to MultiQC report
- MultiQC barplot changed to work with multiple samples
- MultiQC barplot now sorts taxonomy by group size
- Reads unmapped by MultiQC bar chart added
- Shannon alpha diversity per sample bar chart added
- Between-group comparison of alpha diversity added



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
