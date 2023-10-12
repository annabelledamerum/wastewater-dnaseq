# aladdin-shotgun: Changelog

## v0.0.4 

### `Added`
- Visualizations for taxonomy profiling results in the report.
- Diversity analysis using Qiime2. Including exporting taxonomy results to Qiime2, merge/filter samples, alpha rarefaction, alpha/beta diversity.
- Diveristy visualizations including heatmaps, alpha rarefaction curve, alpha/beta diversity plots.
- Filtering of samples or taxa based on low read count, minimum reads per taxa, minimum sample per taxa.
- New profiler: sourmash. 
- Zymo's sourmash database, which contains host sequences. Added support scripts to separate host reads from rest, and correspoding MultiQC visualizations.
- Optional khmer trim-low-abund.py for sourmash.
- Compare with a reference dataset using Qiime2.
- A process to generate an output manifest JSON file, part of compatibility requirements for Aladdin.

### `Changed`
- Metaphan 3 changed to metaphlan 4
- User must choose one profiler-database combination, instead of running multiple profilers. Temporarily disabled profilers except sourmash and metaphlan4.
- Changed the format of sample sheet, aka. design CSV file and the code that sanity checks this file.
- Temporarily disabled support for Nanapore data.
- Tie read length filtering in preprocessing to kmer size, when sourmash is selected.
- Ignore samples that failed read QC or profiling. Let pipeline finish successfully regardless of a few bad samples. Add warnings for failed samples to report.
- Hide most parameters from Aladdin users.
- Use Aladdin report template.
- Eliminated 'perform_shortread_qc' and 'perform_shortread_complexityfilter' paramters and merged them into others.

### `Fixed`
- Sample name cleaning in report. Now one sample occupy one row in the general stats table.
- FastQC results not correctly fed to MultiQC for single-end data.

### `Removed`
- nf-core related files and code that are not required any more.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# Originally based on [nf-core/taxprofiler version v1.0.0](https://github.com/nf-core/taxprofiler/tree/1.0.0)